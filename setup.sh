#!/bin/bash

if [[ ! -x ./uw-src ]]; then
  mkdir -p ./uw-src
  cd ./uw-src;  wget -r -l 1 -nd -nH -A gz https://www.student.cs.uwaterloo.ca/~cs350/common/Install161NonCS.html
fi
