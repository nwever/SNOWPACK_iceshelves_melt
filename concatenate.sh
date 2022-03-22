#
# This script concatenates postprocessed SNOWPACK output files, which can be in a zip file, or simply the output directories
# Example: bash concatenate.sh postprocess/LATLON_MERRA2.zip         *_MERRA2.txt             <comma-separated list of coordinates>
#                              ^ template, LATLON will be replaced   ^ file pattern to match  ^ list of coordinates
#                                with actual coordinates

let j=0		# Count command line parameters
for i in "$@"	# Loop over command line parameters
do
	let j=${j}+1
	if (( ${j} == 1 )); then
		template=$i
		if [[ ${template} == *.zip ]]; then
			zip=1
		else
			zip=0
		fi
	else
		if (( ${zip} )) && (( ${j} == 2 )); then
			pat=$2
		else
			latlon=$(echo ${i} | awk -F, '{printf "%.3f_%.3f", $1, $2}')
			file=$(echo ${template} | sed 's/LATLON/'${latlon}'/g')
			if (( ${zip} )); then
				unzip -p -- ${file} ${pat}
			else
				cat ${file}
			fi
		fi
	fi
done
