#!/bin/bash
set -e

sh clean.sh
sh rebuild_java.sh

echo "Running"
cd Languages/Java
gradle run 