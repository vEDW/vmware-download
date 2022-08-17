# source define_download_version_env
source define_download_version_env

# test env variables
if [ $VMD_USER = '<username>' ]
then
    echo "Update VMD_USER value in set_env before running it"
    exit 1
fi

if [ $VMD_PASS = '<password>' ]
then
    echo "Update VMD_USER value in set_env before running it"
    exit 1
fi

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

get_versions() {
    VERSIONS=$(vmd get versions -p vmware_vsphere -s esxi |tr -d \')
    echo $VERSIONS
}

#requires version as argument
get_file_info(){
    file=$(vmd get files -p vmware_vsphere -s esxi -v $1 |grep VMware-VMvisor-Installer | awk '{print $1}')
    if [ $? -eq 0 ]
    then
        echo $file
    else
        echo "problem getting iso information" >&2
        exit 1
    fi
}

#requires filename as argument
download_file(){
    vmd download -p vmware_vsphere -s esxi -v $1 -f $2 --accepteula -o $BITSDIR
    
    if [ $? -eq 0 ]
    then
        echo $file
    else
        echo "problem getting iso information" >&2
        exit 1
    fi
}

#get list of versions and remove single quotes
echo "Connecting to VMware Customer Connect and retrieving available versions"
echo
echo "Select desired version or CTRL-C to quit"
echo

select VERSION in $(get_versions); do 
    echo "you selected version : ${VERSION}"
    echo "getting corresponding iso"
    isofile=$(get_file_info ${VERSION})
    echo "downloading isofile :  $isofile"
    download_file ${VERSION} $isofile
done
