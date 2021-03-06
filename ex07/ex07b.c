#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <alchemy/sem.h>
#include <rtdm/gpio.h>
#include <math.h>

RT_TASK light_task;
RT_TASK interrupt_task;
RT_SEM mysync;

void light(void *arg) {
	rt_sem_p(&mysync,TM_INFINITE);
    RT_TASK_INFO curtaskinfo;
    rt_task_inquire(NULL,&curtaskinfo);
	rt_task_set_periodic(NULL, TM_NOW, (RTIME) pow(10,9)/2);
	int valuer,ret, valuew ;
	int fdr  = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_RDONLY|O_NONBLOCK);
	int fdw  = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdr, GPIO_RTIOC_DIR_IN);
	ret=ioctl(fdw, GPIO_RTIOC_DIR_OUT, &valuew);
	while(1){
		ret=read(fdr, &valuer, sizeof(valuer));
		if (valuer == 0){
			valuew = 1;
			ret=write(fdw, &valuew, sizeof(valuew));
		}
		else{
			valuew = 0;
			ret=write(fdw, &valuew, sizeof(valuew));
		}
		
		rt_task_wait_period(NULL);
	}
	return;
}

void interrupt(void *arg) {
	rt_sem_p(&mysync,TM_INFINITE);
	int ret, value, count_interrupts;
	count_interrupts=0;
	int fdr24 = open("/dev/rtdm/pinctrl-bcm2835/gpio24",O_RDONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdr24, GPIO_RTIOC_IRQEN, &xeno_trigger);
	while(1) {
		ret = read(fdr24, &value, sizeof(value));
		count_interrupts+=1;
		rt_printf("counter : %d \n",count_interrupts);
	}
}

int main(int argc, char* argv[])
{
  rt_sem_create(&mysync,"MySemaphore",0,S_FIFO);
  rt_task_create(&light_task, "tasklight", 0, 50, 0);
  rt_task_start(&light_task, &light, 0);
  
  rt_task_create(&interrupt_task, "interrupttask", 0, 60, 0);
  rt_task_start(&interrupt_task, &interrupt, 0);
  
  printf("\nType CTRL-C to end this program\n\n" );
  rt_sem_broadcast(&mysync);
  pause();
}
