FROM gliderlabs/alpine

MAINTAINER Steven Borrelli <steve@aster.is>

ENV CONSUL_TEMPLATE_VERSION=0.8.0

RUN apk-install bash nginx

ADD https://github.com/hashicorp/consul-template/releases/download/v${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz /

RUN tar zxvf consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz && \
    mv consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64/consul-template /usr/local/bin/consul-template && \
    rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz && \
    rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64

RUN mkdir -p /consul-template /tmp/nginx

ADD template/ /consul-template/
ADD launch.sh /launch.sh
ADD nginx-run.sh /nginx-run.sh
ADD nginx/nginx-auth.conf /etc/nginx/nginx-auth.conf

CMD ["/launch.sh"]
