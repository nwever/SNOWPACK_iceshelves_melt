iceshelves="$(grep -v ^# points_ice_shelves_4.45km.txt | awk -F, '{print $NF}' | sort -nu)"
regions="$(seq 1 8)"
lt=1	# Use local time (1), or UTC time (0)?

#
# Days with melt
#
for th in 0 0.1 0.2 0.3 1 2 5
do
	for region in ${regions}
	do
		echo "Processing region=${region}, th=${th}..."
		outfile="./stats_per_day/meltdays_${th}mm_R${region}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2.txt \
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} -v melt_th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr((lt)?($3):($1),9,2); mm=substr((lt)?($3):($1),6,2); yr=substr((lt)?($3):($1),1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>melt_th) {n[idx]++}; s=0}; s+=($9>0)?($9):(0); idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, th=${th}..."
		outfile="./stats_iceshelves_per_day/meltdays_${th}mm_S${iceshelf}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2.txt \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} -v melt_th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr((lt)?($3):($1),9,2); mm=substr((lt)?($3):($1),6,2); yr=substr((lt)?($3):($1),1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>melt_th) {n[idx]++}; s=0}; s+=($9>0)?($9):(0); idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
done

#
# Total melt
#
for region in ${regions}
do
	echo "Processing region=${region}..."
	outfile="./stats_per_day/melt_R${region}.txt"
	bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2.txt \
	$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr((lt)?($3):($1),9,2); mm=substr((lt)?($3):($1),6,2); yr=substr((lt)?($3):($1),1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; idx=sprintf("%d,%08d", i, yrmmdd); s[idx]+=(($9>0)?($9):(0))}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %.3f", (idx in s)?(s[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
done
for iceshelf in ${iceshelves}
do
	echo "Processing iceshelf=${iceshelf}..."
	outfile="./stats_iceshelves_per_day/melt_S${iceshelf}.txt"
	bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2.txt \
	$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v lt=${lt} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr((lt)?($3):($1),9,2); mm=substr((lt)?($3):($1),6,2); yr=substr((lt)?($3):($1),1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; idx=sprintf("%d,%08d", i, yrmmdd); s[idx]+=(($9>0)?($9):(0))}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %.3f", (idx in s)?(s[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
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
			outfile="./stats_per_day/${label}_${th}mm_R${region}.txt"
			bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
			$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v col=${i} -v lt=${lt} -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr((lt)?($3):($1),9,2); mm=substr((lt)?($3):($1),6,2); yr=substr((lt)?($3):($1),1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($col>s) {s=$col}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
		done
		for iceshelf in ${iceshelves}
		do
			echo "Processing iceshelf=${iceshelf}, th=${th}..."
			outfile="./stats_iceshelves_per_day/${label}_${th}mm_S${iceshelf}.txt"
			bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
			$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v col=${i} -v lt=${lt} -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr((lt)?($3):($1),9,2); mm=substr((lt)?($3):($1),6,2); yr=substr((lt)?($3):($1),1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($col>s) {s=$col}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
		done
	done
done
