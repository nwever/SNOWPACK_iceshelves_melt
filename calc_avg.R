#
# This R script reads from stdin, calculates mean and sd per row (excluding the first column, which can be a key, like year, or date)
# and prints the row, followed by a column containing the mean per row, and a column containing the sd per row.
#

printf <- function(...) cat(sprintf(...))
data<-read.table(file("stdin"), na.strings = "-999", header=FALSE);
nf=ncol(data)
if(nf==2) {
	data$mean <- data[,2]
	data$sd <- NA
} else {
	data$mean <- apply(data[,2:nf], 1, mean)
	data$sd <- apply(data[,2:nf], 1, sd)
}

# Print header
printf("#Year ");
for(i in 2:ncol(data)) {
	if(i<=nf) {
		printf(" %d", i-1);
	} else {
		printf(" %s", colnames(data)[i]);
	}
}
printf("\n");
# Print data
write.table(data, col.names = FALSE, row.names = FALSE, quote = FALSE, sep = " ")
