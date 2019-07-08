#!/bin/bash

#SBATCH --nodes=4
#SBATCH --partition=RM
#SBATCH --ntasks-per-node 2
#SBATCH --time=00:03:00
#SBATCH --res challenge
#SBATCH -A ac560tp
set -x
./run.sh ${1} hybrid_cpu big ${2}
