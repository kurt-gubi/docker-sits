FROM centos:7

COPY "provision" /tmp/provision

RUN yum -y update && exec /tmp/provision/setup.sh

EXPOSE 80
ENTRYPOINT ["docker-entrypoint.sh"]
