
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
  1a:	eb 32                	jmp    4e <is_prime+0x4e>
    else  //odd
    {       
      int i;
      for (i = 3; i*i <= num; i+=2){
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
  37:	eb 15                	jmp    4e <is_prime+0x4e>
    if((num & 1)==0)      //even - only 2 is prime
        return num == 2;
    else  //odd
    {       
      int i;
      for (i = 3; i*i <= num; i+=2){
  39:	83 45 fc 02          	addl   $0x2,-0x4(%ebp)
  3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  40:	0f af 45 fc          	imul   -0x4(%ebp),%eax
  44:	3b 45 08             	cmp    0x8(%ebp),%eax
  47:	7e dc                	jle    25 <is_prime+0x25>
          if (num % i == 0)
              return 0;
      }
    }
    return 1;
  49:	b8 01 00 00 00       	mov    $0x1,%eax
}
  4e:	c9                   	leave  
  4f:	c3                   	ret    

00000050 <next_pr>:

//get a number x and return the first prime number that is larger than x
int 
next_pr(int num)
{
  50:	55                   	push   %ebp
  51:	89 e5                	mov    %esp,%ebp
  53:	83 ec 18             	sub    $0x18,%esp
    if(num < 2)
  56:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  5a:	7f 07                	jg     63 <next_pr+0x13>
        return 2;
  5c:	b8 02 00 00 00       	mov    $0x2,%eax
  61:	eb 4a                	jmp    ad <next_pr+0x5d>
    else if (num == 2)
  63:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  67:	75 07                	jne    70 <next_pr+0x20>
        return 3;
  69:	b8 03 00 00 00       	mov    $0x3,%eax
  6e:	eb 3d                	jmp    ad <next_pr+0x5d>
    else if(num & 1){ // odd 
  70:	8b 45 08             	mov    0x8(%ebp),%eax
  73:	83 e0 01             	and    $0x1,%eax
  76:	85 c0                	test   %eax,%eax
  78:	74 25                	je     9f <next_pr+0x4f>
        num += 2;
  7a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
        return is_prime(num) ? num : next_pr(num);
  7e:	8b 45 08             	mov    0x8(%ebp),%eax
  81:	89 04 24             	mov    %eax,(%esp)
  84:	e8 77 ff ff ff       	call   0 <is_prime>
  89:	85 c0                	test   %eax,%eax
  8b:	75 0d                	jne    9a <next_pr+0x4a>
  8d:	8b 45 08             	mov    0x8(%ebp),%eax
  90:	89 04 24             	mov    %eax,(%esp)
  93:	e8 b8 ff ff ff       	call   50 <next_pr>
  98:	eb 03                	jmp    9d <next_pr+0x4d>
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	eb 0e                	jmp    ad <next_pr+0x5d>
    } 
    else              // even 
        return next_pr(num-1);  //become odd and return next_pr
  9f:	8b 45 08             	mov    0x8(%ebp),%eax
  a2:	83 e8 01             	sub    $0x1,%eax
  a5:	89 04 24             	mov    %eax,(%esp)
  a8:	e8 a3 ff ff ff       	call   50 <next_pr>
}
  ad:	c9                   	leave  
  ae:	c3                   	ret    

000000af <handle_worker_sig>:

void 
handle_worker_sig(int main_pid, int value)
{
  af:	55                   	push   %ebp
  b0:	89 e5                	mov    %esp,%ebp
  b2:	83 ec 28             	sub    $0x28,%esp
  if (value == 0) {
  b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  b9:	75 05                	jne    c0 <handle_worker_sig+0x11>
    exit();
  bb:	e8 3a 07 00 00       	call   7fa <exit>
  }

  // get next prime
  int c = next_pr(value); 
  c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  c3:	89 04 24             	mov    %eax,(%esp)
  c6:	e8 85 ff ff ff       	call   50 <next_pr>
  cb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //return result to main proccess
  while (sigsend(main_pid, c) != 0);
  ce:	90                   	nop
  cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  d6:	8b 45 08             	mov    0x8(%ebp),%eax
  d9:	89 04 24             	mov    %eax,(%esp)
  dc:	e8 c1 07 00 00       	call   8a2 <sigsend>
  e1:	85 c0                	test   %eax,%eax
  e3:	75 ea                	jne    cf <handle_worker_sig+0x20>
}
  e5:	c9                   	leave  
  e6:	c3                   	ret    

000000e7 <handle_main_sig>:
  
void
handle_main_sig(int worker_pid, int value)
{
  e7:	55                   	push   %ebp
  e8:	89 e5                	mov    %esp,%ebp
  ea:	83 ec 38             	sub    $0x38,%esp
  int i;
  for (i = 0; i < workers_number; i++) {
  ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  f4:	eb 79                	jmp    16f <handle_main_sig+0x88>
    if (workers[i].pid == worker_pid){
  f6:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
  fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ff:	89 d0                	mov    %edx,%eax
 101:	01 c0                	add    %eax,%eax
 103:	01 d0                	add    %edx,%eax
 105:	c1 e0 02             	shl    $0x2,%eax
 108:	01 c8                	add    %ecx,%eax
 10a:	8b 00                	mov    (%eax),%eax
 10c:	3b 45 08             	cmp    0x8(%ebp),%eax
 10f:	75 5a                	jne    16b <handle_main_sig+0x84>
      printf(STDOUT, "worker %d returned %d as a result for %d\n", worker_pid, value, workers[i].input_x);
 111:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 117:	8b 55 f4             	mov    -0xc(%ebp),%edx
 11a:	89 d0                	mov    %edx,%eax
 11c:	01 c0                	add    %eax,%eax
 11e:	01 d0                	add    %edx,%eax
 120:	c1 e0 02             	shl    $0x2,%eax
 123:	01 c8                	add    %ecx,%eax
 125:	8b 40 04             	mov    0x4(%eax),%eax
 128:	89 44 24 10          	mov    %eax,0x10(%esp)
 12c:	8b 45 0c             	mov    0xc(%ebp),%eax
 12f:	89 44 24 0c          	mov    %eax,0xc(%esp)
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	89 44 24 08          	mov    %eax,0x8(%esp)
 13a:	c7 44 24 04 68 0d 00 	movl   $0xd68,0x4(%esp)
 141:	00 
 142:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 149:	e8 4c 08 00 00       	call   99a <printf>
      workers[i].working = 0;
 14e:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 154:	8b 55 f4             	mov    -0xc(%ebp),%edx
 157:	89 d0                	mov    %edx,%eax
 159:	01 c0                	add    %eax,%eax
 15b:	01 d0                	add    %edx,%eax
 15d:	c1 e0 02             	shl    $0x2,%eax
 160:	01 c8                	add    %ecx,%eax
 162:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      break;
 169:	eb 12                	jmp    17d <handle_main_sig+0x96>
  
void
handle_main_sig(int worker_pid, int value)
{
  int i;
  for (i = 0; i < workers_number; i++) {
 16b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 16f:	a1 30 11 00 00       	mov    0x1130,%eax
 174:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 177:	0f 8c 79 ff ff ff    	jl     f6 <handle_main_sig+0xf>
      printf(STDOUT, "worker %d returned %d as a result for %d\n", worker_pid, value, workers[i].input_x);
      workers[i].working = 0;
      break;
    }
  }
}
 17d:	c9                   	leave  
 17e:	c3                   	ret    

0000017f <main>:

int
main(int argc, char *argv[])
{
 17f:	55                   	push   %ebp
 180:	89 e5                	mov    %esp,%ebp
 182:	53                   	push   %ebx
 183:	83 e4 f0             	and    $0xfffffff0,%esp
 186:	81 ec 90 00 00 00    	sub    $0x90,%esp
  int i, pid, input_x, bob;
  int toRun = 1;
 18c:	c7 84 24 84 00 00 00 	movl   $0x1,0x84(%esp)
 193:	01 00 00 00 
  char buf[MAX_INPUT];

  // validate arguments
  if (argc != 2) {
 197:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 19b:	74 19                	je     1b6 <main+0x37>
    printf(STDOUT, "Unvaild parameter for primsrv test\n");
 19d:	c7 44 24 04 94 0d 00 	movl   $0xd94,0x4(%esp)
 1a4:	00 
 1a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1ac:	e8 e9 07 00 00       	call   99a <printf>
    exit();
 1b1:	e8 44 06 00 00       	call   7fa <exit>
  }

  // allocate workers array
  workers_number = atoi(argv[1]);
 1b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b9:	83 c0 04             	add    $0x4,%eax
 1bc:	8b 00                	mov    (%eax),%eax
 1be:	89 04 24             	mov    %eax,(%esp)
 1c1:	e8 a2 05 00 00       	call   768 <atoi>
 1c6:	a3 30 11 00 00       	mov    %eax,0x1130
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
 1cb:	a1 30 11 00 00       	mov    0x1130,%eax
 1d0:	89 c2                	mov    %eax,%edx
 1d2:	89 d0                	mov    %edx,%eax
 1d4:	01 c0                	add    %eax,%eax
 1d6:	01 d0                	add    %edx,%eax
 1d8:	c1 e0 02             	shl    $0x2,%eax
 1db:	89 04 24             	mov    %eax,(%esp)
 1de:	e8 a3 0a 00 00       	call   c86 <malloc>
 1e3:	a3 34 11 00 00       	mov    %eax,0x1134
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
 1e8:	c7 04 24 af 00 00 00 	movl   $0xaf,(%esp)
 1ef:	e8 a6 06 00 00       	call   89a <sigset>
  printf(STDOUT, "workers pids:\n");
 1f4:	c7 44 24 04 b8 0d 00 	movl   $0xdb8,0x4(%esp)
 1fb:	00 
 1fc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 203:	e8 92 07 00 00       	call   99a <printf>
  for(i = 0; i < workers_number; i++) {
 208:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 20f:	00 00 00 00 
 213:	e9 cd 00 00 00       	jmp    2e5 <main+0x166>
    
    if ((pid = fork()) == 0) {  // son
 218:	e8 d5 05 00 00       	call   7f2 <fork>
 21d:	89 84 24 80 00 00 00 	mov    %eax,0x80(%esp)
 224:	83 bc 24 80 00 00 00 	cmpl   $0x0,0x80(%esp)
 22b:	00 
 22c:	75 07                	jne    235 <main+0xb6>
      while(1) sigpause();
 22e:	e8 7f 06 00 00       	call   8b2 <sigpause>
 233:	eb f9                	jmp    22e <main+0xaf>
    }
    else if (pid > 0) {         // father
 235:	83 bc 24 80 00 00 00 	cmpl   $0x0,0x80(%esp)
 23c:	00 
 23d:	0f 8e 89 00 00 00    	jle    2cc <main+0x14d>
      //init son worker_s 
      printf(STDOUT, "%d\n", pid);  
 243:	8b 84 24 80 00 00 00 	mov    0x80(%esp),%eax
 24a:	89 44 24 08          	mov    %eax,0x8(%esp)
 24e:	c7 44 24 04 c7 0d 00 	movl   $0xdc7,0x4(%esp)
 255:	00 
 256:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 25d:	e8 38 07 00 00       	call   99a <printf>
      workers[i].pid = pid;
 262:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 268:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 26f:	89 d0                	mov    %edx,%eax
 271:	01 c0                	add    %eax,%eax
 273:	01 d0                	add    %edx,%eax
 275:	c1 e0 02             	shl    $0x2,%eax
 278:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 27b:	8b 84 24 80 00 00 00 	mov    0x80(%esp),%eax
 282:	89 02                	mov    %eax,(%edx)
      workers[i].input_x = -1;
 284:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 28a:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 291:	89 d0                	mov    %edx,%eax
 293:	01 c0                	add    %eax,%eax
 295:	01 d0                	add    %edx,%eax
 297:	c1 e0 02             	shl    $0x2,%eax
 29a:	01 c8                	add    %ecx,%eax
 29c:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
      workers[i].working = 0;
 2a3:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 2a9:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 2b0:	89 d0                	mov    %edx,%eax
 2b2:	01 c0                	add    %eax,%eax
 2b4:	01 d0                	add    %edx,%eax
 2b6:	c1 e0 02             	shl    $0x2,%eax
 2b9:	01 c8                	add    %ecx,%eax
 2bb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
  printf(STDOUT, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
 2c2:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 2c9:	01 
 2ca:	eb 19                	jmp    2e5 <main+0x166>
      workers[i].pid = pid;
      workers[i].input_x = -1;
      workers[i].working = 0;
    }
    else {                      // fork failed
      printf(STDOUT, "fork() failed!\n"); 
 2cc:	c7 44 24 04 cb 0d 00 	movl   $0xdcb,0x4(%esp)
 2d3:	00 
 2d4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2db:	e8 ba 06 00 00       	call   99a <printf>
      exit();
 2e0:	e8 15 05 00 00       	call   7fa <exit>
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
  printf(STDOUT, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
 2e5:	a1 30 11 00 00       	mov    0x1130,%eax
 2ea:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 2f1:	0f 8c 21 ff ff ff    	jl     218 <main+0x99>
      exit();
    }
  }

  // configure the main process - correct handler
  sigset((void *)handle_main_sig);
 2f7:	c7 04 24 e7 00 00 00 	movl   $0xe7,(%esp)
 2fe:	e8 97 05 00 00       	call   89a <sigset>

  while(toRun)
 303:	e9 2e 02 00 00       	jmp    536 <main+0x3b7>
  {
    printf(STDOUT, "Please enter a number: ");
 308:	c7 44 24 04 db 0d 00 	movl   $0xddb,0x4(%esp)
 30f:	00 
 310:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 317:	e8 7e 06 00 00       	call   99a <printf>

    read(1, buf, MAX_INPUT);
 31c:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
 323:	00 
 324:	8d 44 24 18          	lea    0x18(%esp),%eax
 328:	89 44 24 04          	mov    %eax,0x4(%esp)
 32c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 333:	e8 da 04 00 00       	call   812 <read>
    
    if (buf[0] == '\n'){ //handle main signals
 338:	0f b6 44 24 18       	movzbl 0x18(%esp),%eax
 33d:	3c 0a                	cmp    $0xa,%al
 33f:	75 05                	jne    346 <main+0x1c7>
      continue;
 341:	e9 f0 01 00 00       	jmp    536 <main+0x3b7>
    }

    input_x = atoi(buf);
 346:	8d 44 24 18          	lea    0x18(%esp),%eax
 34a:	89 04 24             	mov    %eax,(%esp)
 34d:	e8 16 04 00 00       	call   768 <atoi>
 352:	89 44 24 7c          	mov    %eax,0x7c(%esp)

    if(input_x != 0)
 356:	83 7c 24 7c 00       	cmpl   $0x0,0x7c(%esp)
 35b:	0f 84 4b 01 00 00    	je     4ac <main+0x32d>
    {
      for (bob = 0; bob < input_x; bob++) 
 361:	c7 84 24 88 00 00 00 	movl   $0x0,0x88(%esp)
 368:	00 00 00 00 
 36c:	e9 25 01 00 00       	jmp    496 <main+0x317>
      {
        // send input_x to process p using sigsend sys-call 
        for (i = 0; i < workers_number; i++)
 371:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 378:	00 00 00 00 
 37c:	e9 d9 00 00 00       	jmp    45a <main+0x2db>
        {
          if (workers[i].working == 0) // available
 381:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 387:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 38e:	89 d0                	mov    %edx,%eax
 390:	01 c0                	add    %eax,%eax
 392:	01 d0                	add    %edx,%eax
 394:	c1 e0 02             	shl    $0x2,%eax
 397:	01 c8                	add    %ecx,%eax
 399:	8b 40 08             	mov    0x8(%eax),%eax
 39c:	85 c0                	test   %eax,%eax
 39e:	0f 85 ae 00 00 00    	jne    452 <main+0x2d3>
          {
            workers[i].working = 1;
 3a4:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 3aa:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3b1:	89 d0                	mov    %edx,%eax
 3b3:	01 c0                	add    %eax,%eax
 3b5:	01 d0                	add    %edx,%eax
 3b7:	c1 e0 02             	shl    $0x2,%eax
 3ba:	01 c8                	add    %ecx,%eax
 3bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
            workers[i].input_x = bob + 1;//input_x;
 3c3:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 3c9:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3d0:	89 d0                	mov    %edx,%eax
 3d2:	01 c0                	add    %eax,%eax
 3d4:	01 d0                	add    %edx,%eax
 3d6:	c1 e0 02             	shl    $0x2,%eax
 3d9:	01 c8                	add    %ecx,%eax
 3db:	8b 94 24 88 00 00 00 	mov    0x88(%esp),%edx
 3e2:	83 c2 01             	add    $0x1,%edx
 3e5:	89 50 04             	mov    %edx,0x4(%eax)
            if (sigsend(workers[i].pid, bob + 1))//input_x);  
 3e8:	8b 84 24 88 00 00 00 	mov    0x88(%esp),%eax
 3ef:	8d 48 01             	lea    0x1(%eax),%ecx
 3f2:	8b 1d 34 11 00 00    	mov    0x1134,%ebx
 3f8:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3ff:	89 d0                	mov    %edx,%eax
 401:	01 c0                	add    %eax,%eax
 403:	01 d0                	add    %edx,%eax
 405:	c1 e0 02             	shl    $0x2,%eax
 408:	01 d8                	add    %ebx,%eax
 40a:	8b 00                	mov    (%eax),%eax
 40c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 410:	89 04 24             	mov    %eax,(%esp)
 413:	e8 8a 04 00 00       	call   8a2 <sigsend>
 418:	85 c0                	test   %eax,%eax
 41a:	74 34                	je     450 <main+0x2d1>
              printf(1, "********** failed to sigsend to worker %d\n", workers[i].pid);
 41c:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 422:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 429:	89 d0                	mov    %edx,%eax
 42b:	01 c0                	add    %eax,%eax
 42d:	01 d0                	add    %edx,%eax
 42f:	c1 e0 02             	shl    $0x2,%eax
 432:	01 c8                	add    %ecx,%eax
 434:	8b 00                	mov    (%eax),%eax
 436:	89 44 24 08          	mov    %eax,0x8(%esp)
 43a:	c7 44 24 04 f4 0d 00 	movl   $0xdf4,0x4(%esp)
 441:	00 
 442:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 449:	e8 4c 05 00 00       	call   99a <printf>
            break;
 44e:	eb 1c                	jmp    46c <main+0x2ed>
 450:	eb 1a                	jmp    46c <main+0x2ed>
    if(input_x != 0)
    {
      for (bob = 0; bob < input_x; bob++) 
      {
        // send input_x to process p using sigsend sys-call 
        for (i = 0; i < workers_number; i++)
 452:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 459:	01 
 45a:	a1 30 11 00 00       	mov    0x1130,%eax
 45f:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 466:	0f 8c 15 ff ff ff    	jl     381 <main+0x202>
            break;
          }
        }

        // no idle workers to handle signal
        if (i == workers_number){
 46c:	a1 30 11 00 00       	mov    0x1130,%eax
 471:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 478:	75 14                	jne    48e <main+0x30f>
          printf(STDOUT, "no idle workers\n");
 47a:	c7 44 24 04 1f 0e 00 	movl   $0xe1f,0x4(%esp)
 481:	00 
 482:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 489:	e8 0c 05 00 00       	call   99a <printf>

    input_x = atoi(buf);

    if(input_x != 0)
    {
      for (bob = 0; bob < input_x; bob++) 
 48e:	83 84 24 88 00 00 00 	addl   $0x1,0x88(%esp)
 495:	01 
 496:	8b 84 24 88 00 00 00 	mov    0x88(%esp),%eax
 49d:	3b 44 24 7c          	cmp    0x7c(%esp),%eax
 4a1:	0f 8c ca fe ff ff    	jl     371 <main+0x1f2>
 4a7:	e9 8a 00 00 00       	jmp    536 <main+0x3b7>
      }
    }

    else // input_x == 0, exiting program
    {
      for (i = 0; i < workers_number; i++)
 4ac:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 4b3:	00 00 00 00 
 4b7:	eb 64                	jmp    51d <main+0x39e>
      {
        sigsend(workers[i].pid, 0);
 4b9:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 4bf:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 4c6:	89 d0                	mov    %edx,%eax
 4c8:	01 c0                	add    %eax,%eax
 4ca:	01 d0                	add    %edx,%eax
 4cc:	c1 e0 02             	shl    $0x2,%eax
 4cf:	01 c8                	add    %ecx,%eax
 4d1:	8b 00                	mov    (%eax),%eax
 4d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4da:	00 
 4db:	89 04 24             	mov    %eax,(%esp)
 4de:	e8 bf 03 00 00       	call   8a2 <sigsend>
        printf(STDOUT, "worker %d exit\n", workers[i].pid);
 4e3:	8b 0d 34 11 00 00    	mov    0x1134,%ecx
 4e9:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 4f0:	89 d0                	mov    %edx,%eax
 4f2:	01 c0                	add    %eax,%eax
 4f4:	01 d0                	add    %edx,%eax
 4f6:	c1 e0 02             	shl    $0x2,%eax
 4f9:	01 c8                	add    %ecx,%eax
 4fb:	8b 00                	mov    (%eax),%eax
 4fd:	89 44 24 08          	mov    %eax,0x8(%esp)
 501:	c7 44 24 04 30 0e 00 	movl   $0xe30,0x4(%esp)
 508:	00 
 509:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 510:	e8 85 04 00 00       	call   99a <printf>
      }
    }

    else // input_x == 0, exiting program
    {
      for (i = 0; i < workers_number; i++)
 515:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 51c:	01 
 51d:	a1 30 11 00 00       	mov    0x1130,%eax
 522:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 529:	7c 8e                	jl     4b9 <main+0x33a>
      {
        sigsend(workers[i].pid, 0);
        printf(STDOUT, "worker %d exit\n", workers[i].pid);
      }
      toRun = 0;
 52b:	c7 84 24 84 00 00 00 	movl   $0x0,0x84(%esp)
 532:	00 00 00 00 
  }

  // configure the main process - correct handler
  sigset((void *)handle_main_sig);

  while(toRun)
 536:	83 bc 24 84 00 00 00 	cmpl   $0x0,0x84(%esp)
 53d:	00 
 53e:	0f 85 c4 fd ff ff    	jne    308 <main+0x189>
      }
      toRun = 0;
    }
  }
  
  for(i = 0; i < workers_number; i++)
 544:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 54b:	00 00 00 00 
 54f:	eb 0d                	jmp    55e <main+0x3df>
    wait();
 551:	e8 ac 02 00 00       	call   802 <wait>
      }
      toRun = 0;
    }
  }
  
  for(i = 0; i < workers_number; i++)
 556:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 55d:	01 
 55e:	a1 30 11 00 00       	mov    0x1130,%eax
 563:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 56a:	7c e5                	jl     551 <main+0x3d2>
    wait();
  free(workers);
 56c:	a1 34 11 00 00       	mov    0x1134,%eax
 571:	89 04 24             	mov    %eax,(%esp)
 574:	e8 d4 05 00 00       	call   b4d <free>
  printf(STDOUT, "primsrv exit\n");
 579:	c7 44 24 04 40 0e 00 	movl   $0xe40,0x4(%esp)
 580:	00 
 581:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 588:	e8 0d 04 00 00       	call   99a <printf>
  exit();
 58d:	e8 68 02 00 00       	call   7fa <exit>

00000592 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 592:	55                   	push   %ebp
 593:	89 e5                	mov    %esp,%ebp
 595:	57                   	push   %edi
 596:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 597:	8b 4d 08             	mov    0x8(%ebp),%ecx
 59a:	8b 55 10             	mov    0x10(%ebp),%edx
 59d:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a0:	89 cb                	mov    %ecx,%ebx
 5a2:	89 df                	mov    %ebx,%edi
 5a4:	89 d1                	mov    %edx,%ecx
 5a6:	fc                   	cld    
 5a7:	f3 aa                	rep stos %al,%es:(%edi)
 5a9:	89 ca                	mov    %ecx,%edx
 5ab:	89 fb                	mov    %edi,%ebx
 5ad:	89 5d 08             	mov    %ebx,0x8(%ebp)
 5b0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 5b3:	5b                   	pop    %ebx
 5b4:	5f                   	pop    %edi
 5b5:	5d                   	pop    %ebp
 5b6:	c3                   	ret    

000005b7 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 5b7:	55                   	push   %ebp
 5b8:	89 e5                	mov    %esp,%ebp
 5ba:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 5bd:	8b 45 08             	mov    0x8(%ebp),%eax
 5c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 5c3:	90                   	nop
 5c4:	8b 45 08             	mov    0x8(%ebp),%eax
 5c7:	8d 50 01             	lea    0x1(%eax),%edx
 5ca:	89 55 08             	mov    %edx,0x8(%ebp)
 5cd:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d0:	8d 4a 01             	lea    0x1(%edx),%ecx
 5d3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 5d6:	0f b6 12             	movzbl (%edx),%edx
 5d9:	88 10                	mov    %dl,(%eax)
 5db:	0f b6 00             	movzbl (%eax),%eax
 5de:	84 c0                	test   %al,%al
 5e0:	75 e2                	jne    5c4 <strcpy+0xd>
    ;
  return os;
 5e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5e5:	c9                   	leave  
 5e6:	c3                   	ret    

000005e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5e7:	55                   	push   %ebp
 5e8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 5ea:	eb 08                	jmp    5f4 <strcmp+0xd>
    p++, q++;
 5ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5f0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	0f b6 00             	movzbl (%eax),%eax
 5fa:	84 c0                	test   %al,%al
 5fc:	74 10                	je     60e <strcmp+0x27>
 5fe:	8b 45 08             	mov    0x8(%ebp),%eax
 601:	0f b6 10             	movzbl (%eax),%edx
 604:	8b 45 0c             	mov    0xc(%ebp),%eax
 607:	0f b6 00             	movzbl (%eax),%eax
 60a:	38 c2                	cmp    %al,%dl
 60c:	74 de                	je     5ec <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 60e:	8b 45 08             	mov    0x8(%ebp),%eax
 611:	0f b6 00             	movzbl (%eax),%eax
 614:	0f b6 d0             	movzbl %al,%edx
 617:	8b 45 0c             	mov    0xc(%ebp),%eax
 61a:	0f b6 00             	movzbl (%eax),%eax
 61d:	0f b6 c0             	movzbl %al,%eax
 620:	29 c2                	sub    %eax,%edx
 622:	89 d0                	mov    %edx,%eax
}
 624:	5d                   	pop    %ebp
 625:	c3                   	ret    

00000626 <strlen>:

uint
strlen(char *s)
{
 626:	55                   	push   %ebp
 627:	89 e5                	mov    %esp,%ebp
 629:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 62c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 633:	eb 04                	jmp    639 <strlen+0x13>
 635:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 639:	8b 55 fc             	mov    -0x4(%ebp),%edx
 63c:	8b 45 08             	mov    0x8(%ebp),%eax
 63f:	01 d0                	add    %edx,%eax
 641:	0f b6 00             	movzbl (%eax),%eax
 644:	84 c0                	test   %al,%al
 646:	75 ed                	jne    635 <strlen+0xf>
    ;
  return n;
 648:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 64b:	c9                   	leave  
 64c:	c3                   	ret    

0000064d <memset>:

void*
memset(void *dst, int c, uint n)
{
 64d:	55                   	push   %ebp
 64e:	89 e5                	mov    %esp,%ebp
 650:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 653:	8b 45 10             	mov    0x10(%ebp),%eax
 656:	89 44 24 08          	mov    %eax,0x8(%esp)
 65a:	8b 45 0c             	mov    0xc(%ebp),%eax
 65d:	89 44 24 04          	mov    %eax,0x4(%esp)
 661:	8b 45 08             	mov    0x8(%ebp),%eax
 664:	89 04 24             	mov    %eax,(%esp)
 667:	e8 26 ff ff ff       	call   592 <stosb>
  return dst;
 66c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 66f:	c9                   	leave  
 670:	c3                   	ret    

00000671 <strchr>:

char*
strchr(const char *s, char c)
{
 671:	55                   	push   %ebp
 672:	89 e5                	mov    %esp,%ebp
 674:	83 ec 04             	sub    $0x4,%esp
 677:	8b 45 0c             	mov    0xc(%ebp),%eax
 67a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 67d:	eb 14                	jmp    693 <strchr+0x22>
    if(*s == c)
 67f:	8b 45 08             	mov    0x8(%ebp),%eax
 682:	0f b6 00             	movzbl (%eax),%eax
 685:	3a 45 fc             	cmp    -0x4(%ebp),%al
 688:	75 05                	jne    68f <strchr+0x1e>
      return (char*)s;
 68a:	8b 45 08             	mov    0x8(%ebp),%eax
 68d:	eb 13                	jmp    6a2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 68f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 693:	8b 45 08             	mov    0x8(%ebp),%eax
 696:	0f b6 00             	movzbl (%eax),%eax
 699:	84 c0                	test   %al,%al
 69b:	75 e2                	jne    67f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 69d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 6a2:	c9                   	leave  
 6a3:	c3                   	ret    

000006a4 <gets>:

char*
gets(char *buf, int max)
{
 6a4:	55                   	push   %ebp
 6a5:	89 e5                	mov    %esp,%ebp
 6a7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 6b1:	eb 4c                	jmp    6ff <gets+0x5b>
    cc = read(0, &c, 1);
 6b3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6ba:	00 
 6bb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 6be:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 6c9:	e8 44 01 00 00       	call   812 <read>
 6ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 6d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6d5:	7f 02                	jg     6d9 <gets+0x35>
      break;
 6d7:	eb 31                	jmp    70a <gets+0x66>
    buf[i++] = c;
 6d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6dc:	8d 50 01             	lea    0x1(%eax),%edx
 6df:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6e2:	89 c2                	mov    %eax,%edx
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
 6e7:	01 c2                	add    %eax,%edx
 6e9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6ed:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 6ef:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6f3:	3c 0a                	cmp    $0xa,%al
 6f5:	74 13                	je     70a <gets+0x66>
 6f7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6fb:	3c 0d                	cmp    $0xd,%al
 6fd:	74 0b                	je     70a <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 702:	83 c0 01             	add    $0x1,%eax
 705:	3b 45 0c             	cmp    0xc(%ebp),%eax
 708:	7c a9                	jl     6b3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 70a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	01 d0                	add    %edx,%eax
 712:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 715:	8b 45 08             	mov    0x8(%ebp),%eax
}
 718:	c9                   	leave  
 719:	c3                   	ret    

0000071a <stat>:

int
stat(char *n, struct stat *st)
{
 71a:	55                   	push   %ebp
 71b:	89 e5                	mov    %esp,%ebp
 71d:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 720:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 727:	00 
 728:	8b 45 08             	mov    0x8(%ebp),%eax
 72b:	89 04 24             	mov    %eax,(%esp)
 72e:	e8 07 01 00 00       	call   83a <open>
 733:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 736:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 73a:	79 07                	jns    743 <stat+0x29>
    return -1;
 73c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 741:	eb 23                	jmp    766 <stat+0x4c>
  r = fstat(fd, st);
 743:	8b 45 0c             	mov    0xc(%ebp),%eax
 746:	89 44 24 04          	mov    %eax,0x4(%esp)
 74a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74d:	89 04 24             	mov    %eax,(%esp)
 750:	e8 fd 00 00 00       	call   852 <fstat>
 755:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 758:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75b:	89 04 24             	mov    %eax,(%esp)
 75e:	e8 bf 00 00 00       	call   822 <close>
  return r;
 763:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 766:	c9                   	leave  
 767:	c3                   	ret    

00000768 <atoi>:

int
atoi(const char *s)
{
 768:	55                   	push   %ebp
 769:	89 e5                	mov    %esp,%ebp
 76b:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 76e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 775:	eb 25                	jmp    79c <atoi+0x34>
    n = n*10 + *s++ - '0';
 777:	8b 55 fc             	mov    -0x4(%ebp),%edx
 77a:	89 d0                	mov    %edx,%eax
 77c:	c1 e0 02             	shl    $0x2,%eax
 77f:	01 d0                	add    %edx,%eax
 781:	01 c0                	add    %eax,%eax
 783:	89 c1                	mov    %eax,%ecx
 785:	8b 45 08             	mov    0x8(%ebp),%eax
 788:	8d 50 01             	lea    0x1(%eax),%edx
 78b:	89 55 08             	mov    %edx,0x8(%ebp)
 78e:	0f b6 00             	movzbl (%eax),%eax
 791:	0f be c0             	movsbl %al,%eax
 794:	01 c8                	add    %ecx,%eax
 796:	83 e8 30             	sub    $0x30,%eax
 799:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 79c:	8b 45 08             	mov    0x8(%ebp),%eax
 79f:	0f b6 00             	movzbl (%eax),%eax
 7a2:	3c 2f                	cmp    $0x2f,%al
 7a4:	7e 0a                	jle    7b0 <atoi+0x48>
 7a6:	8b 45 08             	mov    0x8(%ebp),%eax
 7a9:	0f b6 00             	movzbl (%eax),%eax
 7ac:	3c 39                	cmp    $0x39,%al
 7ae:	7e c7                	jle    777 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 7b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7b3:	c9                   	leave  
 7b4:	c3                   	ret    

000007b5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 7b5:	55                   	push   %ebp
 7b6:	89 e5                	mov    %esp,%ebp
 7b8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 7bb:	8b 45 08             	mov    0x8(%ebp),%eax
 7be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 7c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 7c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 7c7:	eb 17                	jmp    7e0 <memmove+0x2b>
    *dst++ = *src++;
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	8d 50 01             	lea    0x1(%eax),%edx
 7cf:	89 55 fc             	mov    %edx,-0x4(%ebp)
 7d2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7d5:	8d 4a 01             	lea    0x1(%edx),%ecx
 7d8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 7db:	0f b6 12             	movzbl (%edx),%edx
 7de:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 7e0:	8b 45 10             	mov    0x10(%ebp),%eax
 7e3:	8d 50 ff             	lea    -0x1(%eax),%edx
 7e6:	89 55 10             	mov    %edx,0x10(%ebp)
 7e9:	85 c0                	test   %eax,%eax
 7eb:	7f dc                	jg     7c9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 7ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7f0:	c9                   	leave  
 7f1:	c3                   	ret    

000007f2 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 7f2:	b8 01 00 00 00       	mov    $0x1,%eax
 7f7:	cd 40                	int    $0x40
 7f9:	c3                   	ret    

000007fa <exit>:
SYSCALL(exit)
 7fa:	b8 02 00 00 00       	mov    $0x2,%eax
 7ff:	cd 40                	int    $0x40
 801:	c3                   	ret    

00000802 <wait>:
SYSCALL(wait)
 802:	b8 03 00 00 00       	mov    $0x3,%eax
 807:	cd 40                	int    $0x40
 809:	c3                   	ret    

0000080a <pipe>:
SYSCALL(pipe)
 80a:	b8 04 00 00 00       	mov    $0x4,%eax
 80f:	cd 40                	int    $0x40
 811:	c3                   	ret    

00000812 <read>:
SYSCALL(read)
 812:	b8 05 00 00 00       	mov    $0x5,%eax
 817:	cd 40                	int    $0x40
 819:	c3                   	ret    

0000081a <write>:
SYSCALL(write)
 81a:	b8 10 00 00 00       	mov    $0x10,%eax
 81f:	cd 40                	int    $0x40
 821:	c3                   	ret    

00000822 <close>:
SYSCALL(close)
 822:	b8 15 00 00 00       	mov    $0x15,%eax
 827:	cd 40                	int    $0x40
 829:	c3                   	ret    

0000082a <kill>:
SYSCALL(kill)
 82a:	b8 06 00 00 00       	mov    $0x6,%eax
 82f:	cd 40                	int    $0x40
 831:	c3                   	ret    

00000832 <exec>:
SYSCALL(exec)
 832:	b8 07 00 00 00       	mov    $0x7,%eax
 837:	cd 40                	int    $0x40
 839:	c3                   	ret    

0000083a <open>:
SYSCALL(open)
 83a:	b8 0f 00 00 00       	mov    $0xf,%eax
 83f:	cd 40                	int    $0x40
 841:	c3                   	ret    

00000842 <mknod>:
SYSCALL(mknod)
 842:	b8 11 00 00 00       	mov    $0x11,%eax
 847:	cd 40                	int    $0x40
 849:	c3                   	ret    

0000084a <unlink>:
SYSCALL(unlink)
 84a:	b8 12 00 00 00       	mov    $0x12,%eax
 84f:	cd 40                	int    $0x40
 851:	c3                   	ret    

00000852 <fstat>:
SYSCALL(fstat)
 852:	b8 08 00 00 00       	mov    $0x8,%eax
 857:	cd 40                	int    $0x40
 859:	c3                   	ret    

0000085a <link>:
SYSCALL(link)
 85a:	b8 13 00 00 00       	mov    $0x13,%eax
 85f:	cd 40                	int    $0x40
 861:	c3                   	ret    

00000862 <mkdir>:
SYSCALL(mkdir)
 862:	b8 14 00 00 00       	mov    $0x14,%eax
 867:	cd 40                	int    $0x40
 869:	c3                   	ret    

0000086a <chdir>:
SYSCALL(chdir)
 86a:	b8 09 00 00 00       	mov    $0x9,%eax
 86f:	cd 40                	int    $0x40
 871:	c3                   	ret    

00000872 <dup>:
SYSCALL(dup)
 872:	b8 0a 00 00 00       	mov    $0xa,%eax
 877:	cd 40                	int    $0x40
 879:	c3                   	ret    

0000087a <getpid>:
SYSCALL(getpid)
 87a:	b8 0b 00 00 00       	mov    $0xb,%eax
 87f:	cd 40                	int    $0x40
 881:	c3                   	ret    

00000882 <sbrk>:
SYSCALL(sbrk)
 882:	b8 0c 00 00 00       	mov    $0xc,%eax
 887:	cd 40                	int    $0x40
 889:	c3                   	ret    

0000088a <sleep>:
SYSCALL(sleep)
 88a:	b8 0d 00 00 00       	mov    $0xd,%eax
 88f:	cd 40                	int    $0x40
 891:	c3                   	ret    

00000892 <uptime>:
SYSCALL(uptime)
 892:	b8 0e 00 00 00       	mov    $0xe,%eax
 897:	cd 40                	int    $0x40
 899:	c3                   	ret    

0000089a <sigset>:
SYSCALL(sigset)
 89a:	b8 16 00 00 00       	mov    $0x16,%eax
 89f:	cd 40                	int    $0x40
 8a1:	c3                   	ret    

000008a2 <sigsend>:
SYSCALL(sigsend)
 8a2:	b8 17 00 00 00       	mov    $0x17,%eax
 8a7:	cd 40                	int    $0x40
 8a9:	c3                   	ret    

000008aa <sigret>:
SYSCALL(sigret)
 8aa:	b8 18 00 00 00       	mov    $0x18,%eax
 8af:	cd 40                	int    $0x40
 8b1:	c3                   	ret    

000008b2 <sigpause>:
 8b2:	b8 19 00 00 00       	mov    $0x19,%eax
 8b7:	cd 40                	int    $0x40
 8b9:	c3                   	ret    

000008ba <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 8ba:	55                   	push   %ebp
 8bb:	89 e5                	mov    %esp,%ebp
 8bd:	83 ec 18             	sub    $0x18,%esp
 8c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 8c3:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 8c6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 8cd:	00 
 8ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
 8d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d5:	8b 45 08             	mov    0x8(%ebp),%eax
 8d8:	89 04 24             	mov    %eax,(%esp)
 8db:	e8 3a ff ff ff       	call   81a <write>
}
 8e0:	c9                   	leave  
 8e1:	c3                   	ret    

000008e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 8e2:	55                   	push   %ebp
 8e3:	89 e5                	mov    %esp,%ebp
 8e5:	56                   	push   %esi
 8e6:	53                   	push   %ebx
 8e7:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 8ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 8f1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 8f5:	74 17                	je     90e <printint+0x2c>
 8f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 8fb:	79 11                	jns    90e <printint+0x2c>
    neg = 1;
 8fd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 904:	8b 45 0c             	mov    0xc(%ebp),%eax
 907:	f7 d8                	neg    %eax
 909:	89 45 ec             	mov    %eax,-0x14(%ebp)
 90c:	eb 06                	jmp    914 <printint+0x32>
  } else {
    x = xx;
 90e:	8b 45 0c             	mov    0xc(%ebp),%eax
 911:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 914:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 91b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 91e:	8d 41 01             	lea    0x1(%ecx),%eax
 921:	89 45 f4             	mov    %eax,-0xc(%ebp)
 924:	8b 5d 10             	mov    0x10(%ebp),%ebx
 927:	8b 45 ec             	mov    -0x14(%ebp),%eax
 92a:	ba 00 00 00 00       	mov    $0x0,%edx
 92f:	f7 f3                	div    %ebx
 931:	89 d0                	mov    %edx,%eax
 933:	0f b6 80 1c 11 00 00 	movzbl 0x111c(%eax),%eax
 93a:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 93e:	8b 75 10             	mov    0x10(%ebp),%esi
 941:	8b 45 ec             	mov    -0x14(%ebp),%eax
 944:	ba 00 00 00 00       	mov    $0x0,%edx
 949:	f7 f6                	div    %esi
 94b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 94e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 952:	75 c7                	jne    91b <printint+0x39>
  if(neg)
 954:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 958:	74 10                	je     96a <printint+0x88>
    buf[i++] = '-';
 95a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95d:	8d 50 01             	lea    0x1(%eax),%edx
 960:	89 55 f4             	mov    %edx,-0xc(%ebp)
 963:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 968:	eb 1f                	jmp    989 <printint+0xa7>
 96a:	eb 1d                	jmp    989 <printint+0xa7>
    putc(fd, buf[i]);
 96c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 96f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 972:	01 d0                	add    %edx,%eax
 974:	0f b6 00             	movzbl (%eax),%eax
 977:	0f be c0             	movsbl %al,%eax
 97a:	89 44 24 04          	mov    %eax,0x4(%esp)
 97e:	8b 45 08             	mov    0x8(%ebp),%eax
 981:	89 04 24             	mov    %eax,(%esp)
 984:	e8 31 ff ff ff       	call   8ba <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 989:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 98d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 991:	79 d9                	jns    96c <printint+0x8a>
    putc(fd, buf[i]);
}
 993:	83 c4 30             	add    $0x30,%esp
 996:	5b                   	pop    %ebx
 997:	5e                   	pop    %esi
 998:	5d                   	pop    %ebp
 999:	c3                   	ret    

0000099a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 99a:	55                   	push   %ebp
 99b:	89 e5                	mov    %esp,%ebp
 99d:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 9a0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 9a7:	8d 45 0c             	lea    0xc(%ebp),%eax
 9aa:	83 c0 04             	add    $0x4,%eax
 9ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 9b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 9b7:	e9 7c 01 00 00       	jmp    b38 <printf+0x19e>
    c = fmt[i] & 0xff;
 9bc:	8b 55 0c             	mov    0xc(%ebp),%edx
 9bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c2:	01 d0                	add    %edx,%eax
 9c4:	0f b6 00             	movzbl (%eax),%eax
 9c7:	0f be c0             	movsbl %al,%eax
 9ca:	25 ff 00 00 00       	and    $0xff,%eax
 9cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 9d2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9d6:	75 2c                	jne    a04 <printf+0x6a>
      if(c == '%'){
 9d8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9dc:	75 0c                	jne    9ea <printf+0x50>
        state = '%';
 9de:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 9e5:	e9 4a 01 00 00       	jmp    b34 <printf+0x19a>
      } else {
        putc(fd, c);
 9ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9ed:	0f be c0             	movsbl %al,%eax
 9f0:	89 44 24 04          	mov    %eax,0x4(%esp)
 9f4:	8b 45 08             	mov    0x8(%ebp),%eax
 9f7:	89 04 24             	mov    %eax,(%esp)
 9fa:	e8 bb fe ff ff       	call   8ba <putc>
 9ff:	e9 30 01 00 00       	jmp    b34 <printf+0x19a>
      }
    } else if(state == '%'){
 a04:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a08:	0f 85 26 01 00 00    	jne    b34 <printf+0x19a>
      if(c == 'd'){
 a0e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 a12:	75 2d                	jne    a41 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 a14:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a17:	8b 00                	mov    (%eax),%eax
 a19:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 a20:	00 
 a21:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 a28:	00 
 a29:	89 44 24 04          	mov    %eax,0x4(%esp)
 a2d:	8b 45 08             	mov    0x8(%ebp),%eax
 a30:	89 04 24             	mov    %eax,(%esp)
 a33:	e8 aa fe ff ff       	call   8e2 <printint>
        ap++;
 a38:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a3c:	e9 ec 00 00 00       	jmp    b2d <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 a41:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 a45:	74 06                	je     a4d <printf+0xb3>
 a47:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 a4b:	75 2d                	jne    a7a <printf+0xe0>
        printint(fd, *ap, 16, 0);
 a4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a50:	8b 00                	mov    (%eax),%eax
 a52:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 a59:	00 
 a5a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 a61:	00 
 a62:	89 44 24 04          	mov    %eax,0x4(%esp)
 a66:	8b 45 08             	mov    0x8(%ebp),%eax
 a69:	89 04 24             	mov    %eax,(%esp)
 a6c:	e8 71 fe ff ff       	call   8e2 <printint>
        ap++;
 a71:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a75:	e9 b3 00 00 00       	jmp    b2d <printf+0x193>
      } else if(c == 's'){
 a7a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a7e:	75 45                	jne    ac5 <printf+0x12b>
        s = (char*)*ap;
 a80:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a83:	8b 00                	mov    (%eax),%eax
 a85:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a88:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a90:	75 09                	jne    a9b <printf+0x101>
          s = "(null)";
 a92:	c7 45 f4 4e 0e 00 00 	movl   $0xe4e,-0xc(%ebp)
        while(*s != 0){
 a99:	eb 1e                	jmp    ab9 <printf+0x11f>
 a9b:	eb 1c                	jmp    ab9 <printf+0x11f>
          putc(fd, *s);
 a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa0:	0f b6 00             	movzbl (%eax),%eax
 aa3:	0f be c0             	movsbl %al,%eax
 aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
 aaa:	8b 45 08             	mov    0x8(%ebp),%eax
 aad:	89 04 24             	mov    %eax,(%esp)
 ab0:	e8 05 fe ff ff       	call   8ba <putc>
          s++;
 ab5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abc:	0f b6 00             	movzbl (%eax),%eax
 abf:	84 c0                	test   %al,%al
 ac1:	75 da                	jne    a9d <printf+0x103>
 ac3:	eb 68                	jmp    b2d <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 ac5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 ac9:	75 1d                	jne    ae8 <printf+0x14e>
        putc(fd, *ap);
 acb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ace:	8b 00                	mov    (%eax),%eax
 ad0:	0f be c0             	movsbl %al,%eax
 ad3:	89 44 24 04          	mov    %eax,0x4(%esp)
 ad7:	8b 45 08             	mov    0x8(%ebp),%eax
 ada:	89 04 24             	mov    %eax,(%esp)
 add:	e8 d8 fd ff ff       	call   8ba <putc>
        ap++;
 ae2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 ae6:	eb 45                	jmp    b2d <printf+0x193>
      } else if(c == '%'){
 ae8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 aec:	75 17                	jne    b05 <printf+0x16b>
        putc(fd, c);
 aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 af1:	0f be c0             	movsbl %al,%eax
 af4:	89 44 24 04          	mov    %eax,0x4(%esp)
 af8:	8b 45 08             	mov    0x8(%ebp),%eax
 afb:	89 04 24             	mov    %eax,(%esp)
 afe:	e8 b7 fd ff ff       	call   8ba <putc>
 b03:	eb 28                	jmp    b2d <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b05:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 b0c:	00 
 b0d:	8b 45 08             	mov    0x8(%ebp),%eax
 b10:	89 04 24             	mov    %eax,(%esp)
 b13:	e8 a2 fd ff ff       	call   8ba <putc>
        putc(fd, c);
 b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b1b:	0f be c0             	movsbl %al,%eax
 b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
 b22:	8b 45 08             	mov    0x8(%ebp),%eax
 b25:	89 04 24             	mov    %eax,(%esp)
 b28:	e8 8d fd ff ff       	call   8ba <putc>
      }
      state = 0;
 b2d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 b34:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 b38:	8b 55 0c             	mov    0xc(%ebp),%edx
 b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b3e:	01 d0                	add    %edx,%eax
 b40:	0f b6 00             	movzbl (%eax),%eax
 b43:	84 c0                	test   %al,%al
 b45:	0f 85 71 fe ff ff    	jne    9bc <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 b4b:	c9                   	leave  
 b4c:	c3                   	ret    

00000b4d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b4d:	55                   	push   %ebp
 b4e:	89 e5                	mov    %esp,%ebp
 b50:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b53:	8b 45 08             	mov    0x8(%ebp),%eax
 b56:	83 e8 08             	sub    $0x8,%eax
 b59:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b5c:	a1 40 11 00 00       	mov    0x1140,%eax
 b61:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b64:	eb 24                	jmp    b8a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b69:	8b 00                	mov    (%eax),%eax
 b6b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b6e:	77 12                	ja     b82 <free+0x35>
 b70:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b73:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b76:	77 24                	ja     b9c <free+0x4f>
 b78:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7b:	8b 00                	mov    (%eax),%eax
 b7d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b80:	77 1a                	ja     b9c <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b85:	8b 00                	mov    (%eax),%eax
 b87:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b8d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b90:	76 d4                	jbe    b66 <free+0x19>
 b92:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b95:	8b 00                	mov    (%eax),%eax
 b97:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b9a:	76 ca                	jbe    b66 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 b9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b9f:	8b 40 04             	mov    0x4(%eax),%eax
 ba2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 ba9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bac:	01 c2                	add    %eax,%edx
 bae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bb1:	8b 00                	mov    (%eax),%eax
 bb3:	39 c2                	cmp    %eax,%edx
 bb5:	75 24                	jne    bdb <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 bb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bba:	8b 50 04             	mov    0x4(%eax),%edx
 bbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bc0:	8b 00                	mov    (%eax),%eax
 bc2:	8b 40 04             	mov    0x4(%eax),%eax
 bc5:	01 c2                	add    %eax,%edx
 bc7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bca:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd0:	8b 00                	mov    (%eax),%eax
 bd2:	8b 10                	mov    (%eax),%edx
 bd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bd7:	89 10                	mov    %edx,(%eax)
 bd9:	eb 0a                	jmp    be5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 bdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bde:	8b 10                	mov    (%eax),%edx
 be0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 be3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 be5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 be8:	8b 40 04             	mov    0x4(%eax),%eax
 beb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 bf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf5:	01 d0                	add    %edx,%eax
 bf7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bfa:	75 20                	jne    c1c <free+0xcf>
    p->s.size += bp->s.size;
 bfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bff:	8b 50 04             	mov    0x4(%eax),%edx
 c02:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c05:	8b 40 04             	mov    0x4(%eax),%eax
 c08:	01 c2                	add    %eax,%edx
 c0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c0d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c10:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c13:	8b 10                	mov    (%eax),%edx
 c15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c18:	89 10                	mov    %edx,(%eax)
 c1a:	eb 08                	jmp    c24 <free+0xd7>
  } else
    p->s.ptr = bp;
 c1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c1f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 c22:	89 10                	mov    %edx,(%eax)
  freep = p;
 c24:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c27:	a3 40 11 00 00       	mov    %eax,0x1140
}
 c2c:	c9                   	leave  
 c2d:	c3                   	ret    

00000c2e <morecore>:

static Header*
morecore(uint nu)
{
 c2e:	55                   	push   %ebp
 c2f:	89 e5                	mov    %esp,%ebp
 c31:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 c34:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 c3b:	77 07                	ja     c44 <morecore+0x16>
    nu = 4096;
 c3d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 c44:	8b 45 08             	mov    0x8(%ebp),%eax
 c47:	c1 e0 03             	shl    $0x3,%eax
 c4a:	89 04 24             	mov    %eax,(%esp)
 c4d:	e8 30 fc ff ff       	call   882 <sbrk>
 c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 c55:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 c59:	75 07                	jne    c62 <morecore+0x34>
    return 0;
 c5b:	b8 00 00 00 00       	mov    $0x0,%eax
 c60:	eb 22                	jmp    c84 <morecore+0x56>
  hp = (Header*)p;
 c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c6b:	8b 55 08             	mov    0x8(%ebp),%edx
 c6e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c74:	83 c0 08             	add    $0x8,%eax
 c77:	89 04 24             	mov    %eax,(%esp)
 c7a:	e8 ce fe ff ff       	call   b4d <free>
  return freep;
 c7f:	a1 40 11 00 00       	mov    0x1140,%eax
}
 c84:	c9                   	leave  
 c85:	c3                   	ret    

00000c86 <malloc>:

void*
malloc(uint nbytes)
{
 c86:	55                   	push   %ebp
 c87:	89 e5                	mov    %esp,%ebp
 c89:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c8c:	8b 45 08             	mov    0x8(%ebp),%eax
 c8f:	83 c0 07             	add    $0x7,%eax
 c92:	c1 e8 03             	shr    $0x3,%eax
 c95:	83 c0 01             	add    $0x1,%eax
 c98:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c9b:	a1 40 11 00 00       	mov    0x1140,%eax
 ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ca3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ca7:	75 23                	jne    ccc <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 ca9:	c7 45 f0 38 11 00 00 	movl   $0x1138,-0x10(%ebp)
 cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cb3:	a3 40 11 00 00       	mov    %eax,0x1140
 cb8:	a1 40 11 00 00       	mov    0x1140,%eax
 cbd:	a3 38 11 00 00       	mov    %eax,0x1138
    base.s.size = 0;
 cc2:	c7 05 3c 11 00 00 00 	movl   $0x0,0x113c
 cc9:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ccf:	8b 00                	mov    (%eax),%eax
 cd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cd7:	8b 40 04             	mov    0x4(%eax),%eax
 cda:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 cdd:	72 4d                	jb     d2c <malloc+0xa6>
      if(p->s.size == nunits)
 cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ce2:	8b 40 04             	mov    0x4(%eax),%eax
 ce5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ce8:	75 0c                	jne    cf6 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ced:	8b 10                	mov    (%eax),%edx
 cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cf2:	89 10                	mov    %edx,(%eax)
 cf4:	eb 26                	jmp    d1c <malloc+0x96>
      else {
        p->s.size -= nunits;
 cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cf9:	8b 40 04             	mov    0x4(%eax),%eax
 cfc:	2b 45 ec             	sub    -0x14(%ebp),%eax
 cff:	89 c2                	mov    %eax,%edx
 d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d04:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d0a:	8b 40 04             	mov    0x4(%eax),%eax
 d0d:	c1 e0 03             	shl    $0x3,%eax
 d10:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d16:	8b 55 ec             	mov    -0x14(%ebp),%edx
 d19:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d1f:	a3 40 11 00 00       	mov    %eax,0x1140
      return (void*)(p + 1);
 d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d27:	83 c0 08             	add    $0x8,%eax
 d2a:	eb 38                	jmp    d64 <malloc+0xde>
    }
    if(p == freep)
 d2c:	a1 40 11 00 00       	mov    0x1140,%eax
 d31:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 d34:	75 1b                	jne    d51 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 d36:	8b 45 ec             	mov    -0x14(%ebp),%eax
 d39:	89 04 24             	mov    %eax,(%esp)
 d3c:	e8 ed fe ff ff       	call   c2e <morecore>
 d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
 d44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 d48:	75 07                	jne    d51 <malloc+0xcb>
        return 0;
 d4a:	b8 00 00 00 00       	mov    $0x0,%eax
 d4f:	eb 13                	jmp    d64 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d54:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d5a:	8b 00                	mov    (%eax),%eax
 d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 d5f:	e9 70 ff ff ff       	jmp    cd4 <malloc+0x4e>
}
 d64:	c9                   	leave  
 d65:	c3                   	ret    
