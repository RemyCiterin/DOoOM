const std = @import("std");

const logger = std.log.scoped(.fpoint);

pub fn FixedPoint(comptime int: comptime_int, comptime frac: comptime_int) type {
    const bits = int + frac;

    const scaling = 1 << frac;

    const Int = @Type(.{ .Int = .{ .bits = bits, .signedness = .signed } });
    const Int2 = @Type(.{ .Int = .{ .bits = 2 * bits, .signedness = .signed } });
    const UInt = @Type(.{ .Int = .{ .bits = bits, .signedness = .unsigned } });
    _ = UInt;

    return struct {
        raw: Int,

        const F = @This();

        pub inline fn fromFloat(f: f32) F {
            return .{ .raw = @intFromFloat(f * scaling) };
        }

        pub inline fn toFloat(f: F, comptime T: type) T {
            return @as(T, @floatFromInt(f.raw)) / scaling;
        }

        pub inline fn fromInt(i: anytype) F {
            return .{ .raw = @as(Int, @intCast(i)) << frac };
        }

        pub inline fn toInt(comptime T: type, f: F) T {
            return @intCast(@divExact(f.raw, scaling));
        }

        pub inline fn zero() F {
            return .{ .raw = 0 };
        }

        pub inline fn one() F {
            return .{ .raw = 1 << frac };
        }

        pub inline fn add(a: F, b: F) F {
            return .{ .raw = a.raw + b.raw };
        }

        pub inline fn sub(a: F, b: F) F {
            return .{ .raw = a.raw + b.raw };
        }

        pub inline fn neg(a: F) F {
            return .{ .raw = -a.raw };
        }

        pub inline fn mul(a: F, b: F) F {
            const m: Int2 = (@as(Int2, a.raw) * @as(Int2, b.raw)) >> frac;
            return .{ .raw = @as(Int, @truncate(m)) };
        }

        pub inline fn div(a: F, b: F) F {
            const d: Int2 = @divExact(@as(Int2, a.raw) << frac, b.raw);
            return .{ .raw = @as(Int, @intCast(d)) };
        }

        pub inline fn mod(a: F, b: F) F {
            return .{ .raw = @mod(a.raw, b.raw) };
        }

        pub fn format(
            f: F,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            if (comptime std.mem.eql(u8, fmt, "x")) {
                return std.fmt.formatFloatHexadecimal(f.toFloat(f32), options, writer);
            }

            const mode: std.fmt.format_float.Format = comptime blk: {
                if (fmt.len == 0 or std.mem.eql(u8, fmt, "any") or std.mem.eql(u8, fmt, "d")) {
                    break :blk .decimal;
                } else if (std.mem.eql(u8, fmt, "e")) {
                    break :blk .scientific;
                } else {
                    @compileError(std.fmt.comptimePrint(
                        "Invalid fmt for FixedPoint({},{}): {{{s}}}",
                        .{ bits, scaling, fmt },
                    ));
                }
            };

            const foptions = std.fmt.format_float.FormatOptions{
                .mode = mode,
                .precision = if (mode == .decimal) blk: {
                    break :blk if (options.precision) |p| p else int;
                } else options.precision,
            };

            var buf: [std.fmt.format_float.bufferSize(mode, f32)]u8 = undefined;
            const s = try std.fmt.format_float.formatFloat(&buf, f.toFloat(f32), foptions);
            try std.fmt.formatBuf(s, options, writer);
        }
    };
}

// A type of arbitrary size matrix
pub fn Dense(comptime T: type) type {
    return struct {
        rows: [][]T,
        n: usize,
        m: usize,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator, n: usize, m: usize) !Self {
            var rows = try allocator.alloc([]T, n);
            for (0..n) |i|
                rows[i] = try allocator.alloc(T, m);

            return .{
                .rows = rows,
                .n = n,
                .m = m,
            };
        }

        pub fn free(self: Self, allocator: std.mem.Allocator) void {
            for (self.rows) |r|
                allocator.free(r);

            allocator.free(self.rows);
        }

        pub inline fn at(self: Self, i: usize, j: usize) T {
            return self.rows[i][j];
        }

        pub inline fn upd(self: Self, i: usize, j: usize, t: T) void {
            self.rows[i][j] = t;
        }

        pub fn fill(self: Self, x: T) void {
            for (0..self.n) |i| {
                @memset(self.rows[i], x);
            }
        }

        pub fn add(self: Self, other: Self) void {
            if (self.n != other.n) @panic("invalid add size");
            if (self.m != other.m) @panic("invalid add size");
            for (0..self.n) |i| {
                for (0..self.m) |j| {
                    self.upd(i, j, self.at(i, j).add(other.at(i, j)));
                }
            }
        }

        pub fn mul(dest: Self, a: Self, b: Self) void {
            if (a.m != b.n) @panic("invalid mul size");
            if (dest.n != a.n) @panic("invalid mul size");
            if (dest.m != b.m) @panic("invalid mul size");

            for (0..a.n) |i| {
                for (0..a.m) |k| {
                    for (0..b.m) |j| {
                        dest.upd(
                            i,
                            j,
                            dest.at(i, j).add(a.at(i, k).mul(b.at(k, j))),
                        );
                    }
                }
            }
        }

        pub fn times(self: Self, value: T) void {
            for (0..self.n) |i| {
                for (0..self.m) |j| {
                    self.upd(i, j, self.at(i, j).mul(value));
                }
            }
        }

        pub fn plus(self: Self, value: T) void {
            for (0..self.n) |i| {
                for (0..self.m) |j| {
                    self.upd(i, j, self.at(i, j).add(value));
                }
            }
        }

        pub fn identity(self: Self) void {
            if (self.n != self.m) @panic("identity() expect a n*n matrix");
            for (0..self.n) |i| {
                for (0..self.m) |j| {
                    self.upd(i, j, T.zero());
                }

                self.upd(i, i, T.one());
            }
        }
    };
}

// Multiply two small matrix
pub fn matrixMult(
    comptime T: type,
    comptime A: comptime_int,
    comptime B: comptime_int,
    comptime C: comptime_int,
    m1: [A][B]T,
    m2: [B][C]T,
) [A][C]T {
    var ret: [A][C]T = .{.{0} ** C} ** A;
    inline for (0..A) |i| {
        inline for (0..B) |k| {
            inline for (0..C) |j| {
                ret[i][j] = ret[i][j].add(m1[i][k].mul(m2[k][j]));
            }
        }
    }

    return ret;
}
