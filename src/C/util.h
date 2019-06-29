/**
 * @file util.h
 * @brief This file contains the functions and variables that are common to all versions. It of course helps avoiding duplicate codes, but it also makes sure that all versions rely on an identical configuration.
 **/

#ifndef UTIL_H_INCLUDED
#define UTIL_H_INCLUDED

/// Largest permitted change in temp
#define MAX_TEMP_ERROR 0.01
/// Max number of iterations.
#define MAX_NUMBER_OF_ITERATIONS 4000
/// Number of iterations between two summary printings
#define PRINT_FREQUENCY 100

/// Temperature grid.
double temperature[ROWS+2][COLUMNS+2];
/// Temperature grid from last iteration
double temperature_last[ROWS+2][COLUMNS+2]; 
/// Time taken during the entire simulation, in seconds
double timer_simulation;

/**
 * @brief Initialises the temperatures.
 * @details Initialises the arrays temperature and temperature_last with the original temperature grid.
 * @note This function must NOT be altered in ANY WAY.
 **/
void initialise_temperatures();
/**
 * @brief Prints information used for tracking.
 * @param[in] iter The iteration at which printing progress.
 * @note This function must NOT be altered in ANY WAY.
 **/
void track_progress(int iter);
/**
 * @brief Prints the time needed to complete the simulation as well as debugging information.
 * @details In addition to printing the total simulation time, it also prints the iteration at which convergence was reached as well as the last temperature delta observed. The first one is to evaluate performance while the last two help check program correctness.
 * @param[in] iteration The iteration at which the simulation stopped.
 * @param[in] dt The temperature delta when the simulation stopped.
 * @param[in] timer_simulation The timer containing the amount of time elapsed during the simulation calculations.
 * @note This function must NOT be altered in ANY WAY.
 **/
void print_summary(int iteration, double dt, double timer_simulation);
/**
 * @brief Begins the timer.
 * @details This function initialises the timer given.
 * @param[out] timer The timer to start.
 * @note This function must NOT be altered in ANY WAY.
 **/
void start_timer(double* timer);
/**
 * @brief Ends the timer.
 * @param[inout] timer The timer to stop.
 * @post \p timer contains the time elapsed between the call to start_timer() and stop_timer().
 * @note This function must NOT be altered in ANY WAY.
 **/
void stop_timer(double* timer);

#endif