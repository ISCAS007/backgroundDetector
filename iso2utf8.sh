#!/bin/bash

file *.m | grep ISO >> /tmp/iso.txt
cat /tmp/iso.txt | awk -F: '{print $1}' >> /tmp/iso.awk

input=/tmp/iso.awk
cmd=iconv

# from=ISO-8859-1
# from=GB2312
from=GBK
dir=/tmp/utf8
mkdir -p $dir

while read line
do
    echo "$cmd -f $from -t UTF-8 $line -o $dir/$line"
    $cmd -f $from -t UTF-8 $line -o $dir/$line
done < "$input"
