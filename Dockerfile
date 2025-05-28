# Use a pinned mambaforge version for reproducibility
FROM condaforge/mambaforge:24.7.1-0

# Install system-level dependencies for X11 and graphics
RUN apt-get update && apt-get install -y \
    libx11-6 \
    libxext6 \
    libxt6 \
    libpng16-16 \
    x11-utils \
    xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create a conda environment and install run dependencies
RUN mamba create -n heasoft python>=3.12 && \
    conda install -n heasoft -c bioconda heasoft=6.35.1 && \
    conda clean --all --yes 

# Copy the start.sh script
COPY ./start.sh /opt/heasoft/start.sh

# Set the entrypoint to the start.sh script
ENTRYPOINT ["/opt/heasoft/start.sh"]

