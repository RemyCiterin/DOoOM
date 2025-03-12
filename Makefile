RTL = rtl
BUILD = build
BSIM = bsim
PACKAGES = ./src/:./src/lsu/:./src/cache/:+
SIM_FILE = ./build/mkTop_sim
TOP = src/Soc.bs

BSIM_MODULE = mkCPU_SIM

BUILD_MODULE = mkCPU


LIB = \
			$(BLUESPECDIR)/Verilog/SizedFIFO.v \
			$(BLUESPECDIR)/Verilog/SizedFIFO0.v \
			$(BLUESPECDIR)/Verilog/FIFO1.v \
			$(BLUESPECDIR)/Verilog/FIFO2.v \
			$(BLUESPECDIR)/Verilog/FIFO20.v \
			$(BLUESPECDIR)/Verilog/FIFO10.v \
			$(BLUESPECDIR)/Verilog/BRAM1.v \
			$(BLUESPECDIR)/Verilog/BRAM1BELoad.v \
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
						-check-assert -no-warn-action-shadowing -sched-dot

SYNTH_FLAGS = -bdir $(BUILD) -vdir $(RTL) -simdir $(BUILD) \
							-info-dir $(BUILD) -fdir $(BUILD) #-D BSIM

BSIM_FLAGS = -bdir $(BSIM) -vdir $(BSIM) -simdir $(BSIM) \
							-info-dir $(BSIM) -fdir $(BSIM) -D BSIM -l pthread

DOT_FILES = $(shell ls ./build/*_combined_full.dot) \
	$(shell ls ./build/*_conflict.dot)

svg:
	$(foreach f, $(DOT_FILES), sed -i '/_init_register_file/d' $(f);)
	$(foreach f, $(DOT_FILES), sed -i '/_update_register_file/d' $(f);)
	$(foreach f, $(DOT_FILES), sed -i '/_ehr_canon/d' $(f);)
	$(foreach f, $(DOT_FILES), sed -i '/_block_ram_apply_read/d' $(f);)
	$(foreach f, $(DOT_FILES), sed -i '/_block_ram_apply_write/d' $(f);)
	$(foreach f, $(DOT_FILES), sed -i '/Sched /d' $(f);)
	$(foreach f, $(DOT_FILES), dot -Tsvg $(f) > $(f:.dot=.svg);)

test:
	elf_to_hex/elf_to_hex soft/zig-out/bin/bootloader.elf Mem.hex
	riscv32-none-elf-objdump soft/zig-out/bin/bootloader.elf -D \
		> soft/firmware.asm

test_coremark:
	elf_to_hex/elf_to_hex ./coremark/coremark.bare.riscv Mem.hex

test_rust:
	elf_to_hex/elf_to_hex ./rust/target/riscv32im-unknown-none-elf/release/SuperOS Mem.hex
	riscv32-none-elf-objdump ./rust/target/riscv32im-unknown-none-elf/release/SuperOS -D \
		> rust/firmware.asm

compile:
	bsc \
		$(SYNTH_FLAGS) $(BSC_FLAGS) -cpp +RTS -K128M -RTS \
		-p $(PACKAGES) -verilog -u -g $(BUILD_MODULE) $(TOP)

link:
	bsc -e mkCPU -verilog -o $(SIM_FILE) -vdir $(RTL) -bdir $(BUILD) \
		-info-dir $(BUILD) -vsim iverilog $(RTL)/$(BUILD_MODULE).v

sim:
	bsc $(BSC_FLAGS) $(BSIM_FLAGS) -p $(PACKAGES) -sim -u -g $(BSIM_MODULE) $(TOP)
	bsc $(BSC_FLAGS) $(BSIM_FLAGS) -sim -e $(BSIM_MODULE) -o \
		$(BSIM)/bsim $(BSIM)/*.ba
	./bsim/bsim -m 1000000000

run:
	./bsim/bsim -m 1000000000

# Load the binary in the SD card
load:
	riscv32-none-elf-objcopy -O binary ./soft/zig-out/bin/kernel.elf build/kernel
	sudo dd if=build/kernel of=/dev/sdf
	sync

# Load the binary in the SD card
load_coremark:
	riscv32-none-elf-objcopy -O binary ./coremark/coremark.bare.riscv build/kernel
	sudo dd if=build/kernel of=/dev/sdf
	sync


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
