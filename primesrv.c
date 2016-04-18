#include "types.h"  
#include "user.h"

#define MAX_INPUT 10

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
      for (i = 3; i <= num; i+=2){
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
    printf(1, "worker %d exit\n", getpid());
    exit();
  }

  // get next prime
  int c = next_pr(value); 
  printf(1, "process %d in next_pr return ans %d for %d, main_pid is %d\n",getpid(), c, value, main_pid);

  //return result to main proccess
  sigsend(main_pid, c); 
  //pause until the next number
  sigpause();
}
  
void
handle_main_sig(int worker_pid, int value)
{
  int i;
  for (i = 0; i < workers_number; i++) {
    if (workers[i].pid == worker_pid){
      printf(1, "worker %d returned %d as a result for %d", worker_pid, value, workers[i].input_x);
      workers[i].working = 0;
      break;
    }
  }
}

int
main(int argc, char *argv[])
{
  int i, pid, input_x;
  char buff[MAX_INPUT];

  // test arguments
  if (argc != 2) {
  	printf(1, "Unvaild parameter for primsrv test\n");
  	exit();
  }

  // allocate workers array
  workers_number = atoi(argv[1]);
  workers = (worker_s*) malloc(workers_number * sizeof(worker_s));
  
  sigset((void *)handle_main_sig);
  printf(1, "workers pids:\n");
  for(i = 0; i < workers_number; i++) {
  	
    if ((pid = fork()) == 0) {  // son
      printf(1, "%d\n", getpid());	
      sigset((void *)handle_worker_sig);
      sigpause();
    }
    else if (pid > 0) {         // father
      //init son worker_s 
      workers[i].pid = pid;
      workers[i].input_x = -1;
      workers[i].working = 0;
    }
    else {                      // fork failed
      printf(1, "fork() failed!\n"); 
      exit();
    }
  }

  for(;;)
  {
  	printf(1, "Please enter a number: ");
  	gets(buff, MAX_INPUT);
  	if (*buff == 0){
      //handle main signals by calling a system call
      sigset((void *)handle_main_sig);
      continue;
    }

    input_x = atoi(buff);
  	if(input_x != 0)
    {
      // find an idle process = p - TODO
      // send input_x to process p using sigsend sys-call 
      for (i = 0; i < workers_number; i++)
      {
        if (workers[i].working == 0) // available
        {
          workers[i].working = 1;
          sigsend(workers[i].pid, input_x);  
          printf(1, "Send signal val %d to worker %d: \n", input_x, workers[i].pid);
          break;
        }
      }

      // no free workers to handle signal
      if (i == workers_number){
        printf(1, "no idle workers\n");
      }
    }
    else
  	{
  	  for (i = 0; i < workers_number; i++)
  	  {
        sigsend(workers[i].pid, 0);
  	  }
      //wait for all sons
      while (wait() > 0);
      free(workers);
  	  printf(1, "primesrv exit\n");
  	  exit();
  	}
  }

  exit();
}
