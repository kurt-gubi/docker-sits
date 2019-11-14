#! /bin/sh
#
# Script to stop and then start a urouter listener
#
# Recommend it resides in the same directory as insunis, uniface/adm
#
# If you run this script using cron on Solaris important you see FAQ 8216 on mysits.com
#
# Version 1.0 - 06 Aug 2008
#

#
# source environment file, use an absolute path incase script is run from cron etc
# the path to the correct insunis is key as this is how it chooses which urouter to end
#

. /u01/siapp/vision/prod/uniface/adm/insunis

#
# If usys or urouter not set then quit
#

if [ a${USYSBIN} = a ] || [ a${USYSADM} = a ] || [ a${urouter} = a ] 
then
  echo "ERROR - USYSBIN, USYSADM and/or urouter environment variables not set"
  exit 1
fi

#
# shut urouter cleanly using /shut
#

$urouter /shut

#
# If using a second urouter using same bin but different asn file for evision stop that as well
#
#$urouter /asn=$USYSADM/urouter_ev /shut

sleep 5

#
# Check Urouters actually stopped, if not use kill, first with TERM signal, then INT, then finally KILL (-9)
#

ps -ef | grep $USYSBIN/urouter | grep -v grep | awk '{ print $2 }' | xargs -i kill {}
sleep 2
ps -ef | grep $USYSBIN/urouter | grep -v grep | awk '{ print $2 }' | xargs -i kill -INT {}
sleep 2
ps -ef | grep $USYSBIN/urouter | grep -v grep | awk '{ print $2 }' | xargs -i kill -KILL {}
sleep 2

#
# Check if uservers stopped, if not use kill again  first with TERM signal, then INT, then finally KILL
#

ps -ef | grep $USYSBIN/userver | grep -v grep | awk '{ print $2 }' | xargs -i kill {}
sleep 2
ps -ef | grep $USYSBIN/userver | grep -v grep | awk '{ print $2 }' | xargs -i kill -INT {}
sleep 2
ps -ef | grep $USYSBIN/userver | grep -v grep | awk '{ print $2 }' | xargs -i kill -KILL {}

#
# Startup, same as startup.sh
#

nohup $urouter& > /u01/siapp/vision/prod/logs/urouter/urouter.txt 2> /u01/siapp/vision/prod/logs/urouter/urouter.err
#
# If using a second urouter using same bin but different asn file for evision start that as well
#
#nohup $urouter /asn=$USYSADM/urouter_ev& > urouter_ev.txt
sleep 5
echo Urouters started as follows > urouter_running.txt
ps -ef |grep $USYSBIN/urouter | grep -v grep  >> /u01/siapp/vision/prod/logs/urouter/urouter_running.txt
netstat -an | grep 1308 | grep LISTEN  >> /u01/siapp/vision/prod/logs/urouter/urouter_running.txt

#
# If the server is running multiple environments / urouter listeners you
# can create a restart_all.sh script to call all the individual restart scripts
#
# e.g. restart_all.sh
#
#/u01/siapp/vision/live/uniface/adm/restart.sh
#/u01/siapp/vision/test/uniface/adm/restart.sh
#/u01/siapp/vision/train/uniface/adm/restart.sh
