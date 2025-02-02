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
mod fixed;
mod screen;
mod vm;
use core::{
    arch::{asm, global_asm},
    panic::PanicInfo,
};

use screen::Pixel;

use crate::trap::*;

use riscv::register::{mstatus, mie, minstret, mcycle};

global_asm!(include_str!("init.s"));
global_asm!(include_str!("trampoline.s"));

use alloc::vec::Vec;
use alloc::collections::LinkedList;
use alloc::collections::BTreeSet;
use alloc::boxed::Box;

use crate::pointer::PhysAddr;

fn linked_list_bench() {
    let mut list: LinkedList<u32> = LinkedList::new();

    let size: u32 = 1000;

    for i in 0..size {
        list.push_back(i);
    }

    let mut count: usize = 0;
    // searches
    for _ in 0..1 {
        for i in 0..size {
            if count % 100 == 0 {
                println!("found {} elements in the list", count);
            }

            for x in list.iter() {
                if x == &i {count += 1;}
            }
        }
    }

    println!("found {} elements in the list", count);
}

fn vector_bench() {
    let mut list: Vec<u32> = Vec::new();

    let size: u32 = 1000;

    for i in 0..size {
        list.push(i);
    }

    let mut count: usize = 0;
    // searches
    for _ in 0..1 {
        for i in 0..size {
            if count % 100 == 0 {
                println!("found {} elements in the list", count);
            }

            for x in list.iter() {
                if x == &i {count += 1;}
            }
        }
    }

    println!("found {} elements in the list", count);
}

// BTree are implemented using a linear search with a comparison instead of
// counting the elements less than the searched key, so it cause a LOT of
// branch mispredictions
fn btree_bench() {
    let mut list: BTreeSet<u32> = BTreeSet::new();

    let size: u32 = 1000;

    for i in 0..size {
        list.insert(i);
    }

    let mut count: usize = 0;
    // searches
    for _ in 0..1 {
        for i in 0..size {
            //for x in list.iter() {
            //    if x == &i {count += 1;}
            //}
            if count % 100 == 0 {
                println!("found {} elements in the list", count);
            }

            if list.contains(&i) {count += 1;}
        }
    }

    println!("found {} elements in the list", count);
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    println!("\x1b[31mKERNEL PANIC:\x1b[0m {info}");

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
        mstatus::set_mpie();

        mie::set_mext();
        mie::set_mtimer();
    }

    let user_stack = palloc::alloc().unwrap();

    let mut state: TrapState = TrapState {
        registers: Default::default(),
        mepc: user_main as usize,
        kernel_sp: 0,
    };

    println!("user_main: {:x}", state.mepc);

    state.registers.sp = usize::from(user_stack) * 4096 + 4088;

    print!("Hello world!\n");

    loop {
        unsafe { trap::run_user(&mut state) };
        handler::handler(&mut state);
    }
}

extern "C" fn user_main() -> () {
    loop {
        print!("Hello users!!!\n");

        let mut time = 0-mcycle::read();
        let mut instret = 0-minstret::read();

        //println!("start clear screen");
        for i in 0..640 {
            for j in 0..480 {
                let pixel = Pixel::new(127, (i & 255) as u8, j as u8);
                pixel.write_frame_buffer(i, j);
            }
        }

        //println!("stop clear screen");

        //btree_bench();

        time += mcycle::read();
        instret += minstret::read();

        println!("time: {} instret: {}", time, instret);

        unsafe { asm!("ecall") };


        let x: usize = 0;
        unsafe {
            asm!("cbo.clean 0(a0)", in("a0") x);
        }
    }
}
