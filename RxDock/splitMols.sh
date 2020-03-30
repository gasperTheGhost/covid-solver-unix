#!/bin/bash
#Usage: splitMols.sh <input> #Nfiles <outputRoot>
fname=$1
nfiles=$2
output=$3
molnum=$(grep -c '$$$$' $fname)
echo "$molnum molecules found"
echo "Dividing '$fname' into $nfiles files"
rawstep=`echo $molnum/$nfiles | bc -l`
let step=$molnum/$nfiles
if [ ! `echo $rawstep%1 | bc` == 0 ]; then
        let step=$step+1;
fi;
sdsplit -$step -o$output $1