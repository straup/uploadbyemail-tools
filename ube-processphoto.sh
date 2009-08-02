#!/bin/sh

INPUT=$1
FILTER=$2
EXTRA=$3

OUTPUT=${INPUT}-out.jpg

if [ ! -f ${INPUT} ]; then
    exit
fi

filtr ${INPUT} ${OUTPUT} ${FILTER} ${EXTRA} 2>&1 > /tmp/process-filtr
rm -f ${INPUT}

echo ${OUTPUT}
exit
