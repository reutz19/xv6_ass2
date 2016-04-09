
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(argc != 3){
   9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
   d:	74 19                	je     28 <main+0x28>
    printf(2, "Usage: ln old new\n");
   f:	c7 44 24 04 3d 08 00 	movl   $0x83d,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 4e 04 00 00       	call   471 <printf>
    exit();
  23:	e8 b9 02 00 00       	call   2e1 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 08             	add    $0x8,%eax
  2e:	8b 10                	mov    (%eax),%edx
  30:	8b 45 0c             	mov    0xc(%ebp),%eax
  33:	83 c0 04             	add    $0x4,%eax
  36:	8b 00                	mov    (%eax),%eax
  38:	89 54 24 04          	mov    %edx,0x4(%esp)
  3c:	89 04 24             	mov    %eax,(%esp)
  3f:	e8 fd 02 00 00       	call   341 <link>
  44:	85 c0                	test   %eax,%eax
  46:	79 2c                	jns    74 <main+0x74>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	8b 45 0c             	mov    0xc(%ebp),%eax
  4b:	83 c0 08             	add    $0x8,%eax
  4e:	8b 10                	mov    (%eax),%edx
  50:	8b 45 0c             	mov    0xc(%ebp),%eax
  53:	83 c0 04             	add    $0x4,%eax
  56:	8b 00                	mov    (%eax),%eax
  58:	89 54 24 0c          	mov    %edx,0xc(%esp)
  5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  60:	c7 44 24 04 50 08 00 	movl   $0x850,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 fd 03 00 00       	call   471 <printf>
  exit();
  74:	e8 68 02 00 00       	call   2e1 <exit>

00000079 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  7c:	57                   	push   %edi
  7d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  81:	8b 55 10             	mov    0x10(%ebp),%edx
  84:	8b 45 0c             	mov    0xc(%ebp),%eax
  87:	89 cb                	mov    %ecx,%ebx
  89:	89 df                	mov    %ebx,%edi
  8b:	89 d1                	mov    %edx,%ecx
  8d:	fc                   	cld    
  8e:	f3 aa                	rep stos %al,%es:(%edi)
  90:	89 ca                	mov    %ecx,%edx
  92:	89 fb                	mov    %edi,%ebx
  94:	89 5d 08             	mov    %ebx,0x8(%ebp)
  97:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  9a:	5b                   	pop    %ebx
  9b:	5f                   	pop    %edi
  9c:	5d                   	pop    %ebp
  9d:	c3                   	ret    

0000009e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  9e:	55                   	push   %ebp
  9f:	89 e5                	mov    %esp,%ebp
  a1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a4:	8b 45 08             	mov    0x8(%ebp),%eax
  a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  aa:	90                   	nop
  ab:	8b 45 08             	mov    0x8(%ebp),%eax
  ae:	8d 50 01             	lea    0x1(%eax),%edx
  b1:	89 55 08             	mov    %edx,0x8(%ebp)
  b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  ba:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  bd:	0f b6 12             	movzbl (%edx),%edx
  c0:	88 10                	mov    %dl,(%eax)
  c2:	0f b6 00             	movzbl (%eax),%eax
  c5:	84 c0                	test   %al,%al
  c7:	75 e2                	jne    ab <strcpy+0xd>
    ;
  return os;
  c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  cc:	c9                   	leave  
  cd:	c3                   	ret    

000000ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ce:	55                   	push   %ebp
  cf:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d1:	eb 08                	jmp    db <strcmp+0xd>
    p++, q++;
  d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  db:	8b 45 08             	mov    0x8(%ebp),%eax
  de:	0f b6 00             	movzbl (%eax),%eax
  e1:	84 c0                	test   %al,%al
  e3:	74 10                	je     f5 <strcmp+0x27>
  e5:	8b 45 08             	mov    0x8(%ebp),%eax
  e8:	0f b6 10             	movzbl (%eax),%edx
  eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  ee:	0f b6 00             	movzbl (%eax),%eax
  f1:	38 c2                	cmp    %al,%dl
  f3:	74 de                	je     d3 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  f5:	8b 45 08             	mov    0x8(%ebp),%eax
  f8:	0f b6 00             	movzbl (%eax),%eax
  fb:	0f b6 d0             	movzbl %al,%edx
  fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 101:	0f b6 00             	movzbl (%eax),%eax
 104:	0f b6 c0             	movzbl %al,%eax
 107:	29 c2                	sub    %eax,%edx
 109:	89 d0                	mov    %edx,%eax
}
 10b:	5d                   	pop    %ebp
 10c:	c3                   	ret    

0000010d <strlen>:

uint
strlen(char *s)
{
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 113:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 11a:	eb 04                	jmp    120 <strlen+0x13>
 11c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 120:	8b 55 fc             	mov    -0x4(%ebp),%edx
 123:	8b 45 08             	mov    0x8(%ebp),%eax
 126:	01 d0                	add    %edx,%eax
 128:	0f b6 00             	movzbl (%eax),%eax
 12b:	84 c0                	test   %al,%al
 12d:	75 ed                	jne    11c <strlen+0xf>
    ;
  return n;
 12f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 132:	c9                   	leave  
 133:	c3                   	ret    

00000134 <memset>:

void*
memset(void *dst, int c, uint n)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 13a:	8b 45 10             	mov    0x10(%ebp),%eax
 13d:	89 44 24 08          	mov    %eax,0x8(%esp)
 141:	8b 45 0c             	mov    0xc(%ebp),%eax
 144:	89 44 24 04          	mov    %eax,0x4(%esp)
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	89 04 24             	mov    %eax,(%esp)
 14e:	e8 26 ff ff ff       	call   79 <stosb>
  return dst;
 153:	8b 45 08             	mov    0x8(%ebp),%eax
}
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <strchr>:

char*
strchr(const char *s, char c)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	83 ec 04             	sub    $0x4,%esp
 15e:	8b 45 0c             	mov    0xc(%ebp),%eax
 161:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 164:	eb 14                	jmp    17a <strchr+0x22>
    if(*s == c)
 166:	8b 45 08             	mov    0x8(%ebp),%eax
 169:	0f b6 00             	movzbl (%eax),%eax
 16c:	3a 45 fc             	cmp    -0x4(%ebp),%al
 16f:	75 05                	jne    176 <strchr+0x1e>
      return (char*)s;
 171:	8b 45 08             	mov    0x8(%ebp),%eax
 174:	eb 13                	jmp    189 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 176:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	0f b6 00             	movzbl (%eax),%eax
 180:	84 c0                	test   %al,%al
 182:	75 e2                	jne    166 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 184:	b8 00 00 00 00       	mov    $0x0,%eax
}
 189:	c9                   	leave  
 18a:	c3                   	ret    

0000018b <gets>:

char*
gets(char *buf, int max)
{
 18b:	55                   	push   %ebp
 18c:	89 e5                	mov    %esp,%ebp
 18e:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 191:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 198:	eb 4c                	jmp    1e6 <gets+0x5b>
    cc = read(0, &c, 1);
 19a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1a1:	00 
 1a2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b0:	e8 44 01 00 00       	call   2f9 <read>
 1b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1bc:	7f 02                	jg     1c0 <gets+0x35>
      break;
 1be:	eb 31                	jmp    1f1 <gets+0x66>
    buf[i++] = c;
 1c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c3:	8d 50 01             	lea    0x1(%eax),%edx
 1c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1c9:	89 c2                	mov    %eax,%edx
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ce:	01 c2                	add    %eax,%edx
 1d0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1d6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1da:	3c 0a                	cmp    $0xa,%al
 1dc:	74 13                	je     1f1 <gets+0x66>
 1de:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e2:	3c 0d                	cmp    $0xd,%al
 1e4:	74 0b                	je     1f1 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e9:	83 c0 01             	add    $0x1,%eax
 1ec:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1ef:	7c a9                	jl     19a <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
 1f7:	01 d0                	add    %edx,%eax
 1f9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ff:	c9                   	leave  
 200:	c3                   	ret    

00000201 <stat>:

int
stat(char *n, struct stat *st)
{
 201:	55                   	push   %ebp
 202:	89 e5                	mov    %esp,%ebp
 204:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 207:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 20e:	00 
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	89 04 24             	mov    %eax,(%esp)
 215:	e8 07 01 00 00       	call   321 <open>
 21a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 21d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 221:	79 07                	jns    22a <stat+0x29>
    return -1;
 223:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 228:	eb 23                	jmp    24d <stat+0x4c>
  r = fstat(fd, st);
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	89 44 24 04          	mov    %eax,0x4(%esp)
 231:	8b 45 f4             	mov    -0xc(%ebp),%eax
 234:	89 04 24             	mov    %eax,(%esp)
 237:	e8 fd 00 00 00       	call   339 <fstat>
 23c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 23f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 242:	89 04 24             	mov    %eax,(%esp)
 245:	e8 bf 00 00 00       	call   309 <close>
  return r;
 24a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 24d:	c9                   	leave  
 24e:	c3                   	ret    

0000024f <atoi>:

int
atoi(const char *s)
{
 24f:	55                   	push   %ebp
 250:	89 e5                	mov    %esp,%ebp
 252:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 255:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 25c:	eb 25                	jmp    283 <atoi+0x34>
    n = n*10 + *s++ - '0';
 25e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 261:	89 d0                	mov    %edx,%eax
 263:	c1 e0 02             	shl    $0x2,%eax
 266:	01 d0                	add    %edx,%eax
 268:	01 c0                	add    %eax,%eax
 26a:	89 c1                	mov    %eax,%ecx
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	8d 50 01             	lea    0x1(%eax),%edx
 272:	89 55 08             	mov    %edx,0x8(%ebp)
 275:	0f b6 00             	movzbl (%eax),%eax
 278:	0f be c0             	movsbl %al,%eax
 27b:	01 c8                	add    %ecx,%eax
 27d:	83 e8 30             	sub    $0x30,%eax
 280:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 283:	8b 45 08             	mov    0x8(%ebp),%eax
 286:	0f b6 00             	movzbl (%eax),%eax
 289:	3c 2f                	cmp    $0x2f,%al
 28b:	7e 0a                	jle    297 <atoi+0x48>
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	0f b6 00             	movzbl (%eax),%eax
 293:	3c 39                	cmp    $0x39,%al
 295:	7e c7                	jle    25e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 297:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29a:	c9                   	leave  
 29b:	c3                   	ret    

0000029c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 29c:	55                   	push   %ebp
 29d:	89 e5                	mov    %esp,%ebp
 29f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2a2:	8b 45 08             	mov    0x8(%ebp),%eax
 2a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ae:	eb 17                	jmp    2c7 <memmove+0x2b>
    *dst++ = *src++;
 2b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b3:	8d 50 01             	lea    0x1(%eax),%edx
 2b6:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2b9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2bc:	8d 4a 01             	lea    0x1(%edx),%ecx
 2bf:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2c2:	0f b6 12             	movzbl (%edx),%edx
 2c5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2c7:	8b 45 10             	mov    0x10(%ebp),%eax
 2ca:	8d 50 ff             	lea    -0x1(%eax),%edx
 2cd:	89 55 10             	mov    %edx,0x10(%ebp)
 2d0:	85 c0                	test   %eax,%eax
 2d2:	7f dc                	jg     2b0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d7:	c9                   	leave  
 2d8:	c3                   	ret    

000002d9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2d9:	b8 01 00 00 00       	mov    $0x1,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <exit>:
SYSCALL(exit)
 2e1:	b8 02 00 00 00       	mov    $0x2,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <wait>:
SYSCALL(wait)
 2e9:	b8 03 00 00 00       	mov    $0x3,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <pipe>:
SYSCALL(pipe)
 2f1:	b8 04 00 00 00       	mov    $0x4,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <read>:
SYSCALL(read)
 2f9:	b8 05 00 00 00       	mov    $0x5,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <write>:
SYSCALL(write)
 301:	b8 10 00 00 00       	mov    $0x10,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <close>:
SYSCALL(close)
 309:	b8 15 00 00 00       	mov    $0x15,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <kill>:
SYSCALL(kill)
 311:	b8 06 00 00 00       	mov    $0x6,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <exec>:
SYSCALL(exec)
 319:	b8 07 00 00 00       	mov    $0x7,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <open>:
SYSCALL(open)
 321:	b8 0f 00 00 00       	mov    $0xf,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <mknod>:
SYSCALL(mknod)
 329:	b8 11 00 00 00       	mov    $0x11,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <unlink>:
SYSCALL(unlink)
 331:	b8 12 00 00 00       	mov    $0x12,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <fstat>:
SYSCALL(fstat)
 339:	b8 08 00 00 00       	mov    $0x8,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <link>:
SYSCALL(link)
 341:	b8 13 00 00 00       	mov    $0x13,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <mkdir>:
SYSCALL(mkdir)
 349:	b8 14 00 00 00       	mov    $0x14,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <chdir>:
SYSCALL(chdir)
 351:	b8 09 00 00 00       	mov    $0x9,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <dup>:
SYSCALL(dup)
 359:	b8 0a 00 00 00       	mov    $0xa,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <getpid>:
SYSCALL(getpid)
 361:	b8 0b 00 00 00       	mov    $0xb,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <sbrk>:
SYSCALL(sbrk)
 369:	b8 0c 00 00 00       	mov    $0xc,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <sleep>:
SYSCALL(sleep)
 371:	b8 0d 00 00 00       	mov    $0xd,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <uptime>:
SYSCALL(uptime)
 379:	b8 0e 00 00 00       	mov    $0xe,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <sigset>:
SYSCALL(sigset)
 381:	b8 16 00 00 00       	mov    $0x16,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <sigsend>:
 389:	b8 17 00 00 00       	mov    $0x17,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 391:	55                   	push   %ebp
 392:	89 e5                	mov    %esp,%ebp
 394:	83 ec 18             	sub    $0x18,%esp
 397:	8b 45 0c             	mov    0xc(%ebp),%eax
 39a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 39d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3a4:	00 
 3a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3a8:	89 44 24 04          	mov    %eax,0x4(%esp)
 3ac:	8b 45 08             	mov    0x8(%ebp),%eax
 3af:	89 04 24             	mov    %eax,(%esp)
 3b2:	e8 4a ff ff ff       	call   301 <write>
}
 3b7:	c9                   	leave  
 3b8:	c3                   	ret    

000003b9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b9:	55                   	push   %ebp
 3ba:	89 e5                	mov    %esp,%ebp
 3bc:	56                   	push   %esi
 3bd:	53                   	push   %ebx
 3be:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3c8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3cc:	74 17                	je     3e5 <printint+0x2c>
 3ce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3d2:	79 11                	jns    3e5 <printint+0x2c>
    neg = 1;
 3d4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3db:	8b 45 0c             	mov    0xc(%ebp),%eax
 3de:	f7 d8                	neg    %eax
 3e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e3:	eb 06                	jmp    3eb <printint+0x32>
  } else {
    x = xx;
 3e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3f2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3f5:	8d 41 01             	lea    0x1(%ecx),%eax
 3f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
 401:	ba 00 00 00 00       	mov    $0x0,%edx
 406:	f7 f3                	div    %ebx
 408:	89 d0                	mov    %edx,%eax
 40a:	0f b6 80 b0 0a 00 00 	movzbl 0xab0(%eax),%eax
 411:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 415:	8b 75 10             	mov    0x10(%ebp),%esi
 418:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41b:	ba 00 00 00 00       	mov    $0x0,%edx
 420:	f7 f6                	div    %esi
 422:	89 45 ec             	mov    %eax,-0x14(%ebp)
 425:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 429:	75 c7                	jne    3f2 <printint+0x39>
  if(neg)
 42b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 42f:	74 10                	je     441 <printint+0x88>
    buf[i++] = '-';
 431:	8b 45 f4             	mov    -0xc(%ebp),%eax
 434:	8d 50 01             	lea    0x1(%eax),%edx
 437:	89 55 f4             	mov    %edx,-0xc(%ebp)
 43a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 43f:	eb 1f                	jmp    460 <printint+0xa7>
 441:	eb 1d                	jmp    460 <printint+0xa7>
    putc(fd, buf[i]);
 443:	8d 55 dc             	lea    -0x24(%ebp),%edx
 446:	8b 45 f4             	mov    -0xc(%ebp),%eax
 449:	01 d0                	add    %edx,%eax
 44b:	0f b6 00             	movzbl (%eax),%eax
 44e:	0f be c0             	movsbl %al,%eax
 451:	89 44 24 04          	mov    %eax,0x4(%esp)
 455:	8b 45 08             	mov    0x8(%ebp),%eax
 458:	89 04 24             	mov    %eax,(%esp)
 45b:	e8 31 ff ff ff       	call   391 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 460:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 464:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 468:	79 d9                	jns    443 <printint+0x8a>
    putc(fd, buf[i]);
}
 46a:	83 c4 30             	add    $0x30,%esp
 46d:	5b                   	pop    %ebx
 46e:	5e                   	pop    %esi
 46f:	5d                   	pop    %ebp
 470:	c3                   	ret    

00000471 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 471:	55                   	push   %ebp
 472:	89 e5                	mov    %esp,%ebp
 474:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 477:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 47e:	8d 45 0c             	lea    0xc(%ebp),%eax
 481:	83 c0 04             	add    $0x4,%eax
 484:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 487:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 48e:	e9 7c 01 00 00       	jmp    60f <printf+0x19e>
    c = fmt[i] & 0xff;
 493:	8b 55 0c             	mov    0xc(%ebp),%edx
 496:	8b 45 f0             	mov    -0x10(%ebp),%eax
 499:	01 d0                	add    %edx,%eax
 49b:	0f b6 00             	movzbl (%eax),%eax
 49e:	0f be c0             	movsbl %al,%eax
 4a1:	25 ff 00 00 00       	and    $0xff,%eax
 4a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ad:	75 2c                	jne    4db <printf+0x6a>
      if(c == '%'){
 4af:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4b3:	75 0c                	jne    4c1 <printf+0x50>
        state = '%';
 4b5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4bc:	e9 4a 01 00 00       	jmp    60b <printf+0x19a>
      } else {
        putc(fd, c);
 4c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c4:	0f be c0             	movsbl %al,%eax
 4c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4cb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ce:	89 04 24             	mov    %eax,(%esp)
 4d1:	e8 bb fe ff ff       	call   391 <putc>
 4d6:	e9 30 01 00 00       	jmp    60b <printf+0x19a>
      }
    } else if(state == '%'){
 4db:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4df:	0f 85 26 01 00 00    	jne    60b <printf+0x19a>
      if(c == 'd'){
 4e5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4e9:	75 2d                	jne    518 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ee:	8b 00                	mov    (%eax),%eax
 4f0:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4f7:	00 
 4f8:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4ff:	00 
 500:	89 44 24 04          	mov    %eax,0x4(%esp)
 504:	8b 45 08             	mov    0x8(%ebp),%eax
 507:	89 04 24             	mov    %eax,(%esp)
 50a:	e8 aa fe ff ff       	call   3b9 <printint>
        ap++;
 50f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 513:	e9 ec 00 00 00       	jmp    604 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 518:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 51c:	74 06                	je     524 <printf+0xb3>
 51e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 522:	75 2d                	jne    551 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 524:	8b 45 e8             	mov    -0x18(%ebp),%eax
 527:	8b 00                	mov    (%eax),%eax
 529:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 530:	00 
 531:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 538:	00 
 539:	89 44 24 04          	mov    %eax,0x4(%esp)
 53d:	8b 45 08             	mov    0x8(%ebp),%eax
 540:	89 04 24             	mov    %eax,(%esp)
 543:	e8 71 fe ff ff       	call   3b9 <printint>
        ap++;
 548:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54c:	e9 b3 00 00 00       	jmp    604 <printf+0x193>
      } else if(c == 's'){
 551:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 555:	75 45                	jne    59c <printf+0x12b>
        s = (char*)*ap;
 557:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55a:	8b 00                	mov    (%eax),%eax
 55c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 55f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 563:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 567:	75 09                	jne    572 <printf+0x101>
          s = "(null)";
 569:	c7 45 f4 64 08 00 00 	movl   $0x864,-0xc(%ebp)
        while(*s != 0){
 570:	eb 1e                	jmp    590 <printf+0x11f>
 572:	eb 1c                	jmp    590 <printf+0x11f>
          putc(fd, *s);
 574:	8b 45 f4             	mov    -0xc(%ebp),%eax
 577:	0f b6 00             	movzbl (%eax),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	89 44 24 04          	mov    %eax,0x4(%esp)
 581:	8b 45 08             	mov    0x8(%ebp),%eax
 584:	89 04 24             	mov    %eax,(%esp)
 587:	e8 05 fe ff ff       	call   391 <putc>
          s++;
 58c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 590:	8b 45 f4             	mov    -0xc(%ebp),%eax
 593:	0f b6 00             	movzbl (%eax),%eax
 596:	84 c0                	test   %al,%al
 598:	75 da                	jne    574 <printf+0x103>
 59a:	eb 68                	jmp    604 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 59c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5a0:	75 1d                	jne    5bf <printf+0x14e>
        putc(fd, *ap);
 5a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a5:	8b 00                	mov    (%eax),%eax
 5a7:	0f be c0             	movsbl %al,%eax
 5aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ae:	8b 45 08             	mov    0x8(%ebp),%eax
 5b1:	89 04 24             	mov    %eax,(%esp)
 5b4:	e8 d8 fd ff ff       	call   391 <putc>
        ap++;
 5b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5bd:	eb 45                	jmp    604 <printf+0x193>
      } else if(c == '%'){
 5bf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5c3:	75 17                	jne    5dc <printf+0x16b>
        putc(fd, c);
 5c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c8:	0f be c0             	movsbl %al,%eax
 5cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5cf:	8b 45 08             	mov    0x8(%ebp),%eax
 5d2:	89 04 24             	mov    %eax,(%esp)
 5d5:	e8 b7 fd ff ff       	call   391 <putc>
 5da:	eb 28                	jmp    604 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5dc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5e3:	00 
 5e4:	8b 45 08             	mov    0x8(%ebp),%eax
 5e7:	89 04 24             	mov    %eax,(%esp)
 5ea:	e8 a2 fd ff ff       	call   391 <putc>
        putc(fd, c);
 5ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5f2:	0f be c0             	movsbl %al,%eax
 5f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f9:	8b 45 08             	mov    0x8(%ebp),%eax
 5fc:	89 04 24             	mov    %eax,(%esp)
 5ff:	e8 8d fd ff ff       	call   391 <putc>
      }
      state = 0;
 604:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 60b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 60f:	8b 55 0c             	mov    0xc(%ebp),%edx
 612:	8b 45 f0             	mov    -0x10(%ebp),%eax
 615:	01 d0                	add    %edx,%eax
 617:	0f b6 00             	movzbl (%eax),%eax
 61a:	84 c0                	test   %al,%al
 61c:	0f 85 71 fe ff ff    	jne    493 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 622:	c9                   	leave  
 623:	c3                   	ret    

00000624 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
 627:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 62a:	8b 45 08             	mov    0x8(%ebp),%eax
 62d:	83 e8 08             	sub    $0x8,%eax
 630:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 633:	a1 cc 0a 00 00       	mov    0xacc,%eax
 638:	89 45 fc             	mov    %eax,-0x4(%ebp)
 63b:	eb 24                	jmp    661 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 63d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 640:	8b 00                	mov    (%eax),%eax
 642:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 645:	77 12                	ja     659 <free+0x35>
 647:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 64d:	77 24                	ja     673 <free+0x4f>
 64f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 652:	8b 00                	mov    (%eax),%eax
 654:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 657:	77 1a                	ja     673 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 659:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 661:	8b 45 f8             	mov    -0x8(%ebp),%eax
 664:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 667:	76 d4                	jbe    63d <free+0x19>
 669:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 671:	76 ca                	jbe    63d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 673:	8b 45 f8             	mov    -0x8(%ebp),%eax
 676:	8b 40 04             	mov    0x4(%eax),%eax
 679:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 680:	8b 45 f8             	mov    -0x8(%ebp),%eax
 683:	01 c2                	add    %eax,%edx
 685:	8b 45 fc             	mov    -0x4(%ebp),%eax
 688:	8b 00                	mov    (%eax),%eax
 68a:	39 c2                	cmp    %eax,%edx
 68c:	75 24                	jne    6b2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 68e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 691:	8b 50 04             	mov    0x4(%eax),%edx
 694:	8b 45 fc             	mov    -0x4(%ebp),%eax
 697:	8b 00                	mov    (%eax),%eax
 699:	8b 40 04             	mov    0x4(%eax),%eax
 69c:	01 c2                	add    %eax,%edx
 69e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a7:	8b 00                	mov    (%eax),%eax
 6a9:	8b 10                	mov    (%eax),%edx
 6ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ae:	89 10                	mov    %edx,(%eax)
 6b0:	eb 0a                	jmp    6bc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b5:	8b 10                	mov    (%eax),%edx
 6b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ba:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	8b 40 04             	mov    0x4(%eax),%eax
 6c2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	01 d0                	add    %edx,%eax
 6ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6d1:	75 20                	jne    6f3 <free+0xcf>
    p->s.size += bp->s.size;
 6d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d6:	8b 50 04             	mov    0x4(%eax),%edx
 6d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6dc:	8b 40 04             	mov    0x4(%eax),%eax
 6df:	01 c2                	add    %eax,%edx
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ea:	8b 10                	mov    (%eax),%edx
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	89 10                	mov    %edx,(%eax)
 6f1:	eb 08                	jmp    6fb <free+0xd7>
  } else
    p->s.ptr = bp;
 6f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6f9:	89 10                	mov    %edx,(%eax)
  freep = p;
 6fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fe:	a3 cc 0a 00 00       	mov    %eax,0xacc
}
 703:	c9                   	leave  
 704:	c3                   	ret    

00000705 <morecore>:

static Header*
morecore(uint nu)
{
 705:	55                   	push   %ebp
 706:	89 e5                	mov    %esp,%ebp
 708:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 70b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 712:	77 07                	ja     71b <morecore+0x16>
    nu = 4096;
 714:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 71b:	8b 45 08             	mov    0x8(%ebp),%eax
 71e:	c1 e0 03             	shl    $0x3,%eax
 721:	89 04 24             	mov    %eax,(%esp)
 724:	e8 40 fc ff ff       	call   369 <sbrk>
 729:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 72c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 730:	75 07                	jne    739 <morecore+0x34>
    return 0;
 732:	b8 00 00 00 00       	mov    $0x0,%eax
 737:	eb 22                	jmp    75b <morecore+0x56>
  hp = (Header*)p;
 739:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 73f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 742:	8b 55 08             	mov    0x8(%ebp),%edx
 745:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 748:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74b:	83 c0 08             	add    $0x8,%eax
 74e:	89 04 24             	mov    %eax,(%esp)
 751:	e8 ce fe ff ff       	call   624 <free>
  return freep;
 756:	a1 cc 0a 00 00       	mov    0xacc,%eax
}
 75b:	c9                   	leave  
 75c:	c3                   	ret    

0000075d <malloc>:

void*
malloc(uint nbytes)
{
 75d:	55                   	push   %ebp
 75e:	89 e5                	mov    %esp,%ebp
 760:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 763:	8b 45 08             	mov    0x8(%ebp),%eax
 766:	83 c0 07             	add    $0x7,%eax
 769:	c1 e8 03             	shr    $0x3,%eax
 76c:	83 c0 01             	add    $0x1,%eax
 76f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 772:	a1 cc 0a 00 00       	mov    0xacc,%eax
 777:	89 45 f0             	mov    %eax,-0x10(%ebp)
 77a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 77e:	75 23                	jne    7a3 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 780:	c7 45 f0 c4 0a 00 00 	movl   $0xac4,-0x10(%ebp)
 787:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78a:	a3 cc 0a 00 00       	mov    %eax,0xacc
 78f:	a1 cc 0a 00 00       	mov    0xacc,%eax
 794:	a3 c4 0a 00 00       	mov    %eax,0xac4
    base.s.size = 0;
 799:	c7 05 c8 0a 00 00 00 	movl   $0x0,0xac8
 7a0:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a6:	8b 00                	mov    (%eax),%eax
 7a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ae:	8b 40 04             	mov    0x4(%eax),%eax
 7b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7b4:	72 4d                	jb     803 <malloc+0xa6>
      if(p->s.size == nunits)
 7b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b9:	8b 40 04             	mov    0x4(%eax),%eax
 7bc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7bf:	75 0c                	jne    7cd <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c4:	8b 10                	mov    (%eax),%edx
 7c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c9:	89 10                	mov    %edx,(%eax)
 7cb:	eb 26                	jmp    7f3 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d0:	8b 40 04             	mov    0x4(%eax),%eax
 7d3:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7d6:	89 c2                	mov    %eax,%edx
 7d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7db:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e1:	8b 40 04             	mov    0x4(%eax),%eax
 7e4:	c1 e0 03             	shl    $0x3,%eax
 7e7:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7f0:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f6:	a3 cc 0a 00 00       	mov    %eax,0xacc
      return (void*)(p + 1);
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	83 c0 08             	add    $0x8,%eax
 801:	eb 38                	jmp    83b <malloc+0xde>
    }
    if(p == freep)
 803:	a1 cc 0a 00 00       	mov    0xacc,%eax
 808:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 80b:	75 1b                	jne    828 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 80d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 810:	89 04 24             	mov    %eax,(%esp)
 813:	e8 ed fe ff ff       	call   705 <morecore>
 818:	89 45 f4             	mov    %eax,-0xc(%ebp)
 81b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 81f:	75 07                	jne    828 <malloc+0xcb>
        return 0;
 821:	b8 00 00 00 00       	mov    $0x0,%eax
 826:	eb 13                	jmp    83b <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 828:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 82e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 831:	8b 00                	mov    (%eax),%eax
 833:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 836:	e9 70 ff ff ff       	jmp    7ab <malloc+0x4e>
}
 83b:	c9                   	leave  
 83c:	c3                   	ret    
