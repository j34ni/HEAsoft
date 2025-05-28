#!/bin/bash

echo "Activate the environment with 'source /opt/heasoft/start.sh'"

source /opt/conda/etc/profile.d/conda.sh
conda activate heasoft
HEADAS=$(ls -d "${CONDA_PREFIX}/x86_64-pc-linux-gnu-libc"*/ | head -n 1)
source $HEADAS/headas-init.sh
export LHEAPERL=$CONDA_PREFIX/bin/perl

exec "$@"
