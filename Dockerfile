FROM asteris/consul-template:latest

MAINTAINER Chris Aubuchon <Chris.Aubuchon@gmail.com>

RUN apk-install bash nginx ca-certificates

RUN mkdir -p /tmp/nginx /defaults

ADD template.d/ /consul-template/template.d
ADD config.d/ /consul-template/config.d
ADD scripts /scripts/

CMD ["/scripts/launch.sh"]
