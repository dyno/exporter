SHELL = /bin/bash

# https://stackoverflow.com/questions/5873025/heredoc-in-a-makefile
define STREAMLIT_CREDENTIALS
[general]
email = ""
endef
export STREAMLIT_CREDENTIALS

EXPORTER_BASE := $(shell pwd)

# http://supervisord.org/running.html
.PHONY: start-services
start-services: streamlit-credentials
	sudo /usr/bin/supervisord -c $(EXPORTER_BASE)/supervisord.ini

start-%:
	sudo /usr/bin/supervisorctl -c $(EXPORTER_BASE)/supervisord.ini start $*

stop-%:
	sudo /usr/bin/supervisorctl -c $(EXPORTER_BASE)/supervisord.ini stop $*

restart-%:
	sudo /usr/bin/supervisorctl -c $(EXPORTER_BASE)/supervisord.ini stop $*

status-%:
	sudo /usr/bin/supervisorctl -c $(EXPORTER_BASE)/supervisord.ini status $*

update-all:
	sudo /usr/bin/supervisorctl -c $(EXPORTER_BASE)/supervisord.ini update all

terminate:
	sudo /usr/bin/supervisorctl -c $(EXPORTER_BASE)/supervisord.ini signal SIGTERM all

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


# ------------------------------------------------------------------------------
#  system setup

.PHONY: install-requirements
install-requirements:
	sudo apt install nginx nginx-extras supervisor firewalld

.PHONY: setup-firewall
setup-firewall:
	sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
	sudo firewall-cmd --reload
	sudo firewall-cmd --list-all

oci-metadata:
	# https://docs.cloud.oracle.com/iaas/Content/Compute/Tasks/gettingmetadata.htm
	curl -L http://169.254.169.254/opc/v1/instance/

public-ip:
	curl -L http://checkip.amazonaws.com/

check-network:
	route -n
	sudo netstat -tulnp
	sudo firewall-cmd --list-all
