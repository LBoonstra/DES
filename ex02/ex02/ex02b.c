#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <sys/mman.h>

#include <alchemy/task.h>

RT_TASK demo_task;

void demo(void *arg) {
	RT_TASK_INFO curtaskinfo;
	int num = * (int *)arg;
    rt_task_inquire(NULL,&curtaskinfo);
	char str[12];
	sprintf(str, "%d", num);
    rt_printf("Task name: %s ", str);
}

int main(int argc, char* argv[])
{
  char  str[10] ;

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
  sprintf(str,"hello");
  rt_task_create(&demo_task, str, 0, 50, 0);
  //rt_task_create(&demo_task, str, 0, 50, 0);
  //rt_task_create(&demo_task, str, 0, 50, 0);
  //rt_task_create(&demo_task, str, 0, 50, 0);
  //rt_task_create(&demo_task, str, 0, 50, 0);
    /*
   * Arguments: &task,
   *            task function,
   *            function argument
   */
  int indexOne = 1;
  int indexTwo = 2;
  int indexThree = 3;
  int indexFour = 4;
  int indexFive = 5;
  rt_task_start(&demo_task, &demo, &indexOne);
  //rt_task_start(&demo_task, &demo, 0);
  //rt_task_start(&demo_task, &demo, 0);
  //rt_task_start(&demo_task, &demo, 0);
  //rt_task_start(&demo_task, &demo, 0);
  
  rt_task_create(&demo_task, str, 0, 50, 0);
  rt_task_start(&demo_task, &demo, &indexTwo);
  
  rt_task_create(&demo_task, str, 0, 50, 0);
  rt_task_start(&demo_task, &demo, &indexThree);
  
  rt_task_create(&demo_task, str, 0, 50, 0);
  rt_task_start(&demo_task, &demo, &indexFour);
  
  rt_task_create(&demo_task, str, 0, 50, 0);
  rt_task_start(&demo_task, &demo, &indexFive);

}
