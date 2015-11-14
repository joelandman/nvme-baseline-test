#!/bin/bash

#  set your top level mount point here, so all nvme will show up under this as
#  $MNTP/1 ...
MNTP=/data
for i in {0..23}
    do
	mkdir -p $MNTP/${i}
	mount -o noatime,nodiratime /dev/nvme${i}n1 $MNTP/${i}
        mkdir -p $MNTP/${i}/test
    done
df -h | grep $MNTP
