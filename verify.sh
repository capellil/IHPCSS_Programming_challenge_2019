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

# Clear the screen to start with blank
clear

# Check the number of parameters passed
if [ "$#" -eq "1" ]; then
	echo_success "Correct number of arguments received. File to verify \"$1\"."
else
	echo_failure "Wrong number of arguments, just pass the file you want to verify."
fi

# Check the reference file exists
reference_file="output/serial.txt"
if [ -f "${reference_file}" ]; then
	echo_success "The reference file \"${reference_file}\" exists."
else
	echo_failure "The reference file \"${reference_file}\" does not exist."
fi

# Check the challenger file exists
challenger_file=$1
if [ -f "${challenger_file}" ]; then
	echo_success "The file \"${challenger_file}\" exists."
else
	echo_failure "The file \"${challenger_file}\" does not exist."
fi

# Check the numbers of line match
number_of_lines_reference=`wc -l ${reference_file} | cut -d ' ' -f 1`
number_of_lines_challenger=`wc -l ${challenger_file} | cut -d ' ' -f 1`

if [ "${number_of_lines_reference}" -eq "${number_of_lines_challenger}" ]; then
	echo_success "The number of lines match; ${number_of_lines_reference} lines each."
else
	echo_failure "The number of lines of the two files do not match; ${number_of_lines_reference} lines for the reference, ${number_of_lines_challenger} lines for the file you want to verify. Your version probably crashed mid-way, which prevented the output from completing."
fi

# Check the number of iterations
number_iterations_reference=`cat "${reference_file}" | grep "Max error at iteration" | cut -d ' ' -f 5`
number_iterations_challenger=`cat "${challenger_file}" | grep "Max error at iteration" | cut -d ' ' -f 5`
if [ "${number_iterations_reference}" -eq "${number_iterations_challenger}" ]; then
	echo_success "Threshold reached in identical iteration; iteration ${number_iterations_reference} each."
else
	echo_failure "Threshold reached in different iterations; iteration ${number_iterations_reference} for the reference file and ${number_iterations_challenger} for the file to verify."
fi

# Check the max error
max_error_reference=`cat "${reference_file}" | grep "Max error at iteration" | cut -d ' ' -f 7`
max_error_challenger=`cat "${challenger_file}" | grep "Max error at iteration" | cut -d ' ' -f 7`
if [ "${max_error_reference}" = "${max_error_challenger}" ]; then
	echo_success "Max error identical for both versions; ${max_error_reference} for each."
else
	echo_failure "Max error different for both versions; ${max_error_reference} for the reference file and ${max_error_challenger} for the file to verify."
fi

# Compare times
timing_reference=`cat "${reference_file}" | grep "Total time was" | cut -d ' ' -f 4`
timing_challenger=`cat "${challenger_file}" | grep "Total time was" | cut -d ' ' -f 4`
if [ $(bc <<< "${timing_reference} < ${timing_challenger}") -eq "1" ]; then
	speedup_slower=$(bc <<< "scale=2; ${timing_challenger}/${timing_reference}")
	echo_info "Your version is ${speedup_slower} times faster: ${timing_reference}s vs ${timing_challenger}s."
else
	speedup_faster=$(bc <<< "scale=2; ${timing_reference}/${timing_challenger}")
	echo_info "Your version is ${speedup_faster} times faster: ${timing_reference}s vs ${timing_challenger}s."
fi
