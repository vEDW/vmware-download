#!/bin/bash
#edewitte@vmware.com

# source define_download_version_env
if [[ ! -e define_download_version_env ]]; then
    echo "define_download_version_env file not found. please create one by cloning example and filling values as needed."
    exit 1
fi
source define_download_version_env

DATACENTERS=$(govc find / -type d)
DCCT=$(echo "${DATACENTER}" | wc -l)
if [ "${DCCT}" -gt 1 ]
then
    echo "Select Datacenter"
    select VERSION in ${VERSIONS}; do 
        if [ "${VERSION}" = "Quit" ]; then 
        break
        fi
        echo "you selected version : ${VERSION}"
        echo
        break
    done
else
    DATACENTER=${DATACENTERS}
fi

CONTENTLIBRARIES=$(govc library.ls -dc="${DATACENTER}")
CLCT=$(echo "${CONTENTLIBRARIES}" | wc -l)

if [ "${CLCT}" -gt 1 ]
then
    echo "Select Content Library"
    select CONTENTLIBRARY in ${CONTENTLIBRARIES}; do 
        if [ "${CONTENTLIBRARY}" = "Quit" ]; then 
            break
        fi
        echo "you selected Content Library : ${CONTENTLIBRARY}"
        echo
        break
    done
else
    CONTENTLIBRARY=${CONTENTLIBRARIES}
fi

TEMPLATES=$(find  ${BITSDIR}/tanzu-contentlibrary/  -mindepth 1 -maxdepth 1 -type d -print |rev |cut -d "/" -f1 | rev )
echo "Select template to import"
select TEMPLATE in ${TEMPLATES}; do 
    if [ "${TEMPLATE}" = "Quit" ]; then 
        break
    fi
    echo "you selected template : ${TEMPLATE}"
    echo
    break
done



#FILESJSON=$(echo "${CLJSON}" | jq '.items[] | select (.name == "ob-22187091-ubuntu-2004-amd64-vmi-k8s-v1.26.5---vmware.2-fips.1-tkg.1")')

# govc library.import  /test-cl /data/BITS/tanzu-contentlibrary/ob-21961086-photon-3-amd64-vmi-k8s-v1.25.7---vmware.3-fips.1-tkg.1/photon-ova.ovf
# govc library.update -n ob-21961086-photon-3-amd64-vmi-k8s-v1.25.7---vmware.3-fips.1-tkg.1 /test-cl/photon-ova