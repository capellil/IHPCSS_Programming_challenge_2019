SRC_DIRECTORY=src
BIN_DIRECTORY=bin
DOC_DIRECTORY=doc

SMALL_ROWS=168
SMALL_ROWS_GLOBAL=672
SMALL_COLUMNS=672
SMALL_DEFINES=-DROWS=$(SMALL_ROWS_GLOBAL) -DROWS_GLOBAL=$(SMALL_ROWS_GLOBAL) -DCOLUMNS=$(SMALL_COLUMNS)
SMALL_DEFINES_MPI=-DROWS=$(SMALL_ROWS) -DROWS_GLOBAL=$(SMALL_ROWS_GLOBAL) -DCOLUMNS=$(SMALL_COLUMNS)

BIG_ROWS=96
BIG_ROWS_GLOBAL=10752
BIG_COLUMNS=10752
BIG_DEFINES=-DROWS=$(BIG_ROWS_GLOBAL) -DROWS_GLOBAL=$(BIG_ROWS_GLOBAL) -DCOLUMNS=$(BIG_COLUMNS)
BIG_DEFINES_MPI=-DROWS=$(BIG_ROWS) -DROWS_GLOBAL=$(BIG_ROWS_GLOBAL) -DCOLUMNS=$(BIG_COLUMNS)

CC=gcc
MPICC=mpicc
CFLAGS=-O3 -lm -Wall -Wextra

default: help quick_compile

all: help documentation quick_compile 

quick_compile: create_directories serial_versions openmp_versions mpi_versions

################
# SERIAL CODES #
################
serial_versions: print_serial_compilation serial_small serial_big

print_serial_compilation:
	@echo "\n/////////////////////////////"; \
	 echo "// COMPILING SERIAL CODES //"; \
	 echo "///////////////////////////";

serial_small: $(SRC_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c
	@echo "    - Test version ($(SMALL_ROWS_GLOBAL)x$(SMALL_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/serial_small $(SRC_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c $(CFLAGS) $(SMALL_DEFINES) -DVERSION_RUN=\"serial_small\"

serial_big: $(SRC_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c
	@echo "    - Challenge version ($(BIG_ROWS_GLOBAL)x$(BIG_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/serial_big $(SRC_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c $(CFLAGS) $(BIG_DEFINES) -DVERSION_RUN=\"serial_big\"

################
# OPENMP CODES #
################
openmp_versions: print_openmp_compilation openmp_small openmp_big

print_openmp_compilation:
	@echo "\n/////////////////////////////"; \
	 echo "// COMPILING OPENMP CODES //"; \
	 echo "///////////////////////////";

openmp_small: $(SRC_DIRECTORY)/openmp.c $(SRC_DIRECTORY)/util.c
	@echo "    - Test version ($(SMALL_ROWS_GLOBAL)x$(SMALL_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/openmp_small $(SRC_DIRECTORY)/openmp.c $(SRC_DIRECTORY)/util.c $(CFLAGS) $(SMALL_DEFINES) -DVERSION_RUN=\"openmp_small\" -fopenmp

openmp_big: $(SRC_DIRECTORY)/openmp.c $(SRC_DIRECTORY)/util.c
	@echo "    - Challenge version ($(BIG_ROWS_GLOBAL)x$(BIG_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/openmp_big $(SRC_DIRECTORY)/openmp.c $(SRC_DIRECTORY)/util.c $(CFLAGS) $(BIG_DEFINES) -DVERSION_RUN=\"openmp_big\" -fopenmp

#############
# MPI CODES #
#############
mpi_versions: print_mpi_compilation mpi_small mpi_big

print_mpi_compilation:
	@echo "\n//////////////////////////"; \
	 echo "// COMPILING MPI CODES //"; \
	 echo "////////////////////////";

mpi_small: $(SRC_DIRECTORY)/mpi.c $(SRC_DIRECTORY)/util.c
	@echo "    - Test version ($(SMALL_ROWS)x$(SMALL_COLUMNS))\n        \c";
	$(MPICC) -o $(BIN_DIRECTORY)/mpi_small $(SRC_DIRECTORY)/mpi.c $(SRC_DIRECTORY)/util.c $(CFLAGS) $(SMALL_DEFINES_MPI) -DVERSION_RUN=\"mpi_small\" -DVERSION_RUN_IS_MPI

mpi_big: $(SRC_DIRECTORY)/mpi.c $(SRC_DIRECTORY)/util.c
	@echo "    - Challenge version ($(BIG_ROWS)x$(BIG_COLUMNS))\n        \c";
	$(MPICC) -o $(BIN_DIRECTORY)/mpi_big $(SRC_DIRECTORY)/mpi.c $(SRC_DIRECTORY)/util.c $(CFLAGS) $(BIG_DEFINES_MPI) -DVERSION_RUN=\"mpi_big\" -DVERSION_RUN_IS_MPI

#############
# UTILITIES #
#############
create_directories:
	@if [ ! -d $(BIN_DIRECTORY) ]; then mkdir $(BIN_DIRECTORY); fi 

help:
	@clear; \
	echo "Quick help: "; \
	echo "    - To generate the documentation, please issue 'make documentation'."; \
	echo "    - To delete all binaries generated, please issue 'make clean'."; \
	echo "------------------------------------------------------------------------------------";

clean: help
	@echo "\n////////////////////////";
	@echo "// CLEANING BINARIES //";
	@echo "//////////////////////";
	rm -rf $(BIN_DIRECTORY);

documentation: help
	@echo "\n///////////////////////////////";
	@echo "// GENERATING DOCUMENTATION //";
	@echo "/////////////////////////////";
	@echo "    - Generating doxygen... \c"; \
	 doxygen > /dev/null 2>&1; \
	 echo "done"; \
	 echo "    - Compiling latex... \c"; \
	 cd $(DOC_DIRECTORY)/latex; \
	 make > /dev/null 2>&1; \
	 cd ../..; \
	 echo "done"; \
	 echo "    - The HTML documentation is available in 'doc/html/index.xhtml'."; \
	 echo "    - The PDF documentation is available in 'doc/latex/refman.pdf'."
