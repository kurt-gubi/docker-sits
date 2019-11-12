#!/bin/bash

set -e
set -o pipefail
umask 002

# Install Oracle dependencies
yum -y install binutils compat-libcap1 compat-libcap1.i686 compat-libstdc++-33 compat-libstdc++-33.i686 elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc.i686 glibc-common glibc-devel glibc-devel.i686 glibc-headers ksh libaio libaio.i686 libaio-devel libaio-devel.i686 libgcc libgcc.i686 libstdc++ libstdc++.i686 libstdc++-devel libstdc++-devel.i686 make numactl-devel sysstat unixODBC unixODBC.i686 unixODBC-devel
# Install other dependencies
yum -y install zip unzip libXtst

DIR_PROVISION=/tmp/provision
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1

find $DIR_PROVISION -name '*.sh' -exec chmod a+x {} \;

# Setup users / groups
groupadd -g 501 oinstall
groupadd -g 502 dba
groupadd -g 503 oper
useradd -m -u 501 -g oinstall -G dba,oper -d /home/oracle -s /bin/bash -c "Oracle Software Owner" oracle
mkdir -p $ORACLE_BASE
mkdir /u01/app/oraInventory
chown -R oracle:dba /u01/app

# Deploy bash_profile
cp $DIR_PROVISION/oracle.bash_profile /home/oracle/.bash_profile
chown oracle:oinstall /home/oracle/.bash_profile

# Extract installation files
unzip $DIR_PROVISION/p10404530_112030_Linux-x86-64_1of7.zip -d /tmp/
unzip $DIR_PROVISION/p10404530_112030_Linux-x86-64_2of7.zip -d /tmp/
chown -R oracle:oinstall /tmp/database

# Run pre-install scripts
cp -r $DIR_PROVISION/oracle-install /tmp/
chmod u+x /tmp/oracle-install/*.sh
/tmp/oracle-install/runfixup.sh

# Changing "$(MK_EMAGENT_NMECTL)" to "$(MK_EMAGENT_NMECTL) -lnnz11" in ins_emagent.mk
# ( https://community.oracle.com/docs/DOC-921694 )
unzip /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/filegroup38.jar -d /tmp/filegroup38
sed -i 's/^\(\s*\$(MK_EMAGENT_NMECTL)\)\s*$/\1 -lnnz11/g' /tmp/filegroup38/sysman/lib/ins_emagent.mk
cd /tmp/filegroup38
zip -r filegroup38.jar sysman
cd /tmp
mv /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/filegroup38.jar /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/filegroup38.bak
mv /tmp/filegroup38/filegroup38.jar /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/
chown oracle:oinstall /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/filegroup38.jar

# Install oracle
su - oracle -c "/tmp/database/runInstaller -silent -ignorePrereq -noconfig -waitforcompletion -responseFile /tmp/oracle-install/response.11-2-0-3.rsp"
/u01/app/oraInventory/orainstRoot.sh
$ORACLE_HOME/root.sh

# Deploy Docker entry point script
cp ${DIR_PROVISION}/docker-entrypoint.sh /usr/local/bin/

# Tidy up files
rm -rf /tmp/CVU_11.2.0.3.0_oracle
rm -rf /tmp/database
rm -rf /tmp/dbca
rm -rf /tmp/filegroup38
rm -rf /tmp/logs
rm -rf /tmp/oracle-install
rm -rf $DIR_PROVISION
