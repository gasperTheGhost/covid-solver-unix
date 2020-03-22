#!/bin/bash
#
# This is prototype script for OPENSCIENCE project 
# Prototipna skripta za Citizen Science COVID-19 drug search
# 22.3.2020
# v0.5
Version="0.5"
operatingsys="<operating system (mac/linux)>" # Only valid options are mac or linux
#
# CHANGELOG
#   + v0.5   
#       - Added multiple target support
#       - Added periodic update check
#       - Migrated server
#       - Fixed update script call
#       - Added update blocker
#       - Added ability to pre-set save output and thread variables, thus making updates unnoticable
#
#   + v0.4.1
#       - Added update wizard
#       - cURL is now silent
#       - Added check to see if there are any more structures to calculate
#   
#   + v0.4
#       - Migrated from FTP server to cURL dedicated API
#  
#   + v0.3
#       - Added cleanup
#       - Added user interaction
#       - Added auto continue
#       - Added thread checking and selection
#       - Added file checking before updating counter
#
#   + v0.2
#       - Changed ftp from active to passive
#
FirstLoopFinished=0
#
# Set variables according to selected OS
#
if [ $operatingsys = mac ]; then
    FlexX=lib/FlexX.app/Contents/MacOS/FlexX
    versionCheckAPI="<versionCheckAPI" # Ex.: http://some.server.com/path/to/versionMac
    threadCheckCommand="sysctl -n hw.ncpu"
elif [ $operatingsys = linux ]; then
    FlexX=lib/flexx-4.1-Linux-x64
    versionCheckAPI="<versionCheckAPI>" # Ex.: http://some.server.com/path/to/versionLinux
    threadCheckCommand="nproc"
else
    echo "Operating system not specified or invalid!"
    echo "Exiting..."
    exit
fi
# Declare executable var

# Set API key var
apikey="<apikey>"
server="<api server>" # DO NOT END WITH A SLASH!!!!!!!!!!!
# Set license environment variable
license=$(ls lib | grep *.lic)
export BIOSOLVE_LICENSE_FILE=$PWD/lib/$license
#
# Check for updates
#
version_check() {
    if ! [ -e no.update ]; then
        start_time=$(date +%s)
        currentVersion="$(curl -s --request GET $versionCheckCommand)"
        if ! [ $Version = $currentVersion ] && ! [ $currentVersion = *DOCTYPE* ]; then
            echo "Newer version of script found."
            if [ $FirstLoopFinished -eq 1 ]; then
                echo "Saving settings..."
                echo $add_arg_flexx > settings.update
                echo $savdel >> settings.update
                echo $operatingsys >> settings.update
            fi    
            echo "Attempting auto-update..."
            mv lib/update.sh update.sh
            chmod +x update.sh
            /bin/bash update.sh
            exit
        elif [ $currentVersion = *DOCTYPE* ]; then
            echo "Error checking for updates!"
            echo "Continuing..."
        elif [ $Version = $currentVersion ]; then
            echo "You are running the newest version of the script"
        fi
        if [ -e update.sh ]; then
            rm -f update.sh
        fi
    else
        echo "Update block enabled, skipping check..."
    fi
}
#
# Declare main function
#
main_func() {
    #
    # STEP 0. CHECK UPDATES IF TWELVE HOURS HAVE PASSED
    #
    let time_elapsed=$end_time-$start_time
    if [ $time_elapsed -gt 43200 ]; then
        version_check
    fi
    #
    # STEP 1. CHECK THE COUNTER 
    #
    # Get target counter value
    t=$(curl -s --request GET $server/target)
    let tnum=$t
    # Get structure counter value
    c=$(curl -s --request GET $server/$tnum/counter)
    let cnum=$c
    # Check if there's any structures left on server
    while [ $cnum -eq -1 ]; do
        echo "Ran out of structures to calculate"
        echo "We are constantly adding structures to our database"
        echo "The program will continue checking for new structures every 30mins"
        read -t 1800 -p "Press T to [t]erminate script or enter to recheck now..." empty
        case $empty in
            [Tt]*) rm -f TEST_PRO_$tnum.pdb TEST_REF_$tnum.sdf; exit;;
            *) echo "Rechecking..."; main_func;;
        esac
    done
    fx="3D_structures_$cnum.sdf"
    #
    # STEP 2. DOWNLOAD A PACKAGE WITH LIGANDS
    #
    while true; do
        curl -s --request GET $server/$tnum/file/down/$cnum --output $fx
        health=$(head -n 1 $fx) # Check if file is healthy
        if [ -e $fx ] && ! [ "$health" = *DOCTYPE* ]; then
            break # Continue if file is healthy
        else
            echo "Error downloading structure!"
            read -t 5 -p "Retrying in 5 sec... [A]bort " hp
            case $hp in
                [Aa]*) rm -f TEST_PRO_$tnum.pdb TEST_REF_$tnum.sdf $fx; exit;;
                *) echo "Retrying...";;
            esac
        fi
    done
    #
    # STEP 3. DOWNLOAD TARGET AND REFERENCE LIGAND
    #
    if [ $FirstLoopFinished -eq 0 ] || ! [ -e TEST_REF_$tnum.sdf -a -e TEST_PRO_$tnum.pdb ]; then
        rm -f TEST_PRO_$tnum_old.pdb TEST_REF_$tnum_old.sdf
        while true; do
            curl -s --request GET $server/$tnum/file/target/test_pro --output TEST_PRO_$tnum.pdb
            health=$(head -n 1 TEST_PRO_$tnum.pdb) # Check if file is healthy
            if [ -e TEST_PRO_$tnum.pdb ] && ! [ "$health" = *DOCTYPE* ]; then
                break # Continue if file is healthy
            else
                echo "Error downloading target!"
                read -t 5 -p "Retrying in 5 sec... [A]bort " hp
                case $hp in
                    [Aa]*) rm -f TEST_PRO_$tnum.pdb TEST_REF_$tnum.sdf $fx; exit;;
                    *) echo "Retrying...";;
                esac
            fi
        done
        while true; do
            curl -s --request GET $server/$tnum/file/target/test_ref --output TEST_REF_$tnum.sdf
            health=$(head -n 1 TEST_REF_$tnum.sdf) # Check if file is healthy
            if [ -e TEST_REF_$tnum.sdf ] && ! [ "$health" = *DOCTYPE* ]; then
                break # Continue if file is healthy
            else
                echo "Error downloading reference ligand!"
                read -t 5 -p "Retrying in 5 sec... [A]bort " hp
                case $hp in
                    [Aa]*) rm -f TEST_PRO_$tnum.pdb TEST_REF_$tnum.sdf $fx; exit;;
                    *) echo "Retrying...";;
                esac
            fi
        done
    fi
    #
    # STEP 4. RUNNING DOCKING WITH FLEXX
    #
    echo "Docking package $cnum"
    outfx="OUT_T$tnum"'_'"$cnum.sdf"
    $FlexX -p TEST_PRO_$tnum.pdb -r TEST_REF_$tnum.sdf -i $fx -o $outfx -v 4 --max-nof-conf 1$add_arg_flexx
    #
    # STEP 5. UPLOAD RESULTS TO SERVER
    #
    echo "Uploading package $outfx"
    curl -s --request POST -F "data=@$outfx" -F "apikey=$apikey" $server/$tnum/file/$cnum
    #
    # STEP 6. CLEANUP
    #
    rm -f $fx
    if [ "$savdel" = "d" ]; then
        rm -f $outfx
    fi
end_time=$(date +%s)
FirstLoopFinished=1
redo
} # End main function

redo() {
    read -t 10 -p "Would you like to calculate the next package? (Y/n) " yn
    case $yn in
        [Yy]* ) main_func;;
        [Nn]* ) tnum_old=$tnum; rm -f TEST_PRO_$tnum.pdb TEST_REF_$tnum.sdf $fx; exit;;
        * ) main_func;;
    esac
    main_func
}

#
# User input dialogue
#
start_dialogue() {
    echo "Welcome to the CITIZEN SCIENCE COVID-19 v$Version"
    # Check threads
    threads=$($threadCheckCommand)
    if [ $threads -gt 0 ]; then
        echo "Your current machine has $threads available threads"
        while true; do
            read -p "Please enter how many threads you would like this software to use (1-$threads/[A]ll) " thread_count
            if [ "$thread_count" = "A" ] || [ "$thread_count" = "All" ] || [ "$thread_count" = "all" ] || [ "$thread_count" = "a" ]; then
                add_arg_flexx=""
                break;
            elif [ "$thread_count" = "" ]; then
                add_arg_flexx=""
                break;
            elif ! [ $thread_count -gt $threads ] && [ $thread_count -gt 0 ]; then
                add_arg_flexx=" --thread-count $thread_count"
                break;
            else
                echo Please enter a valid number of cores
            fi
        done
    else
        while true; do
            read -p "Cannot determine available threads, would you like to continue with all processing power? (Y/n) " yn
            case $yn in
                [Yy]* ) add_arg_flexx=""; break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    if [ $FirstLoopFinished -eq 0 ]; then
        while true; do
            read -p "Would you like to keep the FlexX output files? ([Y]es/[n]o) " savdel
            case $savdel in
                [Yy]* ) savdel="s"; main_func; break;;
                [Nn]* ) savdel="d"; main_func; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
}

#
# *** PROGRAM START *** #
#
version_check
if [ -e settings.update ]; then
    FirstLoopFinished=1
    start_time=$(date +%s)
    add_arg_flexx="$(head -n 1 settings.update)"
    savdel="$(sed '2q;d' settings.update)"
    main_func
else
    start_dialogue
fi
#
#
# EoF