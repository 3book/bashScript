#!/bin/sh
#sh_dir='/mnt/d/xyp/develop/shell/'
gtemp() {
    temp_dir=$(mktemp -d)
    cd $temp_dir
    #return $temp_dir
}
glog() {
    time=$(date --rfc-3339=seconds)
    echo $time "$@" >> /tmp/glog
}
grm() {
    if [ -d "$1" ];then
        rm -rf $1
    elif [ -f "$1" ];then
        rm $1
    fi
}
