#!/usr/bin/env bash


# Progress spinner for feedback
sp="/-\|"
sc=0
spin() {
   printf "\b${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}
endspin() {
   printf "\r%s\n" "$@"
}

# Expand partition 3 of the SD Card to make it as large as possible
DEV="/dev/mmcblk1"
echo "Resizing partition map for $DEV"
for disk in ${DEV}*
do
	umount $disk
done

fdisk $DEV <<EOF
p
d

n
p



w
EOF

sync; sync

e2fsck -f -y ${DEV}p3
resize2fs ${DEV}p3

sync; sync

echo "Resize complete"
echo "Mounting new Filesystem..."
if [ ! -d /mnt/SD3 ]; then
    mkdir /mnt/SD3
fi
mount ${DEV}p3 /mnt/SD3
pv=`which pv`
if [ ! -f $pv ]; then
    echo "Minimal feedback provided ... be patient."
    echo "run dnf install pv and re-run this script for "
    echo "beter feedback on progress."
    echo "Type ^C to exit now."
    for i in {1..8}
    do
       spin
       sleep 1
    done
    endspin
    
fi

# Move the old rootfs.tar.gz in case we need it again
# If it doesn't exist, this is some other media, so abort.
echo "moving old rootfs for safety"
if [ -f /mnt/SD3/rootfs.tar.gz ]; then
    mv /mnt/SD3/rootfs.tar.gz /mnt/SD3/oldroot.tgz
else
    echo "There is no rootfs.tar.gz in /mnt/SD3"
    echo "This may not be the right thing for you to do."
    exit 1
fi

cd /
echo "Backing up root file system. This will take some time."

TARFILE=/mnt/SD3/rootfs.tar
touch $TARFILE

# These are all added to the tarfile with --no-recursion
ADD_DIRS="bin dev/pts lib lost+found media mnt proc run/systemd run/systemd/shutdown run/systemd/netif run/systemd/netif/links run/systemd/netif/leases run/systemd/machines run/systemd/sessions run/systemd/ask-password run/systemd/users run/systemd/seats run/mariadb run/log run/wpa_supplicant run/lock run/lock/subsys run/lock/lockdev run/user run/faillock run/setrans run/lirc run/console run/netreport run/blkid run/sepermit sbin srv sys var/log var/lock var/run var/cache/yum var/cache/dnf var/yp var/games var/empty var/empty/sshd var/tmp var/spool var/spool/mail var/spool/mail/rpc var/spool/lpd var/spool/anacron var/spool/cron"

# These are added recursively. 
ADD_FILES="etc dev/stdin dev/stderr dev/tty dev/random dev/fd dev/zero dev/full dev/ptmx dev/shm/ dev/urandom dev/null dev/stdout home opt root tmp/.font-unix/ tmp/.Test-unix/ tmp/.XIM-unix/ tmp/.X11-unix/ tmp/.ICE-unix/ usr var/local/ var/nis/ var/log/lastlog var/log/mariadb/ var/log/wtmp var/log/btmp var/log/tallylog var/log/README var/log/journal/ var/lib/ var/mail var/preserve/ var/opt/ var/gopher/ var/kerberos/ var/db/ var/adm/ var/cache/ var/cache/ldconfig/ var/cache/ldconfig/aux-cache var/cache/man/ var/cache/fontconfig/ var/spool/anacron/cron.weekly var/spool/anacron/cron.daily var/spool/anacron/cron.monthly tmp/.kura"

for f in $ADD_DIRS ; do
    if [ $pv ]; then 
        echo -ne  "`tar rf $TARFILE --no-recursion $f | pv -N \"Adding $f \"   ` \r"
    else
        echo "Adding $f to tarfile ..."
        tar rf $TARFILE --no-recursion $f  
    fi
done 
echo  "Done with directories                                     "

for f in $ADD_FILES ; do
    if [ $pv ]; then
        #spin
        echo -ne "`tar cf - $f -P | pv -N \"Adding $f \" -s  $(du -sb $f | awk '{print $1}') >> $TARFILE`                    \r"               
    else
        printf "Adding %s \n" "$f"
        tar rf $TARFILE --checkpoint=.1000 $f 
        printf "\n"
    fi
done 
echo  "Done with files                                          "

if [ -f $pv ]; then 
    gzip /mnt/SD3/rootfs.tar | pv -N "Compressing the rootfs"
else
    echo "Sorry, no progress indication, be patient ..."
    gzip /mnt/SD3/rootfs.tar
fi
echo "Done!"
echo ""