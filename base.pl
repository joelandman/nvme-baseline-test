#!/usr/bin/perl

use strict;
my $MNTP ="/data";
my ($conf,$dir,$sfn,$sfh,$ojfn,$ojfh,$ts);
my @num = (1 .. 20);
my @blk = ("4k","8k","32k","128k","512k","2M","8M");
my @thr = (1,2,4,8,16,32);
my $size = "10g";
my $lastn = $num[$#num];


$ts  = time;

open($sfh,"> run_all.bash");
printf $sfh '#!/bin/bash'."\n\n";
map {printf $sfh 'mkdir -p %s/%i/test'."\n",$MNTP,$_ } (0 .. $lastn-1);

foreach my $n (@num) {
    foreach my $bsize (@blk) {
    printf $sfh '# n=%i, blk_size=%s'."\n",$n,$bsize;
    $ojfn = sprintf "sw_%i_%s.fio",$n,$bsize;
    open($ojfh, ">".$ojfn);
    printf $sfh "mkdir -p %s/{%s}/test\n",$MNTP,join(",",(0 .. $n-1));
    printf $sfh "fio %s > stdout.%s 2> stderr.%s \n",$ojfn,$ojfn,$ojfn;
    printf $ojfh "%s\n",&fio_job_1($size,"write",$bsize,4,$n);
    close($ojfh);
    $ojfn = sprintf "sr_%i_%s.fio",$n,$bsize;
    open($ojfh, ">".$ojfn);
    printf $sfh "fio %s > stdout.%s 2> stderr.%s \n\n",$ojfn,$ojfn,$ojfn;
    printf $ojfh "%s\n",&fio_job_1($size,"read",$bsize,4,$n);
    close($ojfh);
    }
}

$size = "5g";
printf $sfh "\n\n".'########'."\n".'# random tests'."\n";
foreach my $n (@num) {
    foreach my $bsize (@blk) {
    printf $sfh '# n=%i, blk_size=%s'."\n",$n,$bsize;
    $ojfn = sprintf "rw_%i_%s.fio",$n,$bsize;
    open($ojfh, ">".$ojfn);
    printf $sfh "fio %s > stdout.%s 2> stderr.%s \n",$ojfn,$ojfn,$ojfn;
    printf $ojfh "%s\n",&fio_job_1($size,"randwrite",$bsize,4,$n);
    close($ojfh);
    $ojfn = sprintf "rr_%i_%s.fio",$n,$bsize;
    open($ojfh, ">".$ojfn);
    printf $sfh "fio %s > stdout.%s 2> stderr.%s \n\n",$ojfn,$ojfn,$ojfn;
    printf $ojfh "%s\n",&fio_job_1($size,"randread",$bsize,4,$n);
    close($ojfh);
    }
}
chmod 0755,"run_all.bash";


sub fio_job_1 {
    my ($size,$type,$blocksize,$n_per_dir,$ndir) = @_;
    my $template = sprintf
"[global]
size=%s
iodepth=256
direct=1
blocksize=%s
numjobs=%i
nrfiles=1
ioengine=aio
group_reporting
create_serialize=0
create_on_open=1
rw=%s

",$size,$blocksize,$n_per_dir,$type;
foreach my $i (1 .. $ndir) {
    $template .= sprintf "\n[d%i]\ndirectory=%s/%i/test\n",$i,$MNTP,$i-1;
}
return $template;
}
