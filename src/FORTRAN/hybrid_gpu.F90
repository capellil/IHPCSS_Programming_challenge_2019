!> @file hybrid_gpu.F90
!> @brief Contains the MPI + OpenACC version of Laplace.
!> @note This code was originaly written by John Urbanic for PSC 2014, later modified by Ludovic Capelli.
!> @author John Urbanic
!> @author Ludovic Capelli

!> @brief Runs the experiment.
!> @pre The macro 'ROWS' contains the number of rows (excluding boundaries). It is a define passed as a compilation flag, see makefile.
!> @pre The macro 'COLUMNS' contains the number of columns (excluding boundaries) per MPI process. It is a define passed as a compilation flag, see makefile.
PROGRAM serial
    USE util
    USE mpi
    USE openacc
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
    !> The rank of my MPI process on the local node
    INTEGER :: my_local_rank
    !> Number of GPUs detected
    INTEGER :: number_of_acc_devices
    INTEGER(acc_device_kind) :: acc_device_type

    ! The usual mpi startup routines
    CALL MPI_Init(ierr)
    CALL MPI_Comm_size(MPI_COMM_WORLD, comm_size, ierr)
    CALL MPI_Comm_rank(MPI_COMM_WORLD, my_rank, ierr)

    IF (VERSION_RUN .eq. "mpi_small" .and. comm_size /= 2) THEN
        WRITE (*, '(A, I0, A)'), "The small version is meant to be run with 2 MPI processes, not ", comm_size, "."
        CALL MPI_Abort(MPI_COMM_WORLD, -1, ierr)
    ELSE IF (VERSION_RUN .eq. "mpi_big" .and. comm_size /= 8) THEN
        WRITE (*, '(A, I0, A)'), "The small version is meant to be run with 8 MPI processes, not ", comm_size, "."
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

    ! 2 MPI processes per node, 2 GPUs per node, this makes sure that the 2 MPI processes don't use the same GPU
    number_of_acc_devices = acc_get_num_devices(1);
    CALL acc_set_device_num(mod(my_local_rank, number_of_acc_devices), 1);

    ! Do until error is minimal or until maximum steps
    DO WHILE ( dt_global > MAX_TEMP_ERROR .and. iteration <= MAX_NUMBER_OF_ITERATIONS)
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

        !//////////////////////
        !// HALO SWAP PHASE //
        !////////////////////

        ! If we are not the last MPI process, we have a right neighbour
        IF (my_rank /= comm_size-1) THEN
            ! Send out right row to our right neighbour
            CALL MPI_Send(temperature(1, COLUMNS), ROWS, MPI_DOUBLE_PRECISION, my_rank+1, 0, MPI_COMM_WORLD, ierr)
        ENDIF

        ! If we are not the first MPI process, we have a left neighbour
        IF (my_rank /= 0) THEN
            ! We receive the right row from that neighbour into our left halo
            CALL MPI_Recv(temperature_last(1, 0), ROWS, MPI_DOUBLE_PRECISION, my_rank-1, MPI_ANY_TAG, MPI_COMM_WORLD, status, ierr)
        ENDIF

        ! If we are not the first MPI process, we have a left neighbour
        IF (my_rank /= 0) THEN
            ! Send out left row to our left neighbour
            CALL MPI_Send(temperature(1,1), ROWS, MPI_DOUBLE_PRECISION, my_rank-1, 0, MPI_COMM_WORLD, ierr)
        ENDIF

        ! If we are not the last MPI process, we have a right neighbour
        IF (my_rank /= comm_size-1) THEN
            ! We receive the left row from that neighbour into our right halo
            CALL MPI_Recv(temperature_last(1, COLUMNS+1), ROWS, MPI_DOUBLE_PRECISION, my_rank+1, MPI_ANY_TAG, MPI_COMM_WORLD, status, ierr)
        ENDIF

        !//////////////////////////////////////
        !// FIND MAXIMAL TEMPERATURE CHANGE //
        !////////////////////////////////////
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

        ! We know our temperature delta, we now need to sum it with that of other MPI processes
        CALL MPI_Reduce(dt, dt_global, 1, MPI_DOUBLE_PRECISION, MPI_MAX, 0, MPI_COMM_WORLD, ierr);
        CALL MPI_Bcast(dt_global, 1, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierr);

        ! Periodically print test values
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
        CALL print_summary(iteration, dt_global, timer_simulation)
    ENDIF

    ! Print the halo swap verification cell value 
    CALL MPI_Barrier(MPI_COMM_WORLD, ierr);
    IF (my_rank .eq. comm_size - 2) THEN
        WRITE (*, '(A, I0, A, I0, A, F21.18)'), "Value of halo swap verification cell (", ROWS - 1, ", ", COLUMNS_GLOBAL - COLUMNS - 1, ") is ", temperature(ROWS,COLUMNS)
    ENDIF

    CALL MPI_Finalize(ierr)
END PROGRAM serial
