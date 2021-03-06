#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <math.h>

RT_TASK timer_task;
unsigned long long time_samples[10000];
unsigned long long time_differences[9999];

void calc_time_diffs() {
	unsigned int n;
	for (n=1; n<10000;n++) {
		time_differences[n-1]=time_samples[n]-time_samples[n-1];
	}
}

void write_RTIMES(char * filename, unsigned int number_of_values){
    unsigned int n=0;
    FILE *file;
    file = fopen(filename,"w");
    while (n<number_of_values-1) {
        fprintf(file,"%u,%llu\n",n,time_differences[n]);
        n++;
    } 
    fclose(file);
  }

long long unsigned calc_average_time(int nsamples){
	unsigned long long average;
	unsigned long long sum=0;
	int i;
	for (i=0; i< nsamples-1;i++){
		sum+= time_differences[i];
	}
	average = (unsigned long long) (sum / nsamples);
	return average;
}

void measureTime(void *arg) {
	unsigned int nsamples=10000;
	RTIME test;
	rt_task_set_periodic(NULL, TM_NOW, (RTIME) pow(10,5));
	int n;
	for (n=0;n<10000;n++) {
		time_samples[n]= (int) rt_timer_read();
		rt_task_wait_period(NULL);
	}
	calc_time_diffs();
	write_RTIMES("time_diff.csv",nsamples);
	unsigned long long average;
    average=calc_average_time(nsamples);
    printf("average  %llu\n", average);
}

int main(int argc, char* argv[])
{
  unsigned int nsamples=10000;
  
	RTIME *time_diff;
	time_diff = calloc(nsamples, sizeof(RTIME));
	rt_task_create(&timer_task, "timer-task", 0, 50, 0);
	rt_task_start(&timer_task, &measureTime, 0);
  
    printf("\nType CTRL-C to end this program\n\n" );
    pause();
}
