
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10:	00 
  11:	c7 04 24 d6 08 00 00 	movl   $0x8d6,(%esp)
  18:	e8 9a 03 00 00       	call   3b7 <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 d6 08 00 00 	movl   $0x8d6,(%esp)
  38:	e8 82 03 00 00       	call   3bf <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 d6 08 00 00 	movl   $0x8d6,(%esp)
  4c:	e8 66 03 00 00       	call   3b7 <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 92 03 00 00       	call   3ef <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 86 03 00 00       	call   3ef <dup>

  for(;;){
    printf(1, "init: starting sh\n");
  69:	c7 44 24 04 de 08 00 	movl   $0x8de,0x4(%esp)
  70:	00 
  71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  78:	e8 8a 04 00 00       	call   507 <printf>
    pid = fork();
  7d:	e8 ed 02 00 00       	call   36f <fork>
  82:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  86:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8b:	79 19                	jns    a6 <main+0xa6>
      printf(1, "init: fork failed\n");
  8d:	c7 44 24 04 f1 08 00 	movl   $0x8f1,0x4(%esp)
  94:	00 
  95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9c:	e8 66 04 00 00       	call   507 <printf>
      exit();
  a1:	e8 d1 02 00 00       	call   377 <exit>
    }
    if(pid == 0){
  a6:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  ab:	75 2d                	jne    da <main+0xda>
      exec("sh", argv);
  ad:	c7 44 24 04 70 0b 00 	movl   $0xb70,0x4(%esp)
  b4:	00 
  b5:	c7 04 24 d3 08 00 00 	movl   $0x8d3,(%esp)
  bc:	e8 ee 02 00 00       	call   3af <exec>
      printf(1, "init: exec sh failed\n");
  c1:	c7 44 24 04 04 09 00 	movl   $0x904,0x4(%esp)
  c8:	00 
  c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d0:	e8 32 04 00 00       	call   507 <printf>
      exit();
  d5:	e8 9d 02 00 00       	call   377 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  da:	eb 14                	jmp    f0 <main+0xf0>
      printf(1, "zombie!\n");
  dc:	c7 44 24 04 1a 09 00 	movl   $0x91a,0x4(%esp)
  e3:	00 
  e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  eb:	e8 17 04 00 00       	call   507 <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f0:	e8 8a 02 00 00       	call   37f <wait>
  f5:	89 44 24 18          	mov    %eax,0x18(%esp)
  f9:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  fe:	78 0a                	js     10a <main+0x10a>
 100:	8b 44 24 18          	mov    0x18(%esp),%eax
 104:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 108:	75 d2                	jne    dc <main+0xdc>
      printf(1, "zombie!\n");
  }
 10a:	e9 5a ff ff ff       	jmp    69 <main+0x69>

0000010f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	57                   	push   %edi
 113:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 114:	8b 4d 08             	mov    0x8(%ebp),%ecx
 117:	8b 55 10             	mov    0x10(%ebp),%edx
 11a:	8b 45 0c             	mov    0xc(%ebp),%eax
 11d:	89 cb                	mov    %ecx,%ebx
 11f:	89 df                	mov    %ebx,%edi
 121:	89 d1                	mov    %edx,%ecx
 123:	fc                   	cld    
 124:	f3 aa                	rep stos %al,%es:(%edi)
 126:	89 ca                	mov    %ecx,%edx
 128:	89 fb                	mov    %edi,%ebx
 12a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 130:	5b                   	pop    %ebx
 131:	5f                   	pop    %edi
 132:	5d                   	pop    %ebp
 133:	c3                   	ret    

00000134 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 140:	90                   	nop
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	8d 50 01             	lea    0x1(%eax),%edx
 147:	89 55 08             	mov    %edx,0x8(%ebp)
 14a:	8b 55 0c             	mov    0xc(%ebp),%edx
 14d:	8d 4a 01             	lea    0x1(%edx),%ecx
 150:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 153:	0f b6 12             	movzbl (%edx),%edx
 156:	88 10                	mov    %dl,(%eax)
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	84 c0                	test   %al,%al
 15d:	75 e2                	jne    141 <strcpy+0xd>
    ;
  return os;
 15f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 162:	c9                   	leave  
 163:	c3                   	ret    

00000164 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 167:	eb 08                	jmp    171 <strcmp+0xd>
    p++, q++;
 169:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 171:	8b 45 08             	mov    0x8(%ebp),%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	84 c0                	test   %al,%al
 179:	74 10                	je     18b <strcmp+0x27>
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	0f b6 10             	movzbl (%eax),%edx
 181:	8b 45 0c             	mov    0xc(%ebp),%eax
 184:	0f b6 00             	movzbl (%eax),%eax
 187:	38 c2                	cmp    %al,%dl
 189:	74 de                	je     169 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
 18e:	0f b6 00             	movzbl (%eax),%eax
 191:	0f b6 d0             	movzbl %al,%edx
 194:	8b 45 0c             	mov    0xc(%ebp),%eax
 197:	0f b6 00             	movzbl (%eax),%eax
 19a:	0f b6 c0             	movzbl %al,%eax
 19d:	29 c2                	sub    %eax,%edx
 19f:	89 d0                	mov    %edx,%eax
}
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    

000001a3 <strlen>:

uint
strlen(char *s)
{
 1a3:	55                   	push   %ebp
 1a4:	89 e5                	mov    %esp,%ebp
 1a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b0:	eb 04                	jmp    1b6 <strlen+0x13>
 1b2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b9:	8b 45 08             	mov    0x8(%ebp),%eax
 1bc:	01 d0                	add    %edx,%eax
 1be:	0f b6 00             	movzbl (%eax),%eax
 1c1:	84 c0                	test   %al,%al
 1c3:	75 ed                	jne    1b2 <strlen+0xf>
    ;
  return n;
 1c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c8:	c9                   	leave  
 1c9:	c3                   	ret    

000001ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ca:	55                   	push   %ebp
 1cb:	89 e5                	mov    %esp,%ebp
 1cd:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1d0:	8b 45 10             	mov    0x10(%ebp),%eax
 1d3:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1da:	89 44 24 04          	mov    %eax,0x4(%esp)
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	89 04 24             	mov    %eax,(%esp)
 1e4:	e8 26 ff ff ff       	call   10f <stosb>
  return dst;
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ec:	c9                   	leave  
 1ed:	c3                   	ret    

000001ee <strchr>:

char*
strchr(const char *s, char c)
{
 1ee:	55                   	push   %ebp
 1ef:	89 e5                	mov    %esp,%ebp
 1f1:	83 ec 04             	sub    $0x4,%esp
 1f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1fa:	eb 14                	jmp    210 <strchr+0x22>
    if(*s == c)
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	0f b6 00             	movzbl (%eax),%eax
 202:	3a 45 fc             	cmp    -0x4(%ebp),%al
 205:	75 05                	jne    20c <strchr+0x1e>
      return (char*)s;
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	eb 13                	jmp    21f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 20c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	0f b6 00             	movzbl (%eax),%eax
 216:	84 c0                	test   %al,%al
 218:	75 e2                	jne    1fc <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 21a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 21f:	c9                   	leave  
 220:	c3                   	ret    

00000221 <gets>:

char*
gets(char *buf, int max)
{
 221:	55                   	push   %ebp
 222:	89 e5                	mov    %esp,%ebp
 224:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 227:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 22e:	eb 4c                	jmp    27c <gets+0x5b>
    cc = read(0, &c, 1);
 230:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 237:	00 
 238:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23b:	89 44 24 04          	mov    %eax,0x4(%esp)
 23f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 246:	e8 44 01 00 00       	call   38f <read>
 24b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 24e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 252:	7f 02                	jg     256 <gets+0x35>
      break;
 254:	eb 31                	jmp    287 <gets+0x66>
    buf[i++] = c;
 256:	8b 45 f4             	mov    -0xc(%ebp),%eax
 259:	8d 50 01             	lea    0x1(%eax),%edx
 25c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 25f:	89 c2                	mov    %eax,%edx
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	01 c2                	add    %eax,%edx
 266:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 26c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 270:	3c 0a                	cmp    $0xa,%al
 272:	74 13                	je     287 <gets+0x66>
 274:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 278:	3c 0d                	cmp    $0xd,%al
 27a:	74 0b                	je     287 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27f:	83 c0 01             	add    $0x1,%eax
 282:	3b 45 0c             	cmp    0xc(%ebp),%eax
 285:	7c a9                	jl     230 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 287:	8b 55 f4             	mov    -0xc(%ebp),%edx
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	01 d0                	add    %edx,%eax
 28f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 292:	8b 45 08             	mov    0x8(%ebp),%eax
}
 295:	c9                   	leave  
 296:	c3                   	ret    

00000297 <stat>:

int
stat(char *n, struct stat *st)
{
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a4:	00 
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	89 04 24             	mov    %eax,(%esp)
 2ab:	e8 07 01 00 00       	call   3b7 <open>
 2b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b7:	79 07                	jns    2c0 <stat+0x29>
    return -1;
 2b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2be:	eb 23                	jmp    2e3 <stat+0x4c>
  r = fstat(fd, st);
 2c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ca:	89 04 24             	mov    %eax,(%esp)
 2cd:	e8 fd 00 00 00       	call   3cf <fstat>
 2d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 bf 00 00 00       	call   39f <close>
  return r;
 2e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e3:	c9                   	leave  
 2e4:	c3                   	ret    

000002e5 <atoi>:

int
atoi(const char *s)
{
 2e5:	55                   	push   %ebp
 2e6:	89 e5                	mov    %esp,%ebp
 2e8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f2:	eb 25                	jmp    319 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f7:	89 d0                	mov    %edx,%eax
 2f9:	c1 e0 02             	shl    $0x2,%eax
 2fc:	01 d0                	add    %edx,%eax
 2fe:	01 c0                	add    %eax,%eax
 300:	89 c1                	mov    %eax,%ecx
 302:	8b 45 08             	mov    0x8(%ebp),%eax
 305:	8d 50 01             	lea    0x1(%eax),%edx
 308:	89 55 08             	mov    %edx,0x8(%ebp)
 30b:	0f b6 00             	movzbl (%eax),%eax
 30e:	0f be c0             	movsbl %al,%eax
 311:	01 c8                	add    %ecx,%eax
 313:	83 e8 30             	sub    $0x30,%eax
 316:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	3c 2f                	cmp    $0x2f,%al
 321:	7e 0a                	jle    32d <atoi+0x48>
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	3c 39                	cmp    $0x39,%al
 32b:	7e c7                	jle    2f4 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33e:	8b 45 0c             	mov    0xc(%ebp),%eax
 341:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 344:	eb 17                	jmp    35d <memmove+0x2b>
    *dst++ = *src++;
 346:	8b 45 fc             	mov    -0x4(%ebp),%eax
 349:	8d 50 01             	lea    0x1(%eax),%edx
 34c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 34f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 352:	8d 4a 01             	lea    0x1(%edx),%ecx
 355:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 358:	0f b6 12             	movzbl (%edx),%edx
 35b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35d:	8b 45 10             	mov    0x10(%ebp),%eax
 360:	8d 50 ff             	lea    -0x1(%eax),%edx
 363:	89 55 10             	mov    %edx,0x10(%ebp)
 366:	85 c0                	test   %eax,%eax
 368:	7f dc                	jg     346 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36d:	c9                   	leave  
 36e:	c3                   	ret    

0000036f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 36f:	b8 01 00 00 00       	mov    $0x1,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <exit>:
SYSCALL(exit)
 377:	b8 02 00 00 00       	mov    $0x2,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <wait>:
SYSCALL(wait)
 37f:	b8 03 00 00 00       	mov    $0x3,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <pipe>:
SYSCALL(pipe)
 387:	b8 04 00 00 00       	mov    $0x4,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <read>:
SYSCALL(read)
 38f:	b8 05 00 00 00       	mov    $0x5,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <write>:
SYSCALL(write)
 397:	b8 10 00 00 00       	mov    $0x10,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <close>:
SYSCALL(close)
 39f:	b8 15 00 00 00       	mov    $0x15,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <kill>:
SYSCALL(kill)
 3a7:	b8 06 00 00 00       	mov    $0x6,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <exec>:
SYSCALL(exec)
 3af:	b8 07 00 00 00       	mov    $0x7,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <open>:
SYSCALL(open)
 3b7:	b8 0f 00 00 00       	mov    $0xf,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <mknod>:
SYSCALL(mknod)
 3bf:	b8 11 00 00 00       	mov    $0x11,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <unlink>:
SYSCALL(unlink)
 3c7:	b8 12 00 00 00       	mov    $0x12,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <fstat>:
SYSCALL(fstat)
 3cf:	b8 08 00 00 00       	mov    $0x8,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <link>:
SYSCALL(link)
 3d7:	b8 13 00 00 00       	mov    $0x13,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <mkdir>:
SYSCALL(mkdir)
 3df:	b8 14 00 00 00       	mov    $0x14,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <chdir>:
SYSCALL(chdir)
 3e7:	b8 09 00 00 00       	mov    $0x9,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <dup>:
SYSCALL(dup)
 3ef:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <getpid>:
SYSCALL(getpid)
 3f7:	b8 0b 00 00 00       	mov    $0xb,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <sbrk>:
SYSCALL(sbrk)
 3ff:	b8 0c 00 00 00       	mov    $0xc,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <sleep>:
SYSCALL(sleep)
 407:	b8 0d 00 00 00       	mov    $0xd,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <uptime>:
SYSCALL(uptime)
 40f:	b8 0e 00 00 00       	mov    $0xe,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <sigset>:
SYSCALL(sigset)
 417:	b8 16 00 00 00       	mov    $0x16,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <sigsend>:
 41f:	b8 17 00 00 00       	mov    $0x17,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 427:	55                   	push   %ebp
 428:	89 e5                	mov    %esp,%ebp
 42a:	83 ec 18             	sub    $0x18,%esp
 42d:	8b 45 0c             	mov    0xc(%ebp),%eax
 430:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 433:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 43a:	00 
 43b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 43e:	89 44 24 04          	mov    %eax,0x4(%esp)
 442:	8b 45 08             	mov    0x8(%ebp),%eax
 445:	89 04 24             	mov    %eax,(%esp)
 448:	e8 4a ff ff ff       	call   397 <write>
}
 44d:	c9                   	leave  
 44e:	c3                   	ret    

0000044f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 44f:	55                   	push   %ebp
 450:	89 e5                	mov    %esp,%ebp
 452:	56                   	push   %esi
 453:	53                   	push   %ebx
 454:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 457:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 45e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 462:	74 17                	je     47b <printint+0x2c>
 464:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 468:	79 11                	jns    47b <printint+0x2c>
    neg = 1;
 46a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 471:	8b 45 0c             	mov    0xc(%ebp),%eax
 474:	f7 d8                	neg    %eax
 476:	89 45 ec             	mov    %eax,-0x14(%ebp)
 479:	eb 06                	jmp    481 <printint+0x32>
  } else {
    x = xx;
 47b:	8b 45 0c             	mov    0xc(%ebp),%eax
 47e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 481:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 488:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 48b:	8d 41 01             	lea    0x1(%ecx),%eax
 48e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 491:	8b 5d 10             	mov    0x10(%ebp),%ebx
 494:	8b 45 ec             	mov    -0x14(%ebp),%eax
 497:	ba 00 00 00 00       	mov    $0x0,%edx
 49c:	f7 f3                	div    %ebx
 49e:	89 d0                	mov    %edx,%eax
 4a0:	0f b6 80 78 0b 00 00 	movzbl 0xb78(%eax),%eax
 4a7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4ab:	8b 75 10             	mov    0x10(%ebp),%esi
 4ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b1:	ba 00 00 00 00       	mov    $0x0,%edx
 4b6:	f7 f6                	div    %esi
 4b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4bf:	75 c7                	jne    488 <printint+0x39>
  if(neg)
 4c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4c5:	74 10                	je     4d7 <printint+0x88>
    buf[i++] = '-';
 4c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ca:	8d 50 01             	lea    0x1(%eax),%edx
 4cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4d0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4d5:	eb 1f                	jmp    4f6 <printint+0xa7>
 4d7:	eb 1d                	jmp    4f6 <printint+0xa7>
    putc(fd, buf[i]);
 4d9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4df:	01 d0                	add    %edx,%eax
 4e1:	0f b6 00             	movzbl (%eax),%eax
 4e4:	0f be c0             	movsbl %al,%eax
 4e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	89 04 24             	mov    %eax,(%esp)
 4f1:	e8 31 ff ff ff       	call   427 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4f6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4fe:	79 d9                	jns    4d9 <printint+0x8a>
    putc(fd, buf[i]);
}
 500:	83 c4 30             	add    $0x30,%esp
 503:	5b                   	pop    %ebx
 504:	5e                   	pop    %esi
 505:	5d                   	pop    %ebp
 506:	c3                   	ret    

00000507 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 507:	55                   	push   %ebp
 508:	89 e5                	mov    %esp,%ebp
 50a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 50d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 514:	8d 45 0c             	lea    0xc(%ebp),%eax
 517:	83 c0 04             	add    $0x4,%eax
 51a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 51d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 524:	e9 7c 01 00 00       	jmp    6a5 <printf+0x19e>
    c = fmt[i] & 0xff;
 529:	8b 55 0c             	mov    0xc(%ebp),%edx
 52c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 52f:	01 d0                	add    %edx,%eax
 531:	0f b6 00             	movzbl (%eax),%eax
 534:	0f be c0             	movsbl %al,%eax
 537:	25 ff 00 00 00       	and    $0xff,%eax
 53c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 53f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 543:	75 2c                	jne    571 <printf+0x6a>
      if(c == '%'){
 545:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 549:	75 0c                	jne    557 <printf+0x50>
        state = '%';
 54b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 552:	e9 4a 01 00 00       	jmp    6a1 <printf+0x19a>
      } else {
        putc(fd, c);
 557:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55a:	0f be c0             	movsbl %al,%eax
 55d:	89 44 24 04          	mov    %eax,0x4(%esp)
 561:	8b 45 08             	mov    0x8(%ebp),%eax
 564:	89 04 24             	mov    %eax,(%esp)
 567:	e8 bb fe ff ff       	call   427 <putc>
 56c:	e9 30 01 00 00       	jmp    6a1 <printf+0x19a>
      }
    } else if(state == '%'){
 571:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 575:	0f 85 26 01 00 00    	jne    6a1 <printf+0x19a>
      if(c == 'd'){
 57b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 57f:	75 2d                	jne    5ae <printf+0xa7>
        printint(fd, *ap, 10, 1);
 581:	8b 45 e8             	mov    -0x18(%ebp),%eax
 584:	8b 00                	mov    (%eax),%eax
 586:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 58d:	00 
 58e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 595:	00 
 596:	89 44 24 04          	mov    %eax,0x4(%esp)
 59a:	8b 45 08             	mov    0x8(%ebp),%eax
 59d:	89 04 24             	mov    %eax,(%esp)
 5a0:	e8 aa fe ff ff       	call   44f <printint>
        ap++;
 5a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a9:	e9 ec 00 00 00       	jmp    69a <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5b2:	74 06                	je     5ba <printf+0xb3>
 5b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b8:	75 2d                	jne    5e7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5bd:	8b 00                	mov    (%eax),%eax
 5bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5c6:	00 
 5c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5ce:	00 
 5cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
 5d6:	89 04 24             	mov    %eax,(%esp)
 5d9:	e8 71 fe ff ff       	call   44f <printint>
        ap++;
 5de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e2:	e9 b3 00 00 00       	jmp    69a <printf+0x193>
      } else if(c == 's'){
 5e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5eb:	75 45                	jne    632 <printf+0x12b>
        s = (char*)*ap;
 5ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f0:	8b 00                	mov    (%eax),%eax
 5f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fd:	75 09                	jne    608 <printf+0x101>
          s = "(null)";
 5ff:	c7 45 f4 23 09 00 00 	movl   $0x923,-0xc(%ebp)
        while(*s != 0){
 606:	eb 1e                	jmp    626 <printf+0x11f>
 608:	eb 1c                	jmp    626 <printf+0x11f>
          putc(fd, *s);
 60a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60d:	0f b6 00             	movzbl (%eax),%eax
 610:	0f be c0             	movsbl %al,%eax
 613:	89 44 24 04          	mov    %eax,0x4(%esp)
 617:	8b 45 08             	mov    0x8(%ebp),%eax
 61a:	89 04 24             	mov    %eax,(%esp)
 61d:	e8 05 fe ff ff       	call   427 <putc>
          s++;
 622:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 626:	8b 45 f4             	mov    -0xc(%ebp),%eax
 629:	0f b6 00             	movzbl (%eax),%eax
 62c:	84 c0                	test   %al,%al
 62e:	75 da                	jne    60a <printf+0x103>
 630:	eb 68                	jmp    69a <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 632:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 636:	75 1d                	jne    655 <printf+0x14e>
        putc(fd, *ap);
 638:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63b:	8b 00                	mov    (%eax),%eax
 63d:	0f be c0             	movsbl %al,%eax
 640:	89 44 24 04          	mov    %eax,0x4(%esp)
 644:	8b 45 08             	mov    0x8(%ebp),%eax
 647:	89 04 24             	mov    %eax,(%esp)
 64a:	e8 d8 fd ff ff       	call   427 <putc>
        ap++;
 64f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 653:	eb 45                	jmp    69a <printf+0x193>
      } else if(c == '%'){
 655:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 659:	75 17                	jne    672 <printf+0x16b>
        putc(fd, c);
 65b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65e:	0f be c0             	movsbl %al,%eax
 661:	89 44 24 04          	mov    %eax,0x4(%esp)
 665:	8b 45 08             	mov    0x8(%ebp),%eax
 668:	89 04 24             	mov    %eax,(%esp)
 66b:	e8 b7 fd ff ff       	call   427 <putc>
 670:	eb 28                	jmp    69a <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 672:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 679:	00 
 67a:	8b 45 08             	mov    0x8(%ebp),%eax
 67d:	89 04 24             	mov    %eax,(%esp)
 680:	e8 a2 fd ff ff       	call   427 <putc>
        putc(fd, c);
 685:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 688:	0f be c0             	movsbl %al,%eax
 68b:	89 44 24 04          	mov    %eax,0x4(%esp)
 68f:	8b 45 08             	mov    0x8(%ebp),%eax
 692:	89 04 24             	mov    %eax,(%esp)
 695:	e8 8d fd ff ff       	call   427 <putc>
      }
      state = 0;
 69a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6a1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6a5:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ab:	01 d0                	add    %edx,%eax
 6ad:	0f b6 00             	movzbl (%eax),%eax
 6b0:	84 c0                	test   %al,%al
 6b2:	0f 85 71 fe ff ff    	jne    529 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b8:	c9                   	leave  
 6b9:	c3                   	ret    

000006ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ba:	55                   	push   %ebp
 6bb:	89 e5                	mov    %esp,%ebp
 6bd:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c0:	8b 45 08             	mov    0x8(%ebp),%eax
 6c3:	83 e8 08             	sub    $0x8,%eax
 6c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c9:	a1 94 0b 00 00       	mov    0xb94,%eax
 6ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d1:	eb 24                	jmp    6f7 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d6:	8b 00                	mov    (%eax),%eax
 6d8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6db:	77 12                	ja     6ef <free+0x35>
 6dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e3:	77 24                	ja     709 <free+0x4f>
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ed:	77 1a                	ja     709 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f2:	8b 00                	mov    (%eax),%eax
 6f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6fd:	76 d4                	jbe    6d3 <free+0x19>
 6ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 702:	8b 00                	mov    (%eax),%eax
 704:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 707:	76 ca                	jbe    6d3 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 709:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70c:	8b 40 04             	mov    0x4(%eax),%eax
 70f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 716:	8b 45 f8             	mov    -0x8(%ebp),%eax
 719:	01 c2                	add    %eax,%edx
 71b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71e:	8b 00                	mov    (%eax),%eax
 720:	39 c2                	cmp    %eax,%edx
 722:	75 24                	jne    748 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 724:	8b 45 f8             	mov    -0x8(%ebp),%eax
 727:	8b 50 04             	mov    0x4(%eax),%edx
 72a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72d:	8b 00                	mov    (%eax),%eax
 72f:	8b 40 04             	mov    0x4(%eax),%eax
 732:	01 c2                	add    %eax,%edx
 734:	8b 45 f8             	mov    -0x8(%ebp),%eax
 737:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 73a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73d:	8b 00                	mov    (%eax),%eax
 73f:	8b 10                	mov    (%eax),%edx
 741:	8b 45 f8             	mov    -0x8(%ebp),%eax
 744:	89 10                	mov    %edx,(%eax)
 746:	eb 0a                	jmp    752 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	8b 10                	mov    (%eax),%edx
 74d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 750:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 752:	8b 45 fc             	mov    -0x4(%ebp),%eax
 755:	8b 40 04             	mov    0x4(%eax),%eax
 758:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 75f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 762:	01 d0                	add    %edx,%eax
 764:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 767:	75 20                	jne    789 <free+0xcf>
    p->s.size += bp->s.size;
 769:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76c:	8b 50 04             	mov    0x4(%eax),%edx
 76f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 772:	8b 40 04             	mov    0x4(%eax),%eax
 775:	01 c2                	add    %eax,%edx
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 77d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 780:	8b 10                	mov    (%eax),%edx
 782:	8b 45 fc             	mov    -0x4(%ebp),%eax
 785:	89 10                	mov    %edx,(%eax)
 787:	eb 08                	jmp    791 <free+0xd7>
  } else
    p->s.ptr = bp;
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 78f:	89 10                	mov    %edx,(%eax)
  freep = p;
 791:	8b 45 fc             	mov    -0x4(%ebp),%eax
 794:	a3 94 0b 00 00       	mov    %eax,0xb94
}
 799:	c9                   	leave  
 79a:	c3                   	ret    

0000079b <morecore>:

static Header*
morecore(uint nu)
{
 79b:	55                   	push   %ebp
 79c:	89 e5                	mov    %esp,%ebp
 79e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7a1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7a8:	77 07                	ja     7b1 <morecore+0x16>
    nu = 4096;
 7aa:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7b1:	8b 45 08             	mov    0x8(%ebp),%eax
 7b4:	c1 e0 03             	shl    $0x3,%eax
 7b7:	89 04 24             	mov    %eax,(%esp)
 7ba:	e8 40 fc ff ff       	call   3ff <sbrk>
 7bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7c2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c6:	75 07                	jne    7cf <morecore+0x34>
    return 0;
 7c8:	b8 00 00 00 00       	mov    $0x0,%eax
 7cd:	eb 22                	jmp    7f1 <morecore+0x56>
  hp = (Header*)p;
 7cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d8:	8b 55 08             	mov    0x8(%ebp),%edx
 7db:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e1:	83 c0 08             	add    $0x8,%eax
 7e4:	89 04 24             	mov    %eax,(%esp)
 7e7:	e8 ce fe ff ff       	call   6ba <free>
  return freep;
 7ec:	a1 94 0b 00 00       	mov    0xb94,%eax
}
 7f1:	c9                   	leave  
 7f2:	c3                   	ret    

000007f3 <malloc>:

void*
malloc(uint nbytes)
{
 7f3:	55                   	push   %ebp
 7f4:	89 e5                	mov    %esp,%ebp
 7f6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f9:	8b 45 08             	mov    0x8(%ebp),%eax
 7fc:	83 c0 07             	add    $0x7,%eax
 7ff:	c1 e8 03             	shr    $0x3,%eax
 802:	83 c0 01             	add    $0x1,%eax
 805:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 808:	a1 94 0b 00 00       	mov    0xb94,%eax
 80d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 810:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 814:	75 23                	jne    839 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 816:	c7 45 f0 8c 0b 00 00 	movl   $0xb8c,-0x10(%ebp)
 81d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 820:	a3 94 0b 00 00       	mov    %eax,0xb94
 825:	a1 94 0b 00 00       	mov    0xb94,%eax
 82a:	a3 8c 0b 00 00       	mov    %eax,0xb8c
    base.s.size = 0;
 82f:	c7 05 90 0b 00 00 00 	movl   $0x0,0xb90
 836:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 839:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83c:	8b 00                	mov    (%eax),%eax
 83e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 841:	8b 45 f4             	mov    -0xc(%ebp),%eax
 844:	8b 40 04             	mov    0x4(%eax),%eax
 847:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 84a:	72 4d                	jb     899 <malloc+0xa6>
      if(p->s.size == nunits)
 84c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84f:	8b 40 04             	mov    0x4(%eax),%eax
 852:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 855:	75 0c                	jne    863 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 857:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85a:	8b 10                	mov    (%eax),%edx
 85c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85f:	89 10                	mov    %edx,(%eax)
 861:	eb 26                	jmp    889 <malloc+0x96>
      else {
        p->s.size -= nunits;
 863:	8b 45 f4             	mov    -0xc(%ebp),%eax
 866:	8b 40 04             	mov    0x4(%eax),%eax
 869:	2b 45 ec             	sub    -0x14(%ebp),%eax
 86c:	89 c2                	mov    %eax,%edx
 86e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 871:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 874:	8b 45 f4             	mov    -0xc(%ebp),%eax
 877:	8b 40 04             	mov    0x4(%eax),%eax
 87a:	c1 e0 03             	shl    $0x3,%eax
 87d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 880:	8b 45 f4             	mov    -0xc(%ebp),%eax
 883:	8b 55 ec             	mov    -0x14(%ebp),%edx
 886:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 889:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88c:	a3 94 0b 00 00       	mov    %eax,0xb94
      return (void*)(p + 1);
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	83 c0 08             	add    $0x8,%eax
 897:	eb 38                	jmp    8d1 <malloc+0xde>
    }
    if(p == freep)
 899:	a1 94 0b 00 00       	mov    0xb94,%eax
 89e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a1:	75 1b                	jne    8be <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a6:	89 04 24             	mov    %eax,(%esp)
 8a9:	e8 ed fe ff ff       	call   79b <morecore>
 8ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b5:	75 07                	jne    8be <malloc+0xcb>
        return 0;
 8b7:	b8 00 00 00 00       	mov    $0x0,%eax
 8bc:	eb 13                	jmp    8d1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c7:	8b 00                	mov    (%eax),%eax
 8c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8cc:	e9 70 ff ff ff       	jmp    841 <malloc+0x4e>
}
 8d1:	c9                   	leave  
 8d2:	c3                   	ret    
