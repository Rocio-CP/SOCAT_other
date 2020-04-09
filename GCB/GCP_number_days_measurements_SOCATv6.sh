#!/bin/bash

dirfiles='/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/SOCATv6All_SocatEnhancedData/'
dirsummary='/Users/rpr061/Downloads/'
summaryfile='GCB_Datasets_expocode.tsv'

printf "Expocode\tNumb_Days\tNumb_Measurem\n" >> number_measure_info.txt

while IFS=$' \t\r\n' read -r expocodeline ; do 
     expocode=$expocodeline; 
     datafile=$(find ${dirfiles} -name ${expocode}_SOCAT_enhanced.tsv)
     headerline=$(grep -n "Expocode\tversion\tSOCAT_DOI" $datafile | awk -F  ":" '{print $1}')
     firstline=$(($headerline +1))


while IFS=$' \t\r\n' read -r dataline ; do
      # Measurement is flagged 2 (good)
      flag=$(echo $dataline | awk '{print $32}')
      year=$(echo $dataline | awk '{print $5}')
      month=$(echo $dataline | awk '{print $6}')
      day=$(echo $dataline | awk '{print $7}')
#echo $flag
#echo $year
      
      if [ ${flag} -eq 2  ]; then # if they need only flag=2

if [ ${year} -eq 2017  ]; then # only 2017 measurements
printf "${year}/${month}/${day}\n" >> dates.txt
fi
fi

done < <(tail -n "+$firstline" $datafile) 

nummeas=$(wc -l dates.txt | awk '{print $1}')
numdays=$(uniq -c dates.txt | wc -l)

mv dates.txt  dates${expocode}.txt

printf "${expocode}\t${numdays}\t${nummeas}\n" >> number_measure_info.txt

done < ${dirsummary}${summaryfile}
