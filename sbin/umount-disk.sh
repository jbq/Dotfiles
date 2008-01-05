#! /bin/sh -e

sudo umount $CRYPTFILES || true

if [ "$(uname)" = "FreeBSD" ] ; then
    sudo gbde detach /dev/md0
else
    sudo cryptsetup remove disk
fi
