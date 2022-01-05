FROM alpine:latest

RUN addgroup -S icecast && \
    adduser -S icecast
    
RUN apk add --update \
        icecast \
        mailcap \ 
        openssh-server \
        openssh-keygen && \
    rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Azure App-Service-ify
# See: https://github.com/Azure-App-Service/node/blob/master/10.14/Dockerfile
RUN echo "ipv6" >> /etc/modules

RUN echo "root:Docker!" | chpasswd

RUN rm -f /etc/ssh/sshd_config

# configure startup
RUN mkdir -p /tmp
COPY sshd_config /etc/ssh/

COPY ssh_setup.sh /tmp/

RUN chmod -R +x /tmp/ssh_setup.sh \
   && (sleep 1;/tmp/ssh_setup.sh 2>&1 > /dev/null) \
   && rm -rf /tmp/*

ENV SSH_PORT 2222

EXPOSE 2222 8000
VOLUME ["/var/log/icecast"]
ENTRYPOINT ["/entrypoint.sh"]
CMD icecast -c /etc/icecast.xml
