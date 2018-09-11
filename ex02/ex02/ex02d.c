#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <math.h>
#include <sys/mman.h>
#include <alchemy/task.h>

RT_TASK demo_task1;
RT_TASK demo_task2;
RT_TASK demo_task3;



void demo(void *arg) {
    RT_TASK_INFO curtaskinfo;
    rt_task_inquire(NULL,&curtaskinfo);
	int num = * (int*)arg;
	rt_task_sleep(1*pow(10,9));
	rt_task_set_periodic(NULL, TM_NOW, (RTIME) num*pow(10,9));
	while(1){
    rt_printf("Task name: %d \n", num);
	rt_task_wait_period(NULL);
	}
	return;
}

int main(int argc, char* argv[])
{
  char  str1[10] ;
  char  str2[10] ;
  char  str3[10] ;


  printf("start task\n");
  // Lock memory : avoid memory swapping for this program
  mlockall(MCL_CURRENT|MCL_FUTURE);
  
  sprintf(str1,"hello1");
  sprintf(str2,"hello2");
  sprintf(str3,"hello3");

  
  /* Create task
   * Arguments: &task,
   *            name,
   *            stack size (0=default),
   *            priority,
   *            mode (FPU, start suspended, ...)
   */  
  rt_task_create(&demo_task1, str1, 0, 50, 0);
  rt_task_create(&demo_task2, str2, 0, 50, 0);
  rt_task_create(&demo_task3, str3, 0, 50, 0);

	

  /*  Start task
   * Arguments: &task,
   *            task function,
   *            function argument
   */

  int num[3] = {1,2,3};
  rt_task_start(&demo_task1, &demo, &num[0]);
  rt_task_start(&demo_task2, &demo, &num[1]);
  rt_task_start(&demo_task3, &demo, &num[2]);

  
  printf("end program by CTRL-C\n");
  pause();
}