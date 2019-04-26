/**
 * @file util.c
 * @brief The code presented in this file must NOT be modified in any way.
 **/

#include "util.h"

#include <stdio.h>
#include <math.h>
#include <string.h>
#include <sys/time.h>

void initialise_temperatures()
{
	//////////////////////////////////////
	// Previous iteration temperatures //
	////////////////////////////////////

	// Default inner cells to 0.
	for(unsigned int i = 1; i <= ROWS; i++)
	{
		for(unsigned int j = 1; j <= COLUMNS; j++)
		{
			temperature_last[i][j] = 0.0;
		}
	}

	// NOTE: these boundary conditions never change throughout the run

	// Set left side to 0 and right to a linear increase
	for(unsigned int i = 0; i <= ROWS+1; i++)
	{
		temperature_last[i][0] = 0.0;
		temperature_last[i][COLUMNS+1] = (100.0/ROWS)*i;
	}

	// Set top to 0 and bottom to linear increase
	for(unsigned int j = 0; j <= COLUMNS+1; j++)
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
	int start_row = ROWS-5;
	int end_row = ROWS;
	if(iteration == ITERATION_FREQUENCY)
	{
		printf("ITERATION NUMBER");
		for(int i = start_row; i <= end_row; i++)
		{
			printf(" | [%5d,%5d]", i, i);
		}
		printf("\n");
		printf("----------------");
		for(int i = start_row; i <= end_row; i++)
		{
			printf("-+--------------");
		}
		printf("\n");
	}
	printf("ITERATION %6d", iteration);
	for(int i = start_row; i <= end_row; i++)
	{
		printf(" |         %2.2f", temperature[i][i]);
	}
	printf("\n");
}

void start_timer(double* timer)
{
	struct timeval temp_timer;
	gettimeofday(&temp_timer,NULL);
	*timer = (temp_timer.tv_sec + temp_timer.tv_usec/1000000.0);
}

void stop_timer(double* timer)
{
	struct timeval temp_timer;
	gettimeofday(&temp_timer,NULL);
	*timer = (temp_timer.tv_sec + temp_timer.tv_usec/1000000.0) - *timer;
}