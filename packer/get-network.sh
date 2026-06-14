#!/bin/bash
NETWORK_ID=$(openstack network show internet -c id -f value 2>/dev/null || openstack network list -c ID -c Name -f value | grep internet | awk '{print $1}')
echo "network_id = \"$NETWORK_ID\"" > network.auto.pkrvars.hcl
echo "Found network: $NETWORK_ID"
