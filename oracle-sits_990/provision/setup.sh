#!/bin/bash

set -e
set -o pipefail
umask 002

DIR_PROVISION=/tmp/provision
DIR_METADATA=/tmp/oracle-metadata
DIR_TEMP=/tmp/sits-install
IDF="${DIR_TEMP}/uniface/bin/idf /asn=${DIR_PROVISION}/idf.asn"
ZIP_SITS="/tmp/provision/990-REL01ZIP.zip"
ZIP_UNIFACE="/tmp/provision/990-REL01LID.zip"

# Oracle environment
ORACLE_BASE=/u01/app/oracle ; export ORACLE_BASE
ORACLE_HOME=${ORACLE_BASE}/product/12.2/dbhome_1 ; export ORACLE_HOME
ORACLE_SID=sits ; export ORACLE_SID
PATH=${PATH}:${ORACLE_HOME}/bin ; export PATH
ORACLE_USER=oracle
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ORACLE_HOME}/lib ; export LD_LIBRARY_PATH

# Java environment
JAVA_HOME=${APPBASE}/jre ; export JAVA_HOME
JRE_HOME=${JAVA_HOME} ; export JRE_HOME
PATH=${JAVA_HOME}/bin:${PATH} ; export PATH
LD_LIBRARY_PATH=${JAVA_HOME}/lib/amd64/server:${LD_LIBRARY_PATH} ; export LD_LIBRARY_PATH

# Uniface environment
mkdir ${DIR_TEMP}
LD_LIBRARY_PATH=${DIR_TEMP}/uniface/lib:${LD_LIBRARY_PATH} ; export LD_LIBRARY_PATH

# Extract Uniface
unzip -qn ${ZIP_UNIFACE} 'uniface990lid.tar.gz' -d ${DIR_TEMP}/uniface
tar --strip-components=1 -xzf ${DIR_TEMP}/uniface/uniface990lid.tar.gz -C ${DIR_TEMP}/uniface

# Extract Uniface licence from SITS
unzip -qn ${ZIP_SITS} 'sits990.zip' -d ${DIR_TEMP}
unzip -qn ${DIR_TEMP}/sits990.zip 'release/9.9.0/sits/cwlm/license9.xml' -d ${DIR_TEMP}
mv ${DIR_TEMP}/release/9.9.0/sits/cwlm/license9.xml ${DIR_TEMP}/license9.xml

# Extract SITS release data
unzip -qn ${ZIP_SITS} 'release990.zip' -d ${DIR_TEMP}
unzip -qn ${DIR_TEMP}/release990.zip 'release/9.9.0/reldata/*' -d ${DIR_TEMP}/sits
mv ${DIR_TEMP}/sits/release/9.9.0/reldata ${DIR_TEMP}/reldata_990

# Create "SITS" database
su - ${ORACLE_USER} -c "dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname sits -sid sits -characterSet WE8MSWIN1252 -sysPassword sits -systemPassword sits -databaseType SINGLEINSTANCE -automaticMemoryManagement false -storageType FS -datafileDestination /u01/app/oracle/oradata"
sed -i "s/\(sits:.*\):N$/\1:Y/" /etc/oratab
echo -e "\nDEFAULT_SERVICE_LISTENER=sits" >> ${ORACLE_HOME}/network/admin/listener.ora

# Start Oracle
su - ${ORACLE_USER} -c "${ORACLE_HOME}/bin/dbstart ${ORACLE_HOME}"

# Initialise Oracle system settings
su - ${ORACLE_USER} << ORACLE
sqlplus / as sysdba << SQLPLUS
WHENEVER SQLERROR EXIT FAILURE;
ALTER SYSTEM SET open_cursors = 2000 SCOPE=BOTH;
ALTER SYSTEM SET processes = 300 SCOPE=spfile;
ALTER SYSTEM SET sessions = 300 SCOPE=spfile;
ALTER SYSTEM SET db_files = 400 SCOPE=spfile;
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
ALTER SYSTEM SET open_cursors = 2000 SCOPE=BOTH;
EXIT;
SQLPLUS
ORACLE

# Uninstall the unwanted (unlicensed) Oracle options
su - ${ORACLE_USER} << ORACLE
cd ${ORACLE_HOME}/rdbms/lib
make -f ins_rdbms.mk asm_off    # Turn off 'Automated Storage Management'
make -f ins_rdbms.mk dm_off     # Turn off 'Oracle Data Mining'
make -f ins_rdbms.mk olap_off   # Turn off 'Oracle OLAP'
make -f ins_rdbms.mk part_off   # Turn off 'Oracle Partitioning'
make -f ins_rdbms.mk rac_off    # Turn off 'Real Application Cluster'
make -f ins_rdbms.mk rat_off    # Turn off 'Real Application Testing'
sqlplus / as sysdba @"?/md/admin/mddins"
ORACLE

# Create SITS Oracle tablespace
su - ${ORACLE_USER} << ORACLE
sqlplus / as sysdba << SQLPLUS
WHENEVER SQLERROR EXIT FAILURE;
CREATE SMALLFILE TABLESPACE SITS_DATA DATAFILE 
    '/u01/app/oracle/oradata/sits/SITS_DATA_01' SIZE 1M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 20000M , 
    '/u01/app/oracle/oradata/sits/SITS_DATA_02' SIZE 1M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 20000M , 
    '/u01/app/oracle/oradata/sits/SITS_DATA_03' SIZE 1M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 20000M , 
    '/u01/app/oracle/oradata/sits/SITS_DATA_04' SIZE 1M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 20000M 
    LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO; 
CREATE SMALLFILE TABLESPACE SITS_INDX DATAFILE 
    '/u01/app/oracle/oradata/sits/SITS_INDX_01' SIZE 1M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 15000M , 
    '/u01/app/oracle/oradata/sits/SITS_INDX_02' SIZE 1M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 15000M , 
    '/u01/app/oracle/oradata/sits/SITS_INDX_03' SIZE 1M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 15000M 
    LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
EXIT;
SQLPLUS
ORACLE

# Create SITS Oracle user
su - ${ORACLE_USER} << ORACLE
sqlplus / as sysdba << SQLPLUS
WHENEVER SQLERROR EXIT FAILURE;
SET VERIFY OFF
CREATE USER sits PROFILE DEFAULT IDENTIFIED BY "sits" DEFAULT TABLESPACE SITS_DATA 
TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON SITS_DATA QUOTA UNLIMITED ON SITS_INDX ACCOUNT UNLOCK;
GRANT ALTER SESSION TO sits            ;
GRANT CREATE DATABASE LINK TO sits     ;
GRANT CREATE DIMENSION TO sits         ;
GRANT CREATE INDEXTYPE TO sits         ;
GRANT CREATE JOB TO sits               ;
GRANT CREATE MATERIALIZED VIEW TO sits ;
GRANT CREATE PROCEDURE TO sits         ;
GRANT CREATE SEQUENCE TO sits          ;
GRANT CREATE SESSION TO sits           ;
GRANT CREATE SYNONYM TO sits           ;
GRANT CREATE TABLE TO sits             ;
GRANT CREATE TRIGGER TO sits           ;
GRANT CREATE TYPE TO sits              ;
GRANT CREATE VIEW TO sits              ;
GRANT GLOBAL QUERY REWRITE TO sits     ;
GRANT UNLIMITED TABLESPACE TO sits     ;
GRANT EXECUTE ON SYS.DBMS_LOCK TO sits ;
GRANT CONNECT TO sits                  ;
GRANT DBA TO sits                      ;
GRANT RESOURCE TO sits                 ;
EXIT;
SQLPLUS
ORACLE

# Import SITS Oracle metadata
su - ${ORACLE_USER} << ORACLE
sqlplus / as sysdba << SQLPLUS
ALTER SESSION SET CURRENT_SCHEMA=SITS;
@${DIR_METADATA}/sits_metadata.SEQUENCE.SEQUENCE.sql
@${DIR_METADATA}/sits_metadata.TYPE.TYPE_SPEC.sql
@${DIR_METADATA}/sits_metadata.TABLE.TABLE.sql
@${DIR_METADATA}/sits_metadata.PACKAGE.PACKAGE_SPEC.sql
@${DIR_METADATA}/sits_metadata.PACKAGE.COMPILE_PACKAGE.PACKAGE_SPEC.ALTER_PACKAGE_SPEC.sql
@${DIR_METADATA}/sits_metadata.FUNCTION.FUNCTION.sql
@${DIR_METADATA}/sits_metadata.PROCEDURE.PROCEDURE.sql
@${DIR_METADATA}/sits_metadata.FUNCTION.ALTER_FUNCTION.sql
@${DIR_METADATA}/sits_metadata.PROCEDURE.ALTER_PROCEDURE.sql
@${DIR_METADATA}/sits_metadata.TABLE.INDEX.INDEX.sql
@${DIR_METADATA}/sits_metadata.TABLE.CONSTRAINT.CONSTRAINT.sql
@${DIR_METADATA}/sits_metadata.VIEW.VIEW.sql
@${DIR_METADATA}/sits_metadata.PACKAGE.PACKAGE_BODY.sql
@${DIR_METADATA}/sits_metadata.TABLE.TRIGGER.sql
EXIT;
SQLPLUS
ORACLE

# Import SITS 9.9.0 release data
cd ${DIR_TEMP}/reldata_990
${IDF} /rma /int=10000 /cpy xml:*.xml def:

# Stop Oracle
su - ${ORACLE_USER} -c "${ORACLE_HOME}/bin/dbshut ${ORACLE_HOME}"

# Remove temporary resources
rm -rf /tmp/dbca
rm -rf ${DIR_TEMP}
rm -rf ${DIR_METADATA}
rm -rf ${DIR_PROVISION}
