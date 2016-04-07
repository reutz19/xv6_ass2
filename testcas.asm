
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
  1a:	c7 44 24 04 fc 07 00 	movl   $0x7fc,0x4(%esp)
  21:	00 
  22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  29:	e8 01 04 00 00       	call   42f <printf>
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

00000347 <sigset>:
 347:	b8 16 00 00 00       	mov    $0x16,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 34f:	55                   	push   %ebp
 350:	89 e5                	mov    %esp,%ebp
 352:	83 ec 18             	sub    $0x18,%esp
 355:	8b 45 0c             	mov    0xc(%ebp),%eax
 358:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 35b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 362:	00 
 363:	8d 45 f4             	lea    -0xc(%ebp),%eax
 366:	89 44 24 04          	mov    %eax,0x4(%esp)
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
 36d:	89 04 24             	mov    %eax,(%esp)
 370:	e8 52 ff ff ff       	call   2c7 <write>
}
 375:	c9                   	leave  
 376:	c3                   	ret    

00000377 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 377:	55                   	push   %ebp
 378:	89 e5                	mov    %esp,%ebp
 37a:	56                   	push   %esi
 37b:	53                   	push   %ebx
 37c:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 37f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 386:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 38a:	74 17                	je     3a3 <printint+0x2c>
 38c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 390:	79 11                	jns    3a3 <printint+0x2c>
    neg = 1;
 392:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 399:	8b 45 0c             	mov    0xc(%ebp),%eax
 39c:	f7 d8                	neg    %eax
 39e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3a1:	eb 06                	jmp    3a9 <printint+0x32>
  } else {
    x = xx;
 3a3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3b0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3b3:	8d 41 01             	lea    0x1(%ecx),%eax
 3b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3bf:	ba 00 00 00 00       	mov    $0x0,%edx
 3c4:	f7 f3                	div    %ebx
 3c6:	89 d0                	mov    %edx,%eax
 3c8:	0f b6 80 68 0a 00 00 	movzbl 0xa68(%eax),%eax
 3cf:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3d3:	8b 75 10             	mov    0x10(%ebp),%esi
 3d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3d9:	ba 00 00 00 00       	mov    $0x0,%edx
 3de:	f7 f6                	div    %esi
 3e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3e7:	75 c7                	jne    3b0 <printint+0x39>
  if(neg)
 3e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3ed:	74 10                	je     3ff <printint+0x88>
    buf[i++] = '-';
 3ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f2:	8d 50 01             	lea    0x1(%eax),%edx
 3f5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3f8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3fd:	eb 1f                	jmp    41e <printint+0xa7>
 3ff:	eb 1d                	jmp    41e <printint+0xa7>
    putc(fd, buf[i]);
 401:	8d 55 dc             	lea    -0x24(%ebp),%edx
 404:	8b 45 f4             	mov    -0xc(%ebp),%eax
 407:	01 d0                	add    %edx,%eax
 409:	0f b6 00             	movzbl (%eax),%eax
 40c:	0f be c0             	movsbl %al,%eax
 40f:	89 44 24 04          	mov    %eax,0x4(%esp)
 413:	8b 45 08             	mov    0x8(%ebp),%eax
 416:	89 04 24             	mov    %eax,(%esp)
 419:	e8 31 ff ff ff       	call   34f <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 41e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 422:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 426:	79 d9                	jns    401 <printint+0x8a>
    putc(fd, buf[i]);
}
 428:	83 c4 30             	add    $0x30,%esp
 42b:	5b                   	pop    %ebx
 42c:	5e                   	pop    %esi
 42d:	5d                   	pop    %ebp
 42e:	c3                   	ret    

0000042f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 42f:	55                   	push   %ebp
 430:	89 e5                	mov    %esp,%ebp
 432:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 435:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 43c:	8d 45 0c             	lea    0xc(%ebp),%eax
 43f:	83 c0 04             	add    $0x4,%eax
 442:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 445:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 44c:	e9 7c 01 00 00       	jmp    5cd <printf+0x19e>
    c = fmt[i] & 0xff;
 451:	8b 55 0c             	mov    0xc(%ebp),%edx
 454:	8b 45 f0             	mov    -0x10(%ebp),%eax
 457:	01 d0                	add    %edx,%eax
 459:	0f b6 00             	movzbl (%eax),%eax
 45c:	0f be c0             	movsbl %al,%eax
 45f:	25 ff 00 00 00       	and    $0xff,%eax
 464:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 467:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 46b:	75 2c                	jne    499 <printf+0x6a>
      if(c == '%'){
 46d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 471:	75 0c                	jne    47f <printf+0x50>
        state = '%';
 473:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 47a:	e9 4a 01 00 00       	jmp    5c9 <printf+0x19a>
      } else {
        putc(fd, c);
 47f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 482:	0f be c0             	movsbl %al,%eax
 485:	89 44 24 04          	mov    %eax,0x4(%esp)
 489:	8b 45 08             	mov    0x8(%ebp),%eax
 48c:	89 04 24             	mov    %eax,(%esp)
 48f:	e8 bb fe ff ff       	call   34f <putc>
 494:	e9 30 01 00 00       	jmp    5c9 <printf+0x19a>
      }
    } else if(state == '%'){
 499:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 49d:	0f 85 26 01 00 00    	jne    5c9 <printf+0x19a>
      if(c == 'd'){
 4a3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4a7:	75 2d                	jne    4d6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ac:	8b 00                	mov    (%eax),%eax
 4ae:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4b5:	00 
 4b6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4bd:	00 
 4be:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c2:	8b 45 08             	mov    0x8(%ebp),%eax
 4c5:	89 04 24             	mov    %eax,(%esp)
 4c8:	e8 aa fe ff ff       	call   377 <printint>
        ap++;
 4cd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d1:	e9 ec 00 00 00       	jmp    5c2 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 4d6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4da:	74 06                	je     4e2 <printf+0xb3>
 4dc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4e0:	75 2d                	jne    50f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e5:	8b 00                	mov    (%eax),%eax
 4e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4ee:	00 
 4ef:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4f6:	00 
 4f7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4fb:	8b 45 08             	mov    0x8(%ebp),%eax
 4fe:	89 04 24             	mov    %eax,(%esp)
 501:	e8 71 fe ff ff       	call   377 <printint>
        ap++;
 506:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 50a:	e9 b3 00 00 00       	jmp    5c2 <printf+0x193>
      } else if(c == 's'){
 50f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 513:	75 45                	jne    55a <printf+0x12b>
        s = (char*)*ap;
 515:	8b 45 e8             	mov    -0x18(%ebp),%eax
 518:	8b 00                	mov    (%eax),%eax
 51a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 51d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 521:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 525:	75 09                	jne    530 <printf+0x101>
          s = "(null)";
 527:	c7 45 f4 1c 08 00 00 	movl   $0x81c,-0xc(%ebp)
        while(*s != 0){
 52e:	eb 1e                	jmp    54e <printf+0x11f>
 530:	eb 1c                	jmp    54e <printf+0x11f>
          putc(fd, *s);
 532:	8b 45 f4             	mov    -0xc(%ebp),%eax
 535:	0f b6 00             	movzbl (%eax),%eax
 538:	0f be c0             	movsbl %al,%eax
 53b:	89 44 24 04          	mov    %eax,0x4(%esp)
 53f:	8b 45 08             	mov    0x8(%ebp),%eax
 542:	89 04 24             	mov    %eax,(%esp)
 545:	e8 05 fe ff ff       	call   34f <putc>
          s++;
 54a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 54e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 551:	0f b6 00             	movzbl (%eax),%eax
 554:	84 c0                	test   %al,%al
 556:	75 da                	jne    532 <printf+0x103>
 558:	eb 68                	jmp    5c2 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 55a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 55e:	75 1d                	jne    57d <printf+0x14e>
        putc(fd, *ap);
 560:	8b 45 e8             	mov    -0x18(%ebp),%eax
 563:	8b 00                	mov    (%eax),%eax
 565:	0f be c0             	movsbl %al,%eax
 568:	89 44 24 04          	mov    %eax,0x4(%esp)
 56c:	8b 45 08             	mov    0x8(%ebp),%eax
 56f:	89 04 24             	mov    %eax,(%esp)
 572:	e8 d8 fd ff ff       	call   34f <putc>
        ap++;
 577:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 57b:	eb 45                	jmp    5c2 <printf+0x193>
      } else if(c == '%'){
 57d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 581:	75 17                	jne    59a <printf+0x16b>
        putc(fd, c);
 583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 586:	0f be c0             	movsbl %al,%eax
 589:	89 44 24 04          	mov    %eax,0x4(%esp)
 58d:	8b 45 08             	mov    0x8(%ebp),%eax
 590:	89 04 24             	mov    %eax,(%esp)
 593:	e8 b7 fd ff ff       	call   34f <putc>
 598:	eb 28                	jmp    5c2 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 59a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5a1:	00 
 5a2:	8b 45 08             	mov    0x8(%ebp),%eax
 5a5:	89 04 24             	mov    %eax,(%esp)
 5a8:	e8 a2 fd ff ff       	call   34f <putc>
        putc(fd, c);
 5ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b0:	0f be c0             	movsbl %al,%eax
 5b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ba:	89 04 24             	mov    %eax,(%esp)
 5bd:	e8 8d fd ff ff       	call   34f <putc>
      }
      state = 0;
 5c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5c9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5cd:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d3:	01 d0                	add    %edx,%eax
 5d5:	0f b6 00             	movzbl (%eax),%eax
 5d8:	84 c0                	test   %al,%al
 5da:	0f 85 71 fe ff ff    	jne    451 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5e0:	c9                   	leave  
 5e1:	c3                   	ret    

000005e2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5e2:	55                   	push   %ebp
 5e3:	89 e5                	mov    %esp,%ebp
 5e5:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5e8:	8b 45 08             	mov    0x8(%ebp),%eax
 5eb:	83 e8 08             	sub    $0x8,%eax
 5ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5f1:	a1 84 0a 00 00       	mov    0xa84,%eax
 5f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f9:	eb 24                	jmp    61f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fe:	8b 00                	mov    (%eax),%eax
 600:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 603:	77 12                	ja     617 <free+0x35>
 605:	8b 45 f8             	mov    -0x8(%ebp),%eax
 608:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 60b:	77 24                	ja     631 <free+0x4f>
 60d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 615:	77 1a                	ja     631 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 617:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61a:	8b 00                	mov    (%eax),%eax
 61c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 61f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 622:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 625:	76 d4                	jbe    5fb <free+0x19>
 627:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62a:	8b 00                	mov    (%eax),%eax
 62c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 62f:	76 ca                	jbe    5fb <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 631:	8b 45 f8             	mov    -0x8(%ebp),%eax
 634:	8b 40 04             	mov    0x4(%eax),%eax
 637:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 63e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 641:	01 c2                	add    %eax,%edx
 643:	8b 45 fc             	mov    -0x4(%ebp),%eax
 646:	8b 00                	mov    (%eax),%eax
 648:	39 c2                	cmp    %eax,%edx
 64a:	75 24                	jne    670 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 64c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64f:	8b 50 04             	mov    0x4(%eax),%edx
 652:	8b 45 fc             	mov    -0x4(%ebp),%eax
 655:	8b 00                	mov    (%eax),%eax
 657:	8b 40 04             	mov    0x4(%eax),%eax
 65a:	01 c2                	add    %eax,%edx
 65c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 662:	8b 45 fc             	mov    -0x4(%ebp),%eax
 665:	8b 00                	mov    (%eax),%eax
 667:	8b 10                	mov    (%eax),%edx
 669:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66c:	89 10                	mov    %edx,(%eax)
 66e:	eb 0a                	jmp    67a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 670:	8b 45 fc             	mov    -0x4(%ebp),%eax
 673:	8b 10                	mov    (%eax),%edx
 675:	8b 45 f8             	mov    -0x8(%ebp),%eax
 678:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 67a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67d:	8b 40 04             	mov    0x4(%eax),%eax
 680:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68a:	01 d0                	add    %edx,%eax
 68c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 68f:	75 20                	jne    6b1 <free+0xcf>
    p->s.size += bp->s.size;
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 50 04             	mov    0x4(%eax),%edx
 697:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69a:	8b 40 04             	mov    0x4(%eax),%eax
 69d:	01 c2                	add    %eax,%edx
 69f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a8:	8b 10                	mov    (%eax),%edx
 6aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ad:	89 10                	mov    %edx,(%eax)
 6af:	eb 08                	jmp    6b9 <free+0xd7>
  } else
    p->s.ptr = bp;
 6b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6b7:	89 10                	mov    %edx,(%eax)
  freep = p;
 6b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bc:	a3 84 0a 00 00       	mov    %eax,0xa84
}
 6c1:	c9                   	leave  
 6c2:	c3                   	ret    

000006c3 <morecore>:

static Header*
morecore(uint nu)
{
 6c3:	55                   	push   %ebp
 6c4:	89 e5                	mov    %esp,%ebp
 6c6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6c9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6d0:	77 07                	ja     6d9 <morecore+0x16>
    nu = 4096;
 6d2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6d9:	8b 45 08             	mov    0x8(%ebp),%eax
 6dc:	c1 e0 03             	shl    $0x3,%eax
 6df:	89 04 24             	mov    %eax,(%esp)
 6e2:	e8 48 fc ff ff       	call   32f <sbrk>
 6e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6ea:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ee:	75 07                	jne    6f7 <morecore+0x34>
    return 0;
 6f0:	b8 00 00 00 00       	mov    $0x0,%eax
 6f5:	eb 22                	jmp    719 <morecore+0x56>
  hp = (Header*)p;
 6f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 700:	8b 55 08             	mov    0x8(%ebp),%edx
 703:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 706:	8b 45 f0             	mov    -0x10(%ebp),%eax
 709:	83 c0 08             	add    $0x8,%eax
 70c:	89 04 24             	mov    %eax,(%esp)
 70f:	e8 ce fe ff ff       	call   5e2 <free>
  return freep;
 714:	a1 84 0a 00 00       	mov    0xa84,%eax
}
 719:	c9                   	leave  
 71a:	c3                   	ret    

0000071b <malloc>:

void*
malloc(uint nbytes)
{
 71b:	55                   	push   %ebp
 71c:	89 e5                	mov    %esp,%ebp
 71e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 721:	8b 45 08             	mov    0x8(%ebp),%eax
 724:	83 c0 07             	add    $0x7,%eax
 727:	c1 e8 03             	shr    $0x3,%eax
 72a:	83 c0 01             	add    $0x1,%eax
 72d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 730:	a1 84 0a 00 00       	mov    0xa84,%eax
 735:	89 45 f0             	mov    %eax,-0x10(%ebp)
 738:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 73c:	75 23                	jne    761 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 73e:	c7 45 f0 7c 0a 00 00 	movl   $0xa7c,-0x10(%ebp)
 745:	8b 45 f0             	mov    -0x10(%ebp),%eax
 748:	a3 84 0a 00 00       	mov    %eax,0xa84
 74d:	a1 84 0a 00 00       	mov    0xa84,%eax
 752:	a3 7c 0a 00 00       	mov    %eax,0xa7c
    base.s.size = 0;
 757:	c7 05 80 0a 00 00 00 	movl   $0x0,0xa80
 75e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 761:	8b 45 f0             	mov    -0x10(%ebp),%eax
 764:	8b 00                	mov    (%eax),%eax
 766:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 769:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76c:	8b 40 04             	mov    0x4(%eax),%eax
 76f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 772:	72 4d                	jb     7c1 <malloc+0xa6>
      if(p->s.size == nunits)
 774:	8b 45 f4             	mov    -0xc(%ebp),%eax
 777:	8b 40 04             	mov    0x4(%eax),%eax
 77a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 77d:	75 0c                	jne    78b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 77f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 782:	8b 10                	mov    (%eax),%edx
 784:	8b 45 f0             	mov    -0x10(%ebp),%eax
 787:	89 10                	mov    %edx,(%eax)
 789:	eb 26                	jmp    7b1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	8b 40 04             	mov    0x4(%eax),%eax
 791:	2b 45 ec             	sub    -0x14(%ebp),%eax
 794:	89 c2                	mov    %eax,%edx
 796:	8b 45 f4             	mov    -0xc(%ebp),%eax
 799:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 79c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79f:	8b 40 04             	mov    0x4(%eax),%eax
 7a2:	c1 e0 03             	shl    $0x3,%eax
 7a5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7ae:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b4:	a3 84 0a 00 00       	mov    %eax,0xa84
      return (void*)(p + 1);
 7b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bc:	83 c0 08             	add    $0x8,%eax
 7bf:	eb 38                	jmp    7f9 <malloc+0xde>
    }
    if(p == freep)
 7c1:	a1 84 0a 00 00       	mov    0xa84,%eax
 7c6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7c9:	75 1b                	jne    7e6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7ce:	89 04 24             	mov    %eax,(%esp)
 7d1:	e8 ed fe ff ff       	call   6c3 <morecore>
 7d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7dd:	75 07                	jne    7e6 <malloc+0xcb>
        return 0;
 7df:	b8 00 00 00 00       	mov    $0x0,%eax
 7e4:	eb 13                	jmp    7f9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ef:	8b 00                	mov    (%eax),%eax
 7f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7f4:	e9 70 ff ff ff       	jmp    769 <malloc+0x4e>
}
 7f9:	c9                   	leave  
 7fa:	c3                   	ret    
