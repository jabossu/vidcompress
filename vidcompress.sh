#! /bin/bash

version=1.9.2

# Starting variables
autoremove=false
forceconvertion=false
simulate_only=false
loglevel=quiet
priority=10
preset=fast
configfile="$HOME/.config/vidcompress.conf"
resize=false 

[[ -f $configfile ]] && source $configfile || echo "# Vidcompress config file" > $configfile 2>/dev/null

# Output formating
boldtxt=$(tput bold)
normtxt=$(tput sgr0)
undetxt=$(tput smul)

# Welcoming user
echo -e "\nVidcompress $version"

# READING OPTIONS
while [ "$1" != '' ]
do
	if	[ "$1" == "-h" ]
	then
		echo "SYNTAX : vidcompress [OPTIONS] [-i] inputfile
You can use the following options :
	-h 		: this help.
	-i INPUTFILE	: the -i argument can be omitted. You have to provide the filename.
	-n NICEVALUE	: set the priority of the ffmpeg process. Default : 10
	-p PRESET 	: same presets as in ffmpeg.
	-r		: auto remove INPUTFILE when re-encoding is done
	-rz 720 / 1080	: resize file to target resolution
	-t MM:SS	: Only convert the first MM:SS 
			  Usefull for testing everything works fine.
	-f		: Force conversion of every file, even if
			  the finame contains '265'
	-s		: Simulates : only prints what would be done
	-v		: Enable verbose output
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
			preset=$2
		fi
		shift
	elif	[ "$1" == "-t" ]
	then
		if [[ "$2" =~ ^([0-9]{1,2}:)?[0-9]{2}$ ]]
		then
			t="-t $2"
			duration=$2
		else
			echo " * WARNING : incorrect time entered, ignoring argument"
		fi
		shift
	
	elif	[ "$1" == '-r' ]
	then
		autoremove=true

	elif 	[[ "$1" == '-rz' ]]
	then
		if [[ "$2" =~ ^(720|1080)$ ]]
		then
			resize=$2
		else
			echo " * Resolution $2 not supported, ignoring parameter"
		fi
		shift

	elif	[ "$1" == '-n' ]
	then
		if [[ "$2" =~ ^[1-9]{1,2}$ ]]
		then
			priority=$2
		fi
		shift

	elif	[ "$1" == '-v' ]
	then
		loglevel=info

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

input_filesize="$(du -h "$inputfile" | cut -f1)"

if [[ "$inputfile" =~ "265" ]] && [[ $forceconvertion == false ]]

then
	echo " * ERROR : Filename contains a reference to the x265 codec. This file will be skipped. Use '-f' to force conversion."
	exit 1
fi

#finding out output filename
	title_264=$(echo $inputfile |rev| cut -d. -f2- | rev )
	if [[ $title_264 =~ 264 ]]
	then
		title_265="$(echo $title_264 | sed -r 's/(.*)264/\1265/')"
	else
		title_265=$title_264.libx265
		if [[ $autoremove == true ]]
		then
			echo " * Input filename doesn't countain 264 keyword. Autremove disabled"
			autoremove=false
		fi
	fi
	o=$title_265.mkv


#Finding out duration of the video to convert
if [[ $duration ==  "" ]] # If -t was given, $duration already contains the time to convert, so we skip this step
then
	duration=$(ffprobe "$inputfile" 2>&1 | grep Duration | head -n 1 | cut -d " " -f 4 | cut -d "." -f 1)
fi

# Creating the command parameter if user wants to resize video
if [[ $resize != false ]]
then
	param_resize="-vf scale=-2:$resize"
else
	param_resize=""
fi


## Finally starting working for real.

echo -e " * Converting file to\t${undetxt}$o${normtxt}"
echo -e " * Video duration :\t$duration"
echo -e " * Chosen preset :\t$preset"
$autoremove && echo -e " * Autoremove :\t\tEnabled"
[[ "$resize" ]]  && echo -e " * Target resolution :\t$resize p"

if [[ $simulate_only == true ]]
then
	echo "ffmpeg -i $inputfile $t -ca aac -ba 128k -c:v libx265 $param_resize -preset $preset $o"
else
	nice -n "$priority" \
	ffmpeg -hide_banner -loglevel "$loglevel" -stats \
		-i "$inputfile" $t \
		-metadata title="$title" \
		-c:a aac -b:a 128k \
		-c:v libx265 -x265-params log-level=error \
		$param_resize \
		-preset $preset \
		"$o" \
	&& isok=true || exit 1
	$isok && $autoremove && rm -r "$title_264"* && echo " * Removing source file and associated files"
	output_filesize="$(du -h "$o" | cut -f1)"
	echo -e " * Reduced filesize from ${boldtext}$input_filesize${normtext} to ${boldtext}$output_filesize${normtext}"
	echo " " #newline
fi

#echo "Exiting. Goodbye"
