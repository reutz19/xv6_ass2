#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

struct {
  //struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  //initlock(&ptable.lock, "ptable");
}

int 
allocpid(void) 
{
  int pid;
  //acquire(&ptable.lock);
  //pid = nextpid++;
  //release(&ptable.lock);

  do{
    pid = nextpid;
  } while(!cas(&nextpid, pid, pid+1));
  //cprintf("alloc pid = %d", pid + 1);
  return pid;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  //acquire(&ptable.lock);
  //pushcli();
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    //if(p->state == UNUSED)
    if(cas(&(p->state), UNUSED, EMBRYO))
      goto found;
  //release(&ptable.lock);
  //popcli();
  return 0;

found:
  //p->state = EMBRYO;  
  //release(&ptable.lock);
  //popcli();

  p->pid = allocpid();

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  //initialize cstack
  struct cstackframe *csf;
  for(csf = p->pending_signals.frames; csf < &p->pending_signals.frames[MAX_CSTACK_FRAMES]; csf++) {
    csf->used = 0;
  }
  p->pending_signals.head = 0;

  // available for handeling signal 
  p->handling_signal = 0;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));
  //copy signal handler
  np->sighandler = proc->sighandler; 
  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  //acquire(&ptable.lock);
  //np->state = RUNNABLE;
  //release(&ptable.lock);
  pushcli();
  //change process state, if didn't succeed then return -1 for fork() failed
  if(!cas(&(np->state), EMBRYO, RUNNABLE))
  {
    popcli();
    return -1;
  }
  popcli();
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  //acquire(&ptable.lock);
  //proc->state = ZOMBIE;
  pushcli();
  if(!cas(&(proc->state), RUNNING, nZOMBIE)){
    return; // if cas() failed then exit() failed
  }

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc)
    {
      p->parent = initproc;
      if(p->state == ZOMBIE || p->state == nZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  //acquire(&ptable.lock);
  pushcli();

  for(;;){
    proc->chan = (int)proc;
    //proc->state = SLEEPING;
    // start transition to SLEEPING (finish in scheduler)
    cas(&(proc->state),RUNNING, nSLEEPING);    
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      
      havekids = 1;
      //busy wait until scheduler finish transition to ZOMBIE
      while(p->state == nZOMBIE);

      // transition finished, now we are sure the state is ZOMBIE
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        //p->state = UNUSED;
        cas(&(p->state), ZOMBIE, UNUSED);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;

        proc->chan = 0;
        //proc->state = RUNNING;
        //release(&ptable.lock);
        // if a child zombie so we need to return it's pid, so we're back to RUNNING
        cas(&(proc->state), nSLEEPING, RUNNING);
        cas(&(proc->state), nRUNNABLE, RUNNING);  

        popcli();
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      proc->chan = 0;
      //proc->state = RUNNING;      
      //release(&ptable.lock);
      cas(&(proc->state), nSLEEPING, RUNNING);
      cas(&(proc->state), SLEEPING, RUNNING);
      popcli();
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sched();
  }
}

void 
freeproc(struct proc *p)
{
  if (!p || p->state != nZOMBIE)
    panic("freeproc not zombie");
  kfree(p->kstack);
  p->kstack = 0;
  freevm(p->pgdir);
  p->killed = 0;
  p->chan = 0;
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    //acquire(&ptable.lock);
    pushcli();
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      //if(p->state != RUNNABLE)
      if(!cas(&(p->state), RUNNABLE, RUNNING))
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      //p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
      cas(&(p->state), nSLEEPING, SLEEPING);
      cas(&(p->state), nRUNNABLE, RUNNABLE);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      if (p->state == nZOMBIE)
      {
        freeproc(p);
        cas(&(p->state), nZOMBIE, ZOMBIE);
      }
    }
    //release(&ptable.lock);
    popcli();
  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  //if(!holding(&ptable.lock))
  //  panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  //acquire(&ptable.lock);  //DOC: yieldlock
  //proc->state = RUNNABLE;
  pushcli();
  cas(&(proc->state), RUNNING, nRUNNABLE);
  sched();
  popcli();
  //release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  //release(&ptable.lock);
  popcli();

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    initlog();
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  //if(lk != &ptable.lock){  //DOC: sleeplock0
  //  acquire(&ptable.lock);  //DOC: sleeplock1
  //  release(lk);
  //}

  // Go to sleep.
  proc->chan = (int)chan;
  //proc->state = SLEEPING;
  cas(&(proc->state), RUNNING, nSLEEPING);

  pushcli();
  release(lk);
  sched();
  acquire(lk);
  popcli();
  // Reacquire original lock.
  //if(lk != &ptable.lock){  //DOC: sleeplock2
  //  release(&ptable.lock);
  //  acquire(lk);
  //}
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    // if the proccess is sleeping
    if(p->chan == (int)chan)
    {
      // if the proccess did'nt finish transition to SLEEPING then start the transition to RUNNABLE
      if(cas(&(p->state),nSLEEPING, nRUNNABLE))
        p->chan= 0;
      // proccess is SLEEPING
      if(cas(&(p->state),SLEEPING, RUNNABLE))
        p->chan= 0;
    }
  }
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  //acquire(&ptable.lock);
  pushcli();
  wakeup1(chan);
  popcli();
  //release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;
  //acquire(&ptable.lock);
  pushcli();
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {  
    if(p->pid == pid)
    {
      p->killed = 1;
      // Wake process from sleep if necessary.
      //if(p->state == SLEEPING)
        //p->state = RUNNABLE;
      //busy wait until scheduler finish transition to SLEEPING
      while(p->state == nSLEEPING);
      cas(&(p->state), SLEEPING, RUNNABLE);
      //release(&ptable.lock);
      popcli();
      return 0;
    }
  }
  //release(&ptable.lock);
  popcli();
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie",
  [nSLEEPING] "nsleep",
  [nRUNNABLE] "nrunble",
  [nZOMBIE]   "nzombie" 
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    //busy wait until scheduler finish transition to SLEEPING
    while(p->state == nSLEEPING);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

void* 
sigset(void* new_handler)
{
  sig_handler oldhandler = proc->sighandler; 
  proc->sighandler = new_handler;
  return oldhandler;
}

int
sigsend(int dest_pid, int value)
{
  struct proc *p; 

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
    if (p->pid == dest_pid) {
      //found dest_pid process
  
      //if push succeed wakeup current proc and return 0
      if (push(&p->pending_signals, proc->pid, dest_pid, value)) 
      {
        wakeup((void*)p->chan);
        return 0;
      }
      break;
    }
  }
  return -1;  
}

int
sigret(void)
{
  if(proc)
  {
    // restore origin user stack
    *(proc->tf) = proc->old_tf;  

    //finish handling signal so we could handle the next one
    proc->handling_signal = 0;
    proc->curr_signal->used = 0;
  }

  return 0;
}

int
sigpause(void)
{
  /*
  if(proc)
  {
    if (is_empty(&(proc->pending_signals))) {
      acquire(&ptable.lock);
      proc->chan = (int)proc;
      proc->state = SLEEPING;
      sched();
      release(&ptable.lock);
    }
  }
  return 0;
  */
  if(proc)
  {
    if(is_empty(&(proc->pending_signals)))
      return 0;
    int toRun = 1;
    while(toRun)
    {
      proc->chan = (int)proc;    
      cas(&proc->state, RUNNING, nSLEEPING);
      // again, check if there are pending signals
      if(is_empty(&(proc->pending_signals)))
      {
        cas(&proc->state, SLEEPING, RUNNING);
        cas(&proc->state, nSLEEPING, RUNNING);
        toRun = 0;
        return 0;
      }
      pushcli();
      sched();
      popcli();
    }
  }
  return 0;
}


// -------------- cstack implementation ------------
int 
push(struct cstack *cstack, int sender_pid, int recepient_pid, int value)
{
  struct cstackframe *csf;
  for(csf = cstack->frames; csf < &cstack->frames[MAX_CSTACK_FRAMES]; csf++) {
    if(cas(&(csf->used), 0, 1)) 
      goto found;
  }

  //stack is full
  return 0;

  //found an unused signal
  found:

  // copy values
  csf->sender_pid = sender_pid;
  csf->recepient_pid = recepient_pid;
  csf->value = value;
  
  do {
    csf->next = cstack->head;
  } while (!cas((int*)&(cstack->head), (int)csf->next, (int)csf));
  
  return 1;
}

struct cstackframe*
pop(struct cstack *cstack)
{
  struct cstackframe *csf;
  struct cstackframe *next;
  
  do {
    csf = cstack->head;
    if (!csf)
      return 0;

    next = csf->next;
  } while (!cas((int*)&(cstack->head), (int)csf, (int)next));

  return csf;
}

int
is_empty(struct cstack *cstack)
{
  return cstack->head == 0 ? 1 : 0;
}

// this function takes a number and round it up to a number that is divided by 4
// use is in order to push address space to stack, keep stack aligned
int 
roundup_4div(int num)
{
  return (((num + 3) >> 2) << 2);
}

void
fix_tf(struct trapframe *tf)
{ 
  if (proc == 0)  //no proccess
    return;

  if (((tf->cs) & 3) != DPL_USER) //has no user privilge
    return;

  // ---- here only user -----

  // if proc already handling a signal then return
  if (!cas((int*)&proc->handling_signal, 0, 1))
    goto done;

  struct cstackframe *new_signal;
  // no pending signal in the stack  OR  signal_handler is default
  if(!(new_signal = pop(&proc->pending_signals)) || proc->sighandler == DEFSIG_HENDLER) {
    if (new_signal)
      new_signal->used = 0;
    proc->handling_signal = 0;
    goto done; 
  }

  proc->curr_signal = new_signal;

  //else, we have a pending signal and a handler: 
  
  // back-up the old trap-frame for handeling user stack
  proc->old_tf = *(tf);
  
  int addr_space; 
  //int ret_addr;
  
  int stam = 0;
  if (1 == stam) {
    goToStack: // lable#1
    asm volatile("movl $24, %eax; int $64"); //movl $SYS_sigret, %eax; int $T_SYSCALL; 
    returnFromStack:; // lable#2
  }

  addr_space = &&returnFromStack - &&goToStack;
  addr_space = roundup_4div(addr_space);

  tf->esp -= addr_space;
  memmove((void *)tf->esp, &&goToStack, addr_space);

  tf->esp -= 4;
  *(uint *)tf->esp = new_signal->value;      //param 2

  tf->esp -= 4;
  *(uint *)tf->esp = new_signal->sender_pid; //param 1

  tf->esp -= 4;
  *(uint *)tf->esp = tf->esp + 12;
  
  tf->eip = (int)proc->sighandler;  

  done:;
}