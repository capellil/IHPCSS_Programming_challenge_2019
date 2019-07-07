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

###########################################
# Check that the right modules are loaded #
###########################################
if ! type "pgcc" > /dev/null 2>&1; then \
	clear; \
	echo -e "\n    . "; \
	echo -e "   / \\"; \
	echo -e "  / ! \\  It looks like the PGI compiler is not loaded."; \
	echo -e " /_____\\ On Bridges please issue 'module load cuda/9.2 mpi/pgi_openmpi/19.4-nongpu'. You can now make again :)\n"; \
	exit -1; \
fi

######################
# Display quick help #
######################
clear;
echo "Quick help:";
echo "  - This script is meant to be submit as follows: './submit.sh LANGUAGE IMPLEMENTATION SIZE OUTPUT_FILE'";
echo "  - LANGUAGE = 'C' | 'FORTRAN'";
echo "  - IMPLEMENTATION = 'serial' | 'openmp' | 'mpi' | 'hybrid_cpu' | 'openacc' | 'hybrid_gpu'";
echo "  - SIZE = 'small' | 'big'";
echo "  - OUTPUT_FILE = the path to the file in which store the output.";
echo "  - Example: to submit the C serial version on the small grid, submit './submit.sh C serial small'.";
echo "";

#################################
# Check the number of arguments #
#################################
if [ "$#" -eq "4" ]; then
	echo_success "Correct number of arguments received."
else
	echo_failure "Incorrect number of arguments received; $# passed whereas 4 are expected. Please refer to the quick help above."
fi

#############################################
# Check that the language passed is correct #
#############################################
languages=("C" "FORTRAN");
all_languages=`echo ${languages[@]}`;
is_in_array languages $1
language_retrieved=$?;
if [ "${language_retrieved}" == "0" ]; then
	echo_success "The language passed is correct.";
else
	echo_failure "The language '$1' is unknown. It must be one of: ${all_languages}.";
fi

###################################################
# Check that the implementation passed is correct #
###################################################
implementations=("serial" "openmp" "mpi" "hybrid_cpu" "openacc" "hybrid_gpu");
all_implementations=`echo ${implementations[@]}`;
is_in_array implementations $2
implementation_retrieved=$?;
if [ "${implementation_retrieved}" == "0" ]; then
	echo_success "The implementation passed is correct.";
else
	echo_failure "The implementation '$2' is unknown. It must be one of: ${all_implementations}.";
fi

#########################################
# Check that the size passed is correct #
#########################################
sizes=("small" "big");
all_sizes=`echo ${sizes[@]}`;
is_in_array sizes $3
size_retrieved=$?;
if [ "${size_retrieved}" == "0" ]; then
	echo_success "The size passed is correct.";
else
	echo_failure "The size '$3' is unknown. It must be one of: ${all_sizes}.";
fi

#########################################################
# Check that the corresponding submission script exists #
#########################################################
slurm_scripts_path="./slurm_scripts";
slurm_script_to_submit="${slurm_scripts_path}/$2_$3.slurm";
if [ -f "${slurm_script_to_submit}" ]; then
	echo_success "The corresponding submission script \"${slurm_script_to_submit}\" has been found."
else
	echo_failure "The corresponding submission script \"${slurm_script_to_submit}\"has not been found."
fi

sbatch ${slurm_script_to_submit} $1 $4
