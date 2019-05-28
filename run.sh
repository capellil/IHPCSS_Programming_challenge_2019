#!/bin/bash

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
		#runner="mpirun -n 2 -genv OMP_NUM_THREADS=2 -genv I_MPI_PIN_PROCESSOR_LIST=allcores,map=scatter -genv KMP_PLACE_THREADS=1T -genv KMP_AFFINITY=verbose,compact";
		runner="OMP_NUM_THREADS=2 mpirun -n 2";
	else
		#runner="mpirun -n 8 -ppn 2 -genv OMP_NUM_THREADS=14 -genv I_MPI_PIN_PROCESSOR_LIST=allcores,map=scatter -genv KMP_PLACE_THREADS=1T -genv KMP_AFFINITY=verbose,compact";
		runner="OMP_NUM_THREADS=14 mpirun -n 8 -ppn 2";
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
