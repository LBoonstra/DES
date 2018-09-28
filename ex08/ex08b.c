#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <math.h>

RT_TASK A_task;
RT_TASK B_task;
RT_TASK A_interrupt;
unsigned long long ts_interrupt_start[10000];
unsigned long long ts_interrupt_end[10000];
unsigned long long time_differences[10000];

void interruptmakerA(void *arg) {
	rt_task_set_periodic(NULL, TM_NOW, (RTIME) pow(10,5));
	rt_sem_p(&mysync,TM_INFINITE);
	int ret, value,valueh, valuel;
	int fdw4  = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	valueh=1;
	valuel=0;
	ret=write(fdw4, &valueh, sizeof(valueh));
	for (i=0; i<10000;i++){
		ret=write(fdw4, &valuel, sizeof(valuel));
		ts_interrupt_start[n]= (int) rt_timer_read();
		ret=write(fdw4, &valueh, sizeof(valueh));
		rt_task_wait_period(NULL);
	}
}

void interruptA(void *arg) {
	rt_sem_p(&mysync,TM_INFINITE);
	int ret, value, valueh, valuel;
	int fdr13 = open("/dev/rtdm/pinctrl-bcm2835/gpio13",O_RDONLY);
	int fdw4  = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdr13, GPIO_RTIOC_IRQEN, &xeno_trigger);
	valueh=1;
	valuel=0;
	ret=write(fdw4, &valueh, sizeof(valueh));
	int n;
	for (n=0;n<10000;n++) {
		ret = read(fdr13, &value, sizeof(value));
		ts_interrupt_end[n]= (int) rt_timer_read();
	}
	measureTime();
}

void interruptB(void *arg) {
	rt_sem_p(&mysync,TM_INFINITE);
	int ret, value, valueh, valuel;
	int fdr13 = open("/dev/rtdm/pinctrl-bcm2835/gpio13",O_RDONLY);
	int fdw4  = open("/dev/rtdm/pinctrl-bcm2835/gpio4",O_WRONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING;
	ret=ioctl(fdr13, GPIO_RTIOC_IRQEN, &xeno_trigger);
	valueh=1;
	valuel=0;
	ret=write(fdw4, &valueh, sizeof(valueh));
	while(1) {
		ret = read(fdr13, &value, sizeof(value));
		ret=write(fdw4, &valuel, sizeof(valuel));
		ret=write(fdw4, &valueh, sizeof(valueh));
	}
}

void calc_time_diffs() {
	unsigned int n;
	for (n=0; n<10000;n++) {
		time_differences[n]=(ts_interrupt_start[n]-ts_interrupt_end[n])/2;
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

int main(int argc, char* argv[])
{
  unsigned int nsamples=10000;
  
	RTIME *time_diff;
	time_diff = calloc(nsamples, sizeof(RTIME));
	rt_task_create(&A_task, "A-task", 0, 50, 0);
	rt_task_create(&B_task, "B-task", 0, 50, 0);
	rt_task_create(&A_interrupt, "A-interrupt", 0, 50, 0);
	
	rt_task_start(&A_interrupt, interruptmakerA, 0);
	rt_task_start(&A_task, interruptA, 0);
	rt_task_start(&B_task, interruptB, 0);
	//rt_task_start(&timer_task, &measureTime, 0);
  
    printf("\nType CTRL-C to end this program\n\n" );
    pause();
}
