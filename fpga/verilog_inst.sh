#!/bin/bash
scriptpath=$(cd $(dirname $0); pwd)
scriptname=$(basename $0)
i_file=$1
#i_file_path=$(cd "$(dirname "${i_file}")"; pwd)
#i_file_name=$(basename "$i_file")
#file ext name test
if [[ "$i_file" =~ .v ]];then
#	o_file=${i_file_path}"/"${i_file_name%.v}"_inst.v"
	:
else
	echo "Usage: sh $scriptname *.v"
	exit 1
fi

tmp1=$(mktemp)
tmp2=$(mktemp)
cat "$i_file" >$tmp1
#echo "" >"$o_file"
swap_name() {
#	sleep 1
	t=$(mktemp) 
	mv $1 $t
	mv $2 $1
	mv $t $2
}
#find module head
#str_s="^module"
#str_e="^);" | input/output
cat $tmp1|awk '/^module\>|^\s*input\>|^\s*output\>|^\s*parameter\>/' \
	> $tmp2 ;swap_name $tmp1 $tmp2
#cat $tmp1|awk '/^module/ {p=1};p;/);/{p=0}' \
#	> $tmp2 ;swap_name $tmp1 $tmp2
#delete comments
 #kw_sl="//"
cat $tmp1|sed 's/\/\/.*//g' \
	> $tmp2 ;swap_name $tmp1 $tmp2
 #kw_ml_s="/*"
 #kw_ml_e="\*"
cat $tmp1|sed 's/\/\*.*\*\///g' \
	> $tmp2 ;swap_name $tmp1 $tmp2
cat $tmp1|awk '/\/\*/ {p=1};!p;/\*\//{p=0}' \
	> $tmp2 ;swap_name $tmp1 $tmp2
#delete [n:m]
cat $tmp1|sed 's/\[.*\]//' \
	> $tmp2 ;swap_name $tmp1 $tmp2
#delete "wire/reg"
cat $tmp1|sed 's/\>[wire|reg]\>//' \
	> $tmp2 ;swap_name $tmp1 $tmp2
#delete ;|,
#cat $tmp1|sed 's/[,|;]//' \
cat $tmp1|sed 's/\W/ /g' \
	> $tmp2 ;swap_name $tmp1 $tmp2

#get module_name
module_name=$(cat $tmp1|head -1|sed 's/^module\s\+\(\w\+\).*/\1/')
#module_name=$(cat $tmp1|awk '/^module/ {print $2}')
parameter_number=$(cat $tmp1|grep parameter|wc -l)
parameter_exist=$(cat $tmp1|grep parameter|wc -l)
#io length
longest_io=$(cat $tmp1 \
	|awk '/parameter/ {print $2}; \
	      /input/ {print $2}; \
	      /output/ {print $2};' \
	|wc -L )

#out
echo '' >$tmp2
if [[ $parameter_exist -eq 0 ]];then
	echo "${module_name} ${module_name}_inst(" >>"$tmp2"
else
	echo "${module_name} #(" >>"$tmp2"
	cat $tmp1|awk -v len=$longest_io ' \
		/parameter/ {printf ".%-"'len'"s\t(%-"'len'"s\t),\n",$2,$2}' >>"$tmp2"
	sed -i '$s/,$//' "$tmp2"
	echo ")${module_name}_inst(" >> "$tmp2"
fi
cat $tmp1|awk -v len=$longest_io ' \
	/input|output/ {printf ".%-"'len'"s\t(%-"'len'"s\t),\n",$2,$2}' >>"$tmp2"
	sed -i '$s/,$//' "$tmp2"
	sed -i '$a);' "$tmp2"
	
cat "$tmp2"
#echo "outfile:$o_file"
exit 0
