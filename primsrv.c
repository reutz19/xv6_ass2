#include "types.h"  
#include "user.h"
#include "stat.h"

#define MAX_INPUT 100
#define STDOUT 2

typedef struct worker {
  int pid;          // process id
  int input_x;      // input x 
  int working;      // process is currently working on a signal
} worker_s;

static int workers_number;
static worker_s *workers;

//check if a number is prime
int 
is_prime(int num)
{
    if((num & 1)==0)      //even - only 2 is prime
        return num == 2;
    else  //odd
    {       
      int i;
      for (i = 3; i*i <= num; i+=2){
          if (num % i == 0)
              return 0;
      }
    }
    return 1;
}

//get a number x and return the first prime number that is larger than x
int 
next_pr(int num)
{
    if(num < 2)
        return 2;
    else if (num == 2)
        return 3;
    else if(num & 1){ // odd 
        num += 2;
        return is_prime(num) ? num : next_pr(num);
    } 
    else              // even 
        return next_pr(num-1);  //become odd and return next_pr
}

void 
handle_worker_sig(int main_pid, int value)
{
  if (value == 0) {
    exit();
  }

  // get next prime
  int c = next_pr(value); 

  //return result to main proccess
  while (sigsend(main_pid, c) != 0);
}
  
void
handle_main_sig(int worker_pid, int value)
{
  int i;
  for (i = 0; i < workers_number; i++) {
    if (workers[i].pid == worker_pid){
      printf(STDOUT, "worker %d returned %d as a result for %d\n", worker_pid, value, workers[i].input_x);
      workers[i].working = 0;
      break;
    }
  }
}

int
main(int argc, char *argv[])
{
  //int i, pid, input_x, bob;
  int i, pid, input_x;
  int toRun = 1;
  char buf[MAX_INPUT];

  // validate arguments
  if (argc != 2) {
    printf(STDOUT, "Unvaild parameter for primsrv test\n");
    exit();
  }

  // allocate workers array
  workers_number = atoi(argv[1]);
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
  
  // configure the main process with workers-handler inorder to pass it to son by fork()
  sigset((void *)handle_worker_sig);
  printf(STDOUT, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
    
    if ((pid = fork()) == 0) {  // son
      while(1) sigpause();
    }
    else if (pid > 0) {         // father
      //init son worker_s 
      printf(STDOUT, "%d\n", pid);  
      workers[i].pid = pid;
      workers[i].input_x = -1;
      workers[i].working = 0;
    }
    else {                      // fork failed
      printf(STDOUT, "fork() failed!\n"); 
      exit();
    }
  }

  // configure the main process - correct handler
  sigset((void *)handle_main_sig);

  while(toRun)
  {
    printf(STDOUT, "Please enter a number: ");

    read(1, buf, MAX_INPUT);
    
    if (buf[0] == '\n'){ //handle main signals
      continue;
    }

    input_x = atoi(buf);

    if(input_x != 0)
    {
      //for (bob = 0; bob < input_x; bob++) 
      //{
        // send input_x to process p using sigsend sys-call 
        for (i = 0; i < workers_number; i++)
        {
          if (workers[i].working == 0) // available
          {
            workers[i].working = 1;
            //workers[i].input_x = bob + 1;//input_x;
            //if (sigsend(workers[i].pid, bob + 1))//input_x);
            if (sigsend(workers[i].pid, input_x))//input_x);    
              printf(1, "********** failed to sigsend to worker %d\n", workers[i].pid);
            break;
          }
        }

        // no idle workers to handle signal
        if (i == workers_number){
          printf(STDOUT, "no idle workers\n");
        }
      //}
    }

    else // input_x == 0, exiting program
    {
      for (i = 0; i < workers_number; i++)
      {
        sigsend(workers[i].pid, 0);
        printf(STDOUT, "worker %d exit\n", workers[i].pid);
      }
      toRun = 0;
    }
  }
  
  for(i = 0; i < workers_number; i++)
    wait();
  free(workers);
  printf(STDOUT, "primsrv exit\n");
  exit();
}

