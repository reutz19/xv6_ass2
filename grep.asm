
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n, m;
  char *p, *q;
  
  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
   d:	e9 bb 00 00 00       	jmp    cd <grep+0xcd>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    p = buf;
  18:	c7 45 f0 80 0e 00 00 	movl   $0xe80,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  1f:	eb 51                	jmp    72 <grep+0x72>
      *q = 0;
  21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  24:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  2e:	8b 45 08             	mov    0x8(%ebp),%eax
  31:	89 04 24             	mov    %eax,(%esp)
  34:	e8 bc 01 00 00       	call   1f5 <match>
  39:	85 c0                	test   %eax,%eax
  3b:	74 2c                	je     69 <grep+0x69>
        *q = '\n';
  3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  40:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  46:	83 c0 01             	add    $0x1,%eax
  49:	89 c2                	mov    %eax,%edx
  4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  4e:	29 c2                	sub    %eax,%edx
  50:	89 d0                	mov    %edx,%eax
  52:	89 44 24 08          	mov    %eax,0x8(%esp)
  56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  59:	89 44 24 04          	mov    %eax,0x4(%esp)
  5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  64:	e8 74 05 00 00       	call   5dd <write>
      }
      p = q+1;
  69:	8b 45 e8             	mov    -0x18(%ebp),%eax
  6c:	83 c0 01             	add    $0x1,%eax
  6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
    m += n;
    p = buf;
    while((q = strchr(p, '\n')) != 0){
  72:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  79:	00 
  7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  7d:	89 04 24             	mov    %eax,(%esp)
  80:	e8 af 03 00 00       	call   434 <strchr>
  85:	89 45 e8             	mov    %eax,-0x18(%ebp)
  88:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8c:	75 93                	jne    21 <grep+0x21>
        *q = '\n';
        write(1, p, q+1 - p);
      }
      p = q+1;
    }
    if(p == buf)
  8e:	81 7d f0 80 0e 00 00 	cmpl   $0xe80,-0x10(%ebp)
  95:	75 07                	jne    9e <grep+0x9e>
      m = 0;
  97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a2:	7e 29                	jle    cd <grep+0xcd>
      m -= p - buf;
  a4:	ba 80 0e 00 00       	mov    $0xe80,%edx
  a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ac:	29 c2                	sub    %eax,%edx
  ae:	89 d0                	mov    %edx,%eax
  b0:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  c1:	c7 04 24 80 0e 00 00 	movl   $0xe80,(%esp)
  c8:	e8 ab 04 00 00       	call   578 <memmove>
{
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
  cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d0:	ba 00 04 00 00       	mov    $0x400,%edx
  d5:	29 c2                	sub    %eax,%edx
  d7:	89 d0                	mov    %edx,%eax
  d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  dc:	81 c2 80 0e 00 00    	add    $0xe80,%edx
  e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  ed:	89 04 24             	mov    %eax,(%esp)
  f0:	e8 e0 04 00 00       	call   5d5 <read>
  f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  fc:	0f 8f 10 ff ff ff    	jg     12 <grep+0x12>
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
}
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <main>:

int
main(int argc, char *argv[])
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	83 e4 f0             	and    $0xfffffff0,%esp
 10a:	83 ec 20             	sub    $0x20,%esp
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 10d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 111:	7f 19                	jg     12c <main+0x28>
    printf(2, "usage: grep pattern [file ...]\n");
 113:	c7 44 24 04 2c 0b 00 	movl   $0xb2c,0x4(%esp)
 11a:	00 
 11b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 122:	e8 36 06 00 00       	call   75d <printf>
    exit();
 127:	e8 91 04 00 00       	call   5bd <exit>
  }
  pattern = argv[1];
 12c:	8b 45 0c             	mov    0xc(%ebp),%eax
 12f:	8b 40 04             	mov    0x4(%eax),%eax
 132:	89 44 24 18          	mov    %eax,0x18(%esp)
  
  if(argc <= 2){
 136:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 13a:	7f 19                	jg     155 <main+0x51>
    grep(pattern, 0);
 13c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 143:	00 
 144:	8b 44 24 18          	mov    0x18(%esp),%eax
 148:	89 04 24             	mov    %eax,(%esp)
 14b:	e8 b0 fe ff ff       	call   0 <grep>
    exit();
 150:	e8 68 04 00 00       	call   5bd <exit>
  }

  for(i = 2; i < argc; i++){
 155:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
 15c:	00 
 15d:	e9 81 00 00 00       	jmp    1e3 <main+0xdf>
    if((fd = open(argv[i], 0)) < 0){
 162:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 166:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 16d:	8b 45 0c             	mov    0xc(%ebp),%eax
 170:	01 d0                	add    %edx,%eax
 172:	8b 00                	mov    (%eax),%eax
 174:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 17b:	00 
 17c:	89 04 24             	mov    %eax,(%esp)
 17f:	e8 79 04 00 00       	call   5fd <open>
 184:	89 44 24 14          	mov    %eax,0x14(%esp)
 188:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 18d:	79 2f                	jns    1be <main+0xba>
      printf(1, "grep: cannot open %s\n", argv[i]);
 18f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 193:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 19a:	8b 45 0c             	mov    0xc(%ebp),%eax
 19d:	01 d0                	add    %edx,%eax
 19f:	8b 00                	mov    (%eax),%eax
 1a1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1a5:	c7 44 24 04 4c 0b 00 	movl   $0xb4c,0x4(%esp)
 1ac:	00 
 1ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b4:	e8 a4 05 00 00       	call   75d <printf>
      exit();
 1b9:	e8 ff 03 00 00       	call   5bd <exit>
    }
    grep(pattern, fd);
 1be:	8b 44 24 14          	mov    0x14(%esp),%eax
 1c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c6:	8b 44 24 18          	mov    0x18(%esp),%eax
 1ca:	89 04 24             	mov    %eax,(%esp)
 1cd:	e8 2e fe ff ff       	call   0 <grep>
    close(fd);
 1d2:	8b 44 24 14          	mov    0x14(%esp),%eax
 1d6:	89 04 24             	mov    %eax,(%esp)
 1d9:	e8 07 04 00 00       	call   5e5 <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 1de:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1e3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1e7:	3b 45 08             	cmp    0x8(%ebp),%eax
 1ea:	0f 8c 72 ff ff ff    	jl     162 <main+0x5e>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 1f0:	e8 c8 03 00 00       	call   5bd <exit>

000001f5 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 1f5:	55                   	push   %ebp
 1f6:	89 e5                	mov    %esp,%ebp
 1f8:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '^')
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	0f b6 00             	movzbl (%eax),%eax
 201:	3c 5e                	cmp    $0x5e,%al
 203:	75 17                	jne    21c <match+0x27>
    return matchhere(re+1, text);
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	8d 50 01             	lea    0x1(%eax),%edx
 20b:	8b 45 0c             	mov    0xc(%ebp),%eax
 20e:	89 44 24 04          	mov    %eax,0x4(%esp)
 212:	89 14 24             	mov    %edx,(%esp)
 215:	e8 36 00 00 00       	call   250 <matchhere>
 21a:	eb 32                	jmp    24e <match+0x59>
  do{  // must look at empty string
    if(matchhere(re, text))
 21c:	8b 45 0c             	mov    0xc(%ebp),%eax
 21f:	89 44 24 04          	mov    %eax,0x4(%esp)
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	89 04 24             	mov    %eax,(%esp)
 229:	e8 22 00 00 00       	call   250 <matchhere>
 22e:	85 c0                	test   %eax,%eax
 230:	74 07                	je     239 <match+0x44>
      return 1;
 232:	b8 01 00 00 00       	mov    $0x1,%eax
 237:	eb 15                	jmp    24e <match+0x59>
  }while(*text++ != '\0');
 239:	8b 45 0c             	mov    0xc(%ebp),%eax
 23c:	8d 50 01             	lea    0x1(%eax),%edx
 23f:	89 55 0c             	mov    %edx,0xc(%ebp)
 242:	0f b6 00             	movzbl (%eax),%eax
 245:	84 c0                	test   %al,%al
 247:	75 d3                	jne    21c <match+0x27>
  return 0;
 249:	b8 00 00 00 00       	mov    $0x0,%eax
}
 24e:	c9                   	leave  
 24f:	c3                   	ret    

00000250 <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 250:	55                   	push   %ebp
 251:	89 e5                	mov    %esp,%ebp
 253:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '\0')
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	0f b6 00             	movzbl (%eax),%eax
 25c:	84 c0                	test   %al,%al
 25e:	75 0a                	jne    26a <matchhere+0x1a>
    return 1;
 260:	b8 01 00 00 00       	mov    $0x1,%eax
 265:	e9 9b 00 00 00       	jmp    305 <matchhere+0xb5>
  if(re[1] == '*')
 26a:	8b 45 08             	mov    0x8(%ebp),%eax
 26d:	83 c0 01             	add    $0x1,%eax
 270:	0f b6 00             	movzbl (%eax),%eax
 273:	3c 2a                	cmp    $0x2a,%al
 275:	75 24                	jne    29b <matchhere+0x4b>
    return matchstar(re[0], re+2, text);
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	8d 48 02             	lea    0x2(%eax),%ecx
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	0f b6 00             	movzbl (%eax),%eax
 283:	0f be c0             	movsbl %al,%eax
 286:	8b 55 0c             	mov    0xc(%ebp),%edx
 289:	89 54 24 08          	mov    %edx,0x8(%esp)
 28d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 291:	89 04 24             	mov    %eax,(%esp)
 294:	e8 6e 00 00 00       	call   307 <matchstar>
 299:	eb 6a                	jmp    305 <matchhere+0xb5>
  if(re[0] == '$' && re[1] == '\0')
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	0f b6 00             	movzbl (%eax),%eax
 2a1:	3c 24                	cmp    $0x24,%al
 2a3:	75 1d                	jne    2c2 <matchhere+0x72>
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	83 c0 01             	add    $0x1,%eax
 2ab:	0f b6 00             	movzbl (%eax),%eax
 2ae:	84 c0                	test   %al,%al
 2b0:	75 10                	jne    2c2 <matchhere+0x72>
    return *text == '\0';
 2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b5:	0f b6 00             	movzbl (%eax),%eax
 2b8:	84 c0                	test   %al,%al
 2ba:	0f 94 c0             	sete   %al
 2bd:	0f b6 c0             	movzbl %al,%eax
 2c0:	eb 43                	jmp    305 <matchhere+0xb5>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c5:	0f b6 00             	movzbl (%eax),%eax
 2c8:	84 c0                	test   %al,%al
 2ca:	74 34                	je     300 <matchhere+0xb0>
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	0f b6 00             	movzbl (%eax),%eax
 2d2:	3c 2e                	cmp    $0x2e,%al
 2d4:	74 10                	je     2e6 <matchhere+0x96>
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	0f b6 10             	movzbl (%eax),%edx
 2dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2df:	0f b6 00             	movzbl (%eax),%eax
 2e2:	38 c2                	cmp    %al,%dl
 2e4:	75 1a                	jne    300 <matchhere+0xb0>
    return matchhere(re+1, text+1);
 2e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e9:	8d 50 01             	lea    0x1(%eax),%edx
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
 2ef:	83 c0 01             	add    $0x1,%eax
 2f2:	89 54 24 04          	mov    %edx,0x4(%esp)
 2f6:	89 04 24             	mov    %eax,(%esp)
 2f9:	e8 52 ff ff ff       	call   250 <matchhere>
 2fe:	eb 05                	jmp    305 <matchhere+0xb5>
  return 0;
 300:	b8 00 00 00 00       	mov    $0x0,%eax
}
 305:	c9                   	leave  
 306:	c3                   	ret    

00000307 <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 307:	55                   	push   %ebp
 308:	89 e5                	mov    %esp,%ebp
 30a:	83 ec 18             	sub    $0x18,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 30d:	8b 45 10             	mov    0x10(%ebp),%eax
 310:	89 44 24 04          	mov    %eax,0x4(%esp)
 314:	8b 45 0c             	mov    0xc(%ebp),%eax
 317:	89 04 24             	mov    %eax,(%esp)
 31a:	e8 31 ff ff ff       	call   250 <matchhere>
 31f:	85 c0                	test   %eax,%eax
 321:	74 07                	je     32a <matchstar+0x23>
      return 1;
 323:	b8 01 00 00 00       	mov    $0x1,%eax
 328:	eb 29                	jmp    353 <matchstar+0x4c>
  }while(*text!='\0' && (*text++==c || c=='.'));
 32a:	8b 45 10             	mov    0x10(%ebp),%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	84 c0                	test   %al,%al
 332:	74 1a                	je     34e <matchstar+0x47>
 334:	8b 45 10             	mov    0x10(%ebp),%eax
 337:	8d 50 01             	lea    0x1(%eax),%edx
 33a:	89 55 10             	mov    %edx,0x10(%ebp)
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	0f be c0             	movsbl %al,%eax
 343:	3b 45 08             	cmp    0x8(%ebp),%eax
 346:	74 c5                	je     30d <matchstar+0x6>
 348:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 34c:	74 bf                	je     30d <matchstar+0x6>
  return 0;
 34e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 353:	c9                   	leave  
 354:	c3                   	ret    

00000355 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 355:	55                   	push   %ebp
 356:	89 e5                	mov    %esp,%ebp
 358:	57                   	push   %edi
 359:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 35a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 35d:	8b 55 10             	mov    0x10(%ebp),%edx
 360:	8b 45 0c             	mov    0xc(%ebp),%eax
 363:	89 cb                	mov    %ecx,%ebx
 365:	89 df                	mov    %ebx,%edi
 367:	89 d1                	mov    %edx,%ecx
 369:	fc                   	cld    
 36a:	f3 aa                	rep stos %al,%es:(%edi)
 36c:	89 ca                	mov    %ecx,%edx
 36e:	89 fb                	mov    %edi,%ebx
 370:	89 5d 08             	mov    %ebx,0x8(%ebp)
 373:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 376:	5b                   	pop    %ebx
 377:	5f                   	pop    %edi
 378:	5d                   	pop    %ebp
 379:	c3                   	ret    

0000037a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 37a:	55                   	push   %ebp
 37b:	89 e5                	mov    %esp,%ebp
 37d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 380:	8b 45 08             	mov    0x8(%ebp),%eax
 383:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 386:	90                   	nop
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	8d 50 01             	lea    0x1(%eax),%edx
 38d:	89 55 08             	mov    %edx,0x8(%ebp)
 390:	8b 55 0c             	mov    0xc(%ebp),%edx
 393:	8d 4a 01             	lea    0x1(%edx),%ecx
 396:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 399:	0f b6 12             	movzbl (%edx),%edx
 39c:	88 10                	mov    %dl,(%eax)
 39e:	0f b6 00             	movzbl (%eax),%eax
 3a1:	84 c0                	test   %al,%al
 3a3:	75 e2                	jne    387 <strcpy+0xd>
    ;
  return os;
 3a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a8:	c9                   	leave  
 3a9:	c3                   	ret    

000003aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3aa:	55                   	push   %ebp
 3ab:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3ad:	eb 08                	jmp    3b7 <strcmp+0xd>
    p++, q++;
 3af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3b7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ba:	0f b6 00             	movzbl (%eax),%eax
 3bd:	84 c0                	test   %al,%al
 3bf:	74 10                	je     3d1 <strcmp+0x27>
 3c1:	8b 45 08             	mov    0x8(%ebp),%eax
 3c4:	0f b6 10             	movzbl (%eax),%edx
 3c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ca:	0f b6 00             	movzbl (%eax),%eax
 3cd:	38 c2                	cmp    %al,%dl
 3cf:	74 de                	je     3af <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	0f b6 d0             	movzbl %al,%edx
 3da:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dd:	0f b6 00             	movzbl (%eax),%eax
 3e0:	0f b6 c0             	movzbl %al,%eax
 3e3:	29 c2                	sub    %eax,%edx
 3e5:	89 d0                	mov    %edx,%eax
}
 3e7:	5d                   	pop    %ebp
 3e8:	c3                   	ret    

000003e9 <strlen>:

uint
strlen(char *s)
{
 3e9:	55                   	push   %ebp
 3ea:	89 e5                	mov    %esp,%ebp
 3ec:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3ef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3f6:	eb 04                	jmp    3fc <strlen+0x13>
 3f8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3ff:	8b 45 08             	mov    0x8(%ebp),%eax
 402:	01 d0                	add    %edx,%eax
 404:	0f b6 00             	movzbl (%eax),%eax
 407:	84 c0                	test   %al,%al
 409:	75 ed                	jne    3f8 <strlen+0xf>
    ;
  return n;
 40b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 40e:	c9                   	leave  
 40f:	c3                   	ret    

00000410 <memset>:

void*
memset(void *dst, int c, uint n)
{
 410:	55                   	push   %ebp
 411:	89 e5                	mov    %esp,%ebp
 413:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 416:	8b 45 10             	mov    0x10(%ebp),%eax
 419:	89 44 24 08          	mov    %eax,0x8(%esp)
 41d:	8b 45 0c             	mov    0xc(%ebp),%eax
 420:	89 44 24 04          	mov    %eax,0x4(%esp)
 424:	8b 45 08             	mov    0x8(%ebp),%eax
 427:	89 04 24             	mov    %eax,(%esp)
 42a:	e8 26 ff ff ff       	call   355 <stosb>
  return dst;
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 432:	c9                   	leave  
 433:	c3                   	ret    

00000434 <strchr>:

char*
strchr(const char *s, char c)
{
 434:	55                   	push   %ebp
 435:	89 e5                	mov    %esp,%ebp
 437:	83 ec 04             	sub    $0x4,%esp
 43a:	8b 45 0c             	mov    0xc(%ebp),%eax
 43d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 440:	eb 14                	jmp    456 <strchr+0x22>
    if(*s == c)
 442:	8b 45 08             	mov    0x8(%ebp),%eax
 445:	0f b6 00             	movzbl (%eax),%eax
 448:	3a 45 fc             	cmp    -0x4(%ebp),%al
 44b:	75 05                	jne    452 <strchr+0x1e>
      return (char*)s;
 44d:	8b 45 08             	mov    0x8(%ebp),%eax
 450:	eb 13                	jmp    465 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 452:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	0f b6 00             	movzbl (%eax),%eax
 45c:	84 c0                	test   %al,%al
 45e:	75 e2                	jne    442 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 460:	b8 00 00 00 00       	mov    $0x0,%eax
}
 465:	c9                   	leave  
 466:	c3                   	ret    

00000467 <gets>:

char*
gets(char *buf, int max)
{
 467:	55                   	push   %ebp
 468:	89 e5                	mov    %esp,%ebp
 46a:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 46d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 474:	eb 4c                	jmp    4c2 <gets+0x5b>
    cc = read(0, &c, 1);
 476:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 47d:	00 
 47e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 481:	89 44 24 04          	mov    %eax,0x4(%esp)
 485:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 48c:	e8 44 01 00 00       	call   5d5 <read>
 491:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 494:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 498:	7f 02                	jg     49c <gets+0x35>
      break;
 49a:	eb 31                	jmp    4cd <gets+0x66>
    buf[i++] = c;
 49c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49f:	8d 50 01             	lea    0x1(%eax),%edx
 4a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4a5:	89 c2                	mov    %eax,%edx
 4a7:	8b 45 08             	mov    0x8(%ebp),%eax
 4aa:	01 c2                	add    %eax,%edx
 4ac:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4b2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b6:	3c 0a                	cmp    $0xa,%al
 4b8:	74 13                	je     4cd <gets+0x66>
 4ba:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4be:	3c 0d                	cmp    $0xd,%al
 4c0:	74 0b                	je     4cd <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c5:	83 c0 01             	add    $0x1,%eax
 4c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4cb:	7c a9                	jl     476 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
 4d3:	01 d0                	add    %edx,%eax
 4d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4db:	c9                   	leave  
 4dc:	c3                   	ret    

000004dd <stat>:

int
stat(char *n, struct stat *st)
{
 4dd:	55                   	push   %ebp
 4de:	89 e5                	mov    %esp,%ebp
 4e0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4ea:	00 
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	89 04 24             	mov    %eax,(%esp)
 4f1:	e8 07 01 00 00       	call   5fd <open>
 4f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4fd:	79 07                	jns    506 <stat+0x29>
    return -1;
 4ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 504:	eb 23                	jmp    529 <stat+0x4c>
  r = fstat(fd, st);
 506:	8b 45 0c             	mov    0xc(%ebp),%eax
 509:	89 44 24 04          	mov    %eax,0x4(%esp)
 50d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 510:	89 04 24             	mov    %eax,(%esp)
 513:	e8 fd 00 00 00       	call   615 <fstat>
 518:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 51b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51e:	89 04 24             	mov    %eax,(%esp)
 521:	e8 bf 00 00 00       	call   5e5 <close>
  return r;
 526:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 529:	c9                   	leave  
 52a:	c3                   	ret    

0000052b <atoi>:

int
atoi(const char *s)
{
 52b:	55                   	push   %ebp
 52c:	89 e5                	mov    %esp,%ebp
 52e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 531:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 538:	eb 25                	jmp    55f <atoi+0x34>
    n = n*10 + *s++ - '0';
 53a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 53d:	89 d0                	mov    %edx,%eax
 53f:	c1 e0 02             	shl    $0x2,%eax
 542:	01 d0                	add    %edx,%eax
 544:	01 c0                	add    %eax,%eax
 546:	89 c1                	mov    %eax,%ecx
 548:	8b 45 08             	mov    0x8(%ebp),%eax
 54b:	8d 50 01             	lea    0x1(%eax),%edx
 54e:	89 55 08             	mov    %edx,0x8(%ebp)
 551:	0f b6 00             	movzbl (%eax),%eax
 554:	0f be c0             	movsbl %al,%eax
 557:	01 c8                	add    %ecx,%eax
 559:	83 e8 30             	sub    $0x30,%eax
 55c:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 55f:	8b 45 08             	mov    0x8(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	3c 2f                	cmp    $0x2f,%al
 567:	7e 0a                	jle    573 <atoi+0x48>
 569:	8b 45 08             	mov    0x8(%ebp),%eax
 56c:	0f b6 00             	movzbl (%eax),%eax
 56f:	3c 39                	cmp    $0x39,%al
 571:	7e c7                	jle    53a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 573:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 576:	c9                   	leave  
 577:	c3                   	ret    

00000578 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 578:	55                   	push   %ebp
 579:	89 e5                	mov    %esp,%ebp
 57b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 57e:	8b 45 08             	mov    0x8(%ebp),%eax
 581:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 584:	8b 45 0c             	mov    0xc(%ebp),%eax
 587:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 58a:	eb 17                	jmp    5a3 <memmove+0x2b>
    *dst++ = *src++;
 58c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 58f:	8d 50 01             	lea    0x1(%eax),%edx
 592:	89 55 fc             	mov    %edx,-0x4(%ebp)
 595:	8b 55 f8             	mov    -0x8(%ebp),%edx
 598:	8d 4a 01             	lea    0x1(%edx),%ecx
 59b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 59e:	0f b6 12             	movzbl (%edx),%edx
 5a1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5a3:	8b 45 10             	mov    0x10(%ebp),%eax
 5a6:	8d 50 ff             	lea    -0x1(%eax),%edx
 5a9:	89 55 10             	mov    %edx,0x10(%ebp)
 5ac:	85 c0                	test   %eax,%eax
 5ae:	7f dc                	jg     58c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5b3:	c9                   	leave  
 5b4:	c3                   	ret    

000005b5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5b5:	b8 01 00 00 00       	mov    $0x1,%eax
 5ba:	cd 40                	int    $0x40
 5bc:	c3                   	ret    

000005bd <exit>:
SYSCALL(exit)
 5bd:	b8 02 00 00 00       	mov    $0x2,%eax
 5c2:	cd 40                	int    $0x40
 5c4:	c3                   	ret    

000005c5 <wait>:
SYSCALL(wait)
 5c5:	b8 03 00 00 00       	mov    $0x3,%eax
 5ca:	cd 40                	int    $0x40
 5cc:	c3                   	ret    

000005cd <pipe>:
SYSCALL(pipe)
 5cd:	b8 04 00 00 00       	mov    $0x4,%eax
 5d2:	cd 40                	int    $0x40
 5d4:	c3                   	ret    

000005d5 <read>:
SYSCALL(read)
 5d5:	b8 05 00 00 00       	mov    $0x5,%eax
 5da:	cd 40                	int    $0x40
 5dc:	c3                   	ret    

000005dd <write>:
SYSCALL(write)
 5dd:	b8 10 00 00 00       	mov    $0x10,%eax
 5e2:	cd 40                	int    $0x40
 5e4:	c3                   	ret    

000005e5 <close>:
SYSCALL(close)
 5e5:	b8 15 00 00 00       	mov    $0x15,%eax
 5ea:	cd 40                	int    $0x40
 5ec:	c3                   	ret    

000005ed <kill>:
SYSCALL(kill)
 5ed:	b8 06 00 00 00       	mov    $0x6,%eax
 5f2:	cd 40                	int    $0x40
 5f4:	c3                   	ret    

000005f5 <exec>:
SYSCALL(exec)
 5f5:	b8 07 00 00 00       	mov    $0x7,%eax
 5fa:	cd 40                	int    $0x40
 5fc:	c3                   	ret    

000005fd <open>:
SYSCALL(open)
 5fd:	b8 0f 00 00 00       	mov    $0xf,%eax
 602:	cd 40                	int    $0x40
 604:	c3                   	ret    

00000605 <mknod>:
SYSCALL(mknod)
 605:	b8 11 00 00 00       	mov    $0x11,%eax
 60a:	cd 40                	int    $0x40
 60c:	c3                   	ret    

0000060d <unlink>:
SYSCALL(unlink)
 60d:	b8 12 00 00 00       	mov    $0x12,%eax
 612:	cd 40                	int    $0x40
 614:	c3                   	ret    

00000615 <fstat>:
SYSCALL(fstat)
 615:	b8 08 00 00 00       	mov    $0x8,%eax
 61a:	cd 40                	int    $0x40
 61c:	c3                   	ret    

0000061d <link>:
SYSCALL(link)
 61d:	b8 13 00 00 00       	mov    $0x13,%eax
 622:	cd 40                	int    $0x40
 624:	c3                   	ret    

00000625 <mkdir>:
SYSCALL(mkdir)
 625:	b8 14 00 00 00       	mov    $0x14,%eax
 62a:	cd 40                	int    $0x40
 62c:	c3                   	ret    

0000062d <chdir>:
SYSCALL(chdir)
 62d:	b8 09 00 00 00       	mov    $0x9,%eax
 632:	cd 40                	int    $0x40
 634:	c3                   	ret    

00000635 <dup>:
SYSCALL(dup)
 635:	b8 0a 00 00 00       	mov    $0xa,%eax
 63a:	cd 40                	int    $0x40
 63c:	c3                   	ret    

0000063d <getpid>:
SYSCALL(getpid)
 63d:	b8 0b 00 00 00       	mov    $0xb,%eax
 642:	cd 40                	int    $0x40
 644:	c3                   	ret    

00000645 <sbrk>:
SYSCALL(sbrk)
 645:	b8 0c 00 00 00       	mov    $0xc,%eax
 64a:	cd 40                	int    $0x40
 64c:	c3                   	ret    

0000064d <sleep>:
SYSCALL(sleep)
 64d:	b8 0d 00 00 00       	mov    $0xd,%eax
 652:	cd 40                	int    $0x40
 654:	c3                   	ret    

00000655 <uptime>:
SYSCALL(uptime)
 655:	b8 0e 00 00 00       	mov    $0xe,%eax
 65a:	cd 40                	int    $0x40
 65c:	c3                   	ret    

0000065d <sigset>:
SYSCALL(sigset)
 65d:	b8 16 00 00 00       	mov    $0x16,%eax
 662:	cd 40                	int    $0x40
 664:	c3                   	ret    

00000665 <sigsend>:
SYSCALL(sigsend)
 665:	b8 17 00 00 00       	mov    $0x17,%eax
 66a:	cd 40                	int    $0x40
 66c:	c3                   	ret    

0000066d <sigret>:
SYSCALL(sigret)
 66d:	b8 18 00 00 00       	mov    $0x18,%eax
 672:	cd 40                	int    $0x40
 674:	c3                   	ret    

00000675 <sigpause>:
 675:	b8 19 00 00 00       	mov    $0x19,%eax
 67a:	cd 40                	int    $0x40
 67c:	c3                   	ret    

0000067d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 67d:	55                   	push   %ebp
 67e:	89 e5                	mov    %esp,%ebp
 680:	83 ec 18             	sub    $0x18,%esp
 683:	8b 45 0c             	mov    0xc(%ebp),%eax
 686:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 689:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 690:	00 
 691:	8d 45 f4             	lea    -0xc(%ebp),%eax
 694:	89 44 24 04          	mov    %eax,0x4(%esp)
 698:	8b 45 08             	mov    0x8(%ebp),%eax
 69b:	89 04 24             	mov    %eax,(%esp)
 69e:	e8 3a ff ff ff       	call   5dd <write>
}
 6a3:	c9                   	leave  
 6a4:	c3                   	ret    

000006a5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6a5:	55                   	push   %ebp
 6a6:	89 e5                	mov    %esp,%ebp
 6a8:	56                   	push   %esi
 6a9:	53                   	push   %ebx
 6aa:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6ad:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6b4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6b8:	74 17                	je     6d1 <printint+0x2c>
 6ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6be:	79 11                	jns    6d1 <printint+0x2c>
    neg = 1;
 6c0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ca:	f7 d8                	neg    %eax
 6cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6cf:	eb 06                	jmp    6d7 <printint+0x32>
  } else {
    x = xx;
 6d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6de:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6e1:	8d 41 01             	lea    0x1(%ecx),%eax
 6e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6ed:	ba 00 00 00 00       	mov    $0x0,%edx
 6f2:	f7 f3                	div    %ebx
 6f4:	89 d0                	mov    %edx,%eax
 6f6:	0f b6 80 30 0e 00 00 	movzbl 0xe30(%eax),%eax
 6fd:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 701:	8b 75 10             	mov    0x10(%ebp),%esi
 704:	8b 45 ec             	mov    -0x14(%ebp),%eax
 707:	ba 00 00 00 00       	mov    $0x0,%edx
 70c:	f7 f6                	div    %esi
 70e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 711:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 715:	75 c7                	jne    6de <printint+0x39>
  if(neg)
 717:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 71b:	74 10                	je     72d <printint+0x88>
    buf[i++] = '-';
 71d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 720:	8d 50 01             	lea    0x1(%eax),%edx
 723:	89 55 f4             	mov    %edx,-0xc(%ebp)
 726:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 72b:	eb 1f                	jmp    74c <printint+0xa7>
 72d:	eb 1d                	jmp    74c <printint+0xa7>
    putc(fd, buf[i]);
 72f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 732:	8b 45 f4             	mov    -0xc(%ebp),%eax
 735:	01 d0                	add    %edx,%eax
 737:	0f b6 00             	movzbl (%eax),%eax
 73a:	0f be c0             	movsbl %al,%eax
 73d:	89 44 24 04          	mov    %eax,0x4(%esp)
 741:	8b 45 08             	mov    0x8(%ebp),%eax
 744:	89 04 24             	mov    %eax,(%esp)
 747:	e8 31 ff ff ff       	call   67d <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 74c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 750:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 754:	79 d9                	jns    72f <printint+0x8a>
    putc(fd, buf[i]);
}
 756:	83 c4 30             	add    $0x30,%esp
 759:	5b                   	pop    %ebx
 75a:	5e                   	pop    %esi
 75b:	5d                   	pop    %ebp
 75c:	c3                   	ret    

0000075d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 75d:	55                   	push   %ebp
 75e:	89 e5                	mov    %esp,%ebp
 760:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 763:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 76a:	8d 45 0c             	lea    0xc(%ebp),%eax
 76d:	83 c0 04             	add    $0x4,%eax
 770:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 773:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 77a:	e9 7c 01 00 00       	jmp    8fb <printf+0x19e>
    c = fmt[i] & 0xff;
 77f:	8b 55 0c             	mov    0xc(%ebp),%edx
 782:	8b 45 f0             	mov    -0x10(%ebp),%eax
 785:	01 d0                	add    %edx,%eax
 787:	0f b6 00             	movzbl (%eax),%eax
 78a:	0f be c0             	movsbl %al,%eax
 78d:	25 ff 00 00 00       	and    $0xff,%eax
 792:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 795:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 799:	75 2c                	jne    7c7 <printf+0x6a>
      if(c == '%'){
 79b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 79f:	75 0c                	jne    7ad <printf+0x50>
        state = '%';
 7a1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7a8:	e9 4a 01 00 00       	jmp    8f7 <printf+0x19a>
      } else {
        putc(fd, c);
 7ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b0:	0f be c0             	movsbl %al,%eax
 7b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ba:	89 04 24             	mov    %eax,(%esp)
 7bd:	e8 bb fe ff ff       	call   67d <putc>
 7c2:	e9 30 01 00 00       	jmp    8f7 <printf+0x19a>
      }
    } else if(state == '%'){
 7c7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7cb:	0f 85 26 01 00 00    	jne    8f7 <printf+0x19a>
      if(c == 'd'){
 7d1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7d5:	75 2d                	jne    804 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7da:	8b 00                	mov    (%eax),%eax
 7dc:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7e3:	00 
 7e4:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7eb:	00 
 7ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f0:	8b 45 08             	mov    0x8(%ebp),%eax
 7f3:	89 04 24             	mov    %eax,(%esp)
 7f6:	e8 aa fe ff ff       	call   6a5 <printint>
        ap++;
 7fb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ff:	e9 ec 00 00 00       	jmp    8f0 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 804:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 808:	74 06                	je     810 <printf+0xb3>
 80a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 80e:	75 2d                	jne    83d <printf+0xe0>
        printint(fd, *ap, 16, 0);
 810:	8b 45 e8             	mov    -0x18(%ebp),%eax
 813:	8b 00                	mov    (%eax),%eax
 815:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 81c:	00 
 81d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 824:	00 
 825:	89 44 24 04          	mov    %eax,0x4(%esp)
 829:	8b 45 08             	mov    0x8(%ebp),%eax
 82c:	89 04 24             	mov    %eax,(%esp)
 82f:	e8 71 fe ff ff       	call   6a5 <printint>
        ap++;
 834:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 838:	e9 b3 00 00 00       	jmp    8f0 <printf+0x193>
      } else if(c == 's'){
 83d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 841:	75 45                	jne    888 <printf+0x12b>
        s = (char*)*ap;
 843:	8b 45 e8             	mov    -0x18(%ebp),%eax
 846:	8b 00                	mov    (%eax),%eax
 848:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 84b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 84f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 853:	75 09                	jne    85e <printf+0x101>
          s = "(null)";
 855:	c7 45 f4 62 0b 00 00 	movl   $0xb62,-0xc(%ebp)
        while(*s != 0){
 85c:	eb 1e                	jmp    87c <printf+0x11f>
 85e:	eb 1c                	jmp    87c <printf+0x11f>
          putc(fd, *s);
 860:	8b 45 f4             	mov    -0xc(%ebp),%eax
 863:	0f b6 00             	movzbl (%eax),%eax
 866:	0f be c0             	movsbl %al,%eax
 869:	89 44 24 04          	mov    %eax,0x4(%esp)
 86d:	8b 45 08             	mov    0x8(%ebp),%eax
 870:	89 04 24             	mov    %eax,(%esp)
 873:	e8 05 fe ff ff       	call   67d <putc>
          s++;
 878:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	0f b6 00             	movzbl (%eax),%eax
 882:	84 c0                	test   %al,%al
 884:	75 da                	jne    860 <printf+0x103>
 886:	eb 68                	jmp    8f0 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 888:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 88c:	75 1d                	jne    8ab <printf+0x14e>
        putc(fd, *ap);
 88e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 891:	8b 00                	mov    (%eax),%eax
 893:	0f be c0             	movsbl %al,%eax
 896:	89 44 24 04          	mov    %eax,0x4(%esp)
 89a:	8b 45 08             	mov    0x8(%ebp),%eax
 89d:	89 04 24             	mov    %eax,(%esp)
 8a0:	e8 d8 fd ff ff       	call   67d <putc>
        ap++;
 8a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8a9:	eb 45                	jmp    8f0 <printf+0x193>
      } else if(c == '%'){
 8ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8af:	75 17                	jne    8c8 <printf+0x16b>
        putc(fd, c);
 8b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8b4:	0f be c0             	movsbl %al,%eax
 8b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 8bb:	8b 45 08             	mov    0x8(%ebp),%eax
 8be:	89 04 24             	mov    %eax,(%esp)
 8c1:	e8 b7 fd ff ff       	call   67d <putc>
 8c6:	eb 28                	jmp    8f0 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8c8:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8cf:	00 
 8d0:	8b 45 08             	mov    0x8(%ebp),%eax
 8d3:	89 04 24             	mov    %eax,(%esp)
 8d6:	e8 a2 fd ff ff       	call   67d <putc>
        putc(fd, c);
 8db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8de:	0f be c0             	movsbl %al,%eax
 8e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 8e5:	8b 45 08             	mov    0x8(%ebp),%eax
 8e8:	89 04 24             	mov    %eax,(%esp)
 8eb:	e8 8d fd ff ff       	call   67d <putc>
      }
      state = 0;
 8f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8f7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8fb:	8b 55 0c             	mov    0xc(%ebp),%edx
 8fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 901:	01 d0                	add    %edx,%eax
 903:	0f b6 00             	movzbl (%eax),%eax
 906:	84 c0                	test   %al,%al
 908:	0f 85 71 fe ff ff    	jne    77f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 90e:	c9                   	leave  
 90f:	c3                   	ret    

00000910 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 910:	55                   	push   %ebp
 911:	89 e5                	mov    %esp,%ebp
 913:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 916:	8b 45 08             	mov    0x8(%ebp),%eax
 919:	83 e8 08             	sub    $0x8,%eax
 91c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 91f:	a1 68 0e 00 00       	mov    0xe68,%eax
 924:	89 45 fc             	mov    %eax,-0x4(%ebp)
 927:	eb 24                	jmp    94d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	8b 00                	mov    (%eax),%eax
 92e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 931:	77 12                	ja     945 <free+0x35>
 933:	8b 45 f8             	mov    -0x8(%ebp),%eax
 936:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 939:	77 24                	ja     95f <free+0x4f>
 93b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93e:	8b 00                	mov    (%eax),%eax
 940:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 943:	77 1a                	ja     95f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 00                	mov    (%eax),%eax
 94a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 94d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 950:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 953:	76 d4                	jbe    929 <free+0x19>
 955:	8b 45 fc             	mov    -0x4(%ebp),%eax
 958:	8b 00                	mov    (%eax),%eax
 95a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 95d:	76 ca                	jbe    929 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 95f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 962:	8b 40 04             	mov    0x4(%eax),%eax
 965:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 96c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96f:	01 c2                	add    %eax,%edx
 971:	8b 45 fc             	mov    -0x4(%ebp),%eax
 974:	8b 00                	mov    (%eax),%eax
 976:	39 c2                	cmp    %eax,%edx
 978:	75 24                	jne    99e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 97a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97d:	8b 50 04             	mov    0x4(%eax),%edx
 980:	8b 45 fc             	mov    -0x4(%ebp),%eax
 983:	8b 00                	mov    (%eax),%eax
 985:	8b 40 04             	mov    0x4(%eax),%eax
 988:	01 c2                	add    %eax,%edx
 98a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 990:	8b 45 fc             	mov    -0x4(%ebp),%eax
 993:	8b 00                	mov    (%eax),%eax
 995:	8b 10                	mov    (%eax),%edx
 997:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99a:	89 10                	mov    %edx,(%eax)
 99c:	eb 0a                	jmp    9a8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 99e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a1:	8b 10                	mov    (%eax),%edx
 9a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ab:	8b 40 04             	mov    0x4(%eax),%eax
 9ae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b8:	01 d0                	add    %edx,%eax
 9ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9bd:	75 20                	jne    9df <free+0xcf>
    p->s.size += bp->s.size;
 9bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c2:	8b 50 04             	mov    0x4(%eax),%edx
 9c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c8:	8b 40 04             	mov    0x4(%eax),%eax
 9cb:	01 c2                	add    %eax,%edx
 9cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d6:	8b 10                	mov    (%eax),%edx
 9d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9db:	89 10                	mov    %edx,(%eax)
 9dd:	eb 08                	jmp    9e7 <free+0xd7>
  } else
    p->s.ptr = bp;
 9df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9e5:	89 10                	mov    %edx,(%eax)
  freep = p;
 9e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ea:	a3 68 0e 00 00       	mov    %eax,0xe68
}
 9ef:	c9                   	leave  
 9f0:	c3                   	ret    

000009f1 <morecore>:

static Header*
morecore(uint nu)
{
 9f1:	55                   	push   %ebp
 9f2:	89 e5                	mov    %esp,%ebp
 9f4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9f7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9fe:	77 07                	ja     a07 <morecore+0x16>
    nu = 4096;
 a00:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a07:	8b 45 08             	mov    0x8(%ebp),%eax
 a0a:	c1 e0 03             	shl    $0x3,%eax
 a0d:	89 04 24             	mov    %eax,(%esp)
 a10:	e8 30 fc ff ff       	call   645 <sbrk>
 a15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a18:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a1c:	75 07                	jne    a25 <morecore+0x34>
    return 0;
 a1e:	b8 00 00 00 00       	mov    $0x0,%eax
 a23:	eb 22                	jmp    a47 <morecore+0x56>
  hp = (Header*)p;
 a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2e:	8b 55 08             	mov    0x8(%ebp),%edx
 a31:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a37:	83 c0 08             	add    $0x8,%eax
 a3a:	89 04 24             	mov    %eax,(%esp)
 a3d:	e8 ce fe ff ff       	call   910 <free>
  return freep;
 a42:	a1 68 0e 00 00       	mov    0xe68,%eax
}
 a47:	c9                   	leave  
 a48:	c3                   	ret    

00000a49 <malloc>:

void*
malloc(uint nbytes)
{
 a49:	55                   	push   %ebp
 a4a:	89 e5                	mov    %esp,%ebp
 a4c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a4f:	8b 45 08             	mov    0x8(%ebp),%eax
 a52:	83 c0 07             	add    $0x7,%eax
 a55:	c1 e8 03             	shr    $0x3,%eax
 a58:	83 c0 01             	add    $0x1,%eax
 a5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a5e:	a1 68 0e 00 00       	mov    0xe68,%eax
 a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a6a:	75 23                	jne    a8f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a6c:	c7 45 f0 60 0e 00 00 	movl   $0xe60,-0x10(%ebp)
 a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a76:	a3 68 0e 00 00       	mov    %eax,0xe68
 a7b:	a1 68 0e 00 00       	mov    0xe68,%eax
 a80:	a3 60 0e 00 00       	mov    %eax,0xe60
    base.s.size = 0;
 a85:	c7 05 64 0e 00 00 00 	movl   $0x0,0xe64
 a8c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a92:	8b 00                	mov    (%eax),%eax
 a94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9a:	8b 40 04             	mov    0x4(%eax),%eax
 a9d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 aa0:	72 4d                	jb     aef <malloc+0xa6>
      if(p->s.size == nunits)
 aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa5:	8b 40 04             	mov    0x4(%eax),%eax
 aa8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 aab:	75 0c                	jne    ab9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab0:	8b 10                	mov    (%eax),%edx
 ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab5:	89 10                	mov    %edx,(%eax)
 ab7:	eb 26                	jmp    adf <malloc+0x96>
      else {
        p->s.size -= nunits;
 ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abc:	8b 40 04             	mov    0x4(%eax),%eax
 abf:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ac2:	89 c2                	mov    %eax,%edx
 ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acd:	8b 40 04             	mov    0x4(%eax),%eax
 ad0:	c1 e0 03             	shl    $0x3,%eax
 ad3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 adc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae2:	a3 68 0e 00 00       	mov    %eax,0xe68
      return (void*)(p + 1);
 ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aea:	83 c0 08             	add    $0x8,%eax
 aed:	eb 38                	jmp    b27 <malloc+0xde>
    }
    if(p == freep)
 aef:	a1 68 0e 00 00       	mov    0xe68,%eax
 af4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 af7:	75 1b                	jne    b14 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 afc:	89 04 24             	mov    %eax,(%esp)
 aff:	e8 ed fe ff ff       	call   9f1 <morecore>
 b04:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b0b:	75 07                	jne    b14 <malloc+0xcb>
        return 0;
 b0d:	b8 00 00 00 00       	mov    $0x0,%eax
 b12:	eb 13                	jmp    b27 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b17:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1d:	8b 00                	mov    (%eax),%eax
 b1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b22:	e9 70 ff ff ff       	jmp    a97 <malloc+0x4e>
}
 b27:	c9                   	leave  
 b28:	c3                   	ret    
