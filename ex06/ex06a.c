   #include <stdio.h>
   #include <signal.h>
   #include <unistd.h>
   #include <alchemy/task.h>
   #include <alchemy/sem.h>
   #include <alchemy/timer.h>
   
   #define HIGH 50 /* high priority */
   #define MID 40 /* medium priority */
   #define LOW 30  /* low priority */

   RT_TASK lowtask;
   RT_TASK middletask;
   RT_TASK hightask;
   RT_SEM lowhigh;
   RT_SEM midsem;
   RT_SEM highsem;

   #define EXECTIME   2e8   // execution time in ns
   #define SPINTIME   1e7   // spin time in ns

   
   void lowtask(void *arg)
   {
		
   }
   
   void midtask(void *arg)
   {
	   rt_sem_p(&midsem, RTIME TM_INFINITE);
	   int i;
	   for (i=0; i<12; i++){
		   printf("Medium task running\n");
		   if(i==1){
			rt_sem_v(&highsem);   
		   }   
   }
   
   int main(int argc, char* argv[])
   {
	int i;
    char  str[10] ;
    // semaphore to sync task startup on
    rt_sem_create(&mysync,"MySemaphore",0,S_FIFO);
    
	rt_task_create(&lowtask, "low task", 0, LOW, 0);
	rt_task_create(&middletask, "middle task", 0, MID, 0);
	rt_task_create(&hightask, "high task", 0, HIGH, 0);	

    printf("wake up all tasks\n");
    rt_sem_broadcast(&mysync);
    printf("\nType CTRL-C to end this program\n\n" );
    pause();
   }