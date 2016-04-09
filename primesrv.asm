
_primesrv:     file format elf32-i386


Disassembly of section .text:

00000000 <calculate_prime>:

#define MAX_INPUT 10

int
calculate_prime(int number)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
  return 0;
   3:	b8 00 00 00 00       	mov    $0x0,%eax
}
   8:	5d                   	pop    %ebp
   9:	c3                   	ret    

0000000a <main>:

int
main(int argc, char *argv[])
{
   a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   e:	83 e4 f0             	and    $0xfffffff0,%esp
  11:	ff 71 fc             	pushl  -0x4(%ecx)
  14:	55                   	push   %ebp
  15:	89 e5                	mov    %esp,%ebp
  17:	53                   	push   %ebx
  18:	51                   	push   %ecx
  19:	83 ec 40             	sub    $0x40,%esp
  1c:	89 c8                	mov    %ecx,%eax
  int n, i, pid, prime;
  char buff[MAX_INPUT];

  // test arguments
  if (argc != 2){
  1e:	83 38 02             	cmpl   $0x2,(%eax)
  21:	74 19                	je     3c <main+0x32>
  	printf(1, "Unvaild parameter for primsrv test\n");
  23:	c7 44 24 04 78 09 00 	movl   $0x978,0x4(%esp)
  2a:	00 
  2b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  32:	e8 74 05 00 00       	call   5ab <printf>
  	exit();
  37:	e8 d7 03 00 00       	call   413 <exit>
  }

  n = atoi(argv[1]);
  3c:	8b 40 04             	mov    0x4(%eax),%eax
  3f:	83 c0 04             	add    $0x4,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 35 03 00 00       	call   381 <atoi>
  4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int workers[n];
  4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  52:	8d 50 ff             	lea    -0x1(%eax),%edx
  55:	89 55 ec             	mov    %edx,-0x14(%ebp)
  58:	c1 e0 02             	shl    $0x2,%eax
  5b:	8d 50 03             	lea    0x3(%eax),%edx
  5e:	b8 10 00 00 00       	mov    $0x10,%eax
  63:	83 e8 01             	sub    $0x1,%eax
  66:	01 d0                	add    %edx,%eax
  68:	bb 10 00 00 00       	mov    $0x10,%ebx
  6d:	ba 00 00 00 00       	mov    $0x0,%edx
  72:	f7 f3                	div    %ebx
  74:	6b c0 10             	imul   $0x10,%eax,%eax
  77:	29 c4                	sub    %eax,%esp
  79:	8d 44 24 10          	lea    0x10(%esp),%eax
  7d:	83 c0 03             	add    $0x3,%eax
  80:	c1 e8 02             	shr    $0x2,%eax
  83:	c1 e0 02             	shl    $0x2,%eax
  86:	89 45 e8             	mov    %eax,-0x18(%ebp)

  for(i = 0; i < n; i++){
  89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  90:	eb 71                	jmp    103 <main+0xf9>
  	if ((pid = fork()) == 0) { // son
  92:	e8 74 03 00 00       	call   40b <fork>
  97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  9a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  9e:	75 34                	jne    d4 <main+0xca>
      pid = getpid();
  a0:	e8 ee 03 00 00       	call   493 <getpid>
  a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 	    printf(1, "Process number = %d,  PID = %d\n", i+1, pid);	
  a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ab:	8d 50 01             	lea    0x1(%eax),%edx
  ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  b9:	c7 44 24 04 9c 09 00 	movl   $0x99c,0x4(%esp)
  c0:	00 
  c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c8:	e8 de 04 00 00       	call   5ab <printf>
 	    sigpause();
  cd:	e8 f1 03 00 00       	call   4c3 <sigpause>
  d2:	eb 2b                	jmp    ff <main+0xf5>
    }
    else if (pid < 0) {        // fork failed
  d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d8:	79 19                	jns    f3 <main+0xe9>
      printf(1, "fork() failed!\n"); 
  da:	c7 44 24 04 bc 09 00 	movl   $0x9bc,0x4(%esp)
  e1:	00 
  e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e9:	e8 bd 04 00 00       	call   5ab <printf>
      exit();
  ee:	e8 20 03 00 00       	call   413 <exit>
    }
    else {
      workers[i] = pid;
  f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  fc:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
  }

  n = atoi(argv[1]);
  int workers[n];

  for(i = 0; i < n; i++){
  ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 103:	8b 45 f4             	mov    -0xc(%ebp),%eax
 106:	3b 45 f0             	cmp    -0x10(%ebp),%eax
 109:	7c 87                	jl     92 <main+0x88>
    }
  }

  for(;;)
  {
  	printf(1, "Please enter a number: \n");
 10b:	c7 44 24 04 cc 09 00 	movl   $0x9cc,0x4(%esp)
 112:	00 
 113:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 11a:	e8 8c 04 00 00       	call   5ab <printf>
  	gets(buff, MAX_INPUT);
 11f:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
 126:	00 
 127:	8d 45 d6             	lea    -0x2a(%ebp),%eax
 12a:	89 04 24             	mov    %eax,(%esp)
 12d:	e8 8b 01 00 00       	call   2bd <gets>
  	prime = atoi(buff);
 132:	8d 45 d6             	lea    -0x2a(%ebp),%eax
 135:	89 04 24             	mov    %eax,(%esp)
 138:	e8 44 02 00 00       	call   381 <atoi>
 13d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  	if(prime == 0)
 140:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 144:	75 60                	jne    1a6 <main+0x19c>
  	{
  	  for (i = 0; i < n; i++)
 146:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 14d:	eb 36                	jmp    185 <main+0x17b>
  	  {
  	    printf(1, "worker %d exit\n", workers[i]);
 14f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 152:	8b 55 f4             	mov    -0xc(%ebp),%edx
 155:	8b 04 90             	mov    (%eax,%edx,4),%eax
 158:	89 44 24 08          	mov    %eax,0x8(%esp)
 15c:	c7 44 24 04 e5 09 00 	movl   $0x9e5,0x4(%esp)
 163:	00 
 164:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 16b:	e8 3b 04 00 00       	call   5ab <printf>
        kill(workers[i]);
 170:	8b 45 e8             	mov    -0x18(%ebp),%eax
 173:	8b 55 f4             	mov    -0xc(%ebp),%edx
 176:	8b 04 90             	mov    (%eax,%edx,4),%eax
 179:	89 04 24             	mov    %eax,(%esp)
 17c:	e8 c2 02 00 00       	call   443 <kill>
  	printf(1, "Please enter a number: \n");
  	gets(buff, MAX_INPUT);
  	prime = atoi(buff);
  	if(prime == 0)
  	{
  	  for (i = 0; i < n; i++)
 181:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 185:	8b 45 f4             	mov    -0xc(%ebp),%eax
 188:	3b 45 f0             	cmp    -0x10(%ebp),%eax
 18b:	7c c2                	jl     14f <main+0x145>
  	  {
  	    printf(1, "worker %d exit\n", workers[i]);
        kill(workers[i]);
  	  }
  	  printf(1, "primesrv exit\n");
 18d:	c7 44 24 04 f5 09 00 	movl   $0x9f5,0x4(%esp)
 194:	00 
 195:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19c:	e8 0a 04 00 00       	call   5ab <printf>
  	  exit();
 1a1:	e8 6d 02 00 00       	call   413 <exit>
  	}
  }
 1a6:	e9 60 ff ff ff       	jmp    10b <main+0x101>

000001ab <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1ab:	55                   	push   %ebp
 1ac:	89 e5                	mov    %esp,%ebp
 1ae:	57                   	push   %edi
 1af:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1b3:	8b 55 10             	mov    0x10(%ebp),%edx
 1b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b9:	89 cb                	mov    %ecx,%ebx
 1bb:	89 df                	mov    %ebx,%edi
 1bd:	89 d1                	mov    %edx,%ecx
 1bf:	fc                   	cld    
 1c0:	f3 aa                	rep stos %al,%es:(%edi)
 1c2:	89 ca                	mov    %ecx,%edx
 1c4:	89 fb                	mov    %edi,%ebx
 1c6:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1c9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1cc:	5b                   	pop    %ebx
 1cd:	5f                   	pop    %edi
 1ce:	5d                   	pop    %ebp
 1cf:	c3                   	ret    

000001d0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1d6:	8b 45 08             	mov    0x8(%ebp),%eax
 1d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1dc:	90                   	nop
 1dd:	8b 45 08             	mov    0x8(%ebp),%eax
 1e0:	8d 50 01             	lea    0x1(%eax),%edx
 1e3:	89 55 08             	mov    %edx,0x8(%ebp)
 1e6:	8b 55 0c             	mov    0xc(%ebp),%edx
 1e9:	8d 4a 01             	lea    0x1(%edx),%ecx
 1ec:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1ef:	0f b6 12             	movzbl (%edx),%edx
 1f2:	88 10                	mov    %dl,(%eax)
 1f4:	0f b6 00             	movzbl (%eax),%eax
 1f7:	84 c0                	test   %al,%al
 1f9:	75 e2                	jne    1dd <strcpy+0xd>
    ;
  return os;
 1fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1fe:	c9                   	leave  
 1ff:	c3                   	ret    

00000200 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 203:	eb 08                	jmp    20d <strcmp+0xd>
    p++, q++;
 205:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 209:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 20d:	8b 45 08             	mov    0x8(%ebp),%eax
 210:	0f b6 00             	movzbl (%eax),%eax
 213:	84 c0                	test   %al,%al
 215:	74 10                	je     227 <strcmp+0x27>
 217:	8b 45 08             	mov    0x8(%ebp),%eax
 21a:	0f b6 10             	movzbl (%eax),%edx
 21d:	8b 45 0c             	mov    0xc(%ebp),%eax
 220:	0f b6 00             	movzbl (%eax),%eax
 223:	38 c2                	cmp    %al,%dl
 225:	74 de                	je     205 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 227:	8b 45 08             	mov    0x8(%ebp),%eax
 22a:	0f b6 00             	movzbl (%eax),%eax
 22d:	0f b6 d0             	movzbl %al,%edx
 230:	8b 45 0c             	mov    0xc(%ebp),%eax
 233:	0f b6 00             	movzbl (%eax),%eax
 236:	0f b6 c0             	movzbl %al,%eax
 239:	29 c2                	sub    %eax,%edx
 23b:	89 d0                	mov    %edx,%eax
}
 23d:	5d                   	pop    %ebp
 23e:	c3                   	ret    

0000023f <strlen>:

uint
strlen(char *s)
{
 23f:	55                   	push   %ebp
 240:	89 e5                	mov    %esp,%ebp
 242:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 245:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 24c:	eb 04                	jmp    252 <strlen+0x13>
 24e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 252:	8b 55 fc             	mov    -0x4(%ebp),%edx
 255:	8b 45 08             	mov    0x8(%ebp),%eax
 258:	01 d0                	add    %edx,%eax
 25a:	0f b6 00             	movzbl (%eax),%eax
 25d:	84 c0                	test   %al,%al
 25f:	75 ed                	jne    24e <strlen+0xf>
    ;
  return n;
 261:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 264:	c9                   	leave  
 265:	c3                   	ret    

00000266 <memset>:

void*
memset(void *dst, int c, uint n)
{
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 26c:	8b 45 10             	mov    0x10(%ebp),%eax
 26f:	89 44 24 08          	mov    %eax,0x8(%esp)
 273:	8b 45 0c             	mov    0xc(%ebp),%eax
 276:	89 44 24 04          	mov    %eax,0x4(%esp)
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	89 04 24             	mov    %eax,(%esp)
 280:	e8 26 ff ff ff       	call   1ab <stosb>
  return dst;
 285:	8b 45 08             	mov    0x8(%ebp),%eax
}
 288:	c9                   	leave  
 289:	c3                   	ret    

0000028a <strchr>:

char*
strchr(const char *s, char c)
{
 28a:	55                   	push   %ebp
 28b:	89 e5                	mov    %esp,%ebp
 28d:	83 ec 04             	sub    $0x4,%esp
 290:	8b 45 0c             	mov    0xc(%ebp),%eax
 293:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 296:	eb 14                	jmp    2ac <strchr+0x22>
    if(*s == c)
 298:	8b 45 08             	mov    0x8(%ebp),%eax
 29b:	0f b6 00             	movzbl (%eax),%eax
 29e:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2a1:	75 05                	jne    2a8 <strchr+0x1e>
      return (char*)s;
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	eb 13                	jmp    2bb <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2a8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
 2af:	0f b6 00             	movzbl (%eax),%eax
 2b2:	84 c0                	test   %al,%al
 2b4:	75 e2                	jne    298 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2bb:	c9                   	leave  
 2bc:	c3                   	ret    

000002bd <gets>:

char*
gets(char *buf, int max)
{
 2bd:	55                   	push   %ebp
 2be:	89 e5                	mov    %esp,%ebp
 2c0:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2ca:	eb 4c                	jmp    318 <gets+0x5b>
    cc = read(0, &c, 1);
 2cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2d3:	00 
 2d4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2d7:	89 44 24 04          	mov    %eax,0x4(%esp)
 2db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2e2:	e8 44 01 00 00       	call   42b <read>
 2e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2ee:	7f 02                	jg     2f2 <gets+0x35>
      break;
 2f0:	eb 31                	jmp    323 <gets+0x66>
    buf[i++] = c;
 2f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f5:	8d 50 01             	lea    0x1(%eax),%edx
 2f8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2fb:	89 c2                	mov    %eax,%edx
 2fd:	8b 45 08             	mov    0x8(%ebp),%eax
 300:	01 c2                	add    %eax,%edx
 302:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 306:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 308:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 30c:	3c 0a                	cmp    $0xa,%al
 30e:	74 13                	je     323 <gets+0x66>
 310:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 314:	3c 0d                	cmp    $0xd,%al
 316:	74 0b                	je     323 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 318:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31b:	83 c0 01             	add    $0x1,%eax
 31e:	3b 45 0c             	cmp    0xc(%ebp),%eax
 321:	7c a9                	jl     2cc <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 323:	8b 55 f4             	mov    -0xc(%ebp),%edx
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	01 d0                	add    %edx,%eax
 32b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 331:	c9                   	leave  
 332:	c3                   	ret    

00000333 <stat>:

int
stat(char *n, struct stat *st)
{
 333:	55                   	push   %ebp
 334:	89 e5                	mov    %esp,%ebp
 336:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 339:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 340:	00 
 341:	8b 45 08             	mov    0x8(%ebp),%eax
 344:	89 04 24             	mov    %eax,(%esp)
 347:	e8 07 01 00 00       	call   453 <open>
 34c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 34f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 353:	79 07                	jns    35c <stat+0x29>
    return -1;
 355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 35a:	eb 23                	jmp    37f <stat+0x4c>
  r = fstat(fd, st);
 35c:	8b 45 0c             	mov    0xc(%ebp),%eax
 35f:	89 44 24 04          	mov    %eax,0x4(%esp)
 363:	8b 45 f4             	mov    -0xc(%ebp),%eax
 366:	89 04 24             	mov    %eax,(%esp)
 369:	e8 fd 00 00 00       	call   46b <fstat>
 36e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 371:	8b 45 f4             	mov    -0xc(%ebp),%eax
 374:	89 04 24             	mov    %eax,(%esp)
 377:	e8 bf 00 00 00       	call   43b <close>
  return r;
 37c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 37f:	c9                   	leave  
 380:	c3                   	ret    

00000381 <atoi>:

int
atoi(const char *s)
{
 381:	55                   	push   %ebp
 382:	89 e5                	mov    %esp,%ebp
 384:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 387:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 38e:	eb 25                	jmp    3b5 <atoi+0x34>
    n = n*10 + *s++ - '0';
 390:	8b 55 fc             	mov    -0x4(%ebp),%edx
 393:	89 d0                	mov    %edx,%eax
 395:	c1 e0 02             	shl    $0x2,%eax
 398:	01 d0                	add    %edx,%eax
 39a:	01 c0                	add    %eax,%eax
 39c:	89 c1                	mov    %eax,%ecx
 39e:	8b 45 08             	mov    0x8(%ebp),%eax
 3a1:	8d 50 01             	lea    0x1(%eax),%edx
 3a4:	89 55 08             	mov    %edx,0x8(%ebp)
 3a7:	0f b6 00             	movzbl (%eax),%eax
 3aa:	0f be c0             	movsbl %al,%eax
 3ad:	01 c8                	add    %ecx,%eax
 3af:	83 e8 30             	sub    $0x30,%eax
 3b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	0f b6 00             	movzbl (%eax),%eax
 3bb:	3c 2f                	cmp    $0x2f,%al
 3bd:	7e 0a                	jle    3c9 <atoi+0x48>
 3bf:	8b 45 08             	mov    0x8(%ebp),%eax
 3c2:	0f b6 00             	movzbl (%eax),%eax
 3c5:	3c 39                	cmp    $0x39,%al
 3c7:	7e c7                	jle    390 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3cc:	c9                   	leave  
 3cd:	c3                   	ret    

000003ce <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3ce:	55                   	push   %ebp
 3cf:	89 e5                	mov    %esp,%ebp
 3d1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3d4:	8b 45 08             	mov    0x8(%ebp),%eax
 3d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3da:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3e0:	eb 17                	jmp    3f9 <memmove+0x2b>
    *dst++ = *src++;
 3e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3e5:	8d 50 01             	lea    0x1(%eax),%edx
 3e8:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3eb:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3ee:	8d 4a 01             	lea    0x1(%edx),%ecx
 3f1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3f4:	0f b6 12             	movzbl (%edx),%edx
 3f7:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3f9:	8b 45 10             	mov    0x10(%ebp),%eax
 3fc:	8d 50 ff             	lea    -0x1(%eax),%edx
 3ff:	89 55 10             	mov    %edx,0x10(%ebp)
 402:	85 c0                	test   %eax,%eax
 404:	7f dc                	jg     3e2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 406:	8b 45 08             	mov    0x8(%ebp),%eax
}
 409:	c9                   	leave  
 40a:	c3                   	ret    

0000040b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 40b:	b8 01 00 00 00       	mov    $0x1,%eax
 410:	cd 40                	int    $0x40
 412:	c3                   	ret    

00000413 <exit>:
SYSCALL(exit)
 413:	b8 02 00 00 00       	mov    $0x2,%eax
 418:	cd 40                	int    $0x40
 41a:	c3                   	ret    

0000041b <wait>:
SYSCALL(wait)
 41b:	b8 03 00 00 00       	mov    $0x3,%eax
 420:	cd 40                	int    $0x40
 422:	c3                   	ret    

00000423 <pipe>:
SYSCALL(pipe)
 423:	b8 04 00 00 00       	mov    $0x4,%eax
 428:	cd 40                	int    $0x40
 42a:	c3                   	ret    

0000042b <read>:
SYSCALL(read)
 42b:	b8 05 00 00 00       	mov    $0x5,%eax
 430:	cd 40                	int    $0x40
 432:	c3                   	ret    

00000433 <write>:
SYSCALL(write)
 433:	b8 10 00 00 00       	mov    $0x10,%eax
 438:	cd 40                	int    $0x40
 43a:	c3                   	ret    

0000043b <close>:
SYSCALL(close)
 43b:	b8 15 00 00 00       	mov    $0x15,%eax
 440:	cd 40                	int    $0x40
 442:	c3                   	ret    

00000443 <kill>:
SYSCALL(kill)
 443:	b8 06 00 00 00       	mov    $0x6,%eax
 448:	cd 40                	int    $0x40
 44a:	c3                   	ret    

0000044b <exec>:
SYSCALL(exec)
 44b:	b8 07 00 00 00       	mov    $0x7,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	ret    

00000453 <open>:
SYSCALL(open)
 453:	b8 0f 00 00 00       	mov    $0xf,%eax
 458:	cd 40                	int    $0x40
 45a:	c3                   	ret    

0000045b <mknod>:
SYSCALL(mknod)
 45b:	b8 11 00 00 00       	mov    $0x11,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	ret    

00000463 <unlink>:
SYSCALL(unlink)
 463:	b8 12 00 00 00       	mov    $0x12,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret    

0000046b <fstat>:
SYSCALL(fstat)
 46b:	b8 08 00 00 00       	mov    $0x8,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret    

00000473 <link>:
SYSCALL(link)
 473:	b8 13 00 00 00       	mov    $0x13,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret    

0000047b <mkdir>:
SYSCALL(mkdir)
 47b:	b8 14 00 00 00       	mov    $0x14,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	ret    

00000483 <chdir>:
SYSCALL(chdir)
 483:	b8 09 00 00 00       	mov    $0x9,%eax
 488:	cd 40                	int    $0x40
 48a:	c3                   	ret    

0000048b <dup>:
SYSCALL(dup)
 48b:	b8 0a 00 00 00       	mov    $0xa,%eax
 490:	cd 40                	int    $0x40
 492:	c3                   	ret    

00000493 <getpid>:
SYSCALL(getpid)
 493:	b8 0b 00 00 00       	mov    $0xb,%eax
 498:	cd 40                	int    $0x40
 49a:	c3                   	ret    

0000049b <sbrk>:
SYSCALL(sbrk)
 49b:	b8 0c 00 00 00       	mov    $0xc,%eax
 4a0:	cd 40                	int    $0x40
 4a2:	c3                   	ret    

000004a3 <sleep>:
SYSCALL(sleep)
 4a3:	b8 0d 00 00 00       	mov    $0xd,%eax
 4a8:	cd 40                	int    $0x40
 4aa:	c3                   	ret    

000004ab <uptime>:
SYSCALL(uptime)
 4ab:	b8 0e 00 00 00       	mov    $0xe,%eax
 4b0:	cd 40                	int    $0x40
 4b2:	c3                   	ret    

000004b3 <sigset>:
SYSCALL(sigset)
 4b3:	b8 16 00 00 00       	mov    $0x16,%eax
 4b8:	cd 40                	int    $0x40
 4ba:	c3                   	ret    

000004bb <sigsend>:
SYSCALL(sigsend)
 4bb:	b8 17 00 00 00       	mov    $0x17,%eax
 4c0:	cd 40                	int    $0x40
 4c2:	c3                   	ret    

000004c3 <sigpause>:
 4c3:	b8 19 00 00 00       	mov    $0x19,%eax
 4c8:	cd 40                	int    $0x40
 4ca:	c3                   	ret    

000004cb <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4cb:	55                   	push   %ebp
 4cc:	89 e5                	mov    %esp,%ebp
 4ce:	83 ec 18             	sub    $0x18,%esp
 4d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d4:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4d7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4de:	00 
 4df:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e6:	8b 45 08             	mov    0x8(%ebp),%eax
 4e9:	89 04 24             	mov    %eax,(%esp)
 4ec:	e8 42 ff ff ff       	call   433 <write>
}
 4f1:	c9                   	leave  
 4f2:	c3                   	ret    

000004f3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f3:	55                   	push   %ebp
 4f4:	89 e5                	mov    %esp,%ebp
 4f6:	56                   	push   %esi
 4f7:	53                   	push   %ebx
 4f8:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 502:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 506:	74 17                	je     51f <printint+0x2c>
 508:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 50c:	79 11                	jns    51f <printint+0x2c>
    neg = 1;
 50e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 515:	8b 45 0c             	mov    0xc(%ebp),%eax
 518:	f7 d8                	neg    %eax
 51a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 51d:	eb 06                	jmp    525 <printint+0x32>
  } else {
    x = xx;
 51f:	8b 45 0c             	mov    0xc(%ebp),%eax
 522:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 525:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 52c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 52f:	8d 41 01             	lea    0x1(%ecx),%eax
 532:	89 45 f4             	mov    %eax,-0xc(%ebp)
 535:	8b 5d 10             	mov    0x10(%ebp),%ebx
 538:	8b 45 ec             	mov    -0x14(%ebp),%eax
 53b:	ba 00 00 00 00       	mov    $0x0,%edx
 540:	f7 f3                	div    %ebx
 542:	89 d0                	mov    %edx,%eax
 544:	0f b6 80 7c 0c 00 00 	movzbl 0xc7c(%eax),%eax
 54b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 54f:	8b 75 10             	mov    0x10(%ebp),%esi
 552:	8b 45 ec             	mov    -0x14(%ebp),%eax
 555:	ba 00 00 00 00       	mov    $0x0,%edx
 55a:	f7 f6                	div    %esi
 55c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 55f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 563:	75 c7                	jne    52c <printint+0x39>
  if(neg)
 565:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 569:	74 10                	je     57b <printint+0x88>
    buf[i++] = '-';
 56b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56e:	8d 50 01             	lea    0x1(%eax),%edx
 571:	89 55 f4             	mov    %edx,-0xc(%ebp)
 574:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 579:	eb 1f                	jmp    59a <printint+0xa7>
 57b:	eb 1d                	jmp    59a <printint+0xa7>
    putc(fd, buf[i]);
 57d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 580:	8b 45 f4             	mov    -0xc(%ebp),%eax
 583:	01 d0                	add    %edx,%eax
 585:	0f b6 00             	movzbl (%eax),%eax
 588:	0f be c0             	movsbl %al,%eax
 58b:	89 44 24 04          	mov    %eax,0x4(%esp)
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	89 04 24             	mov    %eax,(%esp)
 595:	e8 31 ff ff ff       	call   4cb <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 59a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 59e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a2:	79 d9                	jns    57d <printint+0x8a>
    putc(fd, buf[i]);
}
 5a4:	83 c4 30             	add    $0x30,%esp
 5a7:	5b                   	pop    %ebx
 5a8:	5e                   	pop    %esi
 5a9:	5d                   	pop    %ebp
 5aa:	c3                   	ret    

000005ab <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5ab:	55                   	push   %ebp
 5ac:	89 e5                	mov    %esp,%ebp
 5ae:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5b1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5b8:	8d 45 0c             	lea    0xc(%ebp),%eax
 5bb:	83 c0 04             	add    $0x4,%eax
 5be:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5c8:	e9 7c 01 00 00       	jmp    749 <printf+0x19e>
    c = fmt[i] & 0xff;
 5cd:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d3:	01 d0                	add    %edx,%eax
 5d5:	0f b6 00             	movzbl (%eax),%eax
 5d8:	0f be c0             	movsbl %al,%eax
 5db:	25 ff 00 00 00       	and    $0xff,%eax
 5e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5e7:	75 2c                	jne    615 <printf+0x6a>
      if(c == '%'){
 5e9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5ed:	75 0c                	jne    5fb <printf+0x50>
        state = '%';
 5ef:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5f6:	e9 4a 01 00 00       	jmp    745 <printf+0x19a>
      } else {
        putc(fd, c);
 5fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fe:	0f be c0             	movsbl %al,%eax
 601:	89 44 24 04          	mov    %eax,0x4(%esp)
 605:	8b 45 08             	mov    0x8(%ebp),%eax
 608:	89 04 24             	mov    %eax,(%esp)
 60b:	e8 bb fe ff ff       	call   4cb <putc>
 610:	e9 30 01 00 00       	jmp    745 <printf+0x19a>
      }
    } else if(state == '%'){
 615:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 619:	0f 85 26 01 00 00    	jne    745 <printf+0x19a>
      if(c == 'd'){
 61f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 623:	75 2d                	jne    652 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 625:	8b 45 e8             	mov    -0x18(%ebp),%eax
 628:	8b 00                	mov    (%eax),%eax
 62a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 631:	00 
 632:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 639:	00 
 63a:	89 44 24 04          	mov    %eax,0x4(%esp)
 63e:	8b 45 08             	mov    0x8(%ebp),%eax
 641:	89 04 24             	mov    %eax,(%esp)
 644:	e8 aa fe ff ff       	call   4f3 <printint>
        ap++;
 649:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 64d:	e9 ec 00 00 00       	jmp    73e <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 652:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 656:	74 06                	je     65e <printf+0xb3>
 658:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 65c:	75 2d                	jne    68b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 65e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 661:	8b 00                	mov    (%eax),%eax
 663:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 66a:	00 
 66b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 672:	00 
 673:	89 44 24 04          	mov    %eax,0x4(%esp)
 677:	8b 45 08             	mov    0x8(%ebp),%eax
 67a:	89 04 24             	mov    %eax,(%esp)
 67d:	e8 71 fe ff ff       	call   4f3 <printint>
        ap++;
 682:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 686:	e9 b3 00 00 00       	jmp    73e <printf+0x193>
      } else if(c == 's'){
 68b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 68f:	75 45                	jne    6d6 <printf+0x12b>
        s = (char*)*ap;
 691:	8b 45 e8             	mov    -0x18(%ebp),%eax
 694:	8b 00                	mov    (%eax),%eax
 696:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 699:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 69d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6a1:	75 09                	jne    6ac <printf+0x101>
          s = "(null)";
 6a3:	c7 45 f4 04 0a 00 00 	movl   $0xa04,-0xc(%ebp)
        while(*s != 0){
 6aa:	eb 1e                	jmp    6ca <printf+0x11f>
 6ac:	eb 1c                	jmp    6ca <printf+0x11f>
          putc(fd, *s);
 6ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b1:	0f b6 00             	movzbl (%eax),%eax
 6b4:	0f be c0             	movsbl %al,%eax
 6b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bb:	8b 45 08             	mov    0x8(%ebp),%eax
 6be:	89 04 24             	mov    %eax,(%esp)
 6c1:	e8 05 fe ff ff       	call   4cb <putc>
          s++;
 6c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6cd:	0f b6 00             	movzbl (%eax),%eax
 6d0:	84 c0                	test   %al,%al
 6d2:	75 da                	jne    6ae <printf+0x103>
 6d4:	eb 68                	jmp    73e <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6d6:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6da:	75 1d                	jne    6f9 <printf+0x14e>
        putc(fd, *ap);
 6dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6df:	8b 00                	mov    (%eax),%eax
 6e1:	0f be c0             	movsbl %al,%eax
 6e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e8:	8b 45 08             	mov    0x8(%ebp),%eax
 6eb:	89 04 24             	mov    %eax,(%esp)
 6ee:	e8 d8 fd ff ff       	call   4cb <putc>
        ap++;
 6f3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f7:	eb 45                	jmp    73e <printf+0x193>
      } else if(c == '%'){
 6f9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6fd:	75 17                	jne    716 <printf+0x16b>
        putc(fd, c);
 6ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 702:	0f be c0             	movsbl %al,%eax
 705:	89 44 24 04          	mov    %eax,0x4(%esp)
 709:	8b 45 08             	mov    0x8(%ebp),%eax
 70c:	89 04 24             	mov    %eax,(%esp)
 70f:	e8 b7 fd ff ff       	call   4cb <putc>
 714:	eb 28                	jmp    73e <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 716:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 71d:	00 
 71e:	8b 45 08             	mov    0x8(%ebp),%eax
 721:	89 04 24             	mov    %eax,(%esp)
 724:	e8 a2 fd ff ff       	call   4cb <putc>
        putc(fd, c);
 729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 72c:	0f be c0             	movsbl %al,%eax
 72f:	89 44 24 04          	mov    %eax,0x4(%esp)
 733:	8b 45 08             	mov    0x8(%ebp),%eax
 736:	89 04 24             	mov    %eax,(%esp)
 739:	e8 8d fd ff ff       	call   4cb <putc>
      }
      state = 0;
 73e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 745:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 749:	8b 55 0c             	mov    0xc(%ebp),%edx
 74c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74f:	01 d0                	add    %edx,%eax
 751:	0f b6 00             	movzbl (%eax),%eax
 754:	84 c0                	test   %al,%al
 756:	0f 85 71 fe ff ff    	jne    5cd <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 75c:	c9                   	leave  
 75d:	c3                   	ret    

0000075e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75e:	55                   	push   %ebp
 75f:	89 e5                	mov    %esp,%ebp
 761:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 764:	8b 45 08             	mov    0x8(%ebp),%eax
 767:	83 e8 08             	sub    $0x8,%eax
 76a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76d:	a1 98 0c 00 00       	mov    0xc98,%eax
 772:	89 45 fc             	mov    %eax,-0x4(%ebp)
 775:	eb 24                	jmp    79b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 00                	mov    (%eax),%eax
 77c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 77f:	77 12                	ja     793 <free+0x35>
 781:	8b 45 f8             	mov    -0x8(%ebp),%eax
 784:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 787:	77 24                	ja     7ad <free+0x4f>
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	8b 00                	mov    (%eax),%eax
 78e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 791:	77 1a                	ja     7ad <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 793:	8b 45 fc             	mov    -0x4(%ebp),%eax
 796:	8b 00                	mov    (%eax),%eax
 798:	89 45 fc             	mov    %eax,-0x4(%ebp)
 79b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a1:	76 d4                	jbe    777 <free+0x19>
 7a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a6:	8b 00                	mov    (%eax),%eax
 7a8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ab:	76 ca                	jbe    777 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b0:	8b 40 04             	mov    0x4(%eax),%eax
 7b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bd:	01 c2                	add    %eax,%edx
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	8b 00                	mov    (%eax),%eax
 7c4:	39 c2                	cmp    %eax,%edx
 7c6:	75 24                	jne    7ec <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7cb:	8b 50 04             	mov    0x4(%eax),%edx
 7ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d1:	8b 00                	mov    (%eax),%eax
 7d3:	8b 40 04             	mov    0x4(%eax),%eax
 7d6:	01 c2                	add    %eax,%edx
 7d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7db:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e1:	8b 00                	mov    (%eax),%eax
 7e3:	8b 10                	mov    (%eax),%edx
 7e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e8:	89 10                	mov    %edx,(%eax)
 7ea:	eb 0a                	jmp    7f6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ef:	8b 10                	mov    (%eax),%edx
 7f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f9:	8b 40 04             	mov    0x4(%eax),%eax
 7fc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 803:	8b 45 fc             	mov    -0x4(%ebp),%eax
 806:	01 d0                	add    %edx,%eax
 808:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 80b:	75 20                	jne    82d <free+0xcf>
    p->s.size += bp->s.size;
 80d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 810:	8b 50 04             	mov    0x4(%eax),%edx
 813:	8b 45 f8             	mov    -0x8(%ebp),%eax
 816:	8b 40 04             	mov    0x4(%eax),%eax
 819:	01 c2                	add    %eax,%edx
 81b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 821:	8b 45 f8             	mov    -0x8(%ebp),%eax
 824:	8b 10                	mov    (%eax),%edx
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	89 10                	mov    %edx,(%eax)
 82b:	eb 08                	jmp    835 <free+0xd7>
  } else
    p->s.ptr = bp;
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	8b 55 f8             	mov    -0x8(%ebp),%edx
 833:	89 10                	mov    %edx,(%eax)
  freep = p;
 835:	8b 45 fc             	mov    -0x4(%ebp),%eax
 838:	a3 98 0c 00 00       	mov    %eax,0xc98
}
 83d:	c9                   	leave  
 83e:	c3                   	ret    

0000083f <morecore>:

static Header*
morecore(uint nu)
{
 83f:	55                   	push   %ebp
 840:	89 e5                	mov    %esp,%ebp
 842:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 845:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 84c:	77 07                	ja     855 <morecore+0x16>
    nu = 4096;
 84e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 855:	8b 45 08             	mov    0x8(%ebp),%eax
 858:	c1 e0 03             	shl    $0x3,%eax
 85b:	89 04 24             	mov    %eax,(%esp)
 85e:	e8 38 fc ff ff       	call   49b <sbrk>
 863:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 866:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 86a:	75 07                	jne    873 <morecore+0x34>
    return 0;
 86c:	b8 00 00 00 00       	mov    $0x0,%eax
 871:	eb 22                	jmp    895 <morecore+0x56>
  hp = (Header*)p;
 873:	8b 45 f4             	mov    -0xc(%ebp),%eax
 876:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 879:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87c:	8b 55 08             	mov    0x8(%ebp),%edx
 87f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 882:	8b 45 f0             	mov    -0x10(%ebp),%eax
 885:	83 c0 08             	add    $0x8,%eax
 888:	89 04 24             	mov    %eax,(%esp)
 88b:	e8 ce fe ff ff       	call   75e <free>
  return freep;
 890:	a1 98 0c 00 00       	mov    0xc98,%eax
}
 895:	c9                   	leave  
 896:	c3                   	ret    

00000897 <malloc>:

void*
malloc(uint nbytes)
{
 897:	55                   	push   %ebp
 898:	89 e5                	mov    %esp,%ebp
 89a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89d:	8b 45 08             	mov    0x8(%ebp),%eax
 8a0:	83 c0 07             	add    $0x7,%eax
 8a3:	c1 e8 03             	shr    $0x3,%eax
 8a6:	83 c0 01             	add    $0x1,%eax
 8a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8ac:	a1 98 0c 00 00       	mov    0xc98,%eax
 8b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8b8:	75 23                	jne    8dd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8ba:	c7 45 f0 90 0c 00 00 	movl   $0xc90,-0x10(%ebp)
 8c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c4:	a3 98 0c 00 00       	mov    %eax,0xc98
 8c9:	a1 98 0c 00 00       	mov    0xc98,%eax
 8ce:	a3 90 0c 00 00       	mov    %eax,0xc90
    base.s.size = 0;
 8d3:	c7 05 94 0c 00 00 00 	movl   $0x0,0xc94
 8da:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e0:	8b 00                	mov    (%eax),%eax
 8e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e8:	8b 40 04             	mov    0x4(%eax),%eax
 8eb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8ee:	72 4d                	jb     93d <malloc+0xa6>
      if(p->s.size == nunits)
 8f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f3:	8b 40 04             	mov    0x4(%eax),%eax
 8f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f9:	75 0c                	jne    907 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fe:	8b 10                	mov    (%eax),%edx
 900:	8b 45 f0             	mov    -0x10(%ebp),%eax
 903:	89 10                	mov    %edx,(%eax)
 905:	eb 26                	jmp    92d <malloc+0x96>
      else {
        p->s.size -= nunits;
 907:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90a:	8b 40 04             	mov    0x4(%eax),%eax
 90d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 910:	89 c2                	mov    %eax,%edx
 912:	8b 45 f4             	mov    -0xc(%ebp),%eax
 915:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 918:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91b:	8b 40 04             	mov    0x4(%eax),%eax
 91e:	c1 e0 03             	shl    $0x3,%eax
 921:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 924:	8b 45 f4             	mov    -0xc(%ebp),%eax
 927:	8b 55 ec             	mov    -0x14(%ebp),%edx
 92a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 92d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 930:	a3 98 0c 00 00       	mov    %eax,0xc98
      return (void*)(p + 1);
 935:	8b 45 f4             	mov    -0xc(%ebp),%eax
 938:	83 c0 08             	add    $0x8,%eax
 93b:	eb 38                	jmp    975 <malloc+0xde>
    }
    if(p == freep)
 93d:	a1 98 0c 00 00       	mov    0xc98,%eax
 942:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 945:	75 1b                	jne    962 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 947:	8b 45 ec             	mov    -0x14(%ebp),%eax
 94a:	89 04 24             	mov    %eax,(%esp)
 94d:	e8 ed fe ff ff       	call   83f <morecore>
 952:	89 45 f4             	mov    %eax,-0xc(%ebp)
 955:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 959:	75 07                	jne    962 <malloc+0xcb>
        return 0;
 95b:	b8 00 00 00 00       	mov    $0x0,%eax
 960:	eb 13                	jmp    975 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 962:	8b 45 f4             	mov    -0xc(%ebp),%eax
 965:	89 45 f0             	mov    %eax,-0x10(%ebp)
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	8b 00                	mov    (%eax),%eax
 96d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 970:	e9 70 ff ff ff       	jmp    8e5 <malloc+0x4e>
}
 975:	c9                   	leave  
 976:	c3                   	ret    
