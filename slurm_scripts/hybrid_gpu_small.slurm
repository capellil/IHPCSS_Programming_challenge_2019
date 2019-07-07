#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=GPU-shared
#SBATCH --ntasks-per-node 2
#SBATCH --time=00:00:10
#SBATCH --gres=gpu:p100:2
#SBATCH --res challenge
#SBATCH -A ac560tp
set -x
module load cuda/9.2 mpi/pgi_openmpi/19.4-nongpu;
./run.sh ${1} hybrid_gpu small ${2}
