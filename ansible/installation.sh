#!/bin/bash

ansible-playbook -i inventory ./playbooks/create.yml --ask-vault-pass
