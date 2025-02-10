# .section .text.init
# .global _start
# _start:
#     la t0, bss_start
#     la t1, bss_end
#     bgeu t0, t1, .bss_zero_loop_end
# .bss_zero_loop:
#     sb zero, (t0)
#     addi t0, t0, 1
#     bltu t0, t1, .bss_zero_loop
# .bss_zero_loop_end:
#
#     la sp, stack_top
#     jal kernel_main
# .infinite_loop:
#     j .infinite_loop
#
# .section .bss
# .align 4
#     .skip 0x1000
# stack_top:
