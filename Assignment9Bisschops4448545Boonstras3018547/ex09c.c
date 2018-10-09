#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <rtdm/gpio.h>
#include <math.h>
#include <alchemy/sem.h>
//#include <letters.h>

RT_TASK threeLeftUp_task;
RT_TASK threeLeftDown_task;
RT_TASK twoLeftUp_task;
RT_TASK twoLeftDown_task;
RT_TASK oneLeftUp_task;
RT_TASK oneLeftDown_task;
RT_TASK middle_task;
RT_TASK oneRightUp_task;
RT_TASK oneRightDown_task;
RT_TASK twoRightUp_task;
RT_TASK twoRightDown_task;
RT_TASK threeRightUp_task;
RT_TASK threeRightDown_task;
RT_TASK interrupt_task;

RT_SEM signalSender;

//ADJUST ACCORDING TO 9A BEFORE RUNNING.
static int sensor_interrupted_time = 1664736;
static int rotation_time = 84779669;

void interruptHandler(void *arg) {
	int ret, value;
	int fdr23 = open("/dev/rtdm/pinctrl-bcm2835/gpio23",O_RDONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdr23, GPIO_RTIOC_IRQEN, &xeno_trigger);
	int sleep_time =  sensor_interrupted_time/2; //Adjust on the result of 9a on average sensor
	while(1) {
		ret = read(fdr23, &value, sizeof(value));
		//rt_task_sleep(sleep_time);
		rt_sem_broadcast(&signalSender);
	}

}

void threeLeftUp(void *arg) {
	int ret, value;
	int fdw2 = open("/dev/rtdm/pinctrl-bcm2835/gpio2",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw2, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2- sensor_interrupted_time; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw2, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw2, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw2, &value, sizeof(value));
	}
}

void threeLeftDown(void *arg) {
	int ret, value;
	int fdw9 = open("/dev/rtdm/pinctrl-bcm2835/gpio9",O_WRONLY);
	ret=ioctl(fdw9, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2-sensor_interrupted_time*2; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw9, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw9, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw9, &value, sizeof(value));
	}
}


void twoLeftUp(void *arg) {
	int ret, value;
	int fdw3 = open("/dev/rtdm/pinctrl-bcm2835/gpio3",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw3, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2- sensor_interrupted_time*0.3; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw3, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw3, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw3, &value, sizeof(value));
	}
}

void twoLeftDown(void *arg) {
	int ret, value;
	int fdw10 = open("/dev/rtdm/pinctrl-bcm2835/gpio10",O_WRONLY);
	ret=ioctl(fdw10, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2- sensor_interrupted_time; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw10, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw10, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw10, &value, sizeof(value));
	}
}


void oneLeftUp(void *arg) {
	int ret, value;
	int fdw4 = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw4, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2+ sensor_interrupted_time *0.5; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw4, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw4, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw4, &value, sizeof(value));
	}
}
void oneLeftDown(void *arg) {
	int ret, value;
	int fdw22 = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_WRONLY);
	ret=ioctl(fdw22, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw22, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw22, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw22, &value, sizeof(value));
	}
}

void middle(void *arg) {
	int ret, value;
	int fdw17 = open("/dev/rtdm/pinctrl-bcm2835/gpio17",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw17, GPIO_RTIOC_DIR_OUT, &value);
	int fdw27 = open("/dev/rtdm/pinctrl-bcm2835/gpio27",O_WRONLY);
	ret=ioctl(fdw27, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2+ sensor_interrupted_time;//rotation_time; 
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw17, &value, sizeof(value));
	ret = write(fdw27, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw17, &value, sizeof(value));
		ret = write(fdw27, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw17, &value, sizeof(value));
		ret = write(fdw27, &value, sizeof(value));
	}
}

void oneRightUp(void *arg) {
	int ret, value;
	int fdw4 = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw4, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2+ sensor_interrupted_time*1.5; 
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw4, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw4, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw4, &value, sizeof(value));
	}
}

void oneRightDown(void *arg) {
	int ret, value;
	int fdw22 = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_WRONLY);
	ret=ioctl(fdw22, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2+ sensor_interrupted_time*2; 
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw22, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw22, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw22, &value, sizeof(value));
	}
}

void twoRightUp(void *arg) {
	int ret, value;
	int fdw3 = open("/dev/rtdm/pinctrl-bcm2835/gpio3",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw3, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2+ sensor_interrupted_time*2.3;
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw3, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw3, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw3, &value, sizeof(value));
	}
}
void twoRightDown(void *arg) {
	int ret, value;
	int fdw10 = open("/dev/rtdm/pinctrl-bcm2835/gpio10",O_WRONLY);
	ret=ioctl(fdw10, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2+ sensor_interrupted_time*3; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw10, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw10, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw10, &value, sizeof(value));
	}
}

void threeRightUp(void *arg) {
	int ret, value;
	int fdw2 = open("/dev/rtdm/pinctrl-bcm2835/gpio2",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw2, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2+ sensor_interrupted_time*3; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw2, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw2, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw2, &value, sizeof(value));
	}
}

void threeRightDown(void *arg) {
	int ret, value;
	int fdw9 = open("/dev/rtdm/pinctrl-bcm2835/gpio9",O_WRONLY);
	ret=ioctl(fdw9, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time/2+ sensor_interrupted_time*4; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw9, &value, sizeof(value));
	while(1) {
		rt_sem_p(&signalSender, TM_INFINITE);
		rt_task_sleep(period_time);
		value=1;
		ret = write(fdw9, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw9, &value, sizeof(value));
	}
}

int main(int argc, char* argv[])
{
	rt_sem_create(&signalSender, "SignalWaiter", 0, S_PRIO);
	RTIME *time_diff;
	
	rt_task_create(&threeLeftUp_task, "threeLeft_task", 0, 50, 0);
	rt_task_start(&threeLeftUp_task, &threeLeftUp, 0);
	
	rt_task_create(&threeLeftDown_task, "threeLeft_taskD", 0, 50, 0);
	rt_task_start(&threeLeftDown_task, &threeLeftDown, 0);
	
	rt_task_create(&twoLeftUp_task, "twoLeft_task", 0, 50, 0);
	rt_task_start(&twoLeftUp_task, &twoLeftUp, 0);
	
	rt_task_create(&twoLeftDown_task, "twoLeft_taskD", 0, 50, 0);
	rt_task_start(&twoLeftDown_task, &twoLeftDown, 0);
	
	rt_task_create(&oneLeftUp_task, "oneLeft_task", 0, 50, 0);
	rt_task_start(&oneLeftUp_task, &oneLeftUp, 0);
	
	rt_task_create(&oneLeftDown_task, "oneLeft_taskD", 0, 50, 0);
	rt_task_start(&oneLeftDown_task, &oneLeftDown, 0);
	
	rt_task_create(&middle_task, "middle_task", 0, 50, 0);
	rt_task_start(&middle_task, &middle, 0);
	
	rt_task_create(&oneRightUp_task, "oneRight", 0, 50, 0);
	rt_task_start(&oneRightUp_task, &oneRightUp, 0);
	
	rt_task_create(&oneRightDown_task, "oneRightD", 0, 50, 0);
	rt_task_start(&oneRightDown_task, &oneRightDown, 0);
	
	rt_task_create(&twoRightUp_task, "twoRight", 0, 50, 0);
	rt_task_start(&twoRightUp_task, &twoRightUp, 0);
	
	rt_task_create(&twoRightDown_task, "twoRightD", 0, 50, 0);
	rt_task_start(&twoRightDown_task, &twoRightDown, 0);
	
	rt_task_create(&threeRightUp_task, "threeRight", 0, 50, 0);
	rt_task_start(&threeRightUp_task, &threeRightUp, 0);
	
	rt_task_create(&threeRightDown_task, "threeRightD", 0, 50, 0);
	rt_task_start(&threeRightDown_task, &threeRightDown, 0);
	
	rt_task_create(&interrupt_task, "interrupt_handler", 0, 99, 0);
	rt_task_start(&interrupt_task, &interruptHandler, 0);
  
    printf("\n Ready to start program. Turn on wheel. Type CTRL-C to end this program\n\n" );
    pause();
}