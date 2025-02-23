// This file contain a collection of small benchmarks to measure the
// performances of my CPU

const std = @import("std");
const Spinlock = @import("spinlock.zig");
const RV = @import("riscv.zig");

const logger = std.log.scoped(.bench);

pub var measureLock = Spinlock{};

// Measure the performance of a benchmark test
pub fn measure(
    id: usize,
    bench: anytype,
) @TypeOf(bench.call()) {
    var cycle = RV.mcycle.read();
    var instret = RV.minstret.read();
    const output = bench.call();
    instret = RV.minstret.read() - instret;
    cycle = RV.mcycle.read() - cycle;

    measureLock.lock();
    defer measureLock.unlock();

    logger.info("id: {} cycle: {} instret: {}", .{ id, cycle, instret });

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

    pub fn free(self: *Self) void {
        self.alloc.free(self.A);
        self.alloc.free(self.B);
        self.alloc.free(self.C);
    }

    pub fn call(self: *Self) void {
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
        var begin: usize = 0;
        var end: usize = self.array.len;

        while (begin < end) {
            @setRuntimeSafety(false);
            const m = (begin + end) >> 1;

            if (self.array[m] == x) return m;

            const cond: usize = if (self.array[m] < x) 1 else 0;
            begin = cond * m + (1 - cond) * begin;
            end = cond * end + (1 - cond) * m;
        }

        return null;
    }

    pub fn call(self: Self) void {
        for (0..self.array.len) |i| {
            if (self.search(i) != i)
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
