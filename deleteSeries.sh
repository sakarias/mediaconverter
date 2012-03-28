#!/bin/bash
inputFile=${1}
cleanTitle1=${inputFile%.*}
cleanTitle=${cleanTitle1##*/}

if [ ! "${inputFile}" ];
then
	echo "No input file given"
exit 0
fi

echo $cleanTitle

rm $(grep "${cleanTitle}" rss/* | cut -f1 -d":")
rm images/"${cleanTitle}".png
rm content/"${cleanTitle}".m4v
