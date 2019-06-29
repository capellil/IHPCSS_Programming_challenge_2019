!> @file util.h
!> @brief This file contains the functions and variables that are common to all versions. It of course helps avoiding duplicate codes, but it also makes sure that all versions rely on an identical configuration.
MODULE util
    !> Largest permitted change in temp
    REAL, PARAMETER :: MAX_TEMP_ERROR = 0.01
    !> Max number of iterations.
    INTEGER, PARAMETER :: MAX_NUMBER_OF_ITERATIONS = 4000
    !> Number of iterations between two summary printings
    INTEGER, PARAMETER :: PRINT_FREQUENCY = 100
CONTAINS
    !> @brief Initialises the temperatures.
    !> @details Initialises the arrays temperature and temperature_last with the original temperature grid.
    !> @note This function must NOT be altered in ANY WAY.
    SUBROUTINE initialise_temperatures(temperature, temperature_last)
        IMPLICIT NONE

        INTEGER :: i,j
        REAL*8, DIMENSION(0:ROWS+1,0:COLUMNS+1) :: temperature, temperature_last

        !//////////////////////////////////////
        !// Previous iteration temperatures //
        !////////////////////////////////////

        ! Default all values to 0.
        temperature_last = 0.0

        ! NOTE: these boundary conditions never change throughout run

        ! Set left side to 0 and right to linear increase
        DO i = 0, ROWS + 1
         temperature_last(i,0) = 0.0
         temperature_last(i,COLUMNS+1) = (100.0/ROWS) * i
        ENDDO

        ! Set top to 0 and bottom to linear increase
        DO j = 0, COLUMNS + 1
         temperature_last(0,j) = 0.0
         temperature_last(ROWS+1,j) = ((100.0)/COLUMNS) * j
        ENDDO
        
        !/////////////////////////////////////
        !// Current iteration temperatures //
        !///////////////////////////////////
        temperature = temperature_last

    END SUBROUTINE initialise_temperatures

    !> @brief Prints information used for tracking.
    !> @param[in] iter The iteration at which printing progress.
    !> @note This function must NOT be altered in ANY WAY.
    SUBROUTINE track_progress(iter, temperature)
        IMPLICIT NONE

        INTEGER :: i,iter
        INTEGER, PARAMETER :: number_of_cells = 6
        REAL*8, DIMENSION(0:ROWS+1,0:COLUMNS+1) :: temperature

        IF (iter .eq. 100) THEN
            WRITE (*, '(A)', advance="no"), "ITERATION NUMBER"
            DO i = number_of_cells, 1, -1
                WRITE (*, '(A, I5, A, I5, A)', advance="no"), " | [", ROWS_GLOBAL-i, ",", COLUMNS-i, "]"
            ENDDO
            WRITE (*, '(/, A)', advance="no"), "----------------"
            DO i = number_of_cells, 1, -1
                WRITE (*, '(A)', advance="no"), "-+--------------"
            ENDDO
            WRITE (*, '(A)'), " "
        ENDIF
        WRITE (*, '(A, I6)', advance="no"), "ITERATION ", iter
        DO i = number_of_cells, 1, -1
            WRITE (*, '(A, F5.2)', advance="no"), " |         ", temperature(ROWS-i+1,COLUMNS-i+1)
        ENDDO
        WRITE (*, '(A)'), " "
    END SUBROUTINE track_progress

    !> @brief Prints the time needed to complete the simulation as well as debugging information.
    !> @details In addition to printing the total simulation time, it also prints the iteration at which convergence was reached as well as the last temperature delta observed. The first one is to evaluate performance while the last two help check program correctness.
    !> @param[in] iteration The iteration at which the simulation stopped.
    !> @param[in] dt The temperature delta when the simulation stopped.
    !> @param[in] timer_simulation The timer containing the amount of time elapsed during the simulation calculations.
    !> @note This function must NOT be altered in ANY WAY.
    SUBROUTINE print_summary(iteration, dt, timer_simulation)
        INTEGER :: iteration
        DOUBLE PRECISION :: dt
        REAL :: timer_simulation
        WRITE (*, '(/, A)'), "Language used: FORTRAN."
        WRITE (*, '(A, A, A)'), "Version run: ", VERSION_RUN, "."
        WRITE (*,  '(A, I0, A, F20.18)'), "The maximum temperature change was reached at iteration ", iteration, " was ", dt
        WRITE (*, '(A, F0.1, A)'), "Total time was ", timer_simulation, " seconds."
    END SUBROUTINE print_summary

    !> @brief Begins the timer.
    !> @details This function initialises the timer given.
    !> @param[out] timer The timer to start.
    !> @note This function must NOT be altered in ANY WAY.
    SUBROUTINE start_timer(timer)
        REAL :: timer
        CALL cpu_time(timer)
    END SUBROUTINE

    !> @brief Ends the timer.
    !> @param[inout] timer The timer to stop.
    !> @post \p timer contains the time elapsed between the call to start_timer() and stop_timer().
    !> @note This function must NOT be altered in ANY WAY.
    SUBROUTINE stop_timer(timer)
        REAL :: timer, temp
        CALL cpu_time(temp)
        timer = temp - timer
    END SUBROUTINE
END MODULE
