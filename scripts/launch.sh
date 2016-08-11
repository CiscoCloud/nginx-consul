#!/bin/bash

#set the DEBUG env variable to turn on debugging
[[ -n "$DEBUG" ]] && set -x

ctpid=0

hup_handler() {
	generate_config
	reload_consul_template
}

term_handler() {
	kill ${ctpid}
	wait ${ctpid}
	exit
}

generate_config() {
	for file in /etc/nginx/templates/*; do
		fname="`basename ${file}`"
		cat > /consul-template/config.d/${fname}.conf << EOF
template {
	source = "${file}"
	destination = "/etc/nginx/conf/${fname}.conf"
	command = "/scripts/nginx-run.sh || true"
}
EOF
	done
}

reload_consul_template() {
	if [ ${ctpid} -ne 0 ]; then
		kill -HUP ${ctpid}
		if [ $? -eq 0 ]; then
			return
		fi
	fi

	consul-template -log-level ${CONSUL_LOGLEVEL} \
		-config /consul-template/config.d \
	${ctargs} &
	ctpid=$!
}

trap hup_handler SIGHUP
trap term_handler SIGTERM SIGINT SIGQUIT


CONSUL_LOGLEVEL=${CONSUL_LOGLEVEL:-info}
# set up SSL
if [ "$(ls -A /usr/local/share/ca-certificates)" ]; then
  # normally we'd use update-ca-certificates, but something about running it in
  # Alpine is off, and the certs don't get added. Fortunately, we only need to
  # add ca-certificates to the global store and it's all plain text.
  cat /usr/local/share/ca-certificates/* >> /etc/ssl/certs/ca-certificates.crt
fi

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

if [ -n "${NGINX_AUTH_TYPE}" ]; then
  config_auth
fi

[[ -n "${CONSUL_CONNECT}" ]] && ctargs="${ctargs} -consul ${CONSUL_CONNECT}"
[[ -n "${CONSUL_SSL}" ]] && ctargs="${ctargs} -ssl"
[[ -n "${CONSUL_SSL}" ]] && ctargs="${ctargs} -ssl-verify=${CONSUL_SSL_VERIFY}"
[[ -n "${CONSUL_TOKEN}" ]] && ctargs="${ctargs} -token ${CONSUL_TOKEN}"

generate_config
reload_consul_template

while :; do
	tail -f /dev/null &
	wait $!
done
