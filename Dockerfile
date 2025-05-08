FROM quay.io/condaforge/miniforge3:24.11.3-2

# Install curl and download HEASoft source tarball
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate base && \
    mamba install -y -c conda-forge curl=8.13.0 && \
    curl -o /var/tmp/heasoft-6.35.1src.tar.gz https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft6.35.1/heasoft-6.35.1src.tar.gz && \
    mamba clean -afy

# Untar source
RUN tar -xzf /var/tmp/heasoft-6.35.1src.tar.gz -C /var/tmp && \
    rm /var/tmp/heasoft-6.35.1src.tar.gz

# Install environment with dependencies (including Python packages for Galaxy)
RUN . /opt/conda/etc/profile.d/conda.sh && \
    mamba create -y --name heasoft && \
    mamba install -y --name heasoft --channel conda-forge \
        astropy=6.1.4 \
        astropy-iers-data=0.2025.5.5.0.38.14 \
        binutils=2.43 \
        ccfits=2.6 \
        cfitsio=4.3.1 \
        contourpy=1.3.2 \
        curl=8.13.0 \
        cycler=0.12.1 \
        fftw=3.3.10 \
        fgsl=1.6.0 \
        flex=2.6.4 \
        fonttools=4.57.0 \
        gcc=12.4.0 \
        gfortran=12.4.0 \
        gsl=2.7 \
        gxx=12.4.0 \
        kiwisolver=1.4.7 \
        libpng=1.6.47 \
        libxml2=2.12.7 \
        make=4.4.1 \
        matplotlib=3.9.2 \
        munkres=1.1.4 \
        ncurses=6.5 \
        numpy=2.1.2 \
        packaging=25.0 \
        perl=5.32.1 \
        pip=25.1.1 \
        pkg-config=0.29.2 \
        pyerfa=2.0.1.5 \
        pyparsing=3.2.3 \
        python=3.12 \
        python-dateutil=2.9.0.post0 \
        pyyaml=6.0.2 \
        readline=8.2 \
        scipy=1.14.1 \
        six=1.17.0 \
        tk=8.6.13 \
        wcslib=8.2.2 \
        xorg-libx11=1.8.10 \
        xorg-libxext=1.3.6 \
        xorg-libxfixes=6.0.1 \
        xorg-libxft=2.3.8 \
        xorg-libxi=1.8.2 \
        xorg-libxmu=1.1.3 \
        xorg-libxt=1.3.0 \
        xorg-xproto=7.0.31 \
        zlib=1.3.1 > mamba_install.log 2>&1 || (cat mamba_install.log && exit 1) && \
    mamba clean --all

# Debug: Verify X11 headers are present
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    ls -l $CONDA_PREFIX/include/X11/Xlib.h || (echo "X11/Xlib.h not found!" && exit 1) && \
    ls -l $CONDA_PREFIX/include/X11/Intrinsic.h || (echo "X11/Intrinsic.h not found!" && exit 1)

# Debug: Verify cfortran.h is present in the correct location
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    ls -l /var/tmp/heasoft-6.35.1/heacore/cfitsio/cfortran.h || (echo "cfortran.h not found in heacore/cfitsio!" && exit 1)

# Debug: Verify libpng is present
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    ls -l $CONDA_PREFIX/lib/libpng* || (echo "libpng not found!" && exit 1)

# Debug: Verify Xspec component is present in the source tree
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    ls -ld /var/tmp/heasoft-6.35.1/Xspec || (echo "Xspec directory not found in source tree!" && exit 1)

# Debug: Verify Tcl/Tk source is present in the tarball
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    ls -ld /var/tmp/heasoft-6.35.1/tcltk/tcl /var/tmp/heasoft-6.35.1/tcltk/tk || (echo "Tcl/Tk source directories not found in tarball!" && exit 1)

# Configure and build HEASoft
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    export PATH=$CONDA_PREFIX/bin:$PATH && \
    export CC=$CONDA_PREFIX/bin/x86_64-conda-linux-gnu-gcc && \
    export CXX=$CONDA_PREFIX/bin/x86_64-conda-linux-gnu-g++ && \
    export FC=$CONDA_PREFIX/bin/x86_64-conda-linux-gnu-gfortran && \
    export CFLAGS="-I$CONDA_PREFIX/include -I$CONDA_PREFIX/include/libxml2 -I$CONDA_PREFIX/include/wcslib -I$CONDA_PREFIX/include/cfitsio -I$CONDA_PREFIX/include/X11 -I/var/tmp/heasoft-6.35.1/heacore/cfitsio -Wno-unused-function -Wno-unused-but-set-variable" && \
    export CXXFLAGS="-I$CONDA_PREFIX/include -I$CONDA_PREFIX/include/libxml2 -I$CONDA_PREFIX/include/wcslib -I$CONDA_PREFIX/include/cfitsio -I$CONDA_PREFIX/include/X11 -I/var/tmp/heasoft-6.35.1/heacore/cfitsio -Wno-unused-function -Wno-unused-but-set-variable" && \
    export LDFLAGS="-L$CONDA_PREFIX/lib -lwcs -lcfitsio -lgsl -lgslcblas -lfftw3 -lreadline -lncurses -lX11 -lXext -lXt -lXmu -lXi -lXft -lXfixes -lpng" && \
    export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH && \
    export PKG_CONFIG_PATH=$CONDA_PREFIX/lib/pkgconfig && \
    ln -sf $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-ar $CONDA_PREFIX/bin/ar && \
    ln -sf $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-ranlib $CONDA_PREFIX/bin/ranlib && \
    ln -sf $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-nm $CONDA_PREFIX/bin/nm && \
    ln -sf $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-objdump $CONDA_PREFIX/bin/objdump && \
    cd /var/tmp/heasoft-6.35.1/BUILD_DIR && \
    ./configure --prefix=$CONDA_PREFIX \
                --x-includes=$CONDA_PREFIX/include \
                --x-libraries=$CONDA_PREFIX/lib && \
    make -j1 2> make_error.log || (cat make_error.log && exit 1) && \
    make install && \
    ls -l $CONDA_PREFIX/bin/tclsh* $CONDA_PREFIX/bin/wish* || (echo "Tcl/Tk binaries not installed!" && exit 1) && \
    rm -rf /var/tmp/heasoft-6.35.1

# Copy start script
COPY ./start.sh /opt/heasoft/start.sh
RUN chmod +x /opt/heasoft/start.sh

# Set entrypoint
ENTRYPOINT ["/opt/heasoft/start.sh"]
