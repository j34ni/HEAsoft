FROM quay.io/condaforge/miniforge3:24.11.3-2

# Install curl, download, and verify HEASoft source tarball
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate base && \
    mamba install -y -c conda-forge curl=8.13.0 && \
    curl -o /var/tmp/heasoft-6.35.1src.tar.gz https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft6.35.1/heasoft-6.35.1src.tar.gz && \
    echo "ffec2b5d85a66d7ddea2e69de9dac118  /var/tmp/heasoft-6.35.1src.tar.gz" | md5sum -c - && \
    mamba clean -afy

# Untar source
RUN tar -xzf /var/tmp/heasoft-6.35.1src.tar.gz -C /var/tmp && \
    rm /var/tmp/heasoft-6.35.1src.tar.gz

# Create Conda environment and install dependencies
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda config --set channel_priority strict && \
    mamba clean --all && \
    mamba update -c conda-forge mamba conda && \
    mamba create -y --name heasoft && \
    mamba install -y --name heasoft -c conda-forge \
        gcc=14.2.0 \
        gxx=14.2.0 \
        gfortran=14.2.0 \
        make=4.4.1 \
        perl=5.32.1 \
        readline=8.2 \
        ncurses=6.5 \
        libpng=1.6.47 \
        cfitsio=4.3.1 \
        python=3.12 \
        ccfits=2.6 \
        zlib=1.3.1 \
        curl=8.13.0 \
        gsl=2.7 \
        libxml2=2.13.7 \
        pip=25.1.1 \
        astropy=7.0.1 \
        numpy=2.2.5 \
        scipy=1.15.2 \
        matplotlib=3.10.1 \
        fftw=3.3.10 \
        wcslib=8.2.2 \
        fgsl=1.6.0 \
        six=1.17.0 \
        astropy-iers-data=0.2025.5.5.0.38.14 \
        pyparsing=3.2.3 \
        munkres=1.1.4 \
        packaging=25.0 \
        cycler=0.12.1 \
        python-dateutil=2.9.0.post0 \
        pyyaml=6.0.2 \
        kiwisolver=1.4.7 \
        fonttools=4.57.0 \
        pyerfa=2.0.1.5 \
        contourpy=1.3.2 \
        tk=8.6.13 && \
    mamba clean -afy

# Create custom wcslib.pc
RUN echo "prefix=/opt/conda/envs/heasoft" > /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc && \
    echo "exec_prefix=\${prefix}" >> /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc && \
    echo "libdir=\${prefix}/lib" >> /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc && \
    echo "includedir=\${prefix}/include/wcslib" >> /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc && \
    echo "" >> /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc && \
    echo "Name: wcslib" >> /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc && \
    echo "Description: World Coordinate System library" >> /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc && \
    echo "Version: 8.2.2" >> /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc && \
    echo "Libs: -L\${libdir} -lwcs" >> /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc && \
    echo "Cflags: -I\${includedir}" >> /opt/conda/envs/heasoft/lib/pkgconfig/wcslib.pc

# Compile HEASoft
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate heasoft && \
    export PATH=/opt/conda/envs/heasoft/bin:$PATH && \
    export PKG_CONFIG_PATH=/opt/conda/envs/heasoft/lib/pkgconfig:$PKG_CONFIG_PATH && \
    export CFLAGS="-I/opt/conda/envs/heasoft/include/wcslib $CFLAGS" && \
    export CXXFLAGS="-I/opt/conda/envs/heasoft/include/wcslib $CXXFLAGS" && \
    export LDFLAGS="-L/opt/conda/envs/heasoft/lib -lwcs $LDFLAGS" && \
    export LD_LIBRARY_PATH=/opt/conda/envs/heasoft/lib:$LD_LIBRARY_PATH && \
    ln -sf /opt/conda/envs/heasoft/bin/x86_64-conda-linux-gnu-ar /opt/conda/envs/heasoft/bin/ar && \
    ln -sf /opt/conda/envs/heasoft/bin/x86_64-conda-linux-gnu-gcc /opt/conda/envs/heasoft/bin/gcc && \
    ln -sf /opt/conda/envs/heasoft/bin/x86_64-conda-linux-gnu-g++ /opt/conda/envs/heasoft/bin/g++ && \
    ln -sf /opt/conda/envs/heasoft/bin/x86_64-conda-linux-gnu-gfortran /opt/conda/envs/heasoft/bin/gfortran && \
    sed -i 's|#include <wcsmath.h>|#include <wcslib/wcsmath.h>|' /var/tmp/heasoft-6.35.1/heacore/heasp/wcs.cxx && \
    cd /var/tmp/heasoft-6.35.1/BUILD_DIR && \
    ./configure --prefix=/opt/conda/envs/heasoft \
                --enable-readline \
                --disable-x \
                --with-png=/opt/conda/envs/heasoft \
                --with-components="heacore ftools Xspec" \
                --with-tcl=/opt/conda/envs/heasoft \
                --with-tk=/opt/conda/envs/heasoft \
                --with-wcslib=/opt/conda/envs/heasoft && \
    make && \
    make install && \
    rm -rf /var/tmp/heasoft-6.35.1

# Set environment variables for HEASoft
ENV PYTHONPATH=""
ENV LD_LIBRARY_PATH=""
ENV PATH=/opt/conda/envs/heasoft/bin:$PATH
ENV HEADAS=/opt/conda/envs/heasoft
ENV PYTHONPATH=/opt/conda/envs/heasoft/lib/python3.12/site-packages:$PYTHONPATH
ENV LD_LIBRARY_PATH=/opt/conda/envs/heasoft/lib:$LD_LIBRARY_PATH

# Copy start script
COPY ./start.sh /opt/conda/envs/heasoft/start.sh
RUN chmod +x /opt/conda/envs/heasoft/start.sh

# Set entrypoint
ENTRYPOINT ["/opt/conda/envs/heasoft/start.sh"]
