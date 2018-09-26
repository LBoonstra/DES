#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <math.h>

RT_TASK timer_task;
int time_samples[10000];
int time_differences[9999];

void measureTime(void *arg) {
	RTIME test;
	rt_task_set_periodic(NULL, TM_NOW, (RTIME) pow(10,5));
	int n;
	for (n=0;n<10000;n++) {
		time_samples[n]= (int) rt_timer_read();
		rt_task_wait_period(NULL);
	}
}

void calc_time_diffs(RTIME *time_diff) {
	unsigned int n;
	for (n=1; n<10000;n++) {
		time_differences[n-1]=time_samples[n]-time_samples[n-1];
	}
}

void write_RTIMES(char * filename, unsigned int number_of_values, RTIME *time_values){
    unsigned int n=0;
    FILE *file;
    file = fopen(filename,"w");
    while (n<number_of_values) {
        fprintf(file,"%u,%llu\n",n,time_differences[n]);
        n++;
    } 
    fclose(file);
  }

int main(int argc, char* argv[])
{
  unsigned int nsamples=10000;
  
	RTIME *time_diff;
	time_diff = calloc(nsamples, sizeof(RTIME));
	rt_task_create(&timer_task, "timer-task", 0, 50, 0);
	rt_task_start(&timer_task, &measureTime, 0);
	
    calc_time_diffs(time_diff);
    write_RTIMES("time_diff.csv",nsamples,time_diff);
	//double average;
    //average=calc_average_time(nsamples,time_diff);
    //printf("average  %llu\n", average);
	
	free(time_diff);
  
    //printf("\nType CTRL-C to end this program\n\n" );
    //pause();
}
