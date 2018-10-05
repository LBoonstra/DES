#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <rtdm/gpio.h>
#include <math.h>

int amount_samples=1000;

RT_TASK timer_task;
unsigned long long time_samples_falling[1000];
unsigned long long time_samples_rising[1000];
unsigned long long time_differences_rotation[1000-1];
unsigned long long time_differences_sensor[1000];

void calc_time_diffs() {
	unsigned int n;
	for (n=1; n<amount_samples;n++) {
		time_differences_rotation[n-1]=time_samples_falling[n]-time_samples_falling[n-1];
	}
	for (n=0;n<amount_samples;n++) {
		time_differences_sensor[n]=time_samples_rising[n]-time_samples_falling[n];
	}
}

void write_RTIMES(char * filename, char * filename2, unsigned int number_of_values){
    unsigned int n=0;
    FILE *file, *file2;
    file = fopen(filename,"w");
	file2 = fopen(filename2,"w");
    while (n<number_of_values-1) {
        fprintf(file,"%u,%llu\n",n,time_differences_rotation[n]);
        n++;
    } 
	fclose(file);
	n=0;
	while (n<number_of_values) {
        fprintf(file2,"%u,%llu\n",n,time_differences_sensor[n]);
        n++;
    } 
	fclose(file2);
  }

void calc_average_time(int nsamples){
	unsigned long long average, averagefr, rotationPerMinute;
	unsigned long long sumfr=0;
	unsigned long long sum=0;
	int i;
	printf("Hi  %llu\n", time_differences_rotation[0]);
	for (i=0; i< nsamples-1;i++){
		sum+= time_differences_rotation[i];
	}
	average = (unsigned long long) (sum / (nsamples-1));
	printf("average rotation length  %llu\n", average);
	rotationPerMinute = (unsigned long long) 6*pow(10,10) / average;
	printf("Rotations per minute  %llu\n", rotationPerMinute);
	for (i=0; i< nsamples;i++){
		sumfr+= time_differences_sensor[i];
	}
	averagefr = (unsigned long long) (sumfr / (nsamples));
	printf("average sensor  %llu\n", averagefr);
}

void measureTime(void *arg) {
	unsigned int nsamples=amount_samples;
	int ret, value;
	int fdr13 = open("/dev/rtdm/pinctrl-bcm2835/gpio23",O_RDONLY);
	int xeno_trigger=GPIO_TRIGGER_EDGE_FALLING|GPIO_TRIGGER_EDGE_RISING;
	ret=ioctl(fdr13, GPIO_RTIOC_IRQEN, &xeno_trigger);
	int n;
	for (n=0; n<amount_samples;n++) {
		ret = read(fdr13, &value, sizeof(value));
		time_samples_falling[n]= (unsigned long long) rt_timer_read();
		ret = read(fdr13, &value, sizeof(value));
		time_samples_rising[n]= (unsigned long long) rt_timer_read();
		
	}
	calc_time_diffs();
	write_RTIMES("time_diff_rotation.csv", "time_diff_sensor.csv",nsamples);
    calc_average_time(nsamples);
}

int main(int argc, char* argv[])
{
  unsigned int nsamples=amount_samples;
  
	RTIME *time_diff;
	time_diff = calloc(nsamples, sizeof(RTIME));
	rt_task_create(&timer_task, "timer-task", 0, 50, 0);
	rt_task_start(&timer_task, &measureTime, 0);
  
    printf("\nType CTRL-C to end this program\n\n" );
    pause();
}
