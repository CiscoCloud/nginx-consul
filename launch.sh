#!/bin/bash

set -e 
#set the DEBUG env variable to turn on debugging
[[ -n "$DEBUG" ]] && set -x

# Required vars
NGINX=${NGINX:-/usr/sbin/nginx}
NGINX_CONF=${NGINX_CONF:-/etc/nginx}

CONSUL_TEMPLATE=${CONSUL_TEMPLATE:-/usr/local/bin/consul-template}
CONSUL_CONFIG=${CONSUL_CONFIG:-/consul-template/config.d}
CONSUL_CONNECT=${CONSUL_CONNECT:-consul.service.consul:8500}
CONSUL_MINWAIT=${CONSUL_MINWAIT:-2s}
CONSUL_MAXWAIT=${CONSUL_MAXWAIT:-10s}
CONSUL_LOGLEVEL=${CONSUL_LOGLEVEL:-debug}

function usage {
cat <<USAGE
  launch.sh             Start a consul-backed nginx instance

Configure using the following environment variables:

Nginx vars:
  NGINX                 Location of nginx bin
                        (default /usr/sibn/nginx)

  NGINX_CONF            Location of nginx conf dir
                        (default /etc/nginx)

Consul-template variables:
  CONSUL_TEMPLATE       Location of consul-template bin 
                        (default /usr/local/bin/consul-template)


  CONSUL_CONNECT        The consul connection
                        (default consul.service.consul:8500)

  CONSUL_CONFIG         File/directory for consul-template config
                        (default /consul-template/config.d)
USAGE

  CONSUL_LOGLEVEL       Valid values are "debug", "info", "warn", and "err".
                        (default is "debug")

USAGE
}

function start_nginx {
  echo "Starting nginx..."
  ${NGINX} -c ${NGINX_CONF}/nginx.conf
}


function launch_consul_template {
  vars=$@
  echo "Starting consul template..."
  ${CONSUL_TEMPLATE} -config ${CONSUL_CONFIG} \
                     -log-level ${CONSUL_LOGLEVEL} \
                     -wait ${CONSUL_MINWAIT}:${CONSUL_MAXWAIT} \
                     -consul ${CONSUL_CONNECT} ${vars}
}

start_nginx
launch_consul_template $@
