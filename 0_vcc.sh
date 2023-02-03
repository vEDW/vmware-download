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
curl -s -LO https://github.com/laidbackware/vmd/releases/download/v${VMDRELEASE}/vmd-linux-v${VMDRELEASE}
curl -s -LO https://github.com/vmware-labs/vmware-customer-connect-cli/releases/download/v${VCCRELEASE}/vcc-linux-v${VCCRELEASE}

sudo chown root vmd-linux-v${VMDRELEASE}
sudo chmod ugo+x vmd-linux-v${VMDRELEASE}
sudo mv vmd-linux-v${VMDRELEASE} ${BINDIR}/vmd
