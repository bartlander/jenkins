#!/usr/bin/env bash

set -e

#rm -rf tmp
mkdir -p tmp

cat << EOF > "tmp/tinyproxy.conf"
Port 3333
Listen 127.0.0.1
Timeout 20
Allow 127.0.0.1
LogFile "$PWD/tmp/tinyproxy.log"
LogLevel Info
EOF

ps -fA | grep "tinyproxy" | awk '{print $2}' > t.tmp
#echo $(< t.tmp)
kill $(< t.tmp) > /dev/null 2>&1 || { :; }
sleep 1
tinyproxy -c tmp/tinyproxy.conf
