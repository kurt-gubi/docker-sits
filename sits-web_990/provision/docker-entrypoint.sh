#!/bin/bash

set -e
set -o pipefail
umask 002

service httpd start

/bin/sleep infinity
