#!/bin/bash
#edewitte@vmware.com

# source define_download_version_env
if [[ ! -e define_download_version_env ]]; then
    echo "define_download_version_env file not found. please create one by cloning example and filling values as needed."
    exit 1
fi
source define_download_version_env

CLJSON=$(curl -s https://wp-content.vmware.com/v2/latest/items.json)

VERSIONS=$(echo "${CLJSON}" | jq -r '.items[].name' | grep -o 'v1\.[0-9]*' | sort -Vu)
#echo "${VERSIONS}"

VERSIONS=${VERSIONS}" Quit"

echo
echo "Select desired TKR version :"
echo
select VERSION in ${VERSIONS}; do 
    if [ "${VERSION}" = "Quit" ]; then 
      break
    fi
    echo "you selected version : ${VERSION}"
    echo
 #   echo "templates with that version"
 #   echo "${CLJSON}" | jq -r '.items[].name' | grep "${VERSION}"
    break
done

TEMPLATES_PER_VERSION=$(echo "${CLJSON}" | jq -r '.items[].name' | grep "${VERSION}" | sort )
TEMPLATES_PER_VERSION=${TEMPLATES_PER_VERSION}" Quit"

echo
echo "Select desired TKR template to download :"
echo

select TEMPLATE in ${TEMPLATES_PER_VERSION}; do 
    if [ "${TEMPLATE}" = "Quit" ]; then 
      break
    fi
    echo "you selected template : ${TEMPLATE}"
    echo
    echo "templates files"
    FILESJSON=$(echo "${CLJSON}" | jq '.items[] | select (.name == "'"${TEMPLATE}"'")')
    echo "${FILESJSON}" | jq -r '["File","Size-in-Bytes"], ["----","-------------"], (.files[] | [.name, .size] )| @tsv' | column -t -s $'\t'
    break
done

DESTINATION=${BITSDIR}/tanzu-contentlibrary/"${TEMPLATE}"
if [ ! -d "${DESTINATION}" ]
then 
    mkdir -p ${BITSDIR}/tanzu-contentlibrary/"${TEMPLATE}"
else
    echo
    echo "!!! Directory : ${DESTINATION} already exists."
    echo
    read -n1 -s -r -p $'do you want to proceed anyway ? (press "y" to proceed - anything else to cancel).\n' answer
    if [ "${answer}" != "y" ]
    then
        echo "you decided to not proceed"
        exit
    fi
fi

FILESTODOWNLOAD=$(echo "${CLJSON}" | jq -r '.items[] | select (.name == "'"${TEMPLATE}"'") | .files[].hrefs[]')

for FILE in ${FILESTODOWNLOAD}
do
    SHORTFILENAME=$(echo "${FILE}" | cut -d "/" -f2)
    echo
    echo "Downloading : ${SHORTFILENAME}"
    curl -Lo "${DESTINATION}/${SHORTFILENAME}" "https://wp-content.vmware.com/v2/latest/${FILE}"
done

echo "Files downloaded into directory : ${DESTINATION}"
