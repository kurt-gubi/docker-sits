#!/bin/bash

set -e
set -o pipefail
umask 002

USER_SITS=uroutpr
GROUP_SITS=sitsvision
DIR_PROVISION=/tmp/provision
DIR_APP=/u01/siapp/vision/prod
DIR_TEMP=/tmp/sits-install
INSTALL_DIR_PARAMS="-o ${USER_SITS} -g ${GROUP_SITS} -m 755 -d"
ZIP_SITS="/tmp/provision/970-REL01ZIP.zip"
ZIP_UNIFACE="/tmp/provision/970-REL01LID.zip"
ZIP_ALLFIXES="/tmp/provision/970-ALLFIXES.zip"

# Install package dependencies
yum -y install dos2unix libaio unzip util-linux-ng

# Create the SITS user/group
groupadd -g 900 ${GROUP_SITS}
useradd -m -u 900 -g ${GROUP_SITS} -d /home/${USER_SITS} -s /bin/bash ${USER_SITS}
echo "${USER_SITS}:sits" | chpasswd

# Create required directories
install ${INSTALL_DIR_PARAMS} ${DIR_APP}
install ${INSTALL_DIR_PARAMS} ${DIR_TEMP}

# Extract Uniface
install ${INSTALL_DIR_PARAMS} ${DIR_APP}/uniface
unzip -qn ${ZIP_UNIFACE} 'uniface970lid.tar.gz' -d ${DIR_TEMP}/uniface
tar --strip-components=1 -xzf ${DIR_TEMP}/uniface/uniface970lid.tar.gz -C ${DIR_APP}/uniface

# Extract SITS
unzip -qn ${ZIP_SITS} 'sits970.zip' -d ${DIR_TEMP}
unzip -qn ${DIR_TEMP}/sits970.zip 'release/9.7.0/sits/*' -d ${DIR_TEMP}/sits
mv ${DIR_TEMP}/sits/release/9.7.0/sits ${DIR_APP}/sits

# Link LDAP Uniface library
ln -s /lib64/libldap-2.4.so.2 ${DIR_APP}/uniface/lib/libldap-2.3.so.0

# Deploy Uniface configuration directory
cp -rT ${DIR_PROVISION}/adm-uniface ${DIR_APP}/uniface/adm

# Deploy SITS configuration directory
cp -rT ${DIR_PROVISION}/adm-sits ${DIR_APP}/adm

# Link SITS environment configuration
ln -s ${DIR_APP}/uniface/adm/insunis ${DIR_APP}/adm/sitsenv

# Extract SITS patch script
install ${INSTALL_DIR_PARAMS} ${DIR_APP}/swupdate/install
unzip -qn ${ZIP_ALLFIXES} -d ${DIR_APP}/swupdate/install

# Create logs directories
install ${INSTALL_DIR_PARAMS} ${DIR_APP}/logs/{deewr,eml,finance,fop,javatmp,menbcp,pdf,stutalk,svc,tac,tomcat,urouter,userver,wasv}

# Adjust file permissions
chown -R ${USER_SITS}:${GROUP_SITS} ${DIR_APP}

# Install Oracle client
rpm -ivh ${DIR_PROVISION}/oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm
rpm -ivh ${DIR_PROVISION}/oracle-instantclient11.2-sqlplus-11.2.0.3.0-1.x86_64.rpm

# Deploy Docker entry point script
cp ${DIR_PROVISION}/docker-entrypoint.sh /usr/local/bin/

# Remove temporary resources
rm -rf ${DIR_TEMP}
rm -rf ${DIR_PROVISION}
