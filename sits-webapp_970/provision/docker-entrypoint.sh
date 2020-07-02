#!/bin/bash

set -e
set -o pipefail
umask 002

TOMCAT_HOME=/opt/tomcat

su - tomcat -c "${TOMCAT_HOME}/bin/startup.sh"
/bin/sleep infinity
