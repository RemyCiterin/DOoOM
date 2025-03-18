const Config = @import("config.zig");
const std = @import("std");

pub var screen: []volatile Line =
    @as([*]volatile Line, @ptrFromInt(Config.screen_base))[0..240];

pub const Line = [320]Pixel;
pub const LineWord = [80][4]Pixel;

pub const Pixel = packed struct(u8) {
    blue: u2 = 0,
    green: u3 = 0,
    red: u3 = 0,

    const Self = @This();

    pub fn write(self: Self, u: usize, v: usize) void {
        const logger = std.log.scoped(.pixel);
        logger.info("write at address: 0x{*}", .{&screen[v][u]});
        screen[v][u] = self;
    }

    // Fill a partial line between two pixels with a given color, this function
    // is optimised to be called for large lines using `sw` instruction
    pub fn fillPartLine(self: Self, a: usize, b: usize, v: usize) void {
        const line: *volatile LineWord = @ptrCast(&screen[v]);
        const word = [_]Pixel{self} ** 4;

        const a4 = (a + 3) >> 2;
        const b4 = (b + 1) >> 2;

        // Set the majority of the line using a `sw` instruction
        if (a4 < b4)
            @memset(line[a4..b4], word);

        if (a < @min(b + 1, a4 * 4))
            @memset(screen[v][a..@min(b + 1, a4 * 4)], self);

        if (@max(a, b4 * 4) < b + 1)
            @memset(screen[v][@max(a, b4 * 4) .. b + 1], self);
    }

    // Fill a rectable using an uniform color
    pub fn fillRectangle(
        self: Self,
        x0: usize,
        y0: usize,
        x1: usize,
        y1: usize,
    ) void {
        for (y0..y1 + 1) |y| self.fillPartLine(x0, x1, y);
    }

    // Draw the outline of a rectangle using an uniform color
    pub fn drawRectangle(
        self: Self,
        x0: usize,
        y0: usize,
        x1: usize,
        y1: usize,
    ) void {
        self.fillPartLine(x0, x1, y0);
        self.fillPartLine(x0, x1, y1);

        for (y0..y1 + 1) |y| {
            screen[y][x0] = self;
            screen[y][x1] = self;
        }
    }

    // Fill a complete line using an uniform color
    pub fn fillLine(self: Self, v: usize) void {
        const line: *volatile LineWord = @ptrCast(&screen[v]);
        const word = [_]Pixel{self} ** 4;
        @memset(line, word);
    }

    // Fill all the screen using an uniform color
    pub fn fill(self: Self) void {
        for (0..240) |v| {
            self.fillLine(v);
        }
    }
};
