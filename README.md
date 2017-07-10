Build-Test Script and Docker Image for CS350
===
- You're taking CS350 Operating Systems at UW
- You want to be able to build os161 on your own machine
  - The Docker image here is 24% smaller than other os161 images on Docker Hub (1.12GB vs 1.4GB installed, 345MB vs 454MB compressed)
- You want a build script that has awesome testing features (loops, logging, test aliases) included
  - The `build-test.sh` script here works on both UW servers and with Docker on your own computer

Install
---
- Login to a University of Waterloo server/terminal or install Docker on own machine
- In Terminal, navigate to parent directory of where your os161 directory will be, then run:
  ```bash
  $ curl -s https://raw.githubusercontent.com/andrewparadi/docker-os161/master/bootstrap.sh | bash -s
  ```
- This will create folder structure, do clean install of os161, and download the `Makefile` and `build-test.sh`

Getting Started
---
- Within your os161 directory, start the Docker container with `make`
  - To build image from scratch, run `make build` or `make rebuild` (build without cached Docker images)
- Start your version of os161 with `./build-test.sh` and any of the options below

build-test.sh Options
---
- default: builds from source, runs side by side with GDB in Tmux
- `-b   ` - only build from source, don't run after
- `-c   ` - continuous build loop
- `-d   ` - output debug text when tests are run
- `-m   ` - run with gdb tmux panels without rebuild
- `-r   ` - run only (no gdb tmux or rebuild)
- `-t {}` - run test {test alias}
- `-l {}` - loop all following tests {#} times and log result in `logs/` directory
- `-w   ` - clear all logs

Included Tests
---
- **Usage** `./build-and-run.sh -t {test name | test alias} -t {...`
- **Usage (with loops)** `./build-and-run.sh -l {# of loops} -t {test name | test alias} -t {...`
- `lock         |  l`   - test locks with sy2
- `convar       |  cv`  - test conditional variables with sy3
- `traffic      |  t`   - A1 test for traffic simulation with 4 15 0 1 0 params
- `onefork      |  2aa` - uw-testbin/onefork
- `pidcheck     |  2ab` - uw-testbin/pidcheck
- `widefork     |  2ac` - uw-testbin/widefork
- `forktest     |  2ad` - testbin/forktest
- `hogparty     |  2ba` - uw-testbin/hogparty
- `sty          |  2bb` - testbin/sty
- `argtest      |  2bc` - uw-testbin/argtest
- `argtesttest  |  2bd` - uw-testbin/argtesttest
- `add          |  2be` - testbin/add

Just the Docker Image
---
- Already have Docker installed and want just an os161 image?
- Download image with `docker pull andrewparadi/cs350-os161:latest`
- Run with `docker run -it -v {absolute local os161 src directory}:/root/cs350-os161 --entrypoint /bin/bash andrewparadi/cs350-os161:latest`

Resources
---
- [**Docker Hub andrewparadi/cs350-os161 Image**](https://hub.docker.com/r/andrewparadi/cs350-os161/)
- [**Uberi/uw-cs350-development-environment**](https://github.com/Uberi/uw-cs350-development-environment)
- [**University of Waterloo CS350 Operating Systems Course Site**](https://www.student.cs.uwaterloo.ca/~cs350/)
- [**Source Code on GitHub**](https://github.com/andrewparadi/docker-os161)
