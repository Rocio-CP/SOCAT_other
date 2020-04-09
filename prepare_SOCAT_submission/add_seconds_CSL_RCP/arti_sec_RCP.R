###############################################################################
### Create artificial fractions of seconds. 
###########################

### Import file needs to contain one column with the time (hhmm), with header "hourminute"

### Things to fix:
#- if there is a duplicate second in the first line(s) they will not get artificial seconds (all get 0 seconds). FIX THIS!!!
#- seconds can be 60. fix this so that the highest second is 59

## Modified by RCP from script recieved from CSL 17.Jan.2017. Modified to take into account seconds already present in the file; therefore only adding decimals when duplicates arise

#wd <- "/Users/rpr061/Dropbox/SOCATv6/QC_new_metadata_data/Agneta_Fransson/work_space/"
file <- "fix_seconds.txt"

#read.netcdf <- function(wd, file, ) {}
  
## Set working directory
#setwd(wd)

#---------------------------------------------------------------------------------- 
## READ NetCDF FILE INTO R


## Import all data:
data <- read.table(file, header=TRUE) 


## create new column with seconds.
## First, let it be filled with zeros
data$fractionofsecond <- rep(999,length(data[,1]))

## For l?kke som gir 0 der det ikkje er duplicate secund.
for (i in 1:(length(data[,1])-1)) {
    if(data$hourminutesecond[i] != data$hourminutesecond[i+1]) {
      data$fractionofsecond[i+1] <- 0
    }else {data$fractionofsecond[i+1] <- 999}
}



## For l?kke som lager ny kolonne som tell seier kor mange like det er av dette tidspunktet etter kvarandre
data$count <- rep(998,length(data[,1]))

for (i in 1:(length(data[,1])-1)) {
  if (data$fractionofsecond[i+1]==999 & data$fractionofsecond[i]==0) {
    
       n.loops <- 0    
       for (j in i:(length(data[,1])-1)) {
          if (data$fractionofsecond[j+1]==0) break
      
          dummy <- n.loops + 1
          n.loops <-  dummy     
    }
      
    
    data$count[i]<-n.loops +1
  
    
    
  }else {data$count[i]<-0}
}





## For l?kke som lager sekunder
data$art.sec <- rep(0,length(data[,1]))

for (i in 1:(length(data[,1])-1)) {
  if (data$count[i]>0) {
      
         multiplier <- 0
         for (j in i:(i+(data$count[i]-1))) {
         data$art.sec[j] <- (1/data$count[i])*multiplier # Use "60" when want to find minute! I used "1" because I needed to find decimals for a file with seconds but that still got duplicate times.
         dummy <- multiplier + 1
         multiplier <- dummy 
         }
   }
    
}

  
       
    


## Write output file
    
write.table(data, "artificial_seconds.txt", sep="\t", row.names=FALSE, col.names =TRUE, quote = FALSE)




