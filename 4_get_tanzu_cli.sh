# source define_download_version_env
if [[ ! -e define_download_version_env ]]; then
    echo "define_download_version_env file not found. please create one by cloning example and filling values as needed."
    exit 1
fi
source define_download_version_env

PRODUCT=vmware_tanzu_kubernetes_grid
SUBPRODUCT=tkg
FILESELECTORSTRING=tanzu-cli-bundle

# test env variables
if [ $VMD_USER = '<username>' ]
then
    echo "Update VMD_USER value in define_download_version_env before running it"
    exit 1
fi

if [ $VMD_PASS = '<password>' ]
then
    echo "Update VMD_USER value in define_download_version_env before running it"
    exit 1
fi

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

get_versions() {
    VERSIONS=$(vmd get versions -p $PRODUCT -s $SUBPRODUCT |tr -d \')
    echo $VERSIONS
}

#requires version as argument
get_file_info(){
    file=$(vmd get files -p $PRODUCT -s $SUBPRODUCT -v $1 |grep $FILESELECTORSTRING | awk '{print $1}')
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
    vmd download -p $PRODUCT -s $SUBPRODUCT -v $1 -f $2 --accepteula -o $BITSDIR
    
    if [ $? -eq 0 ]
    then
        echo $file
    else
        echo "problem downloading" >&2
        exit 1
    fi
}

extract_file(){
    mkdir $BITSDIR/tanzu
    if [[ "$OS_CLI" == "linux" ]]; then
        OS_CLI="linux"
        echo "extracting linux cli"
        tar -zxf $BITSDIR/$1 --directory=$BITSDIR/tanzu
    elif [[ "$OS_CLI" == "darwin"* ]]; then
        OS_CLI="darwin"
        echo "extracting macos cli"
        tar -zxf $BITSDIR/$1 --directory=$BITSDIR/tanzu
    elif [[ "$OS_CLI" == "windows" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS_CLI="windows"
        echo "extracting windows cli"
        echo "I still need to check this one"
}

if [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; then
  echo "You are running in a tmux session. That is very wise of you !  :)"
else
  echo "You are not running in a tmux session. Maybe you want to run this in a tmux session?"
fi

if [[ "$OSTYPE" == "linux"* ]]; then
    OS_CLI="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_CLI="darwin"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS_CLI="windows"
else
	OS_NAME="$OSTYPE-$OSBITS"
	echo "Unknown OS '$OS_NAME'"
	exit 1
fi
FILESELECTORSTRING="$FILESELECTORSTRING-$OS_CLI"
echo "filter : $FILESELECTORSTRING"

#get list of versions and remove single quotes
echo "Connecting to VMware Customer Connect and retrieving available versions"
echo
echo "Select desired version or CTRL-C to quit"
echo

select VERSION in $(get_versions); do 
    echo "you selected version : ${VERSION}"
    echo "getting corresponding file"
    isofile=$(get_file_info ${VERSION})
    echo "downloading file :  $isofile"
    download_file ${VERSION} $isofile
    extract_file $isofile
    exit
done
