#include <stdio.h>
#include <signal.h>
#include <unistd.h>

#include <alchemy/task.h>
#include <alchemy/timer.h>
#include <alchemy/sem.h>

#define ITER 3

static RT_TASK  t1;
static RT_TASK  t2;
static RT_TASK  t3;
static RT_TASK  t4;
static RT_TASK  t5;
static RT_TASK  t6;

static RT_SEM decreaser;
static RT_SEM increaser;
static RT_SEM wait;

int global = 1;

void taskOne(void *arg)
{
    int i;
	rt_sem_p(&wait, (RTIME) 0);
    for (i=0; i < ITER; i++) {
		rt_sem_p(&increaser, (RTIME) 0);
        printf("I am taskOne and global = %d................\n", ++global);
		rt_sem_v(&decreaser);
    }
}

void taskTwo(void *arg)
{
    int i;
	rt_sem_p(&wait, (RTIME) 0);
    for (i=0; i < ITER; i++) {
		rt_sem_p(&decreaser, (RTIME) 0);
        printf("I am taskTwo and global = %d----------------\n", --global);
		rt_sem_v(&increaser);
    }
}

void taskThree(void *arg)
{
    int i;
	rt_sem_p(&wait, (RTIME) 0);
    for (i=0; i < ITER; i++) {
		rt_sem_p(&increaser, (RTIME) 0);
        printf("I am taskThree and global = %d................\n", ++global);
		rt_sem_v(&decreaser);
    }
}

void taskFour(void *arg)
{
    int i;
	rt_sem_p(&wait, (RTIME) 0);
    for (i=0; i < ITER; i++) {
		rt_sem_p(&decreaser, (RTIME) 0);
        printf("I am taskFour and global = %d----------------\n", --global);
		rt_sem_v(&increaser);
    }
}

void taskFive(void *arg)
{
    int i;
	rt_sem_p(&wait, (RTIME) 0);
    for (i=0; i < ITER; i++) {
		rt_sem_p(&increaser, (RTIME) 0);
        printf("I am taskFive and global = %d................\n", ++global);
		rt_sem_v(&decreaser);
    }
}

void taskSix(void *arg)
{
    int i;
	rt_sem_p(&wait, (RTIME) 0);
    for (i=0; i < ITER; i++) {
		rt_sem_p(&decreaser, (RTIME) 0);
        printf("I am taskSix and global = %d----------------\n", --global);
		rt_sem_v(&increaser);
    }
}

int main(int argc, char* argv[]) {
	
	rt_sem_create(&decreaser, "Decreaser",1, S_FIFO);
	rt_sem_create(&increaser, "Increaser",1, S_FIFO);
	if (global>0) {
		rt_sem_p(&increaser, (RTIME) 0);
	}
	else {
		rt_sem_p(&decreaser, (RTIME) 0);
	}
	rt_sem_create(&wait, "Waiter", 0, S_FIFO);
    rt_task_create(&t1, "task1", 0, 1, 0);
    rt_task_create(&t2, "task2", 0, 1, 0);
	rt_task_create(&t3, "task3", 0, 1, 0);
    rt_task_create(&t4, "task4", 0, 1, 0);
	rt_task_create(&t5, "task5", 0, 1, 0);
    rt_task_create(&t6, "task6", 0, 1, 0);
    rt_task_start(&t1, &taskOne, 0);
    rt_task_start(&t2, &taskTwo, 0);
	rt_task_start(&t3, &taskThree, 0);
    rt_task_start(&t4, &taskFour, 0);
	rt_task_start(&t5, &taskFive, 0);
    rt_task_start(&t6, &taskSix, 0);
	rt_sem_broadcast(&wait);
    return 0;
}
