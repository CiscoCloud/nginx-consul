#!/bin/bash

set -e 
#set the DEBUG env variable to turn on debugging
[[ -n "$DEBUG" ]] && set -x

# Required vars
NGINX_KV=${NGINX_KV:-nginx/template/default}
CONSUL_LOGLEVEL=${CONSUL_LOGLEVEL:-debug}
CONSUL_SSL_VERIFY=${CONSUL_SSL_VERIFY:-true}

export NGINX_KV

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
  NGINX_KV              Consul K/V path to template contents
                        (default nginx/template/default)

  NGINX_DEBUG           If set, run consul-template once and check generated nginx.conf
                        (default not set)

  NGINX_AUTH_TYPE	Use a preconfigured template for Nginx basic authentication
			Can be basic/auth/<not set>
			(default not set)

  NGINX_AUTH_BASIC_KV	Consul K/V path for nginx users
			(default not set)

Consul vars:
  CONSUL_LOG_LEVEL	Set the consul-template log level
			(default debug)

  CONSUL_CONNECT	URI for Consul agent
			(default not set)

  CONSUL_SSL		Connect to Consul using SSL
			(default not set)

  CONSUL_SSL_VERIFY	Verify Consul SSL connection
			(default true)
USAGE
}

function config_auth {
  case ${NGINX_AUTH_TYPE} in
  basic)
	ln -s /defaults/config.d/nginx-auth.cfg /consul-template/config.d/nginx-auth.cfg
	ln -s /defaults/templates/nginx-basic.tmpl /consul-template/templates/nginx-auth.tmpl
	;;
  esac

  # nginx fails if the file does not exist so create an empty one for now
  touch /etc/nginx/nginx-auth.conf
}

function launch_consul_template {
  vars=$@
  ctargs=

  if [ -n "${NGINX_AUTH_TYPE}" ]; then
    config_auth
  fi

  [[ -n "${CONSUL_CONNECT}" ]] && ctargs="${ctargs} -consul ${CONSUL_CONNECT}"
  [[ -n "${CONSUL_SSL}" ]] && ctargs="${ctargs} -ssl"
  [[ -n "${CONSUL_SSL}" ]] && ctargs="${ctargs} -ssl-verify=${CONSUL_SSL_VERIFY}"

  # Create an empty nginx.tmpl so consul-template will start
  touch /consul-template/templates/nginx.tmpl

  if [ -n "${NGINX_DEBUG}" ]; then
    echo "Running consul template -once..."
    consul-template -log-level ${CONSUL_LOGLEVEL} \
		       -template /consul-template/templates/nginx.tmpl.in:/consul-template/templates/nginx.tmpl \
		       ${ctargs} -once 

    consul-template -log-level ${CONSUL_LOGLEVEL} \
                       -config /consul-template/config.d \
                       ${ctargs} -once ${vars}
    /scripts/nginx-run.sh
  else
    echo "Starting consul template..."
    exec consul-template -log-level ${CONSUL_LOGLEVEL} \
                       -config /consul-template/config.d \
                       ${ctargs} ${vars} 
  fi
}

launch_consul_template $@
