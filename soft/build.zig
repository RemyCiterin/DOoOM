const std = @import("std");
const Target = std.Target;
const Feature = Target.riscv.Feature;
const config = @import("src/config.zig").config;

const XLEN = 32;

const start_file = "src/m_start.zig";

const linker_file = "src/qemu_m_linker.ld";

const Command = struct {
    allocator: std.mem.Allocator,

    args: std.ArrayList([]u8),

    pub fn append(this: *@This(), arg: []const u8) !void {
        const copy = try this.allocator.alloc(u8, arg.len);
        @memcpy(copy, arg);

        try this.args.append(copy);
    }

    pub fn appendSlice(this: *@This(), args: []const []const u8) !void {
        for (args) |arg| try this.append(arg);
    }

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .allocator = allocator,
            .args = std.ArrayList([]u8).init(allocator),
        };
    }

    pub fn deinit(this: @This()) void {
        for (this.args.items) |arg| {
            this.allocator.free(arg);
        }

        this.args.deinit();
    }
};

// try std.fmt.bufPrint(buffer, "hpmcounter{}", .{n})
pub fn simulateCommand(b: *std.Build) !*std.Build.Step.Run {
    switch (config) {
        .qemu => |info| {
            var command = b.addSystemCommand(&[_][]const u8{switch (XLEN) {
                32 => "qemu-system-riscv32",
                64 => "qemu-system-riscv64",
                else => @panic("unsupported XLEN for qemu"),
            }});

            var buffer: [256]u8 = undefined;

            command.addArgs(&[_][]const u8{
                "-M",       "virt",
                "-serial",  "stdio",
                "-display", "none",
                "-m",       "128M",
                "-smp",     try std.fmt.bufPrint(buffer[0..], "{}", .{info.cpus}),
                "-kernel",  "./zig-out/bin/zig-unix.elf",
            });

            switch (info.firmware) {
                .M => command.addArgs(&[_][]const u8{
                    "-bios", "none",
                }),
                .SBI => command.addArgs(&[_][]const u8{
                    "-bios", "default",
                }),
            }

            return command;
        },

        .sail => {
            //riscv_sim_RV64 ./zig-out/bin/zig-unix.elf -t debug/console.log > debug/trace.log 2>&1
            var command = b.addSystemCommand(&[_][]const u8{switch (XLEN) {
                32 => "riscv_sim_RV32",
                64 => "riscv_sim_RV64",
                else => @panic("unsupported XLEN for qemu"),
            }});

            command.addArgs(&[_][]const u8{
                "./zig-out/bin/zig-unix.elf", "-t", "./debug/console.log",
            });

            _ = command.captureStdOut();
            _ = command.captureStdErr();

            return command;
        },
    }
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target64 = std.Target.Query{
        .cpu_arch = Target.Cpu.Arch.riscv64,
        .cpu_model = .{ .explicit = &Target.riscv.cpu.generic_rv64 },
        .cpu_features_add = Target.riscv.featureSet(&[_]Feature{.m}), // .m, .c, .a
        .os_tag = .freestanding,
        .abi = .none, // .eabi
    };

    const target32 = std.Target.Query{
        .cpu_arch = Target.Cpu.Arch.riscv32,
        .cpu_model = .{ .explicit = &Target.riscv.cpu.generic_rv32 },
        .cpu_features_add = Target.riscv.featureSet(&[_]Feature{.m}),
        .os_tag = .freestanding,
        .abi = .none, // .eabi
    };

    const target = switch (XLEN) {
        32 => target32,
        64 => target64,
        else => unreachable,
    };

    const optimize = b.standardOptimizeOption(.{}); // .ReleaseSmall;

    const exe = b.addExecutable(.{
        .name = "zig-unix.elf",
        .root_source_file = .{ .path = start_file },
        .target = b.resolveTargetQuery(target),
        .optimize = optimize,
    });

    //exe.code_model = .medium;

    exe.setLinkerScriptPath(.{ .path = linker_file });

    b.installArtifact(exe);

    const simulate = try simulateCommand(b);

    simulate.step.dependOn(b.default_step);

    const run_simulator = b.step("run", "Run ZIG-OS with a simulator");
    run_simulator.dependOn(&simulate.step);
}
