#!/bin/bash

set -e 
#set the DEBUG env variable to turn on debugging
[[ -n "$DEBUG" ]] && set -x

# Required vars
NGINX=${NGINX:-/usr/sbin/nginx}
NGINX_KV=${NGINX_KV:-nginx/template/default}

CONSUL_TEMPLATE=${CONSUL_TEMPLATE:-/usr/local/bin/consul-template}
CONSUL_CONFIG=${CONSUL_CONFIG:-/consul-template/config.d}
CONSUL_CONNECT=${CONSUL_CONNECT:-127.0.0.1:8500}
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

  NGINX_KV              Consul K/V path to template contents
                        (default nginx/template/default)

  NGINX_DEBUG           If set, run consul-template once and check generated nginx.conf
                        (default not set)

Consul-template variables:
  CONSUL_TEMPLATE       Location of consul-template bin 
                        (default /usr/local/bin/consul-template)


  CONSUL_CONNECT        The consul connection
                        (default consul.service.consul:8500)

  CONSUL_LOGLEVEL       Valid values are "debug", "info", "warn", and "err".
                        (default is "debug")
USAGE
}


function launch_consul_template {
  vars=$@
  if [ -n "${NGINX_ENABLE_AUTH}" ]; then
    nginx_auth='-template /consul-template/nginx-auth.tmpl:/etc/nginx/nginx-auth.conf'
  fi

  if [ -n "${NGINX_DEBUG}" ]; then
    echo "Running consul template -once..."
    ${CONSUL_TEMPLATE} -log-level ${CONSUL_LOGLEVEL} \
                       -wait ${CONSUL_MINWAI}:${CONSUL_MAXWAIT} \
                       -template /consul-template/nginx.tmpl:/etc/nginx/nginx.conf \
                       -consul ${CONSUL_CONNECT} ${nginx_auth} -once ${vars}
    ${NGINX} -t -c /etc/nginx/nginx.conf
  else
    echo "Starting consul template..."
    ${CONSUL_TEMPLATE} -log-level ${CONSUL_LOGLEVEL} \
                       -wait ${CONSUL_MINWAIT}:${CONSUL_MAXWAIT} \
                       -template "/consul-template/nginx.tmpl:/etc/nginx/nginx.conf:${NGINX} -s reload || ( ${NGINX} -t -c /etc/nginx/nginx.conf && ${NGINX} -c /etc/nginx/nginx.conf )" \
                       -consul ${CONSUL_CONNECT} ${nginx_auth} ${vars}
  fi
}

launch_consul_template $@
