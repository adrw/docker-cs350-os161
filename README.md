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
