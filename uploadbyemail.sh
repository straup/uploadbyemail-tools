#!/bin/sh

# please to read me from environment variable set in .procmailrc

FLICKR_CFG=$1

DATE=`date`
echo "[start] ${DATE}"

PHOTO_AND_STUFF=`cat -u /dev/stdin | ube-receivemail.pl`
echo "[parse] ${PHOTO_AND_STUFF}"

# please to make me bettar...

PHOTO=`echo ${PHOTO_AND_STUFF} | awk '{split($1, parts, " "); print parts[1]; }'`
PROCESS=`echo ${PHOTO_AND_STUFF} | awk '{split($2, parts, " "); print parts[1]; }'`
EXTRA=`echo ${PHOTO_AND_STUFF} | awk '{split($3, parts, " "); print parts[1]; }'`

echo "[photo] ${PHOTO}"
echo "[process] ${PROCESS}"
echo "[extra] ${EXTRA}"

FILTRD=`ube-processphoto.sh ${PHOTO} ${FILTR} ${PROCESS}`
echo "FILTRD) ${FILTRD}"

ID=`ube-postphoto.pl -c ${FLICKR_CFG} -i ${FILTRD} -p ${PROCESS}`
echo "[id] ${ID}"

if [ -f ${FILTRD} ]; then
    rm ${FILTRD}
fi

DATE=`date`
echo "[end] ${DATE}"

exit
