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
if [ $VCC_USER = '<username>' ]
then
    echo "Update VCC_USER value in define_download_version_env before running it"
    exit 1
fi

if [ $VCC_PASS = '<password>' ]
then
    echo "Update VCC_PASS value in define_download_version_env before running it"
    exit 1
fi

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

get_products() {
    PRODUCTS=$(./vcc get products | awk 'NR>1 {print $1}')
    echo $PRODUCTS
}

get_sub_products() {
    # get_sub_products "product"
    #PRODUCT="${1}"
    SUBPRODUCTS=$(./vcc get subproducts -p $PRODUCT -t $TYPE  | awk 'NR>1 {print $1}')
    echo $SUBPRODUCTS
}
get_versions() {
    VERSIONS=$(./vcc get versions -p $PRODUCT -t $TYPE -s $SUBPRODUCT |tr -d \')
    echo $VERSIONS
}

#requires version as argument
get_file_info(){
    VERSION=${1}
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    files=$(./vcc get files -p $PRODUCT -s $SUBPRODUCT -t $TYPE -v $VERSION | awk 'NR>6 {print $1}')
    if [ $? -eq 0 ]
    then
        echo
        echo "Select desired file or CTRL-C to quit"
        echo
        select FILE in $files; do 
            echo "downloading file :  $FILE"
            #download_file ${VERSION} $FILE
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
    ./vcc download -p $PRODUCT -s $SUBPRODUCT -t $TYPE -v $1 -f $2 --accepteula -o $BITSDIR
    
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

#get list of versions and remove single quotes
echo "Connecting to VMware Customer Connect and retrieving available versions"
echo
echo "Select desired product or CTRL-C to quit"
echo

select PRODUCT in $(get_products); do 
    echo
    echo "you selected product : ${PRODUCT}"
    echo
    break
done

TYPES="product_binary drivers_tools custom_iso addons"

echo
echo "Select download type (Default: product_binary ) or CTRL-C to quit"
echo
select TYPE in ${TYPES}; do 
    echo
    echo "you selected type : ${TYPE}"
    echo
    break
done


echo
echo "Select desired sub product or CTRL-C to quit"
echo
select SUBPRODUCT in $(get_sub_products); do 
    echo
    echo "you selected sub product : ${SUBPRODUCT}"
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

echo
echo "Select file or CTRL-C to quit"
echo
# select FILEINFO in $(get_file_info ${VERSION}); do 
#     echo
#     echo "you selected file : ${FILEINFO}"
#     echo
#     break
# done

get_file_info ${VERSION} 
download_file ${VERSION} $FILE
