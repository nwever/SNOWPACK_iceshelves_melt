iceshelves="$(grep -v ^# points_ice_shelves_4.45km.txt | awk -F, '{print $NF}' | sort -nu)"
regions="$(seq 1 8)"


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
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v melt_th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>melt_th) {n[idx]++}; s=0}; s+=($9>0)?($9):(0); idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, th=${th}..."
		outfile="./stats_iceshelves_per_day/meltdays_${th}mm_S${iceshelf}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2.txt \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v melt_th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>melt_th) {n[idx]++}; s=0}; s+=($9>0)?($9):(0); idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
done

#
# Total melt
#
lt=1	# Use local time (1), or UTC time (0)?
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
	# Total column liquid water in firn (from *.smet file)
	for region in ${regions} 
	do
		echo "Processing region=${region}, th=${th}..."
		outfile="./stats_per_day/mswater_${th}mm_R${region}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($5>s) {s=$5}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, th=${th}..."
		outfile="./stats_iceshelves_per_day/mswater_${th}mm_S${iceshelf}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($5>s) {s=$5}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done

	# LWC 0-0.1m
	for region in ${regions} 
	do
		echo "Processing region=${region}, th=${th}..."
		outfile="./stats_per_day/mswater0_0.1_${th}mm_R${region}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($6>s) {s=$6}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, th=${th}..."
		outfile="./stats_iceshelves_per_day/mswater0_0.1_${th}mm_S${iceshelf}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($6>s) {s=$6}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done

	# LWC 0-0.25m
	for region in ${regions} 
	do
		echo "Processing region=${region}, th=${th}..."
		outfile="./stats_per_day/mswater0_0.1_${th}mm_R${region}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($7>s) {s=$7}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, th=${th}..."
		outfile="./stats_iceshelves_per_day/mswater0_0.1_${th}mm_S${iceshelf}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($7>s) {s=$7}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done

	# LWC 0-0.5m
	for region in ${regions}
	do
		echo "Processing region=${region}, th=${th}..."
		outfile="./stats_per_day/mswater0_0.5_${th}mm_R${region}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($8>s) {s=$8}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, th=${th}..."
		outfile="./stats_iceshelves_per_day/mswater0_0.5_${th}mm_S${iceshelf}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($8>s) {s=$8}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done

	# LWC 0-1m
	for region in ${regions}
	do
		echo "Processing region=${region}, th=${th}..."
		outfile="./stats_per_day/mswater0_1_${th}mm_R${region}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($9>s) {s=$9}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, th=${th}..."
		outfile="./stats_iceshelves_per_day/mswater0_1_${th}mm_S${iceshelf}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($9>s) {s=$9}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done

	# LWC 0-2m
	for region in ${regions}
	do
		echo "Processing region=${region}, th=${th}..."
		outfile="./stats_per_day/mswater0_2_${th}mm_R${region}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_regions_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${region} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($10>s) {s=$10}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
	for iceshelf in ${iceshelves}
	do
		echo "Processing iceshelf=${iceshelf}, th=${th}..."
		outfile="./stats_iceshelves_per_day/mswater0_2_${th}mm_S${iceshelf}.txt"
		bash concatenate.sh postprocess/LATLON_MERRA2.zip *_MERRA2_water.txt \
		$(grep -v ^# points_ice_shelves_4.45km.txt | sed -e 's/\.88,/.875,/g' -e 's/\.38,/.375,/g' -e 's/\.12,/.125,/g' -e 's/\.62,/.625,/g' | awk -v sel=${iceshelf} -F, '{if($3==sel) {print $1 "," $2}}') | awk -v th=${th} 'BEGIN {yr=-1; dd=-1} {if(substr($1,1,1)=="#") {if(yr!=-1) {i++}; yr=-1} else {dd=substr($1,9,2); mm=substr($1,6,2); yr=substr($1,1,4); yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd); yrmmdds[yrmmdd]=yrmmdd; pp[i]=i; if(dd!=dd_old) {if(s>th) {n[idx]++}; s=0}; if($10>s) {s=$10}; idx=sprintf("%d,%08d", i, yrmmdd); dd_old=dd}} END {ny=asorti(yrmmdds); ni=asorti(pp); for(y=1; y<=ny; y++) {printf("%08d", yrmmdds[y]); for(i=1; i<=ni; i++) {idx=sprintf("%d,%08d", pp[i], yrmmdds[y]); printf " %d", (idx in n)?(n[idx]):(0)}; printf "\n"}}' | Rscript calc_avg.R > ${outfile}
	done
done
