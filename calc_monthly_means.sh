iceshelves="$(grep -v ^# points_ice_shelves_4.45km.txt | awk -F, '{print $NF}' | sort -nu)"
regions="$(seq 1 8)"
smetdir=/pl/active/icesheetsclimate/IDS_Antarctica/smet/
lt=0		# Use local time (1), or UTC time (0)?	NOTE: local time not yet supported (would require to read in longitude and do the time transformations)

# Set suffix
sfx=""


# Create paths, if they don't yet exist
if [ ! -d "./monthlystats${sfx}/" ]; then
	mkdir ./monthlystats${sfx}/
fi
if [ ! -d "./monthlystats_iceshelves${sfx}/" ]; then
	mkdir ./monthlystats_iceshelves${sfx}/
fi

#
# Monthly means for various variables from input *smet files
#
for var in TA QI ILWR ISWR PSUM VW
do
	for region in ${regions}
	do
		echo "Processing region=${region}, var=${var}..."
		outfile="./monthlystats${sfx}/${var}_R${region}.txt"
		bash concatenate.sh ${smetdir}/LATLON.smet \
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} -v var=${var} -f monthly_means.awk | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, var=${var}..."
		outfile="./monthlystats_iceshelves${sfx}/${var}_S${iceshelf}.txt"
		bash concatenate.sh ${smetdir}/LATLON.smet \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} -v var=${var} -f monthly_means.awk | Rscript calc_avg.R > ${outfile}
	done
done
