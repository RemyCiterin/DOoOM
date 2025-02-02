const Syscall = @import("syscall.zig");
const RV = @import("riscv.zig");
const std = @import("std");

locked: bool = false,

pub const Self = @This();

pub fn unlock(self: *Self) void {
    self.locked = false;
}

pub fn tryLock(self: *Self) bool {
    const MIE = RV.mstatus.read().MIE;
    RV.mstatus.modify(.{ .MIE = 0 });
    defer RV.mstatus.modify(.{ .MIE = MIE });

    if (self.locked) return false;

    self.locked = true;
    return true;
}

pub fn lock(self: *Self) void {
    while (!self.tryLock())
        Syscall.yield();
}
