/**
 * @file util.c
 **/

#include "util.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h> // gettimeofday
#include <string.h> // memcpy
#ifdef VERSION_RUN_IS_MPI
	#include <mpi.h>
#endif

void initialise_temperatures()
{
	//////////////////////////////////////
	// Previous iteration temperatures //
	////////////////////////////////////
	#ifdef VERSION_RUN_IS_MPI
		// Retrieve my MPI information
		int my_rank;
		MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
		int comm_size;
		MPI_Comm_size(MPI_COMM_WORLD, &comm_size);

	    for(int i = 0; i <= ROWS+1; i++)
	    {
	        for(int j = 0; j <= COLUMNS+1; j++)
	        {
	            temperature_last[i][j] = 0.0;
	        }
	    }

	    // Local boundry condition endpoints
	    double tMin = (my_rank) * 100.0 / comm_size;
	    double tMax = (my_rank+1) * 100.0 / comm_size;

	    // Left and right boundaries
	    for(int i = 0; i <= ROWS+1; i++)
	    {
			temperature_last[i][0] = 0.0;
			temperature_last[i][COLUMNS+1] = tMin + ((tMax-tMin)/ROWS)*i;
	    }

	    // Top boundary (for first MPI process only)
	    if(my_rank == 0)
	    {
			for(int j = 0; j <= COLUMNS+1; j++)
			{
				temperature_last[0][j] = 0.0;
			}
	    }

	    // Bottom boundary (for last MPI process only)
	    if(my_rank == comm_size - 1)
	    {
			for(int j = 0; j <= COLUMNS + 1; j++)
			{
				temperature_last[ROWS+1][j] = (100.0 / COLUMNS) * j;
			}
	    }
	#else
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
	#endif

	/////////////////////////////////////
	// Current iteration temperatures //
	///////////////////////////////////
	memcpy(temperature, temperature_last, sizeof(double) * (ROWS + 2) * (COLUMNS + 2));

	#ifdef VERSION_RUN_IS_MPI
		MPI_Barrier(MPI_COMM_WORLD);
	#endif
}

void track_progress(int iteration)
{
	int number_of_cells = 6;
	if(iteration == 100)
	{
		printf("ITERATION NUMBER");
		for(int i = number_of_cells; i > 0; i--)
		{
			printf(" | [%5d,%5d]", ROWS_GLOBAL-i, COLUMNS-i);
		}
		printf("\n");
		printf("----------------");
		for(int i = number_of_cells; i > 0; i--)
		{
			printf("-+--------------");
		}
		printf("\n");
	}
	printf("ITERATION %6d", iteration);
	for(int i = number_of_cells; i > 0; i--)
	{
		printf(" |         %2.2f", temperature[ROWS-i+1][COLUMNS-i+1]);
	}
	printf("\n");
}

void print_summary(int iteration, double dt, double timer_simulation)
{
	printf("\nVersion run: %s.\n", VERSION_RUN);
	printf("The maximum temperature change was reached at iteration %d was %.18f\n", iteration, dt);
	printf("Total time was %.1f seconds.\n", timer_simulation);
}

void start_timer(double* timer)
{
	#ifdef VERSION_RUN_IS_MPI
		*timer = MPI_Wtime();
	#else
		struct timeval temp_timer;
		gettimeofday(&temp_timer,NULL);
		*timer = (temp_timer.tv_sec + temp_timer.tv_usec/1000000);
	#endif
}

void stop_timer(double* timer)
{
	#ifdef VERSION_RUN_IS_MPI
		*timer = MPI_Wtime() - *timer;
	#else
		struct timeval temp_timer;
		gettimeofday(&temp_timer,NULL);
		*timer = (temp_timer.tv_sec + temp_timer.tv_usec/1000000) - *timer;
	#endif
}