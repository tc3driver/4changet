#!/bin/bash
CDIR=`pwd`
DLCMD=echo "curl -s http://boards.4chan.org/$1/thread/$2 |tr \">\" \"\n\"| grep -o -i 'File: <a href=\"//i.4cdn.org\/[a-z]*\/[0-9]*\.[a-z]\{3,4\}' | sed -r 's/File: <a href=\"\/\///'"
sedfile="'s/images.4chan.org\/[a-z]*\/src\///'"
if [ -z "$1" ]
then
	echo "command should be ./4cget.sh <board> <postnumber> (<end folder>)"
	echo "as in"
	echo "./4cget a 41232412 r32"
	exit 1
fi
if [ -z "$2" ]
then
	echo "command should be ./4cget.sh <board> <postnumber> (<end folder>)"
	echo "as in"
	echo "./4cget a 41232412 r32"
	exit 1
fi
if [ -z "$3" ]
then
	DIR=$CDIR/$2
else 
	DIR=$CDIR/$3
fi
	#DLCMD="curl -s https://fuuka.worldathleticproject.org/$1/thread/$2/ |grep -o -i '<a href=\"https://fuuka.worldathleticproject.org\/boards\/$1\/image\/[0-9]*\/[0-9]*\/[0-9]*\.[a-z]\{3\}' |sed -r 's/<a href=\"//'"
	#response=$(curl --write-out %{http_code} --silent --output /dev/null https://fuuka.worldathleticproject.org/$1/thread/$2/)
	#sedfile="'s/https:\/\/fuuka.worldathleticproject.org\/boards\/$1\/image\/[0-9]*\/[0-9]*\///'"
if [ ! -d "$DIR" ]
then
	mkdir -p $DIR
fi
response=$(curl --write-out %{http_code} --silent --output /dev/null http://boards.4chan.org/$1/thread/$2)
cd $DIR
echo $response
echo $DLCMD
while [ $response -eq 200 ]
do
	for i in `curl -s http://boards.4chan.org/$1/thread/$2 |tr ">" "\n"| grep -o -i 'File: <a href="//i.4cdn.org\/[a-z]*\/[0-9]*\.[a-z]\{3,4\}' | sed -r 's/File: <a href="\/\///'`
	do
		echo $i
		FILE=`echo $i |sed -r 's/i.4cdn.org\/[a-z]*\///'`
		if [ ! -f "$DIR/$FILE" ]
		then
			wget $i
			echo $DIR/$FILE
		fi
	done
	sleep 60
	response=$(curl --write-out %{http_code} --silent --output /dev/null http://boards.4chan.org/$1/thread/$2)
	echo $response
done
find -not -empty -type f -printf "%s\n" | sort -rn | uniq -d | xargs -I{} -n1 find -type f -size {}c -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate|awk '{print $2}'| awk '/^[0-9][0-9][0-9]/ && !(++c%2)'|xargs rm -rf
cd ..
