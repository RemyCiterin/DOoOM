//! this file define the system entry when using M-mode directly

const std = @import("std");
const Params = @import("params.zig");
const RV = @import("riscv.zig");
const uart = @import("print.zig").writer;
const print = @import("print.zig").putString;
const putChar = @import("print.zig").putChar;
const getChar = @import("print.zig").getChar;
const Spinlock = @import("spinlock.zig");
const Syscall = @import("syscall.zig");
const Process = @import("process.zig");
const Screen = @import("screen.zig");
const Clint = @import("clint.zig");
const Manager = Process.Manager;

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
        "[" ++ @tagName(scope) ++ " at time {}] ";

    uart.print(prefix, .{cycle}) catch unreachable;
    uart.print(format, args) catch unreachable;
    uart.print("\n", .{}) catch unreachable;
}

pub inline fn hang() noreturn {
    putChar(0);
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

extern var kalloc_buffer: [31 * 1024 * 1024]u8;

pub export fn handler(manager: *Manager) callconv(.C) void {
    const pid = manager.current;

    if (RV.mcause.read().INTERRUPT == 0) {
        manager.write(pid, .pc, manager.read(pid, .pc) + 4);
        manager.syscall() catch unreachable;
    } else if (RV.mip.read().MTIP == 1) {
        Clint.setNextTimerInterrupt();
        manager.next();
    } else {
        RV.mip.modify(.{ .MEIP = 0 });
    }
}

pub export fn kernel_main() callconv(.C) void {
    print("=== Start DOoOM ===\n");

    print(
        \\Dooom Out Of Order Machine:
        \\  DOoOM is an out of order RiscV with the goal of
        \\  runing DOOM on it!
        \\
        \\  It support the rv32i isa with machine mode,
        \\  is fine-tuned to run on the ULX3S board at
        \\  25kHz, use a 8kB 2-ways cache and has an
        \\  interface for UART, SDRAM and HDMI
    );

    putChar(10);

    var fba = std.heap.FixedBufferAllocator.init(&kalloc_buffer);
    const allocator = fba.allocator();

    var manager = Manager.init(allocator);
    _ = manager.new(@intFromPtr(&user_main), 512, null) catch unreachable;

    RV.mstatus.modify(.{ .MPIE = 1 });
    RV.mie.modify(.{ .MEIE = 1, .MTIE = 1 });

    Clint.setNextTimerInterrupt();

    while (true) {
        manager.run();
        handler(&manager);
    }

    @panic("unreachable");
}

pub var measureLock = Spinlock{};

pub fn measure(
    logger: anytype,
    pid: usize,
    func: anytype,
    args: anytype,
) @TypeOf(@call(.auto, func, args)) {
    var cycle = RV.mcycle.read();
    var instret = RV.minstret.read();
    const output = @call(.auto, func, args);
    instret = RV.minstret.read() - instret;
    cycle = RV.mcycle.read() - cycle;

    measureLock.lock();
    defer measureLock.unlock();

    logger.info("pid: {} cycle: {} instret: {}", .{ pid, cycle, instret });

    return output;
}

pub fn syscall0(index: usize) void {
    if (index <= 4) return Syscall.yield();
    Syscall.exec(@intFromPtr(&user_main), 512, null);
}

pub export fn user_main(pid: usize) callconv(.C) noreturn {
    const logger = std.log.scoped(.user);

    if (pid == 0) {
        var pixel = Screen.Pixel{ .red = 0b111 };
        pixel.fill();

        //pixel.fillRectangle(101, 100, 137, 300);

        //pixel = .{ .blue = 0b11, .green = 0b111 };

        //pixel.drawRectangle(101, 100, 137, 300);
        //pixel.drawRectangle(102, 101, 136, 299);
        //pixel.drawRectangle(103, 102, 135, 298);
    }

    var index: usize = 0;
    while (true) : (index += 1) {
        measure(logger, pid, syscall0, .{index});
    }

    while (true) {}
}
