#!/bin/bash
#
#	mws.sh by nyamcoder :: mito{XD}  2015
#
###  A (relatively) simple dzen2 script for displaying weather info in a (Linux) desktop bar.
#
#	What you find here:
#
#	* a neat layout displaying weather info for two locations, containing names, temperature, and sky condition
#	* a basic XPM icon set ready to use
#	* easily configurable, customizable, and extendable

#
#	*** Use this script at your own risk! ***
#
#
#	*** Consulting the dzen2 documentation material is indispensable! ***
#		- http://dzen.googlecode.com/svn/trunk/README
#		- https://github.com/robm/dzen/wiki/_pages
#
#
#	*** You will have to edit the paths to your needs, and chmod +x the script before running! ***
#
#
#	*** I am not going to provide any icons for this scripts. You're encouraged to download
#						and process them manually, see below. ***
#
#       *** Dependencies ***
#		- bash, w3m, bc, tr, (g)awk, sed
#
#
#	* This is the most basic one from the collection "mito's Wx Scripts".
#		- Find the others at:  https://github.com/nyamcoder/scripts/mws
#
#
#	* License: CC BY-NC-SA
#		- https://creativecommons.org/licenses/
#		- Feel free to adopt and match the script your style.
#		- No commercial use allowed.
#		- For questions or suggestions send a mail to < info AT mito-space DOT com >
#
#
#	* CREDITS go to:
#		- Robert Manea and his team for the awesome Dzen2 tool
#		- openweathermap.org (OWM) for their weather service and icons



while [ "true" ]
   do


###	Place Name Formatting
#
city1=X
city1col="^fg(#eee8d5)"
city2=Y
city2col="^fg(#eee8d5)"


###	Weather Service Settings
#
#	* extracting the temperature at $city1:
traw1=$(w3m http://openweathermap.org/city/XXXXXXX|grep -m 2 °C| awk '{print $2}'|tr -d '°C \n')

#	* extracting the temperature at $city2:
traw2=$(w3m http://openweathermap.org/city/YYYYYYY|grep -m 2 °C| awk '{print $2}'|tr -d '°C \n')
#		\
#		 \-> please complete the urls yourself!


###	Local Air Temperature Calculation
#
#	* rounding floating numbers to their nearest integers
#	* I figured out this method, but there are others as well; the usage of bc is mandatory!
#
#gettemp1() {
if (( $(bc <<< "${traw1}>=0") )) ; then
temp1=$(echo "(${traw1} + 0.5)/1" | bc )
elif (( $(bc <<< "${traw1}<0") )) ; then
temp1=$(echo "(${traw1} - 0.5)/1" | bc )
else
temp1="^fg()n/a"
fi
#}; gettemp1


#gettemp2() {
if (( $(bc <<< "${traw2}>=0") )) ; then
temp2=$(echo "(${traw2} + 0.5)/1" | bc )
elif (( $(bc <<< "${traw2}<0") )) ; then
temp2=$(echo "(${traw2} - 0.5)/1" | bc )
else
temp2="^fg()n/a"
fi
#}; gettemp2


###	Arbitrary Temperature Colors
#
arctic="#6a5acd"
frosty="#00bfff"
cold="#add8e6"
chilly="#61e296"
moderate="#83d688"	# "#a3c639"
lukewarm="#b5cd62"
warm="#ffd700"
hot="#ffa000"		# "#ff5800"
tropic="#e93423"
meltinghot="#ff2222"


###	Temperature Value Coloring
#
#gettcol1() {
   if   [[ "$temp1" -le -20 ]] ; then
      temp1col="^fg($arctic)"
   elif [[ "$temp1" -le 0 ]] ; then
      temp1col="^fg($frosty)"
   elif [[ "$temp1" -le 4 ]] ; then
      temp1col="^fg($cold)"
   elif [[ "$temp1" -le 10 ]] ; then
      temp1col="^fg($chilly)"
   elif [[ "$temp1" -le 16 ]] ; then
      temp1col="^fg($moderate)"
   elif [[ "$temp1" -le 23 ]] ; then
      temp1col="^fg($lukewarm)"
   elif [[ "$temp1" -le 29 ]] ; then  
      temp1col="^fg($warm)"
   elif [[ "$temp1" -le 34 ]] ; then
      temp1col="^fg($hot)"
   elif [[ "$temp1" -le 39 ]] ; then  
      temp1col="^fg($tropic)"
   elif [[ "$temp1" -gt 39 ]] ; then
      temp1col="^fg($meltinghot)"
   else
      temp1col="^fg()"
   fi
#}; gettcol1


#gettcol2() {
   if   [[ "$temp2" -le -20 ]] ; then
      temp2col="^fg($arctic)"
   elif [[ "$temp2" -le 0 ]] ; then
      temp2col="^fg($frosty)"
   elif [[ "$temp2" -le 4 ]] ; then
      temp2col="^fg($cold)"
   elif [[ "$temp2" -le 10 ]] ; then
      temp2col="^fg($chilly)"
   elif [[ "$temp2" -le 18 ]] ; then
      temp2col="^fg($moderate)"
   elif [[ "$temp2" -le 23 ]] ; then 
      temp2col="^fg($lukewarm)"
   elif [[ "$temp2" -le 29 ]] ; then  
      temp2col="^fg($warm)"
   elif [[ "$temp2" -le 34 ]] ; then
      temp2col="^fg($hot)"
   elif [[ "$temp2" -le 39 ]] ; then  
      temp2col="^fg($tropic)"
   elif [[ "$temp2" -gt 39 ]] ; then
      temp2col="^fg($meltinghot)"
   else
      temp2col="^fg()"
   fi
#}; gettcol2


###	Sky Conditions
#
#	* icon display
#	* Note, that dzen requires the icons to be in XBM or XPM format! Hence these must be converted.
#	* regarding text browsers:
#		- w3m because elinks doesn't show image file names (by default)
#		- lynx (pref. with -accept_all_cookies) does, but changes the prompt color, doesn't exit itself
#			and doesn't dump correctly
#	* An IMO more elegant way would be to download the websites and to parse them locally. See the
#		other scripts on how to do this.

condition1=$(w3m http://openweathermap.org/city/XXXXXXX|grep °C|tr '[' ']'|awk -F] '{print $2}'|tr -d "\n\r")

condition2=$(w3m http://openweathermap.org/city/YYYYYYY|grep °C|tr '[' ']'|awk -F] '{print $2}'|tr -d "\n\r")
#		 eridicates (Windows) newlines, tabs, and square brackets  <--/

#	* icon parsing:
#geticon1() {
   if     [[ -z "$condition1" ]] ; then    # in case for whatever reason there’s no icon ...
      sky1="^fg()n/a"                      # ... print this string in default color
   elif   [[ "$condition1" =~ 50 ]] ; then # parse for the foggy icon marker; note this is for both night and day
      sky1="^i(./icons/foggy-gray.xpm)"    # select the icon manually due to your bg-color
   else
      sky1="^i(./icons/${condition1}.xpm)" # select one of the mirrored icons in all other cases
   fi
   wait
#}; geticon1

 
#geticon2() {
   if     [[ -z "$condition2" ]] ; then
      sky2="^fg()n/a"
   elif   [[ "$condition2" =~ 50 ]] ; then
      sky2="^i(./icons/foggy-gray.xpm)"
   else
      sky2="^i(./icons/${condition2}.xpm)"
   fi
   wait
#}; geticon2



###	Putting it all together:
#
weather1="${city1col}${city1}${temp1col}${temp1}^fg(#93a1a1)°C${sky1}"
weather2="${city2col}${city2}${temp2col}${temp2}^fg(#93a1a1)°C${sky2}"


echo "${weather1} ${weather2}"
   sleep 600	# update interval in seconds
#  sleep 2220	# 37 minutes for something not too regular ;)
done



***	Invoke the script simply manually like so:

$ sh /path/to/my/mws.sh | dzen2 -p&

***	However this bar is designed to be put at the top or the bottom of the screen. So you need to
		explicitely set the x-/y-coordinates for dzen!

***	You might also want to adjust the default font, as well as the coloring. See the Dzen wiki for
		all options:
			https://github.com/robm/dzen/wiki

***	Put the complete command including all options into your startup scripts for desktop integration.

		Have fun!



### EOF ###
