
_testcas:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int pid = getpid();
   9:	e8 19 03 00 00       	call   327 <getpid>
   e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  printf(1, "print cas result proc pid = %d\n", pid);
  12:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  16:	89 44 24 08          	mov    %eax,0x8(%esp)
  1a:	c7 44 24 04 f4 07 00 	movl   $0x7f4,0x4(%esp)
  21:	00 
  22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  29:	e8 f9 03 00 00       	call   427 <printf>
  kill(pid);
  2e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  32:	89 04 24             	mov    %eax,(%esp)
  35:	e8 9d 02 00 00       	call   2d7 <kill>
  exit();
  3a:	e8 68 02 00 00       	call   2a7 <exit>

0000003f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  3f:	55                   	push   %ebp
  40:	89 e5                	mov    %esp,%ebp
  42:	57                   	push   %edi
  43:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  47:	8b 55 10             	mov    0x10(%ebp),%edx
  4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  4d:	89 cb                	mov    %ecx,%ebx
  4f:	89 df                	mov    %ebx,%edi
  51:	89 d1                	mov    %edx,%ecx
  53:	fc                   	cld    
  54:	f3 aa                	rep stos %al,%es:(%edi)
  56:	89 ca                	mov    %ecx,%edx
  58:	89 fb                	mov    %edi,%ebx
  5a:	89 5d 08             	mov    %ebx,0x8(%ebp)
  5d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  60:	5b                   	pop    %ebx
  61:	5f                   	pop    %edi
  62:	5d                   	pop    %ebp
  63:	c3                   	ret    

00000064 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  64:	55                   	push   %ebp
  65:	89 e5                	mov    %esp,%ebp
  67:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  6a:	8b 45 08             	mov    0x8(%ebp),%eax
  6d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  70:	90                   	nop
  71:	8b 45 08             	mov    0x8(%ebp),%eax
  74:	8d 50 01             	lea    0x1(%eax),%edx
  77:	89 55 08             	mov    %edx,0x8(%ebp)
  7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  7d:	8d 4a 01             	lea    0x1(%edx),%ecx
  80:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  83:	0f b6 12             	movzbl (%edx),%edx
  86:	88 10                	mov    %dl,(%eax)
  88:	0f b6 00             	movzbl (%eax),%eax
  8b:	84 c0                	test   %al,%al
  8d:	75 e2                	jne    71 <strcpy+0xd>
    ;
  return os;
  8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  92:	c9                   	leave  
  93:	c3                   	ret    

00000094 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  94:	55                   	push   %ebp
  95:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  97:	eb 08                	jmp    a1 <strcmp+0xd>
    p++, q++;
  99:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  9d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  a1:	8b 45 08             	mov    0x8(%ebp),%eax
  a4:	0f b6 00             	movzbl (%eax),%eax
  a7:	84 c0                	test   %al,%al
  a9:	74 10                	je     bb <strcmp+0x27>
  ab:	8b 45 08             	mov    0x8(%ebp),%eax
  ae:	0f b6 10             	movzbl (%eax),%edx
  b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  b4:	0f b6 00             	movzbl (%eax),%eax
  b7:	38 c2                	cmp    %al,%dl
  b9:	74 de                	je     99 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  bb:	8b 45 08             	mov    0x8(%ebp),%eax
  be:	0f b6 00             	movzbl (%eax),%eax
  c1:	0f b6 d0             	movzbl %al,%edx
  c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  c7:	0f b6 00             	movzbl (%eax),%eax
  ca:	0f b6 c0             	movzbl %al,%eax
  cd:	29 c2                	sub    %eax,%edx
  cf:	89 d0                	mov    %edx,%eax
}
  d1:	5d                   	pop    %ebp
  d2:	c3                   	ret    

000000d3 <strlen>:

uint
strlen(char *s)
{
  d3:	55                   	push   %ebp
  d4:	89 e5                	mov    %esp,%ebp
  d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  e0:	eb 04                	jmp    e6 <strlen+0x13>
  e2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  e9:	8b 45 08             	mov    0x8(%ebp),%eax
  ec:	01 d0                	add    %edx,%eax
  ee:	0f b6 00             	movzbl (%eax),%eax
  f1:	84 c0                	test   %al,%al
  f3:	75 ed                	jne    e2 <strlen+0xf>
    ;
  return n;
  f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f8:	c9                   	leave  
  f9:	c3                   	ret    

000000fa <memset>:

void*
memset(void *dst, int c, uint n)
{
  fa:	55                   	push   %ebp
  fb:	89 e5                	mov    %esp,%ebp
  fd:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 100:	8b 45 10             	mov    0x10(%ebp),%eax
 103:	89 44 24 08          	mov    %eax,0x8(%esp)
 107:	8b 45 0c             	mov    0xc(%ebp),%eax
 10a:	89 44 24 04          	mov    %eax,0x4(%esp)
 10e:	8b 45 08             	mov    0x8(%ebp),%eax
 111:	89 04 24             	mov    %eax,(%esp)
 114:	e8 26 ff ff ff       	call   3f <stosb>
  return dst;
 119:	8b 45 08             	mov    0x8(%ebp),%eax
}
 11c:	c9                   	leave  
 11d:	c3                   	ret    

0000011e <strchr>:

char*
strchr(const char *s, char c)
{
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
 121:	83 ec 04             	sub    $0x4,%esp
 124:	8b 45 0c             	mov    0xc(%ebp),%eax
 127:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 12a:	eb 14                	jmp    140 <strchr+0x22>
    if(*s == c)
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	0f b6 00             	movzbl (%eax),%eax
 132:	3a 45 fc             	cmp    -0x4(%ebp),%al
 135:	75 05                	jne    13c <strchr+0x1e>
      return (char*)s;
 137:	8b 45 08             	mov    0x8(%ebp),%eax
 13a:	eb 13                	jmp    14f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 13c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 140:	8b 45 08             	mov    0x8(%ebp),%eax
 143:	0f b6 00             	movzbl (%eax),%eax
 146:	84 c0                	test   %al,%al
 148:	75 e2                	jne    12c <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 14a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 14f:	c9                   	leave  
 150:	c3                   	ret    

00000151 <gets>:

char*
gets(char *buf, int max)
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 157:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 15e:	eb 4c                	jmp    1ac <gets+0x5b>
    cc = read(0, &c, 1);
 160:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 167:	00 
 168:	8d 45 ef             	lea    -0x11(%ebp),%eax
 16b:	89 44 24 04          	mov    %eax,0x4(%esp)
 16f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 176:	e8 44 01 00 00       	call   2bf <read>
 17b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 17e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 182:	7f 02                	jg     186 <gets+0x35>
      break;
 184:	eb 31                	jmp    1b7 <gets+0x66>
    buf[i++] = c;
 186:	8b 45 f4             	mov    -0xc(%ebp),%eax
 189:	8d 50 01             	lea    0x1(%eax),%edx
 18c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 18f:	89 c2                	mov    %eax,%edx
 191:	8b 45 08             	mov    0x8(%ebp),%eax
 194:	01 c2                	add    %eax,%edx
 196:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 19a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 19c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a0:	3c 0a                	cmp    $0xa,%al
 1a2:	74 13                	je     1b7 <gets+0x66>
 1a4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a8:	3c 0d                	cmp    $0xd,%al
 1aa:	74 0b                	je     1b7 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1af:	83 c0 01             	add    $0x1,%eax
 1b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1b5:	7c a9                	jl     160 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	01 d0                	add    %edx,%eax
 1bf:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1c2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c5:	c9                   	leave  
 1c6:	c3                   	ret    

000001c7 <stat>:

int
stat(char *n, struct stat *st)
{
 1c7:	55                   	push   %ebp
 1c8:	89 e5                	mov    %esp,%ebp
 1ca:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1d4:	00 
 1d5:	8b 45 08             	mov    0x8(%ebp),%eax
 1d8:	89 04 24             	mov    %eax,(%esp)
 1db:	e8 07 01 00 00       	call   2e7 <open>
 1e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1e7:	79 07                	jns    1f0 <stat+0x29>
    return -1;
 1e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1ee:	eb 23                	jmp    213 <stat+0x4c>
  r = fstat(fd, st);
 1f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fa:	89 04 24             	mov    %eax,(%esp)
 1fd:	e8 fd 00 00 00       	call   2ff <fstat>
 202:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 205:	8b 45 f4             	mov    -0xc(%ebp),%eax
 208:	89 04 24             	mov    %eax,(%esp)
 20b:	e8 bf 00 00 00       	call   2cf <close>
  return r;
 210:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 213:	c9                   	leave  
 214:	c3                   	ret    

00000215 <atoi>:

int
atoi(const char *s)
{
 215:	55                   	push   %ebp
 216:	89 e5                	mov    %esp,%ebp
 218:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 21b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 222:	eb 25                	jmp    249 <atoi+0x34>
    n = n*10 + *s++ - '0';
 224:	8b 55 fc             	mov    -0x4(%ebp),%edx
 227:	89 d0                	mov    %edx,%eax
 229:	c1 e0 02             	shl    $0x2,%eax
 22c:	01 d0                	add    %edx,%eax
 22e:	01 c0                	add    %eax,%eax
 230:	89 c1                	mov    %eax,%ecx
 232:	8b 45 08             	mov    0x8(%ebp),%eax
 235:	8d 50 01             	lea    0x1(%eax),%edx
 238:	89 55 08             	mov    %edx,0x8(%ebp)
 23b:	0f b6 00             	movzbl (%eax),%eax
 23e:	0f be c0             	movsbl %al,%eax
 241:	01 c8                	add    %ecx,%eax
 243:	83 e8 30             	sub    $0x30,%eax
 246:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 249:	8b 45 08             	mov    0x8(%ebp),%eax
 24c:	0f b6 00             	movzbl (%eax),%eax
 24f:	3c 2f                	cmp    $0x2f,%al
 251:	7e 0a                	jle    25d <atoi+0x48>
 253:	8b 45 08             	mov    0x8(%ebp),%eax
 256:	0f b6 00             	movzbl (%eax),%eax
 259:	3c 39                	cmp    $0x39,%al
 25b:	7e c7                	jle    224 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 25d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 260:	c9                   	leave  
 261:	c3                   	ret    

00000262 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 262:	55                   	push   %ebp
 263:	89 e5                	mov    %esp,%ebp
 265:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 26e:	8b 45 0c             	mov    0xc(%ebp),%eax
 271:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 274:	eb 17                	jmp    28d <memmove+0x2b>
    *dst++ = *src++;
 276:	8b 45 fc             	mov    -0x4(%ebp),%eax
 279:	8d 50 01             	lea    0x1(%eax),%edx
 27c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 27f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 282:	8d 4a 01             	lea    0x1(%edx),%ecx
 285:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 288:	0f b6 12             	movzbl (%edx),%edx
 28b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 28d:	8b 45 10             	mov    0x10(%ebp),%eax
 290:	8d 50 ff             	lea    -0x1(%eax),%edx
 293:	89 55 10             	mov    %edx,0x10(%ebp)
 296:	85 c0                	test   %eax,%eax
 298:	7f dc                	jg     276 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 29d:	c9                   	leave  
 29e:	c3                   	ret    

0000029f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 29f:	b8 01 00 00 00       	mov    $0x1,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <exit>:
SYSCALL(exit)
 2a7:	b8 02 00 00 00       	mov    $0x2,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <wait>:
SYSCALL(wait)
 2af:	b8 03 00 00 00       	mov    $0x3,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    

000002b7 <pipe>:
SYSCALL(pipe)
 2b7:	b8 04 00 00 00       	mov    $0x4,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <read>:
SYSCALL(read)
 2bf:	b8 05 00 00 00       	mov    $0x5,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret    

000002c7 <write>:
SYSCALL(write)
 2c7:	b8 10 00 00 00       	mov    $0x10,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <close>:
SYSCALL(close)
 2cf:	b8 15 00 00 00       	mov    $0x15,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <kill>:
SYSCALL(kill)
 2d7:	b8 06 00 00 00       	mov    $0x6,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <exec>:
SYSCALL(exec)
 2df:	b8 07 00 00 00       	mov    $0x7,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <open>:
SYSCALL(open)
 2e7:	b8 0f 00 00 00       	mov    $0xf,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <mknod>:
SYSCALL(mknod)
 2ef:	b8 11 00 00 00       	mov    $0x11,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <unlink>:
SYSCALL(unlink)
 2f7:	b8 12 00 00 00       	mov    $0x12,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <fstat>:
SYSCALL(fstat)
 2ff:	b8 08 00 00 00       	mov    $0x8,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <link>:
SYSCALL(link)
 307:	b8 13 00 00 00       	mov    $0x13,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <mkdir>:
SYSCALL(mkdir)
 30f:	b8 14 00 00 00       	mov    $0x14,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <chdir>:
SYSCALL(chdir)
 317:	b8 09 00 00 00       	mov    $0x9,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <dup>:
SYSCALL(dup)
 31f:	b8 0a 00 00 00       	mov    $0xa,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <getpid>:
SYSCALL(getpid)
 327:	b8 0b 00 00 00       	mov    $0xb,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <sbrk>:
SYSCALL(sbrk)
 32f:	b8 0c 00 00 00       	mov    $0xc,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <sleep>:
SYSCALL(sleep)
 337:	b8 0d 00 00 00       	mov    $0xd,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	ret    

0000033f <uptime>:
SYSCALL(uptime)
 33f:	b8 0e 00 00 00       	mov    $0xe,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 347:	55                   	push   %ebp
 348:	89 e5                	mov    %esp,%ebp
 34a:	83 ec 18             	sub    $0x18,%esp
 34d:	8b 45 0c             	mov    0xc(%ebp),%eax
 350:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 353:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 35a:	00 
 35b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 35e:	89 44 24 04          	mov    %eax,0x4(%esp)
 362:	8b 45 08             	mov    0x8(%ebp),%eax
 365:	89 04 24             	mov    %eax,(%esp)
 368:	e8 5a ff ff ff       	call   2c7 <write>
}
 36d:	c9                   	leave  
 36e:	c3                   	ret    

0000036f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 36f:	55                   	push   %ebp
 370:	89 e5                	mov    %esp,%ebp
 372:	56                   	push   %esi
 373:	53                   	push   %ebx
 374:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 377:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 37e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 382:	74 17                	je     39b <printint+0x2c>
 384:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 388:	79 11                	jns    39b <printint+0x2c>
    neg = 1;
 38a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 391:	8b 45 0c             	mov    0xc(%ebp),%eax
 394:	f7 d8                	neg    %eax
 396:	89 45 ec             	mov    %eax,-0x14(%ebp)
 399:	eb 06                	jmp    3a1 <printint+0x32>
  } else {
    x = xx;
 39b:	8b 45 0c             	mov    0xc(%ebp),%eax
 39e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3a8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3ab:	8d 41 01             	lea    0x1(%ecx),%eax
 3ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3b7:	ba 00 00 00 00       	mov    $0x0,%edx
 3bc:	f7 f3                	div    %ebx
 3be:	89 d0                	mov    %edx,%eax
 3c0:	0f b6 80 60 0a 00 00 	movzbl 0xa60(%eax),%eax
 3c7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3cb:	8b 75 10             	mov    0x10(%ebp),%esi
 3ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3d1:	ba 00 00 00 00       	mov    $0x0,%edx
 3d6:	f7 f6                	div    %esi
 3d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3df:	75 c7                	jne    3a8 <printint+0x39>
  if(neg)
 3e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3e5:	74 10                	je     3f7 <printint+0x88>
    buf[i++] = '-';
 3e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ea:	8d 50 01             	lea    0x1(%eax),%edx
 3ed:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3f0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3f5:	eb 1f                	jmp    416 <printint+0xa7>
 3f7:	eb 1d                	jmp    416 <printint+0xa7>
    putc(fd, buf[i]);
 3f9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ff:	01 d0                	add    %edx,%eax
 401:	0f b6 00             	movzbl (%eax),%eax
 404:	0f be c0             	movsbl %al,%eax
 407:	89 44 24 04          	mov    %eax,0x4(%esp)
 40b:	8b 45 08             	mov    0x8(%ebp),%eax
 40e:	89 04 24             	mov    %eax,(%esp)
 411:	e8 31 ff ff ff       	call   347 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 416:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 41a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 41e:	79 d9                	jns    3f9 <printint+0x8a>
    putc(fd, buf[i]);
}
 420:	83 c4 30             	add    $0x30,%esp
 423:	5b                   	pop    %ebx
 424:	5e                   	pop    %esi
 425:	5d                   	pop    %ebp
 426:	c3                   	ret    

00000427 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 427:	55                   	push   %ebp
 428:	89 e5                	mov    %esp,%ebp
 42a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 42d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 434:	8d 45 0c             	lea    0xc(%ebp),%eax
 437:	83 c0 04             	add    $0x4,%eax
 43a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 43d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 444:	e9 7c 01 00 00       	jmp    5c5 <printf+0x19e>
    c = fmt[i] & 0xff;
 449:	8b 55 0c             	mov    0xc(%ebp),%edx
 44c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 44f:	01 d0                	add    %edx,%eax
 451:	0f b6 00             	movzbl (%eax),%eax
 454:	0f be c0             	movsbl %al,%eax
 457:	25 ff 00 00 00       	and    $0xff,%eax
 45c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 45f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 463:	75 2c                	jne    491 <printf+0x6a>
      if(c == '%'){
 465:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 469:	75 0c                	jne    477 <printf+0x50>
        state = '%';
 46b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 472:	e9 4a 01 00 00       	jmp    5c1 <printf+0x19a>
      } else {
        putc(fd, c);
 477:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 47a:	0f be c0             	movsbl %al,%eax
 47d:	89 44 24 04          	mov    %eax,0x4(%esp)
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	89 04 24             	mov    %eax,(%esp)
 487:	e8 bb fe ff ff       	call   347 <putc>
 48c:	e9 30 01 00 00       	jmp    5c1 <printf+0x19a>
      }
    } else if(state == '%'){
 491:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 495:	0f 85 26 01 00 00    	jne    5c1 <printf+0x19a>
      if(c == 'd'){
 49b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 49f:	75 2d                	jne    4ce <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4a4:	8b 00                	mov    (%eax),%eax
 4a6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4ad:	00 
 4ae:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4b5:	00 
 4b6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ba:	8b 45 08             	mov    0x8(%ebp),%eax
 4bd:	89 04 24             	mov    %eax,(%esp)
 4c0:	e8 aa fe ff ff       	call   36f <printint>
        ap++;
 4c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4c9:	e9 ec 00 00 00       	jmp    5ba <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 4ce:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4d2:	74 06                	je     4da <printf+0xb3>
 4d4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4d8:	75 2d                	jne    507 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4dd:	8b 00                	mov    (%eax),%eax
 4df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4e6:	00 
 4e7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4ee:	00 
 4ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	89 04 24             	mov    %eax,(%esp)
 4f9:	e8 71 fe ff ff       	call   36f <printint>
        ap++;
 4fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 502:	e9 b3 00 00 00       	jmp    5ba <printf+0x193>
      } else if(c == 's'){
 507:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 50b:	75 45                	jne    552 <printf+0x12b>
        s = (char*)*ap;
 50d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 510:	8b 00                	mov    (%eax),%eax
 512:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 515:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 519:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51d:	75 09                	jne    528 <printf+0x101>
          s = "(null)";
 51f:	c7 45 f4 14 08 00 00 	movl   $0x814,-0xc(%ebp)
        while(*s != 0){
 526:	eb 1e                	jmp    546 <printf+0x11f>
 528:	eb 1c                	jmp    546 <printf+0x11f>
          putc(fd, *s);
 52a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52d:	0f b6 00             	movzbl (%eax),%eax
 530:	0f be c0             	movsbl %al,%eax
 533:	89 44 24 04          	mov    %eax,0x4(%esp)
 537:	8b 45 08             	mov    0x8(%ebp),%eax
 53a:	89 04 24             	mov    %eax,(%esp)
 53d:	e8 05 fe ff ff       	call   347 <putc>
          s++;
 542:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 546:	8b 45 f4             	mov    -0xc(%ebp),%eax
 549:	0f b6 00             	movzbl (%eax),%eax
 54c:	84 c0                	test   %al,%al
 54e:	75 da                	jne    52a <printf+0x103>
 550:	eb 68                	jmp    5ba <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 552:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 556:	75 1d                	jne    575 <printf+0x14e>
        putc(fd, *ap);
 558:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55b:	8b 00                	mov    (%eax),%eax
 55d:	0f be c0             	movsbl %al,%eax
 560:	89 44 24 04          	mov    %eax,0x4(%esp)
 564:	8b 45 08             	mov    0x8(%ebp),%eax
 567:	89 04 24             	mov    %eax,(%esp)
 56a:	e8 d8 fd ff ff       	call   347 <putc>
        ap++;
 56f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 573:	eb 45                	jmp    5ba <printf+0x193>
      } else if(c == '%'){
 575:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 579:	75 17                	jne    592 <printf+0x16b>
        putc(fd, c);
 57b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57e:	0f be c0             	movsbl %al,%eax
 581:	89 44 24 04          	mov    %eax,0x4(%esp)
 585:	8b 45 08             	mov    0x8(%ebp),%eax
 588:	89 04 24             	mov    %eax,(%esp)
 58b:	e8 b7 fd ff ff       	call   347 <putc>
 590:	eb 28                	jmp    5ba <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 592:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 599:	00 
 59a:	8b 45 08             	mov    0x8(%ebp),%eax
 59d:	89 04 24             	mov    %eax,(%esp)
 5a0:	e8 a2 fd ff ff       	call   347 <putc>
        putc(fd, c);
 5a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a8:	0f be c0             	movsbl %al,%eax
 5ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 5af:	8b 45 08             	mov    0x8(%ebp),%eax
 5b2:	89 04 24             	mov    %eax,(%esp)
 5b5:	e8 8d fd ff ff       	call   347 <putc>
      }
      state = 0;
 5ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5c5:	8b 55 0c             	mov    0xc(%ebp),%edx
 5c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5cb:	01 d0                	add    %edx,%eax
 5cd:	0f b6 00             	movzbl (%eax),%eax
 5d0:	84 c0                	test   %al,%al
 5d2:	0f 85 71 fe ff ff    	jne    449 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5d8:	c9                   	leave  
 5d9:	c3                   	ret    

000005da <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5da:	55                   	push   %ebp
 5db:	89 e5                	mov    %esp,%ebp
 5dd:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5e0:	8b 45 08             	mov    0x8(%ebp),%eax
 5e3:	83 e8 08             	sub    $0x8,%eax
 5e6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e9:	a1 7c 0a 00 00       	mov    0xa7c,%eax
 5ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f1:	eb 24                	jmp    617 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f6:	8b 00                	mov    (%eax),%eax
 5f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5fb:	77 12                	ja     60f <free+0x35>
 5fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 600:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 603:	77 24                	ja     629 <free+0x4f>
 605:	8b 45 fc             	mov    -0x4(%ebp),%eax
 608:	8b 00                	mov    (%eax),%eax
 60a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 60d:	77 1a                	ja     629 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 612:	8b 00                	mov    (%eax),%eax
 614:	89 45 fc             	mov    %eax,-0x4(%ebp)
 617:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61d:	76 d4                	jbe    5f3 <free+0x19>
 61f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 622:	8b 00                	mov    (%eax),%eax
 624:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 627:	76 ca                	jbe    5f3 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 629:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62c:	8b 40 04             	mov    0x4(%eax),%eax
 62f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 636:	8b 45 f8             	mov    -0x8(%ebp),%eax
 639:	01 c2                	add    %eax,%edx
 63b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63e:	8b 00                	mov    (%eax),%eax
 640:	39 c2                	cmp    %eax,%edx
 642:	75 24                	jne    668 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 644:	8b 45 f8             	mov    -0x8(%ebp),%eax
 647:	8b 50 04             	mov    0x4(%eax),%edx
 64a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64d:	8b 00                	mov    (%eax),%eax
 64f:	8b 40 04             	mov    0x4(%eax),%eax
 652:	01 c2                	add    %eax,%edx
 654:	8b 45 f8             	mov    -0x8(%ebp),%eax
 657:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 65a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65d:	8b 00                	mov    (%eax),%eax
 65f:	8b 10                	mov    (%eax),%edx
 661:	8b 45 f8             	mov    -0x8(%ebp),%eax
 664:	89 10                	mov    %edx,(%eax)
 666:	eb 0a                	jmp    672 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 668:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66b:	8b 10                	mov    (%eax),%edx
 66d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 670:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 672:	8b 45 fc             	mov    -0x4(%ebp),%eax
 675:	8b 40 04             	mov    0x4(%eax),%eax
 678:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 67f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 682:	01 d0                	add    %edx,%eax
 684:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 687:	75 20                	jne    6a9 <free+0xcf>
    p->s.size += bp->s.size;
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68c:	8b 50 04             	mov    0x4(%eax),%edx
 68f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 692:	8b 40 04             	mov    0x4(%eax),%eax
 695:	01 c2                	add    %eax,%edx
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 69d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a0:	8b 10                	mov    (%eax),%edx
 6a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a5:	89 10                	mov    %edx,(%eax)
 6a7:	eb 08                	jmp    6b1 <free+0xd7>
  } else
    p->s.ptr = bp;
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6af:	89 10                	mov    %edx,(%eax)
  freep = p;
 6b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b4:	a3 7c 0a 00 00       	mov    %eax,0xa7c
}
 6b9:	c9                   	leave  
 6ba:	c3                   	ret    

000006bb <morecore>:

static Header*
morecore(uint nu)
{
 6bb:	55                   	push   %ebp
 6bc:	89 e5                	mov    %esp,%ebp
 6be:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6c1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6c8:	77 07                	ja     6d1 <morecore+0x16>
    nu = 4096;
 6ca:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6d1:	8b 45 08             	mov    0x8(%ebp),%eax
 6d4:	c1 e0 03             	shl    $0x3,%eax
 6d7:	89 04 24             	mov    %eax,(%esp)
 6da:	e8 50 fc ff ff       	call   32f <sbrk>
 6df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6e2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6e6:	75 07                	jne    6ef <morecore+0x34>
    return 0;
 6e8:	b8 00 00 00 00       	mov    $0x0,%eax
 6ed:	eb 22                	jmp    711 <morecore+0x56>
  hp = (Header*)p;
 6ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f8:	8b 55 08             	mov    0x8(%ebp),%edx
 6fb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 701:	83 c0 08             	add    $0x8,%eax
 704:	89 04 24             	mov    %eax,(%esp)
 707:	e8 ce fe ff ff       	call   5da <free>
  return freep;
 70c:	a1 7c 0a 00 00       	mov    0xa7c,%eax
}
 711:	c9                   	leave  
 712:	c3                   	ret    

00000713 <malloc>:

void*
malloc(uint nbytes)
{
 713:	55                   	push   %ebp
 714:	89 e5                	mov    %esp,%ebp
 716:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 719:	8b 45 08             	mov    0x8(%ebp),%eax
 71c:	83 c0 07             	add    $0x7,%eax
 71f:	c1 e8 03             	shr    $0x3,%eax
 722:	83 c0 01             	add    $0x1,%eax
 725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 728:	a1 7c 0a 00 00       	mov    0xa7c,%eax
 72d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 730:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 734:	75 23                	jne    759 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 736:	c7 45 f0 74 0a 00 00 	movl   $0xa74,-0x10(%ebp)
 73d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 740:	a3 7c 0a 00 00       	mov    %eax,0xa7c
 745:	a1 7c 0a 00 00       	mov    0xa7c,%eax
 74a:	a3 74 0a 00 00       	mov    %eax,0xa74
    base.s.size = 0;
 74f:	c7 05 78 0a 00 00 00 	movl   $0x0,0xa78
 756:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 759:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75c:	8b 00                	mov    (%eax),%eax
 75e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 761:	8b 45 f4             	mov    -0xc(%ebp),%eax
 764:	8b 40 04             	mov    0x4(%eax),%eax
 767:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 76a:	72 4d                	jb     7b9 <malloc+0xa6>
      if(p->s.size == nunits)
 76c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76f:	8b 40 04             	mov    0x4(%eax),%eax
 772:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 775:	75 0c                	jne    783 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 777:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77a:	8b 10                	mov    (%eax),%edx
 77c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77f:	89 10                	mov    %edx,(%eax)
 781:	eb 26                	jmp    7a9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 783:	8b 45 f4             	mov    -0xc(%ebp),%eax
 786:	8b 40 04             	mov    0x4(%eax),%eax
 789:	2b 45 ec             	sub    -0x14(%ebp),%eax
 78c:	89 c2                	mov    %eax,%edx
 78e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 791:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 794:	8b 45 f4             	mov    -0xc(%ebp),%eax
 797:	8b 40 04             	mov    0x4(%eax),%eax
 79a:	c1 e0 03             	shl    $0x3,%eax
 79d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7a6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ac:	a3 7c 0a 00 00       	mov    %eax,0xa7c
      return (void*)(p + 1);
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	83 c0 08             	add    $0x8,%eax
 7b7:	eb 38                	jmp    7f1 <malloc+0xde>
    }
    if(p == freep)
 7b9:	a1 7c 0a 00 00       	mov    0xa7c,%eax
 7be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7c1:	75 1b                	jne    7de <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7c6:	89 04 24             	mov    %eax,(%esp)
 7c9:	e8 ed fe ff ff       	call   6bb <morecore>
 7ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7d5:	75 07                	jne    7de <malloc+0xcb>
        return 0;
 7d7:	b8 00 00 00 00       	mov    $0x0,%eax
 7dc:	eb 13                	jmp    7f1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e7:	8b 00                	mov    (%eax),%eax
 7e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7ec:	e9 70 ff ff ff       	jmp    761 <malloc+0x4e>
}
 7f1:	c9                   	leave  
 7f2:	c3                   	ret    
