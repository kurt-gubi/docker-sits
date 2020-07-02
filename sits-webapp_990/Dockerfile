FROM centos:7

COPY "provision" /tmp/provision
COPY "apache-tomcat-9.0.24.tar.gz" "990-REL01LID.zip" /tmp/provision/

RUN yum -y update && exec /tmp/provision/setup.sh

EXPOSE 13084 13089
ENTRYPOINT ["docker-entrypoint.sh"]
