#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <rtdm/gpio.h>
#include <math.h>

RT_TASK light_task;

void light(void *arg) {
    RT_TASK_INFO curtaskinfo;
    rt_task_inquire(NULL,&curtaskinfo);
	rt_task_set_periodic(NULL, TM_NOW, (RTIME) pow(10,9)/2);
	int valuer,ret, valuew;
	int fdr  = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_RDONLY|O_NONBLOCK);
	int fdw  = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_WRONLY);
	ret=ioctl(fdr, GPIO_RTIOC_DIR_IN);
	ret=ioctl(fdw, GPIO_RTIOC_DIR_OUT, &valuew);
	//valuer= 0;
	while(1){
		ret=read(fdr, &valuer, sizeof(valuer));
		if (valuer == 0){
			valuew = 1;
			rt_printf("value: %d \n",valuew);
			rt_printf("value of read: %d \n",valuer);
			ret=write(fdw, &valuew, sizeof(valuew));
		}
		else{
			valuew = 0;
			rt_printf("value: %d \n",valuew);
			rt_printf("value of read: %d \n",valuer);
			ret=write(fdw, &valuew, sizeof(valuew));
		}
		
		rt_task_wait_period(NULL);
	}
	return;
}


int main(int argc, char* argv[])
{
  rt_task_create(&light_task, "tasklight", 0, 50, 0);
  rt_task_start(&light_task, &light, 0);
  
  printf("\nType CTRL-C to end this program\n\n" );
  pause();
}
