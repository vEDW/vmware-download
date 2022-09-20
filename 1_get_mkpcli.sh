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
    FILENAME="mkpcli-$OS_CLI-amd64.tgz"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_CLI="darwin"
    FILENAME="mkpcli-$OS_CLI-amd64.tgz"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS_CLI="windows"
    FILENAME="mkpcli-$OS_CLI-amd64.zip"
else
	OS_NAME="$OSTYPE-$OSBITS"
	echo "Unknown OS '$OS_NAME'"
	exit 1
fi

echo "downloading mkpcli for $OS_CLI"

# mkpcli
# from https://github.com/vmware-labs/marketplace-cli
echo "curl -s -L --output /tmp/$FILENAME https://github.com/vmware-labs/marketplace-cli/releases/download/v${MKPCLIRELEASE}/$FILENAME"

exit 
echo "moving mkpcli to ${BINDIR}"
tar -zxf /tmp/$FILENAME

sudo chown root mkpcli
sudo chmod ugo+x mkpcli
sudo mv mkpcli ${BINDIR}
