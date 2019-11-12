FROM oracle:11.2.0.3

COPY "provision" /tmp/provision
COPY "oracle-metadata" /tmp/oracle-metadata
COPY "970-REL01LID.zip" "970-REL01ZIP.zip" /tmp/provision/

RUN exec /tmp/provision/setup.sh

EXPOSE 1521
ENTRYPOINT ["docker-entrypoint.sh"]
