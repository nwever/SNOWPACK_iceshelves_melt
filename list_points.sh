#
# This script produces a list of points for which SNOWPACK was run successfully. It determines the sequence in which the points appear in the stats*/* files.
#
iceshelves="$(grep -v ^# points_ice_shelves_4.45km.txt | awk -F, '{print $NF}' | sort -nu)"
regions="$(seq 1 8)"

echo "#Regions"
for region in ${regions}
do
	bash pick_ok_points.sh postprocess/LATLON_MERRA2.zip *_MERRA2.txt \
	$(grep -v ^# ../Spinup/points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') } | \
	awk -v sel=${region} -F, '{print sel, $1 "," $2}'
	#$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print sel, $1 "," $2}}')
done
echo "#Iceshelves"
for iceshelf in ${iceshelves}
do
	bash pick_ok_points.sh postprocess/LATLON_MERRA2.zip *_MERRA2.txt \
	$(grep -v ^# ../Spinup/points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | \
	awk -v sel=${iceshelf} -F, '{print sel, $1 "," $2}'
	#$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print sel, $1 "," $2}}')
done
