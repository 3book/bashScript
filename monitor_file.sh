#!/bin/bash
sh_dir='/mnt/d/xyp/develop/shell/'
. ${sh_dir}config.sh
. ${sh_dir}common.sh
scriptpath=$(cd $(dirname $0); pwd)
scriptname=$(basename $0)
glog "$scriptpath$scriptname start"

IFS_OLD=${IFS}
IFS=';'
inotifywait -mr --timefmt '%Y%m%dT%H%M' \
--format '%T;%w;%f' -e create ${tv_pc_dir} \
|while read DATE DIR FILE
do
    file=${FILE// /\\ }
    l_file="$DIR$file"
    glog "$l_file find"
    if [ "${l_file##*.}" = "pdf" ]; then 
        tmp_dir=gtemp
        o_file=${l_file%*.pdf}.cbz
        pdftoppm -jpeg -r 300 $l_file img
        glog 'pdftoppm finish' 
        zip $o_file img*jpg
        glog $o_file generate
        grm $tmp_dir
    elif [ "${l_file##*.}" = "cbz" ]; then 
        r_dir='/download/book/'
        r_file="$r_dir$file"
        ${sh_dir}ftp_file_transfer.sh -s $tv_ftp \
            -c "put ${l_file} ${r_file}"
        glog 'ftp_file_transfer .cbz file finish' 
    fi
    grm $l_file
done
IFS=${IFS_OLD}
glog "$0 end"
