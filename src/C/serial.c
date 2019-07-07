/**
 * @file serial.c
 * @brief Contains the serial version of Laplace.
 * @note This code was originaly written by John Urbanic for PSC 2014, later modified by Ludovic Capelli.
 * @author John Urbanic
 * @author Ludovic Capelli
 **/

#include "util.h"
#include <math.h> // fabs
#include <stdlib.h> // EXIT_SUCCESS

/**
 * @brief Runs the experiment.
 * @pre The macro 'ROWS' contains the number of rows (excluding boundaries). It is a define passed as a compilation flag, see makefile.
 * @pre The macro 'COLUMNS' contains the number of columns (excluding boundaries). It is a define passed as a compilation flag, see makefile.
 **/
int main(int argc, char *argv[])
{
	// We indicate that we are not going to use argc.
	(void)argc;
	// We indicate that we are not going to use argv.
	(void)argv;
	// Temperature grid.
	double temperature[ROWS+2][COLUMNS+2];
	// Temperature grid from last iteration
	double temperature_last[ROWS+2][COLUMNS+2]; 
	// Current iteration.
	unsigned int iteration = 0;
	// Largest change in temperature. 
	double dt = 100;

	// Initialise temperatures and temperature_last including boundary conditions
	initialise_temperatures(temperature, temperature_last);	

	///////////////////////////////////
	// -- Code from here is timed -- //
	///////////////////////////////////
	start_timer(&timer_simulation);

	// Do until error is under threshold or until max iterations is reached
	while(dt > MAX_TEMP_ERROR && iteration <= MAX_NUMBER_OF_ITERATIONS)
	{
		iteration++;

		// Reset largest temperature change
		dt = 0.0; 

		// Main calculation: average my four neighbors
		for(unsigned int i = 1; i <= ROWS; i++)
		{
			for(unsigned int j = 1; j <= COLUMNS; j++)
			{
				temperature[i][j] = 0.25 * (temperature_last[i+1][j  ] +
											temperature_last[i-1][j  ] +
											temperature_last[i  ][j+1] +
											temperature_last[i  ][j-1]);
			}
		}

		// Copy grid to old grid for next iteration and find latest dt
		for(unsigned int i = 1; i <= ROWS; i++)
		{
			for(unsigned int j = 1; j <= COLUMNS; j++)
			{
				dt = fmax(fabs(temperature[i][j]-temperature_last[i][j]), dt);
				temperature_last[i][j] = temperature[i][j];
			}
		}

		// Periodically print test values
		if((iteration % PRINT_FREQUENCY) == 0)
		{
 			track_progress(iteration, temperature);
		}
	}

	/////////////////////////////////////////////
	// -- Code from here is no longer timed -- //
	/////////////////////////////////////////////
	stop_timer(&timer_simulation);

	print_summary(iteration, dt, timer_simulation);

	return EXIT_SUCCESS;
}
