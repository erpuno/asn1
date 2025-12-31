#!/bin/bash
set -e

sh clean.sh
sh rebuild_java.sh

cd Languages/Java
gradle run
