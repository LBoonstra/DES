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
	int valuer,ret, valuew, value, count_interrupts;
	count_interrupts=0;
	int fdr  = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_RDONLY|O_NONBLOCK);
	int fdw  = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_WRONLY);
	int fdr23 = open("/dev/rtdm/pinctrl-bcm2835/gpio23",O_RDONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdr, GPIO_RTIOC_DIR_IN);
	ret=ioctl(fdr23, GPIO_RTIOC_IRQEN, &xeno_trigger);
	ret=ioctl(fdw, GPIO_RTIOC_DIR_OUT, &valuew);
	//valuer= 0;
	while(1){
		ret = read(fdr23, &value, sizeof(value));
		ret=read(fdr, &valuer, sizeof(valuer));
		count_interrupts+=1;
		rt_printf("counter : %d \n",count_interrupts);
		if (valuer == 0){
			valuew = 1;
			ret=write(fdw, &valuew, sizeof(valuew));
		}
		else{
			valuew = 0;
			ret=write(fdw, &valuew, sizeof(valuew));
		}
	}
	return;
}


int main(int argc, char* argv[])
{
  rt_task_create(&light_task, "tasklight", 0, 50, 0);
  rt_printf("Starting task. Press the button to turn the light on and off. \n");
  rt_task_start(&light_task, &light, 0);
  
  printf("\nType CTRL-C to end this program\n\n" );
  pause();
}
