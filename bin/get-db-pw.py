#! /usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import cryptoyaml

yaml_path = '/Users/daniel/Dev/urlbl3/database.yaml.aes'
data = cryptoyaml.CryptoYAML(yaml_path).data

if len(sys.argv) > 1:
    print(data[sys.argv[1]])
else:
    print(data)
