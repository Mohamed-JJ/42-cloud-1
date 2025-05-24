#!/bin/bash


ansible-playbook playbooks/provision_infra.yaml
ansible-playbook playbooks/deploy_stack.yaml
ansible-playbook playbooks/destroy_infra.yaml