#!/bin/bash

#SBATCH --job-name=run_feature_extraction
#SBATCH --output=run_feature_extraction.out
#SBATCH --error=run_feature_extraction.err
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --mem=12000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH -c 8

