#!/bin/bash
set -e

sh scripts/clean.sh
sh scripts/rebuild_java.sh

cd Languages/Java
gradle run
