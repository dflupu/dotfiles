#! /usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import yaml

i = open('/Users/daniel/Dev/urlbl3/database.yaml')
data = yaml.safe_load(i)

if len(sys.argv) > 1:
    print(data[sys.argv[1]])
else:
    print(data)
