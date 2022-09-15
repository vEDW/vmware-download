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

sudo apt-get update -y
sudo apt-get upgrade -y

# HAproxy OVA
# from https://github.com/haproxytech/vmware-haproxy
curl -LO https://cdn.haproxy.com/download/haproxy/vsphere/ova/haproxy-v${HAPROXYRELEASE}.ova

mv haproxy-v${HAPROXYRELEASE}.ova ${BITSDIR}/haproxy-v${HAPROXYRELEASE}.ova