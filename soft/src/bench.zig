// This file contain a collection of small benchmarks to measure the
// performances of my CPU

const std = @import("std");
const Spinlock = @import("spinlock.zig");
const RV = @import("riscv.zig");

const Random = @import("random.zig");

const logger = std.log.scoped(.bench);

var randomCount: u32 = 0;
noinline fn randomU32() u32 {
    randomCount += 1;
    return std.hash.uint32(randomCount);
}

noinline fn seed() u32 {
    return RV.mcycle.read();
}

pub var measureLock = Spinlock{};

// Measure the performance of a benchmark test
pub fn measure(
    id: usize,
    bench: anytype,
) @TypeOf(bench.call()) {
    var cycle: u32 = RV.mcycle.read();
    var instret = RV.minstret.read();
    const output = bench.call();
    instret = RV.minstret.read() -% instret;
    cycle = RV.mcycle.read() -% cycle;

    measureLock.lock();
    defer measureLock.unlock();

    logger.info("size: {} cycle: {} instret: {}", .{ id, cycle, instret });

    return output;
}

pub const MatrixMult = struct {
    N: usize,
    alloc: std.mem.Allocator,
    A: []i32,
    B: []i32,
    C: []i32,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, N: usize) !Self {
        var self = Self{
            .N = N,
            .alloc = allocator,
            .A = try allocator.alloc(i32, N * N),
            .B = try allocator.alloc(i32, N * N),
            .C = try allocator.alloc(i32, N * N),
        };

        for (0..N) |i| {
            for (0..N) |j| {
                self.A[i * N + j] = 0;
                self.B[i * N + j] = 0;
                self.C[i * N + j] = 0;
            }

            self.A[i * N + i] = 1;
            self.B[i * N + i] = 1;
        }

        return self;
    }

    pub fn free(self: Self) void {
        self.alloc.free(self.A);
        self.alloc.free(self.B);
        self.alloc.free(self.C);
    }

    pub fn call(self: Self) void {
        @setRuntimeSafety(false);
        for (0..self.N) |i| {
            for (0..self.N) |j| {
                for (0..self.N) |k| {
                    self.C[i * self.N + j] +=
                        self.A[i * self.N + k] * self.B[k * self.N + j];
                }
            }
        }
    }
};

pub const BinarySearch = struct {
    alloc: std.mem.Allocator,
    array: []u32,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, N: usize) !Self {
        var array = try allocator.alloc(u32, N);
        for (0..N) |i| array[i] = i;

        return .{
            .array = array,
            .alloc = allocator,
        };
    }

    pub fn free(self: Self) void {
        self.alloc.free(self.array);
    }

    pub noinline fn search(self: Self, x: u32) ?usize {
        var end: usize = self.array.len;
        var begin: usize = 0;

        while (begin < end) {
            @setRuntimeSafety(false);
            const m = (end + begin) / 2;

            if (self.array[m] == x) return m;
            if (self.array[m] < x) {
                begin = m + 1;
            } else end = m;
        }

        return null;
    }

    pub noinline fn linear(self: Self, x: u32) ?usize {
        for (0.., self.array) |i, v| {
            @setRuntimeSafety(false);
            if (v == x) return i;
        }

        return null;
    }

    pub fn call(self: Self) void {
        for (0.., self.array) |i, v| {
            if (self.search(v) != i)
                @panic("item not found");
        }
    }
};

pub const Fibo = struct {
    N: usize,

    const Self = @This();

    pub fn init(N: usize) Self {
        return .{ .N = N };
    }

    // Integer overflow around 300-350
    pub noinline fn call(self: Self) u256 {
        @setRuntimeSafety(false);
        var x0: u256 = 0;
        var x1: u256 = 1;

        for (0..self.N) |_| {
            const tmp: u256 = x1;
            x1 = x0 + x1;
            x0 = tmp;
        }

        return x0;
    }
};

pub const FiboRec = struct {
    N: usize,

    const Self = @This();

    pub fn init(N: usize) Self {
        return .{ .N = N };
    }

    pub noinline fn fibo(x: u32) u32 {
        @setRuntimeSafety(false);
        if (x < 2) return x;

        return fibo(x - 1) + fibo(x - 2);
    }

    // Integer overflow around 300-350
    pub noinline fn call(self: Self) u32 {
        return fibo(self.N);
    }
};

pub const LatencyALU = struct {
    N: usize,

    const Self = @This();

    pub fn init(N: usize) Self {
        return .{ .N = N };
    }

    // The time of execution is expected to be
    // around 100 * self.N * Latency
    // with Latency the latency of the ALU
    pub noinline fn call(self: Self) u32 {
        @setRuntimeSafety(false);

        var x: u32 = 0;

        // 100 add instructions
        for (0..self.N) |_| {
            asm volatile ("addi %[x], %[x], 1;" ** 100
                : [x] "+r" (x),
            );
        }

        return x;
    }
};

pub const BandwidthALU = struct {
    N: usize,

    const Self = @This();

    pub fn init(N: usize) Self {
        return .{ .N = N };
    }

    // The time of execution is expected to be
    // around 100 * self.N * Latency
    // with Latency the latency of the ALU
    pub noinline fn call(self: Self) void {
        @setRuntimeSafety(false);

        // 100 add instructions
        for (0..self.N) |_| {
            asm volatile ("addi zero, zero, 1;" ** 100);
        }
    }
};

pub const LatencyFPU = struct {
    N: usize,

    const Self = @This();

    pub fn init(N: usize) Self {
        return .{ .N = N };
    }

    // The time of execution is expected to be
    // around 100 * self.N * Latency
    // with Latency the latency of the ALU
    pub noinline fn call(self: Self) f32 {
        @setRuntimeSafety(false);

        var x: f32 = 0.0;

        // 100 add instructions
        for (0..self.N) |_| {
            asm volatile ("fadd.s %[x], %[x], %[x];" ** 100
                : [x] "+fr" (x),
            );
        }

        return x;
    }
};

pub const BandwidthFPU = struct {
    N: usize,

    const Self = @This();

    pub const Instr = enum { sqrt, div, mul, add };

    pub fn init(N: usize) Self {
        return .{ .N = N };
    }

    pub fn buildInstr(comptime instr: Instr, comptime reg: []const u8) []const u8 {
        return switch (instr) {
            .sqrt => "fsqrt.s %[" ++ reg ++ "], %[" ++ reg ++ "];",
            .div => "fdiv.s %[" ++ reg ++ "], %[" ++ reg ++ "], %[" ++ reg ++ "];",
            .mul => "fmul.s %[" ++ reg ++ "], %[" ++ reg ++ "], %[" ++ reg ++ "];",
            .add => "fadd.s %[" ++ reg ++ "], %[" ++ reg ++ "], %[" ++ reg ++ "];",
        };
    }

    // The time of execution is expected to be
    // around 100 * self.N * Latency
    // with Latency the latency of the ALU
    pub noinline fn call(self: Self) void {
        @setRuntimeSafety(false);

        var x0: f32 = 10.0;
        var x1: f32 = 10.0;
        var x2: f32 = 10.0;
        var x3: f32 = 10.0;
        var x4: f32 = 10.0;
        var x5: f32 = 10.0;
        var x6: f32 = 10.0;
        var x7: f32 = 10.0;
        var x8: f32 = 10.0;
        var x9: f32 = 10.0;
        // 100 instructions
        const instr: Instr = .add;
        for (0..self.N) |_| {
            inline for (0..10) |_| {
                asm volatile (buildInstr(instr, "x0") ++
                        buildInstr(instr, "x1") ++
                        buildInstr(instr, "x2") ++
                        buildInstr(instr, "x3") ++
                        buildInstr(instr, "x4") ++
                        buildInstr(instr, "x5") ++
                        buildInstr(instr, "x6") ++
                        buildInstr(instr, "x7") ++
                        buildInstr(instr, "x8") ++
                        buildInstr(instr, "x9")
                    : [x0] "+fr" (x0),
                      [x1] "+fr" (x1),
                      [x2] "+fr" (x2),
                      [x3] "+fr" (x3),
                      [x4] "+fr" (x4),
                      [x5] "+fr" (x5),
                      [x6] "+fr" (x6),
                      [x7] "+fr" (x7),
                      [x8] "+fr" (x8),
                      [x9] "+fr" (x9),
                );
            }
        }
    }
};

pub const BandwidthLSU = struct {
    N: usize,

    const Self = @This();

    pub fn init(N: usize) Self {
        return .{ .N = N };
    }

    // The time of execution is expected to be
    // around 100 * self.N * Latency
    // with Latency the latency of the ALU
    pub noinline fn call(self: Self) void {
        @setRuntimeSafety(false);

        // 100 add instructions
        for (0..self.N) |_| {
            asm volatile ("lw zero, (zero);" ** 100);
        }
    }
};

pub const LatencyLSU = struct {
    N: usize,

    const Self = @This();

    pub fn init(N: usize) Self {
        return .{ .N = N };
    }

    // The time of execution is expected to be
    // around 100 * self.N * Latency
    // with Latency the latency of the ALU
    pub noinline fn call(self: Self) void {
        @setRuntimeSafety(false);

        var ptr: *anyopaque = undefined;
        ptr = @ptrCast(&ptr);

        // 100 add instructions
        for (0..self.N) |_| {
            asm volatile ("lw %[ptr], (%[ptr]);" ** 100
                : [ptr] "+r" (ptr),
                :
                : "memory"
            );
        }
    }
};

pub const Sort = struct {
    alloc: std.mem.Allocator,
    larr: []u32,
    rarr: []u32,
    array: []u32,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, N: usize) !Self {
        var array = try allocator.alloc(u32, N);
        for (0..N) |i| array[i] = randomU32() % 10;

        const larr = try allocator.alloc(u32, N);
        const rarr = try allocator.alloc(u32, N);

        return .{
            .larr = larr,
            .rarr = rarr,
            .array = array,
            .alloc = allocator,
        };
    }

    pub fn free(self: Self) void {
        self.alloc.free(self.array);
        self.alloc.free(self.larr);
        self.alloc.free(self.rarr);
    }

    pub fn swap(a: *u32, b: *u32) void {
        const tmp = a.*;
        a.* = b.*;
        b.* = tmp;
    }

    pub fn merge(self: Self, l: u32, m: u32, r: u32) void {
        @setRuntimeSafety(false);
        const nl = m - l + 1;
        const nr = r - m;

        var larr: []u32 = self.larr[0..nl];
        var rarr: []u32 = self.rarr[0..nr];

        for (0..nl) |i| larr[i] = self.array[l + i];
        for (0..nr) |j| rarr[j] = self.array[m + 1 + j];

        var i: u32 = 0;
        var j: u32 = 0;
        var k: u32 = l;

        while (i < nl and j < nr) : (k += 1) {
            if (larr[i] <= rarr[j]) {
                self.array[k] = larr[i];
                i += 1;
            } else {
                self.array[k] = rarr[j];
                j += 1;
            }
        }

        while (i < nl) : (k += 1) {
            self.array[k] = larr[i];
            i += 1;
        }

        while (j < nr) : (k += 1) {
            self.array[k] = rarr[j];
            j += 1;
        }
    }

    pub noinline fn mergeSort(self: Self, l: u32, r: u32) void {
        @setRuntimeSafety(false);
        var m: u32 = undefined;

        if (l < r) {
            m = l + (r - l) / 2;
            self.mergeSort(l, m);
            self.mergeSort(m + 1, r);
            self.merge(l, m, r);
        }
    }

    pub inline fn call(self: Self) void {
        self.mergeSort(0, self.array.len - 1);
    }
};
