# covid-solver-unix
This is the mac/linux universal version of the script used for automated docking in the [Open Science Project COVID-19](https://koronavirus.ctk.uni-lj.si/skupnostna-znanost)
It is used in conjunction with [pevecyan](https://github.com/pevecyan)'s [covid-solver-queue](https://github.com/pevecyan/covid-solver-queue)

[Windows version](https://github.com/pevecyan/covid-solver-windows-)

## Compiling
To use the script as intended RxDock/run_rxdock.sh has to be compiled with
```
cd /path/to/script
shc -r -f run_rxdock.sh -o run_rxdock
```
## Dependencies
* shc [Shell Script Compiler](https://neurobin.org/projects/softwares/unix/shc/) (for compiling)
* [RxDock](https://rxdock.org/)
* Python 2 (>=2.6)
* curl

## File structure of working installation
```
start_docking.command (or .sh on linux)
rxdock.config*
no.update*
RxDock/run_rxdock
RxDock/update.sh
RxDock/splitMols.sh
RxDock/bin - RxDock binary folder
RxDock/lib - RxDock library folder
RxDock/data - RxDock data folder
```
### Target archive
In lieu of minimizing server strain the script expects to get all files pertaining to the target in a zip archive named TARGET_\<target-number>.zip

The inside file structure should be as follows:
```
TARGET_REF_<target-number>.sdf
TARGET_PRO_<target-number>.mol2
TARGET_<target-number>.prm
TARGET_<target-number>.as
htvs.ptc
```

## Optional files
### rxdock.config
When this file is present, the runner skips the startup dialogue and runs automatically with the options preset in the config file.
Structure:
```
threads=<int>
save_output=<bool>
nice=<int>
auto_update=<bool>
```
Threads should be an integer lower or equal to the number of logical cores in your system. This defines how many parallel instances of RxDock will run, by default RxDock uses all processor threads.

Save_output should be TRUE or FALSE. This tells the script if you want to keep the output files or delete them after uploading them to the server, default is FALSE.

Nice should be an integer between -20 and 19. This tells your OS with what priority RxDock should be run, 19 means lowest priority, -20 means highest priority, default is 0. Negative nice values can only be set by root!

Auto_update should be TRUE or FALSE. This tells the script if you want the software to automatically update itself when a new version is found. Default is FALSE, but we recommend setting to TRUE.

### no.update
This prevents the script from checking for updates. This should only be present during developer testing. File can be empty. Create it with touch.
```
touch no.update
```

## Changelog
### v0.6
- Changed autoupdate from default to optional
- Added ability to set nice value
- Changed docking software to RxDock
- Added config to skip questions
### v0.5   
- Added multiple target support
- Added periodic update check
- Migrated server
- Fixed update script call
- Added update blocker
- Added ability to pre-set save output and thread variables, thus making updates unnoticable
### v0.4.1
- Added update wizard
- cURL is now silent
- Added check to see if there are any more structures to calculate   
### v0.4
- Migrated from FTP server to cURL dedicated API  
### v0.3
- Added cleanup
- Added user interaction
- Added auto continue
- Added thread checking and selection
- Added file checking before updating counter
### v0.2
- Changed ftp from active to passive
