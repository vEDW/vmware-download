#!/bin/bash
#edewitte@vmware.com

# source define_download_version_env
if [[ ! -e define_download_version_env ]]; then
    echo "define_download_version_env file not found. please create one by cloning example and filling values as needed."
    exit 1
fi

source define_download_version_env

PRODUCT=nsx-advanced-load-balancer-1
FILESELECTORSTRING=controller-

# test env variables
if [ $CSP_API_TOKEN = '<insert-csp-token-here>' ]
then
    echo "Update CSP_API_TOKEN value in define_download_version_env before running it"
    exit 1
fi


#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

get_versions() {
    VERSIONS=$(mkpcli product list-versions -p $PRODUCT | grep ACTIVE | awk '{print $1}')
    echo $VERSIONS
}

#requires version as argument
get_file_info(){
    file=$(mkpcli product list-assets -p $PRODUCT -v $1 |grep $FILESELECTORSTRING | awk '{print $1}')
    if [ $? -eq 0 ]
    then
        echo $file
    else
        echo "problem getting file information" >&2
        exit 1
    fi
}

#requires filename as argument
download_file(){
    mkpcli download -p $PRODUCT  -v $1 --filter $2 --accept-eula -f $BITSDIR/$2
    
    if [ $? -eq 0 ]
    then
        echo $file
    else
        echo "problem downloading" >&2
        exit 1
    fi
}

#get list of versions and remove single quotes
echo "Connecting to VMware Marketplace and retrieving available versions"
echo
echo "Select desired version or CTRL-C to quit"
echo

select VERSION in $(get_versions); do 
    echo "you selected version : ${VERSION}"
    echo "getting corresponding file"
    isofile=$(get_file_info ${VERSION})
    echo "downloading file :  $isofile"
    download_file ${VERSION} $isofile
    exit
done

