
_primsrv:     file format elf32-i386


Disassembly of section .text:

00000000 <is_prime>:
    else              // even 
        return next_pr(num-1);  //become odd and return next_pr
}
*/

int is_prime(int number) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 2; (i*i) < number; i++)
   6:	c7 45 fc 02 00 00 00 	movl   $0x2,-0x4(%ebp)
   d:	eb 20                	jmp    2f <is_prime+0x2f>
    {
        if (number % i == 0 && i != number)
   f:	8b 45 08             	mov    0x8(%ebp),%eax
  12:	99                   	cltd   
  13:	f7 7d fc             	idivl  -0x4(%ebp)
  16:	89 d0                	mov    %edx,%eax
  18:	85 c0                	test   %eax,%eax
  1a:	75 0f                	jne    2b <is_prime+0x2b>
  1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1f:	3b 45 08             	cmp    0x8(%ebp),%eax
  22:	74 07                	je     2b <is_prime+0x2b>
            return 0;
  24:	b8 00 00 00 00       	mov    $0x0,%eax
  29:	eb 15                	jmp    40 <is_prime+0x40>
}
*/

int is_prime(int number) {
    int i;
    for (i = 2; (i*i) < number; i++)
  2b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  32:	0f af 45 fc          	imul   -0x4(%ebp),%eax
  36:	3b 45 08             	cmp    0x8(%ebp),%eax
  39:	7c d4                	jl     f <is_prime+0xf>
    {
        if (number % i == 0 && i != number)
            return 0;
    }
    return 1;
  3b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  40:	c9                   	leave  
  41:	c3                   	ret    

00000042 <next_pr>:

int next_pr(int n){
  42:	55                   	push   %ebp
  43:	89 e5                	mov    %esp,%ebp
  45:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
  48:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  int found = 0;
  4f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
    for(i=n+1; !found ;i++){
  56:	8b 45 08             	mov    0x8(%ebp),%eax
  59:	83 c0 01             	add    $0x1,%eax
  5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  5f:	eb 18                	jmp    79 <next_pr+0x37>
        if(is_prime(i)){
  61:	8b 45 fc             	mov    -0x4(%ebp),%eax
  64:	89 04 24             	mov    %eax,(%esp)
  67:	e8 94 ff ff ff       	call   0 <is_prime>
  6c:	85 c0                	test   %eax,%eax
  6e:	74 05                	je     75 <next_pr+0x33>
            return i;
  70:	8b 45 fc             	mov    -0x4(%ebp),%eax
  73:	eb 0f                	jmp    84 <next_pr+0x42>
}

int next_pr(int n){
  int i = 0;
  int found = 0;
    for(i=n+1; !found ;i++){
  75:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  79:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  7d:	74 e2                	je     61 <next_pr+0x1f>
        if(is_prime(i)){
            return i;
        }
    }
    return 0;
  7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  84:	c9                   	leave  
  85:	c3                   	ret    

00000086 <handle_worker_sig>:

void 
handle_worker_sig(int main_pid, int value)
{
  86:	55                   	push   %ebp
  87:	89 e5                	mov    %esp,%ebp
  89:	83 ec 28             	sub    $0x28,%esp
  if (value == 0) {
  8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  90:	75 05                	jne    97 <handle_worker_sig+0x11>
    exit();
  92:	e8 d6 06 00 00       	call   76d <exit>
  }
  // get next prime
  int c = next_pr(value); 
  97:	8b 45 0c             	mov    0xc(%ebp),%eax
  9a:	89 04 24             	mov    %eax,(%esp)
  9d:	e8 a0 ff ff ff       	call   42 <next_pr>
  a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //return result to main proccess
  sigsend(main_pid, c); 
  a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  ac:	8b 45 08             	mov    0x8(%ebp),%eax
  af:	89 04 24             	mov    %eax,(%esp)
  b2:	e8 5e 07 00 00       	call   815 <sigsend>
  //pause until the next number
  //sigpause();
}
  b7:	c9                   	leave  
  b8:	c3                   	ret    

000000b9 <handle_main_sig>:
  
void
handle_main_sig(int worker_pid, int value)
{
  b9:	55                   	push   %ebp
  ba:	89 e5                	mov    %esp,%ebp
  bc:	83 ec 38             	sub    $0x38,%esp
  int i;
  for (i = 0; i < workers_number; i++) {
  bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  c6:	eb 79                	jmp    141 <handle_main_sig+0x88>
    if (workers[i].pid == worker_pid){
  c8:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
  ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  d1:	89 d0                	mov    %edx,%eax
  d3:	01 c0                	add    %eax,%eax
  d5:	01 d0                	add    %edx,%eax
  d7:	c1 e0 02             	shl    $0x2,%eax
  da:	01 c8                	add    %ecx,%eax
  dc:	8b 00                	mov    (%eax),%eax
  de:	3b 45 08             	cmp    0x8(%ebp),%eax
  e1:	75 5a                	jne    13d <handle_main_sig+0x84>
      printf(STDOUT, "worker %d returned %d as a result for %d", worker_pid, value, workers[i].input_x);
  e3:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
  e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ec:	89 d0                	mov    %edx,%eax
  ee:	01 c0                	add    %eax,%eax
  f0:	01 d0                	add    %edx,%eax
  f2:	c1 e0 02             	shl    $0x2,%eax
  f5:	01 c8                	add    %ecx,%eax
  f7:	8b 40 04             	mov    0x4(%eax),%eax
  fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 101:	89 44 24 0c          	mov    %eax,0xc(%esp)
 105:	8b 45 08             	mov    0x8(%ebp),%eax
 108:	89 44 24 08          	mov    %eax,0x8(%esp)
 10c:	c7 44 24 04 dc 0c 00 	movl   $0xcdc,0x4(%esp)
 113:	00 
 114:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 11b:	e8 ed 07 00 00       	call   90d <printf>
      workers[i].working = 0;
 120:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 126:	8b 55 f4             	mov    -0xc(%ebp),%edx
 129:	89 d0                	mov    %edx,%eax
 12b:	01 c0                	add    %eax,%eax
 12d:	01 d0                	add    %edx,%eax
 12f:	c1 e0 02             	shl    $0x2,%eax
 132:	01 c8                	add    %ecx,%eax
 134:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      break;
 13b:	eb 12                	jmp    14f <handle_main_sig+0x96>
  
void
handle_main_sig(int worker_pid, int value)
{
  int i;
  for (i = 0; i < workers_number; i++) {
 13d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 141:	a1 78 10 00 00       	mov    0x1078,%eax
 146:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 149:	0f 8c 79 ff ff ff    	jl     c8 <handle_main_sig+0xf>
      printf(STDOUT, "worker %d returned %d as a result for %d", worker_pid, value, workers[i].input_x);
      workers[i].working = 0;
      break;
    }
  }
}
 14f:	c9                   	leave  
 150:	c3                   	ret    

00000151 <main>:

int
main(int argc, char *argv[])
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	83 e4 f0             	and    $0xfffffff0,%esp
 157:	81 ec 90 00 00 00    	sub    $0x90,%esp
  int i, pid, input_x;
  int toRun = 1;
 15d:	c7 84 24 88 00 00 00 	movl   $0x1,0x88(%esp)
 164:	01 00 00 00 
  char buf[MAX_INPUT];

  // validate arguments
  if (argc != 2) {
 168:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 16c:	74 19                	je     187 <main+0x36>
    printf(STDOUT, "Unvaild parameter for primsrv test\n");
 16e:	c7 44 24 04 08 0d 00 	movl   $0xd08,0x4(%esp)
 175:	00 
 176:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 17d:	e8 8b 07 00 00       	call   90d <printf>
    exit();
 182:	e8 e6 05 00 00       	call   76d <exit>
  }

  // allocate workers array
  workers_number = atoi(argv[1]);
 187:	8b 45 0c             	mov    0xc(%ebp),%eax
 18a:	83 c0 04             	add    $0x4,%eax
 18d:	8b 00                	mov    (%eax),%eax
 18f:	89 04 24             	mov    %eax,(%esp)
 192:	e8 44 05 00 00       	call   6db <atoi>
 197:	a3 78 10 00 00       	mov    %eax,0x1078
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
 19c:	a1 78 10 00 00       	mov    0x1078,%eax
 1a1:	89 c2                	mov    %eax,%edx
 1a3:	89 d0                	mov    %edx,%eax
 1a5:	01 c0                	add    %eax,%eax
 1a7:	01 d0                	add    %edx,%eax
 1a9:	c1 e0 02             	shl    $0x2,%eax
 1ac:	89 04 24             	mov    %eax,(%esp)
 1af:	e8 45 0a 00 00       	call   bf9 <malloc>
 1b4:	a3 7c 10 00 00       	mov    %eax,0x107c
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
 1b9:	c7 04 24 86 00 00 00 	movl   $0x86,(%esp)
 1c0:	e8 48 06 00 00       	call   80d <sigset>

  printf(STDOUT, "workers pids:\n");
 1c5:	c7 44 24 04 2c 0d 00 	movl   $0xd2c,0x4(%esp)
 1cc:	00 
 1cd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1d4:	e8 34 07 00 00       	call   90d <printf>
  for(i = 0; i < workers_number; i++) {
 1d9:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 1e0:	00 00 00 00 
 1e4:	e9 cd 00 00 00       	jmp    2b6 <main+0x165>
    
    if ((pid = fork()) == 0) {  // son
 1e9:	e8 77 05 00 00       	call   765 <fork>
 1ee:	89 84 24 84 00 00 00 	mov    %eax,0x84(%esp)
 1f5:	83 bc 24 84 00 00 00 	cmpl   $0x0,0x84(%esp)
 1fc:	00 
 1fd:	75 07                	jne    206 <main+0xb5>
      while(1) sigpause();
 1ff:	e8 21 06 00 00       	call   825 <sigpause>
 204:	eb f9                	jmp    1ff <main+0xae>
    }
    else if (pid > 0) {         // father
 206:	83 bc 24 84 00 00 00 	cmpl   $0x0,0x84(%esp)
 20d:	00 
 20e:	0f 8e 89 00 00 00    	jle    29d <main+0x14c>
      //init son worker_s 
      printf(STDOUT, "%d\n", pid);  
 214:	8b 84 24 84 00 00 00 	mov    0x84(%esp),%eax
 21b:	89 44 24 08          	mov    %eax,0x8(%esp)
 21f:	c7 44 24 04 3b 0d 00 	movl   $0xd3b,0x4(%esp)
 226:	00 
 227:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 22e:	e8 da 06 00 00       	call   90d <printf>
      workers[i].pid = pid;
 233:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 239:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 240:	89 d0                	mov    %edx,%eax
 242:	01 c0                	add    %eax,%eax
 244:	01 d0                	add    %edx,%eax
 246:	c1 e0 02             	shl    $0x2,%eax
 249:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 24c:	8b 84 24 84 00 00 00 	mov    0x84(%esp),%eax
 253:	89 02                	mov    %eax,(%edx)
      workers[i].input_x = -1;
 255:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 25b:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 262:	89 d0                	mov    %edx,%eax
 264:	01 c0                	add    %eax,%eax
 266:	01 d0                	add    %edx,%eax
 268:	c1 e0 02             	shl    $0x2,%eax
 26b:	01 c8                	add    %ecx,%eax
 26d:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
      workers[i].working = 0;
 274:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 27a:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 281:	89 d0                	mov    %edx,%eax
 283:	01 c0                	add    %eax,%eax
 285:	01 d0                	add    %edx,%eax
 287:	c1 e0 02             	shl    $0x2,%eax
 28a:	01 c8                	add    %ecx,%eax
 28c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);

  printf(STDOUT, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
 293:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 29a:	01 
 29b:	eb 19                	jmp    2b6 <main+0x165>
      workers[i].pid = pid;
      workers[i].input_x = -1;
      workers[i].working = 0;
    }
    else {                      // fork failed
      printf(STDOUT, "fork() failed!\n"); 
 29d:	c7 44 24 04 3f 0d 00 	movl   $0xd3f,0x4(%esp)
 2a4:	00 
 2a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2ac:	e8 5c 06 00 00       	call   90d <printf>
      exit();
 2b1:	e8 b7 04 00 00       	call   76d <exit>
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);

  printf(STDOUT, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
 2b6:	a1 78 10 00 00       	mov    0x1078,%eax
 2bb:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 2c2:	0f 8c 21 ff ff ff    	jl     1e9 <main+0x98>
      exit();
    }
  }

  // configure the main process - correct handler
  sigset((void *)handle_main_sig);
 2c8:	c7 04 24 b9 00 00 00 	movl   $0xb9,(%esp)
 2cf:	e8 39 05 00 00       	call   80d <sigset>

  while(toRun)
 2d4:	e9 d0 01 00 00       	jmp    4a9 <main+0x358>
  {
    printf(STDOUT, "Please enter a number: ");
 2d9:	c7 44 24 04 4f 0d 00 	movl   $0xd4f,0x4(%esp)
 2e0:	00 
 2e1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2e8:	e8 20 06 00 00       	call   90d <printf>

    read(1, buf, MAX_INPUT);
 2ed:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
 2f4:	00 
 2f5:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 2f9:	89 44 24 04          	mov    %eax,0x4(%esp)
 2fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 304:	e8 7c 04 00 00       	call   785 <read>
    
    if (buf[0] == '\n'){
 309:	0f b6 44 24 1c       	movzbl 0x1c(%esp),%eax
 30e:	3c 0a                	cmp    $0xa,%al
 310:	75 05                	jne    317 <main+0x1c6>
      //handle main signals by calling a system call
      //sigset((void *)handle_main_sig);
      continue;
 312:	e9 92 01 00 00       	jmp    4a9 <main+0x358>
    }

    input_x = atoi(buf);
 317:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 31b:	89 04 24             	mov    %eax,(%esp)
 31e:	e8 b8 03 00 00       	call   6db <atoi>
 323:	89 84 24 80 00 00 00 	mov    %eax,0x80(%esp)

    if(input_x != 0)
 32a:	83 bc 24 80 00 00 00 	cmpl   $0x0,0x80(%esp)
 331:	00 
 332:	0f 84 e5 00 00 00    	je     41d <main+0x2cc>
    {
      // send input_x to process p using sigsend sys-call 
      for (i = 0; i < workers_number; i++)
 338:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 33f:	00 00 00 00 
 343:	e9 98 00 00 00       	jmp    3e0 <main+0x28f>
      {
        if (workers[i].working == 0) // available
 348:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 34e:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 355:	89 d0                	mov    %edx,%eax
 357:	01 c0                	add    %eax,%eax
 359:	01 d0                	add    %edx,%eax
 35b:	c1 e0 02             	shl    $0x2,%eax
 35e:	01 c8                	add    %ecx,%eax
 360:	8b 40 08             	mov    0x8(%eax),%eax
 363:	85 c0                	test   %eax,%eax
 365:	75 71                	jne    3d8 <main+0x287>
        {
          workers[i].working = 1;
 367:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 36d:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 374:	89 d0                	mov    %edx,%eax
 376:	01 c0                	add    %eax,%eax
 378:	01 d0                	add    %edx,%eax
 37a:	c1 e0 02             	shl    $0x2,%eax
 37d:	01 c8                	add    %ecx,%eax
 37f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
          workers[i].input_x = input_x;
 386:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 38c:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 393:	89 d0                	mov    %edx,%eax
 395:	01 c0                	add    %eax,%eax
 397:	01 d0                	add    %edx,%eax
 399:	c1 e0 02             	shl    $0x2,%eax
 39c:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 39f:	8b 84 24 80 00 00 00 	mov    0x80(%esp),%eax
 3a6:	89 42 04             	mov    %eax,0x4(%edx)
          sigsend(workers[i].pid, input_x);  
 3a9:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 3af:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 3b6:	89 d0                	mov    %edx,%eax
 3b8:	01 c0                	add    %eax,%eax
 3ba:	01 d0                	add    %edx,%eax
 3bc:	c1 e0 02             	shl    $0x2,%eax
 3bf:	01 c8                	add    %ecx,%eax
 3c1:	8b 00                	mov    (%eax),%eax
 3c3:	8b 94 24 80 00 00 00 	mov    0x80(%esp),%edx
 3ca:	89 54 24 04          	mov    %edx,0x4(%esp)
 3ce:	89 04 24             	mov    %eax,(%esp)
 3d1:	e8 3f 04 00 00       	call   815 <sigsend>
          break;
 3d6:	eb 1a                	jmp    3f2 <main+0x2a1>
    input_x = atoi(buf);

    if(input_x != 0)
    {
      // send input_x to process p using sigsend sys-call 
      for (i = 0; i < workers_number; i++)
 3d8:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 3df:	01 
 3e0:	a1 78 10 00 00       	mov    0x1078,%eax
 3e5:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 3ec:	0f 8c 56 ff ff ff    	jl     348 <main+0x1f7>
          break;
        }
      }

      // no idle workers to handle signal
      if (i == workers_number){
 3f2:	a1 78 10 00 00       	mov    0x1078,%eax
 3f7:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 3fe:	0f 85 a5 00 00 00    	jne    4a9 <main+0x358>
        printf(STDOUT, "no idle workers\n");
 404:	c7 44 24 04 67 0d 00 	movl   $0xd67,0x4(%esp)
 40b:	00 
 40c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 413:	e8 f5 04 00 00       	call   90d <printf>
 418:	e9 8c 00 00 00       	jmp    4a9 <main+0x358>
      }
    }

    else // input = 0, exiting program
    {
      for (i = 0; i < workers_number; i++)
 41d:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 424:	00 00 00 00 
 428:	eb 64                	jmp    48e <main+0x33d>
      {
        sigsend(workers[i].pid, 0);
 42a:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 430:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 437:	89 d0                	mov    %edx,%eax
 439:	01 c0                	add    %eax,%eax
 43b:	01 d0                	add    %edx,%eax
 43d:	c1 e0 02             	shl    $0x2,%eax
 440:	01 c8                	add    %ecx,%eax
 442:	8b 00                	mov    (%eax),%eax
 444:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 44b:	00 
 44c:	89 04 24             	mov    %eax,(%esp)
 44f:	e8 c1 03 00 00       	call   815 <sigsend>
        printf(STDOUT, "worker %d exit\n", workers[i].pid);
 454:	8b 0d 7c 10 00 00    	mov    0x107c,%ecx
 45a:	8b 94 24 8c 00 00 00 	mov    0x8c(%esp),%edx
 461:	89 d0                	mov    %edx,%eax
 463:	01 c0                	add    %eax,%eax
 465:	01 d0                	add    %edx,%eax
 467:	c1 e0 02             	shl    $0x2,%eax
 46a:	01 c8                	add    %ecx,%eax
 46c:	8b 00                	mov    (%eax),%eax
 46e:	89 44 24 08          	mov    %eax,0x8(%esp)
 472:	c7 44 24 04 78 0d 00 	movl   $0xd78,0x4(%esp)
 479:	00 
 47a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 481:	e8 87 04 00 00       	call   90d <printf>
      }
    }

    else // input = 0, exiting program
    {
      for (i = 0; i < workers_number; i++)
 486:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 48d:	01 
 48e:	a1 78 10 00 00       	mov    0x1078,%eax
 493:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 49a:	7c 8e                	jl     42a <main+0x2d9>
      {
        sigsend(workers[i].pid, 0);
        printf(STDOUT, "worker %d exit\n", workers[i].pid);
      }
      toRun = 0;
 49c:	c7 84 24 88 00 00 00 	movl   $0x0,0x88(%esp)
 4a3:	00 00 00 00 
      break;
 4a7:	eb 0e                	jmp    4b7 <main+0x366>
  }

  // configure the main process - correct handler
  sigset((void *)handle_main_sig);

  while(toRun)
 4a9:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
 4b0:	00 
 4b1:	0f 85 22 fe ff ff    	jne    2d9 <main+0x188>
      */
    }

  }
  
  for(i = 0; i < workers_number; i++)
 4b7:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 4be:	00 00 00 00 
 4c2:	eb 0d                	jmp    4d1 <main+0x380>
    wait();
 4c4:	e8 ac 02 00 00       	call   775 <wait>
      */
    }

  }
  
  for(i = 0; i < workers_number; i++)
 4c9:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 4d0:	01 
 4d1:	a1 78 10 00 00       	mov    0x1078,%eax
 4d6:	39 84 24 8c 00 00 00 	cmp    %eax,0x8c(%esp)
 4dd:	7c e5                	jl     4c4 <main+0x373>
    wait();
  free(workers);
 4df:	a1 7c 10 00 00       	mov    0x107c,%eax
 4e4:	89 04 24             	mov    %eax,(%esp)
 4e7:	e8 d4 05 00 00       	call   ac0 <free>
  printf(STDOUT, "primsrv exit\n");
 4ec:	c7 44 24 04 88 0d 00 	movl   $0xd88,0x4(%esp)
 4f3:	00 
 4f4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 4fb:	e8 0d 04 00 00       	call   90d <printf>
  exit();
 500:	e8 68 02 00 00       	call   76d <exit>

00000505 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 505:	55                   	push   %ebp
 506:	89 e5                	mov    %esp,%ebp
 508:	57                   	push   %edi
 509:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 50a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 50d:	8b 55 10             	mov    0x10(%ebp),%edx
 510:	8b 45 0c             	mov    0xc(%ebp),%eax
 513:	89 cb                	mov    %ecx,%ebx
 515:	89 df                	mov    %ebx,%edi
 517:	89 d1                	mov    %edx,%ecx
 519:	fc                   	cld    
 51a:	f3 aa                	rep stos %al,%es:(%edi)
 51c:	89 ca                	mov    %ecx,%edx
 51e:	89 fb                	mov    %edi,%ebx
 520:	89 5d 08             	mov    %ebx,0x8(%ebp)
 523:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 526:	5b                   	pop    %ebx
 527:	5f                   	pop    %edi
 528:	5d                   	pop    %ebp
 529:	c3                   	ret    

0000052a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 52a:	55                   	push   %ebp
 52b:	89 e5                	mov    %esp,%ebp
 52d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 530:	8b 45 08             	mov    0x8(%ebp),%eax
 533:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 536:	90                   	nop
 537:	8b 45 08             	mov    0x8(%ebp),%eax
 53a:	8d 50 01             	lea    0x1(%eax),%edx
 53d:	89 55 08             	mov    %edx,0x8(%ebp)
 540:	8b 55 0c             	mov    0xc(%ebp),%edx
 543:	8d 4a 01             	lea    0x1(%edx),%ecx
 546:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 549:	0f b6 12             	movzbl (%edx),%edx
 54c:	88 10                	mov    %dl,(%eax)
 54e:	0f b6 00             	movzbl (%eax),%eax
 551:	84 c0                	test   %al,%al
 553:	75 e2                	jne    537 <strcpy+0xd>
    ;
  return os;
 555:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 558:	c9                   	leave  
 559:	c3                   	ret    

0000055a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 55a:	55                   	push   %ebp
 55b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 55d:	eb 08                	jmp    567 <strcmp+0xd>
    p++, q++;
 55f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 563:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	0f b6 00             	movzbl (%eax),%eax
 56d:	84 c0                	test   %al,%al
 56f:	74 10                	je     581 <strcmp+0x27>
 571:	8b 45 08             	mov    0x8(%ebp),%eax
 574:	0f b6 10             	movzbl (%eax),%edx
 577:	8b 45 0c             	mov    0xc(%ebp),%eax
 57a:	0f b6 00             	movzbl (%eax),%eax
 57d:	38 c2                	cmp    %al,%dl
 57f:	74 de                	je     55f <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 581:	8b 45 08             	mov    0x8(%ebp),%eax
 584:	0f b6 00             	movzbl (%eax),%eax
 587:	0f b6 d0             	movzbl %al,%edx
 58a:	8b 45 0c             	mov    0xc(%ebp),%eax
 58d:	0f b6 00             	movzbl (%eax),%eax
 590:	0f b6 c0             	movzbl %al,%eax
 593:	29 c2                	sub    %eax,%edx
 595:	89 d0                	mov    %edx,%eax
}
 597:	5d                   	pop    %ebp
 598:	c3                   	ret    

00000599 <strlen>:

uint
strlen(char *s)
{
 599:	55                   	push   %ebp
 59a:	89 e5                	mov    %esp,%ebp
 59c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 59f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 5a6:	eb 04                	jmp    5ac <strlen+0x13>
 5a8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 5ac:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5af:	8b 45 08             	mov    0x8(%ebp),%eax
 5b2:	01 d0                	add    %edx,%eax
 5b4:	0f b6 00             	movzbl (%eax),%eax
 5b7:	84 c0                	test   %al,%al
 5b9:	75 ed                	jne    5a8 <strlen+0xf>
    ;
  return n;
 5bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5be:	c9                   	leave  
 5bf:	c3                   	ret    

000005c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 5c0:	55                   	push   %ebp
 5c1:	89 e5                	mov    %esp,%ebp
 5c3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 5c6:	8b 45 10             	mov    0x10(%ebp),%eax
 5c9:	89 44 24 08          	mov    %eax,0x8(%esp)
 5cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d4:	8b 45 08             	mov    0x8(%ebp),%eax
 5d7:	89 04 24             	mov    %eax,(%esp)
 5da:	e8 26 ff ff ff       	call   505 <stosb>
  return dst;
 5df:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5e2:	c9                   	leave  
 5e3:	c3                   	ret    

000005e4 <strchr>:

char*
strchr(const char *s, char c)
{
 5e4:	55                   	push   %ebp
 5e5:	89 e5                	mov    %esp,%ebp
 5e7:	83 ec 04             	sub    $0x4,%esp
 5ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ed:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 5f0:	eb 14                	jmp    606 <strchr+0x22>
    if(*s == c)
 5f2:	8b 45 08             	mov    0x8(%ebp),%eax
 5f5:	0f b6 00             	movzbl (%eax),%eax
 5f8:	3a 45 fc             	cmp    -0x4(%ebp),%al
 5fb:	75 05                	jne    602 <strchr+0x1e>
      return (char*)s;
 5fd:	8b 45 08             	mov    0x8(%ebp),%eax
 600:	eb 13                	jmp    615 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 602:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 606:	8b 45 08             	mov    0x8(%ebp),%eax
 609:	0f b6 00             	movzbl (%eax),%eax
 60c:	84 c0                	test   %al,%al
 60e:	75 e2                	jne    5f2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 610:	b8 00 00 00 00       	mov    $0x0,%eax
}
 615:	c9                   	leave  
 616:	c3                   	ret    

00000617 <gets>:

char*
gets(char *buf, int max)
{
 617:	55                   	push   %ebp
 618:	89 e5                	mov    %esp,%ebp
 61a:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 61d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 624:	eb 4c                	jmp    672 <gets+0x5b>
    cc = read(0, &c, 1);
 626:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 62d:	00 
 62e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 631:	89 44 24 04          	mov    %eax,0x4(%esp)
 635:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 63c:	e8 44 01 00 00       	call   785 <read>
 641:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 644:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 648:	7f 02                	jg     64c <gets+0x35>
      break;
 64a:	eb 31                	jmp    67d <gets+0x66>
    buf[i++] = c;
 64c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64f:	8d 50 01             	lea    0x1(%eax),%edx
 652:	89 55 f4             	mov    %edx,-0xc(%ebp)
 655:	89 c2                	mov    %eax,%edx
 657:	8b 45 08             	mov    0x8(%ebp),%eax
 65a:	01 c2                	add    %eax,%edx
 65c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 660:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 662:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 666:	3c 0a                	cmp    $0xa,%al
 668:	74 13                	je     67d <gets+0x66>
 66a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 66e:	3c 0d                	cmp    $0xd,%al
 670:	74 0b                	je     67d <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 672:	8b 45 f4             	mov    -0xc(%ebp),%eax
 675:	83 c0 01             	add    $0x1,%eax
 678:	3b 45 0c             	cmp    0xc(%ebp),%eax
 67b:	7c a9                	jl     626 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 67d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 680:	8b 45 08             	mov    0x8(%ebp),%eax
 683:	01 d0                	add    %edx,%eax
 685:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 688:	8b 45 08             	mov    0x8(%ebp),%eax
}
 68b:	c9                   	leave  
 68c:	c3                   	ret    

0000068d <stat>:

int
stat(char *n, struct stat *st)
{
 68d:	55                   	push   %ebp
 68e:	89 e5                	mov    %esp,%ebp
 690:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 693:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 69a:	00 
 69b:	8b 45 08             	mov    0x8(%ebp),%eax
 69e:	89 04 24             	mov    %eax,(%esp)
 6a1:	e8 07 01 00 00       	call   7ad <open>
 6a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 6a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ad:	79 07                	jns    6b6 <stat+0x29>
    return -1;
 6af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 6b4:	eb 23                	jmp    6d9 <stat+0x4c>
  r = fstat(fd, st);
 6b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c0:	89 04 24             	mov    %eax,(%esp)
 6c3:	e8 fd 00 00 00       	call   7c5 <fstat>
 6c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 6cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ce:	89 04 24             	mov    %eax,(%esp)
 6d1:	e8 bf 00 00 00       	call   795 <close>
  return r;
 6d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 6d9:	c9                   	leave  
 6da:	c3                   	ret    

000006db <atoi>:

int
atoi(const char *s)
{
 6db:	55                   	push   %ebp
 6dc:	89 e5                	mov    %esp,%ebp
 6de:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 6e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6e8:	eb 25                	jmp    70f <atoi+0x34>
    n = n*10 + *s++ - '0';
 6ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6ed:	89 d0                	mov    %edx,%eax
 6ef:	c1 e0 02             	shl    $0x2,%eax
 6f2:	01 d0                	add    %edx,%eax
 6f4:	01 c0                	add    %eax,%eax
 6f6:	89 c1                	mov    %eax,%ecx
 6f8:	8b 45 08             	mov    0x8(%ebp),%eax
 6fb:	8d 50 01             	lea    0x1(%eax),%edx
 6fe:	89 55 08             	mov    %edx,0x8(%ebp)
 701:	0f b6 00             	movzbl (%eax),%eax
 704:	0f be c0             	movsbl %al,%eax
 707:	01 c8                	add    %ecx,%eax
 709:	83 e8 30             	sub    $0x30,%eax
 70c:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 70f:	8b 45 08             	mov    0x8(%ebp),%eax
 712:	0f b6 00             	movzbl (%eax),%eax
 715:	3c 2f                	cmp    $0x2f,%al
 717:	7e 0a                	jle    723 <atoi+0x48>
 719:	8b 45 08             	mov    0x8(%ebp),%eax
 71c:	0f b6 00             	movzbl (%eax),%eax
 71f:	3c 39                	cmp    $0x39,%al
 721:	7e c7                	jle    6ea <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 723:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 726:	c9                   	leave  
 727:	c3                   	ret    

00000728 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 728:	55                   	push   %ebp
 729:	89 e5                	mov    %esp,%ebp
 72b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 72e:	8b 45 08             	mov    0x8(%ebp),%eax
 731:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 734:	8b 45 0c             	mov    0xc(%ebp),%eax
 737:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 73a:	eb 17                	jmp    753 <memmove+0x2b>
    *dst++ = *src++;
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8d 50 01             	lea    0x1(%eax),%edx
 742:	89 55 fc             	mov    %edx,-0x4(%ebp)
 745:	8b 55 f8             	mov    -0x8(%ebp),%edx
 748:	8d 4a 01             	lea    0x1(%edx),%ecx
 74b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 74e:	0f b6 12             	movzbl (%edx),%edx
 751:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 753:	8b 45 10             	mov    0x10(%ebp),%eax
 756:	8d 50 ff             	lea    -0x1(%eax),%edx
 759:	89 55 10             	mov    %edx,0x10(%ebp)
 75c:	85 c0                	test   %eax,%eax
 75e:	7f dc                	jg     73c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 760:	8b 45 08             	mov    0x8(%ebp),%eax
}
 763:	c9                   	leave  
 764:	c3                   	ret    

00000765 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 765:	b8 01 00 00 00       	mov    $0x1,%eax
 76a:	cd 40                	int    $0x40
 76c:	c3                   	ret    

0000076d <exit>:
SYSCALL(exit)
 76d:	b8 02 00 00 00       	mov    $0x2,%eax
 772:	cd 40                	int    $0x40
 774:	c3                   	ret    

00000775 <wait>:
SYSCALL(wait)
 775:	b8 03 00 00 00       	mov    $0x3,%eax
 77a:	cd 40                	int    $0x40
 77c:	c3                   	ret    

0000077d <pipe>:
SYSCALL(pipe)
 77d:	b8 04 00 00 00       	mov    $0x4,%eax
 782:	cd 40                	int    $0x40
 784:	c3                   	ret    

00000785 <read>:
SYSCALL(read)
 785:	b8 05 00 00 00       	mov    $0x5,%eax
 78a:	cd 40                	int    $0x40
 78c:	c3                   	ret    

0000078d <write>:
SYSCALL(write)
 78d:	b8 10 00 00 00       	mov    $0x10,%eax
 792:	cd 40                	int    $0x40
 794:	c3                   	ret    

00000795 <close>:
SYSCALL(close)
 795:	b8 15 00 00 00       	mov    $0x15,%eax
 79a:	cd 40                	int    $0x40
 79c:	c3                   	ret    

0000079d <kill>:
SYSCALL(kill)
 79d:	b8 06 00 00 00       	mov    $0x6,%eax
 7a2:	cd 40                	int    $0x40
 7a4:	c3                   	ret    

000007a5 <exec>:
SYSCALL(exec)
 7a5:	b8 07 00 00 00       	mov    $0x7,%eax
 7aa:	cd 40                	int    $0x40
 7ac:	c3                   	ret    

000007ad <open>:
SYSCALL(open)
 7ad:	b8 0f 00 00 00       	mov    $0xf,%eax
 7b2:	cd 40                	int    $0x40
 7b4:	c3                   	ret    

000007b5 <mknod>:
SYSCALL(mknod)
 7b5:	b8 11 00 00 00       	mov    $0x11,%eax
 7ba:	cd 40                	int    $0x40
 7bc:	c3                   	ret    

000007bd <unlink>:
SYSCALL(unlink)
 7bd:	b8 12 00 00 00       	mov    $0x12,%eax
 7c2:	cd 40                	int    $0x40
 7c4:	c3                   	ret    

000007c5 <fstat>:
SYSCALL(fstat)
 7c5:	b8 08 00 00 00       	mov    $0x8,%eax
 7ca:	cd 40                	int    $0x40
 7cc:	c3                   	ret    

000007cd <link>:
SYSCALL(link)
 7cd:	b8 13 00 00 00       	mov    $0x13,%eax
 7d2:	cd 40                	int    $0x40
 7d4:	c3                   	ret    

000007d5 <mkdir>:
SYSCALL(mkdir)
 7d5:	b8 14 00 00 00       	mov    $0x14,%eax
 7da:	cd 40                	int    $0x40
 7dc:	c3                   	ret    

000007dd <chdir>:
SYSCALL(chdir)
 7dd:	b8 09 00 00 00       	mov    $0x9,%eax
 7e2:	cd 40                	int    $0x40
 7e4:	c3                   	ret    

000007e5 <dup>:
SYSCALL(dup)
 7e5:	b8 0a 00 00 00       	mov    $0xa,%eax
 7ea:	cd 40                	int    $0x40
 7ec:	c3                   	ret    

000007ed <getpid>:
SYSCALL(getpid)
 7ed:	b8 0b 00 00 00       	mov    $0xb,%eax
 7f2:	cd 40                	int    $0x40
 7f4:	c3                   	ret    

000007f5 <sbrk>:
SYSCALL(sbrk)
 7f5:	b8 0c 00 00 00       	mov    $0xc,%eax
 7fa:	cd 40                	int    $0x40
 7fc:	c3                   	ret    

000007fd <sleep>:
SYSCALL(sleep)
 7fd:	b8 0d 00 00 00       	mov    $0xd,%eax
 802:	cd 40                	int    $0x40
 804:	c3                   	ret    

00000805 <uptime>:
SYSCALL(uptime)
 805:	b8 0e 00 00 00       	mov    $0xe,%eax
 80a:	cd 40                	int    $0x40
 80c:	c3                   	ret    

0000080d <sigset>:
SYSCALL(sigset)
 80d:	b8 16 00 00 00       	mov    $0x16,%eax
 812:	cd 40                	int    $0x40
 814:	c3                   	ret    

00000815 <sigsend>:
SYSCALL(sigsend)
 815:	b8 17 00 00 00       	mov    $0x17,%eax
 81a:	cd 40                	int    $0x40
 81c:	c3                   	ret    

0000081d <sigret>:
SYSCALL(sigret)
 81d:	b8 18 00 00 00       	mov    $0x18,%eax
 822:	cd 40                	int    $0x40
 824:	c3                   	ret    

00000825 <sigpause>:
 825:	b8 19 00 00 00       	mov    $0x19,%eax
 82a:	cd 40                	int    $0x40
 82c:	c3                   	ret    

0000082d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 82d:	55                   	push   %ebp
 82e:	89 e5                	mov    %esp,%ebp
 830:	83 ec 18             	sub    $0x18,%esp
 833:	8b 45 0c             	mov    0xc(%ebp),%eax
 836:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 839:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 840:	00 
 841:	8d 45 f4             	lea    -0xc(%ebp),%eax
 844:	89 44 24 04          	mov    %eax,0x4(%esp)
 848:	8b 45 08             	mov    0x8(%ebp),%eax
 84b:	89 04 24             	mov    %eax,(%esp)
 84e:	e8 3a ff ff ff       	call   78d <write>
}
 853:	c9                   	leave  
 854:	c3                   	ret    

00000855 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 855:	55                   	push   %ebp
 856:	89 e5                	mov    %esp,%ebp
 858:	56                   	push   %esi
 859:	53                   	push   %ebx
 85a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 85d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 864:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 868:	74 17                	je     881 <printint+0x2c>
 86a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 86e:	79 11                	jns    881 <printint+0x2c>
    neg = 1;
 870:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 877:	8b 45 0c             	mov    0xc(%ebp),%eax
 87a:	f7 d8                	neg    %eax
 87c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 87f:	eb 06                	jmp    887 <printint+0x32>
  } else {
    x = xx;
 881:	8b 45 0c             	mov    0xc(%ebp),%eax
 884:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 887:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 88e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 891:	8d 41 01             	lea    0x1(%ecx),%eax
 894:	89 45 f4             	mov    %eax,-0xc(%ebp)
 897:	8b 5d 10             	mov    0x10(%ebp),%ebx
 89a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 89d:	ba 00 00 00 00       	mov    $0x0,%edx
 8a2:	f7 f3                	div    %ebx
 8a4:	89 d0                	mov    %edx,%eax
 8a6:	0f b6 80 64 10 00 00 	movzbl 0x1064(%eax),%eax
 8ad:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 8b1:	8b 75 10             	mov    0x10(%ebp),%esi
 8b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8b7:	ba 00 00 00 00       	mov    $0x0,%edx
 8bc:	f7 f6                	div    %esi
 8be:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8c5:	75 c7                	jne    88e <printint+0x39>
  if(neg)
 8c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8cb:	74 10                	je     8dd <printint+0x88>
    buf[i++] = '-';
 8cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d0:	8d 50 01             	lea    0x1(%eax),%edx
 8d3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8d6:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8db:	eb 1f                	jmp    8fc <printint+0xa7>
 8dd:	eb 1d                	jmp    8fc <printint+0xa7>
    putc(fd, buf[i]);
 8df:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e5:	01 d0                	add    %edx,%eax
 8e7:	0f b6 00             	movzbl (%eax),%eax
 8ea:	0f be c0             	movsbl %al,%eax
 8ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f1:	8b 45 08             	mov    0x8(%ebp),%eax
 8f4:	89 04 24             	mov    %eax,(%esp)
 8f7:	e8 31 ff ff ff       	call   82d <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 8fc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 900:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 904:	79 d9                	jns    8df <printint+0x8a>
    putc(fd, buf[i]);
}
 906:	83 c4 30             	add    $0x30,%esp
 909:	5b                   	pop    %ebx
 90a:	5e                   	pop    %esi
 90b:	5d                   	pop    %ebp
 90c:	c3                   	ret    

0000090d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 90d:	55                   	push   %ebp
 90e:	89 e5                	mov    %esp,%ebp
 910:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 913:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 91a:	8d 45 0c             	lea    0xc(%ebp),%eax
 91d:	83 c0 04             	add    $0x4,%eax
 920:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 923:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 92a:	e9 7c 01 00 00       	jmp    aab <printf+0x19e>
    c = fmt[i] & 0xff;
 92f:	8b 55 0c             	mov    0xc(%ebp),%edx
 932:	8b 45 f0             	mov    -0x10(%ebp),%eax
 935:	01 d0                	add    %edx,%eax
 937:	0f b6 00             	movzbl (%eax),%eax
 93a:	0f be c0             	movsbl %al,%eax
 93d:	25 ff 00 00 00       	and    $0xff,%eax
 942:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 945:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 949:	75 2c                	jne    977 <printf+0x6a>
      if(c == '%'){
 94b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 94f:	75 0c                	jne    95d <printf+0x50>
        state = '%';
 951:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 958:	e9 4a 01 00 00       	jmp    aa7 <printf+0x19a>
      } else {
        putc(fd, c);
 95d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 960:	0f be c0             	movsbl %al,%eax
 963:	89 44 24 04          	mov    %eax,0x4(%esp)
 967:	8b 45 08             	mov    0x8(%ebp),%eax
 96a:	89 04 24             	mov    %eax,(%esp)
 96d:	e8 bb fe ff ff       	call   82d <putc>
 972:	e9 30 01 00 00       	jmp    aa7 <printf+0x19a>
      }
    } else if(state == '%'){
 977:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 97b:	0f 85 26 01 00 00    	jne    aa7 <printf+0x19a>
      if(c == 'd'){
 981:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 985:	75 2d                	jne    9b4 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 987:	8b 45 e8             	mov    -0x18(%ebp),%eax
 98a:	8b 00                	mov    (%eax),%eax
 98c:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 993:	00 
 994:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 99b:	00 
 99c:	89 44 24 04          	mov    %eax,0x4(%esp)
 9a0:	8b 45 08             	mov    0x8(%ebp),%eax
 9a3:	89 04 24             	mov    %eax,(%esp)
 9a6:	e8 aa fe ff ff       	call   855 <printint>
        ap++;
 9ab:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9af:	e9 ec 00 00 00       	jmp    aa0 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 9b4:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9b8:	74 06                	je     9c0 <printf+0xb3>
 9ba:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9be:	75 2d                	jne    9ed <printf+0xe0>
        printint(fd, *ap, 16, 0);
 9c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c3:	8b 00                	mov    (%eax),%eax
 9c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 9cc:	00 
 9cd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 9d4:	00 
 9d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 9d9:	8b 45 08             	mov    0x8(%ebp),%eax
 9dc:	89 04 24             	mov    %eax,(%esp)
 9df:	e8 71 fe ff ff       	call   855 <printint>
        ap++;
 9e4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9e8:	e9 b3 00 00 00       	jmp    aa0 <printf+0x193>
      } else if(c == 's'){
 9ed:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9f1:	75 45                	jne    a38 <printf+0x12b>
        s = (char*)*ap;
 9f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9f6:	8b 00                	mov    (%eax),%eax
 9f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9fb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a03:	75 09                	jne    a0e <printf+0x101>
          s = "(null)";
 a05:	c7 45 f4 96 0d 00 00 	movl   $0xd96,-0xc(%ebp)
        while(*s != 0){
 a0c:	eb 1e                	jmp    a2c <printf+0x11f>
 a0e:	eb 1c                	jmp    a2c <printf+0x11f>
          putc(fd, *s);
 a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a13:	0f b6 00             	movzbl (%eax),%eax
 a16:	0f be c0             	movsbl %al,%eax
 a19:	89 44 24 04          	mov    %eax,0x4(%esp)
 a1d:	8b 45 08             	mov    0x8(%ebp),%eax
 a20:	89 04 24             	mov    %eax,(%esp)
 a23:	e8 05 fe ff ff       	call   82d <putc>
          s++;
 a28:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2f:	0f b6 00             	movzbl (%eax),%eax
 a32:	84 c0                	test   %al,%al
 a34:	75 da                	jne    a10 <printf+0x103>
 a36:	eb 68                	jmp    aa0 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a38:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a3c:	75 1d                	jne    a5b <printf+0x14e>
        putc(fd, *ap);
 a3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a41:	8b 00                	mov    (%eax),%eax
 a43:	0f be c0             	movsbl %al,%eax
 a46:	89 44 24 04          	mov    %eax,0x4(%esp)
 a4a:	8b 45 08             	mov    0x8(%ebp),%eax
 a4d:	89 04 24             	mov    %eax,(%esp)
 a50:	e8 d8 fd ff ff       	call   82d <putc>
        ap++;
 a55:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a59:	eb 45                	jmp    aa0 <printf+0x193>
      } else if(c == '%'){
 a5b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a5f:	75 17                	jne    a78 <printf+0x16b>
        putc(fd, c);
 a61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a64:	0f be c0             	movsbl %al,%eax
 a67:	89 44 24 04          	mov    %eax,0x4(%esp)
 a6b:	8b 45 08             	mov    0x8(%ebp),%eax
 a6e:	89 04 24             	mov    %eax,(%esp)
 a71:	e8 b7 fd ff ff       	call   82d <putc>
 a76:	eb 28                	jmp    aa0 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a78:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a7f:	00 
 a80:	8b 45 08             	mov    0x8(%ebp),%eax
 a83:	89 04 24             	mov    %eax,(%esp)
 a86:	e8 a2 fd ff ff       	call   82d <putc>
        putc(fd, c);
 a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a8e:	0f be c0             	movsbl %al,%eax
 a91:	89 44 24 04          	mov    %eax,0x4(%esp)
 a95:	8b 45 08             	mov    0x8(%ebp),%eax
 a98:	89 04 24             	mov    %eax,(%esp)
 a9b:	e8 8d fd ff ff       	call   82d <putc>
      }
      state = 0;
 aa0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 aa7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 aab:	8b 55 0c             	mov    0xc(%ebp),%edx
 aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab1:	01 d0                	add    %edx,%eax
 ab3:	0f b6 00             	movzbl (%eax),%eax
 ab6:	84 c0                	test   %al,%al
 ab8:	0f 85 71 fe ff ff    	jne    92f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 abe:	c9                   	leave  
 abf:	c3                   	ret    

00000ac0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ac0:	55                   	push   %ebp
 ac1:	89 e5                	mov    %esp,%ebp
 ac3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ac6:	8b 45 08             	mov    0x8(%ebp),%eax
 ac9:	83 e8 08             	sub    $0x8,%eax
 acc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 acf:	a1 88 10 00 00       	mov    0x1088,%eax
 ad4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ad7:	eb 24                	jmp    afd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 adc:	8b 00                	mov    (%eax),%eax
 ade:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ae1:	77 12                	ja     af5 <free+0x35>
 ae3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ae9:	77 24                	ja     b0f <free+0x4f>
 aeb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aee:	8b 00                	mov    (%eax),%eax
 af0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 af3:	77 1a                	ja     b0f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 af5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af8:	8b 00                	mov    (%eax),%eax
 afa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 afd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b00:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b03:	76 d4                	jbe    ad9 <free+0x19>
 b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b08:	8b 00                	mov    (%eax),%eax
 b0a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b0d:	76 ca                	jbe    ad9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 b0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b12:	8b 40 04             	mov    0x4(%eax),%eax
 b15:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b1f:	01 c2                	add    %eax,%edx
 b21:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b24:	8b 00                	mov    (%eax),%eax
 b26:	39 c2                	cmp    %eax,%edx
 b28:	75 24                	jne    b4e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b2d:	8b 50 04             	mov    0x4(%eax),%edx
 b30:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b33:	8b 00                	mov    (%eax),%eax
 b35:	8b 40 04             	mov    0x4(%eax),%eax
 b38:	01 c2                	add    %eax,%edx
 b3a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b3d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b40:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b43:	8b 00                	mov    (%eax),%eax
 b45:	8b 10                	mov    (%eax),%edx
 b47:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b4a:	89 10                	mov    %edx,(%eax)
 b4c:	eb 0a                	jmp    b58 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b51:	8b 10                	mov    (%eax),%edx
 b53:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b56:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b58:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5b:	8b 40 04             	mov    0x4(%eax),%eax
 b5e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b65:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b68:	01 d0                	add    %edx,%eax
 b6a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b6d:	75 20                	jne    b8f <free+0xcf>
    p->s.size += bp->s.size;
 b6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b72:	8b 50 04             	mov    0x4(%eax),%edx
 b75:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b78:	8b 40 04             	mov    0x4(%eax),%eax
 b7b:	01 c2                	add    %eax,%edx
 b7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b80:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b83:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b86:	8b 10                	mov    (%eax),%edx
 b88:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b8b:	89 10                	mov    %edx,(%eax)
 b8d:	eb 08                	jmp    b97 <free+0xd7>
  } else
    p->s.ptr = bp;
 b8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b92:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b95:	89 10                	mov    %edx,(%eax)
  freep = p;
 b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b9a:	a3 88 10 00 00       	mov    %eax,0x1088
}
 b9f:	c9                   	leave  
 ba0:	c3                   	ret    

00000ba1 <morecore>:

static Header*
morecore(uint nu)
{
 ba1:	55                   	push   %ebp
 ba2:	89 e5                	mov    %esp,%ebp
 ba4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 ba7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 bae:	77 07                	ja     bb7 <morecore+0x16>
    nu = 4096;
 bb0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bb7:	8b 45 08             	mov    0x8(%ebp),%eax
 bba:	c1 e0 03             	shl    $0x3,%eax
 bbd:	89 04 24             	mov    %eax,(%esp)
 bc0:	e8 30 fc ff ff       	call   7f5 <sbrk>
 bc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bc8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bcc:	75 07                	jne    bd5 <morecore+0x34>
    return 0;
 bce:	b8 00 00 00 00       	mov    $0x0,%eax
 bd3:	eb 22                	jmp    bf7 <morecore+0x56>
  hp = (Header*)p;
 bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bde:	8b 55 08             	mov    0x8(%ebp),%edx
 be1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 be7:	83 c0 08             	add    $0x8,%eax
 bea:	89 04 24             	mov    %eax,(%esp)
 bed:	e8 ce fe ff ff       	call   ac0 <free>
  return freep;
 bf2:	a1 88 10 00 00       	mov    0x1088,%eax
}
 bf7:	c9                   	leave  
 bf8:	c3                   	ret    

00000bf9 <malloc>:

void*
malloc(uint nbytes)
{
 bf9:	55                   	push   %ebp
 bfa:	89 e5                	mov    %esp,%ebp
 bfc:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bff:	8b 45 08             	mov    0x8(%ebp),%eax
 c02:	83 c0 07             	add    $0x7,%eax
 c05:	c1 e8 03             	shr    $0x3,%eax
 c08:	83 c0 01             	add    $0x1,%eax
 c0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c0e:	a1 88 10 00 00       	mov    0x1088,%eax
 c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c1a:	75 23                	jne    c3f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c1c:	c7 45 f0 80 10 00 00 	movl   $0x1080,-0x10(%ebp)
 c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c26:	a3 88 10 00 00       	mov    %eax,0x1088
 c2b:	a1 88 10 00 00       	mov    0x1088,%eax
 c30:	a3 80 10 00 00       	mov    %eax,0x1080
    base.s.size = 0;
 c35:	c7 05 84 10 00 00 00 	movl   $0x0,0x1084
 c3c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c42:	8b 00                	mov    (%eax),%eax
 c44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c4a:	8b 40 04             	mov    0x4(%eax),%eax
 c4d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c50:	72 4d                	jb     c9f <malloc+0xa6>
      if(p->s.size == nunits)
 c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c55:	8b 40 04             	mov    0x4(%eax),%eax
 c58:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c5b:	75 0c                	jne    c69 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c60:	8b 10                	mov    (%eax),%edx
 c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c65:	89 10                	mov    %edx,(%eax)
 c67:	eb 26                	jmp    c8f <malloc+0x96>
      else {
        p->s.size -= nunits;
 c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c6c:	8b 40 04             	mov    0x4(%eax),%eax
 c6f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c72:	89 c2                	mov    %eax,%edx
 c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c77:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c7d:	8b 40 04             	mov    0x4(%eax),%eax
 c80:	c1 e0 03             	shl    $0x3,%eax
 c83:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c89:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c8c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c92:	a3 88 10 00 00       	mov    %eax,0x1088
      return (void*)(p + 1);
 c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c9a:	83 c0 08             	add    $0x8,%eax
 c9d:	eb 38                	jmp    cd7 <malloc+0xde>
    }
    if(p == freep)
 c9f:	a1 88 10 00 00       	mov    0x1088,%eax
 ca4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ca7:	75 1b                	jne    cc4 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 ca9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 cac:	89 04 24             	mov    %eax,(%esp)
 caf:	e8 ed fe ff ff       	call   ba1 <morecore>
 cb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 cb7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cbb:	75 07                	jne    cc4 <malloc+0xcb>
        return 0;
 cbd:	b8 00 00 00 00       	mov    $0x0,%eax
 cc2:	eb 13                	jmp    cd7 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ccd:	8b 00                	mov    (%eax),%eax
 ccf:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 cd2:	e9 70 ff ff ff       	jmp    c47 <malloc+0x4e>
}
 cd7:	c9                   	leave  
 cd8:	c3                   	ret    
