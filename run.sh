#!/bin/bash

################################################################################
# READ ME                                                                      #
#------------------------------------------------------------------------------#
# MOTIVATION                                                                   #
# Running an application in a wrong way is easy:                               #
# - not setting OMP_NUM_THREADS, or forgetting to update it for a given run    #
# - not launching an MPI application with mpirun                               #
# - using the wrong number of processes                                        #
# - using a bad thread pinning scheme                                          #
# This is why this script has been written; it takes care of launching the     #
# application in the right way so that you can focus on the actual development #
# and optimisation techniques.                                                 #
# So, how does it know how to launch the application? If you have been using   #
# the makefile provided, you have two binaries per technology, one for the big #
# grid, one for the small grid. By passing the technology and grid size to this#
# script, it knows which binary fetch and how to launch it.                    #
#                                                                              #
# PARAMETERS                                                                   #
# 1) Technology: one of 'serial' | 'openmp' | 'mpi' | 'openacc' | 'hybrid'     #
# 2) Size: one of 'small' | 'big'                                              #
# 3) Output file: optional parameter indicating where to store the output. If  #
#    no output file is given, the output is showed on the console.             #
#                                                                              #
# EXAMPLES                                                                     #
# ./run.sh openmp small                                                        #
# ./run.sh mpi big my_result_file.txt                                          #
# ./run.sh openacc small openacc_small_output.txt                              #
################################################################################

function echo_good
{
	echo -e "\033[32m$1\033[0m\c"
}

function echo_bad
{
	echo -e "\033[31m$1\033[0m\c"
}

function echo_success
{
	echo_good "[SUCCESS]"
	echo " $1"
}

function echo_failure
{
	echo_bad "[FAILURE]"
	echo " $1"
	exit -1
}

# Function taken from Meta Stack Overflow (https://meta.stackoverflow.com)
# Author: Glenn Jackman (profile: https://stackoverflow.com/users/7552/glenn-jackman)
# Original article: https://stackoverflow.com/a/14367368
function is_in_array
{ 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

######################
# Display quick help #
######################
clear;
echo "Quick help:";
echo -e "\t- This script is meant to be run as follows: './run.sh IMPLEMENTATION SIZE [OUTPUT_FILE]'";
echo -e "\t- IMPLEMENTATION = 'serial' | 'openmp' | 'mpi' | 'hybrid' | 'openacc'";
echo -e "\t- SIZE = 'small' | 'big'";
echo -e "\t- OUTPUT_FILE = the path to the file in which store the output. If no output file is given, the output is printed in the console."
echo -e "\t- Example: to run the serial version on the small grid, run './run.sh serial small'.\n";
if [ "$#" -eq "2" ] || [ "$#" -eq "3" ]; then
	echo_success "Correct number of arguments received; implementation = \"$1\" and size = \"$2\"."
else
	echo_failure "Wrong number of arguments received: please refer to the quick help above."
fi

###################################################
# Check that the implementation passed is correct #
###################################################
implementations=("serial" "openmp" "mpi" "hybrid" "openacc");
all_implementations=`echo ${implementations[@]}`;
is_in_array implementations $1
implementation_retrieved=$?;
if [ "${implementation_retrieved}" == "0" ]; then
	echo_success "The implementation passed is correct.";
else
	echo_failure "The implementation '$1' is unknown. It must be one of: ${all_implementations}.";
fi

#########################################
# Check that the size passed is correct #
#########################################
sizes=("small" "big");
all_sizes=`echo ${sizes[@]}`;
is_in_array sizes $2
size_retrieved=$?;
if [ "${size_retrieved}" == "0" ]; then
	echo_success "The size passed is correct.";
else
	echo_failure "The size '$2' is unknown. It must be one of: ${all_sizes}.";
fi

################################################
# Find command to issue to run the application #
################################################
runner="";
if [ "$1" == "mpi" ]; then
	if [ "$2" == "small" ]; then
		runner="mpirun -n 4";
	else
		runner="mpirun -n 112";
	fi
elif [ "$1" == "openmp" ]; then
	if [ "$2" == "small" ]; then
		runner="OMP_NUM_THREADS=4";
	else
		runner="OMP_NUM_THREADS=28";
	fi
elif [ "$1" == "hybrid" ]; then
	if [ "$2" == "small" ]; then
		runner="mpirun -n 2 -genv OMP_NUM_THREADS=2 -genv I_MPI_PIN_DOMAIN=omp";
	else
		runner="mpirun -n 8 -genv OMP_NUM_THREADS=14 -genv I_MPI_PIN_DOMAIN=omp";
	fi
elif [ "$1" == "openacc" ]; then
	if [ "$2" == "small" ]; then
		runner="";
	else
		runner="";
	fi
fi
executable="./bin/$1_$2";
if [ -f "${executable}" ]; then
	echo_success "The executable ${executable} exists.";
else
	echo_failure "The executable ${executable} does not exist.";
fi
if [ -z "${runner}" ]; then
	command="${executable}";
else
	command="${runner} ${executable}";
fi
if [ "$#" -eq "3" ]; then
	command="${command} > $3";
fi

echo_success "Command issued to run your application: \"${command}\"";
eval ${command};
