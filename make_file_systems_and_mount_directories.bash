#!/bin/bash

#  set your top level mount point here, so all nvme will show up under this as
#  $MNTP/1 ...
MNTP=/data
for i in {0..23}
    do
	mkdir -p $MNTP/${i}
	mkfs.xfs -K -l size=128m,sectsize=4k -d agcount=32,sectsize=4k -b size=4k /dev/nvme${i}n1
	mount -o noatime,nodiratime /dev/nvme${i}n1 $MNTP/${i}
        mkdir -p $MNTP/${i}/test
    done
df -h | grep $MNTP
