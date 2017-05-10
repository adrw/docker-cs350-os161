while getopts "c" opt; do
    case "$opt" in
    c)  mkdir -p cs350-work/src
        cd cs350-work
        ;;
    esac
done

if [[ ! -x ./src ]]; then
  mkdir -p src
  # get OS161
  wget https://www.student.cs.uwaterloo.ca/~cs350/os161_repository/os161.tar.gz -O os161.tar.gz
  tar -xzf os161.tar.gz
  rm os161.tar.gz
fi

# install Docker if not already installed
# sudo apt-get install --yes -qq docker.io
# brew install docker

if [[ ! -f ./src/build-and-run-kernel.sh ]]; then
  # get useful processing scripts
  wget https://raw.githubusercontent.com/Uberi/uw-cs350-development-environment/master/build-and-run-kernel.sh -O ./src/build-and-run-kernel.sh
  chmod +x ./src/build-and-run-kernel.sh
fi

# if [[ ! -f ./.tmux.conf ]]; then
#   wget https://raw.githubusercontent.com/andrewparadi/.files/master/ansible/roles/tmux/files/.tmux.conf -O ./.tmux.conf
# fi
#
# if [[ ! -f ./.tmux.conf.local ]]; then
#   wget https://raw.githubusercontent.com/andrewparadi/.files/master/ansible/roles/tmux/files/.tmux.conf.local -O ./.tmux.conf.local
# fi

if [[ ! -f ./Makefile ]]; then
  # get useful makefile
  cd ..
  wget https://raw.githubusercontent.com/andrewparadi/docker-os161/master/Makefile -O Makefile
fi

# get the prebuilt Docker image
docker pull andrewparadi/os161:latest
