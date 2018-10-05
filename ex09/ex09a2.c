#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <alchemy/sem.h>
#include <rtdm/gpio.h>
#include <math.h>

RT_TASK A_task;
RT_TASK B_task;
RT_TASK A_interrupt;
unsigned long long ts_interrupt_start[10000];
unsigned long long ts_interrupt_end[10000];
unsigned long long time_differences[10000];


void calc_time_diffs() {
	unsigned int n;
	for (n=0; n<10000;n++) {
		unsigned long long start = ts_interrupt_start[n];
		unsigned long long end = ts_interrupt_end[n];
		time_differences[n]=(end - start);
		time_differences[n] = time_differences[n] /2;
	}
}

void write_RTIMES(char * filename, unsigned int number_of_values){
    unsigned int n=0;
    FILE *file;
    file = fopen(filename,"w");
    while (n<number_of_values) {
        fprintf(file,"%u,%llu\n",n,time_differences[n]);
        n++;
    } 
    fclose(file);
  }

long long unsigned calc_average_time(int nsamples){
	unsigned long long average;
	unsigned long long sum=0;
	int i;
	for (i=0; i< nsamples;i++){
		sum+= time_differences[i];
	}
	average = (unsigned long long) (sum / nsamples);
	return average;
}

void measureTime() {
	unsigned int nsamples=10000;
	calc_time_diffs();
	write_RTIMES("time_interrupt.csv",nsamples);
	unsigned long long average;
    average=calc_average_time(nsamples);
    printf("average  %llu\n", average);
}

void interruptmakerA(void *arg) {
	rt_task_set_periodic(NULL, TM_NOW, (RTIME) pow(10,5));
	int ret, value, i;
	int fdw4  = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	ret=ioctl(fdw4, GPIO_RTIOC_DIR_OUT, &value);
	value=1;
	ret=write(fdw4, &value, sizeof(value));
	for (i=0; i<10000;i++){
		value = 0;
		ret=write(fdw4, &value, sizeof(value));
		value = 1;
		ts_interrupt_start[i]= (int) rt_timer_read();
		rt_task_wait_period(NULL);
		ret=write(fdw4, &value, sizeof(value));
	}
}

void interruptA(void *arg) {
	int ret, value;
	int fdr13 = open("/dev/rtdm/pinctrl-bcm2835/gpio13",O_RDONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdr13, GPIO_RTIOC_IRQEN, &xeno_trigger);
	int n;
	for (n=0;n<10000;n++) {
		ret = read(fdr13, &value, sizeof(value));
		ts_interrupt_end[n]= (int) rt_timer_read();
	}
	measureTime();
}

void interruptB(void *arg) {
	int ret, valueread, value;
	int fdr13 = open("/dev/rtdm/pinctrl-bcm2835/gpio13",O_RDONLY);
	int fdw4  = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdr13, GPIO_RTIOC_IRQEN, &xeno_trigger);
	ret=ioctl(fdw4, GPIO_RTIOC_DIR_OUT, &value);
	value=1;
	ret=write(fdw4, &value, sizeof(value));
	while(1) {
		ret = read(fdr13, &valueread, sizeof(valueread));
		value = 0;
		ret=write(fdw4, &value, sizeof(value));
		value = 1;
		ret=write(fdw4, &value, sizeof(value));
	}
}


int main(int argc, char* argv[])
{
  unsigned int nsamples=10000;
  
	RTIME *time_diff;
	time_diff = calloc(nsamples, sizeof(RTIME));
	rt_task_create(&A_task, "A-task", 0, 50, 0);
	rt_task_create(&B_task, "B-task", 0, 50, 0);
	rt_task_create(&A_interrupt, "A-interrupt", 0, 30, 0);
	rt_task_start(&A_task, &interruptA, 0); //comment to change to B
	rt_task_start(&A_interrupt, &interruptmakerA, 0); //Uncomment to change to B
	//rt_task_start(&B_task, &interruptB, 0); //Uncomment to change to B
	
    printf("\nType CTRL-C to end this program\n\n" );
    pause();
}