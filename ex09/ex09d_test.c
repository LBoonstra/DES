#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <rtdm/gpio.h>
#include <math.h>
#include <alchemy/sem.h>

RT_TASK threeLeft_task;
RT_TASK twoLeft_task;
RT_TASK oneLeft_task;
RT_TASK middle_task;
RT_TASK oneRight_task;
RT_TASK twoRight_task;
RT_TASK threeRight_task;
RT_TASK interrupt_task;
RT_TASK timeshifter_task;
RT_SEM signalSender;

//ADJUST ACCORDING TO 9A BEFORE RUNNING.
static int sensor_interrupted_time = 1658757/7;
static int rotation_time =  83952033/7;
static RTIME time_shift = 0;

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

void threeLeft(void *arg) {
	int ret, value;
	int fdw2 = open("/dev/rtdm/pinctrl-bcm2835/gpio2",O_WRONLY);
	ret=ioctl(fdw2, GPIO_RTIOC_DIR_OUT, &value);
	int fdw9 = open("/dev/rtdm/pinctrl-bcm2835/gpio9",O_WRONLY);
	ret=ioctl(fdw9, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = rotation_time- sensor_interrupted_time*3; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	int fdw3 = open("/dev/rtdm/pinctrl-bcm2835/gpio3",O_WRONLY);
	ret=ioctl(fdw3, GPIO_RTIOC_DIR_OUT, &value);
	int fdw10 = open("/dev/rtdm/pinctrl-bcm2835/gpio10",O_WRONLY);
	ret=ioctl(fdw10, GPIO_RTIOC_DIR_OUT, &value);
	value=0;
	ret = write(fdw2, &value, sizeof(value));
	ret = write(fdw9, &value, sizeof(value));
	ret = write(fdw3, &value, sizeof(value));
	ret = write(fdw10, &value, sizeof(value));
	int fdw4 = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	ret=ioctl(fdw4, GPIO_RTIOC_DIR_OUT, &value);
	int fdw22 = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_WRONLY);
	ret=ioctl(fdw22, GPIO_RTIOC_DIR_OUT, &value);
	ret = write(fdw4, &value, sizeof(value));
	ret = write(fdw22, &value, sizeof(value));
	int fdw17 = open("/dev/rtdm/pinctrl-bcm2835/gpio17",O_WRONLY);
	ret=ioctl(fdw17, GPIO_RTIOC_DIR_OUT, &value);
	int fdw27 = open("/dev/rtdm/pinctrl-bcm2835/gpio27",O_WRONLY);
	ret=ioctl(fdw27, GPIO_RTIOC_DIR_OUT, &value);
	ret = write(fdw17, &value, sizeof(value));
	ret = write(fdw27, &value, sizeof(value));
	
	while(1) {
		int left_over_time;
		rt_sem_p(&signalSender, TM_INFINITE);
		if (period_time + time_shift >= rotation_time){
			left_over_time = period_time + time_shift - rotation_time;
		}
		else{
			left_over_time = period_time + time_shift;
		}
		//rt_task_sleep(left_over_time);
		value=1;
		ret = write(fdw2, &value, sizeof(value));
		ret = write(fdw9, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw3, &value, sizeof(value));
		ret = write(fdw10, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw4, &value, sizeof(value));
		ret = write(fdw22, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw17, &value, sizeof(value));
		ret = write(fdw27, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw2, &value, sizeof(value));
		ret = write(fdw9, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw3, &value, sizeof(value));
		ret = write(fdw10, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw4, &value, sizeof(value));
		ret = write(fdw22, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw17, &value, sizeof(value));
		ret = write(fdw27, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=1;
		rt_task_sleep(sleep_time);
		ret = write(fdw4, &value, sizeof(value));
		ret = write(fdw22, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw3, &value, sizeof(value));
		ret = write(fdw10, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw2, &value, sizeof(value));
		ret = write(fdw9, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw2, &value, sizeof(value));
		ret = write(fdw9, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw3, &value, sizeof(value));
		ret = write(fdw10, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		ret = write(fdw4, &value, sizeof(value));
		ret = write(fdw22, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		
	}
}

void twoLeft(void *arg) {
	int ret, value;
	int fdw3 = open("/dev/rtdm/pinctrl-bcm2835/gpio3",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw3, GPIO_RTIOC_DIR_OUT, &value);
	int fdw10 = open("/dev/rtdm/pinctrl-bcm2835/gpio10",O_WRONLY);
	ret=ioctl(fdw10, GPIO_RTIOC_DIR_OUT, &value);
	int period_time =  rotation_time-sensor_interrupted_time*2; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw3, &value, sizeof(value));
	ret = write(fdw10, &value, sizeof(value));
	while(1) {
		int left_over_time;
		rt_sem_p(&signalSender, TM_INFINITE);
		if (period_time + time_shift >= rotation_time){
			left_over_time = period_time + time_shift - rotation_time;
		}
		else{
			left_over_time = period_time + time_shift;
		}
		rt_task_sleep(left_over_time);
		value=1;
		ret = write(fdw3, &value, sizeof(value));
		ret = write(fdw10, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw3, &value, sizeof(value));
		ret = write(fdw10, &value, sizeof(value));
	}
}

void oneLeft(void *arg) {
	int ret, value;
	int fdw4 = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw4, GPIO_RTIOC_DIR_OUT, &value);
	int fdw22 = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_WRONLY);
	ret=ioctl(fdw22, GPIO_RTIOC_DIR_OUT, &value);
	int period_time =  rotation_time-sensor_interrupted_time; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw4, &value, sizeof(value));
	ret = write(fdw22, &value, sizeof(value));
	while(1) {
		int left_over_time;
		rt_sem_p(&signalSender, TM_INFINITE);
		if (period_time + time_shift >= rotation_time){
			left_over_time = period_time + time_shift - rotation_time;
		}
		else{
			left_over_time = period_time + time_shift;
		}
		rt_task_sleep(left_over_time);
		value=1;
		ret = write(fdw4, &value, sizeof(value));
		ret = write(fdw22, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw4, &value, sizeof(value));
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
	int period_time =  0; 
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw17, &value, sizeof(value));
	ret = write(fdw27, &value, sizeof(value));
	while(1) {
		int left_over_time;
		rt_sem_p(&signalSender, TM_INFINITE);
		if (period_time + time_shift >= rotation_time){
			left_over_time = period_time + time_shift - rotation_time;
		}
		else{
			left_over_time = period_time + time_shift;
		}
		rt_task_sleep(left_over_time);
		value=1;
		ret = write(fdw17, &value, sizeof(value));
		ret = write(fdw27, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw17, &value, sizeof(value));
		ret = write(fdw27, &value, sizeof(value));
	}
}

void oneRight(void *arg) {
	int ret, value;
	int fdw4 = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw4, GPIO_RTIOC_DIR_OUT, &value);
	int fdw22 = open("/dev/rtdm/pinctrl-bcm2835/gpio22",O_WRONLY);
	ret=ioctl(fdw22, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = sensor_interrupted_time; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw4, &value, sizeof(value));
	ret = write(fdw22, &value, sizeof(value));
	while(1) {
		int left_over_time;
		rt_sem_p(&signalSender, TM_INFINITE);
		if (period_time + time_shift >= rotation_time){
			left_over_time = period_time + time_shift - rotation_time;
		}
		else{
			left_over_time = period_time + time_shift;
		}
		rt_task_sleep(left_over_time);
		value=1;
		ret = write(fdw4, &value, sizeof(value));
		ret = write(fdw22, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw4, &value, sizeof(value));
		ret = write(fdw22, &value, sizeof(value));
	}
}

void twoRight(void *arg) {
	int ret, value;
	int fdw3 = open("/dev/rtdm/pinctrl-bcm2835/gpio3",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw3, GPIO_RTIOC_DIR_OUT, &value);
	int fdw10 = open("/dev/rtdm/pinctrl-bcm2835/gpio10",O_WRONLY);
	ret=ioctl(fdw10, GPIO_RTIOC_DIR_OUT, &value);
	int period_time =  sensor_interrupted_time*2; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw3, &value, sizeof(value));
	ret = write(fdw10, &value, sizeof(value));
	while(1) {
		int left_over_time;
		rt_sem_p(&signalSender, TM_INFINITE);
		if (period_time + time_shift >= rotation_time){
			left_over_time = period_time + time_shift - rotation_time;
		}
		else{
			left_over_time = period_time + time_shift;
		}
		rt_task_sleep(left_over_time);
		value=1;
		ret = write(fdw3, &value, sizeof(value));
		ret = write(fdw10, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw3, &value, sizeof(value));
		ret = write(fdw10, &value, sizeof(value));
	}
}

void threeRight(void *arg) {
	int ret, value;
	int fdw2 = open("/dev/rtdm/pinctrl-bcm2835/gpio2",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdw2, GPIO_RTIOC_DIR_OUT, &value);
	int fdw9 = open("/dev/rtdm/pinctrl-bcm2835/gpio9",O_WRONLY);
	ret=ioctl(fdw9, GPIO_RTIOC_DIR_OUT, &value);
	int period_time = sensor_interrupted_time*3; //Adjust on the result of 9a on average sensor
	int sleep_time = sensor_interrupted_time/2;
	value=0;
	ret = write(fdw2, &value, sizeof(value));
	ret = write(fdw9, &value, sizeof(value));
	while(1) {
		int left_over_time;
		rt_sem_p(&signalSender, TM_INFINITE);
		if (period_time + time_shift >= rotation_time){
			left_over_time = period_time + time_shift - rotation_time;
		}
		else{
			left_over_time = period_time + time_shift;
		}
		rt_task_sleep(left_over_time);
		value=1;
		ret = write(fdw2, &value, sizeof(value));
		ret = write(fdw9, &value, sizeof(value));
		rt_task_sleep(sleep_time);
		value=0;
		ret = write(fdw2, &value, sizeof(value));
		ret = write(fdw9, &value, sizeof(value));
	}
}

void shiftTime(void *arg){
	rt_task_set_periodic(NULL, TM_NOW, (RTIME) pow(10,9));
	double rotation_second = rotation_time/60;
	int counter = 1;
	while(1){
		rt_task_wait_period(NULL);
		if (counter == 60){
			counter = 1;
			time_shift =0;
		}
		else{
			counter+=1;
			time_shift+=rotation_second;
		}
	}
}

int main(int argc, char* argv[])
{
	rt_sem_create(&signalSender, "SignalWaiter", 0, S_PRIO);
	RTIME *time_diff;
		
	rt_task_create(&threeLeft_task, "threeLeft_task", 0, 50, 0);
	rt_task_start(&threeLeft_task, &threeLeft, 0);
	
	rt_task_create(&interrupt_task, "interrupt_handler", 0, 99, 0);
	rt_task_start(&interrupt_task, &interruptHandler, 0);
	
	rt_task_create(&timeshifter_task, "Time shifter", 0, 60, 0);
	rt_task_start(&timeshifter_task, &shiftTime, 0);
  
    printf("\n Ready to start program. Turn on wheel. Type CTRL-C to end this program\n\n" );
    pause();
}