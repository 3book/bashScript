#!/bin/bash
sh_dir='./shell/'
. ${sh_dir}config.sh
. ${sh_dir}common.sh
scriptpath=$(cd $(dirname $0); pwd)
scriptname=$(basename $0)
glog "$scriptpath$scriptname start"

echo $1
echo $2
#exit 1
filename_all=$1
replace_patten=$2
for filename_old in $filename_all;do
    filename_new=$(echo $filename_old|sed "s$replace_patten")
    if [ "$filename_old" != "$filename_new" ];then
        mv "$filename_old" "$filename_new"
    fi
done
