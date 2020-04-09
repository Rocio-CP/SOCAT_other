#!/bin/bash

# ALL THIS ASSUMES 1-LINE HEADERS!!

# Convert to txt using libreoffice. It uses commas as separation!!
# It's the most time-consuming script
for f in *.xlsx
      do soffice --headless --convert-to txt:"Text - txt - csv (StarCalc)" "$f"
      done
# Replace commas with tabs. 
# This line is tailored to MacOS. Sed is much more simple in UNIX :(
# sed is incredibly awkward in MacOS...
for f in *.txt 
      do sed -i '.bak' $'s/,/\t/g' "$f"
      done
# Remove backup files .bak (for MacOS# Remove backup files .bak)
rm ./*.bak

# Add 1st column with file name. Useful for splitting after concatenation
files=($(ls *.txt))
for f in $(seq 0 $((${#files[@]} - 1))) 
      do sed -i '.bak' "s/^/${files[$f]}"$'\t/g' "${files[$f]}"
      sed -i '.bak' "1 s/^${files[$f]}/Filename/g" "${files[$f]}"
      done
rm *.bak

# Create "structure" file with the file name + header. 
#files=($(ls *.txt))
for f in $(seq 0 $((${#files[@]} - 1))) 
      do head -n 1 ${files[$f]} >> structure
#      sed -i '.bak' '$'"s/$/"$'\t'"${files[$f]}/" structure
      sed -i '.bak' '$'"s/^/${files[$f]}"$'\t'"/" structure
#      sed -i '.bak' '$'"s/$/"$'\t'"$f/" structure
      done

#for f in *.txt 
#      do head -n 1 $f >> structure
#      sed -i '.bak' '$'"s/^/$f"$'\t'"/" structure
#      done

# Sort structure file and identify how many uniques headers (excluding 1st column, i.e. file name)
sort structure -k 2 > sortedstructure
uniq -f 1 sortedstructure > uniqueheaders
# Remove file name from uniqueheaders
sed -i '.bak' "s/^[a-zA-Z0-9]*.txt"$'\t'"//g" uniqueheaders

# More than one type of header (different columns, in number and/or order)
if [ $(wc -l < uniqueheaders) -gt 1 ]
then
      for d in $(seq 1 $(($(wc -l < uniqueheaders) - 0)))
      do mkdir -p S$d

      # Pick one header
      uniheader=$(sed -n $d'p' uniqueheaders)
      # Find lines (and therefore filenames) with same header in structure file
      grep "$uniheader" structure > tempstructure
      # Get only file names
      filesuniheader=($(cut -f1 tempstructure))
# Move the files into the folder
for fuh in $(seq 0 $((${#filesuniheader[@]} - 1)))
     do cp ${filesuniheader[$fuh]} ./S$d/
     done

     cd ./S$d
     # Join into one large file allS.txt, with only one the first line of headers.  (and do calculations in Excel)
head -n 1 ${filesuniheader[1]} > allS$d.txt
     for fuh in $(seq 0 $((${#filesuniheader[@]} - 1)))
     do tail -n +2 ${filesuniheader[$fuh]} >> allS$d.txt 
     done
# Open the All file with Excel to calculate appropriate equilibrium pressure. Quit Excel completely to return to script!!
open ./allS$d.txt -W -a "Microsoft Excel"

# MacOS excel saves .txt with ^M as carriage return, and in Vim it looks like one large line. Fix it:
     tr '\r' '\n' < allS$d.txt > allS$d$d.txt
     
     # Split into the original .txt files (use Steve's tcl script)
tclsh ../split_cruises_windows.tcl ./allS$d$d.txt ./ '\t' 0

# The split routine appends .txt to the file names; remove the extra one
#rm allS$d.txt
     for fuh in $(seq 0 $((${#filesuniheader[@]} - 1)))
     do mv ${filesuniheader[$fuh]}.txt ${filesuniheader[$fuh]}
     done

cd ..
done

# If only 1 type of header, merge into one file
else
     for f in $(seq 0 $((${#files[@]} - 1)))
     do tail -n +2 ${files[$f]} >> all.txt 
     done

     open ./all.txt -W -a "Microsoft Excel"

# MacOS excel saves .txt with ^M as carriage return, and in Vim it looks like one large line. Fix it:
     tr '\r' '\n' < all.txt > all2.txt
     
     # Split into the original .txt files (use Steve's tcl script)
tclsh ./split_cruises_windows.tcl ./all2.txt ./ '\t' 0
     for f in $(seq 0 $((${#files[@]} - 1)))
     do mv ${files[$f]}.txt ${files[$f]}
     done

fi


