
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	9e010113          	addi	sp,sp,-1568 # 800079e0 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd2f7>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e6c78793          	addi	a5,a5,-404 # 80000ef0 <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	664020ef          	jal	8000277e <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	00010517          	auipc	a0,0x10
    80000196:	84e50513          	addi	a0,a0,-1970 # 8000f9e0 <cons>
    8000019a:	2d1000ef          	jal	80000c6a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00010497          	auipc	s1,0x10
    800001a2:	84248493          	addi	s1,s1,-1982 # 8000f9e0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00010917          	auipc	s2,0x10
    800001aa:	8d290913          	addi	s2,s2,-1838 # 8000fa78 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	7a6010ef          	jal	80001964 <myproc>
    800001c2:	0c8020ef          	jal	8000228a <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	665010ef          	jal	80002030 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00010717          	auipc	a4,0x10
    800001e2:	80270713          	addi	a4,a4,-2046 # 8000f9e0 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	524020ef          	jal	80002734 <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	0000f517          	auipc	a0,0xf
    8000022c:	7b850513          	addi	a0,a0,1976 # 8000f9e0 <cons>
    80000230:	2cf000ef          	jal	80000cfe <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	00010717          	auipc	a4,0x10
    80000252:	82f72523          	sw	a5,-2006(a4) # 8000fa78 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	77c50513          	addi	a0,a0,1916 # 8000f9e0 <cons>
    8000026c:	293000ef          	jal	80000cfe <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
	//printf("sh가 실행되었나요?\n");
  acquire(&cons.lock);
    800002b8:	0000f517          	auipc	a0,0xf
    800002bc:	72850513          	addi	a0,a0,1832 # 8000f9e0 <cons>
    800002c0:	1ab000ef          	jal	80000c6a <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	4ee020ef          	jal	800027c8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	70250513          	addi	a0,a0,1794 # 8000f9e0 <cons>
    800002e6:	219000ef          	jal	80000cfe <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	0000f717          	auipc	a4,0xf
    80000300:	6e470713          	addi	a4,a4,1764 # 8000f9e0 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	0000f717          	auipc	a4,0xf
    80000326:	6be70713          	addi	a4,a4,1726 # 8000f9e0 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	0000f717          	auipc	a4,0xf
    80000350:	72c72703          	lw	a4,1836(a4) # 8000fa78 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	0000f717          	auipc	a4,0xf
    80000366:	67e70713          	addi	a4,a4,1662 # 8000f9e0 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	0000f497          	auipc	s1,0xf
    80000376:	66e48493          	addi	s1,s1,1646 # 8000f9e0 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	0000f717          	auipc	a4,0xf
    800003b8:	62c70713          	addi	a4,a4,1580 # 8000f9e0 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	0000f717          	auipc	a4,0xf
    800003ce:	6af72b23          	sw	a5,1718(a4) # 8000fa80 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	0000f797          	auipc	a5,0xf
    800003ec:	5f878793          	addi	a5,a5,1528 # 8000f9e0 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	0000f797          	auipc	a5,0xf
    8000040e:	66c7a923          	sw	a2,1650(a5) # 8000fa7c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	0000f517          	auipc	a0,0xf
    80000416:	66650513          	addi	a0,a0,1638 # 8000fa78 <cons+0x98>
    8000041a:	463010ef          	jal	8000207c <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00007597          	auipc	a1,0x7
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80007000 <etext>
    80000430:	0000f517          	auipc	a0,0xf
    80000434:	5b050513          	addi	a0,a0,1456 # 8000f9e0 <cons>
    80000438:	7a8000ef          	jal	80000be0 <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00020797          	auipc	a5,0x20
    80000444:	f3078793          	addi	a5,a5,-208 # 80020370 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007817          	auipc	a6,0x7
    80000482:	33280813          	addi	a6,a6,818 # 800077b0 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	49c7a783          	lw	a5,1180(a5) # 800079b4 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	0000f517          	auipc	a0,0xf
    80000562:	52a50513          	addi	a0,a0,1322 # 8000fa88 <pr>
    80000566:	704000ef          	jal	80000c6a <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00007c97          	auipc	s9,0x7
    800006d6:	0dec8c93          	addi	s9,s9,222 # 800077b0 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00007a17          	auipc	s4,0x7
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	00007797          	auipc	a5,0x7
    8000075e:	25a7a783          	lw	a5,602(a5) # 800079b4 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	0000f517          	auipc	a0,0xf
    80000788:	30450513          	addi	a0,a0,772 # 8000fa88 <pr>
    8000078c:	572000ef          	jal	80000cfe <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	00007797          	auipc	a5,0x7
    80000838:	1897a023          	sw	s1,384(a5) # 800079b4 <panicking>
  printf("panic: ");
    8000083c:	00006517          	auipc	a0,0x6
    80000840:	7dc50513          	addi	a0,a0,2012 # 80007018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00006517          	auipc	a0,0x6
    8000084e:	7d650513          	addi	a0,a0,2006 # 80007020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	00007797          	auipc	a5,0x7
    8000085a:	1497ad23          	sw	s1,346(a5) # 800079b0 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00006597          	auipc	a1,0x6
    8000086c:	7c058593          	addi	a1,a1,1984 # 80007028 <etext+0x28>
    80000870:	0000f517          	auipc	a0,0xf
    80000874:	21850513          	addi	a0,a0,536 # 8000fa88 <pr>
    80000878:	368000ef          	jal	80000be0 <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00006597          	auipc	a1,0x6
    800008c2:	77258593          	addi	a1,a1,1906 # 80007030 <etext+0x30>
    800008c6:	0000f517          	auipc	a0,0xf
    800008ca:	1da50513          	addi	a0,a0,474 # 8000faa0 <tx_lock>
    800008ce:	312000ef          	jal	80000be0 <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	0000f517          	auipc	a0,0xf
    800008ee:	1b650513          	addi	a0,a0,438 # 8000faa0 <tx_lock>
    800008f2:	378000ef          	jal	80000c6a <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	00007497          	auipc	s1,0x7
    8000090c:	0b448493          	addi	s1,s1,180 # 800079bc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	0000f997          	auipc	s3,0xf
    80000914:	19098993          	addi	s3,s3,400 # 8000faa0 <tx_lock>
    80000918:	00007917          	auipc	s2,0x7
    8000091c:	0a090913          	addi	s2,s2,160 # 800079b8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	704010ef          	jal	80002030 <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	0000f517          	auipc	a0,0xf
    8000095a:	14a50513          	addi	a0,a0,330 # 8000faa0 <tx_lock>
    8000095e:	3a0000ef          	jal	80000cfe <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	00007797          	auipc	a5,0x7
    8000097e:	03a7a783          	lw	a5,58(a5) # 800079b4 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00007797          	auipc	a5,0x7
    80000988:	02c7a783          	lw	a5,44(a5) # 800079b0 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	00007797          	auipc	a5,0x7
    800009ae:	00a7a783          	lw	a5,10(a5) # 800079b4 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	268000ef          	jal	80000c26 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2e8000ef          	jal	80000cae <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	0000f517          	auipc	a0,0xf
    80000a0a:	09a50513          	addi	a0,a0,154 # 8000faa0 <tx_lock>
    80000a0e:	25c000ef          	jal	80000c6a <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	0000f517          	auipc	a0,0xf
    80000a24:	08050513          	addi	a0,a0,128 # 8000faa0 <tx_lock>
    80000a28:	2d6000ef          	jal	80000cfe <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	00007797          	auipc	a5,0x7
    80000a40:	f807a023          	sw	zero,-128(a5) # 800079bc <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00007517          	auipc	a0,0x7
    80000a48:	f7450513          	addi	a0,a0,-140 # 800079b8 <tx_chan>
    80000a4c:	630010ef          	jal	8000207c <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	00021797          	auipc	a5,0x21
    80000a6c:	aa078793          	addi	a5,a5,-1376 # 80021508 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	47c5                	li	a5,17
    80000a76:	07ee                	slli	a5,a5,0x1b
    80000a78:	17fd                	addi	a5,a5,-1
    80000a7a:	00a7b7b3          	sltu	a5,a5,a0
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	e3b9                	bnez	a5,80000ac6 <kfree+0x6a>
    80000a82:	84aa                	mv	s1,a0
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	ef9d                	bnez	a5,80000ac6 <kfree+0x6a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4585                	li	a1,1
    80000a8e:	2ac000ef          	jal	80000d3a <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a92:	0000f917          	auipc	s2,0xf
    80000a96:	02690913          	addi	s2,s2,38 # 8000fab8 <kmem>
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	1ce000ef          	jal	80000c6a <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  kmem.page_count++; // free 되면 count 증가
    80000aaa:	02092783          	lw	a5,32(s2)
    80000aae:	2785                	addiw	a5,a5,1
    80000ab0:	02f92023          	sw	a5,32(s2)
  release(&kmem.lock);
    80000ab4:	854a                	mv	a0,s2
    80000ab6:	248000ef          	jal	80000cfe <release>
}
    80000aba:	60e2                	ld	ra,24(sp)
    80000abc:	6442                	ld	s0,16(sp)
    80000abe:	64a2                	ld	s1,8(sp)
    80000ac0:	6902                	ld	s2,0(sp)
    80000ac2:	6105                	addi	sp,sp,32
    80000ac4:	8082                	ret
    panic("kfree");
    80000ac6:	00006517          	auipc	a0,0x6
    80000aca:	57250513          	addi	a0,a0,1394 # 80007038 <etext+0x38>
    80000ace:	d57ff0ef          	jal	80000824 <panic>

0000000080000ad2 <freerange>:
{
    80000ad2:	7179                	addi	sp,sp,-48
    80000ad4:	f406                	sd	ra,40(sp)
    80000ad6:	f022                	sd	s0,32(sp)
    80000ad8:	ec26                	sd	s1,24(sp)
    80000ada:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000adc:	6785                	lui	a5,0x1
    80000ade:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae2:	00e504b3          	add	s1,a0,a4
    80000ae6:	777d                	lui	a4,0xfffff
    80000ae8:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aea:	94be                	add	s1,s1,a5
    80000aec:	0295e263          	bltu	a1,s1,80000b10 <freerange+0x3e>
    80000af0:	e84a                	sd	s2,16(sp)
    80000af2:	e44e                	sd	s3,8(sp)
    80000af4:	e052                	sd	s4,0(sp)
    80000af6:	892e                	mv	s2,a1
    kfree(p);
    80000af8:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	89be                	mv	s3,a5
    kfree(p);
    80000afc:	01448533          	add	a0,s1,s4
    80000b00:	f5dff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b04:	94ce                	add	s1,s1,s3
    80000b06:	fe997be3          	bgeu	s2,s1,80000afc <freerange+0x2a>
    80000b0a:	6942                	ld	s2,16(sp)
    80000b0c:	69a2                	ld	s3,8(sp)
    80000b0e:	6a02                	ld	s4,0(sp)
}
    80000b10:	70a2                	ld	ra,40(sp)
    80000b12:	7402                	ld	s0,32(sp)
    80000b14:	64e2                	ld	s1,24(sp)
    80000b16:	6145                	addi	sp,sp,48
    80000b18:	8082                	ret

0000000080000b1a <kinit>:
{
    80000b1a:	1141                	addi	sp,sp,-16
    80000b1c:	e406                	sd	ra,8(sp)
    80000b1e:	e022                	sd	s0,0(sp)
    80000b20:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b22:	00006597          	auipc	a1,0x6
    80000b26:	51e58593          	addi	a1,a1,1310 # 80007040 <etext+0x40>
    80000b2a:	0000f517          	auipc	a0,0xf
    80000b2e:	f8e50513          	addi	a0,a0,-114 # 8000fab8 <kmem>
    80000b32:	0ae000ef          	jal	80000be0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00021517          	auipc	a0,0x21
    80000b3e:	9ce50513          	addi	a0,a0,-1586 # 80021508 <end>
    80000b42:	f91ff0ef          	jal	80000ad2 <freerange>
}
    80000b46:	60a2                	ld	ra,8(sp)
    80000b48:	6402                	ld	s0,0(sp)
    80000b4a:	0141                	addi	sp,sp,16
    80000b4c:	8082                	ret

0000000080000b4e <freememinfo>:

// page 개수 반환
int
freememinfo(void)
{
    80000b4e:	1101                	addi	sp,sp,-32
    80000b50:	ec06                	sd	ra,24(sp)
    80000b52:	e822                	sd	s0,16(sp)
    80000b54:	e426                	sd	s1,8(sp)
    80000b56:	1000                	addi	s0,sp,32
	int count = 0;

	acquire(&kmem.lock);
    80000b58:	0000f517          	auipc	a0,0xf
    80000b5c:	f6050513          	addi	a0,a0,-160 # 8000fab8 <kmem>
    80000b60:	10a000ef          	jal	80000c6a <acquire>
	count = kmem.page_count;
    80000b64:	0000f797          	auipc	a5,0xf
    80000b68:	f747a783          	lw	a5,-140(a5) # 8000fad8 <kmem+0x20>
    80000b6c:	84be                	mv	s1,a5
	release(&kmem.lock);
    80000b6e:	0000f517          	auipc	a0,0xf
    80000b72:	f4a50513          	addi	a0,a0,-182 # 8000fab8 <kmem>
    80000b76:	188000ef          	jal	80000cfe <release>
	return count;
}
    80000b7a:	8526                	mv	a0,s1
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b90:	0000f517          	auipc	a0,0xf
    80000b94:	f2850513          	addi	a0,a0,-216 # 8000fab8 <kmem>
    80000b98:	0d2000ef          	jal	80000c6a <acquire>
  r = kmem.freelist;
    80000b9c:	0000f497          	auipc	s1,0xf
    80000ba0:	f344b483          	ld	s1,-204(s1) # 8000fad0 <kmem+0x18>
  if(r)
    80000ba4:	c49d                	beqz	s1,80000bd2 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000ba6:	609c                	ld	a5,0(s1)
    80000ba8:	0000f717          	auipc	a4,0xf
    80000bac:	f2f73423          	sd	a5,-216(a4) # 8000fad0 <kmem+0x18>
  release(&kmem.lock);
    80000bb0:	0000f517          	auipc	a0,0xf
    80000bb4:	f0850513          	addi	a0,a0,-248 # 8000fab8 <kmem>
    80000bb8:	146000ef          	jal	80000cfe <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bbc:	6605                	lui	a2,0x1
    80000bbe:	4595                	li	a1,5
    80000bc0:	8526                	mv	a0,s1
    80000bc2:	178000ef          	jal	80000d3a <memset>
  return (void*)r;
}
    80000bc6:	8526                	mv	a0,s1
    80000bc8:	60e2                	ld	ra,24(sp)
    80000bca:	6442                	ld	s0,16(sp)
    80000bcc:	64a2                	ld	s1,8(sp)
    80000bce:	6105                	addi	sp,sp,32
    80000bd0:	8082                	ret
  release(&kmem.lock);
    80000bd2:	0000f517          	auipc	a0,0xf
    80000bd6:	ee650513          	addi	a0,a0,-282 # 8000fab8 <kmem>
    80000bda:	124000ef          	jal	80000cfe <release>
  if(r)
    80000bde:	b7e5                	j	80000bc6 <kalloc+0x40>

0000000080000be0 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000be0:	1141                	addi	sp,sp,-16
    80000be2:	e406                	sd	ra,8(sp)
    80000be4:	e022                	sd	s0,0(sp)
    80000be6:	0800                	addi	s0,sp,16
  lk->name = name;
    80000be8:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bea:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bee:	00053823          	sd	zero,16(a0)
}
    80000bf2:	60a2                	ld	ra,8(sp)
    80000bf4:	6402                	ld	s0,0(sp)
    80000bf6:	0141                	addi	sp,sp,16
    80000bf8:	8082                	ret

0000000080000bfa <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bfa:	411c                	lw	a5,0(a0)
    80000bfc:	e399                	bnez	a5,80000c02 <holding+0x8>
    80000bfe:	4501                	li	a0,0
  return r;
}
    80000c00:	8082                	ret
{
    80000c02:	1101                	addi	sp,sp,-32
    80000c04:	ec06                	sd	ra,24(sp)
    80000c06:	e822                	sd	s0,16(sp)
    80000c08:	e426                	sd	s1,8(sp)
    80000c0a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c0c:	691c                	ld	a5,16(a0)
    80000c0e:	84be                	mv	s1,a5
    80000c10:	535000ef          	jal	80001944 <mycpu>
    80000c14:	40a48533          	sub	a0,s1,a0
    80000c18:	00153513          	seqz	a0,a0
}
    80000c1c:	60e2                	ld	ra,24(sp)
    80000c1e:	6442                	ld	s0,16(sp)
    80000c20:	64a2                	ld	s1,8(sp)
    80000c22:	6105                	addi	sp,sp,32
    80000c24:	8082                	ret

0000000080000c26 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c26:	1101                	addi	sp,sp,-32
    80000c28:	ec06                	sd	ra,24(sp)
    80000c2a:	e822                	sd	s0,16(sp)
    80000c2c:	e426                	sd	s1,8(sp)
    80000c2e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c30:	100027f3          	csrr	a5,sstatus
    80000c34:	84be                	mv	s1,a5
    80000c36:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c3a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c3c:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000c40:	505000ef          	jal	80001944 <mycpu>
    80000c44:	5d3c                	lw	a5,120(a0)
    80000c46:	cb99                	beqz	a5,80000c5c <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c48:	4fd000ef          	jal	80001944 <mycpu>
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	2785                	addiw	a5,a5,1
    80000c50:	dd3c                	sw	a5,120(a0)
}
    80000c52:	60e2                	ld	ra,24(sp)
    80000c54:	6442                	ld	s0,16(sp)
    80000c56:	64a2                	ld	s1,8(sp)
    80000c58:	6105                	addi	sp,sp,32
    80000c5a:	8082                	ret
    mycpu()->intena = old;
    80000c5c:	4e9000ef          	jal	80001944 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c60:	0014d793          	srli	a5,s1,0x1
    80000c64:	8b85                	andi	a5,a5,1
    80000c66:	dd7c                	sw	a5,124(a0)
    80000c68:	b7c5                	j	80000c48 <push_off+0x22>

0000000080000c6a <acquire>:
{
    80000c6a:	1101                	addi	sp,sp,-32
    80000c6c:	ec06                	sd	ra,24(sp)
    80000c6e:	e822                	sd	s0,16(sp)
    80000c70:	e426                	sd	s1,8(sp)
    80000c72:	1000                	addi	s0,sp,32
    80000c74:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c76:	fb1ff0ef          	jal	80000c26 <push_off>
  if(holding(lk))
    80000c7a:	8526                	mv	a0,s1
    80000c7c:	f7fff0ef          	jal	80000bfa <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c80:	4705                	li	a4,1
  if(holding(lk))
    80000c82:	e105                	bnez	a0,80000ca2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c84:	87ba                	mv	a5,a4
    80000c86:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c8a:	2781                	sext.w	a5,a5
    80000c8c:	ffe5                	bnez	a5,80000c84 <acquire+0x1a>
  __sync_synchronize();
    80000c8e:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c92:	4b3000ef          	jal	80001944 <mycpu>
    80000c96:	e888                	sd	a0,16(s1)
}
    80000c98:	60e2                	ld	ra,24(sp)
    80000c9a:	6442                	ld	s0,16(sp)
    80000c9c:	64a2                	ld	s1,8(sp)
    80000c9e:	6105                	addi	sp,sp,32
    80000ca0:	8082                	ret
    panic("acquire");
    80000ca2:	00006517          	auipc	a0,0x6
    80000ca6:	3a650513          	addi	a0,a0,934 # 80007048 <etext+0x48>
    80000caa:	b7bff0ef          	jal	80000824 <panic>

0000000080000cae <pop_off>:

void
pop_off(void)
{
    80000cae:	1141                	addi	sp,sp,-16
    80000cb0:	e406                	sd	ra,8(sp)
    80000cb2:	e022                	sd	s0,0(sp)
    80000cb4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cb6:	48f000ef          	jal	80001944 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cbe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cc0:	e39d                	bnez	a5,80000ce6 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cc2:	5d3c                	lw	a5,120(a0)
    80000cc4:	02f05763          	blez	a5,80000cf2 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000cc8:	37fd                	addiw	a5,a5,-1
    80000cca:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000ccc:	eb89                	bnez	a5,80000cde <pop_off+0x30>
    80000cce:	5d7c                	lw	a5,124(a0)
    80000cd0:	c799                	beqz	a5,80000cde <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cd6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cda:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cde:	60a2                	ld	ra,8(sp)
    80000ce0:	6402                	ld	s0,0(sp)
    80000ce2:	0141                	addi	sp,sp,16
    80000ce4:	8082                	ret
    panic("pop_off - interruptible");
    80000ce6:	00006517          	auipc	a0,0x6
    80000cea:	36a50513          	addi	a0,a0,874 # 80007050 <etext+0x50>
    80000cee:	b37ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cf2:	00006517          	auipc	a0,0x6
    80000cf6:	37650513          	addi	a0,a0,886 # 80007068 <etext+0x68>
    80000cfa:	b2bff0ef          	jal	80000824 <panic>

0000000080000cfe <release>:
{
    80000cfe:	1101                	addi	sp,sp,-32
    80000d00:	ec06                	sd	ra,24(sp)
    80000d02:	e822                	sd	s0,16(sp)
    80000d04:	e426                	sd	s1,8(sp)
    80000d06:	1000                	addi	s0,sp,32
    80000d08:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d0a:	ef1ff0ef          	jal	80000bfa <holding>
    80000d0e:	c105                	beqz	a0,80000d2e <release+0x30>
  lk->cpu = 0;
    80000d10:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d14:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d18:	0310000f          	fence	rw,w
    80000d1c:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d20:	f8fff0ef          	jal	80000cae <pop_off>
}
    80000d24:	60e2                	ld	ra,24(sp)
    80000d26:	6442                	ld	s0,16(sp)
    80000d28:	64a2                	ld	s1,8(sp)
    80000d2a:	6105                	addi	sp,sp,32
    80000d2c:	8082                	ret
    panic("release");
    80000d2e:	00006517          	auipc	a0,0x6
    80000d32:	34250513          	addi	a0,a0,834 # 80007070 <etext+0x70>
    80000d36:	aefff0ef          	jal	80000824 <panic>

0000000080000d3a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d3a:	1141                	addi	sp,sp,-16
    80000d3c:	e406                	sd	ra,8(sp)
    80000d3e:	e022                	sd	s0,0(sp)
    80000d40:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d42:	ca19                	beqz	a2,80000d58 <memset+0x1e>
    80000d44:	87aa                	mv	a5,a0
    80000d46:	1602                	slli	a2,a2,0x20
    80000d48:	9201                	srli	a2,a2,0x20
    80000d4a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d4e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d52:	0785                	addi	a5,a5,1
    80000d54:	fee79de3          	bne	a5,a4,80000d4e <memset+0x14>
  }
  return dst;
}
    80000d58:	60a2                	ld	ra,8(sp)
    80000d5a:	6402                	ld	s0,0(sp)
    80000d5c:	0141                	addi	sp,sp,16
    80000d5e:	8082                	ret

0000000080000d60 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d60:	1141                	addi	sp,sp,-16
    80000d62:	e406                	sd	ra,8(sp)
    80000d64:	e022                	sd	s0,0(sp)
    80000d66:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d68:	c61d                	beqz	a2,80000d96 <memcmp+0x36>
    80000d6a:	1602                	slli	a2,a2,0x20
    80000d6c:	9201                	srli	a2,a2,0x20
    80000d6e:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d72:	00054783          	lbu	a5,0(a0)
    80000d76:	0005c703          	lbu	a4,0(a1)
    80000d7a:	00e79863          	bne	a5,a4,80000d8a <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d7e:	0505                	addi	a0,a0,1
    80000d80:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d82:	fed518e3          	bne	a0,a3,80000d72 <memcmp+0x12>
  }

  return 0;
    80000d86:	4501                	li	a0,0
    80000d88:	a019                	j	80000d8e <memcmp+0x2e>
      return *s1 - *s2;
    80000d8a:	40e7853b          	subw	a0,a5,a4
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret
  return 0;
    80000d96:	4501                	li	a0,0
    80000d98:	bfdd                	j	80000d8e <memcmp+0x2e>

0000000080000d9a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d9a:	1141                	addi	sp,sp,-16
    80000d9c:	e406                	sd	ra,8(sp)
    80000d9e:	e022                	sd	s0,0(sp)
    80000da0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000da2:	c205                	beqz	a2,80000dc2 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000da4:	02a5e363          	bltu	a1,a0,80000dca <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000da8:	1602                	slli	a2,a2,0x20
    80000daa:	9201                	srli	a2,a2,0x20
    80000dac:	00c587b3          	add	a5,a1,a2
{
    80000db0:	872a                	mv	a4,a0
      *d++ = *s++;
    80000db2:	0585                	addi	a1,a1,1
    80000db4:	0705                	addi	a4,a4,1
    80000db6:	fff5c683          	lbu	a3,-1(a1)
    80000dba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dbe:	feb79ae3          	bne	a5,a1,80000db2 <memmove+0x18>

  return dst;
}
    80000dc2:	60a2                	ld	ra,8(sp)
    80000dc4:	6402                	ld	s0,0(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret
  if(s < d && s + n > d){
    80000dca:	02061693          	slli	a3,a2,0x20
    80000dce:	9281                	srli	a3,a3,0x20
    80000dd0:	00d58733          	add	a4,a1,a3
    80000dd4:	fce57ae3          	bgeu	a0,a4,80000da8 <memmove+0xe>
    d += n;
    80000dd8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dda:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000dde:	1782                	slli	a5,a5,0x20
    80000de0:	9381                	srli	a5,a5,0x20
    80000de2:	fff7c793          	not	a5,a5
    80000de6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000de8:	177d                	addi	a4,a4,-1
    80000dea:	16fd                	addi	a3,a3,-1
    80000dec:	00074603          	lbu	a2,0(a4)
    80000df0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000df4:	fee79ae3          	bne	a5,a4,80000de8 <memmove+0x4e>
    80000df8:	b7e9                	j	80000dc2 <memmove+0x28>

0000000080000dfa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e406                	sd	ra,8(sp)
    80000dfe:	e022                	sd	s0,0(sp)
    80000e00:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e02:	f99ff0ef          	jal	80000d9a <memmove>
}
    80000e06:	60a2                	ld	ra,8(sp)
    80000e08:	6402                	ld	s0,0(sp)
    80000e0a:	0141                	addi	sp,sp,16
    80000e0c:	8082                	ret

0000000080000e0e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e0e:	1141                	addi	sp,sp,-16
    80000e10:	e406                	sd	ra,8(sp)
    80000e12:	e022                	sd	s0,0(sp)
    80000e14:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e16:	ce11                	beqz	a2,80000e32 <strncmp+0x24>
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf89                	beqz	a5,80000e36 <strncmp+0x28>
    80000e1e:	0005c703          	lbu	a4,0(a1)
    80000e22:	00f71a63          	bne	a4,a5,80000e36 <strncmp+0x28>
    n--, p++, q++;
    80000e26:	367d                	addiw	a2,a2,-1
    80000e28:	0505                	addi	a0,a0,1
    80000e2a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e2c:	f675                	bnez	a2,80000e18 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000e2e:	4501                	li	a0,0
    80000e30:	a801                	j	80000e40 <strncmp+0x32>
    80000e32:	4501                	li	a0,0
    80000e34:	a031                	j	80000e40 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e36:	00054503          	lbu	a0,0(a0)
    80000e3a:	0005c783          	lbu	a5,0(a1)
    80000e3e:	9d1d                	subw	a0,a0,a5
}
    80000e40:	60a2                	ld	ra,8(sp)
    80000e42:	6402                	ld	s0,0(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e406                	sd	ra,8(sp)
    80000e4c:	e022                	sd	s0,0(sp)
    80000e4e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e50:	87aa                	mv	a5,a0
    80000e52:	a011                	j	80000e56 <strncpy+0xe>
    80000e54:	8636                	mv	a2,a3
    80000e56:	02c05863          	blez	a2,80000e86 <strncpy+0x3e>
    80000e5a:	fff6069b          	addiw	a3,a2,-1
    80000e5e:	8836                	mv	a6,a3
    80000e60:	0785                	addi	a5,a5,1
    80000e62:	0005c703          	lbu	a4,0(a1)
    80000e66:	fee78fa3          	sb	a4,-1(a5)
    80000e6a:	0585                	addi	a1,a1,1
    80000e6c:	f765                	bnez	a4,80000e54 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e6e:	873e                	mv	a4,a5
    80000e70:	01005b63          	blez	a6,80000e86 <strncpy+0x3e>
    80000e74:	9fb1                	addw	a5,a5,a2
    80000e76:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e78:	0705                	addi	a4,a4,1
    80000e7a:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e7e:	40e786bb          	subw	a3,a5,a4
    80000e82:	fed04be3          	bgtz	a3,80000e78 <strncpy+0x30>
  return os;
}
    80000e86:	60a2                	ld	ra,8(sp)
    80000e88:	6402                	ld	s0,0(sp)
    80000e8a:	0141                	addi	sp,sp,16
    80000e8c:	8082                	ret

0000000080000e8e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e96:	02c05363          	blez	a2,80000ebc <safestrcpy+0x2e>
    80000e9a:	fff6069b          	addiw	a3,a2,-1
    80000e9e:	1682                	slli	a3,a3,0x20
    80000ea0:	9281                	srli	a3,a3,0x20
    80000ea2:	96ae                	add	a3,a3,a1
    80000ea4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ea6:	00d58963          	beq	a1,a3,80000eb8 <safestrcpy+0x2a>
    80000eaa:	0585                	addi	a1,a1,1
    80000eac:	0785                	addi	a5,a5,1
    80000eae:	fff5c703          	lbu	a4,-1(a1)
    80000eb2:	fee78fa3          	sb	a4,-1(a5)
    80000eb6:	fb65                	bnez	a4,80000ea6 <safestrcpy+0x18>
    ;
  *s = 0;
    80000eb8:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ebc:	60a2                	ld	ra,8(sp)
    80000ebe:	6402                	ld	s0,0(sp)
    80000ec0:	0141                	addi	sp,sp,16
    80000ec2:	8082                	ret

0000000080000ec4 <strlen>:

int
strlen(const char *s)
{
    80000ec4:	1141                	addi	sp,sp,-16
    80000ec6:	e406                	sd	ra,8(sp)
    80000ec8:	e022                	sd	s0,0(sp)
    80000eca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ecc:	00054783          	lbu	a5,0(a0)
    80000ed0:	cf91                	beqz	a5,80000eec <strlen+0x28>
    80000ed2:	00150793          	addi	a5,a0,1
    80000ed6:	86be                	mv	a3,a5
    80000ed8:	0785                	addi	a5,a5,1
    80000eda:	fff7c703          	lbu	a4,-1(a5)
    80000ede:	ff65                	bnez	a4,80000ed6 <strlen+0x12>
    80000ee0:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ee4:	60a2                	ld	ra,8(sp)
    80000ee6:	6402                	ld	s0,0(sp)
    80000ee8:	0141                	addi	sp,sp,16
    80000eea:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eec:	4501                	li	a0,0
    80000eee:	bfdd                	j	80000ee4 <strlen+0x20>

0000000080000ef0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ef0:	1141                	addi	sp,sp,-16
    80000ef2:	e406                	sd	ra,8(sp)
    80000ef4:	e022                	sd	s0,0(sp)
    80000ef6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ef8:	239000ef          	jal	80001930 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000efc:	00007717          	auipc	a4,0x7
    80000f00:	ac470713          	addi	a4,a4,-1340 # 800079c0 <started>
  if(cpuid() == 0){
    80000f04:	c51d                	beqz	a0,80000f32 <main+0x42>
    while(started == 0)
    80000f06:	431c                	lw	a5,0(a4)
    80000f08:	2781                	sext.w	a5,a5
    80000f0a:	dff5                	beqz	a5,80000f06 <main+0x16>
      ;
    __sync_synchronize();
    80000f0c:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f10:	221000ef          	jal	80001930 <cpuid>
    80000f14:	85aa                	mv	a1,a0
    80000f16:	00006517          	auipc	a0,0x6
    80000f1a:	18250513          	addi	a0,a0,386 # 80007098 <etext+0x98>
    80000f1e:	ddcff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000f22:	080000ef          	jal	80000fa2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f26:	1d5010ef          	jal	800028fa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f2a:	2cf040ef          	jal	800059f8 <plicinithart>
  }

  scheduler();        
    80000f2e:	705000ef          	jal	80001e32 <scheduler>
    consoleinit();
    80000f32:	ceeff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000f36:	92bff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000f3a:	00006517          	auipc	a0,0x6
    80000f3e:	13e50513          	addi	a0,a0,318 # 80007078 <etext+0x78>
    80000f42:	db8ff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f46:	00006517          	auipc	a0,0x6
    80000f4a:	13a50513          	addi	a0,a0,314 # 80007080 <etext+0x80>
    80000f4e:	dacff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f52:	00006517          	auipc	a0,0x6
    80000f56:	12650513          	addi	a0,a0,294 # 80007078 <etext+0x78>
    80000f5a:	da0ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f5e:	bbdff0ef          	jal	80000b1a <kinit>
    kvminit();       // create kernel page table
    80000f62:	2cc000ef          	jal	8000122e <kvminit>
    kvminithart();   // turn on paging
    80000f66:	03c000ef          	jal	80000fa2 <kvminithart>
    procinit();      // process table
    80000f6a:	117000ef          	jal	80001880 <procinit>
    trapinit();      // trap vectors
    80000f6e:	169010ef          	jal	800028d6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f72:	189010ef          	jal	800028fa <trapinithart>
    plicinit();      // set up interrupt controller
    80000f76:	269040ef          	jal	800059de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f7a:	27f040ef          	jal	800059f8 <plicinithart>
    binit();         // buffer cache
    80000f7e:	0f2020ef          	jal	80003070 <binit>
    iinit();         // inode table
    80000f82:	644020ef          	jal	800035c6 <iinit>
    fileinit();      // file table
    80000f86:	570030ef          	jal	800044f6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	35f040ef          	jal	80005ae8 <virtio_disk_init>
    userinit();      // first user process
    80000f8e:	4db000ef          	jal	80001c68 <userinit>
    __sync_synchronize();
    80000f92:	0330000f          	fence	rw,rw
    started = 1;
    80000f96:	4785                	li	a5,1
    80000f98:	00007717          	auipc	a4,0x7
    80000f9c:	a2f72423          	sw	a5,-1496(a4) # 800079c0 <started>
    80000fa0:	b779                	j	80000f2e <main+0x3e>

0000000080000fa2 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000fa2:	1141                	addi	sp,sp,-16
    80000fa4:	e406                	sd	ra,8(sp)
    80000fa6:	e022                	sd	s0,0(sp)
    80000fa8:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000faa:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fae:	00007797          	auipc	a5,0x7
    80000fb2:	a1a7b783          	ld	a5,-1510(a5) # 800079c8 <kernel_pagetable>
    80000fb6:	83b1                	srli	a5,a5,0xc
    80000fb8:	577d                	li	a4,-1
    80000fba:	177e                	slli	a4,a4,0x3f
    80000fbc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fbe:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fc2:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fc6:	60a2                	ld	ra,8(sp)
    80000fc8:	6402                	ld	s0,0(sp)
    80000fca:	0141                	addi	sp,sp,16
    80000fcc:	8082                	ret

0000000080000fce <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fce:	7139                	addi	sp,sp,-64
    80000fd0:	fc06                	sd	ra,56(sp)
    80000fd2:	f822                	sd	s0,48(sp)
    80000fd4:	f426                	sd	s1,40(sp)
    80000fd6:	f04a                	sd	s2,32(sp)
    80000fd8:	ec4e                	sd	s3,24(sp)
    80000fda:	e852                	sd	s4,16(sp)
    80000fdc:	e456                	sd	s5,8(sp)
    80000fde:	e05a                	sd	s6,0(sp)
    80000fe0:	0080                	addi	s0,sp,64
    80000fe2:	84aa                	mv	s1,a0
    80000fe4:	89ae                	mv	s3,a1
    80000fe6:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fe8:	57fd                	li	a5,-1
    80000fea:	83e9                	srli	a5,a5,0x1a
    80000fec:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fee:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000ff0:	04b7e263          	bltu	a5,a1,80001034 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000ff4:	0149d933          	srl	s2,s3,s4
    80000ff8:	1ff97913          	andi	s2,s2,511
    80000ffc:	090e                	slli	s2,s2,0x3
    80000ffe:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001000:	00093483          	ld	s1,0(s2)
    80001004:	0014f793          	andi	a5,s1,1
    80001008:	cf85                	beqz	a5,80001040 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000100a:	80a9                	srli	s1,s1,0xa
    8000100c:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    8000100e:	3a5d                	addiw	s4,s4,-9
    80001010:	ff5a12e3          	bne	s4,s5,80000ff4 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80001014:	00c9d513          	srli	a0,s3,0xc
    80001018:	1ff57513          	andi	a0,a0,511
    8000101c:	050e                	slli	a0,a0,0x3
    8000101e:	9526                	add	a0,a0,s1
}
    80001020:	70e2                	ld	ra,56(sp)
    80001022:	7442                	ld	s0,48(sp)
    80001024:	74a2                	ld	s1,40(sp)
    80001026:	7902                	ld	s2,32(sp)
    80001028:	69e2                	ld	s3,24(sp)
    8000102a:	6a42                	ld	s4,16(sp)
    8000102c:	6aa2                	ld	s5,8(sp)
    8000102e:	6b02                	ld	s6,0(sp)
    80001030:	6121                	addi	sp,sp,64
    80001032:	8082                	ret
    panic("walk");
    80001034:	00006517          	auipc	a0,0x6
    80001038:	07c50513          	addi	a0,a0,124 # 800070b0 <etext+0xb0>
    8000103c:	fe8ff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001040:	020b0263          	beqz	s6,80001064 <walk+0x96>
    80001044:	b43ff0ef          	jal	80000b86 <kalloc>
    80001048:	84aa                	mv	s1,a0
    8000104a:	d979                	beqz	a0,80001020 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000104c:	6605                	lui	a2,0x1
    8000104e:	4581                	li	a1,0
    80001050:	cebff0ef          	jal	80000d3a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001054:	00c4d793          	srli	a5,s1,0xc
    80001058:	07aa                	slli	a5,a5,0xa
    8000105a:	0017e793          	ori	a5,a5,1
    8000105e:	00f93023          	sd	a5,0(s2)
    80001062:	b775                	j	8000100e <walk+0x40>
        return 0;
    80001064:	4501                	li	a0,0
    80001066:	bf6d                	j	80001020 <walk+0x52>

0000000080001068 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001068:	57fd                	li	a5,-1
    8000106a:	83e9                	srli	a5,a5,0x1a
    8000106c:	00b7f463          	bgeu	a5,a1,80001074 <walkaddr+0xc>
    return 0;
    80001070:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001072:	8082                	ret
{
    80001074:	1141                	addi	sp,sp,-16
    80001076:	e406                	sd	ra,8(sp)
    80001078:	e022                	sd	s0,0(sp)
    8000107a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000107c:	4601                	li	a2,0
    8000107e:	f51ff0ef          	jal	80000fce <walk>
  if(pte == 0)
    80001082:	c901                	beqz	a0,80001092 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001084:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001086:	0117f693          	andi	a3,a5,17
    8000108a:	4745                	li	a4,17
    return 0;
    8000108c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000108e:	00e68663          	beq	a3,a4,8000109a <walkaddr+0x32>
}
    80001092:	60a2                	ld	ra,8(sp)
    80001094:	6402                	ld	s0,0(sp)
    80001096:	0141                	addi	sp,sp,16
    80001098:	8082                	ret
  pa = PTE2PA(*pte);
    8000109a:	83a9                	srli	a5,a5,0xa
    8000109c:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010a0:	bfcd                	j	80001092 <walkaddr+0x2a>

00000000800010a2 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a2:	715d                	addi	sp,sp,-80
    800010a4:	e486                	sd	ra,72(sp)
    800010a6:	e0a2                	sd	s0,64(sp)
    800010a8:	fc26                	sd	s1,56(sp)
    800010aa:	f84a                	sd	s2,48(sp)
    800010ac:	f44e                	sd	s3,40(sp)
    800010ae:	f052                	sd	s4,32(sp)
    800010b0:	ec56                	sd	s5,24(sp)
    800010b2:	e85a                	sd	s6,16(sp)
    800010b4:	e45e                	sd	s7,8(sp)
    800010b6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800010b8:	03459793          	slli	a5,a1,0x34
    800010bc:	eba1                	bnez	a5,8000110c <mappages+0x6a>
    800010be:	8a2a                	mv	s4,a0
    800010c0:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800010c2:	03461793          	slli	a5,a2,0x34
    800010c6:	eba9                	bnez	a5,80001118 <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    800010c8:	ce31                	beqz	a2,80001124 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800010ca:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    800010ce:	80060613          	addi	a2,a2,-2048
    800010d2:	00b60933          	add	s2,a2,a1
  a = va;
    800010d6:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d8:	4b05                	li	s6,1
    800010da:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010de:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    800010e0:	865a                	mv	a2,s6
    800010e2:	85a6                	mv	a1,s1
    800010e4:	8552                	mv	a0,s4
    800010e6:	ee9ff0ef          	jal	80000fce <walk>
    800010ea:	c929                	beqz	a0,8000113c <mappages+0x9a>
    if(*pte & PTE_V)
    800010ec:	611c                	ld	a5,0(a0)
    800010ee:	8b85                	andi	a5,a5,1
    800010f0:	e3a1                	bnez	a5,80001130 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f2:	013487b3          	add	a5,s1,s3
    800010f6:	83b1                	srli	a5,a5,0xc
    800010f8:	07aa                	slli	a5,a5,0xa
    800010fa:	0157e7b3          	or	a5,a5,s5
    800010fe:	0017e793          	ori	a5,a5,1
    80001102:	e11c                	sd	a5,0(a0)
    if(a == last)
    80001104:	05248863          	beq	s1,s2,80001154 <mappages+0xb2>
    a += PGSIZE;
    80001108:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110a:	bfd9                	j	800010e0 <mappages+0x3e>
    panic("mappages: va not aligned");
    8000110c:	00006517          	auipc	a0,0x6
    80001110:	fac50513          	addi	a0,a0,-84 # 800070b8 <etext+0xb8>
    80001114:	f10ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    80001118:	00006517          	auipc	a0,0x6
    8000111c:	fc050513          	addi	a0,a0,-64 # 800070d8 <etext+0xd8>
    80001120:	f04ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    80001124:	00006517          	auipc	a0,0x6
    80001128:	fd450513          	addi	a0,a0,-44 # 800070f8 <etext+0xf8>
    8000112c:	ef8ff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    80001130:	00006517          	auipc	a0,0x6
    80001134:	fd850513          	addi	a0,a0,-40 # 80007108 <etext+0x108>
    80001138:	eecff0ef          	jal	80000824 <panic>
      return -1;
    8000113c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000113e:	60a6                	ld	ra,72(sp)
    80001140:	6406                	ld	s0,64(sp)
    80001142:	74e2                	ld	s1,56(sp)
    80001144:	7942                	ld	s2,48(sp)
    80001146:	79a2                	ld	s3,40(sp)
    80001148:	7a02                	ld	s4,32(sp)
    8000114a:	6ae2                	ld	s5,24(sp)
    8000114c:	6b42                	ld	s6,16(sp)
    8000114e:	6ba2                	ld	s7,8(sp)
    80001150:	6161                	addi	sp,sp,80
    80001152:	8082                	ret
  return 0;
    80001154:	4501                	li	a0,0
    80001156:	b7e5                	j	8000113e <mappages+0x9c>

0000000080001158 <kvmmap>:
{
    80001158:	1141                	addi	sp,sp,-16
    8000115a:	e406                	sd	ra,8(sp)
    8000115c:	e022                	sd	s0,0(sp)
    8000115e:	0800                	addi	s0,sp,16
    80001160:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001162:	86b2                	mv	a3,a2
    80001164:	863e                	mv	a2,a5
    80001166:	f3dff0ef          	jal	800010a2 <mappages>
    8000116a:	e509                	bnez	a0,80001174 <kvmmap+0x1c>
}
    8000116c:	60a2                	ld	ra,8(sp)
    8000116e:	6402                	ld	s0,0(sp)
    80001170:	0141                	addi	sp,sp,16
    80001172:	8082                	ret
    panic("kvmmap");
    80001174:	00006517          	auipc	a0,0x6
    80001178:	fa450513          	addi	a0,a0,-92 # 80007118 <etext+0x118>
    8000117c:	ea8ff0ef          	jal	80000824 <panic>

0000000080001180 <kvmmake>:
{
    80001180:	1101                	addi	sp,sp,-32
    80001182:	ec06                	sd	ra,24(sp)
    80001184:	e822                	sd	s0,16(sp)
    80001186:	e426                	sd	s1,8(sp)
    80001188:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118a:	9fdff0ef          	jal	80000b86 <kalloc>
    8000118e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001190:	6605                	lui	a2,0x1
    80001192:	4581                	li	a1,0
    80001194:	ba7ff0ef          	jal	80000d3a <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001198:	4719                	li	a4,6
    8000119a:	6685                	lui	a3,0x1
    8000119c:	10000637          	lui	a2,0x10000
    800011a0:	85b2                	mv	a1,a2
    800011a2:	8526                	mv	a0,s1
    800011a4:	fb5ff0ef          	jal	80001158 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a8:	4719                	li	a4,6
    800011aa:	6685                	lui	a3,0x1
    800011ac:	10001637          	lui	a2,0x10001
    800011b0:	85b2                	mv	a1,a2
    800011b2:	8526                	mv	a0,s1
    800011b4:	fa5ff0ef          	jal	80001158 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011b8:	4719                	li	a4,6
    800011ba:	040006b7          	lui	a3,0x4000
    800011be:	0c000637          	lui	a2,0xc000
    800011c2:	85b2                	mv	a1,a2
    800011c4:	8526                	mv	a0,s1
    800011c6:	f93ff0ef          	jal	80001158 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ca:	4729                	li	a4,10
    800011cc:	80006697          	auipc	a3,0x80006
    800011d0:	e3468693          	addi	a3,a3,-460 # 7000 <_entry-0x7fff9000>
    800011d4:	4605                	li	a2,1
    800011d6:	067e                	slli	a2,a2,0x1f
    800011d8:	85b2                	mv	a1,a2
    800011da:	8526                	mv	a0,s1
    800011dc:	f7dff0ef          	jal	80001158 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011e0:	4719                	li	a4,6
    800011e2:	00006697          	auipc	a3,0x6
    800011e6:	e1e68693          	addi	a3,a3,-482 # 80007000 <etext>
    800011ea:	47c5                	li	a5,17
    800011ec:	07ee                	slli	a5,a5,0x1b
    800011ee:	40d786b3          	sub	a3,a5,a3
    800011f2:	00006617          	auipc	a2,0x6
    800011f6:	e0e60613          	addi	a2,a2,-498 # 80007000 <etext>
    800011fa:	85b2                	mv	a1,a2
    800011fc:	8526                	mv	a0,s1
    800011fe:	f5bff0ef          	jal	80001158 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001202:	4729                	li	a4,10
    80001204:	6685                	lui	a3,0x1
    80001206:	00005617          	auipc	a2,0x5
    8000120a:	dfa60613          	addi	a2,a2,-518 # 80006000 <_trampoline>
    8000120e:	040005b7          	lui	a1,0x4000
    80001212:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001214:	05b2                	slli	a1,a1,0xc
    80001216:	8526                	mv	a0,s1
    80001218:	f41ff0ef          	jal	80001158 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000121c:	8526                	mv	a0,s1
    8000121e:	5c4000ef          	jal	800017e2 <proc_mapstacks>
}
    80001222:	8526                	mv	a0,s1
    80001224:	60e2                	ld	ra,24(sp)
    80001226:	6442                	ld	s0,16(sp)
    80001228:	64a2                	ld	s1,8(sp)
    8000122a:	6105                	addi	sp,sp,32
    8000122c:	8082                	ret

000000008000122e <kvminit>:
{
    8000122e:	1141                	addi	sp,sp,-16
    80001230:	e406                	sd	ra,8(sp)
    80001232:	e022                	sd	s0,0(sp)
    80001234:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001236:	f4bff0ef          	jal	80001180 <kvmmake>
    8000123a:	00006797          	auipc	a5,0x6
    8000123e:	78a7b723          	sd	a0,1934(a5) # 800079c8 <kernel_pagetable>
}
    80001242:	60a2                	ld	ra,8(sp)
    80001244:	6402                	ld	s0,0(sp)
    80001246:	0141                	addi	sp,sp,16
    80001248:	8082                	ret

000000008000124a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000124a:	1101                	addi	sp,sp,-32
    8000124c:	ec06                	sd	ra,24(sp)
    8000124e:	e822                	sd	s0,16(sp)
    80001250:	e426                	sd	s1,8(sp)
    80001252:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001254:	933ff0ef          	jal	80000b86 <kalloc>
    80001258:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000125a:	c509                	beqz	a0,80001264 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000125c:	6605                	lui	a2,0x1
    8000125e:	4581                	li	a1,0
    80001260:	adbff0ef          	jal	80000d3a <memset>
  return pagetable;
}
    80001264:	8526                	mv	a0,s1
    80001266:	60e2                	ld	ra,24(sp)
    80001268:	6442                	ld	s0,16(sp)
    8000126a:	64a2                	ld	s1,8(sp)
    8000126c:	6105                	addi	sp,sp,32
    8000126e:	8082                	ret

0000000080001270 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001270:	7139                	addi	sp,sp,-64
    80001272:	fc06                	sd	ra,56(sp)
    80001274:	f822                	sd	s0,48(sp)
    80001276:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001278:	03459793          	slli	a5,a1,0x34
    8000127c:	e38d                	bnez	a5,8000129e <uvmunmap+0x2e>
    8000127e:	f04a                	sd	s2,32(sp)
    80001280:	ec4e                	sd	s3,24(sp)
    80001282:	e852                	sd	s4,16(sp)
    80001284:	e456                	sd	s5,8(sp)
    80001286:	e05a                	sd	s6,0(sp)
    80001288:	8a2a                	mv	s4,a0
    8000128a:	892e                	mv	s2,a1
    8000128c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	0632                	slli	a2,a2,0xc
    80001290:	00b609b3          	add	s3,a2,a1
    80001294:	6b05                	lui	s6,0x1
    80001296:	0535f963          	bgeu	a1,s3,800012e8 <uvmunmap+0x78>
    8000129a:	f426                	sd	s1,40(sp)
    8000129c:	a015                	j	800012c0 <uvmunmap+0x50>
    8000129e:	f426                	sd	s1,40(sp)
    800012a0:	f04a                	sd	s2,32(sp)
    800012a2:	ec4e                	sd	s3,24(sp)
    800012a4:	e852                	sd	s4,16(sp)
    800012a6:	e456                	sd	s5,8(sp)
    800012a8:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800012aa:	00006517          	auipc	a0,0x6
    800012ae:	e7650513          	addi	a0,a0,-394 # 80007120 <etext+0x120>
    800012b2:	d72ff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800012b6:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ba:	995a                	add	s2,s2,s6
    800012bc:	03397563          	bgeu	s2,s3,800012e6 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800012c0:	4601                	li	a2,0
    800012c2:	85ca                	mv	a1,s2
    800012c4:	8552                	mv	a0,s4
    800012c6:	d09ff0ef          	jal	80000fce <walk>
    800012ca:	84aa                	mv	s1,a0
    800012cc:	d57d                	beqz	a0,800012ba <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800012ce:	611c                	ld	a5,0(a0)
    800012d0:	0017f713          	andi	a4,a5,1
    800012d4:	d37d                	beqz	a4,800012ba <uvmunmap+0x4a>
    if(do_free){
    800012d6:	fe0a80e3          	beqz	s5,800012b6 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800012da:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800012dc:	00c79513          	slli	a0,a5,0xc
    800012e0:	f7cff0ef          	jal	80000a5c <kfree>
    800012e4:	bfc9                	j	800012b6 <uvmunmap+0x46>
    800012e6:	74a2                	ld	s1,40(sp)
    800012e8:	7902                	ld	s2,32(sp)
    800012ea:	69e2                	ld	s3,24(sp)
    800012ec:	6a42                	ld	s4,16(sp)
    800012ee:	6aa2                	ld	s5,8(sp)
    800012f0:	6b02                	ld	s6,0(sp)
  }
}
    800012f2:	70e2                	ld	ra,56(sp)
    800012f4:	7442                	ld	s0,48(sp)
    800012f6:	6121                	addi	sp,sp,64
    800012f8:	8082                	ret

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	f39ff0ef          	jal	80001270 <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	0ab66163          	bltu	a2,a1,800013e0 <uvmalloc+0xa2>
{
    80001342:	715d                	addi	sp,sp,-80
    80001344:	e486                	sd	ra,72(sp)
    80001346:	e0a2                	sd	s0,64(sp)
    80001348:	f84a                	sd	s2,48(sp)
    8000134a:	f052                	sd	s4,32(sp)
    8000134c:	ec56                	sd	s5,24(sp)
    8000134e:	e45e                	sd	s7,8(sp)
    80001350:	0880                	addi	s0,sp,80
    80001352:	8aaa                	mv	s5,a0
    80001354:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001356:	6785                	lui	a5,0x1
    80001358:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000135a:	95be                	add	a1,a1,a5
    8000135c:	77fd                	lui	a5,0xfffff
    8000135e:	00f5f933          	and	s2,a1,a5
    80001362:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001364:	08c97063          	bgeu	s2,a2,800013e4 <uvmalloc+0xa6>
    80001368:	fc26                	sd	s1,56(sp)
    8000136a:	f44e                	sd	s3,40(sp)
    8000136c:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000136e:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001370:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001374:	813ff0ef          	jal	80000b86 <kalloc>
    80001378:	84aa                	mv	s1,a0
    if(mem == 0){
    8000137a:	c50d                	beqz	a0,800013a4 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000137c:	864e                	mv	a2,s3
    8000137e:	4581                	li	a1,0
    80001380:	9bbff0ef          	jal	80000d3a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001384:	875a                	mv	a4,s6
    80001386:	86a6                	mv	a3,s1
    80001388:	864e                	mv	a2,s3
    8000138a:	85ca                	mv	a1,s2
    8000138c:	8556                	mv	a0,s5
    8000138e:	d15ff0ef          	jal	800010a2 <mappages>
    80001392:	e915                	bnez	a0,800013c6 <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001394:	994e                	add	s2,s2,s3
    80001396:	fd496fe3          	bltu	s2,s4,80001374 <uvmalloc+0x36>
  return newsz;
    8000139a:	8552                	mv	a0,s4
    8000139c:	74e2                	ld	s1,56(sp)
    8000139e:	79a2                	ld	s3,40(sp)
    800013a0:	6b42                	ld	s6,16(sp)
    800013a2:	a811                	j	800013b6 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    800013a4:	865e                	mv	a2,s7
    800013a6:	85ca                	mv	a1,s2
    800013a8:	8556                	mv	a0,s5
    800013aa:	f51ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ae:	4501                	li	a0,0
    800013b0:	74e2                	ld	s1,56(sp)
    800013b2:	79a2                	ld	s3,40(sp)
    800013b4:	6b42                	ld	s6,16(sp)
}
    800013b6:	60a6                	ld	ra,72(sp)
    800013b8:	6406                	ld	s0,64(sp)
    800013ba:	7942                	ld	s2,48(sp)
    800013bc:	7a02                	ld	s4,32(sp)
    800013be:	6ae2                	ld	s5,24(sp)
    800013c0:	6ba2                	ld	s7,8(sp)
    800013c2:	6161                	addi	sp,sp,80
    800013c4:	8082                	ret
      kfree(mem);
    800013c6:	8526                	mv	a0,s1
    800013c8:	e94ff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013cc:	865e                	mv	a2,s7
    800013ce:	85ca                	mv	a1,s2
    800013d0:	8556                	mv	a0,s5
    800013d2:	f29ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d6:	4501                	li	a0,0
    800013d8:	74e2                	ld	s1,56(sp)
    800013da:	79a2                	ld	s3,40(sp)
    800013dc:	6b42                	ld	s6,16(sp)
    800013de:	bfe1                	j	800013b6 <uvmalloc+0x78>
    return oldsz;
    800013e0:	852e                	mv	a0,a1
}
    800013e2:	8082                	ret
  return newsz;
    800013e4:	8532                	mv	a0,a2
    800013e6:	bfc1                	j	800013b6 <uvmalloc+0x78>

00000000800013e8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e8:	7179                	addi	sp,sp,-48
    800013ea:	f406                	sd	ra,40(sp)
    800013ec:	f022                	sd	s0,32(sp)
    800013ee:	ec26                	sd	s1,24(sp)
    800013f0:	e84a                	sd	s2,16(sp)
    800013f2:	e44e                	sd	s3,8(sp)
    800013f4:	1800                	addi	s0,sp,48
    800013f6:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f8:	84aa                	mv	s1,a0
    800013fa:	6905                	lui	s2,0x1
    800013fc:	992a                	add	s2,s2,a0
    800013fe:	a811                	j	80001412 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    80001400:	00006517          	auipc	a0,0x6
    80001404:	d3850513          	addi	a0,a0,-712 # 80007138 <etext+0x138>
    80001408:	c1cff0ef          	jal	80000824 <panic>
  for(int i = 0; i < 512; i++){
    8000140c:	04a1                	addi	s1,s1,8
    8000140e:	03248163          	beq	s1,s2,80001430 <freewalk+0x48>
    pte_t pte = pagetable[i];
    80001412:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001414:	0017f713          	andi	a4,a5,1
    80001418:	db75                	beqz	a4,8000140c <freewalk+0x24>
    8000141a:	00e7f713          	andi	a4,a5,14
    8000141e:	f36d                	bnez	a4,80001400 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    80001420:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001422:	00c79513          	slli	a0,a5,0xc
    80001426:	fc3ff0ef          	jal	800013e8 <freewalk>
      pagetable[i] = 0;
    8000142a:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000142e:	bff9                	j	8000140c <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    80001430:	854e                	mv	a0,s3
    80001432:	e2aff0ef          	jal	80000a5c <kfree>
}
    80001436:	70a2                	ld	ra,40(sp)
    80001438:	7402                	ld	s0,32(sp)
    8000143a:	64e2                	ld	s1,24(sp)
    8000143c:	6942                	ld	s2,16(sp)
    8000143e:	69a2                	ld	s3,8(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f95ff0ef          	jal	800013e8 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	e01ff0ef          	jal	80001270 <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	ca59                	beqz	a2,8000150c <uvmcopy+0x96>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8bae                	mv	s7,a1
    80001492:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001496:	6a05                	lui	s4,0x1
    80001498:	a021                	j	800014a0 <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    8000149a:	94d2                	add	s1,s1,s4
    8000149c:	0554fc63          	bgeu	s1,s5,800014f4 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    800014a0:	4601                	li	a2,0
    800014a2:	85a6                	mv	a1,s1
    800014a4:	855a                	mv	a0,s6
    800014a6:	b29ff0ef          	jal	80000fce <walk>
    800014aa:	d965                	beqz	a0,8000149a <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    800014ac:	00053983          	ld	s3,0(a0)
    800014b0:	0019f793          	andi	a5,s3,1
    800014b4:	d3fd                	beqz	a5,8000149a <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    800014b6:	ed0ff0ef          	jal	80000b86 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c11d                	beqz	a0,800014e2 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    800014be:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    800014c2:	8652                	mv	a2,s4
    800014c4:	05b2                	slli	a1,a1,0xc
    800014c6:	8d5ff0ef          	jal	80000d9a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014ca:	3ff9f713          	andi	a4,s3,1023
    800014ce:	86ca                	mv	a3,s2
    800014d0:	8652                	mv	a2,s4
    800014d2:	85a6                	mv	a1,s1
    800014d4:	855e                	mv	a0,s7
    800014d6:	bcdff0ef          	jal	800010a2 <mappages>
    800014da:	d161                	beqz	a0,8000149a <uvmcopy+0x24>
      kfree(mem);
    800014dc:	854a                	mv	a0,s2
    800014de:	d7eff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014e2:	4685                	li	a3,1
    800014e4:	00c4d613          	srli	a2,s1,0xc
    800014e8:	4581                	li	a1,0
    800014ea:	855e                	mv	a0,s7
    800014ec:	d85ff0ef          	jal	80001270 <uvmunmap>
  return -1;
    800014f0:	557d                	li	a0,-1
    800014f2:	a011                	j	800014f6 <uvmcopy+0x80>
  return 0;
    800014f4:	4501                	li	a0,0
}
    800014f6:	60a6                	ld	ra,72(sp)
    800014f8:	6406                	ld	s0,64(sp)
    800014fa:	74e2                	ld	s1,56(sp)
    800014fc:	7942                	ld	s2,48(sp)
    800014fe:	79a2                	ld	s3,40(sp)
    80001500:	7a02                	ld	s4,32(sp)
    80001502:	6ae2                	ld	s5,24(sp)
    80001504:	6b42                	ld	s6,16(sp)
    80001506:	6ba2                	ld	s7,8(sp)
    80001508:	6161                	addi	sp,sp,80
    8000150a:	8082                	ret
  return 0;
    8000150c:	4501                	li	a0,0
}
    8000150e:	8082                	ret

0000000080001510 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001510:	1141                	addi	sp,sp,-16
    80001512:	e406                	sd	ra,8(sp)
    80001514:	e022                	sd	s0,0(sp)
    80001516:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001518:	4601                	li	a2,0
    8000151a:	ab5ff0ef          	jal	80000fce <walk>
  if(pte == 0)
    8000151e:	c901                	beqz	a0,8000152e <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001520:	611c                	ld	a5,0(a0)
    80001522:	9bbd                	andi	a5,a5,-17
    80001524:	e11c                	sd	a5,0(a0)
}
    80001526:	60a2                	ld	ra,8(sp)
    80001528:	6402                	ld	s0,0(sp)
    8000152a:	0141                	addi	sp,sp,16
    8000152c:	8082                	ret
    panic("uvmclear");
    8000152e:	00006517          	auipc	a0,0x6
    80001532:	c1a50513          	addi	a0,a0,-998 # 80007148 <etext+0x148>
    80001536:	aeeff0ef          	jal	80000824 <panic>

000000008000153a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000153a:	cac5                	beqz	a3,800015ea <copyinstr+0xb0>
{
    8000153c:	715d                	addi	sp,sp,-80
    8000153e:	e486                	sd	ra,72(sp)
    80001540:	e0a2                	sd	s0,64(sp)
    80001542:	fc26                	sd	s1,56(sp)
    80001544:	f84a                	sd	s2,48(sp)
    80001546:	f44e                	sd	s3,40(sp)
    80001548:	f052                	sd	s4,32(sp)
    8000154a:	ec56                	sd	s5,24(sp)
    8000154c:	e85a                	sd	s6,16(sp)
    8000154e:	e45e                	sd	s7,8(sp)
    80001550:	0880                	addi	s0,sp,80
    80001552:	8aaa                	mv	s5,a0
    80001554:	84ae                	mv	s1,a1
    80001556:	8bb2                	mv	s7,a2
    80001558:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000155a:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000155c:	6a05                	lui	s4,0x1
    8000155e:	a82d                	j	80001598 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001560:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001564:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001566:	0017c793          	xori	a5,a5,1
    8000156a:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000156e:	60a6                	ld	ra,72(sp)
    80001570:	6406                	ld	s0,64(sp)
    80001572:	74e2                	ld	s1,56(sp)
    80001574:	7942                	ld	s2,48(sp)
    80001576:	79a2                	ld	s3,40(sp)
    80001578:	7a02                	ld	s4,32(sp)
    8000157a:	6ae2                	ld	s5,24(sp)
    8000157c:	6b42                	ld	s6,16(sp)
    8000157e:	6ba2                	ld	s7,8(sp)
    80001580:	6161                	addi	sp,sp,80
    80001582:	8082                	ret
    80001584:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001588:	9726                	add	a4,a4,s1
      --max;
    8000158a:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000158e:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001592:	04e58463          	beq	a1,a4,800015da <copyinstr+0xa0>
{
    80001596:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001598:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000159c:	85ca                	mv	a1,s2
    8000159e:	8556                	mv	a0,s5
    800015a0:	ac9ff0ef          	jal	80001068 <walkaddr>
    if(pa0 == 0)
    800015a4:	cd0d                	beqz	a0,800015de <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800015a6:	417906b3          	sub	a3,s2,s7
    800015aa:	96d2                	add	a3,a3,s4
    if(n > max)
    800015ac:	00d9f363          	bgeu	s3,a3,800015b2 <copyinstr+0x78>
    800015b0:	86ce                	mv	a3,s3
    while(n > 0){
    800015b2:	ca85                	beqz	a3,800015e2 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    800015b4:	01750633          	add	a2,a0,s7
    800015b8:	41260633          	sub	a2,a2,s2
    800015bc:	87a6                	mv	a5,s1
      if(*p == '\0'){
    800015be:	8e05                	sub	a2,a2,s1
    while(n > 0){
    800015c0:	96a6                	add	a3,a3,s1
    800015c2:	85be                	mv	a1,a5
      if(*p == '\0'){
    800015c4:	00f60733          	add	a4,a2,a5
    800015c8:	00074703          	lbu	a4,0(a4)
    800015cc:	db51                	beqz	a4,80001560 <copyinstr+0x26>
        *dst = *p;
    800015ce:	00e78023          	sb	a4,0(a5)
      dst++;
    800015d2:	0785                	addi	a5,a5,1
    while(n > 0){
    800015d4:	fed797e3          	bne	a5,a3,800015c2 <copyinstr+0x88>
    800015d8:	b775                	j	80001584 <copyinstr+0x4a>
    800015da:	4781                	li	a5,0
    800015dc:	b769                	j	80001566 <copyinstr+0x2c>
      return -1;
    800015de:	557d                	li	a0,-1
    800015e0:	b779                	j	8000156e <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015e2:	6b85                	lui	s7,0x1
    800015e4:	9bca                	add	s7,s7,s2
    800015e6:	87a6                	mv	a5,s1
    800015e8:	b77d                	j	80001596 <copyinstr+0x5c>
  int got_null = 0;
    800015ea:	4781                	li	a5,0
  if(got_null){
    800015ec:	0017c793          	xori	a5,a5,1
    800015f0:	40f0053b          	negw	a0,a5
}
    800015f4:	8082                	ret

00000000800015f6 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015f6:	1141                	addi	sp,sp,-16
    800015f8:	e406                	sd	ra,8(sp)
    800015fa:	e022                	sd	s0,0(sp)
    800015fc:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015fe:	4601                	li	a2,0
    80001600:	9cfff0ef          	jal	80000fce <walk>
  if (pte == 0) {
    80001604:	c119                	beqz	a0,8000160a <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    80001606:	6108                	ld	a0,0(a0)
    80001608:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    8000160a:	60a2                	ld	ra,8(sp)
    8000160c:	6402                	ld	s0,0(sp)
    8000160e:	0141                	addi	sp,sp,16
    80001610:	8082                	ret

0000000080001612 <vmfault>:
{
    80001612:	7179                	addi	sp,sp,-48
    80001614:	f406                	sd	ra,40(sp)
    80001616:	f022                	sd	s0,32(sp)
    80001618:	e84a                	sd	s2,16(sp)
    8000161a:	e44e                	sd	s3,8(sp)
    8000161c:	1800                	addi	s0,sp,48
    8000161e:	89aa                	mv	s3,a0
    80001620:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001622:	342000ef          	jal	80001964 <myproc>
  if (va >= p->sz)
    80001626:	753c                	ld	a5,104(a0)
    80001628:	00f96a63          	bltu	s2,a5,8000163c <vmfault+0x2a>
    return 0;
    8000162c:	4981                	li	s3,0
}
    8000162e:	854e                	mv	a0,s3
    80001630:	70a2                	ld	ra,40(sp)
    80001632:	7402                	ld	s0,32(sp)
    80001634:	6942                	ld	s2,16(sp)
    80001636:	69a2                	ld	s3,8(sp)
    80001638:	6145                	addi	sp,sp,48
    8000163a:	8082                	ret
    8000163c:	ec26                	sd	s1,24(sp)
    8000163e:	e052                	sd	s4,0(sp)
    80001640:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001642:	77fd                	lui	a5,0xfffff
    80001644:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    80001648:	85d2                	mv	a1,s4
    8000164a:	854e                	mv	a0,s3
    8000164c:	fabff0ef          	jal	800015f6 <ismapped>
    return 0;
    80001650:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001652:	c501                	beqz	a0,8000165a <vmfault+0x48>
    80001654:	64e2                	ld	s1,24(sp)
    80001656:	6a02                	ld	s4,0(sp)
    80001658:	bfd9                	j	8000162e <vmfault+0x1c>
  mem = (uint64) kalloc();
    8000165a:	d2cff0ef          	jal	80000b86 <kalloc>
    8000165e:	892a                	mv	s2,a0
  if(mem == 0)
    80001660:	c905                	beqz	a0,80001690 <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001662:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001664:	6605                	lui	a2,0x1
    80001666:	4581                	li	a1,0
    80001668:	ed2ff0ef          	jal	80000d3a <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000166c:	4759                	li	a4,22
    8000166e:	86ca                	mv	a3,s2
    80001670:	6605                	lui	a2,0x1
    80001672:	85d2                	mv	a1,s4
    80001674:	78a8                	ld	a0,112(s1)
    80001676:	a2dff0ef          	jal	800010a2 <mappages>
    8000167a:	e501                	bnez	a0,80001682 <vmfault+0x70>
    8000167c:	64e2                	ld	s1,24(sp)
    8000167e:	6a02                	ld	s4,0(sp)
    80001680:	b77d                	j	8000162e <vmfault+0x1c>
    kfree((void *)mem);
    80001682:	854a                	mv	a0,s2
    80001684:	bd8ff0ef          	jal	80000a5c <kfree>
    return 0;
    80001688:	4981                	li	s3,0
    8000168a:	64e2                	ld	s1,24(sp)
    8000168c:	6a02                	ld	s4,0(sp)
    8000168e:	b745                	j	8000162e <vmfault+0x1c>
    80001690:	64e2                	ld	s1,24(sp)
    80001692:	6a02                	ld	s4,0(sp)
    80001694:	bf69                	j	8000162e <vmfault+0x1c>

0000000080001696 <copyout>:
  while(len > 0){
    80001696:	cad1                	beqz	a3,8000172a <copyout+0x94>
{
    80001698:	711d                	addi	sp,sp,-96
    8000169a:	ec86                	sd	ra,88(sp)
    8000169c:	e8a2                	sd	s0,80(sp)
    8000169e:	e4a6                	sd	s1,72(sp)
    800016a0:	e0ca                	sd	s2,64(sp)
    800016a2:	fc4e                	sd	s3,56(sp)
    800016a4:	f852                	sd	s4,48(sp)
    800016a6:	f456                	sd	s5,40(sp)
    800016a8:	f05a                	sd	s6,32(sp)
    800016aa:	ec5e                	sd	s7,24(sp)
    800016ac:	e862                	sd	s8,16(sp)
    800016ae:	e466                	sd	s9,8(sp)
    800016b0:	e06a                	sd	s10,0(sp)
    800016b2:	1080                	addi	s0,sp,96
    800016b4:	8baa                	mv	s7,a0
    800016b6:	8a2e                	mv	s4,a1
    800016b8:	8b32                	mv	s6,a2
    800016ba:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800016bc:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    800016be:	5cfd                	li	s9,-1
    800016c0:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    800016c4:	6c05                	lui	s8,0x1
    800016c6:	a005                	j	800016e6 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016c8:	409a0533          	sub	a0,s4,s1
    800016cc:	0009061b          	sext.w	a2,s2
    800016d0:	85da                	mv	a1,s6
    800016d2:	954e                	add	a0,a0,s3
    800016d4:	ec6ff0ef          	jal	80000d9a <memmove>
    len -= n;
    800016d8:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800016dc:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800016de:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016e2:	040a8263          	beqz	s5,80001726 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016e6:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016ea:	049ce263          	bltu	s9,s1,8000172e <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016ee:	85a6                	mv	a1,s1
    800016f0:	855e                	mv	a0,s7
    800016f2:	977ff0ef          	jal	80001068 <walkaddr>
    800016f6:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016f8:	e901                	bnez	a0,80001708 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016fa:	4601                	li	a2,0
    800016fc:	85a6                	mv	a1,s1
    800016fe:	855e                	mv	a0,s7
    80001700:	f13ff0ef          	jal	80001612 <vmfault>
    80001704:	89aa                	mv	s3,a0
    80001706:	c139                	beqz	a0,8000174c <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    80001708:	4601                	li	a2,0
    8000170a:	85a6                	mv	a1,s1
    8000170c:	855e                	mv	a0,s7
    8000170e:	8c1ff0ef          	jal	80000fce <walk>
    if((*pte & PTE_W) == 0)
    80001712:	611c                	ld	a5,0(a0)
    80001714:	8b91                	andi	a5,a5,4
    80001716:	cf8d                	beqz	a5,80001750 <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    80001718:	41448933          	sub	s2,s1,s4
    8000171c:	9962                	add	s2,s2,s8
    if(n > len)
    8000171e:	fb2af5e3          	bgeu	s5,s2,800016c8 <copyout+0x32>
    80001722:	8956                	mv	s2,s5
    80001724:	b755                	j	800016c8 <copyout+0x32>
  return 0;
    80001726:	4501                	li	a0,0
    80001728:	a021                	j	80001730 <copyout+0x9a>
    8000172a:	4501                	li	a0,0
}
    8000172c:	8082                	ret
      return -1;
    8000172e:	557d                	li	a0,-1
}
    80001730:	60e6                	ld	ra,88(sp)
    80001732:	6446                	ld	s0,80(sp)
    80001734:	64a6                	ld	s1,72(sp)
    80001736:	6906                	ld	s2,64(sp)
    80001738:	79e2                	ld	s3,56(sp)
    8000173a:	7a42                	ld	s4,48(sp)
    8000173c:	7aa2                	ld	s5,40(sp)
    8000173e:	7b02                	ld	s6,32(sp)
    80001740:	6be2                	ld	s7,24(sp)
    80001742:	6c42                	ld	s8,16(sp)
    80001744:	6ca2                	ld	s9,8(sp)
    80001746:	6d02                	ld	s10,0(sp)
    80001748:	6125                	addi	sp,sp,96
    8000174a:	8082                	ret
        return -1;
    8000174c:	557d                	li	a0,-1
    8000174e:	b7cd                	j	80001730 <copyout+0x9a>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	bff9                	j	80001730 <copyout+0x9a>

0000000080001754 <copyin>:
  while(len > 0){
    80001754:	c6c9                	beqz	a3,800017de <copyin+0x8a>
{
    80001756:	715d                	addi	sp,sp,-80
    80001758:	e486                	sd	ra,72(sp)
    8000175a:	e0a2                	sd	s0,64(sp)
    8000175c:	fc26                	sd	s1,56(sp)
    8000175e:	f84a                	sd	s2,48(sp)
    80001760:	f44e                	sd	s3,40(sp)
    80001762:	f052                	sd	s4,32(sp)
    80001764:	ec56                	sd	s5,24(sp)
    80001766:	e85a                	sd	s6,16(sp)
    80001768:	e45e                	sd	s7,8(sp)
    8000176a:	e062                	sd	s8,0(sp)
    8000176c:	0880                	addi	s0,sp,80
    8000176e:	8baa                	mv	s7,a0
    80001770:	8aae                	mv	s5,a1
    80001772:	8932                	mv	s2,a2
    80001774:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001776:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001778:	6b05                	lui	s6,0x1
    8000177a:	a035                	j	800017a6 <copyin+0x52>
    8000177c:	412984b3          	sub	s1,s3,s2
    80001780:	94da                	add	s1,s1,s6
    if(n > len)
    80001782:	009a7363          	bgeu	s4,s1,80001788 <copyin+0x34>
    80001786:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001788:	413905b3          	sub	a1,s2,s3
    8000178c:	0004861b          	sext.w	a2,s1
    80001790:	95aa                	add	a1,a1,a0
    80001792:	8556                	mv	a0,s5
    80001794:	e06ff0ef          	jal	80000d9a <memmove>
    len -= n;
    80001798:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000179c:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000179e:	01698933          	add	s2,s3,s6
  while(len > 0){
    800017a2:	020a0163          	beqz	s4,800017c4 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    800017a6:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800017aa:	85ce                	mv	a1,s3
    800017ac:	855e                	mv	a0,s7
    800017ae:	8bbff0ef          	jal	80001068 <walkaddr>
    if(pa0 == 0) {
    800017b2:	f569                	bnez	a0,8000177c <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800017b4:	4601                	li	a2,0
    800017b6:	85ce                	mv	a1,s3
    800017b8:	855e                	mv	a0,s7
    800017ba:	e59ff0ef          	jal	80001612 <vmfault>
    800017be:	fd5d                	bnez	a0,8000177c <copyin+0x28>
        return -1;
    800017c0:	557d                	li	a0,-1
    800017c2:	a011                	j	800017c6 <copyin+0x72>
  return 0;
    800017c4:	4501                	li	a0,0
}
    800017c6:	60a6                	ld	ra,72(sp)
    800017c8:	6406                	ld	s0,64(sp)
    800017ca:	74e2                	ld	s1,56(sp)
    800017cc:	7942                	ld	s2,48(sp)
    800017ce:	79a2                	ld	s3,40(sp)
    800017d0:	7a02                	ld	s4,32(sp)
    800017d2:	6ae2                	ld	s5,24(sp)
    800017d4:	6b42                	ld	s6,16(sp)
    800017d6:	6ba2                	ld	s7,8(sp)
    800017d8:	6c02                	ld	s8,0(sp)
    800017da:	6161                	addi	sp,sp,80
    800017dc:	8082                	ret
  return 0;
    800017de:	4501                	li	a0,0
}
    800017e0:	8082                	ret

00000000800017e2 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017e2:	715d                	addi	sp,sp,-80
    800017e4:	e486                	sd	ra,72(sp)
    800017e6:	e0a2                	sd	s0,64(sp)
    800017e8:	fc26                	sd	s1,56(sp)
    800017ea:	f84a                	sd	s2,48(sp)
    800017ec:	f44e                	sd	s3,40(sp)
    800017ee:	f052                	sd	s4,32(sp)
    800017f0:	ec56                	sd	s5,24(sp)
    800017f2:	e85a                	sd	s6,16(sp)
    800017f4:	e45e                	sd	s7,8(sp)
    800017f6:	e062                	sd	s8,0(sp)
    800017f8:	0880                	addi	s0,sp,80
    800017fa:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017fc:	0000e497          	auipc	s1,0xe
    80001800:	72c48493          	addi	s1,s1,1836 # 8000ff28 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001804:	8c26                	mv	s8,s1
    80001806:	1a1f67b7          	lui	a5,0x1a1f6
    8000180a:	8d178793          	addi	a5,a5,-1839 # 1a1f58d1 <_entry-0x65e0a72f>
    8000180e:	7d634937          	lui	s2,0x7d634
    80001812:	3eb90913          	addi	s2,s2,1003 # 7d6343eb <_entry-0x29cbc15>
    80001816:	1902                	slli	s2,s2,0x20
    80001818:	993e                	add	s2,s2,a5
    8000181a:	040009b7          	lui	s3,0x4000
    8000181e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001820:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001822:	4b99                	li	s7,6
    80001824:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001826:	00015a97          	auipc	s5,0x15
    8000182a:	902a8a93          	addi	s5,s5,-1790 # 80016128 <tickslock>
    char *pa = kalloc();
    8000182e:	b58ff0ef          	jal	80000b86 <kalloc>
    80001832:	862a                	mv	a2,a0
    if(pa == 0)
    80001834:	c121                	beqz	a0,80001874 <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    80001836:	418485b3          	sub	a1,s1,s8
    8000183a:	858d                	srai	a1,a1,0x3
    8000183c:	032585b3          	mul	a1,a1,s2
    80001840:	05b6                	slli	a1,a1,0xd
    80001842:	6789                	lui	a5,0x2
    80001844:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001846:	875e                	mv	a4,s7
    80001848:	86da                	mv	a3,s6
    8000184a:	40b985b3          	sub	a1,s3,a1
    8000184e:	8552                	mv	a0,s4
    80001850:	909ff0ef          	jal	80001158 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	18848493          	addi	s1,s1,392
    80001858:	fd549be3          	bne	s1,s5,8000182e <proc_mapstacks+0x4c>
  }
}
    8000185c:	60a6                	ld	ra,72(sp)
    8000185e:	6406                	ld	s0,64(sp)
    80001860:	74e2                	ld	s1,56(sp)
    80001862:	7942                	ld	s2,48(sp)
    80001864:	79a2                	ld	s3,40(sp)
    80001866:	7a02                	ld	s4,32(sp)
    80001868:	6ae2                	ld	s5,24(sp)
    8000186a:	6b42                	ld	s6,16(sp)
    8000186c:	6ba2                	ld	s7,8(sp)
    8000186e:	6c02                	ld	s8,0(sp)
    80001870:	6161                	addi	sp,sp,80
    80001872:	8082                	ret
      panic("kalloc");
    80001874:	00006517          	auipc	a0,0x6
    80001878:	8e450513          	addi	a0,a0,-1820 # 80007158 <etext+0x158>
    8000187c:	fa9fe0ef          	jal	80000824 <panic>

0000000080001880 <procinit>:

// initialize the proc table.
// 페이지 테이블 초기화 
void
procinit(void)
{
    80001880:	7139                	addi	sp,sp,-64
    80001882:	fc06                	sd	ra,56(sp)
    80001884:	f822                	sd	s0,48(sp)
    80001886:	f426                	sd	s1,40(sp)
    80001888:	f04a                	sd	s2,32(sp)
    8000188a:	ec4e                	sd	s3,24(sp)
    8000188c:	e852                	sd	s4,16(sp)
    8000188e:	e456                	sd	s5,8(sp)
    80001890:	e05a                	sd	s6,0(sp)
    80001892:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001894:	00006597          	auipc	a1,0x6
    80001898:	8cc58593          	addi	a1,a1,-1844 # 80007160 <etext+0x160>
    8000189c:	0000e517          	auipc	a0,0xe
    800018a0:	24450513          	addi	a0,a0,580 # 8000fae0 <pid_lock>
    800018a4:	b3cff0ef          	jal	80000be0 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018a8:	00006597          	auipc	a1,0x6
    800018ac:	8c058593          	addi	a1,a1,-1856 # 80007168 <etext+0x168>
    800018b0:	0000e517          	auipc	a0,0xe
    800018b4:	24850513          	addi	a0,a0,584 # 8000faf8 <wait_lock>
    800018b8:	b28ff0ef          	jal	80000be0 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018bc:	0000e497          	auipc	s1,0xe
    800018c0:	66c48493          	addi	s1,s1,1644 # 8000ff28 <proc>
      initlock(&p->lock, "proc");
    800018c4:	00006b17          	auipc	s6,0x6
    800018c8:	8b4b0b13          	addi	s6,s6,-1868 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800018cc:	8aa6                	mv	s5,s1
    800018ce:	1a1f67b7          	lui	a5,0x1a1f6
    800018d2:	8d178793          	addi	a5,a5,-1839 # 1a1f58d1 <_entry-0x65e0a72f>
    800018d6:	7d634937          	lui	s2,0x7d634
    800018da:	3eb90913          	addi	s2,s2,1003 # 7d6343eb <_entry-0x29cbc15>
    800018de:	1902                	slli	s2,s2,0x20
    800018e0:	993e                	add	s2,s2,a5
    800018e2:	040009b7          	lui	s3,0x4000
    800018e6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018e8:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ea:	00015a17          	auipc	s4,0x15
    800018ee:	83ea0a13          	addi	s4,s4,-1986 # 80016128 <tickslock>
      initlock(&p->lock, "proc");
    800018f2:	85da                	mv	a1,s6
    800018f4:	8526                	mv	a0,s1
    800018f6:	aeaff0ef          	jal	80000be0 <initlock>
      p->state = UNUSED;
    800018fa:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018fe:	415487b3          	sub	a5,s1,s5
    80001902:	878d                	srai	a5,a5,0x3
    80001904:	032787b3          	mul	a5,a5,s2
    80001908:	07b6                	slli	a5,a5,0xd
    8000190a:	6709                	lui	a4,0x2
    8000190c:	9fb9                	addw	a5,a5,a4
    8000190e:	40f987b3          	sub	a5,s3,a5
    80001912:	f0bc                	sd	a5,96(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001914:	18848493          	addi	s1,s1,392
    80001918:	fd449de3          	bne	s1,s4,800018f2 <procinit+0x72>
  }
}
    8000191c:	70e2                	ld	ra,56(sp)
    8000191e:	7442                	ld	s0,48(sp)
    80001920:	74a2                	ld	s1,40(sp)
    80001922:	7902                	ld	s2,32(sp)
    80001924:	69e2                	ld	s3,24(sp)
    80001926:	6a42                	ld	s4,16(sp)
    80001928:	6aa2                	ld	s5,8(sp)
    8000192a:	6b02                	ld	s6,0(sp)
    8000192c:	6121                	addi	sp,sp,64
    8000192e:	8082                	ret

0000000080001930 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001930:	1141                	addi	sp,sp,-16
    80001932:	e406                	sd	ra,8(sp)
    80001934:	e022                	sd	s0,0(sp)
    80001936:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001938:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000193a:	2501                	sext.w	a0,a0
    8000193c:	60a2                	ld	ra,8(sp)
    8000193e:	6402                	ld	s0,0(sp)
    80001940:	0141                	addi	sp,sp,16
    80001942:	8082                	ret

0000000080001944 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001944:	1141                	addi	sp,sp,-16
    80001946:	e406                	sd	ra,8(sp)
    80001948:	e022                	sd	s0,0(sp)
    8000194a:	0800                	addi	s0,sp,16
    8000194c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000194e:	2781                	sext.w	a5,a5
    80001950:	079e                	slli	a5,a5,0x7
  return c;
}
    80001952:	0000e517          	auipc	a0,0xe
    80001956:	1be50513          	addi	a0,a0,446 # 8000fb10 <cpus>
    8000195a:	953e                	add	a0,a0,a5
    8000195c:	60a2                	ld	ra,8(sp)
    8000195e:	6402                	ld	s0,0(sp)
    80001960:	0141                	addi	sp,sp,16
    80001962:	8082                	ret

0000000080001964 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001964:	1101                	addi	sp,sp,-32
    80001966:	ec06                	sd	ra,24(sp)
    80001968:	e822                	sd	s0,16(sp)
    8000196a:	e426                	sd	s1,8(sp)
    8000196c:	1000                	addi	s0,sp,32
  push_off();
    8000196e:	ab8ff0ef          	jal	80000c26 <push_off>
    80001972:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001974:	2781                	sext.w	a5,a5
    80001976:	079e                	slli	a5,a5,0x7
    80001978:	0000e717          	auipc	a4,0xe
    8000197c:	16870713          	addi	a4,a4,360 # 8000fae0 <pid_lock>
    80001980:	97ba                	add	a5,a5,a4
    80001982:	7b9c                	ld	a5,48(a5)
    80001984:	84be                	mv	s1,a5
  pop_off();
    80001986:	b28ff0ef          	jal	80000cae <pop_off>
  return p;
}
    8000198a:	8526                	mv	a0,s1
    8000198c:	60e2                	ld	ra,24(sp)
    8000198e:	6442                	ld	s0,16(sp)
    80001990:	64a2                	ld	s1,8(sp)
    80001992:	6105                	addi	sp,sp,32
    80001994:	8082                	ret

0000000080001996 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001996:	7179                	addi	sp,sp,-48
    80001998:	f406                	sd	ra,40(sp)
    8000199a:	f022                	sd	s0,32(sp)
    8000199c:	ec26                	sd	s1,24(sp)
    8000199e:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019a0:	fc5ff0ef          	jal	80001964 <myproc>
    800019a4:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  // panic:release : scheduler 수정했기 때문에 acquire이 없어짐 -> release 하면 오류-> 주석 처리
  //  release(&p->lock);

  if (first) {
    800019a6:	00006797          	auipc	a5,0x6
    800019aa:	f5a7a783          	lw	a5,-166(a5) # 80007900 <first.1>
    800019ae:	cf95                	beqz	a5,800019ea <forkret+0x54>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019b0:	4505                	li	a0,1
    800019b2:	0d0020ef          	jal	80003a82 <fsinit>

    first = 0;
    800019b6:	00006797          	auipc	a5,0x6
    800019ba:	f407a523          	sw	zero,-182(a5) # 80007900 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    800019be:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    800019c2:	00005797          	auipc	a5,0x5
    800019c6:	7be78793          	addi	a5,a5,1982 # 80007180 <etext+0x180>
    800019ca:	fcf43823          	sd	a5,-48(s0)
    800019ce:	fc043c23          	sd	zero,-40(s0)
    800019d2:	fd040593          	addi	a1,s0,-48
    800019d6:	853e                	mv	a0,a5
    800019d8:	228030ef          	jal	80004c00 <kexec>
    800019dc:	7cbc                	ld	a5,120(s1)
    800019de:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019e0:	7cbc                	ld	a5,120(s1)
    800019e2:	7bb8                	ld	a4,112(a5)
    800019e4:	57fd                	li	a5,-1
    800019e6:	02f70d63          	beq	a4,a5,80001a20 <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019ea:	72d000ef          	jal	80002916 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019ee:	78a8                	ld	a0,112(s1)
    800019f0:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019f2:	04000737          	lui	a4,0x4000
    800019f6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	0732                	slli	a4,a4,0xc
    800019fa:	00004797          	auipc	a5,0x4
    800019fe:	6a278793          	addi	a5,a5,1698 # 8000609c <userret>
    80001a02:	00004697          	auipc	a3,0x4
    80001a06:	5fe68693          	addi	a3,a3,1534 # 80006000 <_trampoline>
    80001a0a:	8f95                	sub	a5,a5,a3
    80001a0c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a0e:	577d                	li	a4,-1
    80001a10:	177e                	slli	a4,a4,0x3f
    80001a12:	8d59                	or	a0,a0,a4
    80001a14:	9782                	jalr	a5
}
    80001a16:	70a2                	ld	ra,40(sp)
    80001a18:	7402                	ld	s0,32(sp)
    80001a1a:	64e2                	ld	s1,24(sp)
    80001a1c:	6145                	addi	sp,sp,48
    80001a1e:	8082                	ret
      panic("exec");
    80001a20:	00005517          	auipc	a0,0x5
    80001a24:	76850513          	addi	a0,a0,1896 # 80007188 <etext+0x188>
    80001a28:	dfdfe0ef          	jal	80000824 <panic>

0000000080001a2c <allocpid>:
{
    80001a2c:	1101                	addi	sp,sp,-32
    80001a2e:	ec06                	sd	ra,24(sp)
    80001a30:	e822                	sd	s0,16(sp)
    80001a32:	e426                	sd	s1,8(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000e517          	auipc	a0,0xe
    80001a3a:	0aa50513          	addi	a0,a0,170 # 8000fae0 <pid_lock>
    80001a3e:	a2cff0ef          	jal	80000c6a <acquire>
  pid = nextpid;
    80001a42:	00006797          	auipc	a5,0x6
    80001a46:	ec278793          	addi	a5,a5,-318 # 80007904 <nextpid>
    80001a4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a4c:	0014871b          	addiw	a4,s1,1
    80001a50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a52:	0000e517          	auipc	a0,0xe
    80001a56:	08e50513          	addi	a0,a0,142 # 8000fae0 <pid_lock>
    80001a5a:	aa4ff0ef          	jal	80000cfe <release>
}
    80001a5e:	8526                	mv	a0,s1
    80001a60:	60e2                	ld	ra,24(sp)
    80001a62:	6442                	ld	s0,16(sp)
    80001a64:	64a2                	ld	s1,8(sp)
    80001a66:	6105                	addi	sp,sp,32
    80001a68:	8082                	ret

0000000080001a6a <proc_pagetable>:
{
    80001a6a:	1101                	addi	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	addi	s0,sp,32
    80001a76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a78:	fd2ff0ef          	jal	8000124a <uvmcreate>
    80001a7c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a7e:	cd05                	beqz	a0,80001ab6 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a80:	4729                	li	a4,10
    80001a82:	00004697          	auipc	a3,0x4
    80001a86:	57e68693          	addi	a3,a3,1406 # 80006000 <_trampoline>
    80001a8a:	6605                	lui	a2,0x1
    80001a8c:	040005b7          	lui	a1,0x4000
    80001a90:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a92:	05b2                	slli	a1,a1,0xc
    80001a94:	e0eff0ef          	jal	800010a2 <mappages>
    80001a98:	02054663          	bltz	a0,80001ac4 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a9c:	4719                	li	a4,6
    80001a9e:	07893683          	ld	a3,120(s2)
    80001aa2:	6605                	lui	a2,0x1
    80001aa4:	020005b7          	lui	a1,0x2000
    80001aa8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aaa:	05b6                	slli	a1,a1,0xd
    80001aac:	8526                	mv	a0,s1
    80001aae:	df4ff0ef          	jal	800010a2 <mappages>
    80001ab2:	00054f63          	bltz	a0,80001ad0 <proc_pagetable+0x66>
}
    80001ab6:	8526                	mv	a0,s1
    80001ab8:	60e2                	ld	ra,24(sp)
    80001aba:	6442                	ld	s0,16(sp)
    80001abc:	64a2                	ld	s1,8(sp)
    80001abe:	6902                	ld	s2,0(sp)
    80001ac0:	6105                	addi	sp,sp,32
    80001ac2:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac4:	4581                	li	a1,0
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	97dff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001acc:	4481                	li	s1,0
    80001ace:	b7e5                	j	80001ab6 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad0:	4681                	li	a3,0
    80001ad2:	4605                	li	a2,1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	8526                	mv	a0,s1
    80001ade:	f92ff0ef          	jal	80001270 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ae2:	4581                	li	a1,0
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	95fff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001aea:	4481                	li	s1,0
    80001aec:	b7e9                	j	80001ab6 <proc_pagetable+0x4c>

0000000080001aee <allocproc>:
{
    80001aee:	1101                	addi	sp,sp,-32
    80001af0:	ec06                	sd	ra,24(sp)
    80001af2:	e822                	sd	s0,16(sp)
    80001af4:	e426                	sd	s1,8(sp)
    80001af6:	e04a                	sd	s2,0(sp)
    80001af8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001afa:	0000e497          	auipc	s1,0xe
    80001afe:	42e48493          	addi	s1,s1,1070 # 8000ff28 <proc>
    80001b02:	00014917          	auipc	s2,0x14
    80001b06:	62690913          	addi	s2,s2,1574 # 80016128 <tickslock>
    acquire(&p->lock);
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	95eff0ef          	jal	80000c6a <acquire>
    if(p->state == UNUSED) {
    80001b10:	4c9c                	lw	a5,24(s1)
    80001b12:	cb91                	beqz	a5,80001b26 <allocproc+0x38>
      release(&p->lock);
    80001b14:	8526                	mv	a0,s1
    80001b16:	9e8ff0ef          	jal	80000cfe <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b1a:	18848493          	addi	s1,s1,392
    80001b1e:	ff2496e3          	bne	s1,s2,80001b0a <allocproc+0x1c>
  return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	a09d                	j	80001b8a <allocproc+0x9c>
  p->pid = allocpid();
    80001b26:	f07ff0ef          	jal	80001a2c <allocpid>
    80001b2a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b2c:	4705                	li	a4,1
    80001b2e:	cc98                	sw	a4,24(s1)
  p->priority = 20; 		// initialize the priority value as 20 (우선순위 값 초기화)
    80001b30:	47d1                	li	a5,20
    80001b32:	d8dc                	sw	a5,52(s1)
  p->weight = weight[20];	// initialize the weight as 1024 (가중치 초기화)
    80001b34:	00006797          	auipc	a5,0x6
    80001b38:	e2c7a783          	lw	a5,-468(a5) # 80007960 <weight+0x50>
    80001b3c:	dc9c                	sw	a5,56(s1)
  p->runtime = 0;		// 일단 실제 실행 시간은 0
    80001b3e:	0204ae23          	sw	zero,60(s1)
  p->vruntime = 0;		// 초기화는 0
    80001b42:	0404b023          	sd	zero,64(s1)
  p->vdeadline = 5000;	// 초기화는 5000
    80001b46:	6785                	lui	a5,0x1
    80001b48:	38878793          	addi	a5,a5,904 # 1388 <_entry-0x7fffec78>
    80001b4c:	e4bc                	sd	a5,72(s1)
  p->is_eligible = 1;		// 초기화는 true
    80001b4e:	c8b8                	sw	a4,80(s1)
  p->remain_time = 5;		// remain_time은 5로 초기화
    80001b50:	4795                	li	a5,5
    80001b52:	c8fc                	sw	a5,84(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b54:	832ff0ef          	jal	80000b86 <kalloc>
    80001b58:	892a                	mv	s2,a0
    80001b5a:	fca8                	sd	a0,120(s1)
    80001b5c:	cd15                	beqz	a0,80001b98 <allocproc+0xaa>
  p->pagetable = proc_pagetable(p);
    80001b5e:	8526                	mv	a0,s1
    80001b60:	f0bff0ef          	jal	80001a6a <proc_pagetable>
    80001b64:	892a                	mv	s2,a0
    80001b66:	f8a8                	sd	a0,112(s1)
  if(p->pagetable == 0){
    80001b68:	cd1d                	beqz	a0,80001ba6 <allocproc+0xb8>
  memset(&p->context, 0, sizeof(p->context));
    80001b6a:	07000613          	li	a2,112
    80001b6e:	4581                	li	a1,0
    80001b70:	08048513          	addi	a0,s1,128
    80001b74:	9c6ff0ef          	jal	80000d3a <memset>
  p->context.ra = (uint64)forkret;
    80001b78:	00000797          	auipc	a5,0x0
    80001b7c:	e1e78793          	addi	a5,a5,-482 # 80001996 <forkret>
    80001b80:	e0dc                	sd	a5,128(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b82:	70bc                	ld	a5,96(s1)
    80001b84:	6705                	lui	a4,0x1
    80001b86:	97ba                	add	a5,a5,a4
    80001b88:	e4dc                	sd	a5,136(s1)
}
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	60e2                	ld	ra,24(sp)
    80001b8e:	6442                	ld	s0,16(sp)
    80001b90:	64a2                	ld	s1,8(sp)
    80001b92:	6902                	ld	s2,0(sp)
    80001b94:	6105                	addi	sp,sp,32
    80001b96:	8082                	ret
    p->state = UNUSED;
    80001b98:	0004ac23          	sw	zero,24(s1)
    release(&p->lock);
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	960ff0ef          	jal	80000cfe <release>
    return 0;
    80001ba2:	84ca                	mv	s1,s2
    80001ba4:	b7dd                	j	80001b8a <allocproc+0x9c>
    kfree(p->trapframe);
    80001ba6:	7ca8                	ld	a0,120(s1)
    80001ba8:	eb5fe0ef          	jal	80000a5c <kfree>
    p->trapframe = 0;
    80001bac:	0604bc23          	sd	zero,120(s1)
    p->state = UNUSED;
    80001bb0:	0004ac23          	sw	zero,24(s1)
    release(&p->lock);
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	948ff0ef          	jal	80000cfe <release>
    return 0;
    80001bba:	84ca                	mv	s1,s2
    80001bbc:	b7f9                	j	80001b8a <allocproc+0x9c>

0000000080001bbe <proc_freepagetable>:
{
    80001bbe:	1101                	addi	sp,sp,-32
    80001bc0:	ec06                	sd	ra,24(sp)
    80001bc2:	e822                	sd	s0,16(sp)
    80001bc4:	e426                	sd	s1,8(sp)
    80001bc6:	e04a                	sd	s2,0(sp)
    80001bc8:	1000                	addi	s0,sp,32
    80001bca:	84aa                	mv	s1,a0
    80001bcc:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	040005b7          	lui	a1,0x4000
    80001bd6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bd8:	05b2                	slli	a1,a1,0xc
    80001bda:	e96ff0ef          	jal	80001270 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bde:	4681                	li	a3,0
    80001be0:	4605                	li	a2,1
    80001be2:	020005b7          	lui	a1,0x2000
    80001be6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001be8:	05b6                	slli	a1,a1,0xd
    80001bea:	8526                	mv	a0,s1
    80001bec:	e84ff0ef          	jal	80001270 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bf0:	85ca                	mv	a1,s2
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	851ff0ef          	jal	80001444 <uvmfree>
}
    80001bf8:	60e2                	ld	ra,24(sp)
    80001bfa:	6442                	ld	s0,16(sp)
    80001bfc:	64a2                	ld	s1,8(sp)
    80001bfe:	6902                	ld	s2,0(sp)
    80001c00:	6105                	addi	sp,sp,32
    80001c02:	8082                	ret

0000000080001c04 <freeproc>:
{
    80001c04:	1101                	addi	sp,sp,-32
    80001c06:	ec06                	sd	ra,24(sp)
    80001c08:	e822                	sd	s0,16(sp)
    80001c0a:	e426                	sd	s1,8(sp)
    80001c0c:	1000                	addi	s0,sp,32
    80001c0e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c10:	7d28                	ld	a0,120(a0)
    80001c12:	c119                	beqz	a0,80001c18 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001c14:	e49fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001c18:	0604bc23          	sd	zero,120(s1)
  if(p->pagetable)
    80001c1c:	78a8                	ld	a0,112(s1)
    80001c1e:	c501                	beqz	a0,80001c26 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001c20:	74ac                	ld	a1,104(s1)
    80001c22:	f9dff0ef          	jal	80001bbe <proc_freepagetable>
  p->pagetable = 0;
    80001c26:	0604b823          	sd	zero,112(s1)
  p->sz = 0;
    80001c2a:	0604b423          	sd	zero,104(s1)
  p->pid = 0;
    80001c2e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c32:	0404bc23          	sd	zero,88(s1)
  p->name[0] = 0;
    80001c36:	16048c23          	sb	zero,376(s1)
  p->chan = 0;
    80001c3a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c3e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c42:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <freemem>:
{
    80001c54:	1141                	addi	sp,sp,-16
    80001c56:	e406                	sd	ra,8(sp)
    80001c58:	e022                	sd	s0,0(sp)
    80001c5a:	0800                	addi	s0,sp,16
	return freememinfo();
    80001c5c:	ef3fe0ef          	jal	80000b4e <freememinfo>
}
    80001c60:	60a2                	ld	ra,8(sp)
    80001c62:	6402                	ld	s0,0(sp)
    80001c64:	0141                	addi	sp,sp,16
    80001c66:	8082                	ret

0000000080001c68 <userinit>:
{
    80001c68:	1101                	addi	sp,sp,-32
    80001c6a:	ec06                	sd	ra,24(sp)
    80001c6c:	e822                	sd	s0,16(sp)
    80001c6e:	e426                	sd	s1,8(sp)
    80001c70:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c72:	e7dff0ef          	jal	80001aee <allocproc>
    80001c76:	84aa                	mv	s1,a0
  initproc = p;
    80001c78:	00006797          	auipc	a5,0x6
    80001c7c:	d4a7bc23          	sd	a0,-680(a5) # 800079d0 <initproc>
  p->cwd = namei("/");
    80001c80:	00005517          	auipc	a0,0x5
    80001c84:	51050513          	addi	a0,a0,1296 # 80007190 <etext+0x190>
    80001c88:	334020ef          	jal	80003fbc <namei>
    80001c8c:	16a4b823          	sd	a0,368(s1)
  p->state = RUNNABLE;
    80001c90:	478d                	li	a5,3
    80001c92:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c94:	8526                	mv	a0,s1
    80001c96:	868ff0ef          	jal	80000cfe <release>
}
    80001c9a:	60e2                	ld	ra,24(sp)
    80001c9c:	6442                	ld	s0,16(sp)
    80001c9e:	64a2                	ld	s1,8(sp)
    80001ca0:	6105                	addi	sp,sp,32
    80001ca2:	8082                	ret

0000000080001ca4 <growproc>:
{
    80001ca4:	1101                	addi	sp,sp,-32
    80001ca6:	ec06                	sd	ra,24(sp)
    80001ca8:	e822                	sd	s0,16(sp)
    80001caa:	e426                	sd	s1,8(sp)
    80001cac:	e04a                	sd	s2,0(sp)
    80001cae:	1000                	addi	s0,sp,32
    80001cb0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001cb2:	cb3ff0ef          	jal	80001964 <myproc>
    80001cb6:	84aa                	mv	s1,a0
  sz = p->sz;
    80001cb8:	752c                	ld	a1,104(a0)
  if(n > 0){
    80001cba:	01204c63          	bgtz	s2,80001cd2 <growproc+0x2e>
  } else if(n < 0){
    80001cbe:	02094463          	bltz	s2,80001ce6 <growproc+0x42>
  p->sz = sz;
    80001cc2:	f4ac                	sd	a1,104(s1)
  return 0;
    80001cc4:	4501                	li	a0,0
}
    80001cc6:	60e2                	ld	ra,24(sp)
    80001cc8:	6442                	ld	s0,16(sp)
    80001cca:	64a2                	ld	s1,8(sp)
    80001ccc:	6902                	ld	s2,0(sp)
    80001cce:	6105                	addi	sp,sp,32
    80001cd0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001cd2:	4691                	li	a3,4
    80001cd4:	00b90633          	add	a2,s2,a1
    80001cd8:	7928                	ld	a0,112(a0)
    80001cda:	e64ff0ef          	jal	8000133e <uvmalloc>
    80001cde:	85aa                	mv	a1,a0
    80001ce0:	f16d                	bnez	a0,80001cc2 <growproc+0x1e>
      return -1;
    80001ce2:	557d                	li	a0,-1
    80001ce4:	b7cd                	j	80001cc6 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ce6:	00b90633          	add	a2,s2,a1
    80001cea:	7928                	ld	a0,112(a0)
    80001cec:	e0eff0ef          	jal	800012fa <uvmdealloc>
    80001cf0:	85aa                	mv	a1,a0
    80001cf2:	bfc1                	j	80001cc2 <growproc+0x1e>

0000000080001cf4 <kfork>:
{
    80001cf4:	7139                	addi	sp,sp,-64
    80001cf6:	fc06                	sd	ra,56(sp)
    80001cf8:	f822                	sd	s0,48(sp)
    80001cfa:	f426                	sd	s1,40(sp)
    80001cfc:	e456                	sd	s5,8(sp)
    80001cfe:	0080                	addi	s0,sp,64
  struct proc *p = myproc(); // 부모 프로세스
    80001d00:	c65ff0ef          	jal	80001964 <myproc>
    80001d04:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d06:	de9ff0ef          	jal	80001aee <allocproc>
    80001d0a:	12050263          	beqz	a0,80001e2e <kfork+0x13a>
    80001d0e:	ec4e                	sd	s3,24(sp)
    80001d10:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d12:	068ab603          	ld	a2,104(s5)
    80001d16:	792c                	ld	a1,112(a0)
    80001d18:	070ab503          	ld	a0,112(s5)
    80001d1c:	f5aff0ef          	jal	80001476 <uvmcopy>
    80001d20:	04054863          	bltz	a0,80001d70 <kfork+0x7c>
    80001d24:	f04a                	sd	s2,32(sp)
    80001d26:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001d28:	068ab783          	ld	a5,104(s5)
    80001d2c:	06f9b423          	sd	a5,104(s3)
  *(np->trapframe) = *(p->trapframe);
    80001d30:	078ab683          	ld	a3,120(s5)
    80001d34:	87b6                	mv	a5,a3
    80001d36:	0789b703          	ld	a4,120(s3)
    80001d3a:	12068693          	addi	a3,a3,288
    80001d3e:	6388                	ld	a0,0(a5)
    80001d40:	678c                	ld	a1,8(a5)
    80001d42:	6b90                	ld	a2,16(a5)
    80001d44:	e308                	sd	a0,0(a4)
    80001d46:	e70c                	sd	a1,8(a4)
    80001d48:	eb10                	sd	a2,16(a4)
    80001d4a:	6f90                	ld	a2,24(a5)
    80001d4c:	ef10                	sd	a2,24(a4)
    80001d4e:	02078793          	addi	a5,a5,32
    80001d52:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d56:	fed794e3          	bne	a5,a3,80001d3e <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d5a:	0789b783          	ld	a5,120(s3)
    80001d5e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d62:	0f0a8493          	addi	s1,s5,240
    80001d66:	0f098913          	addi	s2,s3,240
    80001d6a:	170a8a13          	addi	s4,s5,368
    80001d6e:	a831                	j	80001d8a <kfork+0x96>
    freeproc(np);
    80001d70:	854e                	mv	a0,s3
    80001d72:	e93ff0ef          	jal	80001c04 <freeproc>
    release(&np->lock);
    80001d76:	854e                	mv	a0,s3
    80001d78:	f87fe0ef          	jal	80000cfe <release>
    return -1;
    80001d7c:	54fd                	li	s1,-1
    80001d7e:	69e2                	ld	s3,24(sp)
    80001d80:	a045                	j	80001e20 <kfork+0x12c>
  for(i = 0; i < NOFILE; i++)
    80001d82:	04a1                	addi	s1,s1,8
    80001d84:	0921                	addi	s2,s2,8
    80001d86:	01448963          	beq	s1,s4,80001d98 <kfork+0xa4>
    if(p->ofile[i])
    80001d8a:	6088                	ld	a0,0(s1)
    80001d8c:	d97d                	beqz	a0,80001d82 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d8e:	7ea020ef          	jal	80004578 <filedup>
    80001d92:	00a93023          	sd	a0,0(s2)
    80001d96:	b7f5                	j	80001d82 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d98:	170ab503          	ld	a0,368(s5)
    80001d9c:	1bd010ef          	jal	80003758 <idup>
    80001da0:	16a9b823          	sd	a0,368(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001da4:	4641                	li	a2,16
    80001da6:	178a8593          	addi	a1,s5,376
    80001daa:	17898513          	addi	a0,s3,376
    80001dae:	8e0ff0ef          	jal	80000e8e <safestrcpy>
  np->priority = p->priority;
    80001db2:	034aa783          	lw	a5,52(s5)
    80001db6:	02f9aa23          	sw	a5,52(s3)
  np->weight = p->weight;
    80001dba:	038aa683          	lw	a3,56(s5)
    80001dbe:	02d9ac23          	sw	a3,56(s3)
  np->vruntime = p->vruntime;
    80001dc2:	040ab703          	ld	a4,64(s5)
    80001dc6:	04e9b023          	sd	a4,64(s3)
  np->runtime = 0;
    80001dca:	0209ae23          	sw	zero,60(s3)
  np->remain_time = 5; 
    80001dce:	4795                	li	a5,5
    80001dd0:	04f9aa23          	sw	a5,84(s3)
  np->vdeadline = np->vruntime + (5*1000*1024)/np->weight;
    80001dd4:	004e27b7          	lui	a5,0x4e2
    80001dd8:	02d7c7bb          	divw	a5,a5,a3
    80001ddc:	97ba                	add	a5,a5,a4
    80001dde:	04f9b423          	sd	a5,72(s3)
  pid = np->pid;
    80001de2:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001de6:	854e                	mv	a0,s3
    80001de8:	f17fe0ef          	jal	80000cfe <release>
  acquire(&wait_lock);
    80001dec:	0000e517          	auipc	a0,0xe
    80001df0:	d0c50513          	addi	a0,a0,-756 # 8000faf8 <wait_lock>
    80001df4:	e77fe0ef          	jal	80000c6a <acquire>
  np->parent = p;
    80001df8:	0559bc23          	sd	s5,88(s3)
  release(&wait_lock);
    80001dfc:	0000e517          	auipc	a0,0xe
    80001e00:	cfc50513          	addi	a0,a0,-772 # 8000faf8 <wait_lock>
    80001e04:	efbfe0ef          	jal	80000cfe <release>
  acquire(&np->lock);
    80001e08:	854e                	mv	a0,s3
    80001e0a:	e61fe0ef          	jal	80000c6a <acquire>
  np->state = RUNNABLE;
    80001e0e:	478d                	li	a5,3
    80001e10:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e14:	854e                	mv	a0,s3
    80001e16:	ee9fe0ef          	jal	80000cfe <release>
  return pid;
    80001e1a:	7902                	ld	s2,32(sp)
    80001e1c:	69e2                	ld	s3,24(sp)
    80001e1e:	6a42                	ld	s4,16(sp)
}
    80001e20:	8526                	mv	a0,s1
    80001e22:	70e2                	ld	ra,56(sp)
    80001e24:	7442                	ld	s0,48(sp)
    80001e26:	74a2                	ld	s1,40(sp)
    80001e28:	6aa2                	ld	s5,8(sp)
    80001e2a:	6121                	addi	sp,sp,64
    80001e2c:	8082                	ret
    return -1;
    80001e2e:	54fd                	li	s1,-1
    80001e30:	bfc5                	j	80001e20 <kfork+0x12c>

0000000080001e32 <scheduler>:
{
    80001e32:	7139                	addi	sp,sp,-64
    80001e34:	fc06                	sd	ra,56(sp)
    80001e36:	f822                	sd	s0,48(sp)
    80001e38:	f426                	sd	s1,40(sp)
    80001e3a:	f04a                	sd	s2,32(sp)
    80001e3c:	ec4e                	sd	s3,24(sp)
    80001e3e:	e852                	sd	s4,16(sp)
    80001e40:	e456                	sd	s5,8(sp)
    80001e42:	0080                	addi	s0,sp,64
    80001e44:	8792                	mv	a5,tp
  int id = r_tp();
    80001e46:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e48:	00779a93          	slli	s5,a5,0x7
    80001e4c:	0000e717          	auipc	a4,0xe
    80001e50:	c9470713          	addi	a4,a4,-876 # 8000fae0 <pid_lock>
    80001e54:	9756                	add	a4,a4,s5
    80001e56:	02073823          	sd	zero,48(a4)
	      swtch(&c->context, &targetp->context);
    80001e5a:	0000e717          	auipc	a4,0xe
    80001e5e:	cbe70713          	addi	a4,a4,-834 # 8000fb18 <cpus+0x8>
    80001e62:	9aba                	add	s5,s5,a4
    acquire(&proct_lock);
    80001e64:	0000e997          	auipc	s3,0xe
    80001e68:	0ac98993          	addi	s3,s3,172 # 8000ff10 <proct_lock>
    for (p = proc; p < &proc[NPROC]; p++){
    80001e6c:	00014917          	auipc	s2,0x14
    80001e70:	2bc90913          	addi	s2,s2,700 # 80016128 <tickslock>
	      c->proc = targetp;
    80001e74:	079e                	slli	a5,a5,0x7
    80001e76:	0000ea17          	auipc	s4,0xe
    80001e7a:	c6aa0a13          	addi	s4,s4,-918 # 8000fae0 <pid_lock>
    80001e7e:	9a3e                	add	s4,s4,a5
    80001e80:	a0f5                	j	80001f6c <scheduler+0x13a>
		    min_vruntime = p->vruntime;
    80001e82:	63a8                	ld	a0,64(a5)
	    for (p=proc; p<&proc[NPROC]; p++){
    80001e84:	0000e797          	auipc	a5,0xe
    80001e88:	0a478793          	addi	a5,a5,164 # 8000ff28 <proc>
    80001e8c:	a029                	j	80001e96 <scheduler+0x64>
    80001e8e:	18878793          	addi	a5,a5,392
    80001e92:	01278a63          	beq	a5,s2,80001ea6 <scheduler+0x74>
        if (p->state == RUNNABLE && p->vruntime < min_vruntime){
    80001e96:	4f98                	lw	a4,24(a5)
    80001e98:	fe971be3          	bne	a4,s1,80001e8e <scheduler+0x5c>
    80001e9c:	63b8                	ld	a4,64(a5)
    80001e9e:	fea778e3          	bgeu	a4,a0,80001e8e <scheduler+0x5c>
    80001ea2:	853a                	mv	a0,a4
    80001ea4:	b7ed                	j	80001e8e <scheduler+0x5c>
    uint64 calculated = 0;
    80001ea6:	4681                	li	a3,0
    uint64 total_weight = 0;
    80001ea8:	4801                	li	a6,0
      for (p=proc; p<&proc[NPROC]; p++){
    80001eaa:	0000e797          	auipc	a5,0xe
    80001eae:	07e78793          	addi	a5,a5,126 # 8000ff28 <proc>
    80001eb2:	a029                	j	80001ebc <scheduler+0x8a>
    80001eb4:	18878793          	addi	a5,a5,392
    80001eb8:	01278d63          	beq	a5,s2,80001ed2 <scheduler+0xa0>
	      if (p->state == RUNNABLE){
    80001ebc:	4f98                	lw	a4,24(a5)
    80001ebe:	fe971be3          	bne	a4,s1,80001eb4 <scheduler+0x82>
		      total_weight += p->weight;
    80001ec2:	5f90                	lw	a2,56(a5)
    80001ec4:	9832                	add	a6,a6,a2
		      calculated += (p->vruntime - min_vruntime) * p->weight;
    80001ec6:	63b8                	ld	a4,64(a5)
    80001ec8:	8f09                	sub	a4,a4,a0
    80001eca:	02c70733          	mul	a4,a4,a2
    80001ece:	96ba                	add	a3,a3,a4
    80001ed0:	b7d5                	j	80001eb4 <scheduler+0x82>
    targetp = 0;
    80001ed2:	4581                	li	a1,0
    	for(p = proc; p < &proc[NPROC]; p++) {
    80001ed4:	0000e797          	auipc	a5,0xe
    80001ed8:	05478793          	addi	a5,a5,84 # 8000ff28 <proc>
    80001edc:	a031                	j	80001ee8 <scheduler+0xb6>
              targetp = p;
    80001ede:	85be                	mv	a1,a5
    	for(p = proc; p < &proc[NPROC]; p++) {
    80001ee0:	18878793          	addi	a5,a5,392
    80001ee4:	03278763          	beq	a5,s2,80001f12 <scheduler+0xe0>
        if(p->state == RUNNABLE) {
    80001ee8:	4f98                	lw	a4,24(a5)
    80001eea:	fe971be3          	bne	a4,s1,80001ee0 <scheduler+0xae>
			    if (calculated >= (p->vruntime - min_vruntime)*total_weight){
    80001eee:	63b8                	ld	a4,64(a5)
    80001ef0:	8f09                	sub	a4,a4,a0
    80001ef2:	03070733          	mul	a4,a4,a6
    80001ef6:	00e6b633          	sltu	a2,a3,a4
    80001efa:	00163613          	seqz	a2,a2
    80001efe:	cbb0                	sw	a2,80(a5)
          if (p->is_eligible){
    80001f00:	fee6e0e3          	bltu	a3,a4,80001ee0 <scheduler+0xae>
            if (targetp == 0){
    80001f04:	dde9                	beqz	a1,80001ede <scheduler+0xac>
            } else if (p->vdeadline < targetp->vdeadline){
    80001f06:	67b0                	ld	a2,72(a5)
    80001f08:	65b8                	ld	a4,72(a1)
    80001f0a:	fce67be3          	bgeu	a2,a4,80001ee0 <scheduler+0xae>
              targetp = p;}		
    80001f0e:	85be                	mv	a1,a5
    80001f10:	bfc1                	j	80001ee0 <scheduler+0xae>
    	if (targetp) {
    80001f12:	c9a1                	beqz	a1,80001f62 <scheduler+0x130>
	      targetp->state = RUNNING;
    80001f14:	4791                	li	a5,4
    80001f16:	cd9c                	sw	a5,24(a1)
	      c->proc = targetp;
    80001f18:	02ba3823          	sd	a1,48(s4)
	      swtch(&c->context, &targetp->context);
    80001f1c:	08058593          	addi	a1,a1,128
    80001f20:	8556                	mv	a0,s5
    80001f22:	14b000ef          	jal	8000286c <swtch>
	      c->proc = 0;
    80001f26:	020a3823          	sd	zero,48(s4)
    release(&proct_lock); 
    80001f2a:	854e                	mv	a0,s3
    80001f2c:	dd3fe0ef          	jal	80000cfe <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f30:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f34:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f38:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f3c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001f40:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f42:	10079073          	csrw	sstatus,a5
    acquire(&proct_lock);
    80001f46:	854e                	mv	a0,s3
    80001f48:	d23fe0ef          	jal	80000c6a <acquire>
    for (p = proc; p < &proc[NPROC]; p++){
    80001f4c:	0000e797          	auipc	a5,0xe
    80001f50:	fdc78793          	addi	a5,a5,-36 # 8000ff28 <proc>
	    if (p->state == RUNNABLE){
    80001f54:	4f98                	lw	a4,24(a5)
    80001f56:	f29706e3          	beq	a4,s1,80001e82 <scheduler+0x50>
    for (p = proc; p < &proc[NPROC]; p++){
    80001f5a:	18878793          	addi	a5,a5,392
    80001f5e:	ff279be3          	bne	a5,s2,80001f54 <scheduler+0x122>
    release(&proct_lock); 
    80001f62:	854e                	mv	a0,s3
    80001f64:	d9bfe0ef          	jal	80000cfe <release>
	    asm volatile("wfi");
    80001f68:	10500073          	wfi
	    if (p->state == RUNNABLE){
    80001f6c:	448d                	li	s1,3
    80001f6e:	b7c9                	j	80001f30 <scheduler+0xfe>

0000000080001f70 <sched>:
{
    80001f70:	1101                	addi	sp,sp,-32
    80001f72:	ec06                	sd	ra,24(sp)
    80001f74:	e822                	sd	s0,16(sp)
    80001f76:	e426                	sd	s1,8(sp)
    80001f78:	e04a                	sd	s2,0(sp)
    80001f7a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f7c:	9e9ff0ef          	jal	80001964 <myproc>
    80001f80:	84aa                	mv	s1,a0
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f82:	8912                	mv	s2,tp
  if(!holding(&p->lock))
    80001f84:	c77fe0ef          	jal	80000bfa <holding>
    80001f88:	cd0d                	beqz	a0,80001fc2 <sched+0x52>
  int id = r_tp();
    80001f8a:	2901                	sext.w	s2,s2
  if(p->state == RUNNING)
    80001f8c:	4c98                	lw	a4,24(s1)
    80001f8e:	4791                	li	a5,4
    80001f90:	02f70f63          	beq	a4,a5,80001fce <sched+0x5e>
  release(&p->lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	d69fe0ef          	jal	80000cfe <release>
  swtch(&p->context, &c->context);
    80001f9a:	091e                	slli	s2,s2,0x7
    80001f9c:	0921                	addi	s2,s2,8
    80001f9e:	0000e597          	auipc	a1,0xe
    80001fa2:	b7258593          	addi	a1,a1,-1166 # 8000fb10 <cpus>
    80001fa6:	95ca                	add	a1,a1,s2
    80001fa8:	08048513          	addi	a0,s1,128
    80001fac:	0c1000ef          	jal	8000286c <swtch>
  acquire(&p->lock);
    80001fb0:	8526                	mv	a0,s1
    80001fb2:	cb9fe0ef          	jal	80000c6a <acquire>
}
    80001fb6:	60e2                	ld	ra,24(sp)
    80001fb8:	6442                	ld	s0,16(sp)
    80001fba:	64a2                	ld	s1,8(sp)
    80001fbc:	6902                	ld	s2,0(sp)
    80001fbe:	6105                	addi	sp,sp,32
    80001fc0:	8082                	ret
    panic("sched p->lock");
    80001fc2:	00005517          	auipc	a0,0x5
    80001fc6:	1d650513          	addi	a0,a0,470 # 80007198 <etext+0x198>
    80001fca:	85bfe0ef          	jal	80000824 <panic>
	  p->state = RUNNABLE;
    80001fce:	478d                	li	a5,3
    80001fd0:	cc9c                	sw	a5,24(s1)
    80001fd2:	b7c9                	j	80001f94 <sched+0x24>

0000000080001fd4 <yield>:
{
    80001fd4:	1101                	addi	sp,sp,-32
    80001fd6:	ec06                	sd	ra,24(sp)
    80001fd8:	e822                	sd	s0,16(sp)
    80001fda:	e426                	sd	s1,8(sp)
    80001fdc:	e04a                	sd	s2,0(sp)
    80001fde:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fe0:	985ff0ef          	jal	80001964 <myproc>
    80001fe4:	84aa                	mv	s1,a0
    80001fe6:	8912                	mv	s2,tp
  int id = r_tp();
    80001fe8:	2901                	sext.w	s2,s2
  acquire(&p->lock);
    80001fea:	c81fe0ef          	jal	80000c6a <acquire>
  if (p->state == RUNNING)
    80001fee:	4c98                	lw	a4,24(s1)
    80001ff0:	4791                	li	a5,4
    80001ff2:	02f70c63          	beq	a4,a5,8000202a <yield+0x56>
  release(&p->lock);
    80001ff6:	8526                	mv	a0,s1
    80001ff8:	d07fe0ef          	jal	80000cfe <release>
  swtch(&p->context, &c->context);
    80001ffc:	091e                	slli	s2,s2,0x7
    80001ffe:	0921                	addi	s2,s2,8
    80002000:	0000e597          	auipc	a1,0xe
    80002004:	b1058593          	addi	a1,a1,-1264 # 8000fb10 <cpus>
    80002008:	95ca                	add	a1,a1,s2
    8000200a:	08048513          	addi	a0,s1,128
    8000200e:	05f000ef          	jal	8000286c <swtch>
  acquire(&p->lock);
    80002012:	8526                	mv	a0,s1
    80002014:	c57fe0ef          	jal	80000c6a <acquire>
  release(&p->lock);
    80002018:	8526                	mv	a0,s1
    8000201a:	ce5fe0ef          	jal	80000cfe <release>
}
    8000201e:	60e2                	ld	ra,24(sp)
    80002020:	6442                	ld	s0,16(sp)
    80002022:	64a2                	ld	s1,8(sp)
    80002024:	6902                	ld	s2,0(sp)
    80002026:	6105                	addi	sp,sp,32
    80002028:	8082                	ret
  	p->state = RUNNABLE;
    8000202a:	478d                	li	a5,3
    8000202c:	cc9c                	sw	a5,24(s1)
    8000202e:	b7e1                	j	80001ff6 <yield+0x22>

0000000080002030 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002030:	7179                	addi	sp,sp,-48
    80002032:	f406                	sd	ra,40(sp)
    80002034:	f022                	sd	s0,32(sp)
    80002036:	ec26                	sd	s1,24(sp)
    80002038:	e84a                	sd	s2,16(sp)
    8000203a:	e44e                	sd	s3,8(sp)
    8000203c:	1800                	addi	s0,sp,48
    8000203e:	89aa                	mv	s3,a0
    80002040:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002042:	923ff0ef          	jal	80001964 <myproc>
    80002046:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002048:	c23fe0ef          	jal	80000c6a <acquire>
  release(lk);
    8000204c:	854a                	mv	a0,s2
    8000204e:	cb1fe0ef          	jal	80000cfe <release>

  // Go to sleep.
  p->chan = chan;
    80002052:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002056:	4789                	li	a5,2
    80002058:	cc9c                	sw	a5,24(s1)
  // 스케줄러 수정했는데 sched 함수 호출 -> sched 수정 필요
  sched();
    8000205a:	f17ff0ef          	jal	80001f70 <sched>

  // Tidy up.
  p->chan = 0;
    8000205e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002062:	8526                	mv	a0,s1
    80002064:	c9bfe0ef          	jal	80000cfe <release>
  acquire(lk);
    80002068:	854a                	mv	a0,s2
    8000206a:	c01fe0ef          	jal	80000c6a <acquire>
}
    8000206e:	70a2                	ld	ra,40(sp)
    80002070:	7402                	ld	s0,32(sp)
    80002072:	64e2                	ld	s1,24(sp)
    80002074:	6942                	ld	s2,16(sp)
    80002076:	69a2                	ld	s3,8(sp)
    80002078:	6145                	addi	sp,sp,48
    8000207a:	8082                	ret

000000008000207c <wakeup>:
// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
// 깨어날 때도 eevdf 스케줄러 적용
void
wakeup(void *chan)
{
    8000207c:	715d                	addi	sp,sp,-80
    8000207e:	e486                	sd	ra,72(sp)
    80002080:	e0a2                	sd	s0,64(sp)
    80002082:	fc26                	sd	s1,56(sp)
    80002084:	f84a                	sd	s2,48(sp)
    80002086:	f44e                	sd	s3,40(sp)
    80002088:	f052                	sd	s4,32(sp)
    8000208a:	ec56                	sd	s5,24(sp)
    8000208c:	e85a                	sd	s6,16(sp)
    8000208e:	e45e                	sd	s7,8(sp)
    80002090:	0880                	addi	s0,sp,80
    80002092:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002094:	0000e497          	auipc	s1,0xe
    80002098:	e9448493          	addi	s1,s1,-364 # 8000ff28 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000209c:	4989                	li	s3,2
	// nv, runtime, vruntime은 그대로
	p->remain_time = 5; // 5로 초기화
    8000209e:	4b95                	li	s7,5
	p->vdeadline = p->vruntime + (5*1000*1024)/p->weight; // vdeadline 다시 계산
    800020a0:	004e2b37          	lui	s6,0x4e2
        // eligibility는 scheduler 안에서 계산하니까 그때 수정
	p->state = RUNNABLE;
    800020a4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020a6:	00014917          	auipc	s2,0x14
    800020aa:	08290913          	addi	s2,s2,130 # 80016128 <tickslock>
    800020ae:	a801                	j	800020be <wakeup+0x42>
	///release(&p->lock);
	//printf("wake up process id: %d\n", p->pid);
      }//else{
      release(&p->lock);//}
    800020b0:	8526                	mv	a0,s1
    800020b2:	c4dfe0ef          	jal	80000cfe <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020b6:	18848493          	addi	s1,s1,392
    800020ba:	03248a63          	beq	s1,s2,800020ee <wakeup+0x72>
    if(p != myproc()){
    800020be:	8a7ff0ef          	jal	80001964 <myproc>
    800020c2:	fe950ae3          	beq	a0,s1,800020b6 <wakeup+0x3a>
      acquire(&p->lock);
    800020c6:	8526                	mv	a0,s1
    800020c8:	ba3fe0ef          	jal	80000c6a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800020cc:	4c9c                	lw	a5,24(s1)
    800020ce:	ff3791e3          	bne	a5,s3,800020b0 <wakeup+0x34>
    800020d2:	709c                	ld	a5,32(s1)
    800020d4:	fd479ee3          	bne	a5,s4,800020b0 <wakeup+0x34>
	p->remain_time = 5; // 5로 초기화
    800020d8:	0574aa23          	sw	s7,84(s1)
	p->vdeadline = p->vruntime + (5*1000*1024)/p->weight; // vdeadline 다시 계산
    800020dc:	5c9c                	lw	a5,56(s1)
    800020de:	02fb47bb          	divw	a5,s6,a5
    800020e2:	60b8                	ld	a4,64(s1)
    800020e4:	97ba                	add	a5,a5,a4
    800020e6:	e4bc                	sd	a5,72(s1)
	p->state = RUNNABLE;
    800020e8:	0154ac23          	sw	s5,24(s1)
    800020ec:	b7d1                	j	800020b0 <wakeup+0x34>
    }
  }
}
    800020ee:	60a6                	ld	ra,72(sp)
    800020f0:	6406                	ld	s0,64(sp)
    800020f2:	74e2                	ld	s1,56(sp)
    800020f4:	7942                	ld	s2,48(sp)
    800020f6:	79a2                	ld	s3,40(sp)
    800020f8:	7a02                	ld	s4,32(sp)
    800020fa:	6ae2                	ld	s5,24(sp)
    800020fc:	6b42                	ld	s6,16(sp)
    800020fe:	6ba2                	ld	s7,8(sp)
    80002100:	6161                	addi	sp,sp,80
    80002102:	8082                	ret

0000000080002104 <reparent>:
{
    80002104:	7179                	addi	sp,sp,-48
    80002106:	f406                	sd	ra,40(sp)
    80002108:	f022                	sd	s0,32(sp)
    8000210a:	ec26                	sd	s1,24(sp)
    8000210c:	e84a                	sd	s2,16(sp)
    8000210e:	e44e                	sd	s3,8(sp)
    80002110:	e052                	sd	s4,0(sp)
    80002112:	1800                	addi	s0,sp,48
    80002114:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002116:	0000e497          	auipc	s1,0xe
    8000211a:	e1248493          	addi	s1,s1,-494 # 8000ff28 <proc>
      pp->parent = initproc;
    8000211e:	00006a17          	auipc	s4,0x6
    80002122:	8b2a0a13          	addi	s4,s4,-1870 # 800079d0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002126:	00014997          	auipc	s3,0x14
    8000212a:	00298993          	addi	s3,s3,2 # 80016128 <tickslock>
    8000212e:	a029                	j	80002138 <reparent+0x34>
    80002130:	18848493          	addi	s1,s1,392
    80002134:	01348b63          	beq	s1,s3,8000214a <reparent+0x46>
    if(pp->parent == p){
    80002138:	6cbc                	ld	a5,88(s1)
    8000213a:	ff279be3          	bne	a5,s2,80002130 <reparent+0x2c>
      pp->parent = initproc;
    8000213e:	000a3503          	ld	a0,0(s4)
    80002142:	eca8                	sd	a0,88(s1)
      wakeup(initproc);
    80002144:	f39ff0ef          	jal	8000207c <wakeup>
    80002148:	b7e5                	j	80002130 <reparent+0x2c>
}
    8000214a:	70a2                	ld	ra,40(sp)
    8000214c:	7402                	ld	s0,32(sp)
    8000214e:	64e2                	ld	s1,24(sp)
    80002150:	6942                	ld	s2,16(sp)
    80002152:	69a2                	ld	s3,8(sp)
    80002154:	6a02                	ld	s4,0(sp)
    80002156:	6145                	addi	sp,sp,48
    80002158:	8082                	ret

000000008000215a <kexit>:
{
    8000215a:	7179                	addi	sp,sp,-48
    8000215c:	f406                	sd	ra,40(sp)
    8000215e:	f022                	sd	s0,32(sp)
    80002160:	ec26                	sd	s1,24(sp)
    80002162:	e84a                	sd	s2,16(sp)
    80002164:	e44e                	sd	s3,8(sp)
    80002166:	e052                	sd	s4,0(sp)
    80002168:	1800                	addi	s0,sp,48
    8000216a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000216c:	ff8ff0ef          	jal	80001964 <myproc>
    80002170:	89aa                	mv	s3,a0
  if(p == initproc)
    80002172:	00006797          	auipc	a5,0x6
    80002176:	85e7b783          	ld	a5,-1954(a5) # 800079d0 <initproc>
    8000217a:	0f050493          	addi	s1,a0,240
    8000217e:	17050913          	addi	s2,a0,368
    80002182:	00a79b63          	bne	a5,a0,80002198 <kexit+0x3e>
    panic("init exiting");
    80002186:	00005517          	auipc	a0,0x5
    8000218a:	02250513          	addi	a0,a0,34 # 800071a8 <etext+0x1a8>
    8000218e:	e96fe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002192:	04a1                	addi	s1,s1,8
    80002194:	01248963          	beq	s1,s2,800021a6 <kexit+0x4c>
    if(p->ofile[fd]){
    80002198:	6088                	ld	a0,0(s1)
    8000219a:	dd65                	beqz	a0,80002192 <kexit+0x38>
      fileclose(f);
    8000219c:	422020ef          	jal	800045be <fileclose>
      p->ofile[fd] = 0;
    800021a0:	0004b023          	sd	zero,0(s1)
    800021a4:	b7fd                	j	80002192 <kexit+0x38>
  begin_op();
    800021a6:	7f5010ef          	jal	8000419a <begin_op>
  iput(p->cwd);
    800021aa:	1709b503          	ld	a0,368(s3)
    800021ae:	762010ef          	jal	80003910 <iput>
  end_op();
    800021b2:	058020ef          	jal	8000420a <end_op>
  p->cwd = 0;
    800021b6:	1609b823          	sd	zero,368(s3)
  acquire(&wait_lock);
    800021ba:	0000e517          	auipc	a0,0xe
    800021be:	93e50513          	addi	a0,a0,-1730 # 8000faf8 <wait_lock>
    800021c2:	aa9fe0ef          	jal	80000c6a <acquire>
  reparent(p);
    800021c6:	854e                	mv	a0,s3
    800021c8:	f3dff0ef          	jal	80002104 <reparent>
  wakeup(p->parent);
    800021cc:	0589b503          	ld	a0,88(s3)
    800021d0:	eadff0ef          	jal	8000207c <wakeup>
  acquire(&p->lock);
    800021d4:	854e                	mv	a0,s3
    800021d6:	a95fe0ef          	jal	80000c6a <acquire>
  p->xstate = status;
    800021da:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800021de:	4795                	li	a5,5
    800021e0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800021e4:	0000e517          	auipc	a0,0xe
    800021e8:	91450513          	addi	a0,a0,-1772 # 8000faf8 <wait_lock>
    800021ec:	b13fe0ef          	jal	80000cfe <release>
  sched();
    800021f0:	d81ff0ef          	jal	80001f70 <sched>
  panic("zombie exit");
    800021f4:	00005517          	auipc	a0,0x5
    800021f8:	fc450513          	addi	a0,a0,-60 # 800071b8 <etext+0x1b8>
    800021fc:	e28fe0ef          	jal	80000824 <panic>

0000000080002200 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002200:	7179                	addi	sp,sp,-48
    80002202:	f406                	sd	ra,40(sp)
    80002204:	f022                	sd	s0,32(sp)
    80002206:	ec26                	sd	s1,24(sp)
    80002208:	e84a                	sd	s2,16(sp)
    8000220a:	e44e                	sd	s3,8(sp)
    8000220c:	1800                	addi	s0,sp,48
    8000220e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002210:	0000e497          	auipc	s1,0xe
    80002214:	d1848493          	addi	s1,s1,-744 # 8000ff28 <proc>
    80002218:	00014997          	auipc	s3,0x14
    8000221c:	f1098993          	addi	s3,s3,-240 # 80016128 <tickslock>
    acquire(&p->lock);
    80002220:	8526                	mv	a0,s1
    80002222:	a49fe0ef          	jal	80000c6a <acquire>
    if(p->pid == pid){
    80002226:	589c                	lw	a5,48(s1)
    80002228:	01278b63          	beq	a5,s2,8000223e <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000222c:	8526                	mv	a0,s1
    8000222e:	ad1fe0ef          	jal	80000cfe <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002232:	18848493          	addi	s1,s1,392
    80002236:	ff3495e3          	bne	s1,s3,80002220 <kkill+0x20>
  }
  return -1;
    8000223a:	557d                	li	a0,-1
    8000223c:	a819                	j	80002252 <kkill+0x52>
      p->killed = 1;
    8000223e:	4785                	li	a5,1
    80002240:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002242:	4c98                	lw	a4,24(s1)
    80002244:	4789                	li	a5,2
    80002246:	00f70d63          	beq	a4,a5,80002260 <kkill+0x60>
      release(&p->lock);
    8000224a:	8526                	mv	a0,s1
    8000224c:	ab3fe0ef          	jal	80000cfe <release>
      return 0;
    80002250:	4501                	li	a0,0
}
    80002252:	70a2                	ld	ra,40(sp)
    80002254:	7402                	ld	s0,32(sp)
    80002256:	64e2                	ld	s1,24(sp)
    80002258:	6942                	ld	s2,16(sp)
    8000225a:	69a2                	ld	s3,8(sp)
    8000225c:	6145                	addi	sp,sp,48
    8000225e:	8082                	ret
        p->state = RUNNABLE;
    80002260:	478d                	li	a5,3
    80002262:	cc9c                	sw	a5,24(s1)
    80002264:	b7dd                	j	8000224a <kkill+0x4a>

0000000080002266 <setkilled>:

void
setkilled(struct proc *p)
{
    80002266:	1101                	addi	sp,sp,-32
    80002268:	ec06                	sd	ra,24(sp)
    8000226a:	e822                	sd	s0,16(sp)
    8000226c:	e426                	sd	s1,8(sp)
    8000226e:	1000                	addi	s0,sp,32
    80002270:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002272:	9f9fe0ef          	jal	80000c6a <acquire>
  p->killed = 1;
    80002276:	4785                	li	a5,1
    80002278:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000227a:	8526                	mv	a0,s1
    8000227c:	a83fe0ef          	jal	80000cfe <release>
}
    80002280:	60e2                	ld	ra,24(sp)
    80002282:	6442                	ld	s0,16(sp)
    80002284:	64a2                	ld	s1,8(sp)
    80002286:	6105                	addi	sp,sp,32
    80002288:	8082                	ret

000000008000228a <killed>:

int
killed(struct proc *p)
{
    8000228a:	1101                	addi	sp,sp,-32
    8000228c:	ec06                	sd	ra,24(sp)
    8000228e:	e822                	sd	s0,16(sp)
    80002290:	e426                	sd	s1,8(sp)
    80002292:	e04a                	sd	s2,0(sp)
    80002294:	1000                	addi	s0,sp,32
    80002296:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002298:	9d3fe0ef          	jal	80000c6a <acquire>
  k = p->killed;
    8000229c:	549c                	lw	a5,40(s1)
    8000229e:	893e                	mv	s2,a5
  release(&p->lock);
    800022a0:	8526                	mv	a0,s1
    800022a2:	a5dfe0ef          	jal	80000cfe <release>
  return k;
}
    800022a6:	854a                	mv	a0,s2
    800022a8:	60e2                	ld	ra,24(sp)
    800022aa:	6442                	ld	s0,16(sp)
    800022ac:	64a2                	ld	s1,8(sp)
    800022ae:	6902                	ld	s2,0(sp)
    800022b0:	6105                	addi	sp,sp,32
    800022b2:	8082                	ret

00000000800022b4 <kwait>:
{
    800022b4:	715d                	addi	sp,sp,-80
    800022b6:	e486                	sd	ra,72(sp)
    800022b8:	e0a2                	sd	s0,64(sp)
    800022ba:	fc26                	sd	s1,56(sp)
    800022bc:	f84a                	sd	s2,48(sp)
    800022be:	f44e                	sd	s3,40(sp)
    800022c0:	f052                	sd	s4,32(sp)
    800022c2:	ec56                	sd	s5,24(sp)
    800022c4:	e85a                	sd	s6,16(sp)
    800022c6:	e45e                	sd	s7,8(sp)
    800022c8:	0880                	addi	s0,sp,80
    800022ca:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800022cc:	e98ff0ef          	jal	80001964 <myproc>
    800022d0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022d2:	0000e517          	auipc	a0,0xe
    800022d6:	82650513          	addi	a0,a0,-2010 # 8000faf8 <wait_lock>
    800022da:	991fe0ef          	jal	80000c6a <acquire>
        if(pp->state == ZOMBIE){
    800022de:	4a15                	li	s4,5
        havekids = 1;
    800022e0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022e2:	00014997          	auipc	s3,0x14
    800022e6:	e4698993          	addi	s3,s3,-442 # 80016128 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022ea:	0000eb17          	auipc	s6,0xe
    800022ee:	80eb0b13          	addi	s6,s6,-2034 # 8000faf8 <wait_lock>
    800022f2:	a869                	j	8000238c <kwait+0xd8>
          pid = pp->pid;
    800022f4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800022f8:	000b8c63          	beqz	s7,80002310 <kwait+0x5c>
    800022fc:	4691                	li	a3,4
    800022fe:	02c48613          	addi	a2,s1,44
    80002302:	85de                	mv	a1,s7
    80002304:	07093503          	ld	a0,112(s2)
    80002308:	b8eff0ef          	jal	80001696 <copyout>
    8000230c:	02054a63          	bltz	a0,80002340 <kwait+0x8c>
          freeproc(pp);
    80002310:	8526                	mv	a0,s1
    80002312:	8f3ff0ef          	jal	80001c04 <freeproc>
          release(&pp->lock);
    80002316:	8526                	mv	a0,s1
    80002318:	9e7fe0ef          	jal	80000cfe <release>
          release(&wait_lock);
    8000231c:	0000d517          	auipc	a0,0xd
    80002320:	7dc50513          	addi	a0,a0,2012 # 8000faf8 <wait_lock>
    80002324:	9dbfe0ef          	jal	80000cfe <release>
}
    80002328:	854e                	mv	a0,s3
    8000232a:	60a6                	ld	ra,72(sp)
    8000232c:	6406                	ld	s0,64(sp)
    8000232e:	74e2                	ld	s1,56(sp)
    80002330:	7942                	ld	s2,48(sp)
    80002332:	79a2                	ld	s3,40(sp)
    80002334:	7a02                	ld	s4,32(sp)
    80002336:	6ae2                	ld	s5,24(sp)
    80002338:	6b42                	ld	s6,16(sp)
    8000233a:	6ba2                	ld	s7,8(sp)
    8000233c:	6161                	addi	sp,sp,80
    8000233e:	8082                	ret
            release(&pp->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	9bdfe0ef          	jal	80000cfe <release>
            release(&wait_lock);
    80002346:	0000d517          	auipc	a0,0xd
    8000234a:	7b250513          	addi	a0,a0,1970 # 8000faf8 <wait_lock>
    8000234e:	9b1fe0ef          	jal	80000cfe <release>
            return -1; // 에러
    80002352:	59fd                	li	s3,-1
    80002354:	bfd1                	j	80002328 <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002356:	18848493          	addi	s1,s1,392
    8000235a:	03348063          	beq	s1,s3,8000237a <kwait+0xc6>
      if(pp->parent == p){
    8000235e:	6cbc                	ld	a5,88(s1)
    80002360:	ff279be3          	bne	a5,s2,80002356 <kwait+0xa2>
        acquire(&pp->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	905fe0ef          	jal	80000c6a <acquire>
        if(pp->state == ZOMBIE){
    8000236a:	4c9c                	lw	a5,24(s1)
    8000236c:	f94784e3          	beq	a5,s4,800022f4 <kwait+0x40>
        release(&pp->lock);
    80002370:	8526                	mv	a0,s1
    80002372:	98dfe0ef          	jal	80000cfe <release>
        havekids = 1;
    80002376:	8756                	mv	a4,s5
    80002378:	bff9                	j	80002356 <kwait+0xa2>
    if(!havekids || killed(p)){
    8000237a:	cf19                	beqz	a4,80002398 <kwait+0xe4>
    8000237c:	854a                	mv	a0,s2
    8000237e:	f0dff0ef          	jal	8000228a <killed>
    80002382:	e919                	bnez	a0,80002398 <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002384:	85da                	mv	a1,s6
    80002386:	854a                	mv	a0,s2
    80002388:	ca9ff0ef          	jal	80002030 <sleep>
    havekids = 0;
    8000238c:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000238e:	0000e497          	auipc	s1,0xe
    80002392:	b9a48493          	addi	s1,s1,-1126 # 8000ff28 <proc>
    80002396:	b7e1                	j	8000235e <kwait+0xaa>
      release(&wait_lock);
    80002398:	0000d517          	auipc	a0,0xd
    8000239c:	76050513          	addi	a0,a0,1888 # 8000faf8 <wait_lock>
    800023a0:	95ffe0ef          	jal	80000cfe <release>
      return -1;
    800023a4:	59fd                	li	s3,-1
    800023a6:	b749                	j	80002328 <kwait+0x74>

00000000800023a8 <getnice>:

// 우선순위 정보 가져오는 함수 (nice value를 return)
int 
getnice(int pid)
{
    800023a8:	1101                	addi	sp,sp,-32
    800023aa:	ec06                	sd	ra,24(sp)
    800023ac:	e822                	sd	s0,16(sp)
    800023ae:	e426                	sd	s1,8(sp)
    800023b0:	e04a                	sd	s2,0(sp)
    800023b2:	1000                	addi	s0,sp,32
	struct proc *p;
	int check = 0;
	int nicevalue;

	for (p = proc; p < &proc[NPROC]; p++)
    800023b4:	0000e497          	auipc	s1,0xe
    800023b8:	b7448493          	addi	s1,s1,-1164 # 8000ff28 <proc>
    800023bc:	00014717          	auipc	a4,0x14
    800023c0:	d6c70713          	addi	a4,a4,-660 # 80016128 <tickslock>
	{
		if (p->pid == pid)
    800023c4:	589c                	lw	a5,48(s1)
    800023c6:	00a78863          	beq	a5,a0,800023d6 <getnice+0x2e>
	for (p = proc; p < &proc[NPROC]; p++)
    800023ca:	18848493          	addi	s1,s1,392
    800023ce:	fee49be3          	bne	s1,a4,800023c4 <getnice+0x1c>
		}
	}

	if (check == 0)
	{
		return -1;
    800023d2:	597d                	li	s2,-1
    800023d4:	a829                	j	800023ee <getnice+0x46>
			acquire(&p->lock);
    800023d6:	8526                	mv	a0,s1
    800023d8:	893fe0ef          	jal	80000c6a <acquire>
			if (p->priority < 0 || p->priority > 39)
    800023dc:	0344a903          	lw	s2,52(s1)
    800023e0:	02700793          	li	a5,39
    800023e4:	0127ec63          	bltu	a5,s2,800023fc <getnice+0x54>
			release(&p->lock);
    800023e8:	8526                	mv	a0,s1
    800023ea:	915fe0ef          	jal	80000cfe <release>
	else
	{
		return nicevalue;
	}

}
    800023ee:	854a                	mv	a0,s2
    800023f0:	60e2                	ld	ra,24(sp)
    800023f2:	6442                	ld	s0,16(sp)
    800023f4:	64a2                	ld	s1,8(sp)
    800023f6:	6902                	ld	s2,0(sp)
    800023f8:	6105                	addi	sp,sp,32
    800023fa:	8082                	ret
				return -1;
    800023fc:	597d                	li	s2,-1
    800023fe:	bfc5                	j	800023ee <getnice+0x46>

0000000080002400 <setnice>:
setnice(int pid, int value)
{
	struct proc *p;
	int check = 0;

	if (value < 0 || value > 39 )
    80002400:	02700793          	li	a5,39
    80002404:	06b7e863          	bltu	a5,a1,80002474 <setnice+0x74>
{
    80002408:	1101                	addi	sp,sp,-32
    8000240a:	ec06                	sd	ra,24(sp)
    8000240c:	e822                	sd	s0,16(sp)
    8000240e:	e426                	sd	s1,8(sp)
    80002410:	e04a                	sd	s2,0(sp)
    80002412:	1000                	addi	s0,sp,32
    80002414:	892e                	mv	s2,a1
	{
		return -1;
	}

	for (p = proc; p < &proc[NPROC]; p++)
    80002416:	0000e497          	auipc	s1,0xe
    8000241a:	b1248493          	addi	s1,s1,-1262 # 8000ff28 <proc>
    8000241e:	00014717          	auipc	a4,0x14
    80002422:	d0a70713          	addi	a4,a4,-758 # 80016128 <tickslock>
	{
		if (p->pid == pid)
    80002426:	589c                	lw	a5,48(s1)
    80002428:	00a78863          	beq	a5,a0,80002438 <setnice+0x38>
	for (p = proc; p < &proc[NPROC]; p++)
    8000242c:	18848493          	addi	s1,s1,392
    80002430:	fee49be3          	bne	s1,a4,80002426 <setnice+0x26>
		}
	}
	// 일치하는 프로세스가 없는 경우
	if (check == 0)
	{
		return -1;
    80002434:	557d                	li	a0,-1
    80002436:	a80d                	j	80002468 <setnice+0x68>
			acquire(&p->lock);
    80002438:	8526                	mv	a0,s1
    8000243a:	831fe0ef          	jal	80000c6a <acquire>
			p->priority = value;
    8000243e:	0324aa23          	sw	s2,52(s1)
			p->weight = weight[value];
    80002442:	090a                	slli	s2,s2,0x2
    80002444:	00005797          	auipc	a5,0x5
    80002448:	4cc78793          	addi	a5,a5,1228 # 80007910 <weight>
    8000244c:	97ca                	add	a5,a5,s2
    8000244e:	439c                	lw	a5,0(a5)
    80002450:	dc9c                	sw	a5,56(s1)
			p->vdeadline = p->vruntime + (5*1000*1024)/p->weight;
    80002452:	004e2737          	lui	a4,0x4e2
    80002456:	02f7473b          	divw	a4,a4,a5
    8000245a:	60bc                	ld	a5,64(s1)
    8000245c:	97ba                	add	a5,a5,a4
    8000245e:	e4bc                	sd	a5,72(s1)
			release(&p->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	89dfe0ef          	jal	80000cfe <release>
	}

	return 0;
    80002466:	4501                	li	a0,0
}
    80002468:	60e2                	ld	ra,24(sp)
    8000246a:	6442                	ld	s0,16(sp)
    8000246c:	64a2                	ld	s1,8(sp)
    8000246e:	6902                	ld	s2,0(sp)
    80002470:	6105                	addi	sp,sp,32
    80002472:	8082                	ret
		return -1;
    80002474:	557d                	li	a0,-1
}
    80002476:	8082                	ret

0000000080002478 <state_string>:

// 문자열로 출력하기 위한 로직
const char* state_string(enum procstate state)
{
    80002478:	1141                	addi	sp,sp,-16
    8000247a:	e406                	sd	ra,8(sp)
    8000247c:	e022                	sd	s0,0(sp)
    8000247e:	0800                	addi	s0,sp,16
	switch (state)
    80002480:	4795                	li	a5,5
    80002482:	04a7e763          	bltu	a5,a0,800024d0 <state_string+0x58>
    80002486:	050a                	slli	a0,a0,0x2
    80002488:	00005717          	auipc	a4,0x5
    8000248c:	34070713          	addi	a4,a4,832 # 800077c8 <digits+0x18>
    80002490:	953a                	add	a0,a0,a4
    80002492:	411c                	lw	a5,0(a0)
    80002494:	97ba                	add	a5,a5,a4
    80002496:	8782                	jr	a5
	{
		case UNUSED:
			return "UNUSED";
    80002498:	00005517          	auipc	a0,0x5
    8000249c:	d3050513          	addi	a0,a0,-720 # 800071c8 <etext+0x1c8>
		case ZOMBIE:
			return "ZOMBIE";
		default:
			return "Unknown";
	}
}
    800024a0:	60a2                	ld	ra,8(sp)
    800024a2:	6402                	ld	s0,0(sp)
    800024a4:	0141                	addi	sp,sp,16
    800024a6:	8082                	ret
			return "SLEEPING";
    800024a8:	00005517          	auipc	a0,0x5
    800024ac:	d3050513          	addi	a0,a0,-720 # 800071d8 <etext+0x1d8>
    800024b0:	bfc5                	j	800024a0 <state_string+0x28>
			return "RUNNABLE";
    800024b2:	00005517          	auipc	a0,0x5
    800024b6:	d3650513          	addi	a0,a0,-714 # 800071e8 <etext+0x1e8>
    800024ba:	b7dd                	j	800024a0 <state_string+0x28>
			return "RUNNING";
    800024bc:	00005517          	auipc	a0,0x5
    800024c0:	d3c50513          	addi	a0,a0,-708 # 800071f8 <etext+0x1f8>
    800024c4:	bff1                	j	800024a0 <state_string+0x28>
			return "ZOMBIE";
    800024c6:	00005517          	auipc	a0,0x5
    800024ca:	d3a50513          	addi	a0,a0,-710 # 80007200 <etext+0x200>
    800024ce:	bfc9                	j	800024a0 <state_string+0x28>
			return "Unknown";
    800024d0:	00005517          	auipc	a0,0x5
    800024d4:	d3850513          	addi	a0,a0,-712 # 80007208 <etext+0x208>
    800024d8:	b7e1                	j	800024a0 <state_string+0x28>
	switch (state)
    800024da:	00005517          	auipc	a0,0x5
    800024de:	cf650513          	addi	a0,a0,-778 # 800071d0 <etext+0x1d0>
    800024e2:	bf7d                	j	800024a0 <state_string+0x28>

00000000800024e4 <ps>:

// 프로세스 정보 출력
void
ps(int pid)
{
    800024e4:	711d                	addi	sp,sp,-96
    800024e6:	ec86                	sd	ra,88(sp)
    800024e8:	e8a2                	sd	s0,80(sp)
    800024ea:	e4a6                	sd	s1,72(sp)
    800024ec:	e0ca                	sd	s2,64(sp)
    800024ee:	fc4e                	sd	s3,56(sp)
    800024f0:	f852                	sd	s4,48(sp)
    800024f2:	f456                	sd	s5,40(sp)
    800024f4:	f05a                	sd	s6,32(sp)
    800024f6:	ec5e                	sd	s7,24(sp)
    800024f8:	e862                	sd	s8,16(sp)
    800024fa:	1080                	addi	s0,sp,96
    800024fc:	892a                	mv	s2,a0
	struct proc *p;
	uint total_ticks;

	// ps가 출력되는 시점에 얻은 total_ticks 값 출력
	// lock 걸고 -> 값 구하고 -> lock 풀기
	acquire(&tickslock);
    800024fe:	00014517          	auipc	a0,0x14
    80002502:	c2a50513          	addi	a0,a0,-982 # 80016128 <tickslock>
    80002506:	f64fe0ef          	jal	80000c6a <acquire>
	total_ticks = ticks;
    8000250a:	00005497          	auipc	s1,0x5
    8000250e:	4ce4a483          	lw	s1,1230(s1) # 800079d8 <ticks>
	release(&tickslock);
    80002512:	00014517          	auipc	a0,0x14
    80002516:	c1650513          	addi	a0,a0,-1002 # 80016128 <tickslock>
    8000251a:	fe4fe0ef          	jal	80000cfe <release>

	printf("name\tpid\tstate\t\tpriority\truntime/weight\truntime\tvruntime\tvdeadline\tis_eligible\ttick %d\t\n", total_ticks*1000);
    8000251e:	3e800593          	li	a1,1000
    80002522:	029585bb          	mulw	a1,a1,s1
    80002526:	00005517          	auipc	a0,0x5
    8000252a:	cfa50513          	addi	a0,a0,-774 # 80007220 <etext+0x220>
    8000252e:	fcdfd0ef          	jal	800004fa <printf>

	if (pid == 0)
    80002532:	08091363          	bnez	s2,800025b8 <ps+0xd4>
	{
		for (p = proc; p < &proc[NPROC]; p++)
    80002536:	0000e497          	auipc	s1,0xe
    8000253a:	9f248493          	addi	s1,s1,-1550 # 8000ff28 <proc>
		{
			acquire(&p->lock);
			if (p->state != UNUSED)
			{
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
						(p->runtime*1000/p->weight), p->runtime*1000, p->vruntime, p->vdeadline, p->is_eligible ? "true" : "false" );
    8000253e:	3e800b93          	li	s7,1000
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
    80002542:	00005b17          	auipc	s6,0x5
    80002546:	cd6b0b13          	addi	s6,s6,-810 # 80007218 <etext+0x218>
    8000254a:	00005a97          	auipc	s5,0x5
    8000254e:	d36a8a93          	addi	s5,s5,-714 # 80007280 <etext+0x280>
    80002552:	00005c17          	auipc	s8,0x5
    80002556:	cbec0c13          	addi	s8,s8,-834 # 80007210 <etext+0x210>
		for (p = proc; p < &proc[NPROC]; p++)
    8000255a:	00014917          	auipc	s2,0x14
    8000255e:	bce90913          	addi	s2,s2,-1074 # 80016128 <tickslock>
    80002562:	a839                	j	80002580 <ps+0x9c>
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
    80002564:	e432                	sd	a2,8(sp)
    80002566:	e02e                	sd	a1,0(sp)
    80002568:	8652                	mv	a2,s4
    8000256a:	85ce                	mv	a1,s3
    8000256c:	8556                	mv	a0,s5
    8000256e:	f8dfd0ef          	jal	800004fa <printf>
			}
			release(&p->lock);
    80002572:	8526                	mv	a0,s1
    80002574:	f8afe0ef          	jal	80000cfe <release>
		for (p = proc; p < &proc[NPROC]; p++)
    80002578:	18848493          	addi	s1,s1,392
    8000257c:	0d248063          	beq	s1,s2,8000263c <ps+0x158>
			acquire(&p->lock);
    80002580:	8526                	mv	a0,s1
    80002582:	ee8fe0ef          	jal	80000c6a <acquire>
			if (p->state != UNUSED)
    80002586:	4c88                	lw	a0,24(s1)
    80002588:	d56d                	beqz	a0,80002572 <ps+0x8e>
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
    8000258a:	17848993          	addi	s3,s1,376
    8000258e:	0304aa03          	lw	s4,48(s1)
    80002592:	ee7ff0ef          	jal	80002478 <state_string>
    80002596:	86aa                	mv	a3,a0
    80002598:	58d8                	lw	a4,52(s1)
						(p->runtime*1000/p->weight), p->runtime*1000, p->vruntime, p->vdeadline, p->is_eligible ? "true" : "false" );
    8000259a:	03c4a803          	lw	a6,60(s1)
    8000259e:	030b883b          	mulw	a6,s7,a6
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
    800025a2:	5c9c                	lw	a5,56(s1)
    800025a4:	02f847bb          	divw	a5,a6,a5
    800025a8:	0404b883          	ld	a7,64(s1)
    800025ac:	64ac                	ld	a1,72(s1)
    800025ae:	48a8                	lw	a0,80(s1)
    800025b0:	865a                	mv	a2,s6
    800025b2:	d94d                	beqz	a0,80002564 <ps+0x80>
    800025b4:	8662                	mv	a2,s8
    800025b6:	b77d                	j	80002564 <ps+0x80>
		}
	}

	else 
	{
		for (p = proc; p < &proc[NPROC]; p++)
    800025b8:	0000e497          	auipc	s1,0xe
    800025bc:	97048493          	addi	s1,s1,-1680 # 8000ff28 <proc>
		{
			acquire(&p->lock);
			if (p->pid == pid && p->state != UNUSED)
			{
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
						(p->runtime*1000/p->weight), p->runtime*1000, p->vruntime, p->vdeadline, p->is_eligible ? "true" : "false" );
    800025c0:	3e800b13          	li	s6,1000
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
    800025c4:	00005a97          	auipc	s5,0x5
    800025c8:	c54a8a93          	addi	s5,s5,-940 # 80007218 <etext+0x218>
    800025cc:	00005a17          	auipc	s4,0x5
    800025d0:	cb4a0a13          	addi	s4,s4,-844 # 80007280 <etext+0x280>
    800025d4:	00005b97          	auipc	s7,0x5
    800025d8:	c3cb8b93          	addi	s7,s7,-964 # 80007210 <etext+0x210>
		for (p = proc; p < &proc[NPROC]; p++)
    800025dc:	00014997          	auipc	s3,0x14
    800025e0:	b4c98993          	addi	s3,s3,-1204 # 80016128 <tickslock>
    800025e4:	a839                	j	80002602 <ps+0x11e>
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
    800025e6:	e432                	sd	a2,8(sp)
    800025e8:	e02e                	sd	a1,0(sp)
    800025ea:	864a                	mv	a2,s2
    800025ec:	85e2                	mv	a1,s8
    800025ee:	8552                	mv	a0,s4
    800025f0:	f0bfd0ef          	jal	800004fa <printf>

			}
			release(&p->lock);
    800025f4:	8526                	mv	a0,s1
    800025f6:	f08fe0ef          	jal	80000cfe <release>
		for (p = proc; p < &proc[NPROC]; p++)
    800025fa:	18848493          	addi	s1,s1,392
    800025fe:	03348f63          	beq	s1,s3,8000263c <ps+0x158>
			acquire(&p->lock);
    80002602:	8526                	mv	a0,s1
    80002604:	e66fe0ef          	jal	80000c6a <acquire>
			if (p->pid == pid && p->state != UNUSED)
    80002608:	589c                	lw	a5,48(s1)
    8000260a:	ff2795e3          	bne	a5,s2,800025f4 <ps+0x110>
    8000260e:	4c88                	lw	a0,24(s1)
    80002610:	d175                	beqz	a0,800025f4 <ps+0x110>
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
    80002612:	17848c13          	addi	s8,s1,376
    80002616:	e63ff0ef          	jal	80002478 <state_string>
    8000261a:	86aa                	mv	a3,a0
    8000261c:	58d8                	lw	a4,52(s1)
						(p->runtime*1000/p->weight), p->runtime*1000, p->vruntime, p->vdeadline, p->is_eligible ? "true" : "false" );
    8000261e:	03c4a803          	lw	a6,60(s1)
    80002622:	030b083b          	mulw	a6,s6,a6
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
    80002626:	5c9c                	lw	a5,56(s1)
    80002628:	02f847bb          	divw	a5,a6,a5
    8000262c:	0404b883          	ld	a7,64(s1)
    80002630:	64ac                	ld	a1,72(s1)
    80002632:	48a8                	lw	a0,80(s1)
    80002634:	8656                	mv	a2,s5
    80002636:	d945                	beqz	a0,800025e6 <ps+0x102>
    80002638:	865e                	mv	a2,s7
    8000263a:	b775                	j	800025e6 <ps+0x102>
		}
	}

}
    8000263c:	60e6                	ld	ra,88(sp)
    8000263e:	6446                	ld	s0,80(sp)
    80002640:	64a6                	ld	s1,72(sp)
    80002642:	6906                	ld	s2,64(sp)
    80002644:	79e2                	ld	s3,56(sp)
    80002646:	7a42                	ld	s4,48(sp)
    80002648:	7aa2                	ld	s5,40(sp)
    8000264a:	7b02                	ld	s6,32(sp)
    8000264c:	6be2                	ld	s7,24(sp)
    8000264e:	6c42                	ld	s8,16(sp)
    80002650:	6125                	addi	sp,sp,96
    80002652:	8082                	ret

0000000080002654 <meminfo>:

// 사용 가능한 메모리 공간 bytes 출력
uint64
meminfo(void)
{
    80002654:	1141                	addi	sp,sp,-16
    80002656:	e406                	sd	ra,8(sp)
    80002658:	e022                	sd	s0,0(sp)
    8000265a:	0800                	addi	s0,sp,16
	uint64 memsize = 0;
	memsize = freememinfo()*4096;
    8000265c:	cf2fe0ef          	jal	80000b4e <freememinfo>

	return memsize;
}
    80002660:	00c5151b          	slliw	a0,a0,0xc
    80002664:	60a2                	ld	ra,8(sp)
    80002666:	6402                	ld	s0,0(sp)
    80002668:	0141                	addi	sp,sp,16
    8000266a:	8082                	ret

000000008000266c <waitpid>:

// 성공하면 0, 실패하면 -1 return
int 
waitpid(int pid)
{
    8000266c:	715d                	addi	sp,sp,-80
    8000266e:	e486                	sd	ra,72(sp)
    80002670:	e0a2                	sd	s0,64(sp)
    80002672:	fc26                	sd	s1,56(sp)
    80002674:	f84a                	sd	s2,48(sp)
    80002676:	f44e                	sd	s3,40(sp)
    80002678:	f052                	sd	s4,32(sp)
    8000267a:	ec56                	sd	s5,24(sp)
    8000267c:	e85a                	sd	s6,16(sp)
    8000267e:	e45e                	sd	s7,8(sp)
    80002680:	0880                	addi	s0,sp,80
    80002682:	892a                	mv	s2,a0
	// wait()와 동일한데, 특정 프로세스를 대상으로 함
	struct proc *pp; // 자식 프로세스
	struct proc *p = myproc(); // 부모 프로세스
    80002684:	ae0ff0ef          	jal	80001964 <myproc>
    80002688:	8a2a                	mv	s4,a0
	int havekids;
	
	acquire(&wait_lock);
    8000268a:	0000d517          	auipc	a0,0xd
    8000268e:	46e50513          	addi	a0,a0,1134 # 8000faf8 <wait_lock>
    80002692:	dd8fe0ef          	jal	80000c6a <acquire>
			{
				// 자식 찾음
				acquire(&pp->lock);

				havekids = 1;
				if (pp->state == ZOMBIE)
    80002696:	4a95                	li	s5,5
				havekids = 1;
    80002698:	4b05                	li	s6,1
		for (pp = proc; pp < &proc[NPROC]; pp++)
    8000269a:	00014997          	auipc	s3,0x14
    8000269e:	a8e98993          	addi	s3,s3,-1394 # 80016128 <tickslock>
			return -1;
		}

		// 자식 프로세스 있었다는 소리
		// 상태가 zombie가 아니었기 때문에 부모를 sleep 상태로
		sleep(p, &wait_lock);
    800026a2:	0000db97          	auipc	s7,0xd
    800026a6:	456b8b93          	addi	s7,s7,1110 # 8000faf8 <wait_lock>
    800026aa:	a0bd                	j	80002718 <waitpid+0xac>
					freeproc(pp); // 할당되어 있던 자식 프로세스 공간 free
    800026ac:	8526                	mv	a0,s1
    800026ae:	d56ff0ef          	jal	80001c04 <freeproc>
					release(&pp->lock);
    800026b2:	8526                	mv	a0,s1
    800026b4:	e4afe0ef          	jal	80000cfe <release>
					release(&wait_lock);
    800026b8:	0000d517          	auipc	a0,0xd
    800026bc:	44050513          	addi	a0,a0,1088 # 8000faf8 <wait_lock>
    800026c0:	e3efe0ef          	jal	80000cfe <release>
					return 0;
    800026c4:	4501                	li	a0,0
	}
}
    800026c6:	60a6                	ld	ra,72(sp)
    800026c8:	6406                	ld	s0,64(sp)
    800026ca:	74e2                	ld	s1,56(sp)
    800026cc:	7942                	ld	s2,48(sp)
    800026ce:	79a2                	ld	s3,40(sp)
    800026d0:	7a02                	ld	s4,32(sp)
    800026d2:	6ae2                	ld	s5,24(sp)
    800026d4:	6b42                	ld	s6,16(sp)
    800026d6:	6ba2                	ld	s7,8(sp)
    800026d8:	6161                	addi	sp,sp,80
    800026da:	8082                	ret
		for (pp = proc; pp < &proc[NPROC]; pp++)
    800026dc:	18848493          	addi	s1,s1,392
    800026e0:	03348363          	beq	s1,s3,80002706 <waitpid+0x9a>
			if (pp->pid == pid && pp->parent == p)
    800026e4:	589c                	lw	a5,48(s1)
    800026e6:	ff279be3          	bne	a5,s2,800026dc <waitpid+0x70>
    800026ea:	6cbc                	ld	a5,88(s1)
    800026ec:	ff4798e3          	bne	a5,s4,800026dc <waitpid+0x70>
				acquire(&pp->lock);
    800026f0:	8526                	mv	a0,s1
    800026f2:	d78fe0ef          	jal	80000c6a <acquire>
				if (pp->state == ZOMBIE)
    800026f6:	4c9c                	lw	a5,24(s1)
    800026f8:	fb578ae3          	beq	a5,s5,800026ac <waitpid+0x40>
				release(&pp->lock);
    800026fc:	8526                	mv	a0,s1
    800026fe:	e00fe0ef          	jal	80000cfe <release>
				havekids = 1;
    80002702:	875a                	mv	a4,s6
    80002704:	bfe1                	j	800026dc <waitpid+0x70>
		if (havekids == 0 || killed(p))
    80002706:	cf19                	beqz	a4,80002724 <waitpid+0xb8>
    80002708:	8552                	mv	a0,s4
    8000270a:	b81ff0ef          	jal	8000228a <killed>
    8000270e:	e919                	bnez	a0,80002724 <waitpid+0xb8>
		sleep(p, &wait_lock);
    80002710:	85de                	mv	a1,s7
    80002712:	8552                	mv	a0,s4
    80002714:	91dff0ef          	jal	80002030 <sleep>
		havekids = 0;
    80002718:	4701                	li	a4,0
		for (pp = proc; pp < &proc[NPROC]; pp++)
    8000271a:	0000e497          	auipc	s1,0xe
    8000271e:	80e48493          	addi	s1,s1,-2034 # 8000ff28 <proc>
    80002722:	b7c9                	j	800026e4 <waitpid+0x78>
			release(&wait_lock);
    80002724:	0000d517          	auipc	a0,0xd
    80002728:	3d450513          	addi	a0,a0,980 # 8000faf8 <wait_lock>
    8000272c:	dd2fe0ef          	jal	80000cfe <release>
			return -1;
    80002730:	557d                	li	a0,-1
    80002732:	bf51                	j	800026c6 <waitpid+0x5a>

0000000080002734 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002734:	7179                	addi	sp,sp,-48
    80002736:	f406                	sd	ra,40(sp)
    80002738:	f022                	sd	s0,32(sp)
    8000273a:	ec26                	sd	s1,24(sp)
    8000273c:	e84a                	sd	s2,16(sp)
    8000273e:	e44e                	sd	s3,8(sp)
    80002740:	e052                	sd	s4,0(sp)
    80002742:	1800                	addi	s0,sp,48
    80002744:	84aa                	mv	s1,a0
    80002746:	8a2e                	mv	s4,a1
    80002748:	89b2                	mv	s3,a2
    8000274a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000274c:	a18ff0ef          	jal	80001964 <myproc>
  if(user_dst){
    80002750:	cc99                	beqz	s1,8000276e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002752:	86ca                	mv	a3,s2
    80002754:	864e                	mv	a2,s3
    80002756:	85d2                	mv	a1,s4
    80002758:	7928                	ld	a0,112(a0)
    8000275a:	f3dfe0ef          	jal	80001696 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000275e:	70a2                	ld	ra,40(sp)
    80002760:	7402                	ld	s0,32(sp)
    80002762:	64e2                	ld	s1,24(sp)
    80002764:	6942                	ld	s2,16(sp)
    80002766:	69a2                	ld	s3,8(sp)
    80002768:	6a02                	ld	s4,0(sp)
    8000276a:	6145                	addi	sp,sp,48
    8000276c:	8082                	ret
    memmove((char *)dst, src, len);
    8000276e:	0009061b          	sext.w	a2,s2
    80002772:	85ce                	mv	a1,s3
    80002774:	8552                	mv	a0,s4
    80002776:	e24fe0ef          	jal	80000d9a <memmove>
    return 0;
    8000277a:	8526                	mv	a0,s1
    8000277c:	b7cd                	j	8000275e <either_copyout+0x2a>

000000008000277e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000277e:	7179                	addi	sp,sp,-48
    80002780:	f406                	sd	ra,40(sp)
    80002782:	f022                	sd	s0,32(sp)
    80002784:	ec26                	sd	s1,24(sp)
    80002786:	e84a                	sd	s2,16(sp)
    80002788:	e44e                	sd	s3,8(sp)
    8000278a:	e052                	sd	s4,0(sp)
    8000278c:	1800                	addi	s0,sp,48
    8000278e:	8a2a                	mv	s4,a0
    80002790:	84ae                	mv	s1,a1
    80002792:	89b2                	mv	s3,a2
    80002794:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002796:	9ceff0ef          	jal	80001964 <myproc>
  if(user_src){
    8000279a:	cc99                	beqz	s1,800027b8 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000279c:	86ca                	mv	a3,s2
    8000279e:	864e                	mv	a2,s3
    800027a0:	85d2                	mv	a1,s4
    800027a2:	7928                	ld	a0,112(a0)
    800027a4:	fb1fe0ef          	jal	80001754 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800027a8:	70a2                	ld	ra,40(sp)
    800027aa:	7402                	ld	s0,32(sp)
    800027ac:	64e2                	ld	s1,24(sp)
    800027ae:	6942                	ld	s2,16(sp)
    800027b0:	69a2                	ld	s3,8(sp)
    800027b2:	6a02                	ld	s4,0(sp)
    800027b4:	6145                	addi	sp,sp,48
    800027b6:	8082                	ret
    memmove(dst, (char*)src, len);
    800027b8:	0009061b          	sext.w	a2,s2
    800027bc:	85ce                	mv	a1,s3
    800027be:	8552                	mv	a0,s4
    800027c0:	ddafe0ef          	jal	80000d9a <memmove>
    return 0;
    800027c4:	8526                	mv	a0,s1
    800027c6:	b7cd                	j	800027a8 <either_copyin+0x2a>

00000000800027c8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027c8:	715d                	addi	sp,sp,-80
    800027ca:	e486                	sd	ra,72(sp)
    800027cc:	e0a2                	sd	s0,64(sp)
    800027ce:	fc26                	sd	s1,56(sp)
    800027d0:	f84a                	sd	s2,48(sp)
    800027d2:	f44e                	sd	s3,40(sp)
    800027d4:	f052                	sd	s4,32(sp)
    800027d6:	ec56                	sd	s5,24(sp)
    800027d8:	e85a                	sd	s6,16(sp)
    800027da:	e45e                	sd	s7,8(sp)
    800027dc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027de:	00005517          	auipc	a0,0x5
    800027e2:	89a50513          	addi	a0,a0,-1894 # 80007078 <etext+0x78>
    800027e6:	d15fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ea:	0000e497          	auipc	s1,0xe
    800027ee:	8b648493          	addi	s1,s1,-1866 # 800100a0 <proc+0x178>
    800027f2:	00014917          	auipc	s2,0x14
    800027f6:	aae90913          	addi	s2,s2,-1362 # 800162a0 <bcache+0x160>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027fa:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027fc:	00005997          	auipc	s3,0x5
    80002800:	aa498993          	addi	s3,s3,-1372 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002804:	00005a97          	auipc	s5,0x5
    80002808:	aa4a8a93          	addi	s5,s5,-1372 # 800072a8 <etext+0x2a8>
    printf("\n");
    8000280c:	00005a17          	auipc	s4,0x5
    80002810:	86ca0a13          	addi	s4,s4,-1940 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002814:	00005b97          	auipc	s7,0x5
    80002818:	fccb8b93          	addi	s7,s7,-52 # 800077e0 <states.0>
    8000281c:	a829                	j	80002836 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000281e:	eb86a583          	lw	a1,-328(a3)
    80002822:	8556                	mv	a0,s5
    80002824:	cd7fd0ef          	jal	800004fa <printf>
    printf("\n");
    80002828:	8552                	mv	a0,s4
    8000282a:	cd1fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000282e:	18848493          	addi	s1,s1,392
    80002832:	03248263          	beq	s1,s2,80002856 <procdump+0x8e>
    if(p->state == UNUSED)
    80002836:	86a6                	mv	a3,s1
    80002838:	ea04a783          	lw	a5,-352(s1)
    8000283c:	dbed                	beqz	a5,8000282e <procdump+0x66>
      state = "???";
    8000283e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002840:	fcfb6fe3          	bltu	s6,a5,8000281e <procdump+0x56>
    80002844:	02079713          	slli	a4,a5,0x20
    80002848:	01d75793          	srli	a5,a4,0x1d
    8000284c:	97de                	add	a5,a5,s7
    8000284e:	6390                	ld	a2,0(a5)
    80002850:	f679                	bnez	a2,8000281e <procdump+0x56>
      state = "???";
    80002852:	864e                	mv	a2,s3
    80002854:	b7e9                	j	8000281e <procdump+0x56>
  }
}
    80002856:	60a6                	ld	ra,72(sp)
    80002858:	6406                	ld	s0,64(sp)
    8000285a:	74e2                	ld	s1,56(sp)
    8000285c:	7942                	ld	s2,48(sp)
    8000285e:	79a2                	ld	s3,40(sp)
    80002860:	7a02                	ld	s4,32(sp)
    80002862:	6ae2                	ld	s5,24(sp)
    80002864:	6b42                	ld	s6,16(sp)
    80002866:	6ba2                	ld	s7,8(sp)
    80002868:	6161                	addi	sp,sp,80
    8000286a:	8082                	ret

000000008000286c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000286c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002870:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002874:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002876:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002878:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000287c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002880:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002884:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002888:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000288c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002890:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002894:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002898:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000289c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800028a0:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800028a4:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800028a8:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800028aa:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800028ac:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800028b0:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800028b4:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800028b8:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800028bc:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800028c0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800028c4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800028c8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800028cc:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800028d0:	0685bd83          	ld	s11,104(a1)
        
        ret
    800028d4:	8082                	ret

00000000800028d6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028d6:	1141                	addi	sp,sp,-16
    800028d8:	e406                	sd	ra,8(sp)
    800028da:	e022                	sd	s0,0(sp)
    800028dc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028de:	00005597          	auipc	a1,0x5
    800028e2:	a0a58593          	addi	a1,a1,-1526 # 800072e8 <etext+0x2e8>
    800028e6:	00014517          	auipc	a0,0x14
    800028ea:	84250513          	addi	a0,a0,-1982 # 80016128 <tickslock>
    800028ee:	af2fe0ef          	jal	80000be0 <initlock>
}
    800028f2:	60a2                	ld	ra,8(sp)
    800028f4:	6402                	ld	s0,0(sp)
    800028f6:	0141                	addi	sp,sp,16
    800028f8:	8082                	ret

00000000800028fa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028fa:	1141                	addi	sp,sp,-16
    800028fc:	e406                	sd	ra,8(sp)
    800028fe:	e022                	sd	s0,0(sp)
    80002900:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002902:	00003797          	auipc	a5,0x3
    80002906:	07e78793          	addi	a5,a5,126 # 80005980 <kernelvec>
    8000290a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000290e:	60a2                	ld	ra,8(sp)
    80002910:	6402                	ld	s0,0(sp)
    80002912:	0141                	addi	sp,sp,16
    80002914:	8082                	ret

0000000080002916 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002916:	1141                	addi	sp,sp,-16
    80002918:	e406                	sd	ra,8(sp)
    8000291a:	e022                	sd	s0,0(sp)
    8000291c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000291e:	846ff0ef          	jal	80001964 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002922:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002926:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002928:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000292c:	04000737          	lui	a4,0x4000
    80002930:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002932:	0732                	slli	a4,a4,0xc
    80002934:	00003797          	auipc	a5,0x3
    80002938:	6cc78793          	addi	a5,a5,1740 # 80006000 <_trampoline>
    8000293c:	00003697          	auipc	a3,0x3
    80002940:	6c468693          	addi	a3,a3,1732 # 80006000 <_trampoline>
    80002944:	8f95                	sub	a5,a5,a3
    80002946:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002948:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000294c:	7d3c                	ld	a5,120(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000294e:	18002773          	csrr	a4,satp
    80002952:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002954:	7d38                	ld	a4,120(a0)
    80002956:	713c                	ld	a5,96(a0)
    80002958:	6685                	lui	a3,0x1
    8000295a:	97b6                	add	a5,a5,a3
    8000295c:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000295e:	7d3c                	ld	a5,120(a0)
    80002960:	00000717          	auipc	a4,0x0
    80002964:	13a70713          	addi	a4,a4,314 # 80002a9a <usertrap>
    80002968:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000296a:	7d3c                	ld	a5,120(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000296c:	8712                	mv	a4,tp
    8000296e:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002970:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002974:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002978:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000297c:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002980:	7d3c                	ld	a5,120(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002982:	6f9c                	ld	a5,24(a5)
    80002984:	14179073          	csrw	sepc,a5
}
    80002988:	60a2                	ld	ra,8(sp)
    8000298a:	6402                	ld	s0,0(sp)
    8000298c:	0141                	addi	sp,sp,16
    8000298e:	8082                	ret

0000000080002990 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002990:	1141                	addi	sp,sp,-16
    80002992:	e406                	sd	ra,8(sp)
    80002994:	e022                	sd	s0,0(sp)
    80002996:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002998:	f99fe0ef          	jal	80001930 <cpuid>
    8000299c:	cd09                	beqz	a0,800029b6 <clockintr+0x26>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000299e:	c01027f3          	rdtime	a5
    }
  }

  // ask for the next timer interrupt.
  // 100000로 수정
  w_stimecmp(r_time() + 100000);
    800029a2:	6761                	lui	a4,0x18
    800029a4:	6a070713          	addi	a4,a4,1696 # 186a0 <_entry-0x7ffe7960>
    800029a8:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800029aa:	14d79073          	csrw	stimecmp,a5
}
    800029ae:	60a2                	ld	ra,8(sp)
    800029b0:	6402                	ld	s0,0(sp)
    800029b2:	0141                	addi	sp,sp,16
    800029b4:	8082                	ret
    acquire(&tickslock);
    800029b6:	00013517          	auipc	a0,0x13
    800029ba:	77250513          	addi	a0,a0,1906 # 80016128 <tickslock>
    800029be:	aacfe0ef          	jal	80000c6a <acquire>
    ticks++;
    800029c2:	00005717          	auipc	a4,0x5
    800029c6:	01670713          	addi	a4,a4,22 # 800079d8 <ticks>
    800029ca:	431c                	lw	a5,0(a4)
    800029cc:	2785                	addiw	a5,a5,1
    800029ce:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800029d0:	853a                	mv	a0,a4
    800029d2:	eaaff0ef          	jal	8000207c <wakeup>
    release(&tickslock);
    800029d6:	00013517          	auipc	a0,0x13
    800029da:	75250513          	addi	a0,a0,1874 # 80016128 <tickslock>
    800029de:	b20fe0ef          	jal	80000cfe <release>
    struct proc *p = myproc();
    800029e2:	f83fe0ef          	jal	80001964 <myproc>
    if (p && p->state == RUNNING)
    800029e6:	dd45                	beqz	a0,8000299e <clockintr+0xe>
    800029e8:	4d18                	lw	a4,24(a0)
    800029ea:	4791                	li	a5,4
    800029ec:	faf719e3          	bne	a4,a5,8000299e <clockintr+0xe>
	    p->runtime++;
    800029f0:	5d5c                	lw	a5,60(a0)
    800029f2:	2785                	addiw	a5,a5,1
    800029f4:	dd5c                	sw	a5,60(a0)
	    p->vruntime += (1*1000*1024)/p->weight;
    800029f6:	5d14                	lw	a3,56(a0)
    800029f8:	000fa7b7          	lui	a5,0xfa
    800029fc:	02d7c7bb          	divw	a5,a5,a3
    80002a00:	6138                	ld	a4,64(a0)
    80002a02:	97ba                	add	a5,a5,a4
    80002a04:	e13c                	sd	a5,64(a0)
	    p->remain_time--;
    80002a06:	4978                	lw	a4,84(a0)
    80002a08:	377d                	addiw	a4,a4,-1
    80002a0a:	c978                	sw	a4,84(a0)
	    if (p->remain_time == 0)
    80002a0c:	fb49                	bnez	a4,8000299e <clockintr+0xe>
		    p->vdeadline = p->vruntime + (5*1000*1024)/p->weight;
    80002a0e:	004e2737          	lui	a4,0x4e2
    80002a12:	02d7473b          	divw	a4,a4,a3
    80002a16:	97ba                	add	a5,a5,a4
    80002a18:	e53c                	sd	a5,72(a0)
		    p->remain_time = 5;
    80002a1a:	4795                	li	a5,5
    80002a1c:	c97c                	sw	a5,84(a0)
		    yield();
    80002a1e:	db6ff0ef          	jal	80001fd4 <yield>
    80002a22:	bfb5                	j	8000299e <clockintr+0xe>

0000000080002a24 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a24:	1101                	addi	sp,sp,-32
    80002a26:	ec06                	sd	ra,24(sp)
    80002a28:	e822                	sd	s0,16(sp)
    80002a2a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a2c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a30:	57fd                	li	a5,-1
    80002a32:	17fe                	slli	a5,a5,0x3f
    80002a34:	07a5                	addi	a5,a5,9 # fa009 <_entry-0x7ff05ff7>
    80002a36:	00f70c63          	beq	a4,a5,80002a4e <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a3a:	57fd                	li	a5,-1
    80002a3c:	17fe                	slli	a5,a5,0x3f
    80002a3e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a40:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a42:	04f70863          	beq	a4,a5,80002a92 <devintr+0x6e>
  }
}
    80002a46:	60e2                	ld	ra,24(sp)
    80002a48:	6442                	ld	s0,16(sp)
    80002a4a:	6105                	addi	sp,sp,32
    80002a4c:	8082                	ret
    80002a4e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002a50:	7dd020ef          	jal	80005a2c <plic_claim>
    80002a54:	872a                	mv	a4,a0
    80002a56:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a58:	47a9                	li	a5,10
    80002a5a:	00f50963          	beq	a0,a5,80002a6c <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002a5e:	4785                	li	a5,1
    80002a60:	00f50963          	beq	a0,a5,80002a72 <devintr+0x4e>
    return 1;
    80002a64:	4505                	li	a0,1
    } else if(irq){
    80002a66:	eb09                	bnez	a4,80002a78 <devintr+0x54>
    80002a68:	64a2                	ld	s1,8(sp)
    80002a6a:	bff1                	j	80002a46 <devintr+0x22>
      uartintr();
    80002a6c:	f89fd0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002a70:	a819                	j	80002a86 <devintr+0x62>
      virtio_disk_intr();
    80002a72:	450030ef          	jal	80005ec2 <virtio_disk_intr>
    if(irq)
    80002a76:	a801                	j	80002a86 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a78:	85ba                	mv	a1,a4
    80002a7a:	00005517          	auipc	a0,0x5
    80002a7e:	87650513          	addi	a0,a0,-1930 # 800072f0 <etext+0x2f0>
    80002a82:	a79fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002a86:	8526                	mv	a0,s1
    80002a88:	7c5020ef          	jal	80005a4c <plic_complete>
    return 1;
    80002a8c:	4505                	li	a0,1
    80002a8e:	64a2                	ld	s1,8(sp)
    80002a90:	bf5d                	j	80002a46 <devintr+0x22>
    clockintr();
    80002a92:	effff0ef          	jal	80002990 <clockintr>
    return 2;
    80002a96:	4509                	li	a0,2
    80002a98:	b77d                	j	80002a46 <devintr+0x22>

0000000080002a9a <usertrap>:
{
    80002a9a:	1101                	addi	sp,sp,-32
    80002a9c:	ec06                	sd	ra,24(sp)
    80002a9e:	e822                	sd	s0,16(sp)
    80002aa0:	e426                	sd	s1,8(sp)
    80002aa2:	e04a                	sd	s2,0(sp)
    80002aa4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aa6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002aaa:	1007f793          	andi	a5,a5,256
    80002aae:	eba5                	bnez	a5,80002b1e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ab0:	00003797          	auipc	a5,0x3
    80002ab4:	ed078793          	addi	a5,a5,-304 # 80005980 <kernelvec>
    80002ab8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002abc:	ea9fe0ef          	jal	80001964 <myproc>
    80002ac0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ac2:	7d3c                	ld	a5,120(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ac4:	14102773          	csrr	a4,sepc
    80002ac8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aca:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002ace:	47a1                	li	a5,8
    80002ad0:	04f70d63          	beq	a4,a5,80002b2a <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002ad4:	f51ff0ef          	jal	80002a24 <devintr>
    80002ad8:	892a                	mv	s2,a0
    80002ada:	e945                	bnez	a0,80002b8a <usertrap+0xf0>
    80002adc:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002ae0:	47bd                	li	a5,15
    80002ae2:	08f70863          	beq	a4,a5,80002b72 <usertrap+0xd8>
    80002ae6:	14202773          	csrr	a4,scause
    80002aea:	47b5                	li	a5,13
    80002aec:	08f70363          	beq	a4,a5,80002b72 <usertrap+0xd8>
    80002af0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002af4:	5890                	lw	a2,48(s1)
    80002af6:	00005517          	auipc	a0,0x5
    80002afa:	83a50513          	addi	a0,a0,-1990 # 80007330 <etext+0x330>
    80002afe:	9fdfd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b02:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b06:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002b0a:	00005517          	auipc	a0,0x5
    80002b0e:	85650513          	addi	a0,a0,-1962 # 80007360 <etext+0x360>
    80002b12:	9e9fd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002b16:	8526                	mv	a0,s1
    80002b18:	f4eff0ef          	jal	80002266 <setkilled>
    80002b1c:	a035                	j	80002b48 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002b1e:	00004517          	auipc	a0,0x4
    80002b22:	7f250513          	addi	a0,a0,2034 # 80007310 <etext+0x310>
    80002b26:	cfffd0ef          	jal	80000824 <panic>
    if(killed(p))
    80002b2a:	f60ff0ef          	jal	8000228a <killed>
    80002b2e:	ed15                	bnez	a0,80002b6a <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002b30:	7cb8                	ld	a4,120(s1)
    80002b32:	6f1c                	ld	a5,24(a4)
    80002b34:	0791                	addi	a5,a5,4
    80002b36:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b38:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b3c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b40:	10079073          	csrw	sstatus,a5
    syscall();
    80002b44:	240000ef          	jal	80002d84 <syscall>
  if(killed(p))
    80002b48:	8526                	mv	a0,s1
    80002b4a:	f40ff0ef          	jal	8000228a <killed>
    80002b4e:	e139                	bnez	a0,80002b94 <usertrap+0xfa>
  prepare_return();
    80002b50:	dc7ff0ef          	jal	80002916 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b54:	78a8                	ld	a0,112(s1)
    80002b56:	8131                	srli	a0,a0,0xc
    80002b58:	57fd                	li	a5,-1
    80002b5a:	17fe                	slli	a5,a5,0x3f
    80002b5c:	8d5d                	or	a0,a0,a5
}
    80002b5e:	60e2                	ld	ra,24(sp)
    80002b60:	6442                	ld	s0,16(sp)
    80002b62:	64a2                	ld	s1,8(sp)
    80002b64:	6902                	ld	s2,0(sp)
    80002b66:	6105                	addi	sp,sp,32
    80002b68:	8082                	ret
      kexit(-1);
    80002b6a:	557d                	li	a0,-1
    80002b6c:	deeff0ef          	jal	8000215a <kexit>
    80002b70:	b7c1                	j	80002b30 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b72:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b76:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002b7a:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002b7c:	00163613          	seqz	a2,a2
    80002b80:	78a8                	ld	a0,112(s1)
    80002b82:	a91fe0ef          	jal	80001612 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002b86:	f169                	bnez	a0,80002b48 <usertrap+0xae>
    80002b88:	b7a5                	j	80002af0 <usertrap+0x56>
  if(killed(p))
    80002b8a:	8526                	mv	a0,s1
    80002b8c:	efeff0ef          	jal	8000228a <killed>
    80002b90:	c511                	beqz	a0,80002b9c <usertrap+0x102>
    80002b92:	a011                	j	80002b96 <usertrap+0xfc>
    80002b94:	4901                	li	s2,0
    kexit(-1);
    80002b96:	557d                	li	a0,-1
    80002b98:	dc2ff0ef          	jal	8000215a <kexit>
  if(which_dev == 2)
    80002b9c:	4789                	li	a5,2
    80002b9e:	faf919e3          	bne	s2,a5,80002b50 <usertrap+0xb6>
    yield();
    80002ba2:	c32ff0ef          	jal	80001fd4 <yield>
    80002ba6:	b76d                	j	80002b50 <usertrap+0xb6>

0000000080002ba8 <kerneltrap>:
{
    80002ba8:	7179                	addi	sp,sp,-48
    80002baa:	f406                	sd	ra,40(sp)
    80002bac:	f022                	sd	s0,32(sp)
    80002bae:	ec26                	sd	s1,24(sp)
    80002bb0:	e84a                	sd	s2,16(sp)
    80002bb2:	e44e                	sd	s3,8(sp)
    80002bb4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bb6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bba:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bbe:	142027f3          	csrr	a5,scause
    80002bc2:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002bc4:	1004f793          	andi	a5,s1,256
    80002bc8:	c795                	beqz	a5,80002bf4 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bca:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bce:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bd0:	eb85                	bnez	a5,80002c00 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002bd2:	e53ff0ef          	jal	80002a24 <devintr>
    80002bd6:	c91d                	beqz	a0,80002c0c <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002bd8:	4789                	li	a5,2
    80002bda:	04f50a63          	beq	a0,a5,80002c2e <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bde:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002be2:	10049073          	csrw	sstatus,s1
}
    80002be6:	70a2                	ld	ra,40(sp)
    80002be8:	7402                	ld	s0,32(sp)
    80002bea:	64e2                	ld	s1,24(sp)
    80002bec:	6942                	ld	s2,16(sp)
    80002bee:	69a2                	ld	s3,8(sp)
    80002bf0:	6145                	addi	sp,sp,48
    80002bf2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bf4:	00004517          	auipc	a0,0x4
    80002bf8:	79450513          	addi	a0,a0,1940 # 80007388 <etext+0x388>
    80002bfc:	c29fd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c00:	00004517          	auipc	a0,0x4
    80002c04:	7b050513          	addi	a0,a0,1968 # 800073b0 <etext+0x3b0>
    80002c08:	c1dfd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c10:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002c14:	85ce                	mv	a1,s3
    80002c16:	00004517          	auipc	a0,0x4
    80002c1a:	7ba50513          	addi	a0,a0,1978 # 800073d0 <etext+0x3d0>
    80002c1e:	8ddfd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002c22:	00004517          	auipc	a0,0x4
    80002c26:	7d650513          	addi	a0,a0,2006 # 800073f8 <etext+0x3f8>
    80002c2a:	bfbfd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c2e:	d37fe0ef          	jal	80001964 <myproc>
    80002c32:	d555                	beqz	a0,80002bde <kerneltrap+0x36>
    yield();
    80002c34:	ba0ff0ef          	jal	80001fd4 <yield>
    80002c38:	b75d                	j	80002bde <kerneltrap+0x36>

0000000080002c3a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c3a:	1101                	addi	sp,sp,-32
    80002c3c:	ec06                	sd	ra,24(sp)
    80002c3e:	e822                	sd	s0,16(sp)
    80002c40:	e426                	sd	s1,8(sp)
    80002c42:	1000                	addi	s0,sp,32
    80002c44:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c46:	d1ffe0ef          	jal	80001964 <myproc>
  switch (n) {
    80002c4a:	4795                	li	a5,5
    80002c4c:	0497e163          	bltu	a5,s1,80002c8e <argraw+0x54>
    80002c50:	048a                	slli	s1,s1,0x2
    80002c52:	00005717          	auipc	a4,0x5
    80002c56:	bbe70713          	addi	a4,a4,-1090 # 80007810 <states.0+0x30>
    80002c5a:	94ba                	add	s1,s1,a4
    80002c5c:	409c                	lw	a5,0(s1)
    80002c5e:	97ba                	add	a5,a5,a4
    80002c60:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c62:	7d3c                	ld	a5,120(a0)
    80002c64:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c66:	60e2                	ld	ra,24(sp)
    80002c68:	6442                	ld	s0,16(sp)
    80002c6a:	64a2                	ld	s1,8(sp)
    80002c6c:	6105                	addi	sp,sp,32
    80002c6e:	8082                	ret
    return p->trapframe->a1;
    80002c70:	7d3c                	ld	a5,120(a0)
    80002c72:	7fa8                	ld	a0,120(a5)
    80002c74:	bfcd                	j	80002c66 <argraw+0x2c>
    return p->trapframe->a2;
    80002c76:	7d3c                	ld	a5,120(a0)
    80002c78:	63c8                	ld	a0,128(a5)
    80002c7a:	b7f5                	j	80002c66 <argraw+0x2c>
    return p->trapframe->a3;
    80002c7c:	7d3c                	ld	a5,120(a0)
    80002c7e:	67c8                	ld	a0,136(a5)
    80002c80:	b7dd                	j	80002c66 <argraw+0x2c>
    return p->trapframe->a4;
    80002c82:	7d3c                	ld	a5,120(a0)
    80002c84:	6bc8                	ld	a0,144(a5)
    80002c86:	b7c5                	j	80002c66 <argraw+0x2c>
    return p->trapframe->a5;
    80002c88:	7d3c                	ld	a5,120(a0)
    80002c8a:	6fc8                	ld	a0,152(a5)
    80002c8c:	bfe9                	j	80002c66 <argraw+0x2c>
  panic("argraw");
    80002c8e:	00004517          	auipc	a0,0x4
    80002c92:	77a50513          	addi	a0,a0,1914 # 80007408 <etext+0x408>
    80002c96:	b8ffd0ef          	jal	80000824 <panic>

0000000080002c9a <fetchaddr>:
{
    80002c9a:	1101                	addi	sp,sp,-32
    80002c9c:	ec06                	sd	ra,24(sp)
    80002c9e:	e822                	sd	s0,16(sp)
    80002ca0:	e426                	sd	s1,8(sp)
    80002ca2:	e04a                	sd	s2,0(sp)
    80002ca4:	1000                	addi	s0,sp,32
    80002ca6:	84aa                	mv	s1,a0
    80002ca8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002caa:	cbbfe0ef          	jal	80001964 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cae:	753c                	ld	a5,104(a0)
    80002cb0:	02f4f663          	bgeu	s1,a5,80002cdc <fetchaddr+0x42>
    80002cb4:	00848713          	addi	a4,s1,8
    80002cb8:	02e7e463          	bltu	a5,a4,80002ce0 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cbc:	46a1                	li	a3,8
    80002cbe:	8626                	mv	a2,s1
    80002cc0:	85ca                	mv	a1,s2
    80002cc2:	7928                	ld	a0,112(a0)
    80002cc4:	a91fe0ef          	jal	80001754 <copyin>
    80002cc8:	00a03533          	snez	a0,a0
    80002ccc:	40a0053b          	negw	a0,a0
}
    80002cd0:	60e2                	ld	ra,24(sp)
    80002cd2:	6442                	ld	s0,16(sp)
    80002cd4:	64a2                	ld	s1,8(sp)
    80002cd6:	6902                	ld	s2,0(sp)
    80002cd8:	6105                	addi	sp,sp,32
    80002cda:	8082                	ret
    return -1;
    80002cdc:	557d                	li	a0,-1
    80002cde:	bfcd                	j	80002cd0 <fetchaddr+0x36>
    80002ce0:	557d                	li	a0,-1
    80002ce2:	b7fd                	j	80002cd0 <fetchaddr+0x36>

0000000080002ce4 <fetchstr>:
{
    80002ce4:	7179                	addi	sp,sp,-48
    80002ce6:	f406                	sd	ra,40(sp)
    80002ce8:	f022                	sd	s0,32(sp)
    80002cea:	ec26                	sd	s1,24(sp)
    80002cec:	e84a                	sd	s2,16(sp)
    80002cee:	e44e                	sd	s3,8(sp)
    80002cf0:	1800                	addi	s0,sp,48
    80002cf2:	89aa                	mv	s3,a0
    80002cf4:	84ae                	mv	s1,a1
    80002cf6:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002cf8:	c6dfe0ef          	jal	80001964 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cfc:	86ca                	mv	a3,s2
    80002cfe:	864e                	mv	a2,s3
    80002d00:	85a6                	mv	a1,s1
    80002d02:	7928                	ld	a0,112(a0)
    80002d04:	837fe0ef          	jal	8000153a <copyinstr>
    80002d08:	00054c63          	bltz	a0,80002d20 <fetchstr+0x3c>
  return strlen(buf);
    80002d0c:	8526                	mv	a0,s1
    80002d0e:	9b6fe0ef          	jal	80000ec4 <strlen>
}
    80002d12:	70a2                	ld	ra,40(sp)
    80002d14:	7402                	ld	s0,32(sp)
    80002d16:	64e2                	ld	s1,24(sp)
    80002d18:	6942                	ld	s2,16(sp)
    80002d1a:	69a2                	ld	s3,8(sp)
    80002d1c:	6145                	addi	sp,sp,48
    80002d1e:	8082                	ret
    return -1;
    80002d20:	557d                	li	a0,-1
    80002d22:	bfc5                	j	80002d12 <fetchstr+0x2e>

0000000080002d24 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d24:	1101                	addi	sp,sp,-32
    80002d26:	ec06                	sd	ra,24(sp)
    80002d28:	e822                	sd	s0,16(sp)
    80002d2a:	e426                	sd	s1,8(sp)
    80002d2c:	1000                	addi	s0,sp,32
    80002d2e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d30:	f0bff0ef          	jal	80002c3a <argraw>
    80002d34:	c088                	sw	a0,0(s1)
}
    80002d36:	60e2                	ld	ra,24(sp)
    80002d38:	6442                	ld	s0,16(sp)
    80002d3a:	64a2                	ld	s1,8(sp)
    80002d3c:	6105                	addi	sp,sp,32
    80002d3e:	8082                	ret

0000000080002d40 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d40:	1101                	addi	sp,sp,-32
    80002d42:	ec06                	sd	ra,24(sp)
    80002d44:	e822                	sd	s0,16(sp)
    80002d46:	e426                	sd	s1,8(sp)
    80002d48:	1000                	addi	s0,sp,32
    80002d4a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d4c:	eefff0ef          	jal	80002c3a <argraw>
    80002d50:	e088                	sd	a0,0(s1)
}
    80002d52:	60e2                	ld	ra,24(sp)
    80002d54:	6442                	ld	s0,16(sp)
    80002d56:	64a2                	ld	s1,8(sp)
    80002d58:	6105                	addi	sp,sp,32
    80002d5a:	8082                	ret

0000000080002d5c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d5c:	1101                	addi	sp,sp,-32
    80002d5e:	ec06                	sd	ra,24(sp)
    80002d60:	e822                	sd	s0,16(sp)
    80002d62:	e426                	sd	s1,8(sp)
    80002d64:	e04a                	sd	s2,0(sp)
    80002d66:	1000                	addi	s0,sp,32
    80002d68:	892e                	mv	s2,a1
    80002d6a:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002d6c:	ecfff0ef          	jal	80002c3a <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002d70:	8626                	mv	a2,s1
    80002d72:	85ca                	mv	a1,s2
    80002d74:	f71ff0ef          	jal	80002ce4 <fetchstr>
}
    80002d78:	60e2                	ld	ra,24(sp)
    80002d7a:	6442                	ld	s0,16(sp)
    80002d7c:	64a2                	ld	s1,8(sp)
    80002d7e:	6902                	ld	s2,0(sp)
    80002d80:	6105                	addi	sp,sp,32
    80002d82:	8082                	ret

0000000080002d84 <syscall>:
[SYS_waitpid]   sys_waitpid,
};

void
syscall(void)
{
    80002d84:	1101                	addi	sp,sp,-32
    80002d86:	ec06                	sd	ra,24(sp)
    80002d88:	e822                	sd	s0,16(sp)
    80002d8a:	e426                	sd	s1,8(sp)
    80002d8c:	e04a                	sd	s2,0(sp)
    80002d8e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d90:	bd5fe0ef          	jal	80001964 <myproc>
    80002d94:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d96:	07853903          	ld	s2,120(a0)
    80002d9a:	0a893783          	ld	a5,168(s2)
    80002d9e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002da2:	37fd                	addiw	a5,a5,-1
    80002da4:	4765                	li	a4,25
    80002da6:	00f76f63          	bltu	a4,a5,80002dc4 <syscall+0x40>
    80002daa:	00369713          	slli	a4,a3,0x3
    80002dae:	00005797          	auipc	a5,0x5
    80002db2:	a7a78793          	addi	a5,a5,-1414 # 80007828 <syscalls>
    80002db6:	97ba                	add	a5,a5,a4
    80002db8:	639c                	ld	a5,0(a5)
    80002dba:	c789                	beqz	a5,80002dc4 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002dbc:	9782                	jalr	a5
    80002dbe:	06a93823          	sd	a0,112(s2)
    80002dc2:	a829                	j	80002ddc <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002dc4:	17848613          	addi	a2,s1,376
    80002dc8:	588c                	lw	a1,48(s1)
    80002dca:	00004517          	auipc	a0,0x4
    80002dce:	64650513          	addi	a0,a0,1606 # 80007410 <etext+0x410>
    80002dd2:	f28fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dd6:	7cbc                	ld	a5,120(s1)
    80002dd8:	577d                	li	a4,-1
    80002dda:	fbb8                	sd	a4,112(a5)
  }
}
    80002ddc:	60e2                	ld	ra,24(sp)
    80002dde:	6442                	ld	s0,16(sp)
    80002de0:	64a2                	ld	s1,8(sp)
    80002de2:	6902                	ld	s2,0(sp)
    80002de4:	6105                	addi	sp,sp,32
    80002de6:	8082                	ret

0000000080002de8 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002de8:	1101                	addi	sp,sp,-32
    80002dea:	ec06                	sd	ra,24(sp)
    80002dec:	e822                	sd	s0,16(sp)
    80002dee:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002df0:	fec40593          	addi	a1,s0,-20
    80002df4:	4501                	li	a0,0
    80002df6:	f2fff0ef          	jal	80002d24 <argint>
  kexit(n);
    80002dfa:	fec42503          	lw	a0,-20(s0)
    80002dfe:	b5cff0ef          	jal	8000215a <kexit>
  return 0;  // not reached
}
    80002e02:	4501                	li	a0,0
    80002e04:	60e2                	ld	ra,24(sp)
    80002e06:	6442                	ld	s0,16(sp)
    80002e08:	6105                	addi	sp,sp,32
    80002e0a:	8082                	ret

0000000080002e0c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e0c:	1141                	addi	sp,sp,-16
    80002e0e:	e406                	sd	ra,8(sp)
    80002e10:	e022                	sd	s0,0(sp)
    80002e12:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e14:	b51fe0ef          	jal	80001964 <myproc>
}
    80002e18:	5908                	lw	a0,48(a0)
    80002e1a:	60a2                	ld	ra,8(sp)
    80002e1c:	6402                	ld	s0,0(sp)
    80002e1e:	0141                	addi	sp,sp,16
    80002e20:	8082                	ret

0000000080002e22 <sys_fork>:

uint64
sys_fork(void)
{
    80002e22:	1141                	addi	sp,sp,-16
    80002e24:	e406                	sd	ra,8(sp)
    80002e26:	e022                	sd	s0,0(sp)
    80002e28:	0800                	addi	s0,sp,16
  return kfork();
    80002e2a:	ecbfe0ef          	jal	80001cf4 <kfork>
}
    80002e2e:	60a2                	ld	ra,8(sp)
    80002e30:	6402                	ld	s0,0(sp)
    80002e32:	0141                	addi	sp,sp,16
    80002e34:	8082                	ret

0000000080002e36 <sys_wait>:

uint64
sys_wait(void)
{
    80002e36:	1101                	addi	sp,sp,-32
    80002e38:	ec06                	sd	ra,24(sp)
    80002e3a:	e822                	sd	s0,16(sp)
    80002e3c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e3e:	fe840593          	addi	a1,s0,-24
    80002e42:	4501                	li	a0,0
    80002e44:	efdff0ef          	jal	80002d40 <argaddr>
  return kwait(p);
    80002e48:	fe843503          	ld	a0,-24(s0)
    80002e4c:	c68ff0ef          	jal	800022b4 <kwait>
}
    80002e50:	60e2                	ld	ra,24(sp)
    80002e52:	6442                	ld	s0,16(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret

0000000080002e58 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e58:	7179                	addi	sp,sp,-48
    80002e5a:	f406                	sd	ra,40(sp)
    80002e5c:	f022                	sd	s0,32(sp)
    80002e5e:	ec26                	sd	s1,24(sp)
    80002e60:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002e62:	fd840593          	addi	a1,s0,-40
    80002e66:	4501                	li	a0,0
    80002e68:	ebdff0ef          	jal	80002d24 <argint>
  argint(1, &t);
    80002e6c:	fdc40593          	addi	a1,s0,-36
    80002e70:	4505                	li	a0,1
    80002e72:	eb3ff0ef          	jal	80002d24 <argint>
  addr = myproc()->sz;
    80002e76:	aeffe0ef          	jal	80001964 <myproc>
    80002e7a:	7524                	ld	s1,104(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002e7c:	fdc42703          	lw	a4,-36(s0)
    80002e80:	4785                	li	a5,1
    80002e82:	02f70163          	beq	a4,a5,80002ea4 <sys_sbrk+0x4c>
    80002e86:	fd842783          	lw	a5,-40(s0)
    80002e8a:	0007cd63          	bltz	a5,80002ea4 <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002e8e:	97a6                	add	a5,a5,s1
    80002e90:	0297e863          	bltu	a5,s1,80002ec0 <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80002e94:	ad1fe0ef          	jal	80001964 <myproc>
    80002e98:	fd842703          	lw	a4,-40(s0)
    80002e9c:	753c                	ld	a5,104(a0)
    80002e9e:	97ba                	add	a5,a5,a4
    80002ea0:	f53c                	sd	a5,104(a0)
    80002ea2:	a039                	j	80002eb0 <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80002ea4:	fd842503          	lw	a0,-40(s0)
    80002ea8:	dfdfe0ef          	jal	80001ca4 <growproc>
    80002eac:	00054863          	bltz	a0,80002ebc <sys_sbrk+0x64>
  }
  return addr;
}
    80002eb0:	8526                	mv	a0,s1
    80002eb2:	70a2                	ld	ra,40(sp)
    80002eb4:	7402                	ld	s0,32(sp)
    80002eb6:	64e2                	ld	s1,24(sp)
    80002eb8:	6145                	addi	sp,sp,48
    80002eba:	8082                	ret
      return -1;
    80002ebc:	54fd                	li	s1,-1
    80002ebe:	bfcd                	j	80002eb0 <sys_sbrk+0x58>
      return -1;
    80002ec0:	54fd                	li	s1,-1
    80002ec2:	b7fd                	j	80002eb0 <sys_sbrk+0x58>

0000000080002ec4 <sys_pause>:

uint64
sys_pause(void)
{
    80002ec4:	7139                	addi	sp,sp,-64
    80002ec6:	fc06                	sd	ra,56(sp)
    80002ec8:	f822                	sd	s0,48(sp)
    80002eca:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ecc:	fcc40593          	addi	a1,s0,-52
    80002ed0:	4501                	li	a0,0
    80002ed2:	e53ff0ef          	jal	80002d24 <argint>
  if(n < 0)
    80002ed6:	fcc42783          	lw	a5,-52(s0)
    80002eda:	0607c863          	bltz	a5,80002f4a <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002ede:	00013517          	auipc	a0,0x13
    80002ee2:	24a50513          	addi	a0,a0,586 # 80016128 <tickslock>
    80002ee6:	d85fd0ef          	jal	80000c6a <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002eea:	fcc42783          	lw	a5,-52(s0)
    80002eee:	c3b9                	beqz	a5,80002f34 <sys_pause+0x70>
    80002ef0:	f426                	sd	s1,40(sp)
    80002ef2:	f04a                	sd	s2,32(sp)
    80002ef4:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002ef6:	00005997          	auipc	s3,0x5
    80002efa:	ae29a983          	lw	s3,-1310(s3) # 800079d8 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002efe:	00013917          	auipc	s2,0x13
    80002f02:	22a90913          	addi	s2,s2,554 # 80016128 <tickslock>
    80002f06:	00005497          	auipc	s1,0x5
    80002f0a:	ad248493          	addi	s1,s1,-1326 # 800079d8 <ticks>
    if(killed(myproc())){
    80002f0e:	a57fe0ef          	jal	80001964 <myproc>
    80002f12:	b78ff0ef          	jal	8000228a <killed>
    80002f16:	ed0d                	bnez	a0,80002f50 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002f18:	85ca                	mv	a1,s2
    80002f1a:	8526                	mv	a0,s1
    80002f1c:	914ff0ef          	jal	80002030 <sleep>
  while(ticks - ticks0 < n){
    80002f20:	409c                	lw	a5,0(s1)
    80002f22:	413787bb          	subw	a5,a5,s3
    80002f26:	fcc42703          	lw	a4,-52(s0)
    80002f2a:	fee7e2e3          	bltu	a5,a4,80002f0e <sys_pause+0x4a>
    80002f2e:	74a2                	ld	s1,40(sp)
    80002f30:	7902                	ld	s2,32(sp)
    80002f32:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f34:	00013517          	auipc	a0,0x13
    80002f38:	1f450513          	addi	a0,a0,500 # 80016128 <tickslock>
    80002f3c:	dc3fd0ef          	jal	80000cfe <release>
  return 0;
    80002f40:	4501                	li	a0,0
}
    80002f42:	70e2                	ld	ra,56(sp)
    80002f44:	7442                	ld	s0,48(sp)
    80002f46:	6121                	addi	sp,sp,64
    80002f48:	8082                	ret
    n = 0;
    80002f4a:	fc042623          	sw	zero,-52(s0)
    80002f4e:	bf41                	j	80002ede <sys_pause+0x1a>
      release(&tickslock);
    80002f50:	00013517          	auipc	a0,0x13
    80002f54:	1d850513          	addi	a0,a0,472 # 80016128 <tickslock>
    80002f58:	da7fd0ef          	jal	80000cfe <release>
      return -1;
    80002f5c:	557d                	li	a0,-1
    80002f5e:	74a2                	ld	s1,40(sp)
    80002f60:	7902                	ld	s2,32(sp)
    80002f62:	69e2                	ld	s3,24(sp)
    80002f64:	bff9                	j	80002f42 <sys_pause+0x7e>

0000000080002f66 <sys_kill>:

uint64
sys_kill(void)
{
    80002f66:	1101                	addi	sp,sp,-32
    80002f68:	ec06                	sd	ra,24(sp)
    80002f6a:	e822                	sd	s0,16(sp)
    80002f6c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f6e:	fec40593          	addi	a1,s0,-20
    80002f72:	4501                	li	a0,0
    80002f74:	db1ff0ef          	jal	80002d24 <argint>
  return kkill(pid);
    80002f78:	fec42503          	lw	a0,-20(s0)
    80002f7c:	a84ff0ef          	jal	80002200 <kkill>
}
    80002f80:	60e2                	ld	ra,24(sp)
    80002f82:	6442                	ld	s0,16(sp)
    80002f84:	6105                	addi	sp,sp,32
    80002f86:	8082                	ret

0000000080002f88 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f88:	1101                	addi	sp,sp,-32
    80002f8a:	ec06                	sd	ra,24(sp)
    80002f8c:	e822                	sd	s0,16(sp)
    80002f8e:	e426                	sd	s1,8(sp)
    80002f90:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f92:	00013517          	auipc	a0,0x13
    80002f96:	19650513          	addi	a0,a0,406 # 80016128 <tickslock>
    80002f9a:	cd1fd0ef          	jal	80000c6a <acquire>
  xticks = ticks;
    80002f9e:	00005797          	auipc	a5,0x5
    80002fa2:	a3a7a783          	lw	a5,-1478(a5) # 800079d8 <ticks>
    80002fa6:	84be                	mv	s1,a5
  release(&tickslock);
    80002fa8:	00013517          	auipc	a0,0x13
    80002fac:	18050513          	addi	a0,a0,384 # 80016128 <tickslock>
    80002fb0:	d4ffd0ef          	jal	80000cfe <release>
  return xticks;
}
    80002fb4:	02049513          	slli	a0,s1,0x20
    80002fb8:	9101                	srli	a0,a0,0x20
    80002fba:	60e2                	ld	ra,24(sp)
    80002fbc:	6442                	ld	s0,16(sp)
    80002fbe:	64a2                	ld	s1,8(sp)
    80002fc0:	6105                	addi	sp,sp,32
    80002fc2:	8082                	ret

0000000080002fc4 <sys_getnice>:

// proc.c로 이동-> syscall 실행
uint64
sys_getnice(void)
{
    80002fc4:	1101                	addi	sp,sp,-32
    80002fc6:	ec06                	sd	ra,24(sp)
    80002fc8:	e822                	sd	s0,16(sp)
    80002fca:	1000                	addi	s0,sp,32
	int pid;

	argint(0, &pid);
    80002fcc:	fec40593          	addi	a1,s0,-20
    80002fd0:	4501                	li	a0,0
    80002fd2:	d53ff0ef          	jal	80002d24 <argint>
	return getnice(pid);
    80002fd6:	fec42503          	lw	a0,-20(s0)
    80002fda:	bceff0ef          	jal	800023a8 <getnice>
}
    80002fde:	60e2                	ld	ra,24(sp)
    80002fe0:	6442                	ld	s0,16(sp)
    80002fe2:	6105                	addi	sp,sp,32
    80002fe4:	8082                	ret

0000000080002fe6 <sys_setnice>:

uint64
sys_setnice()
{
    80002fe6:	1101                	addi	sp,sp,-32
    80002fe8:	ec06                	sd	ra,24(sp)
    80002fea:	e822                	sd	s0,16(sp)
    80002fec:	1000                	addi	s0,sp,32
	int pid, value;

	argint(0, &pid);
    80002fee:	fec40593          	addi	a1,s0,-20
    80002ff2:	4501                	li	a0,0
    80002ff4:	d31ff0ef          	jal	80002d24 <argint>
	argint(1, &value);
    80002ff8:	fe840593          	addi	a1,s0,-24
    80002ffc:	4505                	li	a0,1
    80002ffe:	d27ff0ef          	jal	80002d24 <argint>
	return setnice(pid, value);
    80003002:	fe842583          	lw	a1,-24(s0)
    80003006:	fec42503          	lw	a0,-20(s0)
    8000300a:	bf6ff0ef          	jal	80002400 <setnice>
}
    8000300e:	60e2                	ld	ra,24(sp)
    80003010:	6442                	ld	s0,16(sp)
    80003012:	6105                	addi	sp,sp,32
    80003014:	8082                	ret

0000000080003016 <sys_ps>:

uint64
sys_ps()
{
    80003016:	1101                	addi	sp,sp,-32
    80003018:	ec06                	sd	ra,24(sp)
    8000301a:	e822                	sd	s0,16(sp)
    8000301c:	1000                	addi	s0,sp,32
	int pid;

	argint(0, &pid);
    8000301e:	fec40593          	addi	a1,s0,-20
    80003022:	4501                	li	a0,0
    80003024:	d01ff0ef          	jal	80002d24 <argint>
	ps(pid); // ps는 return 값이 없으므로 실행만
    80003028:	fec42503          	lw	a0,-20(s0)
    8000302c:	cb8ff0ef          	jal	800024e4 <ps>
	return 0; // 성공적으로 실행 완료
}
    80003030:	4501                	li	a0,0
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	6105                	addi	sp,sp,32
    80003038:	8082                	ret

000000008000303a <sys_meminfo>:

uint64
sys_meminfo()
{
    8000303a:	1141                	addi	sp,sp,-16
    8000303c:	e406                	sd	ra,8(sp)
    8000303e:	e022                	sd	s0,0(sp)
    80003040:	0800                	addi	s0,sp,16
	return freememinfo(); // meminfo는 freememinfo() 함수 실행해야 함
    80003042:	b0dfd0ef          	jal	80000b4e <freememinfo>
}
    80003046:	60a2                	ld	ra,8(sp)
    80003048:	6402                	ld	s0,0(sp)
    8000304a:	0141                	addi	sp,sp,16
    8000304c:	8082                	ret

000000008000304e <sys_waitpid>:

uint64
sys_waitpid()
{
    8000304e:	1101                	addi	sp,sp,-32
    80003050:	ec06                	sd	ra,24(sp)
    80003052:	e822                	sd	s0,16(sp)
    80003054:	1000                	addi	s0,sp,32
	int pid;

	argint(0, &pid);
    80003056:	fec40593          	addi	a1,s0,-20
    8000305a:	4501                	li	a0,0
    8000305c:	cc9ff0ef          	jal	80002d24 <argint>
	return waitpid(pid);
    80003060:	fec42503          	lw	a0,-20(s0)
    80003064:	e08ff0ef          	jal	8000266c <waitpid>
}
    80003068:	60e2                	ld	ra,24(sp)
    8000306a:	6442                	ld	s0,16(sp)
    8000306c:	6105                	addi	sp,sp,32
    8000306e:	8082                	ret

0000000080003070 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003070:	7179                	addi	sp,sp,-48
    80003072:	f406                	sd	ra,40(sp)
    80003074:	f022                	sd	s0,32(sp)
    80003076:	ec26                	sd	s1,24(sp)
    80003078:	e84a                	sd	s2,16(sp)
    8000307a:	e44e                	sd	s3,8(sp)
    8000307c:	e052                	sd	s4,0(sp)
    8000307e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003080:	00004597          	auipc	a1,0x4
    80003084:	3b058593          	addi	a1,a1,944 # 80007430 <etext+0x430>
    80003088:	00013517          	auipc	a0,0x13
    8000308c:	0b850513          	addi	a0,a0,184 # 80016140 <bcache>
    80003090:	b51fd0ef          	jal	80000be0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003094:	0001b797          	auipc	a5,0x1b
    80003098:	0ac78793          	addi	a5,a5,172 # 8001e140 <bcache+0x8000>
    8000309c:	0001b717          	auipc	a4,0x1b
    800030a0:	30c70713          	addi	a4,a4,780 # 8001e3a8 <bcache+0x8268>
    800030a4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030a8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ac:	00013497          	auipc	s1,0x13
    800030b0:	0ac48493          	addi	s1,s1,172 # 80016158 <bcache+0x18>
    b->next = bcache.head.next;
    800030b4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030b6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030b8:	00004a17          	auipc	s4,0x4
    800030bc:	380a0a13          	addi	s4,s4,896 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    800030c0:	2b893783          	ld	a5,696(s2)
    800030c4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030c6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030ca:	85d2                	mv	a1,s4
    800030cc:	01048513          	addi	a0,s1,16
    800030d0:	328010ef          	jal	800043f8 <initsleeplock>
    bcache.head.next->prev = b;
    800030d4:	2b893783          	ld	a5,696(s2)
    800030d8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030da:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030de:	45848493          	addi	s1,s1,1112
    800030e2:	fd349fe3          	bne	s1,s3,800030c0 <binit+0x50>
  }
}
    800030e6:	70a2                	ld	ra,40(sp)
    800030e8:	7402                	ld	s0,32(sp)
    800030ea:	64e2                	ld	s1,24(sp)
    800030ec:	6942                	ld	s2,16(sp)
    800030ee:	69a2                	ld	s3,8(sp)
    800030f0:	6a02                	ld	s4,0(sp)
    800030f2:	6145                	addi	sp,sp,48
    800030f4:	8082                	ret

00000000800030f6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030f6:	7179                	addi	sp,sp,-48
    800030f8:	f406                	sd	ra,40(sp)
    800030fa:	f022                	sd	s0,32(sp)
    800030fc:	ec26                	sd	s1,24(sp)
    800030fe:	e84a                	sd	s2,16(sp)
    80003100:	e44e                	sd	s3,8(sp)
    80003102:	1800                	addi	s0,sp,48
    80003104:	892a                	mv	s2,a0
    80003106:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003108:	00013517          	auipc	a0,0x13
    8000310c:	03850513          	addi	a0,a0,56 # 80016140 <bcache>
    80003110:	b5bfd0ef          	jal	80000c6a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003114:	0001b497          	auipc	s1,0x1b
    80003118:	2e44b483          	ld	s1,740(s1) # 8001e3f8 <bcache+0x82b8>
    8000311c:	0001b797          	auipc	a5,0x1b
    80003120:	28c78793          	addi	a5,a5,652 # 8001e3a8 <bcache+0x8268>
    80003124:	02f48b63          	beq	s1,a5,8000315a <bread+0x64>
    80003128:	873e                	mv	a4,a5
    8000312a:	a021                	j	80003132 <bread+0x3c>
    8000312c:	68a4                	ld	s1,80(s1)
    8000312e:	02e48663          	beq	s1,a4,8000315a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003132:	449c                	lw	a5,8(s1)
    80003134:	ff279ce3          	bne	a5,s2,8000312c <bread+0x36>
    80003138:	44dc                	lw	a5,12(s1)
    8000313a:	ff3799e3          	bne	a5,s3,8000312c <bread+0x36>
      b->refcnt++;
    8000313e:	40bc                	lw	a5,64(s1)
    80003140:	2785                	addiw	a5,a5,1
    80003142:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003144:	00013517          	auipc	a0,0x13
    80003148:	ffc50513          	addi	a0,a0,-4 # 80016140 <bcache>
    8000314c:	bb3fd0ef          	jal	80000cfe <release>
      acquiresleep(&b->lock);
    80003150:	01048513          	addi	a0,s1,16
    80003154:	2da010ef          	jal	8000442e <acquiresleep>
      return b;
    80003158:	a889                	j	800031aa <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000315a:	0001b497          	auipc	s1,0x1b
    8000315e:	2964b483          	ld	s1,662(s1) # 8001e3f0 <bcache+0x82b0>
    80003162:	0001b797          	auipc	a5,0x1b
    80003166:	24678793          	addi	a5,a5,582 # 8001e3a8 <bcache+0x8268>
    8000316a:	00f48863          	beq	s1,a5,8000317a <bread+0x84>
    8000316e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003170:	40bc                	lw	a5,64(s1)
    80003172:	cb91                	beqz	a5,80003186 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003174:	64a4                	ld	s1,72(s1)
    80003176:	fee49de3          	bne	s1,a4,80003170 <bread+0x7a>
  panic("bget: no buffers");
    8000317a:	00004517          	auipc	a0,0x4
    8000317e:	2c650513          	addi	a0,a0,710 # 80007440 <etext+0x440>
    80003182:	ea2fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80003186:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000318a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000318e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003192:	4785                	li	a5,1
    80003194:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003196:	00013517          	auipc	a0,0x13
    8000319a:	faa50513          	addi	a0,a0,-86 # 80016140 <bcache>
    8000319e:	b61fd0ef          	jal	80000cfe <release>
      acquiresleep(&b->lock);
    800031a2:	01048513          	addi	a0,s1,16
    800031a6:	288010ef          	jal	8000442e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031aa:	409c                	lw	a5,0(s1)
    800031ac:	cb89                	beqz	a5,800031be <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031ae:	8526                	mv	a0,s1
    800031b0:	70a2                	ld	ra,40(sp)
    800031b2:	7402                	ld	s0,32(sp)
    800031b4:	64e2                	ld	s1,24(sp)
    800031b6:	6942                	ld	s2,16(sp)
    800031b8:	69a2                	ld	s3,8(sp)
    800031ba:	6145                	addi	sp,sp,48
    800031bc:	8082                	ret
    virtio_disk_rw(b, 0);
    800031be:	4581                	li	a1,0
    800031c0:	8526                	mv	a0,s1
    800031c2:	2ef020ef          	jal	80005cb0 <virtio_disk_rw>
    b->valid = 1;
    800031c6:	4785                	li	a5,1
    800031c8:	c09c                	sw	a5,0(s1)
  return b;
    800031ca:	b7d5                	j	800031ae <bread+0xb8>

00000000800031cc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031cc:	1101                	addi	sp,sp,-32
    800031ce:	ec06                	sd	ra,24(sp)
    800031d0:	e822                	sd	s0,16(sp)
    800031d2:	e426                	sd	s1,8(sp)
    800031d4:	1000                	addi	s0,sp,32
    800031d6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031d8:	0541                	addi	a0,a0,16
    800031da:	2d2010ef          	jal	800044ac <holdingsleep>
    800031de:	c911                	beqz	a0,800031f2 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031e0:	4585                	li	a1,1
    800031e2:	8526                	mv	a0,s1
    800031e4:	2cd020ef          	jal	80005cb0 <virtio_disk_rw>
}
    800031e8:	60e2                	ld	ra,24(sp)
    800031ea:	6442                	ld	s0,16(sp)
    800031ec:	64a2                	ld	s1,8(sp)
    800031ee:	6105                	addi	sp,sp,32
    800031f0:	8082                	ret
    panic("bwrite");
    800031f2:	00004517          	auipc	a0,0x4
    800031f6:	26650513          	addi	a0,a0,614 # 80007458 <etext+0x458>
    800031fa:	e2afd0ef          	jal	80000824 <panic>

00000000800031fe <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031fe:	1101                	addi	sp,sp,-32
    80003200:	ec06                	sd	ra,24(sp)
    80003202:	e822                	sd	s0,16(sp)
    80003204:	e426                	sd	s1,8(sp)
    80003206:	e04a                	sd	s2,0(sp)
    80003208:	1000                	addi	s0,sp,32
    8000320a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000320c:	01050913          	addi	s2,a0,16
    80003210:	854a                	mv	a0,s2
    80003212:	29a010ef          	jal	800044ac <holdingsleep>
    80003216:	c125                	beqz	a0,80003276 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80003218:	854a                	mv	a0,s2
    8000321a:	25a010ef          	jal	80004474 <releasesleep>

  acquire(&bcache.lock);
    8000321e:	00013517          	auipc	a0,0x13
    80003222:	f2250513          	addi	a0,a0,-222 # 80016140 <bcache>
    80003226:	a45fd0ef          	jal	80000c6a <acquire>
  b->refcnt--;
    8000322a:	40bc                	lw	a5,64(s1)
    8000322c:	37fd                	addiw	a5,a5,-1
    8000322e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003230:	e79d                	bnez	a5,8000325e <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003232:	68b8                	ld	a4,80(s1)
    80003234:	64bc                	ld	a5,72(s1)
    80003236:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003238:	68b8                	ld	a4,80(s1)
    8000323a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000323c:	0001b797          	auipc	a5,0x1b
    80003240:	f0478793          	addi	a5,a5,-252 # 8001e140 <bcache+0x8000>
    80003244:	2b87b703          	ld	a4,696(a5)
    80003248:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000324a:	0001b717          	auipc	a4,0x1b
    8000324e:	15e70713          	addi	a4,a4,350 # 8001e3a8 <bcache+0x8268>
    80003252:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003254:	2b87b703          	ld	a4,696(a5)
    80003258:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000325a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000325e:	00013517          	auipc	a0,0x13
    80003262:	ee250513          	addi	a0,a0,-286 # 80016140 <bcache>
    80003266:	a99fd0ef          	jal	80000cfe <release>
}
    8000326a:	60e2                	ld	ra,24(sp)
    8000326c:	6442                	ld	s0,16(sp)
    8000326e:	64a2                	ld	s1,8(sp)
    80003270:	6902                	ld	s2,0(sp)
    80003272:	6105                	addi	sp,sp,32
    80003274:	8082                	ret
    panic("brelse");
    80003276:	00004517          	auipc	a0,0x4
    8000327a:	1ea50513          	addi	a0,a0,490 # 80007460 <etext+0x460>
    8000327e:	da6fd0ef          	jal	80000824 <panic>

0000000080003282 <bpin>:

void
bpin(struct buf *b) {
    80003282:	1101                	addi	sp,sp,-32
    80003284:	ec06                	sd	ra,24(sp)
    80003286:	e822                	sd	s0,16(sp)
    80003288:	e426                	sd	s1,8(sp)
    8000328a:	1000                	addi	s0,sp,32
    8000328c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000328e:	00013517          	auipc	a0,0x13
    80003292:	eb250513          	addi	a0,a0,-334 # 80016140 <bcache>
    80003296:	9d5fd0ef          	jal	80000c6a <acquire>
  b->refcnt++;
    8000329a:	40bc                	lw	a5,64(s1)
    8000329c:	2785                	addiw	a5,a5,1
    8000329e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032a0:	00013517          	auipc	a0,0x13
    800032a4:	ea050513          	addi	a0,a0,-352 # 80016140 <bcache>
    800032a8:	a57fd0ef          	jal	80000cfe <release>
}
    800032ac:	60e2                	ld	ra,24(sp)
    800032ae:	6442                	ld	s0,16(sp)
    800032b0:	64a2                	ld	s1,8(sp)
    800032b2:	6105                	addi	sp,sp,32
    800032b4:	8082                	ret

00000000800032b6 <bunpin>:

void
bunpin(struct buf *b) {
    800032b6:	1101                	addi	sp,sp,-32
    800032b8:	ec06                	sd	ra,24(sp)
    800032ba:	e822                	sd	s0,16(sp)
    800032bc:	e426                	sd	s1,8(sp)
    800032be:	1000                	addi	s0,sp,32
    800032c0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032c2:	00013517          	auipc	a0,0x13
    800032c6:	e7e50513          	addi	a0,a0,-386 # 80016140 <bcache>
    800032ca:	9a1fd0ef          	jal	80000c6a <acquire>
  b->refcnt--;
    800032ce:	40bc                	lw	a5,64(s1)
    800032d0:	37fd                	addiw	a5,a5,-1
    800032d2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032d4:	00013517          	auipc	a0,0x13
    800032d8:	e6c50513          	addi	a0,a0,-404 # 80016140 <bcache>
    800032dc:	a23fd0ef          	jal	80000cfe <release>
}
    800032e0:	60e2                	ld	ra,24(sp)
    800032e2:	6442                	ld	s0,16(sp)
    800032e4:	64a2                	ld	s1,8(sp)
    800032e6:	6105                	addi	sp,sp,32
    800032e8:	8082                	ret

00000000800032ea <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032ea:	1101                	addi	sp,sp,-32
    800032ec:	ec06                	sd	ra,24(sp)
    800032ee:	e822                	sd	s0,16(sp)
    800032f0:	e426                	sd	s1,8(sp)
    800032f2:	e04a                	sd	s2,0(sp)
    800032f4:	1000                	addi	s0,sp,32
    800032f6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032f8:	00d5d79b          	srliw	a5,a1,0xd
    800032fc:	0001b597          	auipc	a1,0x1b
    80003300:	5205a583          	lw	a1,1312(a1) # 8001e81c <sb+0x1c>
    80003304:	9dbd                	addw	a1,a1,a5
    80003306:	df1ff0ef          	jal	800030f6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000330a:	0074f713          	andi	a4,s1,7
    8000330e:	4785                	li	a5,1
    80003310:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003314:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003316:	90d9                	srli	s1,s1,0x36
    80003318:	00950733          	add	a4,a0,s1
    8000331c:	05874703          	lbu	a4,88(a4)
    80003320:	00e7f6b3          	and	a3,a5,a4
    80003324:	c29d                	beqz	a3,8000334a <bfree+0x60>
    80003326:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003328:	94aa                	add	s1,s1,a0
    8000332a:	fff7c793          	not	a5,a5
    8000332e:	8f7d                	and	a4,a4,a5
    80003330:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003334:	000010ef          	jal	80004334 <log_write>
  brelse(bp);
    80003338:	854a                	mv	a0,s2
    8000333a:	ec5ff0ef          	jal	800031fe <brelse>
}
    8000333e:	60e2                	ld	ra,24(sp)
    80003340:	6442                	ld	s0,16(sp)
    80003342:	64a2                	ld	s1,8(sp)
    80003344:	6902                	ld	s2,0(sp)
    80003346:	6105                	addi	sp,sp,32
    80003348:	8082                	ret
    panic("freeing free block");
    8000334a:	00004517          	auipc	a0,0x4
    8000334e:	11e50513          	addi	a0,a0,286 # 80007468 <etext+0x468>
    80003352:	cd2fd0ef          	jal	80000824 <panic>

0000000080003356 <balloc>:
{
    80003356:	715d                	addi	sp,sp,-80
    80003358:	e486                	sd	ra,72(sp)
    8000335a:	e0a2                	sd	s0,64(sp)
    8000335c:	fc26                	sd	s1,56(sp)
    8000335e:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003360:	0001b797          	auipc	a5,0x1b
    80003364:	4a47a783          	lw	a5,1188(a5) # 8001e804 <sb+0x4>
    80003368:	0e078263          	beqz	a5,8000344c <balloc+0xf6>
    8000336c:	f84a                	sd	s2,48(sp)
    8000336e:	f44e                	sd	s3,40(sp)
    80003370:	f052                	sd	s4,32(sp)
    80003372:	ec56                	sd	s5,24(sp)
    80003374:	e85a                	sd	s6,16(sp)
    80003376:	e45e                	sd	s7,8(sp)
    80003378:	e062                	sd	s8,0(sp)
    8000337a:	8baa                	mv	s7,a0
    8000337c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000337e:	0001bb17          	auipc	s6,0x1b
    80003382:	482b0b13          	addi	s6,s6,1154 # 8001e800 <sb>
      m = 1 << (bi % 8);
    80003386:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003388:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000338a:	6c09                	lui	s8,0x2
    8000338c:	a09d                	j	800033f2 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000338e:	97ca                	add	a5,a5,s2
    80003390:	8e55                	or	a2,a2,a3
    80003392:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003396:	854a                	mv	a0,s2
    80003398:	79d000ef          	jal	80004334 <log_write>
        brelse(bp);
    8000339c:	854a                	mv	a0,s2
    8000339e:	e61ff0ef          	jal	800031fe <brelse>
  bp = bread(dev, bno);
    800033a2:	85a6                	mv	a1,s1
    800033a4:	855e                	mv	a0,s7
    800033a6:	d51ff0ef          	jal	800030f6 <bread>
    800033aa:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033ac:	40000613          	li	a2,1024
    800033b0:	4581                	li	a1,0
    800033b2:	05850513          	addi	a0,a0,88
    800033b6:	985fd0ef          	jal	80000d3a <memset>
  log_write(bp);
    800033ba:	854a                	mv	a0,s2
    800033bc:	779000ef          	jal	80004334 <log_write>
  brelse(bp);
    800033c0:	854a                	mv	a0,s2
    800033c2:	e3dff0ef          	jal	800031fe <brelse>
}
    800033c6:	7942                	ld	s2,48(sp)
    800033c8:	79a2                	ld	s3,40(sp)
    800033ca:	7a02                	ld	s4,32(sp)
    800033cc:	6ae2                	ld	s5,24(sp)
    800033ce:	6b42                	ld	s6,16(sp)
    800033d0:	6ba2                	ld	s7,8(sp)
    800033d2:	6c02                	ld	s8,0(sp)
}
    800033d4:	8526                	mv	a0,s1
    800033d6:	60a6                	ld	ra,72(sp)
    800033d8:	6406                	ld	s0,64(sp)
    800033da:	74e2                	ld	s1,56(sp)
    800033dc:	6161                	addi	sp,sp,80
    800033de:	8082                	ret
    brelse(bp);
    800033e0:	854a                	mv	a0,s2
    800033e2:	e1dff0ef          	jal	800031fe <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033e6:	015c0abb          	addw	s5,s8,s5
    800033ea:	004b2783          	lw	a5,4(s6)
    800033ee:	04faf863          	bgeu	s5,a5,8000343e <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    800033f2:	40dad59b          	sraiw	a1,s5,0xd
    800033f6:	01cb2783          	lw	a5,28(s6)
    800033fa:	9dbd                	addw	a1,a1,a5
    800033fc:	855e                	mv	a0,s7
    800033fe:	cf9ff0ef          	jal	800030f6 <bread>
    80003402:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003404:	004b2503          	lw	a0,4(s6)
    80003408:	84d6                	mv	s1,s5
    8000340a:	4701                	li	a4,0
    8000340c:	fca4fae3          	bgeu	s1,a0,800033e0 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003410:	00777693          	andi	a3,a4,7
    80003414:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003418:	41f7579b          	sraiw	a5,a4,0x1f
    8000341c:	01d7d79b          	srliw	a5,a5,0x1d
    80003420:	9fb9                	addw	a5,a5,a4
    80003422:	4037d79b          	sraiw	a5,a5,0x3
    80003426:	00f90633          	add	a2,s2,a5
    8000342a:	05864603          	lbu	a2,88(a2)
    8000342e:	00c6f5b3          	and	a1,a3,a2
    80003432:	ddb1                	beqz	a1,8000338e <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003434:	2705                	addiw	a4,a4,1
    80003436:	2485                	addiw	s1,s1,1
    80003438:	fd471ae3          	bne	a4,s4,8000340c <balloc+0xb6>
    8000343c:	b755                	j	800033e0 <balloc+0x8a>
    8000343e:	7942                	ld	s2,48(sp)
    80003440:	79a2                	ld	s3,40(sp)
    80003442:	7a02                	ld	s4,32(sp)
    80003444:	6ae2                	ld	s5,24(sp)
    80003446:	6b42                	ld	s6,16(sp)
    80003448:	6ba2                	ld	s7,8(sp)
    8000344a:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    8000344c:	00004517          	auipc	a0,0x4
    80003450:	03450513          	addi	a0,a0,52 # 80007480 <etext+0x480>
    80003454:	8a6fd0ef          	jal	800004fa <printf>
  return 0;
    80003458:	4481                	li	s1,0
    8000345a:	bfad                	j	800033d4 <balloc+0x7e>

000000008000345c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000345c:	7179                	addi	sp,sp,-48
    8000345e:	f406                	sd	ra,40(sp)
    80003460:	f022                	sd	s0,32(sp)
    80003462:	ec26                	sd	s1,24(sp)
    80003464:	e84a                	sd	s2,16(sp)
    80003466:	e44e                	sd	s3,8(sp)
    80003468:	1800                	addi	s0,sp,48
    8000346a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000346c:	47ad                	li	a5,11
    8000346e:	02b7e363          	bltu	a5,a1,80003494 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80003472:	02059793          	slli	a5,a1,0x20
    80003476:	01e7d593          	srli	a1,a5,0x1e
    8000347a:	00b509b3          	add	s3,a0,a1
    8000347e:	0509a483          	lw	s1,80(s3)
    80003482:	e0b5                	bnez	s1,800034e6 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003484:	4108                	lw	a0,0(a0)
    80003486:	ed1ff0ef          	jal	80003356 <balloc>
    8000348a:	84aa                	mv	s1,a0
      if(addr == 0)
    8000348c:	cd29                	beqz	a0,800034e6 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000348e:	04a9a823          	sw	a0,80(s3)
    80003492:	a891                	j	800034e6 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003494:	ff45879b          	addiw	a5,a1,-12
    80003498:	873e                	mv	a4,a5
    8000349a:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    8000349c:	0ff00793          	li	a5,255
    800034a0:	06e7e763          	bltu	a5,a4,8000350e <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800034a4:	08052483          	lw	s1,128(a0)
    800034a8:	e891                	bnez	s1,800034bc <bmap+0x60>
      addr = balloc(ip->dev);
    800034aa:	4108                	lw	a0,0(a0)
    800034ac:	eabff0ef          	jal	80003356 <balloc>
    800034b0:	84aa                	mv	s1,a0
      if(addr == 0)
    800034b2:	c915                	beqz	a0,800034e6 <bmap+0x8a>
    800034b4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034b6:	08a92023          	sw	a0,128(s2)
    800034ba:	a011                	j	800034be <bmap+0x62>
    800034bc:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800034be:	85a6                	mv	a1,s1
    800034c0:	00092503          	lw	a0,0(s2)
    800034c4:	c33ff0ef          	jal	800030f6 <bread>
    800034c8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034ca:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034ce:	02099713          	slli	a4,s3,0x20
    800034d2:	01e75593          	srli	a1,a4,0x1e
    800034d6:	97ae                	add	a5,a5,a1
    800034d8:	89be                	mv	s3,a5
    800034da:	4384                	lw	s1,0(a5)
    800034dc:	cc89                	beqz	s1,800034f6 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800034de:	8552                	mv	a0,s4
    800034e0:	d1fff0ef          	jal	800031fe <brelse>
    return addr;
    800034e4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800034e6:	8526                	mv	a0,s1
    800034e8:	70a2                	ld	ra,40(sp)
    800034ea:	7402                	ld	s0,32(sp)
    800034ec:	64e2                	ld	s1,24(sp)
    800034ee:	6942                	ld	s2,16(sp)
    800034f0:	69a2                	ld	s3,8(sp)
    800034f2:	6145                	addi	sp,sp,48
    800034f4:	8082                	ret
      addr = balloc(ip->dev);
    800034f6:	00092503          	lw	a0,0(s2)
    800034fa:	e5dff0ef          	jal	80003356 <balloc>
    800034fe:	84aa                	mv	s1,a0
      if(addr){
    80003500:	dd79                	beqz	a0,800034de <bmap+0x82>
        a[bn] = addr;
    80003502:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003506:	8552                	mv	a0,s4
    80003508:	62d000ef          	jal	80004334 <log_write>
    8000350c:	bfc9                	j	800034de <bmap+0x82>
    8000350e:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003510:	00004517          	auipc	a0,0x4
    80003514:	f8850513          	addi	a0,a0,-120 # 80007498 <etext+0x498>
    80003518:	b0cfd0ef          	jal	80000824 <panic>

000000008000351c <iget>:
{
    8000351c:	7179                	addi	sp,sp,-48
    8000351e:	f406                	sd	ra,40(sp)
    80003520:	f022                	sd	s0,32(sp)
    80003522:	ec26                	sd	s1,24(sp)
    80003524:	e84a                	sd	s2,16(sp)
    80003526:	e44e                	sd	s3,8(sp)
    80003528:	e052                	sd	s4,0(sp)
    8000352a:	1800                	addi	s0,sp,48
    8000352c:	892a                	mv	s2,a0
    8000352e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003530:	0001b517          	auipc	a0,0x1b
    80003534:	2f050513          	addi	a0,a0,752 # 8001e820 <itable>
    80003538:	f32fd0ef          	jal	80000c6a <acquire>
  empty = 0;
    8000353c:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000353e:	0001b497          	auipc	s1,0x1b
    80003542:	2fa48493          	addi	s1,s1,762 # 8001e838 <itable+0x18>
    80003546:	0001d697          	auipc	a3,0x1d
    8000354a:	d8268693          	addi	a3,a3,-638 # 800202c8 <log>
    8000354e:	a809                	j	80003560 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003550:	e781                	bnez	a5,80003558 <iget+0x3c>
    80003552:	00099363          	bnez	s3,80003558 <iget+0x3c>
      empty = ip;
    80003556:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003558:	08848493          	addi	s1,s1,136
    8000355c:	02d48563          	beq	s1,a3,80003586 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003560:	449c                	lw	a5,8(s1)
    80003562:	fef057e3          	blez	a5,80003550 <iget+0x34>
    80003566:	4098                	lw	a4,0(s1)
    80003568:	ff2718e3          	bne	a4,s2,80003558 <iget+0x3c>
    8000356c:	40d8                	lw	a4,4(s1)
    8000356e:	ff4715e3          	bne	a4,s4,80003558 <iget+0x3c>
      ip->ref++;
    80003572:	2785                	addiw	a5,a5,1
    80003574:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003576:	0001b517          	auipc	a0,0x1b
    8000357a:	2aa50513          	addi	a0,a0,682 # 8001e820 <itable>
    8000357e:	f80fd0ef          	jal	80000cfe <release>
      return ip;
    80003582:	89a6                	mv	s3,s1
    80003584:	a015                	j	800035a8 <iget+0x8c>
  if(empty == 0)
    80003586:	02098a63          	beqz	s3,800035ba <iget+0x9e>
  ip->dev = dev;
    8000358a:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000358e:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003592:	4785                	li	a5,1
    80003594:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003598:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000359c:	0001b517          	auipc	a0,0x1b
    800035a0:	28450513          	addi	a0,a0,644 # 8001e820 <itable>
    800035a4:	f5afd0ef          	jal	80000cfe <release>
}
    800035a8:	854e                	mv	a0,s3
    800035aa:	70a2                	ld	ra,40(sp)
    800035ac:	7402                	ld	s0,32(sp)
    800035ae:	64e2                	ld	s1,24(sp)
    800035b0:	6942                	ld	s2,16(sp)
    800035b2:	69a2                	ld	s3,8(sp)
    800035b4:	6a02                	ld	s4,0(sp)
    800035b6:	6145                	addi	sp,sp,48
    800035b8:	8082                	ret
    panic("iget: no inodes");
    800035ba:	00004517          	auipc	a0,0x4
    800035be:	ef650513          	addi	a0,a0,-266 # 800074b0 <etext+0x4b0>
    800035c2:	a62fd0ef          	jal	80000824 <panic>

00000000800035c6 <iinit>:
{
    800035c6:	7179                	addi	sp,sp,-48
    800035c8:	f406                	sd	ra,40(sp)
    800035ca:	f022                	sd	s0,32(sp)
    800035cc:	ec26                	sd	s1,24(sp)
    800035ce:	e84a                	sd	s2,16(sp)
    800035d0:	e44e                	sd	s3,8(sp)
    800035d2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800035d4:	00004597          	auipc	a1,0x4
    800035d8:	eec58593          	addi	a1,a1,-276 # 800074c0 <etext+0x4c0>
    800035dc:	0001b517          	auipc	a0,0x1b
    800035e0:	24450513          	addi	a0,a0,580 # 8001e820 <itable>
    800035e4:	dfcfd0ef          	jal	80000be0 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035e8:	0001b497          	auipc	s1,0x1b
    800035ec:	26048493          	addi	s1,s1,608 # 8001e848 <itable+0x28>
    800035f0:	0001d997          	auipc	s3,0x1d
    800035f4:	ce898993          	addi	s3,s3,-792 # 800202d8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035f8:	00004917          	auipc	s2,0x4
    800035fc:	ed090913          	addi	s2,s2,-304 # 800074c8 <etext+0x4c8>
    80003600:	85ca                	mv	a1,s2
    80003602:	8526                	mv	a0,s1
    80003604:	5f5000ef          	jal	800043f8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003608:	08848493          	addi	s1,s1,136
    8000360c:	ff349ae3          	bne	s1,s3,80003600 <iinit+0x3a>
}
    80003610:	70a2                	ld	ra,40(sp)
    80003612:	7402                	ld	s0,32(sp)
    80003614:	64e2                	ld	s1,24(sp)
    80003616:	6942                	ld	s2,16(sp)
    80003618:	69a2                	ld	s3,8(sp)
    8000361a:	6145                	addi	sp,sp,48
    8000361c:	8082                	ret

000000008000361e <ialloc>:
{
    8000361e:	7139                	addi	sp,sp,-64
    80003620:	fc06                	sd	ra,56(sp)
    80003622:	f822                	sd	s0,48(sp)
    80003624:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003626:	0001b717          	auipc	a4,0x1b
    8000362a:	1e672703          	lw	a4,486(a4) # 8001e80c <sb+0xc>
    8000362e:	4785                	li	a5,1
    80003630:	06e7f063          	bgeu	a5,a4,80003690 <ialloc+0x72>
    80003634:	f426                	sd	s1,40(sp)
    80003636:	f04a                	sd	s2,32(sp)
    80003638:	ec4e                	sd	s3,24(sp)
    8000363a:	e852                	sd	s4,16(sp)
    8000363c:	e456                	sd	s5,8(sp)
    8000363e:	e05a                	sd	s6,0(sp)
    80003640:	8aaa                	mv	s5,a0
    80003642:	8b2e                	mv	s6,a1
    80003644:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003646:	0001ba17          	auipc	s4,0x1b
    8000364a:	1baa0a13          	addi	s4,s4,442 # 8001e800 <sb>
    8000364e:	00495593          	srli	a1,s2,0x4
    80003652:	018a2783          	lw	a5,24(s4)
    80003656:	9dbd                	addw	a1,a1,a5
    80003658:	8556                	mv	a0,s5
    8000365a:	a9dff0ef          	jal	800030f6 <bread>
    8000365e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003660:	05850993          	addi	s3,a0,88
    80003664:	00f97793          	andi	a5,s2,15
    80003668:	079a                	slli	a5,a5,0x6
    8000366a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000366c:	00099783          	lh	a5,0(s3)
    80003670:	cb9d                	beqz	a5,800036a6 <ialloc+0x88>
    brelse(bp);
    80003672:	b8dff0ef          	jal	800031fe <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003676:	0905                	addi	s2,s2,1
    80003678:	00ca2703          	lw	a4,12(s4)
    8000367c:	0009079b          	sext.w	a5,s2
    80003680:	fce7e7e3          	bltu	a5,a4,8000364e <ialloc+0x30>
    80003684:	74a2                	ld	s1,40(sp)
    80003686:	7902                	ld	s2,32(sp)
    80003688:	69e2                	ld	s3,24(sp)
    8000368a:	6a42                	ld	s4,16(sp)
    8000368c:	6aa2                	ld	s5,8(sp)
    8000368e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003690:	00004517          	auipc	a0,0x4
    80003694:	e4050513          	addi	a0,a0,-448 # 800074d0 <etext+0x4d0>
    80003698:	e63fc0ef          	jal	800004fa <printf>
  return 0;
    8000369c:	4501                	li	a0,0
}
    8000369e:	70e2                	ld	ra,56(sp)
    800036a0:	7442                	ld	s0,48(sp)
    800036a2:	6121                	addi	sp,sp,64
    800036a4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036a6:	04000613          	li	a2,64
    800036aa:	4581                	li	a1,0
    800036ac:	854e                	mv	a0,s3
    800036ae:	e8cfd0ef          	jal	80000d3a <memset>
      dip->type = type;
    800036b2:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036b6:	8526                	mv	a0,s1
    800036b8:	47d000ef          	jal	80004334 <log_write>
      brelse(bp);
    800036bc:	8526                	mv	a0,s1
    800036be:	b41ff0ef          	jal	800031fe <brelse>
      return iget(dev, inum);
    800036c2:	0009059b          	sext.w	a1,s2
    800036c6:	8556                	mv	a0,s5
    800036c8:	e55ff0ef          	jal	8000351c <iget>
    800036cc:	74a2                	ld	s1,40(sp)
    800036ce:	7902                	ld	s2,32(sp)
    800036d0:	69e2                	ld	s3,24(sp)
    800036d2:	6a42                	ld	s4,16(sp)
    800036d4:	6aa2                	ld	s5,8(sp)
    800036d6:	6b02                	ld	s6,0(sp)
    800036d8:	b7d9                	j	8000369e <ialloc+0x80>

00000000800036da <iupdate>:
{
    800036da:	1101                	addi	sp,sp,-32
    800036dc:	ec06                	sd	ra,24(sp)
    800036de:	e822                	sd	s0,16(sp)
    800036e0:	e426                	sd	s1,8(sp)
    800036e2:	e04a                	sd	s2,0(sp)
    800036e4:	1000                	addi	s0,sp,32
    800036e6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036e8:	415c                	lw	a5,4(a0)
    800036ea:	0047d79b          	srliw	a5,a5,0x4
    800036ee:	0001b597          	auipc	a1,0x1b
    800036f2:	12a5a583          	lw	a1,298(a1) # 8001e818 <sb+0x18>
    800036f6:	9dbd                	addw	a1,a1,a5
    800036f8:	4108                	lw	a0,0(a0)
    800036fa:	9fdff0ef          	jal	800030f6 <bread>
    800036fe:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003700:	05850793          	addi	a5,a0,88
    80003704:	40d8                	lw	a4,4(s1)
    80003706:	8b3d                	andi	a4,a4,15
    80003708:	071a                	slli	a4,a4,0x6
    8000370a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000370c:	04449703          	lh	a4,68(s1)
    80003710:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003714:	04649703          	lh	a4,70(s1)
    80003718:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000371c:	04849703          	lh	a4,72(s1)
    80003720:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003724:	04a49703          	lh	a4,74(s1)
    80003728:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000372c:	44f8                	lw	a4,76(s1)
    8000372e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003730:	03400613          	li	a2,52
    80003734:	05048593          	addi	a1,s1,80
    80003738:	00c78513          	addi	a0,a5,12
    8000373c:	e5efd0ef          	jal	80000d9a <memmove>
  log_write(bp);
    80003740:	854a                	mv	a0,s2
    80003742:	3f3000ef          	jal	80004334 <log_write>
  brelse(bp);
    80003746:	854a                	mv	a0,s2
    80003748:	ab7ff0ef          	jal	800031fe <brelse>
}
    8000374c:	60e2                	ld	ra,24(sp)
    8000374e:	6442                	ld	s0,16(sp)
    80003750:	64a2                	ld	s1,8(sp)
    80003752:	6902                	ld	s2,0(sp)
    80003754:	6105                	addi	sp,sp,32
    80003756:	8082                	ret

0000000080003758 <idup>:
{
    80003758:	1101                	addi	sp,sp,-32
    8000375a:	ec06                	sd	ra,24(sp)
    8000375c:	e822                	sd	s0,16(sp)
    8000375e:	e426                	sd	s1,8(sp)
    80003760:	1000                	addi	s0,sp,32
    80003762:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003764:	0001b517          	auipc	a0,0x1b
    80003768:	0bc50513          	addi	a0,a0,188 # 8001e820 <itable>
    8000376c:	cfefd0ef          	jal	80000c6a <acquire>
  ip->ref++;
    80003770:	449c                	lw	a5,8(s1)
    80003772:	2785                	addiw	a5,a5,1
    80003774:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003776:	0001b517          	auipc	a0,0x1b
    8000377a:	0aa50513          	addi	a0,a0,170 # 8001e820 <itable>
    8000377e:	d80fd0ef          	jal	80000cfe <release>
}
    80003782:	8526                	mv	a0,s1
    80003784:	60e2                	ld	ra,24(sp)
    80003786:	6442                	ld	s0,16(sp)
    80003788:	64a2                	ld	s1,8(sp)
    8000378a:	6105                	addi	sp,sp,32
    8000378c:	8082                	ret

000000008000378e <ilock>:
{
    8000378e:	1101                	addi	sp,sp,-32
    80003790:	ec06                	sd	ra,24(sp)
    80003792:	e822                	sd	s0,16(sp)
    80003794:	e426                	sd	s1,8(sp)
    80003796:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003798:	cd19                	beqz	a0,800037b6 <ilock+0x28>
    8000379a:	84aa                	mv	s1,a0
    8000379c:	451c                	lw	a5,8(a0)
    8000379e:	00f05c63          	blez	a5,800037b6 <ilock+0x28>
  acquiresleep(&ip->lock);
    800037a2:	0541                	addi	a0,a0,16
    800037a4:	48b000ef          	jal	8000442e <acquiresleep>
  if(ip->valid == 0){
    800037a8:	40bc                	lw	a5,64(s1)
    800037aa:	cf89                	beqz	a5,800037c4 <ilock+0x36>
}
    800037ac:	60e2                	ld	ra,24(sp)
    800037ae:	6442                	ld	s0,16(sp)
    800037b0:	64a2                	ld	s1,8(sp)
    800037b2:	6105                	addi	sp,sp,32
    800037b4:	8082                	ret
    800037b6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800037b8:	00004517          	auipc	a0,0x4
    800037bc:	d3050513          	addi	a0,a0,-720 # 800074e8 <etext+0x4e8>
    800037c0:	864fd0ef          	jal	80000824 <panic>
    800037c4:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037c6:	40dc                	lw	a5,4(s1)
    800037c8:	0047d79b          	srliw	a5,a5,0x4
    800037cc:	0001b597          	auipc	a1,0x1b
    800037d0:	04c5a583          	lw	a1,76(a1) # 8001e818 <sb+0x18>
    800037d4:	9dbd                	addw	a1,a1,a5
    800037d6:	4088                	lw	a0,0(s1)
    800037d8:	91fff0ef          	jal	800030f6 <bread>
    800037dc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037de:	05850593          	addi	a1,a0,88
    800037e2:	40dc                	lw	a5,4(s1)
    800037e4:	8bbd                	andi	a5,a5,15
    800037e6:	079a                	slli	a5,a5,0x6
    800037e8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037ea:	00059783          	lh	a5,0(a1)
    800037ee:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037f2:	00259783          	lh	a5,2(a1)
    800037f6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037fa:	00459783          	lh	a5,4(a1)
    800037fe:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003802:	00659783          	lh	a5,6(a1)
    80003806:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000380a:	459c                	lw	a5,8(a1)
    8000380c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000380e:	03400613          	li	a2,52
    80003812:	05b1                	addi	a1,a1,12
    80003814:	05048513          	addi	a0,s1,80
    80003818:	d82fd0ef          	jal	80000d9a <memmove>
    brelse(bp);
    8000381c:	854a                	mv	a0,s2
    8000381e:	9e1ff0ef          	jal	800031fe <brelse>
    ip->valid = 1;
    80003822:	4785                	li	a5,1
    80003824:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003826:	04449783          	lh	a5,68(s1)
    8000382a:	c399                	beqz	a5,80003830 <ilock+0xa2>
    8000382c:	6902                	ld	s2,0(sp)
    8000382e:	bfbd                	j	800037ac <ilock+0x1e>
      panic("ilock: no type");
    80003830:	00004517          	auipc	a0,0x4
    80003834:	cc050513          	addi	a0,a0,-832 # 800074f0 <etext+0x4f0>
    80003838:	fedfc0ef          	jal	80000824 <panic>

000000008000383c <iunlock>:
{
    8000383c:	1101                	addi	sp,sp,-32
    8000383e:	ec06                	sd	ra,24(sp)
    80003840:	e822                	sd	s0,16(sp)
    80003842:	e426                	sd	s1,8(sp)
    80003844:	e04a                	sd	s2,0(sp)
    80003846:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003848:	c505                	beqz	a0,80003870 <iunlock+0x34>
    8000384a:	84aa                	mv	s1,a0
    8000384c:	01050913          	addi	s2,a0,16
    80003850:	854a                	mv	a0,s2
    80003852:	45b000ef          	jal	800044ac <holdingsleep>
    80003856:	cd09                	beqz	a0,80003870 <iunlock+0x34>
    80003858:	449c                	lw	a5,8(s1)
    8000385a:	00f05b63          	blez	a5,80003870 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000385e:	854a                	mv	a0,s2
    80003860:	415000ef          	jal	80004474 <releasesleep>
}
    80003864:	60e2                	ld	ra,24(sp)
    80003866:	6442                	ld	s0,16(sp)
    80003868:	64a2                	ld	s1,8(sp)
    8000386a:	6902                	ld	s2,0(sp)
    8000386c:	6105                	addi	sp,sp,32
    8000386e:	8082                	ret
    panic("iunlock");
    80003870:	00004517          	auipc	a0,0x4
    80003874:	c9050513          	addi	a0,a0,-880 # 80007500 <etext+0x500>
    80003878:	fadfc0ef          	jal	80000824 <panic>

000000008000387c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000387c:	7179                	addi	sp,sp,-48
    8000387e:	f406                	sd	ra,40(sp)
    80003880:	f022                	sd	s0,32(sp)
    80003882:	ec26                	sd	s1,24(sp)
    80003884:	e84a                	sd	s2,16(sp)
    80003886:	e44e                	sd	s3,8(sp)
    80003888:	1800                	addi	s0,sp,48
    8000388a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000388c:	05050493          	addi	s1,a0,80
    80003890:	08050913          	addi	s2,a0,128
    80003894:	a021                	j	8000389c <itrunc+0x20>
    80003896:	0491                	addi	s1,s1,4
    80003898:	01248b63          	beq	s1,s2,800038ae <itrunc+0x32>
    if(ip->addrs[i]){
    8000389c:	408c                	lw	a1,0(s1)
    8000389e:	dde5                	beqz	a1,80003896 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800038a0:	0009a503          	lw	a0,0(s3)
    800038a4:	a47ff0ef          	jal	800032ea <bfree>
      ip->addrs[i] = 0;
    800038a8:	0004a023          	sw	zero,0(s1)
    800038ac:	b7ed                	j	80003896 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038ae:	0809a583          	lw	a1,128(s3)
    800038b2:	ed89                	bnez	a1,800038cc <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038b4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038b8:	854e                	mv	a0,s3
    800038ba:	e21ff0ef          	jal	800036da <iupdate>
}
    800038be:	70a2                	ld	ra,40(sp)
    800038c0:	7402                	ld	s0,32(sp)
    800038c2:	64e2                	ld	s1,24(sp)
    800038c4:	6942                	ld	s2,16(sp)
    800038c6:	69a2                	ld	s3,8(sp)
    800038c8:	6145                	addi	sp,sp,48
    800038ca:	8082                	ret
    800038cc:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038ce:	0009a503          	lw	a0,0(s3)
    800038d2:	825ff0ef          	jal	800030f6 <bread>
    800038d6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038d8:	05850493          	addi	s1,a0,88
    800038dc:	45850913          	addi	s2,a0,1112
    800038e0:	a021                	j	800038e8 <itrunc+0x6c>
    800038e2:	0491                	addi	s1,s1,4
    800038e4:	01248963          	beq	s1,s2,800038f6 <itrunc+0x7a>
      if(a[j])
    800038e8:	408c                	lw	a1,0(s1)
    800038ea:	dde5                	beqz	a1,800038e2 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800038ec:	0009a503          	lw	a0,0(s3)
    800038f0:	9fbff0ef          	jal	800032ea <bfree>
    800038f4:	b7fd                	j	800038e2 <itrunc+0x66>
    brelse(bp);
    800038f6:	8552                	mv	a0,s4
    800038f8:	907ff0ef          	jal	800031fe <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038fc:	0809a583          	lw	a1,128(s3)
    80003900:	0009a503          	lw	a0,0(s3)
    80003904:	9e7ff0ef          	jal	800032ea <bfree>
    ip->addrs[NDIRECT] = 0;
    80003908:	0809a023          	sw	zero,128(s3)
    8000390c:	6a02                	ld	s4,0(sp)
    8000390e:	b75d                	j	800038b4 <itrunc+0x38>

0000000080003910 <iput>:
{
    80003910:	1101                	addi	sp,sp,-32
    80003912:	ec06                	sd	ra,24(sp)
    80003914:	e822                	sd	s0,16(sp)
    80003916:	e426                	sd	s1,8(sp)
    80003918:	1000                	addi	s0,sp,32
    8000391a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000391c:	0001b517          	auipc	a0,0x1b
    80003920:	f0450513          	addi	a0,a0,-252 # 8001e820 <itable>
    80003924:	b46fd0ef          	jal	80000c6a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003928:	4498                	lw	a4,8(s1)
    8000392a:	4785                	li	a5,1
    8000392c:	02f70063          	beq	a4,a5,8000394c <iput+0x3c>
  ip->ref--;
    80003930:	449c                	lw	a5,8(s1)
    80003932:	37fd                	addiw	a5,a5,-1
    80003934:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003936:	0001b517          	auipc	a0,0x1b
    8000393a:	eea50513          	addi	a0,a0,-278 # 8001e820 <itable>
    8000393e:	bc0fd0ef          	jal	80000cfe <release>
}
    80003942:	60e2                	ld	ra,24(sp)
    80003944:	6442                	ld	s0,16(sp)
    80003946:	64a2                	ld	s1,8(sp)
    80003948:	6105                	addi	sp,sp,32
    8000394a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000394c:	40bc                	lw	a5,64(s1)
    8000394e:	d3ed                	beqz	a5,80003930 <iput+0x20>
    80003950:	04a49783          	lh	a5,74(s1)
    80003954:	fff1                	bnez	a5,80003930 <iput+0x20>
    80003956:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003958:	01048793          	addi	a5,s1,16
    8000395c:	893e                	mv	s2,a5
    8000395e:	853e                	mv	a0,a5
    80003960:	2cf000ef          	jal	8000442e <acquiresleep>
    release(&itable.lock);
    80003964:	0001b517          	auipc	a0,0x1b
    80003968:	ebc50513          	addi	a0,a0,-324 # 8001e820 <itable>
    8000396c:	b92fd0ef          	jal	80000cfe <release>
    itrunc(ip);
    80003970:	8526                	mv	a0,s1
    80003972:	f0bff0ef          	jal	8000387c <itrunc>
    ip->type = 0;
    80003976:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000397a:	8526                	mv	a0,s1
    8000397c:	d5fff0ef          	jal	800036da <iupdate>
    ip->valid = 0;
    80003980:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003984:	854a                	mv	a0,s2
    80003986:	2ef000ef          	jal	80004474 <releasesleep>
    acquire(&itable.lock);
    8000398a:	0001b517          	auipc	a0,0x1b
    8000398e:	e9650513          	addi	a0,a0,-362 # 8001e820 <itable>
    80003992:	ad8fd0ef          	jal	80000c6a <acquire>
    80003996:	6902                	ld	s2,0(sp)
    80003998:	bf61                	j	80003930 <iput+0x20>

000000008000399a <iunlockput>:
{
    8000399a:	1101                	addi	sp,sp,-32
    8000399c:	ec06                	sd	ra,24(sp)
    8000399e:	e822                	sd	s0,16(sp)
    800039a0:	e426                	sd	s1,8(sp)
    800039a2:	1000                	addi	s0,sp,32
    800039a4:	84aa                	mv	s1,a0
  iunlock(ip);
    800039a6:	e97ff0ef          	jal	8000383c <iunlock>
  iput(ip);
    800039aa:	8526                	mv	a0,s1
    800039ac:	f65ff0ef          	jal	80003910 <iput>
}
    800039b0:	60e2                	ld	ra,24(sp)
    800039b2:	6442                	ld	s0,16(sp)
    800039b4:	64a2                	ld	s1,8(sp)
    800039b6:	6105                	addi	sp,sp,32
    800039b8:	8082                	ret

00000000800039ba <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800039ba:	0001b717          	auipc	a4,0x1b
    800039be:	e5272703          	lw	a4,-430(a4) # 8001e80c <sb+0xc>
    800039c2:	4785                	li	a5,1
    800039c4:	0ae7fe63          	bgeu	a5,a4,80003a80 <ireclaim+0xc6>
{
    800039c8:	7139                	addi	sp,sp,-64
    800039ca:	fc06                	sd	ra,56(sp)
    800039cc:	f822                	sd	s0,48(sp)
    800039ce:	f426                	sd	s1,40(sp)
    800039d0:	f04a                	sd	s2,32(sp)
    800039d2:	ec4e                	sd	s3,24(sp)
    800039d4:	e852                	sd	s4,16(sp)
    800039d6:	e456                	sd	s5,8(sp)
    800039d8:	e05a                	sd	s6,0(sp)
    800039da:	0080                	addi	s0,sp,64
    800039dc:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800039de:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800039e0:	0001ba17          	auipc	s4,0x1b
    800039e4:	e20a0a13          	addi	s4,s4,-480 # 8001e800 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800039e8:	00004b17          	auipc	s6,0x4
    800039ec:	b20b0b13          	addi	s6,s6,-1248 # 80007508 <etext+0x508>
    800039f0:	a099                	j	80003a36 <ireclaim+0x7c>
    800039f2:	85ce                	mv	a1,s3
    800039f4:	855a                	mv	a0,s6
    800039f6:	b05fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800039fa:	85ce                	mv	a1,s3
    800039fc:	8556                	mv	a0,s5
    800039fe:	b1fff0ef          	jal	8000351c <iget>
    80003a02:	89aa                	mv	s3,a0
    brelse(bp);
    80003a04:	854a                	mv	a0,s2
    80003a06:	ff8ff0ef          	jal	800031fe <brelse>
    if (ip) {
    80003a0a:	00098f63          	beqz	s3,80003a28 <ireclaim+0x6e>
      begin_op();
    80003a0e:	78c000ef          	jal	8000419a <begin_op>
      ilock(ip);
    80003a12:	854e                	mv	a0,s3
    80003a14:	d7bff0ef          	jal	8000378e <ilock>
      iunlock(ip);
    80003a18:	854e                	mv	a0,s3
    80003a1a:	e23ff0ef          	jal	8000383c <iunlock>
      iput(ip);
    80003a1e:	854e                	mv	a0,s3
    80003a20:	ef1ff0ef          	jal	80003910 <iput>
      end_op();
    80003a24:	7e6000ef          	jal	8000420a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a28:	0485                	addi	s1,s1,1
    80003a2a:	00ca2703          	lw	a4,12(s4)
    80003a2e:	0004879b          	sext.w	a5,s1
    80003a32:	02e7fd63          	bgeu	a5,a4,80003a6c <ireclaim+0xb2>
    80003a36:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a3a:	0044d593          	srli	a1,s1,0x4
    80003a3e:	018a2783          	lw	a5,24(s4)
    80003a42:	9dbd                	addw	a1,a1,a5
    80003a44:	8556                	mv	a0,s5
    80003a46:	eb0ff0ef          	jal	800030f6 <bread>
    80003a4a:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003a4c:	05850793          	addi	a5,a0,88
    80003a50:	00f9f713          	andi	a4,s3,15
    80003a54:	071a                	slli	a4,a4,0x6
    80003a56:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003a58:	00079703          	lh	a4,0(a5)
    80003a5c:	c701                	beqz	a4,80003a64 <ireclaim+0xaa>
    80003a5e:	00679783          	lh	a5,6(a5)
    80003a62:	dbc1                	beqz	a5,800039f2 <ireclaim+0x38>
    brelse(bp);
    80003a64:	854a                	mv	a0,s2
    80003a66:	f98ff0ef          	jal	800031fe <brelse>
    if (ip) {
    80003a6a:	bf7d                	j	80003a28 <ireclaim+0x6e>
}
    80003a6c:	70e2                	ld	ra,56(sp)
    80003a6e:	7442                	ld	s0,48(sp)
    80003a70:	74a2                	ld	s1,40(sp)
    80003a72:	7902                	ld	s2,32(sp)
    80003a74:	69e2                	ld	s3,24(sp)
    80003a76:	6a42                	ld	s4,16(sp)
    80003a78:	6aa2                	ld	s5,8(sp)
    80003a7a:	6b02                	ld	s6,0(sp)
    80003a7c:	6121                	addi	sp,sp,64
    80003a7e:	8082                	ret
    80003a80:	8082                	ret

0000000080003a82 <fsinit>:
fsinit(int dev) {
    80003a82:	1101                	addi	sp,sp,-32
    80003a84:	ec06                	sd	ra,24(sp)
    80003a86:	e822                	sd	s0,16(sp)
    80003a88:	e426                	sd	s1,8(sp)
    80003a8a:	e04a                	sd	s2,0(sp)
    80003a8c:	1000                	addi	s0,sp,32
    80003a8e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a90:	4585                	li	a1,1
    80003a92:	e64ff0ef          	jal	800030f6 <bread>
    80003a96:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a98:	02000613          	li	a2,32
    80003a9c:	05850593          	addi	a1,a0,88
    80003aa0:	0001b517          	auipc	a0,0x1b
    80003aa4:	d6050513          	addi	a0,a0,-672 # 8001e800 <sb>
    80003aa8:	af2fd0ef          	jal	80000d9a <memmove>
  brelse(bp);
    80003aac:	8526                	mv	a0,s1
    80003aae:	f50ff0ef          	jal	800031fe <brelse>
  if(sb.magic != FSMAGIC)
    80003ab2:	0001b717          	auipc	a4,0x1b
    80003ab6:	d4e72703          	lw	a4,-690(a4) # 8001e800 <sb>
    80003aba:	102037b7          	lui	a5,0x10203
    80003abe:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ac2:	02f71263          	bne	a4,a5,80003ae6 <fsinit+0x64>
  initlog(dev, &sb);
    80003ac6:	0001b597          	auipc	a1,0x1b
    80003aca:	d3a58593          	addi	a1,a1,-710 # 8001e800 <sb>
    80003ace:	854a                	mv	a0,s2
    80003ad0:	648000ef          	jal	80004118 <initlog>
  ireclaim(dev);
    80003ad4:	854a                	mv	a0,s2
    80003ad6:	ee5ff0ef          	jal	800039ba <ireclaim>
}
    80003ada:	60e2                	ld	ra,24(sp)
    80003adc:	6442                	ld	s0,16(sp)
    80003ade:	64a2                	ld	s1,8(sp)
    80003ae0:	6902                	ld	s2,0(sp)
    80003ae2:	6105                	addi	sp,sp,32
    80003ae4:	8082                	ret
    panic("invalid file system");
    80003ae6:	00004517          	auipc	a0,0x4
    80003aea:	a4250513          	addi	a0,a0,-1470 # 80007528 <etext+0x528>
    80003aee:	d37fc0ef          	jal	80000824 <panic>

0000000080003af2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003af2:	1141                	addi	sp,sp,-16
    80003af4:	e406                	sd	ra,8(sp)
    80003af6:	e022                	sd	s0,0(sp)
    80003af8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003afa:	411c                	lw	a5,0(a0)
    80003afc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003afe:	415c                	lw	a5,4(a0)
    80003b00:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b02:	04451783          	lh	a5,68(a0)
    80003b06:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b0a:	04a51783          	lh	a5,74(a0)
    80003b0e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b12:	04c56783          	lwu	a5,76(a0)
    80003b16:	e99c                	sd	a5,16(a1)
}
    80003b18:	60a2                	ld	ra,8(sp)
    80003b1a:	6402                	ld	s0,0(sp)
    80003b1c:	0141                	addi	sp,sp,16
    80003b1e:	8082                	ret

0000000080003b20 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b20:	457c                	lw	a5,76(a0)
    80003b22:	0ed7e663          	bltu	a5,a3,80003c0e <readi+0xee>
{
    80003b26:	7159                	addi	sp,sp,-112
    80003b28:	f486                	sd	ra,104(sp)
    80003b2a:	f0a2                	sd	s0,96(sp)
    80003b2c:	eca6                	sd	s1,88(sp)
    80003b2e:	e0d2                	sd	s4,64(sp)
    80003b30:	fc56                	sd	s5,56(sp)
    80003b32:	f85a                	sd	s6,48(sp)
    80003b34:	f45e                	sd	s7,40(sp)
    80003b36:	1880                	addi	s0,sp,112
    80003b38:	8b2a                	mv	s6,a0
    80003b3a:	8bae                	mv	s7,a1
    80003b3c:	8a32                	mv	s4,a2
    80003b3e:	84b6                	mv	s1,a3
    80003b40:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b42:	9f35                	addw	a4,a4,a3
    return 0;
    80003b44:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b46:	0ad76b63          	bltu	a4,a3,80003bfc <readi+0xdc>
    80003b4a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003b4c:	00e7f463          	bgeu	a5,a4,80003b54 <readi+0x34>
    n = ip->size - off;
    80003b50:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b54:	080a8b63          	beqz	s5,80003bea <readi+0xca>
    80003b58:	e8ca                	sd	s2,80(sp)
    80003b5a:	f062                	sd	s8,32(sp)
    80003b5c:	ec66                	sd	s9,24(sp)
    80003b5e:	e86a                	sd	s10,16(sp)
    80003b60:	e46e                	sd	s11,8(sp)
    80003b62:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b64:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b68:	5c7d                	li	s8,-1
    80003b6a:	a80d                	j	80003b9c <readi+0x7c>
    80003b6c:	020d1d93          	slli	s11,s10,0x20
    80003b70:	020ddd93          	srli	s11,s11,0x20
    80003b74:	05890613          	addi	a2,s2,88
    80003b78:	86ee                	mv	a3,s11
    80003b7a:	963e                	add	a2,a2,a5
    80003b7c:	85d2                	mv	a1,s4
    80003b7e:	855e                	mv	a0,s7
    80003b80:	bb5fe0ef          	jal	80002734 <either_copyout>
    80003b84:	05850363          	beq	a0,s8,80003bca <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b88:	854a                	mv	a0,s2
    80003b8a:	e74ff0ef          	jal	800031fe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b8e:	013d09bb          	addw	s3,s10,s3
    80003b92:	009d04bb          	addw	s1,s10,s1
    80003b96:	9a6e                	add	s4,s4,s11
    80003b98:	0559f363          	bgeu	s3,s5,80003bde <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003b9c:	00a4d59b          	srliw	a1,s1,0xa
    80003ba0:	855a                	mv	a0,s6
    80003ba2:	8bbff0ef          	jal	8000345c <bmap>
    80003ba6:	85aa                	mv	a1,a0
    if(addr == 0)
    80003ba8:	c139                	beqz	a0,80003bee <readi+0xce>
    bp = bread(ip->dev, addr);
    80003baa:	000b2503          	lw	a0,0(s6)
    80003bae:	d48ff0ef          	jal	800030f6 <bread>
    80003bb2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bb4:	3ff4f793          	andi	a5,s1,1023
    80003bb8:	40fc873b          	subw	a4,s9,a5
    80003bbc:	413a86bb          	subw	a3,s5,s3
    80003bc0:	8d3a                	mv	s10,a4
    80003bc2:	fae6f5e3          	bgeu	a3,a4,80003b6c <readi+0x4c>
    80003bc6:	8d36                	mv	s10,a3
    80003bc8:	b755                	j	80003b6c <readi+0x4c>
      brelse(bp);
    80003bca:	854a                	mv	a0,s2
    80003bcc:	e32ff0ef          	jal	800031fe <brelse>
      tot = -1;
    80003bd0:	59fd                	li	s3,-1
      break;
    80003bd2:	6946                	ld	s2,80(sp)
    80003bd4:	7c02                	ld	s8,32(sp)
    80003bd6:	6ce2                	ld	s9,24(sp)
    80003bd8:	6d42                	ld	s10,16(sp)
    80003bda:	6da2                	ld	s11,8(sp)
    80003bdc:	a831                	j	80003bf8 <readi+0xd8>
    80003bde:	6946                	ld	s2,80(sp)
    80003be0:	7c02                	ld	s8,32(sp)
    80003be2:	6ce2                	ld	s9,24(sp)
    80003be4:	6d42                	ld	s10,16(sp)
    80003be6:	6da2                	ld	s11,8(sp)
    80003be8:	a801                	j	80003bf8 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bea:	89d6                	mv	s3,s5
    80003bec:	a031                	j	80003bf8 <readi+0xd8>
    80003bee:	6946                	ld	s2,80(sp)
    80003bf0:	7c02                	ld	s8,32(sp)
    80003bf2:	6ce2                	ld	s9,24(sp)
    80003bf4:	6d42                	ld	s10,16(sp)
    80003bf6:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003bf8:	854e                	mv	a0,s3
    80003bfa:	69a6                	ld	s3,72(sp)
}
    80003bfc:	70a6                	ld	ra,104(sp)
    80003bfe:	7406                	ld	s0,96(sp)
    80003c00:	64e6                	ld	s1,88(sp)
    80003c02:	6a06                	ld	s4,64(sp)
    80003c04:	7ae2                	ld	s5,56(sp)
    80003c06:	7b42                	ld	s6,48(sp)
    80003c08:	7ba2                	ld	s7,40(sp)
    80003c0a:	6165                	addi	sp,sp,112
    80003c0c:	8082                	ret
    return 0;
    80003c0e:	4501                	li	a0,0
}
    80003c10:	8082                	ret

0000000080003c12 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c12:	457c                	lw	a5,76(a0)
    80003c14:	0ed7eb63          	bltu	a5,a3,80003d0a <writei+0xf8>
{
    80003c18:	7159                	addi	sp,sp,-112
    80003c1a:	f486                	sd	ra,104(sp)
    80003c1c:	f0a2                	sd	s0,96(sp)
    80003c1e:	e8ca                	sd	s2,80(sp)
    80003c20:	e0d2                	sd	s4,64(sp)
    80003c22:	fc56                	sd	s5,56(sp)
    80003c24:	f85a                	sd	s6,48(sp)
    80003c26:	f45e                	sd	s7,40(sp)
    80003c28:	1880                	addi	s0,sp,112
    80003c2a:	8aaa                	mv	s5,a0
    80003c2c:	8bae                	mv	s7,a1
    80003c2e:	8a32                	mv	s4,a2
    80003c30:	8936                	mv	s2,a3
    80003c32:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c34:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c38:	00043737          	lui	a4,0x43
    80003c3c:	0cf76963          	bltu	a4,a5,80003d0e <writei+0xfc>
    80003c40:	0cd7e763          	bltu	a5,a3,80003d0e <writei+0xfc>
    80003c44:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c46:	0a0b0a63          	beqz	s6,80003cfa <writei+0xe8>
    80003c4a:	eca6                	sd	s1,88(sp)
    80003c4c:	f062                	sd	s8,32(sp)
    80003c4e:	ec66                	sd	s9,24(sp)
    80003c50:	e86a                	sd	s10,16(sp)
    80003c52:	e46e                	sd	s11,8(sp)
    80003c54:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c56:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c5a:	5c7d                	li	s8,-1
    80003c5c:	a825                	j	80003c94 <writei+0x82>
    80003c5e:	020d1d93          	slli	s11,s10,0x20
    80003c62:	020ddd93          	srli	s11,s11,0x20
    80003c66:	05848513          	addi	a0,s1,88
    80003c6a:	86ee                	mv	a3,s11
    80003c6c:	8652                	mv	a2,s4
    80003c6e:	85de                	mv	a1,s7
    80003c70:	953e                	add	a0,a0,a5
    80003c72:	b0dfe0ef          	jal	8000277e <either_copyin>
    80003c76:	05850663          	beq	a0,s8,80003cc2 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	6b8000ef          	jal	80004334 <log_write>
    brelse(bp);
    80003c80:	8526                	mv	a0,s1
    80003c82:	d7cff0ef          	jal	800031fe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c86:	013d09bb          	addw	s3,s10,s3
    80003c8a:	012d093b          	addw	s2,s10,s2
    80003c8e:	9a6e                	add	s4,s4,s11
    80003c90:	0369fc63          	bgeu	s3,s6,80003cc8 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003c94:	00a9559b          	srliw	a1,s2,0xa
    80003c98:	8556                	mv	a0,s5
    80003c9a:	fc2ff0ef          	jal	8000345c <bmap>
    80003c9e:	85aa                	mv	a1,a0
    if(addr == 0)
    80003ca0:	c505                	beqz	a0,80003cc8 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003ca2:	000aa503          	lw	a0,0(s5)
    80003ca6:	c50ff0ef          	jal	800030f6 <bread>
    80003caa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cac:	3ff97793          	andi	a5,s2,1023
    80003cb0:	40fc873b          	subw	a4,s9,a5
    80003cb4:	413b06bb          	subw	a3,s6,s3
    80003cb8:	8d3a                	mv	s10,a4
    80003cba:	fae6f2e3          	bgeu	a3,a4,80003c5e <writei+0x4c>
    80003cbe:	8d36                	mv	s10,a3
    80003cc0:	bf79                	j	80003c5e <writei+0x4c>
      brelse(bp);
    80003cc2:	8526                	mv	a0,s1
    80003cc4:	d3aff0ef          	jal	800031fe <brelse>
  }

  if(off > ip->size)
    80003cc8:	04caa783          	lw	a5,76(s5)
    80003ccc:	0327f963          	bgeu	a5,s2,80003cfe <writei+0xec>
    ip->size = off;
    80003cd0:	052aa623          	sw	s2,76(s5)
    80003cd4:	64e6                	ld	s1,88(sp)
    80003cd6:	7c02                	ld	s8,32(sp)
    80003cd8:	6ce2                	ld	s9,24(sp)
    80003cda:	6d42                	ld	s10,16(sp)
    80003cdc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003cde:	8556                	mv	a0,s5
    80003ce0:	9fbff0ef          	jal	800036da <iupdate>

  return tot;
    80003ce4:	854e                	mv	a0,s3
    80003ce6:	69a6                	ld	s3,72(sp)
}
    80003ce8:	70a6                	ld	ra,104(sp)
    80003cea:	7406                	ld	s0,96(sp)
    80003cec:	6946                	ld	s2,80(sp)
    80003cee:	6a06                	ld	s4,64(sp)
    80003cf0:	7ae2                	ld	s5,56(sp)
    80003cf2:	7b42                	ld	s6,48(sp)
    80003cf4:	7ba2                	ld	s7,40(sp)
    80003cf6:	6165                	addi	sp,sp,112
    80003cf8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cfa:	89da                	mv	s3,s6
    80003cfc:	b7cd                	j	80003cde <writei+0xcc>
    80003cfe:	64e6                	ld	s1,88(sp)
    80003d00:	7c02                	ld	s8,32(sp)
    80003d02:	6ce2                	ld	s9,24(sp)
    80003d04:	6d42                	ld	s10,16(sp)
    80003d06:	6da2                	ld	s11,8(sp)
    80003d08:	bfd9                	j	80003cde <writei+0xcc>
    return -1;
    80003d0a:	557d                	li	a0,-1
}
    80003d0c:	8082                	ret
    return -1;
    80003d0e:	557d                	li	a0,-1
    80003d10:	bfe1                	j	80003ce8 <writei+0xd6>

0000000080003d12 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d12:	1141                	addi	sp,sp,-16
    80003d14:	e406                	sd	ra,8(sp)
    80003d16:	e022                	sd	s0,0(sp)
    80003d18:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d1a:	4639                	li	a2,14
    80003d1c:	8f2fd0ef          	jal	80000e0e <strncmp>
}
    80003d20:	60a2                	ld	ra,8(sp)
    80003d22:	6402                	ld	s0,0(sp)
    80003d24:	0141                	addi	sp,sp,16
    80003d26:	8082                	ret

0000000080003d28 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d28:	711d                	addi	sp,sp,-96
    80003d2a:	ec86                	sd	ra,88(sp)
    80003d2c:	e8a2                	sd	s0,80(sp)
    80003d2e:	e4a6                	sd	s1,72(sp)
    80003d30:	e0ca                	sd	s2,64(sp)
    80003d32:	fc4e                	sd	s3,56(sp)
    80003d34:	f852                	sd	s4,48(sp)
    80003d36:	f456                	sd	s5,40(sp)
    80003d38:	f05a                	sd	s6,32(sp)
    80003d3a:	ec5e                	sd	s7,24(sp)
    80003d3c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d3e:	04451703          	lh	a4,68(a0)
    80003d42:	4785                	li	a5,1
    80003d44:	00f71f63          	bne	a4,a5,80003d62 <dirlookup+0x3a>
    80003d48:	892a                	mv	s2,a0
    80003d4a:	8aae                	mv	s5,a1
    80003d4c:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d4e:	457c                	lw	a5,76(a0)
    80003d50:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d52:	fa040a13          	addi	s4,s0,-96
    80003d56:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003d58:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d5c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d5e:	e39d                	bnez	a5,80003d84 <dirlookup+0x5c>
    80003d60:	a8b9                	j	80003dbe <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003d62:	00003517          	auipc	a0,0x3
    80003d66:	7de50513          	addi	a0,a0,2014 # 80007540 <etext+0x540>
    80003d6a:	abbfc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80003d6e:	00003517          	auipc	a0,0x3
    80003d72:	7ea50513          	addi	a0,a0,2026 # 80007558 <etext+0x558>
    80003d76:	aaffc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d7a:	24c1                	addiw	s1,s1,16
    80003d7c:	04c92783          	lw	a5,76(s2)
    80003d80:	02f4fe63          	bgeu	s1,a5,80003dbc <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d84:	874e                	mv	a4,s3
    80003d86:	86a6                	mv	a3,s1
    80003d88:	8652                	mv	a2,s4
    80003d8a:	4581                	li	a1,0
    80003d8c:	854a                	mv	a0,s2
    80003d8e:	d93ff0ef          	jal	80003b20 <readi>
    80003d92:	fd351ee3          	bne	a0,s3,80003d6e <dirlookup+0x46>
    if(de.inum == 0)
    80003d96:	fa045783          	lhu	a5,-96(s0)
    80003d9a:	d3e5                	beqz	a5,80003d7a <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003d9c:	85da                	mv	a1,s6
    80003d9e:	8556                	mv	a0,s5
    80003da0:	f73ff0ef          	jal	80003d12 <namecmp>
    80003da4:	f979                	bnez	a0,80003d7a <dirlookup+0x52>
      if(poff)
    80003da6:	000b8463          	beqz	s7,80003dae <dirlookup+0x86>
        *poff = off;
    80003daa:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003dae:	fa045583          	lhu	a1,-96(s0)
    80003db2:	00092503          	lw	a0,0(s2)
    80003db6:	f66ff0ef          	jal	8000351c <iget>
    80003dba:	a011                	j	80003dbe <dirlookup+0x96>
  return 0;
    80003dbc:	4501                	li	a0,0
}
    80003dbe:	60e6                	ld	ra,88(sp)
    80003dc0:	6446                	ld	s0,80(sp)
    80003dc2:	64a6                	ld	s1,72(sp)
    80003dc4:	6906                	ld	s2,64(sp)
    80003dc6:	79e2                	ld	s3,56(sp)
    80003dc8:	7a42                	ld	s4,48(sp)
    80003dca:	7aa2                	ld	s5,40(sp)
    80003dcc:	7b02                	ld	s6,32(sp)
    80003dce:	6be2                	ld	s7,24(sp)
    80003dd0:	6125                	addi	sp,sp,96
    80003dd2:	8082                	ret

0000000080003dd4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003dd4:	711d                	addi	sp,sp,-96
    80003dd6:	ec86                	sd	ra,88(sp)
    80003dd8:	e8a2                	sd	s0,80(sp)
    80003dda:	e4a6                	sd	s1,72(sp)
    80003ddc:	e0ca                	sd	s2,64(sp)
    80003dde:	fc4e                	sd	s3,56(sp)
    80003de0:	f852                	sd	s4,48(sp)
    80003de2:	f456                	sd	s5,40(sp)
    80003de4:	f05a                	sd	s6,32(sp)
    80003de6:	ec5e                	sd	s7,24(sp)
    80003de8:	e862                	sd	s8,16(sp)
    80003dea:	e466                	sd	s9,8(sp)
    80003dec:	e06a                	sd	s10,0(sp)
    80003dee:	1080                	addi	s0,sp,96
    80003df0:	84aa                	mv	s1,a0
    80003df2:	8b2e                	mv	s6,a1
    80003df4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003df6:	00054703          	lbu	a4,0(a0)
    80003dfa:	02f00793          	li	a5,47
    80003dfe:	00f70f63          	beq	a4,a5,80003e1c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e02:	b63fd0ef          	jal	80001964 <myproc>
    80003e06:	17053503          	ld	a0,368(a0)
    80003e0a:	94fff0ef          	jal	80003758 <idup>
    80003e0e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e10:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003e14:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003e16:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e18:	4b85                	li	s7,1
    80003e1a:	a879                	j	80003eb8 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003e1c:	4585                	li	a1,1
    80003e1e:	852e                	mv	a0,a1
    80003e20:	efcff0ef          	jal	8000351c <iget>
    80003e24:	8a2a                	mv	s4,a0
    80003e26:	b7ed                	j	80003e10 <namex+0x3c>
      iunlockput(ip);
    80003e28:	8552                	mv	a0,s4
    80003e2a:	b71ff0ef          	jal	8000399a <iunlockput>
      return 0;
    80003e2e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e30:	8552                	mv	a0,s4
    80003e32:	60e6                	ld	ra,88(sp)
    80003e34:	6446                	ld	s0,80(sp)
    80003e36:	64a6                	ld	s1,72(sp)
    80003e38:	6906                	ld	s2,64(sp)
    80003e3a:	79e2                	ld	s3,56(sp)
    80003e3c:	7a42                	ld	s4,48(sp)
    80003e3e:	7aa2                	ld	s5,40(sp)
    80003e40:	7b02                	ld	s6,32(sp)
    80003e42:	6be2                	ld	s7,24(sp)
    80003e44:	6c42                	ld	s8,16(sp)
    80003e46:	6ca2                	ld	s9,8(sp)
    80003e48:	6d02                	ld	s10,0(sp)
    80003e4a:	6125                	addi	sp,sp,96
    80003e4c:	8082                	ret
      iunlock(ip);
    80003e4e:	8552                	mv	a0,s4
    80003e50:	9edff0ef          	jal	8000383c <iunlock>
      return ip;
    80003e54:	bff1                	j	80003e30 <namex+0x5c>
      iunlockput(ip);
    80003e56:	8552                	mv	a0,s4
    80003e58:	b43ff0ef          	jal	8000399a <iunlockput>
      return 0;
    80003e5c:	8a4a                	mv	s4,s2
    80003e5e:	bfc9                	j	80003e30 <namex+0x5c>
  len = path - s;
    80003e60:	40990633          	sub	a2,s2,s1
    80003e64:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003e68:	09ac5463          	bge	s8,s10,80003ef0 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003e6c:	8666                	mv	a2,s9
    80003e6e:	85a6                	mv	a1,s1
    80003e70:	8556                	mv	a0,s5
    80003e72:	f29fc0ef          	jal	80000d9a <memmove>
    80003e76:	84ca                	mv	s1,s2
  while(*path == '/')
    80003e78:	0004c783          	lbu	a5,0(s1)
    80003e7c:	01379763          	bne	a5,s3,80003e8a <namex+0xb6>
    path++;
    80003e80:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e82:	0004c783          	lbu	a5,0(s1)
    80003e86:	ff378de3          	beq	a5,s3,80003e80 <namex+0xac>
    ilock(ip);
    80003e8a:	8552                	mv	a0,s4
    80003e8c:	903ff0ef          	jal	8000378e <ilock>
    if(ip->type != T_DIR){
    80003e90:	044a1783          	lh	a5,68(s4)
    80003e94:	f9779ae3          	bne	a5,s7,80003e28 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003e98:	000b0563          	beqz	s6,80003ea2 <namex+0xce>
    80003e9c:	0004c783          	lbu	a5,0(s1)
    80003ea0:	d7dd                	beqz	a5,80003e4e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ea2:	4601                	li	a2,0
    80003ea4:	85d6                	mv	a1,s5
    80003ea6:	8552                	mv	a0,s4
    80003ea8:	e81ff0ef          	jal	80003d28 <dirlookup>
    80003eac:	892a                	mv	s2,a0
    80003eae:	d545                	beqz	a0,80003e56 <namex+0x82>
    iunlockput(ip);
    80003eb0:	8552                	mv	a0,s4
    80003eb2:	ae9ff0ef          	jal	8000399a <iunlockput>
    ip = next;
    80003eb6:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003eb8:	0004c783          	lbu	a5,0(s1)
    80003ebc:	01379763          	bne	a5,s3,80003eca <namex+0xf6>
    path++;
    80003ec0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ec2:	0004c783          	lbu	a5,0(s1)
    80003ec6:	ff378de3          	beq	a5,s3,80003ec0 <namex+0xec>
  if(*path == 0)
    80003eca:	cf8d                	beqz	a5,80003f04 <namex+0x130>
  while(*path != '/' && *path != 0)
    80003ecc:	0004c783          	lbu	a5,0(s1)
    80003ed0:	fd178713          	addi	a4,a5,-47
    80003ed4:	cb19                	beqz	a4,80003eea <namex+0x116>
    80003ed6:	cb91                	beqz	a5,80003eea <namex+0x116>
    80003ed8:	8926                	mv	s2,s1
    path++;
    80003eda:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003edc:	00094783          	lbu	a5,0(s2)
    80003ee0:	fd178713          	addi	a4,a5,-47
    80003ee4:	df35                	beqz	a4,80003e60 <namex+0x8c>
    80003ee6:	fbf5                	bnez	a5,80003eda <namex+0x106>
    80003ee8:	bfa5                	j	80003e60 <namex+0x8c>
    80003eea:	8926                	mv	s2,s1
  len = path - s;
    80003eec:	4d01                	li	s10,0
    80003eee:	4601                	li	a2,0
    memmove(name, s, len);
    80003ef0:	2601                	sext.w	a2,a2
    80003ef2:	85a6                	mv	a1,s1
    80003ef4:	8556                	mv	a0,s5
    80003ef6:	ea5fc0ef          	jal	80000d9a <memmove>
    name[len] = 0;
    80003efa:	9d56                	add	s10,s10,s5
    80003efc:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffddaf8>
    80003f00:	84ca                	mv	s1,s2
    80003f02:	bf9d                	j	80003e78 <namex+0xa4>
  if(nameiparent){
    80003f04:	f20b06e3          	beqz	s6,80003e30 <namex+0x5c>
    iput(ip);
    80003f08:	8552                	mv	a0,s4
    80003f0a:	a07ff0ef          	jal	80003910 <iput>
    return 0;
    80003f0e:	4a01                	li	s4,0
    80003f10:	b705                	j	80003e30 <namex+0x5c>

0000000080003f12 <dirlink>:
{
    80003f12:	715d                	addi	sp,sp,-80
    80003f14:	e486                	sd	ra,72(sp)
    80003f16:	e0a2                	sd	s0,64(sp)
    80003f18:	f84a                	sd	s2,48(sp)
    80003f1a:	ec56                	sd	s5,24(sp)
    80003f1c:	e85a                	sd	s6,16(sp)
    80003f1e:	0880                	addi	s0,sp,80
    80003f20:	892a                	mv	s2,a0
    80003f22:	8aae                	mv	s5,a1
    80003f24:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f26:	4601                	li	a2,0
    80003f28:	e01ff0ef          	jal	80003d28 <dirlookup>
    80003f2c:	ed1d                	bnez	a0,80003f6a <dirlink+0x58>
    80003f2e:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f30:	04c92483          	lw	s1,76(s2)
    80003f34:	c4b9                	beqz	s1,80003f82 <dirlink+0x70>
    80003f36:	f44e                	sd	s3,40(sp)
    80003f38:	f052                	sd	s4,32(sp)
    80003f3a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f3c:	fb040a13          	addi	s4,s0,-80
    80003f40:	49c1                	li	s3,16
    80003f42:	874e                	mv	a4,s3
    80003f44:	86a6                	mv	a3,s1
    80003f46:	8652                	mv	a2,s4
    80003f48:	4581                	li	a1,0
    80003f4a:	854a                	mv	a0,s2
    80003f4c:	bd5ff0ef          	jal	80003b20 <readi>
    80003f50:	03351163          	bne	a0,s3,80003f72 <dirlink+0x60>
    if(de.inum == 0)
    80003f54:	fb045783          	lhu	a5,-80(s0)
    80003f58:	c39d                	beqz	a5,80003f7e <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f5a:	24c1                	addiw	s1,s1,16
    80003f5c:	04c92783          	lw	a5,76(s2)
    80003f60:	fef4e1e3          	bltu	s1,a5,80003f42 <dirlink+0x30>
    80003f64:	79a2                	ld	s3,40(sp)
    80003f66:	7a02                	ld	s4,32(sp)
    80003f68:	a829                	j	80003f82 <dirlink+0x70>
    iput(ip);
    80003f6a:	9a7ff0ef          	jal	80003910 <iput>
    return -1;
    80003f6e:	557d                	li	a0,-1
    80003f70:	a83d                	j	80003fae <dirlink+0x9c>
      panic("dirlink read");
    80003f72:	00003517          	auipc	a0,0x3
    80003f76:	5f650513          	addi	a0,a0,1526 # 80007568 <etext+0x568>
    80003f7a:	8abfc0ef          	jal	80000824 <panic>
    80003f7e:	79a2                	ld	s3,40(sp)
    80003f80:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003f82:	4639                	li	a2,14
    80003f84:	85d6                	mv	a1,s5
    80003f86:	fb240513          	addi	a0,s0,-78
    80003f8a:	ebffc0ef          	jal	80000e48 <strncpy>
  de.inum = inum;
    80003f8e:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f92:	4741                	li	a4,16
    80003f94:	86a6                	mv	a3,s1
    80003f96:	fb040613          	addi	a2,s0,-80
    80003f9a:	4581                	li	a1,0
    80003f9c:	854a                	mv	a0,s2
    80003f9e:	c75ff0ef          	jal	80003c12 <writei>
    80003fa2:	1541                	addi	a0,a0,-16
    80003fa4:	00a03533          	snez	a0,a0
    80003fa8:	40a0053b          	negw	a0,a0
    80003fac:	74e2                	ld	s1,56(sp)
}
    80003fae:	60a6                	ld	ra,72(sp)
    80003fb0:	6406                	ld	s0,64(sp)
    80003fb2:	7942                	ld	s2,48(sp)
    80003fb4:	6ae2                	ld	s5,24(sp)
    80003fb6:	6b42                	ld	s6,16(sp)
    80003fb8:	6161                	addi	sp,sp,80
    80003fba:	8082                	ret

0000000080003fbc <namei>:

struct inode*
namei(char *path)
{
    80003fbc:	1101                	addi	sp,sp,-32
    80003fbe:	ec06                	sd	ra,24(sp)
    80003fc0:	e822                	sd	s0,16(sp)
    80003fc2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003fc4:	fe040613          	addi	a2,s0,-32
    80003fc8:	4581                	li	a1,0
    80003fca:	e0bff0ef          	jal	80003dd4 <namex>
}
    80003fce:	60e2                	ld	ra,24(sp)
    80003fd0:	6442                	ld	s0,16(sp)
    80003fd2:	6105                	addi	sp,sp,32
    80003fd4:	8082                	ret

0000000080003fd6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fd6:	1141                	addi	sp,sp,-16
    80003fd8:	e406                	sd	ra,8(sp)
    80003fda:	e022                	sd	s0,0(sp)
    80003fdc:	0800                	addi	s0,sp,16
    80003fde:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003fe0:	4585                	li	a1,1
    80003fe2:	df3ff0ef          	jal	80003dd4 <namex>
}
    80003fe6:	60a2                	ld	ra,8(sp)
    80003fe8:	6402                	ld	s0,0(sp)
    80003fea:	0141                	addi	sp,sp,16
    80003fec:	8082                	ret

0000000080003fee <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fee:	1101                	addi	sp,sp,-32
    80003ff0:	ec06                	sd	ra,24(sp)
    80003ff2:	e822                	sd	s0,16(sp)
    80003ff4:	e426                	sd	s1,8(sp)
    80003ff6:	e04a                	sd	s2,0(sp)
    80003ff8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ffa:	0001c917          	auipc	s2,0x1c
    80003ffe:	2ce90913          	addi	s2,s2,718 # 800202c8 <log>
    80004002:	01892583          	lw	a1,24(s2)
    80004006:	02492503          	lw	a0,36(s2)
    8000400a:	8ecff0ef          	jal	800030f6 <bread>
    8000400e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004010:	02892603          	lw	a2,40(s2)
    80004014:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004016:	00c05f63          	blez	a2,80004034 <write_head+0x46>
    8000401a:	0001c717          	auipc	a4,0x1c
    8000401e:	2da70713          	addi	a4,a4,730 # 800202f4 <log+0x2c>
    80004022:	87aa                	mv	a5,a0
    80004024:	060a                	slli	a2,a2,0x2
    80004026:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004028:	4314                	lw	a3,0(a4)
    8000402a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000402c:	0711                	addi	a4,a4,4
    8000402e:	0791                	addi	a5,a5,4
    80004030:	fec79ce3          	bne	a5,a2,80004028 <write_head+0x3a>
  }
  bwrite(buf);
    80004034:	8526                	mv	a0,s1
    80004036:	996ff0ef          	jal	800031cc <bwrite>
  brelse(buf);
    8000403a:	8526                	mv	a0,s1
    8000403c:	9c2ff0ef          	jal	800031fe <brelse>
}
    80004040:	60e2                	ld	ra,24(sp)
    80004042:	6442                	ld	s0,16(sp)
    80004044:	64a2                	ld	s1,8(sp)
    80004046:	6902                	ld	s2,0(sp)
    80004048:	6105                	addi	sp,sp,32
    8000404a:	8082                	ret

000000008000404c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000404c:	0001c797          	auipc	a5,0x1c
    80004050:	2a47a783          	lw	a5,676(a5) # 800202f0 <log+0x28>
    80004054:	0cf05163          	blez	a5,80004116 <install_trans+0xca>
{
    80004058:	715d                	addi	sp,sp,-80
    8000405a:	e486                	sd	ra,72(sp)
    8000405c:	e0a2                	sd	s0,64(sp)
    8000405e:	fc26                	sd	s1,56(sp)
    80004060:	f84a                	sd	s2,48(sp)
    80004062:	f44e                	sd	s3,40(sp)
    80004064:	f052                	sd	s4,32(sp)
    80004066:	ec56                	sd	s5,24(sp)
    80004068:	e85a                	sd	s6,16(sp)
    8000406a:	e45e                	sd	s7,8(sp)
    8000406c:	e062                	sd	s8,0(sp)
    8000406e:	0880                	addi	s0,sp,80
    80004070:	8b2a                	mv	s6,a0
    80004072:	0001ca97          	auipc	s5,0x1c
    80004076:	282a8a93          	addi	s5,s5,642 # 800202f4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000407a:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000407c:	00003c17          	auipc	s8,0x3
    80004080:	4fcc0c13          	addi	s8,s8,1276 # 80007578 <etext+0x578>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004084:	0001ca17          	auipc	s4,0x1c
    80004088:	244a0a13          	addi	s4,s4,580 # 800202c8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000408c:	40000b93          	li	s7,1024
    80004090:	a025                	j	800040b8 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004092:	000aa603          	lw	a2,0(s5)
    80004096:	85ce                	mv	a1,s3
    80004098:	8562                	mv	a0,s8
    8000409a:	c60fc0ef          	jal	800004fa <printf>
    8000409e:	a839                	j	800040bc <install_trans+0x70>
    brelse(lbuf);
    800040a0:	854a                	mv	a0,s2
    800040a2:	95cff0ef          	jal	800031fe <brelse>
    brelse(dbuf);
    800040a6:	8526                	mv	a0,s1
    800040a8:	956ff0ef          	jal	800031fe <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040ac:	2985                	addiw	s3,s3,1
    800040ae:	0a91                	addi	s5,s5,4
    800040b0:	028a2783          	lw	a5,40(s4)
    800040b4:	04f9d563          	bge	s3,a5,800040fe <install_trans+0xb2>
    if(recovering) {
    800040b8:	fc0b1de3          	bnez	s6,80004092 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040bc:	018a2583          	lw	a1,24(s4)
    800040c0:	013585bb          	addw	a1,a1,s3
    800040c4:	2585                	addiw	a1,a1,1
    800040c6:	024a2503          	lw	a0,36(s4)
    800040ca:	82cff0ef          	jal	800030f6 <bread>
    800040ce:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040d0:	000aa583          	lw	a1,0(s5)
    800040d4:	024a2503          	lw	a0,36(s4)
    800040d8:	81eff0ef          	jal	800030f6 <bread>
    800040dc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040de:	865e                	mv	a2,s7
    800040e0:	05890593          	addi	a1,s2,88
    800040e4:	05850513          	addi	a0,a0,88
    800040e8:	cb3fc0ef          	jal	80000d9a <memmove>
    bwrite(dbuf);  // write dst to disk
    800040ec:	8526                	mv	a0,s1
    800040ee:	8deff0ef          	jal	800031cc <bwrite>
    if(recovering == 0)
    800040f2:	fa0b17e3          	bnez	s6,800040a0 <install_trans+0x54>
      bunpin(dbuf);
    800040f6:	8526                	mv	a0,s1
    800040f8:	9beff0ef          	jal	800032b6 <bunpin>
    800040fc:	b755                	j	800040a0 <install_trans+0x54>
}
    800040fe:	60a6                	ld	ra,72(sp)
    80004100:	6406                	ld	s0,64(sp)
    80004102:	74e2                	ld	s1,56(sp)
    80004104:	7942                	ld	s2,48(sp)
    80004106:	79a2                	ld	s3,40(sp)
    80004108:	7a02                	ld	s4,32(sp)
    8000410a:	6ae2                	ld	s5,24(sp)
    8000410c:	6b42                	ld	s6,16(sp)
    8000410e:	6ba2                	ld	s7,8(sp)
    80004110:	6c02                	ld	s8,0(sp)
    80004112:	6161                	addi	sp,sp,80
    80004114:	8082                	ret
    80004116:	8082                	ret

0000000080004118 <initlog>:
{
    80004118:	7179                	addi	sp,sp,-48
    8000411a:	f406                	sd	ra,40(sp)
    8000411c:	f022                	sd	s0,32(sp)
    8000411e:	ec26                	sd	s1,24(sp)
    80004120:	e84a                	sd	s2,16(sp)
    80004122:	e44e                	sd	s3,8(sp)
    80004124:	1800                	addi	s0,sp,48
    80004126:	84aa                	mv	s1,a0
    80004128:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000412a:	0001c917          	auipc	s2,0x1c
    8000412e:	19e90913          	addi	s2,s2,414 # 800202c8 <log>
    80004132:	00003597          	auipc	a1,0x3
    80004136:	46658593          	addi	a1,a1,1126 # 80007598 <etext+0x598>
    8000413a:	854a                	mv	a0,s2
    8000413c:	aa5fc0ef          	jal	80000be0 <initlock>
  log.start = sb->logstart;
    80004140:	0149a583          	lw	a1,20(s3)
    80004144:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80004148:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    8000414c:	8526                	mv	a0,s1
    8000414e:	fa9fe0ef          	jal	800030f6 <bread>
  log.lh.n = lh->n;
    80004152:	4d30                	lw	a2,88(a0)
    80004154:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80004158:	00c05f63          	blez	a2,80004176 <initlog+0x5e>
    8000415c:	87aa                	mv	a5,a0
    8000415e:	0001c717          	auipc	a4,0x1c
    80004162:	19670713          	addi	a4,a4,406 # 800202f4 <log+0x2c>
    80004166:	060a                	slli	a2,a2,0x2
    80004168:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000416a:	4ff4                	lw	a3,92(a5)
    8000416c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000416e:	0791                	addi	a5,a5,4
    80004170:	0711                	addi	a4,a4,4
    80004172:	fec79ce3          	bne	a5,a2,8000416a <initlog+0x52>
  brelse(buf);
    80004176:	888ff0ef          	jal	800031fe <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000417a:	4505                	li	a0,1
    8000417c:	ed1ff0ef          	jal	8000404c <install_trans>
  log.lh.n = 0;
    80004180:	0001c797          	auipc	a5,0x1c
    80004184:	1607a823          	sw	zero,368(a5) # 800202f0 <log+0x28>
  write_head(); // clear the log
    80004188:	e67ff0ef          	jal	80003fee <write_head>
}
    8000418c:	70a2                	ld	ra,40(sp)
    8000418e:	7402                	ld	s0,32(sp)
    80004190:	64e2                	ld	s1,24(sp)
    80004192:	6942                	ld	s2,16(sp)
    80004194:	69a2                	ld	s3,8(sp)
    80004196:	6145                	addi	sp,sp,48
    80004198:	8082                	ret

000000008000419a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000419a:	1101                	addi	sp,sp,-32
    8000419c:	ec06                	sd	ra,24(sp)
    8000419e:	e822                	sd	s0,16(sp)
    800041a0:	e426                	sd	s1,8(sp)
    800041a2:	e04a                	sd	s2,0(sp)
    800041a4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041a6:	0001c517          	auipc	a0,0x1c
    800041aa:	12250513          	addi	a0,a0,290 # 800202c8 <log>
    800041ae:	abdfc0ef          	jal	80000c6a <acquire>
  while(1){
    if(log.committing){
    800041b2:	0001c497          	auipc	s1,0x1c
    800041b6:	11648493          	addi	s1,s1,278 # 800202c8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800041ba:	4979                	li	s2,30
    800041bc:	a029                	j	800041c6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800041be:	85a6                	mv	a1,s1
    800041c0:	8526                	mv	a0,s1
    800041c2:	e6ffd0ef          	jal	80002030 <sleep>
    if(log.committing){
    800041c6:	509c                	lw	a5,32(s1)
    800041c8:	fbfd                	bnez	a5,800041be <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800041ca:	4cd8                	lw	a4,28(s1)
    800041cc:	2705                	addiw	a4,a4,1
    800041ce:	0027179b          	slliw	a5,a4,0x2
    800041d2:	9fb9                	addw	a5,a5,a4
    800041d4:	0017979b          	slliw	a5,a5,0x1
    800041d8:	5494                	lw	a3,40(s1)
    800041da:	9fb5                	addw	a5,a5,a3
    800041dc:	00f95763          	bge	s2,a5,800041ea <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800041e0:	85a6                	mv	a1,s1
    800041e2:	8526                	mv	a0,s1
    800041e4:	e4dfd0ef          	jal	80002030 <sleep>
    800041e8:	bff9                	j	800041c6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800041ea:	0001c797          	auipc	a5,0x1c
    800041ee:	0ee7ad23          	sw	a4,250(a5) # 800202e4 <log+0x1c>
      release(&log.lock);
    800041f2:	0001c517          	auipc	a0,0x1c
    800041f6:	0d650513          	addi	a0,a0,214 # 800202c8 <log>
    800041fa:	b05fc0ef          	jal	80000cfe <release>
      break;
    }
  }
}
    800041fe:	60e2                	ld	ra,24(sp)
    80004200:	6442                	ld	s0,16(sp)
    80004202:	64a2                	ld	s1,8(sp)
    80004204:	6902                	ld	s2,0(sp)
    80004206:	6105                	addi	sp,sp,32
    80004208:	8082                	ret

000000008000420a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000420a:	7139                	addi	sp,sp,-64
    8000420c:	fc06                	sd	ra,56(sp)
    8000420e:	f822                	sd	s0,48(sp)
    80004210:	f426                	sd	s1,40(sp)
    80004212:	f04a                	sd	s2,32(sp)
    80004214:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004216:	0001c497          	auipc	s1,0x1c
    8000421a:	0b248493          	addi	s1,s1,178 # 800202c8 <log>
    8000421e:	8526                	mv	a0,s1
    80004220:	a4bfc0ef          	jal	80000c6a <acquire>
  log.outstanding -= 1;
    80004224:	4cdc                	lw	a5,28(s1)
    80004226:	37fd                	addiw	a5,a5,-1
    80004228:	893e                	mv	s2,a5
    8000422a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000422c:	509c                	lw	a5,32(s1)
    8000422e:	e7b1                	bnez	a5,8000427a <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80004230:	04091e63          	bnez	s2,8000428c <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80004234:	0001c497          	auipc	s1,0x1c
    80004238:	09448493          	addi	s1,s1,148 # 800202c8 <log>
    8000423c:	4785                	li	a5,1
    8000423e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004240:	8526                	mv	a0,s1
    80004242:	abdfc0ef          	jal	80000cfe <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004246:	549c                	lw	a5,40(s1)
    80004248:	06f04463          	bgtz	a5,800042b0 <end_op+0xa6>
    acquire(&log.lock);
    8000424c:	0001c517          	auipc	a0,0x1c
    80004250:	07c50513          	addi	a0,a0,124 # 800202c8 <log>
    80004254:	a17fc0ef          	jal	80000c6a <acquire>
    log.committing = 0;
    80004258:	0001c797          	auipc	a5,0x1c
    8000425c:	0807a823          	sw	zero,144(a5) # 800202e8 <log+0x20>
    wakeup(&log);
    80004260:	0001c517          	auipc	a0,0x1c
    80004264:	06850513          	addi	a0,a0,104 # 800202c8 <log>
    80004268:	e15fd0ef          	jal	8000207c <wakeup>
    release(&log.lock);
    8000426c:	0001c517          	auipc	a0,0x1c
    80004270:	05c50513          	addi	a0,a0,92 # 800202c8 <log>
    80004274:	a8bfc0ef          	jal	80000cfe <release>
}
    80004278:	a035                	j	800042a4 <end_op+0x9a>
    8000427a:	ec4e                	sd	s3,24(sp)
    8000427c:	e852                	sd	s4,16(sp)
    8000427e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004280:	00003517          	auipc	a0,0x3
    80004284:	32050513          	addi	a0,a0,800 # 800075a0 <etext+0x5a0>
    80004288:	d9cfc0ef          	jal	80000824 <panic>
    wakeup(&log);
    8000428c:	0001c517          	auipc	a0,0x1c
    80004290:	03c50513          	addi	a0,a0,60 # 800202c8 <log>
    80004294:	de9fd0ef          	jal	8000207c <wakeup>
  release(&log.lock);
    80004298:	0001c517          	auipc	a0,0x1c
    8000429c:	03050513          	addi	a0,a0,48 # 800202c8 <log>
    800042a0:	a5ffc0ef          	jal	80000cfe <release>
}
    800042a4:	70e2                	ld	ra,56(sp)
    800042a6:	7442                	ld	s0,48(sp)
    800042a8:	74a2                	ld	s1,40(sp)
    800042aa:	7902                	ld	s2,32(sp)
    800042ac:	6121                	addi	sp,sp,64
    800042ae:	8082                	ret
    800042b0:	ec4e                	sd	s3,24(sp)
    800042b2:	e852                	sd	s4,16(sp)
    800042b4:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800042b6:	0001ca97          	auipc	s5,0x1c
    800042ba:	03ea8a93          	addi	s5,s5,62 # 800202f4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042be:	0001ca17          	auipc	s4,0x1c
    800042c2:	00aa0a13          	addi	s4,s4,10 # 800202c8 <log>
    800042c6:	018a2583          	lw	a1,24(s4)
    800042ca:	012585bb          	addw	a1,a1,s2
    800042ce:	2585                	addiw	a1,a1,1
    800042d0:	024a2503          	lw	a0,36(s4)
    800042d4:	e23fe0ef          	jal	800030f6 <bread>
    800042d8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042da:	000aa583          	lw	a1,0(s5)
    800042de:	024a2503          	lw	a0,36(s4)
    800042e2:	e15fe0ef          	jal	800030f6 <bread>
    800042e6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042e8:	40000613          	li	a2,1024
    800042ec:	05850593          	addi	a1,a0,88
    800042f0:	05848513          	addi	a0,s1,88
    800042f4:	aa7fc0ef          	jal	80000d9a <memmove>
    bwrite(to);  // write the log
    800042f8:	8526                	mv	a0,s1
    800042fa:	ed3fe0ef          	jal	800031cc <bwrite>
    brelse(from);
    800042fe:	854e                	mv	a0,s3
    80004300:	efffe0ef          	jal	800031fe <brelse>
    brelse(to);
    80004304:	8526                	mv	a0,s1
    80004306:	ef9fe0ef          	jal	800031fe <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000430a:	2905                	addiw	s2,s2,1
    8000430c:	0a91                	addi	s5,s5,4
    8000430e:	028a2783          	lw	a5,40(s4)
    80004312:	faf94ae3          	blt	s2,a5,800042c6 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004316:	cd9ff0ef          	jal	80003fee <write_head>
    install_trans(0); // Now install writes to home locations
    8000431a:	4501                	li	a0,0
    8000431c:	d31ff0ef          	jal	8000404c <install_trans>
    log.lh.n = 0;
    80004320:	0001c797          	auipc	a5,0x1c
    80004324:	fc07a823          	sw	zero,-48(a5) # 800202f0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004328:	cc7ff0ef          	jal	80003fee <write_head>
    8000432c:	69e2                	ld	s3,24(sp)
    8000432e:	6a42                	ld	s4,16(sp)
    80004330:	6aa2                	ld	s5,8(sp)
    80004332:	bf29                	j	8000424c <end_op+0x42>

0000000080004334 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004334:	1101                	addi	sp,sp,-32
    80004336:	ec06                	sd	ra,24(sp)
    80004338:	e822                	sd	s0,16(sp)
    8000433a:	e426                	sd	s1,8(sp)
    8000433c:	1000                	addi	s0,sp,32
    8000433e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004340:	0001c517          	auipc	a0,0x1c
    80004344:	f8850513          	addi	a0,a0,-120 # 800202c8 <log>
    80004348:	923fc0ef          	jal	80000c6a <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000434c:	0001c617          	auipc	a2,0x1c
    80004350:	fa462603          	lw	a2,-92(a2) # 800202f0 <log+0x28>
    80004354:	47f5                	li	a5,29
    80004356:	04c7cd63          	blt	a5,a2,800043b0 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000435a:	0001c797          	auipc	a5,0x1c
    8000435e:	f8a7a783          	lw	a5,-118(a5) # 800202e4 <log+0x1c>
    80004362:	04f05d63          	blez	a5,800043bc <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004366:	4781                	li	a5,0
    80004368:	06c05063          	blez	a2,800043c8 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000436c:	44cc                	lw	a1,12(s1)
    8000436e:	0001c717          	auipc	a4,0x1c
    80004372:	f8670713          	addi	a4,a4,-122 # 800202f4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004376:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004378:	4314                	lw	a3,0(a4)
    8000437a:	04b68763          	beq	a3,a1,800043c8 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    8000437e:	2785                	addiw	a5,a5,1
    80004380:	0711                	addi	a4,a4,4
    80004382:	fef61be3          	bne	a2,a5,80004378 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004386:	060a                	slli	a2,a2,0x2
    80004388:	02060613          	addi	a2,a2,32
    8000438c:	0001c797          	auipc	a5,0x1c
    80004390:	f3c78793          	addi	a5,a5,-196 # 800202c8 <log>
    80004394:	97b2                	add	a5,a5,a2
    80004396:	44d8                	lw	a4,12(s1)
    80004398:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000439a:	8526                	mv	a0,s1
    8000439c:	ee7fe0ef          	jal	80003282 <bpin>
    log.lh.n++;
    800043a0:	0001c717          	auipc	a4,0x1c
    800043a4:	f2870713          	addi	a4,a4,-216 # 800202c8 <log>
    800043a8:	571c                	lw	a5,40(a4)
    800043aa:	2785                	addiw	a5,a5,1
    800043ac:	d71c                	sw	a5,40(a4)
    800043ae:	a815                	j	800043e2 <log_write+0xae>
    panic("too big a transaction");
    800043b0:	00003517          	auipc	a0,0x3
    800043b4:	20050513          	addi	a0,a0,512 # 800075b0 <etext+0x5b0>
    800043b8:	c6cfc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    800043bc:	00003517          	auipc	a0,0x3
    800043c0:	20c50513          	addi	a0,a0,524 # 800075c8 <etext+0x5c8>
    800043c4:	c60fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    800043c8:	00279693          	slli	a3,a5,0x2
    800043cc:	02068693          	addi	a3,a3,32
    800043d0:	0001c717          	auipc	a4,0x1c
    800043d4:	ef870713          	addi	a4,a4,-264 # 800202c8 <log>
    800043d8:	9736                	add	a4,a4,a3
    800043da:	44d4                	lw	a3,12(s1)
    800043dc:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043de:	faf60ee3          	beq	a2,a5,8000439a <log_write+0x66>
  }
  release(&log.lock);
    800043e2:	0001c517          	auipc	a0,0x1c
    800043e6:	ee650513          	addi	a0,a0,-282 # 800202c8 <log>
    800043ea:	915fc0ef          	jal	80000cfe <release>
}
    800043ee:	60e2                	ld	ra,24(sp)
    800043f0:	6442                	ld	s0,16(sp)
    800043f2:	64a2                	ld	s1,8(sp)
    800043f4:	6105                	addi	sp,sp,32
    800043f6:	8082                	ret

00000000800043f8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043f8:	1101                	addi	sp,sp,-32
    800043fa:	ec06                	sd	ra,24(sp)
    800043fc:	e822                	sd	s0,16(sp)
    800043fe:	e426                	sd	s1,8(sp)
    80004400:	e04a                	sd	s2,0(sp)
    80004402:	1000                	addi	s0,sp,32
    80004404:	84aa                	mv	s1,a0
    80004406:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004408:	00003597          	auipc	a1,0x3
    8000440c:	1e058593          	addi	a1,a1,480 # 800075e8 <etext+0x5e8>
    80004410:	0521                	addi	a0,a0,8
    80004412:	fcefc0ef          	jal	80000be0 <initlock>
  lk->name = name;
    80004416:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000441a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000441e:	0204a423          	sw	zero,40(s1)
}
    80004422:	60e2                	ld	ra,24(sp)
    80004424:	6442                	ld	s0,16(sp)
    80004426:	64a2                	ld	s1,8(sp)
    80004428:	6902                	ld	s2,0(sp)
    8000442a:	6105                	addi	sp,sp,32
    8000442c:	8082                	ret

000000008000442e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000442e:	1101                	addi	sp,sp,-32
    80004430:	ec06                	sd	ra,24(sp)
    80004432:	e822                	sd	s0,16(sp)
    80004434:	e426                	sd	s1,8(sp)
    80004436:	e04a                	sd	s2,0(sp)
    80004438:	1000                	addi	s0,sp,32
    8000443a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000443c:	00850913          	addi	s2,a0,8
    80004440:	854a                	mv	a0,s2
    80004442:	829fc0ef          	jal	80000c6a <acquire>
  while (lk->locked) {
    80004446:	409c                	lw	a5,0(s1)
    80004448:	c799                	beqz	a5,80004456 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000444a:	85ca                	mv	a1,s2
    8000444c:	8526                	mv	a0,s1
    8000444e:	be3fd0ef          	jal	80002030 <sleep>
  while (lk->locked) {
    80004452:	409c                	lw	a5,0(s1)
    80004454:	fbfd                	bnez	a5,8000444a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004456:	4785                	li	a5,1
    80004458:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000445a:	d0afd0ef          	jal	80001964 <myproc>
    8000445e:	591c                	lw	a5,48(a0)
    80004460:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004462:	854a                	mv	a0,s2
    80004464:	89bfc0ef          	jal	80000cfe <release>
}
    80004468:	60e2                	ld	ra,24(sp)
    8000446a:	6442                	ld	s0,16(sp)
    8000446c:	64a2                	ld	s1,8(sp)
    8000446e:	6902                	ld	s2,0(sp)
    80004470:	6105                	addi	sp,sp,32
    80004472:	8082                	ret

0000000080004474 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004474:	1101                	addi	sp,sp,-32
    80004476:	ec06                	sd	ra,24(sp)
    80004478:	e822                	sd	s0,16(sp)
    8000447a:	e426                	sd	s1,8(sp)
    8000447c:	e04a                	sd	s2,0(sp)
    8000447e:	1000                	addi	s0,sp,32
    80004480:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004482:	00850913          	addi	s2,a0,8
    80004486:	854a                	mv	a0,s2
    80004488:	fe2fc0ef          	jal	80000c6a <acquire>
  lk->locked = 0;
    8000448c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004490:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004494:	8526                	mv	a0,s1
    80004496:	be7fd0ef          	jal	8000207c <wakeup>
  release(&lk->lk);
    8000449a:	854a                	mv	a0,s2
    8000449c:	863fc0ef          	jal	80000cfe <release>
}
    800044a0:	60e2                	ld	ra,24(sp)
    800044a2:	6442                	ld	s0,16(sp)
    800044a4:	64a2                	ld	s1,8(sp)
    800044a6:	6902                	ld	s2,0(sp)
    800044a8:	6105                	addi	sp,sp,32
    800044aa:	8082                	ret

00000000800044ac <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044ac:	7179                	addi	sp,sp,-48
    800044ae:	f406                	sd	ra,40(sp)
    800044b0:	f022                	sd	s0,32(sp)
    800044b2:	ec26                	sd	s1,24(sp)
    800044b4:	e84a                	sd	s2,16(sp)
    800044b6:	1800                	addi	s0,sp,48
    800044b8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044ba:	00850913          	addi	s2,a0,8
    800044be:	854a                	mv	a0,s2
    800044c0:	faafc0ef          	jal	80000c6a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044c4:	409c                	lw	a5,0(s1)
    800044c6:	ef81                	bnez	a5,800044de <holdingsleep+0x32>
    800044c8:	4481                	li	s1,0
  release(&lk->lk);
    800044ca:	854a                	mv	a0,s2
    800044cc:	833fc0ef          	jal	80000cfe <release>
  return r;
}
    800044d0:	8526                	mv	a0,s1
    800044d2:	70a2                	ld	ra,40(sp)
    800044d4:	7402                	ld	s0,32(sp)
    800044d6:	64e2                	ld	s1,24(sp)
    800044d8:	6942                	ld	s2,16(sp)
    800044da:	6145                	addi	sp,sp,48
    800044dc:	8082                	ret
    800044de:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800044e0:	0284a983          	lw	s3,40(s1)
    800044e4:	c80fd0ef          	jal	80001964 <myproc>
    800044e8:	5904                	lw	s1,48(a0)
    800044ea:	413484b3          	sub	s1,s1,s3
    800044ee:	0014b493          	seqz	s1,s1
    800044f2:	69a2                	ld	s3,8(sp)
    800044f4:	bfd9                	j	800044ca <holdingsleep+0x1e>

00000000800044f6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044f6:	1141                	addi	sp,sp,-16
    800044f8:	e406                	sd	ra,8(sp)
    800044fa:	e022                	sd	s0,0(sp)
    800044fc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044fe:	00003597          	auipc	a1,0x3
    80004502:	0fa58593          	addi	a1,a1,250 # 800075f8 <etext+0x5f8>
    80004506:	0001c517          	auipc	a0,0x1c
    8000450a:	f0a50513          	addi	a0,a0,-246 # 80020410 <ftable>
    8000450e:	ed2fc0ef          	jal	80000be0 <initlock>
}
    80004512:	60a2                	ld	ra,8(sp)
    80004514:	6402                	ld	s0,0(sp)
    80004516:	0141                	addi	sp,sp,16
    80004518:	8082                	ret

000000008000451a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000451a:	1101                	addi	sp,sp,-32
    8000451c:	ec06                	sd	ra,24(sp)
    8000451e:	e822                	sd	s0,16(sp)
    80004520:	e426                	sd	s1,8(sp)
    80004522:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004524:	0001c517          	auipc	a0,0x1c
    80004528:	eec50513          	addi	a0,a0,-276 # 80020410 <ftable>
    8000452c:	f3efc0ef          	jal	80000c6a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004530:	0001c497          	auipc	s1,0x1c
    80004534:	ef848493          	addi	s1,s1,-264 # 80020428 <ftable+0x18>
    80004538:	0001d717          	auipc	a4,0x1d
    8000453c:	e9070713          	addi	a4,a4,-368 # 800213c8 <disk>
    if(f->ref == 0){
    80004540:	40dc                	lw	a5,4(s1)
    80004542:	cf89                	beqz	a5,8000455c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004544:	02848493          	addi	s1,s1,40
    80004548:	fee49ce3          	bne	s1,a4,80004540 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000454c:	0001c517          	auipc	a0,0x1c
    80004550:	ec450513          	addi	a0,a0,-316 # 80020410 <ftable>
    80004554:	faafc0ef          	jal	80000cfe <release>
  return 0;
    80004558:	4481                	li	s1,0
    8000455a:	a809                	j	8000456c <filealloc+0x52>
      f->ref = 1;
    8000455c:	4785                	li	a5,1
    8000455e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004560:	0001c517          	auipc	a0,0x1c
    80004564:	eb050513          	addi	a0,a0,-336 # 80020410 <ftable>
    80004568:	f96fc0ef          	jal	80000cfe <release>
}
    8000456c:	8526                	mv	a0,s1
    8000456e:	60e2                	ld	ra,24(sp)
    80004570:	6442                	ld	s0,16(sp)
    80004572:	64a2                	ld	s1,8(sp)
    80004574:	6105                	addi	sp,sp,32
    80004576:	8082                	ret

0000000080004578 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004578:	1101                	addi	sp,sp,-32
    8000457a:	ec06                	sd	ra,24(sp)
    8000457c:	e822                	sd	s0,16(sp)
    8000457e:	e426                	sd	s1,8(sp)
    80004580:	1000                	addi	s0,sp,32
    80004582:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004584:	0001c517          	auipc	a0,0x1c
    80004588:	e8c50513          	addi	a0,a0,-372 # 80020410 <ftable>
    8000458c:	edefc0ef          	jal	80000c6a <acquire>
  if(f->ref < 1)
    80004590:	40dc                	lw	a5,4(s1)
    80004592:	02f05063          	blez	a5,800045b2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004596:	2785                	addiw	a5,a5,1
    80004598:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000459a:	0001c517          	auipc	a0,0x1c
    8000459e:	e7650513          	addi	a0,a0,-394 # 80020410 <ftable>
    800045a2:	f5cfc0ef          	jal	80000cfe <release>
  return f;
}
    800045a6:	8526                	mv	a0,s1
    800045a8:	60e2                	ld	ra,24(sp)
    800045aa:	6442                	ld	s0,16(sp)
    800045ac:	64a2                	ld	s1,8(sp)
    800045ae:	6105                	addi	sp,sp,32
    800045b0:	8082                	ret
    panic("filedup");
    800045b2:	00003517          	auipc	a0,0x3
    800045b6:	04e50513          	addi	a0,a0,78 # 80007600 <etext+0x600>
    800045ba:	a6afc0ef          	jal	80000824 <panic>

00000000800045be <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045be:	7139                	addi	sp,sp,-64
    800045c0:	fc06                	sd	ra,56(sp)
    800045c2:	f822                	sd	s0,48(sp)
    800045c4:	f426                	sd	s1,40(sp)
    800045c6:	0080                	addi	s0,sp,64
    800045c8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045ca:	0001c517          	auipc	a0,0x1c
    800045ce:	e4650513          	addi	a0,a0,-442 # 80020410 <ftable>
    800045d2:	e98fc0ef          	jal	80000c6a <acquire>
  if(f->ref < 1)
    800045d6:	40dc                	lw	a5,4(s1)
    800045d8:	04f05a63          	blez	a5,8000462c <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800045dc:	37fd                	addiw	a5,a5,-1
    800045de:	c0dc                	sw	a5,4(s1)
    800045e0:	06f04063          	bgtz	a5,80004640 <fileclose+0x82>
    800045e4:	f04a                	sd	s2,32(sp)
    800045e6:	ec4e                	sd	s3,24(sp)
    800045e8:	e852                	sd	s4,16(sp)
    800045ea:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045ec:	0004a903          	lw	s2,0(s1)
    800045f0:	0094c783          	lbu	a5,9(s1)
    800045f4:	89be                	mv	s3,a5
    800045f6:	689c                	ld	a5,16(s1)
    800045f8:	8a3e                	mv	s4,a5
    800045fa:	6c9c                	ld	a5,24(s1)
    800045fc:	8abe                	mv	s5,a5
  f->ref = 0;
    800045fe:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004602:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004606:	0001c517          	auipc	a0,0x1c
    8000460a:	e0a50513          	addi	a0,a0,-502 # 80020410 <ftable>
    8000460e:	ef0fc0ef          	jal	80000cfe <release>

  if(ff.type == FD_PIPE){
    80004612:	4785                	li	a5,1
    80004614:	04f90163          	beq	s2,a5,80004656 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004618:	ffe9079b          	addiw	a5,s2,-2
    8000461c:	4705                	li	a4,1
    8000461e:	04f77563          	bgeu	a4,a5,80004668 <fileclose+0xaa>
    80004622:	7902                	ld	s2,32(sp)
    80004624:	69e2                	ld	s3,24(sp)
    80004626:	6a42                	ld	s4,16(sp)
    80004628:	6aa2                	ld	s5,8(sp)
    8000462a:	a00d                	j	8000464c <fileclose+0x8e>
    8000462c:	f04a                	sd	s2,32(sp)
    8000462e:	ec4e                	sd	s3,24(sp)
    80004630:	e852                	sd	s4,16(sp)
    80004632:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004634:	00003517          	auipc	a0,0x3
    80004638:	fd450513          	addi	a0,a0,-44 # 80007608 <etext+0x608>
    8000463c:	9e8fc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    80004640:	0001c517          	auipc	a0,0x1c
    80004644:	dd050513          	addi	a0,a0,-560 # 80020410 <ftable>
    80004648:	eb6fc0ef          	jal	80000cfe <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000464c:	70e2                	ld	ra,56(sp)
    8000464e:	7442                	ld	s0,48(sp)
    80004650:	74a2                	ld	s1,40(sp)
    80004652:	6121                	addi	sp,sp,64
    80004654:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004656:	85ce                	mv	a1,s3
    80004658:	8552                	mv	a0,s4
    8000465a:	348000ef          	jal	800049a2 <pipeclose>
    8000465e:	7902                	ld	s2,32(sp)
    80004660:	69e2                	ld	s3,24(sp)
    80004662:	6a42                	ld	s4,16(sp)
    80004664:	6aa2                	ld	s5,8(sp)
    80004666:	b7dd                	j	8000464c <fileclose+0x8e>
    begin_op();
    80004668:	b33ff0ef          	jal	8000419a <begin_op>
    iput(ff.ip);
    8000466c:	8556                	mv	a0,s5
    8000466e:	aa2ff0ef          	jal	80003910 <iput>
    end_op();
    80004672:	b99ff0ef          	jal	8000420a <end_op>
    80004676:	7902                	ld	s2,32(sp)
    80004678:	69e2                	ld	s3,24(sp)
    8000467a:	6a42                	ld	s4,16(sp)
    8000467c:	6aa2                	ld	s5,8(sp)
    8000467e:	b7f9                	j	8000464c <fileclose+0x8e>

0000000080004680 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004680:	715d                	addi	sp,sp,-80
    80004682:	e486                	sd	ra,72(sp)
    80004684:	e0a2                	sd	s0,64(sp)
    80004686:	fc26                	sd	s1,56(sp)
    80004688:	f052                	sd	s4,32(sp)
    8000468a:	0880                	addi	s0,sp,80
    8000468c:	84aa                	mv	s1,a0
    8000468e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004690:	ad4fd0ef          	jal	80001964 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004694:	409c                	lw	a5,0(s1)
    80004696:	37f9                	addiw	a5,a5,-2
    80004698:	4705                	li	a4,1
    8000469a:	04f76263          	bltu	a4,a5,800046de <filestat+0x5e>
    8000469e:	f84a                	sd	s2,48(sp)
    800046a0:	f44e                	sd	s3,40(sp)
    800046a2:	89aa                	mv	s3,a0
    ilock(f->ip);
    800046a4:	6c88                	ld	a0,24(s1)
    800046a6:	8e8ff0ef          	jal	8000378e <ilock>
    stati(f->ip, &st);
    800046aa:	fb840913          	addi	s2,s0,-72
    800046ae:	85ca                	mv	a1,s2
    800046b0:	6c88                	ld	a0,24(s1)
    800046b2:	c40ff0ef          	jal	80003af2 <stati>
    iunlock(f->ip);
    800046b6:	6c88                	ld	a0,24(s1)
    800046b8:	984ff0ef          	jal	8000383c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046bc:	46e1                	li	a3,24
    800046be:	864a                	mv	a2,s2
    800046c0:	85d2                	mv	a1,s4
    800046c2:	0709b503          	ld	a0,112(s3)
    800046c6:	fd1fc0ef          	jal	80001696 <copyout>
    800046ca:	41f5551b          	sraiw	a0,a0,0x1f
    800046ce:	7942                	ld	s2,48(sp)
    800046d0:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800046d2:	60a6                	ld	ra,72(sp)
    800046d4:	6406                	ld	s0,64(sp)
    800046d6:	74e2                	ld	s1,56(sp)
    800046d8:	7a02                	ld	s4,32(sp)
    800046da:	6161                	addi	sp,sp,80
    800046dc:	8082                	ret
  return -1;
    800046de:	557d                	li	a0,-1
    800046e0:	bfcd                	j	800046d2 <filestat+0x52>

00000000800046e2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046e2:	7179                	addi	sp,sp,-48
    800046e4:	f406                	sd	ra,40(sp)
    800046e6:	f022                	sd	s0,32(sp)
    800046e8:	e84a                	sd	s2,16(sp)
    800046ea:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046ec:	00854783          	lbu	a5,8(a0)
    800046f0:	cfd1                	beqz	a5,8000478c <fileread+0xaa>
    800046f2:	ec26                	sd	s1,24(sp)
    800046f4:	e44e                	sd	s3,8(sp)
    800046f6:	84aa                	mv	s1,a0
    800046f8:	892e                	mv	s2,a1
    800046fa:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800046fc:	411c                	lw	a5,0(a0)
    800046fe:	4705                	li	a4,1
    80004700:	04e78363          	beq	a5,a4,80004746 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004704:	470d                	li	a4,3
    80004706:	04e78763          	beq	a5,a4,80004754 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000470a:	4709                	li	a4,2
    8000470c:	06e79a63          	bne	a5,a4,80004780 <fileread+0x9e>
    ilock(f->ip);
    80004710:	6d08                	ld	a0,24(a0)
    80004712:	87cff0ef          	jal	8000378e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004716:	874e                	mv	a4,s3
    80004718:	5094                	lw	a3,32(s1)
    8000471a:	864a                	mv	a2,s2
    8000471c:	4585                	li	a1,1
    8000471e:	6c88                	ld	a0,24(s1)
    80004720:	c00ff0ef          	jal	80003b20 <readi>
    80004724:	892a                	mv	s2,a0
    80004726:	00a05563          	blez	a0,80004730 <fileread+0x4e>
      f->off += r;
    8000472a:	509c                	lw	a5,32(s1)
    8000472c:	9fa9                	addw	a5,a5,a0
    8000472e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004730:	6c88                	ld	a0,24(s1)
    80004732:	90aff0ef          	jal	8000383c <iunlock>
    80004736:	64e2                	ld	s1,24(sp)
    80004738:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000473a:	854a                	mv	a0,s2
    8000473c:	70a2                	ld	ra,40(sp)
    8000473e:	7402                	ld	s0,32(sp)
    80004740:	6942                	ld	s2,16(sp)
    80004742:	6145                	addi	sp,sp,48
    80004744:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004746:	6908                	ld	a0,16(a0)
    80004748:	3b0000ef          	jal	80004af8 <piperead>
    8000474c:	892a                	mv	s2,a0
    8000474e:	64e2                	ld	s1,24(sp)
    80004750:	69a2                	ld	s3,8(sp)
    80004752:	b7e5                	j	8000473a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004754:	02451783          	lh	a5,36(a0)
    80004758:	03079693          	slli	a3,a5,0x30
    8000475c:	92c1                	srli	a3,a3,0x30
    8000475e:	4725                	li	a4,9
    80004760:	02d76963          	bltu	a4,a3,80004792 <fileread+0xb0>
    80004764:	0792                	slli	a5,a5,0x4
    80004766:	0001c717          	auipc	a4,0x1c
    8000476a:	c0a70713          	addi	a4,a4,-1014 # 80020370 <devsw>
    8000476e:	97ba                	add	a5,a5,a4
    80004770:	639c                	ld	a5,0(a5)
    80004772:	c78d                	beqz	a5,8000479c <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004774:	4505                	li	a0,1
    80004776:	9782                	jalr	a5
    80004778:	892a                	mv	s2,a0
    8000477a:	64e2                	ld	s1,24(sp)
    8000477c:	69a2                	ld	s3,8(sp)
    8000477e:	bf75                	j	8000473a <fileread+0x58>
    panic("fileread");
    80004780:	00003517          	auipc	a0,0x3
    80004784:	e9850513          	addi	a0,a0,-360 # 80007618 <etext+0x618>
    80004788:	89cfc0ef          	jal	80000824 <panic>
    return -1;
    8000478c:	57fd                	li	a5,-1
    8000478e:	893e                	mv	s2,a5
    80004790:	b76d                	j	8000473a <fileread+0x58>
      return -1;
    80004792:	57fd                	li	a5,-1
    80004794:	893e                	mv	s2,a5
    80004796:	64e2                	ld	s1,24(sp)
    80004798:	69a2                	ld	s3,8(sp)
    8000479a:	b745                	j	8000473a <fileread+0x58>
    8000479c:	57fd                	li	a5,-1
    8000479e:	893e                	mv	s2,a5
    800047a0:	64e2                	ld	s1,24(sp)
    800047a2:	69a2                	ld	s3,8(sp)
    800047a4:	bf59                	j	8000473a <fileread+0x58>

00000000800047a6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047a6:	00954783          	lbu	a5,9(a0)
    800047aa:	10078f63          	beqz	a5,800048c8 <filewrite+0x122>
{
    800047ae:	711d                	addi	sp,sp,-96
    800047b0:	ec86                	sd	ra,88(sp)
    800047b2:	e8a2                	sd	s0,80(sp)
    800047b4:	e0ca                	sd	s2,64(sp)
    800047b6:	f456                	sd	s5,40(sp)
    800047b8:	f05a                	sd	s6,32(sp)
    800047ba:	1080                	addi	s0,sp,96
    800047bc:	892a                	mv	s2,a0
    800047be:	8b2e                	mv	s6,a1
    800047c0:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800047c2:	411c                	lw	a5,0(a0)
    800047c4:	4705                	li	a4,1
    800047c6:	02e78a63          	beq	a5,a4,800047fa <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047ca:	470d                	li	a4,3
    800047cc:	02e78b63          	beq	a5,a4,80004802 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047d0:	4709                	li	a4,2
    800047d2:	0ce79f63          	bne	a5,a4,800048b0 <filewrite+0x10a>
    800047d6:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047d8:	0ac05a63          	blez	a2,8000488c <filewrite+0xe6>
    800047dc:	e4a6                	sd	s1,72(sp)
    800047de:	fc4e                	sd	s3,56(sp)
    800047e0:	ec5e                	sd	s7,24(sp)
    800047e2:	e862                	sd	s8,16(sp)
    800047e4:	e466                	sd	s9,8(sp)
    int i = 0;
    800047e6:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800047e8:	6b85                	lui	s7,0x1
    800047ea:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047ee:	6785                	lui	a5,0x1
    800047f0:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800047f4:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047f6:	4c05                	li	s8,1
    800047f8:	a8ad                	j	80004872 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800047fa:	6908                	ld	a0,16(a0)
    800047fc:	204000ef          	jal	80004a00 <pipewrite>
    80004800:	a04d                	j	800048a2 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004802:	02451783          	lh	a5,36(a0)
    80004806:	03079693          	slli	a3,a5,0x30
    8000480a:	92c1                	srli	a3,a3,0x30
    8000480c:	4725                	li	a4,9
    8000480e:	0ad76f63          	bltu	a4,a3,800048cc <filewrite+0x126>
    80004812:	0792                	slli	a5,a5,0x4
    80004814:	0001c717          	auipc	a4,0x1c
    80004818:	b5c70713          	addi	a4,a4,-1188 # 80020370 <devsw>
    8000481c:	97ba                	add	a5,a5,a4
    8000481e:	679c                	ld	a5,8(a5)
    80004820:	cbc5                	beqz	a5,800048d0 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004822:	4505                	li	a0,1
    80004824:	9782                	jalr	a5
    80004826:	a8b5                	j	800048a2 <filewrite+0xfc>
      if(n1 > max)
    80004828:	2981                	sext.w	s3,s3
      begin_op();
    8000482a:	971ff0ef          	jal	8000419a <begin_op>
      ilock(f->ip);
    8000482e:	01893503          	ld	a0,24(s2)
    80004832:	f5dfe0ef          	jal	8000378e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004836:	874e                	mv	a4,s3
    80004838:	02092683          	lw	a3,32(s2)
    8000483c:	016a0633          	add	a2,s4,s6
    80004840:	85e2                	mv	a1,s8
    80004842:	01893503          	ld	a0,24(s2)
    80004846:	bccff0ef          	jal	80003c12 <writei>
    8000484a:	84aa                	mv	s1,a0
    8000484c:	00a05763          	blez	a0,8000485a <filewrite+0xb4>
        f->off += r;
    80004850:	02092783          	lw	a5,32(s2)
    80004854:	9fa9                	addw	a5,a5,a0
    80004856:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000485a:	01893503          	ld	a0,24(s2)
    8000485e:	fdffe0ef          	jal	8000383c <iunlock>
      end_op();
    80004862:	9a9ff0ef          	jal	8000420a <end_op>

      if(r != n1){
    80004866:	02999563          	bne	s3,s1,80004890 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    8000486a:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000486e:	015a5963          	bge	s4,s5,80004880 <filewrite+0xda>
      int n1 = n - i;
    80004872:	414a87bb          	subw	a5,s5,s4
    80004876:	89be                	mv	s3,a5
      if(n1 > max)
    80004878:	fafbd8e3          	bge	s7,a5,80004828 <filewrite+0x82>
    8000487c:	89e6                	mv	s3,s9
    8000487e:	b76d                	j	80004828 <filewrite+0x82>
    80004880:	64a6                	ld	s1,72(sp)
    80004882:	79e2                	ld	s3,56(sp)
    80004884:	6be2                	ld	s7,24(sp)
    80004886:	6c42                	ld	s8,16(sp)
    80004888:	6ca2                	ld	s9,8(sp)
    8000488a:	a801                	j	8000489a <filewrite+0xf4>
    int i = 0;
    8000488c:	4a01                	li	s4,0
    8000488e:	a031                	j	8000489a <filewrite+0xf4>
    80004890:	64a6                	ld	s1,72(sp)
    80004892:	79e2                	ld	s3,56(sp)
    80004894:	6be2                	ld	s7,24(sp)
    80004896:	6c42                	ld	s8,16(sp)
    80004898:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    8000489a:	034a9d63          	bne	s5,s4,800048d4 <filewrite+0x12e>
    8000489e:	8556                	mv	a0,s5
    800048a0:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048a2:	60e6                	ld	ra,88(sp)
    800048a4:	6446                	ld	s0,80(sp)
    800048a6:	6906                	ld	s2,64(sp)
    800048a8:	7aa2                	ld	s5,40(sp)
    800048aa:	7b02                	ld	s6,32(sp)
    800048ac:	6125                	addi	sp,sp,96
    800048ae:	8082                	ret
    800048b0:	e4a6                	sd	s1,72(sp)
    800048b2:	fc4e                	sd	s3,56(sp)
    800048b4:	f852                	sd	s4,48(sp)
    800048b6:	ec5e                	sd	s7,24(sp)
    800048b8:	e862                	sd	s8,16(sp)
    800048ba:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800048bc:	00003517          	auipc	a0,0x3
    800048c0:	d6c50513          	addi	a0,a0,-660 # 80007628 <etext+0x628>
    800048c4:	f61fb0ef          	jal	80000824 <panic>
    return -1;
    800048c8:	557d                	li	a0,-1
}
    800048ca:	8082                	ret
      return -1;
    800048cc:	557d                	li	a0,-1
    800048ce:	bfd1                	j	800048a2 <filewrite+0xfc>
    800048d0:	557d                	li	a0,-1
    800048d2:	bfc1                	j	800048a2 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800048d4:	557d                	li	a0,-1
    800048d6:	7a42                	ld	s4,48(sp)
    800048d8:	b7e9                	j	800048a2 <filewrite+0xfc>

00000000800048da <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048da:	7179                	addi	sp,sp,-48
    800048dc:	f406                	sd	ra,40(sp)
    800048de:	f022                	sd	s0,32(sp)
    800048e0:	ec26                	sd	s1,24(sp)
    800048e2:	e052                	sd	s4,0(sp)
    800048e4:	1800                	addi	s0,sp,48
    800048e6:	84aa                	mv	s1,a0
    800048e8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048ea:	0005b023          	sd	zero,0(a1)
    800048ee:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048f2:	c29ff0ef          	jal	8000451a <filealloc>
    800048f6:	e088                	sd	a0,0(s1)
    800048f8:	c549                	beqz	a0,80004982 <pipealloc+0xa8>
    800048fa:	c21ff0ef          	jal	8000451a <filealloc>
    800048fe:	00aa3023          	sd	a0,0(s4)
    80004902:	cd25                	beqz	a0,8000497a <pipealloc+0xa0>
    80004904:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004906:	a80fc0ef          	jal	80000b86 <kalloc>
    8000490a:	892a                	mv	s2,a0
    8000490c:	c12d                	beqz	a0,8000496e <pipealloc+0x94>
    8000490e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004910:	4985                	li	s3,1
    80004912:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004916:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000491a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000491e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004922:	00003597          	auipc	a1,0x3
    80004926:	d1658593          	addi	a1,a1,-746 # 80007638 <etext+0x638>
    8000492a:	ab6fc0ef          	jal	80000be0 <initlock>
  (*f0)->type = FD_PIPE;
    8000492e:	609c                	ld	a5,0(s1)
    80004930:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004934:	609c                	ld	a5,0(s1)
    80004936:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000493a:	609c                	ld	a5,0(s1)
    8000493c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004940:	609c                	ld	a5,0(s1)
    80004942:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004946:	000a3783          	ld	a5,0(s4)
    8000494a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000494e:	000a3783          	ld	a5,0(s4)
    80004952:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004956:	000a3783          	ld	a5,0(s4)
    8000495a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000495e:	000a3783          	ld	a5,0(s4)
    80004962:	0127b823          	sd	s2,16(a5)
  return 0;
    80004966:	4501                	li	a0,0
    80004968:	6942                	ld	s2,16(sp)
    8000496a:	69a2                	ld	s3,8(sp)
    8000496c:	a01d                	j	80004992 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000496e:	6088                	ld	a0,0(s1)
    80004970:	c119                	beqz	a0,80004976 <pipealloc+0x9c>
    80004972:	6942                	ld	s2,16(sp)
    80004974:	a029                	j	8000497e <pipealloc+0xa4>
    80004976:	6942                	ld	s2,16(sp)
    80004978:	a029                	j	80004982 <pipealloc+0xa8>
    8000497a:	6088                	ld	a0,0(s1)
    8000497c:	c10d                	beqz	a0,8000499e <pipealloc+0xc4>
    fileclose(*f0);
    8000497e:	c41ff0ef          	jal	800045be <fileclose>
  if(*f1)
    80004982:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004986:	557d                	li	a0,-1
  if(*f1)
    80004988:	c789                	beqz	a5,80004992 <pipealloc+0xb8>
    fileclose(*f1);
    8000498a:	853e                	mv	a0,a5
    8000498c:	c33ff0ef          	jal	800045be <fileclose>
  return -1;
    80004990:	557d                	li	a0,-1
}
    80004992:	70a2                	ld	ra,40(sp)
    80004994:	7402                	ld	s0,32(sp)
    80004996:	64e2                	ld	s1,24(sp)
    80004998:	6a02                	ld	s4,0(sp)
    8000499a:	6145                	addi	sp,sp,48
    8000499c:	8082                	ret
  return -1;
    8000499e:	557d                	li	a0,-1
    800049a0:	bfcd                	j	80004992 <pipealloc+0xb8>

00000000800049a2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049a2:	1101                	addi	sp,sp,-32
    800049a4:	ec06                	sd	ra,24(sp)
    800049a6:	e822                	sd	s0,16(sp)
    800049a8:	e426                	sd	s1,8(sp)
    800049aa:	e04a                	sd	s2,0(sp)
    800049ac:	1000                	addi	s0,sp,32
    800049ae:	84aa                	mv	s1,a0
    800049b0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049b2:	ab8fc0ef          	jal	80000c6a <acquire>
  if(writable){
    800049b6:	02090763          	beqz	s2,800049e4 <pipeclose+0x42>
    pi->writeopen = 0;
    800049ba:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049be:	21848513          	addi	a0,s1,536
    800049c2:	ebafd0ef          	jal	8000207c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049c6:	2204a783          	lw	a5,544(s1)
    800049ca:	e781                	bnez	a5,800049d2 <pipeclose+0x30>
    800049cc:	2244a783          	lw	a5,548(s1)
    800049d0:	c38d                	beqz	a5,800049f2 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    800049d2:	8526                	mv	a0,s1
    800049d4:	b2afc0ef          	jal	80000cfe <release>
}
    800049d8:	60e2                	ld	ra,24(sp)
    800049da:	6442                	ld	s0,16(sp)
    800049dc:	64a2                	ld	s1,8(sp)
    800049de:	6902                	ld	s2,0(sp)
    800049e0:	6105                	addi	sp,sp,32
    800049e2:	8082                	ret
    pi->readopen = 0;
    800049e4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049e8:	21c48513          	addi	a0,s1,540
    800049ec:	e90fd0ef          	jal	8000207c <wakeup>
    800049f0:	bfd9                	j	800049c6 <pipeclose+0x24>
    release(&pi->lock);
    800049f2:	8526                	mv	a0,s1
    800049f4:	b0afc0ef          	jal	80000cfe <release>
    kfree((char*)pi);
    800049f8:	8526                	mv	a0,s1
    800049fa:	862fc0ef          	jal	80000a5c <kfree>
    800049fe:	bfe9                	j	800049d8 <pipeclose+0x36>

0000000080004a00 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a00:	7159                	addi	sp,sp,-112
    80004a02:	f486                	sd	ra,104(sp)
    80004a04:	f0a2                	sd	s0,96(sp)
    80004a06:	eca6                	sd	s1,88(sp)
    80004a08:	e8ca                	sd	s2,80(sp)
    80004a0a:	e4ce                	sd	s3,72(sp)
    80004a0c:	e0d2                	sd	s4,64(sp)
    80004a0e:	fc56                	sd	s5,56(sp)
    80004a10:	1880                	addi	s0,sp,112
    80004a12:	84aa                	mv	s1,a0
    80004a14:	8aae                	mv	s5,a1
    80004a16:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a18:	f4dfc0ef          	jal	80001964 <myproc>
    80004a1c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	a4afc0ef          	jal	80000c6a <acquire>
  while(i < n){
    80004a24:	0d405263          	blez	s4,80004ae8 <pipewrite+0xe8>
    80004a28:	f85a                	sd	s6,48(sp)
    80004a2a:	f45e                	sd	s7,40(sp)
    80004a2c:	f062                	sd	s8,32(sp)
    80004a2e:	ec66                	sd	s9,24(sp)
    80004a30:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004a32:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a34:	f9f40c13          	addi	s8,s0,-97
    80004a38:	4b85                	li	s7,1
    80004a3a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a3c:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a40:	21c48c93          	addi	s9,s1,540
    80004a44:	a82d                	j	80004a7e <pipewrite+0x7e>
      release(&pi->lock);
    80004a46:	8526                	mv	a0,s1
    80004a48:	ab6fc0ef          	jal	80000cfe <release>
      return -1;
    80004a4c:	597d                	li	s2,-1
    80004a4e:	7b42                	ld	s6,48(sp)
    80004a50:	7ba2                	ld	s7,40(sp)
    80004a52:	7c02                	ld	s8,32(sp)
    80004a54:	6ce2                	ld	s9,24(sp)
    80004a56:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a58:	854a                	mv	a0,s2
    80004a5a:	70a6                	ld	ra,104(sp)
    80004a5c:	7406                	ld	s0,96(sp)
    80004a5e:	64e6                	ld	s1,88(sp)
    80004a60:	6946                	ld	s2,80(sp)
    80004a62:	69a6                	ld	s3,72(sp)
    80004a64:	6a06                	ld	s4,64(sp)
    80004a66:	7ae2                	ld	s5,56(sp)
    80004a68:	6165                	addi	sp,sp,112
    80004a6a:	8082                	ret
      wakeup(&pi->nread);
    80004a6c:	856a                	mv	a0,s10
    80004a6e:	e0efd0ef          	jal	8000207c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a72:	85a6                	mv	a1,s1
    80004a74:	8566                	mv	a0,s9
    80004a76:	dbafd0ef          	jal	80002030 <sleep>
  while(i < n){
    80004a7a:	05495a63          	bge	s2,s4,80004ace <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004a7e:	2204a783          	lw	a5,544(s1)
    80004a82:	d3f1                	beqz	a5,80004a46 <pipewrite+0x46>
    80004a84:	854e                	mv	a0,s3
    80004a86:	805fd0ef          	jal	8000228a <killed>
    80004a8a:	fd55                	bnez	a0,80004a46 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a8c:	2184a783          	lw	a5,536(s1)
    80004a90:	21c4a703          	lw	a4,540(s1)
    80004a94:	2007879b          	addiw	a5,a5,512
    80004a98:	fcf70ae3          	beq	a4,a5,80004a6c <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a9c:	86de                	mv	a3,s7
    80004a9e:	01590633          	add	a2,s2,s5
    80004aa2:	85e2                	mv	a1,s8
    80004aa4:	0709b503          	ld	a0,112(s3)
    80004aa8:	cadfc0ef          	jal	80001754 <copyin>
    80004aac:	05650063          	beq	a0,s6,80004aec <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ab0:	21c4a783          	lw	a5,540(s1)
    80004ab4:	0017871b          	addiw	a4,a5,1
    80004ab8:	20e4ae23          	sw	a4,540(s1)
    80004abc:	1ff7f793          	andi	a5,a5,511
    80004ac0:	97a6                	add	a5,a5,s1
    80004ac2:	f9f44703          	lbu	a4,-97(s0)
    80004ac6:	00e78c23          	sb	a4,24(a5)
      i++;
    80004aca:	2905                	addiw	s2,s2,1
    80004acc:	b77d                	j	80004a7a <pipewrite+0x7a>
    80004ace:	7b42                	ld	s6,48(sp)
    80004ad0:	7ba2                	ld	s7,40(sp)
    80004ad2:	7c02                	ld	s8,32(sp)
    80004ad4:	6ce2                	ld	s9,24(sp)
    80004ad6:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004ad8:	21848513          	addi	a0,s1,536
    80004adc:	da0fd0ef          	jal	8000207c <wakeup>
  release(&pi->lock);
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	a1cfc0ef          	jal	80000cfe <release>
  return i;
    80004ae6:	bf8d                	j	80004a58 <pipewrite+0x58>
  int i = 0;
    80004ae8:	4901                	li	s2,0
    80004aea:	b7fd                	j	80004ad8 <pipewrite+0xd8>
    80004aec:	7b42                	ld	s6,48(sp)
    80004aee:	7ba2                	ld	s7,40(sp)
    80004af0:	7c02                	ld	s8,32(sp)
    80004af2:	6ce2                	ld	s9,24(sp)
    80004af4:	6d42                	ld	s10,16(sp)
    80004af6:	b7cd                	j	80004ad8 <pipewrite+0xd8>

0000000080004af8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004af8:	711d                	addi	sp,sp,-96
    80004afa:	ec86                	sd	ra,88(sp)
    80004afc:	e8a2                	sd	s0,80(sp)
    80004afe:	e4a6                	sd	s1,72(sp)
    80004b00:	e0ca                	sd	s2,64(sp)
    80004b02:	fc4e                	sd	s3,56(sp)
    80004b04:	f852                	sd	s4,48(sp)
    80004b06:	f456                	sd	s5,40(sp)
    80004b08:	1080                	addi	s0,sp,96
    80004b0a:	84aa                	mv	s1,a0
    80004b0c:	892e                	mv	s2,a1
    80004b0e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b10:	e55fc0ef          	jal	80001964 <myproc>
    80004b14:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b16:	8526                	mv	a0,s1
    80004b18:	952fc0ef          	jal	80000c6a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b1c:	2184a703          	lw	a4,536(s1)
    80004b20:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b24:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b28:	02f71763          	bne	a4,a5,80004b56 <piperead+0x5e>
    80004b2c:	2244a783          	lw	a5,548(s1)
    80004b30:	cf85                	beqz	a5,80004b68 <piperead+0x70>
    if(killed(pr)){
    80004b32:	8552                	mv	a0,s4
    80004b34:	f56fd0ef          	jal	8000228a <killed>
    80004b38:	e11d                	bnez	a0,80004b5e <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b3a:	85a6                	mv	a1,s1
    80004b3c:	854e                	mv	a0,s3
    80004b3e:	cf2fd0ef          	jal	80002030 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b42:	2184a703          	lw	a4,536(s1)
    80004b46:	21c4a783          	lw	a5,540(s1)
    80004b4a:	fef701e3          	beq	a4,a5,80004b2c <piperead+0x34>
    80004b4e:	f05a                	sd	s6,32(sp)
    80004b50:	ec5e                	sd	s7,24(sp)
    80004b52:	e862                	sd	s8,16(sp)
    80004b54:	a829                	j	80004b6e <piperead+0x76>
    80004b56:	f05a                	sd	s6,32(sp)
    80004b58:	ec5e                	sd	s7,24(sp)
    80004b5a:	e862                	sd	s8,16(sp)
    80004b5c:	a809                	j	80004b6e <piperead+0x76>
      release(&pi->lock);
    80004b5e:	8526                	mv	a0,s1
    80004b60:	99efc0ef          	jal	80000cfe <release>
      return -1;
    80004b64:	59fd                	li	s3,-1
    80004b66:	a09d                	j	80004bcc <piperead+0xd4>
    80004b68:	f05a                	sd	s6,32(sp)
    80004b6a:	ec5e                	sd	s7,24(sp)
    80004b6c:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b6e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b70:	faf40c13          	addi	s8,s0,-81
    80004b74:	4b85                	li	s7,1
    80004b76:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b78:	05505063          	blez	s5,80004bb8 <piperead+0xc0>
    if(pi->nread == pi->nwrite)
    80004b7c:	2184a783          	lw	a5,536(s1)
    80004b80:	21c4a703          	lw	a4,540(s1)
    80004b84:	02f70a63          	beq	a4,a5,80004bb8 <piperead+0xc0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b88:	0017871b          	addiw	a4,a5,1
    80004b8c:	20e4ac23          	sw	a4,536(s1)
    80004b90:	1ff7f793          	andi	a5,a5,511
    80004b94:	97a6                	add	a5,a5,s1
    80004b96:	0187c783          	lbu	a5,24(a5)
    80004b9a:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b9e:	86de                	mv	a3,s7
    80004ba0:	8662                	mv	a2,s8
    80004ba2:	85ca                	mv	a1,s2
    80004ba4:	070a3503          	ld	a0,112(s4)
    80004ba8:	aeffc0ef          	jal	80001696 <copyout>
    80004bac:	01650663          	beq	a0,s6,80004bb8 <piperead+0xc0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bb0:	2985                	addiw	s3,s3,1
    80004bb2:	0905                	addi	s2,s2,1
    80004bb4:	fd3a94e3          	bne	s5,s3,80004b7c <piperead+0x84>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bb8:	21c48513          	addi	a0,s1,540
    80004bbc:	cc0fd0ef          	jal	8000207c <wakeup>
  release(&pi->lock);
    80004bc0:	8526                	mv	a0,s1
    80004bc2:	93cfc0ef          	jal	80000cfe <release>
    80004bc6:	7b02                	ld	s6,32(sp)
    80004bc8:	6be2                	ld	s7,24(sp)
    80004bca:	6c42                	ld	s8,16(sp)
  return i;
}
    80004bcc:	854e                	mv	a0,s3
    80004bce:	60e6                	ld	ra,88(sp)
    80004bd0:	6446                	ld	s0,80(sp)
    80004bd2:	64a6                	ld	s1,72(sp)
    80004bd4:	6906                	ld	s2,64(sp)
    80004bd6:	79e2                	ld	s3,56(sp)
    80004bd8:	7a42                	ld	s4,48(sp)
    80004bda:	7aa2                	ld	s5,40(sp)
    80004bdc:	6125                	addi	sp,sp,96
    80004bde:	8082                	ret

0000000080004be0 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004be0:	1141                	addi	sp,sp,-16
    80004be2:	e406                	sd	ra,8(sp)
    80004be4:	e022                	sd	s0,0(sp)
    80004be6:	0800                	addi	s0,sp,16
    80004be8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004bea:	0035151b          	slliw	a0,a0,0x3
    80004bee:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004bf0:	8b89                	andi	a5,a5,2
    80004bf2:	c399                	beqz	a5,80004bf8 <flags2perm+0x18>
      perm |= PTE_W;
    80004bf4:	00456513          	ori	a0,a0,4
    return perm;
}
    80004bf8:	60a2                	ld	ra,8(sp)
    80004bfa:	6402                	ld	s0,0(sp)
    80004bfc:	0141                	addi	sp,sp,16
    80004bfe:	8082                	ret

0000000080004c00 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004c00:	de010113          	addi	sp,sp,-544
    80004c04:	20113c23          	sd	ra,536(sp)
    80004c08:	20813823          	sd	s0,528(sp)
    80004c0c:	20913423          	sd	s1,520(sp)
    80004c10:	21213023          	sd	s2,512(sp)
    80004c14:	1400                	addi	s0,sp,544
    80004c16:	892a                	mv	s2,a0
    80004c18:	dea43823          	sd	a0,-528(s0)
    80004c1c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c20:	d45fc0ef          	jal	80001964 <myproc>
    80004c24:	84aa                	mv	s1,a0

  begin_op();
    80004c26:	d74ff0ef          	jal	8000419a <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004c2a:	854a                	mv	a0,s2
    80004c2c:	b90ff0ef          	jal	80003fbc <namei>
    80004c30:	cd21                	beqz	a0,80004c88 <kexec+0x88>
    80004c32:	fbd2                	sd	s4,496(sp)
    80004c34:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c36:	b59fe0ef          	jal	8000378e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c3a:	04000713          	li	a4,64
    80004c3e:	4681                	li	a3,0
    80004c40:	e5040613          	addi	a2,s0,-432
    80004c44:	4581                	li	a1,0
    80004c46:	8552                	mv	a0,s4
    80004c48:	ed9fe0ef          	jal	80003b20 <readi>
    80004c4c:	04000793          	li	a5,64
    80004c50:	00f51a63          	bne	a0,a5,80004c64 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004c54:	e5042703          	lw	a4,-432(s0)
    80004c58:	464c47b7          	lui	a5,0x464c4
    80004c5c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c60:	02f70863          	beq	a4,a5,80004c90 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c64:	8552                	mv	a0,s4
    80004c66:	d35fe0ef          	jal	8000399a <iunlockput>
    end_op();
    80004c6a:	da0ff0ef          	jal	8000420a <end_op>
  }
  return -1;
    80004c6e:	557d                	li	a0,-1
    80004c70:	7a5e                	ld	s4,496(sp)
}
    80004c72:	21813083          	ld	ra,536(sp)
    80004c76:	21013403          	ld	s0,528(sp)
    80004c7a:	20813483          	ld	s1,520(sp)
    80004c7e:	20013903          	ld	s2,512(sp)
    80004c82:	22010113          	addi	sp,sp,544
    80004c86:	8082                	ret
    end_op();
    80004c88:	d82ff0ef          	jal	8000420a <end_op>
    return -1;
    80004c8c:	557d                	li	a0,-1
    80004c8e:	b7d5                	j	80004c72 <kexec+0x72>
    80004c90:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004c92:	8526                	mv	a0,s1
    80004c94:	dd7fc0ef          	jal	80001a6a <proc_pagetable>
    80004c98:	8b2a                	mv	s6,a0
    80004c9a:	26050f63          	beqz	a0,80004f18 <kexec+0x318>
    80004c9e:	ffce                	sd	s3,504(sp)
    80004ca0:	f7d6                	sd	s5,488(sp)
    80004ca2:	efde                	sd	s7,472(sp)
    80004ca4:	ebe2                	sd	s8,464(sp)
    80004ca6:	e7e6                	sd	s9,456(sp)
    80004ca8:	e3ea                	sd	s10,448(sp)
    80004caa:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cac:	e8845783          	lhu	a5,-376(s0)
    80004cb0:	0e078963          	beqz	a5,80004da2 <kexec+0x1a2>
    80004cb4:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cb8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cba:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004cbc:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004cc0:	6c85                	lui	s9,0x1
    80004cc2:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004cc6:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004cca:	6a85                	lui	s5,0x1
    80004ccc:	a085                	j	80004d2c <kexec+0x12c>
      panic("loadseg: address should exist");
    80004cce:	00003517          	auipc	a0,0x3
    80004cd2:	97250513          	addi	a0,a0,-1678 # 80007640 <etext+0x640>
    80004cd6:	b4ffb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004cda:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cdc:	874a                	mv	a4,s2
    80004cde:	009b86bb          	addw	a3,s7,s1
    80004ce2:	4581                	li	a1,0
    80004ce4:	8552                	mv	a0,s4
    80004ce6:	e3bfe0ef          	jal	80003b20 <readi>
    80004cea:	22a91b63          	bne	s2,a0,80004f20 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004cee:	009a84bb          	addw	s1,s5,s1
    80004cf2:	0334f263          	bgeu	s1,s3,80004d16 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004cf6:	02049593          	slli	a1,s1,0x20
    80004cfa:	9181                	srli	a1,a1,0x20
    80004cfc:	95e2                	add	a1,a1,s8
    80004cfe:	855a                	mv	a0,s6
    80004d00:	b68fc0ef          	jal	80001068 <walkaddr>
    80004d04:	862a                	mv	a2,a0
    if(pa == 0)
    80004d06:	d561                	beqz	a0,80004cce <kexec+0xce>
    if(sz - i < PGSIZE)
    80004d08:	409987bb          	subw	a5,s3,s1
    80004d0c:	893e                	mv	s2,a5
    80004d0e:	fcfcf6e3          	bgeu	s9,a5,80004cda <kexec+0xda>
    80004d12:	8956                	mv	s2,s5
    80004d14:	b7d9                	j	80004cda <kexec+0xda>
    sz = sz1;
    80004d16:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d1a:	2d05                	addiw	s10,s10,1
    80004d1c:	e0843783          	ld	a5,-504(s0)
    80004d20:	0387869b          	addiw	a3,a5,56
    80004d24:	e8845783          	lhu	a5,-376(s0)
    80004d28:	06fd5e63          	bge	s10,a5,80004da4 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d2c:	e0d43423          	sd	a3,-504(s0)
    80004d30:	876e                	mv	a4,s11
    80004d32:	e1840613          	addi	a2,s0,-488
    80004d36:	4581                	li	a1,0
    80004d38:	8552                	mv	a0,s4
    80004d3a:	de7fe0ef          	jal	80003b20 <readi>
    80004d3e:	1db51f63          	bne	a0,s11,80004f1c <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004d42:	e1842783          	lw	a5,-488(s0)
    80004d46:	4705                	li	a4,1
    80004d48:	fce799e3          	bne	a5,a4,80004d1a <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004d4c:	e4043483          	ld	s1,-448(s0)
    80004d50:	e3843783          	ld	a5,-456(s0)
    80004d54:	1ef4e463          	bltu	s1,a5,80004f3c <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004d58:	e2843783          	ld	a5,-472(s0)
    80004d5c:	94be                	add	s1,s1,a5
    80004d5e:	1ef4e263          	bltu	s1,a5,80004f42 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004d62:	de843703          	ld	a4,-536(s0)
    80004d66:	8ff9                	and	a5,a5,a4
    80004d68:	1e079063          	bnez	a5,80004f48 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d6c:	e1c42503          	lw	a0,-484(s0)
    80004d70:	e71ff0ef          	jal	80004be0 <flags2perm>
    80004d74:	86aa                	mv	a3,a0
    80004d76:	8626                	mv	a2,s1
    80004d78:	85ca                	mv	a1,s2
    80004d7a:	855a                	mv	a0,s6
    80004d7c:	dc2fc0ef          	jal	8000133e <uvmalloc>
    80004d80:	dea43c23          	sd	a0,-520(s0)
    80004d84:	1c050563          	beqz	a0,80004f4e <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d88:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d8c:	00098863          	beqz	s3,80004d9c <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d90:	e2843c03          	ld	s8,-472(s0)
    80004d94:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d98:	4481                	li	s1,0
    80004d9a:	bfb1                	j	80004cf6 <kexec+0xf6>
    sz = sz1;
    80004d9c:	df843903          	ld	s2,-520(s0)
    80004da0:	bfad                	j	80004d1a <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004da2:	4901                	li	s2,0
  iunlockput(ip);
    80004da4:	8552                	mv	a0,s4
    80004da6:	bf5fe0ef          	jal	8000399a <iunlockput>
  end_op();
    80004daa:	c60ff0ef          	jal	8000420a <end_op>
  p = myproc();
    80004dae:	bb7fc0ef          	jal	80001964 <myproc>
    80004db2:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004db4:	06853d03          	ld	s10,104(a0)
  sz = PGROUNDUP(sz);
    80004db8:	6985                	lui	s3,0x1
    80004dba:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004dbc:	99ca                	add	s3,s3,s2
    80004dbe:	77fd                	lui	a5,0xfffff
    80004dc0:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004dc4:	4691                	li	a3,4
    80004dc6:	6609                	lui	a2,0x2
    80004dc8:	964e                	add	a2,a2,s3
    80004dca:	85ce                	mv	a1,s3
    80004dcc:	855a                	mv	a0,s6
    80004dce:	d70fc0ef          	jal	8000133e <uvmalloc>
    80004dd2:	8a2a                	mv	s4,a0
    80004dd4:	e105                	bnez	a0,80004df4 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004dd6:	85ce                	mv	a1,s3
    80004dd8:	855a                	mv	a0,s6
    80004dda:	de5fc0ef          	jal	80001bbe <proc_freepagetable>
  return -1;
    80004dde:	557d                	li	a0,-1
    80004de0:	79fe                	ld	s3,504(sp)
    80004de2:	7a5e                	ld	s4,496(sp)
    80004de4:	7abe                	ld	s5,488(sp)
    80004de6:	7b1e                	ld	s6,480(sp)
    80004de8:	6bfe                	ld	s7,472(sp)
    80004dea:	6c5e                	ld	s8,464(sp)
    80004dec:	6cbe                	ld	s9,456(sp)
    80004dee:	6d1e                	ld	s10,448(sp)
    80004df0:	7dfa                	ld	s11,440(sp)
    80004df2:	b541                	j	80004c72 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004df4:	75f9                	lui	a1,0xffffe
    80004df6:	95aa                	add	a1,a1,a0
    80004df8:	855a                	mv	a0,s6
    80004dfa:	f16fc0ef          	jal	80001510 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004dfe:	800a0b93          	addi	s7,s4,-2048
    80004e02:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004e06:	e0043783          	ld	a5,-512(s0)
    80004e0a:	6388                	ld	a0,0(a5)
  sp = sz;
    80004e0c:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004e0e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004e10:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004e14:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004e18:	cd21                	beqz	a0,80004e70 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004e1a:	8aafc0ef          	jal	80000ec4 <strlen>
    80004e1e:	0015079b          	addiw	a5,a0,1
    80004e22:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e26:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004e2a:	13796563          	bltu	s2,s7,80004f54 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e2e:	e0043d83          	ld	s11,-512(s0)
    80004e32:	000db983          	ld	s3,0(s11)
    80004e36:	854e                	mv	a0,s3
    80004e38:	88cfc0ef          	jal	80000ec4 <strlen>
    80004e3c:	0015069b          	addiw	a3,a0,1
    80004e40:	864e                	mv	a2,s3
    80004e42:	85ca                	mv	a1,s2
    80004e44:	855a                	mv	a0,s6
    80004e46:	851fc0ef          	jal	80001696 <copyout>
    80004e4a:	10054763          	bltz	a0,80004f58 <kexec+0x358>
    ustack[argc] = sp;
    80004e4e:	00349793          	slli	a5,s1,0x3
    80004e52:	97e6                	add	a5,a5,s9
    80004e54:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffddaf8>
  for(argc = 0; argv[argc]; argc++) {
    80004e58:	0485                	addi	s1,s1,1
    80004e5a:	008d8793          	addi	a5,s11,8
    80004e5e:	e0f43023          	sd	a5,-512(s0)
    80004e62:	008db503          	ld	a0,8(s11)
    80004e66:	c509                	beqz	a0,80004e70 <kexec+0x270>
    if(argc >= MAXARG)
    80004e68:	fb8499e3          	bne	s1,s8,80004e1a <kexec+0x21a>
  sz = sz1;
    80004e6c:	89d2                	mv	s3,s4
    80004e6e:	b7a5                	j	80004dd6 <kexec+0x1d6>
  ustack[argc] = 0;
    80004e70:	00349793          	slli	a5,s1,0x3
    80004e74:	f9078793          	addi	a5,a5,-112
    80004e78:	97a2                	add	a5,a5,s0
    80004e7a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e7e:	00349693          	slli	a3,s1,0x3
    80004e82:	06a1                	addi	a3,a3,8
    80004e84:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e88:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004e8c:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004e8e:	f57964e3          	bltu	s2,s7,80004dd6 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e92:	e9040613          	addi	a2,s0,-368
    80004e96:	85ca                	mv	a1,s2
    80004e98:	855a                	mv	a0,s6
    80004e9a:	ffcfc0ef          	jal	80001696 <copyout>
    80004e9e:	f2054ce3          	bltz	a0,80004dd6 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004ea2:	078ab783          	ld	a5,120(s5) # 1078 <_entry-0x7fffef88>
    80004ea6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004eaa:	df043783          	ld	a5,-528(s0)
    80004eae:	0007c703          	lbu	a4,0(a5)
    80004eb2:	cf11                	beqz	a4,80004ece <kexec+0x2ce>
    80004eb4:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004eb6:	02f00693          	li	a3,47
    80004eba:	a029                	j	80004ec4 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004ebc:	0785                	addi	a5,a5,1
    80004ebe:	fff7c703          	lbu	a4,-1(a5)
    80004ec2:	c711                	beqz	a4,80004ece <kexec+0x2ce>
    if(*s == '/')
    80004ec4:	fed71ce3          	bne	a4,a3,80004ebc <kexec+0x2bc>
      last = s+1;
    80004ec8:	def43823          	sd	a5,-528(s0)
    80004ecc:	bfc5                	j	80004ebc <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ece:	4641                	li	a2,16
    80004ed0:	df043583          	ld	a1,-528(s0)
    80004ed4:	178a8513          	addi	a0,s5,376
    80004ed8:	fb7fb0ef          	jal	80000e8e <safestrcpy>
  oldpagetable = p->pagetable;
    80004edc:	070ab503          	ld	a0,112(s5)
  p->pagetable = pagetable;
    80004ee0:	076ab823          	sd	s6,112(s5)
  p->sz = sz;
    80004ee4:	074ab423          	sd	s4,104(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ee8:	078ab783          	ld	a5,120(s5)
    80004eec:	e6843703          	ld	a4,-408(s0)
    80004ef0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ef2:	078ab783          	ld	a5,120(s5)
    80004ef6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004efa:	85ea                	mv	a1,s10
    80004efc:	cc3fc0ef          	jal	80001bbe <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f00:	0004851b          	sext.w	a0,s1
    80004f04:	79fe                	ld	s3,504(sp)
    80004f06:	7a5e                	ld	s4,496(sp)
    80004f08:	7abe                	ld	s5,488(sp)
    80004f0a:	7b1e                	ld	s6,480(sp)
    80004f0c:	6bfe                	ld	s7,472(sp)
    80004f0e:	6c5e                	ld	s8,464(sp)
    80004f10:	6cbe                	ld	s9,456(sp)
    80004f12:	6d1e                	ld	s10,448(sp)
    80004f14:	7dfa                	ld	s11,440(sp)
    80004f16:	bbb1                	j	80004c72 <kexec+0x72>
    80004f18:	7b1e                	ld	s6,480(sp)
    80004f1a:	b3a9                	j	80004c64 <kexec+0x64>
    80004f1c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004f20:	df843583          	ld	a1,-520(s0)
    80004f24:	855a                	mv	a0,s6
    80004f26:	c99fc0ef          	jal	80001bbe <proc_freepagetable>
  if(ip){
    80004f2a:	79fe                	ld	s3,504(sp)
    80004f2c:	7abe                	ld	s5,488(sp)
    80004f2e:	7b1e                	ld	s6,480(sp)
    80004f30:	6bfe                	ld	s7,472(sp)
    80004f32:	6c5e                	ld	s8,464(sp)
    80004f34:	6cbe                	ld	s9,456(sp)
    80004f36:	6d1e                	ld	s10,448(sp)
    80004f38:	7dfa                	ld	s11,440(sp)
    80004f3a:	b32d                	j	80004c64 <kexec+0x64>
    80004f3c:	df243c23          	sd	s2,-520(s0)
    80004f40:	b7c5                	j	80004f20 <kexec+0x320>
    80004f42:	df243c23          	sd	s2,-520(s0)
    80004f46:	bfe9                	j	80004f20 <kexec+0x320>
    80004f48:	df243c23          	sd	s2,-520(s0)
    80004f4c:	bfd1                	j	80004f20 <kexec+0x320>
    80004f4e:	df243c23          	sd	s2,-520(s0)
    80004f52:	b7f9                	j	80004f20 <kexec+0x320>
  sz = sz1;
    80004f54:	89d2                	mv	s3,s4
    80004f56:	b541                	j	80004dd6 <kexec+0x1d6>
    80004f58:	89d2                	mv	s3,s4
    80004f5a:	bdb5                	j	80004dd6 <kexec+0x1d6>

0000000080004f5c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f5c:	7179                	addi	sp,sp,-48
    80004f5e:	f406                	sd	ra,40(sp)
    80004f60:	f022                	sd	s0,32(sp)
    80004f62:	ec26                	sd	s1,24(sp)
    80004f64:	e84a                	sd	s2,16(sp)
    80004f66:	1800                	addi	s0,sp,48
    80004f68:	892e                	mv	s2,a1
    80004f6a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f6c:	fdc40593          	addi	a1,s0,-36
    80004f70:	db5fd0ef          	jal	80002d24 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f74:	fdc42703          	lw	a4,-36(s0)
    80004f78:	47bd                	li	a5,15
    80004f7a:	02e7ea63          	bltu	a5,a4,80004fae <argfd+0x52>
    80004f7e:	9e7fc0ef          	jal	80001964 <myproc>
    80004f82:	fdc42703          	lw	a4,-36(s0)
    80004f86:	00371793          	slli	a5,a4,0x3
    80004f8a:	0f078793          	addi	a5,a5,240
    80004f8e:	953e                	add	a0,a0,a5
    80004f90:	611c                	ld	a5,0(a0)
    80004f92:	c385                	beqz	a5,80004fb2 <argfd+0x56>
    return -1;
  if(pfd)
    80004f94:	00090463          	beqz	s2,80004f9c <argfd+0x40>
    *pfd = fd;
    80004f98:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f9c:	4501                	li	a0,0
  if(pf)
    80004f9e:	c091                	beqz	s1,80004fa2 <argfd+0x46>
    *pf = f;
    80004fa0:	e09c                	sd	a5,0(s1)
}
    80004fa2:	70a2                	ld	ra,40(sp)
    80004fa4:	7402                	ld	s0,32(sp)
    80004fa6:	64e2                	ld	s1,24(sp)
    80004fa8:	6942                	ld	s2,16(sp)
    80004faa:	6145                	addi	sp,sp,48
    80004fac:	8082                	ret
    return -1;
    80004fae:	557d                	li	a0,-1
    80004fb0:	bfcd                	j	80004fa2 <argfd+0x46>
    80004fb2:	557d                	li	a0,-1
    80004fb4:	b7fd                	j	80004fa2 <argfd+0x46>

0000000080004fb6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fb6:	1101                	addi	sp,sp,-32
    80004fb8:	ec06                	sd	ra,24(sp)
    80004fba:	e822                	sd	s0,16(sp)
    80004fbc:	e426                	sd	s1,8(sp)
    80004fbe:	1000                	addi	s0,sp,32
    80004fc0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fc2:	9a3fc0ef          	jal	80001964 <myproc>
    80004fc6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fc8:	0f050793          	addi	a5,a0,240
    80004fcc:	4501                	li	a0,0
    80004fce:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004fd0:	6398                	ld	a4,0(a5)
    80004fd2:	cb19                	beqz	a4,80004fe8 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004fd4:	2505                	addiw	a0,a0,1
    80004fd6:	07a1                	addi	a5,a5,8
    80004fd8:	fed51ce3          	bne	a0,a3,80004fd0 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004fdc:	557d                	li	a0,-1
}
    80004fde:	60e2                	ld	ra,24(sp)
    80004fe0:	6442                	ld	s0,16(sp)
    80004fe2:	64a2                	ld	s1,8(sp)
    80004fe4:	6105                	addi	sp,sp,32
    80004fe6:	8082                	ret
      p->ofile[fd] = f;
    80004fe8:	00351793          	slli	a5,a0,0x3
    80004fec:	0f078793          	addi	a5,a5,240
    80004ff0:	963e                	add	a2,a2,a5
    80004ff2:	e204                	sd	s1,0(a2)
      return fd;
    80004ff4:	b7ed                	j	80004fde <fdalloc+0x28>

0000000080004ff6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004ff6:	715d                	addi	sp,sp,-80
    80004ff8:	e486                	sd	ra,72(sp)
    80004ffa:	e0a2                	sd	s0,64(sp)
    80004ffc:	fc26                	sd	s1,56(sp)
    80004ffe:	f84a                	sd	s2,48(sp)
    80005000:	f44e                	sd	s3,40(sp)
    80005002:	f052                	sd	s4,32(sp)
    80005004:	ec56                	sd	s5,24(sp)
    80005006:	e85a                	sd	s6,16(sp)
    80005008:	0880                	addi	s0,sp,80
    8000500a:	892e                	mv	s2,a1
    8000500c:	8a2e                	mv	s4,a1
    8000500e:	8ab2                	mv	s5,a2
    80005010:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005012:	fb040593          	addi	a1,s0,-80
    80005016:	fc1fe0ef          	jal	80003fd6 <nameiparent>
    8000501a:	84aa                	mv	s1,a0
    8000501c:	10050763          	beqz	a0,8000512a <create+0x134>
    return 0;

  ilock(dp);
    80005020:	f6efe0ef          	jal	8000378e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005024:	4601                	li	a2,0
    80005026:	fb040593          	addi	a1,s0,-80
    8000502a:	8526                	mv	a0,s1
    8000502c:	cfdfe0ef          	jal	80003d28 <dirlookup>
    80005030:	89aa                	mv	s3,a0
    80005032:	c131                	beqz	a0,80005076 <create+0x80>
    iunlockput(dp);
    80005034:	8526                	mv	a0,s1
    80005036:	965fe0ef          	jal	8000399a <iunlockput>
    ilock(ip);
    8000503a:	854e                	mv	a0,s3
    8000503c:	f52fe0ef          	jal	8000378e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005040:	4789                	li	a5,2
    80005042:	02f91563          	bne	s2,a5,8000506c <create+0x76>
    80005046:	0449d783          	lhu	a5,68(s3)
    8000504a:	37f9                	addiw	a5,a5,-2
    8000504c:	17c2                	slli	a5,a5,0x30
    8000504e:	93c1                	srli	a5,a5,0x30
    80005050:	4705                	li	a4,1
    80005052:	00f76d63          	bltu	a4,a5,8000506c <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005056:	854e                	mv	a0,s3
    80005058:	60a6                	ld	ra,72(sp)
    8000505a:	6406                	ld	s0,64(sp)
    8000505c:	74e2                	ld	s1,56(sp)
    8000505e:	7942                	ld	s2,48(sp)
    80005060:	79a2                	ld	s3,40(sp)
    80005062:	7a02                	ld	s4,32(sp)
    80005064:	6ae2                	ld	s5,24(sp)
    80005066:	6b42                	ld	s6,16(sp)
    80005068:	6161                	addi	sp,sp,80
    8000506a:	8082                	ret
    iunlockput(ip);
    8000506c:	854e                	mv	a0,s3
    8000506e:	92dfe0ef          	jal	8000399a <iunlockput>
    return 0;
    80005072:	4981                	li	s3,0
    80005074:	b7cd                	j	80005056 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005076:	85ca                	mv	a1,s2
    80005078:	4088                	lw	a0,0(s1)
    8000507a:	da4fe0ef          	jal	8000361e <ialloc>
    8000507e:	892a                	mv	s2,a0
    80005080:	cd15                	beqz	a0,800050bc <create+0xc6>
  ilock(ip);
    80005082:	f0cfe0ef          	jal	8000378e <ilock>
  ip->major = major;
    80005086:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    8000508a:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    8000508e:	4785                	li	a5,1
    80005090:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005094:	854a                	mv	a0,s2
    80005096:	e44fe0ef          	jal	800036da <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000509a:	4705                	li	a4,1
    8000509c:	02ea0463          	beq	s4,a4,800050c4 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800050a0:	00492603          	lw	a2,4(s2)
    800050a4:	fb040593          	addi	a1,s0,-80
    800050a8:	8526                	mv	a0,s1
    800050aa:	e69fe0ef          	jal	80003f12 <dirlink>
    800050ae:	06054263          	bltz	a0,80005112 <create+0x11c>
  iunlockput(dp);
    800050b2:	8526                	mv	a0,s1
    800050b4:	8e7fe0ef          	jal	8000399a <iunlockput>
  return ip;
    800050b8:	89ca                	mv	s3,s2
    800050ba:	bf71                	j	80005056 <create+0x60>
    iunlockput(dp);
    800050bc:	8526                	mv	a0,s1
    800050be:	8ddfe0ef          	jal	8000399a <iunlockput>
    return 0;
    800050c2:	bf51                	j	80005056 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050c4:	00492603          	lw	a2,4(s2)
    800050c8:	00002597          	auipc	a1,0x2
    800050cc:	59858593          	addi	a1,a1,1432 # 80007660 <etext+0x660>
    800050d0:	854a                	mv	a0,s2
    800050d2:	e41fe0ef          	jal	80003f12 <dirlink>
    800050d6:	02054e63          	bltz	a0,80005112 <create+0x11c>
    800050da:	40d0                	lw	a2,4(s1)
    800050dc:	00002597          	auipc	a1,0x2
    800050e0:	58c58593          	addi	a1,a1,1420 # 80007668 <etext+0x668>
    800050e4:	854a                	mv	a0,s2
    800050e6:	e2dfe0ef          	jal	80003f12 <dirlink>
    800050ea:	02054463          	bltz	a0,80005112 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800050ee:	00492603          	lw	a2,4(s2)
    800050f2:	fb040593          	addi	a1,s0,-80
    800050f6:	8526                	mv	a0,s1
    800050f8:	e1bfe0ef          	jal	80003f12 <dirlink>
    800050fc:	00054b63          	bltz	a0,80005112 <create+0x11c>
    dp->nlink++;  // for ".."
    80005100:	04a4d783          	lhu	a5,74(s1)
    80005104:	2785                	addiw	a5,a5,1
    80005106:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000510a:	8526                	mv	a0,s1
    8000510c:	dcefe0ef          	jal	800036da <iupdate>
    80005110:	b74d                	j	800050b2 <create+0xbc>
  ip->nlink = 0;
    80005112:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80005116:	854a                	mv	a0,s2
    80005118:	dc2fe0ef          	jal	800036da <iupdate>
  iunlockput(ip);
    8000511c:	854a                	mv	a0,s2
    8000511e:	87dfe0ef          	jal	8000399a <iunlockput>
  iunlockput(dp);
    80005122:	8526                	mv	a0,s1
    80005124:	877fe0ef          	jal	8000399a <iunlockput>
  return 0;
    80005128:	b73d                	j	80005056 <create+0x60>
    return 0;
    8000512a:	89aa                	mv	s3,a0
    8000512c:	b72d                	j	80005056 <create+0x60>

000000008000512e <sys_dup>:
{
    8000512e:	7179                	addi	sp,sp,-48
    80005130:	f406                	sd	ra,40(sp)
    80005132:	f022                	sd	s0,32(sp)
    80005134:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005136:	fd840613          	addi	a2,s0,-40
    8000513a:	4581                	li	a1,0
    8000513c:	4501                	li	a0,0
    8000513e:	e1fff0ef          	jal	80004f5c <argfd>
    return -1;
    80005142:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005144:	02054363          	bltz	a0,8000516a <sys_dup+0x3c>
    80005148:	ec26                	sd	s1,24(sp)
    8000514a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000514c:	fd843483          	ld	s1,-40(s0)
    80005150:	8526                	mv	a0,s1
    80005152:	e65ff0ef          	jal	80004fb6 <fdalloc>
    80005156:	892a                	mv	s2,a0
    return -1;
    80005158:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000515a:	00054d63          	bltz	a0,80005174 <sys_dup+0x46>
  filedup(f);
    8000515e:	8526                	mv	a0,s1
    80005160:	c18ff0ef          	jal	80004578 <filedup>
  return fd;
    80005164:	87ca                	mv	a5,s2
    80005166:	64e2                	ld	s1,24(sp)
    80005168:	6942                	ld	s2,16(sp)
}
    8000516a:	853e                	mv	a0,a5
    8000516c:	70a2                	ld	ra,40(sp)
    8000516e:	7402                	ld	s0,32(sp)
    80005170:	6145                	addi	sp,sp,48
    80005172:	8082                	ret
    80005174:	64e2                	ld	s1,24(sp)
    80005176:	6942                	ld	s2,16(sp)
    80005178:	bfcd                	j	8000516a <sys_dup+0x3c>

000000008000517a <sys_read>:
{
    8000517a:	7179                	addi	sp,sp,-48
    8000517c:	f406                	sd	ra,40(sp)
    8000517e:	f022                	sd	s0,32(sp)
    80005180:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005182:	fd840593          	addi	a1,s0,-40
    80005186:	4505                	li	a0,1
    80005188:	bb9fd0ef          	jal	80002d40 <argaddr>
  argint(2, &n);
    8000518c:	fe440593          	addi	a1,s0,-28
    80005190:	4509                	li	a0,2
    80005192:	b93fd0ef          	jal	80002d24 <argint>
  if(argfd(0, 0, &f) < 0)
    80005196:	fe840613          	addi	a2,s0,-24
    8000519a:	4581                	li	a1,0
    8000519c:	4501                	li	a0,0
    8000519e:	dbfff0ef          	jal	80004f5c <argfd>
    800051a2:	87aa                	mv	a5,a0
    return -1;
    800051a4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051a6:	0007ca63          	bltz	a5,800051ba <sys_read+0x40>
  return fileread(f, p, n);
    800051aa:	fe442603          	lw	a2,-28(s0)
    800051ae:	fd843583          	ld	a1,-40(s0)
    800051b2:	fe843503          	ld	a0,-24(s0)
    800051b6:	d2cff0ef          	jal	800046e2 <fileread>
}
    800051ba:	70a2                	ld	ra,40(sp)
    800051bc:	7402                	ld	s0,32(sp)
    800051be:	6145                	addi	sp,sp,48
    800051c0:	8082                	ret

00000000800051c2 <sys_write>:
{
    800051c2:	7179                	addi	sp,sp,-48
    800051c4:	f406                	sd	ra,40(sp)
    800051c6:	f022                	sd	s0,32(sp)
    800051c8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051ca:	fd840593          	addi	a1,s0,-40
    800051ce:	4505                	li	a0,1
    800051d0:	b71fd0ef          	jal	80002d40 <argaddr>
  argint(2, &n);
    800051d4:	fe440593          	addi	a1,s0,-28
    800051d8:	4509                	li	a0,2
    800051da:	b4bfd0ef          	jal	80002d24 <argint>
  if(argfd(0, 0, &f) < 0)
    800051de:	fe840613          	addi	a2,s0,-24
    800051e2:	4581                	li	a1,0
    800051e4:	4501                	li	a0,0
    800051e6:	d77ff0ef          	jal	80004f5c <argfd>
    800051ea:	87aa                	mv	a5,a0
    return -1;
    800051ec:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051ee:	0007ca63          	bltz	a5,80005202 <sys_write+0x40>
  return filewrite(f, p, n);
    800051f2:	fe442603          	lw	a2,-28(s0)
    800051f6:	fd843583          	ld	a1,-40(s0)
    800051fa:	fe843503          	ld	a0,-24(s0)
    800051fe:	da8ff0ef          	jal	800047a6 <filewrite>
}
    80005202:	70a2                	ld	ra,40(sp)
    80005204:	7402                	ld	s0,32(sp)
    80005206:	6145                	addi	sp,sp,48
    80005208:	8082                	ret

000000008000520a <sys_close>:
{
    8000520a:	1101                	addi	sp,sp,-32
    8000520c:	ec06                	sd	ra,24(sp)
    8000520e:	e822                	sd	s0,16(sp)
    80005210:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005212:	fe040613          	addi	a2,s0,-32
    80005216:	fec40593          	addi	a1,s0,-20
    8000521a:	4501                	li	a0,0
    8000521c:	d41ff0ef          	jal	80004f5c <argfd>
    return -1;
    80005220:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005222:	02054163          	bltz	a0,80005244 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005226:	f3efc0ef          	jal	80001964 <myproc>
    8000522a:	fec42783          	lw	a5,-20(s0)
    8000522e:	078e                	slli	a5,a5,0x3
    80005230:	0f078793          	addi	a5,a5,240
    80005234:	953e                	add	a0,a0,a5
    80005236:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000523a:	fe043503          	ld	a0,-32(s0)
    8000523e:	b80ff0ef          	jal	800045be <fileclose>
  return 0;
    80005242:	4781                	li	a5,0
}
    80005244:	853e                	mv	a0,a5
    80005246:	60e2                	ld	ra,24(sp)
    80005248:	6442                	ld	s0,16(sp)
    8000524a:	6105                	addi	sp,sp,32
    8000524c:	8082                	ret

000000008000524e <sys_fstat>:
{
    8000524e:	1101                	addi	sp,sp,-32
    80005250:	ec06                	sd	ra,24(sp)
    80005252:	e822                	sd	s0,16(sp)
    80005254:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005256:	fe040593          	addi	a1,s0,-32
    8000525a:	4505                	li	a0,1
    8000525c:	ae5fd0ef          	jal	80002d40 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005260:	fe840613          	addi	a2,s0,-24
    80005264:	4581                	li	a1,0
    80005266:	4501                	li	a0,0
    80005268:	cf5ff0ef          	jal	80004f5c <argfd>
    8000526c:	87aa                	mv	a5,a0
    return -1;
    8000526e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005270:	0007c863          	bltz	a5,80005280 <sys_fstat+0x32>
  return filestat(f, st);
    80005274:	fe043583          	ld	a1,-32(s0)
    80005278:	fe843503          	ld	a0,-24(s0)
    8000527c:	c04ff0ef          	jal	80004680 <filestat>
}
    80005280:	60e2                	ld	ra,24(sp)
    80005282:	6442                	ld	s0,16(sp)
    80005284:	6105                	addi	sp,sp,32
    80005286:	8082                	ret

0000000080005288 <sys_link>:
{
    80005288:	7169                	addi	sp,sp,-304
    8000528a:	f606                	sd	ra,296(sp)
    8000528c:	f222                	sd	s0,288(sp)
    8000528e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005290:	08000613          	li	a2,128
    80005294:	ed040593          	addi	a1,s0,-304
    80005298:	4501                	li	a0,0
    8000529a:	ac3fd0ef          	jal	80002d5c <argstr>
    return -1;
    8000529e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052a0:	0c054e63          	bltz	a0,8000537c <sys_link+0xf4>
    800052a4:	08000613          	li	a2,128
    800052a8:	f5040593          	addi	a1,s0,-176
    800052ac:	4505                	li	a0,1
    800052ae:	aaffd0ef          	jal	80002d5c <argstr>
    return -1;
    800052b2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052b4:	0c054463          	bltz	a0,8000537c <sys_link+0xf4>
    800052b8:	ee26                	sd	s1,280(sp)
  begin_op();
    800052ba:	ee1fe0ef          	jal	8000419a <begin_op>
  if((ip = namei(old)) == 0){
    800052be:	ed040513          	addi	a0,s0,-304
    800052c2:	cfbfe0ef          	jal	80003fbc <namei>
    800052c6:	84aa                	mv	s1,a0
    800052c8:	c53d                	beqz	a0,80005336 <sys_link+0xae>
  ilock(ip);
    800052ca:	cc4fe0ef          	jal	8000378e <ilock>
  if(ip->type == T_DIR){
    800052ce:	04449703          	lh	a4,68(s1)
    800052d2:	4785                	li	a5,1
    800052d4:	06f70663          	beq	a4,a5,80005340 <sys_link+0xb8>
    800052d8:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800052da:	04a4d783          	lhu	a5,74(s1)
    800052de:	2785                	addiw	a5,a5,1
    800052e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052e4:	8526                	mv	a0,s1
    800052e6:	bf4fe0ef          	jal	800036da <iupdate>
  iunlock(ip);
    800052ea:	8526                	mv	a0,s1
    800052ec:	d50fe0ef          	jal	8000383c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800052f0:	fd040593          	addi	a1,s0,-48
    800052f4:	f5040513          	addi	a0,s0,-176
    800052f8:	cdffe0ef          	jal	80003fd6 <nameiparent>
    800052fc:	892a                	mv	s2,a0
    800052fe:	cd21                	beqz	a0,80005356 <sys_link+0xce>
  ilock(dp);
    80005300:	c8efe0ef          	jal	8000378e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005304:	854a                	mv	a0,s2
    80005306:	00092703          	lw	a4,0(s2)
    8000530a:	409c                	lw	a5,0(s1)
    8000530c:	04f71263          	bne	a4,a5,80005350 <sys_link+0xc8>
    80005310:	40d0                	lw	a2,4(s1)
    80005312:	fd040593          	addi	a1,s0,-48
    80005316:	bfdfe0ef          	jal	80003f12 <dirlink>
    8000531a:	02054b63          	bltz	a0,80005350 <sys_link+0xc8>
  iunlockput(dp);
    8000531e:	854a                	mv	a0,s2
    80005320:	e7afe0ef          	jal	8000399a <iunlockput>
  iput(ip);
    80005324:	8526                	mv	a0,s1
    80005326:	deafe0ef          	jal	80003910 <iput>
  end_op();
    8000532a:	ee1fe0ef          	jal	8000420a <end_op>
  return 0;
    8000532e:	4781                	li	a5,0
    80005330:	64f2                	ld	s1,280(sp)
    80005332:	6952                	ld	s2,272(sp)
    80005334:	a0a1                	j	8000537c <sys_link+0xf4>
    end_op();
    80005336:	ed5fe0ef          	jal	8000420a <end_op>
    return -1;
    8000533a:	57fd                	li	a5,-1
    8000533c:	64f2                	ld	s1,280(sp)
    8000533e:	a83d                	j	8000537c <sys_link+0xf4>
    iunlockput(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	e58fe0ef          	jal	8000399a <iunlockput>
    end_op();
    80005346:	ec5fe0ef          	jal	8000420a <end_op>
    return -1;
    8000534a:	57fd                	li	a5,-1
    8000534c:	64f2                	ld	s1,280(sp)
    8000534e:	a03d                	j	8000537c <sys_link+0xf4>
    iunlockput(dp);
    80005350:	854a                	mv	a0,s2
    80005352:	e48fe0ef          	jal	8000399a <iunlockput>
  ilock(ip);
    80005356:	8526                	mv	a0,s1
    80005358:	c36fe0ef          	jal	8000378e <ilock>
  ip->nlink--;
    8000535c:	04a4d783          	lhu	a5,74(s1)
    80005360:	37fd                	addiw	a5,a5,-1
    80005362:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005366:	8526                	mv	a0,s1
    80005368:	b72fe0ef          	jal	800036da <iupdate>
  iunlockput(ip);
    8000536c:	8526                	mv	a0,s1
    8000536e:	e2cfe0ef          	jal	8000399a <iunlockput>
  end_op();
    80005372:	e99fe0ef          	jal	8000420a <end_op>
  return -1;
    80005376:	57fd                	li	a5,-1
    80005378:	64f2                	ld	s1,280(sp)
    8000537a:	6952                	ld	s2,272(sp)
}
    8000537c:	853e                	mv	a0,a5
    8000537e:	70b2                	ld	ra,296(sp)
    80005380:	7412                	ld	s0,288(sp)
    80005382:	6155                	addi	sp,sp,304
    80005384:	8082                	ret

0000000080005386 <sys_unlink>:
{
    80005386:	7151                	addi	sp,sp,-240
    80005388:	f586                	sd	ra,232(sp)
    8000538a:	f1a2                	sd	s0,224(sp)
    8000538c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000538e:	08000613          	li	a2,128
    80005392:	f3040593          	addi	a1,s0,-208
    80005396:	4501                	li	a0,0
    80005398:	9c5fd0ef          	jal	80002d5c <argstr>
    8000539c:	14054d63          	bltz	a0,800054f6 <sys_unlink+0x170>
    800053a0:	eda6                	sd	s1,216(sp)
  begin_op();
    800053a2:	df9fe0ef          	jal	8000419a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053a6:	fb040593          	addi	a1,s0,-80
    800053aa:	f3040513          	addi	a0,s0,-208
    800053ae:	c29fe0ef          	jal	80003fd6 <nameiparent>
    800053b2:	84aa                	mv	s1,a0
    800053b4:	c955                	beqz	a0,80005468 <sys_unlink+0xe2>
  ilock(dp);
    800053b6:	bd8fe0ef          	jal	8000378e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800053ba:	00002597          	auipc	a1,0x2
    800053be:	2a658593          	addi	a1,a1,678 # 80007660 <etext+0x660>
    800053c2:	fb040513          	addi	a0,s0,-80
    800053c6:	94dfe0ef          	jal	80003d12 <namecmp>
    800053ca:	10050b63          	beqz	a0,800054e0 <sys_unlink+0x15a>
    800053ce:	00002597          	auipc	a1,0x2
    800053d2:	29a58593          	addi	a1,a1,666 # 80007668 <etext+0x668>
    800053d6:	fb040513          	addi	a0,s0,-80
    800053da:	939fe0ef          	jal	80003d12 <namecmp>
    800053de:	10050163          	beqz	a0,800054e0 <sys_unlink+0x15a>
    800053e2:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800053e4:	f2c40613          	addi	a2,s0,-212
    800053e8:	fb040593          	addi	a1,s0,-80
    800053ec:	8526                	mv	a0,s1
    800053ee:	93bfe0ef          	jal	80003d28 <dirlookup>
    800053f2:	892a                	mv	s2,a0
    800053f4:	0e050563          	beqz	a0,800054de <sys_unlink+0x158>
    800053f8:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800053fa:	b94fe0ef          	jal	8000378e <ilock>
  if(ip->nlink < 1)
    800053fe:	04a91783          	lh	a5,74(s2)
    80005402:	06f05863          	blez	a5,80005472 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005406:	04491703          	lh	a4,68(s2)
    8000540a:	4785                	li	a5,1
    8000540c:	06f70963          	beq	a4,a5,8000547e <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005410:	fc040993          	addi	s3,s0,-64
    80005414:	4641                	li	a2,16
    80005416:	4581                	li	a1,0
    80005418:	854e                	mv	a0,s3
    8000541a:	921fb0ef          	jal	80000d3a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000541e:	4741                	li	a4,16
    80005420:	f2c42683          	lw	a3,-212(s0)
    80005424:	864e                	mv	a2,s3
    80005426:	4581                	li	a1,0
    80005428:	8526                	mv	a0,s1
    8000542a:	fe8fe0ef          	jal	80003c12 <writei>
    8000542e:	47c1                	li	a5,16
    80005430:	08f51863          	bne	a0,a5,800054c0 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80005434:	04491703          	lh	a4,68(s2)
    80005438:	4785                	li	a5,1
    8000543a:	08f70963          	beq	a4,a5,800054cc <sys_unlink+0x146>
  iunlockput(dp);
    8000543e:	8526                	mv	a0,s1
    80005440:	d5afe0ef          	jal	8000399a <iunlockput>
  ip->nlink--;
    80005444:	04a95783          	lhu	a5,74(s2)
    80005448:	37fd                	addiw	a5,a5,-1
    8000544a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000544e:	854a                	mv	a0,s2
    80005450:	a8afe0ef          	jal	800036da <iupdate>
  iunlockput(ip);
    80005454:	854a                	mv	a0,s2
    80005456:	d44fe0ef          	jal	8000399a <iunlockput>
  end_op();
    8000545a:	db1fe0ef          	jal	8000420a <end_op>
  return 0;
    8000545e:	4501                	li	a0,0
    80005460:	64ee                	ld	s1,216(sp)
    80005462:	694e                	ld	s2,208(sp)
    80005464:	69ae                	ld	s3,200(sp)
    80005466:	a061                	j	800054ee <sys_unlink+0x168>
    end_op();
    80005468:	da3fe0ef          	jal	8000420a <end_op>
    return -1;
    8000546c:	557d                	li	a0,-1
    8000546e:	64ee                	ld	s1,216(sp)
    80005470:	a8bd                	j	800054ee <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005472:	00002517          	auipc	a0,0x2
    80005476:	1fe50513          	addi	a0,a0,510 # 80007670 <etext+0x670>
    8000547a:	baafb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000547e:	04c92703          	lw	a4,76(s2)
    80005482:	02000793          	li	a5,32
    80005486:	f8e7f5e3          	bgeu	a5,a4,80005410 <sys_unlink+0x8a>
    8000548a:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000548c:	4741                	li	a4,16
    8000548e:	86ce                	mv	a3,s3
    80005490:	f1840613          	addi	a2,s0,-232
    80005494:	4581                	li	a1,0
    80005496:	854a                	mv	a0,s2
    80005498:	e88fe0ef          	jal	80003b20 <readi>
    8000549c:	47c1                	li	a5,16
    8000549e:	00f51b63          	bne	a0,a5,800054b4 <sys_unlink+0x12e>
    if(de.inum != 0)
    800054a2:	f1845783          	lhu	a5,-232(s0)
    800054a6:	ebb1                	bnez	a5,800054fa <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054a8:	29c1                	addiw	s3,s3,16
    800054aa:	04c92783          	lw	a5,76(s2)
    800054ae:	fcf9efe3          	bltu	s3,a5,8000548c <sys_unlink+0x106>
    800054b2:	bfb9                	j	80005410 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800054b4:	00002517          	auipc	a0,0x2
    800054b8:	1d450513          	addi	a0,a0,468 # 80007688 <etext+0x688>
    800054bc:	b68fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    800054c0:	00002517          	auipc	a0,0x2
    800054c4:	1e050513          	addi	a0,a0,480 # 800076a0 <etext+0x6a0>
    800054c8:	b5cfb0ef          	jal	80000824 <panic>
    dp->nlink--;
    800054cc:	04a4d783          	lhu	a5,74(s1)
    800054d0:	37fd                	addiw	a5,a5,-1
    800054d2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054d6:	8526                	mv	a0,s1
    800054d8:	a02fe0ef          	jal	800036da <iupdate>
    800054dc:	b78d                	j	8000543e <sys_unlink+0xb8>
    800054de:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800054e0:	8526                	mv	a0,s1
    800054e2:	cb8fe0ef          	jal	8000399a <iunlockput>
  end_op();
    800054e6:	d25fe0ef          	jal	8000420a <end_op>
  return -1;
    800054ea:	557d                	li	a0,-1
    800054ec:	64ee                	ld	s1,216(sp)
}
    800054ee:	70ae                	ld	ra,232(sp)
    800054f0:	740e                	ld	s0,224(sp)
    800054f2:	616d                	addi	sp,sp,240
    800054f4:	8082                	ret
    return -1;
    800054f6:	557d                	li	a0,-1
    800054f8:	bfdd                	j	800054ee <sys_unlink+0x168>
    iunlockput(ip);
    800054fa:	854a                	mv	a0,s2
    800054fc:	c9efe0ef          	jal	8000399a <iunlockput>
    goto bad;
    80005500:	694e                	ld	s2,208(sp)
    80005502:	69ae                	ld	s3,200(sp)
    80005504:	bff1                	j	800054e0 <sys_unlink+0x15a>

0000000080005506 <sys_open>:

uint64
sys_open(void)
{
    80005506:	7131                	addi	sp,sp,-192
    80005508:	fd06                	sd	ra,184(sp)
    8000550a:	f922                	sd	s0,176(sp)
    8000550c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000550e:	f4c40593          	addi	a1,s0,-180
    80005512:	4505                	li	a0,1
    80005514:	811fd0ef          	jal	80002d24 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005518:	08000613          	li	a2,128
    8000551c:	f5040593          	addi	a1,s0,-176
    80005520:	4501                	li	a0,0
    80005522:	83bfd0ef          	jal	80002d5c <argstr>
    80005526:	87aa                	mv	a5,a0
    return -1;
    80005528:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000552a:	0a07c363          	bltz	a5,800055d0 <sys_open+0xca>
    8000552e:	f526                	sd	s1,168(sp)

  begin_op();
    80005530:	c6bfe0ef          	jal	8000419a <begin_op>

  if(omode & O_CREATE){
    80005534:	f4c42783          	lw	a5,-180(s0)
    80005538:	2007f793          	andi	a5,a5,512
    8000553c:	c3dd                	beqz	a5,800055e2 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000553e:	4681                	li	a3,0
    80005540:	4601                	li	a2,0
    80005542:	4589                	li	a1,2
    80005544:	f5040513          	addi	a0,s0,-176
    80005548:	aafff0ef          	jal	80004ff6 <create>
    8000554c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000554e:	c549                	beqz	a0,800055d8 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005550:	04449703          	lh	a4,68(s1)
    80005554:	478d                	li	a5,3
    80005556:	00f71763          	bne	a4,a5,80005564 <sys_open+0x5e>
    8000555a:	0464d703          	lhu	a4,70(s1)
    8000555e:	47a5                	li	a5,9
    80005560:	0ae7ee63          	bltu	a5,a4,8000561c <sys_open+0x116>
    80005564:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005566:	fb5fe0ef          	jal	8000451a <filealloc>
    8000556a:	892a                	mv	s2,a0
    8000556c:	c561                	beqz	a0,80005634 <sys_open+0x12e>
    8000556e:	ed4e                	sd	s3,152(sp)
    80005570:	a47ff0ef          	jal	80004fb6 <fdalloc>
    80005574:	89aa                	mv	s3,a0
    80005576:	0a054b63          	bltz	a0,8000562c <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000557a:	04449703          	lh	a4,68(s1)
    8000557e:	478d                	li	a5,3
    80005580:	0cf70363          	beq	a4,a5,80005646 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005584:	4789                	li	a5,2
    80005586:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000558a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000558e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005592:	f4c42783          	lw	a5,-180(s0)
    80005596:	0017f713          	andi	a4,a5,1
    8000559a:	00174713          	xori	a4,a4,1
    8000559e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800055a2:	0037f713          	andi	a4,a5,3
    800055a6:	00e03733          	snez	a4,a4
    800055aa:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800055ae:	4007f793          	andi	a5,a5,1024
    800055b2:	c791                	beqz	a5,800055be <sys_open+0xb8>
    800055b4:	04449703          	lh	a4,68(s1)
    800055b8:	4789                	li	a5,2
    800055ba:	08f70d63          	beq	a4,a5,80005654 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800055be:	8526                	mv	a0,s1
    800055c0:	a7cfe0ef          	jal	8000383c <iunlock>
  end_op();
    800055c4:	c47fe0ef          	jal	8000420a <end_op>

  return fd;
    800055c8:	854e                	mv	a0,s3
    800055ca:	74aa                	ld	s1,168(sp)
    800055cc:	790a                	ld	s2,160(sp)
    800055ce:	69ea                	ld	s3,152(sp)
}
    800055d0:	70ea                	ld	ra,184(sp)
    800055d2:	744a                	ld	s0,176(sp)
    800055d4:	6129                	addi	sp,sp,192
    800055d6:	8082                	ret
      end_op();
    800055d8:	c33fe0ef          	jal	8000420a <end_op>
      return -1;
    800055dc:	557d                	li	a0,-1
    800055de:	74aa                	ld	s1,168(sp)
    800055e0:	bfc5                	j	800055d0 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    800055e2:	f5040513          	addi	a0,s0,-176
    800055e6:	9d7fe0ef          	jal	80003fbc <namei>
    800055ea:	84aa                	mv	s1,a0
    800055ec:	c11d                	beqz	a0,80005612 <sys_open+0x10c>
    ilock(ip);
    800055ee:	9a0fe0ef          	jal	8000378e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800055f2:	04449703          	lh	a4,68(s1)
    800055f6:	4785                	li	a5,1
    800055f8:	f4f71ce3          	bne	a4,a5,80005550 <sys_open+0x4a>
    800055fc:	f4c42783          	lw	a5,-180(s0)
    80005600:	d3b5                	beqz	a5,80005564 <sys_open+0x5e>
      iunlockput(ip);
    80005602:	8526                	mv	a0,s1
    80005604:	b96fe0ef          	jal	8000399a <iunlockput>
      end_op();
    80005608:	c03fe0ef          	jal	8000420a <end_op>
      return -1;
    8000560c:	557d                	li	a0,-1
    8000560e:	74aa                	ld	s1,168(sp)
    80005610:	b7c1                	j	800055d0 <sys_open+0xca>
      end_op();
    80005612:	bf9fe0ef          	jal	8000420a <end_op>
      return -1;
    80005616:	557d                	li	a0,-1
    80005618:	74aa                	ld	s1,168(sp)
    8000561a:	bf5d                	j	800055d0 <sys_open+0xca>
    iunlockput(ip);
    8000561c:	8526                	mv	a0,s1
    8000561e:	b7cfe0ef          	jal	8000399a <iunlockput>
    end_op();
    80005622:	be9fe0ef          	jal	8000420a <end_op>
    return -1;
    80005626:	557d                	li	a0,-1
    80005628:	74aa                	ld	s1,168(sp)
    8000562a:	b75d                	j	800055d0 <sys_open+0xca>
      fileclose(f);
    8000562c:	854a                	mv	a0,s2
    8000562e:	f91fe0ef          	jal	800045be <fileclose>
    80005632:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005634:	8526                	mv	a0,s1
    80005636:	b64fe0ef          	jal	8000399a <iunlockput>
    end_op();
    8000563a:	bd1fe0ef          	jal	8000420a <end_op>
    return -1;
    8000563e:	557d                	li	a0,-1
    80005640:	74aa                	ld	s1,168(sp)
    80005642:	790a                	ld	s2,160(sp)
    80005644:	b771                	j	800055d0 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005646:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000564a:	04649783          	lh	a5,70(s1)
    8000564e:	02f91223          	sh	a5,36(s2)
    80005652:	bf35                	j	8000558e <sys_open+0x88>
    itrunc(ip);
    80005654:	8526                	mv	a0,s1
    80005656:	a26fe0ef          	jal	8000387c <itrunc>
    8000565a:	b795                	j	800055be <sys_open+0xb8>

000000008000565c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000565c:	7175                	addi	sp,sp,-144
    8000565e:	e506                	sd	ra,136(sp)
    80005660:	e122                	sd	s0,128(sp)
    80005662:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005664:	b37fe0ef          	jal	8000419a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005668:	08000613          	li	a2,128
    8000566c:	f7040593          	addi	a1,s0,-144
    80005670:	4501                	li	a0,0
    80005672:	eeafd0ef          	jal	80002d5c <argstr>
    80005676:	02054363          	bltz	a0,8000569c <sys_mkdir+0x40>
    8000567a:	4681                	li	a3,0
    8000567c:	4601                	li	a2,0
    8000567e:	4585                	li	a1,1
    80005680:	f7040513          	addi	a0,s0,-144
    80005684:	973ff0ef          	jal	80004ff6 <create>
    80005688:	c911                	beqz	a0,8000569c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000568a:	b10fe0ef          	jal	8000399a <iunlockput>
  end_op();
    8000568e:	b7dfe0ef          	jal	8000420a <end_op>
  return 0;
    80005692:	4501                	li	a0,0
}
    80005694:	60aa                	ld	ra,136(sp)
    80005696:	640a                	ld	s0,128(sp)
    80005698:	6149                	addi	sp,sp,144
    8000569a:	8082                	ret
    end_op();
    8000569c:	b6ffe0ef          	jal	8000420a <end_op>
    return -1;
    800056a0:	557d                	li	a0,-1
    800056a2:	bfcd                	j	80005694 <sys_mkdir+0x38>

00000000800056a4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800056a4:	7135                	addi	sp,sp,-160
    800056a6:	ed06                	sd	ra,152(sp)
    800056a8:	e922                	sd	s0,144(sp)
    800056aa:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800056ac:	aeffe0ef          	jal	8000419a <begin_op>
  argint(1, &major);
    800056b0:	f6c40593          	addi	a1,s0,-148
    800056b4:	4505                	li	a0,1
    800056b6:	e6efd0ef          	jal	80002d24 <argint>
  argint(2, &minor);
    800056ba:	f6840593          	addi	a1,s0,-152
    800056be:	4509                	li	a0,2
    800056c0:	e64fd0ef          	jal	80002d24 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800056c4:	08000613          	li	a2,128
    800056c8:	f7040593          	addi	a1,s0,-144
    800056cc:	4501                	li	a0,0
    800056ce:	e8efd0ef          	jal	80002d5c <argstr>
    800056d2:	02054563          	bltz	a0,800056fc <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800056d6:	f6841683          	lh	a3,-152(s0)
    800056da:	f6c41603          	lh	a2,-148(s0)
    800056de:	458d                	li	a1,3
    800056e0:	f7040513          	addi	a0,s0,-144
    800056e4:	913ff0ef          	jal	80004ff6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800056e8:	c911                	beqz	a0,800056fc <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056ea:	ab0fe0ef          	jal	8000399a <iunlockput>
  end_op();
    800056ee:	b1dfe0ef          	jal	8000420a <end_op>
  return 0;
    800056f2:	4501                	li	a0,0
}
    800056f4:	60ea                	ld	ra,152(sp)
    800056f6:	644a                	ld	s0,144(sp)
    800056f8:	610d                	addi	sp,sp,160
    800056fa:	8082                	ret
    end_op();
    800056fc:	b0ffe0ef          	jal	8000420a <end_op>
    return -1;
    80005700:	557d                	li	a0,-1
    80005702:	bfcd                	j	800056f4 <sys_mknod+0x50>

0000000080005704 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005704:	7135                	addi	sp,sp,-160
    80005706:	ed06                	sd	ra,152(sp)
    80005708:	e922                	sd	s0,144(sp)
    8000570a:	e14a                	sd	s2,128(sp)
    8000570c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000570e:	a56fc0ef          	jal	80001964 <myproc>
    80005712:	892a                	mv	s2,a0
  
  begin_op();
    80005714:	a87fe0ef          	jal	8000419a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005718:	08000613          	li	a2,128
    8000571c:	f6040593          	addi	a1,s0,-160
    80005720:	4501                	li	a0,0
    80005722:	e3afd0ef          	jal	80002d5c <argstr>
    80005726:	04054363          	bltz	a0,8000576c <sys_chdir+0x68>
    8000572a:	e526                	sd	s1,136(sp)
    8000572c:	f6040513          	addi	a0,s0,-160
    80005730:	88dfe0ef          	jal	80003fbc <namei>
    80005734:	84aa                	mv	s1,a0
    80005736:	c915                	beqz	a0,8000576a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005738:	856fe0ef          	jal	8000378e <ilock>
  if(ip->type != T_DIR){
    8000573c:	04449703          	lh	a4,68(s1)
    80005740:	4785                	li	a5,1
    80005742:	02f71963          	bne	a4,a5,80005774 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005746:	8526                	mv	a0,s1
    80005748:	8f4fe0ef          	jal	8000383c <iunlock>
  iput(p->cwd);
    8000574c:	17093503          	ld	a0,368(s2)
    80005750:	9c0fe0ef          	jal	80003910 <iput>
  end_op();
    80005754:	ab7fe0ef          	jal	8000420a <end_op>
  p->cwd = ip;
    80005758:	16993823          	sd	s1,368(s2)
  return 0;
    8000575c:	4501                	li	a0,0
    8000575e:	64aa                	ld	s1,136(sp)
}
    80005760:	60ea                	ld	ra,152(sp)
    80005762:	644a                	ld	s0,144(sp)
    80005764:	690a                	ld	s2,128(sp)
    80005766:	610d                	addi	sp,sp,160
    80005768:	8082                	ret
    8000576a:	64aa                	ld	s1,136(sp)
    end_op();
    8000576c:	a9ffe0ef          	jal	8000420a <end_op>
    return -1;
    80005770:	557d                	li	a0,-1
    80005772:	b7fd                	j	80005760 <sys_chdir+0x5c>
    iunlockput(ip);
    80005774:	8526                	mv	a0,s1
    80005776:	a24fe0ef          	jal	8000399a <iunlockput>
    end_op();
    8000577a:	a91fe0ef          	jal	8000420a <end_op>
    return -1;
    8000577e:	557d                	li	a0,-1
    80005780:	64aa                	ld	s1,136(sp)
    80005782:	bff9                	j	80005760 <sys_chdir+0x5c>

0000000080005784 <sys_exec>:

uint64
sys_exec(void)
{
    80005784:	7105                	addi	sp,sp,-480
    80005786:	ef86                	sd	ra,472(sp)
    80005788:	eba2                	sd	s0,464(sp)
    8000578a:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000578c:	e2840593          	addi	a1,s0,-472
    80005790:	4505                	li	a0,1
    80005792:	daefd0ef          	jal	80002d40 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005796:	08000613          	li	a2,128
    8000579a:	f3040593          	addi	a1,s0,-208
    8000579e:	4501                	li	a0,0
    800057a0:	dbcfd0ef          	jal	80002d5c <argstr>
    800057a4:	87aa                	mv	a5,a0
    return -1;
    800057a6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800057a8:	0e07c063          	bltz	a5,80005888 <sys_exec+0x104>
    800057ac:	e7a6                	sd	s1,456(sp)
    800057ae:	e3ca                	sd	s2,448(sp)
    800057b0:	ff4e                	sd	s3,440(sp)
    800057b2:	fb52                	sd	s4,432(sp)
    800057b4:	f756                	sd	s5,424(sp)
    800057b6:	f35a                	sd	s6,416(sp)
    800057b8:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800057ba:	e3040a13          	addi	s4,s0,-464
    800057be:	10000613          	li	a2,256
    800057c2:	4581                	li	a1,0
    800057c4:	8552                	mv	a0,s4
    800057c6:	d74fb0ef          	jal	80000d3a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800057ca:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800057cc:	89d2                	mv	s3,s4
    800057ce:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800057d0:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800057d4:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800057d6:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800057da:	00391513          	slli	a0,s2,0x3
    800057de:	85d6                	mv	a1,s5
    800057e0:	e2843783          	ld	a5,-472(s0)
    800057e4:	953e                	add	a0,a0,a5
    800057e6:	cb4fd0ef          	jal	80002c9a <fetchaddr>
    800057ea:	02054663          	bltz	a0,80005816 <sys_exec+0x92>
    if(uarg == 0){
    800057ee:	e2043783          	ld	a5,-480(s0)
    800057f2:	c7a1                	beqz	a5,8000583a <sys_exec+0xb6>
    argv[i] = kalloc();
    800057f4:	b92fb0ef          	jal	80000b86 <kalloc>
    800057f8:	85aa                	mv	a1,a0
    800057fa:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800057fe:	cd01                	beqz	a0,80005816 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005800:	865a                	mv	a2,s6
    80005802:	e2043503          	ld	a0,-480(s0)
    80005806:	cdefd0ef          	jal	80002ce4 <fetchstr>
    8000580a:	00054663          	bltz	a0,80005816 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    8000580e:	0905                	addi	s2,s2,1
    80005810:	09a1                	addi	s3,s3,8
    80005812:	fd7914e3          	bne	s2,s7,800057da <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005816:	100a0a13          	addi	s4,s4,256
    8000581a:	6088                	ld	a0,0(s1)
    8000581c:	cd31                	beqz	a0,80005878 <sys_exec+0xf4>
    kfree(argv[i]);
    8000581e:	a3efb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005822:	04a1                	addi	s1,s1,8
    80005824:	ff449be3          	bne	s1,s4,8000581a <sys_exec+0x96>
  return -1;
    80005828:	557d                	li	a0,-1
    8000582a:	64be                	ld	s1,456(sp)
    8000582c:	691e                	ld	s2,448(sp)
    8000582e:	79fa                	ld	s3,440(sp)
    80005830:	7a5a                	ld	s4,432(sp)
    80005832:	7aba                	ld	s5,424(sp)
    80005834:	7b1a                	ld	s6,416(sp)
    80005836:	6bfa                	ld	s7,408(sp)
    80005838:	a881                	j	80005888 <sys_exec+0x104>
      argv[i] = 0;
    8000583a:	0009079b          	sext.w	a5,s2
    8000583e:	e3040593          	addi	a1,s0,-464
    80005842:	078e                	slli	a5,a5,0x3
    80005844:	97ae                	add	a5,a5,a1
    80005846:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000584a:	f3040513          	addi	a0,s0,-208
    8000584e:	bb2ff0ef          	jal	80004c00 <kexec>
    80005852:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005854:	100a0a13          	addi	s4,s4,256
    80005858:	6088                	ld	a0,0(s1)
    8000585a:	c511                	beqz	a0,80005866 <sys_exec+0xe2>
    kfree(argv[i]);
    8000585c:	a00fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005860:	04a1                	addi	s1,s1,8
    80005862:	ff449be3          	bne	s1,s4,80005858 <sys_exec+0xd4>
  return ret;
    80005866:	854a                	mv	a0,s2
    80005868:	64be                	ld	s1,456(sp)
    8000586a:	691e                	ld	s2,448(sp)
    8000586c:	79fa                	ld	s3,440(sp)
    8000586e:	7a5a                	ld	s4,432(sp)
    80005870:	7aba                	ld	s5,424(sp)
    80005872:	7b1a                	ld	s6,416(sp)
    80005874:	6bfa                	ld	s7,408(sp)
    80005876:	a809                	j	80005888 <sys_exec+0x104>
  return -1;
    80005878:	557d                	li	a0,-1
    8000587a:	64be                	ld	s1,456(sp)
    8000587c:	691e                	ld	s2,448(sp)
    8000587e:	79fa                	ld	s3,440(sp)
    80005880:	7a5a                	ld	s4,432(sp)
    80005882:	7aba                	ld	s5,424(sp)
    80005884:	7b1a                	ld	s6,416(sp)
    80005886:	6bfa                	ld	s7,408(sp)
}
    80005888:	60fe                	ld	ra,472(sp)
    8000588a:	645e                	ld	s0,464(sp)
    8000588c:	613d                	addi	sp,sp,480
    8000588e:	8082                	ret

0000000080005890 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005890:	7139                	addi	sp,sp,-64
    80005892:	fc06                	sd	ra,56(sp)
    80005894:	f822                	sd	s0,48(sp)
    80005896:	f426                	sd	s1,40(sp)
    80005898:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000589a:	8cafc0ef          	jal	80001964 <myproc>
    8000589e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800058a0:	fd840593          	addi	a1,s0,-40
    800058a4:	4501                	li	a0,0
    800058a6:	c9afd0ef          	jal	80002d40 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800058aa:	fc840593          	addi	a1,s0,-56
    800058ae:	fd040513          	addi	a0,s0,-48
    800058b2:	828ff0ef          	jal	800048da <pipealloc>
    return -1;
    800058b6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800058b8:	0a054763          	bltz	a0,80005966 <sys_pipe+0xd6>
  fd0 = -1;
    800058bc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800058c0:	fd043503          	ld	a0,-48(s0)
    800058c4:	ef2ff0ef          	jal	80004fb6 <fdalloc>
    800058c8:	fca42223          	sw	a0,-60(s0)
    800058cc:	08054463          	bltz	a0,80005954 <sys_pipe+0xc4>
    800058d0:	fc843503          	ld	a0,-56(s0)
    800058d4:	ee2ff0ef          	jal	80004fb6 <fdalloc>
    800058d8:	fca42023          	sw	a0,-64(s0)
    800058dc:	06054263          	bltz	a0,80005940 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800058e0:	4691                	li	a3,4
    800058e2:	fc440613          	addi	a2,s0,-60
    800058e6:	fd843583          	ld	a1,-40(s0)
    800058ea:	78a8                	ld	a0,112(s1)
    800058ec:	dabfb0ef          	jal	80001696 <copyout>
    800058f0:	00054e63          	bltz	a0,8000590c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800058f4:	4691                	li	a3,4
    800058f6:	fc040613          	addi	a2,s0,-64
    800058fa:	fd843583          	ld	a1,-40(s0)
    800058fe:	95b6                	add	a1,a1,a3
    80005900:	78a8                	ld	a0,112(s1)
    80005902:	d95fb0ef          	jal	80001696 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005906:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005908:	04055f63          	bgez	a0,80005966 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    8000590c:	fc442783          	lw	a5,-60(s0)
    80005910:	078e                	slli	a5,a5,0x3
    80005912:	0f078793          	addi	a5,a5,240
    80005916:	97a6                	add	a5,a5,s1
    80005918:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000591c:	fc042783          	lw	a5,-64(s0)
    80005920:	078e                	slli	a5,a5,0x3
    80005922:	0f078793          	addi	a5,a5,240
    80005926:	97a6                	add	a5,a5,s1
    80005928:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000592c:	fd043503          	ld	a0,-48(s0)
    80005930:	c8ffe0ef          	jal	800045be <fileclose>
    fileclose(wf);
    80005934:	fc843503          	ld	a0,-56(s0)
    80005938:	c87fe0ef          	jal	800045be <fileclose>
    return -1;
    8000593c:	57fd                	li	a5,-1
    8000593e:	a025                	j	80005966 <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005940:	fc442783          	lw	a5,-60(s0)
    80005944:	0007c863          	bltz	a5,80005954 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005948:	078e                	slli	a5,a5,0x3
    8000594a:	0f078793          	addi	a5,a5,240
    8000594e:	97a6                	add	a5,a5,s1
    80005950:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005954:	fd043503          	ld	a0,-48(s0)
    80005958:	c67fe0ef          	jal	800045be <fileclose>
    fileclose(wf);
    8000595c:	fc843503          	ld	a0,-56(s0)
    80005960:	c5ffe0ef          	jal	800045be <fileclose>
    return -1;
    80005964:	57fd                	li	a5,-1
}
    80005966:	853e                	mv	a0,a5
    80005968:	70e2                	ld	ra,56(sp)
    8000596a:	7442                	ld	s0,48(sp)
    8000596c:	74a2                	ld	s1,40(sp)
    8000596e:	6121                	addi	sp,sp,64
    80005970:	8082                	ret
	...

0000000080005980 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005980:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005982:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005984:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005986:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005988:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000598a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000598c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000598e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005990:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005992:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005994:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005996:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005998:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000599a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000599c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000599e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800059a0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800059a2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800059a4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800059a6:	a02fd0ef          	jal	80002ba8 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800059aa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800059ac:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800059ae:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800059b0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800059b2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800059b4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800059b6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800059b8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800059ba:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800059bc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800059be:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800059c0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800059c2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800059c4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800059c6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800059c8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800059ca:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800059cc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800059ce:	10200073          	sret
    800059d2:	00000013          	nop
    800059d6:	00000013          	nop
    800059da:	00000013          	nop

00000000800059de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800059de:	1141                	addi	sp,sp,-16
    800059e0:	e406                	sd	ra,8(sp)
    800059e2:	e022                	sd	s0,0(sp)
    800059e4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800059e6:	0c000737          	lui	a4,0xc000
    800059ea:	4785                	li	a5,1
    800059ec:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800059ee:	c35c                	sw	a5,4(a4)
}
    800059f0:	60a2                	ld	ra,8(sp)
    800059f2:	6402                	ld	s0,0(sp)
    800059f4:	0141                	addi	sp,sp,16
    800059f6:	8082                	ret

00000000800059f8 <plicinithart>:

void
plicinithart(void)
{
    800059f8:	1141                	addi	sp,sp,-16
    800059fa:	e406                	sd	ra,8(sp)
    800059fc:	e022                	sd	s0,0(sp)
    800059fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a00:	f31fb0ef          	jal	80001930 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005a04:	0085171b          	slliw	a4,a0,0x8
    80005a08:	0c0027b7          	lui	a5,0xc002
    80005a0c:	97ba                	add	a5,a5,a4
    80005a0e:	40200713          	li	a4,1026
    80005a12:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005a16:	00d5151b          	slliw	a0,a0,0xd
    80005a1a:	0c2017b7          	lui	a5,0xc201
    80005a1e:	97aa                	add	a5,a5,a0
    80005a20:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005a24:	60a2                	ld	ra,8(sp)
    80005a26:	6402                	ld	s0,0(sp)
    80005a28:	0141                	addi	sp,sp,16
    80005a2a:	8082                	ret

0000000080005a2c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005a2c:	1141                	addi	sp,sp,-16
    80005a2e:	e406                	sd	ra,8(sp)
    80005a30:	e022                	sd	s0,0(sp)
    80005a32:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a34:	efdfb0ef          	jal	80001930 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005a38:	00d5151b          	slliw	a0,a0,0xd
    80005a3c:	0c2017b7          	lui	a5,0xc201
    80005a40:	97aa                	add	a5,a5,a0
  return irq;
}
    80005a42:	43c8                	lw	a0,4(a5)
    80005a44:	60a2                	ld	ra,8(sp)
    80005a46:	6402                	ld	s0,0(sp)
    80005a48:	0141                	addi	sp,sp,16
    80005a4a:	8082                	ret

0000000080005a4c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005a4c:	1101                	addi	sp,sp,-32
    80005a4e:	ec06                	sd	ra,24(sp)
    80005a50:	e822                	sd	s0,16(sp)
    80005a52:	e426                	sd	s1,8(sp)
    80005a54:	1000                	addi	s0,sp,32
    80005a56:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005a58:	ed9fb0ef          	jal	80001930 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005a5c:	00d5179b          	slliw	a5,a0,0xd
    80005a60:	0c201737          	lui	a4,0xc201
    80005a64:	97ba                	add	a5,a5,a4
    80005a66:	c3c4                	sw	s1,4(a5)
}
    80005a68:	60e2                	ld	ra,24(sp)
    80005a6a:	6442                	ld	s0,16(sp)
    80005a6c:	64a2                	ld	s1,8(sp)
    80005a6e:	6105                	addi	sp,sp,32
    80005a70:	8082                	ret

0000000080005a72 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a72:	1141                	addi	sp,sp,-16
    80005a74:	e406                	sd	ra,8(sp)
    80005a76:	e022                	sd	s0,0(sp)
    80005a78:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005a7a:	479d                	li	a5,7
    80005a7c:	04a7ca63          	blt	a5,a0,80005ad0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005a80:	0001c797          	auipc	a5,0x1c
    80005a84:	94878793          	addi	a5,a5,-1720 # 800213c8 <disk>
    80005a88:	97aa                	add	a5,a5,a0
    80005a8a:	0187c783          	lbu	a5,24(a5)
    80005a8e:	e7b9                	bnez	a5,80005adc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005a90:	00451693          	slli	a3,a0,0x4
    80005a94:	0001c797          	auipc	a5,0x1c
    80005a98:	93478793          	addi	a5,a5,-1740 # 800213c8 <disk>
    80005a9c:	6398                	ld	a4,0(a5)
    80005a9e:	9736                	add	a4,a4,a3
    80005aa0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005aa4:	6398                	ld	a4,0(a5)
    80005aa6:	9736                	add	a4,a4,a3
    80005aa8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005aac:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ab0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ab4:	97aa                	add	a5,a5,a0
    80005ab6:	4705                	li	a4,1
    80005ab8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005abc:	0001c517          	auipc	a0,0x1c
    80005ac0:	92450513          	addi	a0,a0,-1756 # 800213e0 <disk+0x18>
    80005ac4:	db8fc0ef          	jal	8000207c <wakeup>
}
    80005ac8:	60a2                	ld	ra,8(sp)
    80005aca:	6402                	ld	s0,0(sp)
    80005acc:	0141                	addi	sp,sp,16
    80005ace:	8082                	ret
    panic("free_desc 1");
    80005ad0:	00002517          	auipc	a0,0x2
    80005ad4:	be050513          	addi	a0,a0,-1056 # 800076b0 <etext+0x6b0>
    80005ad8:	d4dfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    80005adc:	00002517          	auipc	a0,0x2
    80005ae0:	be450513          	addi	a0,a0,-1052 # 800076c0 <etext+0x6c0>
    80005ae4:	d41fa0ef          	jal	80000824 <panic>

0000000080005ae8 <virtio_disk_init>:
{
    80005ae8:	1101                	addi	sp,sp,-32
    80005aea:	ec06                	sd	ra,24(sp)
    80005aec:	e822                	sd	s0,16(sp)
    80005aee:	e426                	sd	s1,8(sp)
    80005af0:	e04a                	sd	s2,0(sp)
    80005af2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005af4:	00002597          	auipc	a1,0x2
    80005af8:	bdc58593          	addi	a1,a1,-1060 # 800076d0 <etext+0x6d0>
    80005afc:	0001c517          	auipc	a0,0x1c
    80005b00:	9f450513          	addi	a0,a0,-1548 # 800214f0 <disk+0x128>
    80005b04:	8dcfb0ef          	jal	80000be0 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b08:	100017b7          	lui	a5,0x10001
    80005b0c:	4398                	lw	a4,0(a5)
    80005b0e:	2701                	sext.w	a4,a4
    80005b10:	747277b7          	lui	a5,0x74727
    80005b14:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005b18:	14f71863          	bne	a4,a5,80005c68 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b1c:	100017b7          	lui	a5,0x10001
    80005b20:	43dc                	lw	a5,4(a5)
    80005b22:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b24:	4709                	li	a4,2
    80005b26:	14e79163          	bne	a5,a4,80005c68 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b2a:	100017b7          	lui	a5,0x10001
    80005b2e:	479c                	lw	a5,8(a5)
    80005b30:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b32:	12e79b63          	bne	a5,a4,80005c68 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005b36:	100017b7          	lui	a5,0x10001
    80005b3a:	47d8                	lw	a4,12(a5)
    80005b3c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b3e:	554d47b7          	lui	a5,0x554d4
    80005b42:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005b46:	12f71163          	bne	a4,a5,80005c68 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b4a:	100017b7          	lui	a5,0x10001
    80005b4e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b52:	4705                	li	a4,1
    80005b54:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b56:	470d                	li	a4,3
    80005b58:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005b5a:	10001737          	lui	a4,0x10001
    80005b5e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005b60:	c7ffe6b7          	lui	a3,0xc7ffe
    80005b64:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd257>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005b68:	8f75                	and	a4,a4,a3
    80005b6a:	100016b7          	lui	a3,0x10001
    80005b6e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b70:	472d                	li	a4,11
    80005b72:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b74:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005b78:	439c                	lw	a5,0(a5)
    80005b7a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b7e:	8ba1                	andi	a5,a5,8
    80005b80:	0e078a63          	beqz	a5,80005c74 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005b84:	100017b7          	lui	a5,0x10001
    80005b88:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005b8c:	43fc                	lw	a5,68(a5)
    80005b8e:	2781                	sext.w	a5,a5
    80005b90:	0e079863          	bnez	a5,80005c80 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005b94:	100017b7          	lui	a5,0x10001
    80005b98:	5bdc                	lw	a5,52(a5)
    80005b9a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005b9c:	0e078863          	beqz	a5,80005c8c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005ba0:	471d                	li	a4,7
    80005ba2:	0ef77b63          	bgeu	a4,a5,80005c98 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005ba6:	fe1fa0ef          	jal	80000b86 <kalloc>
    80005baa:	0001c497          	auipc	s1,0x1c
    80005bae:	81e48493          	addi	s1,s1,-2018 # 800213c8 <disk>
    80005bb2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005bb4:	fd3fa0ef          	jal	80000b86 <kalloc>
    80005bb8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005bba:	fcdfa0ef          	jal	80000b86 <kalloc>
    80005bbe:	87aa                	mv	a5,a0
    80005bc0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005bc2:	6088                	ld	a0,0(s1)
    80005bc4:	0e050063          	beqz	a0,80005ca4 <virtio_disk_init+0x1bc>
    80005bc8:	0001c717          	auipc	a4,0x1c
    80005bcc:	80873703          	ld	a4,-2040(a4) # 800213d0 <disk+0x8>
    80005bd0:	cb71                	beqz	a4,80005ca4 <virtio_disk_init+0x1bc>
    80005bd2:	cbe9                	beqz	a5,80005ca4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005bd4:	6605                	lui	a2,0x1
    80005bd6:	4581                	li	a1,0
    80005bd8:	962fb0ef          	jal	80000d3a <memset>
  memset(disk.avail, 0, PGSIZE);
    80005bdc:	0001b497          	auipc	s1,0x1b
    80005be0:	7ec48493          	addi	s1,s1,2028 # 800213c8 <disk>
    80005be4:	6605                	lui	a2,0x1
    80005be6:	4581                	li	a1,0
    80005be8:	6488                	ld	a0,8(s1)
    80005bea:	950fb0ef          	jal	80000d3a <memset>
  memset(disk.used, 0, PGSIZE);
    80005bee:	6605                	lui	a2,0x1
    80005bf0:	4581                	li	a1,0
    80005bf2:	6888                	ld	a0,16(s1)
    80005bf4:	946fb0ef          	jal	80000d3a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005bf8:	100017b7          	lui	a5,0x10001
    80005bfc:	4721                	li	a4,8
    80005bfe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005c00:	4098                	lw	a4,0(s1)
    80005c02:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005c06:	40d8                	lw	a4,4(s1)
    80005c08:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005c0c:	649c                	ld	a5,8(s1)
    80005c0e:	0007869b          	sext.w	a3,a5
    80005c12:	10001737          	lui	a4,0x10001
    80005c16:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005c1a:	9781                	srai	a5,a5,0x20
    80005c1c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005c20:	689c                	ld	a5,16(s1)
    80005c22:	0007869b          	sext.w	a3,a5
    80005c26:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005c2a:	9781                	srai	a5,a5,0x20
    80005c2c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005c30:	4785                	li	a5,1
    80005c32:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005c34:	00f48c23          	sb	a5,24(s1)
    80005c38:	00f48ca3          	sb	a5,25(s1)
    80005c3c:	00f48d23          	sb	a5,26(s1)
    80005c40:	00f48da3          	sb	a5,27(s1)
    80005c44:	00f48e23          	sb	a5,28(s1)
    80005c48:	00f48ea3          	sb	a5,29(s1)
    80005c4c:	00f48f23          	sb	a5,30(s1)
    80005c50:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005c54:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c58:	07272823          	sw	s2,112(a4)
}
    80005c5c:	60e2                	ld	ra,24(sp)
    80005c5e:	6442                	ld	s0,16(sp)
    80005c60:	64a2                	ld	s1,8(sp)
    80005c62:	6902                	ld	s2,0(sp)
    80005c64:	6105                	addi	sp,sp,32
    80005c66:	8082                	ret
    panic("could not find virtio disk");
    80005c68:	00002517          	auipc	a0,0x2
    80005c6c:	a7850513          	addi	a0,a0,-1416 # 800076e0 <etext+0x6e0>
    80005c70:	bb5fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c74:	00002517          	auipc	a0,0x2
    80005c78:	a8c50513          	addi	a0,a0,-1396 # 80007700 <etext+0x700>
    80005c7c:	ba9fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005c80:	00002517          	auipc	a0,0x2
    80005c84:	aa050513          	addi	a0,a0,-1376 # 80007720 <etext+0x720>
    80005c88:	b9dfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    80005c8c:	00002517          	auipc	a0,0x2
    80005c90:	ab450513          	addi	a0,a0,-1356 # 80007740 <etext+0x740>
    80005c94:	b91fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005c98:	00002517          	auipc	a0,0x2
    80005c9c:	ac850513          	addi	a0,a0,-1336 # 80007760 <etext+0x760>
    80005ca0:	b85fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005ca4:	00002517          	auipc	a0,0x2
    80005ca8:	adc50513          	addi	a0,a0,-1316 # 80007780 <etext+0x780>
    80005cac:	b79fa0ef          	jal	80000824 <panic>

0000000080005cb0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005cb0:	711d                	addi	sp,sp,-96
    80005cb2:	ec86                	sd	ra,88(sp)
    80005cb4:	e8a2                	sd	s0,80(sp)
    80005cb6:	e4a6                	sd	s1,72(sp)
    80005cb8:	e0ca                	sd	s2,64(sp)
    80005cba:	fc4e                	sd	s3,56(sp)
    80005cbc:	f852                	sd	s4,48(sp)
    80005cbe:	f456                	sd	s5,40(sp)
    80005cc0:	f05a                	sd	s6,32(sp)
    80005cc2:	ec5e                	sd	s7,24(sp)
    80005cc4:	e862                	sd	s8,16(sp)
    80005cc6:	1080                	addi	s0,sp,96
    80005cc8:	89aa                	mv	s3,a0
    80005cca:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ccc:	00c52b83          	lw	s7,12(a0)
    80005cd0:	001b9b9b          	slliw	s7,s7,0x1
    80005cd4:	1b82                	slli	s7,s7,0x20
    80005cd6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005cda:	0001c517          	auipc	a0,0x1c
    80005cde:	81650513          	addi	a0,a0,-2026 # 800214f0 <disk+0x128>
    80005ce2:	f89fa0ef          	jal	80000c6a <acquire>
  for(int i = 0; i < NUM; i++){
    80005ce6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005ce8:	0001ba97          	auipc	s5,0x1b
    80005cec:	6e0a8a93          	addi	s5,s5,1760 # 800213c8 <disk>
  for(int i = 0; i < 3; i++){
    80005cf0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005cf2:	5c7d                	li	s8,-1
    80005cf4:	a095                	j	80005d58 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005cf6:	00fa8733          	add	a4,s5,a5
    80005cfa:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005cfe:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005d00:	0207c563          	bltz	a5,80005d2a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005d04:	2905                	addiw	s2,s2,1
    80005d06:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005d08:	05490c63          	beq	s2,s4,80005d60 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005d0c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005d0e:	0001b717          	auipc	a4,0x1b
    80005d12:	6ba70713          	addi	a4,a4,1722 # 800213c8 <disk>
    80005d16:	4781                	li	a5,0
    if(disk.free[i]){
    80005d18:	01874683          	lbu	a3,24(a4)
    80005d1c:	fee9                	bnez	a3,80005cf6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005d1e:	2785                	addiw	a5,a5,1
    80005d20:	0705                	addi	a4,a4,1
    80005d22:	fe979be3          	bne	a5,s1,80005d18 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005d26:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005d2a:	01205d63          	blez	s2,80005d44 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d2e:	fa042503          	lw	a0,-96(s0)
    80005d32:	d41ff0ef          	jal	80005a72 <free_desc>
      for(int j = 0; j < i; j++)
    80005d36:	4785                	li	a5,1
    80005d38:	0127d663          	bge	a5,s2,80005d44 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d3c:	fa442503          	lw	a0,-92(s0)
    80005d40:	d33ff0ef          	jal	80005a72 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005d44:	0001b597          	auipc	a1,0x1b
    80005d48:	7ac58593          	addi	a1,a1,1964 # 800214f0 <disk+0x128>
    80005d4c:	0001b517          	auipc	a0,0x1b
    80005d50:	69450513          	addi	a0,a0,1684 # 800213e0 <disk+0x18>
    80005d54:	adcfc0ef          	jal	80002030 <sleep>
  for(int i = 0; i < 3; i++){
    80005d58:	fa040613          	addi	a2,s0,-96
    80005d5c:	4901                	li	s2,0
    80005d5e:	b77d                	j	80005d0c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d60:	fa042503          	lw	a0,-96(s0)
    80005d64:	00451693          	slli	a3,a0,0x4

  if(write)
    80005d68:	0001b797          	auipc	a5,0x1b
    80005d6c:	66078793          	addi	a5,a5,1632 # 800213c8 <disk>
    80005d70:	00451713          	slli	a4,a0,0x4
    80005d74:	0a070713          	addi	a4,a4,160
    80005d78:	973e                	add	a4,a4,a5
    80005d7a:	01603633          	snez	a2,s6
    80005d7e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005d80:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005d84:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005d88:	6398                	ld	a4,0(a5)
    80005d8a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d8c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005d90:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005d92:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005d94:	6390                	ld	a2,0(a5)
    80005d96:	00d60833          	add	a6,a2,a3
    80005d9a:	4741                	li	a4,16
    80005d9c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005da0:	4585                	li	a1,1
    80005da2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005da6:	fa442703          	lw	a4,-92(s0)
    80005daa:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005dae:	0712                	slli	a4,a4,0x4
    80005db0:	963a                	add	a2,a2,a4
    80005db2:	05898813          	addi	a6,s3,88
    80005db6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005dba:	0007b883          	ld	a7,0(a5)
    80005dbe:	9746                	add	a4,a4,a7
    80005dc0:	40000613          	li	a2,1024
    80005dc4:	c710                	sw	a2,8(a4)
  if(write)
    80005dc6:	001b3613          	seqz	a2,s6
    80005dca:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005dce:	8e4d                	or	a2,a2,a1
    80005dd0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005dd4:	fa842603          	lw	a2,-88(s0)
    80005dd8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005ddc:	00451813          	slli	a6,a0,0x4
    80005de0:	02080813          	addi	a6,a6,32
    80005de4:	983e                	add	a6,a6,a5
    80005de6:	577d                	li	a4,-1
    80005de8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005dec:	0612                	slli	a2,a2,0x4
    80005dee:	98b2                	add	a7,a7,a2
    80005df0:	03068713          	addi	a4,a3,48
    80005df4:	973e                	add	a4,a4,a5
    80005df6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005dfa:	6398                	ld	a4,0(a5)
    80005dfc:	9732                	add	a4,a4,a2
    80005dfe:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005e00:	4689                	li	a3,2
    80005e02:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005e06:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005e0a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005e0e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005e12:	6794                	ld	a3,8(a5)
    80005e14:	0026d703          	lhu	a4,2(a3)
    80005e18:	8b1d                	andi	a4,a4,7
    80005e1a:	0706                	slli	a4,a4,0x1
    80005e1c:	96ba                	add	a3,a3,a4
    80005e1e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005e22:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e26:	6798                	ld	a4,8(a5)
    80005e28:	00275783          	lhu	a5,2(a4)
    80005e2c:	2785                	addiw	a5,a5,1
    80005e2e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005e32:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e36:	100017b7          	lui	a5,0x10001
    80005e3a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005e3e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005e42:	0001b917          	auipc	s2,0x1b
    80005e46:	6ae90913          	addi	s2,s2,1710 # 800214f0 <disk+0x128>
  while(b->disk == 1) {
    80005e4a:	84ae                	mv	s1,a1
    80005e4c:	00b79a63          	bne	a5,a1,80005e60 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005e50:	85ca                	mv	a1,s2
    80005e52:	854e                	mv	a0,s3
    80005e54:	9dcfc0ef          	jal	80002030 <sleep>
  while(b->disk == 1) {
    80005e58:	0049a783          	lw	a5,4(s3)
    80005e5c:	fe978ae3          	beq	a5,s1,80005e50 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005e60:	fa042903          	lw	s2,-96(s0)
    80005e64:	00491713          	slli	a4,s2,0x4
    80005e68:	02070713          	addi	a4,a4,32
    80005e6c:	0001b797          	auipc	a5,0x1b
    80005e70:	55c78793          	addi	a5,a5,1372 # 800213c8 <disk>
    80005e74:	97ba                	add	a5,a5,a4
    80005e76:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005e7a:	0001b997          	auipc	s3,0x1b
    80005e7e:	54e98993          	addi	s3,s3,1358 # 800213c8 <disk>
    80005e82:	00491713          	slli	a4,s2,0x4
    80005e86:	0009b783          	ld	a5,0(s3)
    80005e8a:	97ba                	add	a5,a5,a4
    80005e8c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005e90:	854a                	mv	a0,s2
    80005e92:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005e96:	bddff0ef          	jal	80005a72 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005e9a:	8885                	andi	s1,s1,1
    80005e9c:	f0fd                	bnez	s1,80005e82 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005e9e:	0001b517          	auipc	a0,0x1b
    80005ea2:	65250513          	addi	a0,a0,1618 # 800214f0 <disk+0x128>
    80005ea6:	e59fa0ef          	jal	80000cfe <release>
}
    80005eaa:	60e6                	ld	ra,88(sp)
    80005eac:	6446                	ld	s0,80(sp)
    80005eae:	64a6                	ld	s1,72(sp)
    80005eb0:	6906                	ld	s2,64(sp)
    80005eb2:	79e2                	ld	s3,56(sp)
    80005eb4:	7a42                	ld	s4,48(sp)
    80005eb6:	7aa2                	ld	s5,40(sp)
    80005eb8:	7b02                	ld	s6,32(sp)
    80005eba:	6be2                	ld	s7,24(sp)
    80005ebc:	6c42                	ld	s8,16(sp)
    80005ebe:	6125                	addi	sp,sp,96
    80005ec0:	8082                	ret

0000000080005ec2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ec2:	1101                	addi	sp,sp,-32
    80005ec4:	ec06                	sd	ra,24(sp)
    80005ec6:	e822                	sd	s0,16(sp)
    80005ec8:	e426                	sd	s1,8(sp)
    80005eca:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005ecc:	0001b497          	auipc	s1,0x1b
    80005ed0:	4fc48493          	addi	s1,s1,1276 # 800213c8 <disk>
    80005ed4:	0001b517          	auipc	a0,0x1b
    80005ed8:	61c50513          	addi	a0,a0,1564 # 800214f0 <disk+0x128>
    80005edc:	d8ffa0ef          	jal	80000c6a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ee0:	100017b7          	lui	a5,0x10001
    80005ee4:	53bc                	lw	a5,96(a5)
    80005ee6:	8b8d                	andi	a5,a5,3
    80005ee8:	10001737          	lui	a4,0x10001
    80005eec:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005eee:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005ef2:	689c                	ld	a5,16(s1)
    80005ef4:	0204d703          	lhu	a4,32(s1)
    80005ef8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005efc:	04f70863          	beq	a4,a5,80005f4c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005f00:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005f04:	6898                	ld	a4,16(s1)
    80005f06:	0204d783          	lhu	a5,32(s1)
    80005f0a:	8b9d                	andi	a5,a5,7
    80005f0c:	078e                	slli	a5,a5,0x3
    80005f0e:	97ba                	add	a5,a5,a4
    80005f10:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005f12:	00479713          	slli	a4,a5,0x4
    80005f16:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005f1a:	9726                	add	a4,a4,s1
    80005f1c:	01074703          	lbu	a4,16(a4)
    80005f20:	e329                	bnez	a4,80005f62 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f22:	0792                	slli	a5,a5,0x4
    80005f24:	02078793          	addi	a5,a5,32
    80005f28:	97a6                	add	a5,a5,s1
    80005f2a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005f2c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f30:	94cfc0ef          	jal	8000207c <wakeup>

    disk.used_idx += 1;
    80005f34:	0204d783          	lhu	a5,32(s1)
    80005f38:	2785                	addiw	a5,a5,1
    80005f3a:	17c2                	slli	a5,a5,0x30
    80005f3c:	93c1                	srli	a5,a5,0x30
    80005f3e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005f42:	6898                	ld	a4,16(s1)
    80005f44:	00275703          	lhu	a4,2(a4)
    80005f48:	faf71ce3          	bne	a4,a5,80005f00 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005f4c:	0001b517          	auipc	a0,0x1b
    80005f50:	5a450513          	addi	a0,a0,1444 # 800214f0 <disk+0x128>
    80005f54:	dabfa0ef          	jal	80000cfe <release>
}
    80005f58:	60e2                	ld	ra,24(sp)
    80005f5a:	6442                	ld	s0,16(sp)
    80005f5c:	64a2                	ld	s1,8(sp)
    80005f5e:	6105                	addi	sp,sp,32
    80005f60:	8082                	ret
      panic("virtio_disk_intr status");
    80005f62:	00002517          	auipc	a0,0x2
    80005f66:	83650513          	addi	a0,a0,-1994 # 80007798 <etext+0x798>
    80005f6a:	8bbfa0ef          	jal	80000824 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
