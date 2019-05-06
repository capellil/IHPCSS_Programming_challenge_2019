#!/bin/bash

function echo_good
{
	echo -e "\033[32m$1\033[0m\c"
}

function echo_bad
{
	echo -e "\033[31m$1\033[0m\c"
}

function echo_info
{
	echo -e "\033[33m[TIMINGS]\033[0m $1"
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

function array_contains2
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
echo -e "\t- This script is meant to be run as follows: './run.sh <IMPLEMENTATION> <SIZE>'";
echo -e "\t- IMPLEMENTATION = 'serial' | 'openmp' | 'mpi' | 'hybrid' | 'openacc'";
echo -e "\t- SIZE = 'small' | 'big'";
echo -e "\t- Example: to run the serial version on the small grid, run './run.sh serial small'.\n";
if [ "$#" -eq "2" ]; then
	echo_success "Correct number of arguments received; implementation = \"$1\" and size = \"$2\"."
else
	echo_failure "Wrong number of arguments received: please refer to the quick help above."
fi

###################################################
# Check that the implementation passed is correct #
###################################################
implementations=("serial" "openmp" "mpi" "hybrid" "openacc");
all_implementations=`echo ${implementations[@]}`;
array_contains2 implementations $1
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
array_contains2 sizes $2
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
		runner="mpirun -n 120";
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
	command="${runner} ${executable}"
fi

echo_success "Command issued to run your application: \"${command}\"";
${command};