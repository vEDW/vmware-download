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

if [[ ${VCCRELEASE} == "" ]]; then
    VCCRELEASELIST=$(curl -s https://api.github.com/repos/vmware-labs/vmware-customer-connect-cli/releases | jq -r '.[].tag_name')

    echo
    echo "Select desired VCC release or CTRL-C to quit"
    echo

    select VCCRELEASE in ${VCCRELEASELIST}; do 
    echo
    echo "you selected release : ${VCCRELEASE}"
    echo
    break
done

fi

if [[ ${VCCRELEASE} == "null" ]]; then
    echo "github api rate limiting blocked request"
    echo "please set VCCRELEASE version in define_download_version_env"
    exit
fi

curl -s -LO https://github.com/vmware-labs/vmware-customer-connect-cli/releases/download/${VCCRELEASE}/vcc-linux-${VCCRELEASE}

sudo chown root vcc-linux-${VCCRELEASE}
sudo chmod ugo+x vcc-linux-${VCCRELEASE}
sudo mv vcc-linux-${VCCRELEASE} ${BINDIR}/vcc
vcc -v