#!/bin/sh
Usage() {
    cat <<EOF
    $(basename $0):
    user:passwd@host:port command
EOF
    exit 0
}
while getopts ':s:c:' OPT; do
    case $OPT in
        s)
            host=${OPTARG}
            user_passwd=${host%@*}
            addr_port=${host#*@}
            user=${user_passwd%:*}
            passwd=${user_passwd#*:}
            addr=${addr_port%:*}
            port=${addr_port#*:}
            #user=${${host%@*}%:*}
            #passwd=${${host%@*}#*:}
            #addr=${${host#*@}%:*}
            #port=${${host#*@}#*:}
            ;;
        c)
            cmd=${OPTARG}
            ;;
        ?)
            usage;;
    esac
done
user=${user:-anonymous}
passwd=${passwd:-anonymous}
echo $user $passwd $addr $port 

#ascii
#ls -la
#cd $r_dir
#lcd $l_dir
ftp -n -v $addr $port <<EOT
user $user $passwd
prompt
$cmd
bye
EOT
