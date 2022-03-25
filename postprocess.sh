export TZ=UTC
zipdir_snowpackoutput="${HOME}/zip/"
postprocessdir="${HOME}/postprocess/"
snowpack_tools_dir=${HOME}/snowpack/Source/snowpack/tools/"

# Check if mawk exist, otherwise create alias
shopt -s expand_aliases         # Make sure aliases work in non-interactive shells
if ! command -v mawk &> /dev/null
then
	alias mawk='awk'
fi

process () {
	# Postprocess output
	ll=($(cat to_exec.lst.iceshelves | awk '{print $5}' | sed 's/cfgfiles\///' | awk -F.ini '{print $1}'))
	pushd ${zipdir_snowpackoutput}
	for l in ${ll[*]}
	do
		z="${l}_MERRA2.zip"
		echo "Processing: ${z}"
		f="$(basename -- ${z} .zip).smet"
		f2="$(basename -- ${z} .zip).pro"
		g="${postprocessdir}/$(basename -- ${f} .smet).txt"
		gz="${postprocessdir}/$(basename -- ${f} .smet).zip"
		g2="${postprocessdir}/$(basename -- ${f} .smet)_firn.txt"
		g3="${postprocessdir}/$(basename -- ${f} .smet)_water.txt"

		echo "#timestamp unixtime timestamp_local unixtime_local mswind mssnow SWE modeled_snowdepth melt sensible_heat latent_heat rain_energy net_swr net_lwr" > ${g}
		unzip -p ./${z} output/${f} | mawk 'BEGIN {data=0; mswind=-1; mssnow=-1; swe=-1; hs=-1; msmelt=-1; qs=-1; ql=-1; qr=-1; iswr=-1; oswr=-1; lwrnet=-1; a=-1;} {if(/longitude/) {lon=$NF}; if(data==1) {a=mktime(sprintf("%04d %02d %02d %02d %02d %02d 0", substr($1,1,4), substr($1,6,2), substr($1,9,2), substr($1,12,2), substr($1,15,2), substr($1,18,2))); aloc=a+(lon/15)*3600; print $1, a, strftime("%Y-%m-%dT%H:%M:%S", aloc), aloc, $mswind, $mssnow, $swe, ($hs/100.), $msmelt, $qs, $ql, $qr, $iswr-$oswr, $lwrnet}; if(/\[DATA\]/) {data=1}; if(/fields/) {for(i=3; i<=NF; i++) {if($i=="MS_Wind") {mswind=(i-2)}; if($i=="MS_Snow") {mssnow=(i-2)}; if($i=="HS_mod") {hs=(i-2)}; if($i=="SWE") {swe=(i-2)}; if($i=="MS_melt") {msmelt=(i-2)}; if($i=="Qs") {qs=(i-2)}; if($i=="Ql") {ql=(i-2)}; if($i=="Qr") {qr=(i-2)}; if($i=="LWR_net") {lwrnet=(i-2)}; if($i=="ISWR") {iswr=(i-2)}; if($i=="OSWR") {oswr=(i-2)}}}}' >> ${g}

		echo "#timestamp unixtime timestamp_local unixtime_local MS_Water MS_Water0-0.1 MS_Water0-0.25 MS_Water0-0.5 MS_Water0-1 MS_Water0-2" > ${g3}
		unzip -p ./${z} output/${f} | mawk 'BEGIN {data=0; mswater=-1; mswater1=-1; mswater2=-1; mswater3=-1; mswater4=-1; mswater5=-1; a=-1;} {if(/longitude/) {lon=$NF}; if(data==1) {a=mktime(sprintf("%04d %02d %02d %02d %02d %02d 0", substr($1,1,4), substr($1,6,2), substr($1,9,2), substr($1,12,2), substr($1,15,2), substr($1,18,2))); aloc=a+(lon/15)*3600; print $1, a, strftime("%Y-%m-%dT%H:%M:%S", aloc), aloc, $mswater, $mswater1, $mswater2, $mswater3, $mswater4, $mswater5}; if(/\[DATA\]/) {data=1}; if(/fields/) {for(i=3; i<=NF; i++) {if($i=="MS_Water") {mswater=(i-2)}; if($i=="MS_Water0-0.1") {mswater1=(i-2)}; if($i=="MS_Water0-0.25") {mswater2=(i-2)}; if($i=="MS_Water0-0.5") {mswater3=(i-2)}; if($i=="MS_Water0-1") {mswater4=(i-2)}; if($i=="MS_Water0-2") {mswater5=(i-2)}}}}' >> ${g3}

		echo "#timestamp unixtime timestamp_local unixtime_local column_LWC_mm SWE firn_depth" > ${g2}.1
		unzip -p ./${z} output/${f} | mawk 'BEGIN {data=0; mswater=-1; msrunoff=-1; swe=-1; hs=-1; a=-1;} {if(data==1) {a=mktime(sprintf("%04d %02d %02d %02d %02d %02d 0", substr($1,1,4), substr($1,6,2), substr($1,9,2), substr($1,12,2), substr($1,15,2), substr($1,18,2))); aloc=a+(lon/15)*3600; print $1, a, strftime("%Y-%m-%dT%H:%M:%S", aloc), aloc, $mswater, $swe, ($hs/100.)}; if(/\[DATA\]/) {data=1}; if(/fields/) {for(i=3; i<=NF; i++) {if($i=="MS_Water") {mswater=(i-2)}; if($i=="HS_mod") {hs=(i-2)}; if($i=="SWE") {swe=(i-2)}}}}' >> ${g2}.1
		echo "#timestamp FAC_total LWC_total_kg" > ${g2}.2
		bash ${snowpack_tools_dir}/extract_timeseries.sh <(unzip -p ./${z} output/${f2}) | grep -v ^# | mawk '{print $1, $8*$2, $7*$2}' >> ${g2}.2
		echo "#timestamp FAC_0.5m LWC_0.5m_kg" > ${g2}.3
		bash ${snowpack_tools_dir}/extract_timeseries.sh <(unzip -p ./${z} output/${f2}) d=0.5 | grep -v ^# | mawk '{print $1, $8*$2, $7*$2}' >> ${g2}.3
		echo "#timestamp FAC_2m LWC_2m_kg" > ${g2}.4
		bash ${snowpack_tools_dir}/extract_timeseries.sh <(unzip -p ./${z} output/${f2}) d=0.5 | grep -v ^# | mawk '{print $1, $8*$2, $7*$2}' >> ${g2}.4
		join -o1.1,1.2,1.3,1.4,1.5,1.6,1.7,2.2,2.3,2.4,2.5,2.6,2.7 -a 1 -e -9999 ${g2}.1 <(join ${g2}.3 ${g2}.4 | join - ${g2}.2) > ${g2}
		rm ${g2}.[0-9]

		zip ${gz} ${g} ${g2} ${g3}
		rm ${g} ${g2} ${g3}
	done
	popd
}

process
