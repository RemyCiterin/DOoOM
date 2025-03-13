const Config = @import("config.zig");
const writer = @import("print.zig").writer;

const CLINT = extern struct {
    msip: u32,
    _reserved1: [0x4000 - 4]u8,
    mtimecmp: u64,
    _reserved2: [0xBFF8 - 0x4008]u8,
    mtime: u64,
};

const clint: *volatile CLINT = @ptrFromInt(0x30000000);

pub fn setNextTimerInterrupt() void {
    clint.mtimecmp = clint.mtime + Config.timer_step;
}
