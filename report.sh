#!/bin/sh

# $Id: report.sh,v 1.9 2013/06/07 23:13:28 jcuser Exp $

## sloppy send out report script 201007061815 -g2
## updated 20100708 -g2

# Wait a sec for file to be written to by cron process
#wait 15

# set the date
THEDATE=`/bin/date +%Y-%m-%d`
APPPATH="/home/jcuser/webalerts"
ARCHIVEPATH="$APPPATH/archive"
LOGNAME="$APPPATH/webup.log"
FILENAME="$ARCHIVEPATH/webup-$THEDATE.csv"
MINDOWN=`/bin/grep DOWN $LOGNAME | /usr/bin/wc -l`
DAILYWEBUP="$ARCHIVEPATH/webup-$THEDATE"
DAILYDOWN="$ARCHIVEPATH/downtime-$THEDATE"

# create the file with column headers
/bin/echo "year,month,day,hour,minute,web01prdjc,web02prdjc,web01stgjc,webo2stgjc" | /usr/bin/unix2dos > $FILENAME

# create the spreadsheet and convert it to dos
/bin/awk -F '[[:space:],:]' -v OFS=',' '{print $1, $2, $3, $4, $5, $9, $13, $17, $21}' $LOGNAME | /usr/bin/unix2dos >> $FILENAME

# Add count and uptime feature
/bin/echo ',,,,,,,,' | /usr/bin/unix2dos >> $FILENAME
/bin/echo 'EXPERIMENTAL ADDITION,,,,,,,,' | /usr/bin/unix2dos >> $FILENAME
/bin/echo 'THE FOLLOWING FORMULAS MAY OR MAY NOT WORK OR BE ACCURATE,,,,,,,,' | /usr/bin/unix2dos >> $FILENAME
/bin/echo 'IF YOU HAVE PROBLEMS CHECK THAT THE REFERENCES AND RANGES ARE CORRECT,,,,,,,,' | /usr/bin/unix2dos >> $FILENAME
/bin/echo ',,,,,,,,' | /usr/bin/unix2dos >> $FILENAME
/bin/echo 'Total minutes down in the last 24hrs (8a-8a),,,,,"=COUNTIF(F2:F1444,""DOWN!"")","=COUNTIF(G2:G1444,""DOWN!"")","=COUNTIF(H2:H1444,""DOWN!"")","=COUNTIF(I2:I1444,""DOWN!"")"' | /usr/bin/unix2dos >> $FILENAME
/bin/echo 'Percent uptime in the last 24hrs (8a-8a),,,,,=100-(F1446/1440),=100-(G1446/1440),=100-(H1446/1440),=100-(I1446/1440)' | /usr/bin/unix2dos >> $FILENAME

# create downtime report
/bin/echo "We had $MINDOWN minutes of production servers unavailable in the last 24 hours" > $DAILYDOWN
/bin/echo " " >> $DAILYDOWN
/bin/grep DOWN $LOGNAME >> $DAILYDOWN

# encode the spreadsheet as an attachment and send it out
#(/bin/cat $DAILYDOWN ; /usr/bin/uuencode $FILENAME webup-$THEDATE.csv) | /bin/mail -s "Web Up Report for $THEDATE" networkengineers@jennycraig.com
(/bin/cat $DAILYDOWN ; /usr/bin/uuencode $FILENAME webup-$THEDATE.csv) | /bin/mail -s "Web Up Report for $THEDATE" ISSystemsEngineers@jennycraig.com

# rotate the log out
/bin/cp $LOGNAME $DAILYWEBUP
/bin/cat /dev/null > $LOGNAME

exit 0



