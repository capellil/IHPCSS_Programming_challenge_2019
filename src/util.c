/**
 * @file util.c
 **/

#include "util.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h> // gettimeofday
#include <string.h> // memcpy

void initialise_temperatures()
{
	//////////////////////////////////////
	// Previous iteration temperatures //
	////////////////////////////////////
	int i, j;

	// Default all values to 0.
	for(i = 0; i <= ROWS+1; i++)
	{
		for(j = 0; j <= COLUMNS+1; j++)
		{
			temperature_last[i][j] = 0.0;
		}
	}

	// NOTE: these boundary conditions never change throughout the run

	// Set left side to 0 and right to a linear increase
	for(i = 0; i <= ROWS+1; i++)
	{
		temperature_last[i][0] = 0.0;
		temperature_last[i][COLUMNS+1] = (100.0/ROWS)*i;
	}

	// Set top to 0 and bottom to linear increase
	for(j = 0; j <= COLUMNS+1; j++)
	{
		temperature_last[0][j] = 0.0;
		temperature_last[ROWS+1][j] = (100.0/COLUMNS)*j;
	}

	/////////////////////////////////////
	// Current iteration temperatures //
	///////////////////////////////////
	memcpy(temperature, temperature_last, sizeof(double) * (ROWS + 2) * (COLUMNS + 2));
}

void track_progress(int iteration)
{
	int i;
	int start_row = ROWS-5;
	int end_row = ROWS;
	if(iteration == 100)
	{
		printf("ITERATION NUMBER");
		for(i = start_row; i <= end_row; i++)
		{
			printf(" | [%5d,%5d]", i, i);
		}
		printf("\n");
		printf("----------------");
		for(i = start_row; i <= end_row; i++)
		{
			printf("-+--------------");
		}
		printf("\n");
	}
	printf("ITERATION %6d", iteration);
	for(i = start_row; i <= end_row; i++)
	{
		printf(" |         %2.2f", temperature[i][i]);
	}
	printf("\n");
}

void print_summary(int iteration, double dt, double timer_simulation)
{
	printf("\nVersion run: %s.\n", VERSION_RUN);
	printf("Max error at iteration %d was %.15f\n", iteration, dt);
	printf("Total time was %.1f seconds.\n", timer_simulation);
}

void start_timer(double* timer)
{
	struct timeval temp_timer;
	gettimeofday(&temp_timer,NULL);
	*timer = (temp_timer.tv_sec + temp_timer.tv_usec/1000000);
}

void stop_timer(double* timer)
{
	struct timeval temp_timer;
	gettimeofday(&temp_timer,NULL);
	*timer = (temp_timer.tv_sec + temp_timer.tv_usec/1000000) - *timer;
}