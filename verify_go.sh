#!/bin/bash

sh clean
sh rebuild_go.sh

cd Languages/Go
go build
./tobirama
cd ../..

