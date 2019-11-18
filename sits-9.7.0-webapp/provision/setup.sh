#!/bin/bash

set -e
set -o pipefail
umask 002

DIR_PROVISION=/tmp/provision
DIR_TOMCAT_BASE=/opt/tomcat
DIR_APP_BASE=/opt/tomcat/webapps/sitsvision
DIR_APP_RESOURCES=/opt/sitsvision
USER_TOMCAT=tomcat
SOURCE_TOMCAT=${DIR_PROVISION}/apache-tomcat-9.0.24.tar.gz
ZIP_SITS=${DIR_PROVISION}/970-REL01ZIP.zip
ZIP_UNIFACE=${DIR_PROVISION}/970-REL01LID.zip

# Install package dependencies
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip util-linux-ng

# Create the SITS user/group
useradd -m -d /home/${USER_TOMCAT} ${USER_TOMCAT}

# Deploy Tomcat
mkdir ${DIR_TOMCAT_BASE}
tar -xzf ${SOURCE_TOMCAT} -C ${DIR_TOMCAT_BASE} --strip-components=1

# Deploy Tomcat config
cp ${DIR_PROVISION}/server.xml ${DIR_TOMCAT_BASE}/conf/

# Deploy application
mkdir -p ${DIR_APP_BASE}/WEB-INF/lib
unzip -qn ${ZIP_UNIFACE} 'uniface970lid.tar.gz' -d ${DIR_PROVISION}/uniface
tar --strip-components=1 -xzf ${DIR_PROVISION}/uniface/uniface970lid.tar.gz -C ${DIR_PROVISION}/uniface
cp ${DIR_PROVISION}/uniface/WEB-INF/wrd.jar ${DIR_APP_BASE}/WEB-INF/lib/
cp ${DIR_PROVISION}/web.xml ${DIR_APP_BASE}/WEB-INF/
mkdir ${DIR_APP_RESOURCES}

# Adjust permissions
chmod +x ${DIR_TOMCAT_BASE}/bin/*.sh
chown -R ${USER_TOMCAT}:${USER_TOMCAT} ${DIR_TOMCAT_BASE} ${DIR_APP_RESOURCES}
chmod -R a+rX ${DIR_TOMCAT_BASE} ${DIR_APP_RESOURCES}

# Deploy Docker entry point script
cp ${DIR_PROVISION}/docker-entrypoint.sh /usr/local/bin/

# Remove temporary resources
rm -rf ${DIR_PROVISION}
