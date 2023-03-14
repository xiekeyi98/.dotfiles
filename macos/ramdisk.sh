#!/bin/sh -eu
#It takes number of megabytes as its first argument and creates/mounts (ram)disk of this size, for example if called as ramdisk.sh 500, it creates 500 MiB volume and mounts it. To release it, just unmount this volume (of “eject” it with Finder)
#https://www.reddit.com/r/MacOS/comments/sj0bod/is_there_an_implementation_of_tmpfs_for_macos/
NUMSECTORS=$(($1*1024*1024/512))
MYDEV=$(hdiutil attach -nomount ram://$NUMSECTORS)
diskutil eraseVolume HFS+ "ramdisk-${1}mb" $MYDEV
