#!/bin/bash

function echo_good
{
	echo -e "\033[32m$1\033[0m\c"
}

function echo_bad
{
	echo -e "\033[31m$1\033[0m\c"
}

function echo_timing
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

# Clear the screen to start with blank
clear

# Check the number of parameters passed
if [ "$#" -eq "1" ]; then
	echo_success "Correct number of arguments received; file to verify is \"$1\"."
else
	echo_failure "Wrong number of arguments received: please pass the file you want to verify. Don't worry about the reference file to compare against, this script will fetch it automatically in the reference file folder."
fi

# Check the challenger file exists
challenger_file=$1
if [ -f "${challenger_file}" ]; then
	echo_success "The file you passed exists."
else
	echo_failure "The file you passed does not exist."
fi

# Get the version run
version_run=`cat ${challenger_file} | grep "Version run" | cut -d ':' -f 2 | cut -d ' ' -f 2 | cut -d '.' -f 1`
if [ ! -z "${version_run}" ]; then
	echo_success "The version run has been retrieved: ${version_run}.";
else
	echo_failure "The version run has not been retrieved. The program should have produced a line as follows: \"Version run: X.\".";
fi

# Check the reference file exists
reference_file="reference_outputs/${version_run}.txt"
if [ -f "${reference_file}" ]; then
	echo_success "The reference file \"${reference_file}\" has been retrieved."
else
	echo_failure "The reference file \"${reference_file}\" could not be retrieved."
fi

# Check the numbers of line match
number_of_lines_reference=`cat ${reference_file} | wc -l | tr -d [:space:]`
number_of_lines_challenger=`cat ${challenger_file} | wc -l | tr -d [:space:]`

if [ "${number_of_lines_reference}" -eq "${number_of_lines_challenger}" ]; then
	echo_success "Both files have ${number_of_lines_reference} lines."
else
	echo_failure "The number of lines of the two files do not match; ${number_of_lines_reference} lines for the reference file, ${number_of_lines_challenger} lines for the file your file."
fi

# Check the number of iterations
number_iterations_reference=`cat "${reference_file}" | grep "iteration" | cut -d ' ' -f 9`
number_iterations_challenger=`cat "${challenger_file}" | grep "iteration" | cut -d ' ' -f 9`
if [ "${number_iterations_reference}" -eq "${number_iterations_challenger}" ]; then
	echo_success "The temperature delta triggered the threshold at iteration ${number_iterations_reference} for both."
else
	echo_failure "The temperature delta triggered the threshold at different iterations; ${number_iterations_reference} for the reference file vs ${number_iterations_challenger} for the file to verify."
fi

# Check the max error
max_error_reference=`cat "${reference_file}" | grep "iteration" | cut -d ' ' -f 11`
max_error_challenger=`cat "${challenger_file}" | grep "iteration" | cut -d ' ' -f 11`
if [ "${max_error_reference}" = "${max_error_challenger}" ]; then
	echo_success "The final maximum change in temperature is ${max_error_reference} for both."
else
	echo_failure "The final maximum change in temperature is different for both versions; ${max_error_reference} for the reference file vs ${max_error_challenger} for the file to verify."
fi

# Compare times
timing_reference=`cat "${reference_file}" | grep "Total time was" | cut -d ' ' -f 4`
timing_challenger=`cat "${challenger_file}" | grep "Total time was" | cut -d ' ' -f 4`
if [ $(bc <<< "${timing_reference} < ${timing_challenger}") -eq "1" ]; then
	speedup_slower=$(bc <<< "scale=2; ${timing_challenger}/${timing_reference}")
	echo_timing "Your version is ${speedup_slower} times faster: ${timing_reference}s vs ${timing_challenger}s."
else
	speedup_faster=$(bc <<< "scale=2; ${timing_reference}/${timing_challenger}")
	echo_timing "Your version is ${speedup_faster} times faster: ${timing_reference}s vs ${timing_challenger}s."
fi
