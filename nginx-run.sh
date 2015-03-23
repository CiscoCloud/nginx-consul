#!/bin/bash

if [ ! -s /etc/nginx/nginx.conf ]; then
  exit 0
fi

/usr/sbin/nginx -s reload
if [ $? -eq 0 ]; then
  /bin/echo "Reloading nginx..."
  exit 0
fi

/bin/echo "Checking nginx.conf..."
/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
if [ $? -ne 0 ]; then
  /bin/echo "nginx.conf check failed..."
  exit 1
fi

/bin/echo "Starting nginx..."
/usr/sbin/nginx -c /etc/nginx/nginx.conf
exit $?
