#!/bin/bash

echo "Activating environment..."
. /opt/conda/etc/profile.d/conda.sh && conda activate heasoft

export PATH=$CONDA_PREFIX/bin:$PATH
export PYTHONPATH=$CONDA_PREFIX/lib/python3.12/site-packages:$PYTHONPATH
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
export HEADAS=$CONDA_PREFIX/x86_64-pc-linux-gnu-libc2.39

. $HEADAS/headas-init.sh
