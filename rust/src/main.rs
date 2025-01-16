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
use core::{
    arch::{asm, global_asm},
    panic::PanicInfo,
};

use crate::trap::*;

use riscv::register::{mstatus, mie, minstret, mcycle};

global_asm!(include_str!("init.s"));
global_asm!(include_str!("trampoline.s"));

use alloc::vec::Vec;
use alloc::collections::LinkedList;
use alloc::collections::BTreeSet;
use alloc::boxed::Box;

fn linked_list_bench() {
    let mut list: LinkedList<u32> = LinkedList::new();

    for i in 0..100 {
        list.push_back(i);
    }

    let mut count: usize = 0;
    // searches
    for _ in 0..10 {
        for i in 0..100 {
            for x in list.iter() {
                if x == &i {count += 1;}
            }
        }
    }

    println!("found {} elements in the list", count);
}

fn vector_bench() {
    let mut list: Vec<u32> = Vec::new();

    for i in 0..100 {
        list.push(i);
    }

    let mut count: usize = 0;
    // searches
    for _ in 0..10 {
        for i in 0..100 {
            for x in list.iter() {
                if x == &i {count += 1;}
            }
        }
    }

    println!("found {} elements in the list", count);
}

pub const B: usize = 6;

#[derive(Clone, PartialEq, PartialOrd, Eq, Ord)]
struct BSet {
    keys: [u32; B],
    valids: [bool; B],
    nexts: [Option<Box<BSet>>; B+1],
    height: u32
}

impl BSet {
    pub fn init() -> Self {
        Self {
            keys: [0; B],
            valids: [false; B],
            nexts: [None, None, None, None, None, None, None],
            height: 0
        }
    }

    pub fn insert_node(&mut self, key: u32) -> Option<u32> {
        let mut count: usize = 0;
        for i in 0..B {
            count += if self.valids[i] && key < self.keys[i] {1} else {0};
        }

        if count+1 < B && self.valids[count+1] && self.keys[count+1] == key {
            return None;
        }



    }

    pub fn contains(&self, key: u32) -> bool {
        let mut count: usize = 0;
        for i in 0..B {
            count += if self.valids[i] && key < self.keys[i] {1} else {0};
        }

        if count+1 < B && self.valids[count+1] && self.keys[count+1] == key {
            return true;
        }

        if let Some(tree) = &self.nexts[count] {
            return tree.contains(key);
        }

        return false;
    }
}

// BTree are implemented using a linear search with a comparison instead of
// counting the elements less than the searched key, so it cause a LOT of
// branch mispredictions
fn btree_bench() {
    let mut list: BTreeSet<u32> = BTreeSet::new();

    for i in 0..100 {
        list.insert(i);
    }

    let mut count: usize = 0;
    // searches
    for _ in 0..10 {
        for i in 0..100 {
            //for x in list.iter() {
            //    if x == &i {count += 1;}
            //}
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

        vector_bench();

        time += mcycle::read();
        instret += minstret::read();

        println!("time: {} instret: {}", time, instret);

        unsafe { asm!("ecall") };
    }
}
