#! /bin/bash

# READING OPTIONS
while [ "$1" != '' ]
do
	if	[ "$1" == "-h" ]
	then
		echo "You can use the following options :
		-h : for help
		-i inputfile
		-o outputfile
		-p preset : same as in ffmpeg
		-t time : only convert the firts 'time' minutes
		"
		exit 0
	elif	[ "$1" == "-i" ]
	then
		inputfile=$2
		shift
	elif	[ "$1" == "-p" ]
	then
		if [[ ! "ultrafast.veryfast.fast.medium.slow.veryslow.ultraslow" == *"$2"* ]]
		then
			echo " * WARNING : Preset not found, ignored"
		else
			p=$2
		fi
		shift
	elif	[ "$1" == "-t" ]
	then
		if [[ "$2" =~ [0-9]+ ]]
		then
			t="-t $2:00"
		else
			echo " * WARNING : incorrect time entered, ignoring argument"
		fi
		shift
	else
		if  [ -f "$(pwd)/$1" ]
		then 
			inputfile=$1
		fi
	fi
	shift
done

if [[ $p == "" ]]
then
	p=medium
fi

# CHECKING INPUTFILE
if [ "$inputfile" == '' ]
then
	echo " * ERROR : Missing argument : specify inputfile"
	exit 1
else
	if [ ! -f "$(pwd)/$inputfile" ]
	then
		echo " * ERROR : $inputfile : no such file"
		exit 1
	fi
fi

#finding out output filename
	o=$(echo $inputfile |rev| cut -d. -f2- | rev )
	if [[ $o == *"264"* ]]
	then
		o="$(echo $o | sed 's/264/265/')"
	else
		o=$o.libx265
	fi
	o=$o.mkv

echo " * Converting file to $o"

ffmpeg -i "$inputfile" $t -c:a aac -b:a 128k -c:v libx265 -preset $p "$o"