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

if [ ${GOVCRELEASE} == "" ]; then
    GOVCRELEASE=$(curl -s https://api.github.com/repos/vmware/govmomi/releases/latest | jq -r .tag_name)
fi

if [ ${GOVCRELEASE} == "null" ]; then
    echo "github api rate limiting blocked request"
    echo "please set GOVCRELEASE version in define_download_version_env"
    exit
fi

curl -s -LO https://github.com/vmware/govmomi/releases/download/${GOVCRELEASE}/govc_Linux_x86_64.tar.gz

sudo chown root govc_Linux_x86_64.tar.gz
sudo chmod ugo+x govc_Linux_x86_64.tar.gz
sudo mv govc_Linux_x86_64.tar.gz ${BINDIR}/govc
govc version