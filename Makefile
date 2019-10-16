SHELL = /bin/bash

# https://stackoverflow.com/questions/5873025/heredoc-in-a-makefile
define STREAMLIT_CREDENTIALS
[general]
email = ""
endef
export STREAMLIT_CREDENTIALS

EXPORTER_BASE := $(shell pwd)

.PHONY: start-services
start-services: streamlit-credentials
	sudo /usr/bin/supervisord -c $(EXPORTER_BASE)/supervisord.ini

start-%:
	sudo /usr/bin/supervisorctl -c $(EXPORTER_BASE)/supervisord.ini start $*

stop-%:
	sudo /usr/bin/supervisorctl -c $(EXPORTER_BASE)/supervisord.ini stop $*

status-%:
	sudo /usr/bin/supervisorctl -c $(EXPORTER_BASE)/supervisord.ini status $*

.PHONY: streamlit-credentials
streamlit-credentials:
	mkdir -p $(HOME)/.streamlit
	echo "$${STREAMLIT_CREDENTIALS}" >$(HOME)/.streamlit/credentials.toml

.PHONY: disable-autostart disable-nginx-autostart disable-supervisor-autostart

disable-autostart: disable-nginx-autostart disable-supervisor-autostart

disable-nginx-autostart:
	sudo service nginx stop || true
	sudo systemctl disable nginx

disable-supervisor-autostart:
	sudo service supervisor stop || true
	sudo systemctl disable supervisor


.PHONY: install-requirements
install-requirements:
	sudo apt install nginx nginx-extras supervisor

oci-metadata:
	# https://docs.cloud.oracle.com/iaas/Content/Compute/Tasks/gettingmetadata.htm
	curl -L http://169.254.169.254/opc/v1/instance/

network:
	route -n
	sudo netstat -tulnp
	sudo ufw status
