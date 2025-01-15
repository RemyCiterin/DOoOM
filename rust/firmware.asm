
target/riscv32im-unknown-none-elf/release/SuperOS:     file format elf32-littleriscv


Disassembly of section .text:

80000000 <_start>:
80000000:	00004297          	auipc	t0,0x4
80000004:	80828293          	addi	t0,t0,-2040 # 80003808 <__bss_start>

80000008 <.Lpcrel_hi1>:
80000008:	00114317          	auipc	t1,0x114
8000000c:	83030313          	addi	t1,t1,-2000 # 80113838 <__bss_end>
80000010:	0062f863          	bgeu	t0,t1,80000020 <.Lpcrel_hi2>

80000014 <.bss_zero_loop>:
80000014:	0002a023          	sw	zero,0(t0)
80000018:	00428293          	addi	t0,t0,4
8000001c:	fe62ece3          	bltu	t0,t1,80000014 <.bss_zero_loop>

80000020 <.Lpcrel_hi2>:
80000020:	00014117          	auipc	sp,0x14
80000024:	80010113          	addi	sp,sp,-2048 # 80013820 <_ZN7SuperOS6kalloc13KALLOC_BUFFER17h2f62f31b270c2cc8E>
80000028:	420000ef          	jal	80000448 <kernel_main>

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

800001d4 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h347a6d12d8f88ec4E>:
800001d4:	00052503          	lw	a0,0(a0)
800001d8:	00052503          	lw	a0,0(a0)
800001dc:	00002317          	auipc	t1,0x2
800001e0:	95c30067          	jr	-1700(t1) # 80001b38 <_ZN4core3fmt17pointer_fmt_inner17h8c7f2eac4b33a418E>

800001e4 <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17hb03b8688aae70357E>:
800001e4:	00052503          	lw	a0,0(a0)
800001e8:	00001317          	auipc	t1,0x1
800001ec:	c6c30067          	jr	-916(t1) # 80000e54 <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h437e60b278116f80E>

800001f0 <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE>:
800001f0:	ff010113          	addi	sp,sp,-16
800001f4:	08000513          	li	a0,128
800001f8:	00012623          	sw	zero,12(sp)
800001fc:	00a5f863          	bgeu	a1,a0,8000020c <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE+0x1c>
80000200:	00d10513          	addi	a0,sp,13
80000204:	00b10623          	sb	a1,12(sp)
80000208:	0a00006f          	j	800002a8 <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE+0xb8>
8000020c:	00b5d513          	srli	a0,a1,0xb
80000210:	02051263          	bnez	a0,80000234 <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE+0x44>
80000214:	00e10513          	addi	a0,sp,14
80000218:	0065d613          	srli	a2,a1,0x6
8000021c:	0c066613          	ori	a2,a2,192
80000220:	00c10623          	sb	a2,12(sp)
80000224:	03f5f593          	andi	a1,a1,63
80000228:	08058593          	addi	a1,a1,128
8000022c:	00b106a3          	sb	a1,13(sp)
80000230:	0780006f          	j	800002a8 <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE+0xb8>
80000234:	0105d513          	srli	a0,a1,0x10
80000238:	02051a63          	bnez	a0,8000026c <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE+0x7c>
8000023c:	00f10513          	addi	a0,sp,15
80000240:	00c5d613          	srli	a2,a1,0xc
80000244:	0e066613          	ori	a2,a2,224
80000248:	00c10623          	sb	a2,12(sp)
8000024c:	01459613          	slli	a2,a1,0x14
80000250:	01a65613          	srli	a2,a2,0x1a
80000254:	08060613          	addi	a2,a2,128
80000258:	00c106a3          	sb	a2,13(sp)
8000025c:	03f5f593          	andi	a1,a1,63
80000260:	08058593          	addi	a1,a1,128
80000264:	00b10723          	sb	a1,14(sp)
80000268:	0400006f          	j	800002a8 <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE+0xb8>
8000026c:	01010513          	addi	a0,sp,16
80000270:	0125d613          	srli	a2,a1,0x12
80000274:	0f066613          	ori	a2,a2,240
80000278:	00c10623          	sb	a2,12(sp)
8000027c:	00e59613          	slli	a2,a1,0xe
80000280:	01a65613          	srli	a2,a2,0x1a
80000284:	08060613          	addi	a2,a2,128
80000288:	00c106a3          	sb	a2,13(sp)
8000028c:	01459613          	slli	a2,a1,0x14
80000290:	01a65613          	srli	a2,a2,0x1a
80000294:	08060613          	addi	a2,a2,128
80000298:	00c10723          	sb	a2,14(sp)
8000029c:	03f5f593          	andi	a1,a1,63
800002a0:	08058593          	addi	a1,a1,128
800002a4:	00b107a3          	sb	a1,15(sp)
800002a8:	00c10593          	addi	a1,sp,12
800002ac:	10000637          	lui	a2,0x10000
800002b0:	00564683          	lbu	a3,5(a2) # 10000005 <.Lline_table_start2+0xfffec66>
800002b4:	0406f693          	andi	a3,a3,64
800002b8:	02068063          	beqz	a3,800002d8 <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE+0xe8>
800002bc:	0005c683          	lbu	a3,0(a1)
800002c0:	00158593          	addi	a1,a1,1
800002c4:	00d60023          	sb	a3,0(a2)
800002c8:	fea594e3          	bne	a1,a0,800002b0 <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE+0xc0>
800002cc:	00000513          	li	a0,0
800002d0:	01010113          	addi	sp,sp,16
800002d4:	00008067          	ret
800002d8:	0000006f          	j	800002d8 <_ZN4core3fmt5Write10write_char17hda2127b3c6ce6bcfE+0xe8>

800002dc <_ZN4core3fmt5Write9write_fmt17h7c4a0b5b8836a17bE>:
800002dc:	80003637          	lui	a2,0x80003
800002e0:	11860613          	addi	a2,a2,280 # 80003118 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.23>
800002e4:	00058693          	mv	a3,a1
800002e8:	00060593          	mv	a1,a2
800002ec:	00068613          	mv	a2,a3
800002f0:	00001317          	auipc	t1,0x1
800002f4:	f2430067          	jr	-220(t1) # 80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>

800002f8 <_ZN4core9panicking13assert_failed17h10961ca432d19960E>:
800002f8:	ff010113          	addi	sp,sp,-16
800002fc:	00060793          	mv	a5,a2
80000300:	00a12423          	sw	a0,8(sp)
80000304:	00b12623          	sw	a1,12(sp)
80000308:	80003637          	lui	a2,0x80003
8000030c:	00060613          	mv	a2,a2
80000310:	80003837          	lui	a6,0x80003
80000314:	21080813          	addi	a6,a6,528 # 80003210 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.39>
80000318:	00810593          	addi	a1,sp,8
8000031c:	00c10693          	addi	a3,sp,12
80000320:	00000513          	li	a0,0
80000324:	00060713          	mv	a4,a2
80000328:	00001097          	auipc	ra,0x1
8000032c:	cec080e7          	jalr	-788(ra) # 80001014 <_ZN4core9panicking19assert_failed_inner17h95e43b28e148b8c7E>

80000330 <_ZN53_$LT$core..fmt..Error$u20$as$u20$core..fmt..Debug$GT$3fmt17hbd809102de2ae4f6E>:
80000330:	800036b7          	lui	a3,0x80003
80000334:	01068693          	addi	a3,a3,16 # 80003010 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.1>
80000338:	00500613          	li	a2,5
8000033c:	00058513          	mv	a0,a1
80000340:	00068593          	mv	a1,a3
80000344:	00001317          	auipc	t1,0x1
80000348:	7c830067          	jr	1992(t1) # 80001b0c <_ZN4core3fmt9Formatter9write_str17h377b2dc3ce79ad33E>

8000034c <_ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17hf95f0320af548cf6E>:
8000034c:	00054503          	lbu	a0,0(a0)
80000350:	00251513          	slli	a0,a0,0x2
80000354:	80003637          	lui	a2,0x80003
80000358:	2dc60613          	addi	a2,a2,732 # 800032dc <.Lswitch.table._ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17hf95f0320af548cf6E>
8000035c:	00a60633          	add	a2,a2,a0
80000360:	00062603          	lw	a2,0(a2)
80000364:	800036b7          	lui	a3,0x80003
80000368:	31868693          	addi	a3,a3,792 # 80003318 <.Lswitch.table._ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17hf95f0320af548cf6E.1>
8000036c:	00a68533          	add	a0,a3,a0
80000370:	00052683          	lw	a3,0(a0)
80000374:	00058513          	mv	a0,a1
80000378:	00068593          	mv	a1,a3
8000037c:	00001317          	auipc	t1,0x1
80000380:	79030067          	jr	1936(t1) # 80001b0c <_ZN4core3fmt9Formatter9write_str17h377b2dc3ce79ad33E>

80000384 <_ZN61_$LT$SuperOS..printer..Writer$u20$as$u20$core..fmt..Write$GT$9write_str17h7259a10ec9ff8d89E>:
80000384:	02060463          	beqz	a2,800003ac <_ZN61_$LT$SuperOS..printer..Writer$u20$as$u20$core..fmt..Write$GT$9write_str17h7259a10ec9ff8d89E+0x28>
80000388:	10000537          	lui	a0,0x10000
8000038c:	00554683          	lbu	a3,5(a0) # 10000005 <.Lline_table_start2+0xfffec66>
80000390:	0406f693          	andi	a3,a3,64
80000394:	02068063          	beqz	a3,800003b4 <_ZN61_$LT$SuperOS..printer..Writer$u20$as$u20$core..fmt..Write$GT$9write_str17h7259a10ec9ff8d89E+0x30>
80000398:	0005c683          	lbu	a3,0(a1)
8000039c:	00158593          	addi	a1,a1,1
800003a0:	fff60613          	addi	a2,a2,-1
800003a4:	00d50023          	sb	a3,0(a0)
800003a8:	fe0612e3          	bnez	a2,8000038c <_ZN61_$LT$SuperOS..printer..Writer$u20$as$u20$core..fmt..Write$GT$9write_str17h7259a10ec9ff8d89E+0x8>
800003ac:	00000513          	li	a0,0
800003b0:	00008067          	ret
800003b4:	0000006f          	j	800003b4 <_ZN61_$LT$SuperOS..printer..Writer$u20$as$u20$core..fmt..Write$GT$9write_str17h7259a10ec9ff8d89E+0x30>

800003b8 <rust_begin_unwind>:
800003b8:	fd010113          	addi	sp,sp,-48
800003bc:	02112623          	sw	ra,44(sp)
800003c0:	00a12223          	sw	a0,4(sp)
800003c4:	00410513          	addi	a0,sp,4
800003c8:	02a12023          	sw	a0,32(sp)
800003cc:	80000537          	lui	a0,0x80000
800003d0:	1e450513          	addi	a0,a0,484 # 800001e4 <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17hb03b8688aae70357E>
800003d4:	02a12223          	sw	a0,36(sp)
800003d8:	80003537          	lui	a0,0x80003
800003dc:	29450513          	addi	a0,a0,660 # 80003294 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.59>
800003e0:	00a12423          	sw	a0,8(sp)
800003e4:	00200513          	li	a0,2
800003e8:	00a12623          	sw	a0,12(sp)
800003ec:	00012c23          	sw	zero,24(sp)
800003f0:	02010513          	addi	a0,sp,32
800003f4:	00a12823          	sw	a0,16(sp)
800003f8:	00100513          	li	a0,1
800003fc:	00a12a23          	sw	a0,20(sp)
80000400:	800035b7          	lui	a1,0x80003
80000404:	11858593          	addi	a1,a1,280 # 80003118 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.23>
80000408:	02b10513          	addi	a0,sp,43
8000040c:	00810613          	addi	a2,sp,8
80000410:	00001097          	auipc	ra,0x1
80000414:	e04080e7          	jalr	-508(ra) # 80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>
80000418:	00051463          	bnez	a0,80000420 <rust_begin_unwind+0x68>
8000041c:	0000006f          	j	8000041c <rust_begin_unwind+0x64>
80000420:	80003537          	lui	a0,0x80003
80000424:	14050513          	addi	a0,a0,320 # 80003140 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.25>
80000428:	800036b7          	lui	a3,0x80003
8000042c:	13068693          	addi	a3,a3,304 # 80003130 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.24>
80000430:	80003737          	lui	a4,0x80003
80000434:	17c70713          	addi	a4,a4,380 # 8000317c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.27>
80000438:	02b00593          	li	a1,43
8000043c:	02b10613          	addi	a2,sp,43
80000440:	00001097          	auipc	ra,0x1
80000444:	d20080e7          	jalr	-736(ra) # 80001160 <_ZN4core6result13unwrap_failed17hea2e62a5f959197bE>

80000448 <kernel_main>:
80000448:	f1010113          	addi	sp,sp,-240
8000044c:	0e112623          	sw	ra,236(sp)
80000450:	0e812423          	sw	s0,232(sp)
80000454:	0e912223          	sw	s1,228(sp)
80000458:	0f212023          	sw	s2,224(sp)
8000045c:	0d312e23          	sw	s3,220(sp)
80000460:	0d412c23          	sw	s4,216(sp)
80000464:	0d512a23          	sw	s5,212(sp)
80000468:	0d612823          	sw	s6,208(sp)
8000046c:	0d712623          	sw	s7,204(sp)
80000470:	0d812423          	sw	s8,200(sp)
80000474:	0d912223          	sw	s9,196(sp)
80000478:	0da12023          	sw	s10,192(sp)
8000047c:	0bb12e23          	sw	s11,188(sp)
80000480:	100004b7          	lui	s1,0x10000
80000484:	0054c503          	lbu	a0,5(s1) # 10000005 <.Lline_table_start2+0xfffec66>
80000488:	04057513          	andi	a0,a0,64
8000048c:	0a050a63          	beqz	a0,80000540 <kernel_main+0xf8>
80000490:	0054c503          	lbu	a0,5(s1)
80000494:	07300593          	li	a1,115
80000498:	04057513          	andi	a0,a0,64
8000049c:	00b48023          	sb	a1,0(s1)
800004a0:	0a050063          	beqz	a0,80000540 <kernel_main+0xf8>
800004a4:	10000537          	lui	a0,0x10000
800004a8:	07400593          	li	a1,116
800004ac:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
800004b0:	0054c583          	lbu	a1,5(s1)
800004b4:	0405f593          	andi	a1,a1,64
800004b8:	08058463          	beqz	a1,80000540 <kernel_main+0xf8>
800004bc:	06100593          	li	a1,97
800004c0:	00b50023          	sb	a1,0(a0)
800004c4:	0054c503          	lbu	a0,5(s1)
800004c8:	04057513          	andi	a0,a0,64
800004cc:	06050a63          	beqz	a0,80000540 <kernel_main+0xf8>
800004d0:	10000537          	lui	a0,0x10000
800004d4:	07200593          	li	a1,114
800004d8:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
800004dc:	0054c583          	lbu	a1,5(s1)
800004e0:	0405f593          	andi	a1,a1,64
800004e4:	04058e63          	beqz	a1,80000540 <kernel_main+0xf8>
800004e8:	07400593          	li	a1,116
800004ec:	00b50023          	sb	a1,0(a0)
800004f0:	0054c503          	lbu	a0,5(s1)
800004f4:	04057513          	andi	a0,a0,64
800004f8:	04050463          	beqz	a0,80000540 <kernel_main+0xf8>
800004fc:	10000537          	lui	a0,0x10000
80000500:	06500593          	li	a1,101
80000504:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000508:	0054c583          	lbu	a1,5(s1)
8000050c:	0405f593          	andi	a1,a1,64
80000510:	02058863          	beqz	a1,80000540 <kernel_main+0xf8>
80000514:	06400593          	li	a1,100
80000518:	00b50023          	sb	a1,0(a0)
8000051c:	0054c503          	lbu	a0,5(s1)
80000520:	04057513          	andi	a0,a0,64
80000524:	00050e63          	beqz	a0,80000540 <kernel_main+0xf8>
80000528:	10000537          	lui	a0,0x10000
8000052c:	02100593          	li	a1,33
80000530:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000534:	0054c583          	lbu	a1,5(s1)
80000538:	0405f593          	andi	a1,a1,64
8000053c:	00059463          	bnez	a1,80000544 <kernel_main+0xfc>
80000540:	0000006f          	j	80000540 <kernel_main+0xf8>
80000544:	00a00593          	li	a1,10
80000548:	00b50023          	sb	a1,0(a0)
8000054c:	801149b7          	lui	s3,0x80114
80000550:	00098993          	mv	s3,s3
80000554:	0b312223          	sw	s3,164(sp)
80000558:	0a410513          	addi	a0,sp,164
8000055c:	08a12623          	sw	a0,140(sp)
80000560:	80002937          	lui	s2,0x80002
80000564:	e5890913          	addi	s2,s2,-424 # 80001e58 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17he02baeedde33e183E>
80000568:	09212823          	sw	s2,144(sp)
8000056c:	80003537          	lui	a0,0x80003
80000570:	26c50513          	addi	a0,a0,620 # 8000326c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.57>
80000574:	00a12223          	sw	a0,4(sp)
80000578:	00200513          	li	a0,2
8000057c:	00a12423          	sw	a0,8(sp)
80000580:	00012a23          	sw	zero,20(sp)
80000584:	08c10513          	addi	a0,sp,140
80000588:	00a12623          	sw	a0,12(sp)
8000058c:	00100513          	li	a0,1
80000590:	00a12823          	sw	a0,16(sp)
80000594:	800035b7          	lui	a1,0x80003
80000598:	11858593          	addi	a1,a1,280 # 80003118 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.23>
8000059c:	0b810513          	addi	a0,sp,184
800005a0:	00410613          	addi	a2,sp,4
800005a4:	00001097          	auipc	ra,0x1
800005a8:	c70080e7          	jalr	-912(ra) # 80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>
800005ac:	74051263          	bnez	a0,80000cf0 <kernel_main+0x8a8>
800005b0:	80004537          	lui	a0,0x80004
800005b4:	81c54583          	lbu	a1,-2020(a0) # 8000381c <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3>
800005b8:	00058463          	beqz	a1,800005c0 <kernel_main+0x178>
800005bc:	0000006f          	j	800005bc <kernel_main+0x174>
800005c0:	00100593          	li	a1,1
800005c4:	80b50e23          	sb	a1,-2020(a0)
800005c8:	00c9da13          	srli	s4,s3,0xc
800005cc:	001a0413          	addi	s0,s4,1
800005d0:	08812423          	sw	s0,136(sp)
800005d4:	00082537          	lui	a0,0x82
800005d8:	fff50513          	addi	a0,a0,-1 # 81fff <.Lline_table_start2+0x80c60>
800005dc:	0aa12a23          	sw	a0,180(sp)
800005e0:	08810513          	addi	a0,sp,136
800005e4:	0aa12223          	sw	a0,164(sp)
800005e8:	0b212423          	sw	s2,168(sp)
800005ec:	0b410513          	addi	a0,sp,180
800005f0:	0aa12623          	sw	a0,172(sp)
800005f4:	0b212823          	sw	s2,176(sp)
800005f8:	00200513          	li	a0,2
800005fc:	00a12223          	sw	a0,4(sp)
80000600:	00a12623          	sw	a0,12(sp)
80000604:	02000613          	li	a2,32
80000608:	00c12a23          	sw	a2,20(sp)
8000060c:	00012c23          	sw	zero,24(sp)
80000610:	00400693          	li	a3,4
80000614:	00d12e23          	sw	a3,28(sp)
80000618:	00300713          	li	a4,3
8000061c:	02e10023          	sb	a4,32(sp)
80000620:	02a12223          	sw	a0,36(sp)
80000624:	02a12623          	sw	a0,44(sp)
80000628:	02c12a23          	sw	a2,52(sp)
8000062c:	02b12c23          	sw	a1,56(sp)
80000630:	02d12e23          	sw	a3,60(sp)
80000634:	04e10023          	sb	a4,64(sp)
80000638:	800035b7          	lui	a1,0x80003
8000063c:	23458593          	addi	a1,a1,564 # 80003234 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.54>
80000640:	08b12623          	sw	a1,140(sp)
80000644:	08e12823          	sw	a4,144(sp)
80000648:	00410593          	addi	a1,sp,4
8000064c:	08b12e23          	sw	a1,156(sp)
80000650:	0aa12023          	sw	a0,160(sp)
80000654:	0a410593          	addi	a1,sp,164
80000658:	08b12a23          	sw	a1,148(sp)
8000065c:	08a12c23          	sw	a0,152(sp)
80000660:	800035b7          	lui	a1,0x80003
80000664:	11858593          	addi	a1,a1,280 # 80003118 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.23>
80000668:	0b810513          	addi	a0,sp,184
8000066c:	08c10613          	addi	a2,sp,140
80000670:	00001097          	auipc	ra,0x1
80000674:	ba4080e7          	jalr	-1116(ra) # 80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>
80000678:	66051c63          	bnez	a0,80000cf0 <kernel_main+0x8a8>
8000067c:	81ffe537          	lui	a0,0x81ffe
80000680:	fff50513          	addi	a0,a0,-1 # 81ffdfff <__kernel_end_phys+0x1ee9fff>
80000684:	07356463          	bltu	a0,s3,800006ec <kernel_main+0x2a4>
80000688:	80004537          	lui	a0,0x80004
8000068c:	81052603          	lw	a2,-2032(a0) # 80003810 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.0>
80000690:	800045b7          	lui	a1,0x80004
80000694:	8145a683          	lw	a3,-2028(a1) # 80003814 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.1>
80000698:	00c41713          	slli	a4,s0,0xc
8000069c:	00c72023          	sw	a2,0(a4)
800006a0:	00d72223          	sw	a3,4(a4)
800006a4:	00100613          	li	a2,1
800006a8:	80c52823          	sw	a2,-2032(a0)
800006ac:	000827b7          	lui	a5,0x82
800006b0:	ffd78693          	addi	a3,a5,-3 # 81ffd <.Lline_table_start2+0x80c5e>
800006b4:	8085aa23          	sw	s0,-2028(a1)
800006b8:	02da0a63          	beq	s4,a3,800006ec <kernel_main+0x2a4>
800006bc:	00ca1693          	slli	a3,s4,0xc
800006c0:	00002737          	lui	a4,0x2
800006c4:	00e686b3          	add	a3,a3,a4
800006c8:	00001737          	lui	a4,0x1
800006cc:	ffe78793          	addi	a5,a5,-2
800006d0:	00c6a023          	sw	a2,0(a3)
800006d4:	0086a223          	sw	s0,4(a3)
800006d8:	80c52823          	sw	a2,-2032(a0)
800006dc:	00140413          	addi	s0,s0,1
800006e0:	8085aa23          	sw	s0,-2028(a1)
800006e4:	00e686b3          	add	a3,a3,a4
800006e8:	fef414e3          	bne	s0,a5,800006d0 <kernel_main+0x288>
800006ec:	80004537          	lui	a0,0x80004
800006f0:	80050e23          	sb	zero,-2020(a0) # 8000381c <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3>
800006f4:	80114737          	lui	a4,0x80114
800006f8:	800145b7          	lui	a1,0x80014
800006fc:	82058593          	addi	a1,a1,-2016 # 80013820 <_ZN7SuperOS6kalloc13KALLOC_BUFFER17h2f62f31b270c2cc8E>
80000700:	00358513          	addi	a0,a1,3
80000704:	ffc57513          	andi	a0,a0,-4
80000708:	001006b7          	lui	a3,0x100
8000070c:	00d58633          	add	a2,a1,a3
80000710:	40a60633          	sub	a2,a2,a0
80000714:	00700793          	li	a5,7
80000718:	82072023          	sw	zero,-2016(a4) # 80113820 <_ZN7SuperOS6kalloc16KERNEL_ALLOCATOR17h86a57417c9c93ec9E>
8000071c:	26c7f063          	bgeu	a5,a2,8000097c <kernel_main+0x534>
80000720:	ffc67713          	andi	a4,a2,-4
80000724:	00e52023          	sw	a4,0(a0)
80000728:	00052223          	sw	zero,4(a0)
8000072c:	00d586b3          	add	a3,a1,a3
80000730:	0ad12223          	sw	a3,164(sp)
80000734:	00c50633          	add	a2,a0,a2
80000738:	08c12623          	sw	a2,140(sp)
8000073c:	24d61e63          	bne	a2,a3,80000998 <kernel_main+0x550>
80000740:	00e50733          	add	a4,a0,a4
80000744:	0035f593          	andi	a1,a1,3
80000748:	80114637          	lui	a2,0x80114
8000074c:	82060613          	addi	a2,a2,-2016 # 80113820 <_ZN7SuperOS6kalloc16KERNEL_ALLOCATOR17h86a57417c9c93ec9E>
80000750:	00062223          	sw	zero,4(a2)
80000754:	00a62423          	sw	a0,8(a2)
80000758:	00a62623          	sw	a0,12(a2)
8000075c:	00e62823          	sw	a4,16(a2)
80000760:	00b60a23          	sb	a1,20(a2)
80000764:	80000537          	lui	a0,0x80000
80000768:	10050513          	addi	a0,a0,256 # 80000100 <user_trap>
8000076c:	30551073          	.insn	4, 0x30551073
80000770:	02000513          	li	a0,32
80000774:	30452073          	.insn	4, 0x30452073
80000778:	08000513          	li	a0,128
8000077c:	30052073          	.insn	4, 0x30052073
80000780:	80004537          	lui	a0,0x80004
80000784:	81c54583          	lbu	a1,-2020(a0) # 8000381c <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3>
80000788:	00058463          	beqz	a1,80000790 <kernel_main+0x348>
8000078c:	0000006f          	j	8000078c <kernel_main+0x344>
80000790:	800045b7          	lui	a1,0x80004
80000794:	8185a603          	lw	a2,-2024(a1) # 80003818 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.2>
80000798:	800046b7          	lui	a3,0x80004
8000079c:	8106a683          	lw	a3,-2032(a3) # 80003810 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.0>
800007a0:	00100713          	li	a4,1
800007a4:	80e50e23          	sb	a4,-2020(a0)
800007a8:	00160613          	addi	a2,a2,1
800007ac:	80c5ac23          	sw	a2,-2024(a1)
800007b0:	30068e63          	beqz	a3,80000acc <kernel_main+0x684>
800007b4:	80004537          	lui	a0,0x80004
800007b8:	81452403          	lw	s0,-2028(a0) # 80003814 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.1>
800007bc:	00c41413          	slli	s0,s0,0xc
800007c0:	1e040863          	beqz	s0,800009b0 <kernel_main+0x568>
800007c4:	00042503          	lw	a0,0(s0)
800007c8:	00050863          	beqz	a0,800007d8 <kernel_main+0x390>
800007cc:	00442503          	lw	a0,4(s0)
800007d0:	00100593          	li	a1,1
800007d4:	0080006f          	j	800007dc <kernel_main+0x394>
800007d8:	00000593          	li	a1,0
800007dc:	80004637          	lui	a2,0x80004
800007e0:	80b62823          	sw	a1,-2032(a2) # 80003810 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.0>
800007e4:	800045b7          	lui	a1,0x80004
800007e8:	80a5aa23          	sw	a0,-2028(a1) # 80003814 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.1>
800007ec:	80004537          	lui	a0,0x80004
800007f0:	80050e23          	sb	zero,-2020(a0) # 8000381c <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3>
800007f4:	08010993          	addi	s3,sp,128
800007f8:	00410513          	addi	a0,sp,4
800007fc:	07c00613          	li	a2,124
80000800:	00000593          	li	a1,0
80000804:	00002097          	auipc	ra,0x2
80000808:	a3c080e7          	jalr	-1476(ra) # 80002240 <memset>
8000080c:	80001537          	lui	a0,0x80001
80000810:	d1850513          	addi	a0,a0,-744 # 80000d18 <_ZN7SuperOS9user_main17h689d296ac67d944aE>
80000814:	08a12023          	sw	a0,128(sp)
80000818:	08012223          	sw	zero,132(sp)
8000081c:	0b312223          	sw	s3,164(sp)
80000820:	0b212423          	sw	s2,168(sp)
80000824:	80003537          	lui	a0,0x80003
80000828:	2cc50513          	addi	a0,a0,716 # 800032cc <.Lanon.10e9e605f29f28b577aacdba1819c9a4.63>
8000082c:	08a12623          	sw	a0,140(sp)
80000830:	00200513          	li	a0,2
80000834:	08a12823          	sw	a0,144(sp)
80000838:	08012e23          	sw	zero,156(sp)
8000083c:	0a410513          	addi	a0,sp,164
80000840:	08a12a23          	sw	a0,148(sp)
80000844:	00100513          	li	a0,1
80000848:	08a12c23          	sw	a0,152(sp)
8000084c:	800035b7          	lui	a1,0x80003
80000850:	11858593          	addi	a1,a1,280 # 80003118 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.23>
80000854:	0b810513          	addi	a0,sp,184
80000858:	08c10613          	addi	a2,sp,140
8000085c:	00001097          	auipc	ra,0x1
80000860:	9b8080e7          	jalr	-1608(ra) # 80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>
80000864:	48051663          	bnez	a0,80000cf0 <kernel_main+0x8a8>
80000868:	00001537          	lui	a0,0x1
8000086c:	ff850513          	addi	a0,a0,-8 # ff8 <.Lline_table_start2+0x46>
80000870:	00a46533          	or	a0,s0,a0
80000874:	00a12423          	sw	a0,8(sp)
80000878:	0054c503          	lbu	a0,5(s1)
8000087c:	04057513          	andi	a0,a0,64
80000880:	0e050c63          	beqz	a0,80000978 <kernel_main+0x530>
80000884:	10000537          	lui	a0,0x10000
80000888:	04800593          	li	a1,72
8000088c:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000890:	0054c583          	lbu	a1,5(s1)
80000894:	0405f593          	andi	a1,a1,64
80000898:	0e058063          	beqz	a1,80000978 <kernel_main+0x530>
8000089c:	06500593          	li	a1,101
800008a0:	00b50023          	sb	a1,0(a0)
800008a4:	0054c503          	lbu	a0,5(s1)
800008a8:	04057513          	andi	a0,a0,64
800008ac:	0c050663          	beqz	a0,80000978 <kernel_main+0x530>
800008b0:	10000537          	lui	a0,0x10000
800008b4:	06c00593          	li	a1,108
800008b8:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
800008bc:	0054c583          	lbu	a1,5(s1)
800008c0:	0405f593          	andi	a1,a1,64
800008c4:	0a058a63          	beqz	a1,80000978 <kernel_main+0x530>
800008c8:	06f00593          	li	a1,111
800008cc:	00b50023          	sb	a1,0(a0)
800008d0:	0054c503          	lbu	a0,5(s1)
800008d4:	04057513          	andi	a0,a0,64
800008d8:	0a050063          	beqz	a0,80000978 <kernel_main+0x530>
800008dc:	10000537          	lui	a0,0x10000
800008e0:	02000593          	li	a1,32
800008e4:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
800008e8:	0054c583          	lbu	a1,5(s1)
800008ec:	0405f593          	andi	a1,a1,64
800008f0:	08058463          	beqz	a1,80000978 <kernel_main+0x530>
800008f4:	07700593          	li	a1,119
800008f8:	00b50023          	sb	a1,0(a0)
800008fc:	0054c503          	lbu	a0,5(s1)
80000900:	04057513          	andi	a0,a0,64
80000904:	06050a63          	beqz	a0,80000978 <kernel_main+0x530>
80000908:	10000537          	lui	a0,0x10000
8000090c:	06f00593          	li	a1,111
80000910:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000914:	0054c583          	lbu	a1,5(s1)
80000918:	0405f593          	andi	a1,a1,64
8000091c:	04058e63          	beqz	a1,80000978 <kernel_main+0x530>
80000920:	07200593          	li	a1,114
80000924:	00b50023          	sb	a1,0(a0)
80000928:	0054c503          	lbu	a0,5(s1)
8000092c:	04057513          	andi	a0,a0,64
80000930:	04050463          	beqz	a0,80000978 <kernel_main+0x530>
80000934:	10000537          	lui	a0,0x10000
80000938:	06c00593          	li	a1,108
8000093c:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000940:	0054c583          	lbu	a1,5(s1)
80000944:	0405f593          	andi	a1,a1,64
80000948:	02058863          	beqz	a1,80000978 <kernel_main+0x530>
8000094c:	06400593          	li	a1,100
80000950:	00b50023          	sb	a1,0(a0)
80000954:	0054c503          	lbu	a0,5(s1)
80000958:	04057513          	andi	a0,a0,64
8000095c:	00050e63          	beqz	a0,80000978 <kernel_main+0x530>
80000960:	10000537          	lui	a0,0x10000
80000964:	02100593          	li	a1,33
80000968:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
8000096c:	0054c583          	lbu	a1,5(s1)
80000970:	0405f593          	andi	a1,a1,64
80000974:	04059663          	bnez	a1,800009c0 <kernel_main+0x578>
80000978:	0000006f          	j	80000978 <kernel_main+0x530>
8000097c:	80003537          	lui	a0,0x80003
80000980:	1c750513          	addi	a0,a0,455 # 800031c7 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.37>
80000984:	80003637          	lui	a2,0x80003
80000988:	20060613          	addi	a2,a2,512 # 80003200 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.38>
8000098c:	03800593          	li	a1,56
80000990:	00000097          	auipc	ra,0x0
80000994:	63c080e7          	jalr	1596(ra) # 80000fcc <_ZN4core9panicking5panic17hd3c9c2f2ce63f879E>
80000998:	00012223          	sw	zero,4(sp)
8000099c:	0a410513          	addi	a0,sp,164
800009a0:	08c10593          	addi	a1,sp,140
800009a4:	00410613          	addi	a2,sp,4
800009a8:	00000097          	auipc	ra,0x0
800009ac:	950080e7          	jalr	-1712(ra) # 800002f8 <_ZN4core9panicking13assert_failed17h10961ca432d19960E>
800009b0:	80003537          	lui	a0,0x80003
800009b4:	25c50513          	addi	a0,a0,604 # 8000325c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.56>
800009b8:	00000097          	auipc	ra,0x0
800009bc:	474080e7          	jalr	1140(ra) # 80000e2c <_ZN4core6option13unwrap_failed17h3c8b02f60fb2eb06E>
800009c0:	00a00593          	li	a1,10
800009c4:	00b50023          	sb	a1,0(a0)
800009c8:	0054c503          	lbu	a0,5(s1)
800009cc:	04057513          	andi	a0,a0,64
800009d0:	0e050c63          	beqz	a0,80000ac8 <kernel_main+0x680>
800009d4:	10000537          	lui	a0,0x10000
800009d8:	04800593          	li	a1,72
800009dc:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
800009e0:	0054c583          	lbu	a1,5(s1)
800009e4:	0405f593          	andi	a1,a1,64
800009e8:	0e058063          	beqz	a1,80000ac8 <kernel_main+0x680>
800009ec:	06500593          	li	a1,101
800009f0:	00b50023          	sb	a1,0(a0)
800009f4:	0054c503          	lbu	a0,5(s1)
800009f8:	04057513          	andi	a0,a0,64
800009fc:	0c050663          	beqz	a0,80000ac8 <kernel_main+0x680>
80000a00:	10000537          	lui	a0,0x10000
80000a04:	06c00593          	li	a1,108
80000a08:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000a0c:	0054c583          	lbu	a1,5(s1)
80000a10:	0405f593          	andi	a1,a1,64
80000a14:	0a058a63          	beqz	a1,80000ac8 <kernel_main+0x680>
80000a18:	06f00593          	li	a1,111
80000a1c:	00b50023          	sb	a1,0(a0)
80000a20:	0054c503          	lbu	a0,5(s1)
80000a24:	04057513          	andi	a0,a0,64
80000a28:	0a050063          	beqz	a0,80000ac8 <kernel_main+0x680>
80000a2c:	10000537          	lui	a0,0x10000
80000a30:	02000593          	li	a1,32
80000a34:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000a38:	0054c583          	lbu	a1,5(s1)
80000a3c:	0405f593          	andi	a1,a1,64
80000a40:	08058463          	beqz	a1,80000ac8 <kernel_main+0x680>
80000a44:	07700593          	li	a1,119
80000a48:	00b50023          	sb	a1,0(a0)
80000a4c:	0054c503          	lbu	a0,5(s1)
80000a50:	04057513          	andi	a0,a0,64
80000a54:	06050a63          	beqz	a0,80000ac8 <kernel_main+0x680>
80000a58:	10000537          	lui	a0,0x10000
80000a5c:	06f00593          	li	a1,111
80000a60:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000a64:	0054c583          	lbu	a1,5(s1)
80000a68:	0405f593          	andi	a1,a1,64
80000a6c:	04058e63          	beqz	a1,80000ac8 <kernel_main+0x680>
80000a70:	07200593          	li	a1,114
80000a74:	00b50023          	sb	a1,0(a0)
80000a78:	0054c503          	lbu	a0,5(s1)
80000a7c:	04057513          	andi	a0,a0,64
80000a80:	04050463          	beqz	a0,80000ac8 <kernel_main+0x680>
80000a84:	10000537          	lui	a0,0x10000
80000a88:	06c00593          	li	a1,108
80000a8c:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000a90:	0054c583          	lbu	a1,5(s1)
80000a94:	0405f593          	andi	a1,a1,64
80000a98:	02058863          	beqz	a1,80000ac8 <kernel_main+0x680>
80000a9c:	06400593          	li	a1,100
80000aa0:	00b50023          	sb	a1,0(a0)
80000aa4:	0054c503          	lbu	a0,5(s1)
80000aa8:	04057513          	andi	a0,a0,64
80000aac:	00050e63          	beqz	a0,80000ac8 <kernel_main+0x680>
80000ab0:	100009b7          	lui	s3,0x10000
80000ab4:	02100513          	li	a0,33
80000ab8:	00a98023          	sb	a0,0(s3) # 10000000 <.Lline_table_start2+0xfffec61>
80000abc:	0054c503          	lbu	a0,5(s1)
80000ac0:	04057513          	andi	a0,a0,64
80000ac4:	00051e63          	bnez	a0,80000ae0 <kernel_main+0x698>
80000ac8:	0000006f          	j	80000ac8 <kernel_main+0x680>
80000acc:	80050e23          	sb	zero,-2020(a0)
80000ad0:	80003537          	lui	a0,0x80003
80000ad4:	2b050513          	addi	a0,a0,688 # 800032b0 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.61>
80000ad8:	00000097          	auipc	ra,0x0
80000adc:	354080e7          	jalr	852(ra) # 80000e2c <_ZN4core6option13unwrap_failed17h3c8b02f60fb2eb06E>
80000ae0:	00a00513          	li	a0,10
80000ae4:	00a98023          	sb	a0,0(s3)
80000ae8:	08810c13          	addi	s8,sp,136
80000aec:	80000cb7          	lui	s9,0x80000
80000af0:	34cc8c93          	addi	s9,s9,844 # 8000034c <_ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17hf95f0320af548cf6E>
80000af4:	80003d37          	lui	s10,0x80003
80000af8:	1a4d0d13          	addi	s10,s10,420 # 800031a4 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.31>
80000afc:	00300d93          	li	s11,3
80000b00:	0a410b13          	addi	s6,sp,164
80000b04:	00200a13          	li	s4,2
80000b08:	80003437          	lui	s0,0x80003
80000b0c:	11840413          	addi	s0,s0,280 # 80003118 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.23>
80000b10:	07500a93          	li	s5,117
80000b14:	06500b93          	li	s7,101
80000b18:	00410513          	addi	a0,sp,4
80000b1c:	fffff097          	auipc	ra,0xfffff
80000b20:	514080e7          	jalr	1300(ra) # 80000030 <run_user>
80000b24:	34202573          	.insn	4, 0x34202573
80000b28:	06054e63          	bltz	a0,80000ba4 <kernel_main+0x75c>
80000b2c:	00e00593          	li	a1,14
80000b30:	01000613          	li	a2,16
80000b34:	00c57a63          	bgeu	a0,a2,80000b48 <kernel_main+0x700>
80000b38:	800035b7          	lui	a1,0x80003
80000b3c:	04c58593          	addi	a1,a1,76 # 8000304c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.8+0x37>
80000b40:	00a58533          	add	a0,a1,a0
80000b44:	00054583          	lbu	a1,0(a0)
80000b48:	08b10423          	sb	a1,136(sp)
80000b4c:	34102573          	.insn	4, 0x34102573
80000b50:	0aa12a23          	sw	a0,180(sp)
80000b54:	0b410513          	addi	a0,sp,180
80000b58:	0aa12223          	sw	a0,164(sp)
80000b5c:	0b212423          	sw	s2,168(sp)
80000b60:	0b812623          	sw	s8,172(sp)
80000b64:	0b912823          	sw	s9,176(sp)
80000b68:	09a12623          	sw	s10,140(sp)
80000b6c:	09b12823          	sw	s11,144(sp)
80000b70:	08012e23          	sw	zero,156(sp)
80000b74:	09612a23          	sw	s6,148(sp)
80000b78:	09412c23          	sw	s4,152(sp)
80000b7c:	0b810513          	addi	a0,sp,184
80000b80:	08c10613          	addi	a2,sp,140
80000b84:	00040593          	mv	a1,s0
80000b88:	00000097          	auipc	ra,0x0
80000b8c:	68c080e7          	jalr	1676(ra) # 80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>
80000b90:	16051063          	bnez	a0,80000cf0 <kernel_main+0x8a8>
80000b94:	08012503          	lw	a0,128(sp)
80000b98:	00450513          	addi	a0,a0,4
80000b9c:	08a12023          	sw	a0,128(sp)
80000ba0:	f79ff06f          	j	80000b18 <kernel_main+0x6d0>
80000ba4:	0054c503          	lbu	a0,5(s1)
80000ba8:	04057513          	andi	a0,a0,64
80000bac:	14050063          	beqz	a0,80000cec <kernel_main+0x8a4>
80000bb0:	06d00513          	li	a0,109
80000bb4:	00a98023          	sb	a0,0(s3)
80000bb8:	0054c503          	lbu	a0,5(s1)
80000bbc:	04057513          	andi	a0,a0,64
80000bc0:	12050663          	beqz	a0,80000cec <kernel_main+0x8a4>
80000bc4:	06300513          	li	a0,99
80000bc8:	00a98023          	sb	a0,0(s3)
80000bcc:	0054c503          	lbu	a0,5(s1)
80000bd0:	04057513          	andi	a0,a0,64
80000bd4:	10050c63          	beqz	a0,80000cec <kernel_main+0x8a4>
80000bd8:	06100513          	li	a0,97
80000bdc:	00a98023          	sb	a0,0(s3)
80000be0:	0054c503          	lbu	a0,5(s1)
80000be4:	04057513          	andi	a0,a0,64
80000be8:	10050263          	beqz	a0,80000cec <kernel_main+0x8a4>
80000bec:	01598023          	sb	s5,0(s3)
80000bf0:	0054c503          	lbu	a0,5(s1)
80000bf4:	04057513          	andi	a0,a0,64
80000bf8:	0e050a63          	beqz	a0,80000cec <kernel_main+0x8a4>
80000bfc:	07300513          	li	a0,115
80000c00:	00a98023          	sb	a0,0(s3)
80000c04:	0054c503          	lbu	a0,5(s1)
80000c08:	04057513          	andi	a0,a0,64
80000c0c:	0e050063          	beqz	a0,80000cec <kernel_main+0x8a4>
80000c10:	01798023          	sb	s7,0(s3)
80000c14:	0054c503          	lbu	a0,5(s1)
80000c18:	04057513          	andi	a0,a0,64
80000c1c:	0c050863          	beqz	a0,80000cec <kernel_main+0x8a4>
80000c20:	03a00513          	li	a0,58
80000c24:	00a98023          	sb	a0,0(s3)
80000c28:	0054c503          	lbu	a0,5(s1)
80000c2c:	04057513          	andi	a0,a0,64
80000c30:	0a050e63          	beqz	a0,80000cec <kernel_main+0x8a4>
80000c34:	02000513          	li	a0,32
80000c38:	00a98023          	sb	a0,0(s3)
80000c3c:	0054c503          	lbu	a0,5(s1)
80000c40:	04057513          	andi	a0,a0,64
80000c44:	0a050463          	beqz	a0,80000cec <kernel_main+0x8a4>
80000c48:	06900513          	li	a0,105
80000c4c:	00a98023          	sb	a0,0(s3)
80000c50:	0054c503          	lbu	a0,5(s1)
80000c54:	04057513          	andi	a0,a0,64
80000c58:	08050a63          	beqz	a0,80000cec <kernel_main+0x8a4>
80000c5c:	06e00513          	li	a0,110
80000c60:	00a98023          	sb	a0,0(s3)
80000c64:	0054c503          	lbu	a0,5(s1)
80000c68:	04057513          	andi	a0,a0,64
80000c6c:	08050063          	beqz	a0,80000cec <kernel_main+0x8a4>
80000c70:	07400513          	li	a0,116
80000c74:	00a98023          	sb	a0,0(s3)
80000c78:	0054c503          	lbu	a0,5(s1)
80000c7c:	04057513          	andi	a0,a0,64
80000c80:	06050663          	beqz	a0,80000cec <kernel_main+0x8a4>
80000c84:	01798023          	sb	s7,0(s3)
80000c88:	0054c503          	lbu	a0,5(s1)
80000c8c:	04057513          	andi	a0,a0,64
80000c90:	04050e63          	beqz	a0,80000cec <kernel_main+0x8a4>
80000c94:	07200513          	li	a0,114
80000c98:	00a98023          	sb	a0,0(s3)
80000c9c:	0054c503          	lbu	a0,5(s1)
80000ca0:	04057513          	andi	a0,a0,64
80000ca4:	04050463          	beqz	a0,80000cec <kernel_main+0x8a4>
80000ca8:	01598023          	sb	s5,0(s3)
80000cac:	0054c503          	lbu	a0,5(s1)
80000cb0:	04057513          	andi	a0,a0,64
80000cb4:	02050c63          	beqz	a0,80000cec <kernel_main+0x8a4>
80000cb8:	07000513          	li	a0,112
80000cbc:	00a98023          	sb	a0,0(s3)
80000cc0:	0054c503          	lbu	a0,5(s1)
80000cc4:	04057513          	andi	a0,a0,64
80000cc8:	02050263          	beqz	a0,80000cec <kernel_main+0x8a4>
80000ccc:	07400513          	li	a0,116
80000cd0:	00a98023          	sb	a0,0(s3)
80000cd4:	0054c503          	lbu	a0,5(s1)
80000cd8:	04057513          	andi	a0,a0,64
80000cdc:	00050863          	beqz	a0,80000cec <kernel_main+0x8a4>
80000ce0:	00a00513          	li	a0,10
80000ce4:	00a98023          	sb	a0,0(s3)
80000ce8:	e31ff06f          	j	80000b18 <kernel_main+0x6d0>
80000cec:	0000006f          	j	80000cec <kernel_main+0x8a4>
80000cf0:	80003537          	lui	a0,0x80003
80000cf4:	14050513          	addi	a0,a0,320 # 80003140 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.25>
80000cf8:	800036b7          	lui	a3,0x80003
80000cfc:	13068693          	addi	a3,a3,304 # 80003130 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.24>
80000d00:	80003737          	lui	a4,0x80003
80000d04:	17c70713          	addi	a4,a4,380 # 8000317c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.27>
80000d08:	02b00593          	li	a1,43
80000d0c:	0b810613          	addi	a2,sp,184
80000d10:	00000097          	auipc	ra,0x0
80000d14:	450080e7          	jalr	1104(ra) # 80001160 <_ZN4core6result13unwrap_failed17hea2e62a5f959197bE>

80000d18 <_ZN7SuperOS9user_main17h689d296ac67d944aE>:
80000d18:	10000537          	lui	a0,0x10000
80000d1c:	00554583          	lbu	a1,5(a0) # 10000005 <.Lline_table_start2+0xfffec66>
80000d20:	0405f593          	andi	a1,a1,64
80000d24:	0e058a63          	beqz	a1,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000d28:	00554583          	lbu	a1,5(a0)
80000d2c:	04800613          	li	a2,72
80000d30:	0405f593          	andi	a1,a1,64
80000d34:	00c50023          	sb	a2,0(a0)
80000d38:	0e058063          	beqz	a1,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000d3c:	100005b7          	lui	a1,0x10000
80000d40:	06500613          	li	a2,101
80000d44:	00c58023          	sb	a2,0(a1) # 10000000 <.Lline_table_start2+0xfffec61>
80000d48:	00554603          	lbu	a2,5(a0)
80000d4c:	04067613          	andi	a2,a2,64
80000d50:	0c060463          	beqz	a2,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000d54:	06c00613          	li	a2,108
80000d58:	00c58023          	sb	a2,0(a1)
80000d5c:	00554583          	lbu	a1,5(a0)
80000d60:	0405f593          	andi	a1,a1,64
80000d64:	0a058a63          	beqz	a1,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000d68:	100005b7          	lui	a1,0x10000
80000d6c:	06f00613          	li	a2,111
80000d70:	00c58023          	sb	a2,0(a1) # 10000000 <.Lline_table_start2+0xfffec61>
80000d74:	00554603          	lbu	a2,5(a0)
80000d78:	04067613          	andi	a2,a2,64
80000d7c:	08060e63          	beqz	a2,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000d80:	02000613          	li	a2,32
80000d84:	00c58023          	sb	a2,0(a1)
80000d88:	00554583          	lbu	a1,5(a0)
80000d8c:	0405f593          	andi	a1,a1,64
80000d90:	08058463          	beqz	a1,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000d94:	100005b7          	lui	a1,0x10000
80000d98:	07500613          	li	a2,117
80000d9c:	00c58023          	sb	a2,0(a1) # 10000000 <.Lline_table_start2+0xfffec61>
80000da0:	00554603          	lbu	a2,5(a0)
80000da4:	04067613          	andi	a2,a2,64
80000da8:	06060863          	beqz	a2,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000dac:	07300613          	li	a2,115
80000db0:	00c58023          	sb	a2,0(a1)
80000db4:	00554583          	lbu	a1,5(a0)
80000db8:	0405f593          	andi	a1,a1,64
80000dbc:	04058e63          	beqz	a1,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000dc0:	100005b7          	lui	a1,0x10000
80000dc4:	06500613          	li	a2,101
80000dc8:	00c58023          	sb	a2,0(a1) # 10000000 <.Lline_table_start2+0xfffec61>
80000dcc:	00554603          	lbu	a2,5(a0)
80000dd0:	04067613          	andi	a2,a2,64
80000dd4:	04060263          	beqz	a2,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000dd8:	07200613          	li	a2,114
80000ddc:	00c58023          	sb	a2,0(a1)
80000de0:	00554583          	lbu	a1,5(a0)
80000de4:	0405f593          	andi	a1,a1,64
80000de8:	02058863          	beqz	a1,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000dec:	100005b7          	lui	a1,0x10000
80000df0:	07300613          	li	a2,115
80000df4:	00c58023          	sb	a2,0(a1) # 10000000 <.Lline_table_start2+0xfffec61>
80000df8:	00554603          	lbu	a2,5(a0)
80000dfc:	04067613          	andi	a2,a2,64
80000e00:	00060c63          	beqz	a2,80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000e04:	02100613          	li	a2,33
80000e08:	00c58023          	sb	a2,0(a1)
80000e0c:	00554503          	lbu	a0,5(a0)
80000e10:	04057513          	andi	a0,a0,64
80000e14:	00051463          	bnez	a0,80000e1c <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x104>
80000e18:	0000006f          	j	80000e18 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x100>
80000e1c:	10000537          	lui	a0,0x10000
80000e20:	00a00593          	li	a1,10
80000e24:	00b50023          	sb	a1,0(a0) # 10000000 <.Lline_table_start2+0xfffec61>
80000e28:	0000006f          	j	80000e28 <_ZN7SuperOS9user_main17h689d296ac67d944aE+0x110>

80000e2c <_ZN4core6option13unwrap_failed17h3c8b02f60fb2eb06E>:
80000e2c:	ff010113          	addi	sp,sp,-16
80000e30:	00112623          	sw	ra,12(sp)
80000e34:	00812423          	sw	s0,8(sp)
80000e38:	01010413          	addi	s0,sp,16
80000e3c:	00050613          	mv	a2,a0
80000e40:	80003537          	lui	a0,0x80003
80000e44:	35550513          	addi	a0,a0,853 # 80003355 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.222>
80000e48:	02b00593          	li	a1,43
80000e4c:	00000097          	auipc	ra,0x0
80000e50:	180080e7          	jalr	384(ra) # 80000fcc <_ZN4core9panicking5panic17hd3c9c2f2ce63f879E>

80000e54 <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h437e60b278116f80E>:
80000e54:	fb010113          	addi	sp,sp,-80
80000e58:	04112623          	sw	ra,76(sp)
80000e5c:	04812423          	sw	s0,72(sp)
80000e60:	04912223          	sw	s1,68(sp)
80000e64:	05212023          	sw	s2,64(sp)
80000e68:	03312e23          	sw	s3,60(sp)
80000e6c:	03412c23          	sw	s4,56(sp)
80000e70:	03512a23          	sw	s5,52(sp)
80000e74:	05010413          	addi	s0,sp,80
80000e78:	0205a483          	lw	s1,32(a1)
80000e7c:	01c5a903          	lw	s2,28(a1)
80000e80:	00c4aa83          	lw	s5,12(s1)
80000e84:	00050993          	mv	s3,a0
80000e88:	800035b7          	lui	a1,0x80003
80000e8c:	39858593          	addi	a1,a1,920 # 80003398 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.224>
80000e90:	00c00613          	li	a2,12
80000e94:	00090513          	mv	a0,s2
80000e98:	000a80e7          	jalr	s5
80000e9c:	00100a13          	li	s4,1
80000ea0:	0c051c63          	bnez	a0,80000f78 <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h437e60b278116f80E+0x124>
80000ea4:	0049a503          	lw	a0,4(s3)
80000ea8:	00850593          	addi	a1,a0,8
80000eac:	00c50613          	addi	a2,a0,12
80000eb0:	fca42623          	sw	a0,-52(s0)
80000eb4:	80002537          	lui	a0,0x80002
80000eb8:	0fc50513          	addi	a0,a0,252 # 800020fc <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17ha816cb0eaf1a1493E>
80000ebc:	fca42823          	sw	a0,-48(s0)
80000ec0:	fcb42a23          	sw	a1,-44(s0)
80000ec4:	80002537          	lui	a0,0x80002
80000ec8:	edc50513          	addi	a0,a0,-292 # 80001edc <_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17h0f2cd5210a0eafd0E>
80000ecc:	fca42c23          	sw	a0,-40(s0)
80000ed0:	fcc42e23          	sw	a2,-36(s0)
80000ed4:	fea42023          	sw	a0,-32(s0)
80000ed8:	80003537          	lui	a0,0x80003
80000edc:	38050513          	addi	a0,a0,896 # 80003380 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.223>
80000ee0:	faa42a23          	sw	a0,-76(s0)
80000ee4:	00300513          	li	a0,3
80000ee8:	faa42c23          	sw	a0,-72(s0)
80000eec:	fc042223          	sw	zero,-60(s0)
80000ef0:	fcc40593          	addi	a1,s0,-52
80000ef4:	fab42e23          	sw	a1,-68(s0)
80000ef8:	fca42023          	sw	a0,-64(s0)
80000efc:	fb440613          	addi	a2,s0,-76
80000f00:	00090513          	mv	a0,s2
80000f04:	00048593          	mv	a1,s1
80000f08:	00000097          	auipc	ra,0x0
80000f0c:	30c080e7          	jalr	780(ra) # 80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>
80000f10:	06051463          	bnez	a0,80000f78 <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h437e60b278116f80E+0x124>
80000f14:	800035b7          	lui	a1,0x80003
80000f18:	3a458593          	addi	a1,a1,932 # 800033a4 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.225>
80000f1c:	00200613          	li	a2,2
80000f20:	00090513          	mv	a0,s2
80000f24:	000a80e7          	jalr	s5
80000f28:	04051863          	bnez	a0,80000f78 <_ZN73_$LT$core..panic..panic_info..PanicInfo$u20$as$u20$core..fmt..Display$GT$3fmt17h437e60b278116f80E+0x124>
80000f2c:	0009a503          	lw	a0,0(s3)
80000f30:	00052583          	lw	a1,0(a0)
80000f34:	fcb42623          	sw	a1,-52(s0)
80000f38:	00452583          	lw	a1,4(a0)
80000f3c:	fcb42823          	sw	a1,-48(s0)
80000f40:	00852583          	lw	a1,8(a0)
80000f44:	fcb42a23          	sw	a1,-44(s0)
80000f48:	00c52583          	lw	a1,12(a0)
80000f4c:	fcb42c23          	sw	a1,-40(s0)
80000f50:	01052583          	lw	a1,16(a0)
80000f54:	fcb42e23          	sw	a1,-36(s0)
80000f58:	01452503          	lw	a0,20(a0)
80000f5c:	fea42023          	sw	a0,-32(s0)
80000f60:	fcc40613          	addi	a2,s0,-52
80000f64:	00090513          	mv	a0,s2
80000f68:	00048593          	mv	a1,s1
80000f6c:	00000097          	auipc	ra,0x0
80000f70:	2a8080e7          	jalr	680(ra) # 80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>
80000f74:	00050a13          	mv	s4,a0
80000f78:	000a0513          	mv	a0,s4
80000f7c:	04c12083          	lw	ra,76(sp)
80000f80:	04812403          	lw	s0,72(sp)
80000f84:	04412483          	lw	s1,68(sp)
80000f88:	04012903          	lw	s2,64(sp)
80000f8c:	03c12983          	lw	s3,60(sp)
80000f90:	03812a03          	lw	s4,56(sp)
80000f94:	03412a83          	lw	s5,52(sp)
80000f98:	05010113          	addi	sp,sp,80
80000f9c:	00008067          	ret

80000fa0 <_ZN4core9panicking9panic_fmt17h565743de4a6e5eabE>:
80000fa0:	fe010113          	addi	sp,sp,-32
80000fa4:	00112e23          	sw	ra,28(sp)
80000fa8:	00812c23          	sw	s0,24(sp)
80000fac:	02010413          	addi	s0,sp,32
80000fb0:	fea42623          	sw	a0,-20(s0)
80000fb4:	feb42823          	sw	a1,-16(s0)
80000fb8:	00100513          	li	a0,1
80000fbc:	fea41a23          	sh	a0,-12(s0)
80000fc0:	fec40513          	addi	a0,s0,-20
80000fc4:	fffff097          	auipc	ra,0xfffff
80000fc8:	3f4080e7          	jalr	1012(ra) # 800003b8 <rust_begin_unwind>

80000fcc <_ZN4core9panicking5panic17hd3c9c2f2ce63f879E>:
80000fcc:	fd010113          	addi	sp,sp,-48
80000fd0:	02112623          	sw	ra,44(sp)
80000fd4:	02812423          	sw	s0,40(sp)
80000fd8:	03010413          	addi	s0,sp,48
80000fdc:	fea42823          	sw	a0,-16(s0)
80000fe0:	feb42a23          	sw	a1,-12(s0)
80000fe4:	ff040513          	addi	a0,s0,-16
80000fe8:	fca42c23          	sw	a0,-40(s0)
80000fec:	00100513          	li	a0,1
80000ff0:	fca42e23          	sw	a0,-36(s0)
80000ff4:	fe042423          	sw	zero,-24(s0)
80000ff8:	00400513          	li	a0,4
80000ffc:	fea42023          	sw	a0,-32(s0)
80001000:	fe042223          	sw	zero,-28(s0)
80001004:	fd840513          	addi	a0,s0,-40
80001008:	00060593          	mv	a1,a2
8000100c:	00000097          	auipc	ra,0x0
80001010:	f94080e7          	jalr	-108(ra) # 80000fa0 <_ZN4core9panicking9panic_fmt17h565743de4a6e5eabE>

80001014 <_ZN4core9panicking19assert_failed_inner17h95e43b28e148b8c7E>:
80001014:	f8010113          	addi	sp,sp,-128
80001018:	06112e23          	sw	ra,124(sp)
8000101c:	06812c23          	sw	s0,120(sp)
80001020:	06912a23          	sw	s1,116(sp)
80001024:	07212823          	sw	s2,112(sp)
80001028:	08010413          	addi	s0,sp,128
8000102c:	00080493          	mv	s1,a6
80001030:	f8b42423          	sw	a1,-120(s0)
80001034:	f8c42623          	sw	a2,-116(s0)
80001038:	f8d42823          	sw	a3,-112(s0)
8000103c:	f8e42a23          	sw	a4,-108(s0)
80001040:	00050c63          	beqz	a0,80001058 <_ZN4core9panicking19assert_failed_inner17h95e43b28e148b8c7E+0x44>
80001044:	00100593          	li	a1,1
80001048:	02b51263          	bne	a0,a1,8000106c <_ZN4core9panicking19assert_failed_inner17h95e43b28e148b8c7E+0x58>
8000104c:	80003537          	lui	a0,0x80003
80001050:	3a850513          	addi	a0,a0,936 # 800033a8 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.243>
80001054:	00c0006f          	j	80001060 <_ZN4core9panicking19assert_failed_inner17h95e43b28e148b8c7E+0x4c>
80001058:	80003537          	lui	a0,0x80003
8000105c:	3a650513          	addi	a0,a0,934 # 800033a6 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.242>
80001060:	f8a42c23          	sw	a0,-104(s0)
80001064:	00200513          	li	a0,2
80001068:	0140006f          	j	8000107c <_ZN4core9panicking19assert_failed_inner17h95e43b28e148b8c7E+0x68>
8000106c:	80003537          	lui	a0,0x80003
80001070:	3aa50513          	addi	a0,a0,938 # 800033aa <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.244>
80001074:	f8a42c23          	sw	a0,-104(s0)
80001078:	00700513          	li	a0,7
8000107c:	0007a583          	lw	a1,0(a5)
80001080:	f8a42e23          	sw	a0,-100(s0)
80001084:	04059663          	bnez	a1,800010d0 <_ZN4core9panicking19assert_failed_inner17h95e43b28e148b8c7E+0xbc>
80001088:	f9840513          	addi	a0,s0,-104
8000108c:	faa42c23          	sw	a0,-72(s0)
80001090:	80002537          	lui	a0,0x80002
80001094:	0fc50513          	addi	a0,a0,252 # 800020fc <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17ha816cb0eaf1a1493E>
80001098:	faa42e23          	sw	a0,-68(s0)
8000109c:	f8840513          	addi	a0,s0,-120
800010a0:	fca42023          	sw	a0,-64(s0)
800010a4:	80002537          	lui	a0,0x80002
800010a8:	0d050513          	addi	a0,a0,208 # 800020d0 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17hb2addfb6a0710c9bE>
800010ac:	fca42223          	sw	a0,-60(s0)
800010b0:	f9040593          	addi	a1,s0,-112
800010b4:	fcb42423          	sw	a1,-56(s0)
800010b8:	fca42623          	sw	a0,-52(s0)
800010bc:	80003537          	lui	a0,0x80003
800010c0:	3d450513          	addi	a0,a0,980 # 800033d4 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.248>
800010c4:	fca42c23          	sw	a0,-40(s0)
800010c8:	00300513          	li	a0,3
800010cc:	0700006f          	j	8000113c <_ZN4core9panicking19assert_failed_inner17h95e43b28e148b8c7E+0x128>
800010d0:	fa040513          	addi	a0,s0,-96
800010d4:	01800613          	li	a2,24
800010d8:	fa040913          	addi	s2,s0,-96
800010dc:	00078593          	mv	a1,a5
800010e0:	00001097          	auipc	ra,0x1
800010e4:	050080e7          	jalr	80(ra) # 80002130 <memcpy>
800010e8:	f9840513          	addi	a0,s0,-104
800010ec:	faa42c23          	sw	a0,-72(s0)
800010f0:	80002537          	lui	a0,0x80002
800010f4:	0fc50513          	addi	a0,a0,252 # 800020fc <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17ha816cb0eaf1a1493E>
800010f8:	faa42e23          	sw	a0,-68(s0)
800010fc:	fd242023          	sw	s2,-64(s0)
80001100:	80001537          	lui	a0,0x80001
80001104:	1dc50513          	addi	a0,a0,476 # 800011dc <_ZN59_$LT$core..fmt..Arguments$u20$as$u20$core..fmt..Display$GT$3fmt17hdca9ffb43df363feE>
80001108:	fca42223          	sw	a0,-60(s0)
8000110c:	f8840513          	addi	a0,s0,-120
80001110:	fca42423          	sw	a0,-56(s0)
80001114:	80002537          	lui	a0,0x80002
80001118:	0d050513          	addi	a0,a0,208 # 800020d0 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17hb2addfb6a0710c9bE>
8000111c:	fca42623          	sw	a0,-52(s0)
80001120:	f9040593          	addi	a1,s0,-112
80001124:	fcb42823          	sw	a1,-48(s0)
80001128:	fca42a23          	sw	a0,-44(s0)
8000112c:	80003537          	lui	a0,0x80003
80001130:	3f850513          	addi	a0,a0,1016 # 800033f8 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.251>
80001134:	fca42c23          	sw	a0,-40(s0)
80001138:	00400513          	li	a0,4
8000113c:	fca42e23          	sw	a0,-36(s0)
80001140:	fe042423          	sw	zero,-24(s0)
80001144:	fb840593          	addi	a1,s0,-72
80001148:	feb42023          	sw	a1,-32(s0)
8000114c:	fea42223          	sw	a0,-28(s0)
80001150:	fd840513          	addi	a0,s0,-40
80001154:	00048593          	mv	a1,s1
80001158:	00000097          	auipc	ra,0x0
8000115c:	e48080e7          	jalr	-440(ra) # 80000fa0 <_ZN4core9panicking9panic_fmt17h565743de4a6e5eabE>

80001160 <_ZN4core6result13unwrap_failed17hea2e62a5f959197bE>:
80001160:	fc010113          	addi	sp,sp,-64
80001164:	02112e23          	sw	ra,60(sp)
80001168:	02812c23          	sw	s0,56(sp)
8000116c:	04010413          	addi	s0,sp,64
80001170:	fca42023          	sw	a0,-64(s0)
80001174:	fcb42223          	sw	a1,-60(s0)
80001178:	fcc42423          	sw	a2,-56(s0)
8000117c:	fcd42623          	sw	a3,-52(s0)
80001180:	fc040513          	addi	a0,s0,-64
80001184:	fea42423          	sw	a0,-24(s0)
80001188:	80002537          	lui	a0,0x80002
8000118c:	0fc50513          	addi	a0,a0,252 # 800020fc <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17ha816cb0eaf1a1493E>
80001190:	fea42623          	sw	a0,-20(s0)
80001194:	fc840513          	addi	a0,s0,-56
80001198:	fea42823          	sw	a0,-16(s0)
8000119c:	80002537          	lui	a0,0x80002
800011a0:	0d050513          	addi	a0,a0,208 # 800020d0 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17hb2addfb6a0710c9bE>
800011a4:	fea42a23          	sw	a0,-12(s0)
800011a8:	80003537          	lui	a0,0x80003
800011ac:	41c50513          	addi	a0,a0,1052 # 8000341c <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.253>
800011b0:	fca42823          	sw	a0,-48(s0)
800011b4:	00200513          	li	a0,2
800011b8:	fca42a23          	sw	a0,-44(s0)
800011bc:	fe042023          	sw	zero,-32(s0)
800011c0:	fe840593          	addi	a1,s0,-24
800011c4:	fcb42c23          	sw	a1,-40(s0)
800011c8:	fca42e23          	sw	a0,-36(s0)
800011cc:	fd040513          	addi	a0,s0,-48
800011d0:	00070593          	mv	a1,a4
800011d4:	00000097          	auipc	ra,0x0
800011d8:	dcc080e7          	jalr	-564(ra) # 80000fa0 <_ZN4core9panicking9panic_fmt17h565743de4a6e5eabE>

800011dc <_ZN59_$LT$core..fmt..Arguments$u20$as$u20$core..fmt..Display$GT$3fmt17hdca9ffb43df363feE>:
800011dc:	ff010113          	addi	sp,sp,-16
800011e0:	00112623          	sw	ra,12(sp)
800011e4:	00812423          	sw	s0,8(sp)
800011e8:	01010413          	addi	s0,sp,16
800011ec:	01c5a603          	lw	a2,28(a1)
800011f0:	0205a583          	lw	a1,32(a1)
800011f4:	00050693          	mv	a3,a0
800011f8:	00060513          	mv	a0,a2
800011fc:	00068613          	mv	a2,a3
80001200:	00c12083          	lw	ra,12(sp)
80001204:	00812403          	lw	s0,8(sp)
80001208:	01010113          	addi	sp,sp,16
8000120c:	00000317          	auipc	t1,0x0
80001210:	00830067          	jr	8(t1) # 80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>

80001214 <_ZN4core3fmt5write17h33f2525cf67b440fE>:
80001214:	fb010113          	addi	sp,sp,-80
80001218:	04112623          	sw	ra,76(sp)
8000121c:	04812423          	sw	s0,72(sp)
80001220:	04912223          	sw	s1,68(sp)
80001224:	05212023          	sw	s2,64(sp)
80001228:	03312e23          	sw	s3,60(sp)
8000122c:	03412c23          	sw	s4,56(sp)
80001230:	03512a23          	sw	s5,52(sp)
80001234:	03612823          	sw	s6,48(sp)
80001238:	03712623          	sw	s7,44(sp)
8000123c:	03812423          	sw	s8,40(sp)
80001240:	05010413          	addi	s0,sp,80
80001244:	00060493          	mv	s1,a2
80001248:	fa042a23          	sw	zero,-76(s0)
8000124c:	fa042e23          	sw	zero,-68(s0)
80001250:	02000613          	li	a2,32
80001254:	fcc42223          	sw	a2,-60(s0)
80001258:	fc042423          	sw	zero,-56(s0)
8000125c:	0104ab03          	lw	s6,16(s1)
80001260:	00300613          	li	a2,3
80001264:	fcc40623          	sb	a2,-52(s0)
80001268:	fca42823          	sw	a0,-48(s0)
8000126c:	fcb42a23          	sw	a1,-44(s0)
80001270:	120b0063          	beqz	s6,80001390 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x17c>
80001274:	0144aa83          	lw	s5,20(s1)
80001278:	180a8863          	beqz	s5,80001408 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x1f4>
8000127c:	0004aa03          	lw	s4,0(s1)
80001280:	0084a983          	lw	s3,8(s1)
80001284:	fffa8513          	addi	a0,s5,-1
80001288:	00551513          	slli	a0,a0,0x5
8000128c:	00555513          	srli	a0,a0,0x5
80001290:	00150913          	addi	s2,a0,1
80001294:	004a0a13          	addi	s4,s4,4
80001298:	005a9a93          	slli	s5,s5,0x5
8000129c:	010b0b13          	addi	s6,s6,16
800012a0:	00200b93          	li	s7,2
800012a4:	00100c13          	li	s8,1
800012a8:	000a2603          	lw	a2,0(s4)
800012ac:	00060e63          	beqz	a2,800012c8 <_ZN4core3fmt5write17h33f2525cf67b440fE+0xb4>
800012b0:	fd442683          	lw	a3,-44(s0)
800012b4:	fd042503          	lw	a0,-48(s0)
800012b8:	ffca2583          	lw	a1,-4(s4)
800012bc:	00c6a683          	lw	a3,12(a3)
800012c0:	000680e7          	jalr	a3
800012c4:	16051c63          	bnez	a0,8000143c <_ZN4core3fmt5write17h33f2525cf67b440fE+0x228>
800012c8:	000b2603          	lw	a2,0(s6)
800012cc:	00cb4683          	lbu	a3,12(s6)
800012d0:	008b2703          	lw	a4,8(s6)
800012d4:	ff8b2583          	lw	a1,-8(s6)
800012d8:	ffcb2503          	lw	a0,-4(s6)
800012dc:	fcc42223          	sw	a2,-60(s0)
800012e0:	fcd40623          	sb	a3,-52(s0)
800012e4:	fce42423          	sw	a4,-56(s0)
800012e8:	02058863          	beqz	a1,80001318 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x104>
800012ec:	01859a63          	bne	a1,s8,80001300 <_ZN4core3fmt5write17h33f2525cf67b440fE+0xec>
800012f0:	00351513          	slli	a0,a0,0x3
800012f4:	00a98533          	add	a0,s3,a0
800012f8:	00052583          	lw	a1,0(a0)
800012fc:	00058c63          	beqz	a1,80001314 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x100>
80001300:	ff0b2603          	lw	a2,-16(s6)
80001304:	fa042a23          	sw	zero,-76(s0)
80001308:	faa42c23          	sw	a0,-72(s0)
8000130c:	03761063          	bne	a2,s7,8000132c <_ZN4core3fmt5write17h33f2525cf67b440fE+0x118>
80001310:	0340006f          	j	80001344 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x130>
80001314:	00452503          	lw	a0,4(a0)
80001318:	00100593          	li	a1,1
8000131c:	ff0b2603          	lw	a2,-16(s6)
80001320:	fab42a23          	sw	a1,-76(s0)
80001324:	faa42c23          	sw	a0,-72(s0)
80001328:	01760e63          	beq	a2,s7,80001344 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x130>
8000132c:	ff4b2583          	lw	a1,-12(s6)
80001330:	03861063          	bne	a2,s8,80001350 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x13c>
80001334:	00359513          	slli	a0,a1,0x3
80001338:	00a98533          	add	a0,s3,a0
8000133c:	00052583          	lw	a1,0(a0)
80001340:	00058663          	beqz	a1,8000134c <_ZN4core3fmt5write17h33f2525cf67b440fE+0x138>
80001344:	00000613          	li	a2,0
80001348:	00c0006f          	j	80001354 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x140>
8000134c:	00452583          	lw	a1,4(a0)
80001350:	00100613          	li	a2,1
80001354:	004b2503          	lw	a0,4(s6)
80001358:	00351513          	slli	a0,a0,0x3
8000135c:	00a986b3          	add	a3,s3,a0
80001360:	0006a503          	lw	a0,0(a3)
80001364:	0046a683          	lw	a3,4(a3)
80001368:	fac42e23          	sw	a2,-68(s0)
8000136c:	fcb42023          	sw	a1,-64(s0)
80001370:	fb440593          	addi	a1,s0,-76
80001374:	000680e7          	jalr	a3
80001378:	0c051263          	bnez	a0,8000143c <_ZN4core3fmt5write17h33f2525cf67b440fE+0x228>
8000137c:	008a0a13          	addi	s4,s4,8
80001380:	fe0a8a93          	addi	s5,s5,-32
80001384:	020b0b13          	addi	s6,s6,32
80001388:	f20a90e3          	bnez	s5,800012a8 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x94>
8000138c:	0700006f          	j	800013fc <_ZN4core3fmt5write17h33f2525cf67b440fE+0x1e8>
80001390:	00c4a503          	lw	a0,12(s1)
80001394:	06050a63          	beqz	a0,80001408 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x1f4>
80001398:	0084a983          	lw	s3,8(s1)
8000139c:	00351a13          	slli	s4,a0,0x3
800013a0:	01498a33          	add	s4,s3,s4
800013a4:	0004aa83          	lw	s5,0(s1)
800013a8:	fff50513          	addi	a0,a0,-1
800013ac:	00351513          	slli	a0,a0,0x3
800013b0:	00355513          	srli	a0,a0,0x3
800013b4:	00150913          	addi	s2,a0,1
800013b8:	004a8a93          	addi	s5,s5,4
800013bc:	000aa603          	lw	a2,0(s5)
800013c0:	00060e63          	beqz	a2,800013dc <_ZN4core3fmt5write17h33f2525cf67b440fE+0x1c8>
800013c4:	fd442683          	lw	a3,-44(s0)
800013c8:	fd042503          	lw	a0,-48(s0)
800013cc:	ffcaa583          	lw	a1,-4(s5)
800013d0:	00c6a683          	lw	a3,12(a3)
800013d4:	000680e7          	jalr	a3
800013d8:	06051263          	bnez	a0,8000143c <_ZN4core3fmt5write17h33f2525cf67b440fE+0x228>
800013dc:	0009a503          	lw	a0,0(s3)
800013e0:	0049a603          	lw	a2,4(s3)
800013e4:	fb440593          	addi	a1,s0,-76
800013e8:	000600e7          	jalr	a2
800013ec:	04051863          	bnez	a0,8000143c <_ZN4core3fmt5write17h33f2525cf67b440fE+0x228>
800013f0:	00898993          	addi	s3,s3,8
800013f4:	008a8a93          	addi	s5,s5,8
800013f8:	fd4992e3          	bne	s3,s4,800013bc <_ZN4core3fmt5write17h33f2525cf67b440fE+0x1a8>
800013fc:	0044a503          	lw	a0,4(s1)
80001400:	00a96a63          	bltu	s2,a0,80001414 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x200>
80001404:	0400006f          	j	80001444 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x230>
80001408:	00000913          	li	s2,0
8000140c:	0044a503          	lw	a0,4(s1)
80001410:	02a07a63          	bgeu	zero,a0,80001444 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x230>
80001414:	0004a503          	lw	a0,0(s1)
80001418:	00391913          	slli	s2,s2,0x3
8000141c:	01250933          	add	s2,a0,s2
80001420:	fd442683          	lw	a3,-44(s0)
80001424:	fd042503          	lw	a0,-48(s0)
80001428:	00092583          	lw	a1,0(s2)
8000142c:	00492603          	lw	a2,4(s2)
80001430:	00c6a683          	lw	a3,12(a3)
80001434:	000680e7          	jalr	a3
80001438:	00050663          	beqz	a0,80001444 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x230>
8000143c:	00100513          	li	a0,1
80001440:	0080006f          	j	80001448 <_ZN4core3fmt5write17h33f2525cf67b440fE+0x234>
80001444:	00000513          	li	a0,0
80001448:	04c12083          	lw	ra,76(sp)
8000144c:	04812403          	lw	s0,72(sp)
80001450:	04412483          	lw	s1,68(sp)
80001454:	04012903          	lw	s2,64(sp)
80001458:	03c12983          	lw	s3,60(sp)
8000145c:	03812a03          	lw	s4,56(sp)
80001460:	03412a83          	lw	s5,52(sp)
80001464:	03012b03          	lw	s6,48(sp)
80001468:	02c12b83          	lw	s7,44(sp)
8000146c:	02812c03          	lw	s8,40(sp)
80001470:	05010113          	addi	sp,sp,80
80001474:	00008067          	ret

80001478 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE>:
80001478:	fc010113          	addi	sp,sp,-64
8000147c:	02112e23          	sw	ra,60(sp)
80001480:	02812c23          	sw	s0,56(sp)
80001484:	02912a23          	sw	s1,52(sp)
80001488:	03212823          	sw	s2,48(sp)
8000148c:	03312623          	sw	s3,44(sp)
80001490:	03412423          	sw	s4,40(sp)
80001494:	03512223          	sw	s5,36(sp)
80001498:	03612023          	sw	s6,32(sp)
8000149c:	01712e23          	sw	s7,28(sp)
800014a0:	01812c23          	sw	s8,24(sp)
800014a4:	01912a23          	sw	s9,20(sp)
800014a8:	01a12823          	sw	s10,16(sp)
800014ac:	01b12623          	sw	s11,12(sp)
800014b0:	04010413          	addi	s0,sp,64
800014b4:	00078493          	mv	s1,a5
800014b8:	00070913          	mv	s2,a4
800014bc:	00068993          	mv	s3,a3
800014c0:	00060a13          	mv	s4,a2
800014c4:	06058263          	beqz	a1,80001528 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0xb0>
800014c8:	01452b03          	lw	s6,20(a0)
800014cc:	001b7c13          	andi	s8,s6,1
800014d0:	00110ab7          	lui	s5,0x110
800014d4:	000c0463          	beqz	s8,800014dc <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x64>
800014d8:	02b00a93          	li	s5,43
800014dc:	009c0c33          	add	s8,s8,s1
800014e0:	004b7593          	andi	a1,s6,4
800014e4:	04058c63          	beqz	a1,8000153c <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0xc4>
800014e8:	01000593          	li	a1,16
800014ec:	06b9f063          	bgeu	s3,a1,8000154c <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0xd4>
800014f0:	00000593          	li	a1,0
800014f4:	02098263          	beqz	s3,80001518 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0xa0>
800014f8:	013a0633          	add	a2,s4,s3
800014fc:	000a0693          	mv	a3,s4
80001500:	00068703          	lb	a4,0(a3)
80001504:	fc072713          	slti	a4,a4,-64
80001508:	00174713          	xori	a4,a4,1
8000150c:	00168693          	addi	a3,a3,1
80001510:	00e585b3          	add	a1,a1,a4
80001514:	fec696e3          	bne	a3,a2,80001500 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x88>
80001518:	01858c33          	add	s8,a1,s8
8000151c:	00052583          	lw	a1,0(a0)
80001520:	08058863          	beqz	a1,800015b0 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x138>
80001524:	0500006f          	j	80001574 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0xfc>
80001528:	01452b03          	lw	s6,20(a0)
8000152c:	00148c13          	addi	s8,s1,1
80001530:	02d00a93          	li	s5,45
80001534:	004b7593          	andi	a1,s6,4
80001538:	fa0598e3          	bnez	a1,800014e8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x70>
8000153c:	00000a13          	li	s4,0
80001540:	00052583          	lw	a1,0(a0)
80001544:	02059863          	bnez	a1,80001574 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0xfc>
80001548:	0680006f          	j	800015b0 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x138>
8000154c:	00050b93          	mv	s7,a0
80001550:	000a0513          	mv	a0,s4
80001554:	00098593          	mv	a1,s3
80001558:	00000097          	auipc	ra,0x0
8000155c:	6c8080e7          	jalr	1736(ra) # 80001c20 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE>
80001560:	00050593          	mv	a1,a0
80001564:	000b8513          	mv	a0,s7
80001568:	01858c33          	add	s8,a1,s8
8000156c:	000ba583          	lw	a1,0(s7)
80001570:	04058063          	beqz	a1,800015b0 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x138>
80001574:	00452c83          	lw	s9,4(a0)
80001578:	039c7c63          	bgeu	s8,s9,800015b0 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x138>
8000157c:	008b7593          	andi	a1,s6,8
80001580:	0a059663          	bnez	a1,8000162c <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x1b4>
80001584:	01854583          	lbu	a1,24(a0)
80001588:	00300613          	li	a2,3
8000158c:	00c59463          	bne	a1,a2,80001594 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x11c>
80001590:	00100593          	li	a1,1
80001594:	418c8cb3          	sub	s9,s9,s8
80001598:	10058863          	beqz	a1,800016a8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x230>
8000159c:	00100613          	li	a2,1
800015a0:	0ec59e63          	bne	a1,a2,8000169c <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x224>
800015a4:	000c8593          	mv	a1,s9
800015a8:	00000c93          	li	s9,0
800015ac:	0fc0006f          	j	800016a8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x230>
800015b0:	01c52b03          	lw	s6,28(a0)
800015b4:	02052b83          	lw	s7,32(a0)
800015b8:	000b0513          	mv	a0,s6
800015bc:	000b8593          	mv	a1,s7
800015c0:	000a8613          	mv	a2,s5
800015c4:	000a0693          	mv	a3,s4
800015c8:	00098713          	mv	a4,s3
800015cc:	00000097          	auipc	ra,0x0
800015d0:	200080e7          	jalr	512(ra) # 800017cc <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h3fa4f425127ab4f2E>
800015d4:	00050593          	mv	a1,a0
800015d8:	00100513          	li	a0,1
800015dc:	0e059e63          	bnez	a1,800016d8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x260>
800015e0:	00cba303          	lw	t1,12(s7)
800015e4:	000b0513          	mv	a0,s6
800015e8:	00090593          	mv	a1,s2
800015ec:	00048613          	mv	a2,s1
800015f0:	03c12083          	lw	ra,60(sp)
800015f4:	03812403          	lw	s0,56(sp)
800015f8:	03412483          	lw	s1,52(sp)
800015fc:	03012903          	lw	s2,48(sp)
80001600:	02c12983          	lw	s3,44(sp)
80001604:	02812a03          	lw	s4,40(sp)
80001608:	02412a83          	lw	s5,36(sp)
8000160c:	02012b03          	lw	s6,32(sp)
80001610:	01c12b83          	lw	s7,28(sp)
80001614:	01812c03          	lw	s8,24(sp)
80001618:	01412c83          	lw	s9,20(sp)
8000161c:	01012d03          	lw	s10,16(sp)
80001620:	00c12d83          	lw	s11,12(sp)
80001624:	04010113          	addi	sp,sp,64
80001628:	00030067          	jr	t1
8000162c:	01052583          	lw	a1,16(a0)
80001630:	fcb42423          	sw	a1,-56(s0)
80001634:	03000593          	li	a1,48
80001638:	01854d03          	lbu	s10,24(a0)
8000163c:	01c52b03          	lw	s6,28(a0)
80001640:	02052b83          	lw	s7,32(a0)
80001644:	00b52823          	sw	a1,16(a0)
80001648:	00100593          	li	a1,1
8000164c:	00050d93          	mv	s11,a0
80001650:	00b50c23          	sb	a1,24(a0)
80001654:	000b0513          	mv	a0,s6
80001658:	000b8593          	mv	a1,s7
8000165c:	000a8613          	mv	a2,s5
80001660:	000a0693          	mv	a3,s4
80001664:	00098713          	mv	a4,s3
80001668:	00000097          	auipc	ra,0x0
8000166c:	164080e7          	jalr	356(ra) # 800017cc <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h3fa4f425127ab4f2E>
80001670:	06051263          	bnez	a0,800016d4 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x25c>
80001674:	418c89b3          	sub	s3,s9,s8
80001678:	00198993          	addi	s3,s3,1
8000167c:	fff98993          	addi	s3,s3,-1
80001680:	10098863          	beqz	s3,80001790 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x318>
80001684:	010ba603          	lw	a2,16(s7)
80001688:	03000593          	li	a1,48
8000168c:	000b0513          	mv	a0,s6
80001690:	000600e7          	jalr	a2
80001694:	fe0504e3          	beqz	a0,8000167c <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x204>
80001698:	03c0006f          	j	800016d4 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x25c>
8000169c:	001cd593          	srli	a1,s9,0x1
800016a0:	001c8c93          	addi	s9,s9,1
800016a4:	001cdc93          	srli	s9,s9,0x1
800016a8:	01c52b03          	lw	s6,28(a0)
800016ac:	02052b83          	lw	s7,32(a0)
800016b0:	01052c03          	lw	s8,16(a0)
800016b4:	00158d13          	addi	s10,a1,1
800016b8:	fffd0d13          	addi	s10,s10,-1
800016bc:	040d0c63          	beqz	s10,80001714 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x29c>
800016c0:	010ba603          	lw	a2,16(s7)
800016c4:	000b0513          	mv	a0,s6
800016c8:	000c0593          	mv	a1,s8
800016cc:	000600e7          	jalr	a2
800016d0:	fe0504e3          	beqz	a0,800016b8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x240>
800016d4:	00100513          	li	a0,1
800016d8:	03c12083          	lw	ra,60(sp)
800016dc:	03812403          	lw	s0,56(sp)
800016e0:	03412483          	lw	s1,52(sp)
800016e4:	03012903          	lw	s2,48(sp)
800016e8:	02c12983          	lw	s3,44(sp)
800016ec:	02812a03          	lw	s4,40(sp)
800016f0:	02412a83          	lw	s5,36(sp)
800016f4:	02012b03          	lw	s6,32(sp)
800016f8:	01c12b83          	lw	s7,28(sp)
800016fc:	01812c03          	lw	s8,24(sp)
80001700:	01412c83          	lw	s9,20(sp)
80001704:	01012d03          	lw	s10,16(sp)
80001708:	00c12d83          	lw	s11,12(sp)
8000170c:	04010113          	addi	sp,sp,64
80001710:	00008067          	ret
80001714:	000b0513          	mv	a0,s6
80001718:	000b8593          	mv	a1,s7
8000171c:	000a8613          	mv	a2,s5
80001720:	000a0693          	mv	a3,s4
80001724:	00098713          	mv	a4,s3
80001728:	00000097          	auipc	ra,0x0
8000172c:	0a4080e7          	jalr	164(ra) # 800017cc <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h3fa4f425127ab4f2E>
80001730:	00050593          	mv	a1,a0
80001734:	00100513          	li	a0,1
80001738:	fa0590e3          	bnez	a1,800016d8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x260>
8000173c:	00cba683          	lw	a3,12(s7)
80001740:	000b0513          	mv	a0,s6
80001744:	00090593          	mv	a1,s2
80001748:	00048613          	mv	a2,s1
8000174c:	000680e7          	jalr	a3
80001750:	00050593          	mv	a1,a0
80001754:	00100513          	li	a0,1
80001758:	f80590e3          	bnez	a1,800016d8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x260>
8000175c:	41900933          	neg	s2,s9
80001760:	fff00993          	li	s3,-1
80001764:	fff00493          	li	s1,-1
80001768:	00990533          	add	a0,s2,s1
8000176c:	05350c63          	beq	a0,s3,800017c4 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x34c>
80001770:	010ba603          	lw	a2,16(s7)
80001774:	000b0513          	mv	a0,s6
80001778:	000c0593          	mv	a1,s8
8000177c:	000600e7          	jalr	a2
80001780:	00148493          	addi	s1,s1,1
80001784:	fe0502e3          	beqz	a0,80001768 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x2f0>
80001788:	0194b533          	sltu	a0,s1,s9
8000178c:	f4dff06f          	j	800016d8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x260>
80001790:	00cba683          	lw	a3,12(s7)
80001794:	000b0513          	mv	a0,s6
80001798:	00090593          	mv	a1,s2
8000179c:	00048613          	mv	a2,s1
800017a0:	000680e7          	jalr	a3
800017a4:	00050593          	mv	a1,a0
800017a8:	00100513          	li	a0,1
800017ac:	f20596e3          	bnez	a1,800016d8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x260>
800017b0:	00000513          	li	a0,0
800017b4:	fc842583          	lw	a1,-56(s0)
800017b8:	00bda823          	sw	a1,16(s11)
800017bc:	01ad8c23          	sb	s10,24(s11)
800017c0:	f19ff06f          	j	800016d8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x260>
800017c4:	019cb533          	sltu	a0,s9,s9
800017c8:	f11ff06f          	j	800016d8 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE+0x260>

800017cc <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h3fa4f425127ab4f2E>:
800017cc:	fe010113          	addi	sp,sp,-32
800017d0:	00112e23          	sw	ra,28(sp)
800017d4:	00812c23          	sw	s0,24(sp)
800017d8:	00912a23          	sw	s1,20(sp)
800017dc:	01212823          	sw	s2,16(sp)
800017e0:	01312623          	sw	s3,12(sp)
800017e4:	01412423          	sw	s4,8(sp)
800017e8:	02010413          	addi	s0,sp,32
800017ec:	001107b7          	lui	a5,0x110
800017f0:	00070493          	mv	s1,a4
800017f4:	00068913          	mv	s2,a3
800017f8:	00058993          	mv	s3,a1
800017fc:	02f60263          	beq	a2,a5,80001820 <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h3fa4f425127ab4f2E+0x54>
80001800:	0109a683          	lw	a3,16(s3)
80001804:	00050a13          	mv	s4,a0
80001808:	00060593          	mv	a1,a2
8000180c:	000680e7          	jalr	a3
80001810:	00050613          	mv	a2,a0
80001814:	000a0513          	mv	a0,s4
80001818:	00100593          	li	a1,1
8000181c:	02061c63          	bnez	a2,80001854 <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h3fa4f425127ab4f2E+0x88>
80001820:	02090863          	beqz	s2,80001850 <_ZN4core3fmt9Formatter12pad_integral12write_prefix17h3fa4f425127ab4f2E+0x84>
80001824:	00c9a303          	lw	t1,12(s3)
80001828:	00090593          	mv	a1,s2
8000182c:	00048613          	mv	a2,s1
80001830:	01c12083          	lw	ra,28(sp)
80001834:	01812403          	lw	s0,24(sp)
80001838:	01412483          	lw	s1,20(sp)
8000183c:	01012903          	lw	s2,16(sp)
80001840:	00c12983          	lw	s3,12(sp)
80001844:	00812a03          	lw	s4,8(sp)
80001848:	02010113          	addi	sp,sp,32
8000184c:	00030067          	jr	t1
80001850:	00000593          	li	a1,0
80001854:	00058513          	mv	a0,a1
80001858:	01c12083          	lw	ra,28(sp)
8000185c:	01812403          	lw	s0,24(sp)
80001860:	01412483          	lw	s1,20(sp)
80001864:	01012903          	lw	s2,16(sp)
80001868:	00c12983          	lw	s3,12(sp)
8000186c:	00812a03          	lw	s4,8(sp)
80001870:	02010113          	addi	sp,sp,32
80001874:	00008067          	ret

80001878 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E>:
80001878:	fd010113          	addi	sp,sp,-48
8000187c:	02112623          	sw	ra,44(sp)
80001880:	02812423          	sw	s0,40(sp)
80001884:	02912223          	sw	s1,36(sp)
80001888:	03212023          	sw	s2,32(sp)
8000188c:	01312e23          	sw	s3,28(sp)
80001890:	01412c23          	sw	s4,24(sp)
80001894:	01512a23          	sw	s5,20(sp)
80001898:	01612823          	sw	s6,16(sp)
8000189c:	01712623          	sw	s7,12(sp)
800018a0:	03010413          	addi	s0,sp,48
800018a4:	00052683          	lw	a3,0(a0)
800018a8:	00852703          	lw	a4,8(a0)
800018ac:	00e6e7b3          	or	a5,a3,a4
800018b0:	00060493          	mv	s1,a2
800018b4:	00058913          	mv	s2,a1
800018b8:	14078863          	beqz	a5,80001a08 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x190>
800018bc:	00177713          	andi	a4,a4,1
800018c0:	0a070e63          	beqz	a4,8000197c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x104>
800018c4:	00c52703          	lw	a4,12(a0)
800018c8:	00990633          	add	a2,s2,s1
800018cc:	00000593          	li	a1,0
800018d0:	04070e63          	beqz	a4,8000192c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xb4>
800018d4:	0e000793          	li	a5,224
800018d8:	0f000813          	li	a6,240
800018dc:	00090893          	mv	a7,s2
800018e0:	01c0006f          	j	800018fc <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x84>
800018e4:	00188293          	addi	t0,a7,1
800018e8:	40b885b3          	sub	a1,a7,a1
800018ec:	fff70713          	addi	a4,a4,-1
800018f0:	40b285b3          	sub	a1,t0,a1
800018f4:	00028893          	mv	a7,t0
800018f8:	02070c63          	beqz	a4,80001930 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xb8>
800018fc:	08c88063          	beq	a7,a2,8000197c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x104>
80001900:	00088283          	lb	t0,0(a7)
80001904:	fe02d0e3          	bgez	t0,800018e4 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x6c>
80001908:	0ff2f293          	zext.b	t0,t0
8000190c:	00f2e863          	bltu	t0,a5,8000191c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xa4>
80001910:	0102ea63          	bltu	t0,a6,80001924 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xac>
80001914:	00488293          	addi	t0,a7,4
80001918:	fd1ff06f          	j	800018e8 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x70>
8000191c:	00288293          	addi	t0,a7,2
80001920:	fc9ff06f          	j	800018e8 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x70>
80001924:	00388293          	addi	t0,a7,3
80001928:	fc1ff06f          	j	800018e8 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x70>
8000192c:	00090293          	mv	t0,s2
80001930:	04c28663          	beq	t0,a2,8000197c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x104>
80001934:	00028603          	lb	a2,0(t0)
80001938:	00065663          	bgez	a2,80001944 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xcc>
8000193c:	0ff67613          	zext.b	a2,a2
80001940:	0e000713          	li	a4,224
80001944:	02058463          	beqz	a1,8000196c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xf4>
80001948:	0295f063          	bgeu	a1,s1,80001968 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xf0>
8000194c:	00b90633          	add	a2,s2,a1
80001950:	00060603          	lb	a2,0(a2)
80001954:	fc000713          	li	a4,-64
80001958:	00e65a63          	bge	a2,a4,8000196c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xf4>
8000195c:	00000613          	li	a2,0
80001960:	00001a63          	bnez	zero,80001974 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xfc>
80001964:	0180006f          	j	8000197c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x104>
80001968:	fe959ae3          	bne	a1,s1,8000195c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0xe4>
8000196c:	00090613          	mv	a2,s2
80001970:	00090663          	beqz	s2,8000197c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x104>
80001974:	00058493          	mv	s1,a1
80001978:	00060913          	mv	s2,a2
8000197c:	08068663          	beqz	a3,80001a08 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x190>
80001980:	00452983          	lw	s3,4(a0)
80001984:	01000593          	li	a1,16
80001988:	06b4f063          	bgeu	s1,a1,800019e8 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x170>
8000198c:	00000593          	li	a1,0
80001990:	02048263          	beqz	s1,800019b4 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x13c>
80001994:	00990633          	add	a2,s2,s1
80001998:	00090693          	mv	a3,s2
8000199c:	00068703          	lb	a4,0(a3)
800019a0:	fc072713          	slti	a4,a4,-64
800019a4:	00174713          	xori	a4,a4,1
800019a8:	00168693          	addi	a3,a3,1
800019ac:	00e585b3          	add	a1,a1,a4
800019b0:	fec696e3          	bne	a3,a2,8000199c <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x124>
800019b4:	0535fa63          	bgeu	a1,s3,80001a08 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x190>
800019b8:	01854603          	lbu	a2,24(a0)
800019bc:	ffd60693          	addi	a3,a2,-3
800019c0:	0016b693          	seqz	a3,a3
800019c4:	fff68693          	addi	a3,a3,-1
800019c8:	00c6f633          	and	a2,a3,a2
800019cc:	40b98ab3          	sub	s5,s3,a1
800019d0:	08060263          	beqz	a2,80001a54 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x1dc>
800019d4:	00100593          	li	a1,1
800019d8:	06b61863          	bne	a2,a1,80001a48 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x1d0>
800019dc:	000a8613          	mv	a2,s5
800019e0:	00000a93          	li	s5,0
800019e4:	0700006f          	j	80001a54 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x1dc>
800019e8:	00050a13          	mv	s4,a0
800019ec:	00090513          	mv	a0,s2
800019f0:	00048593          	mv	a1,s1
800019f4:	00000097          	auipc	ra,0x0
800019f8:	22c080e7          	jalr	556(ra) # 80001c20 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE>
800019fc:	00050593          	mv	a1,a0
80001a00:	000a0513          	mv	a0,s4
80001a04:	fb35eae3          	bltu	a1,s3,800019b8 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x140>
80001a08:	02052583          	lw	a1,32(a0)
80001a0c:	01c52503          	lw	a0,28(a0)
80001a10:	00c5a303          	lw	t1,12(a1)
80001a14:	00090593          	mv	a1,s2
80001a18:	00048613          	mv	a2,s1
80001a1c:	02c12083          	lw	ra,44(sp)
80001a20:	02812403          	lw	s0,40(sp)
80001a24:	02412483          	lw	s1,36(sp)
80001a28:	02012903          	lw	s2,32(sp)
80001a2c:	01c12983          	lw	s3,28(sp)
80001a30:	01812a03          	lw	s4,24(sp)
80001a34:	01412a83          	lw	s5,20(sp)
80001a38:	01012b03          	lw	s6,16(sp)
80001a3c:	00c12b83          	lw	s7,12(sp)
80001a40:	03010113          	addi	sp,sp,48
80001a44:	00030067          	jr	t1
80001a48:	001ad613          	srli	a2,s5,0x1
80001a4c:	001a8a93          	addi	s5,s5,1 # 110001 <.Lline_table_start2+0x10ec62>
80001a50:	001ada93          	srli	s5,s5,0x1
80001a54:	01c52983          	lw	s3,28(a0)
80001a58:	02052b03          	lw	s6,32(a0)
80001a5c:	01052a03          	lw	s4,16(a0)
80001a60:	00160b93          	addi	s7,a2,1
80001a64:	fffb8b93          	addi	s7,s7,-1
80001a68:	020b8063          	beqz	s7,80001a88 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x210>
80001a6c:	010b2603          	lw	a2,16(s6)
80001a70:	00098513          	mv	a0,s3
80001a74:	000a0593          	mv	a1,s4
80001a78:	000600e7          	jalr	a2
80001a7c:	fe0504e3          	beqz	a0,80001a64 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x1ec>
80001a80:	00100513          	li	a0,1
80001a84:	05c0006f          	j	80001ae0 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x268>
80001a88:	00cb2683          	lw	a3,12(s6)
80001a8c:	00098513          	mv	a0,s3
80001a90:	00090593          	mv	a1,s2
80001a94:	00048613          	mv	a2,s1
80001a98:	000680e7          	jalr	a3
80001a9c:	00050593          	mv	a1,a0
80001aa0:	00100513          	li	a0,1
80001aa4:	02059e63          	bnez	a1,80001ae0 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x268>
80001aa8:	41500933          	neg	s2,s5
80001aac:	fff00b93          	li	s7,-1
80001ab0:	fff00493          	li	s1,-1
80001ab4:	00990533          	add	a0,s2,s1
80001ab8:	03750063          	beq	a0,s7,80001ad8 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x260>
80001abc:	010b2603          	lw	a2,16(s6)
80001ac0:	00098513          	mv	a0,s3
80001ac4:	000a0593          	mv	a1,s4
80001ac8:	000600e7          	jalr	a2
80001acc:	00148493          	addi	s1,s1,1
80001ad0:	fe0502e3          	beqz	a0,80001ab4 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x23c>
80001ad4:	0080006f          	j	80001adc <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E+0x264>
80001ad8:	000a8493          	mv	s1,s5
80001adc:	0154b533          	sltu	a0,s1,s5
80001ae0:	02c12083          	lw	ra,44(sp)
80001ae4:	02812403          	lw	s0,40(sp)
80001ae8:	02412483          	lw	s1,36(sp)
80001aec:	02012903          	lw	s2,32(sp)
80001af0:	01c12983          	lw	s3,28(sp)
80001af4:	01812a03          	lw	s4,24(sp)
80001af8:	01412a83          	lw	s5,20(sp)
80001afc:	01012b03          	lw	s6,16(sp)
80001b00:	00c12b83          	lw	s7,12(sp)
80001b04:	03010113          	addi	sp,sp,48
80001b08:	00008067          	ret

80001b0c <_ZN4core3fmt9Formatter9write_str17h377b2dc3ce79ad33E>:
80001b0c:	ff010113          	addi	sp,sp,-16
80001b10:	00112623          	sw	ra,12(sp)
80001b14:	00812423          	sw	s0,8(sp)
80001b18:	01010413          	addi	s0,sp,16
80001b1c:	02052683          	lw	a3,32(a0)
80001b20:	01c52503          	lw	a0,28(a0)
80001b24:	00c6a303          	lw	t1,12(a3)
80001b28:	00c12083          	lw	ra,12(sp)
80001b2c:	00812403          	lw	s0,8(sp)
80001b30:	01010113          	addi	sp,sp,16
80001b34:	00030067          	jr	t1

80001b38 <_ZN4core3fmt17pointer_fmt_inner17h8c7f2eac4b33a418E>:
80001b38:	f6010113          	addi	sp,sp,-160
80001b3c:	08112e23          	sw	ra,156(sp)
80001b40:	08812c23          	sw	s0,152(sp)
80001b44:	08912a23          	sw	s1,148(sp)
80001b48:	09212823          	sw	s2,144(sp)
80001b4c:	09312623          	sw	s3,140(sp)
80001b50:	09412423          	sw	s4,136(sp)
80001b54:	0a010413          	addi	s0,sp,160
80001b58:	00058493          	mv	s1,a1
80001b5c:	0145a903          	lw	s2,20(a1)
80001b60:	0005a983          	lw	s3,0(a1)
80001b64:	0045aa03          	lw	s4,4(a1)
80001b68:	00497613          	andi	a2,s2,4
80001b6c:	00090593          	mv	a1,s2
80001b70:	00060e63          	beqz	a2,80001b8c <_ZN4core3fmt17pointer_fmt_inner17h8c7f2eac4b33a418E+0x54>
80001b74:	00896593          	ori	a1,s2,8
80001b78:	00099a63          	bnez	s3,80001b8c <_ZN4core3fmt17pointer_fmt_inner17h8c7f2eac4b33a418E+0x54>
80001b7c:	00100613          	li	a2,1
80001b80:	00c4a023          	sw	a2,0(s1)
80001b84:	00a00613          	li	a2,10
80001b88:	00c4a223          	sw	a2,4(s1)
80001b8c:	00000793          	li	a5,0
80001b90:	0045e593          	ori	a1,a1,4
80001b94:	00b4aa23          	sw	a1,20(s1)
80001b98:	fe740593          	addi	a1,s0,-25
80001b9c:	00a00613          	li	a2,10
80001ba0:	01c0006f          	j	80001bbc <_ZN4core3fmt17pointer_fmt_inner17h8c7f2eac4b33a418E+0x84>
80001ba4:	05768693          	addi	a3,a3,87
80001ba8:	00455513          	srli	a0,a0,0x4
80001bac:	00d58023          	sb	a3,0(a1)
80001bb0:	00178793          	addi	a5,a5,1 # 110001 <.Lline_table_start2+0x10ec62>
80001bb4:	fff58593          	addi	a1,a1,-1
80001bb8:	00050a63          	beqz	a0,80001bcc <_ZN4core3fmt17pointer_fmt_inner17h8c7f2eac4b33a418E+0x94>
80001bbc:	00f57693          	andi	a3,a0,15
80001bc0:	fec6f2e3          	bgeu	a3,a2,80001ba4 <_ZN4core3fmt17pointer_fmt_inner17h8c7f2eac4b33a418E+0x6c>
80001bc4:	03068693          	addi	a3,a3,48
80001bc8:	fe1ff06f          	j	80001ba8 <_ZN4core3fmt17pointer_fmt_inner17h8c7f2eac4b33a418E+0x70>
80001bcc:	f6840513          	addi	a0,s0,-152
80001bd0:	40f50533          	sub	a0,a0,a5
80001bd4:	08050713          	addi	a4,a0,128
80001bd8:	80003637          	lui	a2,0x80003
80001bdc:	42c60613          	addi	a2,a2,1068 # 8000342c <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.291>
80001be0:	00100593          	li	a1,1
80001be4:	00200693          	li	a3,2
80001be8:	00048513          	mv	a0,s1
80001bec:	00000097          	auipc	ra,0x0
80001bf0:	88c080e7          	jalr	-1908(ra) # 80001478 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE>
80001bf4:	0134a023          	sw	s3,0(s1)
80001bf8:	0144a223          	sw	s4,4(s1)
80001bfc:	0124aa23          	sw	s2,20(s1)
80001c00:	09c12083          	lw	ra,156(sp)
80001c04:	09812403          	lw	s0,152(sp)
80001c08:	09412483          	lw	s1,148(sp)
80001c0c:	09012903          	lw	s2,144(sp)
80001c10:	08c12983          	lw	s3,140(sp)
80001c14:	08812a03          	lw	s4,136(sp)
80001c18:	0a010113          	addi	sp,sp,160
80001c1c:	00008067          	ret

80001c20 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE>:
80001c20:	ff010113          	addi	sp,sp,-16
80001c24:	00112623          	sw	ra,12(sp)
80001c28:	00812423          	sw	s0,8(sp)
80001c2c:	01010413          	addi	s0,sp,16
80001c30:	00050613          	mv	a2,a0
80001c34:	00350513          	addi	a0,a0,3
80001c38:	ffc57513          	andi	a0,a0,-4
80001c3c:	40c502b3          	sub	t0,a0,a2
80001c40:	0255fc63          	bgeu	a1,t0,80001c78 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x58>
80001c44:	00000513          	li	a0,0
80001c48:	02058063          	beqz	a1,80001c68 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x48>
80001c4c:	00b605b3          	add	a1,a2,a1
80001c50:	00060683          	lb	a3,0(a2)
80001c54:	fc06a693          	slti	a3,a3,-64
80001c58:	0016c693          	xori	a3,a3,1
80001c5c:	00160613          	addi	a2,a2,1
80001c60:	00d50533          	add	a0,a0,a3
80001c64:	feb616e3          	bne	a2,a1,80001c50 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x30>
80001c68:	00c12083          	lw	ra,12(sp)
80001c6c:	00812403          	lw	s0,8(sp)
80001c70:	01010113          	addi	sp,sp,16
80001c74:	00008067          	ret
80001c78:	405586b3          	sub	a3,a1,t0
80001c7c:	0026d893          	srli	a7,a3,0x2
80001c80:	fc0882e3          	beqz	a7,80001c44 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x24>
80001c84:	005602b3          	add	t0,a2,t0
80001c88:	0036f593          	andi	a1,a3,3
80001c8c:	00c51663          	bne	a0,a2,80001c98 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x78>
80001c90:	00000513          	li	a0,0
80001c94:	0200006f          	j	80001cb4 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x94>
80001c98:	00000513          	li	a0,0
80001c9c:	00060703          	lb	a4,0(a2)
80001ca0:	fc072713          	slti	a4,a4,-64
80001ca4:	00174713          	xori	a4,a4,1
80001ca8:	00160613          	addi	a2,a2,1
80001cac:	00e50533          	add	a0,a0,a4
80001cb0:	fe5616e3          	bne	a2,t0,80001c9c <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x7c>
80001cb4:	00000713          	li	a4,0
80001cb8:	02058463          	beqz	a1,80001ce0 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0xc0>
80001cbc:	ffc6f613          	andi	a2,a3,-4
80001cc0:	00c28633          	add	a2,t0,a2
80001cc4:	00060683          	lb	a3,0(a2)
80001cc8:	fc06a693          	slti	a3,a3,-64
80001ccc:	0016c693          	xori	a3,a3,1
80001cd0:	00d70733          	add	a4,a4,a3
80001cd4:	fff58593          	addi	a1,a1,-1
80001cd8:	00160613          	addi	a2,a2,1
80001cdc:	fe0594e3          	bnez	a1,80001cc4 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0xa4>
80001ce0:	010105b7          	lui	a1,0x1010
80001ce4:	10158613          	addi	a2,a1,257 # 1010101 <.Lline_table_start2+0x100ed62>
80001ce8:	00ff05b7          	lui	a1,0xff0
80001cec:	0ff58593          	addi	a1,a1,255 # ff00ff <.Lline_table_start2+0xfeed60>
80001cf0:	00a70533          	add	a0,a4,a0
80001cf4:	00400793          	li	a5,4
80001cf8:	0340006f          	j	80001d2c <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x10c>
80001cfc:	005702b3          	add	t0,a4,t0
80001d00:	410688b3          	sub	a7,a3,a6
80001d04:	00387313          	andi	t1,a6,3
80001d08:	00b3fe33          	and	t3,t2,a1
80001d0c:	0083d393          	srli	t2,t2,0x8
80001d10:	00b3f3b3          	and	t2,t2,a1
80001d14:	01c383b3          	add	t2,t2,t3
80001d18:	01039e13          	slli	t3,t2,0x10
80001d1c:	007e03b3          	add	t2,t3,t2
80001d20:	0103d393          	srli	t2,t2,0x10
80001d24:	00a38533          	add	a0,t2,a0
80001d28:	0a031a63          	bnez	t1,80001ddc <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x1bc>
80001d2c:	f2088ee3          	beqz	a7,80001c68 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x48>
80001d30:	00088693          	mv	a3,a7
80001d34:	00028713          	mv	a4,t0
80001d38:	0c000893          	li	a7,192
80001d3c:	00068813          	mv	a6,a3
80001d40:	0116e463          	bltu	a3,a7,80001d48 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x128>
80001d44:	0c000813          	li	a6,192
80001d48:	00281293          	slli	t0,a6,0x2
80001d4c:	00000393          	li	t2,0
80001d50:	faf6e6e3          	bltu	a3,a5,80001cfc <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0xdc>
80001d54:	3f02f893          	andi	a7,t0,1008
80001d58:	011708b3          	add	a7,a4,a7
80001d5c:	00070313          	mv	t1,a4
80001d60:	00032e03          	lw	t3,0(t1)
80001d64:	fffe4e93          	not	t4,t3
80001d68:	007ede93          	srli	t4,t4,0x7
80001d6c:	006e5e13          	srli	t3,t3,0x6
80001d70:	00432f03          	lw	t5,4(t1)
80001d74:	01ceee33          	or	t3,t4,t3
80001d78:	00ce7e33          	and	t3,t3,a2
80001d7c:	007e03b3          	add	t2,t3,t2
80001d80:	ffff4e13          	not	t3,t5
80001d84:	007e5e13          	srli	t3,t3,0x7
80001d88:	00832e83          	lw	t4,8(t1)
80001d8c:	006f5f13          	srli	t5,t5,0x6
80001d90:	01ee6e33          	or	t3,t3,t5
80001d94:	00ce7e33          	and	t3,t3,a2
80001d98:	fffecf13          	not	t5,t4
80001d9c:	007f5f13          	srli	t5,t5,0x7
80001da0:	006ede93          	srli	t4,t4,0x6
80001da4:	01df6eb3          	or	t4,t5,t4
80001da8:	00c32f03          	lw	t5,12(t1)
80001dac:	00cefeb3          	and	t4,t4,a2
80001db0:	01ce8e33          	add	t3,t4,t3
80001db4:	007e03b3          	add	t2,t3,t2
80001db8:	ffff4e13          	not	t3,t5
80001dbc:	007e5e13          	srli	t3,t3,0x7
80001dc0:	006f5e93          	srli	t4,t5,0x6
80001dc4:	01de6e33          	or	t3,t3,t4
80001dc8:	00ce7e33          	and	t3,t3,a2
80001dcc:	01030313          	addi	t1,t1,16
80001dd0:	007e03b3          	add	t2,t3,t2
80001dd4:	f91316e3          	bne	t1,a7,80001d60 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x140>
80001dd8:	f25ff06f          	j	80001cfc <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0xdc>
80001ddc:	00000793          	li	a5,0
80001de0:	0fc87813          	andi	a6,a6,252
80001de4:	00281813          	slli	a6,a6,0x2
80001de8:	01070733          	add	a4,a4,a6
80001dec:	0c06b813          	sltiu	a6,a3,192
80001df0:	41000833          	neg	a6,a6
80001df4:	0106f6b3          	and	a3,a3,a6
80001df8:	0036f693          	andi	a3,a3,3
80001dfc:	00269693          	slli	a3,a3,0x2
80001e00:	00072803          	lw	a6,0(a4)
80001e04:	00470713          	addi	a4,a4,4
80001e08:	fff84893          	not	a7,a6
80001e0c:	0078d893          	srli	a7,a7,0x7
80001e10:	00685813          	srli	a6,a6,0x6
80001e14:	0108e833          	or	a6,a7,a6
80001e18:	00c87833          	and	a6,a6,a2
80001e1c:	ffc68693          	addi	a3,a3,-4
80001e20:	00f807b3          	add	a5,a6,a5
80001e24:	fc069ee3          	bnez	a3,80001e00 <_ZN4core3str5count14do_count_chars17hb452917a768f82baE+0x1e0>
80001e28:	00b7f633          	and	a2,a5,a1
80001e2c:	0087d793          	srli	a5,a5,0x8
80001e30:	00b7f5b3          	and	a1,a5,a1
80001e34:	00c585b3          	add	a1,a1,a2
80001e38:	01059613          	slli	a2,a1,0x10
80001e3c:	00b605b3          	add	a1,a2,a1
80001e40:	0105d593          	srli	a1,a1,0x10
80001e44:	00a58533          	add	a0,a1,a0
80001e48:	00c12083          	lw	ra,12(sp)
80001e4c:	00812403          	lw	s0,8(sp)
80001e50:	01010113          	addi	sp,sp,16
80001e54:	00008067          	ret

80001e58 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17he02baeedde33e183E>:
80001e58:	f7010113          	addi	sp,sp,-144
80001e5c:	08112623          	sw	ra,140(sp)
80001e60:	08812423          	sw	s0,136(sp)
80001e64:	09010413          	addi	s0,sp,144
80001e68:	00052603          	lw	a2,0(a0)
80001e6c:	00058513          	mv	a0,a1
80001e70:	00000793          	li	a5,0
80001e74:	ff740593          	addi	a1,s0,-9
80001e78:	00a00693          	li	a3,10
80001e7c:	01c0006f          	j	80001e98 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17he02baeedde33e183E+0x40>
80001e80:	05770713          	addi	a4,a4,87
80001e84:	00465613          	srli	a2,a2,0x4
80001e88:	00e58023          	sb	a4,0(a1)
80001e8c:	00178793          	addi	a5,a5,1
80001e90:	fff58593          	addi	a1,a1,-1
80001e94:	00060a63          	beqz	a2,80001ea8 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17he02baeedde33e183E+0x50>
80001e98:	00f67713          	andi	a4,a2,15
80001e9c:	fed772e3          	bgeu	a4,a3,80001e80 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17he02baeedde33e183E+0x28>
80001ea0:	03070713          	addi	a4,a4,48
80001ea4:	fe1ff06f          	j	80001e84 <_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17he02baeedde33e183E+0x2c>
80001ea8:	f7840593          	addi	a1,s0,-136
80001eac:	40f585b3          	sub	a1,a1,a5
80001eb0:	08058713          	addi	a4,a1,128
80001eb4:	80003637          	lui	a2,0x80003
80001eb8:	42c60613          	addi	a2,a2,1068 # 8000342c <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.291>
80001ebc:	00100593          	li	a1,1
80001ec0:	00200693          	li	a3,2
80001ec4:	fffff097          	auipc	ra,0xfffff
80001ec8:	5b4080e7          	jalr	1460(ra) # 80001478 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE>
80001ecc:	08c12083          	lw	ra,140(sp)
80001ed0:	08812403          	lw	s0,136(sp)
80001ed4:	09010113          	addi	sp,sp,144
80001ed8:	00008067          	ret

80001edc <_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17h0f2cd5210a0eafd0E>:
80001edc:	ff010113          	addi	sp,sp,-16
80001ee0:	00112623          	sw	ra,12(sp)
80001ee4:	00812423          	sw	s0,8(sp)
80001ee8:	01010413          	addi	s0,sp,16
80001eec:	00052503          	lw	a0,0(a0)
80001ef0:	00058613          	mv	a2,a1
80001ef4:	00100593          	li	a1,1
80001ef8:	00c12083          	lw	ra,12(sp)
80001efc:	00812403          	lw	s0,8(sp)
80001f00:	01010113          	addi	sp,sp,16
80001f04:	00000317          	auipc	t1,0x0
80001f08:	00830067          	jr	8(t1) # 80001f0c <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17h61a1ae45d60dd3c0E>

80001f0c <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17h61a1ae45d60dd3c0E>:
80001f0c:	fe010113          	addi	sp,sp,-32
80001f10:	00112e23          	sw	ra,28(sp)
80001f14:	00812c23          	sw	s0,24(sp)
80001f18:	00912a23          	sw	s1,20(sp)
80001f1c:	01212823          	sw	s2,16(sp)
80001f20:	02010413          	addi	s0,sp,32
80001f24:	00060693          	mv	a3,a2
80001f28:	00455793          	srli	a5,a0,0x4
80001f2c:	00a00713          	li	a4,10
80001f30:	27100813          	li	a6,625
80001f34:	80003637          	lui	a2,0x80003
80001f38:	42e60613          	addi	a2,a2,1070 # 8000342e <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.293>
80001f3c:	0307f663          	bgeu	a5,a6,80001f68 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17h61a1ae45d60dd3c0E+0x5c>
80001f40:	06300793          	li	a5,99
80001f44:	0ca7ea63          	bltu	a5,a0,80002018 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17h61a1ae45d60dd3c0E+0x10c>
80001f48:	00a00793          	li	a5,10
80001f4c:	12f57263          	bgeu	a0,a5,80002070 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17h61a1ae45d60dd3c0E+0x164>
80001f50:	fff70793          	addi	a5,a4,-1
80001f54:	fe640613          	addi	a2,s0,-26
80001f58:	00f60633          	add	a2,a2,a5
80001f5c:	03056513          	ori	a0,a0,48
80001f60:	00a60023          	sb	a0,0(a2)
80001f64:	1300006f          	j	80002094 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17h61a1ae45d60dd3c0E+0x188>
80001f68:	00000713          	li	a4,0
80001f6c:	fec40793          	addi	a5,s0,-20
80001f70:	fee40813          	addi	a6,s0,-18
80001f74:	d1b718b7          	lui	a7,0xd1b71
80001f78:	75988893          	addi	a7,a7,1881 # d1b71759 <__kernel_end_phys+0x51a5d759>
80001f7c:	000022b7          	lui	t0,0x2
80001f80:	71028293          	addi	t0,t0,1808 # 2710 <.Lline_table_start2+0x1371>
80001f84:	00001337          	lui	t1,0x1
80001f88:	47b30313          	addi	t1,t1,1147 # 147b <.Lline_table_start2+0xdc>
80001f8c:	06400393          	li	t2,100
80001f90:	05f5ee37          	lui	t3,0x5f5e
80001f94:	0ffe0e13          	addi	t3,t3,255 # 5f5e0ff <.Lline_table_start2+0x5f5cd60>
80001f98:	00050e93          	mv	t4,a0
80001f9c:	03153533          	mulhu	a0,a0,a7
80001fa0:	00d55513          	srli	a0,a0,0xd
80001fa4:	02550f33          	mul	t5,a0,t0
80001fa8:	41ee8f33          	sub	t5,t4,t5
80001fac:	010f1f93          	slli	t6,t5,0x10
80001fb0:	012fdf93          	srli	t6,t6,0x12
80001fb4:	026f8fb3          	mul	t6,t6,t1
80001fb8:	011fd493          	srli	s1,t6,0x11
80001fbc:	010fdf93          	srli	t6,t6,0x10
80001fc0:	7fefff93          	andi	t6,t6,2046
80001fc4:	027484b3          	mul	s1,s1,t2
80001fc8:	409f0f33          	sub	t5,t5,s1
80001fcc:	011f1f13          	slli	t5,t5,0x11
80001fd0:	01f60fb3          	add	t6,a2,t6
80001fd4:	001fc483          	lbu	s1,1(t6)
80001fd8:	010f5f13          	srli	t5,t5,0x10
80001fdc:	00e78933          	add	s2,a5,a4
80001fe0:	000fcf83          	lbu	t6,0(t6)
80001fe4:	009900a3          	sb	s1,1(s2)
80001fe8:	01e60f33          	add	t5,a2,t5
80001fec:	001f4483          	lbu	s1,1(t5)
80001ff0:	000f4f03          	lbu	t5,0(t5)
80001ff4:	01f90023          	sb	t6,0(s2)
80001ff8:	00e80fb3          	add	t6,a6,a4
80001ffc:	009f80a3          	sb	s1,1(t6)
80002000:	01ef8023          	sb	t5,0(t6)
80002004:	ffc70713          	addi	a4,a4,-4
80002008:	f9de68e3          	bltu	t3,t4,80001f98 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17h61a1ae45d60dd3c0E+0x8c>
8000200c:	00a70713          	addi	a4,a4,10
80002010:	06300793          	li	a5,99
80002014:	f2a7fae3          	bgeu	a5,a0,80001f48 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17h61a1ae45d60dd3c0E+0x3c>
80002018:	01051793          	slli	a5,a0,0x10
8000201c:	0127d793          	srli	a5,a5,0x12
80002020:	00001837          	lui	a6,0x1
80002024:	47b80813          	addi	a6,a6,1147 # 147b <.Lline_table_start2+0xdc>
80002028:	030787b3          	mul	a5,a5,a6
8000202c:	0117d793          	srli	a5,a5,0x11
80002030:	06400813          	li	a6,100
80002034:	03078833          	mul	a6,a5,a6
80002038:	41050533          	sub	a0,a0,a6
8000203c:	01151513          	slli	a0,a0,0x11
80002040:	01055513          	srli	a0,a0,0x10
80002044:	ffe70713          	addi	a4,a4,-2
80002048:	00a60533          	add	a0,a2,a0
8000204c:	00154803          	lbu	a6,1(a0)
80002050:	00054503          	lbu	a0,0(a0)
80002054:	fe640893          	addi	a7,s0,-26
80002058:	00e888b3          	add	a7,a7,a4
8000205c:	010880a3          	sb	a6,1(a7)
80002060:	00a88023          	sb	a0,0(a7)
80002064:	00078513          	mv	a0,a5
80002068:	00a00793          	li	a5,10
8000206c:	eef562e3          	bltu	a0,a5,80001f50 <_ZN4core3fmt3num3imp21_$LT$impl$u20$u32$GT$4_fmt17h61a1ae45d60dd3c0E+0x44>
80002070:	00151513          	slli	a0,a0,0x1
80002074:	ffe70793          	addi	a5,a4,-2
80002078:	00a60533          	add	a0,a2,a0
8000207c:	00154603          	lbu	a2,1(a0)
80002080:	00054503          	lbu	a0,0(a0)
80002084:	fe640713          	addi	a4,s0,-26
80002088:	00f70733          	add	a4,a4,a5
8000208c:	00c700a3          	sb	a2,1(a4)
80002090:	00a70023          	sb	a0,0(a4)
80002094:	fe640713          	addi	a4,s0,-26
80002098:	00f70733          	add	a4,a4,a5
8000209c:	00a00513          	li	a0,10
800020a0:	40f507b3          	sub	a5,a0,a5
800020a4:	00100613          	li	a2,1
800020a8:	00068513          	mv	a0,a3
800020ac:	00000693          	li	a3,0
800020b0:	fffff097          	auipc	ra,0xfffff
800020b4:	3c8080e7          	jalr	968(ra) # 80001478 <_ZN4core3fmt9Formatter12pad_integral17h274527e96284773cE>
800020b8:	01c12083          	lw	ra,28(sp)
800020bc:	01812403          	lw	s0,24(sp)
800020c0:	01412483          	lw	s1,20(sp)
800020c4:	01012903          	lw	s2,16(sp)
800020c8:	02010113          	addi	sp,sp,32
800020cc:	00008067          	ret

800020d0 <_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17hb2addfb6a0710c9bE>:
800020d0:	ff010113          	addi	sp,sp,-16
800020d4:	00112623          	sw	ra,12(sp)
800020d8:	00812423          	sw	s0,8(sp)
800020dc:	01010413          	addi	s0,sp,16
800020e0:	00452603          	lw	a2,4(a0)
800020e4:	00052503          	lw	a0,0(a0)
800020e8:	00c62303          	lw	t1,12(a2)
800020ec:	00c12083          	lw	ra,12(sp)
800020f0:	00812403          	lw	s0,8(sp)
800020f4:	01010113          	addi	sp,sp,16
800020f8:	00030067          	jr	t1

800020fc <_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17ha816cb0eaf1a1493E>:
800020fc:	ff010113          	addi	sp,sp,-16
80002100:	00112623          	sw	ra,12(sp)
80002104:	00812423          	sw	s0,8(sp)
80002108:	01010413          	addi	s0,sp,16
8000210c:	00052683          	lw	a3,0(a0)
80002110:	00452603          	lw	a2,4(a0)
80002114:	00058513          	mv	a0,a1
80002118:	00068593          	mv	a1,a3
8000211c:	00c12083          	lw	ra,12(sp)
80002120:	00812403          	lw	s0,8(sp)
80002124:	01010113          	addi	sp,sp,16
80002128:	fffff317          	auipc	t1,0xfffff
8000212c:	75030067          	jr	1872(t1) # 80001878 <_ZN4core3fmt9Formatter3pad17h236947e913c47ba6E>

80002130 <memcpy>:
80002130:	ff010113          	addi	sp,sp,-16
80002134:	00112623          	sw	ra,12(sp)
80002138:	00812423          	sw	s0,8(sp)
8000213c:	01010413          	addi	s0,sp,16
80002140:	01000693          	li	a3,16
80002144:	08d66063          	bltu	a2,a3,800021c4 <memcpy+0x94>
80002148:	40a006b3          	neg	a3,a0
8000214c:	0036f693          	andi	a3,a3,3
80002150:	00d50733          	add	a4,a0,a3
80002154:	02e57463          	bgeu	a0,a4,8000217c <memcpy+0x4c>
80002158:	00068793          	mv	a5,a3
8000215c:	00050813          	mv	a6,a0
80002160:	00058893          	mv	a7,a1
80002164:	0008c283          	lbu	t0,0(a7)
80002168:	00580023          	sb	t0,0(a6)
8000216c:	00180813          	addi	a6,a6,1
80002170:	fff78793          	addi	a5,a5,-1
80002174:	00188893          	addi	a7,a7,1
80002178:	fe0796e3          	bnez	a5,80002164 <memcpy+0x34>
8000217c:	00d585b3          	add	a1,a1,a3
80002180:	40d60633          	sub	a2,a2,a3
80002184:	ffc67793          	andi	a5,a2,-4
80002188:	0035f813          	andi	a6,a1,3
8000218c:	00f706b3          	add	a3,a4,a5
80002190:	06081463          	bnez	a6,800021f8 <memcpy+0xc8>
80002194:	00d77e63          	bgeu	a4,a3,800021b0 <memcpy+0x80>
80002198:	00058813          	mv	a6,a1
8000219c:	00082883          	lw	a7,0(a6)
800021a0:	01172023          	sw	a7,0(a4)
800021a4:	00470713          	addi	a4,a4,4
800021a8:	00480813          	addi	a6,a6,4
800021ac:	fed768e3          	bltu	a4,a3,8000219c <memcpy+0x6c>
800021b0:	00f585b3          	add	a1,a1,a5
800021b4:	00367613          	andi	a2,a2,3
800021b8:	00c68733          	add	a4,a3,a2
800021bc:	00e6ea63          	bltu	a3,a4,800021d0 <memcpy+0xa0>
800021c0:	0280006f          	j	800021e8 <memcpy+0xb8>
800021c4:	00050693          	mv	a3,a0
800021c8:	00c50733          	add	a4,a0,a2
800021cc:	00e57e63          	bgeu	a0,a4,800021e8 <memcpy+0xb8>
800021d0:	0005c703          	lbu	a4,0(a1)
800021d4:	00e68023          	sb	a4,0(a3)
800021d8:	00168693          	addi	a3,a3,1
800021dc:	fff60613          	addi	a2,a2,-1
800021e0:	00158593          	addi	a1,a1,1
800021e4:	fe0616e3          	bnez	a2,800021d0 <memcpy+0xa0>
800021e8:	00c12083          	lw	ra,12(sp)
800021ec:	00812403          	lw	s0,8(sp)
800021f0:	01010113          	addi	sp,sp,16
800021f4:	00008067          	ret
800021f8:	fad77ce3          	bgeu	a4,a3,800021b0 <memcpy+0x80>
800021fc:	00359893          	slli	a7,a1,0x3
80002200:	0188f813          	andi	a6,a7,24
80002204:	ffc5f293          	andi	t0,a1,-4
80002208:	0002a303          	lw	t1,0(t0)
8000220c:	411008b3          	neg	a7,a7
80002210:	0188f893          	andi	a7,a7,24
80002214:	00428293          	addi	t0,t0,4
80002218:	0002a383          	lw	t2,0(t0)
8000221c:	01035333          	srl	t1,t1,a6
80002220:	01139e33          	sll	t3,t2,a7
80002224:	006e6333          	or	t1,t3,t1
80002228:	00672023          	sw	t1,0(a4)
8000222c:	00470713          	addi	a4,a4,4
80002230:	00428293          	addi	t0,t0,4
80002234:	00038313          	mv	t1,t2
80002238:	fed760e3          	bltu	a4,a3,80002218 <memcpy+0xe8>
8000223c:	f75ff06f          	j	800021b0 <memcpy+0x80>

80002240 <memset>:
80002240:	ff010113          	addi	sp,sp,-16
80002244:	00112623          	sw	ra,12(sp)
80002248:	00812423          	sw	s0,8(sp)
8000224c:	01010413          	addi	s0,sp,16
80002250:	01000693          	li	a3,16
80002254:	08d66263          	bltu	a2,a3,800022d8 <memset+0x98>
80002258:	40a006b3          	neg	a3,a0
8000225c:	0036f693          	andi	a3,a3,3
80002260:	00d50733          	add	a4,a0,a3
80002264:	00e57e63          	bgeu	a0,a4,80002280 <memset+0x40>
80002268:	00068793          	mv	a5,a3
8000226c:	00050813          	mv	a6,a0
80002270:	00b80023          	sb	a1,0(a6)
80002274:	fff78793          	addi	a5,a5,-1
80002278:	00180813          	addi	a6,a6,1
8000227c:	fe079ae3          	bnez	a5,80002270 <memset+0x30>
80002280:	40d60633          	sub	a2,a2,a3
80002284:	ffc67693          	andi	a3,a2,-4
80002288:	00d706b3          	add	a3,a4,a3
8000228c:	02d77063          	bgeu	a4,a3,800022ac <memset+0x6c>
80002290:	0ff5f793          	zext.b	a5,a1
80002294:	01010837          	lui	a6,0x1010
80002298:	10180813          	addi	a6,a6,257 # 1010101 <.Lline_table_start2+0x100ed62>
8000229c:	030787b3          	mul	a5,a5,a6
800022a0:	00f72023          	sw	a5,0(a4)
800022a4:	00470713          	addi	a4,a4,4
800022a8:	fed76ce3          	bltu	a4,a3,800022a0 <memset+0x60>
800022ac:	00367613          	andi	a2,a2,3
800022b0:	00c68733          	add	a4,a3,a2
800022b4:	00e6fa63          	bgeu	a3,a4,800022c8 <memset+0x88>
800022b8:	00b68023          	sb	a1,0(a3)
800022bc:	fff60613          	addi	a2,a2,-1
800022c0:	00168693          	addi	a3,a3,1
800022c4:	fe061ae3          	bnez	a2,800022b8 <memset+0x78>
800022c8:	00c12083          	lw	ra,12(sp)
800022cc:	00812403          	lw	s0,8(sp)
800022d0:	01010113          	addi	sp,sp,16
800022d4:	00008067          	ret
800022d8:	00050693          	mv	a3,a0
800022dc:	00c50733          	add	a4,a0,a2
800022e0:	fce56ce3          	bltu	a0,a4,800022b8 <memset+0x78>
800022e4:	fe5ff06f          	j	800022c8 <memset+0x88>
	...

Disassembly of section .rodata:

80003000 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.0>:
80003000:	0000                	.insn	2, 0x
80003002:	0000                	.insn	2, 0x
80003004:	0004                	.insn	2, 0x0004
80003006:	0000                	.insn	2, 0x
80003008:	0004                	.insn	2, 0x0004
8000300a:	0000                	.insn	2, 0x
8000300c:	01d4                	.insn	2, 0x01d4
8000300e:	8000                	.insn	2, 0x8000

80003010 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.1>:
80003010:	7245                	.insn	2, 0x7245
80003012:	6f72                	.insn	2, 0x6f72
80003014:	                	.insn	2, 0x4972

80003015 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.8>:
80003015:	6e49                	.insn	2, 0x6e49
80003017:	75727473          	.insn	4, 0x75727473
8000301b:	6f697463          	bgeu	s2,s6,80003703 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.293+0x2d5>
8000301f:	4d6e                	.insn	2, 0x4d6e
80003021:	7369                	.insn	2, 0x7369
80003023:	6c61                	.insn	2, 0x6c61
80003025:	6769                	.insn	2, 0x6769
80003027:	656e                	.insn	2, 0x656e
80003029:	0064                	.insn	2, 0x0064
8000302b:	6100                	.insn	2, 0x6100
8000302d:	72657373          	.insn	4, 0x72657373
80003031:	6974                	.insn	2, 0x6974
80003033:	60206e6f          	jal	t3,80009635 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3+0x5e19>
80003037:	656c                	.insn	2, 0x656c
80003039:	7466                	.insn	2, 0x7466
8000303b:	4920                	.insn	2, 0x4920
8000303d:	736e                	.insn	2, 0x736e
8000303f:	7274                	.insn	2, 0x7274
80003041:	6375                	.insn	2, 0x6375
80003043:	6974                	.insn	2, 0x6974
80003045:	61466e6f          	jal	t3,80069659 <_ZN7SuperOS6kalloc13KALLOC_BUFFER17h2f62f31b270c2cc8E+0x55e39>
80003049:	6c75                	.insn	2, 0x6c75
8000304b:	0074                	.insn	2, 0x0074
8000304d:	0201                	.insn	2, 0x0201
8000304f:	06050403          	lb	s0,96(a0)
80003053:	0e090807          	.insn	4, 0x0e090807
80003057:	0b0a                	.insn	2, 0x0b0a
80003059:	0e0c                	.insn	2, 0x0e0c
8000305b:	200d                	.insn	2, 0x200d
8000305d:	6972                	.insn	2, 0x6972
8000305f:	60746867          	.insn	4, 0x60746867
80003063:	6620                	.insn	2, 0x6620
80003065:	6961                	.insn	2, 0x6961
80003067:	656c                	.insn	2, 0x656c
80003069:	3a64                	.insn	2, 0x3a64
8000306b:	                	.insn	2, 0x4920

8000306c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.10>:
8000306c:	6c49                	.insn	2, 0x6c49
8000306e:	656c                	.insn	2, 0x656c
80003070:	496c6167          	.insn	4, 0x496c6167
80003074:	736e                	.insn	2, 0x736e
80003076:	7274                	.insn	2, 0x7274
80003078:	6375                	.insn	2, 0x6375
8000307a:	6974                	.insn	2, 0x6974
8000307c:	          	jal	t3,800297a0 <_ZN7SuperOS6kalloc13KALLOC_BUFFER17h2f62f31b270c2cc8E+0x15f80>

8000307e <.Lanon.10e9e605f29f28b577aacdba1819c9a4.11>:
8000307e:	7242                	.insn	2, 0x7242
80003080:	6165                	.insn	2, 0x6165
80003082:	696f706b          	.insn	4, 0x696f706b
80003086:	746e                	.insn	2, 0x746e

80003088 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.12>:
80003088:	6f4c                	.insn	2, 0x6f4c
8000308a:	6461                	.insn	2, 0x6461
8000308c:	694d                	.insn	2, 0x694d
8000308e:	696c6173          	.insn	4, 0x696c6173
80003092:	64656e67          	.insn	4, 0x64656e67

80003096 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.13>:
80003096:	6f4c                	.insn	2, 0x6f4c
80003098:	6461                	.insn	2, 0x6461
8000309a:	6146                	.insn	2, 0x6146
8000309c:	6c75                	.insn	2, 0x6c75
8000309e:	                	.insn	2, 0x5374

8000309f <.Lanon.10e9e605f29f28b577aacdba1819c9a4.14>:
8000309f:	726f7453          	.insn	4, 0x726f7453
800030a3:	4d65                	.insn	2, 0x4d65
800030a5:	7369                	.insn	2, 0x7369
800030a7:	6c61                	.insn	2, 0x6c61
800030a9:	6769                	.insn	2, 0x6769
800030ab:	656e                	.insn	2, 0x656e
800030ad:	                	.insn	2, 0x5364

800030ae <.Lanon.10e9e605f29f28b577aacdba1819c9a4.15>:
800030ae:	726f7453          	.insn	4, 0x726f7453
800030b2:	4665                	.insn	2, 0x4665
800030b4:	7561                	.insn	2, 0x7561
800030b6:	746c                	.insn	2, 0x746c

800030b8 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.16>:
800030b8:	7355                	.insn	2, 0x7355
800030ba:	7265                	.insn	2, 0x7265
800030bc:	6e45                	.insn	2, 0x6e45
800030be:	4376                	.insn	2, 0x4376
800030c0:	6c61                	.insn	2, 0x6c61
800030c2:	                	.insn	2, 0x536c

800030c3 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.17>:
800030c3:	65707553          	.insn	4, 0x65707553
800030c7:	7672                	.insn	2, 0x7672
800030c9:	7369                	.insn	2, 0x7369
800030cb:	6e45726f          	jal	tp,8005a7af <_ZN7SuperOS6kalloc13KALLOC_BUFFER17h2f62f31b270c2cc8E+0x46f8f>
800030cf:	4376                	.insn	2, 0x4376
800030d1:	6c61                	.insn	2, 0x6c61
800030d3:	                	.insn	2, 0x4d6c

800030d4 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.18>:
800030d4:	614d                	.insn	2, 0x614d
800030d6:	6e696863          	bltu	s2,t1,800037c6 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.293+0x398>
800030da:	4565                	.insn	2, 0x4565
800030dc:	766e                	.insn	2, 0x766e
800030de:	6c6c6143          	.insn	4, 0x6c6c6143

800030e2 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.19>:
800030e2:	6e49                	.insn	2, 0x6e49
800030e4:	75727473          	.insn	4, 0x75727473
800030e8:	6f697463          	bgeu	s2,s6,800037d0 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.293+0x3a2>
800030ec:	506e                	.insn	2, 0x506e
800030ee:	6761                	.insn	2, 0x6761
800030f0:	4665                	.insn	2, 0x4665
800030f2:	7561                	.insn	2, 0x7561
800030f4:	746c                	.insn	2, 0x746c

800030f6 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.20>:
800030f6:	6f4c                	.insn	2, 0x6f4c
800030f8:	6461                	.insn	2, 0x6461
800030fa:	6150                	.insn	2, 0x6150
800030fc:	61466567          	.insn	4, 0x61466567
80003100:	6c75                	.insn	2, 0x6c75
80003102:	                	.insn	2, 0x5374

80003103 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.21>:
80003103:	726f7453          	.insn	4, 0x726f7453
80003107:	5065                	.insn	2, 0x5065
80003109:	6761                	.insn	2, 0x6761
8000310b:	4665                	.insn	2, 0x4665
8000310d:	7561                	.insn	2, 0x7561
8000310f:	746c                	.insn	2, 0x746c

80003111 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.22>:
80003111:	6e55                	.insn	2, 0x6e55
80003113:	776f6e6b          	.insn	4, 0x776f6e6b
80003117:	                	.insn	2, 0x006e

80003118 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.23>:
	...
80003120:	0001                	.insn	2, 0x0001
80003122:	0000                	.insn	2, 0x
80003124:	0384                	.insn	2, 0x0384
80003126:	8000                	.insn	2, 0x8000
80003128:	01f0                	.insn	2, 0x01f0
8000312a:	8000                	.insn	2, 0x8000
8000312c:	02dc                	.insn	2, 0x02dc
8000312e:	8000                	.insn	2, 0x8000

80003130 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.24>:
	...
80003138:	0001                	.insn	2, 0x0001
8000313a:	0000                	.insn	2, 0x
8000313c:	0330                	.insn	2, 0x0330
8000313e:	8000                	.insn	2, 0x8000

80003140 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.25>:
80003140:	6c6c6163          	bltu	s8,t1,80003802 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.293+0x3d4>
80003144:	6465                	.insn	2, 0x6465
80003146:	6020                	.insn	2, 0x6020
80003148:	6552                	.insn	2, 0x6552
8000314a:	746c7573          	.insn	4, 0x746c7573
8000314e:	3a3a                	.insn	2, 0x3a3a
80003150:	6e75                	.insn	2, 0x6e75
80003152:	70617277          	.insn	4, 0x70617277
80003156:	2928                	.insn	2, 0x2928
80003158:	2060                	.insn	2, 0x2060
8000315a:	61206e6f          	jal	t3,8000976c <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3+0x5f50>
8000315e:	206e                	.insn	2, 0x206e
80003160:	4560                	.insn	2, 0x4560
80003162:	7272                	.insn	2, 0x7272
80003164:	2060                	.insn	2, 0x2060
80003166:	6176                	.insn	2, 0x6176
80003168:	756c                	.insn	2, 0x756c
8000316a:	                	.insn	2, 0x7365

8000316b <.Lanon.10e9e605f29f28b577aacdba1819c9a4.26>:
8000316b:	2f637273          	.insn	4, 0x2f637273
8000316f:	7270                	.insn	2, 0x7270
80003171:	6e69                	.insn	2, 0x6e69
80003173:	6574                	.insn	2, 0x6574
80003175:	2e72                	.insn	2, 0x2e72
80003177:	7372                	.insn	2, 0x7372
80003179:	0000                	.insn	2, 0x
	...

8000317c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.27>:
8000317c:	8000316b          	.insn	4, 0x8000316b
80003180:	000e                	.insn	2, 0x000e
80003182:	0000                	.insn	2, 0x
80003184:	0016                	.insn	2, 0x0016
80003186:	0000                	.insn	2, 0x
80003188:	001c                	.insn	2, 0x001c
	...

8000318c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.28>:
8000318c:	636d                	.insn	2, 0x636d
8000318e:	7561                	.insn	2, 0x7561
80003190:	203a6573          	.insn	4, 0x203a6573
80003194:	7865                	.insn	2, 0x7865
80003196:	74706563          	bltu	zero,t2,800038e0 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3+0xc4>
8000319a:	6f69                	.insn	2, 0x6f69
8000319c:	206e                	.insn	2, 0x206e
8000319e:	7461                	.insn	2, 0x7461
800031a0:	                	.insn	2, 0x2020

800031a1 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.29>:
800031a1:	                	.insn	2, 0x0a20

800031a2 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.30>:
800031a2:	000a                	.insn	2, 0x000a

800031a4 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.31>:
800031a4:	318c                	.insn	2, 0x318c
800031a6:	8000                	.insn	2, 0x8000
800031a8:	0015                	.insn	2, 0x0015
800031aa:	0000                	.insn	2, 0x
800031ac:	31a1                	.insn	2, 0x31a1
800031ae:	8000                	.insn	2, 0x8000
800031b0:	0001                	.insn	2, 0x0001
800031b2:	0000                	.insn	2, 0x
800031b4:	31a2                	.insn	2, 0x31a2
800031b6:	8000                	.insn	2, 0x8000
800031b8:	0001                	.insn	2, 0x0001
	...

800031bc <.Lanon.10e9e605f29f28b577aacdba1819c9a4.32>:
800031bc:	2f637273          	.insn	4, 0x2f637273
800031c0:	6f68                	.insn	2, 0x6f68
800031c2:	656c                	.insn	2, 0x656c
800031c4:	722e                	.insn	2, 0x722e
800031c6:	          	.insn	4, 0x73736173

800031c7 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.37>:
800031c7:	7361                	.insn	2, 0x7361
800031c9:	74726573          	.insn	4, 0x74726573
800031cd:	6f69                	.insn	2, 0x6f69
800031cf:	206e                	.insn	2, 0x206e
800031d1:	6166                	.insn	2, 0x6166
800031d3:	6c69                	.insn	2, 0x6c69
800031d5:	6465                	.insn	2, 0x6465
800031d7:	203a                	.insn	2, 0x203a
800031d9:	6c61                	.insn	2, 0x6c61
800031db:	6769                	.insn	2, 0x6769
800031dd:	656e                	.insn	2, 0x656e
800031df:	5f64                	.insn	2, 0x5f64
800031e1:	6f68                	.insn	2, 0x6f68
800031e3:	656c                	.insn	2, 0x656c
800031e5:	735f 7a69 2065      	.insn	6, 0x20657a69735f
800031eb:	3d3e                	.insn	2, 0x3d3e
800031ed:	7320                	.insn	2, 0x7320
800031ef:	7a69                	.insn	2, 0x7a69
800031f1:	5f65                	.insn	2, 0x5f65
800031f3:	3a3a666f          	jal	a2,800a9d95 <_ZN7SuperOS6kalloc13KALLOC_BUFFER17h2f62f31b270c2cc8E+0x96575>
800031f7:	483c                	.insn	2, 0x483c
800031f9:	3e656c6f          	jal	s8,800595df <_ZN7SuperOS6kalloc13KALLOC_BUFFER17h2f62f31b270c2cc8E+0x45dbf>
800031fd:	2928                	.insn	2, 0x2928
	...

80003200 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.38>:
80003200:	31bc                	.insn	2, 0x31bc
80003202:	8000                	.insn	2, 0x8000
80003204:	0000000b          	.insn	4, 0x000b
80003208:	0162                	.insn	2, 0x0162
8000320a:	0000                	.insn	2, 0x
8000320c:	0009                	.insn	2, 0x0009
	...

80003210 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.39>:
80003210:	31bc                	.insn	2, 0x31bc
80003212:	8000                	.insn	2, 0x8000
80003214:	0000000b          	.insn	4, 0x000b
80003218:	016a                	.insn	2, 0x016a
8000321a:	0000                	.insn	2, 0x
8000321c:	0009                	.insn	2, 0x0009
	...

80003220 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.52>:
80003220:	6170                	.insn	2, 0x6170
80003222:	6c6c                	.insn	2, 0x6c6c
80003224:	203a636f          	jal	t1,800a9c26 <_ZN7SuperOS6kalloc13KALLOC_BUFFER17h2f62f31b270c2cc8E+0x96406>
80003228:	6966                	.insn	2, 0x6966
8000322a:	7372                	.insn	2, 0x7372
8000322c:	2074                	.insn	2, 0x2074

8000322e <.Lanon.10e9e605f29f28b577aacdba1819c9a4.53>:
8000322e:	6c20                	.insn	2, 0x6c20
80003230:	7361                	.insn	2, 0x7361
80003232:	2074                	.insn	2, 0x2074

80003234 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.54>:
80003234:	3220                	.insn	2, 0x3220
80003236:	8000                	.insn	2, 0x8000
80003238:	000e                	.insn	2, 0x000e
8000323a:	0000                	.insn	2, 0x
8000323c:	322e                	.insn	2, 0x322e
8000323e:	8000                	.insn	2, 0x8000
80003240:	0006                	.insn	2, 0x0006
80003242:	0000                	.insn	2, 0x
80003244:	31a2                	.insn	2, 0x31a2
80003246:	8000                	.insn	2, 0x8000
80003248:	0001                	.insn	2, 0x0001
	...

8000324c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.55>:
8000324c:	2f637273          	.insn	4, 0x2f637273
80003250:	6f70                	.insn	2, 0x6f70
80003252:	6e69                	.insn	2, 0x6e69
80003254:	6574                	.insn	2, 0x6574
80003256:	2e72                	.insn	2, 0x2e72
80003258:	7372                	.insn	2, 0x7372
	...

8000325c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.56>:
8000325c:	324c                	.insn	2, 0x324c
8000325e:	8000                	.insn	2, 0x8000
80003260:	000e                	.insn	2, 0x000e
80003262:	0000                	.insn	2, 0x
80003264:	0000002f          	.insn	4, 0x002f
80003268:	0030                	.insn	2, 0x0030
	...

8000326c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.57>:
8000326c:	0001                	.insn	2, 0x0001
8000326e:	0000                	.insn	2, 0x
80003270:	0000                	.insn	2, 0x
80003272:	0000                	.insn	2, 0x
80003274:	31a2                	.insn	2, 0x31a2
80003276:	8000                	.insn	2, 0x8000
80003278:	0001                	.insn	2, 0x0001
	...

8000327c <.Lanon.10e9e605f29f28b577aacdba1819c9a4.58>:
8000327c:	31335b1b          	.insn	4, 0x31335b1b
80003280:	4b6d                	.insn	2, 0x4b6d
80003282:	5245                	.insn	2, 0x5245
80003284:	454e                	.insn	2, 0x454e
80003286:	204c                	.insn	2, 0x204c
80003288:	4150                	.insn	2, 0x4150
8000328a:	494e                	.insn	2, 0x494e
8000328c:	5b1b3a43          	.insn	4, 0x5b1b3a43
80003290:	6d30                	.insn	2, 0x6d30
80003292:	0020                	.insn	2, 0x0020

80003294 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.59>:
80003294:	327c                	.insn	2, 0x327c
80003296:	8000                	.insn	2, 0x8000
80003298:	00000017          	auipc	zero,0x0
8000329c:	31a2                	.insn	2, 0x31a2
8000329e:	8000                	.insn	2, 0x8000
800032a0:	0001                	.insn	2, 0x0001
	...

800032a4 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.60>:
800032a4:	2f637273          	.insn	4, 0x2f637273
800032a8:	616d                	.insn	2, 0x616d
800032aa:	6e69                	.insn	2, 0x6e69
800032ac:	722e                	.insn	2, 0x722e
800032ae:	          	.insn	4, 0x32a40073

800032b0 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.61>:
800032b0:	32a4                	.insn	2, 0x32a4
800032b2:	8000                	.insn	2, 0x8000
800032b4:	0000000b          	.insn	4, 0x000b
800032b8:	0041                	.insn	2, 0x0041
800032ba:	0000                	.insn	2, 0x
800032bc:	0026                	.insn	2, 0x0026
	...

800032c0 <.Lanon.10e9e605f29f28b577aacdba1819c9a4.62>:
800032c0:	7375                	.insn	2, 0x7375
800032c2:	7265                	.insn	2, 0x7265
800032c4:	6d5f 6961 3a6e      	.insn	6, 0x3a6e69616d5f
800032ca:	0020                	.insn	2, 0x0020

800032cc <.Lanon.10e9e605f29f28b577aacdba1819c9a4.63>:
800032cc:	32c0                	.insn	2, 0x32c0
800032ce:	8000                	.insn	2, 0x8000
800032d0:	0000000b          	.insn	4, 0x000b
800032d4:	31a2                	.insn	2, 0x31a2
800032d6:	8000                	.insn	2, 0x8000
800032d8:	0001                	.insn	2, 0x0001
	...

800032dc <.Lswitch.table._ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17hf95f0320af548cf6E>:
800032dc:	0015                	.insn	2, 0x0015
800032de:	0000                	.insn	2, 0x
800032e0:	0010                	.insn	2, 0x0010
800032e2:	0000                	.insn	2, 0x
800032e4:	0012                	.insn	2, 0x0012
800032e6:	0000                	.insn	2, 0x
800032e8:	000a                	.insn	2, 0x000a
800032ea:	0000                	.insn	2, 0x
800032ec:	000e                	.insn	2, 0x000e
800032ee:	0000                	.insn	2, 0x
800032f0:	0009                	.insn	2, 0x0009
800032f2:	0000                	.insn	2, 0x
800032f4:	0000000f          	fence	unknown,unknown
800032f8:	000a                	.insn	2, 0x000a
800032fa:	0000                	.insn	2, 0x
800032fc:	0000000b          	.insn	4, 0x000b
80003300:	0011                	.insn	2, 0x0011
80003302:	0000                	.insn	2, 0x
80003304:	000e                	.insn	2, 0x000e
80003306:	0000                	.insn	2, 0x
80003308:	0014                	.insn	2, 0x0014
8000330a:	0000                	.insn	2, 0x
8000330c:	000d                	.insn	2, 0x000d
8000330e:	0000                	.insn	2, 0x
80003310:	000e                	.insn	2, 0x000e
80003312:	0000                	.insn	2, 0x
80003314:	00000007          	.insn	4, 0x0007

80003318 <.Lswitch.table._ZN71_$LT$riscv..register..mcause..Exception$u20$as$u20$core..fmt..Debug$GT$3fmt17hf95f0320af548cf6E.1>:
80003318:	3015                	.insn	2, 0x3015
8000331a:	8000                	.insn	2, 0x8000
8000331c:	303c                	.insn	2, 0x303c
8000331e:	8000                	.insn	2, 0x8000
80003320:	306c                	.insn	2, 0x306c
80003322:	8000                	.insn	2, 0x8000
80003324:	307e                	.insn	2, 0x307e
80003326:	8000                	.insn	2, 0x8000
80003328:	3088                	.insn	2, 0x3088
8000332a:	8000                	.insn	2, 0x8000
8000332c:	3096                	.insn	2, 0x3096
8000332e:	8000                	.insn	2, 0x8000
80003330:	309f 8000 30ae      	.insn	6, 0x30ae8000309f
80003336:	8000                	.insn	2, 0x8000
80003338:	30b8                	.insn	2, 0x30b8
8000333a:	8000                	.insn	2, 0x8000
8000333c:	800030c3          	.insn	4, 0x800030c3
80003340:	30d4                	.insn	2, 0x30d4
80003342:	8000                	.insn	2, 0x8000
80003344:	30e2                	.insn	2, 0x30e2
80003346:	8000                	.insn	2, 0x8000
80003348:	30f6                	.insn	2, 0x30f6
8000334a:	8000                	.insn	2, 0x8000
8000334c:	80003103          	.insn	4, 0x80003103
80003350:	3111                	.insn	2, 0x3111
80003352:	8000                	.insn	2, 0x8000

80003354 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.212>:
80003354:	                	.insn	2, 0x633a

80003355 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.222>:
80003355:	6c6c6163          	bltu	s8,t1,80003a17 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3+0x1fb>
80003359:	6465                	.insn	2, 0x6465
8000335b:	6020                	.insn	2, 0x6020
8000335d:	6974704f          	.insn	4, 0x6974704f
80003361:	3a3a6e6f          	jal	t3,800a9f03 <_ZN7SuperOS6kalloc13KALLOC_BUFFER17h2f62f31b270c2cc8E+0x966e3>
80003365:	6e75                	.insn	2, 0x6e75
80003367:	70617277          	.insn	4, 0x70617277
8000336b:	2928                	.insn	2, 0x2928
8000336d:	2060                	.insn	2, 0x2060
8000336f:	61206e6f          	jal	t3,80009981 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3+0x6165>
80003373:	6020                	.insn	2, 0x6020
80003375:	6f4e                	.insn	2, 0x6f4e
80003377:	656e                	.insn	2, 0x656e
80003379:	2060                	.insn	2, 0x2060
8000337b:	6176                	.insn	2, 0x6176
8000337d:	756c                	.insn	2, 0x756c
8000337f:	                	.insn	2, 0x0165

80003380 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.223>:
80003380:	0001                	.insn	2, 0x0001
80003382:	0000                	.insn	2, 0x
80003384:	0000                	.insn	2, 0x
80003386:	0000                	.insn	2, 0x
80003388:	3354                	.insn	2, 0x3354
8000338a:	8000                	.insn	2, 0x8000
8000338c:	0001                	.insn	2, 0x0001
8000338e:	0000                	.insn	2, 0x
80003390:	3354                	.insn	2, 0x3354
80003392:	8000                	.insn	2, 0x8000
80003394:	0001                	.insn	2, 0x0001
	...

80003398 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.224>:
80003398:	6170                	.insn	2, 0x6170
8000339a:	696e                	.insn	2, 0x696e
8000339c:	64656b63          	bltu	a0,t1,800039f2 <_ZN7SuperOS6palloc14PAGE_ALLOCATOR17h04fa5c23c2317efeE.3+0x1d6>
800033a0:	6120                	.insn	2, 0x6120
800033a2:	2074                	.insn	2, 0x2074

800033a4 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.225>:
800033a4:	0a3a                	.insn	2, 0x0a3a

800033a6 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.242>:
800033a6:	3d3d                	.insn	2, 0x3d3d

800033a8 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.243>:
800033a8:	3d21                	.insn	2, 0x3d21

800033aa <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.244>:
800033aa:	616d                	.insn	2, 0x616d
800033ac:	6374                	.insn	2, 0x6374
800033ae:	6568                	.insn	2, 0x6568
800033b0:	          	.insn	4, 0x69722073

800033b1 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.246>:
800033b1:	7220                	.insn	2, 0x7220
800033b3:	6769                	.insn	2, 0x6769
800033b5:	7468                	.insn	2, 0x7468
800033b7:	2060                	.insn	2, 0x2060
800033b9:	6166                	.insn	2, 0x6166
800033bb:	6c69                	.insn	2, 0x6c69
800033bd:	6465                	.insn	2, 0x6465
800033bf:	200a                	.insn	2, 0x200a
800033c1:	6c20                	.insn	2, 0x6c20
800033c3:	6665                	.insn	2, 0x6665
800033c5:	3a74                	.insn	2, 0x3a74
800033c7:	                	.insn	2, 0x0a20

800033c8 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.247>:
800033c8:	200a                	.insn	2, 0x200a
800033ca:	6972                	.insn	2, 0x6972
800033cc:	3a746867          	.insn	4, 0x3a746867
800033d0:	0020                	.insn	2, 0x0020
	...

800033d4 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.248>:
800033d4:	302c                	.insn	2, 0x302c
800033d6:	8000                	.insn	2, 0x8000
800033d8:	0010                	.insn	2, 0x0010
800033da:	0000                	.insn	2, 0x
800033dc:	33b1                	.insn	2, 0x33b1
800033de:	8000                	.insn	2, 0x8000
800033e0:	00000017          	auipc	zero,0x0
800033e4:	33c8                	.insn	2, 0x33c8
800033e6:	8000                	.insn	2, 0x8000
800033e8:	0009                	.insn	2, 0x0009
	...

800033ec <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.250>:
800033ec:	200a                	.insn	2, 0x200a
800033ee:	6c20                	.insn	2, 0x6c20
800033f0:	6665                	.insn	2, 0x6665
800033f2:	3a74                	.insn	2, 0x3a74
800033f4:	0020                	.insn	2, 0x0020
	...

800033f8 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.251>:
800033f8:	302c                	.insn	2, 0x302c
800033fa:	8000                	.insn	2, 0x8000
800033fc:	0010                	.insn	2, 0x0010
800033fe:	0000                	.insn	2, 0x
80003400:	305c                	.insn	2, 0x305c
80003402:	8000                	.insn	2, 0x8000
80003404:	0010                	.insn	2, 0x0010
80003406:	0000                	.insn	2, 0x
80003408:	33ec                	.insn	2, 0x33ec
8000340a:	8000                	.insn	2, 0x8000
8000340c:	0009                	.insn	2, 0x0009
8000340e:	0000                	.insn	2, 0x
80003410:	33c8                	.insn	2, 0x33c8
80003412:	8000                	.insn	2, 0x8000
80003414:	0009                	.insn	2, 0x0009
	...

80003418 <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.252>:
80003418:	203a                	.insn	2, 0x203a
	...

8000341c <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.253>:
8000341c:	0001                	.insn	2, 0x0001
8000341e:	0000                	.insn	2, 0x
80003420:	0000                	.insn	2, 0x
80003422:	0000                	.insn	2, 0x
80003424:	3418                	.insn	2, 0x3418
80003426:	8000                	.insn	2, 0x8000
80003428:	0002                	.insn	2, 0x0002
	...

8000342c <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.291>:
8000342c:	7830                	.insn	2, 0x7830

8000342e <.Lanon.be1aee01165082a57d4a2abf8cdb5e98.293>:
8000342e:	3030                	.insn	2, 0x3030
80003430:	3130                	.insn	2, 0x3130
80003432:	3230                	.insn	2, 0x3230
80003434:	3330                	.insn	2, 0x3330
80003436:	3430                	.insn	2, 0x3430
80003438:	3530                	.insn	2, 0x3530
8000343a:	3630                	.insn	2, 0x3630
8000343c:	3730                	.insn	2, 0x3730
8000343e:	3830                	.insn	2, 0x3830
80003440:	3930                	.insn	2, 0x3930
80003442:	3031                	.insn	2, 0x3031
80003444:	3131                	.insn	2, 0x3131
80003446:	3231                	.insn	2, 0x3231
80003448:	3331                	.insn	2, 0x3331
8000344a:	3431                	.insn	2, 0x3431
8000344c:	3531                	.insn	2, 0x3531
8000344e:	3631                	.insn	2, 0x3631
80003450:	3731                	.insn	2, 0x3731
80003452:	3831                	.insn	2, 0x3831
80003454:	3931                	.insn	2, 0x3931
80003456:	3032                	.insn	2, 0x3032
80003458:	3132                	.insn	2, 0x3132
8000345a:	3232                	.insn	2, 0x3232
8000345c:	3332                	.insn	2, 0x3332
8000345e:	3432                	.insn	2, 0x3432
80003460:	3532                	.insn	2, 0x3532
80003462:	3632                	.insn	2, 0x3632
80003464:	3732                	.insn	2, 0x3732
80003466:	3832                	.insn	2, 0x3832
80003468:	3932                	.insn	2, 0x3932
8000346a:	31333033          	.insn	4, 0x31333033
8000346e:	33333233          	.insn	4, 0x33333233
80003472:	35333433          	.insn	4, 0x35333433
80003476:	37333633          	.insn	4, 0x37333633
8000347a:	39333833          	.insn	4, 0x39333833
8000347e:	3034                	.insn	2, 0x3034
80003480:	3134                	.insn	2, 0x3134
80003482:	3234                	.insn	2, 0x3234
80003484:	3334                	.insn	2, 0x3334
80003486:	3434                	.insn	2, 0x3434
80003488:	3534                	.insn	2, 0x3534
8000348a:	3634                	.insn	2, 0x3634
8000348c:	3734                	.insn	2, 0x3734
8000348e:	3834                	.insn	2, 0x3834
80003490:	3934                	.insn	2, 0x3934
80003492:	3035                	.insn	2, 0x3035
80003494:	3135                	.insn	2, 0x3135
80003496:	3235                	.insn	2, 0x3235
80003498:	3335                	.insn	2, 0x3335
8000349a:	3435                	.insn	2, 0x3435
8000349c:	3535                	.insn	2, 0x3535
8000349e:	3635                	.insn	2, 0x3635
800034a0:	3735                	.insn	2, 0x3735
800034a2:	3835                	.insn	2, 0x3835
800034a4:	3935                	.insn	2, 0x3935
800034a6:	3036                	.insn	2, 0x3036
800034a8:	3136                	.insn	2, 0x3136
800034aa:	3236                	.insn	2, 0x3236
800034ac:	3336                	.insn	2, 0x3336
800034ae:	3436                	.insn	2, 0x3436
800034b0:	3536                	.insn	2, 0x3536
800034b2:	3636                	.insn	2, 0x3636
800034b4:	3736                	.insn	2, 0x3736
800034b6:	3836                	.insn	2, 0x3836
800034b8:	3936                	.insn	2, 0x3936
800034ba:	31373037          	lui	zero,0x31373
800034be:	33373237          	lui	tp,0x33373
800034c2:	35373437          	lui	s0,0x35373
800034c6:	37373637          	lui	a2,0x37373
800034ca:	39373837          	lui	a6,0x39373
800034ce:	3038                	.insn	2, 0x3038
800034d0:	3138                	.insn	2, 0x3138
800034d2:	3238                	.insn	2, 0x3238
800034d4:	3338                	.insn	2, 0x3338
800034d6:	3438                	.insn	2, 0x3438
800034d8:	3538                	.insn	2, 0x3538
800034da:	3638                	.insn	2, 0x3638
800034dc:	3738                	.insn	2, 0x3738
800034de:	3838                	.insn	2, 0x3838
800034e0:	3938                	.insn	2, 0x3938
800034e2:	3039                	.insn	2, 0x3039
800034e4:	3139                	.insn	2, 0x3139
800034e6:	3239                	.insn	2, 0x3239
800034e8:	3339                	.insn	2, 0x3339
800034ea:	3439                	.insn	2, 0x3439
800034ec:	3539                	.insn	2, 0x3539
800034ee:	3639                	.insn	2, 0x3639
800034f0:	3739                	.insn	2, 0x3739
800034f2:	3839                	.insn	2, 0x3839
800034f4:	3939                	.insn	2, 0x3939

Disassembly of section .eh_frame:

80003500 <__bss_start-0x308>:
80003500:	0010                	.insn	2, 0x0010
80003502:	0000                	.insn	2, 0x
80003504:	0000                	.insn	2, 0x
80003506:	0000                	.insn	2, 0x
80003508:	7a01                	.insn	2, 0x7a01
8000350a:	0052                	.insn	2, 0x0052
8000350c:	7c01                	.insn	2, 0x7c01
8000350e:	0101                	.insn	2, 0x0101
80003510:	00020c1b          	.insn	4, 0x00020c1b
80003514:	001c                	.insn	2, 0x001c
80003516:	0000                	.insn	2, 0x
80003518:	0018                	.insn	2, 0x0018
8000351a:	0000                	.insn	2, 0x
8000351c:	d910                	.insn	2, 0xd910
8000351e:	ffff                	.insn	2, 0xffff
80003520:	0028                	.insn	2, 0x0028
80003522:	0000                	.insn	2, 0x
80003524:	4400                	.insn	2, 0x4400
80003526:	100e                	.insn	2, 0x100e
80003528:	8148                	.insn	2, 0x8148
8000352a:	8801                	.insn	2, 0x8801
8000352c:	4402                	.insn	2, 0x4402
8000352e:	080c                	.insn	2, 0x080c
80003530:	0000                	.insn	2, 0x
80003532:	0000                	.insn	2, 0x
80003534:	0024                	.insn	2, 0x0024
80003536:	0000                	.insn	2, 0x
80003538:	0038                	.insn	2, 0x0038
8000353a:	0000                	.insn	2, 0x
8000353c:	d918                	.insn	2, 0xd918
8000353e:	ffff                	.insn	2, 0xffff
80003540:	014c                	.insn	2, 0x014c
80003542:	0000                	.insn	2, 0x
80003544:	4400                	.insn	2, 0x4400
80003546:	500e                	.insn	2, 0x500e
80003548:	815c                	.insn	2, 0x815c
8000354a:	8801                	.insn	2, 0x8801
8000354c:	8902                	.insn	2, 0x8902
8000354e:	93049203          	lh	tp,-1744(s1)
80003552:	9405                	.insn	2, 0x9405
80003554:	9506                	.insn	2, 0x9506
80003556:	080c4407          	.insn	4, 0x080c4407
8000355a:	0000                	.insn	2, 0x
8000355c:	001c                	.insn	2, 0x001c
8000355e:	0000                	.insn	2, 0x
80003560:	0060                	.insn	2, 0x0060
80003562:	0000                	.insn	2, 0x
80003564:	da3c                	.insn	2, 0xda3c
80003566:	ffff                	.insn	2, 0xffff
80003568:	002c                	.insn	2, 0x002c
8000356a:	0000                	.insn	2, 0x
8000356c:	4400                	.insn	2, 0x4400
8000356e:	200e                	.insn	2, 0x200e
80003570:	8148                	.insn	2, 0x8148
80003572:	8801                	.insn	2, 0x8801
80003574:	4402                	.insn	2, 0x4402
80003576:	080c                	.insn	2, 0x080c
80003578:	0000                	.insn	2, 0x
8000357a:	0000                	.insn	2, 0x
8000357c:	001c                	.insn	2, 0x001c
8000357e:	0000                	.insn	2, 0x
80003580:	0080                	.insn	2, 0x0080
80003582:	0000                	.insn	2, 0x
80003584:	da48                	.insn	2, 0xda48
80003586:	ffff                	.insn	2, 0xffff
80003588:	0048                	.insn	2, 0x0048
8000358a:	0000                	.insn	2, 0x
8000358c:	4400                	.insn	2, 0x4400
8000358e:	300e                	.insn	2, 0x300e
80003590:	8148                	.insn	2, 0x8148
80003592:	8801                	.insn	2, 0x8801
80003594:	4402                	.insn	2, 0x4402
80003596:	080c                	.insn	2, 0x080c
80003598:	0000                	.insn	2, 0x
8000359a:	0000                	.insn	2, 0x
8000359c:	0020                	.insn	2, 0x0020
8000359e:	0000                	.insn	2, 0x
800035a0:	00a0                	.insn	2, 0x00a0
800035a2:	0000                	.insn	2, 0x
800035a4:	da70                	.insn	2, 0xda70
800035a6:	ffff                	.insn	2, 0xffff
800035a8:	014c                	.insn	2, 0x014c
800035aa:	0000                	.insn	2, 0x
800035ac:	4400                	.insn	2, 0x4400
800035ae:	800e                	.insn	2, 0x800e
800035b0:	5001                	.insn	2, 0x5001
800035b2:	0181                	.insn	2, 0x0181
800035b4:	0288                	.insn	2, 0x0288
800035b6:	0389                	.insn	2, 0x0389
800035b8:	0492                	.insn	2, 0x0492
800035ba:	0c44                	.insn	2, 0x0c44
800035bc:	0008                	.insn	2, 0x0008
800035be:	0000                	.insn	2, 0x
800035c0:	001c                	.insn	2, 0x001c
800035c2:	0000                	.insn	2, 0x
800035c4:	00c4                	.insn	2, 0x00c4
800035c6:	0000                	.insn	2, 0x
800035c8:	db98                	.insn	2, 0xdb98
800035ca:	ffff                	.insn	2, 0xffff
800035cc:	007c                	.insn	2, 0x007c
800035ce:	0000                	.insn	2, 0x
800035d0:	4400                	.insn	2, 0x4400
800035d2:	400e                	.insn	2, 0x400e
800035d4:	8148                	.insn	2, 0x8148
800035d6:	8801                	.insn	2, 0x8801
800035d8:	4402                	.insn	2, 0x4402
800035da:	080c                	.insn	2, 0x080c
800035dc:	0000                	.insn	2, 0x
800035de:	0000                	.insn	2, 0x
800035e0:	001c                	.insn	2, 0x001c
800035e2:	0000                	.insn	2, 0x
800035e4:	00e4                	.insn	2, 0x00e4
800035e6:	0000                	.insn	2, 0x
800035e8:	dbf4                	.insn	2, 0xdbf4
800035ea:	ffff                	.insn	2, 0xffff
800035ec:	0038                	.insn	2, 0x0038
800035ee:	0000                	.insn	2, 0x
800035f0:	4400                	.insn	2, 0x4400
800035f2:	100e                	.insn	2, 0x100e
800035f4:	8148                	.insn	2, 0x8148
800035f6:	8801                	.insn	2, 0x8801
800035f8:	4402                	.insn	2, 0x4402
800035fa:	080c                	.insn	2, 0x080c
800035fc:	0000                	.insn	2, 0x
800035fe:	0000                	.insn	2, 0x
80003600:	002c                	.insn	2, 0x002c
80003602:	0000                	.insn	2, 0x
80003604:	0104                	.insn	2, 0x0104
80003606:	0000                	.insn	2, 0x
80003608:	dc0c                	.insn	2, 0xdc0c
8000360a:	ffff                	.insn	2, 0xffff
8000360c:	0264                	.insn	2, 0x0264
8000360e:	0000                	.insn	2, 0x
80003610:	4400                	.insn	2, 0x4400
80003612:	500e                	.insn	2, 0x500e
80003614:	8168                	.insn	2, 0x8168
80003616:	8801                	.insn	2, 0x8801
80003618:	8902                	.insn	2, 0x8902
8000361a:	93049203          	lh	tp,-1744(s1)
8000361e:	9405                	.insn	2, 0x9405
80003620:	9506                	.insn	2, 0x9506
80003622:	97089607          	.insn	4, 0x97089607
80003626:	9809                	.insn	2, 0x9809
80003628:	440a                	.insn	2, 0x440a
8000362a:	080c                	.insn	2, 0x080c
8000362c:	0000                	.insn	2, 0x
8000362e:	0000                	.insn	2, 0x
80003630:	0030                	.insn	2, 0x0030
80003632:	0000                	.insn	2, 0x
80003634:	0134                	.insn	2, 0x0134
80003636:	0000                	.insn	2, 0x
80003638:	de40                	.insn	2, 0xde40
8000363a:	ffff                	.insn	2, 0xffff
8000363c:	0354                	.insn	2, 0x0354
8000363e:	0000                	.insn	2, 0x
80003640:	4400                	.insn	2, 0x4400
80003642:	400e                	.insn	2, 0x400e
80003644:	8174                	.insn	2, 0x8174
80003646:	8801                	.insn	2, 0x8801
80003648:	8902                	.insn	2, 0x8902
8000364a:	93049203          	lh	tp,-1744(s1)
8000364e:	9405                	.insn	2, 0x9405
80003650:	9506                	.insn	2, 0x9506
80003652:	97089607          	.insn	4, 0x97089607
80003656:	9809                	.insn	2, 0x9809
80003658:	990a                	.insn	2, 0x990a
8000365a:	9b0c9a0b          	.insn	4, 0x9b0c9a0b
8000365e:	440d                	.insn	2, 0x440d
80003660:	080c                	.insn	2, 0x080c
80003662:	0000                	.insn	2, 0x
80003664:	0024                	.insn	2, 0x0024
80003666:	0000                	.insn	2, 0x
80003668:	0168                	.insn	2, 0x0168
8000366a:	0000                	.insn	2, 0x
8000366c:	e160                	.insn	2, 0xe160
8000366e:	ffff                	.insn	2, 0xffff
80003670:	00ac                	.insn	2, 0x00ac
80003672:	0000                	.insn	2, 0x
80003674:	4400                	.insn	2, 0x4400
80003676:	200e                	.insn	2, 0x200e
80003678:	8158                	.insn	2, 0x8158
8000367a:	8801                	.insn	2, 0x8801
8000367c:	8902                	.insn	2, 0x8902
8000367e:	93049203          	lh	tp,-1744(s1)
80003682:	9405                	.insn	2, 0x9405
80003684:	4406                	.insn	2, 0x4406
80003686:	080c                	.insn	2, 0x080c
80003688:	0000                	.insn	2, 0x
8000368a:	0000                	.insn	2, 0x
8000368c:	0028                	.insn	2, 0x0028
8000368e:	0000                	.insn	2, 0x
80003690:	0190                	.insn	2, 0x0190
80003692:	0000                	.insn	2, 0x
80003694:	e1e4                	.insn	2, 0xe1e4
80003696:	ffff                	.insn	2, 0xffff
80003698:	0294                	.insn	2, 0x0294
8000369a:	0000                	.insn	2, 0x
8000369c:	4400                	.insn	2, 0x4400
8000369e:	300e                	.insn	2, 0x300e
800036a0:	8164                	.insn	2, 0x8164
800036a2:	8801                	.insn	2, 0x8801
800036a4:	8902                	.insn	2, 0x8902
800036a6:	93049203          	lh	tp,-1744(s1)
800036aa:	9405                	.insn	2, 0x9405
800036ac:	9506                	.insn	2, 0x9506
800036ae:	97089607          	.insn	4, 0x97089607
800036b2:	4409                	.insn	2, 0x4409
800036b4:	080c                	.insn	2, 0x080c
800036b6:	0000                	.insn	2, 0x
800036b8:	001c                	.insn	2, 0x001c
800036ba:	0000                	.insn	2, 0x
800036bc:	01bc                	.insn	2, 0x01bc
800036be:	0000                	.insn	2, 0x
800036c0:	e44c                	.insn	2, 0xe44c
800036c2:	ffff                	.insn	2, 0xffff
800036c4:	002c                	.insn	2, 0x002c
800036c6:	0000                	.insn	2, 0x
800036c8:	4400                	.insn	2, 0x4400
800036ca:	100e                	.insn	2, 0x100e
800036cc:	8148                	.insn	2, 0x8148
800036ce:	8801                	.insn	2, 0x8801
800036d0:	4402                	.insn	2, 0x4402
800036d2:	080c                	.insn	2, 0x080c
800036d4:	0000                	.insn	2, 0x
800036d6:	0000                	.insn	2, 0x
800036d8:	0024                	.insn	2, 0x0024
800036da:	0000                	.insn	2, 0x
800036dc:	01dc                	.insn	2, 0x01dc
800036de:	0000                	.insn	2, 0x
800036e0:	e458                	.insn	2, 0xe458
800036e2:	ffff                	.insn	2, 0xffff
800036e4:	00e8                	.insn	2, 0x00e8
800036e6:	0000                	.insn	2, 0x
800036e8:	4400                	.insn	2, 0x4400
800036ea:	a00e                	.insn	2, 0xa00e
800036ec:	5801                	.insn	2, 0x5801
800036ee:	0181                	.insn	2, 0x0181
800036f0:	0288                	.insn	2, 0x0288
800036f2:	0389                	.insn	2, 0x0389
800036f4:	0492                	.insn	2, 0x0492
800036f6:	06940593          	addi	a1,s0,105 # 35373069 <.Lline_table_start2+0x35371cca>
800036fa:	0c44                	.insn	2, 0x0c44
800036fc:	0008                	.insn	2, 0x0008
800036fe:	0000                	.insn	2, 0x
80003700:	001c                	.insn	2, 0x001c
80003702:	0000                	.insn	2, 0x
80003704:	0204                	.insn	2, 0x0204
80003706:	0000                	.insn	2, 0x
80003708:	e518                	.insn	2, 0xe518
8000370a:	ffff                	.insn	2, 0xffff
8000370c:	0238                	.insn	2, 0x0238
8000370e:	0000                	.insn	2, 0x
80003710:	4400                	.insn	2, 0x4400
80003712:	100e                	.insn	2, 0x100e
80003714:	8148                	.insn	2, 0x8148
80003716:	8801                	.insn	2, 0x8801
80003718:	4402                	.insn	2, 0x4402
8000371a:	080c                	.insn	2, 0x080c
8000371c:	0000                	.insn	2, 0x
8000371e:	0000                	.insn	2, 0x
80003720:	001c                	.insn	2, 0x001c
80003722:	0000                	.insn	2, 0x
80003724:	0224                	.insn	2, 0x0224
80003726:	0000                	.insn	2, 0x
80003728:	e730                	.insn	2, 0xe730
8000372a:	ffff                	.insn	2, 0xffff
8000372c:	0084                	.insn	2, 0x0084
8000372e:	0000                	.insn	2, 0x
80003730:	4400                	.insn	2, 0x4400
80003732:	900e                	.insn	2, 0x900e
80003734:	4801                	.insn	2, 0x4801
80003736:	0181                	.insn	2, 0x0181
80003738:	0288                	.insn	2, 0x0288
8000373a:	0c44                	.insn	2, 0x0c44
8000373c:	0008                	.insn	2, 0x0008
8000373e:	0000                	.insn	2, 0x
80003740:	001c                	.insn	2, 0x001c
80003742:	0000                	.insn	2, 0x
80003744:	0244                	.insn	2, 0x0244
80003746:	0000                	.insn	2, 0x
80003748:	e794                	.insn	2, 0xe794
8000374a:	ffff                	.insn	2, 0xffff
8000374c:	0030                	.insn	2, 0x0030
8000374e:	0000                	.insn	2, 0x
80003750:	4400                	.insn	2, 0x4400
80003752:	100e                	.insn	2, 0x100e
80003754:	8148                	.insn	2, 0x8148
80003756:	8801                	.insn	2, 0x8801
80003758:	4402                	.insn	2, 0x4402
8000375a:	080c                	.insn	2, 0x080c
8000375c:	0000                	.insn	2, 0x
8000375e:	0000                	.insn	2, 0x
80003760:	0020                	.insn	2, 0x0020
80003762:	0000                	.insn	2, 0x
80003764:	0264                	.insn	2, 0x0264
80003766:	0000                	.insn	2, 0x
80003768:	e7a4                	.insn	2, 0xe7a4
8000376a:	ffff                	.insn	2, 0xffff
8000376c:	01c4                	.insn	2, 0x01c4
8000376e:	0000                	.insn	2, 0x
80003770:	4400                	.insn	2, 0x4400
80003772:	200e                	.insn	2, 0x200e
80003774:	8150                	.insn	2, 0x8150
80003776:	8801                	.insn	2, 0x8801
80003778:	8902                	.insn	2, 0x8902
8000377a:	44049203          	lh	tp,1088(s1)
8000377e:	080c                	.insn	2, 0x080c
80003780:	0000                	.insn	2, 0x
80003782:	0000                	.insn	2, 0x
80003784:	001c                	.insn	2, 0x001c
80003786:	0000                	.insn	2, 0x
80003788:	0288                	.insn	2, 0x0288
8000378a:	0000                	.insn	2, 0x
8000378c:	e944                	.insn	2, 0xe944
8000378e:	ffff                	.insn	2, 0xffff
80003790:	002c                	.insn	2, 0x002c
80003792:	0000                	.insn	2, 0x
80003794:	4400                	.insn	2, 0x4400
80003796:	100e                	.insn	2, 0x100e
80003798:	8148                	.insn	2, 0x8148
8000379a:	8801                	.insn	2, 0x8801
8000379c:	4402                	.insn	2, 0x4402
8000379e:	080c                	.insn	2, 0x080c
800037a0:	0000                	.insn	2, 0x
800037a2:	0000                	.insn	2, 0x
800037a4:	001c                	.insn	2, 0x001c
800037a6:	0000                	.insn	2, 0x
800037a8:	02a8                	.insn	2, 0x02a8
800037aa:	0000                	.insn	2, 0x
800037ac:	e950                	.insn	2, 0xe950
800037ae:	ffff                	.insn	2, 0xffff
800037b0:	0034                	.insn	2, 0x0034
800037b2:	0000                	.insn	2, 0x
800037b4:	4400                	.insn	2, 0x4400
800037b6:	100e                	.insn	2, 0x100e
800037b8:	8148                	.insn	2, 0x8148
800037ba:	8801                	.insn	2, 0x8801
800037bc:	4402                	.insn	2, 0x4402
800037be:	080c                	.insn	2, 0x080c
800037c0:	0000                	.insn	2, 0x
800037c2:	0000                	.insn	2, 0x
800037c4:	001c                	.insn	2, 0x001c
800037c6:	0000                	.insn	2, 0x
800037c8:	02c8                	.insn	2, 0x02c8
800037ca:	0000                	.insn	2, 0x
800037cc:	e964                	.insn	2, 0xe964
800037ce:	ffff                	.insn	2, 0xffff
800037d0:	0110                	.insn	2, 0x0110
800037d2:	0000                	.insn	2, 0x
800037d4:	4400                	.insn	2, 0x4400
800037d6:	100e                	.insn	2, 0x100e
800037d8:	8148                	.insn	2, 0x8148
800037da:	8801                	.insn	2, 0x8801
800037dc:	4402                	.insn	2, 0x4402
800037de:	080c                	.insn	2, 0x080c
800037e0:	0000                	.insn	2, 0x
800037e2:	0000                	.insn	2, 0x
800037e4:	001c                	.insn	2, 0x001c
800037e6:	0000                	.insn	2, 0x
800037e8:	02e8                	.insn	2, 0x02e8
800037ea:	0000                	.insn	2, 0x
800037ec:	ea54                	.insn	2, 0xea54
800037ee:	ffff                	.insn	2, 0xffff
800037f0:	00a8                	.insn	2, 0x00a8
800037f2:	0000                	.insn	2, 0x
800037f4:	4400                	.insn	2, 0x4400
800037f6:	100e                	.insn	2, 0x100e
800037f8:	8148                	.insn	2, 0x8148
800037fa:	8801                	.insn	2, 0x8801
800037fc:	4402                	.insn	2, 0x4402
800037fe:	080c                	.insn	2, 0x080c
	...

Disassembly of section .comment:

00000000 <.comment>:
   0:	694c                	.insn	2, 0x694c
   2:	6b6e                	.insn	2, 0x6b6e
   4:	7265                	.insn	2, 0x7265
   6:	203a                	.insn	2, 0x203a
   8:	4c4c                	.insn	2, 0x4c4c
   a:	2044                	.insn	2, 0x2044
   c:	3931                	.insn	2, 0x3931
   e:	312e                	.insn	2, 0x312e
  10:	362e                	.insn	2, 0x362e
  12:	2820                	.insn	2, 0x2820
  14:	6568632f          	.insn	4, 0x6568632f
  18:	756f6b63          	bltu	t5,s6,76e <.Lline_table_start1+0x418>
  1c:	2f74                	.insn	2, 0x2f74
  1e:	2f637273          	.insn	4, 0x2f637273
  22:	6c6c                	.insn	2, 0x6c6c
  24:	6d76                	.insn	2, 0x6d76
  26:	702d                	.insn	2, 0x702d
  28:	6f72                	.insn	2, 0x6f72
  2a:	656a                	.insn	2, 0x656a
  2c:	6c2f7463          	bgeu	t5,sp,6f4 <.Lline_table_start1+0x39e>
  30:	766c                	.insn	2, 0x766c
  32:	206d                	.insn	2, 0x206d
  34:	3935                	.insn	2, 0x3935
  36:	3135                	.insn	2, 0x3135
  38:	6232                	.insn	2, 0x6232
  3a:	3030                	.insn	2, 0x3030
  3c:	3732                	.insn	2, 0x3732
  3e:	39323833          	.insn	4, 0x39323833
  42:	3238                	.insn	2, 0x3238
  44:	37616433          	.insn	4, 0x37616433
  48:	3034                	.insn	2, 0x3034
  4a:	3035                	.insn	2, 0x3035
  4c:	3364                	.insn	2, 0x3364
  4e:	38623337          	lui	t1,0x38623
  52:	3464                	.insn	2, 0x3464
  54:	6436                	.insn	2, 0x6436
  56:	6362                	.insn	2, 0x6362
  58:	3561                	.insn	2, 0x3561
  5a:	3835                	.insn	2, 0x3835
  5c:	0029                	.insn	2, 0x0029
  5e:	7200                	.insn	2, 0x7200
  60:	7375                	.insn	2, 0x7375
  62:	6374                	.insn	2, 0x6374
  64:	7620                	.insn	2, 0x7620
  66:	7265                	.insn	2, 0x7265
  68:	6e6f6973          	.insn	4, 0x6e6f6973
  6c:	3120                	.insn	2, 0x3120
  6e:	382e                	.insn	2, 0x382e
  70:	2e36                	.insn	2, 0x2e36
  72:	2d30                	.insn	2, 0x2d30
  74:	696e                	.insn	2, 0x696e
  76:	6c746867          	.insn	4, 0x6c746867
  7a:	2079                	.insn	2, 0x2079
  7c:	3428                	.insn	2, 0x3428
  7e:	6138                	.insn	2, 0x6138
  80:	3234                	.insn	2, 0x3234
  82:	6536                	.insn	2, 0x6536
  84:	32206163          	bltu	zero,sp,3a6 <.Lline_table_start1+0x50>
  88:	3230                	.insn	2, 0x3230
  8a:	2d35                	.insn	2, 0x2d35
  8c:	3130                	.insn	2, 0x3130
  8e:	312d                	.insn	2, 0x312d
  90:	2932                	.insn	2, 0x2932
	...

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes>:
   0:	2941                	.insn	2, 0x2941
   2:	0000                	.insn	2, 0x
   4:	7200                	.insn	2, 0x7200
   6:	7369                	.insn	2, 0x7369
   8:	01007663          	bgeu	zero,a6,14 <.Lline_table_start0+0x14>
   c:	001f 0000 1004      	.insn	6, 0x10040000001f
  12:	7205                	.insn	2, 0x7205
  14:	3376                	.insn	2, 0x3376
  16:	6932                	.insn	2, 0x6932
  18:	7032                	.insn	2, 0x7032
  1a:	5f31                	.insn	2, 0x5f31
  1c:	326d                	.insn	2, 0x326d
  1e:	3070                	.insn	2, 0x3070
  20:	7a5f 6d6d 6c75      	.insn	6, 0x6c756d6d7a5f
  26:	7031                	.insn	2, 0x7031
  28:	0030                	.insn	2, 0x0030
