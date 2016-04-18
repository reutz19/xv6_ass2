// Segments in proc->gdt.
#define NSEGS             7
#define MAX_CSTACK_FRAMES 10

// Per-CPU state
struct cpu {
  uchar id;                    // Local APIC ID; index into cpus[] below
  struct context *scheduler;   // swtch() here to enter scheduler
  struct taskstate ts;         // Used by x86 to find stack for interrupt
  struct segdesc gdt[NSEGS];   // x86 global descriptor table
  volatile uint started;       // Has the CPU started?
  int ncli;                    // Depth of pushcli nesting.
  int intena;                  // Were interrupts enabled before pushcli?
  
  // Cpu-local storage variables; see below
  struct cpu *cpu;
  struct proc *proc;           // The currently-running process.
};

extern struct cpu cpus[NCPU];
extern int ncpu;

// Per-CPU variables, holding pointers to the
// current cpu and to the current process.
// The asm suffix tells gcc to use "%gs:0" to refer to cpu
// and "%gs:4" to refer to proc.  seginit sets up the
// %gs segment register so that %gs refers to the memory
// holding those two variables in the local cpu's struct cpu.
// This is similar to how thread-local variables are implemented
// in thread libraries such as Linux pthreads.
extern struct cpu *cpu asm("%gs:0");       // &cpus[cpunum()]
extern struct proc *proc asm("%gs:4");     // cpus[cpunum()].proc


// ----------- cstack frame ----------

//defines an element of the concurrent struct
struct cstackframe {
  int sender_pid;
  int recepient_pid;
  int value;
  int used;
  struct cstackframe *next;
};

//defines a concurrent stack
struct cstack {
  struct cstackframe frames[MAX_CSTACK_FRAMES];
  struct cstackframe *head;
};

//adds a new frame to the cstack which is initialized with values
//sender_pid, recepient_pid and value, then returns 1 on success and 0
//if the stack is full
int push(struct cstack *cstack, int sender_pid, int recepient_pid, int value);

//remove and return an element from the head of the given cstack
//if the stack is empty then return zero
struct cstackframe *pop(struct cstack *cstack);

//check if there are pending signals
int is_empty(struct cstack *cstack);

//PAGEBREAK: 17
// Saved registers for kernel context switches.
// Don't need to save all the segment registers (%cs, etc),
// because they are constant across kernel contexts.
// Don't need to save %eax, %ecx, %edx, because the
// x86 convention is that the caller has saved them.
// Contexts are stored at the bottom of the stack they
// describe; the stack pointer is the address of the context.
// The layout of the context matches the layout of the stack in swtch.S
// at the "Switch stacks" comment. Switch doesn't save eip explicitly,
// but it is on the stack and allocproc() manipulates it.
struct context {
  uint edi;
  uint esi;
  uint ebx;
  uint ebp;
  uint eip;
};

enum procstate { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };
//decleration of a signal handler function
typedef void (*sig_handler)(int pid, int value); 

// Per-process state
struct proc {
  uint sz;                       // Size of process memory (bytes)
  pde_t* pgdir;                  // Page table
  char *kstack;                  // Bottom of kernel stack for this process
  volatile int state;            // Process state
  int pid;                       // Process ID
  struct proc *parent;           // Parent process
  struct trapframe *tf;          // Trap frame for current syscall
  struct context *context;       // swtch() here to run process
  volatile int chan;             // If non-zero, sleeping on chan
  int killed;                    // If non-zero, have been killed
  struct file *ofile[NOFILE];    // Open files
  struct inode *cwd;             // Current directory
  char name[16];                 // Process name (debugging)
  sig_handler sighandler;        // signal handler function
  struct cstack pending_signals; // pending signal stack
  struct trapframe old_tf;       // Trap frame for backup syscall
  int handling_signal;           // flag for handling a signal (zero is not handling)
};

// Process memory is laid out contiguously, low addresses first:
//   text
//   original data and bss
//   fixed-size stack
//   expandable heap
