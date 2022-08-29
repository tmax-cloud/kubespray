#!/bin/bash
ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root playbook.yml -t bootstrap-cloud --ask-pass --ask-become-pass
