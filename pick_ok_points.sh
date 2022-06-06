#
# This script checks if <template> exists for the given list of coordinates, and only outputs the coordinates for which the file exists.
# Example: bash pick_ok_points.sh postprocess/LATLON_MERRA2.zip         *_MERRA2.txt             <comma-separated list of coordinates>
#                                 ^ template, LATLON will be replaced   ^ file pattern to match  ^ list of coordinates
#                                   with actual coordinates

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
				a=$(unzip -p -- ${file} ${pat} | grep -v "^#" | head -1)
				if [ ! -z "${a}" ]; then
					echo ${i}
				fi
			else
				a=$(grep -v "^#" ${file} | head -1)
				if [ ! -z "${a}" ]; then
					echo ${i}
				fi
			fi
		fi
	fi
done
