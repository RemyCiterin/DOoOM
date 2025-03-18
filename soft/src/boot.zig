const std = @import("std");

const RV = @import("riscv.zig");

const UART = @import("print.zig");

const Config = @import("config.zig");

// MMC interface to an SD-card
const SdCard = @import("sdcard.zig");

pub const std_options = .{
    .log_level = .info,
    .logFn = log,
};

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    _ = level;
    const cycle: usize = RV.mcycle.read();

    const prefix =
        "[BOOT:" ++ @tagName(scope) ++ " at time {}] ";

    UART.writer.print(prefix, .{cycle}) catch unreachable;
    UART.writer.print(format, args) catch unreachable;
    UART.writer.print("\n", .{}) catch unreachable;
}

pub inline fn hang() noreturn {
    // Used to stop the execution in case of a simulation
    UART.putChar(0);
    while (true) {}
}

pub fn panic(
    message: []const u8,
    _: ?*std.builtin.StackTrace,
    _: ?usize,
) noreturn {
    std.log.err("Error: KERNEL PANIC \"{s}\"\n\n", .{message});
    hang();
}

pub fn fence() void {
    asm volatile (
        \\fence
        \\fence.i
        ::: "memory");
}

pub fn invalidate(buf: []u8) void {
    var i: u32 = 0;

    while (i < buf.len) : (i += 4) {
        const addr: u32 = @intFromPtr(&buf[i]);
        asm volatile ("cbo.clean 0(%[addr])"
            :
            : [addr] "r" (addr),
            : "memory"
        );
    }
}

pub export fn kernel_main() callconv(.C) void {
    const logger = std.log.scoped(.bootloader);
    logger.info("BOOT start!", .{});

    SdCard.init();

    const blocks = 10000;

    for (0..blocks) |i| {
        if (i % 100 == 0)
            try UART.writer.print("\rCopy sector {}", .{i});
        const base: u32 = Config.kernel_base + 512 * i;

        var buf: [*]u8 = @ptrFromInt(base);
        SdCard.readBlock(i, buf[0..512]) catch unreachable;

        invalidate(buf[0..512]);
        fence();
    }

    try UART.writer.print(
        "\nBoot finish, jump to address {x}\n",
        .{Config.kernel_base},
    );

    // Ensure that all the invalidations finish
    asm volatile (
        \\jalr %[addr]
        :
        : [addr] "r" (Config.kernel_base),
        : "memory"
    );

    while (true) {}
}
