
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   6:	eb 1b                	jmp    23 <cat+0x23>
    write(1, buf, n);
   8:	8b 45 f4             	mov    -0xc(%ebp),%eax
   b:	89 44 24 08          	mov    %eax,0x8(%esp)
   f:	c7 44 24 04 c0 0b 00 	movl   $0xbc0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 82 03 00 00       	call   3a5 <write>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  23:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  2a:	00 
  2b:	c7 44 24 04 c0 0b 00 	movl   $0xbc0,0x4(%esp)
  32:	00 
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 5f 03 00 00       	call   39d <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 19                	jns    66 <cat+0x66>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 f1 08 00 	movl   $0x8f1,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 c4 04 00 00       	call   525 <printf>
    exit();
  61:	e8 1f 03 00 00       	call   385 <exit>
  }
}
  66:	c9                   	leave  
  67:	c3                   	ret    

00000068 <main>:

int
main(int argc, char *argv[])
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	83 e4 f0             	and    $0xfffffff0,%esp
  6e:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
  71:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  75:	7f 11                	jg     88 <main+0x20>
    cat(0);
  77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  7e:	e8 7d ff ff ff       	call   0 <cat>
    exit();
  83:	e8 fd 02 00 00       	call   385 <exit>
  }

  for(i = 1; i < argc; i++){
  88:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  8f:	00 
  90:	eb 79                	jmp    10b <main+0xa3>
    if((fd = open(argv[i], 0)) < 0){
  92:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  a0:	01 d0                	add    %edx,%eax
  a2:	8b 00                	mov    (%eax),%eax
  a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ab:	00 
  ac:	89 04 24             	mov    %eax,(%esp)
  af:	e8 11 03 00 00       	call   3c5 <open>
  b4:	89 44 24 18          	mov    %eax,0x18(%esp)
  b8:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  bd:	79 2f                	jns    ee <main+0x86>
      printf(1, "cat: cannot open %s\n", argv[i]);
  bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  cd:	01 d0                	add    %edx,%eax
  cf:	8b 00                	mov    (%eax),%eax
  d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  d5:	c7 44 24 04 02 09 00 	movl   $0x902,0x4(%esp)
  dc:	00 
  dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e4:	e8 3c 04 00 00       	call   525 <printf>
      exit();
  e9:	e8 97 02 00 00       	call   385 <exit>
    }
    cat(fd);
  ee:	8b 44 24 18          	mov    0x18(%esp),%eax
  f2:	89 04 24             	mov    %eax,(%esp)
  f5:	e8 06 ff ff ff       	call   0 <cat>
    close(fd);
  fa:	8b 44 24 18          	mov    0x18(%esp),%eax
  fe:	89 04 24             	mov    %eax,(%esp)
 101:	e8 a7 02 00 00       	call   3ad <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
 106:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 10b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 10f:	3b 45 08             	cmp    0x8(%ebp),%eax
 112:	0f 8c 7a ff ff ff    	jl     92 <main+0x2a>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
 118:	e8 68 02 00 00       	call   385 <exit>

0000011d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 11d:	55                   	push   %ebp
 11e:	89 e5                	mov    %esp,%ebp
 120:	57                   	push   %edi
 121:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 122:	8b 4d 08             	mov    0x8(%ebp),%ecx
 125:	8b 55 10             	mov    0x10(%ebp),%edx
 128:	8b 45 0c             	mov    0xc(%ebp),%eax
 12b:	89 cb                	mov    %ecx,%ebx
 12d:	89 df                	mov    %ebx,%edi
 12f:	89 d1                	mov    %edx,%ecx
 131:	fc                   	cld    
 132:	f3 aa                	rep stos %al,%es:(%edi)
 134:	89 ca                	mov    %ecx,%edx
 136:	89 fb                	mov    %edi,%ebx
 138:	89 5d 08             	mov    %ebx,0x8(%ebp)
 13b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 13e:	5b                   	pop    %ebx
 13f:	5f                   	pop    %edi
 140:	5d                   	pop    %ebp
 141:	c3                   	ret    

00000142 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
 145:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 14e:	90                   	nop
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	8d 50 01             	lea    0x1(%eax),%edx
 155:	89 55 08             	mov    %edx,0x8(%ebp)
 158:	8b 55 0c             	mov    0xc(%ebp),%edx
 15b:	8d 4a 01             	lea    0x1(%edx),%ecx
 15e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 161:	0f b6 12             	movzbl (%edx),%edx
 164:	88 10                	mov    %dl,(%eax)
 166:	0f b6 00             	movzbl (%eax),%eax
 169:	84 c0                	test   %al,%al
 16b:	75 e2                	jne    14f <strcpy+0xd>
    ;
  return os;
 16d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 170:	c9                   	leave  
 171:	c3                   	ret    

00000172 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 172:	55                   	push   %ebp
 173:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 175:	eb 08                	jmp    17f <strcmp+0xd>
    p++, q++;
 177:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	0f b6 00             	movzbl (%eax),%eax
 185:	84 c0                	test   %al,%al
 187:	74 10                	je     199 <strcmp+0x27>
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 10             	movzbl (%eax),%edx
 18f:	8b 45 0c             	mov    0xc(%ebp),%eax
 192:	0f b6 00             	movzbl (%eax),%eax
 195:	38 c2                	cmp    %al,%dl
 197:	74 de                	je     177 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 199:	8b 45 08             	mov    0x8(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	0f b6 d0             	movzbl %al,%edx
 1a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a5:	0f b6 00             	movzbl (%eax),%eax
 1a8:	0f b6 c0             	movzbl %al,%eax
 1ab:	29 c2                	sub    %eax,%edx
 1ad:	89 d0                	mov    %edx,%eax
}
 1af:	5d                   	pop    %ebp
 1b0:	c3                   	ret    

000001b1 <strlen>:

uint
strlen(char *s)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1be:	eb 04                	jmp    1c4 <strlen+0x13>
 1c0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1c7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ca:	01 d0                	add    %edx,%eax
 1cc:	0f b6 00             	movzbl (%eax),%eax
 1cf:	84 c0                	test   %al,%al
 1d1:	75 ed                	jne    1c0 <strlen+0xf>
    ;
  return n;
 1d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d6:	c9                   	leave  
 1d7:	c3                   	ret    

000001d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1de:	8b 45 10             	mov    0x10(%ebp),%eax
 1e1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	89 04 24             	mov    %eax,(%esp)
 1f2:	e8 26 ff ff ff       	call   11d <stosb>
  return dst;
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fa:	c9                   	leave  
 1fb:	c3                   	ret    

000001fc <strchr>:

char*
strchr(const char *s, char c)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
 1ff:	83 ec 04             	sub    $0x4,%esp
 202:	8b 45 0c             	mov    0xc(%ebp),%eax
 205:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 208:	eb 14                	jmp    21e <strchr+0x22>
    if(*s == c)
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	0f b6 00             	movzbl (%eax),%eax
 210:	3a 45 fc             	cmp    -0x4(%ebp),%al
 213:	75 05                	jne    21a <strchr+0x1e>
      return (char*)s;
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	eb 13                	jmp    22d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 21a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21e:	8b 45 08             	mov    0x8(%ebp),%eax
 221:	0f b6 00             	movzbl (%eax),%eax
 224:	84 c0                	test   %al,%al
 226:	75 e2                	jne    20a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 228:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22d:	c9                   	leave  
 22e:	c3                   	ret    

0000022f <gets>:

char*
gets(char *buf, int max)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 235:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 23c:	eb 4c                	jmp    28a <gets+0x5b>
    cc = read(0, &c, 1);
 23e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 245:	00 
 246:	8d 45 ef             	lea    -0x11(%ebp),%eax
 249:	89 44 24 04          	mov    %eax,0x4(%esp)
 24d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 254:	e8 44 01 00 00       	call   39d <read>
 259:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 25c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 260:	7f 02                	jg     264 <gets+0x35>
      break;
 262:	eb 31                	jmp    295 <gets+0x66>
    buf[i++] = c;
 264:	8b 45 f4             	mov    -0xc(%ebp),%eax
 267:	8d 50 01             	lea    0x1(%eax),%edx
 26a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 26d:	89 c2                	mov    %eax,%edx
 26f:	8b 45 08             	mov    0x8(%ebp),%eax
 272:	01 c2                	add    %eax,%edx
 274:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 278:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 27a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27e:	3c 0a                	cmp    $0xa,%al
 280:	74 13                	je     295 <gets+0x66>
 282:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 286:	3c 0d                	cmp    $0xd,%al
 288:	74 0b                	je     295 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28d:	83 c0 01             	add    $0x1,%eax
 290:	3b 45 0c             	cmp    0xc(%ebp),%eax
 293:	7c a9                	jl     23e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 295:	8b 55 f4             	mov    -0xc(%ebp),%edx
 298:	8b 45 08             	mov    0x8(%ebp),%eax
 29b:	01 d0                	add    %edx,%eax
 29d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    

000002a5 <stat>:

int
stat(char *n, struct stat *st)
{
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
 2a8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2b2:	00 
 2b3:	8b 45 08             	mov    0x8(%ebp),%eax
 2b6:	89 04 24             	mov    %eax,(%esp)
 2b9:	e8 07 01 00 00       	call   3c5 <open>
 2be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2c5:	79 07                	jns    2ce <stat+0x29>
    return -1;
 2c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2cc:	eb 23                	jmp    2f1 <stat+0x4c>
  r = fstat(fd, st);
 2ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 fd 00 00 00       	call   3dd <fstat>
 2e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e6:	89 04 24             	mov    %eax,(%esp)
 2e9:	e8 bf 00 00 00       	call   3ad <close>
  return r;
 2ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2f1:	c9                   	leave  
 2f2:	c3                   	ret    

000002f3 <atoi>:

int
atoi(const char *s)
{
 2f3:	55                   	push   %ebp
 2f4:	89 e5                	mov    %esp,%ebp
 2f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 300:	eb 25                	jmp    327 <atoi+0x34>
    n = n*10 + *s++ - '0';
 302:	8b 55 fc             	mov    -0x4(%ebp),%edx
 305:	89 d0                	mov    %edx,%eax
 307:	c1 e0 02             	shl    $0x2,%eax
 30a:	01 d0                	add    %edx,%eax
 30c:	01 c0                	add    %eax,%eax
 30e:	89 c1                	mov    %eax,%ecx
 310:	8b 45 08             	mov    0x8(%ebp),%eax
 313:	8d 50 01             	lea    0x1(%eax),%edx
 316:	89 55 08             	mov    %edx,0x8(%ebp)
 319:	0f b6 00             	movzbl (%eax),%eax
 31c:	0f be c0             	movsbl %al,%eax
 31f:	01 c8                	add    %ecx,%eax
 321:	83 e8 30             	sub    $0x30,%eax
 324:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	0f b6 00             	movzbl (%eax),%eax
 32d:	3c 2f                	cmp    $0x2f,%al
 32f:	7e 0a                	jle    33b <atoi+0x48>
 331:	8b 45 08             	mov    0x8(%ebp),%eax
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	3c 39                	cmp    $0x39,%al
 339:	7e c7                	jle    302 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 33b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33e:	c9                   	leave  
 33f:	c3                   	ret    

00000340 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 34c:	8b 45 0c             	mov    0xc(%ebp),%eax
 34f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 352:	eb 17                	jmp    36b <memmove+0x2b>
    *dst++ = *src++;
 354:	8b 45 fc             	mov    -0x4(%ebp),%eax
 357:	8d 50 01             	lea    0x1(%eax),%edx
 35a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 35d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 360:	8d 4a 01             	lea    0x1(%edx),%ecx
 363:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 366:	0f b6 12             	movzbl (%edx),%edx
 369:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 36b:	8b 45 10             	mov    0x10(%ebp),%eax
 36e:	8d 50 ff             	lea    -0x1(%eax),%edx
 371:	89 55 10             	mov    %edx,0x10(%ebp)
 374:	85 c0                	test   %eax,%eax
 376:	7f dc                	jg     354 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 378:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37b:	c9                   	leave  
 37c:	c3                   	ret    

0000037d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 37d:	b8 01 00 00 00       	mov    $0x1,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <exit>:
SYSCALL(exit)
 385:	b8 02 00 00 00       	mov    $0x2,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <wait>:
SYSCALL(wait)
 38d:	b8 03 00 00 00       	mov    $0x3,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <pipe>:
SYSCALL(pipe)
 395:	b8 04 00 00 00       	mov    $0x4,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <read>:
SYSCALL(read)
 39d:	b8 05 00 00 00       	mov    $0x5,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <write>:
SYSCALL(write)
 3a5:	b8 10 00 00 00       	mov    $0x10,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <close>:
SYSCALL(close)
 3ad:	b8 15 00 00 00       	mov    $0x15,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <kill>:
SYSCALL(kill)
 3b5:	b8 06 00 00 00       	mov    $0x6,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <exec>:
SYSCALL(exec)
 3bd:	b8 07 00 00 00       	mov    $0x7,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <open>:
SYSCALL(open)
 3c5:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <mknod>:
SYSCALL(mknod)
 3cd:	b8 11 00 00 00       	mov    $0x11,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <unlink>:
SYSCALL(unlink)
 3d5:	b8 12 00 00 00       	mov    $0x12,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <fstat>:
SYSCALL(fstat)
 3dd:	b8 08 00 00 00       	mov    $0x8,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <link>:
SYSCALL(link)
 3e5:	b8 13 00 00 00       	mov    $0x13,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <mkdir>:
SYSCALL(mkdir)
 3ed:	b8 14 00 00 00       	mov    $0x14,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <chdir>:
SYSCALL(chdir)
 3f5:	b8 09 00 00 00       	mov    $0x9,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <dup>:
SYSCALL(dup)
 3fd:	b8 0a 00 00 00       	mov    $0xa,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <getpid>:
SYSCALL(getpid)
 405:	b8 0b 00 00 00       	mov    $0xb,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <sbrk>:
SYSCALL(sbrk)
 40d:	b8 0c 00 00 00       	mov    $0xc,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <sleep>:
SYSCALL(sleep)
 415:	b8 0d 00 00 00       	mov    $0xd,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <uptime>:
SYSCALL(uptime)
 41d:	b8 0e 00 00 00       	mov    $0xe,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <sigset>:
SYSCALL(sigset)
 425:	b8 16 00 00 00       	mov    $0x16,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <sigsend>:
SYSCALL(sigsend)
 42d:	b8 17 00 00 00       	mov    $0x17,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <sigret>:
SYSCALL(sigret)
 435:	b8 18 00 00 00       	mov    $0x18,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <sigpause>:
 43d:	b8 19 00 00 00       	mov    $0x19,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 445:	55                   	push   %ebp
 446:	89 e5                	mov    %esp,%ebp
 448:	83 ec 18             	sub    $0x18,%esp
 44b:	8b 45 0c             	mov    0xc(%ebp),%eax
 44e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 451:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 458:	00 
 459:	8d 45 f4             	lea    -0xc(%ebp),%eax
 45c:	89 44 24 04          	mov    %eax,0x4(%esp)
 460:	8b 45 08             	mov    0x8(%ebp),%eax
 463:	89 04 24             	mov    %eax,(%esp)
 466:	e8 3a ff ff ff       	call   3a5 <write>
}
 46b:	c9                   	leave  
 46c:	c3                   	ret    

0000046d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46d:	55                   	push   %ebp
 46e:	89 e5                	mov    %esp,%ebp
 470:	56                   	push   %esi
 471:	53                   	push   %ebx
 472:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 475:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 47c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 480:	74 17                	je     499 <printint+0x2c>
 482:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 486:	79 11                	jns    499 <printint+0x2c>
    neg = 1;
 488:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 48f:	8b 45 0c             	mov    0xc(%ebp),%eax
 492:	f7 d8                	neg    %eax
 494:	89 45 ec             	mov    %eax,-0x14(%ebp)
 497:	eb 06                	jmp    49f <printint+0x32>
  } else {
    x = xx;
 499:	8b 45 0c             	mov    0xc(%ebp),%eax
 49c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 49f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4a6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4a9:	8d 41 01             	lea    0x1(%ecx),%eax
 4ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4af:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b5:	ba 00 00 00 00       	mov    $0x0,%edx
 4ba:	f7 f3                	div    %ebx
 4bc:	89 d0                	mov    %edx,%eax
 4be:	0f b6 80 84 0b 00 00 	movzbl 0xb84(%eax),%eax
 4c5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4c9:	8b 75 10             	mov    0x10(%ebp),%esi
 4cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4cf:	ba 00 00 00 00       	mov    $0x0,%edx
 4d4:	f7 f6                	div    %esi
 4d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4dd:	75 c7                	jne    4a6 <printint+0x39>
  if(neg)
 4df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4e3:	74 10                	je     4f5 <printint+0x88>
    buf[i++] = '-';
 4e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e8:	8d 50 01             	lea    0x1(%eax),%edx
 4eb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4ee:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4f3:	eb 1f                	jmp    514 <printint+0xa7>
 4f5:	eb 1d                	jmp    514 <printint+0xa7>
    putc(fd, buf[i]);
 4f7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fd:	01 d0                	add    %edx,%eax
 4ff:	0f b6 00             	movzbl (%eax),%eax
 502:	0f be c0             	movsbl %al,%eax
 505:	89 44 24 04          	mov    %eax,0x4(%esp)
 509:	8b 45 08             	mov    0x8(%ebp),%eax
 50c:	89 04 24             	mov    %eax,(%esp)
 50f:	e8 31 ff ff ff       	call   445 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 514:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 518:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51c:	79 d9                	jns    4f7 <printint+0x8a>
    putc(fd, buf[i]);
}
 51e:	83 c4 30             	add    $0x30,%esp
 521:	5b                   	pop    %ebx
 522:	5e                   	pop    %esi
 523:	5d                   	pop    %ebp
 524:	c3                   	ret    

00000525 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 525:	55                   	push   %ebp
 526:	89 e5                	mov    %esp,%ebp
 528:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 52b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 532:	8d 45 0c             	lea    0xc(%ebp),%eax
 535:	83 c0 04             	add    $0x4,%eax
 538:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 53b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 542:	e9 7c 01 00 00       	jmp    6c3 <printf+0x19e>
    c = fmt[i] & 0xff;
 547:	8b 55 0c             	mov    0xc(%ebp),%edx
 54a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 54d:	01 d0                	add    %edx,%eax
 54f:	0f b6 00             	movzbl (%eax),%eax
 552:	0f be c0             	movsbl %al,%eax
 555:	25 ff 00 00 00       	and    $0xff,%eax
 55a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 55d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 561:	75 2c                	jne    58f <printf+0x6a>
      if(c == '%'){
 563:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 567:	75 0c                	jne    575 <printf+0x50>
        state = '%';
 569:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 570:	e9 4a 01 00 00       	jmp    6bf <printf+0x19a>
      } else {
        putc(fd, c);
 575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 578:	0f be c0             	movsbl %al,%eax
 57b:	89 44 24 04          	mov    %eax,0x4(%esp)
 57f:	8b 45 08             	mov    0x8(%ebp),%eax
 582:	89 04 24             	mov    %eax,(%esp)
 585:	e8 bb fe ff ff       	call   445 <putc>
 58a:	e9 30 01 00 00       	jmp    6bf <printf+0x19a>
      }
    } else if(state == '%'){
 58f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 593:	0f 85 26 01 00 00    	jne    6bf <printf+0x19a>
      if(c == 'd'){
 599:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 59d:	75 2d                	jne    5cc <printf+0xa7>
        printint(fd, *ap, 10, 1);
 59f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a2:	8b 00                	mov    (%eax),%eax
 5a4:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5ab:	00 
 5ac:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5b3:	00 
 5b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
 5bb:	89 04 24             	mov    %eax,(%esp)
 5be:	e8 aa fe ff ff       	call   46d <printint>
        ap++;
 5c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c7:	e9 ec 00 00 00       	jmp    6b8 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5cc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5d0:	74 06                	je     5d8 <printf+0xb3>
 5d2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5d6:	75 2d                	jne    605 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5db:	8b 00                	mov    (%eax),%eax
 5dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5e4:	00 
 5e5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5ec:	00 
 5ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f1:	8b 45 08             	mov    0x8(%ebp),%eax
 5f4:	89 04 24             	mov    %eax,(%esp)
 5f7:	e8 71 fe ff ff       	call   46d <printint>
        ap++;
 5fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 600:	e9 b3 00 00 00       	jmp    6b8 <printf+0x193>
      } else if(c == 's'){
 605:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 609:	75 45                	jne    650 <printf+0x12b>
        s = (char*)*ap;
 60b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 60e:	8b 00                	mov    (%eax),%eax
 610:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 613:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 617:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 61b:	75 09                	jne    626 <printf+0x101>
          s = "(null)";
 61d:	c7 45 f4 17 09 00 00 	movl   $0x917,-0xc(%ebp)
        while(*s != 0){
 624:	eb 1e                	jmp    644 <printf+0x11f>
 626:	eb 1c                	jmp    644 <printf+0x11f>
          putc(fd, *s);
 628:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62b:	0f b6 00             	movzbl (%eax),%eax
 62e:	0f be c0             	movsbl %al,%eax
 631:	89 44 24 04          	mov    %eax,0x4(%esp)
 635:	8b 45 08             	mov    0x8(%ebp),%eax
 638:	89 04 24             	mov    %eax,(%esp)
 63b:	e8 05 fe ff ff       	call   445 <putc>
          s++;
 640:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 644:	8b 45 f4             	mov    -0xc(%ebp),%eax
 647:	0f b6 00             	movzbl (%eax),%eax
 64a:	84 c0                	test   %al,%al
 64c:	75 da                	jne    628 <printf+0x103>
 64e:	eb 68                	jmp    6b8 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 650:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 654:	75 1d                	jne    673 <printf+0x14e>
        putc(fd, *ap);
 656:	8b 45 e8             	mov    -0x18(%ebp),%eax
 659:	8b 00                	mov    (%eax),%eax
 65b:	0f be c0             	movsbl %al,%eax
 65e:	89 44 24 04          	mov    %eax,0x4(%esp)
 662:	8b 45 08             	mov    0x8(%ebp),%eax
 665:	89 04 24             	mov    %eax,(%esp)
 668:	e8 d8 fd ff ff       	call   445 <putc>
        ap++;
 66d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 671:	eb 45                	jmp    6b8 <printf+0x193>
      } else if(c == '%'){
 673:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 677:	75 17                	jne    690 <printf+0x16b>
        putc(fd, c);
 679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67c:	0f be c0             	movsbl %al,%eax
 67f:	89 44 24 04          	mov    %eax,0x4(%esp)
 683:	8b 45 08             	mov    0x8(%ebp),%eax
 686:	89 04 24             	mov    %eax,(%esp)
 689:	e8 b7 fd ff ff       	call   445 <putc>
 68e:	eb 28                	jmp    6b8 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 690:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 697:	00 
 698:	8b 45 08             	mov    0x8(%ebp),%eax
 69b:	89 04 24             	mov    %eax,(%esp)
 69e:	e8 a2 fd ff ff       	call   445 <putc>
        putc(fd, c);
 6a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a6:	0f be c0             	movsbl %al,%eax
 6a9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ad:	8b 45 08             	mov    0x8(%ebp),%eax
 6b0:	89 04 24             	mov    %eax,(%esp)
 6b3:	e8 8d fd ff ff       	call   445 <putc>
      }
      state = 0;
 6b8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6bf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6c3:	8b 55 0c             	mov    0xc(%ebp),%edx
 6c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c9:	01 d0                	add    %edx,%eax
 6cb:	0f b6 00             	movzbl (%eax),%eax
 6ce:	84 c0                	test   %al,%al
 6d0:	0f 85 71 fe ff ff    	jne    547 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6d6:	c9                   	leave  
 6d7:	c3                   	ret    

000006d8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d8:	55                   	push   %ebp
 6d9:	89 e5                	mov    %esp,%ebp
 6db:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6de:	8b 45 08             	mov    0x8(%ebp),%eax
 6e1:	83 e8 08             	sub    $0x8,%eax
 6e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e7:	a1 a8 0b 00 00       	mov    0xba8,%eax
 6ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ef:	eb 24                	jmp    715 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f9:	77 12                	ja     70d <free+0x35>
 6fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 701:	77 24                	ja     727 <free+0x4f>
 703:	8b 45 fc             	mov    -0x4(%ebp),%eax
 706:	8b 00                	mov    (%eax),%eax
 708:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 70b:	77 1a                	ja     727 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	8b 00                	mov    (%eax),%eax
 712:	89 45 fc             	mov    %eax,-0x4(%ebp)
 715:	8b 45 f8             	mov    -0x8(%ebp),%eax
 718:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 71b:	76 d4                	jbe    6f1 <free+0x19>
 71d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 720:	8b 00                	mov    (%eax),%eax
 722:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 725:	76 ca                	jbe    6f1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 727:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72a:	8b 40 04             	mov    0x4(%eax),%eax
 72d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 734:	8b 45 f8             	mov    -0x8(%ebp),%eax
 737:	01 c2                	add    %eax,%edx
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	39 c2                	cmp    %eax,%edx
 740:	75 24                	jne    766 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 742:	8b 45 f8             	mov    -0x8(%ebp),%eax
 745:	8b 50 04             	mov    0x4(%eax),%edx
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	8b 00                	mov    (%eax),%eax
 74d:	8b 40 04             	mov    0x4(%eax),%eax
 750:	01 c2                	add    %eax,%edx
 752:	8b 45 f8             	mov    -0x8(%ebp),%eax
 755:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 758:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75b:	8b 00                	mov    (%eax),%eax
 75d:	8b 10                	mov    (%eax),%edx
 75f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 762:	89 10                	mov    %edx,(%eax)
 764:	eb 0a                	jmp    770 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 766:	8b 45 fc             	mov    -0x4(%ebp),%eax
 769:	8b 10                	mov    (%eax),%edx
 76b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 770:	8b 45 fc             	mov    -0x4(%ebp),%eax
 773:	8b 40 04             	mov    0x4(%eax),%eax
 776:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 77d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 780:	01 d0                	add    %edx,%eax
 782:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 785:	75 20                	jne    7a7 <free+0xcf>
    p->s.size += bp->s.size;
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	8b 50 04             	mov    0x4(%eax),%edx
 78d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 790:	8b 40 04             	mov    0x4(%eax),%eax
 793:	01 c2                	add    %eax,%edx
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 79b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79e:	8b 10                	mov    (%eax),%edx
 7a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a3:	89 10                	mov    %edx,(%eax)
 7a5:	eb 08                	jmp    7af <free+0xd7>
  } else
    p->s.ptr = bp;
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7ad:	89 10                	mov    %edx,(%eax)
  freep = p;
 7af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b2:	a3 a8 0b 00 00       	mov    %eax,0xba8
}
 7b7:	c9                   	leave  
 7b8:	c3                   	ret    

000007b9 <morecore>:

static Header*
morecore(uint nu)
{
 7b9:	55                   	push   %ebp
 7ba:	89 e5                	mov    %esp,%ebp
 7bc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7bf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7c6:	77 07                	ja     7cf <morecore+0x16>
    nu = 4096;
 7c8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7cf:	8b 45 08             	mov    0x8(%ebp),%eax
 7d2:	c1 e0 03             	shl    $0x3,%eax
 7d5:	89 04 24             	mov    %eax,(%esp)
 7d8:	e8 30 fc ff ff       	call   40d <sbrk>
 7dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7e0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7e4:	75 07                	jne    7ed <morecore+0x34>
    return 0;
 7e6:	b8 00 00 00 00       	mov    $0x0,%eax
 7eb:	eb 22                	jmp    80f <morecore+0x56>
  hp = (Header*)p;
 7ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f6:	8b 55 08             	mov    0x8(%ebp),%edx
 7f9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ff:	83 c0 08             	add    $0x8,%eax
 802:	89 04 24             	mov    %eax,(%esp)
 805:	e8 ce fe ff ff       	call   6d8 <free>
  return freep;
 80a:	a1 a8 0b 00 00       	mov    0xba8,%eax
}
 80f:	c9                   	leave  
 810:	c3                   	ret    

00000811 <malloc>:

void*
malloc(uint nbytes)
{
 811:	55                   	push   %ebp
 812:	89 e5                	mov    %esp,%ebp
 814:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 817:	8b 45 08             	mov    0x8(%ebp),%eax
 81a:	83 c0 07             	add    $0x7,%eax
 81d:	c1 e8 03             	shr    $0x3,%eax
 820:	83 c0 01             	add    $0x1,%eax
 823:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 826:	a1 a8 0b 00 00       	mov    0xba8,%eax
 82b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 82e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 832:	75 23                	jne    857 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 834:	c7 45 f0 a0 0b 00 00 	movl   $0xba0,-0x10(%ebp)
 83b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83e:	a3 a8 0b 00 00       	mov    %eax,0xba8
 843:	a1 a8 0b 00 00       	mov    0xba8,%eax
 848:	a3 a0 0b 00 00       	mov    %eax,0xba0
    base.s.size = 0;
 84d:	c7 05 a4 0b 00 00 00 	movl   $0x0,0xba4
 854:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 857:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85a:	8b 00                	mov    (%eax),%eax
 85c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	8b 40 04             	mov    0x4(%eax),%eax
 865:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 868:	72 4d                	jb     8b7 <malloc+0xa6>
      if(p->s.size == nunits)
 86a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86d:	8b 40 04             	mov    0x4(%eax),%eax
 870:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 873:	75 0c                	jne    881 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 875:	8b 45 f4             	mov    -0xc(%ebp),%eax
 878:	8b 10                	mov    (%eax),%edx
 87a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87d:	89 10                	mov    %edx,(%eax)
 87f:	eb 26                	jmp    8a7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 881:	8b 45 f4             	mov    -0xc(%ebp),%eax
 884:	8b 40 04             	mov    0x4(%eax),%eax
 887:	2b 45 ec             	sub    -0x14(%ebp),%eax
 88a:	89 c2                	mov    %eax,%edx
 88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 892:	8b 45 f4             	mov    -0xc(%ebp),%eax
 895:	8b 40 04             	mov    0x4(%eax),%eax
 898:	c1 e0 03             	shl    $0x3,%eax
 89b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 89e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8a4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8aa:	a3 a8 0b 00 00       	mov    %eax,0xba8
      return (void*)(p + 1);
 8af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b2:	83 c0 08             	add    $0x8,%eax
 8b5:	eb 38                	jmp    8ef <malloc+0xde>
    }
    if(p == freep)
 8b7:	a1 a8 0b 00 00       	mov    0xba8,%eax
 8bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8bf:	75 1b                	jne    8dc <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c4:	89 04 24             	mov    %eax,(%esp)
 8c7:	e8 ed fe ff ff       	call   7b9 <morecore>
 8cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d3:	75 07                	jne    8dc <malloc+0xcb>
        return 0;
 8d5:	b8 00 00 00 00       	mov    $0x0,%eax
 8da:	eb 13                	jmp    8ef <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8df:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e5:	8b 00                	mov    (%eax),%eax
 8e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8ea:	e9 70 ff ff ff       	jmp    85f <malloc+0x4e>
}
 8ef:	c9                   	leave  
 8f0:	c3                   	ret    
