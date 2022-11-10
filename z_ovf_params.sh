#!/bin/bash
#edewitte@vmware.com

[ "${1}" == "" ] && echo "usage: ${0} <path to ova file>" && exit 1


echo './ovftool --acceptAllEulas  --X:enableHiddenProperties \'
echo '--sourceType=OVA --allowExtraConfig --acceptAllEulas --X:injectOvfEnv  \'
echo '--X:waitForIp --X:logFile=/tmp/ovftool.log --X:logLevel=verbose --X:logTransferHeaderData \'
echo '--name=${NAME} --datastore=${DATASTORE} --powerOn --noSSLVerify \'
echo '--diskMode=thin --net:"Network 1"="VM Network" \'

network=$(ovftool ${1} |grep Networks -A 3 |grep Name:)

echo 'network name = '$network

params=$(ovftool  ${1} |grep "Key:" |awk '{print $2}')
for PARAM in $params; do
    echo "--prop:${PARAM}= \ "
done

echo '${OVA} \'
echo 'vi://${ADMIN}:'${PASSWORD}'@${TARGET}'
