#!/bin/bash

/bin/kill -HUP `/bin/cat /var/run/consul-template.pid`

exit 0
