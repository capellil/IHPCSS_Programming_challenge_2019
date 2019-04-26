/**
 * @file serial.c
 * @brief Contains the serial version.
 * @author John Urbanic
 * @author Ludovic Capelli
 **/

#include "util.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/**
 * @brief Runs the experiment.
 **/
int main()
{
	// Used to iterate through rows.
	unsigned int i;
	// Used to iterate through columns.
	unsigned int j;
	// Current iteration.
	unsigned int iteration=1;
	// Largest change in temperature. 
	double dt=100;

	///////////////////////////////////
	// -- Code from here is timed -- //
	///////////////////////////////////
	start_timer(&timer_simulation);

	// Initialise_temperatures Temp_last including boundary conditions
	initialise_temperatures();				   

	// Do until error is under threshold or until max iterations is reached
	while(dt > MAX_TEMP_ERROR && iteration <= MAX_NUMBER_OF_ITERATIONS)
	{
		// Reset largest temperature change
		dt = 0.0; 

		// Main calculation: average my four neighbors
		for(i = 1; i <= ROWS; i++)
		{
			for(j = 1; j <= COLUMNS; j++)
			{
				temperature[i][j] = 0.25 * (temperature_last[i+1][j  ] + temperature_last[i-1][j  ] +
											temperature_last[i  ][j+1] + temperature_last[i  ][j-1]);
			}
		}

		// Copy grid to old grid for next iteration and find latest dt
		for(i = 1; i <= ROWS; i++)
		{
			for(j = 1; j <= COLUMNS; j++)
			{
				dt = fmax(fabs(temperature[i][j]-temperature_last[i][j]), dt);
				temperature_last[i][j] = temperature[i][j];
			}
		}

		// Periodically print test values
		if((iteration % ITERATION_FREQUENCY) == 0)
		{
 			track_progress(iteration);
		}

		iteration++;
	}

	/////////////////////////////////////////////
	// -- Code from here is no longer timed -- //
	/////////////////////////////////////////////
	stop_timer(&timer_simulation);

	printf("\nMax error at iteration %d was %.15f\n", iteration-1, dt);
	printf("Total time was %.1f seconds.\n", timer_simulation);

	return EXIT_SUCCESS;
}
