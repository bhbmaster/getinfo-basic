#!/bin/bash
# filename: getinfo.sh
# info: run without args, to get info about cpu, nic and drives.
#       outputs file with date and hostname to dirs cpu, nic and drives
#       or run with -s to also write to screen and save to dirs
# pre-reqs: lshw & pciutils

# set -x # uncomment for debug
exec 2>/dev/null # send all stderr to garbarge, so comment this line for debug

# sidenote will pipe most vars to xargs to maintain consistency as it removes whitespace when served without args)

# get script dir
SDIR=$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )
ARG1="$1" # to see if option -s was used
ARG_FOR_SCREEN="-s"

# helper arg checker function
function screen_arg_present () {
    [[ "$ARG1" == "$ARG_FOR_SCREEN" ]] && ( exit 0 ) || ( exit 1 );
}

# helper writer functio
function writer () {
  # writes to dir and if option -s is given for verbose also writes to screen
  # $1 is path name to save to
  FILEPATH="$1"
  CONTENT=$(cat -) # catch content from stdin
  # echo "CONTENT: $CONTENT" # for debug
  # if [[ "$ARG1" == "$ARG_FOR_SCREEN" ]]; then
  if screen_arg_present; then
      # save to file and screen
      echo "$CONTENT" | tee "$FILEPATH"
  else 
      # save to file only
      echo "$CONTENT" > "$FILEPATH"
  fi
}

# get suffix for dirnames comprised of date and hostname
FILENAME="$(hostname)-$(date +%y%m%d-%H%M%S).out"

# output dirs
CPU_DIR="$SDIR/cpu"
NIC_DIR="$SDIR/nic"
DRIVES_DIR="$SDIR/drives"

# filenames
CPU_FN="$CPU_DIR/$FILENAME"
NIC_FN="$NIC_DIR/$FILENAME"
DRIVES_FN="$DRIVES_DIR/$FILENAME"

# create dirs
mkdir "$CPU_DIR" "$NIC_DIR" "$DRIVES_DIR" 2> /dev/null 

# gather cpu stats
MODELS=$(cat /proc/cpuinfo | grep "model name")                 # model of all cores
CPU_MODEL=$(echo "$MODELS" | sort -u | awk -F":" '{print $2}' | xargs)  # model of all cores should be same, so this will end up being 1 line
# if nproc missing get this by count. However, I checked nproc is part of coreutils, so its always present.
type nproc > /dev/null 2>&1 && CPU_CORES=$(nproc) || CPU_CORES=$(echo "$MODELS" | grep -c .)
{ screen_arg_present && echo "CPU:"
echo "* cpu model name: $CPU_MODEL";
echo "* cpu core count: $CPU_CORES"; } | writer "$CPU_FN"

# gather nic stats
HWOUT=$(lshw -class network 2> /dev/null) # stderr to /dev/null to supress progress of its info gathering
PCIOUT=$(lspci | grep -Ei "ethernet|wireless|wi-fi|wireless" | grep .)
# echo "HWOUT: $HWOUT"
# echo "PCIOUT: $PCIOUT"

# if ls pci missing model numbers of eth ports, lets just get logical name and link state, otherwise get full config
{
  screen_arg_present && echo "NETWORK:";
  if [[ -z "$PCIOUT" ]]; then
    # no PCIOUT so just logical name like eth0 and link state
    echo "$HWOUT" | grep "logical name" | awk '{print $NF}' | while read i; do
      LOGICAL_NAME="$i"
      LINK_STATE=$(ethtool $LOGICAL_NAME | grep -i "Link detected" | awk '{print $NF}' | xargs)
      [[ "$LINK_STATE" == "yes" ]] && LINK_UD="up" || LINK_UD="down"
      echo "* $LOGICAL_NAME - link state: $LINK_UD - model name: N/A"
    done
  else
    # we have some possibly useful PCIOUT info so lets try to extract hw info from it
    echo "$PCIOUT" | while read i; do
      ID=$(echo "$i" | awk '{print $1}' | xargs)
      MODEL=$(echo "$i" | awk -F':' '{print $NF}' | xargs)
      # LOGICALNAME=$(echo "$HWOUT" | grep -A1000 "$ID" | grep -B1000 -- "\*-network" | grep "logical name" | awk '{print $NF}')
      LOGICAL_NAME=$(echo "$HWOUT" | grep -A4 "$ID" | grep "logical name" | awk '{print $NF}' | xargs)
      LINK_STATE=$(ethtool $LOGICAL_NAME | grep -i "Link detected" | awk '{print $NF}' | xargs)
      [[ "$LINK_STATE" == "yes" ]] && LINK_UD="up" || LINK_UD="down"
      echo "* $LOGICAL_NAME - link state: $LINK_UD - model name: $MODEL"
    done;
  fi
} | writer "$NIC_FN"

# get drive stats
{ screen_arg_present && echo "DRIVES:";
lsblk | grep disk | awk '{print $1}' | while read i; do
   MODEL=$(cat /sys/block/$i/device/model 2> /dev/null)
   echo "* $i - model name: $MODEL"
done; } | writer "$DRIVES_FN"

exit 0
