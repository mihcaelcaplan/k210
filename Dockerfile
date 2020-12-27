FROM ubuntu:18.04
####### AS ROOT #######
RUN apt-get update && apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev git


# add a non root user
RUN useradd --create-home --shell /bin/bash sdkuser
RUN echo 'sdkuser:sdkuser' | chpasswd
RUN usermod -aG sudo sdkuser
RUN usermod -aG dialout sdkuser

# grab risc-v compiler
USER sdkuser
WORKDIR /home/sdkuser
RUN git clone --recursive https://github.com/kendryte/kendryte-gnu-toolchain
WORKDIR /home/sdkuser/kendryte-gnu-toolchain/riscv-gcc
RUN ./contrib/download_prerequisites
WORKDIR /home/sdkuser/kendryte-gnu-toolchain/
RUN ./configure --prefix=/opt/kendryte-toolchain --with-cmodel=medany --with-arch=rv64imafc --with-abi=lp64f
USER root
RUN make -j8

# add cmake late in the game
RUN apt-get update && apt-get install -y cmake

# add the toolchain to the path
ENV PATH /opt/kendryte-toolchain/bin:$PATH

# grab kflash 
RUN apt-get install -y python3 python3-pip
RUN pip3 install kflash

# deal with scripted entrypoints
COPY entrypoints /usr/local/bin
USER root
RUN chmod +x /usr/local/bin/*.sh

USER sdkuser
WORKDIR /home/sdkuser
ENV DISPLAY=localhost:0
ENTRYPOINT ["/bin/bash"]