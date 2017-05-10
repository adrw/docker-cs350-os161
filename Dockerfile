FROM uberi/cs350:latest
MAINTAINER Andrew Paradi <me@andrewparadi.com>

RUN bash -c "/root/cs350-os161/build-and-run-kernel.sh"
