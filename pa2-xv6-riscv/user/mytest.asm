
user/_mytest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/stat.h"

int main()
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
	int pid = 0;
	int i;

	ps(0);
   a:	4501                	li	a0,0
   c:	3de000ef          	jal	3ea <ps>
	printf("\n");
  10:	00001517          	auipc	a0,0x1
  14:	96050513          	addi	a0,a0,-1696 # 970 <malloc+0xf8>
  18:	7a8000ef          	jal	7c0 <printf>

	for (i = 0; i < 2; i++)
	{
		pid = fork();
  1c:	316000ef          	jal	332 <fork>

		if (pid < 0)
  20:	02054563          	bltz	a0,4a <main+0x4a>
  24:	84aa                	mv	s1,a0
		{
			printf("forked failed");
			exit(1);
		}

		if (pid == 0) // 자식 프로세스
  26:	cd05                	beqz	a0,5e <main+0x5e>
		pid = fork();
  28:	30a000ef          	jal	332 <fork>
		if (pid < 0)
  2c:	00054f63          	bltz	a0,4a <main+0x4a>
		if (pid == 0) // 자식 프로세스
  30:	c515                	beqz	a0,5c <main+0x5c>
			exit(0); // 종료 status가 0 == 정상 종료

		} 
	}

	ps(0);
  32:	4501                	li	a0,0
  34:	3b6000ef          	jal	3ea <ps>

	for (i = 0; i < 2; i++)
	{
		wait(0);
  38:	4501                	li	a0,0
  3a:	308000ef          	jal	342 <wait>
  3e:	4501                	li	a0,0
  40:	302000ef          	jal	342 <wait>
	}

	exit(0);
  44:	4501                	li	a0,0
  46:	2f4000ef          	jal	33a <exit>
			printf("forked failed");
  4a:	00001517          	auipc	a0,0x1
  4e:	92e50513          	addi	a0,a0,-1746 # 978 <malloc+0x100>
  52:	76e000ef          	jal	7c0 <printf>
			exit(1);
  56:	4505                	li	a0,1
  58:	2e2000ef          	jal	33a <exit>
  5c:	4485                	li	s1,1
			setnice(getpid(), i*10);
  5e:	35c000ef          	jal	3ba <getpid>
  62:	409005bb          	negw	a1,s1
  66:	89a9                	andi	a1,a1,10
  68:	37a000ef          	jal	3e2 <setnice>
			ps(0);
  6c:	4501                	li	a0,0
  6e:	37c000ef          	jal	3ea <ps>
			printf("The process successfully determinated.\n");
  72:	00001517          	auipc	a0,0x1
  76:	91650513          	addi	a0,a0,-1770 # 988 <malloc+0x110>
  7a:	746000ef          	jal	7c0 <printf>
			exit(0); // 종료 status가 0 == 정상 종료
  7e:	4501                	li	a0,0
  80:	2ba000ef          	jal	33a <exit>

0000000000000084 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  84:	1141                	addi	sp,sp,-16
  86:	e406                	sd	ra,8(sp)
  88:	e022                	sd	s0,0(sp)
  8a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  8c:	f75ff0ef          	jal	0 <main>
  exit(r);
  90:	2aa000ef          	jal	33a <exit>

0000000000000094 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  94:	1141                	addi	sp,sp,-16
  96:	e406                	sd	ra,8(sp)
  98:	e022                	sd	s0,0(sp)
  9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9c:	87aa                	mv	a5,a0
  9e:	0585                	addi	a1,a1,1
  a0:	0785                	addi	a5,a5,1
  a2:	fff5c703          	lbu	a4,-1(a1)
  a6:	fee78fa3          	sb	a4,-1(a5)
  aa:	fb75                	bnez	a4,9e <strcpy+0xa>
    ;
  return os;
}
  ac:	60a2                	ld	ra,8(sp)
  ae:	6402                	ld	s0,0(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret

00000000000000b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e406                	sd	ra,8(sp)
  b8:	e022                	sd	s0,0(sp)
  ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	cb91                	beqz	a5,d4 <strcmp+0x20>
  c2:	0005c703          	lbu	a4,0(a1)
  c6:	00f71763          	bne	a4,a5,d4 <strcmp+0x20>
    p++, q++;
  ca:	0505                	addi	a0,a0,1
  cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	fbe5                	bnez	a5,c2 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  d4:	0005c503          	lbu	a0,0(a1)
}
  d8:	40a7853b          	subw	a0,a5,a0
  dc:	60a2                	ld	ra,8(sp)
  de:	6402                	ld	s0,0(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strlen>:

uint
strlen(const char *s)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cf91                	beqz	a5,10c <strlen+0x28>
  f2:	00150793          	addi	a5,a0,1
  f6:	86be                	mv	a3,a5
  f8:	0785                	addi	a5,a5,1
  fa:	fff7c703          	lbu	a4,-1(a5)
  fe:	ff65                	bnez	a4,f6 <strlen+0x12>
 100:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 104:	60a2                	ld	ra,8(sp)
 106:	6402                	ld	s0,0(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret
  for(n = 0; s[n]; n++)
 10c:	4501                	li	a0,0
 10e:	bfdd                	j	104 <strlen+0x20>

0000000000000110 <memset>:

void*
memset(void *dst, int c, uint n)
{
 110:	1141                	addi	sp,sp,-16
 112:	e406                	sd	ra,8(sp)
 114:	e022                	sd	s0,0(sp)
 116:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 118:	ca19                	beqz	a2,12e <memset+0x1e>
 11a:	87aa                	mv	a5,a0
 11c:	1602                	slli	a2,a2,0x20
 11e:	9201                	srli	a2,a2,0x20
 120:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 124:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 128:	0785                	addi	a5,a5,1
 12a:	fee79de3          	bne	a5,a4,124 <memset+0x14>
  }
  return dst;
}
 12e:	60a2                	ld	ra,8(sp)
 130:	6402                	ld	s0,0(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strchr>:

char*
strchr(const char *s, char c)
{
 136:	1141                	addi	sp,sp,-16
 138:	e406                	sd	ra,8(sp)
 13a:	e022                	sd	s0,0(sp)
 13c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13e:	00054783          	lbu	a5,0(a0)
 142:	cf81                	beqz	a5,15a <strchr+0x24>
    if(*s == c)
 144:	00f58763          	beq	a1,a5,152 <strchr+0x1c>
  for(; *s; s++)
 148:	0505                	addi	a0,a0,1
 14a:	00054783          	lbu	a5,0(a0)
 14e:	fbfd                	bnez	a5,144 <strchr+0xe>
      return (char*)s;
  return 0;
 150:	4501                	li	a0,0
}
 152:	60a2                	ld	ra,8(sp)
 154:	6402                	ld	s0,0(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret
  return 0;
 15a:	4501                	li	a0,0
 15c:	bfdd                	j	152 <strchr+0x1c>

000000000000015e <gets>:

char*
gets(char *buf, int max)
{
 15e:	711d                	addi	sp,sp,-96
 160:	ec86                	sd	ra,88(sp)
 162:	e8a2                	sd	s0,80(sp)
 164:	e4a6                	sd	s1,72(sp)
 166:	e0ca                	sd	s2,64(sp)
 168:	fc4e                	sd	s3,56(sp)
 16a:	f852                	sd	s4,48(sp)
 16c:	f456                	sd	s5,40(sp)
 16e:	f05a                	sd	s6,32(sp)
 170:	ec5e                	sd	s7,24(sp)
 172:	e862                	sd	s8,16(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 17e:	faf40b13          	addi	s6,s0,-81
 182:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 184:	8c26                	mv	s8,s1
 186:	0014899b          	addiw	s3,s1,1
 18a:	84ce                	mv	s1,s3
 18c:	0349d463          	bge	s3,s4,1b4 <gets+0x56>
    cc = read(0, &c, 1);
 190:	8656                	mv	a2,s5
 192:	85da                	mv	a1,s6
 194:	4501                	li	a0,0
 196:	1bc000ef          	jal	352 <read>
    if(cc < 1)
 19a:	00a05d63          	blez	a0,1b4 <gets+0x56>
      break;
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	0905                	addi	s2,s2,1
 1a8:	ff678713          	addi	a4,a5,-10
 1ac:	c319                	beqz	a4,1b2 <gets+0x54>
 1ae:	17cd                	addi	a5,a5,-13
 1b0:	fbf1                	bnez	a5,184 <gets+0x26>
    buf[i++] = c;
 1b2:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1b4:	9c5e                	add	s8,s8,s7
 1b6:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1ba:	855e                	mv	a0,s7
 1bc:	60e6                	ld	ra,88(sp)
 1be:	6446                	ld	s0,80(sp)
 1c0:	64a6                	ld	s1,72(sp)
 1c2:	6906                	ld	s2,64(sp)
 1c4:	79e2                	ld	s3,56(sp)
 1c6:	7a42                	ld	s4,48(sp)
 1c8:	7aa2                	ld	s5,40(sp)
 1ca:	7b02                	ld	s6,32(sp)
 1cc:	6be2                	ld	s7,24(sp)
 1ce:	6c42                	ld	s8,16(sp)
 1d0:	6125                	addi	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d4:	1101                	addi	sp,sp,-32
 1d6:	ec06                	sd	ra,24(sp)
 1d8:	e822                	sd	s0,16(sp)
 1da:	e04a                	sd	s2,0(sp)
 1dc:	1000                	addi	s0,sp,32
 1de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e0:	4581                	li	a1,0
 1e2:	198000ef          	jal	37a <open>
  if(fd < 0)
 1e6:	02054263          	bltz	a0,20a <stat+0x36>
 1ea:	e426                	sd	s1,8(sp)
 1ec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ee:	85ca                	mv	a1,s2
 1f0:	1a2000ef          	jal	392 <fstat>
 1f4:	892a                	mv	s2,a0
  close(fd);
 1f6:	8526                	mv	a0,s1
 1f8:	16a000ef          	jal	362 <close>
  return r;
 1fc:	64a2                	ld	s1,8(sp)
}
 1fe:	854a                	mv	a0,s2
 200:	60e2                	ld	ra,24(sp)
 202:	6442                	ld	s0,16(sp)
 204:	6902                	ld	s2,0(sp)
 206:	6105                	addi	sp,sp,32
 208:	8082                	ret
    return -1;
 20a:	57fd                	li	a5,-1
 20c:	893e                	mv	s2,a5
 20e:	bfc5                	j	1fe <stat+0x2a>

0000000000000210 <atoi>:

int
atoi(const char *s)
{
 210:	1141                	addi	sp,sp,-16
 212:	e406                	sd	ra,8(sp)
 214:	e022                	sd	s0,0(sp)
 216:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 218:	00054683          	lbu	a3,0(a0)
 21c:	fd06879b          	addiw	a5,a3,-48
 220:	0ff7f793          	zext.b	a5,a5
 224:	4625                	li	a2,9
 226:	02f66963          	bltu	a2,a5,258 <atoi+0x48>
 22a:	872a                	mv	a4,a0
  n = 0;
 22c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 22e:	0705                	addi	a4,a4,1
 230:	0025179b          	slliw	a5,a0,0x2
 234:	9fa9                	addw	a5,a5,a0
 236:	0017979b          	slliw	a5,a5,0x1
 23a:	9fb5                	addw	a5,a5,a3
 23c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 240:	00074683          	lbu	a3,0(a4)
 244:	fd06879b          	addiw	a5,a3,-48
 248:	0ff7f793          	zext.b	a5,a5
 24c:	fef671e3          	bgeu	a2,a5,22e <atoi+0x1e>
  return n;
}
 250:	60a2                	ld	ra,8(sp)
 252:	6402                	ld	s0,0(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  n = 0;
 258:	4501                	li	a0,0
 25a:	bfdd                	j	250 <atoi+0x40>

000000000000025c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e406                	sd	ra,8(sp)
 260:	e022                	sd	s0,0(sp)
 262:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 264:	02b57563          	bgeu	a0,a1,28e <memmove+0x32>
    while(n-- > 0)
 268:	00c05f63          	blez	a2,286 <memmove+0x2a>
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 274:	872a                	mv	a4,a0
      *dst++ = *src++;
 276:	0585                	addi	a1,a1,1
 278:	0705                	addi	a4,a4,1
 27a:	fff5c683          	lbu	a3,-1(a1)
 27e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 282:	fee79ae3          	bne	a5,a4,276 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 286:	60a2                	ld	ra,8(sp)
 288:	6402                	ld	s0,0(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
    while(n-- > 0)
 28e:	fec05ce3          	blez	a2,286 <memmove+0x2a>
    dst += n;
 292:	00c50733          	add	a4,a0,a2
    src += n;
 296:	95b2                	add	a1,a1,a2
 298:	fff6079b          	addiw	a5,a2,-1
 29c:	1782                	slli	a5,a5,0x20
 29e:	9381                	srli	a5,a5,0x20
 2a0:	fff7c793          	not	a5,a5
 2a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a6:	15fd                	addi	a1,a1,-1
 2a8:	177d                	addi	a4,a4,-1
 2aa:	0005c683          	lbu	a3,0(a1)
 2ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b2:	fef71ae3          	bne	a4,a5,2a6 <memmove+0x4a>
 2b6:	bfc1                	j	286 <memmove+0x2a>

00000000000002b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e406                	sd	ra,8(sp)
 2bc:	e022                	sd	s0,0(sp)
 2be:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c0:	c61d                	beqz	a2,2ee <memcmp+0x36>
 2c2:	1602                	slli	a2,a2,0x20
 2c4:	9201                	srli	a2,a2,0x20
 2c6:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	0005c703          	lbu	a4,0(a1)
 2d2:	00e79863          	bne	a5,a4,2e2 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2d6:	0505                	addi	a0,a0,1
    p2++;
 2d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2da:	fed518e3          	bne	a0,a3,2ca <memcmp+0x12>
  }
  return 0;
 2de:	4501                	li	a0,0
 2e0:	a019                	j	2e6 <memcmp+0x2e>
      return *p1 - *p2;
 2e2:	40e7853b          	subw	a0,a5,a4
}
 2e6:	60a2                	ld	ra,8(sp)
 2e8:	6402                	ld	s0,0(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret
  return 0;
 2ee:	4501                	li	a0,0
 2f0:	bfdd                	j	2e6 <memcmp+0x2e>

00000000000002f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e406                	sd	ra,8(sp)
 2f6:	e022                	sd	s0,0(sp)
 2f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fa:	f63ff0ef          	jal	25c <memmove>
}
 2fe:	60a2                	ld	ra,8(sp)
 300:	6402                	ld	s0,0(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret

0000000000000306 <sbrk>:

char *
sbrk(int n) {
 306:	1141                	addi	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 30e:	4585                	li	a1,1
 310:	0b2000ef          	jal	3c2 <sys_sbrk>
}
 314:	60a2                	ld	ra,8(sp)
 316:	6402                	ld	s0,0(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <sbrklazy>:

char *
sbrklazy(int n) {
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 324:	4589                	li	a1,2
 326:	09c000ef          	jal	3c2 <sys_sbrk>
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 332:	4885                	li	a7,1
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <exit>:
.global exit
exit:
 li a7, SYS_exit
 33a:	4889                	li	a7,2
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <wait>:
.global wait
wait:
 li a7, SYS_wait
 342:	488d                	li	a7,3
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34a:	4891                	li	a7,4
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <read>:
.global read
read:
 li a7, SYS_read
 352:	4895                	li	a7,5
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <write>:
.global write
write:
 li a7, SYS_write
 35a:	48c1                	li	a7,16
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <close>:
.global close
close:
 li a7, SYS_close
 362:	48d5                	li	a7,21
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <kill>:
.global kill
kill:
 li a7, SYS_kill
 36a:	4899                	li	a7,6
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <exec>:
.global exec
exec:
 li a7, SYS_exec
 372:	489d                	li	a7,7
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <open>:
.global open
open:
 li a7, SYS_open
 37a:	48bd                	li	a7,15
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 382:	48c5                	li	a7,17
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38a:	48c9                	li	a7,18
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 392:	48a1                	li	a7,8
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <link>:
.global link
link:
 li a7, SYS_link
 39a:	48cd                	li	a7,19
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a2:	48d1                	li	a7,20
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3aa:	48a5                	li	a7,9
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b2:	48a9                	li	a7,10
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ba:	48ad                	li	a7,11
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3c2:	48b1                	li	a7,12
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ca:	48b5                	li	a7,13
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d2:	48b9                	li	a7,14
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <getnice>:
.global getnice
getnice:
 li a7, SYS_getnice
 3da:	48d9                	li	a7,22
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <setnice>:
.global setnice
setnice:
 li a7, SYS_setnice
 3e2:	48dd                	li	a7,23
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <ps>:
.global ps
ps:
 li a7, SYS_ps
 3ea:	48e1                	li	a7,24
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <meminfo>:
.global meminfo
meminfo:
 li a7, SYS_meminfo
 3f2:	48e5                	li	a7,25
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3fa:	48e9                	li	a7,26
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 402:	48ed                	li	a7,27
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 40a:	48f1                	li	a7,28
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <freemem>:
.global freemem
freemem:
 li a7, SYS_freemem
 412:	48f5                	li	a7,29
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 41a:	1101                	addi	sp,sp,-32
 41c:	ec06                	sd	ra,24(sp)
 41e:	e822                	sd	s0,16(sp)
 420:	1000                	addi	s0,sp,32
 422:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 426:	4605                	li	a2,1
 428:	fef40593          	addi	a1,s0,-17
 42c:	f2fff0ef          	jal	35a <write>
}
 430:	60e2                	ld	ra,24(sp)
 432:	6442                	ld	s0,16(sp)
 434:	6105                	addi	sp,sp,32
 436:	8082                	ret

0000000000000438 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 438:	715d                	addi	sp,sp,-80
 43a:	e486                	sd	ra,72(sp)
 43c:	e0a2                	sd	s0,64(sp)
 43e:	f84a                	sd	s2,48(sp)
 440:	f44e                	sd	s3,40(sp)
 442:	0880                	addi	s0,sp,80
 444:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 446:	c6d1                	beqz	a3,4d2 <printint+0x9a>
 448:	0805d563          	bgez	a1,4d2 <printint+0x9a>
    neg = 1;
    x = -xx;
 44c:	40b005b3          	neg	a1,a1
    neg = 1;
 450:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 452:	fb840993          	addi	s3,s0,-72
  neg = 0;
 456:	86ce                	mv	a3,s3
  i = 0;
 458:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 45a:	00000817          	auipc	a6,0x0
 45e:	55e80813          	addi	a6,a6,1374 # 9b8 <digits>
 462:	88ba                	mv	a7,a4
 464:	0017051b          	addiw	a0,a4,1
 468:	872a                	mv	a4,a0
 46a:	02c5f7b3          	remu	a5,a1,a2
 46e:	97c2                	add	a5,a5,a6
 470:	0007c783          	lbu	a5,0(a5)
 474:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 478:	87ae                	mv	a5,a1
 47a:	02c5d5b3          	divu	a1,a1,a2
 47e:	0685                	addi	a3,a3,1
 480:	fec7f1e3          	bgeu	a5,a2,462 <printint+0x2a>
  if(neg)
 484:	00030c63          	beqz	t1,49c <printint+0x64>
    buf[i++] = '-';
 488:	fd050793          	addi	a5,a0,-48
 48c:	00878533          	add	a0,a5,s0
 490:	02d00793          	li	a5,45
 494:	fef50423          	sb	a5,-24(a0)
 498:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 49c:	02e05563          	blez	a4,4c6 <printint+0x8e>
 4a0:	fc26                	sd	s1,56(sp)
 4a2:	377d                	addiw	a4,a4,-1
 4a4:	00e984b3          	add	s1,s3,a4
 4a8:	19fd                	addi	s3,s3,-1
 4aa:	99ba                	add	s3,s3,a4
 4ac:	1702                	slli	a4,a4,0x20
 4ae:	9301                	srli	a4,a4,0x20
 4b0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b4:	0004c583          	lbu	a1,0(s1)
 4b8:	854a                	mv	a0,s2
 4ba:	f61ff0ef          	jal	41a <putc>
  while(--i >= 0)
 4be:	14fd                	addi	s1,s1,-1
 4c0:	ff349ae3          	bne	s1,s3,4b4 <printint+0x7c>
 4c4:	74e2                	ld	s1,56(sp)
}
 4c6:	60a6                	ld	ra,72(sp)
 4c8:	6406                	ld	s0,64(sp)
 4ca:	7942                	ld	s2,48(sp)
 4cc:	79a2                	ld	s3,40(sp)
 4ce:	6161                	addi	sp,sp,80
 4d0:	8082                	ret
  neg = 0;
 4d2:	4301                	li	t1,0
 4d4:	bfbd                	j	452 <printint+0x1a>

00000000000004d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d6:	711d                	addi	sp,sp,-96
 4d8:	ec86                	sd	ra,88(sp)
 4da:	e8a2                	sd	s0,80(sp)
 4dc:	e4a6                	sd	s1,72(sp)
 4de:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e0:	0005c483          	lbu	s1,0(a1)
 4e4:	22048363          	beqz	s1,70a <vprintf+0x234>
 4e8:	e0ca                	sd	s2,64(sp)
 4ea:	fc4e                	sd	s3,56(sp)
 4ec:	f852                	sd	s4,48(sp)
 4ee:	f456                	sd	s5,40(sp)
 4f0:	f05a                	sd	s6,32(sp)
 4f2:	ec5e                	sd	s7,24(sp)
 4f4:	e862                	sd	s8,16(sp)
 4f6:	8b2a                	mv	s6,a0
 4f8:	8a2e                	mv	s4,a1
 4fa:	8bb2                	mv	s7,a2
  state = 0;
 4fc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4fe:	4901                	li	s2,0
 500:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 502:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 506:	06400c13          	li	s8,100
 50a:	a00d                	j	52c <vprintf+0x56>
        putc(fd, c0);
 50c:	85a6                	mv	a1,s1
 50e:	855a                	mv	a0,s6
 510:	f0bff0ef          	jal	41a <putc>
 514:	a019                	j	51a <vprintf+0x44>
    } else if(state == '%'){
 516:	03598363          	beq	s3,s5,53c <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 51a:	0019079b          	addiw	a5,s2,1
 51e:	893e                	mv	s2,a5
 520:	873e                	mv	a4,a5
 522:	97d2                	add	a5,a5,s4
 524:	0007c483          	lbu	s1,0(a5)
 528:	1c048a63          	beqz	s1,6fc <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 52c:	0004879b          	sext.w	a5,s1
    if(state == 0){
 530:	fe0993e3          	bnez	s3,516 <vprintf+0x40>
      if(c0 == '%'){
 534:	fd579ce3          	bne	a5,s5,50c <vprintf+0x36>
        state = '%';
 538:	89be                	mv	s3,a5
 53a:	b7c5                	j	51a <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 53c:	00ea06b3          	add	a3,s4,a4
 540:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 544:	1c060863          	beqz	a2,714 <vprintf+0x23e>
      if(c0 == 'd'){
 548:	03878763          	beq	a5,s8,576 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 54c:	f9478693          	addi	a3,a5,-108
 550:	0016b693          	seqz	a3,a3
 554:	f9c60593          	addi	a1,a2,-100
 558:	e99d                	bnez	a1,58e <vprintf+0xb8>
 55a:	ca95                	beqz	a3,58e <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 55c:	008b8493          	addi	s1,s7,8
 560:	4685                	li	a3,1
 562:	4629                	li	a2,10
 564:	000bb583          	ld	a1,0(s7)
 568:	855a                	mv	a0,s6
 56a:	ecfff0ef          	jal	438 <printint>
        i += 1;
 56e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 570:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 572:	4981                	li	s3,0
 574:	b75d                	j	51a <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 576:	008b8493          	addi	s1,s7,8
 57a:	4685                	li	a3,1
 57c:	4629                	li	a2,10
 57e:	000ba583          	lw	a1,0(s7)
 582:	855a                	mv	a0,s6
 584:	eb5ff0ef          	jal	438 <printint>
 588:	8ba6                	mv	s7,s1
      state = 0;
 58a:	4981                	li	s3,0
 58c:	b779                	j	51a <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 58e:	9752                	add	a4,a4,s4
 590:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 594:	f9460713          	addi	a4,a2,-108
 598:	00173713          	seqz	a4,a4
 59c:	8f75                	and	a4,a4,a3
 59e:	f9c58513          	addi	a0,a1,-100
 5a2:	18051363          	bnez	a0,728 <vprintf+0x252>
 5a6:	18070163          	beqz	a4,728 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5aa:	008b8493          	addi	s1,s7,8
 5ae:	4685                	li	a3,1
 5b0:	4629                	li	a2,10
 5b2:	000bb583          	ld	a1,0(s7)
 5b6:	855a                	mv	a0,s6
 5b8:	e81ff0ef          	jal	438 <printint>
        i += 2;
 5bc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5be:	8ba6                	mv	s7,s1
      state = 0;
 5c0:	4981                	li	s3,0
        i += 2;
 5c2:	bfa1                	j	51a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5c4:	008b8493          	addi	s1,s7,8
 5c8:	4681                	li	a3,0
 5ca:	4629                	li	a2,10
 5cc:	000be583          	lwu	a1,0(s7)
 5d0:	855a                	mv	a0,s6
 5d2:	e67ff0ef          	jal	438 <printint>
 5d6:	8ba6                	mv	s7,s1
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	b781                	j	51a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5dc:	008b8493          	addi	s1,s7,8
 5e0:	4681                	li	a3,0
 5e2:	4629                	li	a2,10
 5e4:	000bb583          	ld	a1,0(s7)
 5e8:	855a                	mv	a0,s6
 5ea:	e4fff0ef          	jal	438 <printint>
        i += 1;
 5ee:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f0:	8ba6                	mv	s7,s1
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b71d                	j	51a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f6:	008b8493          	addi	s1,s7,8
 5fa:	4681                	li	a3,0
 5fc:	4629                	li	a2,10
 5fe:	000bb583          	ld	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	e35ff0ef          	jal	438 <printint>
        i += 2;
 608:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 60a:	8ba6                	mv	s7,s1
      state = 0;
 60c:	4981                	li	s3,0
        i += 2;
 60e:	b731                	j	51a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 610:	008b8493          	addi	s1,s7,8
 614:	4681                	li	a3,0
 616:	4641                	li	a2,16
 618:	000be583          	lwu	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	e1bff0ef          	jal	438 <printint>
 622:	8ba6                	mv	s7,s1
      state = 0;
 624:	4981                	li	s3,0
 626:	bdd5                	j	51a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 628:	008b8493          	addi	s1,s7,8
 62c:	4681                	li	a3,0
 62e:	4641                	li	a2,16
 630:	000bb583          	ld	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	e03ff0ef          	jal	438 <printint>
        i += 1;
 63a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 63c:	8ba6                	mv	s7,s1
      state = 0;
 63e:	4981                	li	s3,0
 640:	bde9                	j	51a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 642:	008b8493          	addi	s1,s7,8
 646:	4681                	li	a3,0
 648:	4641                	li	a2,16
 64a:	000bb583          	ld	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	de9ff0ef          	jal	438 <printint>
        i += 2;
 654:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 656:	8ba6                	mv	s7,s1
      state = 0;
 658:	4981                	li	s3,0
        i += 2;
 65a:	b5c1                	j	51a <vprintf+0x44>
 65c:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 65e:	008b8793          	addi	a5,s7,8
 662:	8cbe                	mv	s9,a5
 664:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 668:	03000593          	li	a1,48
 66c:	855a                	mv	a0,s6
 66e:	dadff0ef          	jal	41a <putc>
  putc(fd, 'x');
 672:	07800593          	li	a1,120
 676:	855a                	mv	a0,s6
 678:	da3ff0ef          	jal	41a <putc>
 67c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67e:	00000b97          	auipc	s7,0x0
 682:	33ab8b93          	addi	s7,s7,826 # 9b8 <digits>
 686:	03c9d793          	srli	a5,s3,0x3c
 68a:	97de                	add	a5,a5,s7
 68c:	0007c583          	lbu	a1,0(a5)
 690:	855a                	mv	a0,s6
 692:	d89ff0ef          	jal	41a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 696:	0992                	slli	s3,s3,0x4
 698:	34fd                	addiw	s1,s1,-1
 69a:	f4f5                	bnez	s1,686 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 69c:	8be6                	mv	s7,s9
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	6ca2                	ld	s9,8(sp)
 6a2:	bda5                	j	51a <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6a4:	008b8493          	addi	s1,s7,8
 6a8:	000bc583          	lbu	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	d6dff0ef          	jal	41a <putc>
 6b2:	8ba6                	mv	s7,s1
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b595                	j	51a <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6b8:	008b8993          	addi	s3,s7,8
 6bc:	000bb483          	ld	s1,0(s7)
 6c0:	cc91                	beqz	s1,6dc <vprintf+0x206>
        for(; *s; s++)
 6c2:	0004c583          	lbu	a1,0(s1)
 6c6:	c985                	beqz	a1,6f6 <vprintf+0x220>
          putc(fd, *s);
 6c8:	855a                	mv	a0,s6
 6ca:	d51ff0ef          	jal	41a <putc>
        for(; *s; s++)
 6ce:	0485                	addi	s1,s1,1
 6d0:	0004c583          	lbu	a1,0(s1)
 6d4:	f9f5                	bnez	a1,6c8 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6d6:	8bce                	mv	s7,s3
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	b581                	j	51a <vprintf+0x44>
          s = "(null)";
 6dc:	00000497          	auipc	s1,0x0
 6e0:	2d448493          	addi	s1,s1,724 # 9b0 <malloc+0x138>
        for(; *s; s++)
 6e4:	02800593          	li	a1,40
 6e8:	b7c5                	j	6c8 <vprintf+0x1f2>
        putc(fd, '%');
 6ea:	85be                	mv	a1,a5
 6ec:	855a                	mv	a0,s6
 6ee:	d2dff0ef          	jal	41a <putc>
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	b51d                	j	51a <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6f6:	8bce                	mv	s7,s3
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b505                	j	51a <vprintf+0x44>
 6fc:	6906                	ld	s2,64(sp)
 6fe:	79e2                	ld	s3,56(sp)
 700:	7a42                	ld	s4,48(sp)
 702:	7aa2                	ld	s5,40(sp)
 704:	7b02                	ld	s6,32(sp)
 706:	6be2                	ld	s7,24(sp)
 708:	6c42                	ld	s8,16(sp)
    }
  }
}
 70a:	60e6                	ld	ra,88(sp)
 70c:	6446                	ld	s0,80(sp)
 70e:	64a6                	ld	s1,72(sp)
 710:	6125                	addi	sp,sp,96
 712:	8082                	ret
      if(c0 == 'd'){
 714:	06400713          	li	a4,100
 718:	e4e78fe3          	beq	a5,a4,576 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 71c:	f9478693          	addi	a3,a5,-108
 720:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 724:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 726:	4701                	li	a4,0
      } else if(c0 == 'u'){
 728:	07500513          	li	a0,117
 72c:	e8a78ce3          	beq	a5,a0,5c4 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 730:	f8b60513          	addi	a0,a2,-117
 734:	e119                	bnez	a0,73a <vprintf+0x264>
 736:	ea0693e3          	bnez	a3,5dc <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 73a:	f8b58513          	addi	a0,a1,-117
 73e:	e119                	bnez	a0,744 <vprintf+0x26e>
 740:	ea071be3          	bnez	a4,5f6 <vprintf+0x120>
      } else if(c0 == 'x'){
 744:	07800513          	li	a0,120
 748:	eca784e3          	beq	a5,a0,610 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 74c:	f8860613          	addi	a2,a2,-120
 750:	e219                	bnez	a2,756 <vprintf+0x280>
 752:	ec069be3          	bnez	a3,628 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 756:	f8858593          	addi	a1,a1,-120
 75a:	e199                	bnez	a1,760 <vprintf+0x28a>
 75c:	ee0713e3          	bnez	a4,642 <vprintf+0x16c>
      } else if(c0 == 'p'){
 760:	07000713          	li	a4,112
 764:	eee78ce3          	beq	a5,a4,65c <vprintf+0x186>
      } else if(c0 == 'c'){
 768:	06300713          	li	a4,99
 76c:	f2e78ce3          	beq	a5,a4,6a4 <vprintf+0x1ce>
      } else if(c0 == 's'){
 770:	07300713          	li	a4,115
 774:	f4e782e3          	beq	a5,a4,6b8 <vprintf+0x1e2>
      } else if(c0 == '%'){
 778:	02500713          	li	a4,37
 77c:	f6e787e3          	beq	a5,a4,6ea <vprintf+0x214>
        putc(fd, '%');
 780:	02500593          	li	a1,37
 784:	855a                	mv	a0,s6
 786:	c95ff0ef          	jal	41a <putc>
        putc(fd, c0);
 78a:	85a6                	mv	a1,s1
 78c:	855a                	mv	a0,s6
 78e:	c8dff0ef          	jal	41a <putc>
      state = 0;
 792:	4981                	li	s3,0
 794:	b359                	j	51a <vprintf+0x44>

0000000000000796 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 796:	715d                	addi	sp,sp,-80
 798:	ec06                	sd	ra,24(sp)
 79a:	e822                	sd	s0,16(sp)
 79c:	1000                	addi	s0,sp,32
 79e:	e010                	sd	a2,0(s0)
 7a0:	e414                	sd	a3,8(s0)
 7a2:	e818                	sd	a4,16(s0)
 7a4:	ec1c                	sd	a5,24(s0)
 7a6:	03043023          	sd	a6,32(s0)
 7aa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ae:	8622                	mv	a2,s0
 7b0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b4:	d23ff0ef          	jal	4d6 <vprintf>
}
 7b8:	60e2                	ld	ra,24(sp)
 7ba:	6442                	ld	s0,16(sp)
 7bc:	6161                	addi	sp,sp,80
 7be:	8082                	ret

00000000000007c0 <printf>:

void
printf(const char *fmt, ...)
{
 7c0:	711d                	addi	sp,sp,-96
 7c2:	ec06                	sd	ra,24(sp)
 7c4:	e822                	sd	s0,16(sp)
 7c6:	1000                	addi	s0,sp,32
 7c8:	e40c                	sd	a1,8(s0)
 7ca:	e810                	sd	a2,16(s0)
 7cc:	ec14                	sd	a3,24(s0)
 7ce:	f018                	sd	a4,32(s0)
 7d0:	f41c                	sd	a5,40(s0)
 7d2:	03043823          	sd	a6,48(s0)
 7d6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7da:	00840613          	addi	a2,s0,8
 7de:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e2:	85aa                	mv	a1,a0
 7e4:	4505                	li	a0,1
 7e6:	cf1ff0ef          	jal	4d6 <vprintf>
}
 7ea:	60e2                	ld	ra,24(sp)
 7ec:	6442                	ld	s0,16(sp)
 7ee:	6125                	addi	sp,sp,96
 7f0:	8082                	ret

00000000000007f2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f2:	1141                	addi	sp,sp,-16
 7f4:	e406                	sd	ra,8(sp)
 7f6:	e022                	sd	s0,0(sp)
 7f8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7fa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fe:	00001797          	auipc	a5,0x1
 802:	8027b783          	ld	a5,-2046(a5) # 1000 <freep>
 806:	a039                	j	814 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 808:	6398                	ld	a4,0(a5)
 80a:	00e7e463          	bltu	a5,a4,812 <free+0x20>
 80e:	00e6ea63          	bltu	a3,a4,822 <free+0x30>
{
 812:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 814:	fed7fae3          	bgeu	a5,a3,808 <free+0x16>
 818:	6398                	ld	a4,0(a5)
 81a:	00e6e463          	bltu	a3,a4,822 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81e:	fee7eae3          	bltu	a5,a4,812 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 822:	ff852583          	lw	a1,-8(a0)
 826:	6390                	ld	a2,0(a5)
 828:	02059813          	slli	a6,a1,0x20
 82c:	01c85713          	srli	a4,a6,0x1c
 830:	9736                	add	a4,a4,a3
 832:	02e60563          	beq	a2,a4,85c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 836:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 83a:	4790                	lw	a2,8(a5)
 83c:	02061593          	slli	a1,a2,0x20
 840:	01c5d713          	srli	a4,a1,0x1c
 844:	973e                	add	a4,a4,a5
 846:	02e68263          	beq	a3,a4,86a <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 84a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 84c:	00000717          	auipc	a4,0x0
 850:	7af73a23          	sd	a5,1972(a4) # 1000 <freep>
}
 854:	60a2                	ld	ra,8(sp)
 856:	6402                	ld	s0,0(sp)
 858:	0141                	addi	sp,sp,16
 85a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 85c:	4618                	lw	a4,8(a2)
 85e:	9f2d                	addw	a4,a4,a1
 860:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 864:	6398                	ld	a4,0(a5)
 866:	6310                	ld	a2,0(a4)
 868:	b7f9                	j	836 <free+0x44>
    p->s.size += bp->s.size;
 86a:	ff852703          	lw	a4,-8(a0)
 86e:	9f31                	addw	a4,a4,a2
 870:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 872:	ff053683          	ld	a3,-16(a0)
 876:	bfd1                	j	84a <free+0x58>

0000000000000878 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 878:	7139                	addi	sp,sp,-64
 87a:	fc06                	sd	ra,56(sp)
 87c:	f822                	sd	s0,48(sp)
 87e:	f04a                	sd	s2,32(sp)
 880:	ec4e                	sd	s3,24(sp)
 882:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 884:	02051993          	slli	s3,a0,0x20
 888:	0209d993          	srli	s3,s3,0x20
 88c:	09bd                	addi	s3,s3,15
 88e:	0049d993          	srli	s3,s3,0x4
 892:	2985                	addiw	s3,s3,1
 894:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 896:	00000517          	auipc	a0,0x0
 89a:	76a53503          	ld	a0,1898(a0) # 1000 <freep>
 89e:	c905                	beqz	a0,8ce <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a2:	4798                	lw	a4,8(a5)
 8a4:	09377663          	bgeu	a4,s3,930 <malloc+0xb8>
 8a8:	f426                	sd	s1,40(sp)
 8aa:	e852                	sd	s4,16(sp)
 8ac:	e456                	sd	s5,8(sp)
 8ae:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8b0:	8a4e                	mv	s4,s3
 8b2:	6705                	lui	a4,0x1
 8b4:	00e9f363          	bgeu	s3,a4,8ba <malloc+0x42>
 8b8:	6a05                	lui	s4,0x1
 8ba:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8be:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c2:	00000497          	auipc	s1,0x0
 8c6:	73e48493          	addi	s1,s1,1854 # 1000 <freep>
  if(p == SBRK_ERROR)
 8ca:	5afd                	li	s5,-1
 8cc:	a83d                	j	90a <malloc+0x92>
 8ce:	f426                	sd	s1,40(sp)
 8d0:	e852                	sd	s4,16(sp)
 8d2:	e456                	sd	s5,8(sp)
 8d4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8d6:	00000797          	auipc	a5,0x0
 8da:	73a78793          	addi	a5,a5,1850 # 1010 <base>
 8de:	00000717          	auipc	a4,0x0
 8e2:	72f73123          	sd	a5,1826(a4) # 1000 <freep>
 8e6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ec:	b7d1                	j	8b0 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8ee:	6398                	ld	a4,0(a5)
 8f0:	e118                	sd	a4,0(a0)
 8f2:	a899                	j	948 <malloc+0xd0>
  hp->s.size = nu;
 8f4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f8:	0541                	addi	a0,a0,16
 8fa:	ef9ff0ef          	jal	7f2 <free>
  return freep;
 8fe:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 900:	c125                	beqz	a0,960 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 902:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 904:	4798                	lw	a4,8(a5)
 906:	03277163          	bgeu	a4,s2,928 <malloc+0xb0>
    if(p == freep)
 90a:	6098                	ld	a4,0(s1)
 90c:	853e                	mv	a0,a5
 90e:	fef71ae3          	bne	a4,a5,902 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 912:	8552                	mv	a0,s4
 914:	9f3ff0ef          	jal	306 <sbrk>
  if(p == SBRK_ERROR)
 918:	fd551ee3          	bne	a0,s5,8f4 <malloc+0x7c>
        return 0;
 91c:	4501                	li	a0,0
 91e:	74a2                	ld	s1,40(sp)
 920:	6a42                	ld	s4,16(sp)
 922:	6aa2                	ld	s5,8(sp)
 924:	6b02                	ld	s6,0(sp)
 926:	a03d                	j	954 <malloc+0xdc>
 928:	74a2                	ld	s1,40(sp)
 92a:	6a42                	ld	s4,16(sp)
 92c:	6aa2                	ld	s5,8(sp)
 92e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 930:	fae90fe3          	beq	s2,a4,8ee <malloc+0x76>
        p->s.size -= nunits;
 934:	4137073b          	subw	a4,a4,s3
 938:	c798                	sw	a4,8(a5)
        p += p->s.size;
 93a:	02071693          	slli	a3,a4,0x20
 93e:	01c6d713          	srli	a4,a3,0x1c
 942:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 944:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 948:	00000717          	auipc	a4,0x0
 94c:	6aa73c23          	sd	a0,1720(a4) # 1000 <freep>
      return (void*)(p + 1);
 950:	01078513          	addi	a0,a5,16
  }
}
 954:	70e2                	ld	ra,56(sp)
 956:	7442                	ld	s0,48(sp)
 958:	7902                	ld	s2,32(sp)
 95a:	69e2                	ld	s3,24(sp)
 95c:	6121                	addi	sp,sp,64
 95e:	8082                	ret
 960:	74a2                	ld	s1,40(sp)
 962:	6a42                	ld	s4,16(sp)
 964:	6aa2                	ld	s5,8(sp)
 966:	6b02                	ld	s6,0(sp)
 968:	b7f5                	j	954 <malloc+0xdc>
