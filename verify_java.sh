#!/bin/bash
set -e

echo "Cleaning"
# sh clean.sh
echo "Rebuilding"
sh rebuild_java.sh

echo "Running"
cd Languages/Java
gradle run 