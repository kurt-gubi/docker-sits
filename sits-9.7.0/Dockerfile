FROM centos:6

COPY "provision" /tmp/provision
COPY "970-ALLFIXES.zip" "970-REL01LID.zip" "970-REL01ZIP.zip" /tmp/provision/

RUN yum -y update && exec /tmp/provision/setup.sh

EXPOSE 80 13089 13086
CMD service uroutpr start
