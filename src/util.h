/**
 * @file util.h
 * @brief This file contains the functions and variables that are common to all versions. It of course helps avoiding duplicate codes, but it also makes sure that all versions rely on an identical configuration.
 **/

#ifndef UTIL_H_INCLUDED
#define UTIL_H_INCLUDED

/// Number of columns in the temperature arrays
#define COLUMNS 672
/// Number of lines in the temperature arrays
#define ROWS 672
/// Largest permitted change in temperatures
#define MAX_TEMP_ERROR 0.01
/// Maximal number of iterations
#define MAX_NUMBER_OF_ITERATIONS 4000
/// Number of iterations between two printings
#define ITERATION_FREQUENCY 100

/// Temperature grid
double temperature[ROWS+2][COLUMNS+2];
/// Temperature grid from last iteration
double temperature_last[ROWS+2][COLUMNS+2]; 
/// Time taken during the entire simulation, in seconds
double timer_simulation;

/**
 * @brief Initialises the temperatures.
 * @todo Initialises the array "temperature" as well? In case of non-blocking etc... one may encounter a problem of uninitialised values.
 * @details Initialises the temperature_last array, which is used for the first iteration.
 **/
void initialise_temperatures();
/**
 * @brief Prints information used for tracking.
 * @note This function must NOT be altered in ANY WAY.
 * @param[in] iter The iteration at which printing progress.
 **/
void track_progress(int iteration);
/**
 * @brief Begins the timer.
 * @details This function initialises the timer given.
 * @param[out] timer The timer to start.
 **/
void start_timer(double* timer);
/**
 * @brief Ends the timer.
 * @param[inout] timer The timer to stop.
 * @post \p timer contains the time elapsed between the call to start_timer() and stop_timer().
 **/
void stop_timer(double* timer);

#endif