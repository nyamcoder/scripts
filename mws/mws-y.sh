#!/bin/bash
#
# 	mws-y.sh by nyamcoder :: mito{XD}
#
###  A multifunctional dzen2 script for displaying weather info in a (Linux) desktop bar.
#
#	What you find here:
#
#	* a detailed single view for the city of Busan, Korea
#	* Koreanized UTF-8 output (subject to changes)
#	* multi-line output
#	* multiple images
#	* XPM icon generation on the fly
#	* multiple online weather resources usage
#	* custom fonts
#	* custom colors, based on Solarized (Dark)
#	* optional time and date
#	* optional webcam widget
#	* extensive exemplary shell coding for self teaching ...
#	* ... such as how to localize stuff
#
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
#							and process them manually, see below. ***
#
#	*** Dependencies ***
#		- bash, wget, bc, tr, (g)awk, sed, imagemagick6, Un fonts
#
#
#	* This is only one from the collection "mito's Wx Scripts".
#		- Find the others at:  https://github.com/nyamcoder/scripts/mws
#
#	* To do:
#		- some extra clickability
#		- some better anti-aliasing on the icons  and/or
#		- interactions with other (graphic) apps like feh
#
#	* License: CC BY-NC-SA
#		- https://creativecommons.org/licenses/
#		- Feel free to adopt and match the script to your style and language.
#		- No commercial use allowed.
#		- For questions or suggestions send a mail to < info AT mito-space DOT com >
#
#	* CREDITS go to:
#		- Robert Manea and his team for the awesome Dzen2 tool
#		- Yr / yr.no, noaa.gov, and kma.go.kr national and international weather services
#		- webcams.travel user "zhongxi", see the other script  ./mws-ycam.sh
#		- Ethan Schoonover for his Solarized palette:  http://ethanschoonover.com/solarized



###	(1) Global Settings
#
#	* Adhere Dzen2 syntax!

#	1a) Font Definitions
#
#	* There're three common locations for dzen (Xft) font settings:
#		 i.  as command line option
#		ii.  in ~/.Xresources
#		iii. in a script like this,
#		where starting option overwrites .Xresources, and a script command the command-line options.

dfnt0="^fn(UnDotum-14)"	# default
dfnt1="^fn(UnDotum-14:bold)"
dfnt2="^fn(UnDotum-10)"
dfnt3="^fn(UnDotum-12)"


#	1b) Color Settings
#
#	* Dzen2 color setting locations are the same as for the fonts.
#	* Solarized (Dark) RGB hex-values in the following
#	* Like for the fonts, if the values here differ from the pre-defined ones, colors at the beginning
#		of a title/slave window line only work for text and other fg objects. So extra command-line
#		might be necessary.

fg0="^fg(#eee8d5)"	# S_base2, default
fg1="^fg(#b58900)"	# S_yellow
fg2="^fg(#93a1a1)"	# S_base1
fg3="^fg(#002b36)"	# S_base03

#bg0="^bg(#002b36)"	# S_base03, default (stated on cmd line)


### the main routine for date and weather processing starts here!

while [ "true" ]	# invoking an endless loop
   do


let "counter+=1"  	# incrementing the counter of script cycles; important when the script also runs a clock


### number of script cycles (reached by $counter) for retrieving new weather data
#
weatherupdate=1
#	\-> To be manually adjusted with care. "1" means the 1st (and not every) cycle. -- Note that this
#		corresponds with the sleep time (in seconds) at the end of the script! And it does not make sense
#		to set an estimated value less than a weather service site updates its data (what can in fact be found
#		out only by testing; seems to be more often than the site says).


###	(2) Module "Location"
#
# 	2a) Location Name
#
#	* formatted text string, here representing Busan Metropolitan City  부산광역시 釜山廣域市, ROK 
#	* yr.no Busan weather station coordinates: 35°06′10″N 129°02′25″E
#	* There seem to be no other valid ones at Yr.

city="${fg1}부산^fg()"

#	2b) Local Time and Day / 날짜
#
#	* yr.no, XML: <timezone id="Asia/Seoul" utcoffsetMinutes="540"/>  KST = UTC +9h 

citydt=`TZ='Asia/Seoul' LC_TIME=ko_KR.UTF-8 date '+%R %Z  %-d (%a)'` 
#	\--> displaying 24 hr. time, time zone, day of the month, and day of the week
#	 \-> Though it's interesting to noticing time shifts, this might or might not be a usable clock,
#		since it's only updated after "sleep" time. And the shorter the sleeping, the more often dzen redraws,
#		and the heavier the system load. -- Anyway the date parameter %T only makes sense to keep this clock
#		synchronous to the system (i.e. sleep=1), otherwise leave it %R.


#	2c) Definiton of Weather Services
#
wservice1="http://www.yr.no/place/South_Korea/Busan/Busan/hour_by_hour.html" 
#		\--> needed for the wind icons
#		 \-> 3hr periods; at least some values get updated hourly though

 
wservice2="http://www.yr.no/place/South_Korea/Busan/Busan/forecast_hour_by_hour.xml"
#		\--> link to be found in the header of http://www.yr.no/place/South_Korea/Busan/Busan/forecast.xml
#		 \-> XML version of $wservice1


#	* alternative link to Gimhae Intl. Airport, ICAO "RKPK"
wservice3="http://weather.noaa.gov/weather/current/RKPK.html"
#		\---> for present time hourly temperature and humidity (yr.no misses the latter)
#		 \--> If you still want Yr's temperature, edit the air temperature section.
#		  \-> FYI: yr.no also provides a link to that place:
#	http://www.yr.no/place/South_Korea/Other/Pusan_%C2%A4002f_Kimhae_International_Airport/hour_by_hour.html
#
#	* Note, temperatures and climate of airports in the vicinities often differ from those in the cities.
#


###	(3) Module "Sky Condition" / 하늘 상태  --狀態
#

if [ ${counter} == 1 ]		### beginning of $counter condition for script executions
then

#	3a) Sky Condition Icons
#
#	* official Yr weather icon collection download link:  http://om.yr.no/sym.zip
#		\---> While this is a comprehensive collection (e.g. allowing for the moon phases), other icons
#		 \	are still missing, see below.
#		  \-> Note all the images need to be converted into XPM before dzen2 usage. Consider ImageMagick's
#			"convert" or "mogrify" macros managing this topic. Find an intro here:
#				http://www.imagemagick.org/Usage/basics/#im_commands


#	* determining the current icon name
#
con=$(wget -q ${wservice2} -NO /tmp/busan2; cat /tmp/busan2 \
| grep -m 1 symbol\ number | awk -F\" '{print $8}')
#	\-> Note that this output also possibly includes the mf/ subfolder.


#	* selection from the downloaded and converted XPM icon set (size 30x30px)
#
skyiconpath="/my/icon/folder/path/to/XPM/" # new folder "XPM/", where the complete converted icon set (sym.zip) resides
skyicon="^i(${skyiconpath}${con}.xpm)"
#	\-> And that's a (little) drawback of dzen's, that it displays only XBM and XPM bitmap icons.
#		Because of the small color palette there's a quality loss, and the former PNGs now often appear jaggy.
#		IM6 also provides macros for adding some blur or shadow to soften this effect a bit, like so:
#			$ convert /my/png/path/my.png -channel RGBA -blur 0x.6 \
#			  \( +clone -background '#93a1a1' -shadow 80x0+1+1 \)\
#			  -background none -compose DstOver -flatten /my/xpm/path/my.xpm
#		However this remains a tricky topic. You might want to read this article: 
#				http://www.imagemagick.org/Usage/blur/


#	3b) Sky Condition Localization
#
#	* in this case into Korean
#	* Mind the upper and lower case spelling, as well as masking whitespace (or using double quotes)!

conEN=$(wget -q ${wservice2} -NO /tmp/busan2; cat /tmp/busan2 \
| grep -m 1 symbol\ number | awk -F\" '{print $6}')

case "${conEN}" in
	Clear\ sky)
		conKO="맑음";;
	Fair)
		conKO="구름조금";;
	Partly\ cloudy)
		conKO="구름많음";;		# cf. 부분 흐림
	Cloudy)
		conKO="흐림";;			# cf. overcast

	Rain)
		conKO="비";;			# 흐리고 비; cf. 강우 降雨
	Rain\ showers)	
		conKO="소나기";;		# 구름많고 가끔 비; cf. 소나기, 대우 大雨, 비, 백우 白雨, 여우비, 가끔 비
	Rain\ and\ thunder)	
		conKO="비와 천둥";;		# cf. 비와 번개
	Rain\ showers\ and\ thunder)	
		conKO="소나기와 천둥";;

	Light\ rain)	
		conKO="가랑비";;		# 흐리고 약한 비; cf. 가랑비, 보슬비, 이슬비, 약한 비, 가벼운 비, 소우 小雨, 보지락
	Light\ rain\ showers)	
		conKO="여우비";;		# 구름많고 여우비
	Light\ rain\ and\ thunder)	
		conKO="소우와 천둥";;
	Light\ rain\ showers\ and\ thunder)	
		conKO="여우비와 천둥";;		# ... ; cf. 천둥, 우레

	Heavy\ rain)	
		conKO="큰비";;			# cf. 세찬비, 호우 豪雨, 폭우 暴雨, 장대비, 심한 비, 심한 강우, 들어붓는 비
	Heavy\ rain\ showers)	
		conKO="가끔 폭우";;		# 구름많고 큰비; cf. 장대비, 가끔 큰비
	Heavy\ rain\ and\ thunder)	
		conKO="폭우와 천둥";;		# cf. 
	Heavy\ rain\ showers\ and\ thunder)	
		conKO="^p(;2)${dfnt2}가끔 폭우와 천둥^p(0;-2)";;

	Sleet)	
		conKO="진눈깨비";;		# cf. 진눈깨비, 싸라기눈, 눈비, 우빙 雨氷
	Sleet\ showers)	
		conKO="가끔 눈비";;
	Sleet\ and\ thunder)	
		conKO="눈비와 천둥";;
	Sleet\ showers\ and\ thunder)	
		conKO="^p(;2)${dfnt2}가끔 눈비와 천둥^p(0;-2)";;

	Light\ sleet)
		conKO="약한 눈비";;		# cf. 가벼운 진눈깨비
	Light\ sleet\ showers)	
		conKO="가끔 약한 눈비";;	# cf. 가랑눈비
	Light\ sleet\ and\ thunder)	
		conKO="^p(;2)${dfnt2}약한 눈비와 천둥^p(0;-2)";;
	Light\ sleet\ showers\ and\ thunder)	
		conKO="^pa(;2)${dfnt2}가끔 약한^ib(1)^p(-56;18)눈비와 천둥^p(0;-12)";;

	Heavy\ Sleet)	
		conKO="심한 눈비";;		# cf. 무거운 진눈깨비
	Heavy\ sleet\ showers)	
		conKO="가끔 심한 눈비";;
	Heavy\ sleet\ and\ thunder)	
		conKO="^p(;2)${dfnt2}심한 눈비와 천둥^p(0;-2)";;
	Heavy\ sleet\ showers\ and\ thunder)	
		conKO="^pa(;2)${dfnt2}가끔 심한^ib(1)^p(-56;18)눈비와 천둥^p(0;-12)";;

	Snow)
		conKO="눈";;
	Snow\ showers)	
		conKO="가끔 눈";;		# cf. 가끔 눈, 간헐적으로 내리는 눈
	Snow\ and\ thunder)	
		conKO="눈과 천둥";;
	Snow\ showers\ and\ thunder)	
		conKO="가끔 눈와 천둥";;

        Light\ snow)    
                conKO="가랑눈";;
	Light\ snow\ showers)	
		conKO="${dfnt3}가끔 약한 눈";;
	Light\ snow\ and\ thunder)	
		conKO="${dfnt3}가랑눈과 천둥";;
	Light\ snow\ showers\ and\ thunder)	
		conKO="^p(;2)${dfnt2}가끔 가랑눈과 천둥^p(0;-2)";;

	Heavy\ snow)	
		conKO="큰눈";;
	Heavy\ snow\ showers)	
		conKO="가끔 눈";;
	Heavy\ snow\ and\ thunder)	
		conKO="큰눈과 천둥";;
	Heavy\ snow\ showers\ and\ thunder)	
		conKO="^p(;2)${dfnt2}가끔 큰눈과 천둥^p(0;-2)";;

	Fog)	
		conKO="안개";;
	*)
		conKO="???"	# for yet unknown weather phenomena (if any)
esac
#	\-> Note for double-liners, the last ^p(...) is for pushing up a (potential) divider.
#		If you don't want dividers, simply comment the $divider line; nothing needs to be
#		changed here.
#
#	\-> weather events on kma.go.kr not especially mentioned by yr.no:
#
#	* 연무 煙霧	(연기와 안개) smog/smoke and fog -> fog 
#	* 황사 黃砂	yellow dust[sand], Asian dust -> fog
#	* 박무 薄霧	thin[gauzy] mist -> fog
#	* 비 또는 눈...	-> sleet
# 	* 천둥번개	-> ~천둥
#
#	\-> KO terms partially derived from
#
#	* http://www.kma.go.kr/weather/icon_info.html
#	* http://www.kma.go.kr/popup/20120626_kma_icon.jsp


#	3c) Air Temperature / 기온 氣溫
#
#	* temperature value (in Celsius degrees)

tempval=$(wget -q ${wservice3} -NO /tmp/rkpk; cat /tmp/rkpk \
|grep -m 1 F\ \(|tr -d '('|awk '{print $5}')

#	* arbitrary colors
arctic="#6a5acd"
frosty="#00bfff"
cold="#add8e6"
chilly="#61e296"
moderate="#83d688"
lukewarm="#b5cd62"
warm="#ffd700"
hot="#ffa000"
tropic="#e93423"
meltinghot="#ff2222"


gettcol() {
   if   [[ "$tempval" -le -20 ]] ; then
      tempcol="^fg($arctic)"
   elif [[ "$tempval" -le 0 ]] ; then
      tempcol="^fg($frosty)"
   elif [[ "$tempval" -le 4 ]] ; then
      tempcol="^fg($cold)"
   elif [[ "$tempval" -le 10 ]] ; then
      tempcol="^fg($chilly)"
   elif [[ "$tempval" -le 16 ]] ; then
      tempcol="^fg($moderate)"
   elif [[ "$tempval" -le 23 ]] ; then
      tempcol="^fg($lukewarm)"
   elif [[ "$tempval" -le 29 ]] ; then  
      tempcol="^fg($warm)"
   elif [[ "$tempval" -le 34 ]] ; then
      tempcol="^fg($hot)"
   elif [[ "$tempval" -le 39 ]] ; then  
      tempcol="^fg($tropic)"
   elif [[ "$tempval" -gt 39 ]] ; then
      tempcol="^fg($meltinghot)"
   else
      tempcol="^fg()"
   fi
	temp="${tempcol}${tempval}${fg2}°C^fg()"
   } ; gettcol



###	(4) Module "Wind" / 바람 
#
#	4a) Wind Icon Processing

#	* determine current icon name

wind=$(wget -q ${wservice1} -NO /tmp/busan1; cat /tmp/busan1 \
| grep -m 1 class=\"wind\" | awk -F\" '{print $2}' | awk -F/ '{print $8}'\
| awk '{split($0,a,".png"); print a[1];exit}')


windiconpath="${skyiconpath}others/" # new folder, storing the downloaded original PNGs
windicon="${windiconpath}XPM/${wind}.xpm" # in new folder "XPM/", where the already existing weather icons reside
windiicon="^i($windicon)"


#	* conversion preparation: get the icon download link
windsymurl=$(cat /tmp/busan1 | grep -m 1 class=\"wind\" | awk -F\" '{print $2}')


#	* check in a loop, whether the converted wind icon already exists:
if [ -s "${windicon}" ] ; then
      :
   else
#	* conversion on the fly (avoiding name-guessing for all possible icons and mass-downloading at least estimated 14401 items)
	windicon=$(wget -q ${windsymurl} -NO ${windiconpath}${wind}.png ;
	wait ;		# to prevent not finding images
	convert ${windiconpath}${wind}.png \
	-fuzz 100% -fill '#eee8d5' -opaque black -channel RGBA -blur 0x.18 \
	${windiconpath}XPM/${wind}.xpm ;
	echo "${windiconpath}XPM/${wind}.xpm")
#	\-> Recoloring and adding some blur and shadow on the behalf of IM6 again.
fi


#	4b) Wind Name List / 바람 명칭
#
windnameEN=$(wget -q ${wservice2} -NO /tmp/busan2; cat /tmp/busan2 \
| grep -m 1 windSpeed | awk -F\" '{print $4}')


#	* definition translations
#
case "${windnameEN}" in
   Calm) 		windnameKO=" 고요"	;; # Beaufort #	0 ; incl. a typographic leading space
   Light\ air)		windnameKO="실바람"	;; #		1
   Light\ breeze)	windnameKO="남실바람"	;; #		2   
   Gentle\ breeze)	windnameKO="산들바람"	;; #		3
   Moderate\ breeze)	windnameKO="건들바람"	;; #		4
   Fresh\ breeze)	windnameKO="흔들바람"	;; #		5
   Strong\ breeze)	windnameKO="된바람"	;; #		6
   Near\ gale)		windnameKO="센바람"	;; #		7
   Gale)		windnameKO="큰바람"	;; #		8
   Strong\ gale)	windnameKO="큰센바람"	;; #		9
   Storm)		windnameKO="노대바람"	;; #		10
   Violent\ storm)	windnameKO="왕바람"	;; #		11
   Hurricane)		windnameKO="싹쓸바람"	;; #		12 ; cf. cyclone, typhoon, 태풍 颱風
esac
# \--> explanation of wind symbols (NO):  http://om.yr.no/forklaring/symbol/vind/
#  \-> NO <-> EN:  http://enno.dict.cc/


#	4c) Wind Speed / 풍속 風速
#
windspeedraw=$(wget -q ${wservice2} -NO /tmp/busan2; cat /tmp/busan2 \
| grep -m 1 windSpeed | awk -F\" '{print $2}' )


#	* rounding to nearest integer when -ge 10.0 m/s
getwindspeed() {
if (( $(bc <<< "${windspeedraw}>=10") )) ; then
        windspeedrd=$(echo "(${windspeedraw} + 0.5)/1" | bc )
else 
        windspeedrd=$(echo ${windspeedraw})
fi
	windspeed=$(echo "${windspeedrd} ${fg2}m/s^fg()")
       }
       getwindspeed



#	4d) Wind Direction / 풍향 風向
#
winddirEN=$(wget -q ${wservice2} -NO /tmp/busan2; cat /tmp/busan2 \
| grep -m 1 windDirection | awk -F\" '{print $4}')


#	* replacing N-E-S-W w/ dong-seo-nam-buk 동·서·남·북 / 東·西·南·北
case "${winddirEN}" in
   *E*|*N*|*S*|*W*)
   	winddirKO=$(echo "${winddirEN}"|sed 's/E/東/g'| sed 's/N/北/g'|sed 's/S/南/g'|sed 's/W/西/g') ;;
   *)
   	winddirKO=""   # empty string when calm
esac


###	(5) Module "Atmosphere" / 공기 空氣
#
#	5a) Precipitation / 강수량 降水量
#
precvalraw=$(wget -q ${wservice2} -NO /tmp/busan2; cat /tmp/busan2 \
| grep -m 1 precipitation\ value | awk -F\" '{print $2}') 

#	* rounding to integer, when -ge 10.0 mm
getprecval() {
if (( $(bc <<< "${precvalraw}>=10") )) ; then
        precvalrd=$(echo "(${precvalraw} + 0.5)/1" | bc )
else 
        precvalrd=$(echo ${precvalraw})
fi
	precval=$(echo "강수 ${precvalrd} ${fg2}mm^fg()")
       }
       getprecval
#	\-> should correspond to sky icon!


#	5b) Relative Humidity / 습도 濕度
#
humraw=$(wget -q ${wservice3} -NO /tmp/rkpk; cat /tmp/rkpk \
| grep \<TD\>\<FONT\ FACE\=\"Arial,Helvetica\"\> | grep % | awk '{print $3}'| tr -d '%')

humid=$(echo "습도 ${humraw}${fg2}%^fg()")


#	5c) Atmospheric Pressure / 공기압력 空氣壓力  (XML only)
#
pressureraw=$(wget -q ${wservice2} -NO /tmp/busan2; cat /tmp/busan2 \
| grep -m 1 pressure | awk -F\" '{print $4}')

#	* rounding to integer
getpressure() {
if (( $(bc <<< "${pressureraw}>0") )) ; then
        pressurerd=$(echo "(${pressureraw} + 0.5)/1" | bc )
#elif    (( $(bc <<< "${pressureraw}<0") )) ; then
#        pressure=$(echo "(${pressureraw} - 0.5)/1" | bc )
else 
        pressurerd=$(echo ${pressureraw})
fi
	pressure=$(echo "압력 ${pressurerd} ${fg2}hPa^fg()")
       }
       getpressure



###	(6) Extra Stuff / 기타 其他
#
#	6a) ROK National Flag / 태극기 太極旗
#
nflag="^i(${windiconpath}XPM/hanguk.xpm)"
#	\-> source: https://en.wikipedia.org/wiki/File:Flag_of_South_Korea.svg

#	6b) forecast period / 예보 기간 豫報期間
#
getperiod=$(wget -q ${wservice1} -NO /tmp/busan1; cat /tmp/busan1 | grep -m1 td\ title\= |\
   sed -e 's/:*[A-z<> =".]//g'|sed 's/:00//g'|tr -d '\n\r')
# \-> splitting by whitespace is no good idea, since the number of words in this line varies

period="${fg1}${getperiod}시 날씨^fg()"


#	6c) Extreme Weather Alerts
#
#	* For dramatic weather deteriorations yr.no also provides icons, which appear on their website then.
#		These are also to be downloaded, converted and resized (manually or on the fly), and assigned.
#	* So far three of such weather situation XML tags came across:
#		 i.  "flood"	-> flooding
#		ii.  "gale"	-> heavy gales
#		iii. "obsforecast" -> very likely a general warning, as e.g. "obs!" appears in Scandinavia
#			 for "Be careful! Watch out!", cf. http://ensv.dict.cc/?s=obs!
#	* Eventually there's also a combination of icons.
#	* With the following procedure yet unknown cases appear as plain text. Then it's up to you to take
#		further action; add new icons and lines accordingly.

getwarnings=$(wget -q ${wservice2} -NO /tmp/busan2; cat /tmp/busan2 \
| grep time\ from\= | grep type\= | awk -F\" '{print $6}' |tr '\n\r' ' ')


warnings=`echo "${getwarnings}" |sed \
	-e "s+obsforecast+\^i(\${windiconpath}XPM\/obs2.xpm)+" \
	-e "s+gale+\^i(\${windiconpath}XPM\/gale2.xpm)+" \
	-e "s+flood+\^i(\${windiconpath}XPM\/flood2.xpm)+"`
# 	\-> In this case the backtick notation is preferable, otherwise $warnings will be printed into
#		single quotes and lead to a misinterpretation and hence to an empty string.


#	6d) Sun and Moon Appearance / 태양·달 출·몰 시각
#

sunicon="^i(${skyiconpath}01d.xpm)"
moonicon="^p()^i(${skyiconpath}mf/01n.50.xpm)"
#	    \-> ^p() resetting y

wservice4="http://www.yr.no/place/South_Korea/Busan/Busan/"
# \-------> necessary since the XML data contains sun, but no moon times
#  \------> "...|grep Moonrise|..." and "...|grep Moonset|..." do not
#   \		work in case there's no moon rising! --
#    \----> Same goes for the sun's appearance at the polar regions! Tested:
#     \		* http://www.yr.no/place/Norway/Finnmark/Gamvik/Gamvik/
#      \	* http://www.yr.no/place/Antarctica/Other/Antarctica/
#       \-> Note: Test grepping with quoted variables!


#	* sunrise / 일출 日出, 동틀녘, 해돋이
#
sunriset=$(wget -q ${wservice4} -NO /tmp/busan3; cat /tmp/busan3 \
|grep -16 Sun\ and\ moon|grep class\=\"txt-left\"|tr '\<' '\>'|awk -F\> '{print $3}')

#getsunrise()	{
case "${sunriset}" in
	Midnight\ sun*)				# midnight sun, cf. 백야 白夜, 밤중의 태양
		sunrise="극의 낮,";;		# cf. polar day 극의 낮, !(극일 極日)
	Polar\ night*)				# cf. 극야 極夜
		sunrise="극의 밤,";;
	*)
		sunrise=$(echo "${sunriset}"|sed 's/Sunrise/出/')
esac
#	}
#	getsunrise


#	* sunset / 일몰 日沒, 태양 계
#
sunsett=$(wget -q ${wservice4} -NO /tmp/busan3; cat /tmp/busan3 \
|grep -23 Sun\ and\ moon|grep class\=\"txt-left\ yr|tr '\<' '\>'|awk -F\> '{print $3}')

#getsunset()	{
case "${sunsett}" in
	"")
	case "${sunriset}" in
        	Midnight\ sun*)
			sunset="^p(7;0)지지 않음";; # cf. 내려오/가다
		Polar\ night*)
			sunset="^p(7;0)오르지 않음"
	esac;;
	*)
		sunset=$(echo "${sunsett}"|sed 's/Sunset/沒/')
esac
#	}
#	getsunset

suntimes="^p(+3;-8)${sunrise}   ^ib(1)^p(-65;+16)${sunset}"


#	* moonrise / 월출 月出			# cf. 달이 뜸; 월출 시각
#
moonriset=$(wget -q ${wservice4} -NO /tmp/busan3; cat /tmp/busan3 \
|grep Moonrise| tr ' ' '\<'|awk -F\< '{printf $10}')


#getmoonrise()	{
case "${moonriset}" in
	"")	# The second is for offline testing with just a file in /tmp.
		moonrise="^p(-2;6)오르지 않음" ;; # cf. The moon does not rise.,  상승 上昇 ...
	*)
		moonrise="出 ${moonriset}"
esac
#	}
#	getmoonrise


#	* moonset / 월몰 月沒
#
moonsett=$(wget -q ${wservice4} -NO /tmp/busan3; cat /tmp/busan3 \
|grep Moonset| tr ' ' '\<'|awk -F\< '{printf $10}')


#getmoonset()	{
case "${moonsett}" in
	"")
		moonset="^p(-2;-6)            " ;;
	*)
		moonset="^p(_UNLOCK_X;+17)沒 ${moonsett}"
esac
#	}
#	getmoonset


moontimes="^p(+3;-8)${moonrise}   ^ib(1)^p(-66;+16)${moonset}"


fi	### ending of $counter condition, do not comment! ###



#	6e) Thin Dividers
#		\-> for a touch of 3D  :D
#	* The last thing I created, so it was the safest to just add it push the contents up.
#	* Using them breaks centering other fg contents (yet), no matter where they're being placed;
#		check by commenting them out.
#		A solution would be to put a divider into an extra line. Since a line height is fixed
#		(by the dzen2 starting option) this would probably look ugly.
#	* Drawing stuff becomes tricky, when piled up objects within the same slave line
#		should get centered, especially when they change their width (due to the output); 
#		they just don't adjust on the fly. "_CENTER" impacts both horizontal and vertical
#		positioning. Hence here proper centering is merely impossible.

dividert="^ib(1)^p(-324;-8)^fg(#073642)^r(324x1)"	# beveled shadow on the top, dark
dividerb="^p(-324;1)^fg(#839496)^r(324x1)"		# bright

#divider="${dividert}${dividerb}"
#	\-> Uncomment for enabling; setting the slave lines to "center" gets the dividers centered,
#		while the other stuff flushes left then.
#	\-> When dividers are enable, consider to let the title also flush left.


#	6f) Webcam Widget
#	
#	* Invoke a second dzen instance by pressing $button, displaying three webcam shots
#		for Busan provided by zhongxi:  http://de.webcams.travel/user/162529


#	* creating the $button object as a combination of several simple geometric shapes
#	* placing objects with relative coordinates ^p(...)
#	* However that's no CSS, and since dzen does yet not provide functions for hovering particular
#		contents, there're no hovering effects.
#
button="^ib(1)^p(;10)${fg1}^r(48x20)\
^ib(1)^p(-44;-4)${fg1}^r(40x28)\
^ib(1)${fg1}^p(-44)^c(8)\
^ib(1)${fg1}^p(32)^c(8)\
^ib(1)${fg1}^p(-8;20)^c(8)\
^ib(1)${fg1}^p(-48;)^c(8)\
^ib(1)${fg3}^p(0;-16)^ro(32x20)\
^fg()${fg0}^p(-33;1)${dfnt2} 웹캠"
# \----> Of course it's not necessary to set the fg color each line here, but it's useful for testing.
#  \		Change each ^fg(...) for testing when moving to other coords then.
#   \--> Drawing always starts at the upper left corner of the new contents.
#    \-> Seems like if a ^p(-X) would go beyond the left edge, it becomes positive again,
#		or the object's position is placed from the inner right.

#	* enabling mouse clicking
#
wcam="^p(_UNLOCK_X)^p(6;-20)^ca(1, sh ./mws-ycam.sh \
| dzen2 -h 160 -w 600 -x 380 -y 68 -l 3 -sa l -bg '#002b36' -fg '#eee8d5' \
-m h -p &)${button}^ca()"
# \----> Despite the slave window, there're no hovering effects (would be a nice to have).
#  \---> Seems like (for $button) the font covering the figure disables clicking,
#   \		so one has to click where the word does not cover the figure.
#    \-> Seems also the order of the arguments (per line) has an impact on displaying an object.


###	(7) Putting It All Together / 현재 날씨 現在--
#
#	* Actually it's 3(-6)hrs ahead for Busan, though the forecast becomes present time, when
#		the periods overlap in the end and before the first update.
#	* So while all the weather stuff is close future, the camera shots are close past.


myweather="${nflag}   ${dfnt1}${city}  ${dfnt0}${citydt}^p(;12) ${wcam}\n\
${dfnt3}${period}   ${skyicon}  ${tempcol}${dfnt0}${temp}  ${conKO}${divider}\n\
${dfnt3}${warnings}${windiicon} ${winddirKO} ${windspeed}  ${dfnt0}${windnameKO}${divider}\n\
${dfnt3}${precval}   ${humid}   ${pressure}^p(;-2)${divider}\n\
${sunicon}${dfnt2}${suntimes}    ${moonicon}${moontimes}^p(;-4)${divider}"
#	\--> Note: To enable or disable dividers, just uncomment or comment the $divider definition line!
#	 \-> Also, when not stating a font starting option, each slave window line would very likely need a font declaration
#		at the beginning.

echo -e "${myweather}" # double quotes for the extra whitespaces to take effect



if [ $counter -ge ${weatherupdate} ]
	then
	counter=0	# resetting the internal counter when the amount of $weatherupdate cycles has been reached
fi

### amount of time in seconds for the script to wait and restart
#
sleep 600	# Don't forget a sleep time for testing purposes w/o the clock stuff; otherwise your system is soon.
#	\---> Set to "1" if you want to draw dzen a clock synchronously to your OS. Note in this case, dzen will redraw
#	 \	everything every second, which might cause heavy system loads on slow machines.
#	  \->	If on the other side you don't need the clock, disable it and set the sleeping time to the real time weather
#		update period, and vice versa $weatherupdate to "1" for keeping dzen and script resources to a minimum.

done    




***************** Invoke the script like so:

$ sh ~/.scripts/mws/mws-y.sh | dzen2 -h 40 -w 340 -x 80 -y 16 -fn 'UnDotum-12' -l 4 -sa c -bg '#002b36' -fg '#eee8d5' -u -p &

***************** See the Dzen wiki for all options:
			https://github.com/robm/dzen/wiki

			Have fun!


### EOF ###
