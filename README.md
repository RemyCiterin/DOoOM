# DOoOM
DOoOM Out-Of-Order Machine is a Risc-V CPU with some interresting features:
- Machine mode
- M-extension: one cycle multiplication using $18x18$ multipliers, and a 34
    cycles division
- A D-cache using a modular cache pipeline, for the moment I and D ports are
    not synchronized
- HDMI output using a frame-buffer and a 256 color palette
- A SDRAM support using an AXI4 bridge
- UART interrupts

This project is for educational purposes only, and DOoOM is most likely not
suitable for industrial use because it uses too much resources to be an
efficient microcontroller and not enough to beat out-of-order industrial
CPUs on benchmarks.

A reasonable developer would probably have made better caches, better
interconnects, drivers or support for the supervisor mode, but it was much
more fun to make it out of order.

The original goal was to run DOOM over or his name but it may take a little
more time: micro SD card driver + compile DOOM with a suitable firmware/driver,
probably one day...
