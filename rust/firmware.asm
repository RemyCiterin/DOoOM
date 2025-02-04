
./rust/target/riscv32im-unknown-none-elf/release/SuperOS:     file format elf32-littleriscv


Disassembly of section .text:

80000000 <_start>:
80000000:	00005297          	auipc	t0,0x5
80000004:	d4828293          	addi	t0,t0,-696 # 80004d48 <__bss_start>

80000008 <.Lpcrel_hi1>:
80000008:	00006317          	auipc	t1,0x6
8000000c:	d7030313          	addi	t1,t1,-656 # 80005d78 <__bss_end>
80000010:	0062f863          	bgeu	t0,t1,80000020 <.Lpcrel_hi2>

80000014 <.bss_zero_loop>:
80000014:	00028023          	sb	zero,0(t0)
80000018:	00128293          	addi	t0,t0,1
8000001c:	fe62ece3          	bltu	t0,t1,80000014 <.bss_zero_loop>

80000020 <.Lpcrel_hi2>:
80000020:	00006117          	auipc	sp,0x6
80000024:	d4010113          	addi	sp,sp,-704 # 80005d60 <_ZN7SuperOS6kalloc16KERNEL_ALLOCATOR17h0e08997bf1bee0d5E>
80000028:	7f0000ef          	jal	80000818 <kernel_main>

8000002c <.infinite_loop>:
8000002c:	0000006f          	j	8000002c <.infinite_loop>

80000030 <run_user>:
80000030:	fc410113          	addi	sp,sp,-60
80000034:	00312023          	sw	gp,0(sp)
80000038:	00412223          	sw	tp,4(sp)
8000003c:	00112423          	sw	ra,8(sp)
80000040:	00812623          	sw	s0,12(sp)
80000044:	00912823          	sw	s1,16(sp)
80000048:	01212a23          	sw	s2,20(sp)
8000004c:	01312c23          	sw	s3,24(sp)
80000050:	01412e23          	sw	s4,28(sp)
80000054:	03512023          	sw	s5,32(sp)
80000058:	03612223          	sw	s6,36(sp)
8000005c:	03712423          	sw	s7,40(sp)
80000060:	03812623          	sw	s8,44(sp)
80000064:	03912823          	sw	s9,48(sp)
80000068:	03a12a23          	sw	s10,52(sp)
8000006c:	03b12c23          	sw	s11,56(sp)
80000070:	34051073          	.insn	4, 0x34051073
80000074:	08252023          	sw	sp,128(a0)
80000078:	07c52283          	lw	t0,124(a0)
8000007c:	34129073          	.insn	4, 0x34129073
80000080:	00052083          	lw	ra,0(a0)
80000084:	00452103          	lw	sp,4(a0)
80000088:	00852183          	lw	gp,8(a0)
8000008c:	00c52203          	lw	tp,12(a0)
80000090:	01052283          	lw	t0,16(a0)
80000094:	01452303          	lw	t1,20(a0)
80000098:	01852383          	lw	t2,24(a0)
8000009c:	01c52403          	lw	s0,28(a0)
800000a0:	02052483          	lw	s1,32(a0)
800000a4:	02852583          	lw	a1,40(a0)
800000a8:	02c52603          	lw	a2,44(a0)
800000ac:	03052683          	lw	a3,48(a0)
800000b0:	03452703          	lw	a4,52(a0)
800000b4:	03852783          	lw	a5,56(a0)
800000b8:	03c52803          	lw	a6,60(a0)
800000bc:	04052883          	lw	a7,64(a0)
800000c0:	04452903          	lw	s2,68(a0)
800000c4:	04852983          	lw	s3,72(a0)
800000c8:	04c52a03          	lw	s4,76(a0)
800000cc:	05052a83          	lw	s5,80(a0)
800000d0:	05452b03          	lw	s6,84(a0)
800000d4:	05852b83          	lw	s7,88(a0)
800000d8:	05c52c03          	lw	s8,92(a0)
800000dc:	06052c83          	lw	s9,96(a0)
800000e0:	06452d03          	lw	s10,100(a0)
800000e4:	06852d83          	lw	s11,104(a0)
800000e8:	06c52e03          	lw	t3,108(a0)
800000ec:	07052e83          	lw	t4,112(a0)
800000f0:	07452f03          	lw	t5,116(a0)
800000f4:	07852f83          	lw	t6,120(a0)
800000f8:	02452503          	lw	a0,36(a0)
800000fc:	30200073          	mret

80000100 <user_trap>:
80000100:	34051573          	.insn	4, 0x34051573
80000104:	00152023          	sw	ra,0(a0)
80000108:	00252223          	sw	sp,4(a0)
8000010c:	00352423          	sw	gp,8(a0)
80000110:	00452623          	sw	tp,12(a0)
80000114:	00552823          	sw	t0,16(a0)
80000118:	00652a23          	sw	t1,20(a0)
8000011c:	00752c23          	sw	t2,24(a0)
80000120:	00852e23          	sw	s0,28(a0)
80000124:	02952023          	sw	s1,32(a0)
80000128:	02b52423          	sw	a1,40(a0)
8000012c:	02c52623          	sw	a2,44(a0)
80000130:	02d52823          	sw	a3,48(a0)
80000134:	02e52a23          	sw	a4,52(a0)
80000138:	02f52c23          	sw	a5,56(a0)
8000013c:	03052e23          	sw	a6,60(a0)
80000140:	05152023          	sw	a7,64(a0)
80000144:	05252223          	sw	s2,68(a0)
80000148:	05352423          	sw	s3,72(a0)
8000014c:	05452623          	sw	s4,76(a0)
80000150:	05552823          	sw	s5,80(a0)
80000154:	05652a23          	sw	s6,84(a0)
80000158:	05752c23          	sw	s7,88(a0)
8000015c:	05852e23          	sw	s8,92(a0)
80000160:	07952023          	sw	s9,96(a0)
80000164:	07a52223          	sw	s10,100(a0)
80000168:	07b52423          	sw	s11,104(a0)
8000016c:	07c52623          	sw	t3,108(a0)
80000170:	07d52823          	sw	t4,112(a0)
80000174:	07e52a23          	sw	t5,116(a0)
80000178:	07f52c23          	sw	t6,120(a0)
8000017c:	340022f3          	.insn	4, 0x340022f3
80000180:	02552223          	sw	t0,36(a0)
80000184:	08052103          	lw	sp,128(a0)
80000188:	341022f3          	.insn	4, 0x341022f3
8000018c:	06552e23          	sw	t0,124(a0)
80000190:	00012183          	lw	gp,0(sp)
80000194:	00412203          	lw	tp,4(sp)
80000198:	00812083          	lw	ra,8(sp)
8000019c:	00c12403          	lw	s0,12(sp)
800001a0:	01012483          	lw	s1,16(sp)
800001a4:	01412903          	lw	s2,20(sp)
800001a8:	01812983          	lw	s3,24(sp)
800001ac:	01c12a03          	lw	s4,28(sp)
800001b0:	02012a83          	lw	s5,32(sp)
800001b4:	02412b03          	lw	s6,36(sp)
800001b8:	02812b83          	lw	s7,40(sp)
800001bc:	02c12c03          	lw	s8,44(sp)
800001c0:	03012c83          	lw	s9,48(sp)
800001c4:	03412d03          	lw	s10,52(sp)
800001c8:	03812d83          	lw	s11,56(sp)
800001cc:	03c10113          	addi	sp,sp,60
800001d0:	00008067          	ret

800001d4 <_ZN4core3fmt3num52_$LT$impl$u20$core..fmt..Debug$u20$for$u20$usize$GT$3fmt17h10cd62dad8640825E>:
800001d4:	01c5a603          	lw	a2,28(a1)
800001d8:	01067693          	andi	a3,a2,16
800001dc:	00069a63          	bnez	a3,800001f0 <_ZN4core3fmt3num52_$LT$impl$u20$core..fmt..Debug$u20$for$u20$usize$GT$3fmt17h10cd62dad8640825E+0x1c>
800001e0:	02067613          	andi	a2,a2,32
800001e4:	00061a63          	bnez	a2,800001f8 <_ZN4core3fmt3num52_$LT$impl$u20$core..fmt..Debug$u20$for$u20$usize$GT$3fmt17h10cd62dad8640825E+0x24>
800001e8:	00003317          	auipc	t1,0x3
800001ec:	fa430067          	jr	-92(t1) # 8000318c <_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17he9e9e363faaccf29E>
800001f0:	00003317          	auipc	t1,0x3
800001f4:	d9c30067          	jr	-612(t1) # 80002f8c <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17hcc6fe785c9e9110eE>
800001f8:	00003317          	auipc	t1,0x3
800001fc:	e1830067          	jr	-488(t1) # 80003010 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..UpperHex$u20$for$u20$i32$GT$3fmt17h8b16a5bc167e7410E>

80000200 <_ZN64_$LT$core..alloc..layout..Layout$u20$as$u20$core..fmt..Debug$GT$3fmt17h3f589c9bfce4375fE>:
80000200:	fe010113          	addi	sp,sp,-32
80000204:	00112e23          	sw	ra,28(sp)
80000208:	00058293          	mv	t0,a1
8000020c:	00450793          	addi	a5,a0,4
80000210:	00a12c23          	sw	a0,24(sp)
80000214:	80004537          	lui	a0,0x80004
80000218:	01050513          	addi	a0,a0,16 # 80004010 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.5>
8000021c:	00a12423          	sw	a0,8(sp)
80000220:	01810513          	addi	a0,sp,24
80000224:	00a12223          	sw	a0,4(sp)
80000228:	00500513          	li	a0,5
8000022c:	800045b7          	lui	a1,0x80004
80000230:	02058593          	addi	a1,a1,32 # 80004020 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.6>
80000234:	800046b7          	lui	a3,0x80004
80000238:	02a68693          	addi	a3,a3,42 # 8000402a <.Lanon.10e9e605f29f28b577aacdba1819c9a4.6+0xa>
8000023c:	80004837          	lui	a6,0x80004
80000240:	00080813          	mv	a6,a6
80000244:	800048b7          	lui	a7,0x80004
80000248:	02e88893          	addi	a7,a7,46 # 8000402e <.Lanon.10e9e605f29f28b577aacdba1819c9a4.8>
8000024c:	00600613          	li	a2,6
80000250:	00400713          	li	a4,4
80000254:	00a12023          	sw	a0,0(sp)
80000258:	00028513          	mv	a0,t0
8000025c:	00002097          	auipc	ra,0x2
80000260:	78c080e7          	jalr	1932(ra) # 800029e8 <_ZN4core3fmt9Formatter26debug_struct_field2_finish17h8b989ef45de6295cE>
80000264:	01c12083          	lw	ra,28(sp)
80000268:	02010113          	addi	sp,sp,32
8000026c:	00008067          	ret

80000270 <_ZN69_$LT$core..alloc..layout..LayoutError$u20$as$u20$core..fmt..Debug$GT$3fmt17hadc1b412746cacb9E>:
80000270:	800046b7          	lui	a3,0x80004
80000274:	03368693          	addi	a3,a3,51 # 80004033 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.9>
80000278:	00b00613          	li	a2,11
8000027c:	00058513          	mv	a0,a1
80000280:	00068593          	mv	a1,a3
80000284:	00002317          	auipc	t1,0x2
80000288:	73830067          	jr	1848(t1) # 800029bc <_ZN4core3fmt9Formatter9write_str17hd607abcbb12fb4c8E>

8000028c <_ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17h43f79eca3d356742E>:
8000028c:	00054503          	lbu	a0,0(a0)
80000290:	00251513          	slli	a0,a0,0x2
80000294:	80004637          	lui	a2,0x80004
80000298:	4ac60613          	addi	a2,a2,1196 # 800044ac <.Lswitch.table._ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17h43f79eca3d356742E>
8000029c:	00a60633          	add	a2,a2,a0
800002a0:	00062603          	lw	a2,0(a2)
800002a4:	800046b7          	lui	a3,0x80004
800002a8:	4e868693          	addi	a3,a3,1256 # 800044e8 <.Lswitch.table._ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17h43f79eca3d356742E.13>
800002ac:	00a68533          	add	a0,a3,a0
800002b0:	00052683          	lw	a3,0(a0)
800002b4:	00058513          	mv	a0,a1
800002b8:	00068593          	mv	a1,a3
800002bc:	00002317          	auipc	t1,0x2
800002c0:	70030067          	jr	1792(t1) # 800029bc <_ZN4core3fmt9Formatter9write_str17hd607abcbb12fb4c8E>

800002c4 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064>:
800002c4:	fd010113          	addi	sp,sp,-48
800002c8:	02112623          	sw	ra,44(sp)
800002cc:	02812423          	sw	s0,40(sp)
800002d0:	02912223          	sw	s1,36(sp)
800002d4:	00800613          	li	a2,8
800002d8:	00050493          	mv	s1,a0
800002dc:	00b66463          	bltu	a2,a1,800002e4 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x20>
800002e0:	00800593          	li	a1,8
800002e4:	00358593          	addi	a1,a1,3
800002e8:	ffc5f413          	andi	s0,a1,-4
800002ec:	00040513          	mv	a0,s0
800002f0:	00048593          	mv	a1,s1
800002f4:	00003097          	auipc	ra,0x3
800002f8:	b58080e7          	jalr	-1192(ra) # 80002e4c <_ZN4core5alloc6layout6Layout19is_size_align_valid17hfcf08246f9a22341E>
800002fc:	00810593          	addi	a1,sp,8
80000300:	10050e63          	beqz	a0,8000041c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x158>
80000304:	80006737          	lui	a4,0x80006
80000308:	d6070713          	addi	a4,a4,-672 # 80005d60 <_ZN7SuperOS6kalloc16KERNEL_ALLOCATOR17h0e08997bf1bee0d5E>
8000030c:	00872683          	lw	a3,8(a4)
80000310:	10068663          	beqz	a3,8000041c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x158>
80000314:	40a00633          	neg	a2,a0
80000318:	00967633          	and	a2,a2,s1
8000031c:	0014d513          	srli	a0,s1,0x1
80000320:	555557b7          	lui	a5,0x55555
80000324:	55578793          	addi	a5,a5,1365 # 55555555 <.Lline_table_start2+0x555541b6>
80000328:	00f57533          	and	a0,a0,a5
8000032c:	40a48533          	sub	a0,s1,a0
80000330:	333337b7          	lui	a5,0x33333
80000334:	33378793          	addi	a5,a5,819 # 33333333 <.Lline_table_start2+0x33331f94>
80000338:	00f57833          	and	a6,a0,a5
8000033c:	00255513          	srli	a0,a0,0x2
80000340:	00f57533          	and	a0,a0,a5
80000344:	00a80533          	add	a0,a6,a0
80000348:	00455793          	srli	a5,a0,0x4
8000034c:	00f50533          	add	a0,a0,a5
80000350:	0f0f17b7          	lui	a5,0xf0f1
80000354:	f0f78793          	addi	a5,a5,-241 # f0f0f0f <.Lline_table_start2+0xf0efb70>
80000358:	00f57533          	and	a0,a0,a5
8000035c:	010107b7          	lui	a5,0x1010
80000360:	10178793          	addi	a5,a5,257 # 1010101 <.Lline_table_start2+0x100ed62>
80000364:	02f507b3          	mul	a5,a0,a5
80000368:	0187d793          	srli	a5,a5,0x18
8000036c:	fff48813          	addi	a6,s1,-1
80000370:	409008b3          	neg	a7,s1
80000374:	00470713          	addi	a4,a4,4
80000378:	00100293          	li	t0,1
8000037c:	0140006f          	j	80000390 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0xcc>
80000380:	0046a503          	lw	a0,4(a3)
80000384:	00068713          	mv	a4,a3
80000388:	00050693          	mv	a3,a0
8000038c:	08050863          	beqz	a0,8000041c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x158>
80000390:	0006ae03          	lw	t3,0(a3)
80000394:	fe8e66e3          	bltu	t3,s0,80000380 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0xbc>
80000398:	0e579463          	bne	a5,t0,80000480 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x1bc>
8000039c:	00d80eb3          	add	t4,a6,a3
800003a0:	011ef3b3          	and	t2,t4,a7
800003a4:	00068513          	mv	a0,a3
800003a8:	00d38863          	beq	t2,a3,800003b8 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0xf4>
800003ac:	008e8e93          	addi	t4,t4,8
800003b0:	011ef533          	and	a0,t4,a7
800003b4:	40d50333          	sub	t1,a0,a3
800003b8:	00850fb3          	add	t6,a0,s0
800003bc:	01c68f33          	add	t5,a3,t3
800003c0:	fdff60e3          	bltu	t5,t6,80000380 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0xbc>
800003c4:	41ff0eb3          	sub	t4,t5,t6
800003c8:	020e8e63          	beqz	t4,80000404 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x140>
800003cc:	003f8f93          	addi	t6,t6,3
800003d0:	ffcffe13          	andi	t3,t6,-4
800003d4:	008e0f93          	addi	t6,t3,8
800003d8:	fbff64e3          	bltu	t5,t6,80000380 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0xbc>
800003dc:	00072223          	sw	zero,4(a4)
800003e0:	0046a783          	lw	a5,4(a3)
800003e4:	0006a223          	sw	zero,4(a3)
800003e8:	06d38e63          	beq	t2,a3,80000464 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x1a0>
800003ec:	01de2023          	sw	t4,0(t3)
800003f0:	00fe2223          	sw	a5,4(t3)
800003f4:	0066a023          	sw	t1,0(a3)
800003f8:	01c6a223          	sw	t3,4(a3)
800003fc:	00d72223          	sw	a3,4(a4)
80000400:	0740006f          	j	80000474 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x1b0>
80000404:	00072223          	sw	zero,4(a4)
80000408:	0046a783          	lw	a5,4(a3)
8000040c:	0006a223          	sw	zero,4(a3)
80000410:	04d39663          	bne	t2,a3,8000045c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x198>
80000414:	00f72223          	sw	a5,4(a4)
80000418:	04051e63          	bnez	a0,80000474 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x1b0>
8000041c:	00000413          	li	s0,0
80000420:	0085a023          	sw	s0,0(a1)
80000424:	00812583          	lw	a1,8(sp)
80000428:	00058e63          	beqz	a1,80000444 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x180>
8000042c:	00c12583          	lw	a1,12(sp)
80000430:	80006637          	lui	a2,0x80006
80000434:	d6062683          	lw	a3,-672(a2) # 80005d60 <_ZN7SuperOS6kalloc16KERNEL_ALLOCATOR17h0e08997bf1bee0d5E>
80000438:	00b685b3          	add	a1,a3,a1
8000043c:	d6b62023          	sw	a1,-672(a2)
80000440:	0080006f          	j	80000448 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x184>
80000444:	00000513          	li	a0,0
80000448:	02c12083          	lw	ra,44(sp)
8000044c:	02812403          	lw	s0,40(sp)
80000450:	02412483          	lw	s1,36(sp)
80000454:	03010113          	addi	sp,sp,48
80000458:	00008067          	ret
8000045c:	00068e13          	mv	t3,a3
80000460:	00030e93          	mv	t4,t1
80000464:	01de2023          	sw	t4,0(t3)
80000468:	00fe2223          	sw	a5,4(t3)
8000046c:	01c72223          	sw	t3,4(a4)
80000470:	fa0506e3          	beqz	a0,8000041c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x158>
80000474:	00c12423          	sw	a2,8(sp)
80000478:	00c10593          	addi	a1,sp,12
8000047c:	fa5ff06f          	j	80000420 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064+0x15c>
80000480:	80004537          	lui	a0,0x80004
80000484:	1a450513          	addi	a0,a0,420 # 800041a4 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.33>
80000488:	00a12623          	sw	a0,12(sp)
8000048c:	00100513          	li	a0,1
80000490:	00a12823          	sw	a0,16(sp)
80000494:	00012e23          	sw	zero,28(sp)
80000498:	00400513          	li	a0,4
8000049c:	00a12a23          	sw	a0,20(sp)
800004a0:	00012c23          	sw	zero,24(sp)
800004a4:	800045b7          	lui	a1,0x80004
800004a8:	22058593          	addi	a1,a1,544 # 80004220 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.35>
800004ac:	00c10513          	addi	a0,sp,12
800004b0:	00001097          	auipc	ra,0x1
800004b4:	3d8080e7          	jalr	984(ra) # 80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>

800004b8 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064>:
800004b8:	fb010113          	addi	sp,sp,-80
800004bc:	04112623          	sw	ra,76(sp)
800004c0:	04812423          	sw	s0,72(sp)
800004c4:	04912223          	sw	s1,68(sp)
800004c8:	00800693          	li	a3,8
800004cc:	00050493          	mv	s1,a0
800004d0:	00c6e463          	bltu	a3,a2,800004d8 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x20>
800004d4:	00800613          	li	a2,8
800004d8:	00360613          	addi	a2,a2,3
800004dc:	ffc67413          	andi	s0,a2,-4
800004e0:	00040513          	mv	a0,s0
800004e4:	00003097          	auipc	ra,0x3
800004e8:	968080e7          	jalr	-1688(ra) # 80002e4c <_ZN4core5alloc6layout6Layout19is_size_align_valid17hfcf08246f9a22341E>
800004ec:	26050a63          	beqz	a0,80000760 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x2a8>
800004f0:	0084a023          	sw	s0,0(s1)
800004f4:	0004a223          	sw	zero,4(s1)
800004f8:	80006637          	lui	a2,0x80006
800004fc:	d6060613          	addi	a2,a2,-672 # 80005d60 <_ZN7SuperOS6kalloc16KERNEL_ALLOCATOR17h0e08997bf1bee0d5E>
80000500:	00862583          	lw	a1,8(a2)
80000504:	04058263          	beqz	a1,80000548 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x90>
80000508:	01062503          	lw	a0,16(a2)
8000050c:	04b4fe63          	bgeu	s1,a1,80000568 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0xb0>
80000510:	00848733          	add	a4,s1,s0
80000514:	16e5e663          	bltu	a1,a4,80000680 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x1c8>
80000518:	00c62683          	lw	a3,12(a2)
8000051c:	00868813          	addi	a6,a3,8
80000520:	00048793          	mv	a5,s1
80000524:	0104fa63          	bgeu	s1,a6,80000538 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x80>
80000528:	40d70733          	sub	a4,a4,a3
8000052c:	00e6a023          	sw	a4,0(a3)
80000530:	0006a223          	sw	zero,4(a3)
80000534:	00068793          	mv	a5,a3
80000538:	00f62423          	sw	a5,8(a2)
8000053c:	00b7a223          	sw	a1,4(a5)
80000540:	00100613          	li	a2,1
80000544:	09c0006f          	j	800005e0 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x128>
80000548:	00c62503          	lw	a0,12(a2)
8000054c:	00850593          	addi	a1,a0,8
80000550:	0cb4fc63          	bgeu	s1,a1,80000628 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x170>
80000554:	009405b3          	add	a1,s0,s1
80000558:	40a585b3          	sub	a1,a1,a0
8000055c:	00b52023          	sw	a1,0(a0)
80000560:	00052223          	sw	zero,4(a0)
80000564:	0cc0006f          	j	80000630 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x178>
80000568:	0045a603          	lw	a2,4(a1)
8000056c:	00912423          	sw	s1,8(sp)
80000570:	02060263          	beqz	a2,80000594 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0xdc>
80000574:	00c4ec63          	bltu	s1,a2,8000058c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0xd4>
80000578:	00060593          	mv	a1,a2
8000057c:	00462603          	lw	a2,4(a2)
80000580:	00912423          	sw	s1,8(sp)
80000584:	00060863          	beqz	a2,80000594 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0xdc>
80000588:	fec4f8e3          	bgeu	s1,a2,80000578 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0xc0>
8000058c:	008486b3          	add	a3,s1,s0
80000590:	18d66c63          	bltu	a2,a3,80000728 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x270>
80000594:	00b12623          	sw	a1,12(sp)
80000598:	0005a683          	lw	a3,0(a1)
8000059c:	00d58733          	add	a4,a1,a3
800005a0:	00d12823          	sw	a3,16(sp)
800005a4:	10e4ea63          	bltu	s1,a4,800006b8 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x200>
800005a8:	0095a223          	sw	s1,4(a1)
800005ac:	00c4a223          	sw	a2,4(s1)
800005b0:	00200613          	li	a2,2
800005b4:	00058493          	mv	s1,a1
800005b8:	0280006f          	j	800005e0 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x128>
800005bc:	00072583          	lw	a1,0(a4)
800005c0:	00472683          	lw	a3,4(a4)
800005c4:	00072223          	sw	zero,4(a4)
800005c8:	0004a703          	lw	a4,0(s1)
800005cc:	00d4a223          	sw	a3,4(s1)
800005d0:	00b705b3          	add	a1,a4,a1
800005d4:	00b4a023          	sw	a1,0(s1)
800005d8:	fff60613          	addi	a2,a2,-1
800005dc:	08060063          	beqz	a2,8000065c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x1a4>
800005e0:	0044a703          	lw	a4,4(s1)
800005e4:	0004a683          	lw	a3,0(s1)
800005e8:	00d485b3          	add	a1,s1,a3
800005ec:	00070c63          	beqz	a4,80000604 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x14c>
800005f0:	fce586e3          	beq	a1,a4,800005bc <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x104>
800005f4:	00070493          	mv	s1,a4
800005f8:	fff60613          	addi	a2,a2,-1
800005fc:	fe0612e3          	bnez	a2,800005e0 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x128>
80000600:	05c0006f          	j	8000065c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x1a4>
80000604:	04a5fc63          	bgeu	a1,a0,8000065c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x1a4>
80000608:	00358613          	addi	a2,a1,3
8000060c:	ffc67613          	andi	a2,a2,-4
80000610:	00860613          	addi	a2,a2,8
80000614:	04c57463          	bgeu	a0,a2,8000065c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x1a4>
80000618:	00a68533          	add	a0,a3,a0
8000061c:	40b50533          	sub	a0,a0,a1
80000620:	00a4a023          	sw	a0,0(s1)
80000624:	0380006f          	j	8000065c <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x1a4>
80000628:	00040593          	mv	a1,s0
8000062c:	00048513          	mv	a0,s1
80000630:	01062683          	lw	a3,16(a2)
80000634:	00b50733          	add	a4,a0,a1
80000638:	02d77063          	bgeu	a4,a3,80000658 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x1a0>
8000063c:	00370793          	addi	a5,a4,3
80000640:	ffc7f793          	andi	a5,a5,-4
80000644:	00878793          	addi	a5,a5,8
80000648:	00f6f863          	bgeu	a3,a5,80000658 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064+0x1a0>
8000064c:	40e686b3          	sub	a3,a3,a4
80000650:	00b685b3          	add	a1,a3,a1
80000654:	00b52023          	sw	a1,0(a0)
80000658:	00a62423          	sw	a0,8(a2)
8000065c:	80006537          	lui	a0,0x80006
80000660:	d6052583          	lw	a1,-672(a0) # 80005d60 <_ZN7SuperOS6kalloc16KERNEL_ALLOCATOR17h0e08997bf1bee0d5E>
80000664:	408585b3          	sub	a1,a1,s0
80000668:	d6b52023          	sw	a1,-672(a0)
8000066c:	04c12083          	lw	ra,76(sp)
80000670:	04812403          	lw	s0,72(sp)
80000674:	04412483          	lw	s1,68(sp)
80000678:	05010113          	addi	sp,sp,80
8000067c:	00008067          	ret
80000680:	80004537          	lui	a0,0x80004
80000684:	30050513          	addi	a0,a0,768 # 80004300 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.43>
80000688:	02a12623          	sw	a0,44(sp)
8000068c:	00100513          	li	a0,1
80000690:	02a12823          	sw	a0,48(sp)
80000694:	02012e23          	sw	zero,60(sp)
80000698:	00400513          	li	a0,4
8000069c:	02a12a23          	sw	a0,52(sp)
800006a0:	02012c23          	sw	zero,56(sp)
800006a4:	800045b7          	lui	a1,0x80004
800006a8:	30858593          	addi	a1,a1,776 # 80004308 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.44>
800006ac:	02c10513          	addi	a0,sp,44
800006b0:	00001097          	auipc	ra,0x1
800006b4:	1d8080e7          	jalr	472(ra) # 80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>
800006b8:	00810513          	addi	a0,sp,8
800006bc:	02a12623          	sw	a0,44(sp)
800006c0:	80001537          	lui	a0,0x80001
800006c4:	1a850513          	addi	a0,a0,424 # 800011a8 <_ZN50_$LT$$BP$mut$u20$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h1b0840452bf4b3d9E>
800006c8:	02a12823          	sw	a0,48(sp)
800006cc:	00c10593          	addi	a1,sp,12
800006d0:	02b12a23          	sw	a1,52(sp)
800006d4:	02a12c23          	sw	a0,56(sp)
800006d8:	01010513          	addi	a0,sp,16
800006dc:	02a12e23          	sw	a0,60(sp)
800006e0:	80003537          	lui	a0,0x80003
800006e4:	18c50513          	addi	a0,a0,396 # 8000318c <_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17he9e9e363faaccf29E>
800006e8:	04a12023          	sw	a0,64(sp)
800006ec:	80004537          	lui	a0,0x80004
800006f0:	35c50513          	addi	a0,a0,860 # 8000435c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.50>
800006f4:	00a12a23          	sw	a0,20(sp)
800006f8:	00400513          	li	a0,4
800006fc:	00a12c23          	sw	a0,24(sp)
80000700:	02012223          	sw	zero,36(sp)
80000704:	02c10513          	addi	a0,sp,44
80000708:	00a12e23          	sw	a0,28(sp)
8000070c:	00300513          	li	a0,3
80000710:	02a12023          	sw	a0,32(sp)
80000714:	800045b7          	lui	a1,0x80004
80000718:	37c58593          	addi	a1,a1,892 # 8000437c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.51>
8000071c:	01410513          	addi	a0,sp,20
80000720:	00001097          	auipc	ra,0x1
80000724:	168080e7          	jalr	360(ra) # 80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>
80000728:	80004537          	lui	a0,0x80004
8000072c:	30050513          	addi	a0,a0,768 # 80004300 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.43>
80000730:	02a12623          	sw	a0,44(sp)
80000734:	00100513          	li	a0,1
80000738:	02a12823          	sw	a0,48(sp)
8000073c:	02012e23          	sw	zero,60(sp)
80000740:	00400513          	li	a0,4
80000744:	02a12a23          	sw	a0,52(sp)
80000748:	02012c23          	sw	zero,56(sp)
8000074c:	800045b7          	lui	a1,0x80004
80000750:	31858593          	addi	a1,a1,792 # 80004318 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.45>
80000754:	02c10513          	addi	a0,sp,44
80000758:	00001097          	auipc	ra,0x1
8000075c:	130080e7          	jalr	304(ra) # 80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>
80000760:	80004537          	lui	a0,0x80004
80000764:	29850513          	addi	a0,a0,664 # 80004298 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.40>
80000768:	800046b7          	lui	a3,0x80004
8000076c:	28868693          	addi	a3,a3,648 # 80004288 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.39>
80000770:	80004737          	lui	a4,0x80004
80000774:	2c470713          	addi	a4,a4,708 # 800042c4 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.41>
80000778:	02b00593          	li	a1,43
8000077c:	02c10613          	addi	a2,sp,44
80000780:	00001097          	auipc	ra,0x1
80000784:	2c8080e7          	jalr	712(ra) # 80001a48 <_ZN4core6result13unwrap_failed17h987d8f67a7161eb1E>

80000788 <rust_begin_unwind>:
80000788:	fd010113          	addi	sp,sp,-48
8000078c:	02112623          	sw	ra,44(sp)
80000790:	00a12223          	sw	a0,4(sp)
80000794:	00410513          	addi	a0,sp,4
80000798:	02a12023          	sw	a0,32(sp)
8000079c:	80001537          	lui	a0,0x80001
800007a0:	07050513          	addi	a0,a0,112 # 80001070 <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17h02ba342068fcc2deE>
800007a4:	02a12223          	sw	a0,36(sp)
800007a8:	80004537          	lui	a0,0x80004
800007ac:	41050513          	addi	a0,a0,1040 # 80004410 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.60>
800007b0:	00a12423          	sw	a0,8(sp)
800007b4:	00200513          	li	a0,2
800007b8:	00a12623          	sw	a0,12(sp)
800007bc:	00012c23          	sw	zero,24(sp)
800007c0:	02010513          	addi	a0,sp,32
800007c4:	00a12823          	sw	a0,16(sp)
800007c8:	00100513          	li	a0,1
800007cc:	00a12a23          	sw	a0,20(sp)
800007d0:	800045b7          	lui	a1,0x80004
800007d4:	53c58593          	addi	a1,a1,1340 # 8000453c <anon.69b25bd7f89c0392b47e51b05b6e4f5f.2.llvm.17300957278716910357>
800007d8:	02b10513          	addi	a0,sp,43
800007dc:	00810613          	addi	a2,sp,8
800007e0:	00002097          	auipc	ra,0x2
800007e4:	8e0080e7          	jalr	-1824(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
800007e8:	00051463          	bnez	a0,800007f0 <rust_begin_unwind+0x68>
800007ec:	0000006f          	j	800007ec <rust_begin_unwind+0x64>
800007f0:	80004537          	lui	a0,0x80004
800007f4:	56450513          	addi	a0,a0,1380 # 80004564 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.4.llvm.17300957278716910357>
800007f8:	800046b7          	lui	a3,0x80004
800007fc:	55468693          	addi	a3,a3,1364 # 80004554 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.3.llvm.17300957278716910357>
80000800:	80004737          	lui	a4,0x80004
80000804:	5a070713          	addi	a4,a4,1440 # 800045a0 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.6.llvm.17300957278716910357>
80000808:	02b00593          	li	a1,43
8000080c:	02b10613          	addi	a2,sp,43
80000810:	00001097          	auipc	ra,0x1
80000814:	238080e7          	jalr	568(ra) # 80001a48 <_ZN4core6result13unwrap_failed17h987d8f67a7161eb1E>

80000818 <kernel_main>:
80000818:	f1010113          	addi	sp,sp,-240
8000081c:	0e112623          	sw	ra,236(sp)
80000820:	0e812423          	sw	s0,232(sp)
80000824:	0e912223          	sw	s1,228(sp)
80000828:	0f212023          	sw	s2,224(sp)
8000082c:	0d312e23          	sw	s3,220(sp)
80000830:	0d412c23          	sw	s4,216(sp)
80000834:	0d512a23          	sw	s5,212(sp)
80000838:	0d612823          	sw	s6,208(sp)
8000083c:	0d712623          	sw	s7,204(sp)
80000840:	0d812423          	sw	s8,200(sp)
80000844:	0d912223          	sw	s9,196(sp)
80000848:	0da12023          	sw	s10,192(sp)
8000084c:	0bb12e23          	sw	s11,188(sp)
80000850:	10000537          	lui	a0,0x10000
80000854:	07300593          	li	a1,115
80000858:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
8000085c:	07400613          	li	a2,116
80000860:	00c50023          	sb	a2,0(a0)
80000864:	06100693          	li	a3,97
80000868:	00d50023          	sb	a3,0(a0)
8000086c:	07200693          	li	a3,114
80000870:	00d50023          	sb	a3,0(a0)
80000874:	00c50023          	sb	a2,0(a0)
80000878:	06500613          	li	a2,101
8000087c:	00c50023          	sb	a2,0(a0)
80000880:	06400613          	li	a2,100
80000884:	00c50023          	sb	a2,0(a0)
80000888:	02100613          	li	a2,33
8000088c:	00c50023          	sb	a2,0(a0)
80000890:	00a00613          	li	a2,10
80000894:	00c50023          	sb	a2,0(a0)
80000898:	04400693          	li	a3,68
8000089c:	00d50023          	sb	a3,0(a0)
800008a0:	04f00693          	li	a3,79
800008a4:	00d50023          	sb	a3,0(a0)
800008a8:	06f00713          	li	a4,111
800008ac:	00e50023          	sb	a4,0(a0)
800008b0:	00d50023          	sb	a3,0(a0)
800008b4:	04d00693          	li	a3,77
800008b8:	00d50023          	sb	a3,0(a0)
800008bc:	02000693          	li	a3,32
800008c0:	00d50023          	sb	a3,0(a0)
800008c4:	00e50023          	sb	a4,0(a0)
800008c8:	00b50023          	sb	a1,0(a0)
800008cc:	00c50023          	sb	a2,0(a0)
800008d0:	00001097          	auipc	ra,0x1
800008d4:	ae8080e7          	jalr	-1304(ra) # 800013b8 <_ZN7SuperOS6palloc4init17hb4eb3dcde82ecf87E>
800008d8:	80006437          	lui	s0,0x80006
800008dc:	00040413          	mv	s0,s0
800008e0:	0a812223          	sw	s0,164(sp)
800008e4:	0a410513          	addi	a0,sp,164
800008e8:	08a12623          	sw	a0,140(sp)
800008ec:	80001537          	lui	a0,0x80001
800008f0:	1a850513          	addi	a0,a0,424 # 800011a8 <_ZN50_$LT$$BP$mut$u20$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h1b0840452bf4b3d9E>
800008f4:	08a12823          	sw	a0,144(sp)
800008f8:	80004537          	lui	a0,0x80004
800008fc:	3a050513          	addi	a0,a0,928 # 800043a0 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.53>
80000900:	00a12223          	sw	a0,4(sp)
80000904:	00200513          	li	a0,2
80000908:	00a12423          	sw	a0,8(sp)
8000090c:	00012a23          	sw	zero,20(sp)
80000910:	08c10513          	addi	a0,sp,140
80000914:	00a12623          	sw	a0,12(sp)
80000918:	00100513          	li	a0,1
8000091c:	00a12823          	sw	a0,16(sp)
80000920:	800045b7          	lui	a1,0x80004
80000924:	53c58593          	addi	a1,a1,1340 # 8000453c <anon.69b25bd7f89c0392b47e51b05b6e4f5f.2.llvm.17300957278716910357>
80000928:	0b810513          	addi	a0,sp,184
8000092c:	00410613          	addi	a2,sp,4
80000930:	00001097          	auipc	ra,0x1
80000934:	790080e7          	jalr	1936(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
80000938:	1c051c63          	bnez	a0,80000b10 <kernel_main+0x2f8>
8000093c:	800066b7          	lui	a3,0x80006
80000940:	00340513          	addi	a0,s0,3 # 80006003 <KALLOC_BUFFER+0x3>
80000944:	ffc57513          	andi	a0,a0,-4
80000948:	01e00637          	lui	a2,0x1e00
8000094c:	00c405b3          	add	a1,s0,a2
80000950:	40a585b3          	sub	a1,a1,a0
80000954:	00700713          	li	a4,7
80000958:	d606a023          	sw	zero,-672(a3) # 80005d60 <_ZN7SuperOS6kalloc16KERNEL_ALLOCATOR17h0e08997bf1bee0d5E>
8000095c:	08b77063          	bgeu	a4,a1,800009dc <kernel_main+0x1c4>
80000960:	ffc5f693          	andi	a3,a1,-4
80000964:	00d52023          	sw	a3,0(a0)
80000968:	00052223          	sw	zero,4(a0)
8000096c:	00c40633          	add	a2,s0,a2
80000970:	0ac12223          	sw	a2,164(sp)
80000974:	00b505b3          	add	a1,a0,a1
80000978:	08b12623          	sw	a1,140(sp)
8000097c:	06c59e63          	bne	a1,a2,800009f8 <kernel_main+0x1e0>
80000980:	00d506b3          	add	a3,a0,a3
80000984:	00347413          	andi	s0,s0,3
80000988:	800065b7          	lui	a1,0x80006
8000098c:	d6058593          	addi	a1,a1,-672 # 80005d60 <_ZN7SuperOS6kalloc16KERNEL_ALLOCATOR17h0e08997bf1bee0d5E>
80000990:	0005a223          	sw	zero,4(a1)
80000994:	00a5a423          	sw	a0,8(a1)
80000998:	00a5a623          	sw	a0,12(a1)
8000099c:	00d5a823          	sw	a3,16(a1)
800009a0:	00858a23          	sb	s0,20(a1)
800009a4:	80000537          	lui	a0,0x80000
800009a8:	10050513          	addi	a0,a0,256 # 80000100 <user_trap>
800009ac:	30551073          	.insn	4, 0x30551073
800009b0:	30002573          	.insn	4, 0x30002573
800009b4:	00300593          	li	a1,3
800009b8:	00b59593          	slli	a1,a1,0xb
800009bc:	00b56533          	or	a0,a0,a1
800009c0:	30051073          	.insn	4, 0x30051073
800009c4:	08000513          	li	a0,128
800009c8:	30052073          	.insn	4, 0x30052073
800009cc:	80005537          	lui	a0,0x80005
800009d0:	d5c54583          	lbu	a1,-676(a0) # 80004d5c <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.3.llvm.17300957278716910357>
800009d4:	04058463          	beqz	a1,80000a1c <kernel_main+0x204>
800009d8:	0000006f          	j	800009d8 <kernel_main+0x1c0>
800009dc:	80004537          	lui	a0,0x80004
800009e0:	23050513          	addi	a0,a0,560 # 80004230 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.36>
800009e4:	80004637          	lui	a2,0x80004
800009e8:	26860613          	addi	a2,a2,616 # 80004268 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.37>
800009ec:	03800593          	li	a1,56
800009f0:	00001097          	auipc	ra,0x1
800009f4:	ec4080e7          	jalr	-316(ra) # 800018b4 <_ZN4core9panicking5panic17h651cf8329c8a8911E>
800009f8:	00012223          	sw	zero,4(sp)
800009fc:	80004737          	lui	a4,0x80004
80000a00:	27870713          	addi	a4,a4,632 # 80004278 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.38>
80000a04:	0a410593          	addi	a1,sp,164
80000a08:	08c10613          	addi	a2,sp,140
80000a0c:	00410693          	addi	a3,sp,4
80000a10:	00000513          	li	a0,0
80000a14:	00000097          	auipc	ra,0x0
80000a18:	764080e7          	jalr	1892(ra) # 80001178 <_ZN4core9panicking13assert_failed17h7470adb29fe66805E>
80000a1c:	800055b7          	lui	a1,0x80005
80000a20:	d585a603          	lw	a2,-680(a1) # 80004d58 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.2.llvm.17300957278716910357>
80000a24:	800056b7          	lui	a3,0x80005
80000a28:	d506a683          	lw	a3,-688(a3) # 80004d50 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.0.llvm.17300957278716910357>
80000a2c:	00100713          	li	a4,1
80000a30:	d4e50e23          	sb	a4,-676(a0)
80000a34:	00160613          	addi	a2,a2,1
80000a38:	d4c5ac23          	sw	a2,-680(a1)
80000a3c:	02068463          	beqz	a3,80000a64 <kernel_main+0x24c>
80000a40:	80005537          	lui	a0,0x80005
80000a44:	d5452403          	lw	s0,-684(a0) # 80004d54 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.1.llvm.17300957278716910357>
80000a48:	00c41413          	slli	s0,s0,0xc
80000a4c:	28040a63          	beqz	s0,80000ce0 <kernel_main+0x4c8>
80000a50:	00042503          	lw	a0,0(s0)
80000a54:	02050263          	beqz	a0,80000a78 <kernel_main+0x260>
80000a58:	00442503          	lw	a0,4(s0)
80000a5c:	00100593          	li	a1,1
80000a60:	01c0006f          	j	80000a7c <kernel_main+0x264>
80000a64:	d4050e23          	sb	zero,-676(a0)
80000a68:	80004537          	lui	a0,0x80004
80000a6c:	42050513          	addi	a0,a0,1056 # 80004420 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.67>
80000a70:	00001097          	auipc	ra,0x1
80000a74:	ca4080e7          	jalr	-860(ra) # 80001714 <_ZN4core6option13unwrap_failed17ha917ca27cfe8d772E>
80000a78:	00000593          	li	a1,0
80000a7c:	80005637          	lui	a2,0x80005
80000a80:	d4b62823          	sw	a1,-688(a2) # 80004d50 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.0.llvm.17300957278716910357>
80000a84:	800055b7          	lui	a1,0x80005
80000a88:	d4a5aa23          	sw	a0,-684(a1) # 80004d54 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.1.llvm.17300957278716910357>
80000a8c:	80005537          	lui	a0,0x80005
80000a90:	d4050e23          	sb	zero,-676(a0) # 80004d5c <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.3.llvm.17300957278716910357>
80000a94:	08010493          	addi	s1,sp,128
80000a98:	00410513          	addi	a0,sp,4
80000a9c:	07c00613          	li	a2,124
80000aa0:	00000593          	li	a1,0
80000aa4:	00003097          	auipc	ra,0x3
80000aa8:	93c080e7          	jalr	-1732(ra) # 800033e0 <memset>
80000aac:	80001537          	lui	a0,0x80001
80000ab0:	cf050513          	addi	a0,a0,-784 # 80000cf0 <_ZN7SuperOS9user_main17h72676f5f18d00749E>
80000ab4:	08a12023          	sw	a0,128(sp)
80000ab8:	08012223          	sw	zero,132(sp)
80000abc:	0a912223          	sw	s1,164(sp)
80000ac0:	80003537          	lui	a0,0x80003
80000ac4:	f8c50513          	addi	a0,a0,-116 # 80002f8c <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17hcc6fe785c9e9110eE>
80000ac8:	0aa12423          	sw	a0,168(sp)
80000acc:	80004537          	lui	a0,0x80004
80000ad0:	43c50513          	addi	a0,a0,1084 # 8000443c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.69>
80000ad4:	08a12623          	sw	a0,140(sp)
80000ad8:	00200513          	li	a0,2
80000adc:	08a12823          	sw	a0,144(sp)
80000ae0:	08012e23          	sw	zero,156(sp)
80000ae4:	0a410513          	addi	a0,sp,164
80000ae8:	08a12a23          	sw	a0,148(sp)
80000aec:	00100513          	li	a0,1
80000af0:	08a12c23          	sw	a0,152(sp)
80000af4:	800045b7          	lui	a1,0x80004
80000af8:	53c58593          	addi	a1,a1,1340 # 8000453c <anon.69b25bd7f89c0392b47e51b05b6e4f5f.2.llvm.17300957278716910357>
80000afc:	0b810513          	addi	a0,sp,184
80000b00:	08c10613          	addi	a2,sp,140
80000b04:	00001097          	auipc	ra,0x1
80000b08:	5bc080e7          	jalr	1468(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
80000b0c:	02050663          	beqz	a0,80000b38 <kernel_main+0x320>
80000b10:	80004537          	lui	a0,0x80004
80000b14:	56450513          	addi	a0,a0,1380 # 80004564 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.4.llvm.17300957278716910357>
80000b18:	800046b7          	lui	a3,0x80004
80000b1c:	55468693          	addi	a3,a3,1364 # 80004554 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.3.llvm.17300957278716910357>
80000b20:	80004737          	lui	a4,0x80004
80000b24:	5a070713          	addi	a4,a4,1440 # 800045a0 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.6.llvm.17300957278716910357>
80000b28:	02b00593          	li	a1,43
80000b2c:	0b810613          	addi	a2,sp,184
80000b30:	00001097          	auipc	ra,0x1
80000b34:	f18080e7          	jalr	-232(ra) # 80001a48 <_ZN4core6result13unwrap_failed17h987d8f67a7161eb1E>
80000b38:	00001537          	lui	a0,0x1
80000b3c:	ff850513          	addi	a0,a0,-8 # ff8 <.Lline_table_start1+0x30>
80000b40:	00a46533          	or	a0,s0,a0
80000b44:	00a12423          	sw	a0,8(sp)
80000b48:	10000a37          	lui	s4,0x10000
80000b4c:	04800513          	li	a0,72
80000b50:	00aa0023          	sb	a0,0(s4) # 10000000 <.Lline_table_start2+0xfffec61>
80000b54:	06500a93          	li	s5,101
80000b58:	015a0023          	sb	s5,0(s4)
80000b5c:	06c00513          	li	a0,108
80000b60:	00aa0023          	sb	a0,0(s4)
80000b64:	00aa0023          	sb	a0,0(s4)
80000b68:	06f00593          	li	a1,111
80000b6c:	00ba0023          	sb	a1,0(s4)
80000b70:	02000613          	li	a2,32
80000b74:	00ca0023          	sb	a2,0(s4)
80000b78:	07700613          	li	a2,119
80000b7c:	00ca0023          	sb	a2,0(s4)
80000b80:	00ba0023          	sb	a1,0(s4)
80000b84:	07200b93          	li	s7,114
80000b88:	017a0023          	sb	s7,0(s4)
80000b8c:	00aa0023          	sb	a0,0(s4)
80000b90:	06400513          	li	a0,100
80000b94:	00aa0023          	sb	a0,0(s4)
80000b98:	02100513          	li	a0,33
80000b9c:	00aa0023          	sb	a0,0(s4)
80000ba0:	00a00513          	li	a0,10
80000ba4:	00aa0023          	sb	a0,0(s4)
80000ba8:	00f00c93          	li	s9,15
80000bac:	0b410d93          	addi	s11,sp,180
80000bb0:	08b10d13          	addi	s10,sp,139
80000bb4:	80000b37          	lui	s6,0x80000
80000bb8:	28cb0b13          	addi	s6,s6,652 # 8000028c <_ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17h43f79eca3d356742E>
80000bbc:	80004c37          	lui	s8,0x80004
80000bc0:	158c0c13          	addi	s8,s8,344 # 80004158 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.30>
80000bc4:	00300493          	li	s1,3
80000bc8:	80004437          	lui	s0,0x80004
80000bcc:	53c40413          	addi	s0,s0,1340 # 8000453c <anon.69b25bd7f89c0392b47e51b05b6e4f5f.2.llvm.17300957278716910357>
80000bd0:	07500913          	li	s2,117
80000bd4:	07400993          	li	s3,116
80000bd8:	0740006f          	j	80000c4c <kernel_main+0x434>
80000bdc:	06d00513          	li	a0,109
80000be0:	00aa0023          	sb	a0,0(s4)
80000be4:	06300513          	li	a0,99
80000be8:	00aa0023          	sb	a0,0(s4)
80000bec:	06100513          	li	a0,97
80000bf0:	00aa0023          	sb	a0,0(s4)
80000bf4:	012a0023          	sb	s2,0(s4)
80000bf8:	07300513          	li	a0,115
80000bfc:	00aa0023          	sb	a0,0(s4)
80000c00:	015a0023          	sb	s5,0(s4)
80000c04:	03a00513          	li	a0,58
80000c08:	00aa0023          	sb	a0,0(s4)
80000c0c:	02000513          	li	a0,32
80000c10:	00aa0023          	sb	a0,0(s4)
80000c14:	06900513          	li	a0,105
80000c18:	00aa0023          	sb	a0,0(s4)
80000c1c:	06e00513          	li	a0,110
80000c20:	00aa0023          	sb	a0,0(s4)
80000c24:	013a0023          	sb	s3,0(s4)
80000c28:	015a0023          	sb	s5,0(s4)
80000c2c:	017a0023          	sb	s7,0(s4)
80000c30:	017a0023          	sb	s7,0(s4)
80000c34:	012a0023          	sb	s2,0(s4)
80000c38:	07000513          	li	a0,112
80000c3c:	00aa0023          	sb	a0,0(s4)
80000c40:	013a0023          	sb	s3,0(s4)
80000c44:	00a00513          	li	a0,10
80000c48:	00aa0023          	sb	a0,0(s4)
80000c4c:	00410513          	addi	a0,sp,4
80000c50:	fffff097          	auipc	ra,0xfffff
80000c54:	3e0080e7          	jalr	992(ra) # 80000030 <run_user>
80000c58:	34202573          	.insn	4, 0x34202573
80000c5c:	f80540e3          	bltz	a0,80000bdc <kernel_main+0x3c4>
80000c60:	00e00593          	li	a1,14
80000c64:	00acea63          	bltu	s9,a0,80000c78 <kernel_main+0x460>
80000c68:	800045b7          	lui	a1,0x80004
80000c6c:	07458593          	addi	a1,a1,116 # 80004074 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.10+0x36>
80000c70:	00a58533          	add	a0,a1,a0
80000c74:	00054583          	lbu	a1,0(a0)
80000c78:	08b105a3          	sb	a1,139(sp)
80000c7c:	34102573          	.insn	4, 0x34102573
80000c80:	0aa12a23          	sw	a0,180(sp)
80000c84:	0bb12223          	sw	s11,164(sp)
80000c88:	80003537          	lui	a0,0x80003
80000c8c:	f8c50513          	addi	a0,a0,-116 # 80002f8c <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17hcc6fe785c9e9110eE>
80000c90:	0aa12423          	sw	a0,168(sp)
80000c94:	0ba12623          	sw	s10,172(sp)
80000c98:	0b612823          	sw	s6,176(sp)
80000c9c:	09812623          	sw	s8,140(sp)
80000ca0:	08912823          	sw	s1,144(sp)
80000ca4:	08012e23          	sw	zero,156(sp)
80000ca8:	0a410513          	addi	a0,sp,164
80000cac:	08a12a23          	sw	a0,148(sp)
80000cb0:	00200513          	li	a0,2
80000cb4:	08a12c23          	sw	a0,152(sp)
80000cb8:	0b810513          	addi	a0,sp,184
80000cbc:	08c10613          	addi	a2,sp,140
80000cc0:	00040593          	mv	a1,s0
80000cc4:	00001097          	auipc	ra,0x1
80000cc8:	3fc080e7          	jalr	1020(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
80000ccc:	e40512e3          	bnez	a0,80000b10 <kernel_main+0x2f8>
80000cd0:	08012503          	lw	a0,128(sp)
80000cd4:	00450513          	addi	a0,a0,4
80000cd8:	08a12023          	sw	a0,128(sp)
80000cdc:	f71ff06f          	j	80000c4c <kernel_main+0x434>
80000ce0:	80004537          	lui	a0,0x80004
80000ce4:	5f050513          	addi	a0,a0,1520 # 800045f0 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.12.llvm.17300957278716910357>
80000ce8:	00001097          	auipc	ra,0x1
80000cec:	a2c080e7          	jalr	-1492(ra) # 80001714 <_ZN4core6option13unwrap_failed17ha917ca27cfe8d772E>

80000cf0 <_ZN7SuperOS9user_main17h72676f5f18d00749E>:
80000cf0:	f8010113          	addi	sp,sp,-128
80000cf4:	06112e23          	sw	ra,124(sp)
80000cf8:	06812c23          	sw	s0,120(sp)
80000cfc:	06912a23          	sw	s1,116(sp)
80000d00:	07212823          	sw	s2,112(sp)
80000d04:	07312623          	sw	s3,108(sp)
80000d08:	07412423          	sw	s4,104(sp)
80000d0c:	07512223          	sw	s5,100(sp)
80000d10:	07612023          	sw	s6,96(sp)
80000d14:	05712e23          	sw	s7,92(sp)
80000d18:	05812c23          	sw	s8,88(sp)
80000d1c:	05912a23          	sw	s9,84(sp)
80000d20:	05a12823          	sw	s10,80(sp)
80000d24:	05b12623          	sw	s11,76(sp)
80000d28:	10000937          	lui	s2,0x10000
80000d2c:	80004437          	lui	s0,0x80004
80000d30:	3e840413          	addi	s0,s0,1000 # 800043e8 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.58>
80000d34:	3e800c13          	li	s8,1000
80000d38:	c28f6537          	lui	a0,0xc28f6
80000d3c:	c2950d13          	addi	s10,a0,-983 # c28f5c29 <KALLOC_BUFFER+0x428efc29>
80000d40:	028f6537          	lui	a0,0x28f6
80000d44:	c2850993          	addi	s3,a0,-984 # 28f5c28 <.Lline_table_start2+0x28f4889>
80000d48:	80003bb7          	lui	s7,0x80003
80000d4c:	18cb8b93          	addi	s7,s7,396 # 8000318c <_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17he9e9e363faaccf29E>
80000d50:	00200a93          	li	s5,2
80000d54:	04010c93          	addi	s9,sp,64
80000d58:	00100d93          	li	s11,1
80000d5c:	800044b7          	lui	s1,0x80004
80000d60:	53c48493          	addi	s1,s1,1340 # 8000453c <anon.69b25bd7f89c0392b47e51b05b6e4f5f.2.llvm.17300957278716910357>
80000d64:	04800513          	li	a0,72
80000d68:	00a90023          	sb	a0,0(s2) # 10000000 <.Lline_table_start2+0xfffec61>
80000d6c:	06500513          	li	a0,101
80000d70:	00a90023          	sb	a0,0(s2)
80000d74:	06c00593          	li	a1,108
80000d78:	00b90023          	sb	a1,0(s2)
80000d7c:	00b90023          	sb	a1,0(s2)
80000d80:	06f00593          	li	a1,111
80000d84:	00b90023          	sb	a1,0(s2)
80000d88:	02000593          	li	a1,32
80000d8c:	00b90023          	sb	a1,0(s2)
80000d90:	07500593          	li	a1,117
80000d94:	00b90023          	sb	a1,0(s2)
80000d98:	07300593          	li	a1,115
80000d9c:	00b90023          	sb	a1,0(s2)
80000da0:	00a90023          	sb	a0,0(s2)
80000da4:	07200513          	li	a0,114
80000da8:	00a90023          	sb	a0,0(s2)
80000dac:	00b90023          	sb	a1,0(s2)
80000db0:	02100513          	li	a0,33
80000db4:	00a90023          	sb	a0,0(s2)
80000db8:	00a90023          	sb	a0,0(s2)
80000dbc:	00a90023          	sb	a0,0(s2)
80000dc0:	00a00513          	li	a0,10
80000dc4:	00a90023          	sb	a0,0(s2)
80000dc8:	b0002573          	.insn	4, 0xb0002573
80000dcc:	40a00533          	neg	a0,a0
80000dd0:	00a12623          	sw	a0,12(sp)
80000dd4:	b0202573          	.insn	4, 0xb0202573
80000dd8:	00000b13          	li	s6,0
80000ddc:	00000a13          	li	s4,0
80000de0:	40a00533          	neg	a0,a0
80000de4:	00a12823          	sw	a0,16(sp)
80000de8:	00012a23          	sw	zero,20(sp)
80000dec:	00400513          	li	a0,4
80000df0:	00a12c23          	sw	a0,24(sp)
80000df4:	00012e23          	sw	zero,28(sp)
80000df8:	0240006f          	j	80000e1c <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x12c>
80000dfc:	01812503          	lw	a0,24(sp)
80000e00:	001a0593          	addi	a1,s4,1
80000e04:	01650533          	add	a0,a0,s6
80000e08:	01452023          	sw	s4,0(a0)
80000e0c:	00b12e23          	sw	a1,28(sp)
80000e10:	004b0b13          	addi	s6,s6,4
80000e14:	00058a13          	mv	s4,a1
80000e18:	03858063          	beq	a1,s8,80000e38 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x148>
80000e1c:	01412503          	lw	a0,20(sp)
80000e20:	fcaa1ee3          	bne	s4,a0,80000dfc <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x10c>
80000e24:	01410513          	addi	a0,sp,20
80000e28:	00040593          	mv	a1,s0
80000e2c:	00000097          	auipc	ra,0x0
80000e30:	48c080e7          	jalr	1164(ra) # 800012b8 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE>
80000e34:	fc9ff06f          	j	80000dfc <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x10c>
80000e38:	00000513          	li	a0,0
80000e3c:	00000b13          	li	s6,0
80000e40:	02012223          	sw	zero,36(sp)
80000e44:	3e800593          	li	a1,1000
80000e48:	02410a13          	addi	s4,sp,36
80000e4c:	00c0006f          	j	80000e58 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x168>
80000e50:	001b0b13          	addi	s6,s6,1
80000e54:	098b0a63          	beq	s6,s8,80000ee8 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x1f8>
80000e58:	03a50633          	mul	a2,a0,s10
80000e5c:	01e61693          	slli	a3,a2,0x1e
80000e60:	00265613          	srli	a2,a2,0x2
80000e64:	00d66633          	or	a2,a2,a3
80000e68:	00c9f663          	bgeu	s3,a2,80000e74 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x184>
80000e6c:	04059863          	bnez	a1,80000ebc <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x1cc>
80000e70:	fe1ff06f          	j	80000e50 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x160>
80000e74:	05412023          	sw	s4,64(sp)
80000e78:	05712223          	sw	s7,68(sp)
80000e7c:	80004537          	lui	a0,0x80004
80000e80:	3cc50513          	addi	a0,a0,972 # 800043cc <.Lanon.10e9e605f29f28b577aacdba1819c9a4.56>
80000e84:	02a12423          	sw	a0,40(sp)
80000e88:	03512623          	sw	s5,44(sp)
80000e8c:	02012c23          	sw	zero,56(sp)
80000e90:	03912823          	sw	s9,48(sp)
80000e94:	03b12a23          	sw	s11,52(sp)
80000e98:	04b10513          	addi	a0,sp,75
80000e9c:	02810613          	addi	a2,sp,40
80000ea0:	00048593          	mv	a1,s1
80000ea4:	00001097          	auipc	ra,0x1
80000ea8:	21c080e7          	jalr	540(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
80000eac:	10051a63          	bnez	a0,80000fc0 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x2d0>
80000eb0:	01c12583          	lw	a1,28(sp)
80000eb4:	02412503          	lw	a0,36(sp)
80000eb8:	f8058ce3          	beqz	a1,80000e50 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x160>
80000ebc:	01812603          	lw	a2,24(sp)
80000ec0:	00259693          	slli	a3,a1,0x2
80000ec4:	0100006f          	j	80000ed4 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x1e4>
80000ec8:	ffc68693          	addi	a3,a3,-4
80000ecc:	00460613          	addi	a2,a2,4
80000ed0:	f80680e3          	beqz	a3,80000e50 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x160>
80000ed4:	00062703          	lw	a4,0(a2)
80000ed8:	ff6718e3          	bne	a4,s6,80000ec8 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x1d8>
80000edc:	00150513          	addi	a0,a0,1
80000ee0:	02a12223          	sw	a0,36(sp)
80000ee4:	fe5ff06f          	j	80000ec8 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x1d8>
80000ee8:	05412023          	sw	s4,64(sp)
80000eec:	05712223          	sw	s7,68(sp)
80000ef0:	80004537          	lui	a0,0x80004
80000ef4:	3cc50513          	addi	a0,a0,972 # 800043cc <.Lanon.10e9e605f29f28b577aacdba1819c9a4.56>
80000ef8:	02a12423          	sw	a0,40(sp)
80000efc:	03512623          	sw	s5,44(sp)
80000f00:	02012c23          	sw	zero,56(sp)
80000f04:	03912823          	sw	s9,48(sp)
80000f08:	03b12a23          	sw	s11,52(sp)
80000f0c:	04b10513          	addi	a0,sp,75
80000f10:	02810613          	addi	a2,sp,40
80000f14:	00048593          	mv	a1,s1
80000f18:	00001097          	auipc	ra,0x1
80000f1c:	1a8080e7          	jalr	424(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
80000f20:	0a051063          	bnez	a0,80000fc0 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x2d0>
80000f24:	01412603          	lw	a2,20(sp)
80000f28:	00060c63          	beqz	a2,80000f40 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x250>
80000f2c:	01812503          	lw	a0,24(sp)
80000f30:	00261613          	slli	a2,a2,0x2
80000f34:	00400593          	li	a1,4
80000f38:	fffff097          	auipc	ra,0xfffff
80000f3c:	580080e7          	jalr	1408(ra) # 800004b8 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064>
80000f40:	b0002573          	.insn	4, 0xb0002573
80000f44:	00c12583          	lw	a1,12(sp)
80000f48:	00a58533          	add	a0,a1,a0
80000f4c:	00a12623          	sw	a0,12(sp)
80000f50:	b0202573          	.insn	4, 0xb0202573
80000f54:	01012583          	lw	a1,16(sp)
80000f58:	00a58533          	add	a0,a1,a0
80000f5c:	00a12823          	sw	a0,16(sp)
80000f60:	00c10513          	addi	a0,sp,12
80000f64:	00a12a23          	sw	a0,20(sp)
80000f68:	01712c23          	sw	s7,24(sp)
80000f6c:	01010513          	addi	a0,sp,16
80000f70:	00a12e23          	sw	a0,28(sp)
80000f74:	03712023          	sw	s7,32(sp)
80000f78:	80004537          	lui	a0,0x80004
80000f7c:	45c50513          	addi	a0,a0,1116 # 8000445c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.76>
80000f80:	02a12423          	sw	a0,40(sp)
80000f84:	00300513          	li	a0,3
80000f88:	02a12623          	sw	a0,44(sp)
80000f8c:	02012c23          	sw	zero,56(sp)
80000f90:	01410513          	addi	a0,sp,20
80000f94:	02a12823          	sw	a0,48(sp)
80000f98:	03512a23          	sw	s5,52(sp)
80000f9c:	04b10513          	addi	a0,sp,75
80000fa0:	02810613          	addi	a2,sp,40
80000fa4:	00048593          	mv	a1,s1
80000fa8:	00001097          	auipc	ra,0x1
80000fac:	118080e7          	jalr	280(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
80000fb0:	00051863          	bnez	a0,80000fc0 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x2d0>
80000fb4:	00000073          	ecall
80000fb8:	0015200f          	cbo.clean	(a0)
80000fbc:	da9ff06f          	j	80000d64 <_ZN7SuperOS9user_main17h72676f5f18d00749E+0x74>
80000fc0:	80004537          	lui	a0,0x80004
80000fc4:	56450513          	addi	a0,a0,1380 # 80004564 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.4.llvm.17300957278716910357>
80000fc8:	800046b7          	lui	a3,0x80004
80000fcc:	55468693          	addi	a3,a3,1364 # 80004554 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.3.llvm.17300957278716910357>
80000fd0:	80004737          	lui	a4,0x80004
80000fd4:	5a070713          	addi	a4,a4,1440 # 800045a0 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.6.llvm.17300957278716910357>
80000fd8:	02b00593          	li	a1,43
80000fdc:	04b10613          	addi	a2,sp,75
80000fe0:	00001097          	auipc	ra,0x1
80000fe4:	a68080e7          	jalr	-1432(ra) # 80001a48 <_ZN4core6result13unwrap_failed17h987d8f67a7161eb1E>

80000fe8 <_ZN7SuperOS6kalloc18handle_alloc_error17hc1197898e00c3e6fE>:
80000fe8:	fd010113          	addi	sp,sp,-48
80000fec:	00a12423          	sw	a0,8(sp)
80000ff0:	00b12623          	sw	a1,12(sp)
80000ff4:	00810513          	addi	a0,sp,8
80000ff8:	02a12423          	sw	a0,40(sp)
80000ffc:	80000537          	lui	a0,0x80000
80001000:	20050513          	addi	a0,a0,512 # 80000200 <_ZN64_$LT$core..alloc..layout..Layout$u20$as$u20$core..fmt..Debug$GT$3fmt17h3f589c9bfce4375fE>
80001004:	02a12623          	sw	a0,44(sp)
80001008:	80004537          	lui	a0,0x80004
8000100c:	48450513          	addi	a0,a0,1156 # 80004484 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.78>
80001010:	00a12823          	sw	a0,16(sp)
80001014:	00100513          	li	a0,1
80001018:	00a12a23          	sw	a0,20(sp)
8000101c:	02012023          	sw	zero,32(sp)
80001020:	02810593          	addi	a1,sp,40
80001024:	00b12c23          	sw	a1,24(sp)
80001028:	00a12e23          	sw	a0,28(sp)
8000102c:	800045b7          	lui	a1,0x80004
80001030:	49c58593          	addi	a1,a1,1180 # 8000449c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.80>
80001034:	01010513          	addi	a0,sp,16
80001038:	00001097          	auipc	ra,0x1
8000103c:	850080e7          	jalr	-1968(ra) # 80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>

80001040 <__rg_oom>:
80001040:	00050613          	mv	a2,a0
80001044:	00058513          	mv	a0,a1
80001048:	00060593          	mv	a1,a2
8000104c:	00000097          	auipc	ra,0x0
80001050:	f9c080e7          	jalr	-100(ra) # 80000fe8 <_ZN7SuperOS6kalloc18handle_alloc_error17hc1197898e00c3e6fE>

80001054 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h238390e4fa15678bE>:
80001054:	00052503          	lw	a0,0(a0)
80001058:	00000317          	auipc	t1,0x0
8000105c:	60430067          	jr	1540(t1) # 8000165c <_ZN68_$LT$core..ptr..alignment..Alignment$u20$as$u20$core..fmt..Debug$GT$3fmt17h68454b409a0fd924E>

80001060 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17hbdca1cfb775e2eebE>:
80001060:	00052503          	lw	a0,0(a0)
80001064:	00052503          	lw	a0,0(a0)
80001068:	00002317          	auipc	t1,0x2
8000106c:	ac430067          	jr	-1340(t1) # 80002b2c <_ZN4core3fmt17pointer_fmt_inner17h3a78f71d335c4ae6E>

80001070 <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17h02ba342068fcc2deE>:
80001070:	00052503          	lw	a0,0(a0)
80001074:	00000317          	auipc	t1,0x0
80001078:	6c830067          	jr	1736(t1) # 8000173c <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h69b70629720e2a98E>

8000107c <_ZN4core3fmt5Write10write_char17h61427ba210d54f53E.llvm.17300957278716910357>:
8000107c:	ff010113          	addi	sp,sp,-16
80001080:	08000513          	li	a0,128
80001084:	00012623          	sw	zero,12(sp)
80001088:	00a5f863          	bgeu	a1,a0,80001098 <_ZN4core3fmt5Write10write_char17h61427ba210d54f53E.llvm.17300957278716910357+0x1c>
8000108c:	00d10513          	addi	a0,sp,13
80001090:	00b10623          	sb	a1,12(sp)
80001094:	0a00006f          	j	80001134 <_ZN4core3fmt5Write10write_char17h61427ba210d54f53E.llvm.17300957278716910357+0xb8>
80001098:	00b5d513          	srli	a0,a1,0xb
8000109c:	02051263          	bnez	a0,800010c0 <_ZN4core3fmt5Write10write_char17h61427ba210d54f53E.llvm.17300957278716910357+0x44>
800010a0:	00e10513          	addi	a0,sp,14
800010a4:	0065d613          	srli	a2,a1,0x6
800010a8:	0c066613          	ori	a2,a2,192
800010ac:	00c10623          	sb	a2,12(sp)
800010b0:	03f5f593          	andi	a1,a1,63
800010b4:	08058593          	addi	a1,a1,128
800010b8:	00b106a3          	sb	a1,13(sp)
800010bc:	0780006f          	j	80001134 <_ZN4core3fmt5Write10write_char17h61427ba210d54f53E.llvm.17300957278716910357+0xb8>
800010c0:	0105d513          	srli	a0,a1,0x10
800010c4:	02051a63          	bnez	a0,800010f8 <_ZN4core3fmt5Write10write_char17h61427ba210d54f53E.llvm.17300957278716910357+0x7c>
800010c8:	00f10513          	addi	a0,sp,15
800010cc:	00c5d613          	srli	a2,a1,0xc
800010d0:	0e066613          	ori	a2,a2,224
800010d4:	00c10623          	sb	a2,12(sp)
800010d8:	01459613          	slli	a2,a1,0x14
800010dc:	01a65613          	srli	a2,a2,0x1a
800010e0:	08060613          	addi	a2,a2,128
800010e4:	00c106a3          	sb	a2,13(sp)
800010e8:	03f5f593          	andi	a1,a1,63
800010ec:	08058593          	addi	a1,a1,128
800010f0:	00b10723          	sb	a1,14(sp)
800010f4:	0400006f          	j	80001134 <_ZN4core3fmt5Write10write_char17h61427ba210d54f53E.llvm.17300957278716910357+0xb8>
800010f8:	01010513          	addi	a0,sp,16
800010fc:	0125d613          	srli	a2,a1,0x12
80001100:	0f066613          	ori	a2,a2,240
80001104:	00c10623          	sb	a2,12(sp)
80001108:	00e59613          	slli	a2,a1,0xe
8000110c:	01a65613          	srli	a2,a2,0x1a
80001110:	08060613          	addi	a2,a2,128
80001114:	00c106a3          	sb	a2,13(sp)
80001118:	01459613          	slli	a2,a1,0x14
8000111c:	01a65613          	srli	a2,a2,0x1a
80001120:	08060613          	addi	a2,a2,128
80001124:	00c10723          	sb	a2,14(sp)
80001128:	03f5f593          	andi	a1,a1,63
8000112c:	08058593          	addi	a1,a1,128
80001130:	00b107a3          	sb	a1,15(sp)
80001134:	00c10613          	addi	a2,sp,12
80001138:	100005b7          	lui	a1,0x10000
8000113c:	00064683          	lbu	a3,0(a2)
80001140:	00160713          	addi	a4,a2,1
80001144:	00d58023          	sb	a3,0(a1) # 10000000 <.Lline_table_start2+0xfffec61>
80001148:	00070613          	mv	a2,a4
8000114c:	fea718e3          	bne	a4,a0,8000113c <_ZN4core3fmt5Write10write_char17h61427ba210d54f53E.llvm.17300957278716910357+0xc0>
80001150:	00000513          	li	a0,0
80001154:	01010113          	addi	sp,sp,16
80001158:	00008067          	ret

8000115c <_ZN4core3fmt5Write9write_fmt17he488f3dd19d82de4E.llvm.17300957278716910357>:
8000115c:	80004637          	lui	a2,0x80004
80001160:	53c60613          	addi	a2,a2,1340 # 8000453c <anon.69b25bd7f89c0392b47e51b05b6e4f5f.2.llvm.17300957278716910357>
80001164:	00058693          	mv	a3,a1
80001168:	00060593          	mv	a1,a2
8000116c:	00068613          	mv	a2,a3
80001170:	00001317          	auipc	t1,0x1
80001174:	f5030067          	jr	-176(t1) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>

80001178 <_ZN4core9panicking13assert_failed17h7470adb29fe66805E>:
80001178:	ff010113          	addi	sp,sp,-16
8000117c:	00070813          	mv	a6,a4
80001180:	00068793          	mv	a5,a3
80001184:	00b12423          	sw	a1,8(sp)
80001188:	00c12623          	sw	a2,12(sp)
8000118c:	80004637          	lui	a2,0x80004
80001190:	52460613          	addi	a2,a2,1316 # 80004524 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.0>
80001194:	00810593          	addi	a1,sp,8
80001198:	00c10693          	addi	a3,sp,12
8000119c:	00060713          	mv	a4,a2
800011a0:	00000097          	auipc	ra,0x0
800011a4:	75c080e7          	jalr	1884(ra) # 800018fc <_ZN4core9panicking19assert_failed_inner17h6dd275b923677f96E>

800011a8 <_ZN50_$LT$$BP$mut$u20$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h1b0840452bf4b3d9E>:
800011a8:	00052503          	lw	a0,0(a0)
800011ac:	00002317          	auipc	t1,0x2
800011b0:	98030067          	jr	-1664(t1) # 80002b2c <_ZN4core3fmt17pointer_fmt_inner17h3a78f71d335c4ae6E>

800011b4 <_ZN53_$LT$core..fmt..Error$u20$as$u20$core..fmt..Debug$GT$3fmt17he79e882de461163bE.llvm.17300957278716910357>:
800011b4:	800046b7          	lui	a3,0x80004
800011b8:	53468693          	addi	a3,a3,1332 # 80004534 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.1>
800011bc:	00500613          	li	a2,5
800011c0:	00058513          	mv	a0,a1
800011c4:	00068593          	mv	a1,a3
800011c8:	00001317          	auipc	t1,0x1
800011cc:	7f430067          	jr	2036(t1) # 800029bc <_ZN4core3fmt9Formatter9write_str17hd607abcbb12fb4c8E>

800011d0 <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E>:
800011d0:	fe010113          	addi	sp,sp,-32
800011d4:	00112e23          	sw	ra,28(sp)
800011d8:	00812c23          	sw	s0,24(sp)
800011dc:	00912a23          	sw	s1,20(sp)
800011e0:	01212823          	sw	s2,16(sp)
800011e4:	01312623          	sw	s3,12(sp)
800011e8:	01412423          	sw	s4,8(sp)
800011ec:	00462683          	lw	a3,4(a2)
800011f0:	00058493          	mv	s1,a1
800011f4:	00050413          	mv	s0,a0
800011f8:	04068e63          	beqz	a3,80001254 <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E+0x84>
800011fc:	00862903          	lw	s2,8(a2)
80001200:	04090a63          	beqz	s2,80001254 <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E+0x84>
80001204:	00062983          	lw	s3,0(a2)
80001208:	00400513          	li	a0,4
8000120c:	00048593          	mv	a1,s1
80001210:	fffff097          	auipc	ra,0xfffff
80001214:	0b4080e7          	jalr	180(ra) # 800002c4 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064>
80001218:	04050c63          	beqz	a0,80001270 <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E+0xa0>
8000121c:	00050a13          	mv	s4,a0
80001220:	00098593          	mv	a1,s3
80001224:	00090613          	mv	a2,s2
80001228:	00002097          	auipc	ra,0x2
8000122c:	260080e7          	jalr	608(ra) # 80003488 <memcpy>
80001230:	00400593          	li	a1,4
80001234:	00098513          	mv	a0,s3
80001238:	00090613          	mv	a2,s2
8000123c:	fffff097          	auipc	ra,0xfffff
80001240:	27c080e7          	jalr	636(ra) # 800004b8 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$7dealloc17h5936be95759e6178E.llvm.8653399049932230064>
80001244:	000a0513          	mv	a0,s4
80001248:	001a3593          	seqz	a1,s4
8000124c:	020a0663          	beqz	s4,80001278 <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E+0xa8>
80001250:	02c0006f          	j	8000127c <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E+0xac>
80001254:	04048a63          	beqz	s1,800012a8 <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E+0xd8>
80001258:	80005537          	lui	a0,0x80005
8000125c:	d5e54003          	lbu	zero,-674(a0) # 80004d5e <__rust_no_alloc_shim_is_unstable>
80001260:	00400513          	li	a0,4
80001264:	00048593          	mv	a1,s1
80001268:	fffff097          	auipc	ra,0xfffff
8000126c:	05c080e7          	jalr	92(ra) # 800002c4 <_ZN95_$LT$SuperOS..linked_list_allocator..LockedHeap$u20$as$u20$core..alloc..global..GlobalAlloc$GT$5alloc17hfa56188228b57e71E.llvm.8653399049932230064>
80001270:	00153593          	seqz	a1,a0
80001274:	00051463          	bnez	a0,8000127c <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E+0xac>
80001278:	00400513          	li	a0,4
8000127c:	00a42223          	sw	a0,4(s0)
80001280:	00942423          	sw	s1,8(s0)
80001284:	00b42023          	sw	a1,0(s0)
80001288:	01c12083          	lw	ra,28(sp)
8000128c:	01812403          	lw	s0,24(sp)
80001290:	01412483          	lw	s1,20(sp)
80001294:	01012903          	lw	s2,16(sp)
80001298:	00c12983          	lw	s3,12(sp)
8000129c:	00812a03          	lw	s4,8(sp)
800012a0:	02010113          	addi	sp,sp,32
800012a4:	00008067          	ret
800012a8:	00400513          	li	a0,4
800012ac:	00153593          	seqz	a1,a0
800012b0:	fc0504e3          	beqz	a0,80001278 <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E+0xa8>
800012b4:	fc9ff06f          	j	8000127c <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E+0xac>

800012b8 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE>:
800012b8:	fd010113          	addi	sp,sp,-48
800012bc:	02112623          	sw	ra,44(sp)
800012c0:	02812423          	sw	s0,40(sp)
800012c4:	02912223          	sw	s1,36(sp)
800012c8:	03212023          	sw	s2,32(sp)
800012cc:	00050493          	mv	s1,a0
800012d0:	00052683          	lw	a3,0(a0)
800012d4:	00168513          	addi	a0,a3,1
800012d8:	00058413          	mv	s0,a1
800012dc:	0a050463          	beqz	a0,80001384 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE+0xcc>
800012e0:	00d05463          	blez	a3,800012e8 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE+0x30>
800012e4:	00169513          	slli	a0,a3,0x1
800012e8:	00400593          	li	a1,4
800012ec:	00050913          	mv	s2,a0
800012f0:	00a5e463          	bltu	a1,a0,800012f8 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE+0x40>
800012f4:	00400913          	li	s2,4
800012f8:	01e55513          	srli	a0,a0,0x1e
800012fc:	08051263          	bnez	a0,80001380 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE+0xc8>
80001300:	00291593          	slli	a1,s2,0x2
80001304:	80000537          	lui	a0,0x80000
80001308:	ffc50713          	addi	a4,a0,-4 # 7ffffffc <.Lline_table_start2+0x7fffec5d>
8000130c:	00000513          	li	a0,0
80001310:	06b76a63          	bltu	a4,a1,80001384 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE+0xcc>
80001314:	00068e63          	beqz	a3,80001330 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE+0x78>
80001318:	0044a503          	lw	a0,4(s1)
8000131c:	00269693          	slli	a3,a3,0x2
80001320:	00a12a23          	sw	a0,20(sp)
80001324:	00d12e23          	sw	a3,28(sp)
80001328:	00400513          	li	a0,4
8000132c:	0080006f          	j	80001334 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE+0x7c>
80001330:	00000513          	li	a0,0
80001334:	00a12c23          	sw	a0,24(sp)
80001338:	00810513          	addi	a0,sp,8
8000133c:	01410613          	addi	a2,sp,20
80001340:	00000097          	auipc	ra,0x0
80001344:	e90080e7          	jalr	-368(ra) # 800011d0 <_ZN5alloc7raw_vec11finish_grow17h9dfb50124e7a0c08E>
80001348:	00812503          	lw	a0,8(sp)
8000134c:	02051463          	bnez	a0,80001374 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE+0xbc>
80001350:	00c12503          	lw	a0,12(sp)
80001354:	00a4a223          	sw	a0,4(s1)
80001358:	0124a023          	sw	s2,0(s1)
8000135c:	02c12083          	lw	ra,44(sp)
80001360:	02812403          	lw	s0,40(sp)
80001364:	02412483          	lw	s1,36(sp)
80001368:	02012903          	lw	s2,32(sp)
8000136c:	03010113          	addi	sp,sp,48
80001370:	00008067          	ret
80001374:	00c12503          	lw	a0,12(sp)
80001378:	01012603          	lw	a2,16(sp)
8000137c:	0080006f          	j	80001384 <_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$8grow_one17hf4a164b8a1f33cdeE+0xcc>
80001380:	00000513          	li	a0,0
80001384:	00060593          	mv	a1,a2
80001388:	00040613          	mv	a2,s0
8000138c:	00000097          	auipc	ra,0x0
80001390:	284080e7          	jalr	644(ra) # 80001610 <_ZN5alloc7raw_vec12handle_error17ha58a8384aa435a2cE>

80001394 <_ZN61_$LT$SuperOS..printer..Writer$u20$as$u20$core..fmt..Write$GT$9write_str17h8b24a3efbe14ea2aE.llvm.17300957278716910357>:
80001394:	00060e63          	beqz	a2,800013b0 <_ZN61_$LT$SuperOS..printer..Writer$u20$as$u20$core..fmt..Write$GT$9write_str17h8b24a3efbe14ea2aE.llvm.17300957278716910357+0x1c>
80001398:	10000537          	lui	a0,0x10000
8000139c:	0005c683          	lbu	a3,0(a1)
800013a0:	00158593          	addi	a1,a1,1
800013a4:	fff60613          	addi	a2,a2,-1
800013a8:	00d50023          	sb	a3,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
800013ac:	fe0618e3          	bnez	a2,8000139c <_ZN61_$LT$SuperOS..printer..Writer$u20$as$u20$core..fmt..Write$GT$9write_str17h8b24a3efbe14ea2aE.llvm.17300957278716910357+0x8>
800013b0:	00000513          	li	a0,0
800013b4:	00008067          	ret

800013b8 <_ZN7SuperOS6palloc4init17hb4eb3dcde82ecf87E>:
800013b8:	f7010113          	addi	sp,sp,-144
800013bc:	08112623          	sw	ra,140(sp)
800013c0:	08812423          	sw	s0,136(sp)
800013c4:	08912223          	sw	s1,132(sp)
800013c8:	09212023          	sw	s2,128(sp)
800013cc:	07312e23          	sw	s3,124(sp)
800013d0:	80006937          	lui	s2,0x80006
800013d4:	00090913          	mv	s2,s2
800013d8:	03212023          	sw	s2,32(sp)
800013dc:	02010513          	addi	a0,sp,32
800013e0:	00a12423          	sw	a0,8(sp)
800013e4:	800039b7          	lui	s3,0x80003
800013e8:	f8c98993          	addi	s3,s3,-116 # 80002f8c <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17hcc6fe785c9e9110eE>
800013ec:	01312623          	sw	s3,12(sp)
800013f0:	80004537          	lui	a0,0x80004
800013f4:	61050513          	addi	a0,a0,1552 # 80004610 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.14>
800013f8:	02a12c23          	sw	a0,56(sp)
800013fc:	00200513          	li	a0,2
80001400:	02a12e23          	sw	a0,60(sp)
80001404:	04012423          	sw	zero,72(sp)
80001408:	00810513          	addi	a0,sp,8
8000140c:	04a12023          	sw	a0,64(sp)
80001410:	00100513          	li	a0,1
80001414:	04a12223          	sw	a0,68(sp)
80001418:	800045b7          	lui	a1,0x80004
8000141c:	53c58593          	addi	a1,a1,1340 # 8000453c <anon.69b25bd7f89c0392b47e51b05b6e4f5f.2.llvm.17300957278716910357>
80001420:	07b10513          	addi	a0,sp,123
80001424:	03810613          	addi	a2,sp,56
80001428:	00001097          	auipc	ra,0x1
8000142c:	c98080e7          	jalr	-872(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
80001430:	16051663          	bnez	a0,8000159c <_ZN7SuperOS6palloc4init17hb4eb3dcde82ecf87E+0x1e4>
80001434:	80005537          	lui	a0,0x80005
80001438:	d5c54583          	lbu	a1,-676(a0) # 80004d5c <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.3.llvm.17300957278716910357>
8000143c:	00058463          	beqz	a1,80001444 <_ZN7SuperOS6palloc4init17hb4eb3dcde82ecf87E+0x8c>
80001440:	0000006f          	j	80001440 <_ZN7SuperOS6palloc4init17hb4eb3dcde82ecf87E+0x88>
80001444:	00100593          	li	a1,1
80001448:	d4b50e23          	sb	a1,-676(a0)
8000144c:	01e00537          	lui	a0,0x1e00
80001450:	00a90933          	add	s2,s2,a0
80001454:	00c95493          	srli	s1,s2,0xc
80001458:	00148413          	addi	s0,s1,1
8000145c:	02812823          	sw	s0,48(sp)
80001460:	00082537          	lui	a0,0x82
80001464:	fff50513          	addi	a0,a0,-1 # 81fff <.Lline_table_start2+0x80c60>
80001468:	02a12a23          	sw	a0,52(sp)
8000146c:	03010513          	addi	a0,sp,48
80001470:	02a12023          	sw	a0,32(sp)
80001474:	03312223          	sw	s3,36(sp)
80001478:	03410513          	addi	a0,sp,52
8000147c:	02a12423          	sw	a0,40(sp)
80001480:	03312623          	sw	s3,44(sp)
80001484:	00200513          	li	a0,2
80001488:	02a12c23          	sw	a0,56(sp)
8000148c:	04a12023          	sw	a0,64(sp)
80001490:	02000613          	li	a2,32
80001494:	04c12423          	sw	a2,72(sp)
80001498:	04012623          	sw	zero,76(sp)
8000149c:	00400693          	li	a3,4
800014a0:	04d12823          	sw	a3,80(sp)
800014a4:	00300713          	li	a4,3
800014a8:	04e10a23          	sb	a4,84(sp)
800014ac:	04a12c23          	sw	a0,88(sp)
800014b0:	06a12023          	sw	a0,96(sp)
800014b4:	06c12423          	sw	a2,104(sp)
800014b8:	06b12623          	sw	a1,108(sp)
800014bc:	06d12823          	sw	a3,112(sp)
800014c0:	06e10a23          	sb	a4,116(sp)
800014c4:	800045b7          	lui	a1,0x80004
800014c8:	5c858593          	addi	a1,a1,1480 # 800045c8 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.10>
800014cc:	00b12423          	sw	a1,8(sp)
800014d0:	00e12623          	sw	a4,12(sp)
800014d4:	03810593          	addi	a1,sp,56
800014d8:	00b12c23          	sw	a1,24(sp)
800014dc:	00a12e23          	sw	a0,28(sp)
800014e0:	02010593          	addi	a1,sp,32
800014e4:	00b12823          	sw	a1,16(sp)
800014e8:	00a12a23          	sw	a0,20(sp)
800014ec:	800045b7          	lui	a1,0x80004
800014f0:	53c58593          	addi	a1,a1,1340 # 8000453c <anon.69b25bd7f89c0392b47e51b05b6e4f5f.2.llvm.17300957278716910357>
800014f4:	07b10513          	addi	a0,sp,123
800014f8:	00810613          	addi	a2,sp,8
800014fc:	00001097          	auipc	ra,0x1
80001500:	bc4080e7          	jalr	-1084(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
80001504:	08051c63          	bnez	a0,8000159c <_ZN7SuperOS6palloc4init17hb4eb3dcde82ecf87E+0x1e4>
80001508:	81ffe537          	lui	a0,0x81ffe
8000150c:	fff50513          	addi	a0,a0,-1 # 81ffdfff <KALLOC_BUFFER+0x1ff7fff>
80001510:	07256463          	bltu	a0,s2,80001578 <_ZN7SuperOS6palloc4init17hb4eb3dcde82ecf87E+0x1c0>
80001514:	80005537          	lui	a0,0x80005
80001518:	d5052603          	lw	a2,-688(a0) # 80004d50 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.0.llvm.17300957278716910357>
8000151c:	800055b7          	lui	a1,0x80005
80001520:	d545a683          	lw	a3,-684(a1) # 80004d54 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.1.llvm.17300957278716910357>
80001524:	00c41713          	slli	a4,s0,0xc
80001528:	00c72023          	sw	a2,0(a4)
8000152c:	00d72223          	sw	a3,4(a4)
80001530:	00100613          	li	a2,1
80001534:	d4c52823          	sw	a2,-688(a0)
80001538:	000826b7          	lui	a3,0x82
8000153c:	ffd68693          	addi	a3,a3,-3 # 81ffd <.Lline_table_start2+0x80c5e>
80001540:	d485aa23          	sw	s0,-684(a1)
80001544:	02d48a63          	beq	s1,a3,80001578 <_ZN7SuperOS6palloc4init17hb4eb3dcde82ecf87E+0x1c0>
80001548:	00c49713          	slli	a4,s1,0xc
8000154c:	000027b7          	lui	a5,0x2
80001550:	00f70733          	add	a4,a4,a5
80001554:	000017b7          	lui	a5,0x1
80001558:	00040813          	mv	a6,s0
8000155c:	00c72023          	sw	a2,0(a4)
80001560:	00872223          	sw	s0,4(a4)
80001564:	d4c52823          	sw	a2,-688(a0)
80001568:	00140413          	addi	s0,s0,1
8000156c:	d485aa23          	sw	s0,-684(a1)
80001570:	00f70733          	add	a4,a4,a5
80001574:	fed812e3          	bne	a6,a3,80001558 <_ZN7SuperOS6palloc4init17hb4eb3dcde82ecf87E+0x1a0>
80001578:	80005537          	lui	a0,0x80005
8000157c:	d4050e23          	sb	zero,-676(a0) # 80004d5c <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17hc506b740a132e98fE.3.llvm.17300957278716910357>
80001580:	08c12083          	lw	ra,140(sp)
80001584:	08812403          	lw	s0,136(sp)
80001588:	08412483          	lw	s1,132(sp)
8000158c:	08012903          	lw	s2,128(sp)
80001590:	07c12983          	lw	s3,124(sp)
80001594:	09010113          	addi	sp,sp,144
80001598:	00008067          	ret
8000159c:	80004537          	lui	a0,0x80004
800015a0:	56450513          	addi	a0,a0,1380 # 80004564 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.4.llvm.17300957278716910357>
800015a4:	800046b7          	lui	a3,0x80004
800015a8:	55468693          	addi	a3,a3,1364 # 80004554 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.3.llvm.17300957278716910357>
800015ac:	80004737          	lui	a4,0x80004
800015b0:	5a070713          	addi	a4,a4,1440 # 800045a0 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.6.llvm.17300957278716910357>
800015b4:	02b00593          	li	a1,43
800015b8:	07b10613          	addi	a2,sp,123
800015bc:	00000097          	auipc	ra,0x0
800015c0:	48c080e7          	jalr	1164(ra) # 80001a48 <_ZN4core6result13unwrap_failed17h987d8f67a7161eb1E>

800015c4 <__rust_alloc_error_handler>:
800015c4:	00000317          	auipc	t1,0x0
800015c8:	a7c30067          	jr	-1412(t1) # 80001040 <__rg_oom>

800015cc <_ZN5alloc7raw_vec17capacity_overflow17hb1592fbbf602c068E>:
800015cc:	fe010113          	addi	sp,sp,-32
800015d0:	00112e23          	sw	ra,28(sp)
800015d4:	00812c23          	sw	s0,24(sp)
800015d8:	02010413          	addi	s0,sp,32
800015dc:	00050593          	mv	a1,a0
800015e0:	80004537          	lui	a0,0x80004
800015e4:	63450513          	addi	a0,a0,1588 # 80004634 <.Lanon.b62c2a328d7ddaf64cdc1bdc0f67bb4c.4>
800015e8:	fea42023          	sw	a0,-32(s0)
800015ec:	00100513          	li	a0,1
800015f0:	fea42223          	sw	a0,-28(s0)
800015f4:	fe042823          	sw	zero,-16(s0)
800015f8:	00400513          	li	a0,4
800015fc:	fea42423          	sw	a0,-24(s0)
80001600:	fe042623          	sw	zero,-20(s0)
80001604:	fe040513          	addi	a0,s0,-32
80001608:	00000097          	auipc	ra,0x0
8000160c:	280080e7          	jalr	640(ra) # 80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>

80001610 <_ZN5alloc7raw_vec12handle_error17ha58a8384aa435a2cE>:
80001610:	ff010113          	addi	sp,sp,-16
80001614:	00112623          	sw	ra,12(sp)
80001618:	00812423          	sw	s0,8(sp)
8000161c:	01010413          	addi	s0,sp,16
80001620:	00051863          	bnez	a0,80001630 <_ZN5alloc7raw_vec12handle_error17ha58a8384aa435a2cE+0x20>
80001624:	00060513          	mv	a0,a2
80001628:	00000097          	auipc	ra,0x0
8000162c:	fa4080e7          	jalr	-92(ra) # 800015cc <_ZN5alloc7raw_vec17capacity_overflow17hb1592fbbf602c068E>
80001630:	00000097          	auipc	ra,0x0
80001634:	008080e7          	jalr	8(ra) # 80001638 <_ZN5alloc5alloc18handle_alloc_error17hacdc36dbf7ea50caE>

80001638 <_ZN5alloc5alloc18handle_alloc_error17hacdc36dbf7ea50caE>:
80001638:	ff010113          	addi	sp,sp,-16
8000163c:	00112623          	sw	ra,12(sp)
80001640:	00812423          	sw	s0,8(sp)
80001644:	01010413          	addi	s0,sp,16
80001648:	00050613          	mv	a2,a0
8000164c:	00058513          	mv	a0,a1
80001650:	00060593          	mv	a1,a2
80001654:	00000097          	auipc	ra,0x0
80001658:	f70080e7          	jalr	-144(ra) # 800015c4 <__rust_alloc_error_handler>

8000165c <_ZN68_$LT$core..ptr..alignment..Alignment$u20$as$u20$core..fmt..Debug$GT$3fmt17h68454b409a0fd924E>:
8000165c:	fc010113          	addi	sp,sp,-64
80001660:	02112e23          	sw	ra,60(sp)
80001664:	02812c23          	sw	s0,56(sp)
80001668:	04010413          	addi	s0,sp,64
8000166c:	00052503          	lw	a0,0(a0)
80001670:	40a00633          	neg	a2,a0
80001674:	00c57633          	and	a2,a0,a2
80001678:	077cb6b7          	lui	a3,0x77cb
8000167c:	53168693          	addi	a3,a3,1329 # 77cb531 <.Lline_table_start2+0x77ca192>
80001680:	02d60633          	mul	a2,a2,a3
80001684:	01b65613          	srli	a2,a2,0x1b
80001688:	800046b7          	lui	a3,0x80004
8000168c:	63c68693          	addi	a3,a3,1596 # 8000463c <.Lanon.b62c2a328d7ddaf64cdc1bdc0f67bb4c.4+0x8>
80001690:	00c68633          	add	a2,a3,a2
80001694:	00064603          	lbu	a2,0(a2)
80001698:	fea42823          	sw	a0,-16(s0)
8000169c:	fec42a23          	sw	a2,-12(s0)
800016a0:	ff040513          	addi	a0,s0,-16
800016a4:	fea42023          	sw	a0,-32(s0)
800016a8:	80003537          	lui	a0,0x80003
800016ac:	e9c50513          	addi	a0,a0,-356 # 80002e9c <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E>
800016b0:	fea42223          	sw	a0,-28(s0)
800016b4:	ff440513          	addi	a0,s0,-12
800016b8:	fea42423          	sw	a0,-24(s0)
800016bc:	80003537          	lui	a0,0x80003
800016c0:	09450513          	addi	a0,a0,148 # 80003094 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE>
800016c4:	fea42623          	sw	a0,-20(s0)
800016c8:	80004537          	lui	a0,0x80004
800016cc:	66450513          	addi	a0,a0,1636 # 80004664 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.140>
800016d0:	fca42423          	sw	a0,-56(s0)
800016d4:	00300513          	li	a0,3
800016d8:	fca42623          	sw	a0,-52(s0)
800016dc:	fc042c23          	sw	zero,-40(s0)
800016e0:	fe040613          	addi	a2,s0,-32
800016e4:	0145a503          	lw	a0,20(a1)
800016e8:	0185a583          	lw	a1,24(a1)
800016ec:	fcc42823          	sw	a2,-48(s0)
800016f0:	00200613          	li	a2,2
800016f4:	fcc42a23          	sw	a2,-44(s0)
800016f8:	fc840613          	addi	a2,s0,-56
800016fc:	00001097          	auipc	ra,0x1
80001700:	9c4080e7          	jalr	-1596(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
80001704:	03c12083          	lw	ra,60(sp)
80001708:	03812403          	lw	s0,56(sp)
8000170c:	04010113          	addi	sp,sp,64
80001710:	00008067          	ret

80001714 <_ZN4core6option13unwrap_failed17ha917ca27cfe8d772E>:
80001714:	ff010113          	addi	sp,sp,-16
80001718:	00112623          	sw	ra,12(sp)
8000171c:	00812423          	sw	s0,8(sp)
80001720:	01010413          	addi	s0,sp,16
80001724:	00050613          	mv	a2,a0
80001728:	80004537          	lui	a0,0x80004
8000172c:	67d50513          	addi	a0,a0,1661 # 8000467d <.Lanon.0a795d8d80343cc40e42ade3e02d1552.220>
80001730:	02b00593          	li	a1,43
80001734:	00000097          	auipc	ra,0x0
80001738:	180080e7          	jalr	384(ra) # 800018b4 <_ZN4core9panicking5panic17h651cf8329c8a8911E>

8000173c <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h69b70629720e2a98E>:
8000173c:	fb010113          	addi	sp,sp,-80
80001740:	04112623          	sw	ra,76(sp)
80001744:	04812423          	sw	s0,72(sp)
80001748:	04912223          	sw	s1,68(sp)
8000174c:	05212023          	sw	s2,64(sp)
80001750:	03312e23          	sw	s3,60(sp)
80001754:	03412c23          	sw	s4,56(sp)
80001758:	03512a23          	sw	s5,52(sp)
8000175c:	05010413          	addi	s0,sp,80
80001760:	0185a483          	lw	s1,24(a1)
80001764:	0145a903          	lw	s2,20(a1)
80001768:	00c4aa83          	lw	s5,12(s1)
8000176c:	00050993          	mv	s3,a0
80001770:	800045b7          	lui	a1,0x80004
80001774:	6c058593          	addi	a1,a1,1728 # 800046c0 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.222>
80001778:	00c00613          	li	a2,12
8000177c:	00090513          	mv	a0,s2
80001780:	000a80e7          	jalr	s5
80001784:	00100a13          	li	s4,1
80001788:	0c051c63          	bnez	a0,80001860 <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h69b70629720e2a98E+0x124>
8000178c:	0049a503          	lw	a0,4(s3)
80001790:	00850593          	addi	a1,a0,8
80001794:	00c50613          	addi	a2,a0,12
80001798:	fca42623          	sw	a0,-52(s0)
8000179c:	80003537          	lui	a0,0x80003
800017a0:	3ac50513          	addi	a0,a0,940 # 800033ac <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17h03d1090a3af591adE>
800017a4:	fca42823          	sw	a0,-48(s0)
800017a8:	fcb42a23          	sw	a1,-44(s0)
800017ac:	80003537          	lui	a0,0x80003
800017b0:	18c50513          	addi	a0,a0,396 # 8000318c <_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17he9e9e363faaccf29E>
800017b4:	fca42c23          	sw	a0,-40(s0)
800017b8:	fcc42e23          	sw	a2,-36(s0)
800017bc:	fea42023          	sw	a0,-32(s0)
800017c0:	80004537          	lui	a0,0x80004
800017c4:	6a850513          	addi	a0,a0,1704 # 800046a8 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.221>
800017c8:	faa42a23          	sw	a0,-76(s0)
800017cc:	00300513          	li	a0,3
800017d0:	faa42c23          	sw	a0,-72(s0)
800017d4:	fc042223          	sw	zero,-60(s0)
800017d8:	fcc40593          	addi	a1,s0,-52
800017dc:	fab42e23          	sw	a1,-68(s0)
800017e0:	fca42023          	sw	a0,-64(s0)
800017e4:	fb440613          	addi	a2,s0,-76
800017e8:	00090513          	mv	a0,s2
800017ec:	00048593          	mv	a1,s1
800017f0:	00001097          	auipc	ra,0x1
800017f4:	8d0080e7          	jalr	-1840(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
800017f8:	06051463          	bnez	a0,80001860 <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h69b70629720e2a98E+0x124>
800017fc:	800045b7          	lui	a1,0x80004
80001800:	6cc58593          	addi	a1,a1,1740 # 800046cc <.Lanon.0a795d8d80343cc40e42ade3e02d1552.223>
80001804:	00200613          	li	a2,2
80001808:	00090513          	mv	a0,s2
8000180c:	000a80e7          	jalr	s5
80001810:	04051863          	bnez	a0,80001860 <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h69b70629720e2a98E+0x124>
80001814:	0009a503          	lw	a0,0(s3)
80001818:	00052583          	lw	a1,0(a0)
8000181c:	fcb42623          	sw	a1,-52(s0)
80001820:	00452583          	lw	a1,4(a0)
80001824:	fcb42823          	sw	a1,-48(s0)
80001828:	00852583          	lw	a1,8(a0)
8000182c:	fcb42a23          	sw	a1,-44(s0)
80001830:	00c52583          	lw	a1,12(a0)
80001834:	fcb42c23          	sw	a1,-40(s0)
80001838:	01052583          	lw	a1,16(a0)
8000183c:	fcb42e23          	sw	a1,-36(s0)
80001840:	01452503          	lw	a0,20(a0)
80001844:	fea42023          	sw	a0,-32(s0)
80001848:	fcc40613          	addi	a2,s0,-52
8000184c:	00090513          	mv	a0,s2
80001850:	00048593          	mv	a1,s1
80001854:	00001097          	auipc	ra,0x1
80001858:	86c080e7          	jalr	-1940(ra) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>
8000185c:	00050a13          	mv	s4,a0
80001860:	000a0513          	mv	a0,s4
80001864:	04c12083          	lw	ra,76(sp)
80001868:	04812403          	lw	s0,72(sp)
8000186c:	04412483          	lw	s1,68(sp)
80001870:	04012903          	lw	s2,64(sp)
80001874:	03c12983          	lw	s3,60(sp)
80001878:	03812a03          	lw	s4,56(sp)
8000187c:	03412a83          	lw	s5,52(sp)
80001880:	05010113          	addi	sp,sp,80
80001884:	00008067          	ret

80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>:
80001888:	fe010113          	addi	sp,sp,-32
8000188c:	00112e23          	sw	ra,28(sp)
80001890:	00812c23          	sw	s0,24(sp)
80001894:	02010413          	addi	s0,sp,32
80001898:	fea42623          	sw	a0,-20(s0)
8000189c:	feb42823          	sw	a1,-16(s0)
800018a0:	00100513          	li	a0,1
800018a4:	fea41a23          	sh	a0,-12(s0)
800018a8:	fec40513          	addi	a0,s0,-20
800018ac:	fffff097          	auipc	ra,0xfffff
800018b0:	edc080e7          	jalr	-292(ra) # 80000788 <rust_begin_unwind>

800018b4 <_ZN4core9panicking5panic17h651cf8329c8a8911E>:
800018b4:	fd010113          	addi	sp,sp,-48
800018b8:	02112623          	sw	ra,44(sp)
800018bc:	02812423          	sw	s0,40(sp)
800018c0:	03010413          	addi	s0,sp,48
800018c4:	fea42823          	sw	a0,-16(s0)
800018c8:	feb42a23          	sw	a1,-12(s0)
800018cc:	ff040513          	addi	a0,s0,-16
800018d0:	fca42c23          	sw	a0,-40(s0)
800018d4:	00100513          	li	a0,1
800018d8:	fca42e23          	sw	a0,-36(s0)
800018dc:	fe042423          	sw	zero,-24(s0)
800018e0:	00400513          	li	a0,4
800018e4:	fea42023          	sw	a0,-32(s0)
800018e8:	fe042223          	sw	zero,-28(s0)
800018ec:	fd840513          	addi	a0,s0,-40
800018f0:	00060593          	mv	a1,a2
800018f4:	00000097          	auipc	ra,0x0
800018f8:	f94080e7          	jalr	-108(ra) # 80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>

800018fc <_ZN4core9panicking19assert_failed_inner17h6dd275b923677f96E>:
800018fc:	f8010113          	addi	sp,sp,-128
80001900:	06112e23          	sw	ra,124(sp)
80001904:	06812c23          	sw	s0,120(sp)
80001908:	06912a23          	sw	s1,116(sp)
8000190c:	07212823          	sw	s2,112(sp)
80001910:	08010413          	addi	s0,sp,128
80001914:	00080493          	mv	s1,a6
80001918:	f8b42423          	sw	a1,-120(s0)
8000191c:	f8c42623          	sw	a2,-116(s0)
80001920:	f8d42823          	sw	a3,-112(s0)
80001924:	f8e42a23          	sw	a4,-108(s0)
80001928:	00050c63          	beqz	a0,80001940 <_ZN4core9panicking19assert_failed_inner17h6dd275b923677f96E+0x44>
8000192c:	00100593          	li	a1,1
80001930:	02b51263          	bne	a0,a1,80001954 <_ZN4core9panicking19assert_failed_inner17h6dd275b923677f96E+0x58>
80001934:	80004537          	lui	a0,0x80004
80001938:	6d050513          	addi	a0,a0,1744 # 800046d0 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.241>
8000193c:	00c0006f          	j	80001948 <_ZN4core9panicking19assert_failed_inner17h6dd275b923677f96E+0x4c>
80001940:	80004537          	lui	a0,0x80004
80001944:	6ce50513          	addi	a0,a0,1742 # 800046ce <.Lanon.0a795d8d80343cc40e42ade3e02d1552.240>
80001948:	f8a42c23          	sw	a0,-104(s0)
8000194c:	00200513          	li	a0,2
80001950:	0140006f          	j	80001964 <_ZN4core9panicking19assert_failed_inner17h6dd275b923677f96E+0x68>
80001954:	80004537          	lui	a0,0x80004
80001958:	6d250513          	addi	a0,a0,1746 # 800046d2 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.242>
8000195c:	f8a42c23          	sw	a0,-104(s0)
80001960:	00700513          	li	a0,7
80001964:	0007a583          	lw	a1,0(a5) # 1000 <.Lline_table_start1+0x38>
80001968:	f8a42e23          	sw	a0,-100(s0)
8000196c:	04059663          	bnez	a1,800019b8 <_ZN4core9panicking19assert_failed_inner17h6dd275b923677f96E+0xbc>
80001970:	f9840513          	addi	a0,s0,-104
80001974:	faa42c23          	sw	a0,-72(s0)
80001978:	80003537          	lui	a0,0x80003
8000197c:	3ac50513          	addi	a0,a0,940 # 800033ac <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17h03d1090a3af591adE>
80001980:	faa42e23          	sw	a0,-68(s0)
80001984:	f8840513          	addi	a0,s0,-120
80001988:	fca42023          	sw	a0,-64(s0)
8000198c:	80003537          	lui	a0,0x80003
80001990:	38050513          	addi	a0,a0,896 # 80003380 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h2421b7a3a4e2e164E>
80001994:	fca42223          	sw	a0,-60(s0)
80001998:	f9040593          	addi	a1,s0,-112
8000199c:	fcb42423          	sw	a1,-56(s0)
800019a0:	fca42623          	sw	a0,-52(s0)
800019a4:	80004537          	lui	a0,0x80004
800019a8:	6fc50513          	addi	a0,a0,1788 # 800046fc <.Lanon.0a795d8d80343cc40e42ade3e02d1552.246>
800019ac:	fca42c23          	sw	a0,-40(s0)
800019b0:	00300513          	li	a0,3
800019b4:	0700006f          	j	80001a24 <_ZN4core9panicking19assert_failed_inner17h6dd275b923677f96E+0x128>
800019b8:	fa040513          	addi	a0,s0,-96
800019bc:	01800613          	li	a2,24
800019c0:	fa040913          	addi	s2,s0,-96
800019c4:	00078593          	mv	a1,a5
800019c8:	00002097          	auipc	ra,0x2
800019cc:	ac0080e7          	jalr	-1344(ra) # 80003488 <memcpy>
800019d0:	f9840513          	addi	a0,s0,-104
800019d4:	faa42c23          	sw	a0,-72(s0)
800019d8:	80003537          	lui	a0,0x80003
800019dc:	3ac50513          	addi	a0,a0,940 # 800033ac <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17h03d1090a3af591adE>
800019e0:	faa42e23          	sw	a0,-68(s0)
800019e4:	fd242023          	sw	s2,-64(s0)
800019e8:	80002537          	lui	a0,0x80002
800019ec:	08850513          	addi	a0,a0,136 # 80002088 <_ZN59_$LT$core..fmt..Arguments$u20$as$u20$core..fmt..Display$GT$3fmt17h5cb0ae2421481506E>
800019f0:	fca42223          	sw	a0,-60(s0)
800019f4:	f8840513          	addi	a0,s0,-120
800019f8:	fca42423          	sw	a0,-56(s0)
800019fc:	80003537          	lui	a0,0x80003
80001a00:	38050513          	addi	a0,a0,896 # 80003380 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h2421b7a3a4e2e164E>
80001a04:	fca42623          	sw	a0,-52(s0)
80001a08:	f9040593          	addi	a1,s0,-112
80001a0c:	fcb42823          	sw	a1,-48(s0)
80001a10:	fca42a23          	sw	a0,-44(s0)
80001a14:	80004537          	lui	a0,0x80004
80001a18:	72050513          	addi	a0,a0,1824 # 80004720 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.249>
80001a1c:	fca42c23          	sw	a0,-40(s0)
80001a20:	00400513          	li	a0,4
80001a24:	fca42e23          	sw	a0,-36(s0)
80001a28:	fe042423          	sw	zero,-24(s0)
80001a2c:	fb840593          	addi	a1,s0,-72
80001a30:	feb42023          	sw	a1,-32(s0)
80001a34:	fea42223          	sw	a0,-28(s0)
80001a38:	fd840513          	addi	a0,s0,-40
80001a3c:	00048593          	mv	a1,s1
80001a40:	00000097          	auipc	ra,0x0
80001a44:	e48080e7          	jalr	-440(ra) # 80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>

80001a48 <_ZN4core6result13unwrap_failed17h987d8f67a7161eb1E>:
80001a48:	fc010113          	addi	sp,sp,-64
80001a4c:	02112e23          	sw	ra,60(sp)
80001a50:	02812c23          	sw	s0,56(sp)
80001a54:	04010413          	addi	s0,sp,64
80001a58:	fca42023          	sw	a0,-64(s0)
80001a5c:	fcb42223          	sw	a1,-60(s0)
80001a60:	fcc42423          	sw	a2,-56(s0)
80001a64:	fcd42623          	sw	a3,-52(s0)
80001a68:	fc040513          	addi	a0,s0,-64
80001a6c:	fea42423          	sw	a0,-24(s0)
80001a70:	80003537          	lui	a0,0x80003
80001a74:	3ac50513          	addi	a0,a0,940 # 800033ac <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17h03d1090a3af591adE>
80001a78:	fea42623          	sw	a0,-20(s0)
80001a7c:	fc840513          	addi	a0,s0,-56
80001a80:	fea42823          	sw	a0,-16(s0)
80001a84:	80003537          	lui	a0,0x80003
80001a88:	38050513          	addi	a0,a0,896 # 80003380 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h2421b7a3a4e2e164E>
80001a8c:	fea42a23          	sw	a0,-12(s0)
80001a90:	80004537          	lui	a0,0x80004
80001a94:	74450513          	addi	a0,a0,1860 # 80004744 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.251>
80001a98:	fca42823          	sw	a0,-48(s0)
80001a9c:	00200513          	li	a0,2
80001aa0:	fca42a23          	sw	a0,-44(s0)
80001aa4:	fe042023          	sw	zero,-32(s0)
80001aa8:	fe840593          	addi	a1,s0,-24
80001aac:	fcb42c23          	sw	a1,-40(s0)
80001ab0:	fca42e23          	sw	a0,-36(s0)
80001ab4:	fd040513          	addi	a0,s0,-48
80001ab8:	00070593          	mv	a1,a4
80001abc:	00000097          	auipc	ra,0x0
80001ac0:	dcc080e7          	jalr	-564(ra) # 80001888 <_ZN4core9panicking9panic_fmt17hd44f1c16c40b716eE>

80001ac4 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E>:
80001ac4:	fb010113          	addi	sp,sp,-80
80001ac8:	04112623          	sw	ra,76(sp)
80001acc:	04812423          	sw	s0,72(sp)
80001ad0:	04912223          	sw	s1,68(sp)
80001ad4:	05212023          	sw	s2,64(sp)
80001ad8:	03312e23          	sw	s3,60(sp)
80001adc:	03412c23          	sw	s4,56(sp)
80001ae0:	03512a23          	sw	s5,52(sp)
80001ae4:	03612823          	sw	s6,48(sp)
80001ae8:	03712623          	sw	s7,44(sp)
80001aec:	03812423          	sw	s8,40(sp)
80001af0:	03912223          	sw	s9,36(sp)
80001af4:	03a12023          	sw	s10,32(sp)
80001af8:	01b12e23          	sw	s11,28(sp)
80001afc:	05010413          	addi	s0,sp,80
80001b00:	00060c13          	mv	s8,a2
80001b04:	00058913          	mv	s2,a1
80001b08:	00000993          	li	s3,0
80001b0c:	00000b93          	li	s7,0
80001b10:	00000d13          	li	s10,0
80001b14:	0a0a15b7          	lui	a1,0xa0a1
80001b18:	a0a58a93          	addi	s5,a1,-1526 # a0a0a0a <.Lline_table_start2+0xa09f66b>
80001b1c:	010105b7          	lui	a1,0x1010
80001b20:	10058b13          	addi	s6,a1,256 # 1010100 <.Lline_table_start2+0x100ed61>
80001b24:	00852583          	lw	a1,8(a0)
80001b28:	fcb42423          	sw	a1,-56(s0)
80001b2c:	00052583          	lw	a1,0(a0)
80001b30:	fcb42223          	sw	a1,-60(s0)
80001b34:	00452503          	lw	a0,4(a0)
80001b38:	fca42023          	sw	a0,-64(s0)
80001b3c:	fff90513          	addi	a0,s2,-1 # 80005fff <__bss_end+0x287>
80001b40:	faa42c23          	sw	a0,-72(s0)
80001b44:	40c00533          	neg	a0,a2
80001b48:	faa42e23          	sw	a0,-68(s0)
80001b4c:	00a00d93          	li	s11,10
80001b50:	80808537          	lui	a0,0x80808
80001b54:	08050a13          	addi	s4,a0,128 # 80808080 <KALLOC_BUFFER+0x802080>
80001b58:	0400006f          	j	80001b98 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0xd4>
80001b5c:	fb842503          	lw	a0,-72(s0)
80001b60:	00950533          	add	a0,a0,s1
80001b64:	00054503          	lbu	a0,0(a0)
80001b68:	ff650513          	addi	a0,a0,-10
80001b6c:	00153513          	seqz	a0,a0
80001b70:	fc842583          	lw	a1,-56(s0)
80001b74:	00a58023          	sb	a0,0(a1)
80001b78:	fc042503          	lw	a0,-64(s0)
80001b7c:	00c52683          	lw	a3,12(a0)
80001b80:	41348633          	sub	a2,s1,s3
80001b84:	013905b3          	add	a1,s2,s3
80001b88:	fc442503          	lw	a0,-60(s0)
80001b8c:	000680e7          	jalr	a3
80001b90:	000c8993          	mv	s3,s9
80001b94:	18051663          	bnez	a0,80001d20 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x25c>
80001b98:	001d7513          	andi	a0,s10,1
80001b9c:	16051e63          	bnez	a0,80001d18 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x254>
80001ba0:	057c7863          	bgeu	s8,s7,80001bf0 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x12c>
80001ba4:	00100d13          	li	s10,1
80001ba8:	00098c93          	mv	s9,s3
80001bac:	000c0493          	mv	s1,s8
80001bb0:	17898463          	beq	s3,s8,80001d18 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x254>
80001bb4:	fc842503          	lw	a0,-56(s0)
80001bb8:	00054503          	lbu	a0,0(a0)
80001bbc:	02050263          	beqz	a0,80001be0 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x11c>
80001bc0:	fc042503          	lw	a0,-64(s0)
80001bc4:	00c52683          	lw	a3,12(a0)
80001bc8:	00400613          	li	a2,4
80001bcc:	fc442503          	lw	a0,-60(s0)
80001bd0:	800045b7          	lui	a1,0x80004
80001bd4:	02658593          	addi	a1,a1,38 # 80004026 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.6+0x6>
80001bd8:	000680e7          	jalr	a3
80001bdc:	14051263          	bnez	a0,80001d20 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x25c>
80001be0:	f7349ee3          	bne	s1,s3,80001b5c <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x98>
80001be4:	00000513          	li	a0,0
80001be8:	f89ff06f          	j	80001b70 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0xac>
80001bec:	fb7c6ce3          	bltu	s8,s7,80001ba4 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0xe0>
80001bf0:	417c05b3          	sub	a1,s8,s7
80001bf4:	01790533          	add	a0,s2,s7
80001bf8:	00700613          	li	a2,7
80001bfc:	02b66863          	bltu	a2,a1,80001c2c <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x168>
80001c00:	117c0263          	beq	s8,s7,80001d04 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x240>
80001c04:	00000593          	li	a1,0
80001c08:	fbc42603          	lw	a2,-68(s0)
80001c0c:	01760633          	add	a2,a2,s7
80001c10:	00050693          	mv	a3,a0
80001c14:	0006c703          	lbu	a4,0(a3)
80001c18:	0bb70c63          	beq	a4,s11,80001cd0 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x20c>
80001c1c:	fff58593          	addi	a1,a1,-1
80001c20:	00168693          	addi	a3,a3,1
80001c24:	feb618e3          	bne	a2,a1,80001c14 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x150>
80001c28:	0dc0006f          	j	80001d04 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x240>
80001c2c:	00350713          	addi	a4,a0,3
80001c30:	ffc77713          	andi	a4,a4,-4
80001c34:	40a70633          	sub	a2,a4,a0
80001c38:	02060463          	beqz	a2,80001c60 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x19c>
80001c3c:	00000693          	li	a3,0
80001c40:	00d507b3          	add	a5,a0,a3
80001c44:	0007c783          	lbu	a5,0(a5)
80001c48:	09b78663          	beq	a5,s11,80001cd4 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x210>
80001c4c:	00168693          	addi	a3,a3,1
80001c50:	fed618e3          	bne	a2,a3,80001c40 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x17c>
80001c54:	ff858693          	addi	a3,a1,-8
80001c58:	00c6f663          	bgeu	a3,a2,80001c64 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x1a0>
80001c5c:	0480006f          	j	80001ca4 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x1e0>
80001c60:	ff858693          	addi	a3,a1,-8
80001c64:	00400793          	li	a5,4
80001c68:	00e78733          	add	a4,a5,a4
80001c6c:	ffc72783          	lw	a5,-4(a4)
80001c70:	00072803          	lw	a6,0(a4)
80001c74:	0157c8b3          	xor	a7,a5,s5
80001c78:	01584833          	xor	a6,a6,s5
80001c7c:	410b02b3          	sub	t0,s6,a6
80001c80:	0102e833          	or	a6,t0,a6
80001c84:	411b08b3          	sub	a7,s6,a7
80001c88:	00f8e7b3          	or	a5,a7,a5
80001c8c:	0107f7b3          	and	a5,a5,a6
80001c90:	0147f7b3          	and	a5,a5,s4
80001c94:	01479863          	bne	a5,s4,80001ca4 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x1e0>
80001c98:	00860613          	addi	a2,a2,8
80001c9c:	00870713          	addi	a4,a4,8
80001ca0:	fcc6f6e3          	bgeu	a3,a2,80001c6c <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x1a8>
80001ca4:	06b60063          	beq	a2,a1,80001d04 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x240>
80001ca8:	00c506b3          	add	a3,a0,a2
80001cac:	40c005b3          	neg	a1,a2
80001cb0:	fbc42603          	lw	a2,-68(s0)
80001cb4:	01760633          	add	a2,a2,s7
80001cb8:	0006c703          	lbu	a4,0(a3)
80001cbc:	01b70a63          	beq	a4,s11,80001cd0 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x20c>
80001cc0:	fff58593          	addi	a1,a1,-1
80001cc4:	00168693          	addi	a3,a3,1
80001cc8:	feb618e3          	bne	a2,a1,80001cb8 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x1f4>
80001ccc:	0380006f          	j	80001d04 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x240>
80001cd0:	40b006b3          	neg	a3,a1
80001cd4:	017685b3          	add	a1,a3,s7
80001cd8:	00158b93          	addi	s7,a1,1
80001cdc:	f185f8e3          	bgeu	a1,s8,80001bec <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x128>
80001ce0:	00d50533          	add	a0,a0,a3
80001ce4:	00054503          	lbu	a0,0(a0)
80001ce8:	f1b512e3          	bne	a0,s11,80001bec <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x128>
80001cec:	000b8c93          	mv	s9,s7
80001cf0:	000b8493          	mv	s1,s7
80001cf4:	fc842503          	lw	a0,-56(s0)
80001cf8:	00054503          	lbu	a0,0(a0)
80001cfc:	ee0502e3          	beqz	a0,80001be0 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x11c>
80001d00:	ec1ff06f          	j	80001bc0 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0xfc>
80001d04:	000c0b93          	mv	s7,s8
80001d08:	00100d13          	li	s10,1
80001d0c:	00098c93          	mv	s9,s3
80001d10:	000c0493          	mv	s1,s8
80001d14:	eb8990e3          	bne	s3,s8,80001bb4 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0xf0>
80001d18:	00000513          	li	a0,0
80001d1c:	0080006f          	j	80001d24 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E+0x260>
80001d20:	00100513          	li	a0,1
80001d24:	04c12083          	lw	ra,76(sp)
80001d28:	04812403          	lw	s0,72(sp)
80001d2c:	04412483          	lw	s1,68(sp)
80001d30:	04012903          	lw	s2,64(sp)
80001d34:	03c12983          	lw	s3,60(sp)
80001d38:	03812a03          	lw	s4,56(sp)
80001d3c:	03412a83          	lw	s5,52(sp)
80001d40:	03012b03          	lw	s6,48(sp)
80001d44:	02c12b83          	lw	s7,44(sp)
80001d48:	02812c03          	lw	s8,40(sp)
80001d4c:	02412c83          	lw	s9,36(sp)
80001d50:	02012d03          	lw	s10,32(sp)
80001d54:	01c12d83          	lw	s11,28(sp)
80001d58:	05010113          	addi	sp,sp,80
80001d5c:	00008067          	ret

80001d60 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$10write_char17h128366ffe57dce96E>:
80001d60:	fe010113          	addi	sp,sp,-32
80001d64:	00112e23          	sw	ra,28(sp)
80001d68:	00812c23          	sw	s0,24(sp)
80001d6c:	00912a23          	sw	s1,20(sp)
80001d70:	01212823          	sw	s2,16(sp)
80001d74:	01312623          	sw	s3,12(sp)
80001d78:	01412423          	sw	s4,8(sp)
80001d7c:	02010413          	addi	s0,sp,32
80001d80:	00852903          	lw	s2,8(a0)
80001d84:	00094603          	lbu	a2,0(s2)
80001d88:	00052483          	lw	s1,0(a0)
80001d8c:	00452983          	lw	s3,4(a0)
80001d90:	04060863          	beqz	a2,80001de0 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$10write_char17h128366ffe57dce96E+0x80>
80001d94:	00c9a703          	lw	a4,12(s3)
80001d98:	800046b7          	lui	a3,0x80004
80001d9c:	02668693          	addi	a3,a3,38 # 80004026 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.6+0x6>
80001da0:	00400613          	li	a2,4
80001da4:	00048513          	mv	a0,s1
80001da8:	00058a13          	mv	s4,a1
80001dac:	00068593          	mv	a1,a3
80001db0:	000700e7          	jalr	a4
80001db4:	000a0593          	mv	a1,s4
80001db8:	02050463          	beqz	a0,80001de0 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$10write_char17h128366ffe57dce96E+0x80>
80001dbc:	00100513          	li	a0,1
80001dc0:	01c12083          	lw	ra,28(sp)
80001dc4:	01812403          	lw	s0,24(sp)
80001dc8:	01412483          	lw	s1,20(sp)
80001dcc:	01012903          	lw	s2,16(sp)
80001dd0:	00c12983          	lw	s3,12(sp)
80001dd4:	00812a03          	lw	s4,8(sp)
80001dd8:	02010113          	addi	sp,sp,32
80001ddc:	00008067          	ret
80001de0:	ff658513          	addi	a0,a1,-10
80001de4:	00153513          	seqz	a0,a0
80001de8:	00a90023          	sb	a0,0(s2)
80001dec:	0109a303          	lw	t1,16(s3)
80001df0:	00048513          	mv	a0,s1
80001df4:	01c12083          	lw	ra,28(sp)
80001df8:	01812403          	lw	s0,24(sp)
80001dfc:	01412483          	lw	s1,20(sp)
80001e00:	01012903          	lw	s2,16(sp)
80001e04:	00c12983          	lw	s3,12(sp)
80001e08:	00812a03          	lw	s4,8(sp)
80001e0c:	02010113          	addi	sp,sp,32
80001e10:	00030067          	jr	t1

80001e14 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E>:
80001e14:	fa010113          	addi	sp,sp,-96
80001e18:	04112e23          	sw	ra,92(sp)
80001e1c:	04812c23          	sw	s0,88(sp)
80001e20:	04912a23          	sw	s1,84(sp)
80001e24:	05212823          	sw	s2,80(sp)
80001e28:	05312623          	sw	s3,76(sp)
80001e2c:	05412423          	sw	s4,72(sp)
80001e30:	05512223          	sw	s5,68(sp)
80001e34:	05612023          	sw	s6,64(sp)
80001e38:	03712e23          	sw	s7,60(sp)
80001e3c:	03812c23          	sw	s8,56(sp)
80001e40:	06010413          	addi	s0,sp,96
80001e44:	00050493          	mv	s1,a0
80001e48:	00454503          	lbu	a0,4(a0)
80001e4c:	00100b13          	li	s6,1
80001e50:	00100a93          	li	s5,1
80001e54:	04050063          	beqz	a0,80001e94 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x80>
80001e58:	01548223          	sb	s5,4(s1)
80001e5c:	016482a3          	sb	s6,5(s1)
80001e60:	00048513          	mv	a0,s1
80001e64:	05c12083          	lw	ra,92(sp)
80001e68:	05812403          	lw	s0,88(sp)
80001e6c:	05412483          	lw	s1,84(sp)
80001e70:	05012903          	lw	s2,80(sp)
80001e74:	04c12983          	lw	s3,76(sp)
80001e78:	04812a03          	lw	s4,72(sp)
80001e7c:	04412a83          	lw	s5,68(sp)
80001e80:	04012b03          	lw	s6,64(sp)
80001e84:	03c12b83          	lw	s7,60(sp)
80001e88:	03812c03          	lw	s8,56(sp)
80001e8c:	06010113          	addi	sp,sp,96
80001e90:	00008067          	ret
80001e94:	00070993          	mv	s3,a4
80001e98:	00068913          	mv	s2,a3
80001e9c:	0004aa03          	lw	s4,0(s1)
80001ea0:	01ca2503          	lw	a0,28(s4)
80001ea4:	0054c683          	lbu	a3,5(s1)
80001ea8:	00457713          	andi	a4,a0,4
80001eac:	00071e63          	bnez	a4,80001ec8 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0xb4>
80001eb0:	00058b93          	mv	s7,a1
80001eb4:	00060c13          	mv	s8,a2
80001eb8:	10069c63          	bnez	a3,80001fd0 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x1bc>
80001ebc:	800045b7          	lui	a1,0x80004
80001ec0:	76c58593          	addi	a1,a1,1900 # 8000476c <.Lanon.0a795d8d80343cc40e42ade3e02d1552.254>
80001ec4:	1140006f          	j	80001fd8 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x1c4>
80001ec8:	04069063          	bnez	a3,80001f08 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0xf4>
80001ecc:	018a2683          	lw	a3,24(s4)
80001ed0:	014a2503          	lw	a0,20(s4)
80001ed4:	00c6a703          	lw	a4,12(a3)
80001ed8:	800046b7          	lui	a3,0x80004
80001edc:	77168693          	addi	a3,a3,1905 # 80004771 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.256>
80001ee0:	00060a93          	mv	s5,a2
80001ee4:	00300613          	li	a2,3
80001ee8:	00058b93          	mv	s7,a1
80001eec:	00068593          	mv	a1,a3
80001ef0:	000700e7          	jalr	a4
80001ef4:	000a8613          	mv	a2,s5
80001ef8:	00100a93          	li	s5,1
80001efc:	f4051ee3          	bnez	a0,80001e58 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x44>
80001f00:	000b8593          	mv	a1,s7
80001f04:	01ca2503          	lw	a0,28(s4)
80001f08:	014a2683          	lw	a3,20(s4)
80001f0c:	018a2703          	lw	a4,24(s4)
80001f10:	00100a93          	li	s5,1
80001f14:	fb5409a3          	sb	s5,-77(s0)
80001f18:	fad42223          	sw	a3,-92(s0)
80001f1c:	fae42423          	sw	a4,-88(s0)
80001f20:	fb340693          	addi	a3,s0,-77
80001f24:	fad42623          	sw	a3,-84(s0)
80001f28:	010a2683          	lw	a3,16(s4)
80001f2c:	020a4703          	lbu	a4,32(s4)
80001f30:	000a2783          	lw	a5,0(s4)
80001f34:	004a2803          	lw	a6,4(s4)
80001f38:	008a2883          	lw	a7,8(s4)
80001f3c:	00ca2283          	lw	t0,12(s4)
80001f40:	fca42823          	sw	a0,-48(s0)
80001f44:	fcd42223          	sw	a3,-60(s0)
80001f48:	fce40a23          	sb	a4,-44(s0)
80001f4c:	faf42a23          	sw	a5,-76(s0)
80001f50:	fb042c23          	sw	a6,-72(s0)
80001f54:	fb142e23          	sw	a7,-68(s0)
80001f58:	fc542023          	sw	t0,-64(s0)
80001f5c:	fa440513          	addi	a0,s0,-92
80001f60:	fca42423          	sw	a0,-56(s0)
80001f64:	80004537          	lui	a0,0x80004
80001f68:	75450513          	addi	a0,a0,1876 # 80004754 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.252>
80001f6c:	fca42623          	sw	a0,-52(s0)
80001f70:	fa440513          	addi	a0,s0,-92
80001f74:	00000097          	auipc	ra,0x0
80001f78:	b50080e7          	jalr	-1200(ra) # 80001ac4 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E>
80001f7c:	ec051ee3          	bnez	a0,80001e58 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x44>
80001f80:	800045b7          	lui	a1,0x80004
80001f84:	74058593          	addi	a1,a1,1856 # 80004740 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.250>
80001f88:	fa440513          	addi	a0,s0,-92
80001f8c:	00200613          	li	a2,2
80001f90:	00000097          	auipc	ra,0x0
80001f94:	b34080e7          	jalr	-1228(ra) # 80001ac4 <_ZN68_$LT$core..fmt..builders..PadAdapter$u20$as$u20$core..fmt..Write$GT$9write_str17hc8bc3946853d1fe4E>
80001f98:	ec0510e3          	bnez	a0,80001e58 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x44>
80001f9c:	00c9a603          	lw	a2,12(s3)
80001fa0:	fb440593          	addi	a1,s0,-76
80001fa4:	00090513          	mv	a0,s2
80001fa8:	000600e7          	jalr	a2
80001fac:	ea0516e3          	bnez	a0,80001e58 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x44>
80001fb0:	fcc42583          	lw	a1,-52(s0)
80001fb4:	fc842503          	lw	a0,-56(s0)
80001fb8:	00c5a683          	lw	a3,12(a1)
80001fbc:	800045b7          	lui	a1,0x80004
80001fc0:	77458593          	addi	a1,a1,1908 # 80004774 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.257>
80001fc4:	00200613          	li	a2,2
80001fc8:	000680e7          	jalr	a3
80001fcc:	07c0006f          	j	80002048 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x234>
80001fd0:	800045b7          	lui	a1,0x80004
80001fd4:	76f58593          	addi	a1,a1,1903 # 8000476f <.Lanon.0a795d8d80343cc40e42ade3e02d1552.255>
80001fd8:	018a2603          	lw	a2,24(s4)
80001fdc:	014a2503          	lw	a0,20(s4)
80001fe0:	00c62703          	lw	a4,12(a2)
80001fe4:	0036c613          	xori	a2,a3,3
80001fe8:	000700e7          	jalr	a4
80001fec:	00100a93          	li	s5,1
80001ff0:	e60514e3          	bnez	a0,80001e58 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x44>
80001ff4:	000c0613          	mv	a2,s8
80001ff8:	000b8593          	mv	a1,s7
80001ffc:	018a2683          	lw	a3,24(s4)
80002000:	014a2503          	lw	a0,20(s4)
80002004:	00c6a683          	lw	a3,12(a3)
80002008:	000680e7          	jalr	a3
8000200c:	00100a93          	li	s5,1
80002010:	e40514e3          	bnez	a0,80001e58 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x44>
80002014:	018a2583          	lw	a1,24(s4)
80002018:	014a2503          	lw	a0,20(s4)
8000201c:	00c5a683          	lw	a3,12(a1)
80002020:	800045b7          	lui	a1,0x80004
80002024:	74058593          	addi	a1,a1,1856 # 80004740 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.250>
80002028:	00200613          	li	a2,2
8000202c:	000680e7          	jalr	a3
80002030:	00100a93          	li	s5,1
80002034:	e20512e3          	bnez	a0,80001e58 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x44>
80002038:	00c9a603          	lw	a2,12(s3)
8000203c:	00090513          	mv	a0,s2
80002040:	000a0593          	mv	a1,s4
80002044:	000600e7          	jalr	a2
80002048:	00050a93          	mv	s5,a0
8000204c:	e0dff06f          	j	80001e58 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E+0x44>

80002050 <_ZN4core3fmt5Write9write_fmt17h9b1e1bd59d19e928E>:
80002050:	ff010113          	addi	sp,sp,-16
80002054:	00112623          	sw	ra,12(sp)
80002058:	00812423          	sw	s0,8(sp)
8000205c:	01010413          	addi	s0,sp,16
80002060:	80004637          	lui	a2,0x80004
80002064:	75460613          	addi	a2,a2,1876 # 80004754 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.252>
80002068:	00058693          	mv	a3,a1
8000206c:	00060593          	mv	a1,a2
80002070:	00068613          	mv	a2,a3
80002074:	00c12083          	lw	ra,12(sp)
80002078:	00812403          	lw	s0,8(sp)
8000207c:	01010113          	addi	sp,sp,16
80002080:	00000317          	auipc	t1,0x0
80002084:	04030067          	jr	64(t1) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>

80002088 <_ZN59_$LT$core..fmt..Arguments$u20$as$u20$core..fmt..Display$GT$3fmt17h5cb0ae2421481506E>:
80002088:	ff010113          	addi	sp,sp,-16
8000208c:	00112623          	sw	ra,12(sp)
80002090:	00812423          	sw	s0,8(sp)
80002094:	01010413          	addi	s0,sp,16
80002098:	0145a603          	lw	a2,20(a1)
8000209c:	0185a583          	lw	a1,24(a1)
800020a0:	00050693          	mv	a3,a0
800020a4:	00060513          	mv	a0,a2
800020a8:	00068613          	mv	a2,a3
800020ac:	00c12083          	lw	ra,12(sp)
800020b0:	00812403          	lw	s0,8(sp)
800020b4:	01010113          	addi	sp,sp,16
800020b8:	00000317          	auipc	t1,0x0
800020bc:	00830067          	jr	8(t1) # 800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>

800020c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E>:
800020c0:	fb010113          	addi	sp,sp,-80
800020c4:	04112623          	sw	ra,76(sp)
800020c8:	04812423          	sw	s0,72(sp)
800020cc:	04912223          	sw	s1,68(sp)
800020d0:	05212023          	sw	s2,64(sp)
800020d4:	03312e23          	sw	s3,60(sp)
800020d8:	03412c23          	sw	s4,56(sp)
800020dc:	03512a23          	sw	s5,52(sp)
800020e0:	03612823          	sw	s6,48(sp)
800020e4:	03712623          	sw	s7,44(sp)
800020e8:	03812423          	sw	s8,40(sp)
800020ec:	05010413          	addi	s0,sp,80
800020f0:	00060493          	mv	s1,a2
800020f4:	fc042823          	sw	zero,-48(s0)
800020f8:	02000613          	li	a2,32
800020fc:	fcc42223          	sw	a2,-60(s0)
80002100:	00300613          	li	a2,3
80002104:	fcc40a23          	sb	a2,-44(s0)
80002108:	0104ab03          	lw	s6,16(s1)
8000210c:	fa042a23          	sw	zero,-76(s0)
80002110:	fa042e23          	sw	zero,-68(s0)
80002114:	fca42423          	sw	a0,-56(s0)
80002118:	fcb42623          	sw	a1,-52(s0)
8000211c:	120b0063          	beqz	s6,8000223c <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x17c>
80002120:	0144aa83          	lw	s5,20(s1)
80002124:	180a8863          	beqz	s5,800022b4 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x1f4>
80002128:	0004aa03          	lw	s4,0(s1)
8000212c:	0084a983          	lw	s3,8(s1)
80002130:	fffa8513          	addi	a0,s5,-1
80002134:	00551513          	slli	a0,a0,0x5
80002138:	00555513          	srli	a0,a0,0x5
8000213c:	00150913          	addi	s2,a0,1
80002140:	004a0a13          	addi	s4,s4,4
80002144:	005a9a93          	slli	s5,s5,0x5
80002148:	010b0b13          	addi	s6,s6,16
8000214c:	00200b93          	li	s7,2
80002150:	00100c13          	li	s8,1
80002154:	000a2603          	lw	a2,0(s4)
80002158:	00060e63          	beqz	a2,80002174 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0xb4>
8000215c:	fcc42683          	lw	a3,-52(s0)
80002160:	fc842503          	lw	a0,-56(s0)
80002164:	ffca2583          	lw	a1,-4(s4)
80002168:	00c6a683          	lw	a3,12(a3)
8000216c:	000680e7          	jalr	a3
80002170:	16051c63          	bnez	a0,800022e8 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x228>
80002174:	000b2603          	lw	a2,0(s6)
80002178:	00cb4683          	lbu	a3,12(s6)
8000217c:	008b2703          	lw	a4,8(s6)
80002180:	ff8b2583          	lw	a1,-8(s6)
80002184:	ffcb2503          	lw	a0,-4(s6)
80002188:	fcc42223          	sw	a2,-60(s0)
8000218c:	fcd40a23          	sb	a3,-44(s0)
80002190:	fce42823          	sw	a4,-48(s0)
80002194:	02058863          	beqz	a1,800021c4 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x104>
80002198:	01859a63          	bne	a1,s8,800021ac <_ZN4core3fmt5write17h10a3cb6eb3728939E+0xec>
8000219c:	00351513          	slli	a0,a0,0x3
800021a0:	00a98533          	add	a0,s3,a0
800021a4:	00052583          	lw	a1,0(a0)
800021a8:	00058c63          	beqz	a1,800021c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x100>
800021ac:	ff0b2603          	lw	a2,-16(s6)
800021b0:	fa042a23          	sw	zero,-76(s0)
800021b4:	faa42c23          	sw	a0,-72(s0)
800021b8:	03761063          	bne	a2,s7,800021d8 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x118>
800021bc:	0340006f          	j	800021f0 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x130>
800021c0:	00452503          	lw	a0,4(a0)
800021c4:	00100593          	li	a1,1
800021c8:	ff0b2603          	lw	a2,-16(s6)
800021cc:	fab42a23          	sw	a1,-76(s0)
800021d0:	faa42c23          	sw	a0,-72(s0)
800021d4:	01760e63          	beq	a2,s7,800021f0 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x130>
800021d8:	ff4b2583          	lw	a1,-12(s6)
800021dc:	03861063          	bne	a2,s8,800021fc <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x13c>
800021e0:	00359513          	slli	a0,a1,0x3
800021e4:	00a98533          	add	a0,s3,a0
800021e8:	00052583          	lw	a1,0(a0)
800021ec:	00058663          	beqz	a1,800021f8 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x138>
800021f0:	00000613          	li	a2,0
800021f4:	00c0006f          	j	80002200 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x140>
800021f8:	00452583          	lw	a1,4(a0)
800021fc:	00100613          	li	a2,1
80002200:	004b2503          	lw	a0,4(s6)
80002204:	00351513          	slli	a0,a0,0x3
80002208:	00a986b3          	add	a3,s3,a0
8000220c:	0006a503          	lw	a0,0(a3)
80002210:	0046a683          	lw	a3,4(a3)
80002214:	fac42e23          	sw	a2,-68(s0)
80002218:	fcb42023          	sw	a1,-64(s0)
8000221c:	fb440593          	addi	a1,s0,-76
80002220:	000680e7          	jalr	a3
80002224:	0c051263          	bnez	a0,800022e8 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x228>
80002228:	008a0a13          	addi	s4,s4,8
8000222c:	fe0a8a93          	addi	s5,s5,-32
80002230:	020b0b13          	addi	s6,s6,32
80002234:	f20a90e3          	bnez	s5,80002154 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x94>
80002238:	0700006f          	j	800022a8 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x1e8>
8000223c:	00c4a503          	lw	a0,12(s1)
80002240:	06050a63          	beqz	a0,800022b4 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x1f4>
80002244:	0084a983          	lw	s3,8(s1)
80002248:	00351a13          	slli	s4,a0,0x3
8000224c:	01498a33          	add	s4,s3,s4
80002250:	0004aa83          	lw	s5,0(s1)
80002254:	fff50513          	addi	a0,a0,-1
80002258:	00351513          	slli	a0,a0,0x3
8000225c:	00355513          	srli	a0,a0,0x3
80002260:	00150913          	addi	s2,a0,1
80002264:	004a8a93          	addi	s5,s5,4
80002268:	000aa603          	lw	a2,0(s5)
8000226c:	00060e63          	beqz	a2,80002288 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x1c8>
80002270:	fcc42683          	lw	a3,-52(s0)
80002274:	fc842503          	lw	a0,-56(s0)
80002278:	ffcaa583          	lw	a1,-4(s5)
8000227c:	00c6a683          	lw	a3,12(a3)
80002280:	000680e7          	jalr	a3
80002284:	06051263          	bnez	a0,800022e8 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x228>
80002288:	0009a503          	lw	a0,0(s3)
8000228c:	0049a603          	lw	a2,4(s3)
80002290:	fb440593          	addi	a1,s0,-76
80002294:	000600e7          	jalr	a2
80002298:	04051863          	bnez	a0,800022e8 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x228>
8000229c:	00898993          	addi	s3,s3,8
800022a0:	008a8a93          	addi	s5,s5,8
800022a4:	fd4992e3          	bne	s3,s4,80002268 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x1a8>
800022a8:	0044a503          	lw	a0,4(s1)
800022ac:	00a96a63          	bltu	s2,a0,800022c0 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x200>
800022b0:	0400006f          	j	800022f0 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x230>
800022b4:	00000913          	li	s2,0
800022b8:	0044a503          	lw	a0,4(s1)
800022bc:	02a07a63          	bgeu	zero,a0,800022f0 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x230>
800022c0:	0004a503          	lw	a0,0(s1)
800022c4:	00391913          	slli	s2,s2,0x3
800022c8:	01250933          	add	s2,a0,s2
800022cc:	fcc42683          	lw	a3,-52(s0)
800022d0:	fc842503          	lw	a0,-56(s0)
800022d4:	00092583          	lw	a1,0(s2)
800022d8:	00492603          	lw	a2,4(s2)
800022dc:	00c6a683          	lw	a3,12(a3)
800022e0:	000680e7          	jalr	a3
800022e4:	00050663          	beqz	a0,800022f0 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x230>
800022e8:	00100513          	li	a0,1
800022ec:	0080006f          	j	800022f4 <_ZN4core3fmt5write17h10a3cb6eb3728939E+0x234>
800022f0:	00000513          	li	a0,0
800022f4:	04c12083          	lw	ra,76(sp)
800022f8:	04812403          	lw	s0,72(sp)
800022fc:	04412483          	lw	s1,68(sp)
80002300:	04012903          	lw	s2,64(sp)
80002304:	03c12983          	lw	s3,60(sp)
80002308:	03812a03          	lw	s4,56(sp)
8000230c:	03412a83          	lw	s5,52(sp)
80002310:	03012b03          	lw	s6,48(sp)
80002314:	02c12b83          	lw	s7,44(sp)
80002318:	02812c03          	lw	s8,40(sp)
8000231c:	05010113          	addi	sp,sp,80
80002320:	00008067          	ret

80002324 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E>:
80002324:	fc010113          	addi	sp,sp,-64
80002328:	02112e23          	sw	ra,60(sp)
8000232c:	02812c23          	sw	s0,56(sp)
80002330:	02912a23          	sw	s1,52(sp)
80002334:	03212823          	sw	s2,48(sp)
80002338:	03312623          	sw	s3,44(sp)
8000233c:	03412423          	sw	s4,40(sp)
80002340:	03512223          	sw	s5,36(sp)
80002344:	03612023          	sw	s6,32(sp)
80002348:	01712e23          	sw	s7,28(sp)
8000234c:	01812c23          	sw	s8,24(sp)
80002350:	01912a23          	sw	s9,20(sp)
80002354:	01a12823          	sw	s10,16(sp)
80002358:	01b12623          	sw	s11,12(sp)
8000235c:	04010413          	addi	s0,sp,64
80002360:	00078493          	mv	s1,a5
80002364:	00070913          	mv	s2,a4
80002368:	00068993          	mv	s3,a3
8000236c:	00060a13          	mv	s4,a2
80002370:	06058263          	beqz	a1,800023d4 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0xb0>
80002374:	01c52b03          	lw	s6,28(a0)
80002378:	001b7c13          	andi	s8,s6,1
8000237c:	00110ab7          	lui	s5,0x110
80002380:	000c0463          	beqz	s8,80002388 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x64>
80002384:	02b00a93          	li	s5,43
80002388:	009c0c33          	add	s8,s8,s1
8000238c:	004b7593          	andi	a1,s6,4
80002390:	04058c63          	beqz	a1,800023e8 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0xc4>
80002394:	01000593          	li	a1,16
80002398:	06b9f063          	bgeu	s3,a1,800023f8 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0xd4>
8000239c:	00000593          	li	a1,0
800023a0:	02098263          	beqz	s3,800023c4 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0xa0>
800023a4:	013a0633          	add	a2,s4,s3
800023a8:	000a0693          	mv	a3,s4
800023ac:	00068703          	lb	a4,0(a3)
800023b0:	fc072713          	slti	a4,a4,-64
800023b4:	00174713          	xori	a4,a4,1
800023b8:	00168693          	addi	a3,a3,1
800023bc:	00e585b3          	add	a1,a1,a4
800023c0:	fec696e3          	bne	a3,a2,800023ac <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x88>
800023c4:	01858c33          	add	s8,a1,s8
800023c8:	00052583          	lw	a1,0(a0)
800023cc:	06058e63          	beqz	a1,80002448 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x124>
800023d0:	0500006f          	j	80002420 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0xfc>
800023d4:	01c52b03          	lw	s6,28(a0)
800023d8:	00148c13          	addi	s8,s1,1
800023dc:	02d00a93          	li	s5,45
800023e0:	004b7593          	andi	a1,s6,4
800023e4:	fa0598e3          	bnez	a1,80002394 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x70>
800023e8:	00000a13          	li	s4,0
800023ec:	00052583          	lw	a1,0(a0)
800023f0:	02059863          	bnez	a1,80002420 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0xfc>
800023f4:	0540006f          	j	80002448 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x124>
800023f8:	00050b93          	mv	s7,a0
800023fc:	000a0513          	mv	a0,s4
80002400:	00098593          	mv	a1,s3
80002404:	00001097          	auipc	ra,0x1
80002408:	810080e7          	jalr	-2032(ra) # 80002c14 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E>
8000240c:	00050593          	mv	a1,a0
80002410:	000b8513          	mv	a0,s7
80002414:	01858c33          	add	s8,a1,s8
80002418:	000ba583          	lw	a1,0(s7)
8000241c:	02058663          	beqz	a1,80002448 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x124>
80002420:	00452c83          	lw	s9,4(a0)
80002424:	039c7263          	bgeu	s8,s9,80002448 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x124>
80002428:	008b7593          	andi	a1,s6,8
8000242c:	08059c63          	bnez	a1,800024c4 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x1a0>
80002430:	02054583          	lbu	a1,32(a0)
80002434:	00100613          	li	a2,1
80002438:	418c8cb3          	sub	s9,s9,s8
8000243c:	0eb64c63          	blt	a2,a1,80002534 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x210>
80002440:	10058a63          	beqz	a1,80002554 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x230>
80002444:	1080006f          	j	8000254c <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x228>
80002448:	01452b03          	lw	s6,20(a0)
8000244c:	01852b83          	lw	s7,24(a0)
80002450:	000b0513          	mv	a0,s6
80002454:	000b8593          	mv	a1,s7
80002458:	000a8613          	mv	a2,s5
8000245c:	000a0693          	mv	a3,s4
80002460:	00098713          	mv	a4,s3
80002464:	00000097          	auipc	ra,0x0
80002468:	214080e7          	jalr	532(ra) # 80002678 <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h79510df2400b15a5E>
8000246c:	00050593          	mv	a1,a0
80002470:	00100513          	li	a0,1
80002474:	10059863          	bnez	a1,80002584 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x260>
80002478:	00cba303          	lw	t1,12(s7)
8000247c:	000b0513          	mv	a0,s6
80002480:	00090593          	mv	a1,s2
80002484:	00048613          	mv	a2,s1
80002488:	03c12083          	lw	ra,60(sp)
8000248c:	03812403          	lw	s0,56(sp)
80002490:	03412483          	lw	s1,52(sp)
80002494:	03012903          	lw	s2,48(sp)
80002498:	02c12983          	lw	s3,44(sp)
8000249c:	02812a03          	lw	s4,40(sp)
800024a0:	02412a83          	lw	s5,36(sp)
800024a4:	02012b03          	lw	s6,32(sp)
800024a8:	01c12b83          	lw	s7,28(sp)
800024ac:	01812c03          	lw	s8,24(sp)
800024b0:	01412c83          	lw	s9,20(sp)
800024b4:	01012d03          	lw	s10,16(sp)
800024b8:	00c12d83          	lw	s11,12(sp)
800024bc:	04010113          	addi	sp,sp,64
800024c0:	00030067          	jr	t1
800024c4:	01052583          	lw	a1,16(a0)
800024c8:	fcb42423          	sw	a1,-56(s0)
800024cc:	03000593          	li	a1,48
800024d0:	02054d03          	lbu	s10,32(a0)
800024d4:	01452b03          	lw	s6,20(a0)
800024d8:	01852b83          	lw	s7,24(a0)
800024dc:	00b52823          	sw	a1,16(a0)
800024e0:	00100593          	li	a1,1
800024e4:	00050d93          	mv	s11,a0
800024e8:	02b50023          	sb	a1,32(a0)
800024ec:	000b0513          	mv	a0,s6
800024f0:	000b8593          	mv	a1,s7
800024f4:	000a8613          	mv	a2,s5
800024f8:	000a0693          	mv	a3,s4
800024fc:	00098713          	mv	a4,s3
80002500:	00000097          	auipc	ra,0x0
80002504:	178080e7          	jalr	376(ra) # 80002678 <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h79510df2400b15a5E>
80002508:	06051c63          	bnez	a0,80002580 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x25c>
8000250c:	418c89b3          	sub	s3,s9,s8
80002510:	00198993          	addi	s3,s3,1
80002514:	fff98993          	addi	s3,s3,-1
80002518:	12098263          	beqz	s3,8000263c <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x318>
8000251c:	010ba603          	lw	a2,16(s7)
80002520:	03000593          	li	a1,48
80002524:	000b0513          	mv	a0,s6
80002528:	000600e7          	jalr	a2
8000252c:	fe0504e3          	beqz	a0,80002514 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x1f0>
80002530:	0500006f          	j	80002580 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x25c>
80002534:	00200613          	li	a2,2
80002538:	00c59a63          	bne	a1,a2,8000254c <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x228>
8000253c:	001cd593          	srli	a1,s9,0x1
80002540:	001c8c93          	addi	s9,s9,1
80002544:	001cdc93          	srli	s9,s9,0x1
80002548:	00c0006f          	j	80002554 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x230>
8000254c:	000c8593          	mv	a1,s9
80002550:	00000c93          	li	s9,0
80002554:	01452b03          	lw	s6,20(a0)
80002558:	01852b83          	lw	s7,24(a0)
8000255c:	01052c03          	lw	s8,16(a0)
80002560:	00158d13          	addi	s10,a1,1
80002564:	fffd0d13          	addi	s10,s10,-1
80002568:	040d0c63          	beqz	s10,800025c0 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x29c>
8000256c:	010ba603          	lw	a2,16(s7)
80002570:	000b0513          	mv	a0,s6
80002574:	000c0593          	mv	a1,s8
80002578:	000600e7          	jalr	a2
8000257c:	fe0504e3          	beqz	a0,80002564 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x240>
80002580:	00100513          	li	a0,1
80002584:	03c12083          	lw	ra,60(sp)
80002588:	03812403          	lw	s0,56(sp)
8000258c:	03412483          	lw	s1,52(sp)
80002590:	03012903          	lw	s2,48(sp)
80002594:	02c12983          	lw	s3,44(sp)
80002598:	02812a03          	lw	s4,40(sp)
8000259c:	02412a83          	lw	s5,36(sp)
800025a0:	02012b03          	lw	s6,32(sp)
800025a4:	01c12b83          	lw	s7,28(sp)
800025a8:	01812c03          	lw	s8,24(sp)
800025ac:	01412c83          	lw	s9,20(sp)
800025b0:	01012d03          	lw	s10,16(sp)
800025b4:	00c12d83          	lw	s11,12(sp)
800025b8:	04010113          	addi	sp,sp,64
800025bc:	00008067          	ret
800025c0:	000b0513          	mv	a0,s6
800025c4:	000b8593          	mv	a1,s7
800025c8:	000a8613          	mv	a2,s5
800025cc:	000a0693          	mv	a3,s4
800025d0:	00098713          	mv	a4,s3
800025d4:	00000097          	auipc	ra,0x0
800025d8:	0a4080e7          	jalr	164(ra) # 80002678 <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h79510df2400b15a5E>
800025dc:	00050593          	mv	a1,a0
800025e0:	00100513          	li	a0,1
800025e4:	fa0590e3          	bnez	a1,80002584 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x260>
800025e8:	00cba683          	lw	a3,12(s7)
800025ec:	000b0513          	mv	a0,s6
800025f0:	00090593          	mv	a1,s2
800025f4:	00048613          	mv	a2,s1
800025f8:	000680e7          	jalr	a3
800025fc:	00050593          	mv	a1,a0
80002600:	00100513          	li	a0,1
80002604:	f80590e3          	bnez	a1,80002584 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x260>
80002608:	41900933          	neg	s2,s9
8000260c:	fff00993          	li	s3,-1
80002610:	fff00493          	li	s1,-1
80002614:	00990533          	add	a0,s2,s1
80002618:	05350c63          	beq	a0,s3,80002670 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x34c>
8000261c:	010ba603          	lw	a2,16(s7)
80002620:	000b0513          	mv	a0,s6
80002624:	000c0593          	mv	a1,s8
80002628:	000600e7          	jalr	a2
8000262c:	00148493          	addi	s1,s1,1
80002630:	fe0502e3          	beqz	a0,80002614 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x2f0>
80002634:	0194b533          	sltu	a0,s1,s9
80002638:	f4dff06f          	j	80002584 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x260>
8000263c:	00cba683          	lw	a3,12(s7)
80002640:	000b0513          	mv	a0,s6
80002644:	00090593          	mv	a1,s2
80002648:	00048613          	mv	a2,s1
8000264c:	000680e7          	jalr	a3
80002650:	00050593          	mv	a1,a0
80002654:	00100513          	li	a0,1
80002658:	f20596e3          	bnez	a1,80002584 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x260>
8000265c:	00000513          	li	a0,0
80002660:	fc842583          	lw	a1,-56(s0)
80002664:	00bda823          	sw	a1,16(s11)
80002668:	03ad8023          	sb	s10,32(s11)
8000266c:	f19ff06f          	j	80002584 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x260>
80002670:	019cb533          	sltu	a0,s9,s9
80002674:	f11ff06f          	j	80002584 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E+0x260>

80002678 <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h79510df2400b15a5E>:
80002678:	fe010113          	addi	sp,sp,-32
8000267c:	00112e23          	sw	ra,28(sp)
80002680:	00812c23          	sw	s0,24(sp)
80002684:	00912a23          	sw	s1,20(sp)
80002688:	01212823          	sw	s2,16(sp)
8000268c:	01312623          	sw	s3,12(sp)
80002690:	01412423          	sw	s4,8(sp)
80002694:	02010413          	addi	s0,sp,32
80002698:	001107b7          	lui	a5,0x110
8000269c:	00070493          	mv	s1,a4
800026a0:	00068913          	mv	s2,a3
800026a4:	00058993          	mv	s3,a1
800026a8:	02f60263          	beq	a2,a5,800026cc <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h79510df2400b15a5E+0x54>
800026ac:	0109a683          	lw	a3,16(s3)
800026b0:	00050a13          	mv	s4,a0
800026b4:	00060593          	mv	a1,a2
800026b8:	000680e7          	jalr	a3
800026bc:	00050613          	mv	a2,a0
800026c0:	000a0513          	mv	a0,s4
800026c4:	00100593          	li	a1,1
800026c8:	02061c63          	bnez	a2,80002700 <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h79510df2400b15a5E+0x88>
800026cc:	02090863          	beqz	s2,800026fc <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h79510df2400b15a5E+0x84>
800026d0:	00c9a303          	lw	t1,12(s3)
800026d4:	00090593          	mv	a1,s2
800026d8:	00048613          	mv	a2,s1
800026dc:	01c12083          	lw	ra,28(sp)
800026e0:	01812403          	lw	s0,24(sp)
800026e4:	01412483          	lw	s1,20(sp)
800026e8:	01012903          	lw	s2,16(sp)
800026ec:	00c12983          	lw	s3,12(sp)
800026f0:	00812a03          	lw	s4,8(sp)
800026f4:	02010113          	addi	sp,sp,32
800026f8:	00030067          	jr	t1
800026fc:	00000593          	li	a1,0
80002700:	00058513          	mv	a0,a1
80002704:	01c12083          	lw	ra,28(sp)
80002708:	01812403          	lw	s0,24(sp)
8000270c:	01412483          	lw	s1,20(sp)
80002710:	01012903          	lw	s2,16(sp)
80002714:	00c12983          	lw	s3,12(sp)
80002718:	00812a03          	lw	s4,8(sp)
8000271c:	02010113          	addi	sp,sp,32
80002720:	00008067          	ret

80002724 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E>:
80002724:	fd010113          	addi	sp,sp,-48
80002728:	02112623          	sw	ra,44(sp)
8000272c:	02812423          	sw	s0,40(sp)
80002730:	02912223          	sw	s1,36(sp)
80002734:	03212023          	sw	s2,32(sp)
80002738:	01312e23          	sw	s3,28(sp)
8000273c:	01412c23          	sw	s4,24(sp)
80002740:	01512a23          	sw	s5,20(sp)
80002744:	01612823          	sw	s6,16(sp)
80002748:	01712623          	sw	s7,12(sp)
8000274c:	03010413          	addi	s0,sp,48
80002750:	00052683          	lw	a3,0(a0)
80002754:	00852703          	lw	a4,8(a0)
80002758:	00060493          	mv	s1,a2
8000275c:	00058913          	mv	s2,a1
80002760:	00177593          	andi	a1,a4,1
80002764:	00069463          	bnez	a3,8000276c <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x48>
80002768:	14058463          	beqz	a1,800028b0 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x18c>
8000276c:	0c058263          	beqz	a1,80002830 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x10c>
80002770:	00c52703          	lw	a4,12(a0)
80002774:	00990633          	add	a2,s2,s1
80002778:	00000593          	li	a1,0
8000277c:	04070e63          	beqz	a4,800027d8 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xb4>
80002780:	0e000793          	li	a5,224
80002784:	0f000813          	li	a6,240
80002788:	00090893          	mv	a7,s2
8000278c:	01c0006f          	j	800027a8 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x84>
80002790:	00188293          	addi	t0,a7,1
80002794:	40b885b3          	sub	a1,a7,a1
80002798:	fff70713          	addi	a4,a4,-1
8000279c:	40b285b3          	sub	a1,t0,a1
800027a0:	00028893          	mv	a7,t0
800027a4:	02070c63          	beqz	a4,800027dc <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xb8>
800027a8:	08c88463          	beq	a7,a2,80002830 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x10c>
800027ac:	00088283          	lb	t0,0(a7)
800027b0:	fe02d0e3          	bgez	t0,80002790 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x6c>
800027b4:	0ff2f293          	zext.b	t0,t0
800027b8:	00f2e863          	bltu	t0,a5,800027c8 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xa4>
800027bc:	0102ea63          	bltu	t0,a6,800027d0 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xac>
800027c0:	00488293          	addi	t0,a7,4
800027c4:	fd1ff06f          	j	80002794 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x70>
800027c8:	00288293          	addi	t0,a7,2
800027cc:	fc9ff06f          	j	80002794 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x70>
800027d0:	00388293          	addi	t0,a7,3
800027d4:	fc1ff06f          	j	80002794 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x70>
800027d8:	00090293          	mv	t0,s2
800027dc:	04c28a63          	beq	t0,a2,80002830 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x10c>
800027e0:	00028603          	lb	a2,0(t0)
800027e4:	00064663          	bltz	a2,800027f0 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xcc>
800027e8:	00059a63          	bnez	a1,800027fc <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xd8>
800027ec:	0340006f          	j	80002820 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xfc>
800027f0:	0ff67613          	zext.b	a2,a2
800027f4:	0e000713          	li	a4,224
800027f8:	02058463          	beqz	a1,80002820 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xfc>
800027fc:	0295f063          	bgeu	a1,s1,8000281c <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xf8>
80002800:	00b90633          	add	a2,s2,a1
80002804:	00060603          	lb	a2,0(a2)
80002808:	fc000713          	li	a4,-64
8000280c:	00e65a63          	bge	a2,a4,80002820 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xfc>
80002810:	00000613          	li	a2,0
80002814:	00001a63          	bnez	zero,80002828 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x104>
80002818:	0180006f          	j	80002830 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x10c>
8000281c:	fe959ae3          	bne	a1,s1,80002810 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0xec>
80002820:	00090613          	mv	a2,s2
80002824:	00090663          	beqz	s2,80002830 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x10c>
80002828:	00058493          	mv	s1,a1
8000282c:	00060913          	mv	s2,a2
80002830:	08068063          	beqz	a3,800028b0 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x18c>
80002834:	00452983          	lw	s3,4(a0)
80002838:	01000593          	li	a1,16
8000283c:	04b4fa63          	bgeu	s1,a1,80002890 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x16c>
80002840:	00000593          	li	a1,0
80002844:	02048263          	beqz	s1,80002868 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x144>
80002848:	00990633          	add	a2,s2,s1
8000284c:	00090693          	mv	a3,s2
80002850:	00068703          	lb	a4,0(a3)
80002854:	fc072713          	slti	a4,a4,-64
80002858:	00174713          	xori	a4,a4,1
8000285c:	00168693          	addi	a3,a3,1
80002860:	00e585b3          	add	a1,a1,a4
80002864:	fec696e3          	bne	a3,a2,80002850 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x12c>
80002868:	0535f463          	bgeu	a1,s3,800028b0 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x18c>
8000286c:	02054683          	lbu	a3,32(a0)
80002870:	00000613          	li	a2,0
80002874:	00100713          	li	a4,1
80002878:	40b98ab3          	sub	s5,s3,a1
8000287c:	06d74a63          	blt	a4,a3,800028f0 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x1cc>
80002880:	08068263          	beqz	a3,80002904 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x1e0>
80002884:	000a8613          	mv	a2,s5
80002888:	00000a93          	li	s5,0
8000288c:	0780006f          	j	80002904 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x1e0>
80002890:	00050a13          	mv	s4,a0
80002894:	00090513          	mv	a0,s2
80002898:	00048593          	mv	a1,s1
8000289c:	00000097          	auipc	ra,0x0
800028a0:	378080e7          	jalr	888(ra) # 80002c14 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E>
800028a4:	00050593          	mv	a1,a0
800028a8:	000a0513          	mv	a0,s4
800028ac:	fd35e0e3          	bltu	a1,s3,8000286c <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x148>
800028b0:	01852583          	lw	a1,24(a0)
800028b4:	01452503          	lw	a0,20(a0)
800028b8:	00c5a303          	lw	t1,12(a1)
800028bc:	00090593          	mv	a1,s2
800028c0:	00048613          	mv	a2,s1
800028c4:	02c12083          	lw	ra,44(sp)
800028c8:	02812403          	lw	s0,40(sp)
800028cc:	02412483          	lw	s1,36(sp)
800028d0:	02012903          	lw	s2,32(sp)
800028d4:	01c12983          	lw	s3,28(sp)
800028d8:	01812a03          	lw	s4,24(sp)
800028dc:	01412a83          	lw	s5,20(sp)
800028e0:	01012b03          	lw	s6,16(sp)
800028e4:	00c12b83          	lw	s7,12(sp)
800028e8:	03010113          	addi	sp,sp,48
800028ec:	00030067          	jr	t1
800028f0:	00200593          	li	a1,2
800028f4:	00b69863          	bne	a3,a1,80002904 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x1e0>
800028f8:	001ad613          	srli	a2,s5,0x1
800028fc:	001a8a93          	addi	s5,s5,1 # 110001 <.Lline_table_start2+0x10ec62>
80002900:	001ada93          	srli	s5,s5,0x1
80002904:	01452983          	lw	s3,20(a0)
80002908:	01852b03          	lw	s6,24(a0)
8000290c:	01052a03          	lw	s4,16(a0)
80002910:	00160b93          	addi	s7,a2,1
80002914:	fffb8b93          	addi	s7,s7,-1
80002918:	020b8063          	beqz	s7,80002938 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x214>
8000291c:	010b2603          	lw	a2,16(s6)
80002920:	00098513          	mv	a0,s3
80002924:	000a0593          	mv	a1,s4
80002928:	000600e7          	jalr	a2
8000292c:	fe0504e3          	beqz	a0,80002914 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x1f0>
80002930:	00100513          	li	a0,1
80002934:	05c0006f          	j	80002990 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x26c>
80002938:	00cb2683          	lw	a3,12(s6)
8000293c:	00098513          	mv	a0,s3
80002940:	00090593          	mv	a1,s2
80002944:	00048613          	mv	a2,s1
80002948:	000680e7          	jalr	a3
8000294c:	00050593          	mv	a1,a0
80002950:	00100513          	li	a0,1
80002954:	02059e63          	bnez	a1,80002990 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x26c>
80002958:	41500933          	neg	s2,s5
8000295c:	fff00b93          	li	s7,-1
80002960:	fff00493          	li	s1,-1
80002964:	00990533          	add	a0,s2,s1
80002968:	03750063          	beq	a0,s7,80002988 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x264>
8000296c:	010b2603          	lw	a2,16(s6)
80002970:	00098513          	mv	a0,s3
80002974:	000a0593          	mv	a1,s4
80002978:	000600e7          	jalr	a2
8000297c:	00148493          	addi	s1,s1,1
80002980:	fe0502e3          	beqz	a0,80002964 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x240>
80002984:	0080006f          	j	8000298c <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E+0x268>
80002988:	000a8493          	mv	s1,s5
8000298c:	0154b533          	sltu	a0,s1,s5
80002990:	02c12083          	lw	ra,44(sp)
80002994:	02812403          	lw	s0,40(sp)
80002998:	02412483          	lw	s1,36(sp)
8000299c:	02012903          	lw	s2,32(sp)
800029a0:	01c12983          	lw	s3,28(sp)
800029a4:	01812a03          	lw	s4,24(sp)
800029a8:	01412a83          	lw	s5,20(sp)
800029ac:	01012b03          	lw	s6,16(sp)
800029b0:	00c12b83          	lw	s7,12(sp)
800029b4:	03010113          	addi	sp,sp,48
800029b8:	00008067          	ret

800029bc <_ZN4core3fmt9Formatter9write_str17hd607abcbb12fb4c8E>:
800029bc:	ff010113          	addi	sp,sp,-16
800029c0:	00112623          	sw	ra,12(sp)
800029c4:	00812423          	sw	s0,8(sp)
800029c8:	01010413          	addi	s0,sp,16
800029cc:	01852683          	lw	a3,24(a0)
800029d0:	01452503          	lw	a0,20(a0)
800029d4:	00c6a303          	lw	t1,12(a3)
800029d8:	00c12083          	lw	ra,12(sp)
800029dc:	00812403          	lw	s0,8(sp)
800029e0:	01010113          	addi	sp,sp,16
800029e4:	00030067          	jr	t1

800029e8 <_ZN4core3fmt9Formatter26debug_struct_field2_finish17h8b989ef45de6295cE>:
800029e8:	fc010113          	addi	sp,sp,-64
800029ec:	02112e23          	sw	ra,60(sp)
800029f0:	02812c23          	sw	s0,56(sp)
800029f4:	02912a23          	sw	s1,52(sp)
800029f8:	03212823          	sw	s2,48(sp)
800029fc:	03312623          	sw	s3,44(sp)
80002a00:	03412423          	sw	s4,40(sp)
80002a04:	03512223          	sw	s5,36(sp)
80002a08:	03612023          	sw	s6,32(sp)
80002a0c:	01712e23          	sw	s7,28(sp)
80002a10:	01812c23          	sw	s8,24(sp)
80002a14:	01912a23          	sw	s9,20(sp)
80002a18:	04010413          	addi	s0,sp,64
80002a1c:	00050493          	mv	s1,a0
80002a20:	00042903          	lw	s2,0(s0)
80002a24:	01852283          	lw	t0,24(a0)
80002a28:	00442983          	lw	s3,4(s0)
80002a2c:	00842a03          	lw	s4,8(s0)
80002a30:	01452503          	lw	a0,20(a0)
80002a34:	00c2a303          	lw	t1,12(t0)
80002a38:	00088a93          	mv	s5,a7
80002a3c:	00080b13          	mv	s6,a6
80002a40:	00078b93          	mv	s7,a5
80002a44:	00070c13          	mv	s8,a4
80002a48:	00068c93          	mv	s9,a3
80002a4c:	000300e7          	jalr	t1
80002a50:	fc942623          	sw	s1,-52(s0)
80002a54:	fca40823          	sb	a0,-48(s0)
80002a58:	fc0408a3          	sb	zero,-47(s0)
80002a5c:	fcc40513          	addi	a0,s0,-52
80002a60:	000c8593          	mv	a1,s9
80002a64:	000c0613          	mv	a2,s8
80002a68:	000b8693          	mv	a3,s7
80002a6c:	000b0713          	mv	a4,s6
80002a70:	fffff097          	auipc	ra,0xfffff
80002a74:	3a4080e7          	jalr	932(ra) # 80001e14 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E>
80002a78:	fcc40513          	addi	a0,s0,-52
80002a7c:	000a8593          	mv	a1,s5
80002a80:	00090613          	mv	a2,s2
80002a84:	00098693          	mv	a3,s3
80002a88:	000a0713          	mv	a4,s4
80002a8c:	fffff097          	auipc	ra,0xfffff
80002a90:	388080e7          	jalr	904(ra) # 80001e14 <_ZN4core3fmt8builders11DebugStruct5field17ha8131389ebaa1b62E>
80002a94:	fd144603          	lbu	a2,-47(s0)
80002a98:	fd044583          	lbu	a1,-48(s0)
80002a9c:	00b66533          	or	a0,a2,a1
80002aa0:	04060a63          	beqz	a2,80002af4 <_ZN4core3fmt9Formatter26debug_struct_field2_finish17h8b989ef45de6295cE+0x10c>
80002aa4:	0015f593          	andi	a1,a1,1
80002aa8:	04059663          	bnez	a1,80002af4 <_ZN4core3fmt9Formatter26debug_struct_field2_finish17h8b989ef45de6295cE+0x10c>
80002aac:	fcc42503          	lw	a0,-52(s0)
80002ab0:	01c54583          	lbu	a1,28(a0)
80002ab4:	0045f593          	andi	a1,a1,4
80002ab8:	02059063          	bnez	a1,80002ad8 <_ZN4core3fmt9Formatter26debug_struct_field2_finish17h8b989ef45de6295cE+0xf0>
80002abc:	01852583          	lw	a1,24(a0)
80002ac0:	01452503          	lw	a0,20(a0)
80002ac4:	00c5a683          	lw	a3,12(a1)
80002ac8:	800045b7          	lui	a1,0x80004
80002acc:	77758593          	addi	a1,a1,1911 # 80004777 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.262>
80002ad0:	00200613          	li	a2,2
80002ad4:	01c0006f          	j	80002af0 <_ZN4core3fmt9Formatter26debug_struct_field2_finish17h8b989ef45de6295cE+0x108>
80002ad8:	01852583          	lw	a1,24(a0)
80002adc:	01452503          	lw	a0,20(a0)
80002ae0:	00c5a683          	lw	a3,12(a1)
80002ae4:	800045b7          	lui	a1,0x80004
80002ae8:	77658593          	addi	a1,a1,1910 # 80004776 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.261>
80002aec:	00100613          	li	a2,1
80002af0:	000680e7          	jalr	a3
80002af4:	00157513          	andi	a0,a0,1
80002af8:	03c12083          	lw	ra,60(sp)
80002afc:	03812403          	lw	s0,56(sp)
80002b00:	03412483          	lw	s1,52(sp)
80002b04:	03012903          	lw	s2,48(sp)
80002b08:	02c12983          	lw	s3,44(sp)
80002b0c:	02812a03          	lw	s4,40(sp)
80002b10:	02412a83          	lw	s5,36(sp)
80002b14:	02012b03          	lw	s6,32(sp)
80002b18:	01c12b83          	lw	s7,28(sp)
80002b1c:	01812c03          	lw	s8,24(sp)
80002b20:	01412c83          	lw	s9,20(sp)
80002b24:	04010113          	addi	sp,sp,64
80002b28:	00008067          	ret

80002b2c <_ZN4core3fmt17pointer_fmt_inner17h3a78f71d335c4ae6E>:
80002b2c:	f6010113          	addi	sp,sp,-160
80002b30:	08112e23          	sw	ra,156(sp)
80002b34:	08812c23          	sw	s0,152(sp)
80002b38:	08912a23          	sw	s1,148(sp)
80002b3c:	09212823          	sw	s2,144(sp)
80002b40:	09312623          	sw	s3,140(sp)
80002b44:	09412423          	sw	s4,136(sp)
80002b48:	0a010413          	addi	s0,sp,160
80002b4c:	00058493          	mv	s1,a1
80002b50:	01c5a903          	lw	s2,28(a1)
80002b54:	0005a983          	lw	s3,0(a1)
80002b58:	0045aa03          	lw	s4,4(a1)
80002b5c:	00497613          	andi	a2,s2,4
80002b60:	00090593          	mv	a1,s2
80002b64:	00060e63          	beqz	a2,80002b80 <_ZN4core3fmt17pointer_fmt_inner17h3a78f71d335c4ae6E+0x54>
80002b68:	00896593          	ori	a1,s2,8
80002b6c:	00099a63          	bnez	s3,80002b80 <_ZN4core3fmt17pointer_fmt_inner17h3a78f71d335c4ae6E+0x54>
80002b70:	00100613          	li	a2,1
80002b74:	00c4a023          	sw	a2,0(s1)
80002b78:	00a00613          	li	a2,10
80002b7c:	00c4a223          	sw	a2,4(s1)
80002b80:	00000793          	li	a5,0
80002b84:	0045e593          	ori	a1,a1,4
80002b88:	00b4ae23          	sw	a1,28(s1)
80002b8c:	fe740593          	addi	a1,s0,-25
80002b90:	00a00613          	li	a2,10
80002b94:	01c0006f          	j	80002bb0 <_ZN4core3fmt17pointer_fmt_inner17h3a78f71d335c4ae6E+0x84>
80002b98:	05768693          	addi	a3,a3,87
80002b9c:	00455513          	srli	a0,a0,0x4
80002ba0:	00d58023          	sb	a3,0(a1)
80002ba4:	00178793          	addi	a5,a5,1 # 110001 <.Lline_table_start2+0x10ec62>
80002ba8:	fff58593          	addi	a1,a1,-1
80002bac:	00050a63          	beqz	a0,80002bc0 <_ZN4core3fmt17pointer_fmt_inner17h3a78f71d335c4ae6E+0x94>
80002bb0:	00f57693          	andi	a3,a0,15
80002bb4:	fec6f2e3          	bgeu	a3,a2,80002b98 <_ZN4core3fmt17pointer_fmt_inner17h3a78f71d335c4ae6E+0x6c>
80002bb8:	03068693          	addi	a3,a3,48
80002bbc:	fe1ff06f          	j	80002b9c <_ZN4core3fmt17pointer_fmt_inner17h3a78f71d335c4ae6E+0x70>
80002bc0:	f6840513          	addi	a0,s0,-152
80002bc4:	40f50533          	sub	a0,a0,a5
80002bc8:	08050713          	addi	a4,a0,128
80002bcc:	80004637          	lui	a2,0x80004
80002bd0:	77960613          	addi	a2,a2,1913 # 80004779 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.289>
80002bd4:	00100593          	li	a1,1
80002bd8:	00200693          	li	a3,2
80002bdc:	00048513          	mv	a0,s1
80002be0:	fffff097          	auipc	ra,0xfffff
80002be4:	744080e7          	jalr	1860(ra) # 80002324 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E>
80002be8:	0134a023          	sw	s3,0(s1)
80002bec:	0144a223          	sw	s4,4(s1)
80002bf0:	0124ae23          	sw	s2,28(s1)
80002bf4:	09c12083          	lw	ra,156(sp)
80002bf8:	09812403          	lw	s0,152(sp)
80002bfc:	09412483          	lw	s1,148(sp)
80002c00:	09012903          	lw	s2,144(sp)
80002c04:	08c12983          	lw	s3,140(sp)
80002c08:	08812a03          	lw	s4,136(sp)
80002c0c:	0a010113          	addi	sp,sp,160
80002c10:	00008067          	ret

80002c14 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E>:
80002c14:	ff010113          	addi	sp,sp,-16
80002c18:	00112623          	sw	ra,12(sp)
80002c1c:	00812423          	sw	s0,8(sp)
80002c20:	01010413          	addi	s0,sp,16
80002c24:	00050613          	mv	a2,a0
80002c28:	00350513          	addi	a0,a0,3
80002c2c:	ffc57513          	andi	a0,a0,-4
80002c30:	40c502b3          	sub	t0,a0,a2
80002c34:	0255fc63          	bgeu	a1,t0,80002c6c <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x58>
80002c38:	00000513          	li	a0,0
80002c3c:	02058063          	beqz	a1,80002c5c <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x48>
80002c40:	00b605b3          	add	a1,a2,a1
80002c44:	00060683          	lb	a3,0(a2)
80002c48:	fc06a693          	slti	a3,a3,-64
80002c4c:	0016c693          	xori	a3,a3,1
80002c50:	00160613          	addi	a2,a2,1
80002c54:	00d50533          	add	a0,a0,a3
80002c58:	feb616e3          	bne	a2,a1,80002c44 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x30>
80002c5c:	00c12083          	lw	ra,12(sp)
80002c60:	00812403          	lw	s0,8(sp)
80002c64:	01010113          	addi	sp,sp,16
80002c68:	00008067          	ret
80002c6c:	405586b3          	sub	a3,a1,t0
80002c70:	0026d893          	srli	a7,a3,0x2
80002c74:	fc0882e3          	beqz	a7,80002c38 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x24>
80002c78:	005602b3          	add	t0,a2,t0
80002c7c:	0036f593          	andi	a1,a3,3
80002c80:	00c51663          	bne	a0,a2,80002c8c <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x78>
80002c84:	00000513          	li	a0,0
80002c88:	0200006f          	j	80002ca8 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x94>
80002c8c:	00000513          	li	a0,0
80002c90:	00060703          	lb	a4,0(a2)
80002c94:	fc072713          	slti	a4,a4,-64
80002c98:	00174713          	xori	a4,a4,1
80002c9c:	00160613          	addi	a2,a2,1
80002ca0:	00e50533          	add	a0,a0,a4
80002ca4:	fe5616e3          	bne	a2,t0,80002c90 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x7c>
80002ca8:	00000713          	li	a4,0
80002cac:	02058463          	beqz	a1,80002cd4 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0xc0>
80002cb0:	ffc6f613          	andi	a2,a3,-4
80002cb4:	00c28633          	add	a2,t0,a2
80002cb8:	00060683          	lb	a3,0(a2)
80002cbc:	fc06a693          	slti	a3,a3,-64
80002cc0:	0016c693          	xori	a3,a3,1
80002cc4:	00d70733          	add	a4,a4,a3
80002cc8:	fff58593          	addi	a1,a1,-1
80002ccc:	00160613          	addi	a2,a2,1
80002cd0:	fe0594e3          	bnez	a1,80002cb8 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0xa4>
80002cd4:	010105b7          	lui	a1,0x1010
80002cd8:	10158613          	addi	a2,a1,257 # 1010101 <.Lline_table_start2+0x100ed62>
80002cdc:	00ff05b7          	lui	a1,0xff0
80002ce0:	0ff58593          	addi	a1,a1,255 # ff00ff <.Lline_table_start2+0xfeed60>
80002ce4:	00a70533          	add	a0,a4,a0
80002ce8:	00400793          	li	a5,4
80002cec:	0340006f          	j	80002d20 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x10c>
80002cf0:	005702b3          	add	t0,a4,t0
80002cf4:	410688b3          	sub	a7,a3,a6
80002cf8:	00387313          	andi	t1,a6,3
80002cfc:	00b3fe33          	and	t3,t2,a1
80002d00:	0083d393          	srli	t2,t2,0x8
80002d04:	00b3f3b3          	and	t2,t2,a1
80002d08:	01c383b3          	add	t2,t2,t3
80002d0c:	01039e13          	slli	t3,t2,0x10
80002d10:	007e03b3          	add	t2,t3,t2
80002d14:	0103d393          	srli	t2,t2,0x10
80002d18:	00a38533          	add	a0,t2,a0
80002d1c:	0a031a63          	bnez	t1,80002dd0 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x1bc>
80002d20:	f2088ee3          	beqz	a7,80002c5c <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x48>
80002d24:	00088693          	mv	a3,a7
80002d28:	00028713          	mv	a4,t0
80002d2c:	0c000893          	li	a7,192
80002d30:	00068813          	mv	a6,a3
80002d34:	0116e463          	bltu	a3,a7,80002d3c <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x128>
80002d38:	0c000813          	li	a6,192
80002d3c:	00281293          	slli	t0,a6,0x2
80002d40:	00000393          	li	t2,0
80002d44:	faf6e6e3          	bltu	a3,a5,80002cf0 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0xdc>
80002d48:	3f02f893          	andi	a7,t0,1008
80002d4c:	011708b3          	add	a7,a4,a7
80002d50:	00070313          	mv	t1,a4
80002d54:	00032e03          	lw	t3,0(t1)
80002d58:	fffe4e93          	not	t4,t3
80002d5c:	007ede93          	srli	t4,t4,0x7
80002d60:	006e5e13          	srli	t3,t3,0x6
80002d64:	00432f03          	lw	t5,4(t1)
80002d68:	01ceee33          	or	t3,t4,t3
80002d6c:	00ce7e33          	and	t3,t3,a2
80002d70:	007e03b3          	add	t2,t3,t2
80002d74:	ffff4e13          	not	t3,t5
80002d78:	007e5e13          	srli	t3,t3,0x7
80002d7c:	00832e83          	lw	t4,8(t1)
80002d80:	006f5f13          	srli	t5,t5,0x6
80002d84:	01ee6e33          	or	t3,t3,t5
80002d88:	00ce7e33          	and	t3,t3,a2
80002d8c:	fffecf13          	not	t5,t4
80002d90:	007f5f13          	srli	t5,t5,0x7
80002d94:	006ede93          	srli	t4,t4,0x6
80002d98:	01df6eb3          	or	t4,t5,t4
80002d9c:	00c32f03          	lw	t5,12(t1)
80002da0:	00cefeb3          	and	t4,t4,a2
80002da4:	01ce8e33          	add	t3,t4,t3
80002da8:	007e03b3          	add	t2,t3,t2
80002dac:	ffff4e13          	not	t3,t5
80002db0:	007e5e13          	srli	t3,t3,0x7
80002db4:	006f5e93          	srli	t4,t5,0x6
80002db8:	01de6e33          	or	t3,t3,t4
80002dbc:	00ce7e33          	and	t3,t3,a2
80002dc0:	01030313          	addi	t1,t1,16
80002dc4:	007e03b3          	add	t2,t3,t2
80002dc8:	f91316e3          	bne	t1,a7,80002d54 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x140>
80002dcc:	f25ff06f          	j	80002cf0 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0xdc>
80002dd0:	00000793          	li	a5,0
80002dd4:	0fc87813          	andi	a6,a6,252
80002dd8:	00281813          	slli	a6,a6,0x2
80002ddc:	01070733          	add	a4,a4,a6
80002de0:	0c06b813          	sltiu	a6,a3,192
80002de4:	41000833          	neg	a6,a6
80002de8:	0106f6b3          	and	a3,a3,a6
80002dec:	0036f693          	andi	a3,a3,3
80002df0:	00269693          	slli	a3,a3,0x2
80002df4:	00072803          	lw	a6,0(a4)
80002df8:	00470713          	addi	a4,a4,4
80002dfc:	fff84893          	not	a7,a6
80002e00:	0078d893          	srli	a7,a7,0x7
80002e04:	00685813          	srli	a6,a6,0x6
80002e08:	0108e833          	or	a6,a7,a6
80002e0c:	00c87833          	and	a6,a6,a2
80002e10:	ffc68693          	addi	a3,a3,-4
80002e14:	00f807b3          	add	a5,a6,a5
80002e18:	fc069ee3          	bnez	a3,80002df4 <_ZN4core3str5count14do_count_chars17h4d10955e3b35bc93E+0x1e0>
80002e1c:	00b7f633          	and	a2,a5,a1
80002e20:	0087d793          	srli	a5,a5,0x8
80002e24:	00b7f5b3          	and	a1,a5,a1
80002e28:	00c585b3          	add	a1,a1,a2
80002e2c:	01059613          	slli	a2,a1,0x10
80002e30:	00b605b3          	add	a1,a2,a1
80002e34:	0105d593          	srli	a1,a1,0x10
80002e38:	00a58533          	add	a0,a1,a0
80002e3c:	00c12083          	lw	ra,12(sp)
80002e40:	00812403          	lw	s0,8(sp)
80002e44:	01010113          	addi	sp,sp,16
80002e48:	00008067          	ret

80002e4c <_ZN4core5alloc6layout6Layout19is_size_align_valid17hfcf08246f9a22341E>:
80002e4c:	ff010113          	addi	sp,sp,-16
80002e50:	00112623          	sw	ra,12(sp)
80002e54:	00812423          	sw	s0,8(sp)
80002e58:	01010413          	addi	s0,sp,16
80002e5c:	fff58613          	addi	a2,a1,-1
80002e60:	00c5c6b3          	xor	a3,a1,a2
80002e64:	02d67263          	bgeu	a2,a3,80002e88 <_ZN4core5alloc6layout6Layout19is_size_align_valid17hfcf08246f9a22341E+0x3c>
80002e68:	80000637          	lui	a2,0x80000
80002e6c:	40b60633          	sub	a2,a2,a1
80002e70:	00a63533          	sltu	a0,a2,a0
80002e74:	00154513          	xori	a0,a0,1
80002e78:	00c12083          	lw	ra,12(sp)
80002e7c:	00812403          	lw	s0,8(sp)
80002e80:	01010113          	addi	sp,sp,16
80002e84:	00008067          	ret
80002e88:	00000513          	li	a0,0
80002e8c:	00c12083          	lw	ra,12(sp)
80002e90:	00812403          	lw	s0,8(sp)
80002e94:	01010113          	addi	sp,sp,16
80002e98:	00008067          	ret

80002e9c <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E>:
80002e9c:	f7010113          	addi	sp,sp,-144
80002ea0:	08112623          	sw	ra,140(sp)
80002ea4:	08812423          	sw	s0,136(sp)
80002ea8:	09010413          	addi	s0,sp,144
80002eac:	00058813          	mv	a6,a1
80002eb0:	01c5a583          	lw	a1,28(a1)
80002eb4:	00052503          	lw	a0,0(a0)
80002eb8:	0105f613          	andi	a2,a1,16
80002ebc:	02061463          	bnez	a2,80002ee4 <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0x48>
80002ec0:	0205f593          	andi	a1,a1,32
80002ec4:	04059c63          	bnez	a1,80002f1c <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0x80>
80002ec8:	00100593          	li	a1,1
80002ecc:	00080613          	mv	a2,a6
80002ed0:	08c12083          	lw	ra,140(sp)
80002ed4:	08812403          	lw	s0,136(sp)
80002ed8:	09010113          	addi	sp,sp,144
80002edc:	00000317          	auipc	t1,0x0
80002ee0:	2e030067          	jr	736(t1) # 800031bc <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE>
80002ee4:	00000793          	li	a5,0
80002ee8:	ff740593          	addi	a1,s0,-9
80002eec:	00a00613          	li	a2,10
80002ef0:	01c0006f          	j	80002f0c <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0x70>
80002ef4:	05768693          	addi	a3,a3,87
80002ef8:	00455513          	srli	a0,a0,0x4
80002efc:	00d58023          	sb	a3,0(a1)
80002f00:	00178793          	addi	a5,a5,1
80002f04:	fff58593          	addi	a1,a1,-1
80002f08:	04050663          	beqz	a0,80002f54 <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0xb8>
80002f0c:	00f57693          	andi	a3,a0,15
80002f10:	fec6f2e3          	bgeu	a3,a2,80002ef4 <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0x58>
80002f14:	03068693          	addi	a3,a3,48
80002f18:	fe1ff06f          	j	80002ef8 <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0x5c>
80002f1c:	00000793          	li	a5,0
80002f20:	ff740593          	addi	a1,s0,-9
80002f24:	00a00613          	li	a2,10
80002f28:	01c0006f          	j	80002f44 <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0xa8>
80002f2c:	03768693          	addi	a3,a3,55
80002f30:	00455513          	srli	a0,a0,0x4
80002f34:	00d58023          	sb	a3,0(a1)
80002f38:	00178793          	addi	a5,a5,1
80002f3c:	fff58593          	addi	a1,a1,-1
80002f40:	00050a63          	beqz	a0,80002f54 <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0xb8>
80002f44:	00f57693          	andi	a3,a0,15
80002f48:	fec6f2e3          	bgeu	a3,a2,80002f2c <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0x90>
80002f4c:	03068693          	addi	a3,a3,48
80002f50:	fe1ff06f          	j	80002f30 <_ZN73_$LT$core..num..nonzero..NonZero$LT$T$GT$$u20$as$u20$core..fmt..Debug$GT$3fmt17h190a7880edc33533E+0x94>
80002f54:	f7840513          	addi	a0,s0,-136
80002f58:	40f50533          	sub	a0,a0,a5
80002f5c:	08050713          	addi	a4,a0,128
80002f60:	80004637          	lui	a2,0x80004
80002f64:	77960613          	addi	a2,a2,1913 # 80004779 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.289>
80002f68:	00100593          	li	a1,1
80002f6c:	00200693          	li	a3,2
80002f70:	00080513          	mv	a0,a6
80002f74:	fffff097          	auipc	ra,0xfffff
80002f78:	3b0080e7          	jalr	944(ra) # 80002324 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E>
80002f7c:	08c12083          	lw	ra,140(sp)
80002f80:	08812403          	lw	s0,136(sp)
80002f84:	09010113          	addi	sp,sp,144
80002f88:	00008067          	ret

80002f8c <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17hcc6fe785c9e9110eE>:
80002f8c:	f7010113          	addi	sp,sp,-144
80002f90:	08112623          	sw	ra,140(sp)
80002f94:	08812423          	sw	s0,136(sp)
80002f98:	09010413          	addi	s0,sp,144
80002f9c:	00052603          	lw	a2,0(a0)
80002fa0:	00058513          	mv	a0,a1
80002fa4:	00000793          	li	a5,0
80002fa8:	ff740593          	addi	a1,s0,-9
80002fac:	00a00693          	li	a3,10
80002fb0:	01c0006f          	j	80002fcc <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17hcc6fe785c9e9110eE+0x40>
80002fb4:	05770713          	addi	a4,a4,87
80002fb8:	00465613          	srli	a2,a2,0x4
80002fbc:	00e58023          	sb	a4,0(a1)
80002fc0:	00178793          	addi	a5,a5,1
80002fc4:	fff58593          	addi	a1,a1,-1
80002fc8:	00060a63          	beqz	a2,80002fdc <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17hcc6fe785c9e9110eE+0x50>
80002fcc:	00f67713          	andi	a4,a2,15
80002fd0:	fed772e3          	bgeu	a4,a3,80002fb4 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17hcc6fe785c9e9110eE+0x28>
80002fd4:	03070713          	addi	a4,a4,48
80002fd8:	fe1ff06f          	j	80002fb8 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17hcc6fe785c9e9110eE+0x2c>
80002fdc:	f7840593          	addi	a1,s0,-136
80002fe0:	40f585b3          	sub	a1,a1,a5
80002fe4:	08058713          	addi	a4,a1,128
80002fe8:	80004637          	lui	a2,0x80004
80002fec:	77960613          	addi	a2,a2,1913 # 80004779 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.289>
80002ff0:	00100593          	li	a1,1
80002ff4:	00200693          	li	a3,2
80002ff8:	fffff097          	auipc	ra,0xfffff
80002ffc:	32c080e7          	jalr	812(ra) # 80002324 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E>
80003000:	08c12083          	lw	ra,140(sp)
80003004:	08812403          	lw	s0,136(sp)
80003008:	09010113          	addi	sp,sp,144
8000300c:	00008067          	ret

80003010 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..UpperHex$u20$for$u20$i32$GT$3fmt17h8b16a5bc167e7410E>:
80003010:	f7010113          	addi	sp,sp,-144
80003014:	08112623          	sw	ra,140(sp)
80003018:	08812423          	sw	s0,136(sp)
8000301c:	09010413          	addi	s0,sp,144
80003020:	00052603          	lw	a2,0(a0)
80003024:	00058513          	mv	a0,a1
80003028:	00000793          	li	a5,0
8000302c:	ff740593          	addi	a1,s0,-9
80003030:	00a00693          	li	a3,10
80003034:	01c0006f          	j	80003050 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..UpperHex$u20$for$u20$i32$GT$3fmt17h8b16a5bc167e7410E+0x40>
80003038:	03770713          	addi	a4,a4,55
8000303c:	00465613          	srli	a2,a2,0x4
80003040:	00e58023          	sb	a4,0(a1)
80003044:	00178793          	addi	a5,a5,1
80003048:	fff58593          	addi	a1,a1,-1
8000304c:	00060a63          	beqz	a2,80003060 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..UpperHex$u20$for$u20$i32$GT$3fmt17h8b16a5bc167e7410E+0x50>
80003050:	00f67713          	andi	a4,a2,15
80003054:	fed772e3          	bgeu	a4,a3,80003038 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..UpperHex$u20$for$u20$i32$GT$3fmt17h8b16a5bc167e7410E+0x28>
80003058:	03070713          	addi	a4,a4,48
8000305c:	fe1ff06f          	j	8000303c <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..UpperHex$u20$for$u20$i32$GT$3fmt17h8b16a5bc167e7410E+0x2c>
80003060:	f7840593          	addi	a1,s0,-136
80003064:	40f585b3          	sub	a1,a1,a5
80003068:	08058713          	addi	a4,a1,128
8000306c:	80004637          	lui	a2,0x80004
80003070:	77960613          	addi	a2,a2,1913 # 80004779 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.289>
80003074:	00100593          	li	a1,1
80003078:	00200693          	li	a3,2
8000307c:	fffff097          	auipc	ra,0xfffff
80003080:	2a8080e7          	jalr	680(ra) # 80002324 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E>
80003084:	08c12083          	lw	ra,140(sp)
80003088:	08812403          	lw	s0,136(sp)
8000308c:	09010113          	addi	sp,sp,144
80003090:	00008067          	ret

80003094 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE>:
80003094:	f7010113          	addi	sp,sp,-144
80003098:	08112623          	sw	ra,140(sp)
8000309c:	08812423          	sw	s0,136(sp)
800030a0:	09010413          	addi	s0,sp,144
800030a4:	00058813          	mv	a6,a1
800030a8:	01c5a583          	lw	a1,28(a1)
800030ac:	0105f613          	andi	a2,a1,16
800030b0:	02061663          	bnez	a2,800030dc <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0x48>
800030b4:	0205f593          	andi	a1,a1,32
800030b8:	06059063          	bnez	a1,80003118 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0x84>
800030bc:	00052503          	lw	a0,0(a0)
800030c0:	00100593          	li	a1,1
800030c4:	00080613          	mv	a2,a6
800030c8:	08c12083          	lw	ra,140(sp)
800030cc:	08812403          	lw	s0,136(sp)
800030d0:	09010113          	addi	sp,sp,144
800030d4:	00000317          	auipc	t1,0x0
800030d8:	0e830067          	jr	232(t1) # 800031bc <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE>
800030dc:	00052503          	lw	a0,0(a0)
800030e0:	00000793          	li	a5,0
800030e4:	ff740593          	addi	a1,s0,-9
800030e8:	00a00613          	li	a2,10
800030ec:	01c0006f          	j	80003108 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0x74>
800030f0:	05768693          	addi	a3,a3,87
800030f4:	00455513          	srli	a0,a0,0x4
800030f8:	00d58023          	sb	a3,0(a1)
800030fc:	00178793          	addi	a5,a5,1
80003100:	fff58593          	addi	a1,a1,-1
80003104:	04050863          	beqz	a0,80003154 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0xc0>
80003108:	00f57693          	andi	a3,a0,15
8000310c:	fec6f2e3          	bgeu	a3,a2,800030f0 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0x5c>
80003110:	03068693          	addi	a3,a3,48
80003114:	fe1ff06f          	j	800030f4 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0x60>
80003118:	00052503          	lw	a0,0(a0)
8000311c:	00000793          	li	a5,0
80003120:	ff740593          	addi	a1,s0,-9
80003124:	00a00613          	li	a2,10
80003128:	01c0006f          	j	80003144 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0xb0>
8000312c:	03768693          	addi	a3,a3,55
80003130:	00455513          	srli	a0,a0,0x4
80003134:	00d58023          	sb	a3,0(a1)
80003138:	00178793          	addi	a5,a5,1
8000313c:	fff58593          	addi	a1,a1,-1
80003140:	00050a63          	beqz	a0,80003154 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0xc0>
80003144:	00f57693          	andi	a3,a0,15
80003148:	fec6f2e3          	bgeu	a3,a2,8000312c <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0x98>
8000314c:	03068693          	addi	a3,a3,48
80003150:	fe1ff06f          	j	80003130 <_ZN4core3fmt3num50_$LT$impl$u20$core..fmt..Debug$u20$for$u20$u32$GT$3fmt17h7eb5bbc22f53551eE+0x9c>
80003154:	f7840513          	addi	a0,s0,-136
80003158:	40f50533          	sub	a0,a0,a5
8000315c:	08050713          	addi	a4,a0,128
80003160:	80004637          	lui	a2,0x80004
80003164:	77960613          	addi	a2,a2,1913 # 80004779 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.289>
80003168:	00100593          	li	a1,1
8000316c:	00200693          	li	a3,2
80003170:	00080513          	mv	a0,a6
80003174:	fffff097          	auipc	ra,0xfffff
80003178:	1b0080e7          	jalr	432(ra) # 80002324 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E>
8000317c:	08c12083          	lw	ra,140(sp)
80003180:	08812403          	lw	s0,136(sp)
80003184:	09010113          	addi	sp,sp,144
80003188:	00008067          	ret

8000318c <_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17he9e9e363faaccf29E>:
8000318c:	ff010113          	addi	sp,sp,-16
80003190:	00112623          	sw	ra,12(sp)
80003194:	00812423          	sw	s0,8(sp)
80003198:	01010413          	addi	s0,sp,16
8000319c:	00052503          	lw	a0,0(a0)
800031a0:	00058613          	mv	a2,a1
800031a4:	00100593          	li	a1,1
800031a8:	00c12083          	lw	ra,12(sp)
800031ac:	00812403          	lw	s0,8(sp)
800031b0:	01010113          	addi	sp,sp,16
800031b4:	00000317          	auipc	t1,0x0
800031b8:	00830067          	jr	8(t1) # 800031bc <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE>

800031bc <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE>:
800031bc:	fe010113          	addi	sp,sp,-32
800031c0:	00112e23          	sw	ra,28(sp)
800031c4:	00812c23          	sw	s0,24(sp)
800031c8:	00912a23          	sw	s1,20(sp)
800031cc:	01212823          	sw	s2,16(sp)
800031d0:	02010413          	addi	s0,sp,32
800031d4:	00060693          	mv	a3,a2
800031d8:	00455793          	srli	a5,a0,0x4
800031dc:	00a00713          	li	a4,10
800031e0:	27100813          	li	a6,625
800031e4:	80004637          	lui	a2,0x80004
800031e8:	77b60613          	addi	a2,a2,1915 # 8000477b <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292>
800031ec:	0307f663          	bgeu	a5,a6,80003218 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE+0x5c>
800031f0:	06300793          	li	a5,99
800031f4:	0ca7ea63          	bltu	a5,a0,800032c8 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE+0x10c>
800031f8:	00a00793          	li	a5,10
800031fc:	12f57263          	bgeu	a0,a5,80003320 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE+0x164>
80003200:	fff70793          	addi	a5,a4,-1
80003204:	fe640613          	addi	a2,s0,-26
80003208:	00f60633          	add	a2,a2,a5
8000320c:	03056513          	ori	a0,a0,48
80003210:	00a60023          	sb	a0,0(a2)
80003214:	1300006f          	j	80003344 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE+0x188>
80003218:	00000713          	li	a4,0
8000321c:	fec40793          	addi	a5,s0,-20
80003220:	fee40813          	addi	a6,s0,-18
80003224:	d1b718b7          	lui	a7,0xd1b71
80003228:	75988893          	addi	a7,a7,1881 # d1b71759 <KALLOC_BUFFER+0x51b6b759>
8000322c:	000022b7          	lui	t0,0x2
80003230:	71028293          	addi	t0,t0,1808 # 2710 <.Lline_table_start2+0x1371>
80003234:	00001337          	lui	t1,0x1
80003238:	47b30313          	addi	t1,t1,1147 # 147b <.Lline_table_start2+0xdc>
8000323c:	06400393          	li	t2,100
80003240:	05f5ee37          	lui	t3,0x5f5e
80003244:	0ffe0e13          	addi	t3,t3,255 # 5f5e0ff <.Lline_table_start2+0x5f5cd60>
80003248:	00050e93          	mv	t4,a0
8000324c:	03153533          	mulhu	a0,a0,a7
80003250:	00d55513          	srli	a0,a0,0xd
80003254:	02550f33          	mul	t5,a0,t0
80003258:	41ee8f33          	sub	t5,t4,t5
8000325c:	010f1f93          	slli	t6,t5,0x10
80003260:	012fdf93          	srli	t6,t6,0x12
80003264:	026f8fb3          	mul	t6,t6,t1
80003268:	011fd493          	srli	s1,t6,0x11
8000326c:	010fdf93          	srli	t6,t6,0x10
80003270:	7fefff93          	andi	t6,t6,2046
80003274:	027484b3          	mul	s1,s1,t2
80003278:	409f0f33          	sub	t5,t5,s1
8000327c:	011f1f13          	slli	t5,t5,0x11
80003280:	01f60fb3          	add	t6,a2,t6
80003284:	001fc483          	lbu	s1,1(t6)
80003288:	010f5f13          	srli	t5,t5,0x10
8000328c:	00e78933          	add	s2,a5,a4
80003290:	000fcf83          	lbu	t6,0(t6)
80003294:	009900a3          	sb	s1,1(s2)
80003298:	01e60f33          	add	t5,a2,t5
8000329c:	001f4483          	lbu	s1,1(t5)
800032a0:	000f4f03          	lbu	t5,0(t5)
800032a4:	01f90023          	sb	t6,0(s2)
800032a8:	00e80fb3          	add	t6,a6,a4
800032ac:	009f80a3          	sb	s1,1(t6)
800032b0:	01ef8023          	sb	t5,0(t6)
800032b4:	ffc70713          	addi	a4,a4,-4
800032b8:	f9de68e3          	bltu	t3,t4,80003248 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE+0x8c>
800032bc:	00a70713          	addi	a4,a4,10
800032c0:	06300793          	li	a5,99
800032c4:	f2a7fae3          	bgeu	a5,a0,800031f8 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE+0x3c>
800032c8:	01051793          	slli	a5,a0,0x10
800032cc:	0127d793          	srli	a5,a5,0x12
800032d0:	00001837          	lui	a6,0x1
800032d4:	47b80813          	addi	a6,a6,1147 # 147b <.Lline_table_start2+0xdc>
800032d8:	030787b3          	mul	a5,a5,a6
800032dc:	0117d793          	srli	a5,a5,0x11
800032e0:	06400813          	li	a6,100
800032e4:	03078833          	mul	a6,a5,a6
800032e8:	41050533          	sub	a0,a0,a6
800032ec:	01151513          	slli	a0,a0,0x11
800032f0:	01055513          	srli	a0,a0,0x10
800032f4:	ffe70713          	addi	a4,a4,-2
800032f8:	00a60533          	add	a0,a2,a0
800032fc:	00154803          	lbu	a6,1(a0)
80003300:	00054503          	lbu	a0,0(a0)
80003304:	fe640893          	addi	a7,s0,-26
80003308:	00e888b3          	add	a7,a7,a4
8000330c:	010880a3          	sb	a6,1(a7)
80003310:	00a88023          	sb	a0,0(a7)
80003314:	00078513          	mv	a0,a5
80003318:	00a00793          	li	a5,10
8000331c:	eef562e3          	bltu	a0,a5,80003200 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17hdc3b05787bb19fdaE+0x44>
80003320:	00151513          	slli	a0,a0,0x1
80003324:	ffe70793          	addi	a5,a4,-2
80003328:	00a60533          	add	a0,a2,a0
8000332c:	00154603          	lbu	a2,1(a0)
80003330:	00054503          	lbu	a0,0(a0)
80003334:	fe640713          	addi	a4,s0,-26
80003338:	00f70733          	add	a4,a4,a5
8000333c:	00c700a3          	sb	a2,1(a4)
80003340:	00a70023          	sb	a0,0(a4)
80003344:	fe640713          	addi	a4,s0,-26
80003348:	00f70733          	add	a4,a4,a5
8000334c:	00a00513          	li	a0,10
80003350:	40f507b3          	sub	a5,a0,a5
80003354:	00100613          	li	a2,1
80003358:	00068513          	mv	a0,a3
8000335c:	00000693          	li	a3,0
80003360:	fffff097          	auipc	ra,0xfffff
80003364:	fc4080e7          	jalr	-60(ra) # 80002324 <_ZN4core3fmt9Formatter12pad_integral17h031df5456fc12874E>
80003368:	01c12083          	lw	ra,28(sp)
8000336c:	01812403          	lw	s0,24(sp)
80003370:	01412483          	lw	s1,20(sp)
80003374:	01012903          	lw	s2,16(sp)
80003378:	02010113          	addi	sp,sp,32
8000337c:	00008067          	ret

80003380 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h2421b7a3a4e2e164E>:
80003380:	ff010113          	addi	sp,sp,-16
80003384:	00112623          	sw	ra,12(sp)
80003388:	00812423          	sw	s0,8(sp)
8000338c:	01010413          	addi	s0,sp,16
80003390:	00452603          	lw	a2,4(a0)
80003394:	00052503          	lw	a0,0(a0)
80003398:	00c62303          	lw	t1,12(a2)
8000339c:	00c12083          	lw	ra,12(sp)
800033a0:	00812403          	lw	s0,8(sp)
800033a4:	01010113          	addi	sp,sp,16
800033a8:	00030067          	jr	t1

800033ac <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17h03d1090a3af591adE>:
800033ac:	ff010113          	addi	sp,sp,-16
800033b0:	00112623          	sw	ra,12(sp)
800033b4:	00812423          	sw	s0,8(sp)
800033b8:	01010413          	addi	s0,sp,16
800033bc:	00052683          	lw	a3,0(a0)
800033c0:	00452603          	lw	a2,4(a0)
800033c4:	00058513          	mv	a0,a1
800033c8:	00068593          	mv	a1,a3
800033cc:	00c12083          	lw	ra,12(sp)
800033d0:	00812403          	lw	s0,8(sp)
800033d4:	01010113          	addi	sp,sp,16
800033d8:	fffff317          	auipc	t1,0xfffff
800033dc:	34c30067          	jr	844(t1) # 80002724 <_ZN4core3fmt9Formatter3pad17h5337212874eb5ea5E>

800033e0 <memset>:
800033e0:	ff010113          	addi	sp,sp,-16
800033e4:	00112623          	sw	ra,12(sp)
800033e8:	00812423          	sw	s0,8(sp)
800033ec:	01010413          	addi	s0,sp,16
800033f0:	01000693          	li	a3,16
800033f4:	08d66263          	bltu	a2,a3,80003478 <memset+0x98>
800033f8:	40a006b3          	neg	a3,a0
800033fc:	0036f693          	andi	a3,a3,3
80003400:	00d50733          	add	a4,a0,a3
80003404:	00e57e63          	bgeu	a0,a4,80003420 <memset+0x40>
80003408:	00068793          	mv	a5,a3
8000340c:	00050813          	mv	a6,a0
80003410:	00b80023          	sb	a1,0(a6)
80003414:	fff78793          	addi	a5,a5,-1
80003418:	00180813          	addi	a6,a6,1
8000341c:	fe079ae3          	bnez	a5,80003410 <memset+0x30>
80003420:	40d60633          	sub	a2,a2,a3
80003424:	ffc67693          	andi	a3,a2,-4
80003428:	00d706b3          	add	a3,a4,a3
8000342c:	02d77063          	bgeu	a4,a3,8000344c <memset+0x6c>
80003430:	0ff5f793          	zext.b	a5,a1
80003434:	01010837          	lui	a6,0x1010
80003438:	10180813          	addi	a6,a6,257 # 1010101 <.Lline_table_start2+0x100ed62>
8000343c:	030787b3          	mul	a5,a5,a6
80003440:	00f72023          	sw	a5,0(a4)
80003444:	00470713          	addi	a4,a4,4
80003448:	fed76ce3          	bltu	a4,a3,80003440 <memset+0x60>
8000344c:	00367613          	andi	a2,a2,3
80003450:	00c68733          	add	a4,a3,a2
80003454:	00e6fa63          	bgeu	a3,a4,80003468 <memset+0x88>
80003458:	00b68023          	sb	a1,0(a3)
8000345c:	fff60613          	addi	a2,a2,-1
80003460:	00168693          	addi	a3,a3,1
80003464:	fe061ae3          	bnez	a2,80003458 <memset+0x78>
80003468:	00c12083          	lw	ra,12(sp)
8000346c:	00812403          	lw	s0,8(sp)
80003470:	01010113          	addi	sp,sp,16
80003474:	00008067          	ret
80003478:	00050693          	mv	a3,a0
8000347c:	00c50733          	add	a4,a0,a2
80003480:	fce56ce3          	bltu	a0,a4,80003458 <memset+0x78>
80003484:	fe5ff06f          	j	80003468 <memset+0x88>

80003488 <memcpy>:
80003488:	ff010113          	addi	sp,sp,-16
8000348c:	00112623          	sw	ra,12(sp)
80003490:	00812423          	sw	s0,8(sp)
80003494:	01010413          	addi	s0,sp,16
80003498:	01000693          	li	a3,16
8000349c:	08d66063          	bltu	a2,a3,8000351c <memcpy+0x94>
800034a0:	40a006b3          	neg	a3,a0
800034a4:	0036f693          	andi	a3,a3,3
800034a8:	00d50733          	add	a4,a0,a3
800034ac:	02e57463          	bgeu	a0,a4,800034d4 <memcpy+0x4c>
800034b0:	00068793          	mv	a5,a3
800034b4:	00050813          	mv	a6,a0
800034b8:	00058893          	mv	a7,a1
800034bc:	0008c283          	lbu	t0,0(a7)
800034c0:	00580023          	sb	t0,0(a6)
800034c4:	00180813          	addi	a6,a6,1
800034c8:	fff78793          	addi	a5,a5,-1
800034cc:	00188893          	addi	a7,a7,1
800034d0:	fe0796e3          	bnez	a5,800034bc <memcpy+0x34>
800034d4:	00d585b3          	add	a1,a1,a3
800034d8:	40d60633          	sub	a2,a2,a3
800034dc:	ffc67793          	andi	a5,a2,-4
800034e0:	0035f813          	andi	a6,a1,3
800034e4:	00f706b3          	add	a3,a4,a5
800034e8:	06081463          	bnez	a6,80003550 <memcpy+0xc8>
800034ec:	00d77e63          	bgeu	a4,a3,80003508 <memcpy+0x80>
800034f0:	00058813          	mv	a6,a1
800034f4:	00082883          	lw	a7,0(a6)
800034f8:	01172023          	sw	a7,0(a4)
800034fc:	00470713          	addi	a4,a4,4
80003500:	00480813          	addi	a6,a6,4
80003504:	fed768e3          	bltu	a4,a3,800034f4 <memcpy+0x6c>
80003508:	00f585b3          	add	a1,a1,a5
8000350c:	00367613          	andi	a2,a2,3
80003510:	00c68733          	add	a4,a3,a2
80003514:	00e6ea63          	bltu	a3,a4,80003528 <memcpy+0xa0>
80003518:	0280006f          	j	80003540 <memcpy+0xb8>
8000351c:	00050693          	mv	a3,a0
80003520:	00c50733          	add	a4,a0,a2
80003524:	00e57e63          	bgeu	a0,a4,80003540 <memcpy+0xb8>
80003528:	0005c703          	lbu	a4,0(a1)
8000352c:	00e68023          	sb	a4,0(a3)
80003530:	00168693          	addi	a3,a3,1
80003534:	fff60613          	addi	a2,a2,-1
80003538:	00158593          	addi	a1,a1,1
8000353c:	fe0616e3          	bnez	a2,80003528 <memcpy+0xa0>
80003540:	00c12083          	lw	ra,12(sp)
80003544:	00812403          	lw	s0,8(sp)
80003548:	01010113          	addi	sp,sp,16
8000354c:	00008067          	ret
80003550:	fad77ce3          	bgeu	a4,a3,80003508 <memcpy+0x80>
80003554:	00359893          	slli	a7,a1,0x3
80003558:	0188f813          	andi	a6,a7,24
8000355c:	ffc5f293          	andi	t0,a1,-4
80003560:	0002a303          	lw	t1,0(t0)
80003564:	411008b3          	neg	a7,a7
80003568:	0188f893          	andi	a7,a7,24
8000356c:	00428293          	addi	t0,t0,4
80003570:	0002a383          	lw	t2,0(t0)
80003574:	01035333          	srl	t1,t1,a6
80003578:	01139e33          	sll	t3,t2,a7
8000357c:	006e6333          	or	t1,t3,t1
80003580:	00672023          	sw	t1,0(a4)
80003584:	00470713          	addi	a4,a4,4
80003588:	00428293          	addi	t0,t0,4
8000358c:	00038313          	mv	t1,t2
80003590:	fed760e3          	bltu	a4,a3,80003570 <memcpy+0xe8>
80003594:	f75ff06f          	j	80003508 <memcpy+0x80>
	...

Disassembly of section .rodata:

80004000 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.4>:
80004000:	0000                	.insn	2, 0x
80004002:	0000                	.insn	2, 0x
80004004:	0004                	.insn	2, 0x0004
80004006:	0000                	.insn	2, 0x
80004008:	0004                	.insn	2, 0x0004
8000400a:	0000                	.insn	2, 0x
8000400c:	01d4                	.insn	2, 0x01d4
8000400e:	8000                	.insn	2, 0x8000

80004010 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.5>:
80004010:	0000                	.insn	2, 0x
80004012:	0000                	.insn	2, 0x
80004014:	0004                	.insn	2, 0x0004
80004016:	0000                	.insn	2, 0x
80004018:	0004                	.insn	2, 0x0004
8000401a:	0000                	.insn	2, 0x
8000401c:	1054                	.insn	2, 0x1054
8000401e:	8000                	.insn	2, 0x8000

80004020 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.6>:
80004020:	614c                	.insn	2, 0x614c
80004022:	6f79                	.insn	2, 0x6f79
80004024:	7475                	.insn	2, 0x7475
80004026:	2020                	.insn	2, 0x2020
80004028:	2020                	.insn	2, 0x2020
8000402a:	657a6973          	.insn	4, 0x657a6973

8000402e <.Lanon.10e9e605f29f28b577aacdba1819c9a4.8>:
8000402e:	6c61                	.insn	2, 0x6c61
80004030:	6769                	.insn	2, 0x6769
80004032:	                	.insn	2, 0x4c6e

80004033 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.9>:
80004033:	614c                	.insn	2, 0x614c
80004035:	6f79                	.insn	2, 0x6f79
80004037:	7475                	.insn	2, 0x7475
80004039:	7245                	.insn	2, 0x7245
8000403b:	6f72                	.insn	2, 0x6f72
8000403d:	                	.insn	2, 0x4972

8000403e <.Lanon.10e9e605f29f28b577aacdba1819c9a4.10>:
8000403e:	6e49                	.insn	2, 0x6e49
80004040:	75727473          	.insn	4, 0x75727473
80004044:	6f697463          	bgeu	s2,s6,8000472c <.Lanon.0a795d8d80343cc40e42ade3e02d1552.249+0xc>
80004048:	4d6e                	.insn	2, 0x4d6e
8000404a:	7369                	.insn	2, 0x7369
8000404c:	6c61                	.insn	2, 0x6c61
8000404e:	6769                	.insn	2, 0x6769
80004050:	656e                	.insn	2, 0x656e
80004052:	0064                	.insn	2, 0x0064
80004054:	7361                	.insn	2, 0x7361
80004056:	74726573          	.insn	4, 0x74726573
8000405a:	6f69                	.insn	2, 0x6f69
8000405c:	206e                	.insn	2, 0x206e
8000405e:	6c60                	.insn	2, 0x6c60
80004060:	6665                	.insn	2, 0x6665
80004062:	2074                	.insn	2, 0x2074
80004064:	6e49                	.insn	2, 0x6e49
80004066:	75727473          	.insn	4, 0x75727473
8000406a:	6f697463          	bgeu	s2,s6,80004752 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.251+0xe>
8000406e:	466e                	.insn	2, 0x466e
80004070:	7561                	.insn	2, 0x7561
80004072:	746c                	.insn	2, 0x746c
80004074:	0100                	.insn	2, 0x0100
80004076:	0302                	.insn	2, 0x0302
80004078:	0504                	.insn	2, 0x0504
8000407a:	0706                	.insn	2, 0x0706
8000407c:	0908                	.insn	2, 0x0908
8000407e:	0a0e                	.insn	2, 0x0a0e
80004080:	0d0e0c0b          	.insn	4, 0x0d0e0c0b
80004084:	7220                	.insn	2, 0x7220
80004086:	6769                	.insn	2, 0x6769
80004088:	7468                	.insn	2, 0x7468
8000408a:	2060                	.insn	2, 0x2060
8000408c:	6166                	.insn	2, 0x6166
8000408e:	6c69                	.insn	2, 0x6c69
80004090:	6465                	.insn	2, 0x6465
80004092:	203a                	.insn	2, 0x203a

80004094 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.12>:
80004094:	6c49                	.insn	2, 0x6c49
80004096:	656c                	.insn	2, 0x656c
80004098:	496c6167          	.insn	4, 0x496c6167
8000409c:	736e                	.insn	2, 0x736e
8000409e:	7274                	.insn	2, 0x7274
800040a0:	6375                	.insn	2, 0x6375
800040a2:	6974                	.insn	2, 0x6974
800040a4:	          	jal	t3,8002a7c8 <KALLOC_BUFFER+0x247c8>

800040a6 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.13>:
800040a6:	7242                	.insn	2, 0x7242
800040a8:	6165                	.insn	2, 0x6165
800040aa:	696f706b          	.insn	4, 0x696f706b
800040ae:	746e                	.insn	2, 0x746e

800040b0 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.14>:
800040b0:	6f4c                	.insn	2, 0x6f4c
800040b2:	6461                	.insn	2, 0x6461
800040b4:	694d                	.insn	2, 0x694d
800040b6:	696c6173          	.insn	4, 0x696c6173
800040ba:	64656e67          	.insn	4, 0x64656e67

800040be <.Lanon.10e9e605f29f28b577aacdba1819c9a4.15>:
800040be:	6f4c                	.insn	2, 0x6f4c
800040c0:	6461                	.insn	2, 0x6461
800040c2:	6146                	.insn	2, 0x6146
800040c4:	6c75                	.insn	2, 0x6c75
800040c6:	                	.insn	2, 0x5374

800040c7 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.16>:
800040c7:	726f7453          	.insn	4, 0x726f7453
800040cb:	4d65                	.insn	2, 0x4d65
800040cd:	7369                	.insn	2, 0x7369
800040cf:	6c61                	.insn	2, 0x6c61
800040d1:	6769                	.insn	2, 0x6769
800040d3:	656e                	.insn	2, 0x656e
800040d5:	                	.insn	2, 0x5364

800040d6 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.17>:
800040d6:	726f7453          	.insn	4, 0x726f7453
800040da:	4665                	.insn	2, 0x4665
800040dc:	7561                	.insn	2, 0x7561
800040de:	746c                	.insn	2, 0x746c

800040e0 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.18>:
800040e0:	7355                	.insn	2, 0x7355
800040e2:	7265                	.insn	2, 0x7265
800040e4:	6e45                	.insn	2, 0x6e45
800040e6:	4376                	.insn	2, 0x4376
800040e8:	6c61                	.insn	2, 0x6c61
800040ea:	                	.insn	2, 0x536c

800040eb <.Lanon.10e9e605f29f28b577aacdba1819c9a4.19>:
800040eb:	65707553          	.insn	4, 0x65707553
800040ef:	7672                	.insn	2, 0x7672
800040f1:	7369                	.insn	2, 0x7369
800040f3:	6e45726f          	jal	tp,8005b7d7 <KALLOC_BUFFER+0x557d7>
800040f7:	4376                	.insn	2, 0x4376
800040f9:	6c61                	.insn	2, 0x6c61
800040fb:	                	.insn	2, 0x4d6c

800040fc <.Lanon.10e9e605f29f28b577aacdba1819c9a4.20>:
800040fc:	614d                	.insn	2, 0x614d
800040fe:	6e696863          	bltu	s2,t1,800047ee <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292+0x73>
80004102:	4565                	.insn	2, 0x4565
80004104:	766e                	.insn	2, 0x766e
80004106:	6c6c6143          	.insn	4, 0x6c6c6143

8000410a <.Lanon.10e9e605f29f28b577aacdba1819c9a4.21>:
8000410a:	6e49                	.insn	2, 0x6e49
8000410c:	75727473          	.insn	4, 0x75727473
80004110:	6f697463          	bgeu	s2,s6,800047f8 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292+0x7d>
80004114:	506e                	.insn	2, 0x506e
80004116:	6761                	.insn	2, 0x6761
80004118:	4665                	.insn	2, 0x4665
8000411a:	7561                	.insn	2, 0x7561
8000411c:	746c                	.insn	2, 0x746c

8000411e <.Lanon.10e9e605f29f28b577aacdba1819c9a4.22>:
8000411e:	6f4c                	.insn	2, 0x6f4c
80004120:	6461                	.insn	2, 0x6461
80004122:	6150                	.insn	2, 0x6150
80004124:	61466567          	.insn	4, 0x61466567
80004128:	6c75                	.insn	2, 0x6c75
8000412a:	                	.insn	2, 0x5374

8000412b <.Lanon.10e9e605f29f28b577aacdba1819c9a4.23>:
8000412b:	726f7453          	.insn	4, 0x726f7453
8000412f:	5065                	.insn	2, 0x5065
80004131:	6761                	.insn	2, 0x6761
80004133:	4665                	.insn	2, 0x4665
80004135:	7561                	.insn	2, 0x7561
80004137:	746c                	.insn	2, 0x746c

80004139 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.24>:
80004139:	6e55                	.insn	2, 0x6e55
8000413b:	776f6e6b          	.insn	4, 0x776f6e6b
8000413f:	                	.insn	2, 0x6d6e

80004140 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.27>:
80004140:	636d                	.insn	2, 0x636d
80004142:	7561                	.insn	2, 0x7561
80004144:	203a6573          	.insn	4, 0x203a6573
80004148:	7865                	.insn	2, 0x7865
8000414a:	74706563          	bltu	zero,t2,80004894 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292+0x119>
8000414e:	6f69                	.insn	2, 0x6f69
80004150:	206e                	.insn	2, 0x206e
80004152:	7461                	.insn	2, 0x7461
80004154:	                	.insn	2, 0x2020

80004155 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.28>:
80004155:	                	.insn	2, 0x0a20

80004156 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.29>:
80004156:	000a                	.insn	2, 0x000a

80004158 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.30>:
80004158:	4140                	.insn	2, 0x4140
8000415a:	8000                	.insn	2, 0x8000
8000415c:	0015                	.insn	2, 0x0015
8000415e:	0000                	.insn	2, 0x
80004160:	4155                	.insn	2, 0x4155
80004162:	8000                	.insn	2, 0x8000
80004164:	0001                	.insn	2, 0x0001
80004166:	0000                	.insn	2, 0x
80004168:	4156                	.insn	2, 0x4156
8000416a:	8000                	.insn	2, 0x8000
8000416c:	0001                	.insn	2, 0x0001
	...

80004170 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.31>:
80004170:	2f637273          	.insn	4, 0x2f637273
80004174:	6f68                	.insn	2, 0x6f68
80004176:	656c                	.insn	2, 0x656c
80004178:	722e                	.insn	2, 0x722e
8000417a:	          	.insn	4, 0x696c6173

8000417b <.Lanon.10e9e605f29f28b577aacdba1819c9a4.32>:
8000417b:	6c61                	.insn	2, 0x6c61
8000417d:	6769                	.insn	2, 0x6769
8000417f:	5f6e                	.insn	2, 0x5f6e
80004181:	7366666f          	jal	a2,8006a8b7 <KALLOC_BUFFER+0x648b7>
80004185:	7465                	.insn	2, 0x7465
80004187:	203a                	.insn	2, 0x203a
80004189:	6c61                	.insn	2, 0x6c61
8000418b:	6769                	.insn	2, 0x6769
8000418d:	206e                	.insn	2, 0x206e
8000418f:	7369                	.insn	2, 0x7369
80004191:	6e20                	.insn	2, 0x6e20
80004193:	6120746f          	jal	s0,8000b7a5 <KALLOC_BUFFER+0x57a5>
80004197:	7020                	.insn	2, 0x7020
80004199:	7265776f          	jal	a4,8005b8bf <KALLOC_BUFFER+0x558bf>
8000419d:	6f2d                	.insn	2, 0x6f2d
8000419f:	2d66                	.insn	2, 0x2d66
800041a1:	7774                	.insn	2, 0x7774
800041a3:	          	jal	s6,8001b1a7 <KALLOC_BUFFER+0x151a7>

800041a4 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.33>:
800041a4:	8000417b          	.insn	4, 0x8000417b
800041a8:	0029                	.insn	2, 0x0029
	...

800041ac <.Lanon.10e9e605f29f28b577aacdba1819c9a4.34>:
800041ac:	6d6f682f          	.insn	4, 0x6d6f682f
800041b0:	2f65                	.insn	2, 0x2f65
800041b2:	6572                	.insn	2, 0x6572
800041b4:	796d                	.insn	2, 0x796d
800041b6:	75722e2f          	.insn	4, 0x75722e2f
800041ba:	70757473          	.insn	4, 0x70757473
800041be:	6f6f742f          	.insn	4, 0x6f6f742f
800041c2:	636c                	.insn	2, 0x636c
800041c4:	6168                	.insn	2, 0x6168
800041c6:	6e69                	.insn	2, 0x6e69
800041c8:	696e2f73          	.insn	4, 0x696e2f73
800041cc:	6c746867          	.insn	4, 0x6c746867
800041d0:	2d79                	.insn	2, 0x2d79
800041d2:	3878                	.insn	2, 0x3878
800041d4:	5f36                	.insn	2, 0x5f36
800041d6:	3436                	.insn	2, 0x3436
800041d8:	752d                	.insn	2, 0x752d
800041da:	6b6e                	.insn	2, 0x6b6e
800041dc:	6f6e                	.insn	2, 0x6f6e
800041de:	6c2d6e77          	.insn	4, 0x6c2d6e77
800041e2:	6e69                	.insn	2, 0x6e69
800041e4:	7875                	.insn	2, 0x7875
800041e6:	672d                	.insn	2, 0x672d
800041e8:	756e                	.insn	2, 0x756e
800041ea:	62696c2f          	.insn	4, 0x62696c2f
800041ee:	7375722f          	.insn	4, 0x7375722f
800041f2:	6c74                	.insn	2, 0x6c74
800041f4:	6269                	.insn	2, 0x6269
800041f6:	6372732f          	.insn	4, 0x6372732f
800041fa:	7375722f          	.insn	4, 0x7375722f
800041fe:	2f74                	.insn	2, 0x2f74
80004200:	696c                	.insn	2, 0x696c
80004202:	7262                	.insn	2, 0x7262
80004204:	7261                	.insn	2, 0x7261
80004206:	2f79                	.insn	2, 0x2f79
80004208:	65726f63          	bltu	tp,s7,80004866 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292+0xeb>
8000420c:	6372732f          	.insn	4, 0x6372732f
80004210:	7274702f          	.insn	4, 0x7274702f
80004214:	74756d2f          	.insn	4, 0x74756d2f
80004218:	705f 7274 722e      	.insn	6, 0x722e7274705f
8000421e:	          	.insn	4, 0x41ac0073

80004220 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.35>:
80004220:	41ac                	.insn	2, 0x41ac
80004222:	8000                	.insn	2, 0x8000
80004224:	00000073          	ecall
80004228:	0666                	.insn	2, 0x0666
8000422a:	0000                	.insn	2, 0x
8000422c:	000d                	.insn	2, 0x000d
	...

80004230 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.36>:
80004230:	7361                	.insn	2, 0x7361
80004232:	74726573          	.insn	4, 0x74726573
80004236:	6f69                	.insn	2, 0x6f69
80004238:	206e                	.insn	2, 0x206e
8000423a:	6166                	.insn	2, 0x6166
8000423c:	6c69                	.insn	2, 0x6c69
8000423e:	6465                	.insn	2, 0x6465
80004240:	203a                	.insn	2, 0x203a
80004242:	6c61                	.insn	2, 0x6c61
80004244:	6769                	.insn	2, 0x6769
80004246:	656e                	.insn	2, 0x656e
80004248:	5f64                	.insn	2, 0x5f64
8000424a:	6f68                	.insn	2, 0x6f68
8000424c:	656c                	.insn	2, 0x656c
8000424e:	735f 7a69 2065      	.insn	6, 0x20657a69735f
80004254:	3d3e                	.insn	2, 0x3d3e
80004256:	7320                	.insn	2, 0x7320
80004258:	7a69                	.insn	2, 0x7a69
8000425a:	5f65                	.insn	2, 0x5f65
8000425c:	3a3a666f          	jal	a2,800aadfe <KALLOC_BUFFER+0xa4dfe>
80004260:	483c                	.insn	2, 0x483c
80004262:	3e656c6f          	jal	s8,8005a648 <KALLOC_BUFFER+0x54648>
80004266:	2928                	.insn	2, 0x2928

80004268 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.37>:
80004268:	4170                	.insn	2, 0x4170
8000426a:	8000                	.insn	2, 0x8000
8000426c:	0000000b          	.insn	4, 0x000b
80004270:	0162                	.insn	2, 0x0162
80004272:	0000                	.insn	2, 0x
80004274:	0009                	.insn	2, 0x0009
	...

80004278 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.38>:
80004278:	4170                	.insn	2, 0x4170
8000427a:	8000                	.insn	2, 0x8000
8000427c:	0000000b          	.insn	4, 0x000b
80004280:	016a                	.insn	2, 0x016a
80004282:	0000                	.insn	2, 0x
80004284:	0009                	.insn	2, 0x0009
	...

80004288 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.39>:
	...
80004290:	0001                	.insn	2, 0x0001
80004292:	0000                	.insn	2, 0x
80004294:	0270                	.insn	2, 0x0270
80004296:	8000                	.insn	2, 0x8000

80004298 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.40>:
80004298:	6c6c6163          	bltu	s8,t1,8000495a <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292+0x1df>
8000429c:	6465                	.insn	2, 0x6465
8000429e:	6020                	.insn	2, 0x6020
800042a0:	6552                	.insn	2, 0x6552
800042a2:	746c7573          	.insn	4, 0x746c7573
800042a6:	3a3a                	.insn	2, 0x3a3a
800042a8:	6e75                	.insn	2, 0x6e75
800042aa:	70617277          	.insn	4, 0x70617277
800042ae:	2928                	.insn	2, 0x2928
800042b0:	2060                	.insn	2, 0x2060
800042b2:	61206e6f          	jal	t3,8000a8c4 <KALLOC_BUFFER+0x48c4>
800042b6:	206e                	.insn	2, 0x206e
800042b8:	4560                	.insn	2, 0x4560
800042ba:	7272                	.insn	2, 0x7272
800042bc:	2060                	.insn	2, 0x2060
800042be:	6176                	.insn	2, 0x6176
800042c0:	756c                	.insn	2, 0x756c
800042c2:	0065                	.insn	2, 0x0065

800042c4 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.41>:
800042c4:	4170                	.insn	2, 0x4170
800042c6:	8000                	.insn	2, 0x8000
800042c8:	0000000b          	.insn	4, 0x000b
800042cc:	01b8                	.insn	2, 0x01b8
800042ce:	0000                	.insn	2, 0x
800042d0:	0039                	.insn	2, 0x0039
	...

800042d4 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.42>:
800042d4:	7246                	.insn	2, 0x7246
800042d6:	6565                	.insn	2, 0x6565
800042d8:	2064                	.insn	2, 0x2064
800042da:	6f6e                	.insn	2, 0x6f6e
800042dc:	6564                	.insn	2, 0x6564
800042de:	6120                	.insn	2, 0x6120
800042e0:	696c                	.insn	2, 0x696c
800042e2:	7361                	.insn	2, 0x7361
800042e4:	7365                	.insn	2, 0x7365
800042e6:	6520                	.insn	2, 0x6520
800042e8:	6978                	.insn	2, 0x6978
800042ea:	6e697473          	.insn	4, 0x6e697473
800042ee:	6f682067          	.insn	4, 0x6f682067
800042f2:	656c                	.insn	2, 0x656c
800042f4:	2021                	.insn	2, 0x2021
800042f6:	6142                	.insn	2, 0x6142
800042f8:	2064                	.insn	2, 0x2064
800042fa:	7266                	.insn	2, 0x7266
800042fc:	6565                	.insn	2, 0x6565
800042fe:	  	.insn	8, 0x002b800042d4003f

80004300 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.43>:
80004300:	42d4                	.insn	2, 0x42d4
80004302:	8000                	.insn	2, 0x8000
80004304:	0000002b          	.insn	4, 0x002b

80004308 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.44>:
80004308:	4170                	.insn	2, 0x4170
8000430a:	8000                	.insn	2, 0x8000
8000430c:	0000000b          	.insn	4, 0x000b
80004310:	0206                	.insn	2, 0x0206
80004312:	0000                	.insn	2, 0x
80004314:	000d                	.insn	2, 0x000d
	...

80004318 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.45>:
80004318:	4170                	.insn	2, 0x4170
8000431a:	8000                	.insn	2, 0x8000
8000431c:	0000000b          	.insn	4, 0x000b
80004320:	0228                	.insn	2, 0x0228
80004322:	0000                	.insn	2, 0x
80004324:	0011                	.insn	2, 0x0011
	...

80004328 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.46>:
80004328:	7246                	.insn	2, 0x7246
8000432a:	6565                	.insn	2, 0x6565
8000432c:	2064                	.insn	2, 0x2064
8000432e:	6f6e                	.insn	2, 0x6f6e
80004330:	6564                	.insn	2, 0x6564
80004332:	2820                	.insn	2, 0x2820

80004334 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.47>:
80004334:	2029                	.insn	2, 0x2029
80004336:	6c61                	.insn	2, 0x6c61
80004338:	6169                	.insn	2, 0x6169
8000433a:	20736573          	.insn	4, 0x20736573
8000433e:	7865                	.insn	2, 0x7865
80004340:	7369                	.insn	2, 0x7369
80004342:	6974                	.insn	2, 0x6974
80004344:	676e                	.insn	2, 0x676e
80004346:	6820                	.insn	2, 0x6820
80004348:	20656c6f          	jal	s8,8005a54e <KALLOC_BUFFER+0x5454e>
8000434c:	                	.insn	2, 0x5b28

8000434d <.Lanon.10e9e605f29f28b577aacdba1819c9a4.48>:
8000434d:	          	.insn	4, 0x21295d5b

8000434e <.Lanon.10e9e605f29f28b577aacdba1819c9a4.49>:
8000434e:	295d                	.insn	2, 0x295d
80004350:	2021                	.insn	2, 0x2021
80004352:	6142                	.insn	2, 0x6142
80004354:	2064                	.insn	2, 0x2064
80004356:	7266                	.insn	2, 0x7266
80004358:	6565                	.insn	2, 0x6565
8000435a:	  	.insn	8, 0x000c80004328003f

8000435c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.50>:
8000435c:	4328                	.insn	2, 0x4328
8000435e:	8000                	.insn	2, 0x8000
80004360:	000c                	.insn	2, 0x000c
80004362:	0000                	.insn	2, 0x
80004364:	4334                	.insn	2, 0x4334
80004366:	8000                	.insn	2, 0x8000
80004368:	0019                	.insn	2, 0x0019
8000436a:	0000                	.insn	2, 0x
8000436c:	434d                	.insn	2, 0x434d
8000436e:	8000                	.insn	2, 0x8000
80004370:	0001                	.insn	2, 0x0001
80004372:	0000                	.insn	2, 0x
80004374:	434e                	.insn	2, 0x434e
80004376:	8000                	.insn	2, 0x8000
80004378:	000d                	.insn	2, 0x000d
	...

8000437c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.51>:
8000437c:	4170                	.insn	2, 0x4170
8000437e:	8000                	.insn	2, 0x8000
80004380:	0000000b          	.insn	4, 0x000b
80004384:	0000023b          	.insn	4, 0x023b
80004388:	0009                	.insn	2, 0x0009
	...

8000438c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.52>:
8000438c:	6c6c616b          	.insn	4, 0x6c6c616b
80004390:	6220636f          	jal	t1,8000a9b2 <KALLOC_BUFFER+0x49b2>
80004394:	6675                	.insn	2, 0x6675
80004396:	6566                	.insn	2, 0x6566
80004398:	2072                	.insn	2, 0x2072
8000439a:	6162                	.insn	2, 0x6162
8000439c:	203a6573          	.insn	4, 0x203a6573

800043a0 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.53>:
800043a0:	438c                	.insn	2, 0x438c
800043a2:	8000                	.insn	2, 0x8000
800043a4:	0014                	.insn	2, 0x0014
800043a6:	0000                	.insn	2, 0x
800043a8:	4156                	.insn	2, 0x4156
800043aa:	8000                	.insn	2, 0x8000
800043ac:	0001                	.insn	2, 0x0001
	...

800043b0 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.54>:
800043b0:	6f66                	.insn	2, 0x6f66
800043b2:	6e75                	.insn	2, 0x6e75
800043b4:	2064                	.insn	2, 0x2064

800043b6 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.55>:
800043b6:	6520                	.insn	2, 0x6520
800043b8:	656c                	.insn	2, 0x656c
800043ba:	656d                	.insn	2, 0x656d
800043bc:	746e                	.insn	2, 0x746e
800043be:	6e692073          	.insn	4, 0x6e692073
800043c2:	7420                	.insn	2, 0x7420
800043c4:	6568                	.insn	2, 0x6568
800043c6:	6c20                	.insn	2, 0x6c20
800043c8:	7369                	.insn	2, 0x7369
800043ca:	0a74                	.insn	2, 0x0a74

800043cc <.Lanon.10e9e605f29f28b577aacdba1819c9a4.56>:
800043cc:	43b0                	.insn	2, 0x43b0
800043ce:	8000                	.insn	2, 0x8000
800043d0:	0006                	.insn	2, 0x0006
800043d2:	0000                	.insn	2, 0x
800043d4:	43b6                	.insn	2, 0x43b6
800043d6:	8000                	.insn	2, 0x8000
800043d8:	0016                	.insn	2, 0x0016
	...

800043dc <.Lanon.10e9e605f29f28b577aacdba1819c9a4.57>:
800043dc:	2f637273          	.insn	4, 0x2f637273
800043e0:	616d                	.insn	2, 0x616d
800043e2:	6e69                	.insn	2, 0x6e69
800043e4:	722e                	.insn	2, 0x722e
800043e6:	          	.insn	4, 0x43dc0073

800043e8 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.58>:
800043e8:	43dc                	.insn	2, 0x43dc
800043ea:	8000                	.insn	2, 0x8000
800043ec:	0000000b          	.insn	4, 0x000b
800043f0:	0050                	.insn	2, 0x0050
800043f2:	0000                	.insn	2, 0x
800043f4:	000e                	.insn	2, 0x000e
	...

800043f8 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.59>:
800043f8:	31335b1b          	.insn	4, 0x31335b1b
800043fc:	4b6d                	.insn	2, 0x4b6d
800043fe:	5245                	.insn	2, 0x5245
80004400:	454e                	.insn	2, 0x454e
80004402:	204c                	.insn	2, 0x204c
80004404:	4150                	.insn	2, 0x4150
80004406:	494e                	.insn	2, 0x494e
80004408:	5b1b3a43          	.insn	4, 0x5b1b3a43
8000440c:	6d30                	.insn	2, 0x6d30
8000440e:	0020                	.insn	2, 0x0020

80004410 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.60>:
80004410:	43f8                	.insn	2, 0x43f8
80004412:	8000                	.insn	2, 0x8000
80004414:	00000017          	auipc	zero,0x0
80004418:	4156                	.insn	2, 0x4156
8000441a:	8000                	.insn	2, 0x8000
8000441c:	0001                	.insn	2, 0x0001
	...

80004420 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.67>:
80004420:	43dc                	.insn	2, 0x43dc
80004422:	8000                	.insn	2, 0x8000
80004424:	0000000b          	.insn	4, 0x000b
80004428:	0000009b          	.insn	4, 0x009b
8000442c:	0026                	.insn	2, 0x0026
	...

80004430 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.68>:
80004430:	7375                	.insn	2, 0x7375
80004432:	7265                	.insn	2, 0x7265
80004434:	6d5f 6961 3a6e      	.insn	6, 0x3a6e69616d5f
8000443a:	0020                	.insn	2, 0x0020

8000443c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.69>:
8000443c:	4430                	.insn	2, 0x4430
8000443e:	8000                	.insn	2, 0x8000
80004440:	0000000b          	.insn	4, 0x000b
80004444:	4156                	.insn	2, 0x4156
80004446:	8000                	.insn	2, 0x8000
80004448:	0001                	.insn	2, 0x0001
	...

8000444c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.74>:
8000444c:	6974                	.insn	2, 0x6974
8000444e:	656d                	.insn	2, 0x656d
80004450:	203a                	.insn	2, 0x203a

80004452 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.75>:
80004452:	6920                	.insn	2, 0x6920
80004454:	736e                	.insn	2, 0x736e
80004456:	7274                	.insn	2, 0x7274
80004458:	7465                	.insn	2, 0x7465
8000445a:	203a                	.insn	2, 0x203a

8000445c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.76>:
8000445c:	444c                	.insn	2, 0x444c
8000445e:	8000                	.insn	2, 0x8000
80004460:	0006                	.insn	2, 0x0006
80004462:	0000                	.insn	2, 0x
80004464:	4452                	.insn	2, 0x4452
80004466:	8000                	.insn	2, 0x8000
80004468:	000a                	.insn	2, 0x000a
8000446a:	0000                	.insn	2, 0x
8000446c:	4156                	.insn	2, 0x4156
8000446e:	8000                	.insn	2, 0x8000
80004470:	0001                	.insn	2, 0x0001
	...

80004474 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.77>:
80004474:	6c6c616b          	.insn	4, 0x6c6c616b
80004478:	6620636f          	jal	t1,8000aada <KALLOC_BUFFER+0x4ada>
8000447c:	6961                	.insn	2, 0x6961
8000447e:	3a6c                	.insn	2, 0x3a6c
80004480:	0020                	.insn	2, 0x0020
	...

80004484 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.78>:
80004484:	4474                	.insn	2, 0x4474
80004486:	8000                	.insn	2, 0x8000
80004488:	000d                	.insn	2, 0x000d
	...

8000448c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.79>:
8000448c:	2f637273          	.insn	4, 0x2f637273
80004490:	6c6c616b          	.insn	4, 0x6c6c616b
80004494:	722e636f          	jal	t1,800eabb6 <KALLOC_BUFFER+0xe4bb6>
80004498:	00000073          	ecall

8000449c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.80>:
8000449c:	448c                	.insn	2, 0x448c
8000449e:	8000                	.insn	2, 0x8000
800044a0:	000d                	.insn	2, 0x000d
800044a2:	0000                	.insn	2, 0x
800044a4:	0019                	.insn	2, 0x0019
800044a6:	0000                	.insn	2, 0x
800044a8:	0005                	.insn	2, 0x0005
	...

800044ac <.Lswitch.table._ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17h43f79eca3d356742E>:
800044ac:	0015                	.insn	2, 0x0015
800044ae:	0000                	.insn	2, 0x
800044b0:	0010                	.insn	2, 0x0010
800044b2:	0000                	.insn	2, 0x
800044b4:	0012                	.insn	2, 0x0012
800044b6:	0000                	.insn	2, 0x
800044b8:	000a                	.insn	2, 0x000a
800044ba:	0000                	.insn	2, 0x
800044bc:	000e                	.insn	2, 0x000e
800044be:	0000                	.insn	2, 0x
800044c0:	0009                	.insn	2, 0x0009
800044c2:	0000                	.insn	2, 0x
800044c4:	0000000f          	fence	unknown,unknown
800044c8:	000a                	.insn	2, 0x000a
800044ca:	0000                	.insn	2, 0x
800044cc:	0000000b          	.insn	4, 0x000b
800044d0:	0011                	.insn	2, 0x0011
800044d2:	0000                	.insn	2, 0x
800044d4:	000e                	.insn	2, 0x000e
800044d6:	0000                	.insn	2, 0x
800044d8:	0014                	.insn	2, 0x0014
800044da:	0000                	.insn	2, 0x
800044dc:	000d                	.insn	2, 0x000d
800044de:	0000                	.insn	2, 0x
800044e0:	000e                	.insn	2, 0x000e
800044e2:	0000                	.insn	2, 0x
800044e4:	00000007          	.insn	4, 0x0007

800044e8 <.Lswitch.table._ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17h43f79eca3d356742E.13>:
800044e8:	403e                	.insn	2, 0x403e
800044ea:	8000                	.insn	2, 0x8000
800044ec:	4064                	.insn	2, 0x4064
800044ee:	8000                	.insn	2, 0x8000
800044f0:	4094                	.insn	2, 0x4094
800044f2:	8000                	.insn	2, 0x8000
800044f4:	40a6                	.insn	2, 0x40a6
800044f6:	8000                	.insn	2, 0x8000
800044f8:	40b0                	.insn	2, 0x40b0
800044fa:	8000                	.insn	2, 0x8000
800044fc:	40be                	.insn	2, 0x40be
800044fe:	8000                	.insn	2, 0x8000
80004500:	800040c7          	.insn	4, 0x800040c7
80004504:	40d6                	.insn	2, 0x40d6
80004506:	8000                	.insn	2, 0x8000
80004508:	40e0                	.insn	2, 0x40e0
8000450a:	8000                	.insn	2, 0x8000
8000450c:	800040eb          	.insn	4, 0x800040eb
80004510:	40fc                	.insn	2, 0x40fc
80004512:	8000                	.insn	2, 0x8000
80004514:	410a                	.insn	2, 0x410a
80004516:	8000                	.insn	2, 0x8000
80004518:	411e                	.insn	2, 0x411e
8000451a:	8000                	.insn	2, 0x8000
8000451c:	8000412b          	.insn	4, 0x8000412b
80004520:	4139                	.insn	2, 0x4139
80004522:	8000                	.insn	2, 0x8000

80004524 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.0>:
80004524:	0000                	.insn	2, 0x
80004526:	0000                	.insn	2, 0x
80004528:	0004                	.insn	2, 0x0004
8000452a:	0000                	.insn	2, 0x
8000452c:	0004                	.insn	2, 0x0004
8000452e:	0000                	.insn	2, 0x
80004530:	1060                	.insn	2, 0x1060
80004532:	8000                	.insn	2, 0x8000

80004534 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.1>:
80004534:	7245                	.insn	2, 0x7245
80004536:	6f72                	.insn	2, 0x6f72
80004538:	0072                	.insn	2, 0x0072
	...

8000453c <anon.69b25bd7f89c0392b47e51b05b6e4f5f.2.llvm.17300957278716910357>:
	...
80004544:	0001                	.insn	2, 0x0001
80004546:	0000                	.insn	2, 0x
80004548:	1394                	.insn	2, 0x1394
8000454a:	8000                	.insn	2, 0x8000
8000454c:	107c                	.insn	2, 0x107c
8000454e:	8000                	.insn	2, 0x8000
80004550:	115c                	.insn	2, 0x115c
80004552:	8000                	.insn	2, 0x8000

80004554 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.3.llvm.17300957278716910357>:
	...
8000455c:	0001                	.insn	2, 0x0001
8000455e:	0000                	.insn	2, 0x
80004560:	11b4                	.insn	2, 0x11b4
80004562:	8000                	.insn	2, 0x8000

80004564 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.4.llvm.17300957278716910357>:
80004564:	6c6c6163          	bltu	s8,t1,80004c26 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292+0x4ab>
80004568:	6465                	.insn	2, 0x6465
8000456a:	6020                	.insn	2, 0x6020
8000456c:	6552                	.insn	2, 0x6552
8000456e:	746c7573          	.insn	4, 0x746c7573
80004572:	3a3a                	.insn	2, 0x3a3a
80004574:	6e75                	.insn	2, 0x6e75
80004576:	70617277          	.insn	4, 0x70617277
8000457a:	2928                	.insn	2, 0x2928
8000457c:	2060                	.insn	2, 0x2060
8000457e:	61206e6f          	jal	t3,8000ab90 <KALLOC_BUFFER+0x4b90>
80004582:	206e                	.insn	2, 0x206e
80004584:	4560                	.insn	2, 0x4560
80004586:	7272                	.insn	2, 0x7272
80004588:	2060                	.insn	2, 0x2060
8000458a:	6176                	.insn	2, 0x6176
8000458c:	756c                	.insn	2, 0x756c
8000458e:	                	.insn	2, 0x7365

8000458f <anon.69b25bd7f89c0392b47e51b05b6e4f5f.5.llvm.17300957278716910357>:
8000458f:	2f637273          	.insn	4, 0x2f637273
80004593:	7270                	.insn	2, 0x7270
80004595:	6e69                	.insn	2, 0x6e69
80004597:	6574                	.insn	2, 0x6574
80004599:	2e72                	.insn	2, 0x2e72
8000459b:	7372                	.insn	2, 0x7372
8000459d:	0000                	.insn	2, 0x
	...

800045a0 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.6.llvm.17300957278716910357>:
800045a0:	8000458f          	.insn	4, 0x8000458f
800045a4:	000e                	.insn	2, 0x000e
800045a6:	0000                	.insn	2, 0x
800045a8:	00000017          	auipc	zero,0x0
800045ac:	001c                	.insn	2, 0x001c
	...

800045b0 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.7>:
800045b0:	6170                	.insn	2, 0x6170
800045b2:	6c6c                	.insn	2, 0x6c6c
800045b4:	203a636f          	jal	t1,800aafb6 <KALLOC_BUFFER+0xa4fb6>
800045b8:	6966                	.insn	2, 0x6966
800045ba:	7372                	.insn	2, 0x7372
800045bc:	2074                	.insn	2, 0x2074

800045be <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.8>:
800045be:	6c20                	.insn	2, 0x6c20
800045c0:	7361                	.insn	2, 0x7361
800045c2:	2074                	.insn	2, 0x2074

800045c4 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.9>:
800045c4:	000a                	.insn	2, 0x000a
	...

800045c8 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.10>:
800045c8:	45b0                	.insn	2, 0x45b0
800045ca:	8000                	.insn	2, 0x8000
800045cc:	000e                	.insn	2, 0x000e
800045ce:	0000                	.insn	2, 0x
800045d0:	45be                	.insn	2, 0x45be
800045d2:	8000                	.insn	2, 0x8000
800045d4:	0006                	.insn	2, 0x0006
800045d6:	0000                	.insn	2, 0x
800045d8:	45c4                	.insn	2, 0x45c4
800045da:	8000                	.insn	2, 0x8000
800045dc:	0001                	.insn	2, 0x0001
	...

800045e0 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.11.llvm.17300957278716910357>:
800045e0:	2f637273          	.insn	4, 0x2f637273
800045e4:	6f70                	.insn	2, 0x6f70
800045e6:	6e69                	.insn	2, 0x6e69
800045e8:	6574                	.insn	2, 0x6574
800045ea:	2e72                	.insn	2, 0x2e72
800045ec:	7372                	.insn	2, 0x7372
	...

800045f0 <anon.69b25bd7f89c0392b47e51b05b6e4f5f.12.llvm.17300957278716910357>:
800045f0:	45e0                	.insn	2, 0x45e0
800045f2:	8000                	.insn	2, 0x8000
800045f4:	000e                	.insn	2, 0x000e
800045f6:	0000                	.insn	2, 0x
800045f8:	0000002f          	.insn	4, 0x002f
800045fc:	0030                	.insn	2, 0x0030
	...

80004600 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.13>:
80004600:	6170                	.insn	2, 0x6170
80004602:	6c6c                	.insn	2, 0x6c6c
80004604:	6220636f          	jal	t1,8000ac26 <KALLOC_BUFFER+0x4c26>
80004608:	7361                	.insn	2, 0x7361
8000460a:	3a65                	.insn	2, 0x3a65
8000460c:	3020                	.insn	2, 0x3020
8000460e:	0078                	.insn	2, 0x0078

80004610 <.Lanon.69b25bd7f89c0392b47e51b05b6e4f5f.14>:
80004610:	4600                	.insn	2, 0x4600
80004612:	8000                	.insn	2, 0x8000
80004614:	0000000f          	fence	unknown,unknown
80004618:	45c4                	.insn	2, 0x45c4
8000461a:	8000                	.insn	2, 0x8000
8000461c:	0001                	.insn	2, 0x0001
	...

80004620 <.Lanon.b62c2a328d7ddaf64cdc1bdc0f67bb4c.3>:
80004620:	61706163          	bltu	zero,s7,80004c22 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292+0x4a7>
80004624:	79746963          	bltu	s0,s7,80004db6 <__rust_no_alloc_shim_is_unstable+0x58>
80004628:	6f20                	.insn	2, 0x6f20
8000462a:	6576                	.insn	2, 0x6576
8000462c:	6672                	.insn	2, 0x6672
8000462e:	6f6c                	.insn	2, 0x6f6c
80004630:	00000077          	.insn	4, 0x0077

80004634 <.Lanon.b62c2a328d7ddaf64cdc1bdc0f67bb4c.4>:
80004634:	4620                	.insn	2, 0x4620
80004636:	8000                	.insn	2, 0x8000
80004638:	0011                	.insn	2, 0x0011
8000463a:	0000                	.insn	2, 0x
8000463c:	0100                	.insn	2, 0x0100
8000463e:	021c                	.insn	2, 0x021c
80004640:	0e1d                	.insn	2, 0x0e1d
80004642:	0318                	.insn	2, 0x0318
80004644:	161e                	.insn	2, 0x161e
80004646:	0f14                	.insn	2, 0x0f14
80004648:	1119                	.insn	2, 0x1119
8000464a:	0804                	.insn	2, 0x0804
8000464c:	1b1f 170d 1315      	.insn	6, 0x1315170d1b1f
80004652:	0710                	.insn	2, 0x0710
80004654:	0c1a                	.insn	2, 0x0c1a
80004656:	0612                	.insn	2, 0x0612
80004658:	090a050b          	.insn	4, 0x090a050b

8000465c <.Lanon.0a795d8d80343cc40e42ade3e02d1552.138>:
8000465c:	2820                	.insn	2, 0x2820
8000465e:	2031                	.insn	2, 0x2031
80004660:	3c3c                	.insn	2, 0x3c3c
80004662:	                	.insn	2, 0x2920

80004663 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.139>:
80004663:	                	.insn	2, 0x0129

80004664 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.140>:
80004664:	0001                	.insn	2, 0x0001
80004666:	0000                	.insn	2, 0x
80004668:	0000                	.insn	2, 0x
8000466a:	0000                	.insn	2, 0x
8000466c:	465c                	.insn	2, 0x465c
8000466e:	8000                	.insn	2, 0x8000
80004670:	00000007          	.insn	4, 0x0007
80004674:	80004663          	bltz	zero,80003680 <memcpy+0x1f8>
80004678:	0001                	.insn	2, 0x0001
	...

8000467c <.Lanon.0a795d8d80343cc40e42ade3e02d1552.210>:
8000467c:	                	.insn	2, 0x633a

8000467d <.Lanon.0a795d8d80343cc40e42ade3e02d1552.220>:
8000467d:	6c6c6163          	bltu	s8,t1,80004d3f <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292+0x5c4>
80004681:	6465                	.insn	2, 0x6465
80004683:	6020                	.insn	2, 0x6020
80004685:	6974704f          	.insn	4, 0x6974704f
80004689:	3a3a6e6f          	jal	t3,800ab22b <KALLOC_BUFFER+0xa522b>
8000468d:	6e75                	.insn	2, 0x6e75
8000468f:	70617277          	.insn	4, 0x70617277
80004693:	2928                	.insn	2, 0x2928
80004695:	2060                	.insn	2, 0x2060
80004697:	61206e6f          	jal	t3,8000aca9 <KALLOC_BUFFER+0x4ca9>
8000469b:	6020                	.insn	2, 0x6020
8000469d:	6f4e                	.insn	2, 0x6f4e
8000469f:	656e                	.insn	2, 0x656e
800046a1:	2060                	.insn	2, 0x2060
800046a3:	6176                	.insn	2, 0x6176
800046a5:	756c                	.insn	2, 0x756c
800046a7:	                	.insn	2, 0x0165

800046a8 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.221>:
800046a8:	0001                	.insn	2, 0x0001
800046aa:	0000                	.insn	2, 0x
800046ac:	0000                	.insn	2, 0x
800046ae:	0000                	.insn	2, 0x
800046b0:	467c                	.insn	2, 0x467c
800046b2:	8000                	.insn	2, 0x8000
800046b4:	0001                	.insn	2, 0x0001
800046b6:	0000                	.insn	2, 0x
800046b8:	467c                	.insn	2, 0x467c
800046ba:	8000                	.insn	2, 0x8000
800046bc:	0001                	.insn	2, 0x0001
	...

800046c0 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.222>:
800046c0:	6170                	.insn	2, 0x6170
800046c2:	696e                	.insn	2, 0x696e
800046c4:	64656b63          	bltu	a0,t1,80004d1a <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292+0x59f>
800046c8:	6120                	.insn	2, 0x6120
800046ca:	2074                	.insn	2, 0x2074

800046cc <.Lanon.0a795d8d80343cc40e42ade3e02d1552.223>:
800046cc:	0a3a                	.insn	2, 0x0a3a

800046ce <.Lanon.0a795d8d80343cc40e42ade3e02d1552.240>:
800046ce:	3d3d                	.insn	2, 0x3d3d

800046d0 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.241>:
800046d0:	3d21                	.insn	2, 0x3d21

800046d2 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.242>:
800046d2:	616d                	.insn	2, 0x616d
800046d4:	6374                	.insn	2, 0x6374
800046d6:	6568                	.insn	2, 0x6568
800046d8:	          	.insn	4, 0x69722073

800046d9 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.244>:
800046d9:	7220                	.insn	2, 0x7220
800046db:	6769                	.insn	2, 0x6769
800046dd:	7468                	.insn	2, 0x7468
800046df:	2060                	.insn	2, 0x2060
800046e1:	6166                	.insn	2, 0x6166
800046e3:	6c69                	.insn	2, 0x6c69
800046e5:	6465                	.insn	2, 0x6465
800046e7:	200a                	.insn	2, 0x200a
800046e9:	6c20                	.insn	2, 0x6c20
800046eb:	6665                	.insn	2, 0x6665
800046ed:	3a74                	.insn	2, 0x3a74
800046ef:	                	.insn	2, 0x0a20

800046f0 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.245>:
800046f0:	200a                	.insn	2, 0x200a
800046f2:	6972                	.insn	2, 0x6972
800046f4:	3a746867          	.insn	4, 0x3a746867
800046f8:	0020                	.insn	2, 0x0020
	...

800046fc <.Lanon.0a795d8d80343cc40e42ade3e02d1552.246>:
800046fc:	4054                	.insn	2, 0x4054
800046fe:	8000                	.insn	2, 0x8000
80004700:	0010                	.insn	2, 0x0010
80004702:	0000                	.insn	2, 0x
80004704:	46d9                	.insn	2, 0x46d9
80004706:	8000                	.insn	2, 0x8000
80004708:	00000017          	auipc	zero,0x0
8000470c:	46f0                	.insn	2, 0x46f0
8000470e:	8000                	.insn	2, 0x8000
80004710:	0009                	.insn	2, 0x0009
	...

80004714 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.248>:
80004714:	200a                	.insn	2, 0x200a
80004716:	6c20                	.insn	2, 0x6c20
80004718:	6665                	.insn	2, 0x6665
8000471a:	3a74                	.insn	2, 0x3a74
8000471c:	0020                	.insn	2, 0x0020
	...

80004720 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.249>:
80004720:	4054                	.insn	2, 0x4054
80004722:	8000                	.insn	2, 0x8000
80004724:	0010                	.insn	2, 0x0010
80004726:	0000                	.insn	2, 0x
80004728:	4084                	.insn	2, 0x4084
8000472a:	8000                	.insn	2, 0x8000
8000472c:	0010                	.insn	2, 0x0010
8000472e:	0000                	.insn	2, 0x
80004730:	4714                	.insn	2, 0x4714
80004732:	8000                	.insn	2, 0x8000
80004734:	0009                	.insn	2, 0x0009
80004736:	0000                	.insn	2, 0x
80004738:	46f0                	.insn	2, 0x46f0
8000473a:	8000                	.insn	2, 0x8000
8000473c:	0009                	.insn	2, 0x0009
	...

80004740 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.250>:
80004740:	203a                	.insn	2, 0x203a
	...

80004744 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.251>:
80004744:	0001                	.insn	2, 0x0001
80004746:	0000                	.insn	2, 0x
80004748:	0000                	.insn	2, 0x
8000474a:	0000                	.insn	2, 0x
8000474c:	4740                	.insn	2, 0x4740
8000474e:	8000                	.insn	2, 0x8000
80004750:	0002                	.insn	2, 0x0002
	...

80004754 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.252>:
80004754:	0000                	.insn	2, 0x
80004756:	0000                	.insn	2, 0x
80004758:	000c                	.insn	2, 0x000c
8000475a:	0000                	.insn	2, 0x
8000475c:	0004                	.insn	2, 0x0004
8000475e:	0000                	.insn	2, 0x
80004760:	1ac4                	.insn	2, 0x1ac4
80004762:	8000                	.insn	2, 0x8000
80004764:	1d60                	.insn	2, 0x1d60
80004766:	8000                	.insn	2, 0x8000
80004768:	2050                	.insn	2, 0x2050
8000476a:	8000                	.insn	2, 0x8000

8000476c <.Lanon.0a795d8d80343cc40e42ade3e02d1552.254>:
8000476c:	7b20                	.insn	2, 0x7b20
8000476e:	                	.insn	2, 0x2c20

8000476f <.Lanon.0a795d8d80343cc40e42ade3e02d1552.255>:
8000476f:	202c                	.insn	2, 0x202c

80004771 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.256>:
80004771:	7b20                	.insn	2, 0x7b20
80004773:	                	.insn	2, 0x2c0a

80004774 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.257>:
80004774:	0a2c                	.insn	2, 0x0a2c

80004776 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.261>:
80004776:	                	.insn	2, 0x207d

80004777 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.262>:
80004777:	7d20                	.insn	2, 0x7d20

80004779 <.Lanon.0a795d8d80343cc40e42ade3e02d1552.289>:
80004779:	7830                	.insn	2, 0x7830

8000477b <.Lanon.0a795d8d80343cc40e42ade3e02d1552.292>:
8000477b:	3030                	.insn	2, 0x3030
8000477d:	3130                	.insn	2, 0x3130
8000477f:	3230                	.insn	2, 0x3230
80004781:	3330                	.insn	2, 0x3330
80004783:	3430                	.insn	2, 0x3430
80004785:	3530                	.insn	2, 0x3530
80004787:	3630                	.insn	2, 0x3630
80004789:	3730                	.insn	2, 0x3730
8000478b:	3830                	.insn	2, 0x3830
8000478d:	3930                	.insn	2, 0x3930
8000478f:	3031                	.insn	2, 0x3031
80004791:	3131                	.insn	2, 0x3131
80004793:	3231                	.insn	2, 0x3231
80004795:	3331                	.insn	2, 0x3331
80004797:	3431                	.insn	2, 0x3431
80004799:	3531                	.insn	2, 0x3531
8000479b:	3631                	.insn	2, 0x3631
8000479d:	3731                	.insn	2, 0x3731
8000479f:	3831                	.insn	2, 0x3831
800047a1:	3931                	.insn	2, 0x3931
800047a3:	3032                	.insn	2, 0x3032
800047a5:	3132                	.insn	2, 0x3132
800047a7:	3232                	.insn	2, 0x3232
800047a9:	3332                	.insn	2, 0x3332
800047ab:	3432                	.insn	2, 0x3432
800047ad:	3532                	.insn	2, 0x3532
800047af:	3632                	.insn	2, 0x3632
800047b1:	3732                	.insn	2, 0x3732
800047b3:	3832                	.insn	2, 0x3832
800047b5:	3932                	.insn	2, 0x3932
800047b7:	31333033          	.insn	4, 0x31333033
800047bb:	33333233          	.insn	4, 0x33333233
800047bf:	35333433          	.insn	4, 0x35333433
800047c3:	37333633          	.insn	4, 0x37333633
800047c7:	39333833          	.insn	4, 0x39333833
800047cb:	3034                	.insn	2, 0x3034
800047cd:	3134                	.insn	2, 0x3134
800047cf:	3234                	.insn	2, 0x3234
800047d1:	3334                	.insn	2, 0x3334
800047d3:	3434                	.insn	2, 0x3434
800047d5:	3534                	.insn	2, 0x3534
800047d7:	3634                	.insn	2, 0x3634
800047d9:	3734                	.insn	2, 0x3734
800047db:	3834                	.insn	2, 0x3834
800047dd:	3934                	.insn	2, 0x3934
800047df:	3035                	.insn	2, 0x3035
800047e1:	3135                	.insn	2, 0x3135
800047e3:	3235                	.insn	2, 0x3235
800047e5:	3335                	.insn	2, 0x3335
800047e7:	3435                	.insn	2, 0x3435
800047e9:	3535                	.insn	2, 0x3535
800047eb:	3635                	.insn	2, 0x3635
800047ed:	3735                	.insn	2, 0x3735
800047ef:	3835                	.insn	2, 0x3835
800047f1:	3935                	.insn	2, 0x3935
800047f3:	3036                	.insn	2, 0x3036
800047f5:	3136                	.insn	2, 0x3136
800047f7:	3236                	.insn	2, 0x3236
800047f9:	3336                	.insn	2, 0x3336
800047fb:	3436                	.insn	2, 0x3436
800047fd:	3536                	.insn	2, 0x3536
800047ff:	3636                	.insn	2, 0x3636
80004801:	3736                	.insn	2, 0x3736
80004803:	3836                	.insn	2, 0x3836
80004805:	3936                	.insn	2, 0x3936
80004807:	31373037          	lui	zero,0x31373
8000480b:	33373237          	lui	tp,0x33373
8000480f:	35373437          	lui	s0,0x35373
80004813:	37373637          	lui	a2,0x37373
80004817:	39373837          	lui	a6,0x39373
8000481b:	3038                	.insn	2, 0x3038
8000481d:	3138                	.insn	2, 0x3138
8000481f:	3238                	.insn	2, 0x3238
80004821:	3338                	.insn	2, 0x3338
80004823:	3438                	.insn	2, 0x3438
80004825:	3538                	.insn	2, 0x3538
80004827:	3638                	.insn	2, 0x3638
80004829:	3738                	.insn	2, 0x3738
8000482b:	3838                	.insn	2, 0x3838
8000482d:	3938                	.insn	2, 0x3938
8000482f:	3039                	.insn	2, 0x3039
80004831:	3139                	.insn	2, 0x3139
80004833:	3239                	.insn	2, 0x3239
80004835:	3339                	.insn	2, 0x3339
80004837:	3439                	.insn	2, 0x3439
80004839:	3539                	.insn	2, 0x3539
8000483b:	3639                	.insn	2, 0x3639
8000483d:	3739                	.insn	2, 0x3739
8000483f:	3839                	.insn	2, 0x3839
80004841:	3939                	.insn	2, 0x3939

Disassembly of section .eh_frame:

80004850 <__bss_start-0x4f8>:
80004850:	0010                	.insn	2, 0x0010
80004852:	0000                	.insn	2, 0x
80004854:	0000                	.insn	2, 0x
80004856:	0000                	.insn	2, 0x
80004858:	7a01                	.insn	2, 0x7a01
8000485a:	0052                	.insn	2, 0x0052
8000485c:	7c01                	.insn	2, 0x7c01
8000485e:	0101                	.insn	2, 0x0101
80004860:	00020c1b          	.insn	4, 0x00020c1b
80004864:	0010                	.insn	2, 0x0010
80004866:	0000                	.insn	2, 0x
80004868:	0018                	.insn	2, 0x0018
8000486a:	0000                	.insn	2, 0x
8000486c:	cd58                	.insn	2, 0xcd58
8000486e:	ffff                	.insn	2, 0xffff
80004870:	0008                	.insn	2, 0x0008
80004872:	0000                	.insn	2, 0x
80004874:	0000                	.insn	2, 0x
80004876:	0000                	.insn	2, 0x
80004878:	001c                	.insn	2, 0x001c
8000487a:	0000                	.insn	2, 0x
8000487c:	002c                	.insn	2, 0x002c
8000487e:	0000                	.insn	2, 0x
80004880:	cd4c                	.insn	2, 0xcd4c
80004882:	ffff                	.insn	2, 0xffff
80004884:	0044                	.insn	2, 0x0044
80004886:	0000                	.insn	2, 0x
80004888:	4400                	.insn	2, 0x4400
8000488a:	200e                	.insn	2, 0x200e
8000488c:	8148                	.insn	2, 0x8148
8000488e:	8801                	.insn	2, 0x8801
80004890:	4402                	.insn	2, 0x4402
80004892:	080c                	.insn	2, 0x080c
80004894:	0000                	.insn	2, 0x
80004896:	0000                	.insn	2, 0x
80004898:	001c                	.insn	2, 0x001c
8000489a:	0000                	.insn	2, 0x
8000489c:	004c                	.insn	2, 0x004c
8000489e:	0000                	.insn	2, 0x
800048a0:	cd70                	.insn	2, 0xcd70
800048a2:	ffff                	.insn	2, 0xffff
800048a4:	0028                	.insn	2, 0x0028
800048a6:	0000                	.insn	2, 0x
800048a8:	4400                	.insn	2, 0x4400
800048aa:	100e                	.insn	2, 0x100e
800048ac:	8148                	.insn	2, 0x8148
800048ae:	8801                	.insn	2, 0x8801
800048b0:	4402                	.insn	2, 0x4402
800048b2:	080c                	.insn	2, 0x080c
800048b4:	0000                	.insn	2, 0x
800048b6:	0000                	.insn	2, 0x
800048b8:	001c                	.insn	2, 0x001c
800048ba:	0000                	.insn	2, 0x
800048bc:	006c                	.insn	2, 0x006c
800048be:	0000                	.insn	2, 0x
800048c0:	cd78                	.insn	2, 0xcd78
800048c2:	ffff                	.insn	2, 0xffff
800048c4:	0024                	.insn	2, 0x0024
800048c6:	0000                	.insn	2, 0x
800048c8:	4400                	.insn	2, 0x4400
800048ca:	100e                	.insn	2, 0x100e
800048cc:	8148                	.insn	2, 0x8148
800048ce:	8801                	.insn	2, 0x8801
800048d0:	4402                	.insn	2, 0x4402
800048d2:	080c                	.insn	2, 0x080c
800048d4:	0000                	.insn	2, 0x
800048d6:	0000                	.insn	2, 0x
800048d8:	001c                	.insn	2, 0x001c
800048da:	0000                	.insn	2, 0x
800048dc:	008c                	.insn	2, 0x008c
800048de:	0000                	.insn	2, 0x
800048e0:	cd7c                	.insn	2, 0xcd7c
800048e2:	ffff                	.insn	2, 0xffff
800048e4:	00b8                	.insn	2, 0x00b8
800048e6:	0000                	.insn	2, 0x
800048e8:	4400                	.insn	2, 0x4400
800048ea:	400e                	.insn	2, 0x400e
800048ec:	8148                	.insn	2, 0x8148
800048ee:	8801                	.insn	2, 0x8801
800048f0:	4402                	.insn	2, 0x4402
800048f2:	080c                	.insn	2, 0x080c
800048f4:	0000                	.insn	2, 0x
800048f6:	0000                	.insn	2, 0x
800048f8:	001c                	.insn	2, 0x001c
800048fa:	0000                	.insn	2, 0x
800048fc:	00ac                	.insn	2, 0x00ac
800048fe:	0000                	.insn	2, 0x
80004900:	ce14                	.insn	2, 0xce14
80004902:	ffff                	.insn	2, 0xffff
80004904:	0028                	.insn	2, 0x0028
80004906:	0000                	.insn	2, 0x
80004908:	4400                	.insn	2, 0x4400
8000490a:	100e                	.insn	2, 0x100e
8000490c:	8148                	.insn	2, 0x8148
8000490e:	8801                	.insn	2, 0x8801
80004910:	4402                	.insn	2, 0x4402
80004912:	080c                	.insn	2, 0x080c
80004914:	0000                	.insn	2, 0x
80004916:	0000                	.insn	2, 0x
80004918:	0024                	.insn	2, 0x0024
8000491a:	0000                	.insn	2, 0x
8000491c:	00cc                	.insn	2, 0x00cc
8000491e:	0000                	.insn	2, 0x
80004920:	ce1c                	.insn	2, 0xce1c
80004922:	ffff                	.insn	2, 0xffff
80004924:	014c                	.insn	2, 0x014c
80004926:	0000                	.insn	2, 0x
80004928:	4400                	.insn	2, 0x4400
8000492a:	500e                	.insn	2, 0x500e
8000492c:	815c                	.insn	2, 0x815c
8000492e:	8801                	.insn	2, 0x8801
80004930:	8902                	.insn	2, 0x8902
80004932:	93049203          	lh	tp,-1744(s1)
80004936:	9405                	.insn	2, 0x9405
80004938:	9506                	.insn	2, 0x9506
8000493a:	080c4407          	.insn	4, 0x080c4407
8000493e:	0000                	.insn	2, 0x
80004940:	001c                	.insn	2, 0x001c
80004942:	0000                	.insn	2, 0x
80004944:	00f4                	.insn	2, 0x00f4
80004946:	0000                	.insn	2, 0x
80004948:	cf40                	.insn	2, 0xcf40
8000494a:	ffff                	.insn	2, 0xffff
8000494c:	002c                	.insn	2, 0x002c
8000494e:	0000                	.insn	2, 0x
80004950:	4400                	.insn	2, 0x4400
80004952:	200e                	.insn	2, 0x200e
80004954:	8148                	.insn	2, 0x8148
80004956:	8801                	.insn	2, 0x8801
80004958:	4402                	.insn	2, 0x4402
8000495a:	080c                	.insn	2, 0x080c
8000495c:	0000                	.insn	2, 0x
8000495e:	0000                	.insn	2, 0x
80004960:	001c                	.insn	2, 0x001c
80004962:	0000                	.insn	2, 0x
80004964:	0114                	.insn	2, 0x0114
80004966:	0000                	.insn	2, 0x
80004968:	cf4c                	.insn	2, 0xcf4c
8000496a:	ffff                	.insn	2, 0xffff
8000496c:	0048                	.insn	2, 0x0048
8000496e:	0000                	.insn	2, 0x
80004970:	4400                	.insn	2, 0x4400
80004972:	300e                	.insn	2, 0x300e
80004974:	8148                	.insn	2, 0x8148
80004976:	8801                	.insn	2, 0x8801
80004978:	4402                	.insn	2, 0x4402
8000497a:	080c                	.insn	2, 0x080c
8000497c:	0000                	.insn	2, 0x
8000497e:	0000                	.insn	2, 0x
80004980:	0020                	.insn	2, 0x0020
80004982:	0000                	.insn	2, 0x
80004984:	0134                	.insn	2, 0x0134
80004986:	0000                	.insn	2, 0x
80004988:	cf74                	.insn	2, 0xcf74
8000498a:	ffff                	.insn	2, 0xffff
8000498c:	014c                	.insn	2, 0x014c
8000498e:	0000                	.insn	2, 0x
80004990:	4400                	.insn	2, 0x4400
80004992:	800e                	.insn	2, 0x800e
80004994:	5001                	.insn	2, 0x5001
80004996:	0181                	.insn	2, 0x0181
80004998:	0288                	.insn	2, 0x0288
8000499a:	0389                	.insn	2, 0x0389
8000499c:	0492                	.insn	2, 0x0492
8000499e:	0c44                	.insn	2, 0x0c44
800049a0:	0008                	.insn	2, 0x0008
800049a2:	0000                	.insn	2, 0x
800049a4:	001c                	.insn	2, 0x001c
800049a6:	0000                	.insn	2, 0x
800049a8:	0158                	.insn	2, 0x0158
800049aa:	0000                	.insn	2, 0x
800049ac:	d09c                	.insn	2, 0xd09c
800049ae:	ffff                	.insn	2, 0xffff
800049b0:	007c                	.insn	2, 0x007c
800049b2:	0000                	.insn	2, 0x
800049b4:	4400                	.insn	2, 0x4400
800049b6:	400e                	.insn	2, 0x400e
800049b8:	8148                	.insn	2, 0x8148
800049ba:	8801                	.insn	2, 0x8801
800049bc:	4402                	.insn	2, 0x4402
800049be:	080c                	.insn	2, 0x080c
800049c0:	0000                	.insn	2, 0x
800049c2:	0000                	.insn	2, 0x
800049c4:	0030                	.insn	2, 0x0030
800049c6:	0000                	.insn	2, 0x
800049c8:	0178                	.insn	2, 0x0178
800049ca:	0000                	.insn	2, 0x
800049cc:	d0f8                	.insn	2, 0xd0f8
800049ce:	ffff                	.insn	2, 0xffff
800049d0:	029c                	.insn	2, 0x029c
800049d2:	0000                	.insn	2, 0x
800049d4:	4400                	.insn	2, 0x4400
800049d6:	500e                	.insn	2, 0x500e
800049d8:	8174                	.insn	2, 0x8174
800049da:	8801                	.insn	2, 0x8801
800049dc:	8902                	.insn	2, 0x8902
800049de:	93049203          	lh	tp,-1744(s1)
800049e2:	9405                	.insn	2, 0x9405
800049e4:	9506                	.insn	2, 0x9506
800049e6:	97089607          	.insn	4, 0x97089607
800049ea:	9809                	.insn	2, 0x9809
800049ec:	990a                	.insn	2, 0x990a
800049ee:	9b0c9a0b          	.insn	4, 0x9b0c9a0b
800049f2:	440d                	.insn	2, 0x440d
800049f4:	080c                	.insn	2, 0x080c
800049f6:	0000                	.insn	2, 0x
800049f8:	0024                	.insn	2, 0x0024
800049fa:	0000                	.insn	2, 0x
800049fc:	01ac                	.insn	2, 0x01ac
800049fe:	0000                	.insn	2, 0x
80004a00:	d360                	.insn	2, 0xd360
80004a02:	ffff                	.insn	2, 0xffff
80004a04:	00b4                	.insn	2, 0x00b4
80004a06:	0000                	.insn	2, 0x
80004a08:	4400                	.insn	2, 0x4400
80004a0a:	200e                	.insn	2, 0x200e
80004a0c:	8158                	.insn	2, 0x8158
80004a0e:	8801                	.insn	2, 0x8801
80004a10:	8902                	.insn	2, 0x8902
80004a12:	93049203          	lh	tp,-1744(s1)
80004a16:	9405                	.insn	2, 0x9405
80004a18:	4406                	.insn	2, 0x4406
80004a1a:	080c                	.insn	2, 0x080c
80004a1c:	0000                	.insn	2, 0x
80004a1e:	0000                	.insn	2, 0x
80004a20:	002c                	.insn	2, 0x002c
80004a22:	0000                	.insn	2, 0x
80004a24:	01d4                	.insn	2, 0x01d4
80004a26:	0000                	.insn	2, 0x
80004a28:	d3ec                	.insn	2, 0xd3ec
80004a2a:	ffff                	.insn	2, 0xffff
80004a2c:	023c                	.insn	2, 0x023c
80004a2e:	0000                	.insn	2, 0x
80004a30:	4400                	.insn	2, 0x4400
80004a32:	600e                	.insn	2, 0x600e
80004a34:	8168                	.insn	2, 0x8168
80004a36:	8801                	.insn	2, 0x8801
80004a38:	8902                	.insn	2, 0x8902
80004a3a:	93049203          	lh	tp,-1744(s1)
80004a3e:	9405                	.insn	2, 0x9405
80004a40:	9506                	.insn	2, 0x9506
80004a42:	97089607          	.insn	4, 0x97089607
80004a46:	9809                	.insn	2, 0x9809
80004a48:	440a                	.insn	2, 0x440a
80004a4a:	080c                	.insn	2, 0x080c
80004a4c:	0000                	.insn	2, 0x
80004a4e:	0000                	.insn	2, 0x
80004a50:	001c                	.insn	2, 0x001c
80004a52:	0000                	.insn	2, 0x
80004a54:	0204                	.insn	2, 0x0204
80004a56:	0000                	.insn	2, 0x
80004a58:	d5f8                	.insn	2, 0xd5f8
80004a5a:	ffff                	.insn	2, 0xffff
80004a5c:	0038                	.insn	2, 0x0038
80004a5e:	0000                	.insn	2, 0x
80004a60:	4400                	.insn	2, 0x4400
80004a62:	100e                	.insn	2, 0x100e
80004a64:	8148                	.insn	2, 0x8148
80004a66:	8801                	.insn	2, 0x8801
80004a68:	4402                	.insn	2, 0x4402
80004a6a:	080c                	.insn	2, 0x080c
80004a6c:	0000                	.insn	2, 0x
80004a6e:	0000                	.insn	2, 0x
80004a70:	001c                	.insn	2, 0x001c
80004a72:	0000                	.insn	2, 0x
80004a74:	0224                	.insn	2, 0x0224
80004a76:	0000                	.insn	2, 0x
80004a78:	d610                	.insn	2, 0xd610
80004a7a:	ffff                	.insn	2, 0xffff
80004a7c:	0038                	.insn	2, 0x0038
80004a7e:	0000                	.insn	2, 0x
80004a80:	4400                	.insn	2, 0x4400
80004a82:	100e                	.insn	2, 0x100e
80004a84:	8148                	.insn	2, 0x8148
80004a86:	8801                	.insn	2, 0x8801
80004a88:	4402                	.insn	2, 0x4402
80004a8a:	080c                	.insn	2, 0x080c
80004a8c:	0000                	.insn	2, 0x
80004a8e:	0000                	.insn	2, 0x
80004a90:	002c                	.insn	2, 0x002c
80004a92:	0000                	.insn	2, 0x
80004a94:	0244                	.insn	2, 0x0244
80004a96:	0000                	.insn	2, 0x
80004a98:	d628                	.insn	2, 0xd628
80004a9a:	ffff                	.insn	2, 0xffff
80004a9c:	0264                	.insn	2, 0x0264
80004a9e:	0000                	.insn	2, 0x
80004aa0:	4400                	.insn	2, 0x4400
80004aa2:	500e                	.insn	2, 0x500e
80004aa4:	8168                	.insn	2, 0x8168
80004aa6:	8801                	.insn	2, 0x8801
80004aa8:	8902                	.insn	2, 0x8902
80004aaa:	93049203          	lh	tp,-1744(s1)
80004aae:	9405                	.insn	2, 0x9405
80004ab0:	9506                	.insn	2, 0x9506
80004ab2:	97089607          	.insn	4, 0x97089607
80004ab6:	9809                	.insn	2, 0x9809
80004ab8:	440a                	.insn	2, 0x440a
80004aba:	080c                	.insn	2, 0x080c
80004abc:	0000                	.insn	2, 0x
80004abe:	0000                	.insn	2, 0x
80004ac0:	0030                	.insn	2, 0x0030
80004ac2:	0000                	.insn	2, 0x
80004ac4:	0274                	.insn	2, 0x0274
80004ac6:	0000                	.insn	2, 0x
80004ac8:	d85c                	.insn	2, 0xd85c
80004aca:	ffff                	.insn	2, 0xffff
80004acc:	0354                	.insn	2, 0x0354
80004ace:	0000                	.insn	2, 0x
80004ad0:	4400                	.insn	2, 0x4400
80004ad2:	400e                	.insn	2, 0x400e
80004ad4:	8174                	.insn	2, 0x8174
80004ad6:	8801                	.insn	2, 0x8801
80004ad8:	8902                	.insn	2, 0x8902
80004ada:	93049203          	lh	tp,-1744(s1)
80004ade:	9405                	.insn	2, 0x9405
80004ae0:	9506                	.insn	2, 0x9506
80004ae2:	97089607          	.insn	4, 0x97089607
80004ae6:	9809                	.insn	2, 0x9809
80004ae8:	990a                	.insn	2, 0x990a
80004aea:	9b0c9a0b          	.insn	4, 0x9b0c9a0b
80004aee:	440d                	.insn	2, 0x440d
80004af0:	080c                	.insn	2, 0x080c
80004af2:	0000                	.insn	2, 0x
80004af4:	0024                	.insn	2, 0x0024
80004af6:	0000                	.insn	2, 0x
80004af8:	02a8                	.insn	2, 0x02a8
80004afa:	0000                	.insn	2, 0x
80004afc:	db7c                	.insn	2, 0xdb7c
80004afe:	ffff                	.insn	2, 0xffff
80004b00:	00ac                	.insn	2, 0x00ac
80004b02:	0000                	.insn	2, 0x
80004b04:	4400                	.insn	2, 0x4400
80004b06:	200e                	.insn	2, 0x200e
80004b08:	8158                	.insn	2, 0x8158
80004b0a:	8801                	.insn	2, 0x8801
80004b0c:	8902                	.insn	2, 0x8902
80004b0e:	93049203          	lh	tp,-1744(s1)
80004b12:	9405                	.insn	2, 0x9405
80004b14:	4406                	.insn	2, 0x4406
80004b16:	080c                	.insn	2, 0x080c
80004b18:	0000                	.insn	2, 0x
80004b1a:	0000                	.insn	2, 0x
80004b1c:	0028                	.insn	2, 0x0028
80004b1e:	0000                	.insn	2, 0x
80004b20:	02d0                	.insn	2, 0x02d0
80004b22:	0000                	.insn	2, 0x
80004b24:	dc00                	.insn	2, 0xdc00
80004b26:	ffff                	.insn	2, 0xffff
80004b28:	0298                	.insn	2, 0x0298
80004b2a:	0000                	.insn	2, 0x
80004b2c:	4400                	.insn	2, 0x4400
80004b2e:	300e                	.insn	2, 0x300e
80004b30:	8164                	.insn	2, 0x8164
80004b32:	8801                	.insn	2, 0x8801
80004b34:	8902                	.insn	2, 0x8902
80004b36:	93049203          	lh	tp,-1744(s1)
80004b3a:	9405                	.insn	2, 0x9405
80004b3c:	9506                	.insn	2, 0x9506
80004b3e:	97089607          	.insn	4, 0x97089607
80004b42:	4409                	.insn	2, 0x4409
80004b44:	080c                	.insn	2, 0x080c
80004b46:	0000                	.insn	2, 0x
80004b48:	001c                	.insn	2, 0x001c
80004b4a:	0000                	.insn	2, 0x
80004b4c:	02fc                	.insn	2, 0x02fc
80004b4e:	0000                	.insn	2, 0x
80004b50:	de6c                	.insn	2, 0xde6c
80004b52:	ffff                	.insn	2, 0xffff
80004b54:	002c                	.insn	2, 0x002c
80004b56:	0000                	.insn	2, 0x
80004b58:	4400                	.insn	2, 0x4400
80004b5a:	100e                	.insn	2, 0x100e
80004b5c:	8148                	.insn	2, 0x8148
80004b5e:	8801                	.insn	2, 0x8801
80004b60:	4402                	.insn	2, 0x4402
80004b62:	080c                	.insn	2, 0x080c
80004b64:	0000                	.insn	2, 0x
80004b66:	0000                	.insn	2, 0x
80004b68:	002c                	.insn	2, 0x002c
80004b6a:	0000                	.insn	2, 0x
80004b6c:	031c                	.insn	2, 0x031c
80004b6e:	0000                	.insn	2, 0x
80004b70:	de78                	.insn	2, 0xde78
80004b72:	ffff                	.insn	2, 0xffff
80004b74:	0144                	.insn	2, 0x0144
80004b76:	0000                	.insn	2, 0x
80004b78:	4400                	.insn	2, 0x4400
80004b7a:	400e                	.insn	2, 0x400e
80004b7c:	816c                	.insn	2, 0x816c
80004b7e:	8801                	.insn	2, 0x8801
80004b80:	8902                	.insn	2, 0x8902
80004b82:	93049203          	lh	tp,-1744(s1)
80004b86:	9405                	.insn	2, 0x9405
80004b88:	9506                	.insn	2, 0x9506
80004b8a:	97089607          	.insn	4, 0x97089607
80004b8e:	9809                	.insn	2, 0x9809
80004b90:	990a                	.insn	2, 0x990a
80004b92:	080c440b          	.insn	4, 0x080c440b
80004b96:	0000                	.insn	2, 0x
80004b98:	0024                	.insn	2, 0x0024
80004b9a:	0000                	.insn	2, 0x
80004b9c:	034c                	.insn	2, 0x034c
80004b9e:	0000                	.insn	2, 0x
80004ba0:	df8c                	.insn	2, 0xdf8c
80004ba2:	ffff                	.insn	2, 0xffff
80004ba4:	00e8                	.insn	2, 0x00e8
80004ba6:	0000                	.insn	2, 0x
80004ba8:	4400                	.insn	2, 0x4400
80004baa:	a00e                	.insn	2, 0xa00e
80004bac:	5801                	.insn	2, 0x5801
80004bae:	0181                	.insn	2, 0x0181
80004bb0:	0288                	.insn	2, 0x0288
80004bb2:	0389                	.insn	2, 0x0389
80004bb4:	0492                	.insn	2, 0x0492
80004bb6:	06940593          	addi	a1,s0,105 # 35373069 <.Lline_table_start2+0x35371cca>
80004bba:	0c44                	.insn	2, 0x0c44
80004bbc:	0008                	.insn	2, 0x0008
80004bbe:	0000                	.insn	2, 0x
80004bc0:	001c                	.insn	2, 0x001c
80004bc2:	0000                	.insn	2, 0x
80004bc4:	0374                	.insn	2, 0x0374
80004bc6:	0000                	.insn	2, 0x
80004bc8:	e04c                	.insn	2, 0xe04c
80004bca:	ffff                	.insn	2, 0xffff
80004bcc:	0238                	.insn	2, 0x0238
80004bce:	0000                	.insn	2, 0x
80004bd0:	4400                	.insn	2, 0x4400
80004bd2:	100e                	.insn	2, 0x100e
80004bd4:	8148                	.insn	2, 0x8148
80004bd6:	8801                	.insn	2, 0x8801
80004bd8:	4402                	.insn	2, 0x4402
80004bda:	080c                	.insn	2, 0x080c
80004bdc:	0000                	.insn	2, 0x
80004bde:	0000                	.insn	2, 0x
80004be0:	001c                	.insn	2, 0x001c
80004be2:	0000                	.insn	2, 0x
80004be4:	0394                	.insn	2, 0x0394
80004be6:	0000                	.insn	2, 0x
80004be8:	e264                	.insn	2, 0xe264
80004bea:	ffff                	.insn	2, 0xffff
80004bec:	0050                	.insn	2, 0x0050
80004bee:	0000                	.insn	2, 0x
80004bf0:	4400                	.insn	2, 0x4400
80004bf2:	100e                	.insn	2, 0x100e
80004bf4:	8148                	.insn	2, 0x8148
80004bf6:	8801                	.insn	2, 0x8801
80004bf8:	4402                	.insn	2, 0x4402
80004bfa:	080c                	.insn	2, 0x080c
80004bfc:	0000                	.insn	2, 0x
80004bfe:	0000                	.insn	2, 0x
80004c00:	001c                	.insn	2, 0x001c
80004c02:	0000                	.insn	2, 0x
80004c04:	03b4                	.insn	2, 0x03b4
80004c06:	0000                	.insn	2, 0x
80004c08:	e294                	.insn	2, 0xe294
80004c0a:	ffff                	.insn	2, 0xffff
80004c0c:	00f0                	.insn	2, 0x00f0
80004c0e:	0000                	.insn	2, 0x
80004c10:	4400                	.insn	2, 0x4400
80004c12:	900e                	.insn	2, 0x900e
80004c14:	4801                	.insn	2, 0x4801
80004c16:	0181                	.insn	2, 0x0181
80004c18:	0288                	.insn	2, 0x0288
80004c1a:	0c44                	.insn	2, 0x0c44
80004c1c:	0008                	.insn	2, 0x0008
80004c1e:	0000                	.insn	2, 0x
80004c20:	001c                	.insn	2, 0x001c
80004c22:	0000                	.insn	2, 0x
80004c24:	03d4                	.insn	2, 0x03d4
80004c26:	0000                	.insn	2, 0x
80004c28:	e364                	.insn	2, 0xe364
80004c2a:	ffff                	.insn	2, 0xffff
80004c2c:	0084                	.insn	2, 0x0084
80004c2e:	0000                	.insn	2, 0x
80004c30:	4400                	.insn	2, 0x4400
80004c32:	900e                	.insn	2, 0x900e
80004c34:	4801                	.insn	2, 0x4801
80004c36:	0181                	.insn	2, 0x0181
80004c38:	0288                	.insn	2, 0x0288
80004c3a:	0c44                	.insn	2, 0x0c44
80004c3c:	0008                	.insn	2, 0x0008
80004c3e:	0000                	.insn	2, 0x
80004c40:	001c                	.insn	2, 0x001c
80004c42:	0000                	.insn	2, 0x
80004c44:	03f4                	.insn	2, 0x03f4
80004c46:	0000                	.insn	2, 0x
80004c48:	e3c8                	.insn	2, 0xe3c8
80004c4a:	ffff                	.insn	2, 0xffff
80004c4c:	0084                	.insn	2, 0x0084
80004c4e:	0000                	.insn	2, 0x
80004c50:	4400                	.insn	2, 0x4400
80004c52:	900e                	.insn	2, 0x900e
80004c54:	4801                	.insn	2, 0x4801
80004c56:	0181                	.insn	2, 0x0181
80004c58:	0288                	.insn	2, 0x0288
80004c5a:	0c44                	.insn	2, 0x0c44
80004c5c:	0008                	.insn	2, 0x0008
80004c5e:	0000                	.insn	2, 0x
80004c60:	001c                	.insn	2, 0x001c
80004c62:	0000                	.insn	2, 0x
80004c64:	0414                	.insn	2, 0x0414
80004c66:	0000                	.insn	2, 0x
80004c68:	e42c                	.insn	2, 0xe42c
80004c6a:	ffff                	.insn	2, 0xffff
80004c6c:	00f8                	.insn	2, 0x00f8
80004c6e:	0000                	.insn	2, 0x
80004c70:	4400                	.insn	2, 0x4400
80004c72:	900e                	.insn	2, 0x900e
80004c74:	4801                	.insn	2, 0x4801
80004c76:	0181                	.insn	2, 0x0181
80004c78:	0288                	.insn	2, 0x0288
80004c7a:	0c44                	.insn	2, 0x0c44
80004c7c:	0008                	.insn	2, 0x0008
80004c7e:	0000                	.insn	2, 0x
80004c80:	001c                	.insn	2, 0x001c
80004c82:	0000                	.insn	2, 0x
80004c84:	0434                	.insn	2, 0x0434
80004c86:	0000                	.insn	2, 0x
80004c88:	e504                	.insn	2, 0xe504
80004c8a:	ffff                	.insn	2, 0xffff
80004c8c:	0030                	.insn	2, 0x0030
80004c8e:	0000                	.insn	2, 0x
80004c90:	4400                	.insn	2, 0x4400
80004c92:	100e                	.insn	2, 0x100e
80004c94:	8148                	.insn	2, 0x8148
80004c96:	8801                	.insn	2, 0x8801
80004c98:	4402                	.insn	2, 0x4402
80004c9a:	080c                	.insn	2, 0x080c
80004c9c:	0000                	.insn	2, 0x
80004c9e:	0000                	.insn	2, 0x
80004ca0:	0020                	.insn	2, 0x0020
80004ca2:	0000                	.insn	2, 0x
80004ca4:	0454                	.insn	2, 0x0454
80004ca6:	0000                	.insn	2, 0x
80004ca8:	e514                	.insn	2, 0xe514
80004caa:	ffff                	.insn	2, 0xffff
80004cac:	01c4                	.insn	2, 0x01c4
80004cae:	0000                	.insn	2, 0x
80004cb0:	4400                	.insn	2, 0x4400
80004cb2:	200e                	.insn	2, 0x200e
80004cb4:	8150                	.insn	2, 0x8150
80004cb6:	8801                	.insn	2, 0x8801
80004cb8:	8902                	.insn	2, 0x8902
80004cba:	44049203          	lh	tp,1088(s1)
80004cbe:	080c                	.insn	2, 0x080c
80004cc0:	0000                	.insn	2, 0x
80004cc2:	0000                	.insn	2, 0x
80004cc4:	001c                	.insn	2, 0x001c
80004cc6:	0000                	.insn	2, 0x
80004cc8:	0478                	.insn	2, 0x0478
80004cca:	0000                	.insn	2, 0x
80004ccc:	e6b4                	.insn	2, 0xe6b4
80004cce:	ffff                	.insn	2, 0xffff
80004cd0:	002c                	.insn	2, 0x002c
80004cd2:	0000                	.insn	2, 0x
80004cd4:	4400                	.insn	2, 0x4400
80004cd6:	100e                	.insn	2, 0x100e
80004cd8:	8148                	.insn	2, 0x8148
80004cda:	8801                	.insn	2, 0x8801
80004cdc:	4402                	.insn	2, 0x4402
80004cde:	080c                	.insn	2, 0x080c
80004ce0:	0000                	.insn	2, 0x
80004ce2:	0000                	.insn	2, 0x
80004ce4:	001c                	.insn	2, 0x001c
80004ce6:	0000                	.insn	2, 0x
80004ce8:	0498                	.insn	2, 0x0498
80004cea:	0000                	.insn	2, 0x
80004cec:	e6c0                	.insn	2, 0xe6c0
80004cee:	ffff                	.insn	2, 0xffff
80004cf0:	0034                	.insn	2, 0x0034
80004cf2:	0000                	.insn	2, 0x
80004cf4:	4400                	.insn	2, 0x4400
80004cf6:	100e                	.insn	2, 0x100e
80004cf8:	8148                	.insn	2, 0x8148
80004cfa:	8801                	.insn	2, 0x8801
80004cfc:	4402                	.insn	2, 0x4402
80004cfe:	080c                	.insn	2, 0x080c
80004d00:	0000                	.insn	2, 0x
80004d02:	0000                	.insn	2, 0x
80004d04:	001c                	.insn	2, 0x001c
80004d06:	0000                	.insn	2, 0x
80004d08:	04b8                	.insn	2, 0x04b8
80004d0a:	0000                	.insn	2, 0x
80004d0c:	e6d4                	.insn	2, 0xe6d4
80004d0e:	ffff                	.insn	2, 0xffff
80004d10:	00a8                	.insn	2, 0x00a8
80004d12:	0000                	.insn	2, 0x
80004d14:	4400                	.insn	2, 0x4400
80004d16:	100e                	.insn	2, 0x100e
80004d18:	8148                	.insn	2, 0x8148
80004d1a:	8801                	.insn	2, 0x8801
80004d1c:	4402                	.insn	2, 0x4402
80004d1e:	080c                	.insn	2, 0x080c
80004d20:	0000                	.insn	2, 0x
80004d22:	0000                	.insn	2, 0x
80004d24:	001c                	.insn	2, 0x001c
80004d26:	0000                	.insn	2, 0x
80004d28:	04d8                	.insn	2, 0x04d8
80004d2a:	0000                	.insn	2, 0x
80004d2c:	e75c                	.insn	2, 0xe75c
80004d2e:	ffff                	.insn	2, 0xffff
80004d30:	0110                	.insn	2, 0x0110
80004d32:	0000                	.insn	2, 0x
80004d34:	4400                	.insn	2, 0x4400
80004d36:	100e                	.insn	2, 0x100e
80004d38:	8148                	.insn	2, 0x8148
80004d3a:	8801                	.insn	2, 0x8801
80004d3c:	4402                	.insn	2, 0x4402
80004d3e:	080c                	.insn	2, 0x080c
	...

Disassembly of section .comment:

00000000 <.comment>:
   0:	4c00                	.insn	2, 0x4c00
   2:	6e69                	.insn	2, 0x6e69
   4:	3a72656b          	.insn	4, 0x3a72656b
   8:	4c20                	.insn	2, 0x4c20
   a:	444c                	.insn	2, 0x444c
   c:	3120                	.insn	2, 0x3120
   e:	2e39                	.insn	2, 0x2e39
  10:	2e31                	.insn	2, 0x2e31
  12:	2034                	.insn	2, 0x2034
  14:	2f28                	.insn	2, 0x2f28
  16:	63656863          	bltu	a0,s6,646 <.Lline_table_start1+0x2f0>
  1a:	74756f6b          	.insn	4, 0x74756f6b
  1e:	6372732f          	.insn	4, 0x6372732f
  22:	766c6c2f          	.insn	4, 0x766c6c2f
  26:	2d6d                	.insn	2, 0x2d6d
  28:	7270                	.insn	2, 0x7270
  2a:	63656a6f          	jal	s4,56660 <.Lline_table_start2+0x552c1>
  2e:	2f74                	.insn	2, 0x2f74
  30:	6c6c                	.insn	2, 0x6c6c
  32:	6d76                	.insn	2, 0x6d76
  34:	3120                	.insn	2, 0x3120
  36:	3430                	.insn	2, 0x3430
  38:	3064                	.insn	2, 0x3064
  3a:	3164                	.insn	2, 0x3164
  3c:	6336                	.insn	2, 0x6336
  3e:	63376333          	.insn	4, 0x63376333
  42:	66656633          	.insn	4, 0x66656633
  46:	3432                	.insn	2, 0x3432
  48:	65663533          	.insn	4, 0x65663533
  4c:	3666                	.insn	2, 0x3666
  4e:	6665                	.insn	2, 0x6665
  50:	3262                	.insn	2, 0x3262
  52:	3564                	.insn	2, 0x3564
  54:	30376237          	lui	tp,0x30376
  58:	6666                	.insn	2, 0x6666
  5a:	3766                	.insn	2, 0x3766
  5c:	72002933          	.insn	4, 0x72002933
  60:	7375                	.insn	2, 0x7375
  62:	6374                	.insn	2, 0x6374
  64:	7620                	.insn	2, 0x7620
  66:	7265                	.insn	2, 0x7265
  68:	6e6f6973          	.insn	4, 0x6e6f6973
  6c:	3120                	.insn	2, 0x3120
  6e:	382e                	.insn	2, 0x382e
  70:	2e35                	.insn	2, 0x2e35
  72:	2d30                	.insn	2, 0x2d30
  74:	696e                	.insn	2, 0x696e
  76:	6c746867          	.insn	4, 0x6c746867
  7a:	2079                	.insn	2, 0x2079
  7c:	3228                	.insn	2, 0x3228
  7e:	6638                	.insn	2, 0x6638
  80:	61623263          	.insn	4, 0x61623263
  84:	32203137          	lui	sp,0x32203
  88:	3230                	.insn	2, 0x3230
  8a:	2d34                	.insn	2, 0x2d34
  8c:	3131                	.insn	2, 0x3131
  8e:	322d                	.insn	2, 0x322d
  90:	2934                	.insn	2, 0x2934
	...

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes>:
   0:	3341                	.insn	2, 0x3341
   2:	0000                	.insn	2, 0x
   4:	7200                	.insn	2, 0x7200
   6:	7369                	.insn	2, 0x7369
   8:	01007663          	bgeu	zero,a6,14 <.Lline_table_start0+0x14>
   c:	0029                	.insn	2, 0x0029
   e:	0000                	.insn	2, 0x
  10:	1004                	.insn	2, 0x1004
  12:	7205                	.insn	2, 0x7205
  14:	3376                	.insn	2, 0x3376
  16:	6932                	.insn	2, 0x6932
  18:	7032                	.insn	2, 0x7032
  1a:	5f31                	.insn	2, 0x5f31
  1c:	326d                	.insn	2, 0x326d
  1e:	3070                	.insn	2, 0x3070
  20:	7a5f 6369 6f62      	.insn	6, 0x6f6263697a5f
  26:	316d                	.insn	2, 0x316d
  28:	3070                	.insn	2, 0x3070
  2a:	7a5f 6d6d 6c75      	.insn	6, 0x6c756d6d7a5f
  30:	7031                	.insn	2, 0x7031
  32:	0030                	.insn	2, 0x0030
