#!/bin/bash
#SBATCH --job-name=test_run
#SBATCH --output=test_run.out
#SBATCH --error=test_run.err
#SBATCH --time=00:02:00
#SBATCH --nodes=1
#SBATCH --mem=10000M
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:a30:1          # Request 1x A30 GPU
#SBATCH --partition=gpu          # Force job onto the A30 GPU nodes

echo "Running on $(hostname)"
nvidia-smi
