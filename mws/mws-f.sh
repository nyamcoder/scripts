#!/bin/bash
#
#       mws-f.sh by nyamcoder :: mito{XD}  2015
#
###  A(nother) basic dzen2 script for displaying weather info.
#
#       What you find here:
#
#       * Temperatures in Fahrenheit scale. -- Since there’s no "°F" grepping without JavaScript at openweathermap.org (OMW),
#		using the US national services of noaa.gov (NOAA) and weather.gov (NWs)
#	* the cases for New York City and Austin
#	* alternative layout
#	* adapted NWS icons
#	* an alternative way to deal with multiple dzen instances (experimental!)
#
#
#       *** Use this script at your own risk! ***
#
#
#       *** Consulting the dzen2 documentation material is indispensable! ***
#               - http://dzen.googlecode.com/svn/trunk/README
#               - https://github.com/robm/dzen/wiki/_pages
#
#
#       *** You will have to edit the paths to your needs, and chmod +x the script before running! ***
#
#
#       *** I am not going to provide any icons for this scripts. You're encouraged to download
#                                                       and process them manually, see below. ***
#
#       *** Dependencies ***
#               - bash, wget, tr, (g)awk, sed, imagemagick6
#
#
#       * License: CC BY-NC-SA
#               - https://creativecommons.org/licenses/
#               - Feel free to adopt and match the script to your style and language.
#               - No commercial use allowed.
#               - For questions or suggestions send a mail to < info AT mito-space DOT com >
#
#
#       * This is only one of the collection "mito's Wx Scripts".
#               - Find more at:  https://github.com/nyamcoder/scripts/mws
#


while [ "true" ]
   do



city1=NYC
city1col="^fg(#eee8d5)"
city2=Austin
city2col="^fg(#eee8d5)"




# 1: New York City, Manhattan/Central Park (KNYC), NY, USA

wservice1="http://w1.weather.gov/xml/current_obs/KNYC.xml"

###	Cross-service double-checking of weather stations (may require active JS)
#
#	* NYC, Central Park by OWM:  http://openweathermap.org/city/5125771
#	* http://forecast.weather.gov/MapClick.php?lat=40.78333&lon=-73.96667
#		\-->  http://w1.weather.gov/obhistory/KNYC.html  (table)
#	* http://w1.weather.gov/xml/current_obs/seek.php?state=ny&Find=Find (NY state)
#		\--> "New York City, Central Park (KNYC)": http://w1.weather.gov/xml/current_obs/display.php?stid=KNYC
#		 \-> XML:  http://w1.weather.gov/xml/current_obs/KNYC.xml


# 2: Austin City, Austin Camp Mabry (KATT), TX, USA

wservice2="http://w1.weather.gov/xml/current_obs/KATT.xml"


###	Air Temperatures
#
temp1=$(wget -q ${wservice1} -NO /tmp/knyc; cat -A /tmp/knyc| grep temp_f | awk '{sub(/>/, "<"); split($0,a,"<"); print a[3]}'| tr -d '.0')
# \-->	A method to isolate a substring by awk, which replaces the ">" character of the XML tags by "<" and then printing the 3rd element.
#  \->	cat -A option to reveal also meta-characters this file includes

temp2=$(wget -q ${wservice2} -NO /tmp/katt; cat -A /tmp/katt| grep temp_f | awk '{sub(/>/, "<"); split($0,a,"<"); print a[3]}'| tr -d '.0')

# As all NOAA °F values seem to end ".0" there’s no need for bc. This can simply be chopped by tr; otherwise there'll be syntax errors.


# arbitrary temperature colors
arctic="#6a5acd"
frosty="#00bfff"
cold="#add8e6"
chilly="#61e296"
#moderate="#a3c639"
#moderate="#83d688"
moderate="#83c088"
lukewarm="#b5cd62"
warm="#ffd700"
hot="#ffa000"
#hot="#ff5800"
tropic="#e93423"
meltinghot="#ff2222"


gettcol1() {
   if   [[ "$temp1" -le -5 ]] ; then
      temp1col="^fg($arctic)"
   elif [[ "$temp1" -le 29 ]] ; then
      temp1col="^fg($frosty)"
   elif [[ "$temp1" -le 39 ]] ; then
      temp1col="^fg($cold)"
   elif [[ "$temp1" -le 49 ]] ; then
      temp1col="^fg($chilly)"
   elif [[ "$temp1" -le 59 ]] ; then
      temp1col="^fg($moderate)"
   elif [[ "$temp1" -le 74 ]] ; then
      temp1col="^fg($lukewarm)"
   elif [[ "$temp1" -le 84 ]] ; then  
      temp1col="^fg($warm)"
   elif [[ "$temp1" -le 94 ]] ; then
      temp1col="^fg($hot)"
   elif [[ "$temp1" -le 99 ]] ; then  
      temp1col="^fg($tropic)"
   elif [[ "$temp1" -gt 99 ]] ; then
      temp1col="^fg($meltinghot)"
   else
      temp1col="^fg()"
   fi
   } ; gettcol1

gettcol2() {
   if   [[ "$temp2" -le -5 ]] ; then
      temp2col="^fg($arctic)"
   elif [[ "$temp2" -le 29 ]] ; then
      temp2col="^fg($frosty)"
   elif [[ "$temp2" -le 39 ]] ; then
      temp2col="^fg($cold)"
   elif [[ "$temp2" -le 49 ]] ; then
      temp2col="^fg($chilly)"
   elif [[ "$temp2" -le 59 ]] ; then
      temp2col="^fg($moderate)"
   elif [[ "$temp2" -le 74 ]] ; then 
      temp2col="^fg($lukewarm)"
   elif [[ "$temp2" -le 84 ]] ; then  
      temp2col="^fg($warm)"
   elif [[ "$temp2" -le 94 ]] ; then
      temp2col="^fg($hot)"
   elif [[ "$temp2" -le 99 ]] ; then  
      temp2col="^fg($tropic)"
   elif [[ "$temp2" -gt 99 ]] ; then
      temp2col="^fg($meltinghot)"
   else
      temp2col="^fg()"
   fi
   } ; gettcol2





###	Sky Conditions
#
con1=$(wget -q ${wservice1} -NO /tmp/knyc; cat /tmp/knyc | grep icon_url_name | sed -e 's/<[^>]*>//g'| sed -e 's/.png//')

con2=$(wget -q ${wservice2} -NO /tmp/katt; cat /tmp/katt | grep icon_url_name | sed -e 's/<[^>]*>//g'| sed -e 's/.png//')

# \--->	"New Forecast-at-a-Glance icons":  http://www.weather.gov/forecast-icons
#  \--> There seems to be no downloadable icon set, so fetch them manually.
#   \->	All PNG have to be scaled and converted to XPM format.


iconpath="/path/to/my/noaa-icons/XPM/"

#geticon1() {
   if     [[ -z "${con1}" ]] ; then # in case for whatever reason there’s no icon ...
      sky1="n/a"                    # ... print this string in default color
   else
      sky1=$(printf "^i(${iconpath}${con1}.xpm)"|tr -d '\t') # select one of the mirrored icons in all other cases
   fi
#   }
#geticon1


#geticon2() {
   if     [[ -z "${con2}" ]] ; then
      sky2="n/a"
   else
      sky2=$(printf "^i(${iconpath}${con2}.xpm)"|tr -d '\t')
   fi
#   }
#geticon2



###	Putting it all together:
#
weatherskies="${sky1} ${sky2}"

echo "${weatherskies}" |dzen2 -h 68 -w 258 -x 372 -y 426 -p & echo $! > /tmp/dzen-skies
sleep 0.3  # attempting to prevent accidental ${weatherskies} hiding the other elements
echo -e "${city1col}${city1}\n${temp1col}${temp1}^fg(#93a1a1) °F" |dzen2 -h 30 -w 62 -x 376 -y 430 -l 1 -sa c -e 'onstart=uncollapse,unhide' -bg black -p & echo $! > /tmp/dzen-city1
echo -e "${city2col}${city2}\n${temp2col}${temp2}^fg(#93a1a1) °F" |dzen2 -h 30 -w 62 -x 564 -y 430 -l 1 -sa c -e 'onstart=uncollapse,unhide' -bg black -p & echo $! > /tmp/dzen-city2
sleep 100

###	Further actions to prevent countless starting of bars:
#
kill -9 $(cat /tmp/dzen-skies); wait $(cat /tmp/dzen-skies) 2>/dev/null
kill -9 $(cat /tmp/dzen-city1); wait $(cat /tmp/dzen-city1) 2>/dev/null
kill -9 $(cat /tmp/dzen-city2); wait $(cat /tmp/dzen-city2) 2>/dev/null



done






*** Notes ***

* Invoke the script like so:

$ sh ~/scripts/mws/mws-f.sh &


* This script is experimental! IMO calling several independent piped dzen instances "in-line" is deprecated,
	since it’s causing flicker while reloading!
	For advanced overlay positioning and drawing techniques see the other script ./mws-y.sh or
	consult the Dzen wiki. However properly overlaying centered stuff with varying size (due to changing data)
	is nearly impossible.

* Since this minimal bar is meant to be set at the top or the bottom of the screen, match dzen’s x- and y-coordinates
	accordingly.


* Anyway this commands might be of help:

# For testing purposes in an X terminal, it’s useful echoing the background PID of the running script as well like so:
$ sh ~/scripts/mws/mws-f.sh & ; echo $! > /tmp/sh-mwsf
 
# Because if working on another term, (as shown before) this makes killing this process pretty easy, if necessary:
$ kill -9 $(cat /tmp/sh-mwsf)

# or (to first kill the old PID before creating the new):
$ kill -9 $(cat /tmp/sh-mwsf) ; sh ~/scripts/mws/mws-f.sh & ; echo $! > /tmp/sh-mwsf

# Killing the background PID might require to kill the remaining dzen instances explicitely though:
$ kill -9 $(cat /tmp/dzen*)

# From the X terminal the script was started, it can be terminated much faster by entering
$ jobs
[1]+  Running                  sh mws-f.sh &
$ kill %1


### EOF ###
