#!/usr/bin/env bash

MONGO_TOOLS_VERSION=${VERSION:-"latest"}

. /etc/os-release

MONGO_TOOLS_AVAIL_VERSIONS=($(curl -sSlr GET "https://s3.amazonaws.com/repo.mongodb.org?list-type=2&prefix=apt/debian/dists/$VERSION_CODENAME/mongodb-org/&delimiter=/" | grep -oPu '(?<=mongodb-org\/)[0-9]*\.[0-9]*?(?=\/)' | sort -rnu))

echo available:
echo ${MONGO_TOOLS_AVAIL_VERSIONS[*]}

if [ "${MONGO_TOOLS_VERSION}" = "latest" ] || [ "${MONGO_TOOLS_VERSION}" = "current" ] || [ "${MONGO_TOOLS_VERSION}" = "lts" ]; then
    MONGO_TOOLS_VERSION=${MONGO_TOOLS_AVAIL_VERSIONS[0]}
fi

echo latest: $MONGO_TOOLS_VERSION
