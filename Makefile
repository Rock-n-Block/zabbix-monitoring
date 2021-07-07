
hosts_path := ansible/hosts.yml
compose_server := docker-compose -f docker-compose.yml
compose_agent := docker-compose -f docker-compose.agentyml
verbosity := -v

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
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l zabbix_server ansible/tasks/configure-server.yml $(verbosity)

setup_agent:
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) ansible/tasks/configure-agent.yml $(verbosity)


# ------ #
# Docker orchestration to all nodes if w/o service or selected node by ansible hostname

docker_build:
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(service) ansible/tasks/compose/build.yml $(verbosity)

docker_start:
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(service) ansible/tasks/compose/start.yml $(verbosity)

docker_stop:
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(service) ansible/tasks/compose/stop.yml $(verbosity)

docker_destroy:
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(service) ansible/tasks/compose/destroy.yml $(verbosity)


start_server:
	$(compose_server) up -d

start_agent:
	$(compose_agent) up -d

stop_server:
	$(compose_server) down

stop_agent:
	$(compose_agent) down


build_server:setup_server docker_build

build_agent: setup_agent docker_build