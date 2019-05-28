#!/bin/bash

##################################
# WHERE TO FIND MORE INFORMATION #
##################################
# You can find sample batch scripts at: https://www.psc.edu/bridges/user-guide/sample-batch-scripts
# You can find more information about options at: https://www.psc.edu/bridges/user-guide/running-jobs#sbatch
# You can find more information about bridges system at: https://www.psc.edu/bridges/user-guide/system-configuration

##################
# COMMON PITFALL #
##################
# A comment starts with '#' followed by a SPACE. An SBATCH command starts with '#' NOT followed by a space.
# SBATCH <- This will not be treated as an SBATCH command because of the space between '#' and 'SBATCH'.

####################
# TYPICAL COMMANDS #
####################
# Indicate the number of nodes we want
#SBATCH --nodes=1

# Indicate that we want to use the Regular Memory nodes
# RM-shared indicates that we're okay to share the node with someone else
# RM-small indicates that we're running a short job on 2 nodes or less
# GPU indicates that we're running on nodes having GPUs
#SBATCH --partition=RM-small

# Indicate the number of cores to allocate per node
#SBATCH --ntasks-per-node 28

# Indicate the amount of time needed HH:MM:SS
#SBATCH --time=00:00:10

# Indicate which account use
#SBATCH -A ac560tp

# Echo commands to stdout 
set -x

# Your command here: ./openMPProgram ... or mpirun -n ... ./yourMPIProgram
