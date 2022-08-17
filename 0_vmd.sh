# source define_download_version_env
if [[ ! -e define_download_version_env ]]; then
    
fi
source define_download_version_env

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

sudo apt-get update -y
sudo apt-get upgrade -y

# vmd cli
# from https://github.com/laidbackware/vmd
curl -LO https://github.com/laidbackware/vmd/releases/download/v${VMDRELEASE}/vmd-linux-v${VMDRELEASE}


sudo chown root vmd-linux-v${VMDRELEASE}
sudo chmod ugo+x vmd-linux-v${VMDRELEASE}
sudo mv vmd-linux-v${VMDRELEASE} ${BINDIR}/vmd
