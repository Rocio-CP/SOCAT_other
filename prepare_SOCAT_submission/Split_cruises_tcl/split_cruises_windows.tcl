#!/usr/bin/tclsh
# 
proc isNumeric {value} {

    set result 0

    if {[string length $value] > 0} {
        regexp "\(\[0-9.\]*\)" $value dummy numbers

        if {[string length $numbers] == [string length $value]} {
            set result 1
        }
    }

    return $result
}

set infile [lindex $argv 0]
set outdir [lindex $argv 1]
set separator [lindex $argv 2]
set expoCodeCol [lindex $argv 3]

if {$expoCodeCol == ""} {
    puts "Usage: split.tcl \[file\] \[outdir\] \[separator\] \[EXPO Code Col\]"
    exit
}

if {$separator == "\\t"} {
    set separator "\t"
}

# Read in the file
puts "Reading file..."
set chan [open $infile r]
set data [read $chan]
set lines [split $data "\n"]
close $chan

# Find the header lines
set headers [list]

set headerFound 0
set headerLastLine 0

while {!$headerFound} {
    set line [lindex $lines $headerLastLine]

    set fields [split $line $separator]

    if {[llength $fields] >= 5} {
        set headerFound 1
        lappend headers $line
    }

    incr headerLastLine
    if {$headerLastLine > [llength $lines]} {
        puts "Fell off end of file."
        exit
    }
}

set firstDataLine $headerLastLine
set foundData 0

while {$foundData == 0} {
    set line [lindex $lines $firstDataLine]

    set numericFields 0

    set fields [split $line $separator]
    for {set i 0} {$numericFields == 0 && $i < [llength $fields]} {incr i} {
        set numericFields [isNumeric [lindex $fields $i]]
    }

    if {$numericFields == 0} {
        lappend headers $line
        incr firstDataLine
    } else {
        set foundData 1
    }

}

set currentExpoCode ""
set outChan ""
for {set i $firstDataLine} {$i < [llength $lines]} {incr i} {

    set line [lindex $lines $i]
    set fields [split $line $separator]
    if {[llength $fields] > 1} {
        set lineExpoCode [lindex $fields $expoCodeCol]

        if {[string compare $lineExpoCode $currentExpoCode] != 0} {
            if {$currentExpoCode != ""} {
                close $outChan
            }

            set currentExpoCode $lineExpoCode

            set outFile "${outdir}/${lineExpoCode}.txt"
            if {$separator == "\t"} {
                set outFile "${outdir}/${lineExpoCode}.txt"
            }

          puts $outFile
            set outChan [open $outFile w]
            foreach headerLine $headers {
                puts $outChan $headerLine
            }
        }
    }

    puts $outChan $line
}

close $outChan

