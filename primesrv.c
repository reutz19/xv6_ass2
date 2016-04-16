#include "types.h"  
#include "user.h"

#define MAX_INPUT 10
/*
int
calculate_prime(int number)
{
  return 0;
}
*/

int 
is_prime(int num){
    if((num & 1)==0)
        return num == 2;
    else {
        int i;
        for (i = 3; i <= num; i+=2){
            if (num % i == 0)
                return 0;
        }
    }
    return 1;
}

int 
next_pr(int num){
    int c;
    if(num < 2)
        c = 2;
    else if (num == 2)
        c = 3;
    else if(num & 1){
        num += 2;
        c = is_prime(num) ? num : next_pr(num);
    } else
        c = next_pr(num-1);
    printf(1, "in next_pr the ans is %d\n", c);
    return c;
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

  printf(1, "workers pids:\n");
  for(i = 0; i < n; i++){
  	if ((pid = fork()) == 0) { // son
      pid = getpid();
 	    printf(1,"%d\n", pid);	
 	    sigset((int *)next_pr);
      sigpause();
    }
    else if (pid > 0) {        // father
      workers[i] = pid;
    }
    else{
    // fork failed
      printf(1, "fork() failed!\n"); 
      exit();
    }
  }

  for(;;)
  {
  	printf(1, "Please enter a number: \n");
  	gets(buff, MAX_INPUT);
  	prime = atoi(buff);
    int ans;
  	if(prime != 0)
    {
      // find an idle process = p
      // send the process the input number using sigsend sys-call -
      // if (sigsend(p, prime) != -1)
      if (!sigsend(5, prime)){
        printf(1, "worker 5 returned ??? as a result for %d\n",prime);
      }

    }
    else
  	{
  	  for (i = 0; i < n; i++)
  	  {
  	    printf(1, "worker %d exit\n", workers[i]);
  	  }
  	  printf(1, "primesrv exit\n");
  	  exit();
  	}
  }

  exit();
}
