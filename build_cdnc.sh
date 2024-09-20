#!/bin/bash

########
# this is for downloading and compiling all the necessary files before running the simulation
########

set -e # to stop execution if there is an error

BOLD_GREEN="\t\e[1;32m==> "
BOLD_YELLOW="\e[1;33m"
TEXT_RST=" \e[1;32m <==\e[0m"

main_dir="$(pwd)"  # run script outside of NVM_SIMULATION/


echo -e "$BOLD_GREEN pwd= $BOLD_YELLOW $main_dir  $TEXT_RST"

echo -e "$BOLD_GREEN clonning $BOLD_YELLOW NVM_Simulation.git cdnc branch  $TEXT_RST"
git clone -b cdnc --single-branch https://github.com/OMA-NVM/NVM_Simulation.git


cd NVM_Simulation/

echo -e "$BOLD_GREEN pwd= $BOLD_YELLOW $main_dir/NVM_Simulation/  $TEXT_RST"
echo -e "$BOLD_GREEN running $BOLD_YELLOW git submodule init...  $TEXT_RST"

git submodule init && git submodule update --remote --init

echo -e "$BOLD_GREEN running $BOLD_YELLOW ./cdnc/skip-Steps1and2.sh $TEXT_RST"

./cdnc/skip-Steps1and2.sh 

echo -e "$BOLD_GREEN building $BOLD_YELLOW gem5.opt/X86 $TEXT_RST"

./cdnc/step3-testingWithGem5.sh -c

cd "$main_dir"
echo -e "$BOLD_GREEN pwd= $BOLD_YELLOW $main_dir  $TEXT_RST"
echo -e "$BOLD_GREEN Done :) $TEXT_RST"
