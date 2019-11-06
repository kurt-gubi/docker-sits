#!/bin/bash

set -e
set -o pipefail
umask 002

# install Oracle dependencies
yum -y install binutils compat-libcap1 compat-libcap1.i686 compat-libstdc++-33 compat-libstdc++-33.i686 elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc.i686 glibc-common glibc-devel glibc-devel.i686 glibc-headers ksh libaio libaio.i686 libaio-devel libaio-devel.i686 libgcc libgcc.i686 libstdc++ libstdc++.i686 libstdc++-devel libstdc++-devel.i686 make numactl-devel sysstat unixODBC unixODBC.i686 unixODBC-devel
# install other dependencies
yum -y install zip unzip libXtst

find /tmp/provision -name '*.sh' -exec chmod a+x {} \;

cd /tmp/

# setup users / groups
groupadd -g 501 oinstall
groupadd -g 502 dba
groupadd -g 503 oper
useradd -m -u 501 -g oinstall -G dba,oper -d /home/oracle -s /bin/bash -c "Oracle Software Owner" oracle
mkdir -p /u01/app/oracle
mkdir /u01/app/oraInventory
chown -R oracle:dba /u01/app

# deploy bash_profile
cp /tmp/provision/oracle.bash_profile /home/oracle/.bash_profile
chown oracle:oinstall /home/oracle/.bash_profile

# extract installation files
unzip /tmp/p10404530_112030_Linux-x86-64_1of7.zip -d /tmp/
unzip /tmp/p10404530_112030_Linux-x86-64_2of7.zip -d /tmp/
chown -R oracle:oinstall /tmp/database

# run pre-install scripts
cp -r /tmp/provision/oracle-install /tmp/
chmod u+x /tmp/oracle-install/*.sh
/tmp/oracle-install/runfixup.sh

# changing "$(MK_EMAGENT_NMECTL)" to "$(MK_EMAGENT_NMECTL) -lnnz11" in ins_emagent.mk
# ( https://community.oracle.com/docs/DOC-921694 )
unzip /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/filegroup38.jar -d /tmp/filegroup38
sed -i 's/^\(\s*\$(MK_EMAGENT_NMECTL)\)\s*$/\1 -lnnz11/g' /tmp/filegroup38/sysman/lib/ins_emagent.mk
cd /tmp/filegroup38
zip -r filegroup38.jar sysman
cd /tmp
mv /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/filegroup38.jar /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/filegroup38.bak
mv /tmp/filegroup38/filegroup38.jar /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/
chown oracle:oinstall /tmp/database/stage/Components/oracle.sysman.agent/10.2.0.4.3/1/DataFiles/filegroup38.jar

# install oracle
su - oracle -c "/tmp/database/runInstaller -silent -ignorePrereq -noconfig -waitforcompletion -responseFile /tmp/oracle-install/response.11-2-0-3.rsp"
/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/11.2.0/dbhome_1/root.sh

# create "SITS" database
su - oracle -c "dbca -silent -responseFile /tmp/provision/dbca-sits.rsp"
sed -i "s/\(sits:.*\):N$/\1:Y/" /etc/oratab
echo -e "\nDEFAULT_SERVICE_LISTENER=sits" >> /u01/app/oracle/product/11.2.0/dbhome_1/network/admin/listener.ora

# initialise system settings
su - oracle << ORACLE
sqlplus / as sysdba << SQLPLUS
ALTER SYSTEM SET open_cursors = 2000 SCOPE=BOTH;
ALTER SYSTEM SET processes = 300 SCOPE=spfile;
ALTER SYSTEM SET sessions = 300 SCOPE=spfile;
ALTER SYSTEM SET db_files = 400 SCOPE=spfile;
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
ALTER SYSTEM SET open_cursors = 2000 SCOPE=BOTH;
SQLPLUS
ORACLE

# deploy startup script
cp /tmp/provision/init-d.dbora /etc/init.d/dbora
chmod 750 /etc/init.d/dbora
chkconfig --level 345 dbora on

# tidy up files
rm -rf /tmp/CVU_11.2.0.3.0_oracle
rm -rf /tmp/database
rm -rf /tmp/dbca
rm -rf /tmp/filegroup38
rm -rf /tmp/logs
rm -rf /tmp/oracle-install
rm -rf /tmp/provision
rm -f /tmp/p10404530_112030_Linux-x86-64_1of7.zip
rm -f /tmp/p10404530_112030_Linux-x86-64_2of7.zip
