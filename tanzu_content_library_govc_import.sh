#!/bin/bash
#edewitte@vmware.com

# source define_download_version_env
if [[ ! -e define_download_version_env ]]; then
    echo "define_download_version_env file not found. please create one by cloning example and filling values as needed."
    exit 1
fi
source define_download_version_env

CONTENTLIBRARIES=$(govc library.ls)
CLCT=$(echo "${CONTENTLIBRARIES}" | wc -l)

[ "${CLCT}" -lt 1 ] && echo "no content library found. create one first." && exit

if [ "${CLCT}" -gt 1 ]
then
    echo "Select Content Library"
    select CONTENTLIBRARY in ${CONTENTLIBRARIES}; do 
        if [ "${CONTENTLIBRARY}" = "Quit" ]; then 
            break
        fi
        echo
        echo "you selected Content Library : ${CONTENTLIBRARY}"
        break
    done
else
    CONTENTLIBRARY=${CONTENTLIBRARIES}
    echo
    echo "using Content Library : ${CONTENTLIBRARY}"
fi

TEMPLATES=$(find  ${BITSDIR}/tanzu-contentlibrary/  -mindepth 1 -maxdepth 1 -type d -print |rev |cut -d "/" -f1 | rev )
echo
echo "Select template to import"
select TEMPLATE in ${TEMPLATES}; do 
    if [ "${TEMPLATE}" = "Quit" ]; then 
        break
    fi
    echo "you selected template : ${TEMPLATE}"
    echo
    break
done

LISTCONTENT=$(govc library.ls "${CONTENTLIBRARY}/")
echo "Current library content : "
echo "${LISTCONTENT}"
echo 

OVFFILE=$(ls ${BITSDIR}/tanzu-contentlibrary/${TEMPLATE}/*.ovf)
OVFTST=$(echo "${OVFFILE}" |wc -l)
if [ "${OVFTST}" -gt 1 ]
then
    echo "Select OVF"
    select OVF in ${OVFFILE}; do 
        if [ "${OVF}" = "Quit" ]; then 
            break
        fi
        echo
        echo "you selected ovf : ${OVF}"
        break
    done
else
    OVF=${OVFFILE}
    echo
    echo "using ovf : ${OVF}"
fi

echo "importing in content library"
govc library.import  "${CONTENTLIBRARY}"  ${OVF}
echo "setting ova name"
ITEMNAME=$(echo "${OVF}" |rev |cut -d "/" -f1 | rev |cut -d "." -f1)
govc library.update -n "${TEMPLATE}" "${CONTENTLIBRARY}/${ITEMNAME}"
