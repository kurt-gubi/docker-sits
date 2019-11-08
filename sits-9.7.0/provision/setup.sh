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

# Install SITS dependencies
yum -y install dos2unix
# Install other dependencies
yum -y install unzip

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

# Extract SITS patch script
install ${INSTALL_DIR_PARAMS} ${DIR_APP}/swupdate/install
unzip -qn ${ZIP_ALLFIXES} -d ${DIR_APP}/swupdate/install

# Adjust file permissions
chown -R ${USER_SITS}:${GROUP_SITS} ${DIR_APP}

# Deploy startup script for urouter
cp /tmp/provision/init-d.sits /etc/init.d/${USER_SITS}
chmod 750 /etc/init.d/${USER_SITS}
chkconfig --level 345 ${USER_SITS} on

# Remove temporary resources
rm -rf ${DIR_TEMP}
rm -rf ${DIR_PROVISION}
