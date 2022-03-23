shelf[1]="Amery"
shelf[2]="Amundsen"
shelf[3]="Dronning"
shelf[4]="Peninsula"
shelf[5]="Ronne"
shelf[6]="Ross"
shelf[7]="Victoria"
shelf[8]="Wilkes"
color[1]="#4287f5" # lightblue
color[2]="#d400b7" # purple
color[3]="#00d45f" # green
color[4]="#d4d400" # yellow
color[5]="#d47500" # orange
color[6]="#c41000" # red
color[7]="#00a19b" # cyan
color[8]="#4287f5" # darkblue

for i in $(seq 1 8)
do
	n[i]=$(head -1 ./stats/meltdays_0mm_R${i}.txt | mawk '{for(i=1; i<=NF; i++) {if($i ~ /^[0-9]+$/) {n++}}} END {print n}')
	mean[i]=$(head -1 ./stats/meltdays_0mm_R${i}.txt | mawk '{for(i=1; i<=NF; i++) {if($i ~ /^[0-9]+$/) {n++}}} END {print n+1}')
	sd[i]=$(head -1 ./stats/meltdays_0mm_R${i}.txt | mawk '{for(i=1; i<=NF; i++) {if($i ~ /^[0-9]+$/) {n++}}} END {print n+2}')
done


for th in 0 0.2 0.3 5
do
	plotfilename="./plots/melt_${th}mm"
	echo "set term pdf size 14,4.5 font 'Helvetica,14'" > ${plotfilename}
	echo "set output '${plotfilename}.pdf'" >> ${plotfilename}
	echo "set multiplot layout 2,4" >> ${plotfilename}
	echo "set ylabel 'Days with melt > ${th} mm'" >> ${plotfilename}
	echo "set xlabel 'Year'" >> ${plotfilename}
	echo "set yrange [0:*]" >> ${plotfilename}
	for i in $(seq 1 8)
	do
		echo -n "pl './stats/meltdays_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]}) w l lc rgb '${color[${i}]}' lw 2 title '${shelf[${i}]} (${n[${i}]})'" >> ${plotfilename}
		if (( ${n[${i}]} > 1 )); then
			echo ", './stats/meltdays_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]} - \$${sd[${i}]}):(\$${mean[${i}]} + \$${sd[${i}]}) w filledcurves lc rgb '${color[${i}]}' lw 2 fs transparent solid 0.5 notitle" >> ${plotfilename}
		else
			echo "" >> ${plotfilename}
		fi
	done

	echo "" >> ${plotfilename}
	gnuplot ${plotfilename}
done




plotfilename="./plots/melt"
echo "set term pdf size 14,4.5 font 'Helvetica,14'" > ${plotfilename}
echo "set output '${plotfilename}.pdf'" >> ${plotfilename}
echo "set multiplot layout 2,4" >> ${plotfilename}
echo "set ylabel 'Sum of melt (mm)'" >> ${plotfilename}
echo "set xlabel 'Year'" >> ${plotfilename}
echo "set yrange [0:*]" >> ${plotfilename}
for i in $(seq 1 8)
do
	echo -n "pl './stats/melt_R${i}.txt' u 1:(\$${mean[${i}]}) w l lc rgb '${color[${i}]}' lw 2 title '${shelf[${i}]} (${n[${i}]})'" >> ${plotfilename}
	if (( ${n[${i}]} > 1 )); then
		echo ", './stats/melt_R${i}.txt' u 1:(\$${mean[${i}]} - \$${sd[${i}]}):(\$${mean[${i}]} + \$${sd[${i}]}) w filledcurves lc rgb '${color[${i}]}' lw 2 fs transparent solid 0.5 notitle" >> ${plotfilename}
	else
		echo "" >> ${plotfilename}
	fi
done

echo "" >> ${plotfilename}
gnuplot ${plotfilename}







for th in 0 0.1 0.2 0.5 1
do
	plotfilename="./plots/totalcolumnlwc_${th}mm"
	echo "set term pdf size 14,4.5 font 'Helvetica,14'" > ${plotfilename}
	echo "set output '${plotfilename}.pdf'" >> ${plotfilename}
	echo "set multiplot layout 2,4" >> ${plotfilename}
	echo "set ylabel 'Days with total LWC > ${th} mm m^{-2}'" >> ${plotfilename}
	echo "set xlabel 'Year'" >> ${plotfilename}
	echo "set yrange [0:*]" >> ${plotfilename}
	for i in $(seq 1 8)
	do
		echo -n "pl './stats/mswater_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]}) w l lc rgb '${color[${i}]}' lw 2 title '${shelf[${i}]} (${n[${i}]})'" >> ${plotfilename}
		if (( ${n[${i}]} > 1 )); then
			echo ", './stats/mswater_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]} - \$${sd[${i}]}):(\$${mean[${i}]} + \$${sd[${i}]}) w filledcurves lc rgb '${color[${i}]}' lw 2 fs transparent solid 0.5 notitle" >> ${plotfilename}
		else
			echo "" >> ${plotfilename}
		fi
	done

	echo "" >> ${plotfilename}
	gnuplot ${plotfilename}
done

for th in 0 0.1 0.2 0.5 1
do
	plotfilename="./plots/0-0.1mlwc_${th}mm"
	echo "set term pdf size 14,4.5 font 'Helvetica,14'" > ${plotfilename}
	echo "set output '${plotfilename}.pdf'" >> ${plotfilename}
	echo "set multiplot layout 2,4" >> ${plotfilename}
	echo "set ylabel 'Days with max. LWC > ${th} kg/m^2'" >> ${plotfilename}
	echo "set xlabel 'Year'" >> ${plotfilename}
	echo "set yrange [0:*]" >> ${plotfilename}
	for i in $(seq 1 8)
	do
		echo -n "pl './stats/mswater0_0.1_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]}) w l lc rgb '${color[${i}]}' lw 2 title '${shelf[${i}]} (${n[${i}]})'" >> ${plotfilename}
		if (( ${n[${i}]} > 1 )); then
			echo ", './stats/mswater0_0.1_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]} - \$${sd[${i}]}):(\$${mean[${i}]} + \$${sd[${i}]}) w filledcurves lc rgb '${color[${i}]}' lw 2 fs transparent solid 0.5 notitle" >> ${plotfilename}
		else
			echo "" >> ${plotfilename}
		fi
	done

	echo "" >> ${plotfilename}
	gnuplot ${plotfilename}
done

for th in 0 0.1 0.2 0.5 1
do
	plotfilename="./plots/0-0.5mlwc_${th}mm"
	echo "set term pdf size 14,4.5 font 'Helvetica,14'" > ${plotfilename}
	echo "set output '${plotfilename}.pdf'" >> ${plotfilename}
	echo "set multiplot layout 2,4" >> ${plotfilename}
	echo "set ylabel 'Days with max. LWC > ${th} kg/m^2'" >> ${plotfilename}
	echo "set xlabel 'Year'" >> ${plotfilename}
	echo "set yrange [0:*]" >> ${plotfilename}
	for i in $(seq 1 8)
	do
		echo -n "pl './stats/mswater0_0.5_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]}) w l lc rgb '${color[${i}]}' lw 2 title '${shelf[${i}]} (${n[${i}]})'" >> ${plotfilename}
		if (( ${n[${i}]} > 1 )); then
			echo ", './stats/mswater0_0.5_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]} - \$${sd[${i}]}):(\$${mean[${i}]} + \$${sd[${i}]}) w filledcurves lc rgb '${color[${i}]}' lw 2 fs transparent solid 0.5 notitle" >> ${plotfilename}
		else
			echo "" >> ${plotfilename}
		fi
	done

	echo "" >> ${plotfilename}
	gnuplot ${plotfilename}
done

for th in 0 0.1 0.2 0.5 1
do
	plotfilename="./plots/0-2mlwc_${th}mm"
	echo "set term pdf size 14,4.5 font 'Helvetica,14'" > ${plotfilename}
	echo "set output '${plotfilename}.pdf'" >> ${plotfilename}
	echo "set multiplot layout 2,4" >> ${plotfilename}
	echo "set ylabel 'Days with max. LWC > ${th} kg/m^2'" >> ${plotfilename}
	echo "set xlabel 'Year'" >> ${plotfilename}
	echo "set yrange [0:*]" >> ${plotfilename}
	for i in $(seq 1 8)
	do
		echo -n "pl './stats/mswater0_2_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]}) w l lc rgb '${color[${i}]}' lw 2 title '${shelf[${i}]} (${n[${i}]})'" >> ${plotfilename}
		if (( ${n[${i}]} > 1 )); then
			echo ", './stats/mswater0_2_${th}mm_R${i}.txt' u 1:(\$${mean[${i}]} - \$${sd[${i}]}):(\$${mean[${i}]} + \$${sd[${i}]}) w filledcurves lc rgb '${color[${i}]}' lw 2 fs transparent solid 0.5 notitle" >> ${plotfilename}
		else
			echo "" >> ${plotfilename}
		fi
	done

	echo "" >> ${plotfilename}
	gnuplot ${plotfilename}
done
