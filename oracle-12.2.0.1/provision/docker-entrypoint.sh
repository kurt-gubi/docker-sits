#!/bin/bash

set -e
set -o pipefail
umask 002

ORA_BASE=/u01/app/oracle
ORA_HOME=${ORA_BASE}/product/12.2/dbhome_1
ORA_OWNER=oracle

# SIGTERM handler
function _term() {
    echo "SIGTERM received, shutting down Oracle!"
    su - ${ORA_OWNER} -c "${ORA_HOME}/bin/dbshut ${ORA_HOME}"    
}
trap _term SIGTERM

# SIGKILL handler
function _kill() {
    echo "SIGKILL received, shutting down Oracle!"
    su - ${ORA_OWNER} -c "${ORA_HOME}/bin/dbshut ${ORA_HOME}"    
}
trap _kill SIGKILL

su - ${ORA_OWNER} -c "${ORA_HOME}/bin/dbstart ${ORA_HOME}"
/bin/sleep infinity
