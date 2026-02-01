
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
  12:	4589                	li	a1,2
  14:	00001517          	auipc	a0,0x1
  18:	9cc50513          	addi	a0,a0,-1588 # 9e0 <malloc+0x100>
  1c:	3c6000ef          	jal	3e2 <open>
  20:	06054a63          	bltz	a0,94 <main+0x94>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  24:	4501                	li	a0,0
  26:	3f4000ef          	jal	41a <dup>
  dup(0);  // stderr
  2a:	4501                	li	a0,0
  2c:	3ee000ef          	jal	41a <dup>

  for(;;){
    printf("init: starting sh\n");
  30:	00001a97          	auipc	s5,0x1
  34:	9b8a8a93          	addi	s5,s5,-1608 # 9e8 <malloc+0x108>
    printf("Student ID: 2023312782\n");
  38:	00001a17          	auipc	s4,0x1
  3c:	9c8a0a13          	addi	s4,s4,-1592 # a00 <malloc+0x120>
    printf("Name: Minju Kang\n");
  40:	00001997          	auipc	s3,0x1
  44:	9d898993          	addi	s3,s3,-1576 # a18 <malloc+0x138>
    printf("Print any message for debugging\n");
  48:	00001917          	auipc	s2,0x1
  4c:	9e890913          	addi	s2,s2,-1560 # a30 <malloc+0x150>
    printf("init: starting sh\n");
  50:	8556                	mv	a0,s5
  52:	7d6000ef          	jal	828 <printf>
    printf("Student ID: 2023312782\n");
  56:	8552                	mv	a0,s4
  58:	7d0000ef          	jal	828 <printf>
    printf("Name: Minju Kang\n");
  5c:	854e                	mv	a0,s3
  5e:	7ca000ef          	jal	828 <printf>
    printf("Print any message for debugging\n");
  62:	854a                	mv	a0,s2
  64:	7c4000ef          	jal	828 <printf>
    pid = fork();
  68:	332000ef          	jal	39a <fork>
  6c:	84aa                	mv	s1,a0
    if(pid < 0){
  6e:	04054363          	bltz	a0,b4 <main+0xb4>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  72:	c931                	beqz	a0,c6 <main+0xc6>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  74:	4501                	li	a0,0
  76:	334000ef          	jal	3aa <wait>
      if(wpid == pid){
  7a:	fca48be3          	beq	s1,a0,50 <main+0x50>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  7e:	fe055be3          	bgez	a0,74 <main+0x74>
        printf("init: wait returned an error\n");
  82:	00001517          	auipc	a0,0x1
  86:	a0e50513          	addi	a0,a0,-1522 # a90 <malloc+0x1b0>
  8a:	79e000ef          	jal	828 <printf>
        exit(1);
  8e:	4505                	li	a0,1
  90:	312000ef          	jal	3a2 <exit>
    mknod("console", CONSOLE, 0);
  94:	4601                	li	a2,0
  96:	4585                	li	a1,1
  98:	00001517          	auipc	a0,0x1
  9c:	94850513          	addi	a0,a0,-1720 # 9e0 <malloc+0x100>
  a0:	34a000ef          	jal	3ea <mknod>
    open("console", O_RDWR);
  a4:	4589                	li	a1,2
  a6:	00001517          	auipc	a0,0x1
  aa:	93a50513          	addi	a0,a0,-1734 # 9e0 <malloc+0x100>
  ae:	334000ef          	jal	3e2 <open>
  b2:	bf8d                	j	24 <main+0x24>
      printf("init: fork failed\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	9a450513          	addi	a0,a0,-1628 # a58 <malloc+0x178>
  bc:	76c000ef          	jal	828 <printf>
      exit(1);
  c0:	4505                	li	a0,1
  c2:	2e0000ef          	jal	3a2 <exit>
      exec("sh", argv);
  c6:	00001597          	auipc	a1,0x1
  ca:	f3a58593          	addi	a1,a1,-198 # 1000 <argv>
  ce:	00001517          	auipc	a0,0x1
  d2:	9a250513          	addi	a0,a0,-1630 # a70 <malloc+0x190>
  d6:	304000ef          	jal	3da <exec>
      printf("init: exec sh failed\n");
  da:	00001517          	auipc	a0,0x1
  de:	99e50513          	addi	a0,a0,-1634 # a78 <malloc+0x198>
  e2:	746000ef          	jal	828 <printf>
      exit(1);
  e6:	4505                	li	a0,1
  e8:	2ba000ef          	jal	3a2 <exit>

00000000000000ec <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e406                	sd	ra,8(sp)
  f0:	e022                	sd	s0,0(sp)
  f2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  f4:	f0dff0ef          	jal	0 <main>
  exit(r);
  f8:	2aa000ef          	jal	3a2 <exit>

00000000000000fc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e406                	sd	ra,8(sp)
 100:	e022                	sd	s0,0(sp)
 102:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 104:	87aa                	mv	a5,a0
 106:	0585                	addi	a1,a1,1
 108:	0785                	addi	a5,a5,1
 10a:	fff5c703          	lbu	a4,-1(a1)
 10e:	fee78fa3          	sb	a4,-1(a5)
 112:	fb75                	bnez	a4,106 <strcpy+0xa>
    ;
  return os;
}
 114:	60a2                	ld	ra,8(sp)
 116:	6402                	ld	s0,0(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 124:	00054783          	lbu	a5,0(a0)
 128:	cb91                	beqz	a5,13c <strcmp+0x20>
 12a:	0005c703          	lbu	a4,0(a1)
 12e:	00f71763          	bne	a4,a5,13c <strcmp+0x20>
    p++, q++;
 132:	0505                	addi	a0,a0,1
 134:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 136:	00054783          	lbu	a5,0(a0)
 13a:	fbe5                	bnez	a5,12a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 13c:	0005c503          	lbu	a0,0(a1)
}
 140:	40a7853b          	subw	a0,a5,a0
 144:	60a2                	ld	ra,8(sp)
 146:	6402                	ld	s0,0(sp)
 148:	0141                	addi	sp,sp,16
 14a:	8082                	ret

000000000000014c <strlen>:

uint
strlen(const char *s)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e406                	sd	ra,8(sp)
 150:	e022                	sd	s0,0(sp)
 152:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 154:	00054783          	lbu	a5,0(a0)
 158:	cf91                	beqz	a5,174 <strlen+0x28>
 15a:	00150793          	addi	a5,a0,1
 15e:	86be                	mv	a3,a5
 160:	0785                	addi	a5,a5,1
 162:	fff7c703          	lbu	a4,-1(a5)
 166:	ff65                	bnez	a4,15e <strlen+0x12>
 168:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 16c:	60a2                	ld	ra,8(sp)
 16e:	6402                	ld	s0,0(sp)
 170:	0141                	addi	sp,sp,16
 172:	8082                	ret
  for(n = 0; s[n]; n++)
 174:	4501                	li	a0,0
 176:	bfdd                	j	16c <strlen+0x20>

0000000000000178 <memset>:

void*
memset(void *dst, int c, uint n)
{
 178:	1141                	addi	sp,sp,-16
 17a:	e406                	sd	ra,8(sp)
 17c:	e022                	sd	s0,0(sp)
 17e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 180:	ca19                	beqz	a2,196 <memset+0x1e>
 182:	87aa                	mv	a5,a0
 184:	1602                	slli	a2,a2,0x20
 186:	9201                	srli	a2,a2,0x20
 188:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 18c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 190:	0785                	addi	a5,a5,1
 192:	fee79de3          	bne	a5,a4,18c <memset+0x14>
  }
  return dst;
}
 196:	60a2                	ld	ra,8(sp)
 198:	6402                	ld	s0,0(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret

000000000000019e <strchr>:

char*
strchr(const char *s, char c)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e406                	sd	ra,8(sp)
 1a2:	e022                	sd	s0,0(sp)
 1a4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	cf81                	beqz	a5,1c2 <strchr+0x24>
    if(*s == c)
 1ac:	00f58763          	beq	a1,a5,1ba <strchr+0x1c>
  for(; *s; s++)
 1b0:	0505                	addi	a0,a0,1
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	fbfd                	bnez	a5,1ac <strchr+0xe>
      return (char*)s;
  return 0;
 1b8:	4501                	li	a0,0
}
 1ba:	60a2                	ld	ra,8(sp)
 1bc:	6402                	ld	s0,0(sp)
 1be:	0141                	addi	sp,sp,16
 1c0:	8082                	ret
  return 0;
 1c2:	4501                	li	a0,0
 1c4:	bfdd                	j	1ba <strchr+0x1c>

00000000000001c6 <gets>:

char*
gets(char *buf, int max)
{
 1c6:	711d                	addi	sp,sp,-96
 1c8:	ec86                	sd	ra,88(sp)
 1ca:	e8a2                	sd	s0,80(sp)
 1cc:	e4a6                	sd	s1,72(sp)
 1ce:	e0ca                	sd	s2,64(sp)
 1d0:	fc4e                	sd	s3,56(sp)
 1d2:	f852                	sd	s4,48(sp)
 1d4:	f456                	sd	s5,40(sp)
 1d6:	f05a                	sd	s6,32(sp)
 1d8:	ec5e                	sd	s7,24(sp)
 1da:	e862                	sd	s8,16(sp)
 1dc:	1080                	addi	s0,sp,96
 1de:	8baa                	mv	s7,a0
 1e0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e2:	892a                	mv	s2,a0
 1e4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1e6:	faf40b13          	addi	s6,s0,-81
 1ea:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1ec:	8c26                	mv	s8,s1
 1ee:	0014899b          	addiw	s3,s1,1
 1f2:	84ce                	mv	s1,s3
 1f4:	0349d463          	bge	s3,s4,21c <gets+0x56>
    cc = read(0, &c, 1);
 1f8:	8656                	mv	a2,s5
 1fa:	85da                	mv	a1,s6
 1fc:	4501                	li	a0,0
 1fe:	1bc000ef          	jal	3ba <read>
    if(cc < 1)
 202:	00a05d63          	blez	a0,21c <gets+0x56>
      break;
    buf[i++] = c;
 206:	faf44783          	lbu	a5,-81(s0)
 20a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20e:	0905                	addi	s2,s2,1
 210:	ff678713          	addi	a4,a5,-10
 214:	c319                	beqz	a4,21a <gets+0x54>
 216:	17cd                	addi	a5,a5,-13
 218:	fbf1                	bnez	a5,1ec <gets+0x26>
    buf[i++] = c;
 21a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 21c:	9c5e                	add	s8,s8,s7
 21e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 222:	855e                	mv	a0,s7
 224:	60e6                	ld	ra,88(sp)
 226:	6446                	ld	s0,80(sp)
 228:	64a6                	ld	s1,72(sp)
 22a:	6906                	ld	s2,64(sp)
 22c:	79e2                	ld	s3,56(sp)
 22e:	7a42                	ld	s4,48(sp)
 230:	7aa2                	ld	s5,40(sp)
 232:	7b02                	ld	s6,32(sp)
 234:	6be2                	ld	s7,24(sp)
 236:	6c42                	ld	s8,16(sp)
 238:	6125                	addi	sp,sp,96
 23a:	8082                	ret

000000000000023c <stat>:

int
stat(const char *n, struct stat *st)
{
 23c:	1101                	addi	sp,sp,-32
 23e:	ec06                	sd	ra,24(sp)
 240:	e822                	sd	s0,16(sp)
 242:	e04a                	sd	s2,0(sp)
 244:	1000                	addi	s0,sp,32
 246:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 248:	4581                	li	a1,0
 24a:	198000ef          	jal	3e2 <open>
  if(fd < 0)
 24e:	02054263          	bltz	a0,272 <stat+0x36>
 252:	e426                	sd	s1,8(sp)
 254:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 256:	85ca                	mv	a1,s2
 258:	1a2000ef          	jal	3fa <fstat>
 25c:	892a                	mv	s2,a0
  close(fd);
 25e:	8526                	mv	a0,s1
 260:	16a000ef          	jal	3ca <close>
  return r;
 264:	64a2                	ld	s1,8(sp)
}
 266:	854a                	mv	a0,s2
 268:	60e2                	ld	ra,24(sp)
 26a:	6442                	ld	s0,16(sp)
 26c:	6902                	ld	s2,0(sp)
 26e:	6105                	addi	sp,sp,32
 270:	8082                	ret
    return -1;
 272:	57fd                	li	a5,-1
 274:	893e                	mv	s2,a5
 276:	bfc5                	j	266 <stat+0x2a>

0000000000000278 <atoi>:

int
atoi(const char *s)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e406                	sd	ra,8(sp)
 27c:	e022                	sd	s0,0(sp)
 27e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 280:	00054683          	lbu	a3,0(a0)
 284:	fd06879b          	addiw	a5,a3,-48
 288:	0ff7f793          	zext.b	a5,a5
 28c:	4625                	li	a2,9
 28e:	02f66963          	bltu	a2,a5,2c0 <atoi+0x48>
 292:	872a                	mv	a4,a0
  n = 0;
 294:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 296:	0705                	addi	a4,a4,1
 298:	0025179b          	slliw	a5,a0,0x2
 29c:	9fa9                	addw	a5,a5,a0
 29e:	0017979b          	slliw	a5,a5,0x1
 2a2:	9fb5                	addw	a5,a5,a3
 2a4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a8:	00074683          	lbu	a3,0(a4)
 2ac:	fd06879b          	addiw	a5,a3,-48
 2b0:	0ff7f793          	zext.b	a5,a5
 2b4:	fef671e3          	bgeu	a2,a5,296 <atoi+0x1e>
  return n;
}
 2b8:	60a2                	ld	ra,8(sp)
 2ba:	6402                	ld	s0,0(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
  n = 0;
 2c0:	4501                	li	a0,0
 2c2:	bfdd                	j	2b8 <atoi+0x40>

00000000000002c4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2cc:	02b57563          	bgeu	a0,a1,2f6 <memmove+0x32>
    while(n-- > 0)
 2d0:	00c05f63          	blez	a2,2ee <memmove+0x2a>
 2d4:	1602                	slli	a2,a2,0x20
 2d6:	9201                	srli	a2,a2,0x20
 2d8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2dc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2de:	0585                	addi	a1,a1,1
 2e0:	0705                	addi	a4,a4,1
 2e2:	fff5c683          	lbu	a3,-1(a1)
 2e6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ea:	fee79ae3          	bne	a5,a4,2de <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ee:	60a2                	ld	ra,8(sp)
 2f0:	6402                	ld	s0,0(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret
    while(n-- > 0)
 2f6:	fec05ce3          	blez	a2,2ee <memmove+0x2a>
    dst += n;
 2fa:	00c50733          	add	a4,a0,a2
    src += n;
 2fe:	95b2                	add	a1,a1,a2
 300:	fff6079b          	addiw	a5,a2,-1
 304:	1782                	slli	a5,a5,0x20
 306:	9381                	srli	a5,a5,0x20
 308:	fff7c793          	not	a5,a5
 30c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 30e:	15fd                	addi	a1,a1,-1
 310:	177d                	addi	a4,a4,-1
 312:	0005c683          	lbu	a3,0(a1)
 316:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 31a:	fef71ae3          	bne	a4,a5,30e <memmove+0x4a>
 31e:	bfc1                	j	2ee <memmove+0x2a>

0000000000000320 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 328:	c61d                	beqz	a2,356 <memcmp+0x36>
 32a:	1602                	slli	a2,a2,0x20
 32c:	9201                	srli	a2,a2,0x20
 32e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 332:	00054783          	lbu	a5,0(a0)
 336:	0005c703          	lbu	a4,0(a1)
 33a:	00e79863          	bne	a5,a4,34a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 33e:	0505                	addi	a0,a0,1
    p2++;
 340:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 342:	fed518e3          	bne	a0,a3,332 <memcmp+0x12>
  }
  return 0;
 346:	4501                	li	a0,0
 348:	a019                	j	34e <memcmp+0x2e>
      return *p1 - *p2;
 34a:	40e7853b          	subw	a0,a5,a4
}
 34e:	60a2                	ld	ra,8(sp)
 350:	6402                	ld	s0,0(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret
  return 0;
 356:	4501                	li	a0,0
 358:	bfdd                	j	34e <memcmp+0x2e>

000000000000035a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e406                	sd	ra,8(sp)
 35e:	e022                	sd	s0,0(sp)
 360:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 362:	f63ff0ef          	jal	2c4 <memmove>
}
 366:	60a2                	ld	ra,8(sp)
 368:	6402                	ld	s0,0(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret

000000000000036e <sbrk>:

char *
sbrk(int n) {
 36e:	1141                	addi	sp,sp,-16
 370:	e406                	sd	ra,8(sp)
 372:	e022                	sd	s0,0(sp)
 374:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 376:	4585                	li	a1,1
 378:	0b2000ef          	jal	42a <sys_sbrk>
}
 37c:	60a2                	ld	ra,8(sp)
 37e:	6402                	ld	s0,0(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret

0000000000000384 <sbrklazy>:

char *
sbrklazy(int n) {
 384:	1141                	addi	sp,sp,-16
 386:	e406                	sd	ra,8(sp)
 388:	e022                	sd	s0,0(sp)
 38a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 38c:	4589                	li	a1,2
 38e:	09c000ef          	jal	42a <sys_sbrk>
}
 392:	60a2                	ld	ra,8(sp)
 394:	6402                	ld	s0,0(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret

000000000000039a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39a:	4885                	li	a7,1
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a2:	4889                	li	a7,2
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <wait>:
.global wait
wait:
 li a7, SYS_wait
 3aa:	488d                	li	a7,3
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b2:	4891                	li	a7,4
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <read>:
.global read
read:
 li a7, SYS_read
 3ba:	4895                	li	a7,5
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <write>:
.global write
write:
 li a7, SYS_write
 3c2:	48c1                	li	a7,16
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <close>:
.global close
close:
 li a7, SYS_close
 3ca:	48d5                	li	a7,21
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d2:	4899                	li	a7,6
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <exec>:
.global exec
exec:
 li a7, SYS_exec
 3da:	489d                	li	a7,7
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <open>:
.global open
open:
 li a7, SYS_open
 3e2:	48bd                	li	a7,15
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ea:	48c5                	li	a7,17
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f2:	48c9                	li	a7,18
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3fa:	48a1                	li	a7,8
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <link>:
.global link
link:
 li a7, SYS_link
 402:	48cd                	li	a7,19
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 40a:	48d1                	li	a7,20
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 412:	48a5                	li	a7,9
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <dup>:
.global dup
dup:
 li a7, SYS_dup
 41a:	48a9                	li	a7,10
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 422:	48ad                	li	a7,11
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 42a:	48b1                	li	a7,12
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <pause>:
.global pause
pause:
 li a7, SYS_pause
 432:	48b5                	li	a7,13
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 43a:	48b9                	li	a7,14
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <getnice>:
.global getnice
getnice:
 li a7, SYS_getnice
 442:	48d9                	li	a7,22
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <setnice>:
.global setnice
setnice:
 li a7, SYS_setnice
 44a:	48dd                	li	a7,23
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <ps>:
.global ps
ps:
 li a7, SYS_ps
 452:	48e1                	li	a7,24
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <meminfo>:
.global meminfo
meminfo:
 li a7, SYS_meminfo
 45a:	48e5                	li	a7,25
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 462:	48e9                	li	a7,26
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 46a:	48ed                	li	a7,27
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 472:	48f1                	li	a7,28
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <freemem>:
.global freemem
freemem:
 li a7, SYS_freemem
 47a:	48f5                	li	a7,29
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 482:	1101                	addi	sp,sp,-32
 484:	ec06                	sd	ra,24(sp)
 486:	e822                	sd	s0,16(sp)
 488:	1000                	addi	s0,sp,32
 48a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48e:	4605                	li	a2,1
 490:	fef40593          	addi	a1,s0,-17
 494:	f2fff0ef          	jal	3c2 <write>
}
 498:	60e2                	ld	ra,24(sp)
 49a:	6442                	ld	s0,16(sp)
 49c:	6105                	addi	sp,sp,32
 49e:	8082                	ret

00000000000004a0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4a0:	715d                	addi	sp,sp,-80
 4a2:	e486                	sd	ra,72(sp)
 4a4:	e0a2                	sd	s0,64(sp)
 4a6:	f84a                	sd	s2,48(sp)
 4a8:	f44e                	sd	s3,40(sp)
 4aa:	0880                	addi	s0,sp,80
 4ac:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4ae:	c6d1                	beqz	a3,53a <printint+0x9a>
 4b0:	0805d563          	bgez	a1,53a <printint+0x9a>
    neg = 1;
    x = -xx;
 4b4:	40b005b3          	neg	a1,a1
    neg = 1;
 4b8:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4ba:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4be:	86ce                	mv	a3,s3
  i = 0;
 4c0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c2:	00000817          	auipc	a6,0x0
 4c6:	5f680813          	addi	a6,a6,1526 # ab8 <digits>
 4ca:	88ba                	mv	a7,a4
 4cc:	0017051b          	addiw	a0,a4,1
 4d0:	872a                	mv	a4,a0
 4d2:	02c5f7b3          	remu	a5,a1,a2
 4d6:	97c2                	add	a5,a5,a6
 4d8:	0007c783          	lbu	a5,0(a5)
 4dc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e0:	87ae                	mv	a5,a1
 4e2:	02c5d5b3          	divu	a1,a1,a2
 4e6:	0685                	addi	a3,a3,1
 4e8:	fec7f1e3          	bgeu	a5,a2,4ca <printint+0x2a>
  if(neg)
 4ec:	00030c63          	beqz	t1,504 <printint+0x64>
    buf[i++] = '-';
 4f0:	fd050793          	addi	a5,a0,-48
 4f4:	00878533          	add	a0,a5,s0
 4f8:	02d00793          	li	a5,45
 4fc:	fef50423          	sb	a5,-24(a0)
 500:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 504:	02e05563          	blez	a4,52e <printint+0x8e>
 508:	fc26                	sd	s1,56(sp)
 50a:	377d                	addiw	a4,a4,-1
 50c:	00e984b3          	add	s1,s3,a4
 510:	19fd                	addi	s3,s3,-1
 512:	99ba                	add	s3,s3,a4
 514:	1702                	slli	a4,a4,0x20
 516:	9301                	srli	a4,a4,0x20
 518:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 51c:	0004c583          	lbu	a1,0(s1)
 520:	854a                	mv	a0,s2
 522:	f61ff0ef          	jal	482 <putc>
  while(--i >= 0)
 526:	14fd                	addi	s1,s1,-1
 528:	ff349ae3          	bne	s1,s3,51c <printint+0x7c>
 52c:	74e2                	ld	s1,56(sp)
}
 52e:	60a6                	ld	ra,72(sp)
 530:	6406                	ld	s0,64(sp)
 532:	7942                	ld	s2,48(sp)
 534:	79a2                	ld	s3,40(sp)
 536:	6161                	addi	sp,sp,80
 538:	8082                	ret
  neg = 0;
 53a:	4301                	li	t1,0
 53c:	bfbd                	j	4ba <printint+0x1a>

000000000000053e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 53e:	711d                	addi	sp,sp,-96
 540:	ec86                	sd	ra,88(sp)
 542:	e8a2                	sd	s0,80(sp)
 544:	e4a6                	sd	s1,72(sp)
 546:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 548:	0005c483          	lbu	s1,0(a1)
 54c:	22048363          	beqz	s1,772 <vprintf+0x234>
 550:	e0ca                	sd	s2,64(sp)
 552:	fc4e                	sd	s3,56(sp)
 554:	f852                	sd	s4,48(sp)
 556:	f456                	sd	s5,40(sp)
 558:	f05a                	sd	s6,32(sp)
 55a:	ec5e                	sd	s7,24(sp)
 55c:	e862                	sd	s8,16(sp)
 55e:	8b2a                	mv	s6,a0
 560:	8a2e                	mv	s4,a1
 562:	8bb2                	mv	s7,a2
  state = 0;
 564:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 566:	4901                	li	s2,0
 568:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 56a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 56e:	06400c13          	li	s8,100
 572:	a00d                	j	594 <vprintf+0x56>
        putc(fd, c0);
 574:	85a6                	mv	a1,s1
 576:	855a                	mv	a0,s6
 578:	f0bff0ef          	jal	482 <putc>
 57c:	a019                	j	582 <vprintf+0x44>
    } else if(state == '%'){
 57e:	03598363          	beq	s3,s5,5a4 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 582:	0019079b          	addiw	a5,s2,1
 586:	893e                	mv	s2,a5
 588:	873e                	mv	a4,a5
 58a:	97d2                	add	a5,a5,s4
 58c:	0007c483          	lbu	s1,0(a5)
 590:	1c048a63          	beqz	s1,764 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 594:	0004879b          	sext.w	a5,s1
    if(state == 0){
 598:	fe0993e3          	bnez	s3,57e <vprintf+0x40>
      if(c0 == '%'){
 59c:	fd579ce3          	bne	a5,s5,574 <vprintf+0x36>
        state = '%';
 5a0:	89be                	mv	s3,a5
 5a2:	b7c5                	j	582 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5a4:	00ea06b3          	add	a3,s4,a4
 5a8:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5ac:	1c060863          	beqz	a2,77c <vprintf+0x23e>
      if(c0 == 'd'){
 5b0:	03878763          	beq	a5,s8,5de <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5b4:	f9478693          	addi	a3,a5,-108
 5b8:	0016b693          	seqz	a3,a3
 5bc:	f9c60593          	addi	a1,a2,-100
 5c0:	e99d                	bnez	a1,5f6 <vprintf+0xb8>
 5c2:	ca95                	beqz	a3,5f6 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c4:	008b8493          	addi	s1,s7,8
 5c8:	4685                	li	a3,1
 5ca:	4629                	li	a2,10
 5cc:	000bb583          	ld	a1,0(s7)
 5d0:	855a                	mv	a0,s6
 5d2:	ecfff0ef          	jal	4a0 <printint>
        i += 1;
 5d6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d8:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b75d                	j	582 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5de:	008b8493          	addi	s1,s7,8
 5e2:	4685                	li	a3,1
 5e4:	4629                	li	a2,10
 5e6:	000ba583          	lw	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	eb5ff0ef          	jal	4a0 <printint>
 5f0:	8ba6                	mv	s7,s1
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b779                	j	582 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 5f6:	9752                	add	a4,a4,s4
 5f8:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5fc:	f9460713          	addi	a4,a2,-108
 600:	00173713          	seqz	a4,a4
 604:	8f75                	and	a4,a4,a3
 606:	f9c58513          	addi	a0,a1,-100
 60a:	18051363          	bnez	a0,790 <vprintf+0x252>
 60e:	18070163          	beqz	a4,790 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 612:	008b8493          	addi	s1,s7,8
 616:	4685                	li	a3,1
 618:	4629                	li	a2,10
 61a:	000bb583          	ld	a1,0(s7)
 61e:	855a                	mv	a0,s6
 620:	e81ff0ef          	jal	4a0 <printint>
        i += 2;
 624:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 626:	8ba6                	mv	s7,s1
      state = 0;
 628:	4981                	li	s3,0
        i += 2;
 62a:	bfa1                	j	582 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 62c:	008b8493          	addi	s1,s7,8
 630:	4681                	li	a3,0
 632:	4629                	li	a2,10
 634:	000be583          	lwu	a1,0(s7)
 638:	855a                	mv	a0,s6
 63a:	e67ff0ef          	jal	4a0 <printint>
 63e:	8ba6                	mv	s7,s1
      state = 0;
 640:	4981                	li	s3,0
 642:	b781                	j	582 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 644:	008b8493          	addi	s1,s7,8
 648:	4681                	li	a3,0
 64a:	4629                	li	a2,10
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	e4fff0ef          	jal	4a0 <printint>
        i += 1;
 656:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	8ba6                	mv	s7,s1
      state = 0;
 65a:	4981                	li	s3,0
 65c:	b71d                	j	582 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65e:	008b8493          	addi	s1,s7,8
 662:	4681                	li	a3,0
 664:	4629                	li	a2,10
 666:	000bb583          	ld	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	e35ff0ef          	jal	4a0 <printint>
        i += 2;
 670:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 672:	8ba6                	mv	s7,s1
      state = 0;
 674:	4981                	li	s3,0
        i += 2;
 676:	b731                	j	582 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 678:	008b8493          	addi	s1,s7,8
 67c:	4681                	li	a3,0
 67e:	4641                	li	a2,16
 680:	000be583          	lwu	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	e1bff0ef          	jal	4a0 <printint>
 68a:	8ba6                	mv	s7,s1
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bdd5                	j	582 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 690:	008b8493          	addi	s1,s7,8
 694:	4681                	li	a3,0
 696:	4641                	li	a2,16
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	e03ff0ef          	jal	4a0 <printint>
        i += 1;
 6a2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a4:	8ba6                	mv	s7,s1
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bde9                	j	582 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6aa:	008b8493          	addi	s1,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4641                	li	a2,16
 6b2:	000bb583          	ld	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	de9ff0ef          	jal	4a0 <printint>
        i += 2;
 6bc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6be:	8ba6                	mv	s7,s1
      state = 0;
 6c0:	4981                	li	s3,0
        i += 2;
 6c2:	b5c1                	j	582 <vprintf+0x44>
 6c4:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6c6:	008b8793          	addi	a5,s7,8
 6ca:	8cbe                	mv	s9,a5
 6cc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d0:	03000593          	li	a1,48
 6d4:	855a                	mv	a0,s6
 6d6:	dadff0ef          	jal	482 <putc>
  putc(fd, 'x');
 6da:	07800593          	li	a1,120
 6de:	855a                	mv	a0,s6
 6e0:	da3ff0ef          	jal	482 <putc>
 6e4:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e6:	00000b97          	auipc	s7,0x0
 6ea:	3d2b8b93          	addi	s7,s7,978 # ab8 <digits>
 6ee:	03c9d793          	srli	a5,s3,0x3c
 6f2:	97de                	add	a5,a5,s7
 6f4:	0007c583          	lbu	a1,0(a5)
 6f8:	855a                	mv	a0,s6
 6fa:	d89ff0ef          	jal	482 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6fe:	0992                	slli	s3,s3,0x4
 700:	34fd                	addiw	s1,s1,-1
 702:	f4f5                	bnez	s1,6ee <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 704:	8be6                	mv	s7,s9
      state = 0;
 706:	4981                	li	s3,0
 708:	6ca2                	ld	s9,8(sp)
 70a:	bda5                	j	582 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 70c:	008b8493          	addi	s1,s7,8
 710:	000bc583          	lbu	a1,0(s7)
 714:	855a                	mv	a0,s6
 716:	d6dff0ef          	jal	482 <putc>
 71a:	8ba6                	mv	s7,s1
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b595                	j	582 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 720:	008b8993          	addi	s3,s7,8
 724:	000bb483          	ld	s1,0(s7)
 728:	cc91                	beqz	s1,744 <vprintf+0x206>
        for(; *s; s++)
 72a:	0004c583          	lbu	a1,0(s1)
 72e:	c985                	beqz	a1,75e <vprintf+0x220>
          putc(fd, *s);
 730:	855a                	mv	a0,s6
 732:	d51ff0ef          	jal	482 <putc>
        for(; *s; s++)
 736:	0485                	addi	s1,s1,1
 738:	0004c583          	lbu	a1,0(s1)
 73c:	f9f5                	bnez	a1,730 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 73e:	8bce                	mv	s7,s3
      state = 0;
 740:	4981                	li	s3,0
 742:	b581                	j	582 <vprintf+0x44>
          s = "(null)";
 744:	00000497          	auipc	s1,0x0
 748:	36c48493          	addi	s1,s1,876 # ab0 <malloc+0x1d0>
        for(; *s; s++)
 74c:	02800593          	li	a1,40
 750:	b7c5                	j	730 <vprintf+0x1f2>
        putc(fd, '%');
 752:	85be                	mv	a1,a5
 754:	855a                	mv	a0,s6
 756:	d2dff0ef          	jal	482 <putc>
      state = 0;
 75a:	4981                	li	s3,0
 75c:	b51d                	j	582 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 75e:	8bce                	mv	s7,s3
      state = 0;
 760:	4981                	li	s3,0
 762:	b505                	j	582 <vprintf+0x44>
 764:	6906                	ld	s2,64(sp)
 766:	79e2                	ld	s3,56(sp)
 768:	7a42                	ld	s4,48(sp)
 76a:	7aa2                	ld	s5,40(sp)
 76c:	7b02                	ld	s6,32(sp)
 76e:	6be2                	ld	s7,24(sp)
 770:	6c42                	ld	s8,16(sp)
    }
  }
}
 772:	60e6                	ld	ra,88(sp)
 774:	6446                	ld	s0,80(sp)
 776:	64a6                	ld	s1,72(sp)
 778:	6125                	addi	sp,sp,96
 77a:	8082                	ret
      if(c0 == 'd'){
 77c:	06400713          	li	a4,100
 780:	e4e78fe3          	beq	a5,a4,5de <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 784:	f9478693          	addi	a3,a5,-108
 788:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 78c:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 78e:	4701                	li	a4,0
      } else if(c0 == 'u'){
 790:	07500513          	li	a0,117
 794:	e8a78ce3          	beq	a5,a0,62c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 798:	f8b60513          	addi	a0,a2,-117
 79c:	e119                	bnez	a0,7a2 <vprintf+0x264>
 79e:	ea0693e3          	bnez	a3,644 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7a2:	f8b58513          	addi	a0,a1,-117
 7a6:	e119                	bnez	a0,7ac <vprintf+0x26e>
 7a8:	ea071be3          	bnez	a4,65e <vprintf+0x120>
      } else if(c0 == 'x'){
 7ac:	07800513          	li	a0,120
 7b0:	eca784e3          	beq	a5,a0,678 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7b4:	f8860613          	addi	a2,a2,-120
 7b8:	e219                	bnez	a2,7be <vprintf+0x280>
 7ba:	ec069be3          	bnez	a3,690 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7be:	f8858593          	addi	a1,a1,-120
 7c2:	e199                	bnez	a1,7c8 <vprintf+0x28a>
 7c4:	ee0713e3          	bnez	a4,6aa <vprintf+0x16c>
      } else if(c0 == 'p'){
 7c8:	07000713          	li	a4,112
 7cc:	eee78ce3          	beq	a5,a4,6c4 <vprintf+0x186>
      } else if(c0 == 'c'){
 7d0:	06300713          	li	a4,99
 7d4:	f2e78ce3          	beq	a5,a4,70c <vprintf+0x1ce>
      } else if(c0 == 's'){
 7d8:	07300713          	li	a4,115
 7dc:	f4e782e3          	beq	a5,a4,720 <vprintf+0x1e2>
      } else if(c0 == '%'){
 7e0:	02500713          	li	a4,37
 7e4:	f6e787e3          	beq	a5,a4,752 <vprintf+0x214>
        putc(fd, '%');
 7e8:	02500593          	li	a1,37
 7ec:	855a                	mv	a0,s6
 7ee:	c95ff0ef          	jal	482 <putc>
        putc(fd, c0);
 7f2:	85a6                	mv	a1,s1
 7f4:	855a                	mv	a0,s6
 7f6:	c8dff0ef          	jal	482 <putc>
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b359                	j	582 <vprintf+0x44>

00000000000007fe <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7fe:	715d                	addi	sp,sp,-80
 800:	ec06                	sd	ra,24(sp)
 802:	e822                	sd	s0,16(sp)
 804:	1000                	addi	s0,sp,32
 806:	e010                	sd	a2,0(s0)
 808:	e414                	sd	a3,8(s0)
 80a:	e818                	sd	a4,16(s0)
 80c:	ec1c                	sd	a5,24(s0)
 80e:	03043023          	sd	a6,32(s0)
 812:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 816:	8622                	mv	a2,s0
 818:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 81c:	d23ff0ef          	jal	53e <vprintf>
}
 820:	60e2                	ld	ra,24(sp)
 822:	6442                	ld	s0,16(sp)
 824:	6161                	addi	sp,sp,80
 826:	8082                	ret

0000000000000828 <printf>:

void
printf(const char *fmt, ...)
{
 828:	711d                	addi	sp,sp,-96
 82a:	ec06                	sd	ra,24(sp)
 82c:	e822                	sd	s0,16(sp)
 82e:	1000                	addi	s0,sp,32
 830:	e40c                	sd	a1,8(s0)
 832:	e810                	sd	a2,16(s0)
 834:	ec14                	sd	a3,24(s0)
 836:	f018                	sd	a4,32(s0)
 838:	f41c                	sd	a5,40(s0)
 83a:	03043823          	sd	a6,48(s0)
 83e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 842:	00840613          	addi	a2,s0,8
 846:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 84a:	85aa                	mv	a1,a0
 84c:	4505                	li	a0,1
 84e:	cf1ff0ef          	jal	53e <vprintf>
}
 852:	60e2                	ld	ra,24(sp)
 854:	6442                	ld	s0,16(sp)
 856:	6125                	addi	sp,sp,96
 858:	8082                	ret

000000000000085a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 85a:	1141                	addi	sp,sp,-16
 85c:	e406                	sd	ra,8(sp)
 85e:	e022                	sd	s0,0(sp)
 860:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 862:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 866:	00000797          	auipc	a5,0x0
 86a:	7aa7b783          	ld	a5,1962(a5) # 1010 <freep>
 86e:	a039                	j	87c <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 870:	6398                	ld	a4,0(a5)
 872:	00e7e463          	bltu	a5,a4,87a <free+0x20>
 876:	00e6ea63          	bltu	a3,a4,88a <free+0x30>
{
 87a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87c:	fed7fae3          	bgeu	a5,a3,870 <free+0x16>
 880:	6398                	ld	a4,0(a5)
 882:	00e6e463          	bltu	a3,a4,88a <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 886:	fee7eae3          	bltu	a5,a4,87a <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 88a:	ff852583          	lw	a1,-8(a0)
 88e:	6390                	ld	a2,0(a5)
 890:	02059813          	slli	a6,a1,0x20
 894:	01c85713          	srli	a4,a6,0x1c
 898:	9736                	add	a4,a4,a3
 89a:	02e60563          	beq	a2,a4,8c4 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 89e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8a2:	4790                	lw	a2,8(a5)
 8a4:	02061593          	slli	a1,a2,0x20
 8a8:	01c5d713          	srli	a4,a1,0x1c
 8ac:	973e                	add	a4,a4,a5
 8ae:	02e68263          	beq	a3,a4,8d2 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8b2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8b4:	00000717          	auipc	a4,0x0
 8b8:	74f73e23          	sd	a5,1884(a4) # 1010 <freep>
}
 8bc:	60a2                	ld	ra,8(sp)
 8be:	6402                	ld	s0,0(sp)
 8c0:	0141                	addi	sp,sp,16
 8c2:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8c4:	4618                	lw	a4,8(a2)
 8c6:	9f2d                	addw	a4,a4,a1
 8c8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8cc:	6398                	ld	a4,0(a5)
 8ce:	6310                	ld	a2,0(a4)
 8d0:	b7f9                	j	89e <free+0x44>
    p->s.size += bp->s.size;
 8d2:	ff852703          	lw	a4,-8(a0)
 8d6:	9f31                	addw	a4,a4,a2
 8d8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8da:	ff053683          	ld	a3,-16(a0)
 8de:	bfd1                	j	8b2 <free+0x58>

00000000000008e0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e0:	7139                	addi	sp,sp,-64
 8e2:	fc06                	sd	ra,56(sp)
 8e4:	f822                	sd	s0,48(sp)
 8e6:	f04a                	sd	s2,32(sp)
 8e8:	ec4e                	sd	s3,24(sp)
 8ea:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ec:	02051993          	slli	s3,a0,0x20
 8f0:	0209d993          	srli	s3,s3,0x20
 8f4:	09bd                	addi	s3,s3,15
 8f6:	0049d993          	srli	s3,s3,0x4
 8fa:	2985                	addiw	s3,s3,1
 8fc:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8fe:	00000517          	auipc	a0,0x0
 902:	71253503          	ld	a0,1810(a0) # 1010 <freep>
 906:	c905                	beqz	a0,936 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 908:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90a:	4798                	lw	a4,8(a5)
 90c:	09377663          	bgeu	a4,s3,998 <malloc+0xb8>
 910:	f426                	sd	s1,40(sp)
 912:	e852                	sd	s4,16(sp)
 914:	e456                	sd	s5,8(sp)
 916:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 918:	8a4e                	mv	s4,s3
 91a:	6705                	lui	a4,0x1
 91c:	00e9f363          	bgeu	s3,a4,922 <malloc+0x42>
 920:	6a05                	lui	s4,0x1
 922:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 926:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 92a:	00000497          	auipc	s1,0x0
 92e:	6e648493          	addi	s1,s1,1766 # 1010 <freep>
  if(p == SBRK_ERROR)
 932:	5afd                	li	s5,-1
 934:	a83d                	j	972 <malloc+0x92>
 936:	f426                	sd	s1,40(sp)
 938:	e852                	sd	s4,16(sp)
 93a:	e456                	sd	s5,8(sp)
 93c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 93e:	00000797          	auipc	a5,0x0
 942:	6e278793          	addi	a5,a5,1762 # 1020 <base>
 946:	00000717          	auipc	a4,0x0
 94a:	6cf73523          	sd	a5,1738(a4) # 1010 <freep>
 94e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 950:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 954:	b7d1                	j	918 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 956:	6398                	ld	a4,0(a5)
 958:	e118                	sd	a4,0(a0)
 95a:	a899                	j	9b0 <malloc+0xd0>
  hp->s.size = nu;
 95c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 960:	0541                	addi	a0,a0,16
 962:	ef9ff0ef          	jal	85a <free>
  return freep;
 966:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 968:	c125                	beqz	a0,9c8 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 96c:	4798                	lw	a4,8(a5)
 96e:	03277163          	bgeu	a4,s2,990 <malloc+0xb0>
    if(p == freep)
 972:	6098                	ld	a4,0(s1)
 974:	853e                	mv	a0,a5
 976:	fef71ae3          	bne	a4,a5,96a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 97a:	8552                	mv	a0,s4
 97c:	9f3ff0ef          	jal	36e <sbrk>
  if(p == SBRK_ERROR)
 980:	fd551ee3          	bne	a0,s5,95c <malloc+0x7c>
        return 0;
 984:	4501                	li	a0,0
 986:	74a2                	ld	s1,40(sp)
 988:	6a42                	ld	s4,16(sp)
 98a:	6aa2                	ld	s5,8(sp)
 98c:	6b02                	ld	s6,0(sp)
 98e:	a03d                	j	9bc <malloc+0xdc>
 990:	74a2                	ld	s1,40(sp)
 992:	6a42                	ld	s4,16(sp)
 994:	6aa2                	ld	s5,8(sp)
 996:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 998:	fae90fe3          	beq	s2,a4,956 <malloc+0x76>
        p->s.size -= nunits;
 99c:	4137073b          	subw	a4,a4,s3
 9a0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9a2:	02071693          	slli	a3,a4,0x20
 9a6:	01c6d713          	srli	a4,a3,0x1c
 9aa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9ac:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9b0:	00000717          	auipc	a4,0x0
 9b4:	66a73023          	sd	a0,1632(a4) # 1010 <freep>
      return (void*)(p + 1);
 9b8:	01078513          	addi	a0,a5,16
  }
}
 9bc:	70e2                	ld	ra,56(sp)
 9be:	7442                	ld	s0,48(sp)
 9c0:	7902                	ld	s2,32(sp)
 9c2:	69e2                	ld	s3,24(sp)
 9c4:	6121                	addi	sp,sp,64
 9c6:	8082                	ret
 9c8:	74a2                	ld	s1,40(sp)
 9ca:	6a42                	ld	s4,16(sp)
 9cc:	6aa2                	ld	s5,8(sp)
 9ce:	6b02                	ld	s6,0(sp)
 9d0:	b7f5                	j	9bc <malloc+0xdc>
