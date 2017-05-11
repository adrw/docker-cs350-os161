#!/usr/bin/env bash

# runs OS/161 in SYS/161 and attaches GDB, side by side in a tmux window

function show_help {
  echo "{ }   {default: builds from source, runs with gdb in Tmux}"
  echo "-b    {only build, don't run after}"
  echo "-r    {only run, don't build, don't run with gdb}"
  echo "-t {} {run test {testcode} }"
  exit 0
}

div="*************************"
DEFAULT=true
BUILD=false
RUN=false
TEST=false
while getopts "h?:brt:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    b)  DEFAULT=false
        BUILD=true
        echo "Option Registered: build"
        ;;
    r)  DEFAULT=false
        RUN=true
        echo "Option Registered: run"
        ;;
    t)  TEST=$OPTARG
        DEFAULT=false
        echo "Option Registered: test ${TEST}"
        # BUILD=true
        ;;
    esac
done

# set up bash to handle errors more aggressively - a "strict mode" of sorts
set -e # give an error if any command finishes with a non-zero exit code
set -u # give an error if we reference unset variables
set -o pipefail # for a pipeline, if any of the commands fail with a non-zero exit code, fail the entire pipeline with that exit code

cs350dir="/root/cs350-os161"
sys161dir="/root/sys161"

# display an error if we're not running inside a Docker container
if ! grep docker /proc/1/cgroup -qa; then
  cs350dir="$HOME/cs350-os161"
  sys161dir="/u/cs350/sys161"
  if [[ ! $HOME == /u* ]]; then
    echo 'ERROR: PLEASE RUN THIS SCRIPT ON UW ENVIRONMENT OR IN DOCKER CONTAINER'
    exit 1
  fi
fi

ASSIGNMENT=ASST1
echo "${div} os161 :: ${ASSIGNMENT} ${div}"

if [[ "$DEFAULT" == true || "$BUILD" == true ]]; then
  # copy in the SYS/161 default configuration
  mkdir --parents $cs350dir/root
  cp --update $sys161dir/share/examples/sys161/sys161.conf.sample $cs350dir/root/sys161.conf

  # build kernel
  cd $cs350dir/os161-1.99
  ./configure --ostree=$cs350dir/root --toolprefix=cs350-
  cd $cs350dir/os161-1.99/kern/conf
  ./config $ASSIGNMENT
  cd $cs350dir/os161-1.99/kern/compile/$ASSIGNMENT
  bmake depend
  bmake
  bmake install

  # build user-level programs
  cd $cs350dir/os161-1.99
  bmake
  bmake install

  cd $cs350dir/root
fi


if [[ "$DEFAULT" == true ]]; then
  # set up the simulator run
  cd $cs350dir/root
  if ! which tmux &> /dev/null; then
    apt-get install --yes -qq tmux
  fi

  # set up a tmux session with SYS/161 in one pane, and GDB in another
  tmux kill-session -t os161 || true # kill old tmux session, if present
  tmux new-session -d -s os161 # start a new tmux session, but don't attach to it just yet
  tmux split-window -v -t os161:0 # split the tmux window in half
  tmux send-keys -t os161:0.0 'sys161 -w kernel' C-m # start SYS/161 and wait for GDB to connect
  tmux send-keys -t os161:0.1 'cs350-gdb kernel' C-m # start GDB
  sleep 0.5 # wait a little bit for SYS/161 and GDB to start
  tmux send-keys -t os161:0.1 "dir $cs350dir/os161-1.99/kern/compile/$ASSIGNMENT" C-m # in GDB, switch to the kernel dir
  tmux send-keys -t os161:0.1 'target remote unix:.sockets/gdb' C-m # in GDB, connect to SYS/161
  tmux send-keys -t os161:0.1 'c' # in GDB, fill in the continue command automatically so the user can just press Enter to continue
  tmux attach-session -t os161 # attach to the tmux session
elif [[ "$RUN" == true ]]; then
  cd $cs350dir/root
  sys161 kernel-$ASSIGNMENT
fi

function show_test_help {
  echo "### INVALID TEST CODE ###"
  echo "Use any of the following test codes in ./build-and-run.sh -t {test code}"
  echo "lock    l   {test locks with sy2}"
  echo "convar  cv  {test conditional variables with sy2}"
  exit 0
}

if [[ "$TEST" ]]; then
  start_test="Test ::"
  cd $cs350dir/root
  case $TEST in
    l|lock)     echo "${div} ${start_test} Lock ${div}"
                sys161 kernel-$ASSIGNMENT "sy2;q"
                ;;
    cv|convar)  echo "${div} ${start_test} Conditional Variable ${div}"
                sys161 kernel-$ASSIGNMENT "sy3;q"
                ;;
    *|h|\?)     show_test_help
                exit 0
                ;;
  esac
  echo "${div} Test :: Finished ${div}"
fi
