#!/bin/bash
tvSeries=("Eureka","The Big Bang Theory")
tvSeriesPath="/storage/media/TV"
tvSeriesDays="-1"
tvSeriesExtension="*.mkv"
generateRSS="/var/www/podcast/generateRSS.sh"
mode="${1}"
txtred=$(tput setaf 1)
txtrst=$(tput sgr0)
txtpur=$(tput setaf 5)

if [ "${mode}" == "test" ]; then
	echo "${txtred}Test mode!${txtrst}"
	echo "${txtpur}$(echo "${tvSeries[*]}" | sed 's/,/, /g')${txtrst}"
	echo "---"
fi

IFS=","
#IFS=$'\n'

for tvSerie in ${tvSeries[*]}
do
	for episode in $(find "${tvSeriesPath}"/"${tvSerie}" -mtime "${tvSeriesDays}" -iname "${tvSeriesExtension}" | grep -v '/[.]')
	do
		if [ "${mode}" == "test" ]; then
			echo "${episode}" | sed 's/'${tvSerie}'/'${txtred}${tvSerie}${txtrst}'/g'
		else
			${generateRSS} "${episode}"
			#echo ""
		fi
	done
done

unset IFS
