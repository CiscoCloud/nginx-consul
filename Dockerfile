FROM drifting/consul-template:latest

MAINTAINER Chris Aubuchon <Chris.Aubuchon@gmail.com>

RUN apk-install bash nginx ca-certificates

RUN mkdir -p /tmp/nginx /defaults

ADD templates/ /consul-template/templates
ADD config.d/ /consul-template/config.d
ADD defaults/ /defaults
ADD scripts /scripts/

CMD ["/scripts/launch.sh"]
