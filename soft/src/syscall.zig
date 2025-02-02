pub const Output = union(enum) {
    exec: void,
    yield: void,
};

pub const Input = union(enum) {
    exec: struct {
        stack_size: usize,
        args: ?*anyopaque,
        pc: usize,
    },
    yield,
};

pub fn syscall(input: Input) *Output {
    var output: *Output = undefined;
    asm volatile ("ecall"
        : [output] "={a0}" (output),
        : [input] "{a0}" (&input),
        : "memory"
    );

    return output;
}

pub fn exec(pc: usize, stack_size: usize, args: ?*anyopaque) void {
    const output = syscall(.{ .exec = .{
        .pc = pc,
        .args = args,
        .stack_size = stack_size,
    } });

    switch (output.*) {
        .exec => {},
        else => @panic("exec syscall must return an \".exec\" output"),
    }
}

pub fn yield() void {
    const output = syscall(.yield);

    switch (output.*) {
        .yield => {},
        else => @panic("yield syscall must return an \".yield\" output"),
    }
}
