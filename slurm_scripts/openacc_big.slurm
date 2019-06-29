#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=GPU-shared
#SBATCH --ntasks-per-node 1
#SBATCH --time=00:02:00
#SBATCH --gres=gpu:p100:2
#SBATCH -A ac560tp
set -x
./run.sh ${1} openacc big ${2}
