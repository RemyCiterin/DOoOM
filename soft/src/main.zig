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
        Clint.setNextTimerInterrupt();
        manager.next();
    } else {
        RV.mip.modify(.{ .MEIP = 0 });
    }
}

pub export fn kernel_main() callconv(.C) void {
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

    SdCard.init();
    var buf = kalloc.alloc(u8, 512) catch unreachable;
    defer buf.free();

    for (0..15) |i| {
        logger.info("block: {}", .{i});
        SdCard.readBlock(i, buf) catch unreachable;
    }

    const addresses = [_]u32{
        63000000000 / 512,
        64000000000 / 512,
        65000000000 / 512,
    };

    for (addresses) |id| {
        logger.info("block: {}", .{id});
        SdCard.readBlock(id, buf) catch unreachable;
    }

    while (true) {}

    //var user_fba = std.heap.FixedBufferAllocator.init(kalloc_buffer[kalloc_len..]);
    //var user_alloc = UserAlloc.init(user_fba.allocator());
    //malloc = user_alloc.allocator();

    //var manager = Manager.init(kalloc);
    //_ = manager.new(@intFromPtr(&user_main), 4096, &malloc) catch unreachable;

    //RV.mstatus.modify(.{ .MPIE = 1 });
    //RV.mie.modify(.{ .MEIE = 1, .MTIE = 1 });

    //Clint.setNextTimerInterrupt();

    //while (true) {
    //    manager.run();
    //    handler(&manager);
    //}

    //@panic("unreachable");
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

//pub fn syscall0(index: usize) void {
//    if (index <= 4) return Syscall.yield();
//    Syscall.exec(@intFromPtr(&user_main), 512, null);
//}

//pub export fn user_main(pid: usize, alloc: *Allocator) callconv(.C) noreturn {
//    const logger = std.log.scoped(.user);
//
//    measureLock.lock();
//    logger.info("Binary Search:", .{});
//    for (1..11) |i| {
//        const size = 10 * i;
//        var bench = Bench.BinarySearch.init(alloc.*, size) catch unreachable;
//        Bench.measure(size, &bench);
//        bench.free();
//    }
//
//    logger.info("Linked List:", .{});
//    for (1..11) |i| {
//        const size = 10 * i;
//        var bench = Bench.LinkedList.init(alloc.*, size);
//        _ = Bench.measure(size, &bench) catch unreachable;
//    }
//
//    logger.info("Fibo:", .{});
//    for (1..11) |i| {
//        const size = 10 * i;
//        var bench = Bench.Fibo.init(size);
//        const fibo = Bench.measure(size, &bench);
//        //logger.info("fibo({}) = {}", .{ size, fibo });
//        _ = fibo;
//    }
//
//    logger.info("Fibo Recursive:", .{});
//    for (1..11) |i| {
//        const size = 2 * i;
//        var bench = Bench.FiboRec.init(size);
//        const fibo = Bench.measure(size, &bench);
//        //logger.info("fibo({}) = {}", .{ size, fibo });
//        _ = fibo;
//    }
//
//    logger.info("ALU latency:", .{});
//    for (1..11) |i| {
//        const size = 10 * i;
//        var bench = Bench.LatencyALU.init(size);
//        const output = Bench.measure(size, &bench);
//        _ = output;
//    }
//
//    logger.info("ALU bandwidth:", .{});
//    for (1..11) |i| {
//        const size = 10 * i;
//        var bench = Bench.BandwidthALU.init(size);
//        const output = Bench.measure(size, &bench);
//        _ = output;
//    }
//
//    logger.info("LSU latency:", .{});
//    for (1..11) |i| {
//        const size = 10 * i;
//        var bench = Bench.LatencyLSU.init(size);
//        const output = Bench.measure(size, &bench);
//        _ = output;
//    }
//
//    logger.info("LSU bandwidth:", .{});
//    for (1..11) |i| {
//        const size = 10 * i;
//        var bench = Bench.BandwidthLSU.init(size);
//        const output = Bench.measure(size, &bench);
//        _ = output;
//    }
//
//    logger.info("Merge Sort:", .{});
//    for (1..11) |i| {
//        const size = 10 * i;
//        var bench = Bench.Sort.init(alloc.*, size) catch unreachable;
//        Bench.measure(size, &bench);
//        bench.free();
//    }
//
//    //logger.info("Matrix Multiplication:", .{});
//    //for (1..11) |i| {
//    //    const size = 2 * i;
//    //    var bench = Bench.MatrixMult.init(alloc.*, size) catch unreachable;
//    //    Bench.measure(size, &bench);
//    //    bench.free();
//    //}
//    measureLock.unlock();
//
//    if (pid == 0) {
//        var pixel = Screen.Pixel{ .red = 0b111 };
//        measure(logger, pid, Screen.Pixel.fill, .{pixel});
//
//        pixel = .{ .blue = 0b01, .green = 0b011 };
//        pixel.fillRectangle(101, 100, 137, 200);
//
//        pixel = .{ .blue = 0b11, .green = 0b111 };
//
//        pixel.drawRectangle(101, 100, 137, 200);
//        pixel.drawRectangle(102, 101, 136, 199);
//        pixel.drawRectangle(103, 102, 135, 198);
//    }
//
//    try UART.writer.print("ready to fence?", .{});
//    asm volatile ("fence" ::: "memory");
//
//    var index: usize = 0;
//    while (true) : (index += 1) {
//        measure(logger, pid, syscall0, .{index});
//    }
//
//    while (true) {}
//}
