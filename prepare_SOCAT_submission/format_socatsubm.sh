#!/bin/bash

~/Documents/DATAMANAGEMENT/SOCAT/Scripts/Split_cruises_tcl/split_cruises_windows.tcl ./Gould_2016_All.csv ./ ',' 1

files=($(ls *.txt))
for f in $(seq 0 $((${#files[@]} - 1))) 
            # Change commas for tabs
      do sed -i '.bak' $'s/,/\t/g' "${files[$f]}"
            
            # Insert 4 first lines of info (required by SOCAT dashboard)
            expocode=$(echo ${files[$f]}| cut -d'.' -f 1)
            
            sed -i '.bak' "1i\ 
            Expocode: ${expocode}
            " "${files[$f]}"

            sed -i '.bak' '2i\
            Ship: Laurence M. Gould
            ' "${files[$f]}"

            sed -i '.bak' '3i\
            PIs: Takahashi, T.; Sutherland, S. C.; Sweeney, C.
            ' "${files[$f]}"

            sed -i '.bak' '4i\
            Vessel Type: Ship
            ' "${files[$f]}"

# Remove backup files .bak (for MacOS# Remove backup files .bak)
rm *.bak

      done

