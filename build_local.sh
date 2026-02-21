#!/bin/sh
VERSION_FILE="$(pwd)/version.yml" REGISTRY_USER=ignimutos DEBUG=true FORCE=true bash -x ./build.sh $1