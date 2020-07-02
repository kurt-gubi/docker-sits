FROM centos:7

COPY "provision" /tmp/provision
COPY "990-ALLFIXES.zip" "990-REL01LID.zip" "990-REL01ZIP.zip" "oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm" "oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm" /tmp/provision/

RUN yum -y update && exec /tmp/provision/setup.sh

EXPOSE 13086
ENTRYPOINT ["docker-entrypoint.sh"]
