//! this file define the configuration of the hardware/firmware,
//! it allows to use the right interface depending on the target
//! (qemu, real hardware, sail...)

/// now, only Qemu and Sail are supported
pub const Config = union(enum) {
    qemu: QemuInfo,
    sail,

    pub const QemuInfo = struct {
        firmware: FirmwareInfo,
        cpus: usize,
    };

    pub const FirmwareInfo = enum {
        /// no firmware, start in M-mode
        M,

        /// use FBI to communicate with the firmware,
        /// start in S-mode
        SBI,
    };

    pub fn cpus(this: @This()) usize {
        switch (this) {
            .qemu => |info| return info.cpus,
            .sail => return 1,
        }
    }

    pub fn sbi(this: @This()) bool {
        switch (this) {
            .qemu => |info| return info.firmware == .SBI,
            .sail => false,
        }
    }

    pub const UartMode = enum {
        /// HTIF uart communication, need variables `tohost`
        /// and `fromhost` in the ELF file
        HTIF,

        /// SBI communication, use Syscall from the supervisor
        SBI,

        /// use UART mmio
        MMIO,
    };

    pub fn uartMode(this: @This()) UartMode {
        switch (this) {
            .qemu => |info| switch (info.firmware) {
                .M => return .MMIO,
                .SBI => return .MMIO, // .SBI,
            },
            .sail => return .HTIF,
        }
    }

    pub fn firmwareMode(this: @This()) FirmwareInfo {
        switch (this) {
            .qemu => |info| return info.firmware,
            .sail => return .M,
        }
    }

    /// return the maximum physical address
    pub fn maxAddr(this: @This()) usize {
        return switch (this) {
            .qemu => 0x80000000 + 128 * 1024 * 2024,
            .sail => 0x80000000 + 128 * 1024 * 1024,
        };
    }
};

pub const config = Config{ .qemu = .{ .cpus = 4, .firmware = .SBI } };
//pub const config = Config{ .sail = {} };
