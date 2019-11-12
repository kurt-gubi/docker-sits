#!/bin/bash

set -e
set -o pipefail
umask 002

ORA_BASE=/u01/app/oracle
ORA_HOME=$ORA_BASE/product/11.2.0/dbhome_1
ORA_OWNER=oracle

su - $ORA_OWNER -c "$ORA_HOME/bin/dbstart $ORA_HOME"
tailf $ORA_BASE/diag/rdbms/*/*/trace/alert*.log
