#!/bin/bash

PATH=$PATH:/sbin:/usr/sbin

SCRIPTNAME=$(basename $0)

[ "$1" ] && [ "$2" ] && [ "$3" ]|| { echo "usage: $SCRIPTNAME <file_prefix> <log_file:0|1> <list_of_cmds|none>"; exit; }

HNAME=$(hostname)
PREFIX=$(echo $1.hostinfo | sed 's/_/-/g;s/\./-/g')
[ -d $PREFIX ] || { mkdir $PREFIX; }
PREFIX="$PREFIX/$HNAME"

LOG=$2
[ "$2" != "1" ] || {
    LOGFILE="$SCRIPTNAME.exec.$(date +%Y%m%d%H%M%S).log"
    exec &> >(tee -a "$LOGFILE")
}
shift 2

PACKAGES=""
for i in lspci lsusb hdparm lshw ifconfig cpu-info cpuid 
do
    which $i &> /dev/null
    if [ $? -ne 0 ]
    then
        case $i in
            lsusb) 
                PACKAGES="$PACKAGES usbutils"
                ;;
            lspci) 
                PACKAGES="$PACKAGES pciutils"
                ;;
            ifconfig) 
                PACKAGES="$PACKAGES inetutils-tools"
                ;;
            cpu-info) 
                PACKAGES="$PACKAGES cpuinfo"
                ;;
            *)
                PACKAGES="$PACKAGES $i"
                ;;
       esac
    fi
done

if [ "$PACKAGES" != "" ]
then
    sudo apt install $PACKAGES -y
fi

sudo docker version &> "$PREFIX.INFO.docker"
uname -v &> "$PREFIX.INFO.uname"
hostnamectl &> "$PREFIX.INFO.hostnamectl"
cat /proc/cpuinfo  &> "$PREFIX.INFO.cpuinfo"
sudo lshw -short &> "$PREFIX.INFO.lshw"
lspci -v &> "$PREFIX.INFO.lspci"
lsusb -v &> "$PREFIX.INFO.lsusb"
cpu-info &> "$PREFIX.INFO.cpu-info"
cpuid &> "$PREFIX.INFO.cpuid"
sudo hdparm $(df | grep -w -E "(/$)" | cut -d" " -f1) &> "$PREFIX.INFO.hdparm"
sudo ifconfig -a &> "$PREFIX.INFO.ifconfig"

if [ "$1" != "none" ]
then
    for CMD in $*
    do
        which $CMD &> /dev/null
        if [ $? -eq 0 ]
        then
            # -q is required because of some cmds such as cpp
            for i in "--version -v" "-v -q" "-V -q" "version"
            do
                $CMD $i &> $PREFIX.CMD.$CMD.v
                if [ $? -eq 0 ]
                then
                    break
                fi
            done
        else
            echo "[ERROR] CMD $CMD NOT FOUND!"
        fi
    done
fi

sudo apt list --installed &> $PREFIX.INFO.apt_installed

# ubuntu
[ ! -f /etc/lsb-release ] || { 
    cat /etc/lsb-release &> $PREFIX.INFO.lsb-release
}

# ubuntu & debian
which lsb_release &> /dev/null
[ $? -ne 0 ] || { 
    lsb_release -a &> $PREFIX.INFO.lsb_release
}

# debian
[ ! -f /etc/lsb-release ] || { 
    cat /etc/debian_version &> $PREFIX.INFO.debian_version
}

# alpine & fedora
[ ! -f /etc/os-release ] || { 
    cat /etc/os-release &> $PREFIX.INFO.os-release
}

# alpine
[ ! -f /etc/alpine-release ] || { 
    cat /etc/alpine-release &> $PREFIX.INFO.alpine-release
}

# all *release
cat /etc/*release &> $PREFIX.INFO.all-release

cat $PREFIX*.docker

