#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=RM
#SBATCH --ntasks-per-node 28
#SBATCH --time=00:00:10
#SBATCH -A ac560tp
set -x
./run.sh openmp big ${1}
