#!/usr/bin/env bash
MONGO_TOOLS_VERSION=${VERSION:-"latest"}

. /etc/os-release

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

MONGO_TOOLS_AVAIL_VERSIONS=($(curl -s https://s3.amazonaws.com/repo.mongodb.org -f prefix=apt/debian/dists/${VERSION_CODENAME} |grep -oPu '(?<=mongodb-org\/)[0-9]*\.[0-9]*?(?=\/)'| sort -rnu))

if [ "${MONGO_TOOLS_VERSION}" = "latest" ] || [ "${MONGO_TOOLS_VERSION}" = "current" ] || [ "${MONGO_TOOLS_VERSION}" = "lts" ]; then
    declare -g ${MONGO_TOOLS_VERSION} = ${MONGO_TOOLS_AVAIL_VERSIONS[0]}
fi

if !(echo ${MONGO_TOOLS_AVAIL_VERSIONS[*]} | grep -q ${MONGO_TOOLS_VERSION}); then
    exit 1
fi

architecture="$(uname -m)"
case $architecture in
    x86_64) architecture="amd64";;
    aarch64 | armv8* | arm64) architecture="arm64";;
    *) echo "(!) Architecture $architecture unsupported"; exit 1 ;;
esac

curl -sSL "https://www.mongodb.org/static/pgp/server-${MONGO_TOOLS_VERSION}.asc" | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
echo "deb [arch=${architecture} signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian ${VERSION_CODENAME}/mongodb-org/${MONGO_TOOLS_VERSION} main" | tee /etc/apt/sources.list.d/mongodb-org-${MONGO_TOOLS_VERSION}.list

apt-get update

export DEBIAN_FRONTEND=noninteractive 

apt-get install -y mongodb-mongosh 

if [ ${architecture} = "amd64" ]; then 
    apt-get install -y mongodb-database-tools; 
fi

apt-get clean -y 
rm -rf /var/lib/apt/lists/*