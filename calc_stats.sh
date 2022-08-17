iceshelves="$(grep -v ^# points_ice_shelves_4.45km.txt | awk -F, '{print $NF}' | sort -nu)"
regions="$(seq 1 8)"
experiment_tag="ICESHELVES"
lt=1		# Use local time (1), or UTC time (0)?
fullday=0	# Analyze 24 hr, 00:00-00:00 (1), or restrict analysis between 6:00-10:00 and 18:00-22:00 (0)?


# Set suffix
if (( ${fullday} )); then
	sfx=""
else
	sfx="622"
fi


# Create paths, if they don't yet exist
if [ ! -d "./stats${sfx}/" ]; then
	mkdir ./stats${sfx}/
fi
if [ ! -d "./stats_iceshelves${sfx}/" ]; then
	mkdir ./stats_iceshelves${sfx}/
fi

#
# Days with melt
#
for th in 0 0.1 0.2 0.3 1 2 5
do
	for region in ${regions}
	do
		echo "Processing region=${region}, th=${th}..."
		outfile="./stats${sfx}/meltdays_${th}mm_R${region}.txt"
		bash concatenate.sh postprocess/LATLON_${experiment_tag}.zip *_${experiment_tag}.txt \
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} -v melt_th=${th} -f days_with_melt.awk | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, th=${th}..."
		outfile="./stats_iceshelves${sfx}/meltdays_${th}mm_S${iceshelf}.txt"
		bash concatenate.sh postprocess/LATLON_${experiment_tag}.zip *_${experiment_tag}.txt \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} -v melt_th=${th} -f days_with_melt.awk | Rscript calc_avg.R > ${outfile}
	done
done

#
# Total melt
#
for region in ${regions}
do
	echo "Processing region=${region}..."
	outfile="./stats${sfx}/melt_R${region}.txt"
	bash concatenate.sh postprocess/LATLON_${experiment_tag}.zip *_${experiment_tag}.txt \
	$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} -f total_melt.awk | Rscript calc_avg.R > ${outfile}
done
for iceshelf in ${iceshelves}
do
	echo "Processing iceshelf=${iceshelf}..."
	outfile="./stats_iceshelves${sfx}/melt_S${iceshelf}.txt"
	bash concatenate.sh postprocess/LATLON_${experiment_tag}.zip *_${experiment_tag}.txt \
	$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} -f total_melt.awk | Rscript calc_avg.R > ${outfile}
done

#
# Liquid water in firn (from *.smet file)
#
for th in 0 0.1 0.2 0.3 0.5 1 1.5 2
do
	for i in $(seq 5 10)
	do
		# Map columns to labels for output filenames
		case "${i}" in
			5) label="mswater" ;;		# Total column liquid water in firn (from *.smet file)
			6 ) label="mswater0_0.1" ;;	# LWC 0-0.1m
			7 ) label="mswater0_0.25" ;;	# LWC 0-0.25m
			8 ) label="mswater0_0.5" ;;	# LWC 0-0.5m
			9 ) label="mswater0_1" ;;	# LWC 0-1m
			10 ) label="mswater0_2" ;;	# LWC 0-1m
		esac

		for region in ${regions}
		do
			echo "Processing region=${region}, th=${th}..."
			outfile="./stats${sfx}/${label}_${th}mm_R${region}.txt"
			bash concatenate.sh postprocess/LATLON_${experiment_tag}.zip *_${experiment_tag}_water.txt \
			$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v col=${i} -v lt=${lt} -v fd=${fullday} -v th=${th} -f liquid_water_in_firn.awk | Rscript calc_avg.R > ${outfile}
		done
		for iceshelf in ${iceshelves}
		do
			echo "Processing iceshelf=${iceshelf}, th=${th}..."
			outfile="./stats_iceshelves${sfx}/${label}_${th}mm_S${iceshelf}.txt"
			bash concatenate.sh postprocess/LATLON_${experiment_tag}.zip *_${experiment_tag}_water.txt \
			$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v col=${i} -v lt=${lt} -v fd=${fullday} -v th=${th} -f liquid_water_in_firn.awk | Rscript calc_avg.R > ${outfile}
		done
	done
done
