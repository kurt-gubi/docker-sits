FROM centos:6

COPY "provision" /tmp/provision
COPY "p10404530_112030_Linux-x86-64_1of7.zip" "p10404530_112030_Linux-x86-64_2of7.zip" /tmp/

RUN yum -y update && exec /tmp/provision/setup.sh

EXPOSE 1521
CMD service dbora start
