FROM centos:6

COPY "provision" /tmp/provision
COPY "970-ALLFIXES.zip" "970-REL01LID.zip" "970-REL01ZIP.zip" "oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm" "oracle-instantclient11.2-sqlplus-11.2.0.3.0-1.x86_64.rpm" /tmp/provision/

RUN yum -y update && exec /tmp/provision/setup.sh

EXPOSE 13086
ENTRYPOINT ["docker-entrypoint.sh"]
