#!/bin/bash
#
# verify.sh
#
# 2016 Enzo Nardese
#
# Use: ./verify.sh volume_to_check
# checks existing disk_seal.txt, written by either dataman.sh or verify.sh -g
#
# option: verify.sh -g volume_to_seal 
# generates disk_seal.txt in volume_to_seal
#
# name of directory must contain only alphanumeric characters and not contain spaces, file's names alphanumeric, ".", "_", "-", "'"
#
# CONFIGURATION: media type
MEDIA="flac|mp3"

# ===============================================================================

REMOVE=0
while getopts ":g" opt; do
  case $opt in
    g)
      find $2 -print0 | xargs -0 stat -f "%N" | grep -E "$MEDIA" | grep -o "[a-zA-Z0-9._'-]*$" > /tmp/file_list1.txt
      find $2 -print0 | xargs -0 stat -f "%N %z" | grep -E "$MEDIA" | grep -o '[a-zA-Z0-9._]*$' > /tmp/file_size1.txt
      find $2 -type f -exec md5 {} + | grep -E "$MEDIA" | grep -o '[a-z0-9]*$' > /tmp/disk_check_sums1.txt

      paste -d ' ' /tmp/file_list1.txt /tmp/file_size1.txt /tmp/disk_check_sums1.txt > $2/disk_seal.txt
      exit 1
      ;;
	\?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# build list of files on disk $1 and generate verify.txt file in directory $1

find $1 -print0 | xargs -0 stat -f "%N" | grep -E "$MEDIA" | grep -o "[a-zA-Z0-9._'-]*$" > /tmp/file_list1.txt
find $1 -print0 | xargs -0 stat -f "%N %z" | grep -E "$MEDIA" | grep -o "[a-zA-Z0-9._'-]*$" > /tmp/file_size1.txt
find $1 -type f -exec md5 {} + | grep -E "$MEDIA" | grep -o '[a-z0-9]*$' > /tmp/disk_check_sums1.txt

paste -d ' ' /tmp/file_list1.txt /tmp/file_size1.txt /tmp/disk_check_sums1.txt > $1/verify.txt

# normalize report file in $1, and generate file verify_disk,txt in $1

cat $1/disk_seal.txt | awk '{print $1}' | grep -o "[a-zA-Z0-9._'-]*$" > /tmp/file_list2.txt
cat $1/disk_seal.txt | awk '{print $2}' > /tmp/file_size2.txt
cat $1/disk_seal.txt | awk '{print $3}' > /tmp/file_checksums2.txt

paste -d ' ' /tmp/file_list2.txt /tmp/file_size2.txt /tmp/file_checksums2.txt > $1/verify_disk.txt

# check differencies between verify.txt and verify_disk.txt, exit code = 0 no differencies -> check ok!
sort $1/verify.txt > /tmp/verify_sorted.txt
sort $1/verify_disk.txt > /tmp/verify_disk_sorted.txt
diff /tmp/verify_disk_sorted.txt /tmp/verify_sorted.txt
rv=$?  
if [[ $rv == 1 ]]  
then    
    echo "failed"
    else
    echo "checked seal...OK!"    
fi

# remove verify.txt and verify_disk.txt
rm $1/verify.txt $1/verify_disk.txt


