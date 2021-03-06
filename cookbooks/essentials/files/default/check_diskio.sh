#!/bin/bash
# ========================================================================================
# DISK Utilization Statistics plugin for Nagios 
#
# Written by	: Andreas Baess based on a script by Steve Bosek
# Release	: 1.0
# Creation date : 29 Aug 2012
# Description   : Nagios plugin (script) to check disk utilization statistics.
#		This script has been designed and written on Linux plateform only, 
#		requiring iostat as external program. The locations of these can easily 
#		be changed by editing the variables $IOSTAT at the top of the script. 
#		The script is used to query 3 of the key disk statistics (avgqu-sz,await,utility)
#		at the same time. 
#
# Usage         : ./check_cpu.sh [-d <device>]
#                                [-ww <diskio_await warn>] [-wc <diskio_await crit>]
#                                [-qw <diskio_queue warn>] [-qc <diskio_queue crit>]
#                                [-uw <disk_util warn>] [-uc <disk_util crit>]
#                                [-i <intervals in second>] [-n <report number>] 
# ----------------------------------------------------------------------------------------
# ========================================================================================

# Paths to commands used in this script.  These may have to be modified to match your system setup.

IOSTAT=/usr/bin/iostat

# Nagios return codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Plugin parameters value if not define
INTERVAL_SEC=${INTERVAL_SEC:="1"}
NUM_REPORT=${NUM_REPORT:="3"}
W_DISK_W=${WARNING_THRESHOLD:="1000.00"}
Q_DISK_W=${WARNING_THRESHOLD:="1000.00"}
U_DISK_W=${WARNING_THRESHOLD:="10.00"}
W_DISK_C=${CRITICAL_THRESHOLD:="1000.00"}
Q_DISK_C=${CRITICAL_THRESHOLD:="1000.00"}
U_DISK_C=${CRITICAL_THRESHOLD:="20.00"}
DEVICENAME=${DEVICENAME:="/dev/sda"}


# Plugin variable description
PROGNAME=$(basename $0)
RELEASE="Revision 1.0"
AUTHOR="by cvvnx1 <cvvnx1@163.com> based on a work from Andreas Baess (ab@gun.de)"

if [ ! -x $IOSTAT ]; then
	echo "UNKNOWN: iostat not found or is not executable by the nagios user."
	exit $STATE_UNKNOWN
fi

# Functions plugin usage
print_release() {
    echo "$RELEASE $AUTHOR"
}

print_usage() {
	echo ""
	echo "$PROGNAME $RELEASE - Disk Utilization check script for Nagios"
	echo ""
	echo "Usage: check_diskio.sh [flags]"
	echo ""
	echo "Flags:"
	echo "  -d  <devicename> : Identify check device"
	echo "  -ww <number> : Warning level in % for disk average IO wait time(ms)"
	echo "  -qw <number> : Warning level in % for disk queue length(ms)"
	echo "  -uw <number> : Warning level in % for disk % utility"
	echo "  -wc <number> : Critical level in % for disk average IO wait time(ms)"
	echo "  -qc <number> : Critical level in % for disk queue length(ms)"
	echo "  -uc <number> : Critical level in % for disk % utility"
	echo "  -i  <number> : Interval in seconds for iostat (default : 1)"
	echo "  -n  <number> : Number report for iostat (default : 3)"
	echo "  -h  Show this page"
	echo ""
    echo "Usage: $PROGNAME"
    echo "Usage: $PROGNAME --help"
    echo ""
}

print_help() {
	print_usage
        echo ""
        echo "This plugin will check disk utilization (avgqu-sz,await,utility in %)"
        echo ""
	exit 0
}

# Parse parameters
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
            print_help
            exit $STATE_OK
            ;;
        -v | --version)
            print_release
            exit $STATE_OK
            ;;
        -d | --device)
            shift
            DEVICENAME=$1
            ;;
        -ww | --wwarn)
            shift
            W_DISK_W=$1
            ;;
        -qw | --qwarn)
            shift
            Q_DISK_W=$1
            ;;
        -uw | --uwarn)
            shift
            U_DISK_W=$1
            ;;
        -wc | --wcrit)
            shift
            W_DISK_C=$1
            ;;
        -qc | --qcrit)
            shift
            Q_DISK_C=$1
            ;;
        -uc | --ucrit)
            shift
            U_DISK_C=$1
            ;;
        -i | --interval)
            shift
            INTERVAL_SEC=$1
            ;;
        -n | --number)
            shift
            NUM_REPORT=$1
            ;;        
        *)  echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
        esac
    shift
done

# CPU Utilization Statistics Unix Plateform ( Linux,AIX,Solaris are supported )
case `uname` in
  	Linux )
  	    DISK_REPORT=`iostat -dx -k $DEVICENAME 2 3 | sed -e 's/,/./g' | tr -s ' ' ';' | tail -2`
  	    DISK_AWAIT=`echo $DISK_REPORT | cut -d ";" -f 10 `
  	    DISK_AVGQU=`echo $DISK_REPORT | cut -d ";" -f 9 `
  	    DISK_UTIL=`echo $DISK_REPORT | cut -d ";" -f 14 `
	    CHECK_DISK_UTIL=`echo $DISK_UTIL | sed "s/\.//"`
	    if [ ${CHECK_DISK_UTIL} -ge 10000 ];
	    then
		DISK_UTIL=100.00;
 	    fi
        ;;
	  *)
	      echo "UNKNOWN: `uname` not yet supported by this plugin. Coming soon !"
			  exit $STATE_UNKNOWN
	      ;;
	esac

INT_DISK_AWAIT=`echo $DISK_AWAIT | sed "s/\.//"`
INT_DISK_AVGQU=`echo $DISK_AVGQU | sed "s/\.//"`
INT_DISK_UTIL=`echo $DISK_UTIL | sed "s/\.//"`

INT_W_DISK_W=`echo $W_DISK_W | sed "s/\.//"`
INT_Q_DISK_W=`echo $Q_DISK_W | sed "s/\.//"`
INT_U_DISK_W=`echo $U_DISK_W | sed "s/\.//"`
INT_W_DISK_C=`echo $W_DISK_C | sed "s/\.//"`
INT_Q_DISK_C=`echo $Q_DISK_C | sed "s/\.//"`
INT_U_DISK_C=`echo $U_DISK_C | sed "s/\.//"`

# Are we in a critical state?
#if [ ${DISK_AWAIT} -ge ${W_DISK_C} -o ${DISK_AVGQU} -ge ${Q_DISK_C} -o ${DISK_UTIL} -ge ${U_DISK_C} ];
#then
#    echo "DISKIO CRITICAL : disk_await=${DISK_AWAIT} disk_avgrq=${DISK_AVGQU} disk_util=${DISK_UTIL}% | disk_await=${DISK_AWAIT};${W_DISK_W};${W_DISK_C}; disk_avgrq=${DISK_AVGQU};${U_DISK_W};${U_DISK_C}; disk_util=${DISK_UTIL}%;${U_DISK_W};${U_DISK_C};"
#    exit $STATE_CRITICAL
#fi

if [ ${INT_DISK_AWAIT} -ge ${INT_W_DISK_C} -o ${INT_DISK_AVGQU} -ge ${INT_Q_DISK_C} -o ${INT_DISK_UTIL} -ge ${INT_U_DISK_C} ];
then
    echo "DISKIO CRITICAL : disk_await=${DISK_AWAIT} disk_avgrq=${DISK_AVGQU} disk_util=${DISK_UTIL}% | disk_await=${DISK_AWAIT}; disk_avgrq=${DISK_AVGQU}; disk_util=${DISK_UTIL}%;${U_DISK_W};${U_DISK_C};"
    exit $STATE_CRITICAL
fi

#if (expr ${DISK_AWAIT} > ${W_DISK_C}) || (expr ${DISK_AVGQU} > ${Q_DISK_C}) || (expr ${DISK_UTIL} > ${U_DISK_C}) then
#    echo "DISKIO CRITICAL : disk_await=${DISK_AWAIT} disk_avgrq=${DISK_AVGQU} disk_util=${DISK_UTIL}% | disk_await=${DISK_AWAIT};${W_DISK_W};${W_DISK_C}; disk_avgrq=${DISK_AVGQU};${U_DISK_W};${U_DISK_C}; disk_util=${DISK_UTIL}%;${U_DISK_W};${U_DISK_C};"
#    exit $STATE_CRITICAL
#fi


# Are we in a warning state?
if [ ${INT_DISK_AWAIT} -ge ${INT_W_DISK_W} -o ${INT_DISK_AVGQU} -ge ${INT_Q_DISK_W} -o ${INT_DISK_UTIL} -ge ${INT_U_DISK_W} ];
then
    echo "DISKIO WARNING : disk_await=${DISK_AWAIT} disk_avgrq=${DISK_AVGQU} disk_util=${DISK_UTIL}% | disk_await=${DISK_AWAIT}; disk_avgrq=${DISK_AVGQU}; disk_util=${DISK_UTIL}%;${U_DISK_W};${U_DISK_C};"
    exit $STATE_CRITICAL
fi

#if (expr ${DISK_AWAIT} \> ${W_DISK_W}) || (expr ${DISK_AVGQU} \> ${Q_DISK_W}) || (expr ${DISK_UTIL} \> ${U_DISK_W}) then
#    echo "DISKIO WARNING : disk_await=${DISK_AWAIT} disk_avgrq=${DISK_AVGQU} disk_util=${DISK_UTIL}% | disk_await=${DISK_AWAIT};${W_DISK_W};${W_DISK_C}; disk_avgrq=${DISK_AVGQU};${U_DISK_W};${U_DISK_C}; disk_util=${DISK_UTIL}%;${U_DISK_W};${U_DISK_C};"
#    exit $STATE_CRITICAL
#fi

# If we got this far, everything seems to be OK - IDLE has no threshold
echo "DISKIO OK : disk_await=${DISK_AWAIT} disk_avgrq=${DISK_AVGQU} disk_util=${DISK_UTIL}% | disk_await=${DISK_AWAIT}; disk_avgrq=${DISK_AVGQU}; disk_util=${DISK_UTIL}%;${U_DISK_W};${U_DISK_C};"
exit $STATE_OK



