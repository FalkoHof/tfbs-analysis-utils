options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
print(args)

#read in values from command line
test.values.file =  args[1]
random.values.file = args[2]
output.file =  args[3]
output.plot = args[4]

#read in line count from the test sample
test.value = try(system(paste('wc -l', test.values.file) ,intern = TRUE))
test.value <- sapply(strsplit(test.value, " "), "[", 3)

#read in data
random.dist.values <- read.table(random.values.file, header=F, sep =' ', stringsAsFactors = F)
#fit and estimate ecdf
P = ecdf(random.dist.values$V1)    

#get probabilty value for the "measured value" 
test.prob <- P(test.value)
#calcualte pvalue
p.value <- 1-test.prob

#plot ecdf with the p-value
png(output.plot)
plot(P,pch=20)
points(test.value,P(test.value), col='red',pch=19)
dev.off()