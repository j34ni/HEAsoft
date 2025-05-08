FROM quay.io/condaforge/miniforge3:24.11.3-2

# Configure conda-forge channel
RUN conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    mamba update -y -c conda-forge mamba conda

# Download and unpack HEASoft source
RUN . /opt/conda/etc/profile.d/conda.sh && conda activate base && \
    mamba install -y -c conda-forge curl=8.13.0 && \
    curl -o /var/tmp/heasoft-6.35.1src.tar.gz https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft6.35.1/heasoft-6.35.1src.tar.gz && \
    tar -xzf /var/tmp/heasoft-6.35.1src.tar.gz -C /var/tmp && \
    rm /var/tmp/heasoft-6.35.1src.tar.gz && \
    mamba clean -afy
