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

echo "Connecting to VMware Customer Connect and retrieving available versions"

#get list of versions and remove single quotes
VERSIONS=$(vmd get versions -p vmware_vsphere -s esxi |tr -d \')

echo
echo "Select desired version or CTRL-C to quit"
echo

select VERSION in ${VERSIONS}; do 

    echo "you selected version : ${VERSION}"
    echo "getting corresponding iso"
    isofile=$(vmd get files -p vmware_vsphere -s esxi -v ${VERSION} |grep VMware-VMvisor-Installer | awk '{print $1}')
    echo "downloading isofile :  $isofile"
    vmd download -p vmware_vsphere -s esxi -v ${VERSION} -f '$isofile' --accepteula -o $BITSDIR
done
