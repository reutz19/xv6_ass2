
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
  bb:	e8 f2 06 00 00       	call   7b2 <exit>
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
  dc:	e8 79 07 00 00       	call   85a <sigsend>
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
  f6:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
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
 111:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
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
 13a:	c7 44 24 04 20 0d 00 	movl   $0xd20,0x4(%esp)
 141:	00 
 142:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 149:	e8 04 08 00 00       	call   952 <printf>
      workers[i].working = 0;
 14e:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
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
 16f:	a1 e8 10 00 00       	mov    0x10e8,%eax
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
 19c:	c7 44 24 04 4c 0d 00 	movl   $0xd4c,0x4(%esp)
 1a3:	00 
 1a4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1ab:	e8 a2 07 00 00       	call   952 <printf>
    exit();
 1b0:	e8 fd 05 00 00       	call   7b2 <exit>
  }

  // allocate workers array
  workers_number = atoi(argv[1]);
 1b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b8:	83 c0 04             	add    $0x4,%eax
 1bb:	8b 00                	mov    (%eax),%eax
 1bd:	89 04 24             	mov    %eax,(%esp)
 1c0:	e8 5b 05 00 00       	call   720 <atoi>
 1c5:	a3 e8 10 00 00       	mov    %eax,0x10e8
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
 1ca:	a1 e8 10 00 00       	mov    0x10e8,%eax
 1cf:	89 c2                	mov    %eax,%edx
 1d1:	89 d0                	mov    %edx,%eax
 1d3:	01 c0                	add    %eax,%eax
 1d5:	01 d0                	add    %edx,%eax
 1d7:	c1 e0 02             	shl    $0x2,%eax
 1da:	89 04 24             	mov    %eax,(%esp)
 1dd:	e8 5c 0a 00 00       	call   c3e <malloc>
 1e2:	a3 ec 10 00 00       	mov    %eax,0x10ec
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
 1e7:	c7 04 24 af 00 00 00 	movl   $0xaf,(%esp)
 1ee:	e8 5f 06 00 00       	call   852 <sigset>
  printf(STDOUT, "workers pids:\n");
 1f3:	c7 44 24 04 70 0d 00 	movl   $0xd70,0x4(%esp)
 1fa:	00 
 1fb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 202:	e8 4b 07 00 00       	call   952 <printf>
  for(i = 0; i < workers_number; i++) {
 207:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 20e:	00 00 00 00 
 212:	e9 cd 00 00 00       	jmp    2e4 <main+0x165>
    
    if ((pid = fork()) == 0) {  // son
 217:	e8 8e 05 00 00       	call   7aa <fork>
 21c:	89 84 24 84 00 00 00 	mov    %eax,0x84(%esp)
 223:	83 bc 24 84 00 00 00 	cmpl   $0x0,0x84(%esp)
 22a:	00 
 22b:	75 07                	jne    234 <main+0xb5>
      while(1) sigpause();
 22d:	e8 38 06 00 00       	call   86a <sigpause>
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
 24d:	c7 44 24 04 7f 0d 00 	movl   $0xd7f,0x4(%esp)
 254:	00 
 255:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 25c:	e8 f1 06 00 00       	call   952 <printf>
      workers[i].pid = pid;
 261:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
 267:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 26e:	89 d0                	mov    %edx,%eax
 270:	01 c0                	add    %eax,%eax
 272:	01 d0                	add    %edx,%eax
 274:	c1 e0 02             	shl    $0x2,%eax
 277:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 27a:	8b 84 24 84 00 00 00 	mov    0x84(%esp),%eax
 281:	89 02                	mov    %eax,(%edx)
      workers[i].input_x = -1;
 283:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
 289:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 290:	89 d0                	mov    %edx,%eax
 292:	01 c0                	add    %eax,%eax
 294:	01 d0                	add    %edx,%eax
 296:	c1 e0 02             	shl    $0x2,%eax
 299:	01 c8                	add    %ecx,%eax
 29b:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
      workers[i].working = 0;
 2a2:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
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
 2cb:	c7 44 24 04 83 0d 00 	movl   $0xd83,0x4(%esp)
 2d2:	00 
 2d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2da:	e8 73 06 00 00       	call   952 <printf>
      exit();
 2df:	e8 ce 04 00 00       	call   7b2 <exit>
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
  printf(STDOUT, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
 2e4:	a1 e8 10 00 00       	mov    0x10e8,%eax
 2e9:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 2f0:	0f 8c 21 ff ff ff    	jl     217 <main+0x98>
      exit();
    }
  }

  // configure the main process - correct handler
  sigset((void *)handle_main_sig);
 2f6:	c7 04 24 e7 00 00 00 	movl   $0xe7,(%esp)
 2fd:	e8 50 05 00 00       	call   852 <sigset>

  while(toRun)
 302:	e9 e7 01 00 00       	jmp    4ee <main+0x36f>
  {
    printf(STDOUT, "Please enter a number: ");
 307:	c7 44 24 04 93 0d 00 	movl   $0xd93,0x4(%esp)
 30e:	00 
 30f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 316:	e8 37 06 00 00       	call   952 <printf>

    read(1, buf, MAX_INPUT);
 31b:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
 322:	00 
 323:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 327:	89 44 24 04          	mov    %eax,0x4(%esp)
 32b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 332:	e8 93 04 00 00       	call   7ca <read>
    
    if (buf[0] == '\n'){ //handle main signals
 337:	0f b6 44 24 1c       	movzbl 0x1c(%esp),%eax
 33c:	3c 0a                	cmp    $0xa,%al
 33e:	75 05                	jne    345 <main+0x1c6>
      continue;
 340:	e9 a9 01 00 00       	jmp    4ee <main+0x36f>
    }

    input_x = atoi(buf);
 345:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 349:	89 04 24             	mov    %eax,(%esp)
 34c:	e8 cf 03 00 00       	call   720 <atoi>
 351:	89 84 24 80 00 00 00 	mov    %eax,0x80(%esp)

    if(input_x != 0)
 358:	83 bc 24 80 00 00 00 	cmpl   $0x0,0x80(%esp)
 35f:	00 
 360:	0f 84 fe 00 00 00    	je     464 <main+0x2e5>
    {
      //for (bob = 0; bob < input_x; bob++) 
      //{
        // send input_x to process p using sigsend sys-call 
        for (i = 0; i < workers_number; i++)
 366:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 36d:	00 00 00 00 
 371:	e9 b1 00 00 00       	jmp    427 <main+0x2a8>
        {
          if (workers[i].working == 0) // available
 376:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
 37c:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 383:	89 d0                	mov    %edx,%eax
 385:	01 c0                	add    %eax,%eax
 387:	01 d0                	add    %edx,%eax
 389:	c1 e0 02             	shl    $0x2,%eax
 38c:	01 c8                	add    %ecx,%eax
 38e:	8b 40 08             	mov    0x8(%eax),%eax
 391:	85 c0                	test   %eax,%eax
 393:	0f 85 86 00 00 00    	jne    41f <main+0x2a0>
          {
            workers[i].working = 1;
 399:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
 39f:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3a6:	89 d0                	mov    %edx,%eax
 3a8:	01 c0                	add    %eax,%eax
 3aa:	01 d0                	add    %edx,%eax
 3ac:	c1 e0 02             	shl    $0x2,%eax
 3af:	01 c8                	add    %ecx,%eax
 3b1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
            //workers[i].input_x = bob + 1;//input_x;
            //if (sigsend(workers[i].pid, bob + 1))//input_x);
            if (sigsend(workers[i].pid, input_x))//input_x);    
 3b8:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
 3be:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3c5:	89 d0                	mov    %edx,%eax
 3c7:	01 c0                	add    %eax,%eax
 3c9:	01 d0                	add    %edx,%eax
 3cb:	c1 e0 02             	shl    $0x2,%eax
 3ce:	01 c8                	add    %ecx,%eax
 3d0:	8b 00                	mov    (%eax),%eax
 3d2:	8b 94 24 80 00 00 00 	mov    0x80(%esp),%edx
 3d9:	89 54 24 04          	mov    %edx,0x4(%esp)
 3dd:	89 04 24             	mov    %eax,(%esp)
 3e0:	e8 75 04 00 00       	call   85a <sigsend>
 3e5:	85 c0                	test   %eax,%eax
 3e7:	74 34                	je     41d <main+0x29e>
              printf(1, "********** failed to sigsend to worker %d\n", workers[i].pid);
 3e9:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
 3ef:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3f6:	89 d0                	mov    %edx,%eax
 3f8:	01 c0                	add    %eax,%eax
 3fa:	01 d0                	add    %edx,%eax
 3fc:	c1 e0 02             	shl    $0x2,%eax
 3ff:	01 c8                	add    %ecx,%eax
 401:	8b 00                	mov    (%eax),%eax
 403:	89 44 24 08          	mov    %eax,0x8(%esp)
 407:	c7 44 24 04 ac 0d 00 	movl   $0xdac,0x4(%esp)
 40e:	00 
 40f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 416:	e8 37 05 00 00       	call   952 <printf>
            break;
 41b:	eb 1c                	jmp    439 <main+0x2ba>
 41d:	eb 1a                	jmp    439 <main+0x2ba>
    if(input_x != 0)
    {
      //for (bob = 0; bob < input_x; bob++) 
      //{
        // send input_x to process p using sigsend sys-call 
        for (i = 0; i < workers_number; i++)
 41f:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 426:	01 
 427:	a1 e8 10 00 00       	mov    0x10e8,%eax
 42c:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 433:	0f 8c 3d ff ff ff    	jl     376 <main+0x1f7>
            break;
          }
        }

        // no idle workers to handle signal
        if (i == workers_number){
 439:	a1 e8 10 00 00       	mov    0x10e8,%eax
 43e:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 445:	0f 85 a3 00 00 00    	jne    4ee <main+0x36f>
          printf(STDOUT, "no idle workers\n");
 44b:	c7 44 24 04 d7 0d 00 	movl   $0xdd7,0x4(%esp)
 452:	00 
 453:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 45a:	e8 f3 04 00 00       	call   952 <printf>
 45f:	e9 8a 00 00 00       	jmp    4ee <main+0x36f>
      //}
    }

    else // input_x == 0, exiting program
    {
      for (i = 0; i < workers_number; i++)
 464:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 46b:	00 00 00 00 
 46f:	eb 64                	jmp    4d5 <main+0x356>
      {
        sigsend(workers[i].pid, 0);
 471:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
 477:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 47e:	89 d0                	mov    %edx,%eax
 480:	01 c0                	add    %eax,%eax
 482:	01 d0                	add    %edx,%eax
 484:	c1 e0 02             	shl    $0x2,%eax
 487:	01 c8                	add    %ecx,%eax
 489:	8b 00                	mov    (%eax),%eax
 48b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 492:	00 
 493:	89 04 24             	mov    %eax,(%esp)
 496:	e8 bf 03 00 00       	call   85a <sigsend>
        printf(STDOUT, "worker %d exit\n", workers[i].pid);
 49b:	8b 0d ec 10 00 00    	mov    0x10ec,%ecx
 4a1:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 4a8:	89 d0                	mov    %edx,%eax
 4aa:	01 c0                	add    %eax,%eax
 4ac:	01 d0                	add    %edx,%eax
 4ae:	c1 e0 02             	shl    $0x2,%eax
 4b1:	01 c8                	add    %ecx,%eax
 4b3:	8b 00                	mov    (%eax),%eax
 4b5:	89 44 24 08          	mov    %eax,0x8(%esp)
 4b9:	c7 44 24 04 e8 0d 00 	movl   $0xde8,0x4(%esp)
 4c0:	00 
 4c1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 4c8:	e8 85 04 00 00       	call   952 <printf>
      //}
    }

    else // input_x == 0, exiting program
    {
      for (i = 0; i < workers_number; i++)
 4cd:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 4d4:	01 
 4d5:	a1 e8 10 00 00       	mov    0x10e8,%eax
 4da:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 4e1:	7c 8e                	jl     471 <main+0x2f2>
      {
        sigsend(workers[i].pid, 0);
        printf(STDOUT, "worker %d exit\n", workers[i].pid);
      }
      toRun = 0;
 4e3:	c7 84 24 88 00 00 00 	movl   $0x0,0x88(%esp)
 4ea:	00 00 00 00 
  }

  // configure the main process - correct handler
  sigset((void *)handle_main_sig);

  while(toRun)
 4ee:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
 4f5:	00 
 4f6:	0f 85 0b fe ff ff    	jne    307 <main+0x188>
      }
      toRun = 0;
    }
  }
  
  for(i = 0; i < workers_number; i++)
 4fc:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 503:	00 00 00 00 
 507:	eb 0d                	jmp    516 <main+0x397>
    wait();
 509:	e8 ac 02 00 00       	call   7ba <wait>
      }
      toRun = 0;
    }
  }
  
  for(i = 0; i < workers_number; i++)
 50e:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 515:	01 
 516:	a1 e8 10 00 00       	mov    0x10e8,%eax
 51b:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 522:	7c e5                	jl     509 <main+0x38a>
    wait();
  free(workers);
 524:	a1 ec 10 00 00       	mov    0x10ec,%eax
 529:	89 04 24             	mov    %eax,(%esp)
 52c:	e8 d4 05 00 00       	call   b05 <free>
  printf(STDOUT, "primsrv exit\n");
 531:	c7 44 24 04 f8 0d 00 	movl   $0xdf8,0x4(%esp)
 538:	00 
 539:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 540:	e8 0d 04 00 00       	call   952 <printf>
  exit();
 545:	e8 68 02 00 00       	call   7b2 <exit>

0000054a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 54a:	55                   	push   %ebp
 54b:	89 e5                	mov    %esp,%ebp
 54d:	57                   	push   %edi
 54e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 54f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 552:	8b 55 10             	mov    0x10(%ebp),%edx
 555:	8b 45 0c             	mov    0xc(%ebp),%eax
 558:	89 cb                	mov    %ecx,%ebx
 55a:	89 df                	mov    %ebx,%edi
 55c:	89 d1                	mov    %edx,%ecx
 55e:	fc                   	cld    
 55f:	f3 aa                	rep stos %al,%es:(%edi)
 561:	89 ca                	mov    %ecx,%edx
 563:	89 fb                	mov    %edi,%ebx
 565:	89 5d 08             	mov    %ebx,0x8(%ebp)
 568:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 56b:	5b                   	pop    %ebx
 56c:	5f                   	pop    %edi
 56d:	5d                   	pop    %ebp
 56e:	c3                   	ret    

0000056f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 56f:	55                   	push   %ebp
 570:	89 e5                	mov    %esp,%ebp
 572:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 575:	8b 45 08             	mov    0x8(%ebp),%eax
 578:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 57b:	90                   	nop
 57c:	8b 45 08             	mov    0x8(%ebp),%eax
 57f:	8d 50 01             	lea    0x1(%eax),%edx
 582:	89 55 08             	mov    %edx,0x8(%ebp)
 585:	8b 55 0c             	mov    0xc(%ebp),%edx
 588:	8d 4a 01             	lea    0x1(%edx),%ecx
 58b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 58e:	0f b6 12             	movzbl (%edx),%edx
 591:	88 10                	mov    %dl,(%eax)
 593:	0f b6 00             	movzbl (%eax),%eax
 596:	84 c0                	test   %al,%al
 598:	75 e2                	jne    57c <strcpy+0xd>
    ;
  return os;
 59a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 59d:	c9                   	leave  
 59e:	c3                   	ret    

0000059f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 59f:	55                   	push   %ebp
 5a0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 5a2:	eb 08                	jmp    5ac <strcmp+0xd>
    p++, q++;
 5a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 5ac:	8b 45 08             	mov    0x8(%ebp),%eax
 5af:	0f b6 00             	movzbl (%eax),%eax
 5b2:	84 c0                	test   %al,%al
 5b4:	74 10                	je     5c6 <strcmp+0x27>
 5b6:	8b 45 08             	mov    0x8(%ebp),%eax
 5b9:	0f b6 10             	movzbl (%eax),%edx
 5bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 5bf:	0f b6 00             	movzbl (%eax),%eax
 5c2:	38 c2                	cmp    %al,%dl
 5c4:	74 de                	je     5a4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 5c6:	8b 45 08             	mov    0x8(%ebp),%eax
 5c9:	0f b6 00             	movzbl (%eax),%eax
 5cc:	0f b6 d0             	movzbl %al,%edx
 5cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d2:	0f b6 00             	movzbl (%eax),%eax
 5d5:	0f b6 c0             	movzbl %al,%eax
 5d8:	29 c2                	sub    %eax,%edx
 5da:	89 d0                	mov    %edx,%eax
}
 5dc:	5d                   	pop    %ebp
 5dd:	c3                   	ret    

000005de <strlen>:

uint
strlen(char *s)
{
 5de:	55                   	push   %ebp
 5df:	89 e5                	mov    %esp,%ebp
 5e1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 5e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 5eb:	eb 04                	jmp    5f1 <strlen+0x13>
 5ed:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 5f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	01 d0                	add    %edx,%eax
 5f9:	0f b6 00             	movzbl (%eax),%eax
 5fc:	84 c0                	test   %al,%al
 5fe:	75 ed                	jne    5ed <strlen+0xf>
    ;
  return n;
 600:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 603:	c9                   	leave  
 604:	c3                   	ret    

00000605 <memset>:

void*
memset(void *dst, int c, uint n)
{
 605:	55                   	push   %ebp
 606:	89 e5                	mov    %esp,%ebp
 608:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 60b:	8b 45 10             	mov    0x10(%ebp),%eax
 60e:	89 44 24 08          	mov    %eax,0x8(%esp)
 612:	8b 45 0c             	mov    0xc(%ebp),%eax
 615:	89 44 24 04          	mov    %eax,0x4(%esp)
 619:	8b 45 08             	mov    0x8(%ebp),%eax
 61c:	89 04 24             	mov    %eax,(%esp)
 61f:	e8 26 ff ff ff       	call   54a <stosb>
  return dst;
 624:	8b 45 08             	mov    0x8(%ebp),%eax
}
 627:	c9                   	leave  
 628:	c3                   	ret    

00000629 <strchr>:

char*
strchr(const char *s, char c)
{
 629:	55                   	push   %ebp
 62a:	89 e5                	mov    %esp,%ebp
 62c:	83 ec 04             	sub    $0x4,%esp
 62f:	8b 45 0c             	mov    0xc(%ebp),%eax
 632:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 635:	eb 14                	jmp    64b <strchr+0x22>
    if(*s == c)
 637:	8b 45 08             	mov    0x8(%ebp),%eax
 63a:	0f b6 00             	movzbl (%eax),%eax
 63d:	3a 45 fc             	cmp    -0x4(%ebp),%al
 640:	75 05                	jne    647 <strchr+0x1e>
      return (char*)s;
 642:	8b 45 08             	mov    0x8(%ebp),%eax
 645:	eb 13                	jmp    65a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 647:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 64b:	8b 45 08             	mov    0x8(%ebp),%eax
 64e:	0f b6 00             	movzbl (%eax),%eax
 651:	84 c0                	test   %al,%al
 653:	75 e2                	jne    637 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 655:	b8 00 00 00 00       	mov    $0x0,%eax
}
 65a:	c9                   	leave  
 65b:	c3                   	ret    

0000065c <gets>:

char*
gets(char *buf, int max)
{
 65c:	55                   	push   %ebp
 65d:	89 e5                	mov    %esp,%ebp
 65f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 662:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 669:	eb 4c                	jmp    6b7 <gets+0x5b>
    cc = read(0, &c, 1);
 66b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 672:	00 
 673:	8d 45 ef             	lea    -0x11(%ebp),%eax
 676:	89 44 24 04          	mov    %eax,0x4(%esp)
 67a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 681:	e8 44 01 00 00       	call   7ca <read>
 686:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 689:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 68d:	7f 02                	jg     691 <gets+0x35>
      break;
 68f:	eb 31                	jmp    6c2 <gets+0x66>
    buf[i++] = c;
 691:	8b 45 f4             	mov    -0xc(%ebp),%eax
 694:	8d 50 01             	lea    0x1(%eax),%edx
 697:	89 55 f4             	mov    %edx,-0xc(%ebp)
 69a:	89 c2                	mov    %eax,%edx
 69c:	8b 45 08             	mov    0x8(%ebp),%eax
 69f:	01 c2                	add    %eax,%edx
 6a1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6a5:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 6a7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6ab:	3c 0a                	cmp    $0xa,%al
 6ad:	74 13                	je     6c2 <gets+0x66>
 6af:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6b3:	3c 0d                	cmp    $0xd,%al
 6b5:	74 0b                	je     6c2 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ba:	83 c0 01             	add    $0x1,%eax
 6bd:	3b 45 0c             	cmp    0xc(%ebp),%eax
 6c0:	7c a9                	jl     66b <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 6c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6c5:	8b 45 08             	mov    0x8(%ebp),%eax
 6c8:	01 d0                	add    %edx,%eax
 6ca:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 6cd:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6d0:	c9                   	leave  
 6d1:	c3                   	ret    

000006d2 <stat>:

int
stat(char *n, struct stat *st)
{
 6d2:	55                   	push   %ebp
 6d3:	89 e5                	mov    %esp,%ebp
 6d5:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 6df:	00 
 6e0:	8b 45 08             	mov    0x8(%ebp),%eax
 6e3:	89 04 24             	mov    %eax,(%esp)
 6e6:	e8 07 01 00 00       	call   7f2 <open>
 6eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 6ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f2:	79 07                	jns    6fb <stat+0x29>
    return -1;
 6f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 6f9:	eb 23                	jmp    71e <stat+0x4c>
  r = fstat(fd, st);
 6fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 6fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 702:	8b 45 f4             	mov    -0xc(%ebp),%eax
 705:	89 04 24             	mov    %eax,(%esp)
 708:	e8 fd 00 00 00       	call   80a <fstat>
 70d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 710:	8b 45 f4             	mov    -0xc(%ebp),%eax
 713:	89 04 24             	mov    %eax,(%esp)
 716:	e8 bf 00 00 00       	call   7da <close>
  return r;
 71b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 71e:	c9                   	leave  
 71f:	c3                   	ret    

00000720 <atoi>:

int
atoi(const char *s)
{
 720:	55                   	push   %ebp
 721:	89 e5                	mov    %esp,%ebp
 723:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 726:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 72d:	eb 25                	jmp    754 <atoi+0x34>
    n = n*10 + *s++ - '0';
 72f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 732:	89 d0                	mov    %edx,%eax
 734:	c1 e0 02             	shl    $0x2,%eax
 737:	01 d0                	add    %edx,%eax
 739:	01 c0                	add    %eax,%eax
 73b:	89 c1                	mov    %eax,%ecx
 73d:	8b 45 08             	mov    0x8(%ebp),%eax
 740:	8d 50 01             	lea    0x1(%eax),%edx
 743:	89 55 08             	mov    %edx,0x8(%ebp)
 746:	0f b6 00             	movzbl (%eax),%eax
 749:	0f be c0             	movsbl %al,%eax
 74c:	01 c8                	add    %ecx,%eax
 74e:	83 e8 30             	sub    $0x30,%eax
 751:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 754:	8b 45 08             	mov    0x8(%ebp),%eax
 757:	0f b6 00             	movzbl (%eax),%eax
 75a:	3c 2f                	cmp    $0x2f,%al
 75c:	7e 0a                	jle    768 <atoi+0x48>
 75e:	8b 45 08             	mov    0x8(%ebp),%eax
 761:	0f b6 00             	movzbl (%eax),%eax
 764:	3c 39                	cmp    $0x39,%al
 766:	7e c7                	jle    72f <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 768:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 76b:	c9                   	leave  
 76c:	c3                   	ret    

0000076d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 76d:	55                   	push   %ebp
 76e:	89 e5                	mov    %esp,%ebp
 770:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 779:	8b 45 0c             	mov    0xc(%ebp),%eax
 77c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 77f:	eb 17                	jmp    798 <memmove+0x2b>
    *dst++ = *src++;
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	8d 50 01             	lea    0x1(%eax),%edx
 787:	89 55 fc             	mov    %edx,-0x4(%ebp)
 78a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 78d:	8d 4a 01             	lea    0x1(%edx),%ecx
 790:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 793:	0f b6 12             	movzbl (%edx),%edx
 796:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 798:	8b 45 10             	mov    0x10(%ebp),%eax
 79b:	8d 50 ff             	lea    -0x1(%eax),%edx
 79e:	89 55 10             	mov    %edx,0x10(%ebp)
 7a1:	85 c0                	test   %eax,%eax
 7a3:	7f dc                	jg     781 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 7a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7a8:	c9                   	leave  
 7a9:	c3                   	ret    

000007aa <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 7aa:	b8 01 00 00 00       	mov    $0x1,%eax
 7af:	cd 40                	int    $0x40
 7b1:	c3                   	ret    

000007b2 <exit>:
SYSCALL(exit)
 7b2:	b8 02 00 00 00       	mov    $0x2,%eax
 7b7:	cd 40                	int    $0x40
 7b9:	c3                   	ret    

000007ba <wait>:
SYSCALL(wait)
 7ba:	b8 03 00 00 00       	mov    $0x3,%eax
 7bf:	cd 40                	int    $0x40
 7c1:	c3                   	ret    

000007c2 <pipe>:
SYSCALL(pipe)
 7c2:	b8 04 00 00 00       	mov    $0x4,%eax
 7c7:	cd 40                	int    $0x40
 7c9:	c3                   	ret    

000007ca <read>:
SYSCALL(read)
 7ca:	b8 05 00 00 00       	mov    $0x5,%eax
 7cf:	cd 40                	int    $0x40
 7d1:	c3                   	ret    

000007d2 <write>:
SYSCALL(write)
 7d2:	b8 10 00 00 00       	mov    $0x10,%eax
 7d7:	cd 40                	int    $0x40
 7d9:	c3                   	ret    

000007da <close>:
SYSCALL(close)
 7da:	b8 15 00 00 00       	mov    $0x15,%eax
 7df:	cd 40                	int    $0x40
 7e1:	c3                   	ret    

000007e2 <kill>:
SYSCALL(kill)
 7e2:	b8 06 00 00 00       	mov    $0x6,%eax
 7e7:	cd 40                	int    $0x40
 7e9:	c3                   	ret    

000007ea <exec>:
SYSCALL(exec)
 7ea:	b8 07 00 00 00       	mov    $0x7,%eax
 7ef:	cd 40                	int    $0x40
 7f1:	c3                   	ret    

000007f2 <open>:
SYSCALL(open)
 7f2:	b8 0f 00 00 00       	mov    $0xf,%eax
 7f7:	cd 40                	int    $0x40
 7f9:	c3                   	ret    

000007fa <mknod>:
SYSCALL(mknod)
 7fa:	b8 11 00 00 00       	mov    $0x11,%eax
 7ff:	cd 40                	int    $0x40
 801:	c3                   	ret    

00000802 <unlink>:
SYSCALL(unlink)
 802:	b8 12 00 00 00       	mov    $0x12,%eax
 807:	cd 40                	int    $0x40
 809:	c3                   	ret    

0000080a <fstat>:
SYSCALL(fstat)
 80a:	b8 08 00 00 00       	mov    $0x8,%eax
 80f:	cd 40                	int    $0x40
 811:	c3                   	ret    

00000812 <link>:
SYSCALL(link)
 812:	b8 13 00 00 00       	mov    $0x13,%eax
 817:	cd 40                	int    $0x40
 819:	c3                   	ret    

0000081a <mkdir>:
SYSCALL(mkdir)
 81a:	b8 14 00 00 00       	mov    $0x14,%eax
 81f:	cd 40                	int    $0x40
 821:	c3                   	ret    

00000822 <chdir>:
SYSCALL(chdir)
 822:	b8 09 00 00 00       	mov    $0x9,%eax
 827:	cd 40                	int    $0x40
 829:	c3                   	ret    

0000082a <dup>:
SYSCALL(dup)
 82a:	b8 0a 00 00 00       	mov    $0xa,%eax
 82f:	cd 40                	int    $0x40
 831:	c3                   	ret    

00000832 <getpid>:
SYSCALL(getpid)
 832:	b8 0b 00 00 00       	mov    $0xb,%eax
 837:	cd 40                	int    $0x40
 839:	c3                   	ret    

0000083a <sbrk>:
SYSCALL(sbrk)
 83a:	b8 0c 00 00 00       	mov    $0xc,%eax
 83f:	cd 40                	int    $0x40
 841:	c3                   	ret    

00000842 <sleep>:
SYSCALL(sleep)
 842:	b8 0d 00 00 00       	mov    $0xd,%eax
 847:	cd 40                	int    $0x40
 849:	c3                   	ret    

0000084a <uptime>:
SYSCALL(uptime)
 84a:	b8 0e 00 00 00       	mov    $0xe,%eax
 84f:	cd 40                	int    $0x40
 851:	c3                   	ret    

00000852 <sigset>:
SYSCALL(sigset)
 852:	b8 16 00 00 00       	mov    $0x16,%eax
 857:	cd 40                	int    $0x40
 859:	c3                   	ret    

0000085a <sigsend>:
SYSCALL(sigsend)
 85a:	b8 17 00 00 00       	mov    $0x17,%eax
 85f:	cd 40                	int    $0x40
 861:	c3                   	ret    

00000862 <sigret>:
SYSCALL(sigret)
 862:	b8 18 00 00 00       	mov    $0x18,%eax
 867:	cd 40                	int    $0x40
 869:	c3                   	ret    

0000086a <sigpause>:
 86a:	b8 19 00 00 00       	mov    $0x19,%eax
 86f:	cd 40                	int    $0x40
 871:	c3                   	ret    

00000872 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 872:	55                   	push   %ebp
 873:	89 e5                	mov    %esp,%ebp
 875:	83 ec 18             	sub    $0x18,%esp
 878:	8b 45 0c             	mov    0xc(%ebp),%eax
 87b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 87e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 885:	00 
 886:	8d 45 f4             	lea    -0xc(%ebp),%eax
 889:	89 44 24 04          	mov    %eax,0x4(%esp)
 88d:	8b 45 08             	mov    0x8(%ebp),%eax
 890:	89 04 24             	mov    %eax,(%esp)
 893:	e8 3a ff ff ff       	call   7d2 <write>
}
 898:	c9                   	leave  
 899:	c3                   	ret    

0000089a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 89a:	55                   	push   %ebp
 89b:	89 e5                	mov    %esp,%ebp
 89d:	56                   	push   %esi
 89e:	53                   	push   %ebx
 89f:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 8a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 8a9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 8ad:	74 17                	je     8c6 <printint+0x2c>
 8af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 8b3:	79 11                	jns    8c6 <printint+0x2c>
    neg = 1;
 8b5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 8bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 8bf:	f7 d8                	neg    %eax
 8c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8c4:	eb 06                	jmp    8cc <printint+0x32>
  } else {
    x = xx;
 8c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 8c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 8cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 8d3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 8d6:	8d 41 01             	lea    0x1(%ecx),%eax
 8d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
 8df:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8e2:	ba 00 00 00 00       	mov    $0x0,%edx
 8e7:	f7 f3                	div    %ebx
 8e9:	89 d0                	mov    %edx,%eax
 8eb:	0f b6 80 d4 10 00 00 	movzbl 0x10d4(%eax),%eax
 8f2:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 8f6:	8b 75 10             	mov    0x10(%ebp),%esi
 8f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8fc:	ba 00 00 00 00       	mov    $0x0,%edx
 901:	f7 f6                	div    %esi
 903:	89 45 ec             	mov    %eax,-0x14(%ebp)
 906:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 90a:	75 c7                	jne    8d3 <printint+0x39>
  if(neg)
 90c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 910:	74 10                	je     922 <printint+0x88>
    buf[i++] = '-';
 912:	8b 45 f4             	mov    -0xc(%ebp),%eax
 915:	8d 50 01             	lea    0x1(%eax),%edx
 918:	89 55 f4             	mov    %edx,-0xc(%ebp)
 91b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 920:	eb 1f                	jmp    941 <printint+0xa7>
 922:	eb 1d                	jmp    941 <printint+0xa7>
    putc(fd, buf[i]);
 924:	8d 55 dc             	lea    -0x24(%ebp),%edx
 927:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92a:	01 d0                	add    %edx,%eax
 92c:	0f b6 00             	movzbl (%eax),%eax
 92f:	0f be c0             	movsbl %al,%eax
 932:	89 44 24 04          	mov    %eax,0x4(%esp)
 936:	8b 45 08             	mov    0x8(%ebp),%eax
 939:	89 04 24             	mov    %eax,(%esp)
 93c:	e8 31 ff ff ff       	call   872 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 941:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 945:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 949:	79 d9                	jns    924 <printint+0x8a>
    putc(fd, buf[i]);
}
 94b:	83 c4 30             	add    $0x30,%esp
 94e:	5b                   	pop    %ebx
 94f:	5e                   	pop    %esi
 950:	5d                   	pop    %ebp
 951:	c3                   	ret    

00000952 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 952:	55                   	push   %ebp
 953:	89 e5                	mov    %esp,%ebp
 955:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 958:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 95f:	8d 45 0c             	lea    0xc(%ebp),%eax
 962:	83 c0 04             	add    $0x4,%eax
 965:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 968:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 96f:	e9 7c 01 00 00       	jmp    af0 <printf+0x19e>
    c = fmt[i] & 0xff;
 974:	8b 55 0c             	mov    0xc(%ebp),%edx
 977:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97a:	01 d0                	add    %edx,%eax
 97c:	0f b6 00             	movzbl (%eax),%eax
 97f:	0f be c0             	movsbl %al,%eax
 982:	25 ff 00 00 00       	and    $0xff,%eax
 987:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 98a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 98e:	75 2c                	jne    9bc <printf+0x6a>
      if(c == '%'){
 990:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 994:	75 0c                	jne    9a2 <printf+0x50>
        state = '%';
 996:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 99d:	e9 4a 01 00 00       	jmp    aec <printf+0x19a>
      } else {
        putc(fd, c);
 9a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9a5:	0f be c0             	movsbl %al,%eax
 9a8:	89 44 24 04          	mov    %eax,0x4(%esp)
 9ac:	8b 45 08             	mov    0x8(%ebp),%eax
 9af:	89 04 24             	mov    %eax,(%esp)
 9b2:	e8 bb fe ff ff       	call   872 <putc>
 9b7:	e9 30 01 00 00       	jmp    aec <printf+0x19a>
      }
    } else if(state == '%'){
 9bc:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 9c0:	0f 85 26 01 00 00    	jne    aec <printf+0x19a>
      if(c == 'd'){
 9c6:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 9ca:	75 2d                	jne    9f9 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 9cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9cf:	8b 00                	mov    (%eax),%eax
 9d1:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 9d8:	00 
 9d9:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 9e0:	00 
 9e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 9e5:	8b 45 08             	mov    0x8(%ebp),%eax
 9e8:	89 04 24             	mov    %eax,(%esp)
 9eb:	e8 aa fe ff ff       	call   89a <printint>
        ap++;
 9f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9f4:	e9 ec 00 00 00       	jmp    ae5 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 9f9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9fd:	74 06                	je     a05 <printf+0xb3>
 9ff:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 a03:	75 2d                	jne    a32 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 a05:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a08:	8b 00                	mov    (%eax),%eax
 a0a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 a11:	00 
 a12:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 a19:	00 
 a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
 a1e:	8b 45 08             	mov    0x8(%ebp),%eax
 a21:	89 04 24             	mov    %eax,(%esp)
 a24:	e8 71 fe ff ff       	call   89a <printint>
        ap++;
 a29:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a2d:	e9 b3 00 00 00       	jmp    ae5 <printf+0x193>
      } else if(c == 's'){
 a32:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a36:	75 45                	jne    a7d <printf+0x12b>
        s = (char*)*ap;
 a38:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a3b:	8b 00                	mov    (%eax),%eax
 a3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a40:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a48:	75 09                	jne    a53 <printf+0x101>
          s = "(null)";
 a4a:	c7 45 f4 06 0e 00 00 	movl   $0xe06,-0xc(%ebp)
        while(*s != 0){
 a51:	eb 1e                	jmp    a71 <printf+0x11f>
 a53:	eb 1c                	jmp    a71 <printf+0x11f>
          putc(fd, *s);
 a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a58:	0f b6 00             	movzbl (%eax),%eax
 a5b:	0f be c0             	movsbl %al,%eax
 a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
 a62:	8b 45 08             	mov    0x8(%ebp),%eax
 a65:	89 04 24             	mov    %eax,(%esp)
 a68:	e8 05 fe ff ff       	call   872 <putc>
          s++;
 a6d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a74:	0f b6 00             	movzbl (%eax),%eax
 a77:	84 c0                	test   %al,%al
 a79:	75 da                	jne    a55 <printf+0x103>
 a7b:	eb 68                	jmp    ae5 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a7d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a81:	75 1d                	jne    aa0 <printf+0x14e>
        putc(fd, *ap);
 a83:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a86:	8b 00                	mov    (%eax),%eax
 a88:	0f be c0             	movsbl %al,%eax
 a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
 a8f:	8b 45 08             	mov    0x8(%ebp),%eax
 a92:	89 04 24             	mov    %eax,(%esp)
 a95:	e8 d8 fd ff ff       	call   872 <putc>
        ap++;
 a9a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a9e:	eb 45                	jmp    ae5 <printf+0x193>
      } else if(c == '%'){
 aa0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 aa4:	75 17                	jne    abd <printf+0x16b>
        putc(fd, c);
 aa6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 aa9:	0f be c0             	movsbl %al,%eax
 aac:	89 44 24 04          	mov    %eax,0x4(%esp)
 ab0:	8b 45 08             	mov    0x8(%ebp),%eax
 ab3:	89 04 24             	mov    %eax,(%esp)
 ab6:	e8 b7 fd ff ff       	call   872 <putc>
 abb:	eb 28                	jmp    ae5 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 abd:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 ac4:	00 
 ac5:	8b 45 08             	mov    0x8(%ebp),%eax
 ac8:	89 04 24             	mov    %eax,(%esp)
 acb:	e8 a2 fd ff ff       	call   872 <putc>
        putc(fd, c);
 ad0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 ad3:	0f be c0             	movsbl %al,%eax
 ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
 ada:	8b 45 08             	mov    0x8(%ebp),%eax
 add:	89 04 24             	mov    %eax,(%esp)
 ae0:	e8 8d fd ff ff       	call   872 <putc>
      }
      state = 0;
 ae5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 aec:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 af0:	8b 55 0c             	mov    0xc(%ebp),%edx
 af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 af6:	01 d0                	add    %edx,%eax
 af8:	0f b6 00             	movzbl (%eax),%eax
 afb:	84 c0                	test   %al,%al
 afd:	0f 85 71 fe ff ff    	jne    974 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 b03:	c9                   	leave  
 b04:	c3                   	ret    

00000b05 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b05:	55                   	push   %ebp
 b06:	89 e5                	mov    %esp,%ebp
 b08:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b0b:	8b 45 08             	mov    0x8(%ebp),%eax
 b0e:	83 e8 08             	sub    $0x8,%eax
 b11:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b14:	a1 f8 10 00 00       	mov    0x10f8,%eax
 b19:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b1c:	eb 24                	jmp    b42 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b21:	8b 00                	mov    (%eax),%eax
 b23:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b26:	77 12                	ja     b3a <free+0x35>
 b28:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b2b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b2e:	77 24                	ja     b54 <free+0x4f>
 b30:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b33:	8b 00                	mov    (%eax),%eax
 b35:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b38:	77 1a                	ja     b54 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3d:	8b 00                	mov    (%eax),%eax
 b3f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b42:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b45:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b48:	76 d4                	jbe    b1e <free+0x19>
 b4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4d:	8b 00                	mov    (%eax),%eax
 b4f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b52:	76 ca                	jbe    b1e <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 b54:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b57:	8b 40 04             	mov    0x4(%eax),%eax
 b5a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b61:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b64:	01 c2                	add    %eax,%edx
 b66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b69:	8b 00                	mov    (%eax),%eax
 b6b:	39 c2                	cmp    %eax,%edx
 b6d:	75 24                	jne    b93 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b72:	8b 50 04             	mov    0x4(%eax),%edx
 b75:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b78:	8b 00                	mov    (%eax),%eax
 b7a:	8b 40 04             	mov    0x4(%eax),%eax
 b7d:	01 c2                	add    %eax,%edx
 b7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b82:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b85:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b88:	8b 00                	mov    (%eax),%eax
 b8a:	8b 10                	mov    (%eax),%edx
 b8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b8f:	89 10                	mov    %edx,(%eax)
 b91:	eb 0a                	jmp    b9d <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b93:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b96:	8b 10                	mov    (%eax),%edx
 b98:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b9b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba0:	8b 40 04             	mov    0x4(%eax),%eax
 ba3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 baa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bad:	01 d0                	add    %edx,%eax
 baf:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bb2:	75 20                	jne    bd4 <free+0xcf>
    p->s.size += bp->s.size;
 bb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bb7:	8b 50 04             	mov    0x4(%eax),%edx
 bba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bbd:	8b 40 04             	mov    0x4(%eax),%eax
 bc0:	01 c2                	add    %eax,%edx
 bc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bc5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 bc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bcb:	8b 10                	mov    (%eax),%edx
 bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd0:	89 10                	mov    %edx,(%eax)
 bd2:	eb 08                	jmp    bdc <free+0xd7>
  } else
    p->s.ptr = bp;
 bd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 bda:	89 10                	mov    %edx,(%eax)
  freep = p;
 bdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bdf:	a3 f8 10 00 00       	mov    %eax,0x10f8
}
 be4:	c9                   	leave  
 be5:	c3                   	ret    

00000be6 <morecore>:

static Header*
morecore(uint nu)
{
 be6:	55                   	push   %ebp
 be7:	89 e5                	mov    %esp,%ebp
 be9:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 bec:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 bf3:	77 07                	ja     bfc <morecore+0x16>
    nu = 4096;
 bf5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bfc:	8b 45 08             	mov    0x8(%ebp),%eax
 bff:	c1 e0 03             	shl    $0x3,%eax
 c02:	89 04 24             	mov    %eax,(%esp)
 c05:	e8 30 fc ff ff       	call   83a <sbrk>
 c0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 c0d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 c11:	75 07                	jne    c1a <morecore+0x34>
    return 0;
 c13:	b8 00 00 00 00       	mov    $0x0,%eax
 c18:	eb 22                	jmp    c3c <morecore+0x56>
  hp = (Header*)p;
 c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c23:	8b 55 08             	mov    0x8(%ebp),%edx
 c26:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c2c:	83 c0 08             	add    $0x8,%eax
 c2f:	89 04 24             	mov    %eax,(%esp)
 c32:	e8 ce fe ff ff       	call   b05 <free>
  return freep;
 c37:	a1 f8 10 00 00       	mov    0x10f8,%eax
}
 c3c:	c9                   	leave  
 c3d:	c3                   	ret    

00000c3e <malloc>:

void*
malloc(uint nbytes)
{
 c3e:	55                   	push   %ebp
 c3f:	89 e5                	mov    %esp,%ebp
 c41:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c44:	8b 45 08             	mov    0x8(%ebp),%eax
 c47:	83 c0 07             	add    $0x7,%eax
 c4a:	c1 e8 03             	shr    $0x3,%eax
 c4d:	83 c0 01             	add    $0x1,%eax
 c50:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c53:	a1 f8 10 00 00       	mov    0x10f8,%eax
 c58:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c5f:	75 23                	jne    c84 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c61:	c7 45 f0 f0 10 00 00 	movl   $0x10f0,-0x10(%ebp)
 c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c6b:	a3 f8 10 00 00       	mov    %eax,0x10f8
 c70:	a1 f8 10 00 00       	mov    0x10f8,%eax
 c75:	a3 f0 10 00 00       	mov    %eax,0x10f0
    base.s.size = 0;
 c7a:	c7 05 f4 10 00 00 00 	movl   $0x0,0x10f4
 c81:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c87:	8b 00                	mov    (%eax),%eax
 c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8f:	8b 40 04             	mov    0x4(%eax),%eax
 c92:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c95:	72 4d                	jb     ce4 <malloc+0xa6>
      if(p->s.size == nunits)
 c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c9a:	8b 40 04             	mov    0x4(%eax),%eax
 c9d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ca0:	75 0c                	jne    cae <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca5:	8b 10                	mov    (%eax),%edx
 ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 caa:	89 10                	mov    %edx,(%eax)
 cac:	eb 26                	jmp    cd4 <malloc+0x96>
      else {
        p->s.size -= nunits;
 cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cb1:	8b 40 04             	mov    0x4(%eax),%eax
 cb4:	2b 45 ec             	sub    -0x14(%ebp),%eax
 cb7:	89 c2                	mov    %eax,%edx
 cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cbc:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc2:	8b 40 04             	mov    0x4(%eax),%eax
 cc5:	c1 e0 03             	shl    $0x3,%eax
 cc8:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cce:	8b 55 ec             	mov    -0x14(%ebp),%edx
 cd1:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cd7:	a3 f8 10 00 00       	mov    %eax,0x10f8
      return (void*)(p + 1);
 cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cdf:	83 c0 08             	add    $0x8,%eax
 ce2:	eb 38                	jmp    d1c <malloc+0xde>
    }
    if(p == freep)
 ce4:	a1 f8 10 00 00       	mov    0x10f8,%eax
 ce9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 cec:	75 1b                	jne    d09 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 cee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 cf1:	89 04 24             	mov    %eax,(%esp)
 cf4:	e8 ed fe ff ff       	call   be6 <morecore>
 cf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 cfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 d00:	75 07                	jne    d09 <malloc+0xcb>
        return 0;
 d02:	b8 00 00 00 00       	mov    $0x0,%eax
 d07:	eb 13                	jmp    d1c <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d12:	8b 00                	mov    (%eax),%eax
 d14:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 d17:	e9 70 ff ff ff       	jmp    c8c <malloc+0x4e>
}
 d1c:	c9                   	leave  
 d1d:	c3                   	ret    
