FROM oracle:12.2.0.1

COPY "provision" /tmp/provision
COPY "oracle-metadata" /tmp/oracle-metadata
COPY "990-REL01LID.zip" "990-REL01ZIP.zip" /tmp/provision/

RUN exec /tmp/provision/setup.sh

EXPOSE 1521
ENTRYPOINT ["docker-entrypoint.sh"]
