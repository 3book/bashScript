#!/bin/bash
sh_dir='./common/'
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
    glog 'star----------------------------------------'
    cd $DIR
    IFS=${IFS_OLD}
    a=${FILE}
    if [ $(echo $a|grep ' '|wc -l) -ne 0 ];then
        b=${FILE// /_}
        #file=${FILE// /\\ }
        mv "$a" $b
        glog 'mdify file name'
        a=$b
    fi
    file=$a
    l_file="$DIR$file"
    glog "$l_file find"
    if [ "${l_file##*.}" = "pdf" ]; then 
        gtemp
        glog $(pwd)
        o_file=${l_file%*.pdf}.cbz
        glog pdftoppm -jpeg -r 300 "${l_file}" img
        pdftoppm -jpeg -r 300 "${l_file}" img
        if [ $(ls|grep img-|wc -l) -eq 0 ];then
            glog 'pdftoppm error' 
            glog 'end----------------------------------------'
            continue
        fi
        glog 'pdftoppm finish' 
        zip ${o_file} img*jpg
        glog ${o_file} generate
        tmp_dir=$(pwd)
        grm ${tmp_dir}
        glog 'end----------------------------------------'
        grm $l_file
    elif [ "${l_file##*.}" = "cbz" ]; then 
        glog 'star----------------------------------------'
        r_dir='/download/book/'
        r_file="$r_dir$file"
        ${sh_dir}ftp_file_transfer.sh -s $tv_ftp \
            -c "put ${l_file} ${r_file}"
        glog 'ftp_file_transfer .cbz file finish' 
        glog 'end----------------------------------------'
        grm $l_file
    elif [ "${l_file##*.}" = "mp3" ]; then 
        r_dir='/download/music/else'
        r_file="$r_dir$file"
        ${sh_dir}ftp_file_transfer.sh -s $tv_ftp \
            -c "put ${l_file} ${r_file}"
        glog 'ftp_file_transfer .cbz file finish' 
    fi
    #grm $l_file
    IFS=';'
done
IFS=${IFS_OLD}
glog "$0 end"
