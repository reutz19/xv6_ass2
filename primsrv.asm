
_primsrv:     file format elf32-i386


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
  ae:	83 ec 28             	sub    $0x28,%esp
  if (value == 0) {
  b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  b5:	75 05                	jne    bc <handle_worker_sig+0x11>
    //printf(1, "worker %d exit\n", getpid());
    exit();
  b7:	e8 43 06 00 00       	call   6ff <exit>
  }

  // get next prime
  int c = next_pr(value); 
  bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  bf:	89 04 24             	mov    %eax,(%esp)
  c2:	e8 85 ff ff ff       	call   4c <next_pr>
  c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //printf(1, "process %d in next_pr return ans %d for %d, main_pid is %d\n",getpid(), c, value, main_pid);

  //return result to main proccess
  sigsend(main_pid, c); 
  ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  d1:	8b 45 08             	mov    0x8(%ebp),%eax
  d4:	89 04 24             	mov    %eax,(%esp)
  d7:	e8 cb 06 00 00       	call   7a7 <sigsend>
  //pause until the next number
  sigpause();
  dc:	e8 d6 06 00 00       	call   7b7 <sigpause>
}
  e1:	c9                   	leave  
  e2:	c3                   	ret    

000000e3 <handle_main_sig>:
  
void
handle_main_sig(int worker_pid, int value)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  e6:	83 ec 38             	sub    $0x38,%esp
  int i;
  for (i = 0; i < workers_number; i++) {
  e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  f0:	eb 79                	jmp    16b <handle_main_sig+0x88>
    if (workers[i].pid == worker_pid){
  f2:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
  f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  fb:	89 d0                	mov    %edx,%eax
  fd:	01 c0                	add    %eax,%eax
  ff:	01 d0                	add    %edx,%eax
 101:	c1 e0 02             	shl    $0x2,%eax
 104:	01 c8                	add    %ecx,%eax
 106:	8b 00                	mov    (%eax),%eax
 108:	3b 45 08             	cmp    0x8(%ebp),%eax
 10b:	75 5a                	jne    167 <handle_main_sig+0x84>
      printf(1, "worker %d returned %d as a result for %d", worker_pid, value, workers[i].input_x);
 10d:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 113:	8b 55 f4             	mov    -0xc(%ebp),%edx
 116:	89 d0                	mov    %edx,%eax
 118:	01 c0                	add    %eax,%eax
 11a:	01 d0                	add    %edx,%eax
 11c:	c1 e0 02             	shl    $0x2,%eax
 11f:	01 c8                	add    %ecx,%eax
 121:	8b 40 04             	mov    0x4(%eax),%eax
 124:	89 44 24 10          	mov    %eax,0x10(%esp)
 128:	8b 45 0c             	mov    0xc(%ebp),%eax
 12b:	89 44 24 0c          	mov    %eax,0xc(%esp)
 12f:	8b 45 08             	mov    0x8(%ebp),%eax
 132:	89 44 24 08          	mov    %eax,0x8(%esp)
 136:	c7 44 24 04 6c 0c 00 	movl   $0xc6c,0x4(%esp)
 13d:	00 
 13e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 145:	e8 55 07 00 00       	call   89f <printf>
      workers[i].working = 0;
 14a:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 150:	8b 55 f4             	mov    -0xc(%ebp),%edx
 153:	89 d0                	mov    %edx,%eax
 155:	01 c0                	add    %eax,%eax
 157:	01 d0                	add    %edx,%eax
 159:	c1 e0 02             	shl    $0x2,%eax
 15c:	01 c8                	add    %ecx,%eax
 15e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      break;
 165:	eb 12                	jmp    179 <handle_main_sig+0x96>
  
void
handle_main_sig(int worker_pid, int value)
{
  int i;
  for (i = 0; i < workers_number; i++) {
 167:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 16b:	a1 08 10 00 00       	mov    0x1008,%eax
 170:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 173:	0f 8c 79 ff ff ff    	jl     f2 <handle_main_sig+0xf>
      printf(1, "worker %d returned %d as a result for %d", worker_pid, value, workers[i].input_x);
      workers[i].working = 0;
      break;
    }
  }
}
 179:	c9                   	leave  
 17a:	c3                   	ret    

0000017b <main>:

int
main(int argc, char *argv[])
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
 17e:	83 e4 f0             	and    $0xfffffff0,%esp
 181:	83 ec 30             	sub    $0x30,%esp
  int i, pid, input_x;
  char buf[MAX_INPUT];

  // test arguments
  if (argc != 2) {
 184:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 188:	74 19                	je     1a3 <main+0x28>
  	printf(1, "Unvaild parameter for primsrv test\n");
 18a:	c7 44 24 04 98 0c 00 	movl   $0xc98,0x4(%esp)
 191:	00 
 192:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 199:	e8 01 07 00 00       	call   89f <printf>
  	exit();
 19e:	e8 5c 05 00 00       	call   6ff <exit>
  }

  // allocate workers array
  workers_number = atoi(argv[1]);
 1a3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a6:	83 c0 04             	add    $0x4,%eax
 1a9:	8b 00                	mov    (%eax),%eax
 1ab:	89 04 24             	mov    %eax,(%esp)
 1ae:	e8 ba 04 00 00       	call   66d <atoi>
 1b3:	a3 08 10 00 00       	mov    %eax,0x1008
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
 1b8:	a1 08 10 00 00       	mov    0x1008,%eax
 1bd:	89 c2                	mov    %eax,%edx
 1bf:	89 d0                	mov    %edx,%eax
 1c1:	01 c0                	add    %eax,%eax
 1c3:	01 d0                	add    %edx,%eax
 1c5:	c1 e0 02             	shl    $0x2,%eax
 1c8:	89 04 24             	mov    %eax,(%esp)
 1cb:	e8 bb 09 00 00       	call   b8b <malloc>
 1d0:	a3 0c 10 00 00       	mov    %eax,0x100c
  
  sigset((void *)handle_main_sig);
 1d5:	c7 04 24 e3 00 00 00 	movl   $0xe3,(%esp)
 1dc:	e8 be 05 00 00       	call   79f <sigset>
  printf(1, "workers pids:\n");
 1e1:	c7 44 24 04 bc 0c 00 	movl   $0xcbc,0x4(%esp)
 1e8:	00 
 1e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1f0:	e8 aa 06 00 00       	call   89f <printf>
  for(i = 0; i < workers_number; i++) {
 1f5:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
 1fc:	00 
 1fd:	e9 bd 00 00 00       	jmp    2bf <main+0x144>
  	
    if ((pid = fork()) == 0) {  // son
 202:	e8 f0 04 00 00       	call   6f7 <fork>
 207:	89 44 24 28          	mov    %eax,0x28(%esp)
 20b:	83 7c 24 28 00       	cmpl   $0x0,0x28(%esp)
 210:	75 16                	jne    228 <main+0xad>
      sigset((void *)handle_worker_sig);
 212:	c7 04 24 ab 00 00 00 	movl   $0xab,(%esp)
 219:	e8 81 05 00 00       	call   79f <sigset>
      sigpause();
 21e:	e8 94 05 00 00       	call   7b7 <sigpause>
 223:	e9 92 00 00 00       	jmp    2ba <main+0x13f>
    }
    else if (pid > 0) {         // father
 228:	83 7c 24 28 00       	cmpl   $0x0,0x28(%esp)
 22d:	7e 72                	jle    2a1 <main+0x126>
      //init son worker_s 
      printf(1, "%d\n", pid);  
 22f:	8b 44 24 28          	mov    0x28(%esp),%eax
 233:	89 44 24 08          	mov    %eax,0x8(%esp)
 237:	c7 44 24 04 cb 0c 00 	movl   $0xccb,0x4(%esp)
 23e:	00 
 23f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 246:	e8 54 06 00 00       	call   89f <printf>
      workers[i].pid = pid;
 24b:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 251:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 255:	89 d0                	mov    %edx,%eax
 257:	01 c0                	add    %eax,%eax
 259:	01 d0                	add    %edx,%eax
 25b:	c1 e0 02             	shl    $0x2,%eax
 25e:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 261:	8b 44 24 28          	mov    0x28(%esp),%eax
 265:	89 02                	mov    %eax,(%edx)
      workers[i].input_x = -1;
 267:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 26d:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 271:	89 d0                	mov    %edx,%eax
 273:	01 c0                	add    %eax,%eax
 275:	01 d0                	add    %edx,%eax
 277:	c1 e0 02             	shl    $0x2,%eax
 27a:	01 c8                	add    %ecx,%eax
 27c:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
      workers[i].working = 0;
 283:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 289:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 28d:	89 d0                	mov    %edx,%eax
 28f:	01 c0                	add    %eax,%eax
 291:	01 d0                	add    %edx,%eax
 293:	c1 e0 02             	shl    $0x2,%eax
 296:	01 c8                	add    %ecx,%eax
 298:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
 29f:	eb 19                	jmp    2ba <main+0x13f>
    }
    else {                      // fork failed
      printf(1, "fork() failed!\n"); 
 2a1:	c7 44 24 04 cf 0c 00 	movl   $0xccf,0x4(%esp)
 2a8:	00 
 2a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2b0:	e8 ea 05 00 00       	call   89f <printf>
      exit();
 2b5:	e8 45 04 00 00       	call   6ff <exit>
  workers_number = atoi(argv[1]);
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
  
  sigset((void *)handle_main_sig);
  printf(1, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
 2ba:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
 2bf:	a1 08 10 00 00       	mov    0x1008,%eax
 2c4:	39 44 24 2c          	cmp    %eax,0x2c(%esp)
 2c8:	0f 8c 34 ff ff ff    	jl     202 <main+0x87>
  }

  for(;;)
  {
    //buf[MAX_INPUT];
  	printf(1, "Please enter a number: ");
 2ce:	c7 44 24 04 df 0c 00 	movl   $0xcdf,0x4(%esp)
 2d5:	00 
 2d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2dd:	e8 bd 05 00 00       	call   89f <printf>
  	gets(buf, MAX_INPUT);
 2e2:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
 2e9:	00 
 2ea:	8d 44 24 1a          	lea    0x1a(%esp),%eax
 2ee:	89 04 24             	mov    %eax,(%esp)
 2f1:	e8 b3 02 00 00       	call   5a9 <gets>
    //printf(1, "bufer is %s\n",buf);
  	if (buf[0] == 0){
 2f6:	0f b6 44 24 1a       	movzbl 0x1a(%esp),%eax
 2fb:	84 c0                	test   %al,%al
 2fd:	75 11                	jne    310 <main+0x195>
      //handle main signals by calling a system call
      sigset((void *)handle_main_sig);
 2ff:	c7 04 24 e3 00 00 00 	movl   $0xe3,(%esp)
 306:	e8 94 04 00 00       	call   79f <sigset>
      continue;
 30b:	e9 82 01 00 00       	jmp    492 <main+0x317>
    }

    input_x = atoi(buf);
 310:	8d 44 24 1a          	lea    0x1a(%esp),%eax
 314:	89 04 24             	mov    %eax,(%esp)
 317:	e8 51 03 00 00       	call   66d <atoi>
 31c:	89 44 24 24          	mov    %eax,0x24(%esp)
  	if(input_x != 0)
 320:	83 7c 24 24 00       	cmpl   $0x0,0x24(%esp)
 325:	0f 84 c7 00 00 00    	je     3f2 <main+0x277>
    {
      // find an idle process = p - TODO
      // send input_x to process p using sigsend sys-call 
      for (i = 0; i < workers_number; i++)
 32b:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
 332:	00 
 333:	e9 83 00 00 00       	jmp    3bb <main+0x240>
      {
        if (workers[i].working == 0) // available
 338:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 33e:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 342:	89 d0                	mov    %edx,%eax
 344:	01 c0                	add    %eax,%eax
 346:	01 d0                	add    %edx,%eax
 348:	c1 e0 02             	shl    $0x2,%eax
 34b:	01 c8                	add    %ecx,%eax
 34d:	8b 40 08             	mov    0x8(%eax),%eax
 350:	85 c0                	test   %eax,%eax
 352:	75 62                	jne    3b6 <main+0x23b>
        {
          workers[i].working = 1;
 354:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 35a:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 35e:	89 d0                	mov    %edx,%eax
 360:	01 c0                	add    %eax,%eax
 362:	01 d0                	add    %edx,%eax
 364:	c1 e0 02             	shl    $0x2,%eax
 367:	01 c8                	add    %ecx,%eax
 369:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
          workers[i].input_x = input_x;
 370:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 376:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 37a:	89 d0                	mov    %edx,%eax
 37c:	01 c0                	add    %eax,%eax
 37e:	01 d0                	add    %edx,%eax
 380:	c1 e0 02             	shl    $0x2,%eax
 383:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 386:	8b 44 24 24          	mov    0x24(%esp),%eax
 38a:	89 42 04             	mov    %eax,0x4(%edx)
          sigsend(workers[i].pid, input_x);  
 38d:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 393:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 397:	89 d0                	mov    %edx,%eax
 399:	01 c0                	add    %eax,%eax
 39b:	01 d0                	add    %edx,%eax
 39d:	c1 e0 02             	shl    $0x2,%eax
 3a0:	01 c8                	add    %ecx,%eax
 3a2:	8b 00                	mov    (%eax),%eax
 3a4:	8b 54 24 24          	mov    0x24(%esp),%edx
 3a8:	89 54 24 04          	mov    %edx,0x4(%esp)
 3ac:	89 04 24             	mov    %eax,(%esp)
 3af:	e8 f3 03 00 00       	call   7a7 <sigsend>
          //printf(1, "Send signal val %d to worker %d: \n", input_x, workers[i].pid);
          break;
 3b4:	eb 14                	jmp    3ca <main+0x24f>
    input_x = atoi(buf);
  	if(input_x != 0)
    {
      // find an idle process = p - TODO
      // send input_x to process p using sigsend sys-call 
      for (i = 0; i < workers_number; i++)
 3b6:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
 3bb:	a1 08 10 00 00       	mov    0x1008,%eax
 3c0:	39 44 24 2c          	cmp    %eax,0x2c(%esp)
 3c4:	0f 8c 6e ff ff ff    	jl     338 <main+0x1bd>
        }
      }
      //printf(1, "end for loop\n");

      // no idle workers to handle signal
      if (i == workers_number){
 3ca:	a1 08 10 00 00       	mov    0x1008,%eax
 3cf:	39 44 24 2c          	cmp    %eax,0x2c(%esp)
 3d3:	0f 85 b9 00 00 00    	jne    492 <main+0x317>
        printf(1, "no idle workers\n");
 3d9:	c7 44 24 04 f7 0c 00 	movl   $0xcf7,0x4(%esp)
 3e0:	00 
 3e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3e8:	e8 b2 04 00 00       	call   89f <printf>
      free(workers);
  	  printf(1, "primsrv exit\n");
  	  exit();
  	}

  }
 3ed:	e9 dc fe ff ff       	jmp    2ce <main+0x153>
    }

    else // input = 0, exiting program
  	{
      //printf(1, "ELSE\n");
  	  for (i = 0; i < workers_number; i++)
 3f2:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
 3f9:	00 
 3fa:	eb 5b                	jmp    457 <main+0x2dc>
  	  {
        sigsend(workers[i].pid, 0);
 3fc:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 402:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 406:	89 d0                	mov    %edx,%eax
 408:	01 c0                	add    %eax,%eax
 40a:	01 d0                	add    %edx,%eax
 40c:	c1 e0 02             	shl    $0x2,%eax
 40f:	01 c8                	add    %ecx,%eax
 411:	8b 00                	mov    (%eax),%eax
 413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 41a:	00 
 41b:	89 04 24             	mov    %eax,(%esp)
 41e:	e8 84 03 00 00       	call   7a7 <sigsend>
        printf(1, "worker %d exit\n", workers[i].pid);
 423:	8b 0d 0c 10 00 00    	mov    0x100c,%ecx
 429:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 42d:	89 d0                	mov    %edx,%eax
 42f:	01 c0                	add    %eax,%eax
 431:	01 d0                	add    %edx,%eax
 433:	c1 e0 02             	shl    $0x2,%eax
 436:	01 c8                	add    %ecx,%eax
 438:	8b 00                	mov    (%eax),%eax
 43a:	89 44 24 08          	mov    %eax,0x8(%esp)
 43e:	c7 44 24 04 08 0d 00 	movl   $0xd08,0x4(%esp)
 445:	00 
 446:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 44d:	e8 4d 04 00 00       	call   89f <printf>
    }

    else // input = 0, exiting program
  	{
      //printf(1, "ELSE\n");
  	  for (i = 0; i < workers_number; i++)
 452:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
 457:	a1 08 10 00 00       	mov    0x1008,%eax
 45c:	39 44 24 2c          	cmp    %eax,0x2c(%esp)
 460:	7c 9a                	jl     3fc <main+0x281>
  	  {
        sigsend(workers[i].pid, 0);
        printf(1, "worker %d exit\n", workers[i].pid);
  	  }
      //wait for all workers to exit
      while (wait() > 0);
 462:	90                   	nop
 463:	e8 9f 02 00 00       	call   707 <wait>
 468:	85 c0                	test   %eax,%eax
 46a:	7f f7                	jg     463 <main+0x2e8>
      free(workers);
 46c:	a1 0c 10 00 00       	mov    0x100c,%eax
 471:	89 04 24             	mov    %eax,(%esp)
 474:	e8 d9 05 00 00       	call   a52 <free>
  	  printf(1, "primsrv exit\n");
 479:	c7 44 24 04 18 0d 00 	movl   $0xd18,0x4(%esp)
 480:	00 
 481:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 488:	e8 12 04 00 00       	call   89f <printf>
  	  exit();
 48d:	e8 6d 02 00 00       	call   6ff <exit>
  	}

  }
 492:	e9 37 fe ff ff       	jmp    2ce <main+0x153>

00000497 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 497:	55                   	push   %ebp
 498:	89 e5                	mov    %esp,%ebp
 49a:	57                   	push   %edi
 49b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 49c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 49f:	8b 55 10             	mov    0x10(%ebp),%edx
 4a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a5:	89 cb                	mov    %ecx,%ebx
 4a7:	89 df                	mov    %ebx,%edi
 4a9:	89 d1                	mov    %edx,%ecx
 4ab:	fc                   	cld    
 4ac:	f3 aa                	rep stos %al,%es:(%edi)
 4ae:	89 ca                	mov    %ecx,%edx
 4b0:	89 fb                	mov    %edi,%ebx
 4b2:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4b5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4b8:	5b                   	pop    %ebx
 4b9:	5f                   	pop    %edi
 4ba:	5d                   	pop    %ebp
 4bb:	c3                   	ret    

000004bc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 4bc:	55                   	push   %ebp
 4bd:	89 e5                	mov    %esp,%ebp
 4bf:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4c2:	8b 45 08             	mov    0x8(%ebp),%eax
 4c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4c8:	90                   	nop
 4c9:	8b 45 08             	mov    0x8(%ebp),%eax
 4cc:	8d 50 01             	lea    0x1(%eax),%edx
 4cf:	89 55 08             	mov    %edx,0x8(%ebp)
 4d2:	8b 55 0c             	mov    0xc(%ebp),%edx
 4d5:	8d 4a 01             	lea    0x1(%edx),%ecx
 4d8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 4db:	0f b6 12             	movzbl (%edx),%edx
 4de:	88 10                	mov    %dl,(%eax)
 4e0:	0f b6 00             	movzbl (%eax),%eax
 4e3:	84 c0                	test   %al,%al
 4e5:	75 e2                	jne    4c9 <strcpy+0xd>
    ;
  return os;
 4e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4ea:	c9                   	leave  
 4eb:	c3                   	ret    

000004ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4ec:	55                   	push   %ebp
 4ed:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4ef:	eb 08                	jmp    4f9 <strcmp+0xd>
    p++, q++;
 4f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4f5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 4f9:	8b 45 08             	mov    0x8(%ebp),%eax
 4fc:	0f b6 00             	movzbl (%eax),%eax
 4ff:	84 c0                	test   %al,%al
 501:	74 10                	je     513 <strcmp+0x27>
 503:	8b 45 08             	mov    0x8(%ebp),%eax
 506:	0f b6 10             	movzbl (%eax),%edx
 509:	8b 45 0c             	mov    0xc(%ebp),%eax
 50c:	0f b6 00             	movzbl (%eax),%eax
 50f:	38 c2                	cmp    %al,%dl
 511:	74 de                	je     4f1 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 513:	8b 45 08             	mov    0x8(%ebp),%eax
 516:	0f b6 00             	movzbl (%eax),%eax
 519:	0f b6 d0             	movzbl %al,%edx
 51c:	8b 45 0c             	mov    0xc(%ebp),%eax
 51f:	0f b6 00             	movzbl (%eax),%eax
 522:	0f b6 c0             	movzbl %al,%eax
 525:	29 c2                	sub    %eax,%edx
 527:	89 d0                	mov    %edx,%eax
}
 529:	5d                   	pop    %ebp
 52a:	c3                   	ret    

0000052b <strlen>:

uint
strlen(char *s)
{
 52b:	55                   	push   %ebp
 52c:	89 e5                	mov    %esp,%ebp
 52e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 531:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 538:	eb 04                	jmp    53e <strlen+0x13>
 53a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 53e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 541:	8b 45 08             	mov    0x8(%ebp),%eax
 544:	01 d0                	add    %edx,%eax
 546:	0f b6 00             	movzbl (%eax),%eax
 549:	84 c0                	test   %al,%al
 54b:	75 ed                	jne    53a <strlen+0xf>
    ;
  return n;
 54d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 550:	c9                   	leave  
 551:	c3                   	ret    

00000552 <memset>:

void*
memset(void *dst, int c, uint n)
{
 552:	55                   	push   %ebp
 553:	89 e5                	mov    %esp,%ebp
 555:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 558:	8b 45 10             	mov    0x10(%ebp),%eax
 55b:	89 44 24 08          	mov    %eax,0x8(%esp)
 55f:	8b 45 0c             	mov    0xc(%ebp),%eax
 562:	89 44 24 04          	mov    %eax,0x4(%esp)
 566:	8b 45 08             	mov    0x8(%ebp),%eax
 569:	89 04 24             	mov    %eax,(%esp)
 56c:	e8 26 ff ff ff       	call   497 <stosb>
  return dst;
 571:	8b 45 08             	mov    0x8(%ebp),%eax
}
 574:	c9                   	leave  
 575:	c3                   	ret    

00000576 <strchr>:

char*
strchr(const char *s, char c)
{
 576:	55                   	push   %ebp
 577:	89 e5                	mov    %esp,%ebp
 579:	83 ec 04             	sub    $0x4,%esp
 57c:	8b 45 0c             	mov    0xc(%ebp),%eax
 57f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 582:	eb 14                	jmp    598 <strchr+0x22>
    if(*s == c)
 584:	8b 45 08             	mov    0x8(%ebp),%eax
 587:	0f b6 00             	movzbl (%eax),%eax
 58a:	3a 45 fc             	cmp    -0x4(%ebp),%al
 58d:	75 05                	jne    594 <strchr+0x1e>
      return (char*)s;
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	eb 13                	jmp    5a7 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 594:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	0f b6 00             	movzbl (%eax),%eax
 59e:	84 c0                	test   %al,%al
 5a0:	75 e2                	jne    584 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 5a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5a7:	c9                   	leave  
 5a8:	c3                   	ret    

000005a9 <gets>:

char*
gets(char *buf, int max)
{
 5a9:	55                   	push   %ebp
 5aa:	89 e5                	mov    %esp,%ebp
 5ac:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5b6:	eb 4c                	jmp    604 <gets+0x5b>
    cc = read(0, &c, 1);
 5b8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5bf:	00 
 5c0:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 5ce:	e8 44 01 00 00       	call   717 <read>
 5d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5da:	7f 02                	jg     5de <gets+0x35>
      break;
 5dc:	eb 31                	jmp    60f <gets+0x66>
    buf[i++] = c;
 5de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e1:	8d 50 01             	lea    0x1(%eax),%edx
 5e4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5e7:	89 c2                	mov    %eax,%edx
 5e9:	8b 45 08             	mov    0x8(%ebp),%eax
 5ec:	01 c2                	add    %eax,%edx
 5ee:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5f2:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 5f4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5f8:	3c 0a                	cmp    $0xa,%al
 5fa:	74 13                	je     60f <gets+0x66>
 5fc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 600:	3c 0d                	cmp    $0xd,%al
 602:	74 0b                	je     60f <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 604:	8b 45 f4             	mov    -0xc(%ebp),%eax
 607:	83 c0 01             	add    $0x1,%eax
 60a:	3b 45 0c             	cmp    0xc(%ebp),%eax
 60d:	7c a9                	jl     5b8 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 60f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 612:	8b 45 08             	mov    0x8(%ebp),%eax
 615:	01 d0                	add    %edx,%eax
 617:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 61a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 61d:	c9                   	leave  
 61e:	c3                   	ret    

0000061f <stat>:

int
stat(char *n, struct stat *st)
{
 61f:	55                   	push   %ebp
 620:	89 e5                	mov    %esp,%ebp
 622:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 625:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 62c:	00 
 62d:	8b 45 08             	mov    0x8(%ebp),%eax
 630:	89 04 24             	mov    %eax,(%esp)
 633:	e8 07 01 00 00       	call   73f <open>
 638:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 63b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 63f:	79 07                	jns    648 <stat+0x29>
    return -1;
 641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 646:	eb 23                	jmp    66b <stat+0x4c>
  r = fstat(fd, st);
 648:	8b 45 0c             	mov    0xc(%ebp),%eax
 64b:	89 44 24 04          	mov    %eax,0x4(%esp)
 64f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 652:	89 04 24             	mov    %eax,(%esp)
 655:	e8 fd 00 00 00       	call   757 <fstat>
 65a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 65d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 660:	89 04 24             	mov    %eax,(%esp)
 663:	e8 bf 00 00 00       	call   727 <close>
  return r;
 668:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 66b:	c9                   	leave  
 66c:	c3                   	ret    

0000066d <atoi>:

int
atoi(const char *s)
{
 66d:	55                   	push   %ebp
 66e:	89 e5                	mov    %esp,%ebp
 670:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 673:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 67a:	eb 25                	jmp    6a1 <atoi+0x34>
    n = n*10 + *s++ - '0';
 67c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 67f:	89 d0                	mov    %edx,%eax
 681:	c1 e0 02             	shl    $0x2,%eax
 684:	01 d0                	add    %edx,%eax
 686:	01 c0                	add    %eax,%eax
 688:	89 c1                	mov    %eax,%ecx
 68a:	8b 45 08             	mov    0x8(%ebp),%eax
 68d:	8d 50 01             	lea    0x1(%eax),%edx
 690:	89 55 08             	mov    %edx,0x8(%ebp)
 693:	0f b6 00             	movzbl (%eax),%eax
 696:	0f be c0             	movsbl %al,%eax
 699:	01 c8                	add    %ecx,%eax
 69b:	83 e8 30             	sub    $0x30,%eax
 69e:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6a1:	8b 45 08             	mov    0x8(%ebp),%eax
 6a4:	0f b6 00             	movzbl (%eax),%eax
 6a7:	3c 2f                	cmp    $0x2f,%al
 6a9:	7e 0a                	jle    6b5 <atoi+0x48>
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
 6ae:	0f b6 00             	movzbl (%eax),%eax
 6b1:	3c 39                	cmp    $0x39,%al
 6b3:	7e c7                	jle    67c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6b8:	c9                   	leave  
 6b9:	c3                   	ret    

000006ba <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 6ba:	55                   	push   %ebp
 6bb:	89 e5                	mov    %esp,%ebp
 6bd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 6c0:	8b 45 08             	mov    0x8(%ebp),%eax
 6c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6cc:	eb 17                	jmp    6e5 <memmove+0x2b>
    *dst++ = *src++;
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	8d 50 01             	lea    0x1(%eax),%edx
 6d4:	89 55 fc             	mov    %edx,-0x4(%ebp)
 6d7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6da:	8d 4a 01             	lea    0x1(%edx),%ecx
 6dd:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 6e0:	0f b6 12             	movzbl (%edx),%edx
 6e3:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 6e5:	8b 45 10             	mov    0x10(%ebp),%eax
 6e8:	8d 50 ff             	lea    -0x1(%eax),%edx
 6eb:	89 55 10             	mov    %edx,0x10(%ebp)
 6ee:	85 c0                	test   %eax,%eax
 6f0:	7f dc                	jg     6ce <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 6f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6f5:	c9                   	leave  
 6f6:	c3                   	ret    

000006f7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 6f7:	b8 01 00 00 00       	mov    $0x1,%eax
 6fc:	cd 40                	int    $0x40
 6fe:	c3                   	ret    

000006ff <exit>:
SYSCALL(exit)
 6ff:	b8 02 00 00 00       	mov    $0x2,%eax
 704:	cd 40                	int    $0x40
 706:	c3                   	ret    

00000707 <wait>:
SYSCALL(wait)
 707:	b8 03 00 00 00       	mov    $0x3,%eax
 70c:	cd 40                	int    $0x40
 70e:	c3                   	ret    

0000070f <pipe>:
SYSCALL(pipe)
 70f:	b8 04 00 00 00       	mov    $0x4,%eax
 714:	cd 40                	int    $0x40
 716:	c3                   	ret    

00000717 <read>:
SYSCALL(read)
 717:	b8 05 00 00 00       	mov    $0x5,%eax
 71c:	cd 40                	int    $0x40
 71e:	c3                   	ret    

0000071f <write>:
SYSCALL(write)
 71f:	b8 10 00 00 00       	mov    $0x10,%eax
 724:	cd 40                	int    $0x40
 726:	c3                   	ret    

00000727 <close>:
SYSCALL(close)
 727:	b8 15 00 00 00       	mov    $0x15,%eax
 72c:	cd 40                	int    $0x40
 72e:	c3                   	ret    

0000072f <kill>:
SYSCALL(kill)
 72f:	b8 06 00 00 00       	mov    $0x6,%eax
 734:	cd 40                	int    $0x40
 736:	c3                   	ret    

00000737 <exec>:
SYSCALL(exec)
 737:	b8 07 00 00 00       	mov    $0x7,%eax
 73c:	cd 40                	int    $0x40
 73e:	c3                   	ret    

0000073f <open>:
SYSCALL(open)
 73f:	b8 0f 00 00 00       	mov    $0xf,%eax
 744:	cd 40                	int    $0x40
 746:	c3                   	ret    

00000747 <mknod>:
SYSCALL(mknod)
 747:	b8 11 00 00 00       	mov    $0x11,%eax
 74c:	cd 40                	int    $0x40
 74e:	c3                   	ret    

0000074f <unlink>:
SYSCALL(unlink)
 74f:	b8 12 00 00 00       	mov    $0x12,%eax
 754:	cd 40                	int    $0x40
 756:	c3                   	ret    

00000757 <fstat>:
SYSCALL(fstat)
 757:	b8 08 00 00 00       	mov    $0x8,%eax
 75c:	cd 40                	int    $0x40
 75e:	c3                   	ret    

0000075f <link>:
SYSCALL(link)
 75f:	b8 13 00 00 00       	mov    $0x13,%eax
 764:	cd 40                	int    $0x40
 766:	c3                   	ret    

00000767 <mkdir>:
SYSCALL(mkdir)
 767:	b8 14 00 00 00       	mov    $0x14,%eax
 76c:	cd 40                	int    $0x40
 76e:	c3                   	ret    

0000076f <chdir>:
SYSCALL(chdir)
 76f:	b8 09 00 00 00       	mov    $0x9,%eax
 774:	cd 40                	int    $0x40
 776:	c3                   	ret    

00000777 <dup>:
SYSCALL(dup)
 777:	b8 0a 00 00 00       	mov    $0xa,%eax
 77c:	cd 40                	int    $0x40
 77e:	c3                   	ret    

0000077f <getpid>:
SYSCALL(getpid)
 77f:	b8 0b 00 00 00       	mov    $0xb,%eax
 784:	cd 40                	int    $0x40
 786:	c3                   	ret    

00000787 <sbrk>:
SYSCALL(sbrk)
 787:	b8 0c 00 00 00       	mov    $0xc,%eax
 78c:	cd 40                	int    $0x40
 78e:	c3                   	ret    

0000078f <sleep>:
SYSCALL(sleep)
 78f:	b8 0d 00 00 00       	mov    $0xd,%eax
 794:	cd 40                	int    $0x40
 796:	c3                   	ret    

00000797 <uptime>:
SYSCALL(uptime)
 797:	b8 0e 00 00 00       	mov    $0xe,%eax
 79c:	cd 40                	int    $0x40
 79e:	c3                   	ret    

0000079f <sigset>:
SYSCALL(sigset)
 79f:	b8 16 00 00 00       	mov    $0x16,%eax
 7a4:	cd 40                	int    $0x40
 7a6:	c3                   	ret    

000007a7 <sigsend>:
SYSCALL(sigsend)
 7a7:	b8 17 00 00 00       	mov    $0x17,%eax
 7ac:	cd 40                	int    $0x40
 7ae:	c3                   	ret    

000007af <sigret>:
SYSCALL(sigret)
 7af:	b8 18 00 00 00       	mov    $0x18,%eax
 7b4:	cd 40                	int    $0x40
 7b6:	c3                   	ret    

000007b7 <sigpause>:
 7b7:	b8 19 00 00 00       	mov    $0x19,%eax
 7bc:	cd 40                	int    $0x40
 7be:	c3                   	ret    

000007bf <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 7bf:	55                   	push   %ebp
 7c0:	89 e5                	mov    %esp,%ebp
 7c2:	83 ec 18             	sub    $0x18,%esp
 7c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 7c8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 7cb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7d2:	00 
 7d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
 7d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7da:	8b 45 08             	mov    0x8(%ebp),%eax
 7dd:	89 04 24             	mov    %eax,(%esp)
 7e0:	e8 3a ff ff ff       	call   71f <write>
}
 7e5:	c9                   	leave  
 7e6:	c3                   	ret    

000007e7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7e7:	55                   	push   %ebp
 7e8:	89 e5                	mov    %esp,%ebp
 7ea:	56                   	push   %esi
 7eb:	53                   	push   %ebx
 7ec:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7f6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7fa:	74 17                	je     813 <printint+0x2c>
 7fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 800:	79 11                	jns    813 <printint+0x2c>
    neg = 1;
 802:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 809:	8b 45 0c             	mov    0xc(%ebp),%eax
 80c:	f7 d8                	neg    %eax
 80e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 811:	eb 06                	jmp    819 <printint+0x32>
  } else {
    x = xx;
 813:	8b 45 0c             	mov    0xc(%ebp),%eax
 816:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 819:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 820:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 823:	8d 41 01             	lea    0x1(%ecx),%eax
 826:	89 45 f4             	mov    %eax,-0xc(%ebp)
 829:	8b 5d 10             	mov    0x10(%ebp),%ebx
 82c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 82f:	ba 00 00 00 00       	mov    $0x0,%edx
 834:	f7 f3                	div    %ebx
 836:	89 d0                	mov    %edx,%eax
 838:	0f b6 80 f4 0f 00 00 	movzbl 0xff4(%eax),%eax
 83f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 843:	8b 75 10             	mov    0x10(%ebp),%esi
 846:	8b 45 ec             	mov    -0x14(%ebp),%eax
 849:	ba 00 00 00 00       	mov    $0x0,%edx
 84e:	f7 f6                	div    %esi
 850:	89 45 ec             	mov    %eax,-0x14(%ebp)
 853:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 857:	75 c7                	jne    820 <printint+0x39>
  if(neg)
 859:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 85d:	74 10                	je     86f <printint+0x88>
    buf[i++] = '-';
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	8d 50 01             	lea    0x1(%eax),%edx
 865:	89 55 f4             	mov    %edx,-0xc(%ebp)
 868:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 86d:	eb 1f                	jmp    88e <printint+0xa7>
 86f:	eb 1d                	jmp    88e <printint+0xa7>
    putc(fd, buf[i]);
 871:	8d 55 dc             	lea    -0x24(%ebp),%edx
 874:	8b 45 f4             	mov    -0xc(%ebp),%eax
 877:	01 d0                	add    %edx,%eax
 879:	0f b6 00             	movzbl (%eax),%eax
 87c:	0f be c0             	movsbl %al,%eax
 87f:	89 44 24 04          	mov    %eax,0x4(%esp)
 883:	8b 45 08             	mov    0x8(%ebp),%eax
 886:	89 04 24             	mov    %eax,(%esp)
 889:	e8 31 ff ff ff       	call   7bf <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 88e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 892:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 896:	79 d9                	jns    871 <printint+0x8a>
    putc(fd, buf[i]);
}
 898:	83 c4 30             	add    $0x30,%esp
 89b:	5b                   	pop    %ebx
 89c:	5e                   	pop    %esi
 89d:	5d                   	pop    %ebp
 89e:	c3                   	ret    

0000089f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 89f:	55                   	push   %ebp
 8a0:	89 e5                	mov    %esp,%ebp
 8a2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 8a5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 8ac:	8d 45 0c             	lea    0xc(%ebp),%eax
 8af:	83 c0 04             	add    $0x4,%eax
 8b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 8b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8bc:	e9 7c 01 00 00       	jmp    a3d <printf+0x19e>
    c = fmt[i] & 0xff;
 8c1:	8b 55 0c             	mov    0xc(%ebp),%edx
 8c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c7:	01 d0                	add    %edx,%eax
 8c9:	0f b6 00             	movzbl (%eax),%eax
 8cc:	0f be c0             	movsbl %al,%eax
 8cf:	25 ff 00 00 00       	and    $0xff,%eax
 8d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 8d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8db:	75 2c                	jne    909 <printf+0x6a>
      if(c == '%'){
 8dd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8e1:	75 0c                	jne    8ef <printf+0x50>
        state = '%';
 8e3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8ea:	e9 4a 01 00 00       	jmp    a39 <printf+0x19a>
      } else {
        putc(fd, c);
 8ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8f2:	0f be c0             	movsbl %al,%eax
 8f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f9:	8b 45 08             	mov    0x8(%ebp),%eax
 8fc:	89 04 24             	mov    %eax,(%esp)
 8ff:	e8 bb fe ff ff       	call   7bf <putc>
 904:	e9 30 01 00 00       	jmp    a39 <printf+0x19a>
      }
    } else if(state == '%'){
 909:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 90d:	0f 85 26 01 00 00    	jne    a39 <printf+0x19a>
      if(c == 'd'){
 913:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 917:	75 2d                	jne    946 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 919:	8b 45 e8             	mov    -0x18(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 925:	00 
 926:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 92d:	00 
 92e:	89 44 24 04          	mov    %eax,0x4(%esp)
 932:	8b 45 08             	mov    0x8(%ebp),%eax
 935:	89 04 24             	mov    %eax,(%esp)
 938:	e8 aa fe ff ff       	call   7e7 <printint>
        ap++;
 93d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 941:	e9 ec 00 00 00       	jmp    a32 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 946:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 94a:	74 06                	je     952 <printf+0xb3>
 94c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 950:	75 2d                	jne    97f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 952:	8b 45 e8             	mov    -0x18(%ebp),%eax
 955:	8b 00                	mov    (%eax),%eax
 957:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 95e:	00 
 95f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 966:	00 
 967:	89 44 24 04          	mov    %eax,0x4(%esp)
 96b:	8b 45 08             	mov    0x8(%ebp),%eax
 96e:	89 04 24             	mov    %eax,(%esp)
 971:	e8 71 fe ff ff       	call   7e7 <printint>
        ap++;
 976:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 97a:	e9 b3 00 00 00       	jmp    a32 <printf+0x193>
      } else if(c == 's'){
 97f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 983:	75 45                	jne    9ca <printf+0x12b>
        s = (char*)*ap;
 985:	8b 45 e8             	mov    -0x18(%ebp),%eax
 988:	8b 00                	mov    (%eax),%eax
 98a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 98d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 991:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 995:	75 09                	jne    9a0 <printf+0x101>
          s = "(null)";
 997:	c7 45 f4 26 0d 00 00 	movl   $0xd26,-0xc(%ebp)
        while(*s != 0){
 99e:	eb 1e                	jmp    9be <printf+0x11f>
 9a0:	eb 1c                	jmp    9be <printf+0x11f>
          putc(fd, *s);
 9a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a5:	0f b6 00             	movzbl (%eax),%eax
 9a8:	0f be c0             	movsbl %al,%eax
 9ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 9af:	8b 45 08             	mov    0x8(%ebp),%eax
 9b2:	89 04 24             	mov    %eax,(%esp)
 9b5:	e8 05 fe ff ff       	call   7bf <putc>
          s++;
 9ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c1:	0f b6 00             	movzbl (%eax),%eax
 9c4:	84 c0                	test   %al,%al
 9c6:	75 da                	jne    9a2 <printf+0x103>
 9c8:	eb 68                	jmp    a32 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 9ca:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 9ce:	75 1d                	jne    9ed <printf+0x14e>
        putc(fd, *ap);
 9d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9d3:	8b 00                	mov    (%eax),%eax
 9d5:	0f be c0             	movsbl %al,%eax
 9d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 9dc:	8b 45 08             	mov    0x8(%ebp),%eax
 9df:	89 04 24             	mov    %eax,(%esp)
 9e2:	e8 d8 fd ff ff       	call   7bf <putc>
        ap++;
 9e7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9eb:	eb 45                	jmp    a32 <printf+0x193>
      } else if(c == '%'){
 9ed:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9f1:	75 17                	jne    a0a <printf+0x16b>
        putc(fd, c);
 9f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9f6:	0f be c0             	movsbl %al,%eax
 9f9:	89 44 24 04          	mov    %eax,0x4(%esp)
 9fd:	8b 45 08             	mov    0x8(%ebp),%eax
 a00:	89 04 24             	mov    %eax,(%esp)
 a03:	e8 b7 fd ff ff       	call   7bf <putc>
 a08:	eb 28                	jmp    a32 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a0a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a11:	00 
 a12:	8b 45 08             	mov    0x8(%ebp),%eax
 a15:	89 04 24             	mov    %eax,(%esp)
 a18:	e8 a2 fd ff ff       	call   7bf <putc>
        putc(fd, c);
 a1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a20:	0f be c0             	movsbl %al,%eax
 a23:	89 44 24 04          	mov    %eax,0x4(%esp)
 a27:	8b 45 08             	mov    0x8(%ebp),%eax
 a2a:	89 04 24             	mov    %eax,(%esp)
 a2d:	e8 8d fd ff ff       	call   7bf <putc>
      }
      state = 0;
 a32:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 a39:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a3d:	8b 55 0c             	mov    0xc(%ebp),%edx
 a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a43:	01 d0                	add    %edx,%eax
 a45:	0f b6 00             	movzbl (%eax),%eax
 a48:	84 c0                	test   %al,%al
 a4a:	0f 85 71 fe ff ff    	jne    8c1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 a50:	c9                   	leave  
 a51:	c3                   	ret    

00000a52 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a52:	55                   	push   %ebp
 a53:	89 e5                	mov    %esp,%ebp
 a55:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a58:	8b 45 08             	mov    0x8(%ebp),%eax
 a5b:	83 e8 08             	sub    $0x8,%eax
 a5e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a61:	a1 18 10 00 00       	mov    0x1018,%eax
 a66:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a69:	eb 24                	jmp    a8f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a6e:	8b 00                	mov    (%eax),%eax
 a70:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a73:	77 12                	ja     a87 <free+0x35>
 a75:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a78:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a7b:	77 24                	ja     aa1 <free+0x4f>
 a7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a80:	8b 00                	mov    (%eax),%eax
 a82:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a85:	77 1a                	ja     aa1 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a87:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a8a:	8b 00                	mov    (%eax),%eax
 a8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a8f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a92:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a95:	76 d4                	jbe    a6b <free+0x19>
 a97:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a9a:	8b 00                	mov    (%eax),%eax
 a9c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a9f:	76 ca                	jbe    a6b <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 aa1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aa4:	8b 40 04             	mov    0x4(%eax),%eax
 aa7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 aae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab1:	01 c2                	add    %eax,%edx
 ab3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab6:	8b 00                	mov    (%eax),%eax
 ab8:	39 c2                	cmp    %eax,%edx
 aba:	75 24                	jne    ae0 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 abc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 abf:	8b 50 04             	mov    0x4(%eax),%edx
 ac2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac5:	8b 00                	mov    (%eax),%eax
 ac7:	8b 40 04             	mov    0x4(%eax),%eax
 aca:	01 c2                	add    %eax,%edx
 acc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 acf:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 ad2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad5:	8b 00                	mov    (%eax),%eax
 ad7:	8b 10                	mov    (%eax),%edx
 ad9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 adc:	89 10                	mov    %edx,(%eax)
 ade:	eb 0a                	jmp    aea <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae3:	8b 10                	mov    (%eax),%edx
 ae5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae8:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 aea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aed:	8b 40 04             	mov    0x4(%eax),%eax
 af0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 af7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 afa:	01 d0                	add    %edx,%eax
 afc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 aff:	75 20                	jne    b21 <free+0xcf>
    p->s.size += bp->s.size;
 b01:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b04:	8b 50 04             	mov    0x4(%eax),%edx
 b07:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b0a:	8b 40 04             	mov    0x4(%eax),%eax
 b0d:	01 c2                	add    %eax,%edx
 b0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b12:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b15:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b18:	8b 10                	mov    (%eax),%edx
 b1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b1d:	89 10                	mov    %edx,(%eax)
 b1f:	eb 08                	jmp    b29 <free+0xd7>
  } else
    p->s.ptr = bp;
 b21:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b24:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b27:	89 10                	mov    %edx,(%eax)
  freep = p;
 b29:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b2c:	a3 18 10 00 00       	mov    %eax,0x1018
}
 b31:	c9                   	leave  
 b32:	c3                   	ret    

00000b33 <morecore>:

static Header*
morecore(uint nu)
{
 b33:	55                   	push   %ebp
 b34:	89 e5                	mov    %esp,%ebp
 b36:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b39:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b40:	77 07                	ja     b49 <morecore+0x16>
    nu = 4096;
 b42:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b49:	8b 45 08             	mov    0x8(%ebp),%eax
 b4c:	c1 e0 03             	shl    $0x3,%eax
 b4f:	89 04 24             	mov    %eax,(%esp)
 b52:	e8 30 fc ff ff       	call   787 <sbrk>
 b57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b5a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b5e:	75 07                	jne    b67 <morecore+0x34>
    return 0;
 b60:	b8 00 00 00 00       	mov    $0x0,%eax
 b65:	eb 22                	jmp    b89 <morecore+0x56>
  hp = (Header*)p;
 b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b70:	8b 55 08             	mov    0x8(%ebp),%edx
 b73:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b79:	83 c0 08             	add    $0x8,%eax
 b7c:	89 04 24             	mov    %eax,(%esp)
 b7f:	e8 ce fe ff ff       	call   a52 <free>
  return freep;
 b84:	a1 18 10 00 00       	mov    0x1018,%eax
}
 b89:	c9                   	leave  
 b8a:	c3                   	ret    

00000b8b <malloc>:

void*
malloc(uint nbytes)
{
 b8b:	55                   	push   %ebp
 b8c:	89 e5                	mov    %esp,%ebp
 b8e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b91:	8b 45 08             	mov    0x8(%ebp),%eax
 b94:	83 c0 07             	add    $0x7,%eax
 b97:	c1 e8 03             	shr    $0x3,%eax
 b9a:	83 c0 01             	add    $0x1,%eax
 b9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 ba0:	a1 18 10 00 00       	mov    0x1018,%eax
 ba5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ba8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 bac:	75 23                	jne    bd1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 bae:	c7 45 f0 10 10 00 00 	movl   $0x1010,-0x10(%ebp)
 bb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bb8:	a3 18 10 00 00       	mov    %eax,0x1018
 bbd:	a1 18 10 00 00       	mov    0x1018,%eax
 bc2:	a3 10 10 00 00       	mov    %eax,0x1010
    base.s.size = 0;
 bc7:	c7 05 14 10 00 00 00 	movl   $0x0,0x1014
 bce:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bd4:	8b 00                	mov    (%eax),%eax
 bd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bdc:	8b 40 04             	mov    0x4(%eax),%eax
 bdf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 be2:	72 4d                	jb     c31 <malloc+0xa6>
      if(p->s.size == nunits)
 be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be7:	8b 40 04             	mov    0x4(%eax),%eax
 bea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 bed:	75 0c                	jne    bfb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bf2:	8b 10                	mov    (%eax),%edx
 bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf7:	89 10                	mov    %edx,(%eax)
 bf9:	eb 26                	jmp    c21 <malloc+0x96>
      else {
        p->s.size -= nunits;
 bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bfe:	8b 40 04             	mov    0x4(%eax),%eax
 c01:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c04:	89 c2                	mov    %eax,%edx
 c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c09:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c0f:	8b 40 04             	mov    0x4(%eax),%eax
 c12:	c1 e0 03             	shl    $0x3,%eax
 c15:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c1b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c1e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c24:	a3 18 10 00 00       	mov    %eax,0x1018
      return (void*)(p + 1);
 c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c2c:	83 c0 08             	add    $0x8,%eax
 c2f:	eb 38                	jmp    c69 <malloc+0xde>
    }
    if(p == freep)
 c31:	a1 18 10 00 00       	mov    0x1018,%eax
 c36:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c39:	75 1b                	jne    c56 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 c3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 c3e:	89 04 24             	mov    %eax,(%esp)
 c41:	e8 ed fe ff ff       	call   b33 <morecore>
 c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c4d:	75 07                	jne    c56 <malloc+0xcb>
        return 0;
 c4f:	b8 00 00 00 00       	mov    $0x0,%eax
 c54:	eb 13                	jmp    c69 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c59:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5f:	8b 00                	mov    (%eax),%eax
 c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 c64:	e9 70 ff ff ff       	jmp    bd9 <malloc+0x4e>
}
 c69:	c9                   	leave  
 c6a:	c3                   	ret    
