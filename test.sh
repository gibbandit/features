
. /etc/os-release

MONGO_TOOLS_AVAIL_VERSIONS=($(curl -s --location --request GET "https://s3.amazonaws.com/repo.mongodb.org?list-type=2&prefix=apt/debian/dists/$VERSION_CODENAME/mongodb-org/&delimiter=/" |grep -oPu '(?<=mongodb-org\/)[0-9]*\.[0-9]*?(?=\/)'| sort -rnu))

echo ${MONGO_TOOLS_AVAIL_VERSIONS[*]}