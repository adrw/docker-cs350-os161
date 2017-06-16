#!/usr/bin/env bash

# runs OS/161 in SYS/161 and attaches GDB, side by side in a tmux window

# set up bash to handle errors more aggressively - a "strict mode" of sorts
set -e # give an error if any command finishes with a non-zero exit code
set -u # give an error if we reference unset variables
set -o pipefail # for a pipeline, if any of the commands fail with a non-zero exit code, fail the entire pipeline with that exit code

cs350dir="/root/cs350-os161"
sys161dir="/root/sys161"
ASSIGNMENT=ASST2
TEST=false
LOOP=false
OPTIONS=false
DEBUG=false

div="***************************************************************************"
function status {
  echo ""
  echo "[ ${1} ] ${div:${#1}}"
}

function show_help {
  status "Help :: Build and Run Options"
  echo "{ }       { default: builds from source, runs with gdb in Tmux }"
  echo "-b        { only build, don't run after }"
  echo "-c        { continuous build loop }"
  echo "-d        { set debug mode }"
  echo "-m        { only run, with gdb tmux panels }"
  echo "-r        { only run, don't build, don't run with gdb }"
  echo "-t {}     { run test {test alias}  }"
  echo "-l {}     { loop all following tests {#} times and log result }"
  echo "-w        { clear all logs }"
  echo ""
}

function show_test_help {
  status "Help :: Test Aliases"
  echo "./build-and-run.sh -l {# of loops} -t {test name | code} -t {..."
  echo "lock        l   { test locks with sy2 }"
  echo "convar      cv  { test conditional variables with sy3 }"
  echo "traffic     t   { A1 test for traffic simulation with 4 15 0 1 0 params }"
  echo "onefork     2aa { uw-testbin/onefork }"
  echo "pidcheck    2ab { uw-testbin/pidcheck }"
  echo "widefork    2ac { uw-testbin/widefork }"
  echo "forktest    2ad { testbin/forktest }"
  echo ""
}

# display an error if we're not running inside a Docker container
if ! grep docker /proc/1/cgroup -qa; then
  cs350dir="$HOME/cs350-os161"
  sys161dir="/u/cs350/sys161"
  if [[ ! $HOME == /u* ]]; then
    status 'ERROR :: PLEASE RUN THIS SCRIPT ON UW ENVIRONMENT OR DOCKER CONTAINER'
    exit 1
  fi
fi

function run_build {
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
}

function run_continuous_build {
  for (( ; ; )); do
    run_build
  done
}

function run_tmux {
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
}

function run_only {
  cd $cs350dir/root
  sys161 kernel-$ASSIGNMENT "$1"
}

function run_loop {
  mkdir -p $cs350dir/log
  logfile=$cs350dir/log/$log_filename
  echo $logfile
  echo -n "1"
  denom=$((LOOP / 75 + 1))
  chunk_char="."
  chunk_size=$((75 / LOOP - 1))
  chunk=$chunk_char
  for i in $(seq 1 $chunk_size); do chunk+=$chunk_char; done
  for i in $(seq 1 $LOOP)
  do
    [ $denom -eq 0 ] && echo -n $chunk
    [ $denom -ne 0 ] && [ $((i%denom)) -eq 0 ] && echo -n $chunk
    status "${i} of ${LOOP}" >> $logfile
    sys161 kernel-$ASSIGNMENT "${test_command}" &>> $logfile
    echo "" >> $logfile
  done
  echo $i
  success=$(grep -o "${success_word}" ${logfile} | wc -w)
}

function run_test {
  log_ext=".log"
  log_filename="`date '+%Y%m%d-%H%M%S'`-"

  start_test="Test ::"
  test_command=""
  pre_command=""
  if [[ "$DEBUG" == true ]]; then
    pre_command="dl 8192; "
  fi

  cd $cs350dir/root

  case $TEST in
    h|\?)         show_test_help
                  exit 0
                  ;;
    l|lock)       status "${start_test} Lock "
                  test_command="sy2;q"
                  log_filename+="lock${log_ext}"
                  success_word="done"
                  ;;
    cv|convar)    status "${start_test} Conditional Variable "
                  test_command="sy3;q"
                  log_filename+="cond-var${log_ext}"
                  success_word="done"
                  ;;
    t|traffic)    status "${start_test} A1 Traffic 4 15 0 1 0 "
                  test_command="sp3 4 15 0 1 0;q"
                  log_filename+="traffic${log_ext}"
                  success_word="Simulation"
                  ;;
    2aa|onefork)  status "${start_test} uw-testbin/onefork "
                  test_command="${pre_command} p uw-testbin/onefork;q"
                  log_filename+="a2a-onefork${log_ext}"
                  success_word="took"
                  ;;
    2ab|pidcheck) status "${start_test} uw-testbin/pidcheck "
                  test_command="${pre_command} p uw-testbin/pidcheck;q"
                  log_filename+="a2a-pidcheck${log_ext}"
                  success_word="took"
                  ;;
    2ac|widefork) status "${start_test} uw-testbin/widefork "
                  test_command="${pre_command} p uw-testbin/widefork;q"
                  log_filename+="a2a-widefork${log_ext}"
                  success_word="took"
                  ;;
    2ad|forktest) status "${start_test} testbin/forktest "
                  test_command="${pre_command} p testbin/forktest;q"
                  log_filename+="a2a-forktest${log_ext}"
                  success_word="took"
                  ;;
    *)            show_test_help
                  status "${start_test} ${TEST} "
                  test_command="${pre_command} ${TEST};q"
                  log_filename+="a2a-${TEST}${log_ext}"
                  success_word="took"
                  ;;
  esac

  if [[ "$LOOP" != false ]]; then
    run_loop
  else
    run_only "${test_command}"
    i=1
    success=1
  fi

  status "Test :: Fin ${success} / $i"
}



status "os161 :: ${ASSIGNMENT}"

while getopts "h?:bcdmrwl:t:" opt; do
  OPTIONS=true
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    b)  echo "Option Registered: build"
        run_build
        ;;
    c)  echo "Option Registered: continuous build"
        run_continuous_build
        ;;
    d)  echo "Option Registered: run with debug output"
        DEBUG=true
        ;;
    m)  echo "Option Registered: run with gdb tmux"
        run_tmux
        ;;
    r)  echo "Option Registered: run"
        run_only ""
        ;;
    l)  LOOP=$OPTARG
        echo "Option Registered: loop following test ${LOOP} times"
        ;;
    t)  TEST=$OPTARG
        echo "Option Registered: test ${TEST}"
        run_test
        TEST=false
        ;;
    w)  touch $cs350dir/log/tmp.log; rm $cs350dir/log/*.log
        echo "Option Registered: wipe logs"
        status "Logs Cleared"
        exit 0
        ;;
    esac
done

if [[ "$OPTIONS" == false ]]; then
  run_build
  run_tmux
fi

exit 0
