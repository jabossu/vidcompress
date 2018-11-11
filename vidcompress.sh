#! /bin/bash

# Starting variables
autoremove=false
forceconvertion=false
simulate_only=false

# READING OPTIONS
while [ "$1" != '' ]
do
	if	[ "$1" == "-h" ]
	then
		echo "SYNTAX : vidcompress [OPTIONS] [-i] inputfile
You can use the following options :
	-h 		: this help.
	-i INPUTFILE	: the -i argument can be omitted. You have to provide the filename.
	-p PRESET 	: same presets as in ffmpeg.
	-r		: auto remove INPUTFILE when re-encoding is done
	-t MM:SS	: Only convert the first MM:SS 
			  Usefull for testing everything works fine.
	-f		: Force conversion of every file, even if
			  the finame contains '265'
	-s		: Simulates : only prints what would be done
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
		if [[ "$2" =~ ^([0-9]{1,2}:)?[0-9]{2}$ ]]
		then
			t="-t $2"
		else
			echo " * WARNING : incorrect time entered, ignoring argument"
		fi
		shift
	
	elif	[ "$1" == '-r' ]
	then
		autoremove=true
	
	elif	[[ $1 == '-f' ]]
	then
		forceconvertion=true
	
	elif	[[ $1 == '-s' ]]
	then
		simulate_only=true	
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

if [[ "$inputfile" =~ *264* ]] && [[ $forceconvertion == false ]]
then
	echo " * ERROR : Filename contains a reference to the x265 codec. This file will be skipped. Use '-f' to force conversion."
	exit 1
fi

#finding out output filename
	o=$(echo $inputfile |rev| cut -d. -f2- | rev )
	if [[ $o == *"264"* ]]
	then
		o="$(echo $o | sed -r 's/(.*)264/\1265/')"
	else
		o=$o.libx265
	fi
	o=$o.mkv

echo " * Converting file to $o"

if [[ $simulate_only == true ]]
then
	echo "ffmpeg -i $inputfile $t -ca aac -ba 128k -c:v libx265 -preset $p $o"
else
	ffmpeg -hide_banner -loglevel error -stats -i "$inputfile" $t -c:a aac -b:a 128k -c:v libx265 -x265-params log-level=error -preset $p "$o" && $autoremove && rm $inputfile
fi
