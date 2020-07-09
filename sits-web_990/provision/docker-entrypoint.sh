#!/bin/bash

set -e
set -o pipefail
umask 002

/usr/sbin/httpd -D FOREGROUND
