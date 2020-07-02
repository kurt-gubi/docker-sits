#!/bin/bash

set -e
set -o pipefail
umask 002

SITS_HOME=/u01/siapp/vision/prod

su - uroutpr -c "${SITS_HOME}/uniface/adm/startup.sh"
/bin/sleep infinity
