FROM debian:latest
MAINTAINER Anthony Zhang <azhang9@gmail.com>
MAINTAINER Andrew Paradi <me@andrewparadi.com>

# this basically sets up a Docker image according to the instructions on https://www.student.cs.uwaterloo.ca/~build/common/Install161NonCS.html
# a copy of that page is also included in this repository in case the URL ever changes or goes down

# preliminary setup
RUN apt-get update
RUN apt-get install software-properties-common --yes
RUN apt-get update
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get install build-essential --yes
RUN apt-get install gcc-4.9 --yes
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 50 # compile everything with GCC 4.9

# step 1: download all of the files listed in the Step 1 table on the instructions page into ./uw-src directory
# done by setup.sh script triggered automatically during any `make` command

# step 2: install binutils for os161
ADD ./uw-src/os161-binutils.tar.gz /root/cs350
WORKDIR /root/cs350/binutils-2.17+os161-2.0.1
RUN ./configure --nfp --disable-werror --target=mips-harvard-os161 --prefix=/root/sys161/tools
RUN make
RUN make install

# step 3: put sys161 stuff on the PATH
RUN mkdir /root/sys161/bin
ENV PATH /root/sys161/bin:/root/sys161/tools/bin:$PATH

# step 4: install GCC MIPS cross-compiler
ADD ./uw-src/os161-gcc.tar.gz /root/cs350
WORKDIR /root/cs350/gcc-4.1.2+os161-2.0
RUN ./configure -nfp --disable-shared --disable-threads --disable-libmudflap --disable-libssp --target=mips-harvard-os161 --prefix=/root/sys161/tools
RUN make
RUN make install

# step 5: install GDB for os161
RUN apt-get install libncurses5-dev --yes
ADD ./uw-src/os161-gdb.tar.gz /root/cs350
WORKDIR /root/cs350/gdb-6.6+os161-2.0
RUN ./configure --target=mips-harvard-os161 --prefix=/root/sys161/tools --disable-werror
RUN make
RUN make install

# step 6: install bmake for os161
ADD ./uw-src/os161-bmake.tar.gz /root/cs350
ADD ./uw-src/os161-mk.tar.gz /root/cs350
WORKDIR /root/cs350/bmake
RUN ./boot-strap --prefix=/root/sys161/tools | sed '1,/Commands to install into \/root\/sys161\/tools\//d' | bash

# step 7: set up links for toolchain binaries
RUN mkdir --parents /root/sys161/bin
WORKDIR /root/sys161/tools/bin
RUN sh -c 'for i in mips-*; do ln -s /root/sys161/tools/bin/$i /root/sys161/bin/cs350-`echo $i | cut -d- -f4-`; done'
RUN ln -s /root/sys161/tools/bin/bmake /root/sys161/bin/bmake

# step 8: install sys161
ADD ./uw-src/sys161.tar.gz /root/cs350
WORKDIR /root/cs350/sys161-1.99.06
RUN ./configure --prefix=/root/sys161 mipseb
RUN make
RUN make install
RUN ln -s /root/sys161/share/examples/sys161/sys161.conf.sample /root/sys161/sys161.conf

# step 9: install os161
# VOLUME /root/cs350-os161 # extracting the archive should be done on the host side
# ./src volume mounted automatically to /root/cs350-os161 within makefile

# delete all original src code to compress docker image size
WORKDIR /root
RUN rm -rf /root/cs350

# make sure to start commands in the os161 folder
WORKDIR /root/cs350-os161
