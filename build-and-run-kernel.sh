#!/usr/bin/env bash

# runs OS/161 in SYS/161 and attaches GDB, side by side in a tmux window

# set up bash to handle errors more aggressively - a "strict mode" of sorts
set -e # give an error if any command finishes with a non-zero exit code
set -u # give an error if we reference unset variables
set -o pipefail # for a pipeline, if any of the commands fail with a non-zero exit code, fail the entire pipeline with that exit code

cs350dir="/root/cs350-os161"
sys161dir="/root/sys161"

function show_help {
  echo "{ }   {default: builds from source, runs with gdb in Tmux}"
  echo "-b    {only build, don't run after}"
  echo "-r    {only run, don't build, don't run with gdb}"
  echo "-t {} {run test {testcode} }"
  echo "-l    {loop test 100 times and log result}"
  echo "-c    {clear all logs}"
  exit 0
}

div="*************************"
DEFAULT=true
BUILD=false
RUN=false
TEST=false
LOOP=false
while getopts "h?:brlct:" opt; do
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
    l)  LOOP=true
        echo "Option Registered: loop"
        ;;
    c)  rm $cs350dir/log/*.log
        echo "Option Registered: clear logs"
        exit 0
        ;;
    t)  TEST=$OPTARG
        DEFAULT=false
        echo "Option Registered: test ${TEST}"
        # BUILD=true
        ;;
    esac
done

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
  echo "convar  cv  {test conditional variables with sy3}"
  echo "traffic t   {A1 test for traffic simulation with 5 10 1 2 0 params}"
  exit 0
}

if [[ "$TEST" != false ]]; then
  log_ext=".log"
  log_filename="`date '+%Y%m%d-%H%M%S'`-"

  start_test="Test ::"
  test_command=""

  cd $cs350dir/root

  case $TEST in
    l|lock)     echo "${div} ${start_test} Lock ${div}"
                test_command="sy2;q"
                log_filename+="lock${log_ext}"
                ;;
    cv|convar)  echo "${div} ${start_test} Conditional Variable ${div}"
                test_command="sy3;q"
                log_filename+="cond-var${log_ext}"
                ;;
    t|traffic)  echo "${div} ${start_test} A1 Traffic ${div}"
                test_command="sp3 5 10 1 2 0;q"
                log_filename+="traffic${log_ext}"
                ;;
    *|h|\?)     show_test_help
                exit 0
                ;;
  esac

  if [[ "$LOOP" == true ]]; then
    mkdir -p $cs350dir/log
    logfile=$cs350dir/log/$log_filename
    echo -n "1"
    for i in {1..100}
    do
      [ $((i%2)) -eq 0 ] && echo -n "."
      echo "${div} ${i} of 100 ${div}" >> $logfile
      sys161 kernel-$ASSIGNMENT "${test_command}" &>> $logfile
      echo "" >> $logfile
    done
    echo $i
    success=$(grep -o "done" ${logfile} | wc -w)
  else
    sys161 kernel-$ASSIGNMENT "${test_command}"
    i=1
    success=1
  fi

  echo "${div} Test :: Finished ${success} / $i ${div}"
fi
