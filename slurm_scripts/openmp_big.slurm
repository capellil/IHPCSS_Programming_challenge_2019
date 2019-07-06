#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=RM
#SBATCH --ntasks-per-node 28
#SBATCH --time=00:06:00
#SBATCH -A ac560tp
set -x
./run.sh ${1} openmp big ${2}
