#!/bin/bash
siteUrl="http://gongo.local/podcast"
wwwDir="/var/www/podcast"
imageDir="images"
rssDir="rss"
contentDir="content"
thumbSize="512"
ffmpegthumbnailerBin="/usr/bin/ffmpegthumbnailer"
handbrakeBin="/usr/bin/HandBrakeCLI"
handbrakePreset="iPad"
md5sumBin="/usr/bin/md5sum"
inputFile="${1}"
lockFile="/tmp/generateRSS.lock"

function urlencode() {
	local url=$(echo "${1}" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
	echo "${url}"
}

cleanTitle1=${inputFile%.*}
cleanTitle=${cleanTitle1##*/}
outputFile="${cleanTitle}.m4v"
nfoFile="${inputFile%.*}.nfo"
imageFile="${cleanTitle}.png"

if [ -f "${lockFile}" ]; then
	echo "I'm already running!"
	exit 0
else
	touch "${lockFile}"
fi

if [ -f "${wwwDir}/${contentDir}/${outputFile}" ]; then
	echo "${outputFile} already exists!"
	rm "${lockFile}"
	exit 0
fi

if [ ! -d "${wwwDir}/${contentDir}" ]; then
	mkdir "${wwwDir}/${contentDir}"
fi

if [ ! -d "${wwwDir}/${imageDir}" ]; then
	mkdir "${wwwDir}/${imageDir}"
fi

if [ ! -d "${wwwDir}/${rssDir}" ]; then
	mkdir "${wwwDir}/${rssDir}"
fi

if [ -f "${nfoFile}" ]; then
	author=$(grep director "${nfoFile}" | sed -e 's/^[ \t]*//' | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')
	description=$(grep plot "${nfoFile}" | sed -e 's/^[ \t]*//' | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')
else
	author="N/A"
	description="N/A"
fi

audioLanguage=$(ffmpeg -i "${inputFile}" 2>&1| grep Audio | grep eng | awk '{print $2}' | cut -f2 -d "." | cut -f1 -d"(")
pubDate=$(date -R)
duration=$(ffmpeg -i "${inputFile}" 2>&1 | grep "Duration" | awk '{print $2}' | sed 's/,//' | cut -f1 -d".")
md5sum=$(${md5sumBin} "${inputFile}" | awk '{print $1}')
episode=$(echo "${cleanTitle}" | cut -f2 -d "-" | awk -Fx '{print $2}' | tr -d " ")
season=$(echo "${cleanTitle}" | cut -f2 -d "-" | awk -Fx '{print $1}' | tr -d " ")
series=$(echo "${cleanTitle}" | cut -f1 -d "-" | sed 's/^[ \t]*//;s/[ \t]*$//')

${ffmpegthumbnailerBin} -i "${inputFile}" -o "${wwwDir}/${imageDir}/${imageFile}" -s "${thumbSize}"

if [ ! "${audioLanguage}" ]; then
	${handbrakeBin} -i "${inputFile}" -o "${wwwDir}/${contentDir}/${outputFile}" --preset "${handbrakePreset}" 
else
	${handbrakeBin} -i "${inputFile}" -o "${wwwDir}/${contentDir}/${outputFile}" --preset "${handbrakePreset}"  -a "${audioLanguage}"
fi

size=$(du -b "${wwwDir}/${contentDir}/${outputFile}" | awk '{print $1}')

cat >> "${wwwDir}/${rssDir}/${md5sum}".rss << EOF
	<item>
		<title><![CDATA[${cleanTitle}]]></title>
		<itunes:author><![CDATA[${series}]]></itunes:author>
		<itunes:subtitle><![CDATA[${season}x${episode} - ${description}]]></itunes:subtitle>
		<itunes:summary><![CDATA[${season}x${episode} - ${description}]]></itunes:summary>
		<itunes:image href="${siteUrl}/${imageDir}/$(urlencode "${imageFile}")" />
		<enclosure url="${siteUrl}/${contentDir}/$(urlencode "${outputFile}")" length="${size}" type="video/mp4" />
		<guid isPermaLink="false">${md5sum}</guid>
		<pubDate>${pubDate}</pubDate>
		<itunes:duration>${duration}</itunes:duration>
		<itunes:keywords></itunes:keywords>
	</item>
EOF

rm "${lockFile}"
