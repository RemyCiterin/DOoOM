const Config = @import("config.zig");
const std = @import("std");

const logger = std.log.scoped(.sdcard);

const Spi: *volatile u8 = @ptrFromInt(Config.sdcard_base);
const CS: *volatile u8 = @ptrFromInt(Config.sdcard_base + 1);
const Clk: *volatile u8 = @ptrFromInt(Config.sdcard_base + 2);

var buffer: [512]u8 linksection(".bss") = undefined;

const boot_time: usize = 10000000;
const timeout: usize = 100;

pub fn send(x: u8) u8 {
    Spi.* = x;
    asm volatile ("fence" ::: "memory");
    return Spi.*;
}

pub fn sendCmd(cmd: u64) u8 {
    const msg: [8]u8 = @bitCast(cmd);

    inline for (0..8) |i| {
        _ = send(msg[7 - i]);
    }

    var index: usize = 0;
    var result: u8 = 0xFF;

    while (result == 0xFF) : (index += 1) {
        if (index > timeout) @panic("sd: timout");
        if (index > timeout) break;
        result = send(0xFF);
    }

    return result;
}

pub fn sendCmd0() void {
    const result = sendCmd(0xFFFF400000000095);

    logger.info("receive {} from cmd0", .{result});
    //if (result != 1) @panic("cmd0 fail");
}

pub fn sendCmd8() void {
    var results: [10]u8 = undefined;
    results[0] = sendCmd(0xFFFF48000001AA87);

    for (0..9) |i| {
        results[i + 1] = send(0xFF);
    }

    logger.info("cmd8: {any}", .{results});
}

pub fn init() void {
    logger.info("init SD for {} cycles", .{boot_time});
    Clk.* = 32;
    CS.* = 1;

    for (0..boot_time) |_| {
        asm volatile ("nop");
    }

    for (0..160) |_| {
        _ = send(0xFF);
    }

    CS.* = 0;

    logger.info("send command 0", .{});

    sendCmd0();

    logger.info("send command 8", .{});

    sendCmd8();
}
