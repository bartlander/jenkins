#!/usr/bin/env bash

set -e

VERSION="1.0.0"
DEBUG=${DEBUG:-1}

env | sort | grep -iv PASSWORD > "/startup.log"
echo "------------------------"
echo "ls -l /var/jenkins_home"
ls -l /var/jenkins_home
echo "------------------------"
echo "cat /startup.log"
cat "/startup.log"
if [[ -e "/etc/cntlm.conf" ]]; then
  echo "------------------------"
  echo "cat /etc/cntlm.conf"
  if [[ DEBUG -eq 1 ]]; then
    cat /etc/cntlm.conf
  else
    cat /etc/cntlm.conf | grep -iv PassNTLMv2
  fi
fi
echo "------------------------"
echo "cat /etc/apt/apt.conf"
cat /etc/apt/apt.conf
echo "------------------------"
echo "If jenkins plugin installation fails, try:"
echo "  docker exec -it jenkins bash"
echo "  jenkins-plugin-cli -d /var/jenkins_home/plugins --plugins \"gradle\""
echo "  jenkins-plugin-cli -d /var/jenkins_home/plugins -l"
echo "------------------------"
echo "To test proxy:"
echo "  cd /misc"
echo "  javac JavaHttpsClient"
echo "  java -Djavax.net.debug=all -Djava.net.useSystemProxies=true JavaHttpsClient https://redhat.com/ 1"
echo "    or"
echo "  java -Dhttp.proxyHost=$DKR_PROXY_HOST -Dhttp.proxyPort=$DKR_PROXY_PORT -Dhttps.proxyHost=$DKR_PROXY_HOST -Dhttps.proxyPort=$DKR_PROXY_PORT JavaHttpsClient https://redhat.com/ 1"
echo "    or"
echo "  curl -L google.com"
echo "    or"
echo "  apt-get update (as root)"
echo "------------------------"

# Use default value of domain to test if cntlm (corporate) is not being used - see env file
if [[ ! "$DKR_CNTLM_DOMAIN" == "domain" ]]; then
  sudo /usr/sbin/service cntlm restart
  service cntlm status
else 
  sudo tinyproxy -d &
fi

exec /usr/local/bin/jenkins.sh
