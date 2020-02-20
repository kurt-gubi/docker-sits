#!/bin/bash

set -e
set -o pipefail
umask 002

DIR_PROVISION=/tmp/provision

# Install package dependencies
yum -y install httpd mod_ssl openssl util-linux-ng

# Deploy Apache configuration
cp ${DIR_PROVISION}/sits.conf /etc/httpd/conf.d/

# Deploy Docker entry point script
cp ${DIR_PROVISION}/docker-entrypoint.sh /usr/local/bin/

# Remove temporary resources
rm -rf ${DIR_PROVISION}
