//! this file define the system entry when using M-mode directly

const std = @import("std");
const Params = @import("params.zig");
const RV = @import("riscv.zig");
const uart = @import("print.zig").writer;
const print = @import("print.zig").putString;
const putChar = @import("print.zig").putChar;
const getChar = @import("print.zig").getChar;
const math = std.math;
const Complex = math.complex.Complex;

var frame_slide_index: u32 = 0;

var slide_index: u32 = 0;
var slide_number: u32 = 100;

const row_number: u32 = 100; //480;
const col_number: u32 = 100; //640;

var row_index: u32 = 0;
var col_index: u32 = 0;

var request_new_line: bool = true;

var interrupt_count: u32 = 0;

var slides: [][]u8 = undefined;

pub fn wait(comptime cycle: comptime_int) void {
    //for (0..cycle) |_|
    //    asm volatile ("nop");
    _ = cycle;
}

pub fn incrFrameSlideIndex() void {
    frame_slide_index = (frame_slide_index + 1) % slide_number;
}

pub fn decrFrameSlideIndex() void {
    if (frame_slide_index == 0) {
        frame_slide_index = slide_number - 1;
    } else frame_slide_index -= 1;
}

pub export const stack0: [1024]u8 align(16) linksection(".bss") = undefined;

pub const frame_buffer: [*]volatile u8 = @ptrFromInt(0x40000000);

pub const Btn = packed struct {
    _reserved1: u2,
    up: bool,
    down: bool,
    left: bool,
    right: bool,

    pub inline fn isUp(self: Btn, prev: Btn) bool {
        return self.up and !prev.up;
    }

    pub inline fn isDown(self: Btn, prev: Btn) bool {
        return self.down and !prev.down;
    }

    pub inline fn isLeft(self: Btn, prev: Btn) bool {
        return self.left and !prev.left;
    }

    pub inline fn isRight(self: Btn, prev: Btn) bool {
        return self.right and !prev.right;
    }

    pub inline fn isActive(self: Btn, prev: Btn) bool {
        return self.isUp(prev) or self.isLeft(prev) or self.isDown(prev) or self.isRight(prev);
    }
};

pub const btn: *volatile Btn = @ptrFromInt(0x20000000);
pub var prev_btn: Btn = undefined;

// extern fn timervec() callconv(.Naked) void;

pub export fn _start() linksection(".text.init") callconv(.Naked) noreturn {
    asm volatile (
        \\  # a 4096-byte stack per CPU.
        \\  # sp = stack0 + (hartid * 4096)
        \\  csrr tp, mhartid
        \\  add sp, t0, zero
        \\clear_bss:
        \\  beq t1, t2, call_kernel_start
        \\  lb zero, 0(t1)
        \\  addi t1, t1, 1
        \\  j clear_bss
        \\call_kernel_start:
        \\  call kernel_start
        :
        : [t0] "{t0}" (&stack0[1023]),
          [t1] "{t1}" (&bss_start),
          [t2] "{t2}" (&bss_end),
    );

    while (true) {}
}

pub fn my_panic() noreturn {
    print("panic!");
    putChar(0);
    while (true) {}
}

pub export var nested: bool = false;

extern var bss_start: u8;
extern var bss_end: u8;

extern var kernel_end: [10000000]u8;

pub fn uint32(input: u32) u32 {
    var x: u32 = input;
    //x ^= x >> 16;
    //x *%= 0x7feb352d;
    x ^= x << 7;
    //x ^= x >> 15;
    //x *%= 0x846ca68b;
    //x ^= x >> 16;
    return x;
}

pub const F32 = packed struct {
    frac: u16,
    int: i16,

    pub fn init(int: i16, frac: u16) F32 {
        return .{ .int = int, .frac = frac };
    }

    pub fn zero() F32 {
        return init(0, 0);
    }

    pub fn one() F32 {
        return init(1, 0);
    }

    pub fn castInt(x: F32) i32 {
        return @bitCast(x);
    }

    pub fn add(x: F32, y: F32) F32 {
        return @bitCast(x.castInt() + y.castInt());
    }

    pub fn sub(x: F32, y: F32) F32 {
        return @bitCast(x.castInt() - y.castInt());
    }

    pub fn neg(x: F32) F32 {
        return sub(zero(), x);
    }

    pub fn mul(x: F32, y: F32) F32 {
        const x64: i64 = @intCast(x.castInt());
        const y64: i64 = @intCast(y.castInt());

        return @bitCast(@as(i32, @truncate(x64 * y64 >> 16)));
    }

    pub fn fromFloat(x: f32) F32 {
        return @bitCast(@as(i32, @intFromFloat(x * 65536)));
    }
};

pub const C32 = struct {
    im: F32,
    re: F32,

    pub fn init(re: F32, im: F32) C32 {
        return .{ .re = re, .im = im };
    }

    pub fn add(x: C32, y: C32) C32 {
        return init(x.re.add(y.re), x.im.add(y.im));
    }

    pub fn sub(x: C32, y: C32) C32 {
        return init(x.re.sub(y.re), x.im.sub(y.im));
    }

    pub fn mul(x: C32, y: C32) C32 {
        return init(
            x.re.mul(y.re).sub(x.im.mul(y.im)),
            x.re.mul(y.im).add(x.im.mul(y.re)),
        );
    }
};

pub const Registers = extern struct {
    ra: usize = 0, // x1
    sp: usize = 0, // x2
    gp: usize = 0, // x3
    tp: usize = 0, // x4
    t0: usize = 0, // x5
    t1: usize = 0, // x6
    t2: usize = 0, // x7
    s0: usize = 0, // x8
    s1: usize = 0, // x9
    a0: usize = 0, // x10
    a1: usize = 0, // x11
    a2: usize = 0, // x12
    a3: usize = 0, // x13
    a4: usize = 0, // x14
    a5: usize = 0, // x15
    a6: usize = 0, // x16
    a7: usize = 0, // x17
    s2: usize = 0, // x18
    s3: usize = 0, // x19
    s4: usize = 0, // x20
    s5: usize = 0, // x21
    s6: usize = 0, // x22
    s7: usize = 0, // x23
    s8: usize = 0, // x24
    s9: usize = 0, // x25
    s10: usize = 0, // x26
    s11: usize = 0, // x27
    t3: usize = 0, // x28
    t4: usize = 0, // x29
    t5: usize = 0, // x30
    t6: usize = 0, // x31
};

pub const STATUS = packed struct(u32) {
    _reserved1: u3 = 0,
    MIE: u1 = 0,
    _reserved2: u3 = 0,
    MPIE: u1 = 0,
    _reserved4: u24 = 0,

    pub fn modify(this: *@This(), fields: anytype) void {
        inline for (@typeInfo(@TypeOf(fields)).Struct.fields) |field| {
            @field(this, field.name) = @field(fields, field.name);
        }
    }
};

/// state saved at each interrupt, unique per CPU core
pub const TrapState = extern struct {
    /// register-set of the last interrupted user process of the CPU core
    registers: Registers,
    /// program counter of the last interrupt user process of the CPU core
    mepc: usize,
    /// interrupt status of the last interrupted user process of the CPU core
    mstatus: STATUS,
    /// the stack pointer of the kernel idle of the CPU core
    kernel_sp: usize,
};

pub var TRAP_STATE: TrapState = undefined;

pub inline fn trap_init() void {
    RV.mscratch.write(@intFromPtr(&TRAP_STATE));
    RV.mtvec.write(@intFromPtr(&trap32));
}

pub fn requestLine(x: u32, y: u32) void {
    wait(100_000);

    col_index = 0;
    try uart.print("{x} {x}\n", .{ x, y });
    request_new_line = false;
}

pub export fn handler(state: *TrapState) callconv(.C) void {
    TRAP_STATE.mstatus.MPIE = 1;

    if (RV.mcause.read().INTERRUPT == 0) {
        //print("exception!\n");
        state.mepc += 4;
    } else {
        //print("interrupt!!!\n");
        RV.mip.modify(.{ .MEIP = 0 });

        if (!std.meta.eql(btn.*, prev_btn)) {
            if (btn.*.right) {
                incrFrameSlideIndex();
                //putChar('>');
            }

            if (btn.*.left) {
                decrFrameSlideIndex();
                //putChar('<');
            }
        } else {
            interrupt_count += 1;
            slides[slide_index][col_number * row_index + col_index] =
                getChar();

            col_index += 1;

            request_new_line = false;
            if (col_index >= col_number) {
                request_new_line = true;
                row_index += 1;
                col_index = 0;

                if (row_index >= row_number) {
                    row_index = 0;

                    slide_index += 1;
                    if (slide_index >= slide_number)
                        slide_index = 0;
                }
            }

            if (request_new_line) {
                requestLine(slide_index, row_index);
            }

            //putChar(getChar());
        }
    }

    prev_btn = btn.*;
}

pub fn trap32() align(4) callconv(.Naked) void {
    asm volatile (
        \\csrrw a0, mscratch, a0
        \\
        \\#save registers into the stack
        \\sw ra, 0 * 4(a0)
        \\sw sp, 1 * 4(a0)
        \\sw gp, 2 * 4(a0)
        \\sw tp, 3 * 4(a0)
        \\sw t0, 4 * 4(a0)
        \\sw t1, 5 * 4(a0)
        \\sw t2, 6 * 4(a0)
        \\sw s0, 7 * 4(a0)
        \\sw s1, 8 * 4(a0)
        \\# don't `sw a0, 9 * 4(a0)`, a0 is in sscratch
        \\sw a1, 10 * 4(a0)
        \\sw a2, 11 * 4(a0)
        \\sw a3, 12 * 4(a0)
        \\sw a4, 13 * 4(a0)
        \\sw a5, 14 * 4(a0)
        \\sw a6, 15 * 4(a0)
        \\sw a7, 16 * 4(a0)
        \\sw s2, 17 * 4(a0)
        \\sw s3, 18 * 4(a0)
        \\sw s4, 19 * 4(a0)
        \\sw s5, 20 * 4(a0)
        \\sw s6, 21 * 4(a0)
        \\sw s7, 22 * 4(a0)
        \\sw s8, 23 * 4(a0)
        \\sw s9, 24 * 4(a0)
        \\sw s10, 25 * 4(a0)
        \\sw s11, 26 * 4(a0)
        \\sw t3, 27 * 4(a0)
        \\sw t4, 28 * 4(a0)
        \\sw t5, 29 * 4(a0)
        \\sw t6, 30 * 4(a0)
        \\
        \\#save user-a0 in 9 * 4(a0)
        \\csrr t0, mscratch
        \\sw t0, 9 * 4(a0)
        \\
        \\#save sepc into the stack
        \\csrr t0, mepc
        \\sw t0, 31 * 4(a0)
        \\
        \\#save sstatus into the stack
        \\csrr t0, mstatus
        \\sw t0, 32 * 4(a0)
        \\
        \\#search the kernel stack of the current CPU
        \\lw sp, 33 * 4(a0)
        \\
        \\csrw mscratch, a0
        \\call handler
        \\
        \\j userret32
    );
}

pub export fn userret32() callconv(.Naked) void {
    asm volatile (
        \\csrr a0, mscratch
        \\
        \\#copy the kernel stack
        \\sw sp, 33 * 4(a0)
        \\
        \\lw t0, 31 * 4(a0) # sepc register
        \\lw t1, 32 * 4(a0) # sstatus register
        \\csrw mepc, t0
        \\csrw mstatus, t1
        \\
        \\#save registers into the stack
        \\lw ra, 0 * 4(a0)
        \\lw sp, 1 * 4(a0)
        \\lw gp, 2 * 4(a0)
        \\lw tp, 3 * 4(a0)
        \\lw t0, 4 * 4(a0)
        \\lw t1, 5 * 4(a0)
        \\lw t2, 6 * 4(a0)
        \\lw s0, 7 * 4(a0)
        \\lw s1, 8 * 4(a0)
        \\# don't `lw a0, 9 * 4(a0)`, a0 is still used
        \\lw a1, 10 * 4(a0)
        \\lw a2, 11 * 4(a0)
        \\lw a3, 12 * 4(a0)
        \\lw a4, 13 * 4(a0)
        \\lw a5, 14 * 4(a0)
        \\lw a6, 15 * 4(a0)
        \\lw a7, 16 * 4(a0)
        \\lw s2, 17 * 4(a0)
        \\lw s3, 18 * 4(a0)
        \\lw s4, 19 * 4(a0)
        \\lw s5, 20 * 4(a0)
        \\lw s6, 21 * 4(a0)
        \\lw s7, 22 * 4(a0)
        \\lw s8, 23 * 4(a0)
        \\lw s9, 24 * 4(a0)
        \\lw s10, 25 * 4(a0)
        \\lw s11, 26 * 4(a0)
        \\lw t3, 27 * 4(a0)
        \\lw t4, 28 * 4(a0)
        \\lw t5, 29 * 4(a0)
        \\lw t6, 30 * 4(a0)
        \\
        \\lw a0, 9 * 4(a0)
        \\mret
    );
}

pub export fn kernel_start() callconv(.C) void {
    print("=== Start DOoOM ===\n");

    print(
        \\Dooom Out Of Order Machine:
        \\  DOoOM is an out of order RiscV with the goal of
        \\  runing DOOM on it!
        \\
        \\  It support the rv32i isa with machine mode,
        \\  is fine-tuned to run on the ULX3S board at
        \\  25kHz, use a 8kB 2-ways cache and has an
        \\  interface for UART, SDRAM and HDMI
    );

    putChar(10);

    const buffer: []u8 = &kernel_end;

    var fba = std.heap.FixedBufferAllocator.init(buffer);
    const allocator = fba.allocator();

    slides = allocator.alloc([]u8, slide_number) catch unreachable;

    for (0..slide_number) |i| {
        slides[i] = allocator.alloc(u8, row_number * col_number) catch unreachable;
    }

    var stack1: []u8 = allocator.alloc(u8, 1024) catch unreachable;
    TRAP_STATE.registers.sp = @intFromPtr(&stack1[1023]);
    TRAP_STATE.mepc = @intFromPtr(&user_main);

    TRAP_STATE.mstatus = .{};
    TRAP_STATE.mstatus.MPIE = 1;
    RV.mie.modify(.{ .MEIE = 1 });
    trap_init();

    const LinkList = union(enum) {
        const Self = @This();
        cons: *Node,
        nil: void,

        const Node = struct {
            item: u32,
            next: Self,
        };
    };

    var list: LinkList = .nil;

    for (0..1000) |i| {
        const tmp = allocator.create(LinkList.Node) catch unreachable;
        tmp.next = list;
        tmp.item = i;

        list = .{ .cons = tmp };
    }

    while (list != .nil) {
        const tmp = list.cons.*;
        allocator.destroy(list.cons);
        list = tmp.next;
    }

    asm volatile ("j userret32");
    my_panic();
}

pub export fn user_main() callconv(.C) void {
    var frame_number: u32 = 0;

    print("0 0\n");

    var last_interrupt_count: u32 = interrupt_count;

    while (true) {
        wait(1000000);
        if (last_interrupt_count == interrupt_count)
            requestLine(slide_index, row_index);

        last_interrupt_count = interrupt_count;

        @memcpy(frame_buffer, slides[frame_slide_index]);

        frame_number += 1;

        asm volatile ("ecall");

        try uart.print("minstret {}\n", .{RV.minstret.read()});
        try uart.print("minstreth {}\n", .{RV.minstreth.read()});

        if (frame_number == 5)
            putChar(0);
    }
}
