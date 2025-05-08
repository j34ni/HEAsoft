#!/bin/bash
echo "Activating environment..."
. /opt/conda/etc/profile.d/conda.sh && conda activate heasoft
. $CONDA_PREFIX/headas-init.sh
export PATH=$CONDA_PREFIX/bin:$PATH
export PYTHONPATH=$CONDA_PREFIX/lib/python3.10/site-packages:$PYTHONPATH
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
exec "$@"

