#!/bin/bash
#
# Script to stop a urouter listener
#

# Source function file from init.d folder (used for coloring text)
. /etc/init.d/functions

##################################################################
##################### Define parameters here #####################
##################################################################

# Path to SITS environment and source it
SITSENV=/u01/siapp/vision/prod/adm/sitsenv
. $SITSENV

# Program name (same as program description in /etc/init.d/uroutpr - line 14)
prog="uroutpr"

# Define a PID file for monitoring
PIDFILE=$USYSADM/$prog.pid

# Define grep pattern to catch
PATTERN=urouter

##################################################################
####### Should require no further changes beyond this line #######
##################################################################

# Check for number of urouter process occurance for $RUN_AS_USER
PROC_COUNT=`ps -C urouter -o user:$USERID -o pid,comm | grep -i -w $RUN_AS_USER | wc -l`

# Get PID of parent bash process for urouter with wrapper
#pid=(`ps -ef | grep -i $PATTERN | grep -i -w $RUN_AS_USER | grep -v grep | awk '{print $3}'`)
pid=(`ps -C urouter -o user:$USERID -o ppid,pid,comm |grep -i -w $RUN_AS_USER | awk '{print $2}'`)
#
# If usys or urouter not set then quit
#

## Debugging mode
## SECTION=1
## echo Entered $0 - section $SECTION

if [ a${USYSBIN} == a ] || [ a${USYSADM} == a ] || [ a${urouter} == a ]; then 
  ## Debugging mode
  ## SECTION=1.1
  ## echo Entered $0 - section $SECTION

  echo "ERROR - USYSBIN, USYSADM and/or urouter environment variables not set"
  exit 1
fi

## Debugging mode
## SECTION=2
## echo Entered $0 - section $SECTION

# Check for a urouter process belonging to $RUN_AS_USER - if there is no such process, there is no need to proceed further.
if [ $PROC_COUNT -eq 0 ]; then 
  ## Debugging mode
  ## SECTION=2.1
  ## echo Entered $0 - section $SECTION

  # Paint yellow text (warning)
  $SETCOLOR_WARNING
  echo "UROUTER process for $RUN_AS_USER does not seem to be running!"
  echo "Exiting now on $(date)."
  # Paint normal text
  $SETCOLOR_NORMAL
  exit 1; 
fi

## Debugging mode
## SECTION=3
## echo Entered $0 - section $SECTION

# Check if the current user is the correct user
# If it is not the correct user, inform that it is not the correct user and exits program
if [ "x$USER" != "x$RUN_AS_USER" ]; then
  ## Debugging mode
  ## SECTION=3.1
  ## echo Entered $0 - section $SECTION

  # Paint red text (failure)
  $SETCOLOR_FAILURE
  echo "Current user is \"$USER\", while expected \"$RUN_AS_USER\" to stop the service"
  echo "Service is not stopped."
  echo "Exiting now on $(date)."
  # Paint normal text
  $SETCOLOR_NORMAL
  exit 1;
fi

# Else, proceed with stopping the service

## Debugging mode
## SECTION=4
## echo Entered $0 - section $SECTION

# Paint bold light red text (stopping)
MSG="Stopping UROUTER service: on $(date)"
echo -e  "\033[1m\033[31m$MSG\033[0m"

## Debugging mode
## SECTION=5
## echo Entered $0 - section $SECTION

# To cater for urouter process started with wrapper script
# Check for a PID file to kill parent bash process (for use with startup_wrp.sh)
# If PID file exists, remove PID file after killing the process

if [ -f $PIDFILE ]; then 
  ## Debugging mode
  ## SECTION=5.1
  ## echo Entered $0 - section $SECTION

  # Read PIDFILE
  pid_pidfile=`cat $PIDFILE`

  # If the current parent PID matches the PID in the PIDFILE, kill it
  if [ x$pid_pidfile == x$pid ]; then
    ## Debugging mode
    ## SECTION=5.2
    ## echo Entered $0 - section $SECTION

    kill $pid
  fi

  # Cleanup PIDFILE
  rm -f $PIDFILE
fi

## Debugging mode
## SECTION=6
## echo Entered $0 - section $SECTION

# To cater for urouter process started with wrapper script
# Check if there is still a parent process (batch) attached to the urouter process, if yes, kill it (or urouter process will keep spawning)
pid_check=(`ps -ef | grep $pid | grep -v grep | wc -l`)
if [ $pid_check != 0 ]; then
  ## Debugging mode
  ## SECTION=6.1
  ## echo Entered $0 - section $SECTION

  # Check PID of parent process
  pid=(`ps -C urouter -o user:$USERID -o ppid,pid,comm |grep -i -w $RUN_AS_USER | awk '{print $2}'`)


  # If PID is not equal to 1, kill it
  if [ $pid != 1 ]; then
    ## Debugging mode
    ## SECTION=6.2
    ## echo Entered $0 - section $SECTION

    kill $pid
  fi
fi

## Debugging mode
## SECTION=7
## echo Entered $0 - section $SECTION

#
# shut urouter cleanly using /shut
#

$urouter /shut

#
# If using a second urouter using same bin but different asn file for evision stop that as well
#
#$urouter /asn=$USYSADM/urouter_ev /shut

## Debugging mode
## SECTION=8
## echo Entered $0 - section $SECTION

sleep 5

#
# Check Urouters actually stopped, if not use kill, first with TERM signal, then INT, then finally KILL (-9)
#
pid=(`ps -C urouter -o user:$USERID -o ppid,pid,comm |grep -i -w $RUN_AS_USER | awk '{print $2}'`)

ps -C urouter -o user:$USERID -o pid |grep -i -w $RUN_AS_USER | awk '{ print $2 }' | xargs -i kill {}
sleep 2
ps -C urouter -o user:$USERID -o pid |grep -i -w $RUN_AS_USER | awk '{ print $2 }' | xargs -i kill -INT {}
sleep 2
ps -C urouter -o user:$USERID -o pid |grep -i -w $RUN_AS_USER | awk '{ print $2 }' | xargs -i kill -KILL {}
sleep 2

#
# Check if uservers stopped, if not use kill again  first with TERM signal, then INT, then finally KILL
#

## Debugging mode
## SECTION=9
## echo Entered $0 - section $SECTION
ps -C userver -o user:$USERID -o pid |grep -i -w $RUN_AS_USER | awk '{ print $2 }' | xargs -i kill  {}
sleep 2
ps -C userver -o user:$USERID -o pid |grep -i -w $RUN_AS_USER | awk '{ print $2 }' | xargs -i kill -INT {}
sleep 2
ps -C userver -o user:$USERID -o pid |grep -i -w $RUN_AS_USER | awk '{ print $2 }' | xargs -i kill -KILL {}
sleep 2

MSG="UROUTER service is now stopped on $(date)."
echo -e  "\033[31m$MSG\033[0m"
