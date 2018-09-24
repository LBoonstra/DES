#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/sem.h>
#include <alchemy/timer.h>
#include <alchemy/mutex.h>
   
#define HIGH 50 /* high priority */
#define MID 40 /* medium priority */
#define LOW 30  /* low priority */

RT_TASK lowtask;
RT_TASK middletask;
RT_TASK hightask;
RT_MUTEX lowhigh;
RT_SEM midsem;
RT_SEM highsem;
RT_SEM synchron;

#define EXECTIME   2e8   // execution time in ns
#define SPINTIME   1e7   // spin time in ns

   
void lowesttask(void *arg)
{
	rt_sem_p(&synchron, (RTIME) TM_INFINITE);
	int i;
	for (i=0; i<3;i++) {
		rt_mutex_acquire(&lowhigh, (RTIME) TM_INFINITE);
		rt_printf("Low priority task locks mutex\n");
		rt_sem_v(&midsem);
		rt_printf("Low priority task unlocks mutex\n");
		rt_mutex_release(&lowhigh);
	}
	rt_printf("..........................................Low priority task ends\n");
}
   
void midtask(void *arg)
{
   rt_sem_p(&midsem, (RTIME) TM_INFINITE);
   int i;
   for (i=0; i<12; i++){
	   printf("Medium task running\n");
	   if(i==1){
		rt_sem_v(&highsem);   
   }
   }
	printf("------------------------------------------Medium priority task ends\n");       
}

   
void highesttask(void *arg)
{
	rt_sem_p(&highsem, (RTIME) TM_INFINITE);
	int i;
	for (i=0; i<3;i++) {
		rt_printf("High priority tries to lock mutex\n");
		rt_mutex_acquire(&lowhigh, (RTIME) TM_INFINITE);
		rt_printf("High priority task locks mutex\n");
		rt_printf("High priority task unlocks mutex\n");
		rt_mutex_release(&lowhigh);
	}
	rt_printf("..........................................High priority task ends\n");
}

   
int main(int argc, char* argv[])
{
	rt_sem_create(&synchron,"Synchronisation",0,S_FIFO);
	// semaphore to sync task startup on
	rt_sem_create(&midsem,"MidSemaphore",0,S_FIFO);
	rt_sem_create(&highsem,"HighSemaphore",0,S_FIFO);
	rt_mutex_create(&lowhigh, "LowHighMutex");

	rt_task_create(&lowtask, "low task", 0, LOW, 0);
	rt_task_create(&middletask, "middle task", 0, MID, 0);
	rt_task_create(&hightask, "high task", 0, HIGH, 0);    
	rt_task_start(&lowtask, &lowesttask, 0);
	rt_task_start(&middletask, &midtask, 0);
	rt_task_start(&hightask, &highesttask, 0);
	printf("wake up all tasks\n");
	rt_sem_broadcast(&synchron);
	printf("\nType CTRL-C to end this program\n\n" );
	pause();
}

