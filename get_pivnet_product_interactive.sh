#!/bin/bash
#edewitte@vmware.com

# source define_download_version_env
if [[ ! -e define_download_version_env ]]; then
    echo "define_download_version_env file not found. please create one by cloning example and filling values as needed."
    exit 1
fi
source define_download_version_env

#PRODUCT=vmware_tanzu_kubernetes_grid
#SUBPRODUCT=tkg
#FILESELECTORSTRING=ova

# test env variables
if [ $APIREFRESHTOKEN = '<insert-csp-token-here>' ]
then
    echo "Update APIREFRESHTOKEN value in define_download_version_env before running it"
    exit 1
fi

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi


#checking if pivnet cli is there
test=$(pivnet version)
if [ ! $? -eq 0 ]
then
    echo "pivnet cli not available. please install it."
    exit 1
fi

get_products() {
    # PRODUCTS=$(pivnet products | sort |grep -v "|     |" | grep -v "+-----+" | grep -v "| ID  |" | awk '{print $4}' | sort)
    JSON_PRODUCTS=$(pivnet products --format=json)
    PRODUCTS=$(echo $JSON_PRODUCTS | jq -r '.[].slug' |sort)
    echo $PRODUCTS
}

get_versions() {
    # VERSIONS=$(pivnet releases  -p $PRODUCT  | sort |grep -v "|         |" | grep -v "+---------+" | grep -v "|   ID    |" | awk '{print $4}' | sort)
    JSON_VERSIONS=$(pivnet releases --format=json -p $PRODUCT )
    VERSIONS=$(echo $JSON_VERSIONS | jq -r '.[].version' |sort -r)
    echo $VERSIONS
}

#requires version as argument
get_file_info(){
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    JSON_FILES=$(pivnet pfs --format=json -p $PRODUCT  -r $VERSION)
    files=$(echo $JSON_FILES | jq -r '.[].name')
    if [ $? -eq 0 ]
    then
        echo
        echo "Select desired file or CTRL-C to quit"
        echo

        select FILE in $files; do 
            FILE_ID=$(echo $JSON_FILES | jq '.[] | select (.name == "'${FILE}'") | .id')
            echo "downloading file :  $FILE - id: $FILE_ID"
            break 
        done
    else
        echo "problem getting file information" >&2
        exit 1
    fi
    IFS=$SAVEIFS
}

#requires filename as argument
download_file(){
    
    pivnet download-product-files -p $PRODUCT  -r $VERSION -i $2 --accept-eula -d $BITSDIR
    
    if [ $? -eq 0 ]
    then
        echo $file
    else
        echo "problem downloading" >&2
        exit 1
    fi
}

if [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; then
  echo "You are running in a tmux session. That is very wise of you !  :)"
else
  echo "You are not running in a tmux session. Maybe you want to run this in a tmux session?"
fi

# pivnet login 
pivnet login --api-token=$APIREFRESHTOKEN


#get list of versions and remove single quotes
echo "Connecting to VMware Tanzu Network and retrieving available products"
echo
echo "Select desired product or CTRL-C to quit"
echo

select PRODUCT in $(get_products); do 
    echo
    echo "you selected product : ${PRODUCT}"
    echo
    break
done

echo
echo "Select desired version or CTRL-C to quit"
echo
select VERSION in $(get_versions); do 
    echo
    echo "you selected product version: ${VERSION}"
    echo
    break
done

# echo
# echo "Select file or CTRL-C to quit"
# echo
get_file_info

# select FILEINFO in $(get_file_info); do 
#     echo
#     echo "you selected file : ${FILEINFO}"
#     echo
#     break
# done

download_file ${VERSION} $FILE_ID

