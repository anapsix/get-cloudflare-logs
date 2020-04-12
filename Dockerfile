FROM alpine:3.11
ENV FERON_VERSION=0.2.1         \
    FILEBEAT_VERSION=7.6.2      \
    FILEBEAT_HOME=/opt/filebeat \
    FILEBEAT_USER=filebeat
RUN apk upgrade -U && \
    apk add dumb-init bash jq curl coreutils libc6-compat upx && \
    addgroup -g 1000 ${FILEBEAT_USER} && \
    adduser -h ${FILEBEAT_HOME} -H -D -u 1000 -G ${FILEBEAT_USER} -s /bin/false ${FILEBEAT_USER} && \
    curl -sSL https://github.com/anapsix/feron/releases/download/v${FERON_VERSION}/feron-${FERON_VERSION}-linux-amd64 -o /usr/local/bin/feron && \
    chmod +x /usr/local/bin/feron && \
    touch /etc/crontabs/${FILEBEAT_USER} && \
    mkdir /logs && \
    curl -sS https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz -o /tmp/filebeat.tar.gz && \
    tar -C /opt -xzf /tmp/filebeat.tar.gz && \
    rm -rf /tmp/filebeat.tar.gz /etc/crontabs/root && \
    mv /opt/filebeat-${FILEBEAT_VERSION}-linux-x86_64 ${FILEBEAT_HOME} && \
    upx ${FILEBEAT_HOME}/filebeat && \
    cp ${FILEBEAT_HOME}/fields.yml ${FILEBEAT_HOME}/fields.yml.reference && \
    mkdir ${FILEBEAT_HOME}/data && \
    chown -R ${FILEBEAT_USER}:${FILEBEAT_USER} \
      ${FILEBEAT_HOME} \
      /etc/crontabs/${FILEBEAT_USER} \
      /logs && \
    apk del --purge upx && \
    rm -rf /var/cache/apk && \
    ln -s ${FILEBEAT_HOME}/filebeat /usr/local/bin/filebeat && \
    filebeat version && \
    echo -n "feron version " && feron --version
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
