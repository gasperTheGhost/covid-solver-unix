# covid-solver-unix
This is the mac/linux universal version of the script used for automated docking in the [Open Science Project COVID-19](https://koronavirus.ctk.uni-lj.si/skupnostna-znanost)
It is used in conjunction with [pevecyan](https://github.com/pevecyan)'s [covid-solver-queue](https://github.com/pevecyan/covid-solver-queue)

## Compiling
To use the script as intended lib/run_flexx.sh has to be compiled with
```
cd /path/to/script
shc -r -f run_flexx.sh -o run_flexx
```
## Prerequisites
This package depends on
* shc [Shell Script Compiler](https://neurobin.org/projects/softwares/unix/shc/) (for compiling)
* curl
* [FlexX CLI](https://www.biosolveit.de/FlexX/)

## File structure of working installation
### macOS
```
run_flexx.command
lib/update.sh
lib/run_flexx
lib/31may2020_biosolveit.lic
lib/FlexX.app
```
### Linux
```
run_flexx.sh # Same as run_flexx.command
lib/update.sh
lib/run_flexx
lib/31may2020_biosolveit.lic
lib/flexx-4.1-Linux-x64
lib/lib/libQt5Concurrent.so.5
lib/lib/libQt5Core.so.5
lib/lib/libQt5Xml.so.5
lib/lib/libnlopt.so.0
lib/lib/libquazip.so.1
lib/qt.conf
lib/readme/Installation_SRC.txt
lib/readme/LICENSE.txt
lib/readme/Qt_3rdPartyLibs.html
lib/readme/Qt_OtherLicenses.txt
lib/readme/README.txt
lib/readme/gpl3_lgpl3.txt
```
## Releases
Compiled archives can be found at the [project's site](https://koronavirus.ctk.uni-lj.si/skupnostna-znanost), prepackaged with FlexX and will not be uploaded to GitHub for legal reasons.
