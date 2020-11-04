#! /usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import cryptoyaml3

yaml_path = '/Users/daniel/Dev/urlbl3/database.yaml.aes'
data = cryptoyaml3.CryptoYAML(yaml_path).data

if len(sys.argv) > 1:
    rs = data[sys.argv[1]]

    for db in rs['databases']:
        hosts = rs['hosts']
        username = rs['databases'][db]['username']
        password = rs['databases'][db]['password']

        print(f'mongodb://{username}:{password}@{",".join(hosts)}/{db}?replicaSet={sys.argv[1]}')

