#!/bin/bash
# Must be called from run_rxdock!
# Syntax: /bin/bash update.sh <GitHub username> <GitHub repo> 
operatingsys="$(sed '3q;d' settings.update)"
#
# Set variables according to selected OS
#
if [ $operatingsys = mac ]; then
    newVersionURL=$(curl -s https://api.github.com/repos/$1/$2/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep macOS) # Expects archive with macOS in its name in releases
    runFile="start_docking.command"
elif [ $operatingsys = linux ]; then
    newVersionURL=$(curl -s https://api.github.com/repos/$1/$2/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep linux64) # Expects archive with linux64 in its name in releases
    runFile="start_docking.sh"
else
    echo "Operating system not specified or invalid!"
    echo "Exiting..."
    exit
fi
#
# Start update
#
echo "Downloading update archive..."
curl --request GET $newVersionURL --output update.zip
if [ -e update.zip ] && ! [ $(head -n 1 update.zip) = *DOCTYPE* ]; then
    echo "Installing..."
    rm -rf lib $runFile
    unzip update.zip
    rm -f update.zip
    echo "Update successful!"
    /bin/bash $runFile
    exit
else
    rm -f update.zip
    echo "Error downloading update!"
    read -p "Please update manually from $newVersionURL"
    exit
fi