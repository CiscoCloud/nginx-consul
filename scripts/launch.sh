#!/bin/bash

set -e 
#set the DEBUG env variable to turn on debugging
[[ -n "$DEBUG" ]] && set -x

# Required vars
CONSUL_TEMPLATE=${CONSUL_TEMPLATE:-/usr/local/bin/consul-template}
CONSUL_CONFIG=${CONSUL_CONFIG:-/consul-template/config.d}
CONSUL_CONNECT=${CONSUL_CONNECT:-consul.service.consul:8500}
CONSUL_MINWAIT=${CONSUL_MINWAIT:-2s}
CONSUL_MAXWAIT=${CONSUL_MAXWAIT:-10s}
CONSUL_LOGLEVEL=${CONSUL_LOGLEVEL:-info}

# set up SSL
if [ "$(ls -A /usr/local/share/ca-certificates)" ]; then
  # normally we'd use update-ca-certificates, but something about running it in
  # Alpine is off, and the certs don't get added. Fortunately, we only need to
  # add ca-certificates to the global store and it's all plain text.
  cat /usr/local/share/ca-certificates/* >> /etc/ssl/certs/ca-certificates.crt
fi

function usage {
cat <<USAGE
  launch.sh             Start a consul-backed nginx instance

Configure using the following environment variables:

Nginx vars:
  NGINX_DOMAIN          The domain to match aainst
                        (default: example.com or app.example.com)

  NGINX_DEBUG           If set, run consul-template once and check generated nginx.conf
                        (default not set)

  NGINX_AUTH_TYPE	Use a preconfigured template for Nginx basic authentication
			Can be basic/auth/<not set>
			(default not set)

  NGINX_AUTH_BASIC_KV	Consul K/V path for nginx users
			(default not set)

Consul vars:
  CONSUL_LOG_LEVEL	Set the consul-template log level
			(default info)

  CONSUL_CONNECT	URI for Consul agent
			(default not set)

  CONSUL_SSL		Connect to Consul using SSL
			(default not set)

  CONSUL_SSL_VERIFY	Verify Consul SSL connection
			(default true)

  CONSUL_TOKEN		Consul API token
			(default not set)
USAGE
}

function launch_consul_template {
    if [ "$(ls -A /usr/local/share/ca-certificates)" ]; then
        cat /usr/local/share/ca-certificates/* >> /etc/ssl/certs/ca-certificates.crt
    fi

    if [ -n "${CONSUL_TOKEN}" ]; then
        ctargs="${ctargs} -token ${CONSUL_TOKEN}"
    fi

    vars=$@
    ${CONSUL_TEMPLATE} -config ${CONSUL_CONFIG} \
                       -log-level ${CONSUL_LOGLEVEL} \
                       -wait ${CONSUL_MINWAIT}:${CONSUL_MAXWAIT} \
                       -consul ${CONSUL_CONNECT} ${ctargs} ${vars}
}

launch_consul_template $@
