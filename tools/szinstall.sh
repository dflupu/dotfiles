#! /bin/bash
# -*- coding: utf-8 -*-
set -e

cd /tmp
fn=lrzsz-0.12.20
tar=$fn.tar.gz
wget https://ohse.de/uwe/releases/$tar --no-check-certificate
tar xf $tar
cd $fn
./configure
make -j2
sudo su -c "make install"
rm -rf $fn $tar
