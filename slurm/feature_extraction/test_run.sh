#!/bin/bash

#SBATCH --job-name=test_run
#SBATCH --output=test_run.out
#SBATCH --error=test_run.err
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --mem=5000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH -c 2

