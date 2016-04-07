#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
  int pid = getpid();
  printf(1, "print cas result proc pid = %d\n", pid);
  kill(pid);
  exit();
}
