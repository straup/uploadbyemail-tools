#!/bin/sh

DATE=`date`
echo "[start] ${DATE} reading ${FLICKR_CFG}"

PHOTO_AND_STUFF=`cat -u /dev/stdin | ube-receivemail.pl`
echo "[parse] '${PHOTO_AND_STUFF}'"

PHOTO=`echo ${PHOTO_AND_STUFF} | cut -f 1 -d"|"`
PROCESS=`echo ${PHOTO_AND_STUFF} | cut -f 2 -d"|"`
EXTRA=`echo ${PHOTO_AND_STUFF} | cut -f 3 -d "|"`
TITLE=`echo ${PHOTO_AND_STUFF} | cut -f 4 -d "|"`
PERMS=`echo ${PHOTO_AND_STUFF} | cut -f 5 -d "|"`

echo "[photo] '${PHOTO}'"
echo "[process] '${PROCESS}'"
echo "[extra] '${EXTRA}'"
echo "[title] '${TITLE}'"
echo "[perms] '${PERMS}'"

FILTRD=`ube-processphoto.sh ${PHOTO} ${PROCESS} ${EXTRA}`
echo "FILTRD) ${FILTRD}"

ID=`ube-postphoto.pl -c ${FLICKR_CFG} -i ${FILTRD} -p ${PROCESS} -T "${TITLE}" -P ${PERMS}`
echo "[id] ${ID}"

if [ -f ${FILTRD} ]; then
    rm ${FILTRD}
fi

DATE=`date`
echo "[end] ${DATE}"

exit
