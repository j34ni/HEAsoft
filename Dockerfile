FROM quay.io/jeani/heasoft:main

# Create conda environment
RUN . /opt/conda/etc/profile.d/conda.sh && \
    mamba create -y --name heasoft python=3.12 && \
    conda activate heasoft && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    mamba update -y -c conda-forge mamba conda && \
    conda clean --all --yes

# Install packages
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    mamba install -y \
        _libgcc_mutex=0.1=conda_forge \
        _openmp_mutex=4.5=2_gnu \
        astropy=6.1.4 \
        astropy-iers-data=0.2025.5.5.0.38.14 \
        contourpy=1.3.0 \
        cycler=0.12.1 \
        fonttools=4.57.0 \
        gcc=15.1.0 \
        gfortran=15.1.0 \
        gxx=15.1.0 \
        kiwisolver=1.4.7 \
        libgcc-ng=15.1.0 \
        libgfortran-ng=15.1.0 \
        libgomp=15.1.0 \
        libpng=1.6.47 \
        libstdcxx-ng=15.1.0 \
        make=4.4.1 \
        matplotlib=3.9.2 \
        munkres=1.1.4 \
        ncurses=6.5 \
        numpy=2.1.2 \
        perl=5.32.1 \
        perl-file-which \
        pip=25.1.1 \
        pyerfa=2.0.1.5 \
        pyparsing=3.2.3 \
        python=3.12 \
        python-dateutil=2.9.0.post0 \
        pyyaml=6.0.2 \
        readline=8.2 \
        scipy=1.14.1 \
        six=1.16.0 \
        xorg-libx11=1.8.12 \
        xorg-libxt=1.3.0 \
        xorg-libxext=1.3.6 \
        xorg-xproto=7.0.31 \
        xorg-util-macros=1.20.2 \
        xorg-kbproto=1.0.7 \
        xorg-inputproto=2.3.2 \
        xorg-xf86vidmodeproto=2.3.1 \
        xorg-xextproto=7.3.0 \
        zlib=1.3.1 && \
    mamba clean --all --yes && \
    perl -MCPAN -e 'install Devel::CheckLib'

# Configure and build HEASoft-6.35.1 from the previously downloaded source
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    export CC=$CONDA_PREFIX/bin/x86_64-conda-linux-gnu-gcc && \
    export CXX=$CONDA_PREFIX/bin/x86_64-conda-linux-gnu-g++ && \
    export FC=$CONDA_PREFIX/bin/x86_64-conda-linux-gnu-gfortran && \
    export PERL=$CONDA_PREFIX/bin/perl && \
    export PYTHON=$CONDA_PREFIX/bin/python && \
    ln -sf $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-ar $CONDA_PREFIX/bin/ar && \
    ln -sf $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-ranlib $CONDA_PREFIX/bin/ranlib && \
    ln -sf $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-nm $CONDA_PREFIX/bin/nm && \
    ln -sf $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-objdump $CONDA_PREFIX/bin/objdump && \
    ln -sf $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-ld $CONDA_PREFIX/bin/ld && \
    unset CFLAGS CXXFLAGS FFLAGS LDFLAGS build_alias host_alias && \
    export CFLAGS="-I$CONDA_PREFIX/include" && \
    export LDFLAGS="-L$CONDA_PREFIX/lib -lz" && \
    cd /var/tmp/heasoft-6.35.1/BUILD_DIR && \
    ./configure --prefix=$CONDA_PREFIX \
                --x-includes=$CONDA_PREFIX/include \
                --x-libraries=$CONDA_PREFIX/lib && \
    make && \
    make install && \
    rm -rf /var/tmp/heasoft-6.35.1

# Install heasoftpy-6.35.1
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    export HEADAS=$CONDA_PREFIX/x86_64-pc-linux-gnu-libc2.39 && \
    . $HEADAS/headas-init.sh && \
    pip install git+https://github.com/HEASARC/heasoftpy.git

# Copy start script
COPY start.sh /opt/heasoft/start.sh
RUN chmod +x /opt/heasoft/start.sh

WORKDIR /workspace
ENTRYPOINT ["/opt/heasoft/start.sh"]
