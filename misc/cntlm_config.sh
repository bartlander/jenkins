#!/usr/bin/env bash

set -e

#rm -rf tmp
mkdir -p tmp

generate_cntlm_conf() {
  cat << EOF > "tmp/dfiles/etc/cntlm.conf"
Domain      ${DKR_CNTLM_DOMAIN:-domain}
Auth        NTLMv2
Proxy       ${DKR_CNTLM_PROXY:-some.proxy.host:8080}
NoProxy     ${DKR_NO_PROXY:-no_proxy_list}

Listen      8888

Username    ${DKR_CNTLM_USER:-user}
PassNTLMv2  ${DKR_CNTLM_PASSWORD:-password}
EOF
}

if [[ ! "$DKR_CNTLM_DOMAIN" == "" ]]; then generate_cntlm_conf; fi
