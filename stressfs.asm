
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 30 02 00 00    	sub    $0x230,%esp
  int fd, i;
  char path[] = "stressfs0";
   c:	c7 84 24 1e 02 00 00 	movl   $0x65727473,0x21e(%esp)
  13:	73 74 72 65 
  17:	c7 84 24 22 02 00 00 	movl   $0x73667373,0x222(%esp)
  1e:	73 73 66 73 
  22:	66 c7 84 24 26 02 00 	movw   $0x30,0x226(%esp)
  29:	00 30 00 
  char data[512];

  printf(1, "stressfs starting\n");
  2c:	c7 44 24 04 7f 09 00 	movl   $0x97f,0x4(%esp)
  33:	00 
  34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3b:	e8 73 05 00 00       	call   5b3 <printf>
  memset(data, 'a', sizeof(data));
  40:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  47:	00 
  48:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  4f:	00 
  50:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 12 02 00 00       	call   26e <memset>

  for(i = 0; i < 4; i++)
  5c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  63:	00 00 00 00 
  67:	eb 13                	jmp    7c <main+0x7c>
    if(fork() > 0)
  69:	e8 a5 03 00 00       	call   413 <fork>
  6e:	85 c0                	test   %eax,%eax
  70:	7e 02                	jle    74 <main+0x74>
      break;
  72:	eb 12                	jmp    86 <main+0x86>
  char data[512];

  printf(1, "stressfs starting\n");
  memset(data, 'a', sizeof(data));

  for(i = 0; i < 4; i++)
  74:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
  7b:	01 
  7c:	83 bc 24 2c 02 00 00 	cmpl   $0x3,0x22c(%esp)
  83:	03 
  84:	7e e3                	jle    69 <main+0x69>
    if(fork() > 0)
      break;

  printf(1, "write %d\n", i);
  86:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  91:	c7 44 24 04 92 09 00 	movl   $0x992,0x4(%esp)
  98:	00 
  99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a0:	e8 0e 05 00 00       	call   5b3 <printf>

  path[8] += i;
  a5:	0f b6 84 24 26 02 00 	movzbl 0x226(%esp),%eax
  ac:	00 
  ad:	89 c2                	mov    %eax,%edx
  af:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  b6:	01 d0                	add    %edx,%eax
  b8:	88 84 24 26 02 00 00 	mov    %al,0x226(%esp)
  fd = open(path, O_CREATE | O_RDWR);
  bf:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  c6:	00 
  c7:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
  ce:	89 04 24             	mov    %eax,(%esp)
  d1:	e8 85 03 00 00       	call   45b <open>
  d6:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for(i = 0; i < 20; i++)
  dd:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  e4:	00 00 00 00 
  e8:	eb 27                	jmp    111 <main+0x111>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  ea:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  f1:	00 
  f2:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  fa:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 101:	89 04 24             	mov    %eax,(%esp)
 104:	e8 32 03 00 00       	call   43b <write>

  printf(1, "write %d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 20; i++)
 109:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 110:	01 
 111:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 118:	13 
 119:	7e cf                	jle    ea <main+0xea>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  close(fd);
 11b:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 122:	89 04 24             	mov    %eax,(%esp)
 125:	e8 19 03 00 00       	call   443 <close>

  printf(1, "read\n");
 12a:	c7 44 24 04 9c 09 00 	movl   $0x99c,0x4(%esp)
 131:	00 
 132:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 139:	e8 75 04 00 00       	call   5b3 <printf>

  fd = open(path, O_RDONLY);
 13e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 145:	00 
 146:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
 14d:	89 04 24             	mov    %eax,(%esp)
 150:	e8 06 03 00 00       	call   45b <open>
 155:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for (i = 0; i < 20; i++)
 15c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
 163:	00 00 00 00 
 167:	eb 27                	jmp    190 <main+0x190>
    read(fd, data, sizeof(data));
 169:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 170:	00 
 171:	8d 44 24 1e          	lea    0x1e(%esp),%eax
 175:	89 44 24 04          	mov    %eax,0x4(%esp)
 179:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 180:	89 04 24             	mov    %eax,(%esp)
 183:	e8 ab 02 00 00       	call   433 <read>
  close(fd);

  printf(1, "read\n");

  fd = open(path, O_RDONLY);
  for (i = 0; i < 20; i++)
 188:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 18f:	01 
 190:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 197:	13 
 198:	7e cf                	jle    169 <main+0x169>
    read(fd, data, sizeof(data));
  close(fd);
 19a:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 1a1:	89 04 24             	mov    %eax,(%esp)
 1a4:	e8 9a 02 00 00       	call   443 <close>

  wait();
 1a9:	e8 75 02 00 00       	call   423 <wait>
  
  exit();
 1ae:	e8 68 02 00 00       	call   41b <exit>

000001b3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1b3:	55                   	push   %ebp
 1b4:	89 e5                	mov    %esp,%ebp
 1b6:	57                   	push   %edi
 1b7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1bb:	8b 55 10             	mov    0x10(%ebp),%edx
 1be:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c1:	89 cb                	mov    %ecx,%ebx
 1c3:	89 df                	mov    %ebx,%edi
 1c5:	89 d1                	mov    %edx,%ecx
 1c7:	fc                   	cld    
 1c8:	f3 aa                	rep stos %al,%es:(%edi)
 1ca:	89 ca                	mov    %ecx,%edx
 1cc:	89 fb                	mov    %edi,%ebx
 1ce:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1d1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1d4:	5b                   	pop    %ebx
 1d5:	5f                   	pop    %edi
 1d6:	5d                   	pop    %ebp
 1d7:	c3                   	ret    

000001d8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1e4:	90                   	nop
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
 1e8:	8d 50 01             	lea    0x1(%eax),%edx
 1eb:	89 55 08             	mov    %edx,0x8(%ebp)
 1ee:	8b 55 0c             	mov    0xc(%ebp),%edx
 1f1:	8d 4a 01             	lea    0x1(%edx),%ecx
 1f4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1f7:	0f b6 12             	movzbl (%edx),%edx
 1fa:	88 10                	mov    %dl,(%eax)
 1fc:	0f b6 00             	movzbl (%eax),%eax
 1ff:	84 c0                	test   %al,%al
 201:	75 e2                	jne    1e5 <strcpy+0xd>
    ;
  return os;
 203:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 206:	c9                   	leave  
 207:	c3                   	ret    

00000208 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 20b:	eb 08                	jmp    215 <strcmp+0xd>
    p++, q++;
 20d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 211:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	0f b6 00             	movzbl (%eax),%eax
 21b:	84 c0                	test   %al,%al
 21d:	74 10                	je     22f <strcmp+0x27>
 21f:	8b 45 08             	mov    0x8(%ebp),%eax
 222:	0f b6 10             	movzbl (%eax),%edx
 225:	8b 45 0c             	mov    0xc(%ebp),%eax
 228:	0f b6 00             	movzbl (%eax),%eax
 22b:	38 c2                	cmp    %al,%dl
 22d:	74 de                	je     20d <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	0f b6 00             	movzbl (%eax),%eax
 235:	0f b6 d0             	movzbl %al,%edx
 238:	8b 45 0c             	mov    0xc(%ebp),%eax
 23b:	0f b6 00             	movzbl (%eax),%eax
 23e:	0f b6 c0             	movzbl %al,%eax
 241:	29 c2                	sub    %eax,%edx
 243:	89 d0                	mov    %edx,%eax
}
 245:	5d                   	pop    %ebp
 246:	c3                   	ret    

00000247 <strlen>:

uint
strlen(char *s)
{
 247:	55                   	push   %ebp
 248:	89 e5                	mov    %esp,%ebp
 24a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 24d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 254:	eb 04                	jmp    25a <strlen+0x13>
 256:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 25a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 25d:	8b 45 08             	mov    0x8(%ebp),%eax
 260:	01 d0                	add    %edx,%eax
 262:	0f b6 00             	movzbl (%eax),%eax
 265:	84 c0                	test   %al,%al
 267:	75 ed                	jne    256 <strlen+0xf>
    ;
  return n;
 269:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 26c:	c9                   	leave  
 26d:	c3                   	ret    

0000026e <memset>:

void*
memset(void *dst, int c, uint n)
{
 26e:	55                   	push   %ebp
 26f:	89 e5                	mov    %esp,%ebp
 271:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 274:	8b 45 10             	mov    0x10(%ebp),%eax
 277:	89 44 24 08          	mov    %eax,0x8(%esp)
 27b:	8b 45 0c             	mov    0xc(%ebp),%eax
 27e:	89 44 24 04          	mov    %eax,0x4(%esp)
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	89 04 24             	mov    %eax,(%esp)
 288:	e8 26 ff ff ff       	call   1b3 <stosb>
  return dst;
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 290:	c9                   	leave  
 291:	c3                   	ret    

00000292 <strchr>:

char*
strchr(const char *s, char c)
{
 292:	55                   	push   %ebp
 293:	89 e5                	mov    %esp,%ebp
 295:	83 ec 04             	sub    $0x4,%esp
 298:	8b 45 0c             	mov    0xc(%ebp),%eax
 29b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 29e:	eb 14                	jmp    2b4 <strchr+0x22>
    if(*s == c)
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
 2a3:	0f b6 00             	movzbl (%eax),%eax
 2a6:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2a9:	75 05                	jne    2b0 <strchr+0x1e>
      return (char*)s;
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
 2ae:	eb 13                	jmp    2c3 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	0f b6 00             	movzbl (%eax),%eax
 2ba:	84 c0                	test   %al,%al
 2bc:	75 e2                	jne    2a0 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2be:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c3:	c9                   	leave  
 2c4:	c3                   	ret    

000002c5 <gets>:

char*
gets(char *buf, int max)
{
 2c5:	55                   	push   %ebp
 2c6:	89 e5                	mov    %esp,%ebp
 2c8:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2d2:	eb 4c                	jmp    320 <gets+0x5b>
    cc = read(0, &c, 1);
 2d4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2db:	00 
 2dc:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2df:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2ea:	e8 44 01 00 00       	call   433 <read>
 2ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2f6:	7f 02                	jg     2fa <gets+0x35>
      break;
 2f8:	eb 31                	jmp    32b <gets+0x66>
    buf[i++] = c;
 2fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fd:	8d 50 01             	lea    0x1(%eax),%edx
 300:	89 55 f4             	mov    %edx,-0xc(%ebp)
 303:	89 c2                	mov    %eax,%edx
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	01 c2                	add    %eax,%edx
 30a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 30e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 310:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 314:	3c 0a                	cmp    $0xa,%al
 316:	74 13                	je     32b <gets+0x66>
 318:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 31c:	3c 0d                	cmp    $0xd,%al
 31e:	74 0b                	je     32b <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 320:	8b 45 f4             	mov    -0xc(%ebp),%eax
 323:	83 c0 01             	add    $0x1,%eax
 326:	3b 45 0c             	cmp    0xc(%ebp),%eax
 329:	7c a9                	jl     2d4 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 32b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	01 d0                	add    %edx,%eax
 333:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 336:	8b 45 08             	mov    0x8(%ebp),%eax
}
 339:	c9                   	leave  
 33a:	c3                   	ret    

0000033b <stat>:

int
stat(char *n, struct stat *st)
{
 33b:	55                   	push   %ebp
 33c:	89 e5                	mov    %esp,%ebp
 33e:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 341:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 348:	00 
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	89 04 24             	mov    %eax,(%esp)
 34f:	e8 07 01 00 00       	call   45b <open>
 354:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 357:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 35b:	79 07                	jns    364 <stat+0x29>
    return -1;
 35d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 362:	eb 23                	jmp    387 <stat+0x4c>
  r = fstat(fd, st);
 364:	8b 45 0c             	mov    0xc(%ebp),%eax
 367:	89 44 24 04          	mov    %eax,0x4(%esp)
 36b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 36e:	89 04 24             	mov    %eax,(%esp)
 371:	e8 fd 00 00 00       	call   473 <fstat>
 376:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 379:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37c:	89 04 24             	mov    %eax,(%esp)
 37f:	e8 bf 00 00 00       	call   443 <close>
  return r;
 384:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 387:	c9                   	leave  
 388:	c3                   	ret    

00000389 <atoi>:

int
atoi(const char *s)
{
 389:	55                   	push   %ebp
 38a:	89 e5                	mov    %esp,%ebp
 38c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 38f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 396:	eb 25                	jmp    3bd <atoi+0x34>
    n = n*10 + *s++ - '0';
 398:	8b 55 fc             	mov    -0x4(%ebp),%edx
 39b:	89 d0                	mov    %edx,%eax
 39d:	c1 e0 02             	shl    $0x2,%eax
 3a0:	01 d0                	add    %edx,%eax
 3a2:	01 c0                	add    %eax,%eax
 3a4:	89 c1                	mov    %eax,%ecx
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	8d 50 01             	lea    0x1(%eax),%edx
 3ac:	89 55 08             	mov    %edx,0x8(%ebp)
 3af:	0f b6 00             	movzbl (%eax),%eax
 3b2:	0f be c0             	movsbl %al,%eax
 3b5:	01 c8                	add    %ecx,%eax
 3b7:	83 e8 30             	sub    $0x30,%eax
 3ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	0f b6 00             	movzbl (%eax),%eax
 3c3:	3c 2f                	cmp    $0x2f,%al
 3c5:	7e 0a                	jle    3d1 <atoi+0x48>
 3c7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ca:	0f b6 00             	movzbl (%eax),%eax
 3cd:	3c 39                	cmp    $0x39,%al
 3cf:	7e c7                	jle    398 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d4:	c9                   	leave  
 3d5:	c3                   	ret    

000003d6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3d6:	55                   	push   %ebp
 3d7:	89 e5                	mov    %esp,%ebp
 3d9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3dc:	8b 45 08             	mov    0x8(%ebp),%eax
 3df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3e8:	eb 17                	jmp    401 <memmove+0x2b>
    *dst++ = *src++;
 3ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ed:	8d 50 01             	lea    0x1(%eax),%edx
 3f0:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3f3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3f6:	8d 4a 01             	lea    0x1(%edx),%ecx
 3f9:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3fc:	0f b6 12             	movzbl (%edx),%edx
 3ff:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 401:	8b 45 10             	mov    0x10(%ebp),%eax
 404:	8d 50 ff             	lea    -0x1(%eax),%edx
 407:	89 55 10             	mov    %edx,0x10(%ebp)
 40a:	85 c0                	test   %eax,%eax
 40c:	7f dc                	jg     3ea <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 40e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 411:	c9                   	leave  
 412:	c3                   	ret    

00000413 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 413:	b8 01 00 00 00       	mov    $0x1,%eax
 418:	cd 40                	int    $0x40
 41a:	c3                   	ret    

0000041b <exit>:
SYSCALL(exit)
 41b:	b8 02 00 00 00       	mov    $0x2,%eax
 420:	cd 40                	int    $0x40
 422:	c3                   	ret    

00000423 <wait>:
SYSCALL(wait)
 423:	b8 03 00 00 00       	mov    $0x3,%eax
 428:	cd 40                	int    $0x40
 42a:	c3                   	ret    

0000042b <pipe>:
SYSCALL(pipe)
 42b:	b8 04 00 00 00       	mov    $0x4,%eax
 430:	cd 40                	int    $0x40
 432:	c3                   	ret    

00000433 <read>:
SYSCALL(read)
 433:	b8 05 00 00 00       	mov    $0x5,%eax
 438:	cd 40                	int    $0x40
 43a:	c3                   	ret    

0000043b <write>:
SYSCALL(write)
 43b:	b8 10 00 00 00       	mov    $0x10,%eax
 440:	cd 40                	int    $0x40
 442:	c3                   	ret    

00000443 <close>:
SYSCALL(close)
 443:	b8 15 00 00 00       	mov    $0x15,%eax
 448:	cd 40                	int    $0x40
 44a:	c3                   	ret    

0000044b <kill>:
SYSCALL(kill)
 44b:	b8 06 00 00 00       	mov    $0x6,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	ret    

00000453 <exec>:
SYSCALL(exec)
 453:	b8 07 00 00 00       	mov    $0x7,%eax
 458:	cd 40                	int    $0x40
 45a:	c3                   	ret    

0000045b <open>:
SYSCALL(open)
 45b:	b8 0f 00 00 00       	mov    $0xf,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	ret    

00000463 <mknod>:
SYSCALL(mknod)
 463:	b8 11 00 00 00       	mov    $0x11,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret    

0000046b <unlink>:
SYSCALL(unlink)
 46b:	b8 12 00 00 00       	mov    $0x12,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret    

00000473 <fstat>:
SYSCALL(fstat)
 473:	b8 08 00 00 00       	mov    $0x8,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret    

0000047b <link>:
SYSCALL(link)
 47b:	b8 13 00 00 00       	mov    $0x13,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	ret    

00000483 <mkdir>:
SYSCALL(mkdir)
 483:	b8 14 00 00 00       	mov    $0x14,%eax
 488:	cd 40                	int    $0x40
 48a:	c3                   	ret    

0000048b <chdir>:
SYSCALL(chdir)
 48b:	b8 09 00 00 00       	mov    $0x9,%eax
 490:	cd 40                	int    $0x40
 492:	c3                   	ret    

00000493 <dup>:
SYSCALL(dup)
 493:	b8 0a 00 00 00       	mov    $0xa,%eax
 498:	cd 40                	int    $0x40
 49a:	c3                   	ret    

0000049b <getpid>:
SYSCALL(getpid)
 49b:	b8 0b 00 00 00       	mov    $0xb,%eax
 4a0:	cd 40                	int    $0x40
 4a2:	c3                   	ret    

000004a3 <sbrk>:
SYSCALL(sbrk)
 4a3:	b8 0c 00 00 00       	mov    $0xc,%eax
 4a8:	cd 40                	int    $0x40
 4aa:	c3                   	ret    

000004ab <sleep>:
SYSCALL(sleep)
 4ab:	b8 0d 00 00 00       	mov    $0xd,%eax
 4b0:	cd 40                	int    $0x40
 4b2:	c3                   	ret    

000004b3 <uptime>:
SYSCALL(uptime)
 4b3:	b8 0e 00 00 00       	mov    $0xe,%eax
 4b8:	cd 40                	int    $0x40
 4ba:	c3                   	ret    

000004bb <sigset>:
SYSCALL(sigset)
 4bb:	b8 16 00 00 00       	mov    $0x16,%eax
 4c0:	cd 40                	int    $0x40
 4c2:	c3                   	ret    

000004c3 <sigsend>:
SYSCALL(sigsend)
 4c3:	b8 17 00 00 00       	mov    $0x17,%eax
 4c8:	cd 40                	int    $0x40
 4ca:	c3                   	ret    

000004cb <sigpause>:
 4cb:	b8 19 00 00 00       	mov    $0x19,%eax
 4d0:	cd 40                	int    $0x40
 4d2:	c3                   	ret    

000004d3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4d3:	55                   	push   %ebp
 4d4:	89 e5                	mov    %esp,%ebp
 4d6:	83 ec 18             	sub    $0x18,%esp
 4d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4dc:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4df:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4e6:	00 
 4e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	89 04 24             	mov    %eax,(%esp)
 4f4:	e8 42 ff ff ff       	call   43b <write>
}
 4f9:	c9                   	leave  
 4fa:	c3                   	ret    

000004fb <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4fb:	55                   	push   %ebp
 4fc:	89 e5                	mov    %esp,%ebp
 4fe:	56                   	push   %esi
 4ff:	53                   	push   %ebx
 500:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 503:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 50a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 50e:	74 17                	je     527 <printint+0x2c>
 510:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 514:	79 11                	jns    527 <printint+0x2c>
    neg = 1;
 516:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 51d:	8b 45 0c             	mov    0xc(%ebp),%eax
 520:	f7 d8                	neg    %eax
 522:	89 45 ec             	mov    %eax,-0x14(%ebp)
 525:	eb 06                	jmp    52d <printint+0x32>
  } else {
    x = xx;
 527:	8b 45 0c             	mov    0xc(%ebp),%eax
 52a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 52d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 534:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 537:	8d 41 01             	lea    0x1(%ecx),%eax
 53a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 53d:	8b 5d 10             	mov    0x10(%ebp),%ebx
 540:	8b 45 ec             	mov    -0x14(%ebp),%eax
 543:	ba 00 00 00 00       	mov    $0x0,%edx
 548:	f7 f3                	div    %ebx
 54a:	89 d0                	mov    %edx,%eax
 54c:	0f b6 80 f0 0b 00 00 	movzbl 0xbf0(%eax),%eax
 553:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 557:	8b 75 10             	mov    0x10(%ebp),%esi
 55a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 55d:	ba 00 00 00 00       	mov    $0x0,%edx
 562:	f7 f6                	div    %esi
 564:	89 45 ec             	mov    %eax,-0x14(%ebp)
 567:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 56b:	75 c7                	jne    534 <printint+0x39>
  if(neg)
 56d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 571:	74 10                	je     583 <printint+0x88>
    buf[i++] = '-';
 573:	8b 45 f4             	mov    -0xc(%ebp),%eax
 576:	8d 50 01             	lea    0x1(%eax),%edx
 579:	89 55 f4             	mov    %edx,-0xc(%ebp)
 57c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 581:	eb 1f                	jmp    5a2 <printint+0xa7>
 583:	eb 1d                	jmp    5a2 <printint+0xa7>
    putc(fd, buf[i]);
 585:	8d 55 dc             	lea    -0x24(%ebp),%edx
 588:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58b:	01 d0                	add    %edx,%eax
 58d:	0f b6 00             	movzbl (%eax),%eax
 590:	0f be c0             	movsbl %al,%eax
 593:	89 44 24 04          	mov    %eax,0x4(%esp)
 597:	8b 45 08             	mov    0x8(%ebp),%eax
 59a:	89 04 24             	mov    %eax,(%esp)
 59d:	e8 31 ff ff ff       	call   4d3 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5a2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5aa:	79 d9                	jns    585 <printint+0x8a>
    putc(fd, buf[i]);
}
 5ac:	83 c4 30             	add    $0x30,%esp
 5af:	5b                   	pop    %ebx
 5b0:	5e                   	pop    %esi
 5b1:	5d                   	pop    %ebp
 5b2:	c3                   	ret    

000005b3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5b3:	55                   	push   %ebp
 5b4:	89 e5                	mov    %esp,%ebp
 5b6:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5b9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5c0:	8d 45 0c             	lea    0xc(%ebp),%eax
 5c3:	83 c0 04             	add    $0x4,%eax
 5c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5d0:	e9 7c 01 00 00       	jmp    751 <printf+0x19e>
    c = fmt[i] & 0xff;
 5d5:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5db:	01 d0                	add    %edx,%eax
 5dd:	0f b6 00             	movzbl (%eax),%eax
 5e0:	0f be c0             	movsbl %al,%eax
 5e3:	25 ff 00 00 00       	and    $0xff,%eax
 5e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5ef:	75 2c                	jne    61d <printf+0x6a>
      if(c == '%'){
 5f1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f5:	75 0c                	jne    603 <printf+0x50>
        state = '%';
 5f7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5fe:	e9 4a 01 00 00       	jmp    74d <printf+0x19a>
      } else {
        putc(fd, c);
 603:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 606:	0f be c0             	movsbl %al,%eax
 609:	89 44 24 04          	mov    %eax,0x4(%esp)
 60d:	8b 45 08             	mov    0x8(%ebp),%eax
 610:	89 04 24             	mov    %eax,(%esp)
 613:	e8 bb fe ff ff       	call   4d3 <putc>
 618:	e9 30 01 00 00       	jmp    74d <printf+0x19a>
      }
    } else if(state == '%'){
 61d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 621:	0f 85 26 01 00 00    	jne    74d <printf+0x19a>
      if(c == 'd'){
 627:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 62b:	75 2d                	jne    65a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 62d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 630:	8b 00                	mov    (%eax),%eax
 632:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 639:	00 
 63a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 641:	00 
 642:	89 44 24 04          	mov    %eax,0x4(%esp)
 646:	8b 45 08             	mov    0x8(%ebp),%eax
 649:	89 04 24             	mov    %eax,(%esp)
 64c:	e8 aa fe ff ff       	call   4fb <printint>
        ap++;
 651:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 655:	e9 ec 00 00 00       	jmp    746 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 65a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 65e:	74 06                	je     666 <printf+0xb3>
 660:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 664:	75 2d                	jne    693 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 666:	8b 45 e8             	mov    -0x18(%ebp),%eax
 669:	8b 00                	mov    (%eax),%eax
 66b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 672:	00 
 673:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 67a:	00 
 67b:	89 44 24 04          	mov    %eax,0x4(%esp)
 67f:	8b 45 08             	mov    0x8(%ebp),%eax
 682:	89 04 24             	mov    %eax,(%esp)
 685:	e8 71 fe ff ff       	call   4fb <printint>
        ap++;
 68a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 68e:	e9 b3 00 00 00       	jmp    746 <printf+0x193>
      } else if(c == 's'){
 693:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 697:	75 45                	jne    6de <printf+0x12b>
        s = (char*)*ap;
 699:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69c:	8b 00                	mov    (%eax),%eax
 69e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6a9:	75 09                	jne    6b4 <printf+0x101>
          s = "(null)";
 6ab:	c7 45 f4 a2 09 00 00 	movl   $0x9a2,-0xc(%ebp)
        while(*s != 0){
 6b2:	eb 1e                	jmp    6d2 <printf+0x11f>
 6b4:	eb 1c                	jmp    6d2 <printf+0x11f>
          putc(fd, *s);
 6b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b9:	0f b6 00             	movzbl (%eax),%eax
 6bc:	0f be c0             	movsbl %al,%eax
 6bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c3:	8b 45 08             	mov    0x8(%ebp),%eax
 6c6:	89 04 24             	mov    %eax,(%esp)
 6c9:	e8 05 fe ff ff       	call   4d3 <putc>
          s++;
 6ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d5:	0f b6 00             	movzbl (%eax),%eax
 6d8:	84 c0                	test   %al,%al
 6da:	75 da                	jne    6b6 <printf+0x103>
 6dc:	eb 68                	jmp    746 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6de:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6e2:	75 1d                	jne    701 <printf+0x14e>
        putc(fd, *ap);
 6e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e7:	8b 00                	mov    (%eax),%eax
 6e9:	0f be c0             	movsbl %al,%eax
 6ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f0:	8b 45 08             	mov    0x8(%ebp),%eax
 6f3:	89 04 24             	mov    %eax,(%esp)
 6f6:	e8 d8 fd ff ff       	call   4d3 <putc>
        ap++;
 6fb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ff:	eb 45                	jmp    746 <printf+0x193>
      } else if(c == '%'){
 701:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 705:	75 17                	jne    71e <printf+0x16b>
        putc(fd, c);
 707:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70a:	0f be c0             	movsbl %al,%eax
 70d:	89 44 24 04          	mov    %eax,0x4(%esp)
 711:	8b 45 08             	mov    0x8(%ebp),%eax
 714:	89 04 24             	mov    %eax,(%esp)
 717:	e8 b7 fd ff ff       	call   4d3 <putc>
 71c:	eb 28                	jmp    746 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 71e:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 725:	00 
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	89 04 24             	mov    %eax,(%esp)
 72c:	e8 a2 fd ff ff       	call   4d3 <putc>
        putc(fd, c);
 731:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 734:	0f be c0             	movsbl %al,%eax
 737:	89 44 24 04          	mov    %eax,0x4(%esp)
 73b:	8b 45 08             	mov    0x8(%ebp),%eax
 73e:	89 04 24             	mov    %eax,(%esp)
 741:	e8 8d fd ff ff       	call   4d3 <putc>
      }
      state = 0;
 746:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 74d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 751:	8b 55 0c             	mov    0xc(%ebp),%edx
 754:	8b 45 f0             	mov    -0x10(%ebp),%eax
 757:	01 d0                	add    %edx,%eax
 759:	0f b6 00             	movzbl (%eax),%eax
 75c:	84 c0                	test   %al,%al
 75e:	0f 85 71 fe ff ff    	jne    5d5 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 764:	c9                   	leave  
 765:	c3                   	ret    

00000766 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 766:	55                   	push   %ebp
 767:	89 e5                	mov    %esp,%ebp
 769:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76c:	8b 45 08             	mov    0x8(%ebp),%eax
 76f:	83 e8 08             	sub    $0x8,%eax
 772:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 775:	a1 0c 0c 00 00       	mov    0xc0c,%eax
 77a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 77d:	eb 24                	jmp    7a3 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 782:	8b 00                	mov    (%eax),%eax
 784:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 787:	77 12                	ja     79b <free+0x35>
 789:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 78f:	77 24                	ja     7b5 <free+0x4f>
 791:	8b 45 fc             	mov    -0x4(%ebp),%eax
 794:	8b 00                	mov    (%eax),%eax
 796:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 799:	77 1a                	ja     7b5 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79e:	8b 00                	mov    (%eax),%eax
 7a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a9:	76 d4                	jbe    77f <free+0x19>
 7ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ae:	8b 00                	mov    (%eax),%eax
 7b0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b3:	76 ca                	jbe    77f <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b8:	8b 40 04             	mov    0x4(%eax),%eax
 7bb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c5:	01 c2                	add    %eax,%edx
 7c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ca:	8b 00                	mov    (%eax),%eax
 7cc:	39 c2                	cmp    %eax,%edx
 7ce:	75 24                	jne    7f4 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d3:	8b 50 04             	mov    0x4(%eax),%edx
 7d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d9:	8b 00                	mov    (%eax),%eax
 7db:	8b 40 04             	mov    0x4(%eax),%eax
 7de:	01 c2                	add    %eax,%edx
 7e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e9:	8b 00                	mov    (%eax),%eax
 7eb:	8b 10                	mov    (%eax),%edx
 7ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f0:	89 10                	mov    %edx,(%eax)
 7f2:	eb 0a                	jmp    7fe <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f7:	8b 10                	mov    (%eax),%edx
 7f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fc:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 801:	8b 40 04             	mov    0x4(%eax),%eax
 804:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 80b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80e:	01 d0                	add    %edx,%eax
 810:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 813:	75 20                	jne    835 <free+0xcf>
    p->s.size += bp->s.size;
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	8b 50 04             	mov    0x4(%eax),%edx
 81b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81e:	8b 40 04             	mov    0x4(%eax),%eax
 821:	01 c2                	add    %eax,%edx
 823:	8b 45 fc             	mov    -0x4(%ebp),%eax
 826:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 829:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82c:	8b 10                	mov    (%eax),%edx
 82e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 831:	89 10                	mov    %edx,(%eax)
 833:	eb 08                	jmp    83d <free+0xd7>
  } else
    p->s.ptr = bp;
 835:	8b 45 fc             	mov    -0x4(%ebp),%eax
 838:	8b 55 f8             	mov    -0x8(%ebp),%edx
 83b:	89 10                	mov    %edx,(%eax)
  freep = p;
 83d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 840:	a3 0c 0c 00 00       	mov    %eax,0xc0c
}
 845:	c9                   	leave  
 846:	c3                   	ret    

00000847 <morecore>:

static Header*
morecore(uint nu)
{
 847:	55                   	push   %ebp
 848:	89 e5                	mov    %esp,%ebp
 84a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 84d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 854:	77 07                	ja     85d <morecore+0x16>
    nu = 4096;
 856:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 85d:	8b 45 08             	mov    0x8(%ebp),%eax
 860:	c1 e0 03             	shl    $0x3,%eax
 863:	89 04 24             	mov    %eax,(%esp)
 866:	e8 38 fc ff ff       	call   4a3 <sbrk>
 86b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 86e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 872:	75 07                	jne    87b <morecore+0x34>
    return 0;
 874:	b8 00 00 00 00       	mov    $0x0,%eax
 879:	eb 22                	jmp    89d <morecore+0x56>
  hp = (Header*)p;
 87b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 881:	8b 45 f0             	mov    -0x10(%ebp),%eax
 884:	8b 55 08             	mov    0x8(%ebp),%edx
 887:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 88a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88d:	83 c0 08             	add    $0x8,%eax
 890:	89 04 24             	mov    %eax,(%esp)
 893:	e8 ce fe ff ff       	call   766 <free>
  return freep;
 898:	a1 0c 0c 00 00       	mov    0xc0c,%eax
}
 89d:	c9                   	leave  
 89e:	c3                   	ret    

0000089f <malloc>:

void*
malloc(uint nbytes)
{
 89f:	55                   	push   %ebp
 8a0:	89 e5                	mov    %esp,%ebp
 8a2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a5:	8b 45 08             	mov    0x8(%ebp),%eax
 8a8:	83 c0 07             	add    $0x7,%eax
 8ab:	c1 e8 03             	shr    $0x3,%eax
 8ae:	83 c0 01             	add    $0x1,%eax
 8b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8b4:	a1 0c 0c 00 00       	mov    0xc0c,%eax
 8b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8c0:	75 23                	jne    8e5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8c2:	c7 45 f0 04 0c 00 00 	movl   $0xc04,-0x10(%ebp)
 8c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cc:	a3 0c 0c 00 00       	mov    %eax,0xc0c
 8d1:	a1 0c 0c 00 00       	mov    0xc0c,%eax
 8d6:	a3 04 0c 00 00       	mov    %eax,0xc04
    base.s.size = 0;
 8db:	c7 05 08 0c 00 00 00 	movl   $0x0,0xc08
 8e2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e8:	8b 00                	mov    (%eax),%eax
 8ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f0:	8b 40 04             	mov    0x4(%eax),%eax
 8f3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f6:	72 4d                	jb     945 <malloc+0xa6>
      if(p->s.size == nunits)
 8f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fb:	8b 40 04             	mov    0x4(%eax),%eax
 8fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 901:	75 0c                	jne    90f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 903:	8b 45 f4             	mov    -0xc(%ebp),%eax
 906:	8b 10                	mov    (%eax),%edx
 908:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90b:	89 10                	mov    %edx,(%eax)
 90d:	eb 26                	jmp    935 <malloc+0x96>
      else {
        p->s.size -= nunits;
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	8b 40 04             	mov    0x4(%eax),%eax
 915:	2b 45 ec             	sub    -0x14(%ebp),%eax
 918:	89 c2                	mov    %eax,%edx
 91a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 920:	8b 45 f4             	mov    -0xc(%ebp),%eax
 923:	8b 40 04             	mov    0x4(%eax),%eax
 926:	c1 e0 03             	shl    $0x3,%eax
 929:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 92c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 932:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 935:	8b 45 f0             	mov    -0x10(%ebp),%eax
 938:	a3 0c 0c 00 00       	mov    %eax,0xc0c
      return (void*)(p + 1);
 93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 940:	83 c0 08             	add    $0x8,%eax
 943:	eb 38                	jmp    97d <malloc+0xde>
    }
    if(p == freep)
 945:	a1 0c 0c 00 00       	mov    0xc0c,%eax
 94a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 94d:	75 1b                	jne    96a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 94f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 952:	89 04 24             	mov    %eax,(%esp)
 955:	e8 ed fe ff ff       	call   847 <morecore>
 95a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 95d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 961:	75 07                	jne    96a <malloc+0xcb>
        return 0;
 963:	b8 00 00 00 00       	mov    $0x0,%eax
 968:	eb 13                	jmp    97d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	8b 00                	mov    (%eax),%eax
 975:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 978:	e9 70 ff ff ff       	jmp    8ed <malloc+0x4e>
}
 97d:	c9                   	leave  
 97e:	c3                   	ret    
