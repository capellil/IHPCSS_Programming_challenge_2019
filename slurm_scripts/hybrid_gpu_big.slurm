#!/bin/bash

#SBATCH --nodes=4
#SBATCH --partition=GPU
#SBATCH --ntasks-per-node 2
#SBATCH --time=00:17:00
#SBATCH --gres=gpu:p100:2
#SBATCH --res challenge
#SBATCH -A ac560tp
set -x
module load cuda/9.2 mpi/pgi_openmpi/19.4-nongpu;
./run.sh ${1} hybrid_gpu big ${2}
