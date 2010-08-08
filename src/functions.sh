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
# Functions for d4firewall
#
# Author: d4lamar 
#
# 2010-05-29 0.4 Changes for World Wide Distribution 
#

do_start()
{
    #Load Enabled Rules
    cat $ENABLED_CONFIG | comments_filter | expansion_filter | $IPTABLES_RESTORE_BIN 2>&1 >/dev/null 

    if [ $? == 0 ];
    then
        return 0
    else
        return 1
    fi  
}

do_stop()
{
    #Load Disabled Rules
    cat $DISABLED_CONFIG | comments_filter | expansion_filter | $IPTABLES_RESTORE_BIN 2>&1 >/dev/null 

    if [ $? == 0 ];
    then
        return 0
    else
        return 1
    fi  
}

do_status() 
{
    TMP_FILE='/tmp/d4ffirewall.tmp'
    DIFF_ENABLED_FILE='/tmp/d4fenabled.tmp'
    DIFF_DISABLED_FILE='/tmp/d4fdisabled.tmp'

    delete_tmp() {
        #Delete Temporary File
        rm -f $TMP_FILE
        rm -f $DIFF_ENABLED_FILE
        rm -f $DIFF_DISABLED_FILE
    }

    #INITIALIZE IPTABLES
    $IPTABLES_BIN -L 2>&1 >/dev/null
    
    $IPTABLES_SAVE_BIN  | comments_filter | tables_filter > $TMP_FILE
    cat $ENABLED_CONFIG | comments_filter | expansion_filter | tables_filter | diff -wB - $TMP_FILE 2>&1 >$DIFF_ENABLED_FILE
    if [ $? == 0 ];
    then
        delete_tmp;
        return 0;
    fi
    cat $DISABLED_CONFIG | comments_filter | expansion_filter | tables_filter | diff -wB - $TMP_FILE 2>&1 >$DIFF_DISABLED_FILE
    if [ $? == 0 ];
        then
        delete_tmp;
        return 3;
    else
        #delete_tmp;
	show_status_diffs;
        return 4;
    fi
    
}

do_save_enabled()
{
        #$IPTABLES_SAVE_BIN > $ENABLED_CONFIG
	do_save $ENABLED_CONFIG
        if [ $? == 0 ];
        then
                return 0
        else
                return 1
        fi
}

do_save_disabled()
{
        #$IPTABLES_SAVE_BIN > $DISABLED_CONFIG
	do_save $DISABLED_CONFIG
        if [ $? == 0 ];
        then
                return 0
        else
                return 1
        fi
}

do_save()
{
	CONFIG_FILE=$1

	#PHASE 0 - Collect iptables status
	TMP_FILE0=/tmp/d4f_firewall.0.tmp
        $IPTABLES_SAVE_BIN | comments_filter | tables_filter > $TMP_FILE0 || return 1

	#PHASE 1 - Save diffs with previous config file expanding variables
	TMP_FILE1=/tmp/d4f_firewall.1.tmp
	cat $CONFIG_FILE | comments_filter | expansion_filter | tables_filter | diff -wB - $TMP_FILE0 2>/dev/null 1>$TMP_FILE1 

	#PHASE 2 - Patch previous config file without expanding variables
	TMP_FILE2=/tmp/d4f_firewall.2.tmp
	cat $CONFIG_FILE | comments_filter | tables_filter > $TMP_FILE2 
	patch -p0 $TMP_FILE2 < $TMP_FILE1 2>&1 >/dev/null || return 1

	#PHASE 3 - Place back comments that come before an unmodified line
	TMP_FILE3=/tmp/d4f_firewall.3.tmp
	replace_comments $CONFIG_FILE $TMP_FILE2

	#Delete TMP files
	rm -f /tmp/d4f_*.tmp
}

tables_filter()
{      
	switch_table() {
		TABLE_NAME=$1
        	TMP_TABLE_FILENAME="/tmp/d4f_"$TABLE_NAME".tmp"
	}
	
       	TMP_ORDER_FILENAME="/tmp/d4f_order.tmp"
	ORDER_DEFAULTS=0

	switch_table "0-preamble"

        while read line
        do      
		echo "$line" | grep -Eq '^[[:blank:]]*#'
		if [ $? -eq 0 ]; then
			echo "$line" | grep -Eq '^# Generated'
			if [ $? -eq 0 ]; then
				GENERATED_COMMENT=$line
			else
                        	echo "$line" >> $TMP_TABLE_FILENAME
			fi	
		else
			if [ $ORDER_DEFAULTS -eq 1 ];then
				if [ "${line:0:1}" == ":" ];then
					echo "$line"  | sed -r "s/\[[0-9]+\:[0-9]+\]//" | sed -r "s/^[[:blank:]]*$//" >> $TMP_ORDER_FILENAME
					continue
				else
					ORDER_DEFAULTS=0
					cat $TMP_ORDER_FILENAME | sort >> $TMP_TABLE_FILENAME
					rm -f $TMP_ORDER_FILENAME
				fi
			fi
                	TMP_NAME=`echo "$line" | sed -rn "s/^\*(.+)/\1/p"`
                	if [ -n "$TMP_NAME" ];then                                        
				switch_table $TMP_NAME
				ORDER_DEFAULTS=1
				if [ -n "$GENERATED_COMMENT" ];then
                        		echo "$GENERATED_COMMENT" >> $TMP_TABLE_FILENAME            
                        		GENERATED_COMMENT=''           
				fi
                        	echo "$line" >> $TMP_TABLE_FILENAME            
                        else                                            
                                echo "$line"  | sed -r "s/\[[0-9]+\:[0-9]+\]//" | sed -r "s/^[[:blank:]]*$//" >> $TMP_TABLE_FILENAME
                	fi
		fi	
        done

        #Reorder tables output
        FILES=`ls /tmp/d4f_*.tmp | sort`

        for FILE in $FILES
        do
                cat $FILE
        done

        #Delete Temporary Files
        rm -f /tmp/d4f_*.tmp
}

show_status_diffs() {

    TMP_FILE='/tmp/d4ffirewall.tmp'
    DIFF_ENABLED_FILE='/tmp/d4fenabled.tmp'
    DIFF_DISABLED_FILE='/tmp/d4fdisabled.tmp'

    delete_tmp() {
        #Delete Temporary File
        rm -f $TMP_FILE
        rm -f $DIFF_ENABLED_FILE
        rm -f $DIFF_DISABLED_FILE
    }


    echo -e "\nDifferences with ENABLED RULES ($ENABLED_CONFIG) :" 
    cat $DIFF_ENABLED_FILE
    echo -e "\nDifferences with DISABLED RULES ($DISABLED_CONFIG) :" 
    cat $DIFF_DISABLED_FILE
    echo "" 

    #Delete Temporary Files
    delete_tmp
}

comments_filter() {
 while read data
 do
 	echo $data | grep -v '^[[:blank:]]*#'
 done
}

expansion_filter() {
 while read data
 do
 	data=`echo $data | sed 's/\"/\\\"/g'`
 	data=`echo $data | sed "s/'/\\\\\'/g"`
 	eval "echo $data"
 done
}

replace_comments() {

	local COMMENTS_FILE=$1
	local NO_COMMENTS_FILE=$2
	local OUTPUT_FILE='/tmp/d4f_replace-out.tmp'
	local TMP_FILE='/tmp/d4f_replace-tmp.tmp'

	#Pipe form to use variables outside the subshells loop
	cat $COMMENTS_FILE | grep -A1 '^[[:blank:]]*#' | {
	
	comment_lines=0
	comment=''
	cat $NO_COMMENTS_FILE > $OUTPUT_FILE

	while read row
	do
		#Save comment line
		if [ "$row" != "--" ]; then 
			comment[${comment_lines}]=$row
			(( comment_lines++ ))
		else
			(( comment_lines-- ))
			#End of File Comments Exception
			echo ${comment[${comment_lines}]} | grep -q "^[[:blank:]]*#"
			if [ $? -ne 0 ];then
				cat $OUTPUT_FILE | while read line
				do
					if [ "$line" == "${comment[${comment_lines}]}" ];then
						for index in `seq 0 ${comment_lines}`
						do
							echo ${comment[${index}]} >> $TMP_FILE 
						done
					else
						echo $line >> $TMP_FILE
					fi
				done
				comment_lines=0
				comment=''
				mv $TMP_FILE $OUTPUT_FILE
			fi	
		fi
	done
	
	#End of File Comments Exception
	(( comment_lines-- ))
	if [ $comment_lines -gt 0 ];then
		cat $OUTPUT_FILE > $TMP_FILE
		for index in `seq 0 ${comment_lines}`
		do
			echo ${comment[${index}]} >> $TMP_FILE 
		done
		mv $TMP_FILE $OUTPUT_FILE
	fi

	}

	mv $OUTPUT_FILE $COMMENTS_FILE || return 1

}

