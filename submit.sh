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
echo "  - This script is meant to be submit as follows: './submit.sh IMPLEMENTATION SIZE OUTPUT_FILE'";
echo "  - IMPLEMENTATION = 'serial' | 'openmp' | 'mpi' | 'hybrid' | 'openacc'";
echo "  - SIZE = 'small' | 'big'";
echo "  - OUTPUT_FILE = the path to the file in which store the output.";
echo "  - Example: to submit the serial version on the small grid, submit './submit.sh serial small'.";
echo "";

#################################
# Check the number of arguments #
#################################
if [ "$#" -eq "3" ]; then
	echo_success "Correct number of arguments received."
else
	echo_failure "Incorrect number of arguments received; $# passed whereas 3 are expected."
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

#########################################################
# Check that the corresponding submission script exists #
#########################################################
slurm_scripts_path="./slurm_scripts";
slurm_script_to_submit="${slurm_scripts_path}/$1_$2.slurm";
if [ -f "${slurm_script_to_submit}" ]; then
	echo_success "The corresponding submission script \"${slurm_script_to_submit}\" has been found."
else
	echo_failure "The corresponding submission script \"${slurm_script_to_submit}\"has not been found."
fi

sbatch ${slurm_script_to_submit} $3
