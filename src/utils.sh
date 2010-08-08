#!/bin/bash
##########################################################################
#     This file is part of d4firewall
#
#     d4firewall is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.
#
#     d4firewall is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
##########################################################################
#     Copyright (C) 2010 Matteo Chesi
##########################################################################
#
# Utils functions
#
# Author: Matteo Chesi < d4lamar(at)gmail.com >
#
#
# 2010-05-29 0.4 Changes for World Wide Distribution 
#

CUR_X=0
TPUT=/usr/bin/tput
if [ -x $TPUT ];
then
	COLUMNS=`$TPUT cols 2>/dev/null`
fi
if [ -z "$COLUMNS" ];
then 
	COLUMNS=80
fi


#Colors Sequences
#Black       0;30     Dark Gray     1;30
#Blue        0;34     Light Blue    1;34
#Green       0;32     Light Green   1;32
#Cyan        0;36     Light Cyan    1;36
#Red         0;31     Light Red     1;31
#Purple      0;35     Light Purple  1;35
#Brown       0;33     Yellow        1;33
#Light Gray  0;37     White         1;37

#GRAY="\[\033[1;30m\]"
#LIGHT_GRAY="\[\033[0;37m\]"
NO_COLOR="\033[0m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
WHITE="\033[1;37m"

log_begin()
{
	string=`echo "$1" | sed -r 's/^(.*)\s*$/\1/'`
	if [ -n "$string" ];
	then
		#If contains \n I have to handle it in string length calc
		string2=`echo -e "$string" | tail -n 1` 
		if [ -n "$string2" ];
		then
			length=`expr length "$string2"`
		else
			length=`expr length "$string"`
		fi
		echo -ne "$string"
		CUR_X=$length
	fi
}

log_end()
{
	if [ -n "$1" ];
	then
		length=`expr length "$1"`
		forward=`expr $COLUMNS - $CUR_X - $length - 1`
		echo -ne  "\033["$forward"C"
		if [ -n "$2" ];
		then
			echo -e "$2"
		else
			echo -e "$1"
		fi
		CUR_X=0
	fi

}

log_failed()
{
	uncolored="[failed]"
	colored="[${RED}failed${NO_COLOR}]"
	log_end "$uncolored" "$colored"
}

log_unused()
{
        uncolored="[unused]"
        colored="[${WHITE}unused${NO_COLOR}]"
        log_end "$uncolored" "$colored"

}

log_ok()
{
        uncolored="[ok]"
        colored="[${GREEN}ok${NO_COLOR}]"
        log_end "$uncolored" "$colored"
}

log_running()
{
        uncolored="[running]"
        colored="[${GREEN}running${NO_COLOR}]"
        log_end "$uncolored" "$colored"
}

log_unknown()
{
        uncolored="[unknown]"
        colored="[${YELLOW}unknown${NO_COLOR}]"
        log_end "$uncolored" "$colored"
}

# Return values acc. to LSB for all commands but status:
# 0       - success
# 1       - generic or unspecified error
# 2       - invalid or excess argument(s)
# 3       - unimplemented feature (e.g. "reload")
# 4       - user had insufficient privileges
# 5       - program is not installed
# 6       - program is not configured
# 7       - program is not running
# 8--199  - reserved (8--99 LSB, 100--149 distrib, 150--199 appl)
#
# Note that starting an already running service, stopping
# or restarting a not-running service as well as the restart
# with force-reload (in case signaling is not supported) are
# considered a success.

# Return value is slightly different for the status command:
# 0 - service up and running
# 1 - service dead, but /var/run/  pid  file exists
# 2 - service dead, but /var/lock/ lock file exists
# 3 - service not running (unused)
# 4 - service status unknown :-(
# 5--199 reserved (5--99 LSB, 100--149 distro, 150--199 appl.)

status_exit()
{
	case "$1" in
		0)
			log_running
			;;
		3)
			log_unused
			;;
		*)
			log_unknown
			;;
	esac
	
	if [ -n "$1" ];
	then
		exit $1
	else
		exit 1
	fi
}

init_exit()
{
        case "$1" in
                0)
                        log_ok
                        ;;
                1)
                        log_failed
                        ;;
                *)
                        log_unknown
                        ;;
        esac

        if [ -n "$1" ];
        then
                exit $1
        else
                exit 1
        fi
}

