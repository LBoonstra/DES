#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <sys/mman.h>

#include <alchemy/task.h>

RT_TASK demo_task1;
RT_TASK demo_task2;
RT_TASK demo_task3;
RT_TASK demo_task4;
RT_TASK demo_task5;

void demo(void *arg) {
    RT_TASK_INFO curtaskinfo;
    rt_task_inquire(NULL,&curtaskinfo);
    rt_printf("Task name: %s \n", curtaskinfo.name);
}

int main(int argc, char* argv[])
{
  char  str1[10] ;
  char  str2[10] ;
  char  str3[10] ;
  char  str4[10] ;
  char  str5[10] ;

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
  sprintf(str4,"hello4");
  sprintf(str5,"hello5");
  rt_task_create(&demo_task1, str1, 0, 50, 0);
  rt_task_create(&demo_task2, str2, 0, 50, 0);
  rt_task_create(&demo_task3, str3, 0, 50, 0);
  rt_task_create(&demo_task4, str4, 0, 50, 0);
  rt_task_create(&demo_task5, str5, 0, 50, 0);
    /*
   * Arguments: &task,
   *            task function,
   *            function argument
   */

  rt_task_start(&demo_task1, &demo, 0);
  rt_task_start(&demo_task2, &demo, 0);
  rt_task_start(&demo_task3, &demo, 0);
  rt_task_start(&demo_task4, &demo, 0);
  rt_task_start(&demo_task5, &demo, 0);

}
