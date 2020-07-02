#!/bin/bash

set -e
set -o pipefail
umask 002

# Install Oracle dependencies
yum -y install binutils compat-libcap1 compat-libstdc++ compat-libstdc++ gcc gcc-c++ glibc glibc glibc-devel glibc-devel ksh libaio libaio libaio-devel libaio-devel libgcc libgcc libstdc++ libstdc++ libstdc++-devel libstdc++-devel libXi libXi libXrender libXtst libXtst make sysstat
# Install other dependencies
yum -y install unzip

DIR_PROVISION=/tmp/provision
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=${ORACLE_BASE}/product/12.2/dbhome_1

find ${DIR_PROVISION} -name '*.sh' -exec chmod a+x {} \;

# Setup users / groups
groupadd -g 501 oinstall
groupadd -g 502 dba
groupadd -g 503 oper
useradd -m -u 501 -g oinstall -G dba,oper -d /home/oracle -s /bin/bash -c "Oracle Software Owner" oracle
mkdir -p ${ORACLE_BASE}
mkdir /u01/app/oraInventory
chown -R oracle:dba /u01/app

# Deploy bash_profile
cp ${DIR_PROVISION}/oracle.bash_profile /home/oracle/.bash_profile
chown oracle:oinstall /home/oracle/.bash_profile

# Extract installation files
unzip ${DIR_PROVISION}/linuxx64_12201_database.zip -d /tmp/
chown -R oracle:oinstall /tmp/database

# Install oracle
su - oracle -c "/tmp/database/runInstaller -silent -ignorePrereq -noconfig -waitforcompletion -responseFile ${DIR_PROVISION}/response.12-2-0-1.rsp"
/u01/app/oraInventory/orainstRoot.sh
${ORACLE_HOME}/root.sh

# Deploy Docker entry point script
cp ${DIR_PROVISION}/docker-entrypoint.sh /usr/local/bin/

# Tidy up files
rm -rf /tmp/database
rm -rf ${DIR_PROVISION}
