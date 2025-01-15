RTL = rtl
BUILD = build
BSIM = bsim
PACKAGES = ./src/:+
SIM_FILE = ./build/mkTop_sim
TOP = src/Top.bs

SIM_MODULE = mkCPU_SIM


LIB = \
			$(BLUESPECDIR)/Verilog/SizedFIFO.v \
			$(BLUESPECDIR)/Verilog/SizedFIFO0.v \
			$(BLUESPECDIR)/Verilog/FIFO1.v \
			$(BLUESPECDIR)/Verilog/FIFO2.v \
			$(BLUESPECDIR)/Verilog/FIFO20.v \
			$(BLUESPECDIR)/Verilog/BRAM1.v \
			$(BLUESPECDIR)/Verilog/BRAM2.v \
			$(BLUESPECDIR)/Verilog/RevertReg.v \
			$(BLUESPECDIR)/Verilog/RegFile.v \
			$(BLUESPECDIR)/Verilog/RegFileLoad.v \
			src/sdram_axi.v \
			src/Top.v

VGA_LIB = \
			src/tmds_encoder.v \
			src/clk_25_system.v \
			src/fake_differential.v \
			src/vga2dvid.v

BSC_FLAGS = -show-schedule -show-range-conflict -keep-fires -aggressive-conditions \
						-check-assert -no-warn-action-shadowing

SYNTH_FLAGS = -bdir $(BUILD) -vdir $(RTL) -simdir $(BUILD) \
							-info-dir $(BUILD) -fdir $(BUILD) -D BSIM

BSIM_FLAGS = -bdir $(BSIM) -vdir $(BSIM) -simdir $(BSIM) \
							-info-dir $(BSIM) -fdir $(BSIM) -D BSIM -l pthread

test:
	elf_to_hex/elf_to_hex soft/zig-out/bin/zig-unix.elf Mem.hex
	riscv32-none-elf-objdump soft/zig-out/bin/zig-unix.elf -D \
		> soft/firmware.asm

test_rust:
	elf_to_hex/elf_to_hex ./rust/target/riscv32im-unknown-none-elf/release/SuperOS Mem.hex
	riscv32-none-elf-objdump soft/zig-out/bin/zig-unix.elf -D \
		> soft/firmware.asm

compile:
	bsc \
		$(SYNTH_FLAGS) $(BSC_FLAGS) -cpp +RTS -K128M -RTS \
		-p $(PACKAGES) -verilog -u -g mkCPU $(TOP)


link:
	bsc -e mkCPU -verilog -o $(SIM_FILE) -vdir $(RTL) -bdir $(BUILD) \
		-info-dir $(BUILD) -vsim iverilog $(RTL)/mkCPU.v

sim:
	bsc $(BSC_FLAGS) $(BSIM_FLAGS) -p $(PACKAGES) -sim -u -g $(SIM_MODULE) $(TOP)
	bsc $(BSC_FLAGS) $(BSIM_FLAGS) -sim -e $(SIM_MODULE) -o \
		$(BSIM)/bsim $(BSIM)/*.ba
	./bsim/bsim -m 10000000

yosys:
	yosys \
		-DULX3S -q -p "synth_ecp5 -abc9 -abc2 -top mkTop -json ./build/mkTop.json" \
		rtl/* $(LIB) $(VGA_LIB)

		#-DULX3S -q -p "synth_ecp5 -noabc9 -top mkTop -json ./build/mkTop.json" \
		#-DULX3S -q -p "synth_ecp5 -abc9 -top mkTop -json ./build/mkTop.json" \

yosys_ice40:
	yosys \
		-p "synth_ice40 -top mkTop -json ./build/mkTop.json" \
		rtl/* $(LIB) $(VGA_LIB)

nextpnr:
	nextpnr-ecp5 --force --timing-allow-fail --json ./build/mkTop.json --lpf ulx3s.lpf \
		--textcfg ./build/mkTop_out.config --85k --freq 40 --package CABGA381

nextpnr_gui:
	nextpnr-ecp5 --force --timing-allow-fail --json ./build/mkTop.json --lpf ulx3s.lpf \
		--textcfg ./build/mkTop_out.config --85k --freq 40 --package CABGA381 --gui

ecppack:
	ecppack --compress --svf-rowsize 100000 --svf ./build/mkTop.svf \
		./build/mkTop_out.config ./build/mkTop.bit

ram_simulate:
	iverilog -o build/test_sdram.vvp -s test_sdram \
		simulation/test_sdram.v rtl/* simulation/mt48lc16m16a2.v $(LIB)
	vvp build/test_sdram.vvp

simulate: link
	$(SIM_FILE)

fujprog:
	sudo fujprog build/mkTop.bit

fujprog_t:
	sudo fujprog build/mkTop.bit -t

clean:
	rm -rf $(BUILD)/*
	rm -rf $(BSIM)/*
	rm -rf $(RTL)/*
