#!/usr/bin/awk -f 
# Note: this script should be called after setting:
#  -v var=<SMET variable>	(SMET variable name)
#  -v lt=<local time>           (0=no, use UTC, 1=yes, use local time)
BEGIN {
	h=0;		# Flag if we are in header
	d=0;		# Flag if we are in DATA block
	nodata=-999;	# Default nodata value, to be overwritten when found in *smet file
}
{
	# Check if we get to a new site (first line starts with #)
	if($0=="SMET 1.1 ASCII") {
		h=1;	# Entering header section ....
		d=0;	# .... leaving data section
		i++;	# Increase site number
                # Store the site numbers
                pp[i]=i;
		# Reset columns
		col=-999;
		colU=-999;
		colV=-999;
	} else if (substr($1,1,6)=="fields") {
		# Read fields
		for (j=3; j<=NF; j++) {
			if ($j==var) {
				wind=0;
				col=j-2;
			}
			# For VW, try to see if the smet file provides components U and V
			if (var=="VW" && col==-999) {
				if ($j=="U") {
					colU=j-2;
				}
				if ($j=="V") {
					colV=j-2;
				}
			}
		}
	} else if (substr($1,1,6)=="nodata") {
		# Read nodata value from smet file
		nodata=$NF
	}
	if (d) {
		# If in data section, calculate averages
		mm=int(substr((lt)?($3):($1),6,2));	# Get month
		yr=int(substr((lt)?($3):($1),1,4));	# Get year
		yrmm=yr*100+mm;				# Construct index
		yearsmonths[yrmm]=yrmm;			# Store year/month combinations
		idx=sprintf("%d,%06d", i, yrmm);	# Index to use
		if (col>0 && $col!=nodata) {
			# Calculate statistics when column was specified and is not nodata
			s[idx]+=$col;
			n[idx]++;
		} else {
			# If the above fails, try to see if we are working with wind speed components
			if(colU>0 && colV>0) {
				vw=sqrt($colU*$colU + $colV*$colV);	# Calculate wind speed from components
				s[idx]+=vw;
				n[idx]++;
			}
		}
	}
	if ($0=="[DATA]") {
		h=0;	# Leaving header section ....
		d=1;	# .... entering data section
	}
}
END {
	# Generate output
	nym=asort(yearsmonths);	# Make sure we loop over the years in sequence
	ni=asort(pp);		# Make sure we loop over the sites in sequence
	for(y=1; y<=nym; y++) {	# Loop over years
		printf("%d", yearsmonths[y]);
		for(i=1; i<=ni; i++) {	# Loop over sites
			idx=sprintf("%d,%d", pp[i], yearsmonths[y]);
			printf " %f", (idx in n)?(s[idx]/n[idx]):(nodata)
		}
		printf "\n";
	}
}
