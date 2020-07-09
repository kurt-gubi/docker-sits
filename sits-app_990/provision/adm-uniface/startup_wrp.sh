#!/bin/bash
# This script is to restart a failing Uniface URouter.
# The 3 last core dumps will be saved.
# Call this script with the urouter command line switches

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

# The logfile you like to store
LOG=./core
# Init
NUM=0

## For debugging purposes - uncomment to turn on debugging mode
## This is to list the actual result of processes 'grepped'
## ps -ef | grep $PATTERN | grep $RUN_AS_USER | grep -v grep

## This is to echo the value of $PROC_COUNT
## echo $PROC_COUNT


## Debugging mode
## SECTION=1
## echo Entered $0 - section $SECTION 


# Check if urouter process for $RUN_AS_USER exists (if it is greater than 0, it suggests that urouter service is already running and we shouldn't start it again).
if [ $PROC_COUNT -gt 0 ]; then
  ## Debugging mode
  ## SECTION=1.1
  ## echo Entered $0 - section $SECTION 
  
  # Paint yellow text (warning)
  $SETCOLOR_WARNING
  echo "UROUTER process for $RUN_AS_USER may already be running!"
  echo "Exiting now."
  # Paint normal text
  $SETCOLOR_NORMAL
  exit 1; 
fi

## Debugging mode
## SECTION=2
## echo Entered $0 - section $SECTION 

# Check if the current user is the correct user
# If it is not the correct user, inform that it is not the correct user and exits program
if [ "x$USER" != "x$RUN_AS_USER" ]; then
  ## Debugging mode
  ## SECTION=2.1
  ## echo Entered $0 - section $SECTION

  # Paint red text (failure)
  $SETCOLOR_FAILURE
  echo "Current user is \"$USER\", while expected \"$RUN_AS_USER\" to run the service"
  echo "Service is not started."
  echo "Exiting now."
  # Paint normal text
  $SETCOLOR_NORMAL
  exit 1;
# Else, proceed with starting the service
else
  ## Debugging mode
  ## SECTION=2.2
  ## echo Entered $0 - section $SECTION

  # Create a PID file and chown/chgrp the file to the correct user/usergroup
  echo $$ > $PIDFILE
  chown $RUN_AS_USER $PIDFILE
  chgrp $USER_GRP $PIDFILE
fi

# Proceed with starting UROUTER service if all checks passed.
while :
do
  $urouter $*                             # Startup the Router + commandline
  STATUS=$?                               # Status of an ended URouter
  echo "Status: $STATUS"                  # Print status
  NUM=`expr $NUM + 1`                     # Next number for stored LOG file
  sleep 5                                 # Wait 10 seconds
  [ -f "$LOG"     ] && mv $LOG $LOG.$NUM  # Copy the LOG file if exist
  [ "$NUM" -ge 3  ] && NUM=0              # Store the last 3 LOG files only
  [ "$STATUS" = 0 ] && exit               # End of script if status = 0
done
exit
