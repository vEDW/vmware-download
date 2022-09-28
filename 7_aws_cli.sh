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
    mkdir $BITSDIR
fi

if [[ "$OSTYPE" == "linux"* ]]; then
    OS_CLI="linux"
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_CLI="darwin"
    curl -s -L --output /tmp/AWSCLIV2.pkg https://awscli.amazonaws.com/AWSCLIV2.pkg
    sudo installer -pkg /tmp/AWSCLIV2.pkg -target /usr/local/bin
    aws --version

elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS_CLI="windows"
    
else
	OS_NAME="$OSTYPE-$OSBITS"
	echo "Unknown OS '$OS_NAME'"
	exit 1
fi



