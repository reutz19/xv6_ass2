
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
  bb:	e8 15 07 00 00       	call   7d5 <exit>
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
  dc:	e8 9c 07 00 00       	call   87d <sigsend>
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
  f6:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
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
 111:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
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
 13a:	c7 44 24 04 44 0d 00 	movl   $0xd44,0x4(%esp)
 141:	00 
 142:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 149:	e8 27 08 00 00       	call   975 <printf>
      workers[i].working = 0;
 14e:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
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
 16f:	a1 0c 11 00 00       	mov    0x110c,%eax
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
 182:	83 e4 f0             	and    $0xfffffff0,%esp
 185:	81 ec 90 00 00 00    	sub    $0x90,%esp
  //int i, pid, input_x, bob;
  int i, pid, input_x;
  int toRun = 1;
 18b:	c7 84 24 88 00 00 00 	movl   $0x1,0x88(%esp)
 192:	01 00 00 00 
  char buf[MAX_INPUT];

  // validate arguments
  if (argc != 2) {
 196:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 19a:	74 19                	je     1b5 <main+0x36>
    printf(STDOUT, "Unvaild parameter for primsrv test\n");
 19c:	c7 44 24 04 70 0d 00 	movl   $0xd70,0x4(%esp)
 1a3:	00 
 1a4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1ab:	e8 c5 07 00 00       	call   975 <printf>
    exit();
 1b0:	e8 20 06 00 00       	call   7d5 <exit>
  }

  // allocate workers array
  workers_number = atoi(argv[1]);
 1b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b8:	83 c0 04             	add    $0x4,%eax
 1bb:	8b 00                	mov    (%eax),%eax
 1bd:	89 04 24             	mov    %eax,(%esp)
 1c0:	e8 7e 05 00 00       	call   743 <atoi>
 1c5:	a3 0c 11 00 00       	mov    %eax,0x110c
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
 1ca:	a1 0c 11 00 00       	mov    0x110c,%eax
 1cf:	89 c2                	mov    %eax,%edx
 1d1:	89 d0                	mov    %edx,%eax
 1d3:	01 c0                	add    %eax,%eax
 1d5:	01 d0                	add    %edx,%eax
 1d7:	c1 e0 02             	shl    $0x2,%eax
 1da:	89 04 24             	mov    %eax,(%esp)
 1dd:	e8 7f 0a 00 00       	call   c61 <malloc>
 1e2:	a3 10 11 00 00       	mov    %eax,0x1110
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
 1e7:	c7 04 24 af 00 00 00 	movl   $0xaf,(%esp)
 1ee:	e8 82 06 00 00       	call   875 <sigset>
  printf(STDOUT, "workers pids:\n");
 1f3:	c7 44 24 04 94 0d 00 	movl   $0xd94,0x4(%esp)
 1fa:	00 
 1fb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 202:	e8 6e 07 00 00       	call   975 <printf>
  for(i = 0; i < workers_number; i++) {
 207:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 20e:	00 00 00 00 
 212:	e9 cd 00 00 00       	jmp    2e4 <main+0x165>
    
    if ((pid = fork()) == 0) {  // son
 217:	e8 b1 05 00 00       	call   7cd <fork>
 21c:	89 84 24 84 00 00 00 	mov    %eax,0x84(%esp)
 223:	83 bc 24 84 00 00 00 	cmpl   $0x0,0x84(%esp)
 22a:	00 
 22b:	75 07                	jne    234 <main+0xb5>
      while(1) sigpause();
 22d:	e8 5b 06 00 00       	call   88d <sigpause>
 232:	eb f9                	jmp    22d <main+0xae>
    }
    else if (pid > 0) {         // father
 234:	83 bc 24 84 00 00 00 	cmpl   $0x0,0x84(%esp)
 23b:	00 
 23c:	0f 8e 89 00 00 00    	jle    2cb <main+0x14c>
      //init son worker_s 
      printf(STDOUT, "%d\n", pid);  
 242:	8b 84 24 84 00 00 00 	mov    0x84(%esp),%eax
 249:	89 44 24 08          	mov    %eax,0x8(%esp)
 24d:	c7 44 24 04 a3 0d 00 	movl   $0xda3,0x4(%esp)
 254:	00 
 255:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 25c:	e8 14 07 00 00       	call   975 <printf>
      workers[i].pid = pid;
 261:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 267:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 26e:	89 d0                	mov    %edx,%eax
 270:	01 c0                	add    %eax,%eax
 272:	01 d0                	add    %edx,%eax
 274:	c1 e0 02             	shl    $0x2,%eax
 277:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 27a:	8b 84 24 84 00 00 00 	mov    0x84(%esp),%eax
 281:	89 02                	mov    %eax,(%edx)
      workers[i].input_x = -1;
 283:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 289:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 290:	89 d0                	mov    %edx,%eax
 292:	01 c0                	add    %eax,%eax
 294:	01 d0                	add    %edx,%eax
 296:	c1 e0 02             	shl    $0x2,%eax
 299:	01 c8                	add    %ecx,%eax
 29b:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
      workers[i].working = 0;
 2a2:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 2a8:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 2af:	89 d0                	mov    %edx,%eax
 2b1:	01 c0                	add    %eax,%eax
 2b3:	01 d0                	add    %edx,%eax
 2b5:	c1 e0 02             	shl    $0x2,%eax
 2b8:	01 c8                	add    %ecx,%eax
 2ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
  printf(STDOUT, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
 2c1:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 2c8:	01 
 2c9:	eb 19                	jmp    2e4 <main+0x165>
      workers[i].pid = pid;
      workers[i].input_x = -1;
      workers[i].working = 0;
    }
    else {                      // fork failed
      printf(STDOUT, "fork() failed!\n"); 
 2cb:	c7 44 24 04 a7 0d 00 	movl   $0xda7,0x4(%esp)
 2d2:	00 
 2d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2da:	e8 96 06 00 00       	call   975 <printf>
      exit();
 2df:	e8 f1 04 00 00       	call   7d5 <exit>
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
  printf(STDOUT, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
 2e4:	a1 0c 11 00 00       	mov    0x110c,%eax
 2e9:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 2f0:	0f 8c 21 ff ff ff    	jl     217 <main+0x98>
      exit();
    }
  }

  // configure the main process - correct handler
  sigset((void *)handle_main_sig);
 2f6:	c7 04 24 e7 00 00 00 	movl   $0xe7,(%esp)
 2fd:	e8 73 05 00 00       	call   875 <sigset>

  while(toRun)
 302:	e9 0a 02 00 00       	jmp    511 <main+0x392>
  {
    printf(STDOUT, "Please enter a number: ");
 307:	c7 44 24 04 b7 0d 00 	movl   $0xdb7,0x4(%esp)
 30e:	00 
 30f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 316:	e8 5a 06 00 00       	call   975 <printf>

    read(1, buf, MAX_INPUT);
 31b:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
 322:	00 
 323:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 327:	89 44 24 04          	mov    %eax,0x4(%esp)
 32b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 332:	e8 b6 04 00 00       	call   7ed <read>
    
    if (buf[0] == '\n'){ //handle main signals
 337:	0f b6 44 24 1c       	movzbl 0x1c(%esp),%eax
 33c:	3c 0a                	cmp    $0xa,%al
 33e:	75 05                	jne    345 <main+0x1c6>
      continue;
 340:	e9 cc 01 00 00       	jmp    511 <main+0x392>
    }

    input_x = atoi(buf);
 345:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 349:	89 04 24             	mov    %eax,(%esp)
 34c:	e8 f2 03 00 00       	call   743 <atoi>
 351:	89 84 24 80 00 00 00 	mov    %eax,0x80(%esp)

    if(input_x != 0)
 358:	83 bc 24 80 00 00 00 	cmpl   $0x0,0x80(%esp)
 35f:	00 
 360:	0f 84 21 01 00 00    	je     487 <main+0x308>
    {
      //for (bob = 0; bob < input_x; bob++) 
      //{
        // send input_x to process p using sigsend sys-call 
        for (i = 0; i < workers_number; i++)
 366:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 36d:	00 00 00 00 
 371:	e9 d4 00 00 00       	jmp    44a <main+0x2cb>
        {
          if (workers[i].working == 0) // available
 376:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 37c:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 383:	89 d0                	mov    %edx,%eax
 385:	01 c0                	add    %eax,%eax
 387:	01 d0                	add    %edx,%eax
 389:	c1 e0 02             	shl    $0x2,%eax
 38c:	01 c8                	add    %ecx,%eax
 38e:	8b 40 08             	mov    0x8(%eax),%eax
 391:	85 c0                	test   %eax,%eax
 393:	0f 85 a9 00 00 00    	jne    442 <main+0x2c3>
          {
            workers[i].working = 1;
 399:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 39f:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3a6:	89 d0                	mov    %edx,%eax
 3a8:	01 c0                	add    %eax,%eax
 3aa:	01 d0                	add    %edx,%eax
 3ac:	c1 e0 02             	shl    $0x2,%eax
 3af:	01 c8                	add    %ecx,%eax
 3b1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
            //workers[i].input_x = bob + 1;//input_x;
            //if (sigsend(workers[i].pid, bob + 1))//input_x);
            workers[i].input_x = input_x;
 3b8:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 3be:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3c5:	89 d0                	mov    %edx,%eax
 3c7:	01 c0                	add    %eax,%eax
 3c9:	01 d0                	add    %edx,%eax
 3cb:	c1 e0 02             	shl    $0x2,%eax
 3ce:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 3d1:	8b 84 24 80 00 00 00 	mov    0x80(%esp),%eax
 3d8:	89 42 04             	mov    %eax,0x4(%edx)
            if (sigsend(workers[i].pid, input_x))//input_x);    
 3db:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 3e1:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3e8:	89 d0                	mov    %edx,%eax
 3ea:	01 c0                	add    %eax,%eax
 3ec:	01 d0                	add    %edx,%eax
 3ee:	c1 e0 02             	shl    $0x2,%eax
 3f1:	01 c8                	add    %ecx,%eax
 3f3:	8b 00                	mov    (%eax),%eax
 3f5:	8b 94 24 80 00 00 00 	mov    0x80(%esp),%edx
 3fc:	89 54 24 04          	mov    %edx,0x4(%esp)
 400:	89 04 24             	mov    %eax,(%esp)
 403:	e8 75 04 00 00       	call   87d <sigsend>
 408:	85 c0                	test   %eax,%eax
 40a:	74 34                	je     440 <main+0x2c1>
              printf(1, "********** failed to sigsend to worker %d\n", workers[i].pid);
 40c:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 412:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 419:	89 d0                	mov    %edx,%eax
 41b:	01 c0                	add    %eax,%eax
 41d:	01 d0                	add    %edx,%eax
 41f:	c1 e0 02             	shl    $0x2,%eax
 422:	01 c8                	add    %ecx,%eax
 424:	8b 00                	mov    (%eax),%eax
 426:	89 44 24 08          	mov    %eax,0x8(%esp)
 42a:	c7 44 24 04 d0 0d 00 	movl   $0xdd0,0x4(%esp)
 431:	00 
 432:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 439:	e8 37 05 00 00       	call   975 <printf>
            break;
 43e:	eb 1c                	jmp    45c <main+0x2dd>
 440:	eb 1a                	jmp    45c <main+0x2dd>
    if(input_x != 0)
    {
      //for (bob = 0; bob < input_x; bob++) 
      //{
        // send input_x to process p using sigsend sys-call 
        for (i = 0; i < workers_number; i++)
 442:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 449:	01 
 44a:	a1 0c 11 00 00       	mov    0x110c,%eax
 44f:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 456:	0f 8c 1a ff ff ff    	jl     376 <main+0x1f7>
            break;
          }
        }

        // no idle workers to handle signal
        if (i == workers_number){
 45c:	a1 0c 11 00 00       	mov    0x110c,%eax
 461:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 468:	0f 85 a3 00 00 00    	jne    511 <main+0x392>
          printf(STDOUT, "no idle workers\n");
 46e:	c7 44 24 04 fb 0d 00 	movl   $0xdfb,0x4(%esp)
 475:	00 
 476:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 47d:	e8 f3 04 00 00       	call   975 <printf>
 482:	e9 8a 00 00 00       	jmp    511 <main+0x392>
      //}
    }

    else // input_x == 0, exiting program
    {
      for (i = 0; i < workers_number; i++)
 487:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 48e:	00 00 00 00 
 492:	eb 64                	jmp    4f8 <main+0x379>
      {
        sigsend(workers[i].pid, 0);
 494:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 49a:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 4a1:	89 d0                	mov    %edx,%eax
 4a3:	01 c0                	add    %eax,%eax
 4a5:	01 d0                	add    %edx,%eax
 4a7:	c1 e0 02             	shl    $0x2,%eax
 4aa:	01 c8                	add    %ecx,%eax
 4ac:	8b 00                	mov    (%eax),%eax
 4ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4b5:	00 
 4b6:	89 04 24             	mov    %eax,(%esp)
 4b9:	e8 bf 03 00 00       	call   87d <sigsend>
        printf(STDOUT, "worker %d exit\n", workers[i].pid);
 4be:	8b 0d 10 11 00 00    	mov    0x1110,%ecx
 4c4:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 4cb:	89 d0                	mov    %edx,%eax
 4cd:	01 c0                	add    %eax,%eax
 4cf:	01 d0                	add    %edx,%eax
 4d1:	c1 e0 02             	shl    $0x2,%eax
 4d4:	01 c8                	add    %ecx,%eax
 4d6:	8b 00                	mov    (%eax),%eax
 4d8:	89 44 24 08          	mov    %eax,0x8(%esp)
 4dc:	c7 44 24 04 0c 0e 00 	movl   $0xe0c,0x4(%esp)
 4e3:	00 
 4e4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 4eb:	e8 85 04 00 00       	call   975 <printf>
      //}
    }

    else // input_x == 0, exiting program
    {
      for (i = 0; i < workers_number; i++)
 4f0:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 4f7:	01 
 4f8:	a1 0c 11 00 00       	mov    0x110c,%eax
 4fd:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 504:	7c 8e                	jl     494 <main+0x315>
      {
        sigsend(workers[i].pid, 0);
        printf(STDOUT, "worker %d exit\n", workers[i].pid);
      }
      toRun = 0;
 506:	c7 84 24 88 00 00 00 	movl   $0x0,0x88(%esp)
 50d:	00 00 00 00 
  }

  // configure the main process - correct handler
  sigset((void *)handle_main_sig);

  while(toRun)
 511:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
 518:	00 
 519:	0f 85 e8 fd ff ff    	jne    307 <main+0x188>
      }
      toRun = 0;
    }
  }
  
  for(i = 0; i < workers_number; i++)
 51f:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 526:	00 00 00 00 
 52a:	eb 0d                	jmp    539 <main+0x3ba>
    wait();
 52c:	e8 ac 02 00 00       	call   7dd <wait>
      }
      toRun = 0;
    }
  }
  
  for(i = 0; i < workers_number; i++)
 531:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 538:	01 
 539:	a1 0c 11 00 00       	mov    0x110c,%eax
 53e:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 545:	7c e5                	jl     52c <main+0x3ad>
    wait();
  free(workers);
 547:	a1 10 11 00 00       	mov    0x1110,%eax
 54c:	89 04 24             	mov    %eax,(%esp)
 54f:	e8 d4 05 00 00       	call   b28 <free>
  printf(STDOUT, "primsrv exit\n");
 554:	c7 44 24 04 1c 0e 00 	movl   $0xe1c,0x4(%esp)
 55b:	00 
 55c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 563:	e8 0d 04 00 00       	call   975 <printf>
  exit();
 568:	e8 68 02 00 00       	call   7d5 <exit>

0000056d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 56d:	55                   	push   %ebp
 56e:	89 e5                	mov    %esp,%ebp
 570:	57                   	push   %edi
 571:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 572:	8b 4d 08             	mov    0x8(%ebp),%ecx
 575:	8b 55 10             	mov    0x10(%ebp),%edx
 578:	8b 45 0c             	mov    0xc(%ebp),%eax
 57b:	89 cb                	mov    %ecx,%ebx
 57d:	89 df                	mov    %ebx,%edi
 57f:	89 d1                	mov    %edx,%ecx
 581:	fc                   	cld    
 582:	f3 aa                	rep stos %al,%es:(%edi)
 584:	89 ca                	mov    %ecx,%edx
 586:	89 fb                	mov    %edi,%ebx
 588:	89 5d 08             	mov    %ebx,0x8(%ebp)
 58b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 58e:	5b                   	pop    %ebx
 58f:	5f                   	pop    %edi
 590:	5d                   	pop    %ebp
 591:	c3                   	ret    

00000592 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 592:	55                   	push   %ebp
 593:	89 e5                	mov    %esp,%ebp
 595:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 59e:	90                   	nop
 59f:	8b 45 08             	mov    0x8(%ebp),%eax
 5a2:	8d 50 01             	lea    0x1(%eax),%edx
 5a5:	89 55 08             	mov    %edx,0x8(%ebp)
 5a8:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ab:	8d 4a 01             	lea    0x1(%edx),%ecx
 5ae:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 5b1:	0f b6 12             	movzbl (%edx),%edx
 5b4:	88 10                	mov    %dl,(%eax)
 5b6:	0f b6 00             	movzbl (%eax),%eax
 5b9:	84 c0                	test   %al,%al
 5bb:	75 e2                	jne    59f <strcpy+0xd>
    ;
  return os;
 5bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5c0:	c9                   	leave  
 5c1:	c3                   	ret    

000005c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5c2:	55                   	push   %ebp
 5c3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 5c5:	eb 08                	jmp    5cf <strcmp+0xd>
    p++, q++;
 5c7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5cb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 5cf:	8b 45 08             	mov    0x8(%ebp),%eax
 5d2:	0f b6 00             	movzbl (%eax),%eax
 5d5:	84 c0                	test   %al,%al
 5d7:	74 10                	je     5e9 <strcmp+0x27>
 5d9:	8b 45 08             	mov    0x8(%ebp),%eax
 5dc:	0f b6 10             	movzbl (%eax),%edx
 5df:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e2:	0f b6 00             	movzbl (%eax),%eax
 5e5:	38 c2                	cmp    %al,%dl
 5e7:	74 de                	je     5c7 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 5e9:	8b 45 08             	mov    0x8(%ebp),%eax
 5ec:	0f b6 00             	movzbl (%eax),%eax
 5ef:	0f b6 d0             	movzbl %al,%edx
 5f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f5:	0f b6 00             	movzbl (%eax),%eax
 5f8:	0f b6 c0             	movzbl %al,%eax
 5fb:	29 c2                	sub    %eax,%edx
 5fd:	89 d0                	mov    %edx,%eax
}
 5ff:	5d                   	pop    %ebp
 600:	c3                   	ret    

00000601 <strlen>:

uint
strlen(char *s)
{
 601:	55                   	push   %ebp
 602:	89 e5                	mov    %esp,%ebp
 604:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 607:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 60e:	eb 04                	jmp    614 <strlen+0x13>
 610:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 614:	8b 55 fc             	mov    -0x4(%ebp),%edx
 617:	8b 45 08             	mov    0x8(%ebp),%eax
 61a:	01 d0                	add    %edx,%eax
 61c:	0f b6 00             	movzbl (%eax),%eax
 61f:	84 c0                	test   %al,%al
 621:	75 ed                	jne    610 <strlen+0xf>
    ;
  return n;
 623:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 626:	c9                   	leave  
 627:	c3                   	ret    

00000628 <memset>:

void*
memset(void *dst, int c, uint n)
{
 628:	55                   	push   %ebp
 629:	89 e5                	mov    %esp,%ebp
 62b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 62e:	8b 45 10             	mov    0x10(%ebp),%eax
 631:	89 44 24 08          	mov    %eax,0x8(%esp)
 635:	8b 45 0c             	mov    0xc(%ebp),%eax
 638:	89 44 24 04          	mov    %eax,0x4(%esp)
 63c:	8b 45 08             	mov    0x8(%ebp),%eax
 63f:	89 04 24             	mov    %eax,(%esp)
 642:	e8 26 ff ff ff       	call   56d <stosb>
  return dst;
 647:	8b 45 08             	mov    0x8(%ebp),%eax
}
 64a:	c9                   	leave  
 64b:	c3                   	ret    

0000064c <strchr>:

char*
strchr(const char *s, char c)
{
 64c:	55                   	push   %ebp
 64d:	89 e5                	mov    %esp,%ebp
 64f:	83 ec 04             	sub    $0x4,%esp
 652:	8b 45 0c             	mov    0xc(%ebp),%eax
 655:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 658:	eb 14                	jmp    66e <strchr+0x22>
    if(*s == c)
 65a:	8b 45 08             	mov    0x8(%ebp),%eax
 65d:	0f b6 00             	movzbl (%eax),%eax
 660:	3a 45 fc             	cmp    -0x4(%ebp),%al
 663:	75 05                	jne    66a <strchr+0x1e>
      return (char*)s;
 665:	8b 45 08             	mov    0x8(%ebp),%eax
 668:	eb 13                	jmp    67d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 66a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 66e:	8b 45 08             	mov    0x8(%ebp),%eax
 671:	0f b6 00             	movzbl (%eax),%eax
 674:	84 c0                	test   %al,%al
 676:	75 e2                	jne    65a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 678:	b8 00 00 00 00       	mov    $0x0,%eax
}
 67d:	c9                   	leave  
 67e:	c3                   	ret    

0000067f <gets>:

char*
gets(char *buf, int max)
{
 67f:	55                   	push   %ebp
 680:	89 e5                	mov    %esp,%ebp
 682:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 68c:	eb 4c                	jmp    6da <gets+0x5b>
    cc = read(0, &c, 1);
 68e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 695:	00 
 696:	8d 45 ef             	lea    -0x11(%ebp),%eax
 699:	89 44 24 04          	mov    %eax,0x4(%esp)
 69d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 6a4:	e8 44 01 00 00       	call   7ed <read>
 6a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 6ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6b0:	7f 02                	jg     6b4 <gets+0x35>
      break;
 6b2:	eb 31                	jmp    6e5 <gets+0x66>
    buf[i++] = c;
 6b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b7:	8d 50 01             	lea    0x1(%eax),%edx
 6ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6bd:	89 c2                	mov    %eax,%edx
 6bf:	8b 45 08             	mov    0x8(%ebp),%eax
 6c2:	01 c2                	add    %eax,%edx
 6c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6c8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 6ca:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6ce:	3c 0a                	cmp    $0xa,%al
 6d0:	74 13                	je     6e5 <gets+0x66>
 6d2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6d6:	3c 0d                	cmp    $0xd,%al
 6d8:	74 0b                	je     6e5 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6dd:	83 c0 01             	add    $0x1,%eax
 6e0:	3b 45 0c             	cmp    0xc(%ebp),%eax
 6e3:	7c a9                	jl     68e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 6e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6e8:	8b 45 08             	mov    0x8(%ebp),%eax
 6eb:	01 d0                	add    %edx,%eax
 6ed:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 6f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6f3:	c9                   	leave  
 6f4:	c3                   	ret    

000006f5 <stat>:

int
stat(char *n, struct stat *st)
{
 6f5:	55                   	push   %ebp
 6f6:	89 e5                	mov    %esp,%ebp
 6f8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 702:	00 
 703:	8b 45 08             	mov    0x8(%ebp),%eax
 706:	89 04 24             	mov    %eax,(%esp)
 709:	e8 07 01 00 00       	call   815 <open>
 70e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 711:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 715:	79 07                	jns    71e <stat+0x29>
    return -1;
 717:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 71c:	eb 23                	jmp    741 <stat+0x4c>
  r = fstat(fd, st);
 71e:	8b 45 0c             	mov    0xc(%ebp),%eax
 721:	89 44 24 04          	mov    %eax,0x4(%esp)
 725:	8b 45 f4             	mov    -0xc(%ebp),%eax
 728:	89 04 24             	mov    %eax,(%esp)
 72b:	e8 fd 00 00 00       	call   82d <fstat>
 730:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 733:	8b 45 f4             	mov    -0xc(%ebp),%eax
 736:	89 04 24             	mov    %eax,(%esp)
 739:	e8 bf 00 00 00       	call   7fd <close>
  return r;
 73e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 741:	c9                   	leave  
 742:	c3                   	ret    

00000743 <atoi>:

int
atoi(const char *s)
{
 743:	55                   	push   %ebp
 744:	89 e5                	mov    %esp,%ebp
 746:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 749:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 750:	eb 25                	jmp    777 <atoi+0x34>
    n = n*10 + *s++ - '0';
 752:	8b 55 fc             	mov    -0x4(%ebp),%edx
 755:	89 d0                	mov    %edx,%eax
 757:	c1 e0 02             	shl    $0x2,%eax
 75a:	01 d0                	add    %edx,%eax
 75c:	01 c0                	add    %eax,%eax
 75e:	89 c1                	mov    %eax,%ecx
 760:	8b 45 08             	mov    0x8(%ebp),%eax
 763:	8d 50 01             	lea    0x1(%eax),%edx
 766:	89 55 08             	mov    %edx,0x8(%ebp)
 769:	0f b6 00             	movzbl (%eax),%eax
 76c:	0f be c0             	movsbl %al,%eax
 76f:	01 c8                	add    %ecx,%eax
 771:	83 e8 30             	sub    $0x30,%eax
 774:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 777:	8b 45 08             	mov    0x8(%ebp),%eax
 77a:	0f b6 00             	movzbl (%eax),%eax
 77d:	3c 2f                	cmp    $0x2f,%al
 77f:	7e 0a                	jle    78b <atoi+0x48>
 781:	8b 45 08             	mov    0x8(%ebp),%eax
 784:	0f b6 00             	movzbl (%eax),%eax
 787:	3c 39                	cmp    $0x39,%al
 789:	7e c7                	jle    752 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 78e:	c9                   	leave  
 78f:	c3                   	ret    

00000790 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 790:	55                   	push   %ebp
 791:	89 e5                	mov    %esp,%ebp
 793:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 796:	8b 45 08             	mov    0x8(%ebp),%eax
 799:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 79c:	8b 45 0c             	mov    0xc(%ebp),%eax
 79f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 7a2:	eb 17                	jmp    7bb <memmove+0x2b>
    *dst++ = *src++;
 7a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a7:	8d 50 01             	lea    0x1(%eax),%edx
 7aa:	89 55 fc             	mov    %edx,-0x4(%ebp)
 7ad:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7b0:	8d 4a 01             	lea    0x1(%edx),%ecx
 7b3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 7b6:	0f b6 12             	movzbl (%edx),%edx
 7b9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 7bb:	8b 45 10             	mov    0x10(%ebp),%eax
 7be:	8d 50 ff             	lea    -0x1(%eax),%edx
 7c1:	89 55 10             	mov    %edx,0x10(%ebp)
 7c4:	85 c0                	test   %eax,%eax
 7c6:	7f dc                	jg     7a4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 7c8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7cb:	c9                   	leave  
 7cc:	c3                   	ret    

000007cd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 7cd:	b8 01 00 00 00       	mov    $0x1,%eax
 7d2:	cd 40                	int    $0x40
 7d4:	c3                   	ret    

000007d5 <exit>:
SYSCALL(exit)
 7d5:	b8 02 00 00 00       	mov    $0x2,%eax
 7da:	cd 40                	int    $0x40
 7dc:	c3                   	ret    

000007dd <wait>:
SYSCALL(wait)
 7dd:	b8 03 00 00 00       	mov    $0x3,%eax
 7e2:	cd 40                	int    $0x40
 7e4:	c3                   	ret    

000007e5 <pipe>:
SYSCALL(pipe)
 7e5:	b8 04 00 00 00       	mov    $0x4,%eax
 7ea:	cd 40                	int    $0x40
 7ec:	c3                   	ret    

000007ed <read>:
SYSCALL(read)
 7ed:	b8 05 00 00 00       	mov    $0x5,%eax
 7f2:	cd 40                	int    $0x40
 7f4:	c3                   	ret    

000007f5 <write>:
SYSCALL(write)
 7f5:	b8 10 00 00 00       	mov    $0x10,%eax
 7fa:	cd 40                	int    $0x40
 7fc:	c3                   	ret    

000007fd <close>:
SYSCALL(close)
 7fd:	b8 15 00 00 00       	mov    $0x15,%eax
 802:	cd 40                	int    $0x40
 804:	c3                   	ret    

00000805 <kill>:
SYSCALL(kill)
 805:	b8 06 00 00 00       	mov    $0x6,%eax
 80a:	cd 40                	int    $0x40
 80c:	c3                   	ret    

0000080d <exec>:
SYSCALL(exec)
 80d:	b8 07 00 00 00       	mov    $0x7,%eax
 812:	cd 40                	int    $0x40
 814:	c3                   	ret    

00000815 <open>:
SYSCALL(open)
 815:	b8 0f 00 00 00       	mov    $0xf,%eax
 81a:	cd 40                	int    $0x40
 81c:	c3                   	ret    

0000081d <mknod>:
SYSCALL(mknod)
 81d:	b8 11 00 00 00       	mov    $0x11,%eax
 822:	cd 40                	int    $0x40
 824:	c3                   	ret    

00000825 <unlink>:
SYSCALL(unlink)
 825:	b8 12 00 00 00       	mov    $0x12,%eax
 82a:	cd 40                	int    $0x40
 82c:	c3                   	ret    

0000082d <fstat>:
SYSCALL(fstat)
 82d:	b8 08 00 00 00       	mov    $0x8,%eax
 832:	cd 40                	int    $0x40
 834:	c3                   	ret    

00000835 <link>:
SYSCALL(link)
 835:	b8 13 00 00 00       	mov    $0x13,%eax
 83a:	cd 40                	int    $0x40
 83c:	c3                   	ret    

0000083d <mkdir>:
SYSCALL(mkdir)
 83d:	b8 14 00 00 00       	mov    $0x14,%eax
 842:	cd 40                	int    $0x40
 844:	c3                   	ret    

00000845 <chdir>:
SYSCALL(chdir)
 845:	b8 09 00 00 00       	mov    $0x9,%eax
 84a:	cd 40                	int    $0x40
 84c:	c3                   	ret    

0000084d <dup>:
SYSCALL(dup)
 84d:	b8 0a 00 00 00       	mov    $0xa,%eax
 852:	cd 40                	int    $0x40
 854:	c3                   	ret    

00000855 <getpid>:
SYSCALL(getpid)
 855:	b8 0b 00 00 00       	mov    $0xb,%eax
 85a:	cd 40                	int    $0x40
 85c:	c3                   	ret    

0000085d <sbrk>:
SYSCALL(sbrk)
 85d:	b8 0c 00 00 00       	mov    $0xc,%eax
 862:	cd 40                	int    $0x40
 864:	c3                   	ret    

00000865 <sleep>:
SYSCALL(sleep)
 865:	b8 0d 00 00 00       	mov    $0xd,%eax
 86a:	cd 40                	int    $0x40
 86c:	c3                   	ret    

0000086d <uptime>:
SYSCALL(uptime)
 86d:	b8 0e 00 00 00       	mov    $0xe,%eax
 872:	cd 40                	int    $0x40
 874:	c3                   	ret    

00000875 <sigset>:
SYSCALL(sigset)
 875:	b8 16 00 00 00       	mov    $0x16,%eax
 87a:	cd 40                	int    $0x40
 87c:	c3                   	ret    

0000087d <sigsend>:
SYSCALL(sigsend)
 87d:	b8 17 00 00 00       	mov    $0x17,%eax
 882:	cd 40                	int    $0x40
 884:	c3                   	ret    

00000885 <sigret>:
SYSCALL(sigret)
 885:	b8 18 00 00 00       	mov    $0x18,%eax
 88a:	cd 40                	int    $0x40
 88c:	c3                   	ret    

0000088d <sigpause>:
 88d:	b8 19 00 00 00       	mov    $0x19,%eax
 892:	cd 40                	int    $0x40
 894:	c3                   	ret    

00000895 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 895:	55                   	push   %ebp
 896:	89 e5                	mov    %esp,%ebp
 898:	83 ec 18             	sub    $0x18,%esp
 89b:	8b 45 0c             	mov    0xc(%ebp),%eax
 89e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 8a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 8a8:	00 
 8a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
 8ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 8b0:	8b 45 08             	mov    0x8(%ebp),%eax
 8b3:	89 04 24             	mov    %eax,(%esp)
 8b6:	e8 3a ff ff ff       	call   7f5 <write>
}
 8bb:	c9                   	leave  
 8bc:	c3                   	ret    

000008bd <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 8bd:	55                   	push   %ebp
 8be:	89 e5                	mov    %esp,%ebp
 8c0:	56                   	push   %esi
 8c1:	53                   	push   %ebx
 8c2:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 8c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 8cc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 8d0:	74 17                	je     8e9 <printint+0x2c>
 8d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 8d6:	79 11                	jns    8e9 <printint+0x2c>
    neg = 1;
 8d8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 8df:	8b 45 0c             	mov    0xc(%ebp),%eax
 8e2:	f7 d8                	neg    %eax
 8e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8e7:	eb 06                	jmp    8ef <printint+0x32>
  } else {
    x = xx;
 8e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 8ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 8ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 8f6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 8f9:	8d 41 01             	lea    0x1(%ecx),%eax
 8fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
 902:	8b 45 ec             	mov    -0x14(%ebp),%eax
 905:	ba 00 00 00 00       	mov    $0x0,%edx
 90a:	f7 f3                	div    %ebx
 90c:	89 d0                	mov    %edx,%eax
 90e:	0f b6 80 f8 10 00 00 	movzbl 0x10f8(%eax),%eax
 915:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 919:	8b 75 10             	mov    0x10(%ebp),%esi
 91c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 91f:	ba 00 00 00 00       	mov    $0x0,%edx
 924:	f7 f6                	div    %esi
 926:	89 45 ec             	mov    %eax,-0x14(%ebp)
 929:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 92d:	75 c7                	jne    8f6 <printint+0x39>
  if(neg)
 92f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 933:	74 10                	je     945 <printint+0x88>
    buf[i++] = '-';
 935:	8b 45 f4             	mov    -0xc(%ebp),%eax
 938:	8d 50 01             	lea    0x1(%eax),%edx
 93b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 93e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 943:	eb 1f                	jmp    964 <printint+0xa7>
 945:	eb 1d                	jmp    964 <printint+0xa7>
    putc(fd, buf[i]);
 947:	8d 55 dc             	lea    -0x24(%ebp),%edx
 94a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94d:	01 d0                	add    %edx,%eax
 94f:	0f b6 00             	movzbl (%eax),%eax
 952:	0f be c0             	movsbl %al,%eax
 955:	89 44 24 04          	mov    %eax,0x4(%esp)
 959:	8b 45 08             	mov    0x8(%ebp),%eax
 95c:	89 04 24             	mov    %eax,(%esp)
 95f:	e8 31 ff ff ff       	call   895 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 964:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 968:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 96c:	79 d9                	jns    947 <printint+0x8a>
    putc(fd, buf[i]);
}
 96e:	83 c4 30             	add    $0x30,%esp
 971:	5b                   	pop    %ebx
 972:	5e                   	pop    %esi
 973:	5d                   	pop    %ebp
 974:	c3                   	ret    

00000975 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 975:	55                   	push   %ebp
 976:	89 e5                	mov    %esp,%ebp
 978:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 97b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 982:	8d 45 0c             	lea    0xc(%ebp),%eax
 985:	83 c0 04             	add    $0x4,%eax
 988:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 98b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 992:	e9 7c 01 00 00       	jmp    b13 <printf+0x19e>
    c = fmt[i] & 0xff;
 997:	8b 55 0c             	mov    0xc(%ebp),%edx
 99a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99d:	01 d0                	add    %edx,%eax
 99f:	0f b6 00             	movzbl (%eax),%eax
 9a2:	0f be c0             	movsbl %al,%eax
 9a5:	25 ff 00 00 00       	and    $0xff,%eax
 9aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 9ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9b1:	75 2c                	jne    9df <printf+0x6a>
      if(c == '%'){
 9b3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9b7:	75 0c                	jne    9c5 <printf+0x50>
        state = '%';
 9b9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 9c0:	e9 4a 01 00 00       	jmp    b0f <printf+0x19a>
      } else {
        putc(fd, c);
 9c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9c8:	0f be c0             	movsbl %al,%eax
 9cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 9cf:	8b 45 08             	mov    0x8(%ebp),%eax
 9d2:	89 04 24             	mov    %eax,(%esp)
 9d5:	e8 bb fe ff ff       	call   895 <putc>
 9da:	e9 30 01 00 00       	jmp    b0f <printf+0x19a>
      }
    } else if(state == '%'){
 9df:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 9e3:	0f 85 26 01 00 00    	jne    b0f <printf+0x19a>
      if(c == 'd'){
 9e9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 9ed:	75 2d                	jne    a1c <printf+0xa7>
        printint(fd, *ap, 10, 1);
 9ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9f2:	8b 00                	mov    (%eax),%eax
 9f4:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 9fb:	00 
 9fc:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 a03:	00 
 a04:	89 44 24 04          	mov    %eax,0x4(%esp)
 a08:	8b 45 08             	mov    0x8(%ebp),%eax
 a0b:	89 04 24             	mov    %eax,(%esp)
 a0e:	e8 aa fe ff ff       	call   8bd <printint>
        ap++;
 a13:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a17:	e9 ec 00 00 00       	jmp    b08 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 a1c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 a20:	74 06                	je     a28 <printf+0xb3>
 a22:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 a26:	75 2d                	jne    a55 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 a28:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a2b:	8b 00                	mov    (%eax),%eax
 a2d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 a34:	00 
 a35:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 a3c:	00 
 a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
 a41:	8b 45 08             	mov    0x8(%ebp),%eax
 a44:	89 04 24             	mov    %eax,(%esp)
 a47:	e8 71 fe ff ff       	call   8bd <printint>
        ap++;
 a4c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a50:	e9 b3 00 00 00       	jmp    b08 <printf+0x193>
      } else if(c == 's'){
 a55:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a59:	75 45                	jne    aa0 <printf+0x12b>
        s = (char*)*ap;
 a5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a5e:	8b 00                	mov    (%eax),%eax
 a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a63:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a6b:	75 09                	jne    a76 <printf+0x101>
          s = "(null)";
 a6d:	c7 45 f4 2a 0e 00 00 	movl   $0xe2a,-0xc(%ebp)
        while(*s != 0){
 a74:	eb 1e                	jmp    a94 <printf+0x11f>
 a76:	eb 1c                	jmp    a94 <printf+0x11f>
          putc(fd, *s);
 a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7b:	0f b6 00             	movzbl (%eax),%eax
 a7e:	0f be c0             	movsbl %al,%eax
 a81:	89 44 24 04          	mov    %eax,0x4(%esp)
 a85:	8b 45 08             	mov    0x8(%ebp),%eax
 a88:	89 04 24             	mov    %eax,(%esp)
 a8b:	e8 05 fe ff ff       	call   895 <putc>
          s++;
 a90:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a97:	0f b6 00             	movzbl (%eax),%eax
 a9a:	84 c0                	test   %al,%al
 a9c:	75 da                	jne    a78 <printf+0x103>
 a9e:	eb 68                	jmp    b08 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 aa0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 aa4:	75 1d                	jne    ac3 <printf+0x14e>
        putc(fd, *ap);
 aa6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 aa9:	8b 00                	mov    (%eax),%eax
 aab:	0f be c0             	movsbl %al,%eax
 aae:	89 44 24 04          	mov    %eax,0x4(%esp)
 ab2:	8b 45 08             	mov    0x8(%ebp),%eax
 ab5:	89 04 24             	mov    %eax,(%esp)
 ab8:	e8 d8 fd ff ff       	call   895 <putc>
        ap++;
 abd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 ac1:	eb 45                	jmp    b08 <printf+0x193>
      } else if(c == '%'){
 ac3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 ac7:	75 17                	jne    ae0 <printf+0x16b>
        putc(fd, c);
 ac9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 acc:	0f be c0             	movsbl %al,%eax
 acf:	89 44 24 04          	mov    %eax,0x4(%esp)
 ad3:	8b 45 08             	mov    0x8(%ebp),%eax
 ad6:	89 04 24             	mov    %eax,(%esp)
 ad9:	e8 b7 fd ff ff       	call   895 <putc>
 ade:	eb 28                	jmp    b08 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 ae0:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 ae7:	00 
 ae8:	8b 45 08             	mov    0x8(%ebp),%eax
 aeb:	89 04 24             	mov    %eax,(%esp)
 aee:	e8 a2 fd ff ff       	call   895 <putc>
        putc(fd, c);
 af3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 af6:	0f be c0             	movsbl %al,%eax
 af9:	89 44 24 04          	mov    %eax,0x4(%esp)
 afd:	8b 45 08             	mov    0x8(%ebp),%eax
 b00:	89 04 24             	mov    %eax,(%esp)
 b03:	e8 8d fd ff ff       	call   895 <putc>
      }
      state = 0;
 b08:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 b0f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 b13:	8b 55 0c             	mov    0xc(%ebp),%edx
 b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b19:	01 d0                	add    %edx,%eax
 b1b:	0f b6 00             	movzbl (%eax),%eax
 b1e:	84 c0                	test   %al,%al
 b20:	0f 85 71 fe ff ff    	jne    997 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 b26:	c9                   	leave  
 b27:	c3                   	ret    

00000b28 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b28:	55                   	push   %ebp
 b29:	89 e5                	mov    %esp,%ebp
 b2b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b2e:	8b 45 08             	mov    0x8(%ebp),%eax
 b31:	83 e8 08             	sub    $0x8,%eax
 b34:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b37:	a1 1c 11 00 00       	mov    0x111c,%eax
 b3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b3f:	eb 24                	jmp    b65 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b41:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b44:	8b 00                	mov    (%eax),%eax
 b46:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b49:	77 12                	ja     b5d <free+0x35>
 b4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b4e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b51:	77 24                	ja     b77 <free+0x4f>
 b53:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b56:	8b 00                	mov    (%eax),%eax
 b58:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b5b:	77 1a                	ja     b77 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b60:	8b 00                	mov    (%eax),%eax
 b62:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b65:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b68:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b6b:	76 d4                	jbe    b41 <free+0x19>
 b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b70:	8b 00                	mov    (%eax),%eax
 b72:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b75:	76 ca                	jbe    b41 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 b77:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b7a:	8b 40 04             	mov    0x4(%eax),%eax
 b7d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b84:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b87:	01 c2                	add    %eax,%edx
 b89:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b8c:	8b 00                	mov    (%eax),%eax
 b8e:	39 c2                	cmp    %eax,%edx
 b90:	75 24                	jne    bb6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b92:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b95:	8b 50 04             	mov    0x4(%eax),%edx
 b98:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b9b:	8b 00                	mov    (%eax),%eax
 b9d:	8b 40 04             	mov    0x4(%eax),%eax
 ba0:	01 c2                	add    %eax,%edx
 ba2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ba5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 ba8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bab:	8b 00                	mov    (%eax),%eax
 bad:	8b 10                	mov    (%eax),%edx
 baf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bb2:	89 10                	mov    %edx,(%eax)
 bb4:	eb 0a                	jmp    bc0 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 bb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bb9:	8b 10                	mov    (%eax),%edx
 bbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bbe:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 bc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bc3:	8b 40 04             	mov    0x4(%eax),%eax
 bc6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd0:	01 d0                	add    %edx,%eax
 bd2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bd5:	75 20                	jne    bf7 <free+0xcf>
    p->s.size += bp->s.size;
 bd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bda:	8b 50 04             	mov    0x4(%eax),%edx
 bdd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 be0:	8b 40 04             	mov    0x4(%eax),%eax
 be3:	01 c2                	add    %eax,%edx
 be5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 be8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 beb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bee:	8b 10                	mov    (%eax),%edx
 bf0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf3:	89 10                	mov    %edx,(%eax)
 bf5:	eb 08                	jmp    bff <free+0xd7>
  } else
    p->s.ptr = bp;
 bf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bfa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 bfd:	89 10                	mov    %edx,(%eax)
  freep = p;
 bff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c02:	a3 1c 11 00 00       	mov    %eax,0x111c
}
 c07:	c9                   	leave  
 c08:	c3                   	ret    

00000c09 <morecore>:

static Header*
morecore(uint nu)
{
 c09:	55                   	push   %ebp
 c0a:	89 e5                	mov    %esp,%ebp
 c0c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 c0f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 c16:	77 07                	ja     c1f <morecore+0x16>
    nu = 4096;
 c18:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 c1f:	8b 45 08             	mov    0x8(%ebp),%eax
 c22:	c1 e0 03             	shl    $0x3,%eax
 c25:	89 04 24             	mov    %eax,(%esp)
 c28:	e8 30 fc ff ff       	call   85d <sbrk>
 c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 c30:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 c34:	75 07                	jne    c3d <morecore+0x34>
    return 0;
 c36:	b8 00 00 00 00       	mov    $0x0,%eax
 c3b:	eb 22                	jmp    c5f <morecore+0x56>
  hp = (Header*)p;
 c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c46:	8b 55 08             	mov    0x8(%ebp),%edx
 c49:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c4f:	83 c0 08             	add    $0x8,%eax
 c52:	89 04 24             	mov    %eax,(%esp)
 c55:	e8 ce fe ff ff       	call   b28 <free>
  return freep;
 c5a:	a1 1c 11 00 00       	mov    0x111c,%eax
}
 c5f:	c9                   	leave  
 c60:	c3                   	ret    

00000c61 <malloc>:

void*
malloc(uint nbytes)
{
 c61:	55                   	push   %ebp
 c62:	89 e5                	mov    %esp,%ebp
 c64:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c67:	8b 45 08             	mov    0x8(%ebp),%eax
 c6a:	83 c0 07             	add    $0x7,%eax
 c6d:	c1 e8 03             	shr    $0x3,%eax
 c70:	83 c0 01             	add    $0x1,%eax
 c73:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c76:	a1 1c 11 00 00       	mov    0x111c,%eax
 c7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c82:	75 23                	jne    ca7 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c84:	c7 45 f0 14 11 00 00 	movl   $0x1114,-0x10(%ebp)
 c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c8e:	a3 1c 11 00 00       	mov    %eax,0x111c
 c93:	a1 1c 11 00 00       	mov    0x111c,%eax
 c98:	a3 14 11 00 00       	mov    %eax,0x1114
    base.s.size = 0;
 c9d:	c7 05 18 11 00 00 00 	movl   $0x0,0x1118
 ca4:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 caa:	8b 00                	mov    (%eax),%eax
 cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cb2:	8b 40 04             	mov    0x4(%eax),%eax
 cb5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 cb8:	72 4d                	jb     d07 <malloc+0xa6>
      if(p->s.size == nunits)
 cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cbd:	8b 40 04             	mov    0x4(%eax),%eax
 cc0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 cc3:	75 0c                	jne    cd1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc8:	8b 10                	mov    (%eax),%edx
 cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ccd:	89 10                	mov    %edx,(%eax)
 ccf:	eb 26                	jmp    cf7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cd4:	8b 40 04             	mov    0x4(%eax),%eax
 cd7:	2b 45 ec             	sub    -0x14(%ebp),%eax
 cda:	89 c2                	mov    %eax,%edx
 cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cdf:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ce5:	8b 40 04             	mov    0x4(%eax),%eax
 ce8:	c1 e0 03             	shl    $0x3,%eax
 ceb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cf1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 cf4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cfa:	a3 1c 11 00 00       	mov    %eax,0x111c
      return (void*)(p + 1);
 cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d02:	83 c0 08             	add    $0x8,%eax
 d05:	eb 38                	jmp    d3f <malloc+0xde>
    }
    if(p == freep)
 d07:	a1 1c 11 00 00       	mov    0x111c,%eax
 d0c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 d0f:	75 1b                	jne    d2c <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 d11:	8b 45 ec             	mov    -0x14(%ebp),%eax
 d14:	89 04 24             	mov    %eax,(%esp)
 d17:	e8 ed fe ff ff       	call   c09 <morecore>
 d1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 d1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 d23:	75 07                	jne    d2c <malloc+0xcb>
        return 0;
 d25:	b8 00 00 00 00       	mov    $0x0,%eax
 d2a:	eb 13                	jmp    d3f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d35:	8b 00                	mov    (%eax),%eax
 d37:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 d3a:	e9 70 ff ff ff       	jmp    caf <malloc+0x4e>
}
 d3f:	c9                   	leave  
 d40:	c3                   	ret    
