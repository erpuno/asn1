#!/bin/bash
set -e

sh clean.sh
sh rebuild_java.sh


echo "Running"
cd Languages/Java
git clone git@github.com:chat-x509/der.java
gradle run
 