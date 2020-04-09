#!/bin/bash

dirfiles='/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/SOCATv6All_SocatEnhancedData/'
dirsummary='/Users/rpr061/Downloads/'
summaryfile='GCB_Datasets_expocode.tsv'
socatfile='SOCATv6.tsv'


while IFS=$' \t\r\n' read -r expocodeline ; do 
     expocode=$expocodeline; 
grep -m 1 "$expocode" ${dirsummary}${socatfile} >> dois.txt

done < ${dirsummary}${summaryfile}
     
