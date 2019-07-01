# IHPCSS Challenge #

You are taking part to the [International High-Performance Computing Summer School](https://ss19.ihpcss.org) coding challenge? That's where it starts!

## What is the challenge? ##

This challenge introduces a simple problem: placing heating elements against a metal plate and simulate the temperature propagation across that metal plate. As the simulation progresses, the temperature across the metal plate stabilises; in other words, the total temperature variation tends towards 0. To put an end to the simulation, we determine a threshold under which we consider the simulation as converged. This is illustrated in the GIF animation below:

<p>
  <img src="images/Animation_intro.gif" alt="drawing" width="600"/>
</p>

For the challenge we take a metal plate of 14560x14560 and a threshold of 0.01. We know that, in this configuration, the simulation takes 3586 iterations to converge. Your job? Make that simulation as fast as you can.

## What is this repository for? ##

* You will find here everything you need to compete; source codes, makefiles, documentation, scripts, tests...
* It allows you to start with a basic version of the code in each model: serial, OpenMP, MPI and OpenACC.
* It provides you with a pre-setup experimental protocol that allows to compare experiments fairly.
* This repository serves as the formal challenge setup; it makes sure contestants compete in the same conditions.

## How do I get set up? ##
### Download the source codes ###
All you have to do is clone this repository: ```git clone https://github.com/capellil/IHPCSS_Coding_challenge.git```.

It contains basic versions (serial, OpenMP, MPI, OpenACC and hybrid) for both C and FORTRAN languages.

Note that you are strongly encouraged to work on the source files provided instead of making copies. To keep it short, you will discover in the sections below that multiple scripts have been written to make your life easier (makefile, running locally, submitting to compute nodes, verification). However, these scripts are designed to work with the files provided, not the arbitrary copies you could make.

### Generate the binaries ###
There is a makefile as you can see; it will compile all versions (serial, OpenMP, MPI, OpenACC etc...) and generate the corresponding binaries in a folder ```bin```. OpenACC requires the PGI compiler, so make sure you have the PGI module loaded (```module load pgi```) before you issue ```make```.

How does it work? Each version is compiled twice, once for the small grid and once for the big grid (see section below for definitions).

### Run locally ###
To make your life easier, a simple script has been written so you can launch your applications effortlessly: ```./run.sh LANGUAGE IMPLEMENTATION SIZE [OUTPUT_FILE]```.
  * LANGUAGE: the programming language to use, it must be either: ```C``` or ```FORTRAN```.
  * IMPLEMENTATION: the source code version to use, it must be either ```serial```, ```openmp```, ```mpi```, ```hybrid``` or ```openacc```.
  * SIZE: There are two grid sizes, a ```small``` for tests and a ```big``` for the challenge. The former converges in a handful of seconds; it is for you to test and debug your program quickly. Once you checked your implementation yields the correct result (you will see how to do this below), you can move to the latter one, which converges in approximately two minutes. It is against the ```big``` grid that your program will be run for the challenge.
  * OUTPUT_FILE: optional parameter indicating in which file write the output generated. If no file is passed, the output is generated to the standard stream (your console).

How does it work? As explained in section "Generate the binaries" above, there is one binary per technology per size. This script fetches the binary corresponding to the technology and size you passed, and runs it. This script is helpful because it takes care of launching the binary properly; setting ```OMP_NUM_THREADS``` if you use OpenMP, or invoking ```mpirun``` and setting the number of processes etc... Don't worry however, the script will tell you what command is issues to run the binary, so you will see how everything was invoked.

Example: you want to run the MPI version on the small grid, you thus type ```./run.sh mpi small```, this is an extract of what you will get:
```
./run.sh mpi small
[SUCCESS] Correct number of arguments received; implementation = "mpi" and size = "small".
[SUCCESS] The implementation passed is correct.
[SUCCESS] The size passed is correct.
[SUCCESS] The executable ./bin/mpi_small exists.
[SUCCESS] Command issued to run your application: "mpirun -n 4 ./bin/mpi_small"
```

#### IMPORTANT ####
On Bridges, you should not run ```big``` grid calculations locally but on the compute nodes (see next section). The node on which you program is the login node, it is meant for people to ssh and send jobs to the compute nodes, not run programs. Running the ```small``` grid calculations, something that finishes in maximum 5 seconds is okay, but trying to run the ```big``` grid calculations, therefore using 100% of all CPUs for minutes is a good way to make the login node lag and every other user in a bad mood.
  
### Submit to Bridges compute nodes ###
Similarly to the section "Run locally", a script has been written for you to easily submit your work to Bridges via SLURM: ```./submit.sh LANGUAGE IMPLEMENTATION SIZE OUTPUT_FILE```. The parameters LANGUAGE, IMPLEMENTATION and SIZE are identical to that passed to the ```run.sh``` script. The output file this time is no longer optional however, because you need a file to which redirect the output of your job.

How does it work? As you have probably seen, there is a ```slurm_scripts``` folder. It contains two SLURM submission scripts for each version (serial, OpenMP, MPI etc...): one for the small grid, one for the big grid. That allows each SLURM script to be tailored (number of nodes, type of nodes, walltime...) for the implementation and size demanded.

If you want to create your own SLURM submission script, there is an additional one called ```general.slurm```, which contains all the commands you may want to use along with their description. You will also find in that submission script links that will lead you to PSC webpages containing more information about submission scripts.

### Verification ###
One more script to make your life easier and encapsulate all the verification process in a single command: ```./verify.sh YOUR_OUTPUT_FILE```.

How does it work? As you have probably seen, there is a ```reference_outputs``` folder. It contains the output files generated by each version (serial, OpenMP, MPI etc...) untouched, for each programming language (C, FORTRAN). When your optimised version generates an output file, you want to check that your results are correct, and see if you got any faster than the original version. To that end, you want to compare your own output file against the reference output file. This is where this script gets handy; you just pass your output file and the script will:
* automatically detect which language you used, which version is used, which grid size is used to automatically find the corresponding reference file
* compare the number of iterations to reach convergence
* compare the final temperature change
* compare the total time and give your speed-up

Example: you worked on the MPI version, you submitted it as follow: ```./submit.sh mpi big my_mpi_big_results.txt```. To verify your output file, just type ```./verify.sh my_mpi_big_results.txt```. This is an example of what you could get:
```
./verify.sh my_mpi_big_results.txt
[SUCCESS] Correct number of arguments received; file to verify is "my_mpi_big_results.txt".
[SUCCESS] The file you passed exists.
[SUCCESS] The version run has been retrieved: mpi_big.
[SUCCESS] The reference file "reference_outputs/mpi_big.txt" has been retrieved.
[SUCCESS] Both files have 43 lines.
[SUCCESS] The temperature delta triggered the threshold at iteration 3586 for both.
[SUCCESS] The final maximum change in temperature is 0.009996974331912156 for both.
[TIMINGS] Your version is 1.26 times faster: 89.4s (you) vs 112.8s (reference).
```

## What kind of optimisations are not allowed? ##

* Reducing the amount of work to be done such as ignoring the cells whose value will be zero during the entire simulation.
* Removing the track_progress from the loop or changing the frequency at which it prints.
* Bypassing the buffer copy using a pointer swap.
* Decreasing the accuracy of the calculations by switching from doubles to floats.

## Who do I talk to? ##

* Repository owner
* IHPCSS Coding Challenge organisers

## Acknowledgments ##
* [John Urbanic](https://www.psc.edu/staff/urbanic)
* [David Henty](https://www.epcc.ed.ac.uk/about/staff/dr-david-henty)
