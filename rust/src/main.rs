#![no_std]
#![no_main]
#![feature(alloc_error_handler)]
#![feature(naked_functions)]
#![feature(allocator_api)]
#![feature(alloc_layout_extra)]
#![allow(dead_code)]

#[macro_use]
extern crate alloc;

#[macro_use]
mod printer;
mod constant;
mod handler;
mod hole;
mod linked_list_allocator;
mod kalloc;
mod mutex;
mod palloc;
mod pointer;
mod process;
mod trap;
mod vm;

//use alloc::vec::Vec;
use core::{
    arch::{asm, global_asm},
    panic::PanicInfo,
};

use riscv::register::mstatus;

global_asm!(include_str!("init.s"));
global_asm!(include_str!("trampoline.s"));

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    //let _ = writeln!(UartLogger, "\x1b[31mKERNEL PANIC:\x1b[0m {info}");
    println!("\x1b[31mKERNEL PANIC:\x1b[0m {info}");

    //sbi::system_reset::system_reset(
    //    sbi::system_reset::ResetType::Shutdown,
    //    sbi::system_reset::ResetReason::NoReason,
    //)
    //.unwrap_or_else(|_| loop {});

    loop {}
}

/// Main program function
#[no_mangle]
unsafe extern "C" fn kernel_main(_hartid: usize, _dtb: usize) -> () {
    println!("started!");
    println!("DOoOM os");
    palloc::init();
    kalloc::init();
    trap::init();

    unsafe {
        // mret will set the mode to machine
        mstatus::set_mpp(mstatus::MPP::Machine);
    }

    let user_stack = palloc::alloc().unwrap();

    let mut state: trap::TrapState = trap::TrapState {
        registers: Default::default(),
        mepc: user_main as usize,
        kernel_sp: 0,
    };

    println!("user_main: {:x}", state.mepc);

    state.registers.sp = usize::from(user_stack) * 4096 + 4088;

    print!("Hello world!\n");
    print!("Hello world!\n");

    loop {
        unsafe { trap::run_user(&mut state) };
        handler::handler(&mut state);
    }
}

extern "C" fn user_main() -> () {
    loop {
        print!("Hello users!!!\n");

        for _ in 0..1000 {
            unsafe { asm!("nop") };
        }

        unsafe { asm!("ecall") };
    }
}
