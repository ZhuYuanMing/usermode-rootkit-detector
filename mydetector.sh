unalias login > /dev/null 2>&1
unalias ls > /dev/null 2>&1
unalias netstat > /dev/null 2>&1
unalias ss > /dev/null 2>&1
unalias ps > /dev/null 2>&1
unalias dirname > /dev/null 2>&1

TROJAN="amd biff date du dirname echo egrep env find fingerd gpm grep su ifconfig \
init killall login ls lsof mail netstat named passwd ps slogin sendmail \
sshd syslogd tar telnetd timed traceroute w write"

GENERIC_ROOTKIT_LABEL="^/bin/.*sh$|bash|elite$|vejeta|\.ark|iroffer"

cmdlist="
awk
cut
echo
egrep
find
head
id
ls
ps
sed
strings
uname
"

INFECTED=0
NOT_INFECTED=1
NOT_FOUND=2



#two self-defined function 
loc () {
    thing=$1
    shift
    dflt=$1
    shift
    for dir in $*; do
            case "$thing" in
            .)
            if test -d $dir/$thing; then
                    echo $dir
                    exit 0
            fi
            ;;
            *)
            for thisthing in $dir/$thing; do
                    :
            done
            if test -f $thisthing; then
                    echo $thisthing
                    exit 0
            fi
            ;;
            esac
    done
    echo ${dflt}
    exit 1
}


getCMD() {
   RUNNING=`${ps} ${ps_cmd} | ${egrep} "${L_REGEXP}${1}${R_REGEXP}" | \
            ${egrep} -v grep | ${egrep} -v chkrootkit |  \
            ${awk} '{ print $5 }'`

   for i in ${RUNNING} usr/sbin/${1} `loc ${1} ${1} $pth`
   do
      CMD="${i}"
      if [ -r "${i}" ]
        then
        return 0
      fi
   done
   return 1
}



#chkfuctions for sys-functions
chk_amd () {
    STATUS=${NOT_INFECTED}
    AMD_INFECTED_LABEL="blah"
    CMD=`loc amd amd $pth`
    if [ ! -x "${CMD}" ]; then
         return ${NOT_FOUND}
    fi
    if ${strings} -a ${CMD} | ${egrep} "${AMD_INFECTED_LABEL}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_biff () {
    STATUS=${NOT_INFECTED}
    CMD=`loc biff biff $pth`
    if [ "${?}" -ne 0 ]; then
        return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${GENERIC_ROOTKIT_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    if ${ls} -l ${CMD} | ${egrep} "^...s" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_date () {
    STATUS=${NOT_INFECTED}
    CMD=`loc date date $pth`

    if ${ls} -l ${CMD} | ${egrep} "^...s" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_du () {
    STATUS=${NOT_INFECTED}
    DU_INFECTED_LABEL="/dev/ttyof|/dev/pty[pqrsx]|w0rm|^/prof|/dev/tux|file\.h"
    CMD=`loc du du $pth`

    if ${strings} -a ${CMD} | ${egrep} "${DU_INFECTED_LABEL}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_dirname () {
    STATUS=${NOT_INFECTED}
    CMD=`loc dirname dirname $pth`

    if ${strings} -a ${CMD} | ${egrep} "${GENERIC_ROOTKIT_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    if ${ls} -l ${CMD} | ${egrep} "^...s" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_echo () {
    STATUS=${NOT_INFECTED}
    CMD=`loc echo echo $pth`

    if ${strings} -a ${CMD} | ${egrep} "${GENERIC_ROOTKIT_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    if ${ls} -l ${CMD} | ${egrep} "^...s" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_env () {
    STATUS=${NOT_INFECTED}
    CMD=`loc env env $pth`

    if ${strings} -a ${CMD} | ${egrep} "${GENERIC_ROOTKIT_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    if ${ls} -l ${CMD} | ${egrep} "^...s" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi

    return ${STATUS}
}


chk_egrep () {
    STATUS=${NOT_INFECTED}
    EGREP_INFECTED_LABEL="blah"
    CMD=`loc egrep egrep $pth`

    if ${strings} -a ${CMD} | ${egrep} "${EGREP_INFECTED_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_find () {
    STATUS=${NOT_INFECTED}
    FIND_INFECTED_LABEL="/dev/ttyof|/dev/pty[pqrs]|^/prof|/home/virus|/security|file\.h"
    CMD=`loc find find $pth`

    if [ "${?}" -ne 0 ]; then
        return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${FIND_INFECTED_LABEL}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_fingerd () {
    STATUS=${NOT_INFECTED}
    FINGER_INFECTED_LABEL="cterm100|${GENERIC_ROOTKIT_LABEL}"
    CMD=`loc fingerd fingerd $pth`

    if [ ${?} -ne 0 ]; then
        CMD=`loc in.fingerd in.fingerd $pth`
        if [ ${?} -ne 0 ]; then
           return ${NOT_FOUND}
        fi
    fi

    if ${strings} -a ${CMD} | ${egrep} "${FINGER_INFECTED_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_grep () {
    STATUS=${NOT_INFECTED}
    GREP_INFECTED_LABEL="givemer"
    CMD=`loc grep grep $pth`

    if ${strings} -a ${CMD} | ${egrep} "${GREP_INFECTED_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    if ${ls} -l ${CMD} | ${egrep} "^...s" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_gpm () {
    STATUS=${NOT_INFECTED}
    GPM_INFECTED_LABEL="mingetty"
    CMD=`loc gpm gpm $pth`
    if [ ! -r ${CMD} ]
    then
       return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${GPM_INFECTED_LABEL}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_su () {
    STATUS=${NOT_INFECTED}
    SU_INFECTED_LABEL="satori|vejeta|conf\.inv"
    CMD=`loc su su $pth`

    if ${strings} -a ${CMD} | ${egrep} "${SU_INFECTED_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_ifconfig () {
    STATUS=${INFECTED}
    IFCONFIG_NOT_INFECTED_LABEL="PROMISC"
    IFCONFIG_INFECTED_LABEL="/dev/tux|/session.null"
    CMD=`loc ifconfig ifconfig $pth`
    if [ "${?}" -ne 0 ]; then
        return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${IFCONFIG_NOT_INFECTED_LABEL}" \
    >/dev/null 2>&1
    then
       STATUS=${NOT_INFECTED}
    fi
    if ${strings} -a ${CMD} | ${egrep} "${IFCONFIG_INFECTED_LABEL}" \
    >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_init () {
    STATUS=${NOT_INFECTED}
    INIT_INFECTED_LABEL="UPX"
    CMD=`loc init init $pth`
    if [ ${?} -ne 0 ]; then
       return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${INIT_INFECTED_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_killall () {
    STATUS=${NOT_INFECTED}
    TOP_INFECTED_LABEL="/dev/ttyop|/dev/pty[pqrs]|/dev/hda[0-7]|/dev/hdp|/dev/ptyxx|/dev/tux|proc\.h"
    CMD=`loc killall killall $pth`

    if [ "${?}" -ne 0 ]
       then
        return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${TOP_INFECTED_LABEL}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_login () {
    STATUS=${NOT_INFECTED}
    CMD=`loc login login $pth`

    GENERAL="^root$"
    TROJED_L_L="vejeta|^xlogin|^@\(#\)klogin\.c|lets_log|sukasuka|/usr/lib/.ark?|SucKIT|cocola"
    if ${strings} -a ${CMD} | ${egrep} -c "${GENERAL}" >/dev/null 2>&1
    then 
	STATUS=${INFECTED}
    fi
    if ${strings} -a ${CMD} | ${egrep} "${TROJED_L_L}" 2>&1 >/dev/null
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_ls () {
    STATUS=${NOT_INFECTED}
    LS_INFECTED_LABEL="/dev/ttyof|/dev/pty[pqrs]|/dev/hdl0|\.tmp/lsfile|/dev/hdcc|/dev/ptyxx|duarawkz|^/prof|/dev/tux|/security|file\.h"
    CMD=`loc ls ls $pth`

    if ${strings} -a ${CMD} | ${egrep} "${LS_INFECTED_LABEL}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_lsof () {
    STATUS=${NOT_INFECTED}
    LSOF_INFECTED_LABEL="^/prof"
    CMD=`loc lsof lsof $pth`

    if [ ! -x "${CMD}" ]; then
         return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${LSOF_INFECTED_LABEL}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_mail () {
    STATUS=${NOT_INFECTED}
    MAIL_INFECTED_LABEL="sh -i"
    CMD=`loc mail mail $pth`
    if [ "${?}" -ne 0 ]
       then
        return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${MAIL_INFECTED_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    if ${ls} -l ${CMD} | ${egrep} "^...s" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_netstat () {
    STATUS=${NOT_INFECTED}
    NETSTAT_I_L="/dev/hdl0/dev/xdta|/dev/ttyoa|/dev/pty[pqrsx]|/dev/cui|/dev/hdn0|/dev/cui221|/dev/dszy|/dev/ddth3|/dev/caca|^/prof|/dev/tux|grep|addr\.h|__bzero"
    CMD=`loc netstat netstat $pth`

    if ${strings} -a ${CMD} | ${egrep} "${NETSTAT_I_L}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_named () {
    STATUS=${NOT_INFECTED}
    NAMED_I_L="blah|bye"
    CMD=`loc named named $pth`

    if [ ! -r "${CMD}" ]; then
       CMD=`loc in.named in.named $pth`
       if [ ! -r "${CMD}" ]; then
          return ${NOT_FOUND}
       fi
    fi

    if ${strings} -a ${CMD} | ${egrep} "${NAMED_I_L}" \
    >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_passwd () {
    STATUS=${NOT_INFECTED}
    CMD=`loc passwd passwd $pth`

    if [ ! -x ${CMD} -a -x ${ROOTDIR}usr/bin/passwd ]; then
       CMD="/usr/bin/passwd"
    fi

    if ${strings} -a ${CMD} | ${egrep} "${GENERIC_ROOTKIT_LABEL}|/lib/security" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_ps () {
   STATUS=${NOT_INFECTED}
    PS_I_L="/dev/xmx|\.1proc|/dev/ttyop|/dev/pty[pqrsx]|/dev/cui|/dev/hda[0-7]|\
    /dev/hdp|/dev/cui220|/dev/dsx|w0rm|/dev/hdaa|duarawkz|/dev/tux|/security|^proc\.h|ARRRGH\.so"
   CMD=`loc ps ps $pth`

    if ${strings} -a ${CMD} | ${egrep} "${PS_I_L}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_slogin () {
    STATUS=${NOT_INFECTED}
    SLOGIN_INFECTED_LABEL="homo"
    CMD=`loc slogin slogin $pth`

    if [ ! -x "${CMD}" ]; then
         return ${NOT_FOUND}
    fi
    if ${strings} -a ${CMD} | ${egrep} "${SLOGIN_INFECTED_LABEL}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_sendmail () {
    STATUS=${NOT_INFECTED}
    SENDMAIL_INFECTED_LABEL="fuck"
    CMD=`loc sendmail sendmail $pth`
    if [ ! -r ${CMD} ]
    then
       return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${SENDMAIL_INFECTED_LABEL}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_sshd () {
    STATUS=${NOT_INFECTED}
    SSHD2_INFECTED_LABEL="check_global_passwd|panasonic|satori|vejeta|\.ark|/hash\.zk"
    getCMD 'sshd'

    if [ ${?} -ne 0 ]; then
       return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${SSHD2_INFECTED_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
        if ${ps} ${ps_cmd} | ${egrep} sshd >/dev/null 2>&1; then
           STATUS=${INFECTED_BUT_DISABLED}
        fi
    fi
    return ${STATUS}
}


chk_syslogd () {
    STATUS=${NOT_INFECTED}
SYSLOG_I_L="/usr/lib/pt07|/dev/pty[pqrs]|/dev/hd[als][0-7]|/dev/ddtz1|/dev/ptyxx|/dev/tux|syslogs\.h"
    CMD=`loc syslogd syslogd $pth`

    if [ ! -r ${CMD} ]
    then
       return ${NOT_TESTED}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${SYSLOG_I_L}" >/dev/null 2>&1
    then
       STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_tar () {
    STATUS=${NOT_INFECTED}

    CMD=`loc tar tar $pth`
    if [ ${?} -ne 0 ]; then
	return ${NOT_FOUND}
    fi


    if ${ls} -l ${CMD} | ${egrep} "^...s" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_telnetd () {
    STATUS=${NOT_INFECTED}
    TELNETD_INFECTED_LABEL='cterm100|vt350|VT100|ansi-term|/dev/hda[0-7]'
    CMD=`loc telnetd telnetd $pth`

    if [ ${?} -ne 0 ]; then
        CMD=`loc in.telnetd in.telnetd $pth`
        if [ ${?} -ne 0 ]; then
           return ${NOT_FOUND}
        fi
    fi

    if ${strings} -a ${CMD} | ${egrep} "${TELNETD_INFECTED_LABEL}" >/dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_timed () {
    STATUS=${NOT_INFECTED}
    CMD=`loc timed timed $pth`

    if [ ${?} -ne 0 ]; then
       CMD=`loc in.timed in.timed $pth`
       if [ ${?} -ne 0 ]; then
          return ${NOT_FOUND}
       fi
    fi

    if ${strings} -a ${CMD} | ${egrep} "${GENERIC_ROOTKIT_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_traceroute () {
    STATUS=${NOT_INFECTED}
    CMD=`loc traceroute traceroute $pth`

    if [ ! -r "${CMD}" ]
    then
       return ${NOT_FOUND}
    fi

    if ${strings} -a ${CMD} | ${egrep} "${GENERIC_ROOTKIT_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_write () {
    STATUS=${NOT_INFECTED}
    CMD=`loc write write $pth`
    WRITE_ROOTKIT_LABEL="bash|elite$|vejeta|\.ark"

    if ${strings} -a ${CMD} | ${egrep} "${WRITE_ROOTKIT_LABEL}" | grep -v locale > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    if ${ls} -l ${CMD} | ${egrep} "^...s" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


chk_w () {
    STATUS=${NOT_INFECTED}
    CMD=`loc w w $pth`
    W_INFECTED_LABEL="uname -a"

    if ${strings} -a ${CMD} | ${egrep} "${W_INFECTED_LABEL}" > /dev/null 2>&1
    then
        STATUS=${INFECTED}
    fi
    return ${STATUS}
}


# TEST1 check all the sys-functions
pth=`echo $PATH | sed -e "s/:/ /g"`
pth="$pth /sbin /usr/sbin /lib /usr/lib /usr/libexec"

for file in $cmdlist; do 
    xxx=`loc $file $file $pth`
    eval $file=$xxx
    case "$xxx" in 
    /* | ./* | ../*)
    
	    if [ ! -x "${xxx}" ]; then
		echo >&2 "can't exec \'$xxx'."
		exit 1
	    fi
	    ;;

    *)
	    echo >&2 " can't find \'$xxx'."
	    exit 1
	    ;;
    esac
done 

ps_cmd="-fe"
if [ `${id} | ${cut} -d= -f2 | ${cut} -d\( -f1` -ne 0 ]; then
   echo "$0 needs root privileges"
   exit 1
fi



#check functions replaced rootkits
LIST="${TROJAN}"
echo "Checking packages ..."
for cmd in ${LIST}
do
    chk_${cmd}
    STATUS=$?

    
    case $STATUS in
    0) echo "Checking \`${cmd}'...INFECTED";;
    1) echo "Checking \`${cmd}'...not infected";;
    2) echo "Checking \`${cmd}'...not found";;
    esac
done



#check userspace rootkit for those using ld_preload
Find_file="/etc/ld.so.preload"
Find_str="lib/libselinux.so"
echo "Checking /etc/ld.so.preload ..."

if [ ! -d $Find_file ]; then
	if [ `grep -c ${Find_str} ${Find_file}` > /dev/null 2>&1 ]; then
	    echo "There might be userspace rootkit, you need to recheck "
	    exit 0
	else 
	    echo "Do not find any changes on ld_preload"	    
	fi 

fi



# check dir for some lkm
dirs="/tmp"
echo "Checking libs'dirs ..."
for i in /usr/share /usr/bin /usr/sbin/ /lib
do
    if [ -d $i ] 
    then 
	dirs="$dirs $i"
    fi
done

echo $dirs

if ./checkdirs $dirs; then
    echo "checkdir: Nothing is detected"
else
    echo "checkdir:There might be usermode rootkit"
fi 

# all works have been done
echo "All the detections have been done."
echo "Thanks for using"
