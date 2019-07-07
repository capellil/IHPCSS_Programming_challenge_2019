#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=RM-shared
#SBATCH --ntasks-per-node 1
#SBATCH --time=00:00:10
#SBATCH --res challenge
#SBATCH -A ac560tp
set -x
./run.sh ${1} serial small ${2}
