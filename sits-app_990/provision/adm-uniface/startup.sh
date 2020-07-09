#!/bin/bash
#
# Script to start a urouter listener
#

##################################################################
##################### Define parameters here #####################
##################################################################

# Path to SITS environment and source it
SITSENV=/u01/siapp/vision/prod/adm/sitsenv
. $SITSENV

# UROUTER startup script with wrapper
START_WRP=$USYSADM/startup_wrp.sh

# Define grep pattern to catch
PATTERN=urouter

##################################################################
####### Should require no further changes beyond this line #######
##################################################################

# Check for number of urouter process occurance for $RUN_AS_USER
PROC_COUNT=`ps -C urouter -o user:$USERID -o pid,comm | grep -i -w $RUN_AS_USER | wc -l`

## For debugging purposes - uncomment to turn on debugging mode
## This is to list the actual result of processes 'grepped'
## ps -ef | grep $PATTERN | grep $RUN_AS_USER | grep -v grep

## This is to echo the value of $PROC_COUNT
## echo $PROC_COUNT


## Debugging mode
## SECTION=1
## echo Entered $0 - section $SECTION 

# Check if urouter process for $RUN_AS_USER exists (if it is more than 0, it suggests that urouter service is already running and we shouldn't start it again).
if [ $PROC_COUNT -gt 0 ]; then
  ## Debugging mode
  ## SECTION=1.1
  ## echo Entered $0 - section $SECTION 
  
  # Paint yellow text (warning)
  $SETCOLOR_WARNING
  echo "UROUTER process for $RUN_AS_USER may already be running!"
  echo "Exiting now on $(date)."
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
  echo "Exiting now on $(date)."
  # Paint normal text
  $SETCOLOR_NORMAL
  exit 1;
# Else, proceed with starting the service
else
  ## Debugging mode
  ## SECTION=2.2
  ## echo Entered $0 - section $SECTION

  # Paint bold light green text (starting)
  MSG="Starting UROUTER service: on $(date)"
  echo -e  "\033[1m\033[32m$MSG\033[0m"

  # Start UROUTER Service (with '&' to run in background)
  $START_WRP > /dev/null 2>&1 &

  RETVAL=$?
  if [ $RETVAL -eq 0 ]; then
    # Pause for 3 seconds to allow the process to complete starting up
    sleep 3
    MSG="UROUTER service is now started on $(date)."
    echo -e  "\033[32m$MSG\033[0m"
  fi
fi
