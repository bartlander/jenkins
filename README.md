# docker build for jenkins using proxy for either

* external - tinyproxy (no firewall)
* internal - cntlm (for authenticating proxy behind corporate firewall)

## Thanks to starting point provided by

* https://itnext.io/docker-inside-docker-for-jenkins-d906b7b5f527
* https://github.com/smoogie/jenkins_docker_example

# Prereqs for external:

* docker installed as host
* user jenkins exists

Should work out of the box.

# Prereqs for internal/corporate:

* seperate DOCKER_HOST defined
* set correct env values for DKR_HOST_UID (jenkins) and DKR_HOST_GID (docker)
* set DKR_CNTLM_vars - see env file
