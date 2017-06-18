os161 Environment for CS350 University of Waterloo
---

Why this os161 image?
---
- You're enrolled in CS350 Operating Systems at UW and want to code on your own machine
- 16% smaller than other os161 images on Docker Hub (1.18GB vs 1.4GB installed, 406MB vs 454MB compressed)
- Included helper files installed with `bootstrap.sh` make build and compile easy
- Common `build-and-run-kernel.sh` script that works on both UW servers and in Docker container

Install
---
- Login to a University of Waterloo server/terminal or install Docker on own machine
- In Terminal, navigate to parent directory of where your os161 directory will be, then run:
  ```bash
  $ curl -s https://raw.githubusercontent.com/andrewparadi/docker-os161/master/bootstrap.sh | bash -s
  ```
- This will create the initial folder directory, initialize a clean install of os161, and download the `Makefile`

Getting Started
---
- `cd` into the `cs350-work` directory where your `Makefile` was installed
- Start Docker container with `make`
  - To build image from scratch, run `make build` or `make rebuild` (build without cached Docker images)
- In Docker container, or in cs350-os161 directory on UW server, run `./build-and-run-kernel.sh`
- It will compile os161 and then run within Tmux with gdb side by side for easy debugging
- Tmux will boot with `c` already typed into gdb (right). Press enter to `continue` os161 boot in left pane

build-and-run.sh options
---
- default: builds from source, runs side by side with GDB in Tmux
- `-b   ` - only build, don't run after
- `-c   ` - continuous build loop
- `-d   ` - set debug mode to output debug text
- `-m   ` - only run, with gdb tmux panels
- `-r   ` - only run, don't build, don't run with gdb
- `-t {}` - run test {test alias}
- `-l {}` - loop all following tests {#} times and log result in logs/ directory
- `-w   ` - clear all logs

Built in test aliases
---
- **Usage** `./build-and-run.sh -l {# of loops} -t {test name | code} -t {...`
- `lock     | l`   - test locks with sy2
- `convar   | cv`  - test conditional variables with sy3
- `traffic  | t`   - A1 test for traffic simulation with 4 15 0 1 0 params
- `onefork  | 2aa` - uw-testbin/onefork
- `pidcheck | 2ab` - uw-testbin/pidcheck
- `widefork | 2ac` - uw-testbin/widefork
- `forktest | 2ad` - testbin/forktest

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
- [**Source Code**](https://github.com/andrewparadi/docker-os161)
