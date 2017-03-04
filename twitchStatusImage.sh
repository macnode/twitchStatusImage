#!/bin/bash

########################################
####        twitchOnOff v3.7        ####
####  Get stream info from Twitch   ####
####    Write image with results    ####
#### 	  the100:  /u/L0r3          ####
####      Reddit:  /u/L0r3_Titan    ####
####      Twitter: @L0r3_Titan      ####
########################################

clear; echo

### FIND CURRENT DIRECTORY AND LINK DEPENDENCIES ####
#currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#source "$currentDir"'/apiKeys.sh'
authKeyTwitch='xxxxxxxxxxxxxxxxxxxxxxxxx'


### TWITCH USERS (streamName,displayName) ###
twitchList="avengerspec2id,AvengerSpec2ID \
deadlycranefly,DeadlyCraneFly \
f4cekill3r,Crispycrits \
fearbroner,FearBroner \
kupe81,Kupe81 \
l0r3_titan,L0r3 \
mad_mux,MadMux \
menacingmommy,MenacingMommy \
mungtacular,Vegetabless \
phdshenanigans,PhDShenanigans \
odinsfuryz,OdinsFuryz \
riotspyne,RiotSpyne \
wookie_approved,WookieApproved \
bungie,Bungie"


### PUT TWITCH STREAMERS INTO ARRAY ###
oIFS="$IFS"; IFS=' '
twitchArray=($twitchList)
IFS="$oIFS"

liveList='Clan EPIC Streamer Status:'

###  ###
funcTwitchInfo ()
{	
	#### EXTRACT STREAMER NAME AND DISPLAY NAME ####
	streamName=`echo $twitchStreamer | sed 's/,.*[^,]*//'`
	displayName=`echo $twitchStreamer | rev | sed 's/,.*[^,]*//' | rev`
	#echo "streamName:$streamName displayName:$displayName"
	#### GET USERS CURRENT STREAM INFO ##
	getTwitch=`curl -s -X GET \
	-H "Accept: application/vnd.twitchtv.v3+json" \
	-H "Client-ID: $authKeyTwitch" \
	"https://api.twitch.tv/kraken/streams/$streamName"`
	niceTwitch=`echo "$getTwitch" | python -mjson.tool`
	#echo "$niceTwitch"
	#### DETERMINE IF USER IS LIVE ####
	liveStatus=`echo "$niceTwitch" | grep -o 'stream".*' | cut -c 10-`
	#echo "liveStatus: $liveStatus"
	if [ "$liveStatus" == null ]
	then
		echo "$streamName is offline"
		twitchStatus='Offline'
		onFont='Dimitri'
		onColor='white'
		liveList="$liveList\n$displayName is offline"
	else
		echo "$streamName is live"
		twitchStatus='** LIVE! **'
		onFont='Dimitri'
		onColor='orange'
		liveList="$liveList\n$displayName is live at https://www.twitch.tv/$streamName"
	fi
}


funcTwitchImage ()
{
	convert \
	-size 210x29 \
	-background transparent \
	-border 0x0 \
	-bordercolor transparent \
	-gravity northwest \
	-font "Roboto-Medium" -pointsize 16 -weight 600 -gravity northwest -page +0+0 -fill yellow label:"$displayName:" \
	-font "$onFont" -pointsize 16 -weight 600 -gravity northwest -page +135+5 -fill "$onColor" label:"$twitchStatus" \
	-flatten \
	/srv/www/vhosts/destinygrinder/clan/epic/liveData/twitchStatus/$streamName.png
}


### LOOP THOUGH TWITCH STREAMER LIST ###
for twitchStreamer in "${twitchArray[@]}"
do
	funcTwitchInfo
	funcTwitchImage
done


echo""; echo "$liveList"
echo -e "$liveList" > '/srv/www/vhosts/destinygrinder/clan/epic/liveData/twitchStatus/twitchStatus.txt'


exit
