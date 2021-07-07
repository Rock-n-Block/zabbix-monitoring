
compose_server := docker-compose -f docker-compose.yml
compose_agent := docker-compose -f docker-compose.yml
verbosity := 

ansible_cfg := ANSIBLE_CONFIG=$(shell pwd)/ansible/ansible.cfg

# ------ #
# Install dependencies

# All nodes if w/o service or selected node by ansible hostname
setup_deps:
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(service) ansible/tasks/global-install-deps.yml $(verbosity)

# ------ #
# Sync files and configuration

# All nodes if w/o service or selected node by ansible hostname
setup_global:
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(service) ansible/tasks/global-sync.yml $(verbosity)

setup_server:
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l zabbix-server ansible/tasks/configure-server.yml $(verbosity)

setup_agent:
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(service) ansible/tasks/configure-agents.yml $(verbosity)

start_server:
  $(compose_server) up -d

start_agent:
  $(compose_agent) up -d

stop_server:
  $(compose_server) down

stop_agent:
  $(compose_agent) down


build_server: setup_server start_server

build_agent: setup_agent start_agent