SRC_DIRECTORY=src
BIN_DIRECTORY=bin
DOC_DIRECTORY=doc

SMALL_ROWS=672
SMALL_COLUMNS=672

BIG_ROWS=10572
BIG_COLUMNS=10572

CC=gcc
CFLAGS=-O3 -lm -Wall -Wextra

default: help quick_compile

all: help documentation quick_compile 

quick_compile: create_directories serial_versions

################
# SERIAL CODES #
################
serial_versions: print_serial_compilation serial_small serial_big

print_serial_compilation:
	@echo "\n/////////////////////////////"; \
	 echo "// COMPILING SERIAL CODES //"; \
	 echo "///////////////////////////";

serial_small: $(SRC_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c
	@echo "    - Test version ($(SMALL_ROWS)x$(SMALL_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/serial_small $(SRC_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c $(CFLAGS) -DROWS=$(SMALL_ROWS) -DCOLUMNS=$(SMALL_COLUMNS) -DVERSION_RUN=\"serial_small\"

serial_big: $(SRC_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c
	@echo "    - Challenge version ($(BIG_ROWS)x$(BIG_COLUMNS))\n        \c";
	$(CC) -o $(BIN_DIRECTORY)/serial_big $(SRC_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c $(CFLAGS) -DROWS=$(BIG_ROWS) -DCOLUMNS=$(BIG_COLUMNS) -DVERSION_RUN=\"serial_big\"

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
