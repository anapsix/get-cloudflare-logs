FROM alpine:3.11
ENV FILEBEAT_VERSION=7.6.2
ENV FILEBEAT_HOME=/opt/filebeat
ENV FILEBEAT_USER=filebeat
RUN apk upgrade -U && \
    apk add dumb-init bash jq curl coreutils libc6-compat && \
    rm -rf /var/cache/apk/* && \
    addgroup -g 1000 ${FILEBEAT_USER} && \
    adduser -h ${FILEBEAT_HOME} -H -D -u 1000 -G ${FILEBEAT_USER} -s /bin/false ${FILEBEAT_USER} && \
    touch /etc/crontabs/${FILEBEAT_USER} && \
    mkdir /logs && \
    curl -sS https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz -o /tmp/filebeat.tar.gz && \
    tar -C /opt -xzf /tmp/filebeat.tar.gz && \
    rm /tmp/filebeat.tar.gz /etc/crontabs/root && \
    mv /opt/filebeat-${FILEBEAT_VERSION}-linux-x86_64 ${FILEBEAT_HOME} && \
    cp ${FILEBEAT_HOME}/fields.yml ${FILEBEAT_HOME}/fields.yml.reference && \
    mkdir ${FILEBEAT_HOME}/data && \
    chown -R ${FILEBEAT_USER}:${FILEBEAT_USER} \
      ${FILEBEAT_HOME} \
      /etc/crontabs/${FILEBEAT_USER} \
      /logs && \
    ln -s ${FILEBEAT_HOME}/filebeat /usr/local/bin/filebeat && \
    filebeat version
COPY scripts/go-tasks /usr/local/bin/
COPY config/filebeat.yml ${FILEBEAT_HOME}/
COPY config/fields.yml ${FILEBEAT_HOME}/
COPY config/templates/index-template.json.tpl ${FILEBEAT_HOME}/
COPY scripts/get_cloudflare_logs.sh /usr/local/bin/
COPY scripts/docker-entrypoint.sh /usr/local/bin/
VOLUME ["/logs"]
USER ${FILEBEAT_USER}
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/docker-entrypoint.sh"]
