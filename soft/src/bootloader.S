.section .text.init
.globl print_string
.globl _start

#define SPI_BASE 0x50000000
#define UART_BASE 0x10000000

#define SEND_SPI(arg, tmp) \
  li tmp, SPI_BASE; \
  sb arg, 0(tmp)

#define RECEIVE_SPI(out, tmp) \
  li tmp, SPI_BASE; \
  fence; \
  lb out, 0(tmp)

#define REBOOT \
  j _start

#define SET_SPI_CLK(arg, tmp) \
  li tmp, SPI_BASE; \
  sb arg, 2(tmp)

#define SET_SPI_CS(arg, tmp) \
  li tmp, SPI_BASE; \
  sb arg, 1(tmp)

#define RANGE_WITH(symb, begin, end, step, var, tmp, code...) \
  li var, begin; \
  li tmp, end; \
  symb:; \
  beq var, tmp, symb f; \
  code; \
  addi var, var, step; \
  j symb b; \
  symb:;

#define RANGE(begin, end, step, var, tmp, code...) \
  RANGE_WITH(1, begin, end, step, var, tmp, code)

_start:
  la t0, bss_start
  la t1, bss_end
  bgeu t0, t1, .bss_zero_loop_end
.bss_zero_loop:
  sb zero, (t0)
  addi t0, t0, 1
  bltu t0, t1, .bss_zero_loop
.bss_zero_loop_end:

  # Set the stack to the stack_top address
  la sp, stack_top

  # print start message
  la a0, start_msg
  call print_string

  # call reset_spi
  # call send_cmd0
  # call send_cmd8
  # call quit_idle_mode

  # start the kernel
  call kernel_main
infinite_loop:
  j infinite_loop

# Initialize the SPI channel before sending the first commands
reset_spi:
  addi sp, sp, -8
  sw ra, 0(sp)

  li a0, 1
  SET_SPI_CS(a0, t0)
  li a0, 32
  SET_SPI_CLK(a0, t0)

  li t0, 1000
1:
  beqz t0, 2f
  addi t0, t0, -1
  j 1b
2:
  li t0, 160
3:
  beqz t0, 4f
  addi t0, t0, -1
  li a0, 0xFF

  sw t0, 4(sp)
  call send_spi
  lw t0, 4(sp)

  j 3b
4:

  li a0, 0
  SET_SPI_CS(a0, t0)

  lw ra, 0(sp)
  addi sp, sp, 8
  ret


# Send the first byte of `a0` to the spi channel and get the result using `a0`
send_spi:
  SEND_SPI(a0, t0)
  RECEIVE_SPI(a0, t0)
  ret


# Set the chip select wire of the channel of the SD card
set_spi_cs:
  SET_SPI_CS(a0, t0)
  ret


# Set the clock frequency as the value in a0
set_spi_clk:
  SET_SPI_CLK(a0, t0)
  ret


send_cmd0:
  addi sp, sp, -4 * 4
  sw ra, 4 * 0(sp)
  sw s0, 4 * 1(sp)
  li s0, 10

1:
  la a0, send_cmd0_msg
  call print_string
  li a1, 0xFFFF4000
  li a0, 0x00000095
  call send_cmd
  call pp_response1

  addi s0, s0, -1
  beqz s0, 1f

  andi a0, a0, 0b11111110
  bnez a0, 1b

1:
  lw ra, 4 * 0(sp)
  lw s0, 4 * 1(sp)
  addi sp, sp, 4 * 4
  ret


send_cmd8:
  addi sp, sp, -4 * 4
  sw ra, 4 * 0(sp)
  sw s0, 4 * 1(sp)

  la a0, send_cmd8_msg
  call print_string
  li a1, 0xFFFF4800
  li a0, 0x0001AA87
  call send_cmd
  call pp_response1

  li a0, 0xFF
  call send_spi
  call print_byte
  li a0, 0xFF
  call send_spi
  call print_byte
  li a0, 0xFF
  call send_spi
  call print_byte
  li a0, 0xFF
  call send_spi
  call print_byte

  call print_endline

  lw ra, 4 * 0(sp)
  lw s0, 4 * 1(sp)
  addi sp, sp, 4 * 4
  ret


send_cmd55:
  addi sp, sp, -4 * 4
  sw ra, 4 * 0(sp)
  sw s0, 4 * 1(sp)

  la a0, send_cmd55_msg
  call print_string
  li a1, 0xFFFF7700
  li a0, 0x00000000
  call send_cmd
  call pp_response1

  lw ra, 4 * 0(sp)
  lw s0, 4 * 1(sp)
  addi sp, sp, 4 * 4
  ret


send_cmd41:
  addi sp, sp, -4 * 4
  sw ra, 4 * 0(sp)
  sw s0, 4 * 1(sp)

  la a0, send_cmd41_msg
  call print_string
  li a1, 0xFFFF6940
  li a0, 0x00000000
  call send_cmd
  call pp_response1

  lw ra, 4 * 0(sp)
  lw s0, 4 * 1(sp)
  addi sp, sp, 4 * 4
  ret


quit_idle_mode:
  addi sp, sp, -4 * 4
  sw ra, 4 * 0(sp)
  sw s0, 4 * 1(sp)

1:
  call send_cmd55
  call send_cmd41
  andi a0, a0, 1
  bnez a0, 1b

  lw ra, 4 * 0(sp)
  lw s0, 4 * 1(sp)
  addi sp, sp, 4 * 4
  ret


# Take a command in {a1,a0} and return the first byte of response in a0
send_cmd:
  addi sp, sp, -4 * 4

  sw ra, 0 * 4(sp)
  sw s0, 1 * 4(sp)
  sw s1, 2 * 4(sp)
  mv s0, a0
  mv s1, a1

  srli a0, s1, 24
  SEND_SPI(a0, t0)

  srli a0, s1, 16
  SEND_SPI(a0, t0)

  srli a0, s1, 8
  SEND_SPI(a0, t0)

  srli a0, s1, 0
  SEND_SPI(a0, t0)

  srli a0, s0, 24
  SEND_SPI(a0, t0)

  srli a0, s0, 16
  SEND_SPI(a0, t0)

  srli a0, s0, 8
  SEND_SPI(a0, t0)

  srli a0, s0, 0
  SEND_SPI(a0, t0)

  # s0 represent the timeout
  li s0, 10
1:
  li a0, 0xFF
  call send_spi

  addi s0, s0, -1
  beqz s0, 1f

  li t0, 0xFF
  beq a0, t0, 1b

1:
  lw ra, 0 * 4(sp)
  lw s0, 1 * 4(sp)
  lw s1, 2 * 4(sp)
  addi sp, sp, 4 * 4
  ret


# Pretty print a Response1 message from the SD card, return the initial value of
# a0 in a0
pp_response1:
  beqz a0, 2f

  # Keep a 16 bytes alignment
  addi sp, sp, -4 * 4
  sw ra, 4 * 0(sp)
  sw s0, 4 * 1(sp)
  sw a0, 4 * 2(sp)
  mv s0, a0

  la a0, response1_msg
  call print_string
1:
  andi t0, s0, 0b00000001
  beqz t0, 1f
  la a0, idle_msg
  call print_string
1:
  andi t0, s0, 0b00000010
  beqz t0, 1f
  la a0, erase_reset_msg
  call print_string
1:
  andi t0, s0, 0b00000100
  beqz t0, 1f
  la a0, illegal_command_msg
  call print_string
1:
  andi t0, s0, 0b00001000
  beqz t0, 1f
  la a0, crc_error_msg
  call print_string
1:
  andi t0, s0, 0b00010000
  beqz t0, 1f
  la a0, erase_sequence_error_msg
  call print_string
1:
  andi t0, s0, 0b00100000
  beqz t0, 1f
  la a0, address_error_msg
  call print_string
1:
  andi t0, s0, 0b01000000
  beqz t0, 1f
  la a0, parameter_error_msg
  call print_string
1:
  lw ra, 4 * 0(sp)
  lw s0, 4 * 1(sp)
  lw a0, 4 * 2(sp)
  addi sp, sp, 4 * 4
2:
  ret


# print an integer in a0
print_unsigned_decimal:
  addi sp, sp, -4 * 10
  li t1, 10
  li t2, 0

  RANGE(0, 4 * 10, 4, t2, t4,
    remu t0, a0, t1;
    divu a0, a0, t1;
    add t3, t2, sp;
    sw t0, 0(t3)
  )

  RANGE(4 * 9, -4, -4, t2, t4,
    add t3, t2, sp;
    lw t0, 0(t3);
    ori t0, t0, 0x30;

    li t1, UART_BASE;
    sb t0, 0(t1)
  )

  addi sp, sp, 4 * 10
  ret


# print a signed integer in a0
print_signed_decimal:
  addi sp, sp, -4
  sw ra, 0(sp)

  bltz a0, 1f
  call print_unsigned_decimal
  j 2f
1:
  li t0, UART_BASE
  li t1, 45
  sb t1, 0(t0)
  neg a0, a0
  call print_unsigned_decimal
2:
  lw ra, 0(sp)
  addi sp, sp, 4
  ret

print_byte:
  andi t0, a0, 0x0F
  andi t1, a0, 0xF0
  srli t1, t1, 4
  li t3, UART_BASE
  li t2, 10

  blt t1, t2, 1f
  addi t1, t1, 0x41 - 10
  sb t1, 0(t3)
  j 2f
1:
  addi t1, t1, 0x30
  sb t1, 0(t3)
2:

  blt t0, t2, 1f
  addi t0, t0, 0x41 - 10
  sb t0, 0(t3)
  j 2f
1:
  addi t0, t0, 0x30
  sb t0, 0(t3)
2:
  ret

print_half:
  addi sp, sp, -4 * 4
  sw ra, 4 * 0(sp)
  sw s0, 4 * 1(sp)

  mv s0, a0
  srli a0, a0, 8
  call print_byte
  mv a0, s0
  call print_byte

  lw ra, 4 * 0(sp)
  lw s0, 4 * 1(sp)
  addi sp, sp, 4 * 4
  ret

print_word:
  addi sp, sp, -4 * 4
  sw ra, 4 * 0(sp)
  sw s0, 4 * 1(sp)

  mv s0, a0
  srli a0, a0, 16
  call print_half
  mv a0, s0
  call print_half

  lw ra, 4 * 0(sp)
  lw s0, 4 * 1(sp)
  addi sp, sp, 4 * 4
  ret



print_endline:
  li t0, UART_BASE
  li t1, 10
  sb t1, 0(t0)
  ret


print_string:
  li t0, UART_BASE
1:
  lb t1,0(a0)
  beqz t1, 1f
  sb t1,0(t0)
  addi a0,a0,1
  j 1b
1:
  ret


.section .data
start_msg:
  .string "Bootloader start!\n"
response1_msg:
  .string "Response1:\n"
idle_msg:
  .string "  idle\n"
erase_reset_msg:
  .string "  erase reset\n"
illegal_command_msg:
  .string "  illegaal command\n"
crc_error_msg:
  .string "  crc error\n"
erase_sequence_error_msg:
  .string "  erase sequence error\n"
address_error_msg:
  .string "  address error\n"
parameter_error_msg:
  .string "  parameter error\n"
send_cmd0_msg:
  .string "Send command 0\n"
send_cmd8_msg:
  .string "Send command 8\n"
send_cmd41_msg:
  .string "Send command 41\n"
send_cmd55_msg:
  .string "Send command 55\n"
send_cmd17_msg:
  .string "Send command 17\n"

.section .bss
.align 16
.skip 0x1000
stack_top:
.skip 0x4
