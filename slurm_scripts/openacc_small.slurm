#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=GPU-shared
#SBATCH --ntasks-per-node 1
#SBATCH --time=00:00:10
#SBATCH --gres=gpu:p100:1
#SBATCH -A ac560tp
set -x
./run.sh ${1} openacc small ${2}
