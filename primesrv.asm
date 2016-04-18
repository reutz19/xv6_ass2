
_primesrv:     file format elf32-i386


Disassembly of section .text:

00000000 <is_prime>:
static worker_s *workers;

//check if a number is prime
int 
is_prime(int num)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
    if((num & 1)==0)      //even - only 2 is prime
   6:	8b 45 08             	mov    0x8(%ebp),%eax
   9:	83 e0 01             	and    $0x1,%eax
   c:	85 c0                	test   %eax,%eax
   e:	75 0c                	jne    1c <is_prime+0x1c>
        return num == 2;
  10:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  14:	0f 94 c0             	sete   %al
  17:	0f b6 c0             	movzbl %al,%eax
  1a:	eb 2e                	jmp    4a <is_prime+0x4a>
    else  //odd
    {       
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
    if((num & 1)==0)      //even - only 2 is prime
        return num == 2;
    else  //odd
    {       
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

//get a number x and return the first prime number that is larger than x
int 
next_pr(int num)
{
  4c:	55                   	push   %ebp
  4d:	89 e5                	mov    %esp,%ebp
  4f:	83 ec 18             	sub    $0x18,%esp
    if(num < 2)
  52:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  56:	7f 07                	jg     5f <next_pr+0x13>
        return 2;
  58:	b8 02 00 00 00       	mov    $0x2,%eax
  5d:	eb 4a                	jmp    a9 <next_pr+0x5d>
    else if (num == 2)
  5f:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  63:	75 07                	jne    6c <next_pr+0x20>
        return 3;
  65:	b8 03 00 00 00       	mov    $0x3,%eax
  6a:	eb 3d                	jmp    a9 <next_pr+0x5d>
    else if(num & 1){ // odd 
  6c:	8b 45 08             	mov    0x8(%ebp),%eax
  6f:	83 e0 01             	and    $0x1,%eax
  72:	85 c0                	test   %eax,%eax
  74:	74 25                	je     9b <next_pr+0x4f>
        num += 2;
  76:	83 45 08 02          	addl   $0x2,0x8(%ebp)
        return is_prime(num) ? num : next_pr(num);
  7a:	8b 45 08             	mov    0x8(%ebp),%eax
  7d:	89 04 24             	mov    %eax,(%esp)
  80:	e8 7b ff ff ff       	call   0 <is_prime>
  85:	85 c0                	test   %eax,%eax
  87:	75 0d                	jne    96 <next_pr+0x4a>
  89:	8b 45 08             	mov    0x8(%ebp),%eax
  8c:	89 04 24             	mov    %eax,(%esp)
  8f:	e8 b8 ff ff ff       	call   4c <next_pr>
  94:	eb 03                	jmp    99 <next_pr+0x4d>
  96:	8b 45 08             	mov    0x8(%ebp),%eax
  99:	eb 0e                	jmp    a9 <next_pr+0x5d>
    } 
    else              // even 
        return next_pr(num-1);  //become odd and return next_pr
  9b:	8b 45 08             	mov    0x8(%ebp),%eax
  9e:	83 e8 01             	sub    $0x1,%eax
  a1:	89 04 24             	mov    %eax,(%esp)
  a4:	e8 a3 ff ff ff       	call   4c <next_pr>
}
  a9:	c9                   	leave  
  aa:	c3                   	ret    

000000ab <handle_worker_sig>:

void 
handle_worker_sig(int main_pid, int value)
{
  ab:	55                   	push   %ebp
  ac:	89 e5                	mov    %esp,%ebp
  ae:	83 ec 38             	sub    $0x38,%esp
  if (value == 0) {
  b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  b5:	75 22                	jne    d9 <handle_worker_sig+0x2e>
    printf(1, "worker %d exit\n", getpid());
  b7:	e8 fb 06 00 00       	call   7b7 <getpid>
  bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  c0:	c7 44 24 04 a4 0c 00 	movl   $0xca4,0x4(%esp)
  c7:	00 
  c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  cf:	e8 03 08 00 00       	call   8d7 <printf>
    exit();
  d4:	e8 5e 06 00 00       	call   737 <exit>
  }

  // get next prime
  int c = next_pr(value); 
  d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  dc:	89 04 24             	mov    %eax,(%esp)
  df:	e8 68 ff ff ff       	call   4c <next_pr>
  e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  printf(1, "process %d in next_pr return ans %d for %d, main_pid is %d\n",getpid(), c, value, main_pid);
  e7:	e8 cb 06 00 00       	call   7b7 <getpid>
  ec:	8b 55 08             	mov    0x8(%ebp),%edx
  ef:	89 54 24 14          	mov    %edx,0x14(%esp)
  f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  f6:	89 54 24 10          	mov    %edx,0x10(%esp)
  fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
 101:	89 44 24 08          	mov    %eax,0x8(%esp)
 105:	c7 44 24 04 b4 0c 00 	movl   $0xcb4,0x4(%esp)
 10c:	00 
 10d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 114:	e8 be 07 00 00       	call   8d7 <printf>

  //return result to main proccess
  sigsend(main_pid, c); 
 119:	8b 45 f4             	mov    -0xc(%ebp),%eax
 11c:	89 44 24 04          	mov    %eax,0x4(%esp)
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	89 04 24             	mov    %eax,(%esp)
 126:	e8 b4 06 00 00       	call   7df <sigsend>
  //pause until the next number
  sigpause();
 12b:	e8 bf 06 00 00       	call   7ef <sigpause>
}
 130:	c9                   	leave  
 131:	c3                   	ret    

00000132 <handle_main_sig>:
  
void
handle_main_sig(int worker_pid, int value)
{
 132:	55                   	push   %ebp
 133:	89 e5                	mov    %esp,%ebp
 135:	83 ec 38             	sub    $0x38,%esp
  int i;
  for (i = 0; i < workers_number; i++) {
 138:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 13f:	eb 79                	jmp    1ba <handle_main_sig+0x88>
    if (workers[i].pid == worker_pid){
 141:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 147:	8b 55 f4             	mov    -0xc(%ebp),%edx
 14a:	89 d0                	mov    %edx,%eax
 14c:	01 c0                	add    %eax,%eax
 14e:	01 d0                	add    %edx,%eax
 150:	c1 e0 02             	shl    $0x2,%eax
 153:	01 c8                	add    %ecx,%eax
 155:	8b 00                	mov    (%eax),%eax
 157:	3b 45 08             	cmp    0x8(%ebp),%eax
 15a:	75 5a                	jne    1b6 <handle_main_sig+0x84>
      printf(1, "worker %d returned %d as a result for %d", worker_pid, value, workers[i].input_x);
 15c:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 162:	8b 55 f4             	mov    -0xc(%ebp),%edx
 165:	89 d0                	mov    %edx,%eax
 167:	01 c0                	add    %eax,%eax
 169:	01 d0                	add    %edx,%eax
 16b:	c1 e0 02             	shl    $0x2,%eax
 16e:	01 c8                	add    %ecx,%eax
 170:	8b 40 04             	mov    0x4(%eax),%eax
 173:	89 44 24 10          	mov    %eax,0x10(%esp)
 177:	8b 45 0c             	mov    0xc(%ebp),%eax
 17a:	89 44 24 0c          	mov    %eax,0xc(%esp)
 17e:	8b 45 08             	mov    0x8(%ebp),%eax
 181:	89 44 24 08          	mov    %eax,0x8(%esp)
 185:	c7 44 24 04 f0 0c 00 	movl   $0xcf0,0x4(%esp)
 18c:	00 
 18d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 194:	e8 3e 07 00 00       	call   8d7 <printf>
      workers[i].working = 0;
 199:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 19f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1a2:	89 d0                	mov    %edx,%eax
 1a4:	01 c0                	add    %eax,%eax
 1a6:	01 d0                	add    %edx,%eax
 1a8:	c1 e0 02             	shl    $0x2,%eax
 1ab:	01 c8                	add    %ecx,%eax
 1ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      break;
 1b4:	eb 12                	jmp    1c8 <handle_main_sig+0x96>
  
void
handle_main_sig(int worker_pid, int value)
{
  int i;
  for (i = 0; i < workers_number; i++) {
 1b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1ba:	a1 a0 10 00 00       	mov    0x10a0,%eax
 1bf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 1c2:	0f 8c 79 ff ff ff    	jl     141 <handle_main_sig+0xf>
      printf(1, "worker %d returned %d as a result for %d", worker_pid, value, workers[i].input_x);
      workers[i].working = 0;
      break;
    }
  }
}
 1c8:	c9                   	leave  
 1c9:	c3                   	ret    

000001ca <main>:

int
main(int argc, char *argv[])
{
 1ca:	55                   	push   %ebp
 1cb:	89 e5                	mov    %esp,%ebp
 1cd:	83 e4 f0             	and    $0xfffffff0,%esp
 1d0:	83 ec 30             	sub    $0x30,%esp
  int i, pid, input_x;
  char buff[MAX_INPUT];

  // test arguments
  if (argc != 2) {
 1d3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 1d7:	74 19                	je     1f2 <main+0x28>
  	printf(1, "Unvaild parameter for primsrv test\n");
 1d9:	c7 44 24 04 1c 0d 00 	movl   $0xd1c,0x4(%esp)
 1e0:	00 
 1e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1e8:	e8 ea 06 00 00       	call   8d7 <printf>
  	exit();
 1ed:	e8 45 05 00 00       	call   737 <exit>
  }

  // allocate workers array
  workers_number = atoi(argv[1]);
 1f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f5:	83 c0 04             	add    $0x4,%eax
 1f8:	8b 00                	mov    (%eax),%eax
 1fa:	89 04 24             	mov    %eax,(%esp)
 1fd:	e8 a3 04 00 00       	call   6a5 <atoi>
 202:	a3 a0 10 00 00       	mov    %eax,0x10a0
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
 207:	a1 a0 10 00 00       	mov    0x10a0,%eax
 20c:	89 c2                	mov    %eax,%edx
 20e:	89 d0                	mov    %edx,%eax
 210:	01 c0                	add    %eax,%eax
 212:	01 d0                	add    %edx,%eax
 214:	c1 e0 02             	shl    $0x2,%eax
 217:	89 04 24             	mov    %eax,(%esp)
 21a:	e8 a4 09 00 00       	call   bc3 <malloc>
 21f:	a3 a4 10 00 00       	mov    %eax,0x10a4
  
  sigset((void *)handle_main_sig);
 224:	c7 04 24 32 01 00 00 	movl   $0x132,(%esp)
 22b:	e8 a7 05 00 00       	call   7d7 <sigset>
  printf(1, "workers pids:\n");
 230:	c7 44 24 04 40 0d 00 	movl   $0xd40,0x4(%esp)
 237:	00 
 238:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 23f:	e8 93 06 00 00       	call   8d7 <printf>
  for(i = 0; i < workers_number; i++) {
 244:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
 24b:	00 
 24c:	e9 bb 00 00 00       	jmp    30c <main+0x142>
  	
    if ((pid = fork()) == 0) {  // son
 251:	e8 d9 04 00 00       	call   72f <fork>
 256:	89 44 24 28          	mov    %eax,0x28(%esp)
 25a:	83 7c 24 28 00       	cmpl   $0x0,0x28(%esp)
 25f:	75 30                	jne    291 <main+0xc7>
      printf(1, "%d\n", getpid());	
 261:	e8 51 05 00 00       	call   7b7 <getpid>
 266:	89 44 24 08          	mov    %eax,0x8(%esp)
 26a:	c7 44 24 04 4f 0d 00 	movl   $0xd4f,0x4(%esp)
 271:	00 
 272:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 279:	e8 59 06 00 00       	call   8d7 <printf>
      sigset((void *)handle_worker_sig);
 27e:	c7 04 24 ab 00 00 00 	movl   $0xab,(%esp)
 285:	e8 4d 05 00 00       	call   7d7 <sigset>
      sigpause();
 28a:	e8 60 05 00 00       	call   7ef <sigpause>
 28f:	eb 76                	jmp    307 <main+0x13d>
    }
    else if (pid > 0) {         // father
 291:	83 7c 24 28 00       	cmpl   $0x0,0x28(%esp)
 296:	7e 56                	jle    2ee <main+0x124>
      //init son worker_s 
      workers[i].pid = pid;
 298:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 29e:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 2a2:	89 d0                	mov    %edx,%eax
 2a4:	01 c0                	add    %eax,%eax
 2a6:	01 d0                	add    %edx,%eax
 2a8:	c1 e0 02             	shl    $0x2,%eax
 2ab:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 2ae:	8b 44 24 28          	mov    0x28(%esp),%eax
 2b2:	89 02                	mov    %eax,(%edx)
      workers[i].input_x = -1;
 2b4:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 2ba:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 2be:	89 d0                	mov    %edx,%eax
 2c0:	01 c0                	add    %eax,%eax
 2c2:	01 d0                	add    %edx,%eax
 2c4:	c1 e0 02             	shl    $0x2,%eax
 2c7:	01 c8                	add    %ecx,%eax
 2c9:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
      workers[i].working = 0;
 2d0:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 2d6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 2da:	89 d0                	mov    %edx,%eax
 2dc:	01 c0                	add    %eax,%eax
 2de:	01 d0                	add    %edx,%eax
 2e0:	c1 e0 02             	shl    $0x2,%eax
 2e3:	01 c8                	add    %ecx,%eax
 2e5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
 2ec:	eb 19                	jmp    307 <main+0x13d>
    }
    else {                      // fork failed
      printf(1, "fork() failed!\n"); 
 2ee:	c7 44 24 04 53 0d 00 	movl   $0xd53,0x4(%esp)
 2f5:	00 
 2f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2fd:	e8 d5 05 00 00       	call   8d7 <printf>
      exit();
 302:	e8 30 04 00 00       	call   737 <exit>
  workers_number = atoi(argv[1]);
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
  
  sigset((void *)handle_main_sig);
  printf(1, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
 307:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
 30c:	a1 a0 10 00 00       	mov    0x10a0,%eax
 311:	39 44 24 2c          	cmp    %eax,0x2c(%esp)
 315:	0f 8c 36 ff ff ff    	jl     251 <main+0x87>
    }
  }

  for(;;)
  {
  	printf(1, "Please enter a number: ");
 31b:	c7 44 24 04 63 0d 00 	movl   $0xd63,0x4(%esp)
 322:	00 
 323:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 32a:	e8 a8 05 00 00       	call   8d7 <printf>
  	gets(buff, MAX_INPUT);
 32f:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
 336:	00 
 337:	8d 44 24 1a          	lea    0x1a(%esp),%eax
 33b:	89 04 24             	mov    %eax,(%esp)
 33e:	e8 9e 02 00 00       	call   5e1 <gets>
  	if (*buff == 0){
 343:	0f b6 44 24 1a       	movzbl 0x1a(%esp),%eax
 348:	84 c0                	test   %al,%al
 34a:	75 11                	jne    35d <main+0x193>
      //handle main signals by calling a system call
      sigset((void *)handle_main_sig);
 34c:	c7 04 24 32 01 00 00 	movl   $0x132,(%esp)
 353:	e8 7f 04 00 00       	call   7d7 <sigset>
      continue;
 358:	e9 6d 01 00 00       	jmp    4ca <main+0x300>
    }

    input_x = atoi(buff);
 35d:	8d 44 24 1a          	lea    0x1a(%esp),%eax
 361:	89 04 24             	mov    %eax,(%esp)
 364:	e8 3c 03 00 00       	call   6a5 <atoi>
 369:	89 44 24 24          	mov    %eax,0x24(%esp)
  	if(input_x != 0)
 36d:	83 7c 24 24 00       	cmpl   $0x0,0x24(%esp)
 372:	0f 84 e1 00 00 00    	je     459 <main+0x28f>
    {
      // find an idle process = p - TODO
      // send input_x to process p using sigsend sys-call 
      for (i = 0; i < workers_number; i++)
 378:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
 37f:	00 
 380:	e9 9d 00 00 00       	jmp    422 <main+0x258>
      {
        if (workers[i].working == 0) // available
 385:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 38b:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 38f:	89 d0                	mov    %edx,%eax
 391:	01 c0                	add    %eax,%eax
 393:	01 d0                	add    %edx,%eax
 395:	c1 e0 02             	shl    $0x2,%eax
 398:	01 c8                	add    %ecx,%eax
 39a:	8b 40 08             	mov    0x8(%eax),%eax
 39d:	85 c0                	test   %eax,%eax
 39f:	75 7c                	jne    41d <main+0x253>
        {
          workers[i].working = 1;
 3a1:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 3a7:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 3ab:	89 d0                	mov    %edx,%eax
 3ad:	01 c0                	add    %eax,%eax
 3af:	01 d0                	add    %edx,%eax
 3b1:	c1 e0 02             	shl    $0x2,%eax
 3b4:	01 c8                	add    %ecx,%eax
 3b6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
          sigsend(workers[i].pid, input_x);  
 3bd:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 3c3:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 3c7:	89 d0                	mov    %edx,%eax
 3c9:	01 c0                	add    %eax,%eax
 3cb:	01 d0                	add    %edx,%eax
 3cd:	c1 e0 02             	shl    $0x2,%eax
 3d0:	01 c8                	add    %ecx,%eax
 3d2:	8b 00                	mov    (%eax),%eax
 3d4:	8b 54 24 24          	mov    0x24(%esp),%edx
 3d8:	89 54 24 04          	mov    %edx,0x4(%esp)
 3dc:	89 04 24             	mov    %eax,(%esp)
 3df:	e8 fb 03 00 00       	call   7df <sigsend>
          printf(1, "Send signal val %d to worker %d: \n", input_x, workers[i].pid);
 3e4:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 3ea:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 3ee:	89 d0                	mov    %edx,%eax
 3f0:	01 c0                	add    %eax,%eax
 3f2:	01 d0                	add    %edx,%eax
 3f4:	c1 e0 02             	shl    $0x2,%eax
 3f7:	01 c8                	add    %ecx,%eax
 3f9:	8b 00                	mov    (%eax),%eax
 3fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
 3ff:	8b 44 24 24          	mov    0x24(%esp),%eax
 403:	89 44 24 08          	mov    %eax,0x8(%esp)
 407:	c7 44 24 04 7c 0d 00 	movl   $0xd7c,0x4(%esp)
 40e:	00 
 40f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 416:	e8 bc 04 00 00       	call   8d7 <printf>
          break;
 41b:	eb 14                	jmp    431 <main+0x267>
    input_x = atoi(buff);
  	if(input_x != 0)
    {
      // find an idle process = p - TODO
      // send input_x to process p using sigsend sys-call 
      for (i = 0; i < workers_number; i++)
 41d:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
 422:	a1 a0 10 00 00       	mov    0x10a0,%eax
 427:	39 44 24 2c          	cmp    %eax,0x2c(%esp)
 42b:	0f 8c 54 ff ff ff    	jl     385 <main+0x1bb>
          break;
        }
      }

      // no free workers to handle signal
      if (i == workers_number){
 431:	a1 a0 10 00 00       	mov    0x10a0,%eax
 436:	39 44 24 2c          	cmp    %eax,0x2c(%esp)
 43a:	0f 85 8a 00 00 00    	jne    4ca <main+0x300>
        printf(1, "no idle workers\n");
 440:	c7 44 24 04 9f 0d 00 	movl   $0xd9f,0x4(%esp)
 447:	00 
 448:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 44f:	e8 83 04 00 00       	call   8d7 <printf>
      while (wait() > 0);
      free(workers);
  	  printf(1, "primesrv exit\n");
  	  exit();
  	}
  }
 454:	e9 c2 fe ff ff       	jmp    31b <main+0x151>
        printf(1, "no idle workers\n");
      }
    }
    else
  	{
  	  for (i = 0; i < workers_number; i++)
 459:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
 460:	00 
 461:	eb 2c                	jmp    48f <main+0x2c5>
  	  {
        sigsend(workers[i].pid, 0);
 463:	8b 0d a4 10 00 00    	mov    0x10a4,%ecx
 469:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 46d:	89 d0                	mov    %edx,%eax
 46f:	01 c0                	add    %eax,%eax
 471:	01 d0                	add    %edx,%eax
 473:	c1 e0 02             	shl    $0x2,%eax
 476:	01 c8                	add    %ecx,%eax
 478:	8b 00                	mov    (%eax),%eax
 47a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 481:	00 
 482:	89 04 24             	mov    %eax,(%esp)
 485:	e8 55 03 00 00       	call   7df <sigsend>
        printf(1, "no idle workers\n");
      }
    }
    else
  	{
  	  for (i = 0; i < workers_number; i++)
 48a:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
 48f:	a1 a0 10 00 00       	mov    0x10a0,%eax
 494:	39 44 24 2c          	cmp    %eax,0x2c(%esp)
 498:	7c c9                	jl     463 <main+0x299>
  	  {
        sigsend(workers[i].pid, 0);
  	  }
      //wait for all sons
      while (wait() > 0);
 49a:	90                   	nop
 49b:	e8 9f 02 00 00       	call   73f <wait>
 4a0:	85 c0                	test   %eax,%eax
 4a2:	7f f7                	jg     49b <main+0x2d1>
      free(workers);
 4a4:	a1 a4 10 00 00       	mov    0x10a4,%eax
 4a9:	89 04 24             	mov    %eax,(%esp)
 4ac:	e8 d9 05 00 00       	call   a8a <free>
  	  printf(1, "primesrv exit\n");
 4b1:	c7 44 24 04 b0 0d 00 	movl   $0xdb0,0x4(%esp)
 4b8:	00 
 4b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4c0:	e8 12 04 00 00       	call   8d7 <printf>
  	  exit();
 4c5:	e8 6d 02 00 00       	call   737 <exit>
  	}
  }
 4ca:	e9 4c fe ff ff       	jmp    31b <main+0x151>

000004cf <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4cf:	55                   	push   %ebp
 4d0:	89 e5                	mov    %esp,%ebp
 4d2:	57                   	push   %edi
 4d3:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4d7:	8b 55 10             	mov    0x10(%ebp),%edx
 4da:	8b 45 0c             	mov    0xc(%ebp),%eax
 4dd:	89 cb                	mov    %ecx,%ebx
 4df:	89 df                	mov    %ebx,%edi
 4e1:	89 d1                	mov    %edx,%ecx
 4e3:	fc                   	cld    
 4e4:	f3 aa                	rep stos %al,%es:(%edi)
 4e6:	89 ca                	mov    %ecx,%edx
 4e8:	89 fb                	mov    %edi,%ebx
 4ea:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4ed:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4f0:	5b                   	pop    %ebx
 4f1:	5f                   	pop    %edi
 4f2:	5d                   	pop    %ebp
 4f3:	c3                   	ret    

000004f4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 4f4:	55                   	push   %ebp
 4f5:	89 e5                	mov    %esp,%ebp
 4f7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4fa:	8b 45 08             	mov    0x8(%ebp),%eax
 4fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 500:	90                   	nop
 501:	8b 45 08             	mov    0x8(%ebp),%eax
 504:	8d 50 01             	lea    0x1(%eax),%edx
 507:	89 55 08             	mov    %edx,0x8(%ebp)
 50a:	8b 55 0c             	mov    0xc(%ebp),%edx
 50d:	8d 4a 01             	lea    0x1(%edx),%ecx
 510:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 513:	0f b6 12             	movzbl (%edx),%edx
 516:	88 10                	mov    %dl,(%eax)
 518:	0f b6 00             	movzbl (%eax),%eax
 51b:	84 c0                	test   %al,%al
 51d:	75 e2                	jne    501 <strcpy+0xd>
    ;
  return os;
 51f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 522:	c9                   	leave  
 523:	c3                   	ret    

00000524 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 524:	55                   	push   %ebp
 525:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 527:	eb 08                	jmp    531 <strcmp+0xd>
    p++, q++;
 529:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 52d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 531:	8b 45 08             	mov    0x8(%ebp),%eax
 534:	0f b6 00             	movzbl (%eax),%eax
 537:	84 c0                	test   %al,%al
 539:	74 10                	je     54b <strcmp+0x27>
 53b:	8b 45 08             	mov    0x8(%ebp),%eax
 53e:	0f b6 10             	movzbl (%eax),%edx
 541:	8b 45 0c             	mov    0xc(%ebp),%eax
 544:	0f b6 00             	movzbl (%eax),%eax
 547:	38 c2                	cmp    %al,%dl
 549:	74 de                	je     529 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 54b:	8b 45 08             	mov    0x8(%ebp),%eax
 54e:	0f b6 00             	movzbl (%eax),%eax
 551:	0f b6 d0             	movzbl %al,%edx
 554:	8b 45 0c             	mov    0xc(%ebp),%eax
 557:	0f b6 00             	movzbl (%eax),%eax
 55a:	0f b6 c0             	movzbl %al,%eax
 55d:	29 c2                	sub    %eax,%edx
 55f:	89 d0                	mov    %edx,%eax
}
 561:	5d                   	pop    %ebp
 562:	c3                   	ret    

00000563 <strlen>:

uint
strlen(char *s)
{
 563:	55                   	push   %ebp
 564:	89 e5                	mov    %esp,%ebp
 566:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 569:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 570:	eb 04                	jmp    576 <strlen+0x13>
 572:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 576:	8b 55 fc             	mov    -0x4(%ebp),%edx
 579:	8b 45 08             	mov    0x8(%ebp),%eax
 57c:	01 d0                	add    %edx,%eax
 57e:	0f b6 00             	movzbl (%eax),%eax
 581:	84 c0                	test   %al,%al
 583:	75 ed                	jne    572 <strlen+0xf>
    ;
  return n;
 585:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 588:	c9                   	leave  
 589:	c3                   	ret    

0000058a <memset>:

void*
memset(void *dst, int c, uint n)
{
 58a:	55                   	push   %ebp
 58b:	89 e5                	mov    %esp,%ebp
 58d:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 590:	8b 45 10             	mov    0x10(%ebp),%eax
 593:	89 44 24 08          	mov    %eax,0x8(%esp)
 597:	8b 45 0c             	mov    0xc(%ebp),%eax
 59a:	89 44 24 04          	mov    %eax,0x4(%esp)
 59e:	8b 45 08             	mov    0x8(%ebp),%eax
 5a1:	89 04 24             	mov    %eax,(%esp)
 5a4:	e8 26 ff ff ff       	call   4cf <stosb>
  return dst;
 5a9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5ac:	c9                   	leave  
 5ad:	c3                   	ret    

000005ae <strchr>:

char*
strchr(const char *s, char c)
{
 5ae:	55                   	push   %ebp
 5af:	89 e5                	mov    %esp,%ebp
 5b1:	83 ec 04             	sub    $0x4,%esp
 5b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 5ba:	eb 14                	jmp    5d0 <strchr+0x22>
    if(*s == c)
 5bc:	8b 45 08             	mov    0x8(%ebp),%eax
 5bf:	0f b6 00             	movzbl (%eax),%eax
 5c2:	3a 45 fc             	cmp    -0x4(%ebp),%al
 5c5:	75 05                	jne    5cc <strchr+0x1e>
      return (char*)s;
 5c7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ca:	eb 13                	jmp    5df <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 5cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5d0:	8b 45 08             	mov    0x8(%ebp),%eax
 5d3:	0f b6 00             	movzbl (%eax),%eax
 5d6:	84 c0                	test   %al,%al
 5d8:	75 e2                	jne    5bc <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 5da:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5df:	c9                   	leave  
 5e0:	c3                   	ret    

000005e1 <gets>:

char*
gets(char *buf, int max)
{
 5e1:	55                   	push   %ebp
 5e2:	89 e5                	mov    %esp,%ebp
 5e4:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5ee:	eb 4c                	jmp    63c <gets+0x5b>
    cc = read(0, &c, 1);
 5f0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5f7:	00 
 5f8:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 606:	e8 44 01 00 00       	call   74f <read>
 60b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 60e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 612:	7f 02                	jg     616 <gets+0x35>
      break;
 614:	eb 31                	jmp    647 <gets+0x66>
    buf[i++] = c;
 616:	8b 45 f4             	mov    -0xc(%ebp),%eax
 619:	8d 50 01             	lea    0x1(%eax),%edx
 61c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 61f:	89 c2                	mov    %eax,%edx
 621:	8b 45 08             	mov    0x8(%ebp),%eax
 624:	01 c2                	add    %eax,%edx
 626:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 62a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 62c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 630:	3c 0a                	cmp    $0xa,%al
 632:	74 13                	je     647 <gets+0x66>
 634:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 638:	3c 0d                	cmp    $0xd,%al
 63a:	74 0b                	je     647 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 63c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63f:	83 c0 01             	add    $0x1,%eax
 642:	3b 45 0c             	cmp    0xc(%ebp),%eax
 645:	7c a9                	jl     5f0 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 647:	8b 55 f4             	mov    -0xc(%ebp),%edx
 64a:	8b 45 08             	mov    0x8(%ebp),%eax
 64d:	01 d0                	add    %edx,%eax
 64f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 652:	8b 45 08             	mov    0x8(%ebp),%eax
}
 655:	c9                   	leave  
 656:	c3                   	ret    

00000657 <stat>:

int
stat(char *n, struct stat *st)
{
 657:	55                   	push   %ebp
 658:	89 e5                	mov    %esp,%ebp
 65a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 65d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 664:	00 
 665:	8b 45 08             	mov    0x8(%ebp),%eax
 668:	89 04 24             	mov    %eax,(%esp)
 66b:	e8 07 01 00 00       	call   777 <open>
 670:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 673:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 677:	79 07                	jns    680 <stat+0x29>
    return -1;
 679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 67e:	eb 23                	jmp    6a3 <stat+0x4c>
  r = fstat(fd, st);
 680:	8b 45 0c             	mov    0xc(%ebp),%eax
 683:	89 44 24 04          	mov    %eax,0x4(%esp)
 687:	8b 45 f4             	mov    -0xc(%ebp),%eax
 68a:	89 04 24             	mov    %eax,(%esp)
 68d:	e8 fd 00 00 00       	call   78f <fstat>
 692:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 695:	8b 45 f4             	mov    -0xc(%ebp),%eax
 698:	89 04 24             	mov    %eax,(%esp)
 69b:	e8 bf 00 00 00       	call   75f <close>
  return r;
 6a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 6a3:	c9                   	leave  
 6a4:	c3                   	ret    

000006a5 <atoi>:

int
atoi(const char *s)
{
 6a5:	55                   	push   %ebp
 6a6:	89 e5                	mov    %esp,%ebp
 6a8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 6ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6b2:	eb 25                	jmp    6d9 <atoi+0x34>
    n = n*10 + *s++ - '0';
 6b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6b7:	89 d0                	mov    %edx,%eax
 6b9:	c1 e0 02             	shl    $0x2,%eax
 6bc:	01 d0                	add    %edx,%eax
 6be:	01 c0                	add    %eax,%eax
 6c0:	89 c1                	mov    %eax,%ecx
 6c2:	8b 45 08             	mov    0x8(%ebp),%eax
 6c5:	8d 50 01             	lea    0x1(%eax),%edx
 6c8:	89 55 08             	mov    %edx,0x8(%ebp)
 6cb:	0f b6 00             	movzbl (%eax),%eax
 6ce:	0f be c0             	movsbl %al,%eax
 6d1:	01 c8                	add    %ecx,%eax
 6d3:	83 e8 30             	sub    $0x30,%eax
 6d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6d9:	8b 45 08             	mov    0x8(%ebp),%eax
 6dc:	0f b6 00             	movzbl (%eax),%eax
 6df:	3c 2f                	cmp    $0x2f,%al
 6e1:	7e 0a                	jle    6ed <atoi+0x48>
 6e3:	8b 45 08             	mov    0x8(%ebp),%eax
 6e6:	0f b6 00             	movzbl (%eax),%eax
 6e9:	3c 39                	cmp    $0x39,%al
 6eb:	7e c7                	jle    6b4 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6f0:	c9                   	leave  
 6f1:	c3                   	ret    

000006f2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 6f2:	55                   	push   %ebp
 6f3:	89 e5                	mov    %esp,%ebp
 6f5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 6f8:	8b 45 08             	mov    0x8(%ebp),%eax
 6fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 701:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 704:	eb 17                	jmp    71d <memmove+0x2b>
    *dst++ = *src++;
 706:	8b 45 fc             	mov    -0x4(%ebp),%eax
 709:	8d 50 01             	lea    0x1(%eax),%edx
 70c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 70f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 712:	8d 4a 01             	lea    0x1(%edx),%ecx
 715:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 718:	0f b6 12             	movzbl (%edx),%edx
 71b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 71d:	8b 45 10             	mov    0x10(%ebp),%eax
 720:	8d 50 ff             	lea    -0x1(%eax),%edx
 723:	89 55 10             	mov    %edx,0x10(%ebp)
 726:	85 c0                	test   %eax,%eax
 728:	7f dc                	jg     706 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 72a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 72d:	c9                   	leave  
 72e:	c3                   	ret    

0000072f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 72f:	b8 01 00 00 00       	mov    $0x1,%eax
 734:	cd 40                	int    $0x40
 736:	c3                   	ret    

00000737 <exit>:
SYSCALL(exit)
 737:	b8 02 00 00 00       	mov    $0x2,%eax
 73c:	cd 40                	int    $0x40
 73e:	c3                   	ret    

0000073f <wait>:
SYSCALL(wait)
 73f:	b8 03 00 00 00       	mov    $0x3,%eax
 744:	cd 40                	int    $0x40
 746:	c3                   	ret    

00000747 <pipe>:
SYSCALL(pipe)
 747:	b8 04 00 00 00       	mov    $0x4,%eax
 74c:	cd 40                	int    $0x40
 74e:	c3                   	ret    

0000074f <read>:
SYSCALL(read)
 74f:	b8 05 00 00 00       	mov    $0x5,%eax
 754:	cd 40                	int    $0x40
 756:	c3                   	ret    

00000757 <write>:
SYSCALL(write)
 757:	b8 10 00 00 00       	mov    $0x10,%eax
 75c:	cd 40                	int    $0x40
 75e:	c3                   	ret    

0000075f <close>:
SYSCALL(close)
 75f:	b8 15 00 00 00       	mov    $0x15,%eax
 764:	cd 40                	int    $0x40
 766:	c3                   	ret    

00000767 <kill>:
SYSCALL(kill)
 767:	b8 06 00 00 00       	mov    $0x6,%eax
 76c:	cd 40                	int    $0x40
 76e:	c3                   	ret    

0000076f <exec>:
SYSCALL(exec)
 76f:	b8 07 00 00 00       	mov    $0x7,%eax
 774:	cd 40                	int    $0x40
 776:	c3                   	ret    

00000777 <open>:
SYSCALL(open)
 777:	b8 0f 00 00 00       	mov    $0xf,%eax
 77c:	cd 40                	int    $0x40
 77e:	c3                   	ret    

0000077f <mknod>:
SYSCALL(mknod)
 77f:	b8 11 00 00 00       	mov    $0x11,%eax
 784:	cd 40                	int    $0x40
 786:	c3                   	ret    

00000787 <unlink>:
SYSCALL(unlink)
 787:	b8 12 00 00 00       	mov    $0x12,%eax
 78c:	cd 40                	int    $0x40
 78e:	c3                   	ret    

0000078f <fstat>:
SYSCALL(fstat)
 78f:	b8 08 00 00 00       	mov    $0x8,%eax
 794:	cd 40                	int    $0x40
 796:	c3                   	ret    

00000797 <link>:
SYSCALL(link)
 797:	b8 13 00 00 00       	mov    $0x13,%eax
 79c:	cd 40                	int    $0x40
 79e:	c3                   	ret    

0000079f <mkdir>:
SYSCALL(mkdir)
 79f:	b8 14 00 00 00       	mov    $0x14,%eax
 7a4:	cd 40                	int    $0x40
 7a6:	c3                   	ret    

000007a7 <chdir>:
SYSCALL(chdir)
 7a7:	b8 09 00 00 00       	mov    $0x9,%eax
 7ac:	cd 40                	int    $0x40
 7ae:	c3                   	ret    

000007af <dup>:
SYSCALL(dup)
 7af:	b8 0a 00 00 00       	mov    $0xa,%eax
 7b4:	cd 40                	int    $0x40
 7b6:	c3                   	ret    

000007b7 <getpid>:
SYSCALL(getpid)
 7b7:	b8 0b 00 00 00       	mov    $0xb,%eax
 7bc:	cd 40                	int    $0x40
 7be:	c3                   	ret    

000007bf <sbrk>:
SYSCALL(sbrk)
 7bf:	b8 0c 00 00 00       	mov    $0xc,%eax
 7c4:	cd 40                	int    $0x40
 7c6:	c3                   	ret    

000007c7 <sleep>:
SYSCALL(sleep)
 7c7:	b8 0d 00 00 00       	mov    $0xd,%eax
 7cc:	cd 40                	int    $0x40
 7ce:	c3                   	ret    

000007cf <uptime>:
SYSCALL(uptime)
 7cf:	b8 0e 00 00 00       	mov    $0xe,%eax
 7d4:	cd 40                	int    $0x40
 7d6:	c3                   	ret    

000007d7 <sigset>:
SYSCALL(sigset)
 7d7:	b8 16 00 00 00       	mov    $0x16,%eax
 7dc:	cd 40                	int    $0x40
 7de:	c3                   	ret    

000007df <sigsend>:
SYSCALL(sigsend)
 7df:	b8 17 00 00 00       	mov    $0x17,%eax
 7e4:	cd 40                	int    $0x40
 7e6:	c3                   	ret    

000007e7 <sigret>:
SYSCALL(sigret)
 7e7:	b8 18 00 00 00       	mov    $0x18,%eax
 7ec:	cd 40                	int    $0x40
 7ee:	c3                   	ret    

000007ef <sigpause>:
 7ef:	b8 19 00 00 00       	mov    $0x19,%eax
 7f4:	cd 40                	int    $0x40
 7f6:	c3                   	ret    

000007f7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 7f7:	55                   	push   %ebp
 7f8:	89 e5                	mov    %esp,%ebp
 7fa:	83 ec 18             	sub    $0x18,%esp
 7fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 800:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 803:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 80a:	00 
 80b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 80e:	89 44 24 04          	mov    %eax,0x4(%esp)
 812:	8b 45 08             	mov    0x8(%ebp),%eax
 815:	89 04 24             	mov    %eax,(%esp)
 818:	e8 3a ff ff ff       	call   757 <write>
}
 81d:	c9                   	leave  
 81e:	c3                   	ret    

0000081f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 81f:	55                   	push   %ebp
 820:	89 e5                	mov    %esp,%ebp
 822:	56                   	push   %esi
 823:	53                   	push   %ebx
 824:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 827:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 82e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 832:	74 17                	je     84b <printint+0x2c>
 834:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 838:	79 11                	jns    84b <printint+0x2c>
    neg = 1;
 83a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 841:	8b 45 0c             	mov    0xc(%ebp),%eax
 844:	f7 d8                	neg    %eax
 846:	89 45 ec             	mov    %eax,-0x14(%ebp)
 849:	eb 06                	jmp    851 <printint+0x32>
  } else {
    x = xx;
 84b:	8b 45 0c             	mov    0xc(%ebp),%eax
 84e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 851:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 858:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 85b:	8d 41 01             	lea    0x1(%ecx),%eax
 85e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 861:	8b 5d 10             	mov    0x10(%ebp),%ebx
 864:	8b 45 ec             	mov    -0x14(%ebp),%eax
 867:	ba 00 00 00 00       	mov    $0x0,%edx
 86c:	f7 f3                	div    %ebx
 86e:	89 d0                	mov    %edx,%eax
 870:	0f b6 80 8c 10 00 00 	movzbl 0x108c(%eax),%eax
 877:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 87b:	8b 75 10             	mov    0x10(%ebp),%esi
 87e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 881:	ba 00 00 00 00       	mov    $0x0,%edx
 886:	f7 f6                	div    %esi
 888:	89 45 ec             	mov    %eax,-0x14(%ebp)
 88b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 88f:	75 c7                	jne    858 <printint+0x39>
  if(neg)
 891:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 895:	74 10                	je     8a7 <printint+0x88>
    buf[i++] = '-';
 897:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89a:	8d 50 01             	lea    0x1(%eax),%edx
 89d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8a0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8a5:	eb 1f                	jmp    8c6 <printint+0xa7>
 8a7:	eb 1d                	jmp    8c6 <printint+0xa7>
    putc(fd, buf[i]);
 8a9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8af:	01 d0                	add    %edx,%eax
 8b1:	0f b6 00             	movzbl (%eax),%eax
 8b4:	0f be c0             	movsbl %al,%eax
 8b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 8bb:	8b 45 08             	mov    0x8(%ebp),%eax
 8be:	89 04 24             	mov    %eax,(%esp)
 8c1:	e8 31 ff ff ff       	call   7f7 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 8c6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ce:	79 d9                	jns    8a9 <printint+0x8a>
    putc(fd, buf[i]);
}
 8d0:	83 c4 30             	add    $0x30,%esp
 8d3:	5b                   	pop    %ebx
 8d4:	5e                   	pop    %esi
 8d5:	5d                   	pop    %ebp
 8d6:	c3                   	ret    

000008d7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 8d7:	55                   	push   %ebp
 8d8:	89 e5                	mov    %esp,%ebp
 8da:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 8dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 8e4:	8d 45 0c             	lea    0xc(%ebp),%eax
 8e7:	83 c0 04             	add    $0x4,%eax
 8ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 8ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8f4:	e9 7c 01 00 00       	jmp    a75 <printf+0x19e>
    c = fmt[i] & 0xff;
 8f9:	8b 55 0c             	mov    0xc(%ebp),%edx
 8fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ff:	01 d0                	add    %edx,%eax
 901:	0f b6 00             	movzbl (%eax),%eax
 904:	0f be c0             	movsbl %al,%eax
 907:	25 ff 00 00 00       	and    $0xff,%eax
 90c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 90f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 913:	75 2c                	jne    941 <printf+0x6a>
      if(c == '%'){
 915:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 919:	75 0c                	jne    927 <printf+0x50>
        state = '%';
 91b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 922:	e9 4a 01 00 00       	jmp    a71 <printf+0x19a>
      } else {
        putc(fd, c);
 927:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 92a:	0f be c0             	movsbl %al,%eax
 92d:	89 44 24 04          	mov    %eax,0x4(%esp)
 931:	8b 45 08             	mov    0x8(%ebp),%eax
 934:	89 04 24             	mov    %eax,(%esp)
 937:	e8 bb fe ff ff       	call   7f7 <putc>
 93c:	e9 30 01 00 00       	jmp    a71 <printf+0x19a>
      }
    } else if(state == '%'){
 941:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 945:	0f 85 26 01 00 00    	jne    a71 <printf+0x19a>
      if(c == 'd'){
 94b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 94f:	75 2d                	jne    97e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 951:	8b 45 e8             	mov    -0x18(%ebp),%eax
 954:	8b 00                	mov    (%eax),%eax
 956:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 95d:	00 
 95e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 965:	00 
 966:	89 44 24 04          	mov    %eax,0x4(%esp)
 96a:	8b 45 08             	mov    0x8(%ebp),%eax
 96d:	89 04 24             	mov    %eax,(%esp)
 970:	e8 aa fe ff ff       	call   81f <printint>
        ap++;
 975:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 979:	e9 ec 00 00 00       	jmp    a6a <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 97e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 982:	74 06                	je     98a <printf+0xb3>
 984:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 988:	75 2d                	jne    9b7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 98a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 98d:	8b 00                	mov    (%eax),%eax
 98f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 996:	00 
 997:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 99e:	00 
 99f:	89 44 24 04          	mov    %eax,0x4(%esp)
 9a3:	8b 45 08             	mov    0x8(%ebp),%eax
 9a6:	89 04 24             	mov    %eax,(%esp)
 9a9:	e8 71 fe ff ff       	call   81f <printint>
        ap++;
 9ae:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9b2:	e9 b3 00 00 00       	jmp    a6a <printf+0x193>
      } else if(c == 's'){
 9b7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9bb:	75 45                	jne    a02 <printf+0x12b>
        s = (char*)*ap;
 9bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c0:	8b 00                	mov    (%eax),%eax
 9c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9cd:	75 09                	jne    9d8 <printf+0x101>
          s = "(null)";
 9cf:	c7 45 f4 bf 0d 00 00 	movl   $0xdbf,-0xc(%ebp)
        while(*s != 0){
 9d6:	eb 1e                	jmp    9f6 <printf+0x11f>
 9d8:	eb 1c                	jmp    9f6 <printf+0x11f>
          putc(fd, *s);
 9da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9dd:	0f b6 00             	movzbl (%eax),%eax
 9e0:	0f be c0             	movsbl %al,%eax
 9e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 9e7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ea:	89 04 24             	mov    %eax,(%esp)
 9ed:	e8 05 fe ff ff       	call   7f7 <putc>
          s++;
 9f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 9f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f9:	0f b6 00             	movzbl (%eax),%eax
 9fc:	84 c0                	test   %al,%al
 9fe:	75 da                	jne    9da <printf+0x103>
 a00:	eb 68                	jmp    a6a <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a02:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a06:	75 1d                	jne    a25 <printf+0x14e>
        putc(fd, *ap);
 a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a0b:	8b 00                	mov    (%eax),%eax
 a0d:	0f be c0             	movsbl %al,%eax
 a10:	89 44 24 04          	mov    %eax,0x4(%esp)
 a14:	8b 45 08             	mov    0x8(%ebp),%eax
 a17:	89 04 24             	mov    %eax,(%esp)
 a1a:	e8 d8 fd ff ff       	call   7f7 <putc>
        ap++;
 a1f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a23:	eb 45                	jmp    a6a <printf+0x193>
      } else if(c == '%'){
 a25:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a29:	75 17                	jne    a42 <printf+0x16b>
        putc(fd, c);
 a2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a2e:	0f be c0             	movsbl %al,%eax
 a31:	89 44 24 04          	mov    %eax,0x4(%esp)
 a35:	8b 45 08             	mov    0x8(%ebp),%eax
 a38:	89 04 24             	mov    %eax,(%esp)
 a3b:	e8 b7 fd ff ff       	call   7f7 <putc>
 a40:	eb 28                	jmp    a6a <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a42:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a49:	00 
 a4a:	8b 45 08             	mov    0x8(%ebp),%eax
 a4d:	89 04 24             	mov    %eax,(%esp)
 a50:	e8 a2 fd ff ff       	call   7f7 <putc>
        putc(fd, c);
 a55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a58:	0f be c0             	movsbl %al,%eax
 a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
 a5f:	8b 45 08             	mov    0x8(%ebp),%eax
 a62:	89 04 24             	mov    %eax,(%esp)
 a65:	e8 8d fd ff ff       	call   7f7 <putc>
      }
      state = 0;
 a6a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 a71:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a75:	8b 55 0c             	mov    0xc(%ebp),%edx
 a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7b:	01 d0                	add    %edx,%eax
 a7d:	0f b6 00             	movzbl (%eax),%eax
 a80:	84 c0                	test   %al,%al
 a82:	0f 85 71 fe ff ff    	jne    8f9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 a88:	c9                   	leave  
 a89:	c3                   	ret    

00000a8a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a8a:	55                   	push   %ebp
 a8b:	89 e5                	mov    %esp,%ebp
 a8d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a90:	8b 45 08             	mov    0x8(%ebp),%eax
 a93:	83 e8 08             	sub    $0x8,%eax
 a96:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a99:	a1 b0 10 00 00       	mov    0x10b0,%eax
 a9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 aa1:	eb 24                	jmp    ac7 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aa3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa6:	8b 00                	mov    (%eax),%eax
 aa8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 aab:	77 12                	ja     abf <free+0x35>
 aad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ab3:	77 24                	ja     ad9 <free+0x4f>
 ab5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab8:	8b 00                	mov    (%eax),%eax
 aba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 abd:	77 1a                	ja     ad9 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 abf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac2:	8b 00                	mov    (%eax),%eax
 ac4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ac7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 acd:	76 d4                	jbe    aa3 <free+0x19>
 acf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad2:	8b 00                	mov    (%eax),%eax
 ad4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ad7:	76 ca                	jbe    aa3 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 ad9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 adc:	8b 40 04             	mov    0x4(%eax),%eax
 adf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 ae6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae9:	01 c2                	add    %eax,%edx
 aeb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aee:	8b 00                	mov    (%eax),%eax
 af0:	39 c2                	cmp    %eax,%edx
 af2:	75 24                	jne    b18 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 af4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 af7:	8b 50 04             	mov    0x4(%eax),%edx
 afa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 afd:	8b 00                	mov    (%eax),%eax
 aff:	8b 40 04             	mov    0x4(%eax),%eax
 b02:	01 c2                	add    %eax,%edx
 b04:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b07:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b0d:	8b 00                	mov    (%eax),%eax
 b0f:	8b 10                	mov    (%eax),%edx
 b11:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b14:	89 10                	mov    %edx,(%eax)
 b16:	eb 0a                	jmp    b22 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b18:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b1b:	8b 10                	mov    (%eax),%edx
 b1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b20:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b22:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b25:	8b 40 04             	mov    0x4(%eax),%eax
 b28:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b32:	01 d0                	add    %edx,%eax
 b34:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b37:	75 20                	jne    b59 <free+0xcf>
    p->s.size += bp->s.size;
 b39:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3c:	8b 50 04             	mov    0x4(%eax),%edx
 b3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b42:	8b 40 04             	mov    0x4(%eax),%eax
 b45:	01 c2                	add    %eax,%edx
 b47:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b50:	8b 10                	mov    (%eax),%edx
 b52:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b55:	89 10                	mov    %edx,(%eax)
 b57:	eb 08                	jmp    b61 <free+0xd7>
  } else
    p->s.ptr = bp;
 b59:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b5f:	89 10                	mov    %edx,(%eax)
  freep = p;
 b61:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b64:	a3 b0 10 00 00       	mov    %eax,0x10b0
}
 b69:	c9                   	leave  
 b6a:	c3                   	ret    

00000b6b <morecore>:

static Header*
morecore(uint nu)
{
 b6b:	55                   	push   %ebp
 b6c:	89 e5                	mov    %esp,%ebp
 b6e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b71:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b78:	77 07                	ja     b81 <morecore+0x16>
    nu = 4096;
 b7a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b81:	8b 45 08             	mov    0x8(%ebp),%eax
 b84:	c1 e0 03             	shl    $0x3,%eax
 b87:	89 04 24             	mov    %eax,(%esp)
 b8a:	e8 30 fc ff ff       	call   7bf <sbrk>
 b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b92:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b96:	75 07                	jne    b9f <morecore+0x34>
    return 0;
 b98:	b8 00 00 00 00       	mov    $0x0,%eax
 b9d:	eb 22                	jmp    bc1 <morecore+0x56>
  hp = (Header*)p;
 b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba8:	8b 55 08             	mov    0x8(%ebp),%edx
 bab:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bb1:	83 c0 08             	add    $0x8,%eax
 bb4:	89 04 24             	mov    %eax,(%esp)
 bb7:	e8 ce fe ff ff       	call   a8a <free>
  return freep;
 bbc:	a1 b0 10 00 00       	mov    0x10b0,%eax
}
 bc1:	c9                   	leave  
 bc2:	c3                   	ret    

00000bc3 <malloc>:

void*
malloc(uint nbytes)
{
 bc3:	55                   	push   %ebp
 bc4:	89 e5                	mov    %esp,%ebp
 bc6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bc9:	8b 45 08             	mov    0x8(%ebp),%eax
 bcc:	83 c0 07             	add    $0x7,%eax
 bcf:	c1 e8 03             	shr    $0x3,%eax
 bd2:	83 c0 01             	add    $0x1,%eax
 bd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 bd8:	a1 b0 10 00 00       	mov    0x10b0,%eax
 bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 be0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 be4:	75 23                	jne    c09 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 be6:	c7 45 f0 a8 10 00 00 	movl   $0x10a8,-0x10(%ebp)
 bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf0:	a3 b0 10 00 00       	mov    %eax,0x10b0
 bf5:	a1 b0 10 00 00       	mov    0x10b0,%eax
 bfa:	a3 a8 10 00 00       	mov    %eax,0x10a8
    base.s.size = 0;
 bff:	c7 05 ac 10 00 00 00 	movl   $0x0,0x10ac
 c06:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c0c:	8b 00                	mov    (%eax),%eax
 c0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c14:	8b 40 04             	mov    0x4(%eax),%eax
 c17:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c1a:	72 4d                	jb     c69 <malloc+0xa6>
      if(p->s.size == nunits)
 c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c1f:	8b 40 04             	mov    0x4(%eax),%eax
 c22:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c25:	75 0c                	jne    c33 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c2a:	8b 10                	mov    (%eax),%edx
 c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c2f:	89 10                	mov    %edx,(%eax)
 c31:	eb 26                	jmp    c59 <malloc+0x96>
      else {
        p->s.size -= nunits;
 c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c36:	8b 40 04             	mov    0x4(%eax),%eax
 c39:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c3c:	89 c2                	mov    %eax,%edx
 c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c41:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c47:	8b 40 04             	mov    0x4(%eax),%eax
 c4a:	c1 e0 03             	shl    $0x3,%eax
 c4d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c53:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c56:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c5c:	a3 b0 10 00 00       	mov    %eax,0x10b0
      return (void*)(p + 1);
 c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c64:	83 c0 08             	add    $0x8,%eax
 c67:	eb 38                	jmp    ca1 <malloc+0xde>
    }
    if(p == freep)
 c69:	a1 b0 10 00 00       	mov    0x10b0,%eax
 c6e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c71:	75 1b                	jne    c8e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 c73:	8b 45 ec             	mov    -0x14(%ebp),%eax
 c76:	89 04 24             	mov    %eax,(%esp)
 c79:	e8 ed fe ff ff       	call   b6b <morecore>
 c7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c85:	75 07                	jne    c8e <malloc+0xcb>
        return 0;
 c87:	b8 00 00 00 00       	mov    $0x0,%eax
 c8c:	eb 13                	jmp    ca1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c91:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c97:	8b 00                	mov    (%eax),%eax
 c99:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 c9c:	e9 70 ff ff ff       	jmp    c11 <malloc+0x4e>
}
 ca1:	c9                   	leave  
 ca2:	c3                   	ret    
