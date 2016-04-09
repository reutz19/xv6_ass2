#include "types.h"  
#include "user.h"

#define MAX_INPUT 10

int
calculate_prime(int number)
{
  return 0;
}

int
main(int argc, char *argv[])
{
  int n, i, pid, prime;
  char buff[MAX_INPUT];

  // test arguments
  if (argc != 2){
  	printf(1, "Unvaild parameter for primsrv test\n");
  	exit();
  }

  n = atoi(argv[1]);
  int workers[n];

  for(i = 0; i < n; i++){
  	if ((pid = fork()) == 0) { // son
      pid = getpid();
 	    printf(1, "Process number = %d,  PID = %d\n", i+1, pid);	
 	    sigpause();
    }
    else if (pid < 0) {        // fork failed
      printf(1, "fork() failed!\n"); 
      exit();
    }
    else {
      workers[i] = pid;
    }
  }

  for(;;)
  {
  	printf(1, "Please enter a number: \n");
  	gets(buff, MAX_INPUT);
  	prime = atoi(buff);
  	if(prime == 0)
  	{
  	  for (i = 0; i < n; i++)
  	  {
  	    printf(1, "worker %d exit\n", workers[i]);
        kill(workers[i]);
  	  }
  	  printf(1, "primesrv exit\n");
  	  exit();
  	}
  }

  exit();
}
