#!/bin/bash

#SBATCH --job-name=download_cobra
#SBATCH --output=download_cobra.out
#SBATCH --error=download_cobra.err
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --mem=5000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH -c 8
