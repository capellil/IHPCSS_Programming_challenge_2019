!> @file serial.f90
!> @brief Contains the MPI version of Laplace.
!> @note This code was originaly written by John Urbanic for PSC 2014, later modified by Ludovic Capelli.
!> @author John Urbanic
!> @author Ludovic Capelli

!> @brief Runs the experiment.
!> @details The variables "temperature" and "temperature_last" are two arrays of doubles declared in util.h.
!> @pre The macro 'ROWS' contains the number of rows (excluding boundaries). It is a define passed as a compilation flag, see makefile.
!> @pre The macro 'COLUMNS' contains the number of columns (excluding boundaries) per MPI process. It is a define passed as a compilation flag, see makefile.
PROGRAM serial
    USE util
    USE mpi
    IMPLICIT NONE

    !> Indexes used in for loops
    INTEGER :: i, j
    !> Current iteration.
    INTEGER :: iteration = 0
    !> Temperature change for our MPI process
    DOUBLE PRECISION :: dt;
    !> Temperature change across all MPI processes
    DOUBLE PRECISION :: dt_global = 100;
    !> Time taken during the entire simulation, in seconds
    REAL :: timer_simulation
    !> Temperature grid.
    DOUBLE PRECISION, DIMENSION(0:ROWS+1,0:COLUMNS+1) :: temperature
    !> Temperature grid from last iteration.
    DOUBLE PRECISION, DIMENSION(0:ROWS+1,0:COLUMNS+1) :: temperature_last
    !> Error code returned by MPI routines
    INTEGER :: ierr
    !> The number of MPI processes in total
    INTEGER :: comm_size;
    !> The rank of my MPI process
    INTEGER :: my_rank;
    !> Status returned by MPI calls
    INTEGER :: status(MPI_STATUS_SIZE)

    ! The usual mpi startup routines
    CALL MPI_Init(ierr)
    CALL MPI_Comm_size(MPI_COMM_WORLD, comm_size, ierr)
    CALL MPI_Comm_rank(MPI_COMM_WORLD, my_rank, ierr)

    IF (VERSION_RUN .eq. "mpi_small" .and. comm_size /= 4) THEN
        WRITE (*, '(A, I0, A)'), "The small version is meant to be run with 4 MPI processes, not ", comm_size, "."
        CALL MPI_Abort(MPI_COMM_WORLD, -1, ierr)
    ELSE IF (VERSION_RUN .eq. "mpi_big" .and. comm_size /= 112) THEN
        WRITE (*, '(A, I0, A)'), "The small version is meant to be run with 112 MPI processes, not ", comm_size, "."
        CALL MPI_Abort(MPI_COMM_WORLD, -1, ierr)
    ENDIF

    IF (my_rank .eq. 0) THEN
        WRITE (*, '(A, I0, A, /)'), "Running on ", comm_size, " MPI processes"
    ENDIF

    ! Initialise temperatures and temperature_last including boundary conditions
    CALL initialise_temperatures(temperature, temperature_last)

    !///////////////////////////////////
    !// -- Code from here is timed -- //
    !///////////////////////////////////
    IF (my_rank .eq. 0) THEN
        CALL start_timer(timer_simulation)
    ENDIF

    ! Do until error is minimal or until maximum steps
    DO WHILE ( dt_global > MAX_TEMP_ERROR .and. iteration <= MAX_NUMBER_OF_ITERATIONS)
        iteration = iteration+1

        DO j=1,COLUMNS
            DO i=1,ROWS
                temperature(i,j) = 0.25 * (temperature_last(i+1, j  ) + &
                                           temperature_last(i-1, j  ) + &
                                           temperature_last(i  , j+1) + &
                                           temperature_last(i  , j-1))
            ENDDO
         ENDDO

        !//////////////////////
        !// HALO SWAP PHASE //
        !////////////////////

        ! If we are not the last MPI process, we have a bottom neighbour
        IF (my_rank /= comm_size-1) THEN
            ! Send out bottom row to our bottom neighbour
            CALL MPI_Send(temperature(1, COLUMNS), ROWS, MPI_DOUBLE_PRECISION, my_rank+1, 0, MPI_COMM_WORLD, ierr)
        ENDIF

        ! If we are not the first MPI process, we have a top neighbour
        IF (my_rank /= 0) THEN
            ! We receive the bottom row from that neighbour into our top halo
            CALL MPI_Recv(temperature_last(1, 0), ROWS, MPI_DOUBLE_PRECISION, my_rank-1, MPI_ANY_TAG, MPI_COMM_WORLD, status, ierr)
        ENDIF

        ! If we are not the first MPI process, we have a top neighbour
        IF (my_rank /= 0) THEN
            ! Send out top row to our top neighbour
            CALL MPI_Send(temperature(1,1), ROWS, MPI_DOUBLE_PRECISION, my_rank-1, 0, MPI_COMM_WORLD, ierr)
        ENDIF

        ! If we are not the last MPI process, we have a bottom neighbour
        IF (my_rank /= comm_size-1) THEN
            ! We receive the top row from that neighbour into our bottom halo
            CALL MPI_Recv(temperature_last(1, COLUMNS+1), ROWS, MPI_DOUBLE_PRECISION, my_rank+1, MPI_ANY_TAG, MPI_COMM_WORLD, status, ierr)
        ENDIF

        !//////////////////////////////////////
        !// FIND MAXIMAL TEMPERATURE CHANGE //
        !////////////////////////////////////
        dt=0.0

        ! Copy grid to old grid for next iteration and find max change
        DO j=1,COLUMNS
            DO i=1,ROWS
                dt = max(abs(temperature(i,j) - temperature_last(i,j)), dt)
                temperature_last(i,j) = temperature(i,j)
            ENDDO
        ENDDO

        ! We know our temperature delta, we now need to sum it with that of other MPI processes
        CALL MPI_Reduce(dt, dt_global, 1, MPI_DOUBLE_PRECISION, MPI_MAX, 0, MPI_COMM_WORLD, ierr);
        CALL MPI_Bcast(dt_global, 1, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierr);

        ! PeriodiCALLy print test values
        IF (mod(iteration, PRINT_FREQUENCY) .eq. 0) THEN
            IF (my_rank .eq. comm_size - 1) THEN
                CALL track_progress(iteration, temperature)
            ENDIF
        ENDIF
    ENDDO

    ! Slightly more accurate timing and cleaner output 
    CALL MPI_Barrier(MPI_COMM_WORLD, ierr)

    IF (my_rank .eq. 0) THEN
        CALL stop_timer(timer_simulation)
        CALL print_summary(iteration, dt, timer_simulation)
    ENDIF

    CALL MPI_Finalize(ierr)
END PROGRAM serial
