#!/usr/bin/expect -f

set force_conservative 0
if {$force_conservative} {
        set send_slow {1 .1}
        proc send {ignore arg} {
                sleep .1
                exp_send -s -- $arg
        }
}

set THREADS [lindex $argv 0]
set PRIORITY [lindex $argv 1]
set OUTPUT_FILES_SAVE [lindex $argv 2]

set timeout -1
spawn ./covid-solver
match_max 100000
send -- "\r"
expect -re ".*Please enter how many threads you would like this software to use.*"
send -- "$THREADS\r"
expect -re ".*priority for this software.*"
send -- "$PRIORITY\r"
expect -re ".*keep the RxDock output files?.*"
send -- "$OUTPUT_FILES_SAVE\r\n"

expect -re ".*Newer version of script found.*"
send -- "Yes\r"

interact
expect eof
