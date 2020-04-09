###############################################################################
### Create artificial seconds. 
###########################

### Import file needs to contain one column with the time (hhmm), with header "hourminute"

### Things to fix:
#- if there is a duplicate second in the first line(s) they will not get artificial seconds (all get 0 seconds). FIX THIS!!!
#- seconds can be 60. fix this so that the highest second is 59

scriptdir <- getwd()

wd <- "/Users/rpr061/Documents/DATAMANAGEMENT/SOCAT/Test_area/overlaps_v5/Datafiles/internal_overlaps"
file <- "fix_seconds.txt"

#read.netcdf <- function(wd, file, ) {}
  
## Set working directory
setwd(wd)

#---------------------------------------------------------------------------------- 
## READ NetCDF FILE INTO R


## Import all data:
data <- read.table(file, header=TRUE) 


## create new column with seconds.
## First, let it be filled with zeros
data$second <- rep(999,length(data[,1]))

## For løkke som gir 0 der det ikkje er duplicate secund.
for (i in 1:(length(data[,1])-1)) {
    if(data$hourminute[i] != data$hourminute[i+1]) {
      data$second[i+1] <- 0
    }else {data$second[i+1] <- 999}
}



## For løkke som lager ny kolonne som tell seier kor mange like det er av dette tidspunktet etter kvarandre
data$count <- rep(998,length(data[,1]))

for (i in 1:(length(data[,1])-1)) {
  if (data$second[i+1]==999 & data$second[i]==0) {
    
       n.loops <- 0    
       for (j in i:(length(data[,1])-1)) {
          if (data$second[j+1]==0) break
      
          dummy <- n.loops + 1
          n.loops <-  dummy     
    }
      
    
    data$count[i]<-n.loops +1
  
    
    
  }else {data$count[i]<-0}
}





## For løkke som lager sekunder
data$art.sec <- rep(0,length(data[,1]))

for (i in 1:(length(data[,1])-1)) {
  if (data$count[i]>0) {
      
         multiplier <- 0
         for (j in i:(i+(data$count[i]-1))) {
         data$art.sec[j] <- (60/data$count[i])*multiplier # Use "60" when want to find minute! I used "1" because I needed to find decimals for a file with seconds but that still got duplicate times.
         dummy <- multiplier + 1
         multiplier <- dummy 
         }
   }
    
}

  
       
    


## Write output file
    
write.table(data, "artificial_seconds.txt", sep="\t", row.names=FALSE, col.names =TRUE, quote = FALSE)

setwd(scriptdir)


