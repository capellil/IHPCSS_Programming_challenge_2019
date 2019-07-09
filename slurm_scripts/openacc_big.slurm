#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=GPU
#SBATCH --ntasks-per-node 1
#SBATCH --time=00:03:00
#SBATCH --gres=gpu:p100:2
#SBATCH --res challengegpu
#SBATCH -A ac560tp
set -x
module load cuda/9.2;
./run.sh ${1} openacc big ${2}
