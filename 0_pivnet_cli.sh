#!/bin/bash
#edewitte@vmware.com

# source define_download_version_env
if [[ ! -e define_download_version_env ]]; then
    echo "define_download_version_env file not found. please create one by cloning example and filling values as needed."
    exit 1
fi
source define_download_version_env

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    sudo mkdir -p $BITSDIR
fi

#sudo apt-get update -y
#sudo apt-get upgrade -y

# vmd cli
# from https://github.com/laidbackware/vmd


if [[ ${PIVNETRELEASE} == "" ]]; then
    PIVNETRELEASE=$(curl -s https://api.github.com/repos/pivotal-cf/pivnet-cli/releases/latest | jq -r .tag_name)
fi

if [[ ${PIVNETRELEASE} == "null" ]]; then
    echo "github api rate limiting blocked request"
    echo "please set PIVNETRELEASE version in define_download_version_env"
    exit
fi

PIVNETRELEASE=$(echo $PIVNETRELEASE | sed 's/v//g')

# pivnet cli
curl -s -LO https://github.com/pivotal-cf/pivnet-cli/releases/download/v${PIVNETRELEASE}/pivnet-linux-amd64-${PIVNETRELEASE}

sudo chown root pivnet-linux-amd64-${PIVNETRELEASE}
sudo chmod ugo+x pivnet-linux-amd64-${PIVNETRELEASE}
sudo mv pivnet-linux-amd64-${PIVNETRELEASE} ${BINDIR}/pivnet
pivnet version
