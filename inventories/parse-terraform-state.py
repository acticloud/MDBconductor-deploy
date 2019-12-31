#!/usr/bin/env python3

# Read a Terraform state file and extract information
# that is relevant to Ansible.
#
# In particular, generate a host entry for every cluster
# node setting ansible_user and  ansible_host to the proper IP number
# so Ansible can connect, and create groups 'conductor' and
# 'minion' based on the 'cluster' and 'cluster_role' tags.

from collections import defaultdict
import json
import os
import sys

STATEFILE = sys.argv[1]

if not os.path.isfile(STATEFILE):
    sys.exit(0)

state = json.load(open(STATEFILE))

instances = [
    i
    for r in state['resources']
    if r['type'] == 'aws_instance'
    for i in r['instances']
]

groups = defaultdict(lambda: [])
vars = defaultdict(lambda: {})

for i in instances:
    attrs = i['attributes']
    tags = attrs.get('tags', {})
    name = tags['Name']
    cluster_name = tags.get('cluster')
    public_ip = attrs.get('public_ip')
    private_ip = attrs.get('private_ip')
    if not public_ip:
        continue
    cluster = tags.get('cluster')
    if not cluster:
        continue
    cluster_groups = tags.get('cluster_groups', '').split()
    vars[name] = dict(
        ansible_user='ubuntu',
        ansible_host=public_ip,
        private_ip=private_ip,
    )
    if cluster_name:
        vars[name]['cluster_name'] = cluster_name
    for g in cluster_groups:
        groups[g].append(name)

# construct the inventory in the proper json format
inventory = dict(_meta=dict(hostvars=vars))
for group, hosts in sorted(groups.items()):
    inventory[group] = hosts


# print(json.dumps(groups, indent=4))
# print(json.dumps(vars, indent=4))
print(json.dumps(inventory, indent=4))
