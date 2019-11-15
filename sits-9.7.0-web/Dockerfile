FROM centos:6

COPY "provision" /tmp/provision

RUN yum -y update && exec /tmp/provision/setup.sh

EXPOSE 80
ENTRYPOINT ["docker-entrypoint.sh"]
