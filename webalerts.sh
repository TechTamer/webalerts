#!/bin/sh

# $Id: webalerts.sh,v 1.9 2013/05/09 17:56:15 jcuser Exp $

# This a sloppy script to monitor the web sites.
# This is meant to be called from cron every minute by jcuser from prodmgmt02.
# Don't critisize me is this is sloppy (not full paths, etc).
# 20100625 - updated to move it to jcuser
### 201008101642 - Removed alerts for staging
### 201010271203 - Cleaned up some comments
### 201204060808 - Cleaned up incriminating comments

# Files used by the scipt
HOMEDIRR=/home/jcuser/webalerts
LOGFILE=$HOMEDIRR/webup.log
BLACKOUTFILE=$HOMEDIRR/BLACKOUT
ALERTFILE=$HOMEDIRR/ACTIVE_ALERT
ALERTEMAIL=webalerts@jennycraig.com
THEDATE=`/bin/date +%Y:%m:%d:%H:%M`
BLACKOUTTIME=120

# Check the sites
WEBA=`/usr/bin/curl -s --connect-timeout 12 http://10.217.60.25/heartbeat.html | /bin/grep -c Alive`
WEBB=`/usr/bin/curl -s --connect-timeout 12 http://10.217.60.26/heartbeat.html | /bin/grep -c Alive`
#WEBC=`/usr/bin/curl -s --connect-timeout 12 http://10.217.70.25/heartbeat.html | /bin/grep -c Alive`
#WEBD=`/usr/bin/curl -s --connect-timeout 12 http://10.217.70.26/heartbeat.html | /bin/grep -c Alive`

ALERT=0
# Up or down
if [ $WEBA -eq 0 ] ; then
	OUTPUTA="web01prdjc is DOWN!"
	ALERT=1
	else
		OUTPUTA="web01prdjc is up"
fi
if [ $WEBB -eq 0 ] ; then
	OUTPUTB="web02prdjc is DOWN!"
	ALERT=1
	else
		OUTPUTB="web02prdjc is up"
fi
#if [ $WEBC -eq 0 ] ; then
#	OUTPUTC="web01stgjc is DOWN!"
#	ALERT=1
#	else
#		OUTPUTC="web01stgjc is up"
#fi
#if [ $WEBD -eq 0 ] ; then
#	OUTPUTD="web02stgjc is DOWN!"
#	ALERT=1
#	else
#		OUTPUTD="web02stgjc is up"
#fi

# update the log
#FINALOUTPUT="$THEDATE -- $OUTPUTA -- $OUTPUTB -- $OUTPUTC -- $OUTPUTD"
FINALOUTPUT="$THEDATE -- $OUTPUTA -- $OUTPUTB"
echo $FINALOUTPUT >> $LOGFILE

# Stop scrip if blackout file exists
### I need to add function to blackout individual dev levels
### During blackout, still send email, but not pages
# New blackout routine
if [ -e $BLACKOUTFILE ] ; then
	BLACKOUT=`/usr/bin/find $BLACKOUTFILE -mmin -$BLACKOUTTIME | /usr/bin/wc -l`
	if [ $BLACKOUT -eq 0 ] ; then
		/bin/echo "Webalerts have been in blackout mode for over $BLACKOUTTIME minutes.  Is that on purpose?" | /bin/mail -s "Webalerts on BLACKOUT for over $BLACKOUTTIME minutes" $ALERTEMAIL
		/bin/touch $BLACKOUTFILE
	else
		exit 2
	fi
fi

#if [ -e $BLACKOUTFILE -a $BLACKOUT -eq 0 ] ; then
#	/bin/echo "Webalerts have been in blackout mode for over $BLACKOUTTIME mnutes.  Is that on purpose?" | /bin/mail -s "Webalerts on BLACKOUT for over $BLACKOUTTIME minutes" $ALERTEMAIL
#	/bin/touch $BLACKOUTFILE
#	elif [ -e $BLACKOUTFILE ] ; then
#		exit 2
#fi

# Is there an active alert?
# if there is currently an alert condition
# 	is there an alert file
# 		if not, create it
# 	was file touched in the last 10 mintues?
# 	if file older than 10 minutes, reset alert time
ACTIVE=0
if [ $ALERT -ne 0 ] ; then
	if [ ! -e $ALERTFILE ] ; then
		/bin/touch $ALERTFILE
		else
			ACTIVE=`/usr/bin/find $ALERTFILE -mmin -10 | /usr/bin/wc -l`
	fi
	if [ $ACTIVE -eq 0 ] ; then
		/bin/echo "$FINALOUTPUT" | /bin/mail -s "$FINALOUTPUT" $ALERTEMAIL
		/bin/touch $ALERTFILE
	fi
	elif [ -e $ALERTFILE ] ; then
		/bin/rm $ALERTFILE
fi

exit 0


