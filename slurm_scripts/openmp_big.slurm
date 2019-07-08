#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=RM
#SBATCH --ntasks-per-node 28
#SBATCH --time=00:08:00
#SBATCH --res challenge
#SBATCH -A ac560tp
set -x
./run.sh ${1} openmp big ${2}
