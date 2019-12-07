#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import keyring
import getpass

host = sys.argv[1]
password = getpass.getpass()

keyring.set_password('ranger', 'host_' + host, password)
