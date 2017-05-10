os161 Environment for CS350 University of Waterloo
---

Install
---
- Login to University of Waterloo account or install Docker on own machine
- In Terminal, navigate to parent directory of where your os161 directory will be, then run :
  ```bash
  curl -s https://raw.githubusercontent.com/andrewparadi/docker-os161/master/bootstrap.sh | bash -s
  ```

Docker
---
- `cd` into the the os161 directory where your `Makefile` was installed
- Start Docker container with `make`
- To build image from scratch, run `make build` or `make rebuild`

Start os161
---
- In Docker container, or in cs350-os161 directory on UW server, run `./build-and-run-kernel.sh`
- It will compile os161 and then run within Tmux with gdb side by side for easy debugging
- Tmux will boot with `c` already typed in the left gdb window. Press enter to `continue` os161 boot

Docker Image
---
- Already have Docker installed and want just an os161 image?
  - Download image with `docker pull andrewparadi/os161:latest`
  - Run with `docker run -it -v {local os161 src directory}:/root/cs350-os161 --entrypoint /bin/bash andrewparadi/os161:latest`

Resources
---
- [Uberi/uw-cs350-development-environment](https://github.com/Uberi/uw-cs350-development-environment)
