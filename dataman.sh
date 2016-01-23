#!/bin/bash
#
# dataman.sh
#
# 2016 Enzo Nardese
#
# Two configurations: disk name at line 13, and media file suffix at line 53 to normalize reports
#
# define card name as directory name
NOMESORG=`echo "$1"| grep -o '[a-zA-Z0-9_]*$'`

# configure disk to copy media to
DISK="/Volumes/Fabbrica"

# create directory for each day of shooting, with no argument or -t argument date is today, with -y date is yesterday
DATE=`date +%Y-%m-%d`
while getopts ":yt" opt; do
  case $opt in
    y)
      DATE=`date -v -1d +%Y-%m-%d`
      ;;
    t)
	  DATE=`date +%Y-%m-%d`
	  ;;
	\?)
      echo "Invalid option: -$OPTARG" >&2
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

echo "copy $1 in $DIRECTORYDEST"

# copy using rsync, use --append to continue interrupted transfers, requires rsync 3.1.1
rsync -av --progress --append --log-file=$DIRECTORYDEST/$NOMESORG/logs.txt --log-file-format="%f %b %l %C" $1 $DIRECTORYDEST

chmod 777 $DIRECTORYDEST/$NOMESORG/

# must be configured with media file suffix, e.g. grep -E 'mov|mxf' uses OR to choose between mov and mxf
# awk -v var=... simplify variables for awk

cat $DIRECTORYDEST/$NOMESORG/logs.txt | grep -E 'mov' | awk -v var="$NOMESORG" '{ printf var " " $1" "$2" "$4" "$6" "$7"\n"}' > $DIRECTORYDEST/$NOMESORG/MD5checksums.txt

cat $DIRECTORYDEST/$NOMESORG/logs.txt | grep mov | awk '{print $1" "$2" "$4" "$6" "$7}' >> $DISK/report.txt

# send iphone imessage...
# osascript -e 'tell application "Messages" to send "copia1 finita!" to buddy "miotel"'
