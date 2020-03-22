#!/bin/bash
operatingsys="$(sed '3q;d' settings.update)"
#
# Set variables according to selected OS
#
if [ $operatingsys = mac ]; then
    newVersionURL="<newVersionURL>" # Ex.: https://some.server.com/path/to/newVersionMac.zip
    runFile="run_flexx.command"
elif [ $operatingsys = linux ]; then
    newVersionURL="<newVersionURL>" # Ex.: https://some.server.com/path/to/newVersionLinux.zip
    runFile="run_flexx.sh"
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