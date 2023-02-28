#!/usr/bin/env bash

set -e
set -o pipefail

#keystore="-keystore fred.jks"; rm -f "./usr/local/share/ca-certificates/fred.jks"
keystore="-cacerts"
pushd "./usr/local/share/ca-certificates" > /dev/null
for f in *.crt; do
    if [[ "$f" == "*.crt" ]]; then break; fi
    alias="${f%.crt}"
    echo "keytool -import $keystore -storepass changeit -trustcacerts -noprompt -file $f -alias $alias"
    keytool -import $keystore -storepass changeit -trustcacerts -noprompt -file $f -alias $alias
done
if [[ -e "fred.jks" ]]; then keytool -list -keystore fred.jks -storepass changeit; rm -f fred.jks; fi
popd > /dev/null

#if [[ -e /etc/tinyproxy/tinyproxy.conf ]]; then
#  sed -i "s/Port 8888/Port 3333/" /etc/tinyproxy/tinyproxy.conf
#fi
