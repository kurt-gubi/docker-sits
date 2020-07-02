FROM centos:7

COPY "provision" /tmp/provision
COPY "linuxx64_12201_database.zip" /tmp/provision/

RUN yum -y update && exec /tmp/provision/setup.sh

EXPOSE 1521
ENTRYPOINT ["docker-entrypoint.sh"]
