SRC_DIRECTORY=src
BIN_DIRECTORY=bin
DOC_DIRECTORY=doc
SERIAL_DIRECTORY=serial

CC=gcc
CFLAGS=-O3 -lm -Wall -Wextra

default: clear_screen quick_compile

all: clear_screen documentation quick_compile 

quick_compile: create_directories serial

################
# ACTUAL CODES #
################
serial: $(SRC_DIRECTORY)/$(SERIAL_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c
	@echo "Compiling serial version: \c";
	$(CC) -o $(BIN_DIRECTORY)/serial $(SRC_DIRECTORY)/$(SERIAL_DIRECTORY)/serial.c $(SRC_DIRECTORY)/util.c $(CFLAGS)

#############
# UTILITIES #
#############
create_directories:
	@if [ ! -d $(BIN_DIRECTORY) ]; then mkdir $(BIN_DIRECTORY); fi 

clear_screen:
	@clear

clean:
	@rm -rf $(BIN_DIRECTORY) $(DOC_DIRECTORY);

documentation:
	@echo "Generating doxygen... \c"; \
	doxygen > /dev/null 2>&1; \
	echo "done"; \
	echo "Compiling latex... \c"; \
	cd $(DOC_DIRECTORY)/latex; \
	make > /dev/null 2>&1; \
	cd ../..; \
	echo "done"; \
