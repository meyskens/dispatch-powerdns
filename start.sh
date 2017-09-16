#!/bin/bash

wget -O /etc/ssl/etcd/ca.pem ${CA_URL}
etcd gateway start --discovery-srv=$DISCOVER --listen-addr 127.0.0.1:2379 --trusted-ca-file /etc/ssl/etcd/ca.pem & pdns_server & ITDNS