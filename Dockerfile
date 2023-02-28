ARG IMAGE_FROM=jenkins-staging
FROM $IMAGE_FROM

#ARG CACHEBUST=1
ARG DEPENDENCY=tmp
ARG DKR_USER=jenkins
ARG DKR_HOST_UID
ARG DKR_HOST_GID
ARG DKR_NO_PROXY
ARG DKR_CNTLM_DOMAIN
ARG DKR_CNTLM_PROXY
ARG DKR_NO_PROXY
ARG DKR_CNTLM_USER
ARG DKR_CNTLM_PASSWORD

ENV DKR_CNTLM_DOMAIN=$DKR_CNTLM_DOMAIN
ENV DKR_PROXY_HOST=localhost
ENV DKR_PROXY_PORT=8888
ENV DKR_NO_PROXY=$DKR_NO_PROXY
ENV http_proxy=$DKR_PROXY_HOST:$DKR_PROXY_PORT
ENV https_proxy=$http_proxy
ENV ftp_proxy=$http_proxy
ENV JAVA_PROXY="-Djava.net.useSystemProxies=true -Dhttp.proxyHost=$DKR_PROXY_HOST -Dhttp.proxyPort=$DKR_PROXY_PORT -Dhttps.proxyHost=$DKR_PROXY_HOST -Dhttps.proxyPort=$DKR_PROXY_PORT -Dhttp.nonProxyHosts=\"$DKR_NO_PROXY\""
ENV JAVA_OPTS="-Xmx3g -Xms2G $JAVA_PROXY"

USER root

RUN usermod -u $DKR_HOST_UID jenkins
RUN groupmod -g $DKR_HOST_GID docker
RUN usermod -aG docker jenkins

RUN echo "jenkins ALL = NOPASSWD: /usr/sbin/service cntlm stop" >> /etc/sudoers
RUN echo "jenkins ALL = NOPASSWD: /usr/sbin/service cntlm restart" >> /etc/sudoers
RUN echo "jenkins ALL = NOPASSWD: /usr/bin/tinyproxy" >> /etc/sudoers

RUN chmod go+r /etc/cntlm.conf
RUN mv /etc/cntlm.conf /etc/cntlm.conf.bak

COPY $DEPENDENCY/dfiles /

RUN sed -i "s/\${DKR_CNTLM_DOMAIN}/${DKR_CNTLM_DOMAIN}/" /etc/cntlm.conf
RUN sed -i "s/\${DKR_CNTLM_PROXY}/${DKR_CNTLM_PROXY}/" /etc/cntlm.conf
RUN sed -i "s/\${DKR_NO_PROXY}/${DKR_NO_PROXY}/" /etc/cntlm.conf
RUN sed -i "s/\${DKR_CNTLM_USER}/${DKR_CNTLM_USER}/" /etc/cntlm.conf
RUN sed -i "s/\${DKR_CNTLM_PASSWORD}/${DKR_CNTLM_PASSWORD}/" /etc/cntlm.conf

RUN touch /startup.log
RUN chown $DKR_USER:$DKR_USER /startup.log
RUN chown -R $DKR_USER:$DKR_USER /misc

RUN sed -i 's/\r$//' /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /patch.sh

RUN update-ca-certificates

RUN /patch.sh

USER $DKR_USER

ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
