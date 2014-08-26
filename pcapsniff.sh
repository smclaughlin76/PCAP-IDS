#!/bin/bash
#

# Check to see if already running
LOCKFILE=/var/run/filedrop.lock

trap "{ rm -f $LOCKFILE; exit 255; }" EXIT
if  [ -f $LOCKFILE ]
then
   echo "Already running. Exiting."
   exit 1
fi

touch $LOCKFILE

ndir=/home/nessus/dropoff
pdir=/home/pcap/dropoff 

# Process PCAP files for Snort
echo "Processing PCAP File Drop"
if [ -f $pdir/*.pcap ]; then
        pwdir=/tmp/`date +"%s"`
        mkdir $pwdir
        for file in $(ls $pdir/*.pcap); do
                openfile=`/usr/sbin/lsof $file`
                echo This is the check $openfile
                        if [[ -z $openfile ]] ; then
                        mv $file $pwdir
                        else
                        echo "PCAP file in use."
                        fi
                if [ -f $pwdir/*.pcap ]; then
                /usr/local/bin/snort -c /usr/local/etc/snort/snort_pcap.conf --pcap filter="*.pcap" --pcap-dir=$pwdir
                fi
        rm -fr $pwdir
        done
fi 

exit 0
