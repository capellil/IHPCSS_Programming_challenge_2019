#!/bin/bash

#SBATCH --nodes=4
#SBATCH --partition=RM
#SBATCH --ntasks-per-node 28
#SBATCH --time=00:02:00
#SBATCH -A ac560tp
set -x
./run.sh mpi big ${1}
