#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=RM-shared
#SBATCH --ntasks-per-node 4
#SBATCH --time=00:00:10
#SBATCH --res challenge
#SBATCH -A ac560tp
set -x
./run.sh ${1} hybrid small ${2}
