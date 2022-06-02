#!/usr/bin/awk -f 
# Note: this script should be called after setting:
#  -v col=<column>		(column number to analyze)
#  -v lt=<local time>		(0=no, use UTC, 1=yes, use local time)
#  -v fd=<full day>		(0=only 6:00-10:00 AM/PM, 1=24 hours)
#  -v th=<threshold>		(threshold to use for the average of col)
BEGIN {
	yr=-1;
	dd=-1;
}
{
	# Check if we get to a new site (first line starts with #)
	if(substr($1,1,1)=="#") {
		if(yr!=-1) {
			# Note that multiple lines with # can occur, yet in those cases we only need to increase the counter once
			i++;
		}
		yr=-1
	} else {
		# Split date in day, month, year
		dd=substr((lt)?($3):($1),9,2);
		mm=substr((lt)?($3):($1),6,2);
		yr=substr((lt)?($3):($1),1,4);
		if(mm>=11) {
			# Take care of the definition of melt year, running from November to March
			yr++;
		};
		# Split time in hr, min
		hr=substr((lt)?($3):($1),12,2);
		min=substr((lt)?($3):($1),15,2);
		hrmin=100*(hr*100+min);
		# store the years
		years[yr]=yr;
		# Store the site numbers
		pp[i]=i;
		# If we move to a new day, check for idx is necessary so that this is skipped for the very first data point
		if(dd!=dd_old && idx!=0) {
			if(k>0 && (s/k)>th && (mm_old>=11 || mm_old<=3)) {
				n[idx]++;
			}
			s=0; # Tracks the sum to calculate the average
			k=0; # Tracks the count to calculate the average
		}
		if((hrmin>=60000 && hrmin<=100000) || (hrmin>=180000 && hrmin<=220000) || fd==1) {
			s+=$col;
			k++;
		}
		# Set the index to store the information
		idx=sprintf("%d,%d", i, yr);
		# Keep track of the day we are summing melt over
		dd_old=dd;
		mm_old=mm;
	}
}
END {
	# Generate output
	ny=asort(years);	# Make sure we loop over the years in sequence
	ni=asort(pp);		# Make sure we loop over the sites in sequence
	for(y=1; y<=ny; y++) {	# Loop over years
		printf("%d", years[y]);
		for(i=1; i<=ni; i++) {	# Loop over sites
			idx=sprintf("%d,%d", pp[i], years[y]);
			printf " %d", (idx in n)?(n[idx]):(0)
		}
		printf "\n";
	}
}
