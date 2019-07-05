#!/bin/bash

#SBATCH --nodes=4
#SBATCH --partition=GPU
#SBATCH --ntasks-per-node 2
#SBATCH --time=00:02:00
#SBATCH --gres=gpu:p100:2
#SBATCH -A ac560tp
set -x
./run.sh ${1} hybrid_gpu big ${2}
