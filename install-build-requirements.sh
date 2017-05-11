#!/bin/bash

if [[ ! -f ./docker-compose.yml ]]; then
  wget https://raw.githubusercontent.com/andrewparadi/docker-os161/master/docker-compose.yml -O docker-compose.yml
fi

if [[ ! -f ./Dockerfile ]]; then
  wget https://raw.githubusercontent.com/andrewparadi/docker-os161/master/Dockerfile -O Dockerfile
fi

if [[ ! -f ./os161.tar.gz ]]; then
  wget -r -l 1 -nd -nH -A gz https://www.student.cs.uwaterloo.ca/~cs350/common/Install161NonCS.html
fi
