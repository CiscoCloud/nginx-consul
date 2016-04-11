FROM drifting/consul-template:latest

MAINTAINER Chris Aubuchon <Chris.Aubuchon@gmail.com>

RUN apk-install bash nginx ca-certificates

RUN mkdir -p /etc/nginx /tmp/nginx /defaults

ADD defaults/ /defaults
ADD scripts /scripts/
ADD nginx/ /etc/nginx

CMD ["/scripts/launch.sh"]
