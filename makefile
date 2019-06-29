SRC_DIRECTORY=src
BIN_DIRECTORY=bin
DOC_DIRECTORY=doc

C_DIRECTORY=C
FORTRAN_DIRECTORY=FORTRAN

SMALL_ROWS=168
SMALL_ROWS_HYBRID=336
SMALL_ROWS_GLOBAL=672
SMALL_COLUMNS=672
SMALL_DEFINES=-DROWS=$(SMALL_ROWS_GLOBAL) -DROWS_GLOBAL=$(SMALL_ROWS_GLOBAL) -DCOLUMNS=$(SMALL_COLUMNS)
SMALL_DEFINES_MPI=-DROWS=$(SMALL_ROWS) -DROWS_GLOBAL=$(SMALL_ROWS_GLOBAL) -DCOLUMNS=$(SMALL_COLUMNS)
SMALL_DEFINES_HYBRID=-DROWS=$(SMALL_ROWS_HYBRID) -DROWS_GLOBAL=$(SMALL_ROWS_GLOBAL) -DCOLUMNS=$(SMALL_COLUMNS)

BIG_ROWS=130
BIG_ROWS_HYBRID=1820
BIG_ROWS_GLOBAL=14560
BIG_COLUMNS=14560
BIG_DEFINES=-DROWS=$(BIG_ROWS_GLOBAL) -DROWS_GLOBAL=$(BIG_ROWS_GLOBAL) -DCOLUMNS=$(BIG_COLUMNS)
BIG_DEFINES_MPI=-DROWS=$(BIG_ROWS) -DROWS_GLOBAL=$(BIG_ROWS_GLOBAL) -DCOLUMNS=$(BIG_COLUMNS)
BIG_DEFINES_HYBRID=-DROWS=$(BIG_ROWS_HYBRID) -DROWS_GLOBAL=$(BIG_ROWS_GLOBAL) -DCOLUMNS=$(BIG_COLUMNS)

CC=icc
MPICC=mpiicc
OPENACCCC=pgcc
CFLAGS=-std=c99 -O2 -lm -Wall -Wextra
PGICFLAGS=-c99 -O2 -acc

FORTRANC=ifort
FORTRANFLAGS=-O2 -fpp

default: help quick_compile

all: help documentation quick_compile 

quick_compile: create_directories serial_versions openmp_versions mpi_versions hybrid_versions openacc_versions

################
# SERIAL CODES #
################
serial_versions: print_serial_compilation C_serial_small C_serial_big FORTRAN_serial_small

print_serial_compilation:
	@echo -e "\n/////////////////////////////"; \
	 echo "// COMPILING SERIAL CODES //"; \
	 echo "///////////////////////////";

C_serial_small: $(SRC_DIRECTORY)/$(C_DIRECTORY)/serial.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Test version ($(SMALL_ROWS_GLOBAL)x$(SMALL_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/serial_small $(SRC_DIRECTORY)/$(C_DIRECTORY)/serial.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(CFLAGS) $(SMALL_DEFINES) -DVERSION_RUN=\"serial_small\"

C_serial_big: $(SRC_DIRECTORY)/$(C_DIRECTORY)/serial.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Challenge version ($(BIG_ROWS_GLOBAL)x$(BIG_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/serial_big $(SRC_DIRECTORY)/$(C_DIRECTORY)/serial.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(CFLAGS) $(BIG_DEFINES) -DVERSION_RUN=\"serial_big\"

FORTRAN_serial_small: $(SRC_DIRECTORY)/$(FORTRAN_DIRECTORY)/serial.f90 $(SRC_DIRECTORY)/$(FORTRAN_DIRECTORY)/util.f90
	@echo -e "    - Test version ($(SMALL_ROWS_GLOBAL)x$(SMALL_COLUMNS))\n        \c";
	$(FORTRANC) $(SMALL_DEFINES) -o $(BIN_DIRECTORY)/$(FORTRAN_DIRECTORY)/serial_small $(SRC_DIRECTORY)/$(FORTRAN_DIRECTORY)/util.f90 $(SRC_DIRECTORY)/$(FORTRAN_DIRECTORY)/serial.f90 $(FORTRANFLAGS) -DVERSION_RUN=\"serial_small\"

################
# OPENMP CODES #
################
openmp_versions: print_openmp_compilation C_openmp_small C_openmp_big

print_openmp_compilation:
	@echo -e "\n/////////////////////////////"; \
	 echo "// COMPILING OPENMP CODES //"; \
	 echo "///////////////////////////";

C_openmp_small: $(SRC_DIRECTORY)/$(C_DIRECTORY)/openmp.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Test version ($(SMALL_ROWS_GLOBAL)x$(SMALL_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/openmp_small $(SRC_DIRECTORY)/$(C_DIRECTORY)/openmp.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(CFLAGS) $(SMALL_DEFINES) -DVERSION_RUN=\"openmp_small\" -qopenmp

C_openmp_big: $(SRC_DIRECTORY)/$(C_DIRECTORY)/openmp.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Challenge version ($(BIG_ROWS_GLOBAL)x$(BIG_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/openmp_big $(SRC_DIRECTORY)/$(C_DIRECTORY)/openmp.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(CFLAGS) $(BIG_DEFINES) -DVERSION_RUN=\"openmp_big\" -qopenmp

#############
# MPI CODES #
#############
mpi_versions: print_mpi_compilation mpi_small mpi_big

print_mpi_compilation:
	@echo -e "\n//////////////////////////"; \
	 echo "// COMPILING MPI CODES //"; \
	 echo "////////////////////////";

mpi_small: $(SRC_DIRECTORY)/$(C_DIRECTORY)/mpi.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Test version ($(SMALL_ROWS_GLOBAL)x$(SMALL_COLUMNS))\n        \c";
	$(MPICC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/mpi_small $(SRC_DIRECTORY)/$(C_DIRECTORY)/mpi.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(CFLAGS) $(SMALL_DEFINES_MPI) -DVERSION_RUN=\"mpi_small\" -DVERSION_RUN_IS_MPI

mpi_big: $(SRC_DIRECTORY)/$(C_DIRECTORY)/mpi.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Challenge version ($(BIG_ROWS_GLOBAL)x$(BIG_COLUMNS))\n        \c";
	$(MPICC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/mpi_big $(SRC_DIRECTORY)/$(C_DIRECTORY)/mpi.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(CFLAGS) $(BIG_DEFINES_MPI) -DVERSION_RUN=\"mpi_big\" -DVERSION_RUN_IS_MPI

################
# HYBRID CODES #
################
hybrid_versions: print_hybrid_compilation hybrid_small hybrid_big

print_hybrid_compilation:
	@echo -e "\n/////////////////////////////"; \
	 echo "// COMPILING HYBRID CODES //"; \
	 echo "///////////////////////////";

hybrid_small: $(SRC_DIRECTORY)/$(C_DIRECTORY)/hybrid.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Test version ($(SMALL_ROWS_GLOBAL)x$(SMALL_COLUMNS))\n        \c";
	$(MPICC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/hybrid_small $(SRC_DIRECTORY)/$(C_DIRECTORY)/hybrid.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(CFLAGS) $(SMALL_DEFINES_HYBRID) -qopenmp -DVERSION_RUN=\"hybrid_small\" -DVERSION_RUN_IS_MPI

hybrid_big: $(SRC_DIRECTORY)/$(C_DIRECTORY)/hybrid.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Challenge version ($(BIG_ROWS_GLOBAL)x$(BIG_COLUMNS))\n        \c";
	$(MPICC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/hybrid_big $(SRC_DIRECTORY)/$(C_DIRECTORY)/hybrid.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(CFLAGS) $(BIG_DEFINES_HYBRID) -qopenmp -DVERSION_RUN=\"hybrid_big\" -DVERSION_RUN_IS_MPI

#################
# OPENACC CODES #
#################
openacc_versions: print_openacc_compilation openacc_small openacc_big clean_objects

print_openacc_compilation:
	@echo -e "\n//////////////////////////////"; \
	 echo "// COMPILING OPENACC CODES //"; \
	 echo "////////////////////////////";

openacc_small: $(SRC_DIRECTORY)/$(C_DIRECTORY)/openacc.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Test version ($(SMALL_ROWS_GLOBAL)x$(SMALL_COLUMNS))\n        \c";
	$(OPENACCCC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/openacc_small $(SRC_DIRECTORY)/$(C_DIRECTORY)/openacc.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(PGICFLAGS) $(SMALL_DEFINES) -DVERSION_RUN=\"openacc_small\"

openacc_big: $(SRC_DIRECTORY)/$(C_DIRECTORY)/openacc.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c
	@echo -e "    - Challenge version ($(BIG_ROWS_GLOBAL)x$(BIG_COLUMNS))\n        \c";
	$(OPENACCCC) -o $(BIN_DIRECTORY)/$(C_DIRECTORY)/openacc_big $(SRC_DIRECTORY)/$(C_DIRECTORY)/openacc.c $(SRC_DIRECTORY)/$(C_DIRECTORY)/util.c $(PGICFLAGS) $(BIG_DEFINES) -DVERSION_RUN=\"openacc_big\"

clean_objects:
	@rm -f *.o *.mod;

#############
# UTILITIES #
#############
create_directories:
	@if [ ! -d $(BIN_DIRECTORY) ]; then mkdir $(BIN_DIRECTORY); fi; \
	if [ ! -d $(BIN_DIRECTORY)/$(C_DIRECTORY) ]; then mkdir $(BIN_DIRECTORY)/$(C_DIRECTORY); fi; \
	if [ ! -d $(BIN_DIRECTORY)/$(FORTRAN_DIRECTORY) ]; then mkdir $(BIN_DIRECTORY)/$(FORTRAN_DIRECTORY); fi 

help:
	@clear; \
	echo "+-----------+"; \
	echo "| Quick help \\"; \
	echo "+-------------+------------------+--------------------+"; \
	echo "| Generate the documentation     | make documentation |"; \
	echo "| Delete all binaries            | make clean         |"; \
	echo "| 'make: XXX: Command not found' | module load XXX    |"; \
	echo "+-----------------------------------------------------+";

clean: help
	@echo -e "\n////////////////////////";
	@echo "// CLEANING BINARIES //";
	@echo "//////////////////////";
	rm -rf $(BIN_DIRECTORY);

documentation: help
	@echo -e "\n///////////////////////////////";
	@echo "// GENERATING DOCUMENTATION //";
	@echo "/////////////////////////////";
	@echo -e "    - Generating doxygen... \c"; \
	 doxygen > /dev/null 2>&1; \
	 echo "done"; \
	 echo -e "    - Compiling latex... \c"; \
	 cd $(DOC_DIRECTORY)/latex; \
	 make > /dev/null 2>&1; \
	 cd ../..; \
	 echo "done"; \
	 echo "    - The HTML documentation is available in 'doc/html/index.xhtml'."; \
	 echo "    - The PDF documentation is available in 'doc/latex/refman.pdf'."
