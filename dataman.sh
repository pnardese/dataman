#!/bin/bash
#
# dataman.sh
#
# 2016 Enzo Nardese
# Use: ./dataman.sh volu_to_copy
# copy media to $DISK, the script produces two files: report.txt and disk_seal.txt, this last one is used to provide a seal to the disk
# contains file name, size and MD5 checksum. The disk is checked with verify.sh, verifies number of files, names, sizes and MD5 checksums
# name of directory must contain only alphanumeric characters and not contain spaces, file's names alphanumeric, ".", "_", "-", "'"
#
#
#
# CONFIGURATION:
# configure disk to copy media to and media type, use | for different media types

DISK="/Volumes/Nick/prova"
MEDIA="flac|mp3"

# ===============================================================================

# create directory for each day of shooting, with no argument or -t argument date is today, with -y date is yesterday
DATE=`date +%Y-%m-%d`

# define card name as directory name
NOMESORG=`echo "$1"| grep -o '[a-zA-Z0-9_.]*$'`

# $SWITCH = 1 no arguments passed, $SWITCH = 2 argument, either -y or -t
SWITCH=1
while getopts ":yt" opt; do
  case $opt in
    y)
      DATE=`date -v -1d +%Y-%m-%d`
      NOMESORG=`echo "$2"| grep -o '[a-zA-Z0-9_.]*$'`
      SWITCH=2
      ;;
    t)
	    DATE=`date +%Y-%m-%d`
      NOMESORG=`echo "$2"| grep -o '[a-zA-Z0-9_.]*$'`
      SWITCH=2
	  ;;
	\?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

DIRECTORYDEST="$DISK/$DATE"

# create date directory only if does not exist
if [ ! -d "$DIRECTORYDEST" ]; then
  mkdir $DIRECTORYDEST
fi

# create directory in advance, in order to write MD5checksums.txt file
if [ ! -d "$DIRECTORYDEST/$NOMESORG" ]; then
	mkdir $DIRECTORYDEST/$NOMESORG
fi

# copy using rsync, use --append to continue interrupted transfers, requires rsync 3.1.1
rsync -av --progress --append --log-file=$DIRECTORYDEST/$NOMESORG/logs.txt --log-file-format="%f %b %l %C" ${!SWITCH} $DIRECTORYDEST

chmod 777 $DIRECTORYDEST/$NOMESORG/

# write report on disk home directory
cat $DIRECTORYDEST/$NOMESORG/logs.txt | grep -E "$MEDIA" | awk '{print $1" "$2" /"$4" "$6" "$7}' >> $DISK/report.txt

# write disk seal on disk, contains file name with complete path, size and MD5 checksum
cat $DIRECTORYDEST/$NOMESORG/logs.txt | grep -E "$MEDIA" | awk '{print "/"$4" "$6" "$7}' >> $DISK/disk_seal.txt

# send iphone imessage...
# osascript -e 'tell application "Messages" to send "copia1 finita!" to buddy "miotel"'
