os161 Environment for University of Waterloo CS350
---

Getting Started
---
- To use only the image, install Docker and use `docker pull andrewparadi/os161`
  - Run with `docker run -it -v {local os161 src directory}:/root/cs350-os161 --entrypoint /bin/bash andrewparadi/os161`
- To build the image yourself, follow the Build Instructions below
- Don't want to remember `docker run -it -v ...`? Clone this repo
  - `git clone git@github.com:andrewparadi/docker-os161.git`
  - In the repo, create '/src' directory and extract [`os161.tar.gz`](http://www.student.cs.uwaterloo.ca/~cs350/os161_repository/os161.tar.gz) os161 source code into it
  - In Terminal, run `make` and continue with the [os161 install instructions](https://www.student.cs.uwaterloo.ca/~cs350/common/Install161.html)

File Structure
---
- `/src`: your src code for os161
- `/uw-src`: tar.gz files for os161 and sys161 build tools

Build Instructions
---
`docker-compose.yml`
```yml
api:
  image: andrewparadi/os161:latest
  # Comment out image ^, uncomment below to build image for yourself
  # build:
  #   context: ./
  #   dockerfile: Dockerfile
```
- To build your own image, comment the `image: a...` line, and uncomment the `build, context, dockerfile`

Makefile
---
- Run `make` or `make run` and image builds if it doesn't exist, and then runs
- Run `make build` to build image
- Run `make rebuild` to build without `FROM image` or previously built steps cache

Resources
---
- [Uberi/uw-cs350-development-environment](https://github.com/Uberi/uw-cs350-development-environment)
