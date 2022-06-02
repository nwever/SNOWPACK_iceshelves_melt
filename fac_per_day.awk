#!/usr/bin/awk -f 
# Note: this script should be called after setting:
#  -v lt=<local time>		(0=no, use UTC, 1=yes, use local time)
BEGIN {
	yr=-1;

{
	# Check if we get to a new site (first line starts with #)
	if(substr($1,1,1)=="#") {
		if(yr!=-1) {
			# Note that multiple lines with # can occur, yet in those cases we only need to increase the counter once
			i++;
		}
		yr=-1
	} else {
		# Split date in hour, day, month, year
		hr=substr((lt)?($3):($1),12,2);
		dd=substr((lt)?($3):($1),9,2);
		mm=substr((lt)?($3):($1),6,2);
		yr=substr((lt)?($3):($1),1,4);
		yrmmdd=sprintf("%04d%02d%02d", yr, mm, dd);
		# store the dates
		yrmmdds[yrmmdd]=yrmmdd;
		# Store the site numbers
		pp[i]=i;
		# Set the index to store the information
		idx=sprintf("%d,%08d", i, yrmmdd);
		# Calculate FAC
		fac=$7-(($6-$5)/917.)-($5/1000.);
		if(hr==12) {
			s[idx]=fac;
		}
	}
}
END {
	# Generate output
	ny=asort(yrmmdds);	# Make sure we loop over the years in sequence
	ni=asort(pp);		# Make sure we loop over the sites in sequence
	for(y=1; y<=ny; y++) {	# Loop over years
		printf("%08d", yrmmdds[y]);
		for(i=1; i<=ni; i++) {	# Loop over sites
			idx=sprintf("%d,%08d", pp[i], yrmmdds[y]);
			printf " %.3f", (idx in s)?(s[idx]):(0)
		}
		printf "\n";
	}
}
