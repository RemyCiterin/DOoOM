const std = @import("std");
const mem = std.mem;

const Spinlock = @import("spinlock.zig");

// User allocator protedted by a spinlock
const UserAlloc = @This();

lock: Spinlock = .{},
kalloc: std.mem.Allocator,

pub fn init(kalloc: std.mem.Allocator) UserAlloc {
    return .{ .kalloc = kalloc };
}

pub fn allocator(self: *UserAlloc) std.mem.Allocator {
    return .{
        .ptr = self,
        .vtable = &.{
            .alloc = alloc,
            .resize = resize,
            .free = free,
        },
    };
}

pub fn alloc(
    ctx: *anyopaque,
    len: usize,
    alignment: u8,
    ret_addr: usize,
) ?[*]u8 {
    const self: *UserAlloc = @ptrCast(@alignCast(ctx));

    self.lock.lock();
    defer self.lock.unlock();

    return self.kalloc.vtable.alloc(
        self.kalloc.ptr,
        len,
        alignment,
        ret_addr,
    );
}

pub fn resize(
    ctx: *anyopaque,
    memory: []u8,
    alignment: u8,
    new_len: usize,
    ret_addr: usize,
) bool {
    const self: *UserAlloc = @ptrCast(@alignCast(ctx));

    self.lock.lock();
    defer self.lock.unlock();

    return self.kalloc.vtable.resize(
        self.kalloc.ptr,
        memory,
        alignment,
        new_len,
        ret_addr,
    );
}

pub fn free(
    ctx: *anyopaque,
    memory: []u8,
    alignment: u8,
    ret_addr: usize,
) void {
    const self: *UserAlloc = @ptrCast(@alignCast(ctx));

    self.lock.lock();
    defer self.lock.unlock();

    self.kalloc.vtable.free(
        self.kalloc.ptr,
        memory,
        alignment,
        ret_addr,
    );
}
