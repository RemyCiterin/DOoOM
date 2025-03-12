const Config = @import("config.zig");
const std = @import("std");

const UART = @import("print.zig");
const logger = std.log.scoped(.sdcard);

const Spi: *volatile u8 = @ptrFromInt(Config.sdcard_base);
const CS: *volatile u8 = @ptrFromInt(Config.sdcard_base + 1);
const Clk: *volatile u8 = @ptrFromInt(Config.sdcard_base + 2);

var buffer: [512]u8 linksection(".bss") = undefined;

const boot_time: usize = 1000000;
const timeout: usize = 1000;

const CRC16 = struct {
    crc: u16,

    const Self = @This();

    fn step(self: *Self, data: u8) void {
        self.crc = (self.crc >> 8) | (self.crc << 8);
        self.crc ^= @intCast(data);
        self.crc ^= (self.crc & 0xFF) >> 4;
        self.crc ^= self.crc << 12;
        self.crc ^= (self.crc & 0xFF) << 5;
    }

    pub fn compute(buf: []u8) Self {
        var self = Self{ .crc = 0 };

        for (buf) |x| self.step(x);

        return self;
    }
};

const SdError = error{
    // We reach the timeout for reading a response from the SD card
    Timeout,
    // We read an invalid response from the SD card
    Invalid,
};

pub fn disable() void {
    _ = send(0xFF);
    CS.* = 1;
    _ = send(0xFF);
}

pub fn enable() void {
    _ = send(0xFF);
    CS.* = 0;
    _ = send(0xFF);
}

pub const Response1 = packed struct(u8) {
    idle: u1,
    erase_reset: u1,
    illegal_command: u1,
    crc_error: u1,
    erase_sequence_error: u1,
    address_error: u1,
    parameter_error: u1,
    _reserved: u1,

    pub fn log(self: Response1) void {
        logger.info("  Response1:", .{});
        inline for (@typeInfo(Response1).Struct.fields) |field| {
            if (@field(self, field.name) == 1)
                logger.info("    " ++ field.name ++ ": 1", .{});
        }
    }

    pub fn uint8(self: Response1) u8 {
        return @bitCast(self);
    }
};

pub fn send(x: u8) u8 {
    Spi.* = x;
    asm volatile ("fence" ::: "memory");
    return Spi.*;
}

pub fn sendCmd(cmd: u8, arg: u32, crc: u8) SdError!u8 {
    _ = send(0xFF);
    _ = send(0xFF);
    _ = send(cmd | 0x40);
    _ = send(@truncate(arg >> 24));
    _ = send(@truncate(arg >> 16));
    _ = send(@truncate(arg >> 8));
    _ = send(@truncate(arg));
    _ = send(crc | 0x01);

    var index: usize = 0;
    var result: u8 = 0xFF;

    while (result == 0xFF) : (index += 1) {
        if (index > timeout) return error.Timeout;
        result = send(0xFF);
    }

    return result;
}

pub fn sendCmd0() SdError!void {
    enable();
    defer disable();

    const result: Response1 = @bitCast(try sendCmd(0, 0, 0x95));

    logger.info("Cmd0:", .{});
    result.log();

    if (result.uint8() != 1)
        return error.Invalid;
}

pub fn sendCmd8() SdError!void {
    enable();
    defer disable();

    var results: [10]u8 = undefined;
    results[0] = try sendCmd(8, 0x01AA, 0x87);

    if (results[0] != 1)
        return error.Invalid;

    for (1..10) |i| results[i] = send(0xFF);

    logger.info("cmd8: {any}", .{results});
}

pub fn sendCmd41() SdError!void {
    enable();
    defer disable();

    var idle: bool = true;
    var index: usize = 0;

    while (idle) : (index += 1) {
        if (index >= timeout) return error.Timeout;

        const result1: Response1 =
            @bitCast(try sendCmd(55, 0, 0));

        if (result1.uint8() >> 1 != 0)
            return error.Invalid;

        logger.info("Cmd55:", .{});
        result1.log();

        const result2: Response1 =
            @bitCast(try sendCmd(41, 0x40000000, 0));

        if (result2.uint8() >> 1 != 0)
            return error.Invalid;

        logger.info("Cmd41:", .{});
        result2.log();

        idle = result2.idle == 1;
    }
}

pub fn sendCmd58() SdError!void {
    enable();
    defer disable();

    var res: [6]u8 = undefined;
    res[0] = @bitCast(try sendCmd(58, 0, 0));

    for (1..res.len) |i|
        res[i] = send(0xFF);

    logger.info("cmd58: {any}", .{res});
}

pub fn sendCmd16() SdError!void {
    enable();
    defer disable();

    const response: Response1 = @bitCast(try sendCmd(16, 512, 0));
    logger.info("Cmd16:", .{});
    response.log();
}

pub fn initInternal() SdError!void {
    logger.info("init SD for {} cycles", .{boot_time});
    Clk.* = 32;
    CS.* = 1;

    for (0..boot_time) |_| {
        asm volatile ("nop");
    }

    for (0..160) |_|
        _ = send(0xFF);

    CS.* = 0;

    for (0..160) |_|
        _ = send(0xFF);

    logger.info("send command 0", .{});

    try sendCmd0();

    logger.info("send command 8", .{});

    try sendCmd8();

    logger.info("send command 41", .{});

    try sendCmd41();

    Clk.* = 0;

    logger.info("send command 58", .{});

    try sendCmd58();

    logger.info("send command 16", .{});

    try sendCmd16();
}

pub fn init() void {
    while (true) {
        initInternal() catch |err| switch (err) {
            error.Timeout => {
                logger.info("timeout", .{});
                continue;
            },
            error.Invalid => {
                logger.info("invalid", .{});
                continue;
            },
        };
        break;
    }
}

pub fn readBlock(block_id: u32, buf: []u8) SdError!void {
    if (buf.len != 512) @panic("The buffer length must be >= 512");

    enable();
    defer disable();

    logger.debug("send comand 17:", .{});

    var response = try sendCmd(17, block_id, 0);
    logger.debug("    {}", .{response});

    response = 0xFF;
    var index: usize = 0;
    while (response == 0xFF) : (index += 1) {
        if (index >= timeout) return error.Timeout;
        response = send(0xFF);
    }

    if (response != 0xFE)
        return error.Invalid;

    for (0..512) |i|
        buf[i] = send(0xFF);

    var crc: u16 = @as(u16, @intCast(send(0xFF))) << 8;
    crc |= @intCast(send(0xFF));

    if (crc != CRC16.compute(buf[0..512]).crc)
        return error.Invalid;
}
