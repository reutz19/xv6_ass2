
_primesrv:     file format elf32-i386


Disassembly of section .text:

00000000 <is_prime>:
  return 0;
}
*/

int 
is_prime(int num){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
    if((num & 1)==0)
   6:	8b 45 08             	mov    0x8(%ebp),%eax
   9:	83 e0 01             	and    $0x1,%eax
   c:	85 c0                	test   %eax,%eax
   e:	75 0c                	jne    1c <is_prime+0x1c>
        return num == 2;
  10:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  14:	0f 94 c0             	sete   %al
  17:	0f b6 c0             	movzbl %al,%eax
  1a:	eb 2e                	jmp    4a <is_prime+0x4a>
    else {
        int i;
        for (i = 3; i <= num; i+=2){
  1c:	c7 45 fc 03 00 00 00 	movl   $0x3,-0x4(%ebp)
  23:	eb 18                	jmp    3d <is_prime+0x3d>
            if (num % i == 0)
  25:	8b 45 08             	mov    0x8(%ebp),%eax
  28:	99                   	cltd   
  29:	f7 7d fc             	idivl  -0x4(%ebp)
  2c:	89 d0                	mov    %edx,%eax
  2e:	85 c0                	test   %eax,%eax
  30:	75 07                	jne    39 <is_prime+0x39>
                return 0;
  32:	b8 00 00 00 00       	mov    $0x0,%eax
  37:	eb 11                	jmp    4a <is_prime+0x4a>
is_prime(int num){
    if((num & 1)==0)
        return num == 2;
    else {
        int i;
        for (i = 3; i <= num; i+=2){
  39:	83 45 fc 02          	addl   $0x2,-0x4(%ebp)
  3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  40:	3b 45 08             	cmp    0x8(%ebp),%eax
  43:	7e e0                	jle    25 <is_prime+0x25>
            if (num % i == 0)
                return 0;
        }
    }
    return 1;
  45:	b8 01 00 00 00       	mov    $0x1,%eax
}
  4a:	c9                   	leave  
  4b:	c3                   	ret    

0000004c <next_pr>:

int 
next_pr(int num){
  4c:	55                   	push   %ebp
  4d:	89 e5                	mov    %esp,%ebp
  4f:	83 ec 28             	sub    $0x28,%esp
    int c;
    if(num < 2)
  52:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  56:	7f 09                	jg     61 <next_pr+0x15>
        c = 2;
  58:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  5f:	eb 52                	jmp    b3 <next_pr+0x67>
    else if (num == 2)
  61:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  65:	75 09                	jne    70 <next_pr+0x24>
        c = 3;
  67:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
  6e:	eb 43                	jmp    b3 <next_pr+0x67>
    else if(num & 1){
  70:	8b 45 08             	mov    0x8(%ebp),%eax
  73:	83 e0 01             	and    $0x1,%eax
  76:	85 c0                	test   %eax,%eax
  78:	74 28                	je     a2 <next_pr+0x56>
        num += 2;
  7a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
        c = is_prime(num) ? num : next_pr(num);
  7e:	8b 45 08             	mov    0x8(%ebp),%eax
  81:	89 04 24             	mov    %eax,(%esp)
  84:	e8 77 ff ff ff       	call   0 <is_prime>
  89:	85 c0                	test   %eax,%eax
  8b:	75 0d                	jne    9a <next_pr+0x4e>
  8d:	8b 45 08             	mov    0x8(%ebp),%eax
  90:	89 04 24             	mov    %eax,(%esp)
  93:	e8 b4 ff ff ff       	call   4c <next_pr>
  98:	eb 03                	jmp    9d <next_pr+0x51>
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  a0:	eb 11                	jmp    b3 <next_pr+0x67>
    } else
        c = next_pr(num-1);
  a2:	8b 45 08             	mov    0x8(%ebp),%eax
  a5:	83 e8 01             	sub    $0x1,%eax
  a8:	89 04 24             	mov    %eax,(%esp)
  ab:	e8 9c ff ff ff       	call   4c <next_pr>
  b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return c;
  b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  b6:	c9                   	leave  
  b7:	c3                   	ret    

000000b8 <main>:


  
int
main(int argc, char *argv[])
{
  b8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  bc:	83 e4 f0             	and    $0xfffffff0,%esp
  bf:	ff 71 fc             	pushl  -0x4(%ecx)
  c2:	55                   	push   %ebp
  c3:	89 e5                	mov    %esp,%ebp
  c5:	53                   	push   %ebx
  c6:	51                   	push   %ecx
  c7:	83 ec 40             	sub    $0x40,%esp
  ca:	89 c8                	mov    %ecx,%eax
  int n, i, pid, prime;
  char buff[MAX_INPUT];

  // test arguments
  if (argc != 2){
  cc:	83 38 02             	cmpl   $0x2,(%eax)
  cf:	74 19                	je     ea <main+0x32>
  	printf(1, "Unvaild parameter for primsrv test\n");
  d1:	c7 44 24 04 34 0a 00 	movl   $0xa34,0x4(%esp)
  d8:	00 
  d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e0:	e8 83 05 00 00       	call   668 <printf>
  	exit();
  e5:	e8 de 03 00 00       	call   4c8 <exit>
  }

  n = atoi(argv[1]);
  ea:	8b 40 04             	mov    0x4(%eax),%eax
  ed:	83 c0 04             	add    $0x4,%eax
  f0:	8b 00                	mov    (%eax),%eax
  f2:	89 04 24             	mov    %eax,(%esp)
  f5:	e8 3c 03 00 00       	call   436 <atoi>
  fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int workers[n];
  fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 100:	8d 50 ff             	lea    -0x1(%eax),%edx
 103:	89 55 ec             	mov    %edx,-0x14(%ebp)
 106:	c1 e0 02             	shl    $0x2,%eax
 109:	8d 50 03             	lea    0x3(%eax),%edx
 10c:	b8 10 00 00 00       	mov    $0x10,%eax
 111:	83 e8 01             	sub    $0x1,%eax
 114:	01 d0                	add    %edx,%eax
 116:	bb 10 00 00 00       	mov    $0x10,%ebx
 11b:	ba 00 00 00 00       	mov    $0x0,%edx
 120:	f7 f3                	div    %ebx
 122:	6b c0 10             	imul   $0x10,%eax,%eax
 125:	29 c4                	sub    %eax,%esp
 127:	8d 44 24 0c          	lea    0xc(%esp),%eax
 12b:	83 c0 03             	add    $0x3,%eax
 12e:	c1 e8 02             	shr    $0x2,%eax
 131:	c1 e0 02             	shl    $0x2,%eax
 134:	89 45 e8             	mov    %eax,-0x18(%ebp)

  printf(1, "workers pids:\n");
 137:	c7 44 24 04 58 0a 00 	movl   $0xa58,0x4(%esp)
 13e:	00 
 13f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 146:	e8 1d 05 00 00       	call   668 <printf>
  for(i = 0; i < n; i++){
 14b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 152:	eb 75                	jmp    1c9 <main+0x111>
  	if ((pid = fork()) == 0) { // son
 154:	e8 67 03 00 00       	call   4c0 <fork>
 159:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 15c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 160:	75 36                	jne    198 <main+0xe0>
      pid = getpid();
 162:	e8 e1 03 00 00       	call   548 <getpid>
 167:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 	    printf(1,"%d\n", pid);	
 16a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 16d:	89 44 24 08          	mov    %eax,0x8(%esp)
 171:	c7 44 24 04 67 0a 00 	movl   $0xa67,0x4(%esp)
 178:	00 
 179:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 180:	e8 e3 04 00 00       	call   668 <printf>
 	    sigset((int *)next_pr);
 185:	c7 04 24 4c 00 00 00 	movl   $0x4c,(%esp)
 18c:	e8 d7 03 00 00       	call   568 <sigset>
      sigpause();
 191:	e8 ea 03 00 00       	call   580 <sigpause>
 196:	eb 2d                	jmp    1c5 <main+0x10d>
    }
    else if (pid > 0) {        // father
 198:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 19c:	7e 0e                	jle    1ac <main+0xf4>
      workers[i] = pid;
 19e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1a4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 1a7:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
 1aa:	eb 19                	jmp    1c5 <main+0x10d>
    }
    else{
    // fork failed
      printf(1, "fork() failed!\n"); 
 1ac:	c7 44 24 04 6b 0a 00 	movl   $0xa6b,0x4(%esp)
 1b3:	00 
 1b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bb:	e8 a8 04 00 00       	call   668 <printf>
      exit();
 1c0:	e8 03 03 00 00       	call   4c8 <exit>

  n = atoi(argv[1]);
  int workers[n];

  printf(1, "workers pids:\n");
  for(i = 0; i < n; i++){
 1c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
 1cf:	7c 83                	jl     154 <main+0x9c>
    }
  }

  for(;;)
  {
  	printf(1, "Please enter a number: \n");
 1d1:	c7 44 24 04 7b 0a 00 	movl   $0xa7b,0x4(%esp)
 1d8:	00 
 1d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1e0:	e8 83 04 00 00       	call   668 <printf>
  	gets(buff, MAX_INPUT);
 1e5:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
 1ec:	00 
 1ed:	8d 45 d6             	lea    -0x2a(%ebp),%eax
 1f0:	89 04 24             	mov    %eax,(%esp)
 1f3:	e8 7a 01 00 00       	call   372 <gets>
  	prime = atoi(buff);
 1f8:	8d 45 d6             	lea    -0x2a(%ebp),%eax
 1fb:	89 04 24             	mov    %eax,(%esp)
 1fe:	e8 33 02 00 00       	call   436 <atoi>
 203:	89 45 e0             	mov    %eax,-0x20(%ebp)
    //int ans;
  	if(prime != 0)
 206:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 20a:	75 4f                	jne    25b <main+0x1a3>
    {
      //sigsend
    }
    else
  	{
  	  for (i = 0; i < n; i++)
 20c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 213:	eb 25                	jmp    23a <main+0x182>
  	  {
  	    printf(1, "worker %d exit\n", workers[i]);
 215:	8b 45 e8             	mov    -0x18(%ebp),%eax
 218:	8b 55 f4             	mov    -0xc(%ebp),%edx
 21b:	8b 04 90             	mov    (%eax,%edx,4),%eax
 21e:	89 44 24 08          	mov    %eax,0x8(%esp)
 222:	c7 44 24 04 94 0a 00 	movl   $0xa94,0x4(%esp)
 229:	00 
 22a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 231:	e8 32 04 00 00       	call   668 <printf>
    {
      //sigsend
    }
    else
  	{
  	  for (i = 0; i < n; i++)
 236:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 23a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
 240:	7c d3                	jl     215 <main+0x15d>
  	  {
  	    printf(1, "worker %d exit\n", workers[i]);
  	  }
  	  printf(1, "primesrv exit\n");
 242:	c7 44 24 04 a4 0a 00 	movl   $0xaa4,0x4(%esp)
 249:	00 
 24a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 251:	e8 12 04 00 00       	call   668 <printf>
  	  exit();
 256:	e8 6d 02 00 00       	call   4c8 <exit>
  	}
  }
 25b:	e9 71 ff ff ff       	jmp    1d1 <main+0x119>

00000260 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 260:	55                   	push   %ebp
 261:	89 e5                	mov    %esp,%ebp
 263:	57                   	push   %edi
 264:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 265:	8b 4d 08             	mov    0x8(%ebp),%ecx
 268:	8b 55 10             	mov    0x10(%ebp),%edx
 26b:	8b 45 0c             	mov    0xc(%ebp),%eax
 26e:	89 cb                	mov    %ecx,%ebx
 270:	89 df                	mov    %ebx,%edi
 272:	89 d1                	mov    %edx,%ecx
 274:	fc                   	cld    
 275:	f3 aa                	rep stos %al,%es:(%edi)
 277:	89 ca                	mov    %ecx,%edx
 279:	89 fb                	mov    %edi,%ebx
 27b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 27e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 281:	5b                   	pop    %ebx
 282:	5f                   	pop    %edi
 283:	5d                   	pop    %ebp
 284:	c3                   	ret    

00000285 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 285:	55                   	push   %ebp
 286:	89 e5                	mov    %esp,%ebp
 288:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 28b:	8b 45 08             	mov    0x8(%ebp),%eax
 28e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 291:	90                   	nop
 292:	8b 45 08             	mov    0x8(%ebp),%eax
 295:	8d 50 01             	lea    0x1(%eax),%edx
 298:	89 55 08             	mov    %edx,0x8(%ebp)
 29b:	8b 55 0c             	mov    0xc(%ebp),%edx
 29e:	8d 4a 01             	lea    0x1(%edx),%ecx
 2a1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 2a4:	0f b6 12             	movzbl (%edx),%edx
 2a7:	88 10                	mov    %dl,(%eax)
 2a9:	0f b6 00             	movzbl (%eax),%eax
 2ac:	84 c0                	test   %al,%al
 2ae:	75 e2                	jne    292 <strcpy+0xd>
    ;
  return os;
 2b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b3:	c9                   	leave  
 2b4:	c3                   	ret    

000002b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2b8:	eb 08                	jmp    2c2 <strcmp+0xd>
    p++, q++;
 2ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
 2c5:	0f b6 00             	movzbl (%eax),%eax
 2c8:	84 c0                	test   %al,%al
 2ca:	74 10                	je     2dc <strcmp+0x27>
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	0f b6 10             	movzbl (%eax),%edx
 2d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d5:	0f b6 00             	movzbl (%eax),%eax
 2d8:	38 c2                	cmp    %al,%dl
 2da:	74 de                	je     2ba <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
 2df:	0f b6 00             	movzbl (%eax),%eax
 2e2:	0f b6 d0             	movzbl %al,%edx
 2e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	0f b6 c0             	movzbl %al,%eax
 2ee:	29 c2                	sub    %eax,%edx
 2f0:	89 d0                	mov    %edx,%eax
}
 2f2:	5d                   	pop    %ebp
 2f3:	c3                   	ret    

000002f4 <strlen>:

uint
strlen(char *s)
{
 2f4:	55                   	push   %ebp
 2f5:	89 e5                	mov    %esp,%ebp
 2f7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 301:	eb 04                	jmp    307 <strlen+0x13>
 303:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 307:	8b 55 fc             	mov    -0x4(%ebp),%edx
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	01 d0                	add    %edx,%eax
 30f:	0f b6 00             	movzbl (%eax),%eax
 312:	84 c0                	test   %al,%al
 314:	75 ed                	jne    303 <strlen+0xf>
    ;
  return n;
 316:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 319:	c9                   	leave  
 31a:	c3                   	ret    

0000031b <memset>:

void*
memset(void *dst, int c, uint n)
{
 31b:	55                   	push   %ebp
 31c:	89 e5                	mov    %esp,%ebp
 31e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 321:	8b 45 10             	mov    0x10(%ebp),%eax
 324:	89 44 24 08          	mov    %eax,0x8(%esp)
 328:	8b 45 0c             	mov    0xc(%ebp),%eax
 32b:	89 44 24 04          	mov    %eax,0x4(%esp)
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
 332:	89 04 24             	mov    %eax,(%esp)
 335:	e8 26 ff ff ff       	call   260 <stosb>
  return dst;
 33a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33d:	c9                   	leave  
 33e:	c3                   	ret    

0000033f <strchr>:

char*
strchr(const char *s, char c)
{
 33f:	55                   	push   %ebp
 340:	89 e5                	mov    %esp,%ebp
 342:	83 ec 04             	sub    $0x4,%esp
 345:	8b 45 0c             	mov    0xc(%ebp),%eax
 348:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 34b:	eb 14                	jmp    361 <strchr+0x22>
    if(*s == c)
 34d:	8b 45 08             	mov    0x8(%ebp),%eax
 350:	0f b6 00             	movzbl (%eax),%eax
 353:	3a 45 fc             	cmp    -0x4(%ebp),%al
 356:	75 05                	jne    35d <strchr+0x1e>
      return (char*)s;
 358:	8b 45 08             	mov    0x8(%ebp),%eax
 35b:	eb 13                	jmp    370 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 35d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 361:	8b 45 08             	mov    0x8(%ebp),%eax
 364:	0f b6 00             	movzbl (%eax),%eax
 367:	84 c0                	test   %al,%al
 369:	75 e2                	jne    34d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 36b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 370:	c9                   	leave  
 371:	c3                   	ret    

00000372 <gets>:

char*
gets(char *buf, int max)
{
 372:	55                   	push   %ebp
 373:	89 e5                	mov    %esp,%ebp
 375:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 378:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 37f:	eb 4c                	jmp    3cd <gets+0x5b>
    cc = read(0, &c, 1);
 381:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 388:	00 
 389:	8d 45 ef             	lea    -0x11(%ebp),%eax
 38c:	89 44 24 04          	mov    %eax,0x4(%esp)
 390:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 397:	e8 44 01 00 00       	call   4e0 <read>
 39c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 39f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3a3:	7f 02                	jg     3a7 <gets+0x35>
      break;
 3a5:	eb 31                	jmp    3d8 <gets+0x66>
    buf[i++] = c;
 3a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3aa:	8d 50 01             	lea    0x1(%eax),%edx
 3ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3b0:	89 c2                	mov    %eax,%edx
 3b2:	8b 45 08             	mov    0x8(%ebp),%eax
 3b5:	01 c2                	add    %eax,%edx
 3b7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3bb:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3c1:	3c 0a                	cmp    $0xa,%al
 3c3:	74 13                	je     3d8 <gets+0x66>
 3c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3c9:	3c 0d                	cmp    $0xd,%al
 3cb:	74 0b                	je     3d8 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d0:	83 c0 01             	add    $0x1,%eax
 3d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3d6:	7c a9                	jl     381 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
 3de:	01 d0                	add    %edx,%eax
 3e0:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3e6:	c9                   	leave  
 3e7:	c3                   	ret    

000003e8 <stat>:

int
stat(char *n, struct stat *st)
{
 3e8:	55                   	push   %ebp
 3e9:	89 e5                	mov    %esp,%ebp
 3eb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 3f5:	00 
 3f6:	8b 45 08             	mov    0x8(%ebp),%eax
 3f9:	89 04 24             	mov    %eax,(%esp)
 3fc:	e8 07 01 00 00       	call   508 <open>
 401:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 404:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 408:	79 07                	jns    411 <stat+0x29>
    return -1;
 40a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 40f:	eb 23                	jmp    434 <stat+0x4c>
  r = fstat(fd, st);
 411:	8b 45 0c             	mov    0xc(%ebp),%eax
 414:	89 44 24 04          	mov    %eax,0x4(%esp)
 418:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41b:	89 04 24             	mov    %eax,(%esp)
 41e:	e8 fd 00 00 00       	call   520 <fstat>
 423:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 426:	8b 45 f4             	mov    -0xc(%ebp),%eax
 429:	89 04 24             	mov    %eax,(%esp)
 42c:	e8 bf 00 00 00       	call   4f0 <close>
  return r;
 431:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 434:	c9                   	leave  
 435:	c3                   	ret    

00000436 <atoi>:

int
atoi(const char *s)
{
 436:	55                   	push   %ebp
 437:	89 e5                	mov    %esp,%ebp
 439:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 43c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 443:	eb 25                	jmp    46a <atoi+0x34>
    n = n*10 + *s++ - '0';
 445:	8b 55 fc             	mov    -0x4(%ebp),%edx
 448:	89 d0                	mov    %edx,%eax
 44a:	c1 e0 02             	shl    $0x2,%eax
 44d:	01 d0                	add    %edx,%eax
 44f:	01 c0                	add    %eax,%eax
 451:	89 c1                	mov    %eax,%ecx
 453:	8b 45 08             	mov    0x8(%ebp),%eax
 456:	8d 50 01             	lea    0x1(%eax),%edx
 459:	89 55 08             	mov    %edx,0x8(%ebp)
 45c:	0f b6 00             	movzbl (%eax),%eax
 45f:	0f be c0             	movsbl %al,%eax
 462:	01 c8                	add    %ecx,%eax
 464:	83 e8 30             	sub    $0x30,%eax
 467:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 46a:	8b 45 08             	mov    0x8(%ebp),%eax
 46d:	0f b6 00             	movzbl (%eax),%eax
 470:	3c 2f                	cmp    $0x2f,%al
 472:	7e 0a                	jle    47e <atoi+0x48>
 474:	8b 45 08             	mov    0x8(%ebp),%eax
 477:	0f b6 00             	movzbl (%eax),%eax
 47a:	3c 39                	cmp    $0x39,%al
 47c:	7e c7                	jle    445 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 47e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 481:	c9                   	leave  
 482:	c3                   	ret    

00000483 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 483:	55                   	push   %ebp
 484:	89 e5                	mov    %esp,%ebp
 486:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 489:	8b 45 08             	mov    0x8(%ebp),%eax
 48c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 48f:	8b 45 0c             	mov    0xc(%ebp),%eax
 492:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 495:	eb 17                	jmp    4ae <memmove+0x2b>
    *dst++ = *src++;
 497:	8b 45 fc             	mov    -0x4(%ebp),%eax
 49a:	8d 50 01             	lea    0x1(%eax),%edx
 49d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 4a0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4a3:	8d 4a 01             	lea    0x1(%edx),%ecx
 4a6:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 4a9:	0f b6 12             	movzbl (%edx),%edx
 4ac:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4ae:	8b 45 10             	mov    0x10(%ebp),%eax
 4b1:	8d 50 ff             	lea    -0x1(%eax),%edx
 4b4:	89 55 10             	mov    %edx,0x10(%ebp)
 4b7:	85 c0                	test   %eax,%eax
 4b9:	7f dc                	jg     497 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4be:	c9                   	leave  
 4bf:	c3                   	ret    

000004c0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4c0:	b8 01 00 00 00       	mov    $0x1,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <exit>:
SYSCALL(exit)
 4c8:	b8 02 00 00 00       	mov    $0x2,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <wait>:
SYSCALL(wait)
 4d0:	b8 03 00 00 00       	mov    $0x3,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <pipe>:
SYSCALL(pipe)
 4d8:	b8 04 00 00 00       	mov    $0x4,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <read>:
SYSCALL(read)
 4e0:	b8 05 00 00 00       	mov    $0x5,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <write>:
SYSCALL(write)
 4e8:	b8 10 00 00 00       	mov    $0x10,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <close>:
SYSCALL(close)
 4f0:	b8 15 00 00 00       	mov    $0x15,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <kill>:
SYSCALL(kill)
 4f8:	b8 06 00 00 00       	mov    $0x6,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <exec>:
SYSCALL(exec)
 500:	b8 07 00 00 00       	mov    $0x7,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <open>:
SYSCALL(open)
 508:	b8 0f 00 00 00       	mov    $0xf,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <mknod>:
SYSCALL(mknod)
 510:	b8 11 00 00 00       	mov    $0x11,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <unlink>:
SYSCALL(unlink)
 518:	b8 12 00 00 00       	mov    $0x12,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <fstat>:
SYSCALL(fstat)
 520:	b8 08 00 00 00       	mov    $0x8,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <link>:
SYSCALL(link)
 528:	b8 13 00 00 00       	mov    $0x13,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <mkdir>:
SYSCALL(mkdir)
 530:	b8 14 00 00 00       	mov    $0x14,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <chdir>:
SYSCALL(chdir)
 538:	b8 09 00 00 00       	mov    $0x9,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <dup>:
SYSCALL(dup)
 540:	b8 0a 00 00 00       	mov    $0xa,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <getpid>:
SYSCALL(getpid)
 548:	b8 0b 00 00 00       	mov    $0xb,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <sbrk>:
SYSCALL(sbrk)
 550:	b8 0c 00 00 00       	mov    $0xc,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <sleep>:
SYSCALL(sleep)
 558:	b8 0d 00 00 00       	mov    $0xd,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <uptime>:
SYSCALL(uptime)
 560:	b8 0e 00 00 00       	mov    $0xe,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <sigset>:
SYSCALL(sigset)
 568:	b8 16 00 00 00       	mov    $0x16,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <sigsend>:
SYSCALL(sigsend)
 570:	b8 17 00 00 00       	mov    $0x17,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <sigret>:
SYSCALL(sigret)
 578:	b8 18 00 00 00       	mov    $0x18,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <sigpause>:
 580:	b8 19 00 00 00       	mov    $0x19,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 588:	55                   	push   %ebp
 589:	89 e5                	mov    %esp,%ebp
 58b:	83 ec 18             	sub    $0x18,%esp
 58e:	8b 45 0c             	mov    0xc(%ebp),%eax
 591:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 594:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 59b:	00 
 59c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 59f:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a3:	8b 45 08             	mov    0x8(%ebp),%eax
 5a6:	89 04 24             	mov    %eax,(%esp)
 5a9:	e8 3a ff ff ff       	call   4e8 <write>
}
 5ae:	c9                   	leave  
 5af:	c3                   	ret    

000005b0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5b0:	55                   	push   %ebp
 5b1:	89 e5                	mov    %esp,%ebp
 5b3:	56                   	push   %esi
 5b4:	53                   	push   %ebx
 5b5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5bf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5c3:	74 17                	je     5dc <printint+0x2c>
 5c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5c9:	79 11                	jns    5dc <printint+0x2c>
    neg = 1;
 5cb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d5:	f7 d8                	neg    %eax
 5d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5da:	eb 06                	jmp    5e2 <printint+0x32>
  } else {
    x = xx;
 5dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 5df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5e9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5ec:	8d 41 01             	lea    0x1(%ecx),%eax
 5ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5f8:	ba 00 00 00 00       	mov    $0x0,%edx
 5fd:	f7 f3                	div    %ebx
 5ff:	89 d0                	mov    %edx,%eax
 601:	0f b6 80 4c 0d 00 00 	movzbl 0xd4c(%eax),%eax
 608:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 60c:	8b 75 10             	mov    0x10(%ebp),%esi
 60f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 612:	ba 00 00 00 00       	mov    $0x0,%edx
 617:	f7 f6                	div    %esi
 619:	89 45 ec             	mov    %eax,-0x14(%ebp)
 61c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 620:	75 c7                	jne    5e9 <printint+0x39>
  if(neg)
 622:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 626:	74 10                	je     638 <printint+0x88>
    buf[i++] = '-';
 628:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62b:	8d 50 01             	lea    0x1(%eax),%edx
 62e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 631:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 636:	eb 1f                	jmp    657 <printint+0xa7>
 638:	eb 1d                	jmp    657 <printint+0xa7>
    putc(fd, buf[i]);
 63a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 63d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 640:	01 d0                	add    %edx,%eax
 642:	0f b6 00             	movzbl (%eax),%eax
 645:	0f be c0             	movsbl %al,%eax
 648:	89 44 24 04          	mov    %eax,0x4(%esp)
 64c:	8b 45 08             	mov    0x8(%ebp),%eax
 64f:	89 04 24             	mov    %eax,(%esp)
 652:	e8 31 ff ff ff       	call   588 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 657:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 65b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 65f:	79 d9                	jns    63a <printint+0x8a>
    putc(fd, buf[i]);
}
 661:	83 c4 30             	add    $0x30,%esp
 664:	5b                   	pop    %ebx
 665:	5e                   	pop    %esi
 666:	5d                   	pop    %ebp
 667:	c3                   	ret    

00000668 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 668:	55                   	push   %ebp
 669:	89 e5                	mov    %esp,%ebp
 66b:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 66e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 675:	8d 45 0c             	lea    0xc(%ebp),%eax
 678:	83 c0 04             	add    $0x4,%eax
 67b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 67e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 685:	e9 7c 01 00 00       	jmp    806 <printf+0x19e>
    c = fmt[i] & 0xff;
 68a:	8b 55 0c             	mov    0xc(%ebp),%edx
 68d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 690:	01 d0                	add    %edx,%eax
 692:	0f b6 00             	movzbl (%eax),%eax
 695:	0f be c0             	movsbl %al,%eax
 698:	25 ff 00 00 00       	and    $0xff,%eax
 69d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6a4:	75 2c                	jne    6d2 <printf+0x6a>
      if(c == '%'){
 6a6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6aa:	75 0c                	jne    6b8 <printf+0x50>
        state = '%';
 6ac:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6b3:	e9 4a 01 00 00       	jmp    802 <printf+0x19a>
      } else {
        putc(fd, c);
 6b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6bb:	0f be c0             	movsbl %al,%eax
 6be:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c2:	8b 45 08             	mov    0x8(%ebp),%eax
 6c5:	89 04 24             	mov    %eax,(%esp)
 6c8:	e8 bb fe ff ff       	call   588 <putc>
 6cd:	e9 30 01 00 00       	jmp    802 <printf+0x19a>
      }
    } else if(state == '%'){
 6d2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6d6:	0f 85 26 01 00 00    	jne    802 <printf+0x19a>
      if(c == 'd'){
 6dc:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6e0:	75 2d                	jne    70f <printf+0xa7>
        printint(fd, *ap, 10, 1);
 6e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e5:	8b 00                	mov    (%eax),%eax
 6e7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6ee:	00 
 6ef:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6f6:	00 
 6f7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6fb:	8b 45 08             	mov    0x8(%ebp),%eax
 6fe:	89 04 24             	mov    %eax,(%esp)
 701:	e8 aa fe ff ff       	call   5b0 <printint>
        ap++;
 706:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70a:	e9 ec 00 00 00       	jmp    7fb <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 70f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 713:	74 06                	je     71b <printf+0xb3>
 715:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 719:	75 2d                	jne    748 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 71b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 71e:	8b 00                	mov    (%eax),%eax
 720:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 727:	00 
 728:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 72f:	00 
 730:	89 44 24 04          	mov    %eax,0x4(%esp)
 734:	8b 45 08             	mov    0x8(%ebp),%eax
 737:	89 04 24             	mov    %eax,(%esp)
 73a:	e8 71 fe ff ff       	call   5b0 <printint>
        ap++;
 73f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 743:	e9 b3 00 00 00       	jmp    7fb <printf+0x193>
      } else if(c == 's'){
 748:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 74c:	75 45                	jne    793 <printf+0x12b>
        s = (char*)*ap;
 74e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 751:	8b 00                	mov    (%eax),%eax
 753:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 756:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 75a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 75e:	75 09                	jne    769 <printf+0x101>
          s = "(null)";
 760:	c7 45 f4 b3 0a 00 00 	movl   $0xab3,-0xc(%ebp)
        while(*s != 0){
 767:	eb 1e                	jmp    787 <printf+0x11f>
 769:	eb 1c                	jmp    787 <printf+0x11f>
          putc(fd, *s);
 76b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76e:	0f b6 00             	movzbl (%eax),%eax
 771:	0f be c0             	movsbl %al,%eax
 774:	89 44 24 04          	mov    %eax,0x4(%esp)
 778:	8b 45 08             	mov    0x8(%ebp),%eax
 77b:	89 04 24             	mov    %eax,(%esp)
 77e:	e8 05 fe ff ff       	call   588 <putc>
          s++;
 783:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 787:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78a:	0f b6 00             	movzbl (%eax),%eax
 78d:	84 c0                	test   %al,%al
 78f:	75 da                	jne    76b <printf+0x103>
 791:	eb 68                	jmp    7fb <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 793:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 797:	75 1d                	jne    7b6 <printf+0x14e>
        putc(fd, *ap);
 799:	8b 45 e8             	mov    -0x18(%ebp),%eax
 79c:	8b 00                	mov    (%eax),%eax
 79e:	0f be c0             	movsbl %al,%eax
 7a1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a5:	8b 45 08             	mov    0x8(%ebp),%eax
 7a8:	89 04 24             	mov    %eax,(%esp)
 7ab:	e8 d8 fd ff ff       	call   588 <putc>
        ap++;
 7b0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b4:	eb 45                	jmp    7fb <printf+0x193>
      } else if(c == '%'){
 7b6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ba:	75 17                	jne    7d3 <printf+0x16b>
        putc(fd, c);
 7bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7bf:	0f be c0             	movsbl %al,%eax
 7c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c6:	8b 45 08             	mov    0x8(%ebp),%eax
 7c9:	89 04 24             	mov    %eax,(%esp)
 7cc:	e8 b7 fd ff ff       	call   588 <putc>
 7d1:	eb 28                	jmp    7fb <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7d3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7da:	00 
 7db:	8b 45 08             	mov    0x8(%ebp),%eax
 7de:	89 04 24             	mov    %eax,(%esp)
 7e1:	e8 a2 fd ff ff       	call   588 <putc>
        putc(fd, c);
 7e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7e9:	0f be c0             	movsbl %al,%eax
 7ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f0:	8b 45 08             	mov    0x8(%ebp),%eax
 7f3:	89 04 24             	mov    %eax,(%esp)
 7f6:	e8 8d fd ff ff       	call   588 <putc>
      }
      state = 0;
 7fb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 802:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 806:	8b 55 0c             	mov    0xc(%ebp),%edx
 809:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80c:	01 d0                	add    %edx,%eax
 80e:	0f b6 00             	movzbl (%eax),%eax
 811:	84 c0                	test   %al,%al
 813:	0f 85 71 fe ff ff    	jne    68a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 819:	c9                   	leave  
 81a:	c3                   	ret    

0000081b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81b:	55                   	push   %ebp
 81c:	89 e5                	mov    %esp,%ebp
 81e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 821:	8b 45 08             	mov    0x8(%ebp),%eax
 824:	83 e8 08             	sub    $0x8,%eax
 827:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82a:	a1 68 0d 00 00       	mov    0xd68,%eax
 82f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 832:	eb 24                	jmp    858 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 834:	8b 45 fc             	mov    -0x4(%ebp),%eax
 837:	8b 00                	mov    (%eax),%eax
 839:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83c:	77 12                	ja     850 <free+0x35>
 83e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 841:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 844:	77 24                	ja     86a <free+0x4f>
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 00                	mov    (%eax),%eax
 84b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 84e:	77 1a                	ja     86a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	8b 00                	mov    (%eax),%eax
 855:	89 45 fc             	mov    %eax,-0x4(%ebp)
 858:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 85e:	76 d4                	jbe    834 <free+0x19>
 860:	8b 45 fc             	mov    -0x4(%ebp),%eax
 863:	8b 00                	mov    (%eax),%eax
 865:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 868:	76 ca                	jbe    834 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 86a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86d:	8b 40 04             	mov    0x4(%eax),%eax
 870:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 877:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87a:	01 c2                	add    %eax,%edx
 87c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87f:	8b 00                	mov    (%eax),%eax
 881:	39 c2                	cmp    %eax,%edx
 883:	75 24                	jne    8a9 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 885:	8b 45 f8             	mov    -0x8(%ebp),%eax
 888:	8b 50 04             	mov    0x4(%eax),%edx
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	8b 00                	mov    (%eax),%eax
 890:	8b 40 04             	mov    0x4(%eax),%eax
 893:	01 c2                	add    %eax,%edx
 895:	8b 45 f8             	mov    -0x8(%ebp),%eax
 898:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 89b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89e:	8b 00                	mov    (%eax),%eax
 8a0:	8b 10                	mov    (%eax),%edx
 8a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a5:	89 10                	mov    %edx,(%eax)
 8a7:	eb 0a                	jmp    8b3 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ac:	8b 10                	mov    (%eax),%edx
 8ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b1:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b6:	8b 40 04             	mov    0x4(%eax),%eax
 8b9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c3:	01 d0                	add    %edx,%eax
 8c5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8c8:	75 20                	jne    8ea <free+0xcf>
    p->s.size += bp->s.size;
 8ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cd:	8b 50 04             	mov    0x4(%eax),%edx
 8d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d3:	8b 40 04             	mov    0x4(%eax),%eax
 8d6:	01 c2                	add    %eax,%edx
 8d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8db:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e1:	8b 10                	mov    (%eax),%edx
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	89 10                	mov    %edx,(%eax)
 8e8:	eb 08                	jmp    8f2 <free+0xd7>
  } else
    p->s.ptr = bp;
 8ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ed:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8f0:	89 10                	mov    %edx,(%eax)
  freep = p;
 8f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f5:	a3 68 0d 00 00       	mov    %eax,0xd68
}
 8fa:	c9                   	leave  
 8fb:	c3                   	ret    

000008fc <morecore>:

static Header*
morecore(uint nu)
{
 8fc:	55                   	push   %ebp
 8fd:	89 e5                	mov    %esp,%ebp
 8ff:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 902:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 909:	77 07                	ja     912 <morecore+0x16>
    nu = 4096;
 90b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 912:	8b 45 08             	mov    0x8(%ebp),%eax
 915:	c1 e0 03             	shl    $0x3,%eax
 918:	89 04 24             	mov    %eax,(%esp)
 91b:	e8 30 fc ff ff       	call   550 <sbrk>
 920:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 923:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 927:	75 07                	jne    930 <morecore+0x34>
    return 0;
 929:	b8 00 00 00 00       	mov    $0x0,%eax
 92e:	eb 22                	jmp    952 <morecore+0x56>
  hp = (Header*)p;
 930:	8b 45 f4             	mov    -0xc(%ebp),%eax
 933:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 936:	8b 45 f0             	mov    -0x10(%ebp),%eax
 939:	8b 55 08             	mov    0x8(%ebp),%edx
 93c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 93f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 942:	83 c0 08             	add    $0x8,%eax
 945:	89 04 24             	mov    %eax,(%esp)
 948:	e8 ce fe ff ff       	call   81b <free>
  return freep;
 94d:	a1 68 0d 00 00       	mov    0xd68,%eax
}
 952:	c9                   	leave  
 953:	c3                   	ret    

00000954 <malloc>:

void*
malloc(uint nbytes)
{
 954:	55                   	push   %ebp
 955:	89 e5                	mov    %esp,%ebp
 957:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95a:	8b 45 08             	mov    0x8(%ebp),%eax
 95d:	83 c0 07             	add    $0x7,%eax
 960:	c1 e8 03             	shr    $0x3,%eax
 963:	83 c0 01             	add    $0x1,%eax
 966:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 969:	a1 68 0d 00 00       	mov    0xd68,%eax
 96e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 971:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 975:	75 23                	jne    99a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 977:	c7 45 f0 60 0d 00 00 	movl   $0xd60,-0x10(%ebp)
 97e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 981:	a3 68 0d 00 00       	mov    %eax,0xd68
 986:	a1 68 0d 00 00       	mov    0xd68,%eax
 98b:	a3 60 0d 00 00       	mov    %eax,0xd60
    base.s.size = 0;
 990:	c7 05 64 0d 00 00 00 	movl   $0x0,0xd64
 997:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99d:	8b 00                	mov    (%eax),%eax
 99f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a5:	8b 40 04             	mov    0x4(%eax),%eax
 9a8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ab:	72 4d                	jb     9fa <malloc+0xa6>
      if(p->s.size == nunits)
 9ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b0:	8b 40 04             	mov    0x4(%eax),%eax
 9b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9b6:	75 0c                	jne    9c4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bb:	8b 10                	mov    (%eax),%edx
 9bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c0:	89 10                	mov    %edx,(%eax)
 9c2:	eb 26                	jmp    9ea <malloc+0x96>
      else {
        p->s.size -= nunits;
 9c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c7:	8b 40 04             	mov    0x4(%eax),%eax
 9ca:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9cd:	89 c2                	mov    %eax,%edx
 9cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d8:	8b 40 04             	mov    0x4(%eax),%eax
 9db:	c1 e0 03             	shl    $0x3,%eax
 9de:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9e7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ed:	a3 68 0d 00 00       	mov    %eax,0xd68
      return (void*)(p + 1);
 9f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f5:	83 c0 08             	add    $0x8,%eax
 9f8:	eb 38                	jmp    a32 <malloc+0xde>
    }
    if(p == freep)
 9fa:	a1 68 0d 00 00       	mov    0xd68,%eax
 9ff:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a02:	75 1b                	jne    a1f <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a04:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a07:	89 04 24             	mov    %eax,(%esp)
 a0a:	e8 ed fe ff ff       	call   8fc <morecore>
 a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a16:	75 07                	jne    a1f <malloc+0xcb>
        return 0;
 a18:	b8 00 00 00 00       	mov    $0x0,%eax
 a1d:	eb 13                	jmp    a32 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a28:	8b 00                	mov    (%eax),%eax
 a2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a2d:	e9 70 ff ff ff       	jmp    9a2 <malloc+0x4e>
}
 a32:	c9                   	leave  
 a33:	c3                   	ret    
