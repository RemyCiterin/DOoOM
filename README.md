# DOoOM
DOoOM Out-Of-Order Machine is a Risc-V CPU with some interresting features:
- Machine mode
- M-extension: one cycle multiplication using $18x18$ multipliers, and a 34
    cycles division
- D and I-cache using a modular cache pipeline, for the moment I and D ports are
    not synchronized, except using explicit `zicbom` instructions.
- HDMI output using a frame-buffer and a 256 color palette
- A SDRAM support using an AXI4 bridge
- UART interrupts

Of course DOoOM can run DOOM. To do it, run `nix-shell`, then connect
your SD card to your computer, overwrite `/dev/sd*` by the one of the card in
`doom_riscv/src/riscv/Makefile`, and run:

```
make -C doom_riscv/src/riscv
make -C doom_riscv/src/riscv load
```

Then connect an `ULX3S` boad with your computer and run:

```
cd soft
zig build --release=small
cd ..
make test compile yosys nextpnr ecppack fujprog_t
```

Then use
- button `1` to fire
- button `2+up` to select an entry in the menu
- button `2+down` to open a door
- the arrows
