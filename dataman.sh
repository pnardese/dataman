#!/bin/bash
#
# dataman.sh
#
# 2016 Enzo Nardese
#
# Two configurations: disk name at line 12, and media file suffix at line 65 ans 67 to normalize reports
# 

# configure disk to copy media to
DISK="/Volumes/Nick/prova"

# create directory for each day of shooting, with no argument or -t argument date is today, with -y date is yesterday
DATE=`date +%Y-%m-%d`

# define card name as directory name
NOMESORG=`echo "$1"| grep -o '[a-zA-Z0-9_]*$'`

# $SWITCH = 1 no arguments passed, $SWITCH = 2 argument, either -y or -t
SWITCH=1
while getopts ":yt" opt; do
  case $opt in
    y)
      DATE=`date -v -1d +%Y-%m-%d`
      NOMESORG=`echo "$2"| grep -o '[a-zA-Z0-9_]*$'`
      SWITCH=2
      ;;
    t)
	    DATE=`date +%Y-%m-%d`
      NOMESORG=`echo "$2"| grep -o '[a-zA-Z0-9_]*$'`
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

#if [ $SWITCH -eq 1 ]; then
#  rsync -av --progress --append --log-file=$DIRECTORYDEST/$NOMESORG/logs.txt --log-file-format="%f %b %l %C" $1 $DIRECTORYDEST
#elif [ $SWITCH -eq 2 ]; then
#  rsync -av --progress --append --log-file=$DIRECTORYDEST/$NOMESORG/logs.txt --log-file-format="%f %b %l %C" $2 $DIRECTORYDEST
#else
#  echo "error"
#  exit 1
#fi

chmod 777 $DIRECTORYDEST/$NOMESORG/

# must be configured with media file suffix, e.g. grep -E 'mov|mxf' uses OR to choose between mov and mxf
# awk -v var=... simplify variables for awk

cat $DIRECTORYDEST/$NOMESORG/logs.txt | grep -E 'mp3' | awk -v var="$NOMESORG" '{ printf var " " $1" "$2" "$4" "$6" "$7"\n"}' > $DIRECTORYDEST/$NOMESORG/MD5checksums.txt

cat $DIRECTORYDEST/$NOMESORG/logs.txt | grep mp3 | awk '{print $1" "$2" "$4" "$6" "$7}' >> $DISK/report.txt

# send iphone imessage...
# osascript -e 'tell application "Messages" to send "copia1 finita!" to buddy "miotel"'
