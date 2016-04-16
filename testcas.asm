
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
  1a:	c7 44 24 04 14 08 00 	movl   $0x814,0x4(%esp)
  21:	00 
  22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  29:	e8 19 04 00 00       	call   447 <printf>
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
SYSCALL(sigset)
 347:	b8 16 00 00 00       	mov    $0x16,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <sigsend>:
SYSCALL(sigsend)
 34f:	b8 17 00 00 00       	mov    $0x17,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <sigret>:
SYSCALL(sigret)
 357:	b8 18 00 00 00       	mov    $0x18,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <sigpause>:
 35f:	b8 19 00 00 00       	mov    $0x19,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 367:	55                   	push   %ebp
 368:	89 e5                	mov    %esp,%ebp
 36a:	83 ec 18             	sub    $0x18,%esp
 36d:	8b 45 0c             	mov    0xc(%ebp),%eax
 370:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 373:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 37a:	00 
 37b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 37e:	89 44 24 04          	mov    %eax,0x4(%esp)
 382:	8b 45 08             	mov    0x8(%ebp),%eax
 385:	89 04 24             	mov    %eax,(%esp)
 388:	e8 3a ff ff ff       	call   2c7 <write>
}
 38d:	c9                   	leave  
 38e:	c3                   	ret    

0000038f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 38f:	55                   	push   %ebp
 390:	89 e5                	mov    %esp,%ebp
 392:	56                   	push   %esi
 393:	53                   	push   %ebx
 394:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 397:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 39e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3a2:	74 17                	je     3bb <printint+0x2c>
 3a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3a8:	79 11                	jns    3bb <printint+0x2c>
    neg = 1;
 3aa:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b4:	f7 d8                	neg    %eax
 3b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b9:	eb 06                	jmp    3c1 <printint+0x32>
  } else {
    x = xx;
 3bb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3c8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3cb:	8d 41 01             	lea    0x1(%ecx),%eax
 3ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3d7:	ba 00 00 00 00       	mov    $0x0,%edx
 3dc:	f7 f3                	div    %ebx
 3de:	89 d0                	mov    %edx,%eax
 3e0:	0f b6 80 80 0a 00 00 	movzbl 0xa80(%eax),%eax
 3e7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3eb:	8b 75 10             	mov    0x10(%ebp),%esi
 3ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f1:	ba 00 00 00 00       	mov    $0x0,%edx
 3f6:	f7 f6                	div    %esi
 3f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3ff:	75 c7                	jne    3c8 <printint+0x39>
  if(neg)
 401:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 405:	74 10                	je     417 <printint+0x88>
    buf[i++] = '-';
 407:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40a:	8d 50 01             	lea    0x1(%eax),%edx
 40d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 410:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 415:	eb 1f                	jmp    436 <printint+0xa7>
 417:	eb 1d                	jmp    436 <printint+0xa7>
    putc(fd, buf[i]);
 419:	8d 55 dc             	lea    -0x24(%ebp),%edx
 41c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41f:	01 d0                	add    %edx,%eax
 421:	0f b6 00             	movzbl (%eax),%eax
 424:	0f be c0             	movsbl %al,%eax
 427:	89 44 24 04          	mov    %eax,0x4(%esp)
 42b:	8b 45 08             	mov    0x8(%ebp),%eax
 42e:	89 04 24             	mov    %eax,(%esp)
 431:	e8 31 ff ff ff       	call   367 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 436:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 43a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 43e:	79 d9                	jns    419 <printint+0x8a>
    putc(fd, buf[i]);
}
 440:	83 c4 30             	add    $0x30,%esp
 443:	5b                   	pop    %ebx
 444:	5e                   	pop    %esi
 445:	5d                   	pop    %ebp
 446:	c3                   	ret    

00000447 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 447:	55                   	push   %ebp
 448:	89 e5                	mov    %esp,%ebp
 44a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 44d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 454:	8d 45 0c             	lea    0xc(%ebp),%eax
 457:	83 c0 04             	add    $0x4,%eax
 45a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 45d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 464:	e9 7c 01 00 00       	jmp    5e5 <printf+0x19e>
    c = fmt[i] & 0xff;
 469:	8b 55 0c             	mov    0xc(%ebp),%edx
 46c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 46f:	01 d0                	add    %edx,%eax
 471:	0f b6 00             	movzbl (%eax),%eax
 474:	0f be c0             	movsbl %al,%eax
 477:	25 ff 00 00 00       	and    $0xff,%eax
 47c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 47f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 483:	75 2c                	jne    4b1 <printf+0x6a>
      if(c == '%'){
 485:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 489:	75 0c                	jne    497 <printf+0x50>
        state = '%';
 48b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 492:	e9 4a 01 00 00       	jmp    5e1 <printf+0x19a>
      } else {
        putc(fd, c);
 497:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 49a:	0f be c0             	movsbl %al,%eax
 49d:	89 44 24 04          	mov    %eax,0x4(%esp)
 4a1:	8b 45 08             	mov    0x8(%ebp),%eax
 4a4:	89 04 24             	mov    %eax,(%esp)
 4a7:	e8 bb fe ff ff       	call   367 <putc>
 4ac:	e9 30 01 00 00       	jmp    5e1 <printf+0x19a>
      }
    } else if(state == '%'){
 4b1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4b5:	0f 85 26 01 00 00    	jne    5e1 <printf+0x19a>
      if(c == 'd'){
 4bb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4bf:	75 2d                	jne    4ee <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4c4:	8b 00                	mov    (%eax),%eax
 4c6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4cd:	00 
 4ce:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4d5:	00 
 4d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4da:	8b 45 08             	mov    0x8(%ebp),%eax
 4dd:	89 04 24             	mov    %eax,(%esp)
 4e0:	e8 aa fe ff ff       	call   38f <printint>
        ap++;
 4e5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4e9:	e9 ec 00 00 00       	jmp    5da <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 4ee:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4f2:	74 06                	je     4fa <printf+0xb3>
 4f4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4f8:	75 2d                	jne    527 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4fd:	8b 00                	mov    (%eax),%eax
 4ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 506:	00 
 507:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 50e:	00 
 50f:	89 44 24 04          	mov    %eax,0x4(%esp)
 513:	8b 45 08             	mov    0x8(%ebp),%eax
 516:	89 04 24             	mov    %eax,(%esp)
 519:	e8 71 fe ff ff       	call   38f <printint>
        ap++;
 51e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 522:	e9 b3 00 00 00       	jmp    5da <printf+0x193>
      } else if(c == 's'){
 527:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 52b:	75 45                	jne    572 <printf+0x12b>
        s = (char*)*ap;
 52d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 530:	8b 00                	mov    (%eax),%eax
 532:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 535:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 539:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53d:	75 09                	jne    548 <printf+0x101>
          s = "(null)";
 53f:	c7 45 f4 34 08 00 00 	movl   $0x834,-0xc(%ebp)
        while(*s != 0){
 546:	eb 1e                	jmp    566 <printf+0x11f>
 548:	eb 1c                	jmp    566 <printf+0x11f>
          putc(fd, *s);
 54a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54d:	0f b6 00             	movzbl (%eax),%eax
 550:	0f be c0             	movsbl %al,%eax
 553:	89 44 24 04          	mov    %eax,0x4(%esp)
 557:	8b 45 08             	mov    0x8(%ebp),%eax
 55a:	89 04 24             	mov    %eax,(%esp)
 55d:	e8 05 fe ff ff       	call   367 <putc>
          s++;
 562:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 566:	8b 45 f4             	mov    -0xc(%ebp),%eax
 569:	0f b6 00             	movzbl (%eax),%eax
 56c:	84 c0                	test   %al,%al
 56e:	75 da                	jne    54a <printf+0x103>
 570:	eb 68                	jmp    5da <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 572:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 576:	75 1d                	jne    595 <printf+0x14e>
        putc(fd, *ap);
 578:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57b:	8b 00                	mov    (%eax),%eax
 57d:	0f be c0             	movsbl %al,%eax
 580:	89 44 24 04          	mov    %eax,0x4(%esp)
 584:	8b 45 08             	mov    0x8(%ebp),%eax
 587:	89 04 24             	mov    %eax,(%esp)
 58a:	e8 d8 fd ff ff       	call   367 <putc>
        ap++;
 58f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 593:	eb 45                	jmp    5da <printf+0x193>
      } else if(c == '%'){
 595:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 599:	75 17                	jne    5b2 <printf+0x16b>
        putc(fd, c);
 59b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59e:	0f be c0             	movsbl %al,%eax
 5a1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a5:	8b 45 08             	mov    0x8(%ebp),%eax
 5a8:	89 04 24             	mov    %eax,(%esp)
 5ab:	e8 b7 fd ff ff       	call   367 <putc>
 5b0:	eb 28                	jmp    5da <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5b9:	00 
 5ba:	8b 45 08             	mov    0x8(%ebp),%eax
 5bd:	89 04 24             	mov    %eax,(%esp)
 5c0:	e8 a2 fd ff ff       	call   367 <putc>
        putc(fd, c);
 5c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c8:	0f be c0             	movsbl %al,%eax
 5cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5cf:	8b 45 08             	mov    0x8(%ebp),%eax
 5d2:	89 04 24             	mov    %eax,(%esp)
 5d5:	e8 8d fd ff ff       	call   367 <putc>
      }
      state = 0;
 5da:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5e1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5e5:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5eb:	01 d0                	add    %edx,%eax
 5ed:	0f b6 00             	movzbl (%eax),%eax
 5f0:	84 c0                	test   %al,%al
 5f2:	0f 85 71 fe ff ff    	jne    469 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5f8:	c9                   	leave  
 5f9:	c3                   	ret    

000005fa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5fa:	55                   	push   %ebp
 5fb:	89 e5                	mov    %esp,%ebp
 5fd:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 600:	8b 45 08             	mov    0x8(%ebp),%eax
 603:	83 e8 08             	sub    $0x8,%eax
 606:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 609:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 60e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 611:	eb 24                	jmp    637 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 613:	8b 45 fc             	mov    -0x4(%ebp),%eax
 616:	8b 00                	mov    (%eax),%eax
 618:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61b:	77 12                	ja     62f <free+0x35>
 61d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 620:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 623:	77 24                	ja     649 <free+0x4f>
 625:	8b 45 fc             	mov    -0x4(%ebp),%eax
 628:	8b 00                	mov    (%eax),%eax
 62a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 62d:	77 1a                	ja     649 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 62f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 632:	8b 00                	mov    (%eax),%eax
 634:	89 45 fc             	mov    %eax,-0x4(%ebp)
 637:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63d:	76 d4                	jbe    613 <free+0x19>
 63f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 642:	8b 00                	mov    (%eax),%eax
 644:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 647:	76 ca                	jbe    613 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 649:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64c:	8b 40 04             	mov    0x4(%eax),%eax
 64f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 656:	8b 45 f8             	mov    -0x8(%ebp),%eax
 659:	01 c2                	add    %eax,%edx
 65b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65e:	8b 00                	mov    (%eax),%eax
 660:	39 c2                	cmp    %eax,%edx
 662:	75 24                	jne    688 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 664:	8b 45 f8             	mov    -0x8(%ebp),%eax
 667:	8b 50 04             	mov    0x4(%eax),%edx
 66a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66d:	8b 00                	mov    (%eax),%eax
 66f:	8b 40 04             	mov    0x4(%eax),%eax
 672:	01 c2                	add    %eax,%edx
 674:	8b 45 f8             	mov    -0x8(%ebp),%eax
 677:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 67a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67d:	8b 00                	mov    (%eax),%eax
 67f:	8b 10                	mov    (%eax),%edx
 681:	8b 45 f8             	mov    -0x8(%ebp),%eax
 684:	89 10                	mov    %edx,(%eax)
 686:	eb 0a                	jmp    692 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 688:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68b:	8b 10                	mov    (%eax),%edx
 68d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 690:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 692:	8b 45 fc             	mov    -0x4(%ebp),%eax
 695:	8b 40 04             	mov    0x4(%eax),%eax
 698:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 69f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a2:	01 d0                	add    %edx,%eax
 6a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a7:	75 20                	jne    6c9 <free+0xcf>
    p->s.size += bp->s.size;
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 50 04             	mov    0x4(%eax),%edx
 6af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b2:	8b 40 04             	mov    0x4(%eax),%eax
 6b5:	01 c2                	add    %eax,%edx
 6b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ba:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c0:	8b 10                	mov    (%eax),%edx
 6c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c5:	89 10                	mov    %edx,(%eax)
 6c7:	eb 08                	jmp    6d1 <free+0xd7>
  } else
    p->s.ptr = bp;
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6cf:	89 10                	mov    %edx,(%eax)
  freep = p;
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	a3 9c 0a 00 00       	mov    %eax,0xa9c
}
 6d9:	c9                   	leave  
 6da:	c3                   	ret    

000006db <morecore>:

static Header*
morecore(uint nu)
{
 6db:	55                   	push   %ebp
 6dc:	89 e5                	mov    %esp,%ebp
 6de:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6e1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6e8:	77 07                	ja     6f1 <morecore+0x16>
    nu = 4096;
 6ea:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6f1:	8b 45 08             	mov    0x8(%ebp),%eax
 6f4:	c1 e0 03             	shl    $0x3,%eax
 6f7:	89 04 24             	mov    %eax,(%esp)
 6fa:	e8 30 fc ff ff       	call   32f <sbrk>
 6ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 702:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 706:	75 07                	jne    70f <morecore+0x34>
    return 0;
 708:	b8 00 00 00 00       	mov    $0x0,%eax
 70d:	eb 22                	jmp    731 <morecore+0x56>
  hp = (Header*)p;
 70f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 712:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 715:	8b 45 f0             	mov    -0x10(%ebp),%eax
 718:	8b 55 08             	mov    0x8(%ebp),%edx
 71b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 71e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 721:	83 c0 08             	add    $0x8,%eax
 724:	89 04 24             	mov    %eax,(%esp)
 727:	e8 ce fe ff ff       	call   5fa <free>
  return freep;
 72c:	a1 9c 0a 00 00       	mov    0xa9c,%eax
}
 731:	c9                   	leave  
 732:	c3                   	ret    

00000733 <malloc>:

void*
malloc(uint nbytes)
{
 733:	55                   	push   %ebp
 734:	89 e5                	mov    %esp,%ebp
 736:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 739:	8b 45 08             	mov    0x8(%ebp),%eax
 73c:	83 c0 07             	add    $0x7,%eax
 73f:	c1 e8 03             	shr    $0x3,%eax
 742:	83 c0 01             	add    $0x1,%eax
 745:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 748:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 74d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 750:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 754:	75 23                	jne    779 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 756:	c7 45 f0 94 0a 00 00 	movl   $0xa94,-0x10(%ebp)
 75d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 760:	a3 9c 0a 00 00       	mov    %eax,0xa9c
 765:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 76a:	a3 94 0a 00 00       	mov    %eax,0xa94
    base.s.size = 0;
 76f:	c7 05 98 0a 00 00 00 	movl   $0x0,0xa98
 776:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 779:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77c:	8b 00                	mov    (%eax),%eax
 77e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 781:	8b 45 f4             	mov    -0xc(%ebp),%eax
 784:	8b 40 04             	mov    0x4(%eax),%eax
 787:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 78a:	72 4d                	jb     7d9 <malloc+0xa6>
      if(p->s.size == nunits)
 78c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78f:	8b 40 04             	mov    0x4(%eax),%eax
 792:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 795:	75 0c                	jne    7a3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 797:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79a:	8b 10                	mov    (%eax),%edx
 79c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79f:	89 10                	mov    %edx,(%eax)
 7a1:	eb 26                	jmp    7c9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a6:	8b 40 04             	mov    0x4(%eax),%eax
 7a9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7ac:	89 c2                	mov    %eax,%edx
 7ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b7:	8b 40 04             	mov    0x4(%eax),%eax
 7ba:	c1 e0 03             	shl    $0x3,%eax
 7bd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7c6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cc:	a3 9c 0a 00 00       	mov    %eax,0xa9c
      return (void*)(p + 1);
 7d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d4:	83 c0 08             	add    $0x8,%eax
 7d7:	eb 38                	jmp    811 <malloc+0xde>
    }
    if(p == freep)
 7d9:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 7de:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7e1:	75 1b                	jne    7fe <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7e6:	89 04 24             	mov    %eax,(%esp)
 7e9:	e8 ed fe ff ff       	call   6db <morecore>
 7ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f5:	75 07                	jne    7fe <malloc+0xcb>
        return 0;
 7f7:	b8 00 00 00 00       	mov    $0x0,%eax
 7fc:	eb 13                	jmp    811 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 801:	89 45 f0             	mov    %eax,-0x10(%ebp)
 804:	8b 45 f4             	mov    -0xc(%ebp),%eax
 807:	8b 00                	mov    (%eax),%eax
 809:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 80c:	e9 70 ff ff ff       	jmp    781 <malloc+0x4e>
}
 811:	c9                   	leave  
 812:	c3                   	ret    
