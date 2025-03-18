//! this file define the system entry when using M-mode directly

const std = @import("std");
const Allocator = std.mem.Allocator;

// Control and status registers description
const RV = @import("riscv.zig");

// UART mmio interface
const UART = @import("print.zig");
const print = UART.putString;

// User only memory protection (ensure that no other process will access the
// data)
const Spinlock = @import("spinlock.zig");

// User only syscall interface, must not be user by the kernel
const Syscall = @import("syscall.zig");

// Process managment
const Process = @import("process.zig");
const Manager = Process.Manager;

// 640*480 screen using a 256 color palette
const Screen = @import("screen.zig");

// MMC interface to an SD-card
const SdCard = @import("sdcard.zig");

// Control over timer and software interrupts
const Clint = @import("clint.zig");

// User-mode performance benchmarks
const Bench = @import("bench.zig");

// Protected user memory allocator
const UserAlloc = @import("user_alloc.zig");

pub const std_options = .{
    .log_level = .info,
    .logFn = log,
};

// Log informations provided by the kernel. As example:
// ```zig
//  const logger = std.log.scoped(.my_scope);
//
//  pub fn foo() void {
//      // visible at runtime
//      logger.info("run foo {}", .{42});
//  }
//
//  pub fn bar() void {
//      // visible only in debug mode
//      logger.debug("run bar", .{});
//  }
// ```
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

extern var kalloc_buffer: [31 * 1024 * 1024]u8;

// Main kernel allocator
pub var kalloc: Allocator = undefined;
pub var malloc: Allocator = undefined;

pub export fn handler(manager: *Manager) callconv(.C) void {
    const pid = manager.current;

    if (RV.mcause.read().INTERRUPT == 0) {
        manager.write(pid, .pc, manager.read(pid, .pc) + 4);
        manager.syscall() catch unreachable;
    } else if (RV.mip.read().MTIP == 1) {
        //try UART.writer.print("timmer interrupt\n", .{});
        Clint.setNextTimerInterrupt();
        manager.next();
    } else {
        RV.mip.modify(.{ .MEIP = 0 });
    }
}

pub export fn kernel_main() align(16) callconv(.C) void {
    const logger = std.log.scoped(.kernel);
    logger.info("=== Start DOoOM ===", .{});

    logger.info(
        \\Dooom Out Of Order Machine:
        \\  DOoOM is an out of order RiscV with the goal of
        \\  runing DOOM on it!
        \\
        \\  It support the rv32i isa with machine mode,
        \\  is fine-tuned to run on the ULX3S board at
        \\  25kHz, use a 8kB 2-ways cache and has an
        \\  interface for UART, SDRAM, MMC and HDMI
    , .{});

    const kalloc_len = 28 * 1024 * 1024;
    var kernel_fba = std.heap.FixedBufferAllocator.init(kalloc_buffer[0..kalloc_len]);
    kalloc = kernel_fba.allocator();

    var user_fba = std.heap.FixedBufferAllocator.init(kalloc_buffer[kalloc_len..]);
    var user_alloc = UserAlloc.init(user_fba.allocator());
    malloc = user_alloc.allocator();

    var manager = Manager.init(kalloc);
    _ = manager.new(@intFromPtr(&user_main), 4096, &malloc) catch unreachable;

    RV.mstatus.modify(.{ .MPIE = 1 });
    RV.mie.modify(.{ .MEIE = 0, .MTIE = 1 });

    Clint.setNextTimerInterrupt();

    while (true) {
        //logger.info("run pc={}", .{manager.current});
        manager.run();
        handler(&manager);
    }

    @panic("unreachable");
}

pub const Position = struct {
    u: usize = 0,
    v: usize = 0,

    const logger = std.log.scoped(.pos);

    pub fn left(self: *Position) void {
        logger.info("left", .{});
        if (self.u == 0) {
            self.u = 319;
        } else self.u -= 1;
    }

    pub fn right(self: *Position) void {
        logger.info("right", .{});
        if (self.u == 319) {
            self.u = 0;
        } else self.u += 1;
    }

    pub fn up(self: *Position) void {
        logger.info("up", .{});
        if (self.v == 0) {
            self.v = 239;
        } else self.v -= 1;
    }

    pub fn down(self: *Position) void {
        logger.info("down", .{});
        if (self.v == 239) {
            self.v = 0;
        } else self.v += 1;
    }
};

pub export fn user_main(pid: usize, alloc: *Allocator) callconv(.C) noreturn {
    const logger = std.log.scoped(.user);

    logger.info("Binary Search:", .{});
    //for (1..11) |i| {
    //    const size = 10 * i;
    //    var bench = Bench.BinarySearch.init(alloc.*, size) catch unreachable;
    //    Bench.measure(size, &bench);
    //    bench.free();
    //}

    //logger.info("Linked List:", .{});
    //for (1..11) |i| {
    //    const size = 10 * i;
    //    var bench = Bench.LinkedList.init(alloc.*, size);
    //    _ = Bench.measure(size, &bench) catch unreachable;
    //}

    //logger.info("Fibo:", .{});
    //for (1..11) |i| {
    //    const size = 10 * i;
    //    var bench = Bench.Fibo.init(size);
    //    const fibo = Bench.measure(size, &bench);
    //    //logger.info("fibo({}) = {}", .{ size, fibo });
    //    _ = fibo;
    //}

    //logger.info("Fibo Recursive:", .{});
    //for (1..11) |i| {
    //    const size = 2 * i;
    //    var bench = Bench.FiboRec.init(size);
    //    const fibo = Bench.measure(size, &bench);
    //    //logger.info("fibo({}) = {}", .{ size, fibo });
    //    _ = fibo;
    //}

    //logger.info("ALU latency:", .{});
    //for (1..11) |i| {
    //    const size = 10 * i;
    //    var bench = Bench.LatencyALU.init(size);
    //    const output = Bench.measure(size, &bench);
    //    _ = output;
    //}

    //logger.info("ALU bandwidth:", .{});
    //for (1..11) |i| {
    //    const size = 10 * i;
    //    var bench = Bench.BandwidthALU.init(size);
    //    const output = Bench.measure(size, &bench);
    //    _ = output;
    //}

    //logger.info("LSU latency:", .{});
    //for (1..11) |i| {
    //    const size = 10 * i;
    //    var bench = Bench.LatencyLSU.init(size);
    //    const output = Bench.measure(size, &bench);
    //    _ = output;
    //}

    //logger.info("LSU bandwidth:", .{});
    //for (1..11) |i| {
    //    const size = 10 * i;
    //    var bench = Bench.BandwidthLSU.init(size);
    //    const output = Bench.measure(size, &bench);
    //    _ = output;
    //}

    //logger.info("Merge Sort:", .{});
    //for (1..11) |i| {
    //    const size = 10 * i;
    //    var bench = Bench.Sort.init(alloc.*, size) catch unreachable;
    //    Bench.measure(size, &bench);
    //    bench.free();
    //}

    //logger.info("Matrix Multiplication:", .{});
    //for (1..11) |i| {
    //    const size = 2 * i;
    //    var bench = Bench.MatrixMult.init(alloc.*, size) catch unreachable;
    //    Bench.measure(size, &bench);
    //    bench.free();
    //}

    const pixel = Screen.Pixel{ .blue = 0b10, .red = 0b100 };
    pixel.fillRectangle(100, 0, 100, 240 - 1);
    pixel.fillRectangle(0, 100, 320 - 1, 100);

    //if (pid == 0) {
    //    var pixel = Screen.Pixel{ .red = 0b111 };
    //    pixel.fill();

    //    pixel = .{ .blue = 0b01, .green = 0b011 };
    //    pixel.fillRectangle(101, 100, 137, 200);

    //    pixel = .{ .blue = 0b11, .green = 0b111 };

    //    pixel.drawRectangle(101, 100, 137, 200);
    //    pixel.drawRectangle(102, 101, 136, 199);
    //    pixel.drawRectangle(103, 102, 135, 198);
    //}

    //const px = Screen.Pixel{ .blue = 0b10, .red = 0b100 };
    //px.fill();

    //const btn: *volatile u8 = @ptrFromInt(0x20000000);
    //var pos = Position{};

    //while (true) {
    //    switch (btn.*) {
    //        4 => pos.down(),
    //        8 => pos.up(),
    //        32 => pos.right(),
    //        16 => pos.left(),
    //        1 => {},
    //        else => {},
    //    }

    //    const pixel = Screen.Pixel{ .green = 0b111 };
    //    pixel.write(pos.u, pos.v);

    //    try UART.writer.print(
    //        "\rbtn: 0x{x} u: {} v: {}   ",
    //        .{ btn.*, pos.u, pos.v },
    //    );
    //}

    //Syscall.exec(@intFromPtr(&user_main), 4096, alloc);
    _ = alloc;
    _ = pid;
    hang();
}
