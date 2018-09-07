#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <sys/mman.h>
#include <math.h>

#include <alchemy/task.h>

RT_TASK demo_task1;
RT_TASK demo_task2;
RT_TASK demo_task3;

void demo(void *arg) {
	int num = * (int *)arg;
	//rt_task_set_periodic(NULL, TM_NOW,  (RTIME)num*pow(10,8));
	rt_task_sleep(1*pow(10,7));//1*pow(10,7)
	rt_printf("I am awake");
	//while (1) {
	//	RT_TASK_INFO curtaskinfo;
	//	rt_task_inquire(NULL,&curtaskinfo);
	//	char str[12];
	//	sprintf(str, "%d", num);
	//	rt_printf("Task name: %s ", str);
	//	rt_printf("\n");
	//	rt_task_wait_period(NULL);
	//}
	return;
}

int main(int argc, char* argv[])
{
  char  str1[10] ;
  char  str2[10] ;
  char  str3[10] ;

  // Perform auto-init of rt_print buffers if the task doesn't do so
  //rt_print_auto_init(1);

  // Lock memory : avoid memory swapping for this program
  mlockall(MCL_CURRENT|MCL_FUTURE);

  rt_printf("start task\n");

  /*
   * Arguments: &task,
   *            name,
   *            stack size (0=default),
   *            priority,
   *            mode (FPU, start suspended, ...)
   */
  sprintf(str1,"hello1");
  sprintf(str2,"hello2");
  sprintf(str3,"hello3");
  rt_task_create(&demo_task1, str1, 0, 50, 0);
  rt_task_create(&demo_task2, str2, 0, 50, 0);
  rt_task_create(&demo_task3, str3, 0, 50, 0);
    /*
   * Arguments: &task,
   *            task function,
   *            function argument
   */
  int indexOne = 1;
  int indexTwo = 2;
  int indexThree = 3;
  int returnval = rt_task_start(&demo_task1, &demo, &indexOne);
  if (returnval<0)
	rt_printf("Sending error %d : %s\n",-returnval,strerror(-returnval));
  //rt_task_start(&demo_task2, &demo, &indexTwo);
  //rt_task_start(&demo_task3, &demo, &indexThree);
  printf("end program by CTRL-C\n");
  //pause();
}
