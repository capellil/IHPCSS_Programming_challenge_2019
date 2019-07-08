# IHPCSS Challenge #

You are taking part to the [International High-Performance Computing Summer School](https://ss19.ihpcss.org) coding challenge? That's where it starts!

## Table of contents ##

* [What is the challenge](#what-is-the-challenge)
* [What is this repository for?](#what-is-this-repository-for)
* [How do I get set up?](#how-do-i-get-set-up)
  * [Download the source codes](#download-the-source-codes)
  * [Compile the source codes](#compile-the-source-codes)
  * [Run locally](#run-locally)
  * [Submit to Bridges compute nodes](#submit-to-bridges-compute-nodes)
  * [Verification](#verification)
* [What kind of optimisations are not allowed?](#what-kind-of-optimisations-are-not-allowed)
* [Send your solution to the competition](#send-your-solution-to-the-competition)
* [Who do I talk to?](#who-do-i-talk-to)
* [Acknowledgments](#acknowledgments)

## What is the challenge? ##

This challenge introduces a simple problem: placing heating elements against a metal plate and simulate the temperature propagation across that metal plate. As the simulation progresses, the temperature across the metal plate stabilises; in other words, the total temperature variation tends towards 0. To put an end to the simulation, we determine a threshold for the temperature variation, under which we consider the simulation as converged. This is illustrated in the GIF animation below:

<p>
  <img src="images/Animation_intro.gif" alt="drawing" width="600"/>
</p>

For the challenge we take a metal plate of 14560x14560 and a threshold of 0.01. We know that, in this configuration, the simulation takes 3586 iterations to converge. Your job? Make that simulation as fast as you can.

[Go back to table of contents](#table-of-contents)
## What is this repository for? ##

* You will find here everything you need to compete; source codes, makefiles, documentation, scripts, tests...
* You will also find a basic version of the source code in every model (available in both C and FORTRAN):
  * serial
  * OpenMP
  * OpenACC
  * MPI
  * MPI + OpenMP
  * MPI + OpenACC
* It provides you with a pre-setup experimental protocol; it makes sure contestants compete in the same conditions and allows to compare experiments fairly.

[Go back to table of contents](#table-of-contents)
## How do I get set up? ##
### Download the source codes ###
All you have to do is clone this repository: ```git clone https://github.com/capellil/IHPCSS_Coding_challenge.git```.

Note that you are strongly encouraged to work on the source files provided instead of making copies. To keep it short, you will discover in the sections below that multiple scripts have been written to make your life easier (makefile, running locally, submitting to compute nodes, verification). However, these scripts are designed to work with the files provided, not the arbitrary copies you could make.

[Go back to table of contents](#table-of-contents)
### Compile the source codes ###
There is a makefile as you can see; it will compile all versions (serial, OpenMP, MPI, OpenACC etc...) and generate the corresponding binaries in a folder ```bin```. OpenACC requires the PGI compiler, so we use the PGI compiler over all versions to keep things consistent. Make sure you load the right module with ```module load cuda/9.2 mpi/pgi_openmpi/19.4-nongpu``` before making, if you do not, the makefile will remind you.

What happens behind the scene?

As you will quickly see, there is one folder for C source codes, one for FORTRAN source codes. Inside, each version has a specific file:

| Model | C version | FORTRAN version |
|-------|-----------|-----------------|
| serial | serial.c | serial.F90 |
| OpenMP | openmp.c | openmp.F90 |
| OpenACC | openacc.c | openacc.F90 |
| MPI | mpi.c | mpi.F90 |
| MPI + OpenMP | hybrid_cpu.c | hybrid_cpu.F90 |
| MPI + OpenACC | hybrid_gpu.c | hybrid_gpu.F90 |

And of course, modify the file corresponding to the combination you want to work on. No need to make a copy, work on the original file, everything is version controlled remember.

[Go back to table of contents](#table-of-contents)
### Run locally ###
(***Note**: If you use a GPU version (```openacc``` or ```hybrid_gpu```), you cannot run your program locally because it is compiled to explicitly target NVIDIA Tesla GPUs (c.f: ```-ta=tesla,cuda9.2```); the ones that are on the compute nodes. The login node on which you work however does not have such GPUs so it will complain if you try to run your program locally. Do not worry, just submit it to the compute nodes as showed in [next section](#submit-to-bridges-compute-nodes).*)

To make your life easier, a simple script has been written so you can launch your applications effortlessly: ```./run.sh LANGUAGE IMPLEMENTATION SIZE [OUTPUT_FILE]```.

| Parameter | Description |
|-----------|-------------|
| LANGUAGE | The programming language to use, it must be either: ```C``` or ```FORTRAN```
| IMPLEMENTATION | The source code version to use, it must be either ```serial```, ```openmp```, ```mpi```, ```openacc```, ```hybrid_cpu``` or ```hybrid_gpu```. |
| SIZE | There are two grid sizes, a ```small``` for tests and a ```big``` for the challenge. The former converges in a handful of seconds; it is for you to test and debug your program quickly. Once you checked your implementation yields the correct result (you will see how below), you can move to the latter one, which converges in approximately two minutes for most cases. It is against the ```big``` grid that your program will be run for the challenge. |
| OUTPUT_FILE | Optional parameter indicating in which file write the output generated. If no file is passed, the output is generated to the standard stream (your console). |

How does it work? As explained in section "Compile the source codes" above, there is one binary per technology per size. This script fetches the binary corresponding to the technology and size you passed, and runs it. This script is helpful because it takes care of launching the binary properly; setting ```OMP_NUM_THREADS``` if you use OpenMP, or invoking ```mpirun``` and setting the number of processes etc... Don't worry however, the script is totally transparent; it tells what command it issues so you see how everything was invoked.

Example: you want to run the MPI version on the small grid, you thus type ```./run.sh mpi small```, this is an extract of what you will get:
```
./run.sh mpi small
[SUCCESS] Correct number of arguments received; implementation = "mpi" and size = "small".
[SUCCESS] The implementation passed is correct.
[SUCCESS] The size passed is correct.
[SUCCESS] The executable ./bin/mpi_small exists.
[SUCCESS] Command issued to run your application: "mpirun -n 4 ./bin/mpi_small"
```

**IMPORTANT**

On Bridges, you should not run ```big``` grid calculations locally but on the compute nodes (see [next section](#submit-to-bridges-compute-nodes)). The node on which you program is the login node, it is meant for people to ssh and send jobs to the compute nodes, not run programs. Running the ```small``` grid calculations, something that finishes in maximum 5 seconds is okay, but trying to run the ```big``` grid calculations, therefore using 100% of all CPUs for minutes is a good way to make the login node lag and every other user in a bad mood.

[Go back to table of contents](#table-of-contents)
### Submit to Bridges compute nodes ###
(***Note**: Jobs submitted with this script use the reservation queue ```challenge```, which becomes active on Monday the 8th of July 2019 at 8:00pm local. No need to submit your jobs before that time then because they will be queued but will not be executed until the reservation queue becomes active.*)

Similarly to the section "Run locally", a script has been written for you to easily submit your work to Bridges via SLURM: ```./submit.sh LANGUAGE IMPLEMENTATION SIZE OUTPUT_FILE```. The parameters LANGUAGE, IMPLEMENTATION and SIZE are identical to that passed to the ```run.sh``` script. The output file this time is no longer optional however, because you need a file to which redirect the output of your job.

How does it work? As you have probably seen, there is a ```slurm_scripts``` folder. It contains two SLURM submission scripts for each version (serial, OpenMP, MPI etc...): one for the small grid, one for the big grid. That allows each SLURM script to be tailored (number of nodes, type of nodes, walltime...) for the implementation and size demanded.

If you want to create your own SLURM submission script, there is an additional one called ```general.slurm```, which contains all the commands you may want to use along with their description. You will also find in that submission script links that will lead you to PSC webpages containing more information about submission scripts.

[Go back to table of contents](#table-of-contents)
### Verification ###
One more script to make your life easier and encapsulate all the verification process in a single command: ```./verify.sh YOUR_OUTPUT_FILE```.

How does it work? As you have probably seen, there is a ```reference_outputs``` folder. It contains the output files generated by each version (serial, OpenMP, MPI etc...) untouched, for each programming language (C, FORTRAN). When your optimised version generates an output file, you want to check that your results are correct, and see if you got any faster than the original version. To that end, you want to compare your own output file against the reference output file. This is where this script gets handy; you just pass your output file and the script will:
* automatically detect which language, version and grid size were used to fetch the corresponding reference file
* compare the number of iterations to reach convergence
* compare the final temperature change
* compare the halo swap verification cell value (for MPI versions only)
* compare the total time and give your speed-up

**Note**: for the ```small``` grid size, do not pay attention to the speed-up. The purpose of the ```small``` grid size is solely debugging / testing. In order to have a shorter queueing time, the ```small``` grid size jobs use shared nodes. In other words, if someone is heavily using the node you are sharing, your program will logically become slower but not because of a sudden unknown inefficiency. Again, keep in mind: ```small``` grid size is for checking your program is correct, if you want to evaluate and analyse performance, switch to the ```big``` grid size.

Example: you worked on the MPI version, you submitted it as follow: ```./submit.sh C mpi big my_mpi_big_results.txt```. To verify your output file, just type ```./verify.sh my_mpi_big_results.txt```. This is an example of what you could get:
```
./verify.sh my_mpi_big_results.txt
[SUCCESS] Correct number of arguments received; file to verify is "your_outputs/my_mpi_big_results.txt".
[SUCCESS] The file you passed exists.
[SUCCESS] The language used has been retrieved: C.
[SUCCESS] The version run has been retrieved: mpi_big.
[SUCCESS] The reference file "reference_outputs/C/mpi_big.txt" has been retrieved.
[SUCCESS] Both files have 45 lines.
[SUCCESS] The temperature delta triggered the threshold at iteration 3586 for both.
[SUCCESS] The final maximum change in temperature is 0.009996974331912156 for both.
[SUCCESS] The halo swap verification cell value is 97.243705075613661393 for both.
[TIMINGS] Your version is 1.43 times faster: 89.4s (you) vs 128.5s (reference).
```

[Go back to table of contents](#table-of-contents)
## What kind of optimisations are not allowed? ##

* Changing the compilation process (that is: using different compilers, compiler flags, external libraries etc...). The point in this challenge is not for you to read hundreds of pages of documentation to find an extra flag people may have missed.
* Reducing the amount of work to be done such as ignoring the cells whose value will be zero during the entire simulation.
* Removing the track_progress from the loop or changing the frequency at which it prints.
* Bypassing the buffer copy using a pointer swap.
* Decreasing the accuracy of the calculations by switching from doubles to floats.
* You are not sure about whether a certain optimisation is allowed or not? Just ask :)

[Go back to table of contents](#table-of-contents)
## Send your solution to the competition ##
Participating to the hybrid challenge is for fun; to practice what you have learned during the IHPCSS. But if you want to see how far you got, you can send your solution for it to be assessed and evaluated as part of the competition, and know if you managed to develop the fastest code of your category (CPU or GPU). By the way, the team who will have developed the fastest CPU solution will win the trophy shown at the last slide in the IHPCSS_Coding_challenge_intro.pdf file, and identically for the fastest GPU solution of course.

If you want your solution to be assessed, send an email **by Friday 12th of July 2019 noon (Japan local time)** to CAPELLI Ludovic (email address in the IHPCSS_Coding_challenge_intro.pdf file; next to last slide) containing:
* The full name of each team member (no more than 3 members per team remember), because if your team wins we need to know who we should call on stage :)
* The source file of the version you optimised. Typically, it will certainly mean:
  * hybrid_cpu.c (or hybrid_cpu.F90) if you focused on CPU using the MPI + OpenMP version. Possibly mpi.c (or mpi.F90) if you focused on CPU using the MPI only version instead.
  * hybrid_gpu.c (or hybrid_gpu.F90) if you focused on GPU using the MPI + OpenACC version.

**Note**: there is no need to send the makefile / run.sh / submit.sh scripts or else, send just the source file of the version you optimised. Your code will be compiled and run using the original makefile / run.sh / submit.sh scripts provided, on the ```big``` grid. This way, every participant has their code compiled & run in strictly identical conditions.

**IMPORTANT ABOUT HARD DEADLINE**: solutions must be sent by Friday noon (so that you have a lot of time to play with the code) and at 2pm on Friday the winners are announced. In other words, all submissions must have been collected, run and verified within 2 hours, which is already challenging. Therefore, every email received **AFTER** Friday 12th of July 2019 noon (Japan local time) will be discarded. For the record, remember that you do not need to wait the very last minute to send your solution.

[Go back to table of contents](#table-of-contents)
## Who do I talk to? ##

* CAPELLI Ludovic
* AASAWAT Tanuj Kr

(Their email addresses are in the IHPCSS_Coding_challenge_intro.pdf file; next to last slide)

[Go back to table of contents](#table-of-contents)
## Acknowledgments ##
* [John Urbanic](https://www.psc.edu/staff/urbanic)
* [David Henty](https://www.epcc.ed.ac.uk/about/staff/dr-david-henty)

[Go back to table of contents](#table-of-contents)
