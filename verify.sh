#!/bin/bash
#
# verify.sh
#
# 2016 Enzo Nardese
#
# CONFIGURATION: media type
MEDIA="flac|mp3"

# ===============================================================================
# build list of files on disk $1 and generate verify.txt file in directory $1

find $1 -print0 | xargs -0 stat -f "%N" | grep -E "$MEDIA" | grep -o "[a-zA-Z0-9._'-]*$" > /tmp/file_list1.txt
find $1 -print0 | xargs -0 stat -f "%N %z" | grep -E "$MEDIA" | grep -o '[a-zA-Z0-9._]*$' > /tmp/file_size1.txt
find $1 -type f -exec md5 {} + | grep -E "$MEDIA" | grep -o '[a-z0-9]*$' > /tmp/disk_check_sums1.txt

paste -d ' ' /tmp/file_list1.txt /tmp/file_size1.txt /tmp/disk_check_sums1.txt > $1/verify.txt

# normalize report file in $1, and generate file verify_disk,txt in $1

cat $1/disk_seal.txt | awk '{print $1}' | grep -o "[a-zA-Z0-9._'-]*$" > /tmp/file_list2.txt
cat $1/disk_seal.txt | awk '{print $2}' > /tmp/file_size2.txt
cat $1/disk_seal.txt | awk '{print $3}' > /tmp/file_checksums2.txt

paste -d ' ' /tmp/file_list2.txt /tmp/file_size2.txt /tmp/file_checksums2.txt > $1/verify_disk.txt

# check differencies between verify.txt and verify_disk.txt, exit code = 0 no differencies -> check ok!
diff $1/verify_disk.txt $1/verify.txt
rv=$?  
if [[ $rv == 1 ]]  
then    
    echo "failed"
    else
    echo "checked seal...OK!"    
fi

# remove verify.txt and verify_disk.txt

rm $1/verify.txt $1/verify_disk.txt

