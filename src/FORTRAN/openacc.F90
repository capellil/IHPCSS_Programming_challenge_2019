!> @file serial.f90
!> @brief Contains the serial version of Laplace.
!> @note This code was originaly written by John Urbanic for PSC 2014, later modified by Ludovic Capelli.
!> @author John Urbanic
!> @author Ludovic Capelli

!> @brief Runs the experiment.
!> @details The variables "temperature" and "temperature_last" are two arrays of doubles declared in util.h.
!> @pre The macro 'ROWS' contains the number of rows (excluding boundaries). It is a define passed as a compilation flag, see makefile.
!> @pre The macro 'COLUMNS' contains the number of columns (excluding boundaries). It is a define passed as a compilation flag, see makefile.
PROGRAM serial
    USE util
    IMPLICIT NONE

    !> Indexes used in for loops
    INTEGER :: i, j
    !> Current iteration.
    INTEGER :: iteration = 0
    !> Largest change in temperature. 
    DOUBLE PRECISION :: dt = 100.0
    !> Time taken during the entire simulation, in seconds
    REAL :: timer_simulation
    !> Temperature grid.
    REAL*8, DIMENSION(0:ROWS+1,0:COLUMNS+1) :: temperature
    !> Temperature grid from last iteration.
    REAL*8, DIMENSION(0:ROWS+1,0:COLUMNS+1) :: temperature_last

    ! Initialise temperatures and temperature_last including boundary conditions
    CALL initialise_temperatures(temperature, temperature_last)

    !///////////////////////////////////
    !// -- Code from here is timed -- //
    !///////////////////////////////////
    CALL start_timer(timer_simulation)

    ! Do until error is minimal or until maximum steps
    !$acc data copy(temperature_last), create(temperature)
    DO WHILE ( dt > MAX_TEMP_ERROR .and. iteration <= MAX_NUMBER_OF_ITERATIONS)
        iteration = iteration+1

        !$acc kernels
        DO j=1,COLUMNS
            DO i=1,ROWS
                temperature(i,j) = 0.25 * (temperature_last(i+1, j  ) + &
                                           temperature_last(i-1, j  ) + &
                                           temperature_last(i  , j+1) + &
                                           temperature_last(i  , j-1))
            ENDDO
        ENDDO
        !$acc end kernels

        dt=0.0

        ! Copy grid to old grid for next iteration and find max change
        !$acc kernels
        DO j=1,COLUMNS
            DO i=1,ROWS
                dt = max(abs(temperature(i,j) - temperature_last(i,j)), dt)
                temperature_last(i,j) = temperature(i,j)
            ENDDO
        ENDDO
        !$acc end kernels

        ! Periodically print test values
        IF (mod(iteration, PRINT_FREQUENCY) .eq. 0) THEN
            CALL track_progress(iteration, temperature)
        ENDIF
    ENDDO
    !$acc end data

    CALL stop_timer(timer_simulation)

    CALL print_summary(iteration, dt, timer_simulation)
END PROGRAM serial
