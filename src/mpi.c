/**
 * @file mpi.c
 * @brief Contains the MPI version of Laplace.
 * @note This code was originaly written by John Urbanic for PSC 2014, later modified by Ludovic Capelli.
 * @author John Urbanic
 * @author Ludovic Capelli
 **/

#include <stdio.h> // printf
#include <stdlib.h> // EXIT_FAILURE
#include <math.h> // fabs
#include <mpi.h> // MPI_*
#include "util.h"  

/**
 * @brief Runs the experiment.
 * @details The variables "temperature" and "temperature_last" are two arrays of doubles declared in util.h.
 * @pre The macro 'ROWS' contains the number of rows (excluding boundaries) per MPI process. It is a define passed as a compilation flag, see makefile.
 * @pre The macro 'COLUMNS' contains the number of columns (excluding boundaries). It is a define passed as a compilation flag, see makefile.
 **/
int main(int argc, char *argv[])
{
    int iteration = 0;
    // Temperature change for our MPI process
    double dt;
    // Temperature change across all MPI processes
    double dt_global = 100;
    // The number of MPI processes in total
    int comm_size;
    // The rank of my MPI process
    int my_rank;
    // Communication tags
    const int DOWN = 100;
    const int UP = 101 ;
    // Status returned by MPI calls
    MPI_Status status;

    // The usual MPI startup routines
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_size);

    if(VERSION_RUN == "mpi_small" && comm_size != 4)
    {
        printf("The small version is meant to be run with 4 MPI processes, not %d.\n", comm_size);
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }
    else if(VERSION_RUN == "mpi_big" && comm_size != 120)
    {
        printf("The big version is meant to be run with 120 MPI processes, not %d.\n", comm_size);
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }

    if(my_rank == 0)
    {
        printf("Running on %d MPI processes\n\n", comm_size);
    }

    // Initialise temperatures and temperature_last including boundary conditions
    initialise_temperatures();

    ///////////////////////////////////
    // -- Code from here is timed -- //
    ///////////////////////////////////
    if(my_rank == 0)
    {
        start_timer(&timer_simulation);
    }

    while(dt_global > MAX_TEMP_ERROR && iteration <= MAX_NUMBER_OF_ITERATIONS)
    {
        iteration++;

        // Main calculation: average my four neighbours
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

        //////////////////////
        // HALO SWAP PHASE //
        ////////////////////

        // If we are not the last MPI process, we have a bottom neighbour
        if(my_rank != comm_size-1)
        {             //unless we are bottom PE
            MPI_Send(&temperature[ROWS][1], COLUMNS, MPI_DOUBLE, my_rank+1, DOWN, MPI_COMM_WORLD);
        }

        // If we are not the first MPI process, we have a top neighbour
        if(my_rank != 0)
        {
            // We receive the bottom row from that neighbour into our top halo
            MPI_Recv(&temperature_last[0][1], COLUMNS, MPI_DOUBLE, my_rank-1, DOWN, MPI_COMM_WORLD, &status);
        }

        // If we are not the first MPI process, we have a top neighbour
        if(my_rank != 0)
        {
            // Send out top row to our top neighbour
            MPI_Send(&temperature[1][1], COLUMNS, MPI_DOUBLE, my_rank-1, UP, MPI_COMM_WORLD);
        }

        // If we are not the last MPI process, we have a bottom neighbour
        if(my_rank != comm_size-1)
        {   
            // We receive the top row from that neighbour into our bottom halo
            MPI_Recv(&temperature_last[ROWS+1][1], COLUMNS, MPI_DOUBLE, my_rank+1, UP, MPI_COMM_WORLD, &status);
        }

        //////////////////////////////////////
        // FIND MAXIMAL TEMPERATURE CHANGE //
        ////////////////////////////////////
        dt = 0.0;

        for(unsigned int i = 1; i <= ROWS; i++)
        {
            for(unsigned int j = 1; j <= COLUMNS; j++)
            {
    	        dt = fmax(fabs(temperature[i][j]-temperature_last[i][j]), dt);
    	        temperature_last[i][j] = temperature[i][j];
            }
        }

        // We know our temperature delta, we now need to sum it with that of other MPI processes
        MPI_Reduce(&dt, &dt_global, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
        MPI_Bcast(&dt_global, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

        // Periodically print test values
        if((iteration % PRINT_FREQUENCY) == 0)
        {
            if(my_rank == comm_size - 1)
            {
                track_progress(iteration);
    	    }
        }
    }

    // Slightly more accurate timing and cleaner output 
    MPI_Barrier(MPI_COMM_WORLD);

    /////////////////////////////////////////////
    // -- Code from here is no longer timed -- //
    /////////////////////////////////////////////
    if(my_rank == 0)
    {
        stop_timer(&timer_simulation);
        print_summary(iteration, dt_global, timer_simulation);
    }

    MPI_Finalize();
}