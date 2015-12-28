#!/bin/bash
#
#       mws-ycam.sh by nyamcoder :: mito{XD} 2015
#
###  A webcam widget for the ./mws-y.sh Dzen2 script
#
#       What you find here:
#
#	* dzen horizontal menu mode
#	* weather webcam shots for Busan, Korea, provided by zhongxi (see the links below)
#	* on-the-fly image conversion
#	* Solarized color palette
#	* cam activity coloring
#	* optional dividers
#	* Korean localization
#
#
#       *** Dependencies ***
#               - bash, wget, tr, (g)awk, sed, imagemagick6, Un fonts
#
#
#       *** License ***
#		- CC BY-NC-SA -- see https://creativecommons.org/licenses/
#               - Feel free to adopt and match the script to your style and language.
#               - No commercial use allowed.
#               - For questions or suggestions send a mail to < info AT mito-space DOT com >
#
#
#       *** Use this script at your own risk! ***
#
#
#       *** Consulting the dzen2 documentation material is strongly advised! ***
#               - http://dzen.googlecode.com/svn/trunk/README
#               - https://github.com/robm/dzen/wiki/_pages
#		- Note that the main script ./mws-y.sh is also comprehensively documented.
#



while [ "true" ]
   do


###	i.   Typographic Settings
#
# fonts
dfnt0="^fn(UnDotum-14)" # default
#dfnt1="^fn(UnDotum-14:bold)"
dfnt2="^fn(UnDotum-10)"


# using Solarized colors
fg1="^fg(#eee8d5)"      # S_base2, default
fg2="^fg(#b58900)"      # S_yellow
fg3="^fg(#93a1a1)"      # S_base1
fg4="^fg(#859900)"      # S_green	-- camera is	active
fg5="^fg(#dc322f)"      # S_red		-- 	"	inactive
#				\-> http://ethanschoonover.com/solarized


# left and center dividers
camdivt="^fg(#073642)^r(200x1)"	# beveled shadow, dark (top light)
camdivb="^p(-200;1)^fg(#839496)^r(200x1)"	# bright
#camdivider="${camdivt}${camdivb}"
# \-> uncomment for enabling left and center dividers

# right divider (pushing sth. left by putting sth. else right seems not to work)
camdivtR="^fg(#073642)^r(192x1)"	# right space of 8px
camdivbR="^p(-192;1)^fg(#839496)^r(192x1)"
#camdividerR="${camdivtR}${camdivbR}"
# \-> uncomment for enabling right divider


###	ii.  Online Resources
camservice="http://webcams.travel/user/162529"
#		\-> zhongxi's website,
#			preferred to yr.no since here no matter if active or not, all cameras are
#			permanently displayed; yet there are 3 cams.
#
#	* image direct links:
#
#	dongnae		http://images.webcams.travel/webcam/1431666906.jpg
#		thumb	http://images.webcams.travel/thumbnail/1431666906.jpg
#	kayadong	http://images.webcams.travel/webcam/1431666619.jpg
#		thumb	http://images.webcams.travel/thumbnail/1431666619.jpg
#	morari		http://images.webcams.travel/webcam/1431664582.jpg
#		thumb	http://images.webcams.travel/thumbnail/1431664582.jpg
#
#	Note: There must be some contents for each line, since their number has been stated as dzen options on
#		the command line. Otherwise dzen will behave weird. So it's the easiest to have 1 camera per line,
#		and the same number of lines as cameras (you want to show).



###	iii. Camera Shots and Data Processing
#
### Camera #1
#
# (localized) location or view of cam1
view1="동래구, 금정산"

# fetching and processing cam1 shot
wcam1="http://images.webcams.travel/thumbnail/1431666906.jpg"   # 동래구 東萊區, 금정산 金井山 Dongnae-gu, Mt Geumjeong
camicon1=$(wget -q ${wcam1} -NO /tmp/cam1.jpg; convert /tmp/cam1.jpg /tmp/cam1.xpm; echo /tmp/cam1.xpm)
cam1="^i(${camicon1})"


# check cam1 activity, display camera no. in red if inactive
chkactive1=$(wget -q ${camservice} -NO /tmp/weathercams; cat /tmp/weathercams| \
grep -10 -m 1 'Kumjung' |grep aktiv|tr '\<' '\>'|awk -F\> '{print $3}')

case "$chkactive1" in
	aktiv)
		cam1col="${fg4}" ;;
	inaktiv)
		cam1col="${fg5}"
esac


# check cam1 latest shot update
chklast1=$(wget -q ${camservice} -NO /tmp/weathercams; cat /tmp/weathercams| \
grep -4 -m 1 'Kumjung' |tr '\(' '\)'|tr -d '\n\r'| awk -F\) '{print $2}'| \
sed -e 's/vor//' \
-e 's/ Jahr.*/년/' \
-e 's/ Monat.*/개월/' \
-e 's/ Tag.*/일/' \
-e 's/ Stunde.*/시간/' \
-e 's/ Minute.*/분/')	#; \
#printf \ 전)
# \-> Note: The input language depends on the server location and/or the language of your browser, or your OS.

# assembling cam1 module
webcam1="^ib(1)^pa(8;2)${camdivider}^pa(54;14)${cam1}^pa(58;120)${cam1col}${dfnt0}① \
^pa(;114)${fg1}${dfnt2}${view1}^pa(79;130)${fg3}${chklast1} 전"


### Camera #2
#
# location
view2="가야동, 구봉산"

# image
wcam2="http://images.webcams.travel/thumbnail/1431666619.jpg"   # 가야동 伽倻洞, 구봉산 龜峰山 Gaya-dong, Mt Gubong
camicon2=$(wget -q ${wcam2} -NO /tmp/cam2.jpg; convert /tmp/cam2.jpg /tmp/cam2.xpm; echo /tmp/cam2.xpm)
cam2="^i(${camicon2})"

# activity
chkactive2=$(wget -q ${camservice} -NO /tmp/weathercams; cat /tmp/weathercams| \
grep -10 -m 1 'Kaya-dong'|grep aktiv|tr '\<' '\>'|awk -F\> '{print $3}')

case "$chkactive2" in
	aktiv)
		cam2col="${fg4}" ;;
	inaktiv)
		cam2col="${fg5}"
esac

# latest updated at:
chklast2=$(wget -q ${camservice} -NO /tmp/weathercams; cat /tmp/weathercams| \
grep -4 -m 1 'Kaya-dong' |tr '\(' '\)'|tr -d '\n\r'| awk -F\) '{print $2}'| \
sed -e 's/vor//' \
-e 's/ Jahr.*/년/' \
-e 's/ Monat.*/개월/' \
-e 's/ Tag.*/일/' \
-e 's/ Stunde.*/시간/' \
-e 's/ Minute.*/분/')	#; \
#printf \ 전)

# cam2 module
webcam2="^ib(1)^pa(0;2)${camdivider}^pa(36;14)${cam2}^pa(40;120)${cam2col}${dfnt0}② \
^pa(;114)${fg1}${dfnt2}${view2}^pa(61;130)${fg3}${chklast2} 전"


### Camera #3
#
# location
view3="모라리, 백양산"

# image
wcam3="http://images.webcams.travel/thumbnail/1431664582.jpg"   # 모라리 毛羅里, 백양산 白楊山 Mora-ri, Mt Baegyang
camicon3=$(wget -q ${wcam3} -NO /tmp/cam3.jpg; convert /tmp/cam3.jpg /tmp/cam3.xpm; echo /tmp/cam3.xpm)
cam3="^i(${camicon3})"

# activity
chkactive3=$(wget -q ${camservice} -NO /tmp/weathercams; cat /tmp/weathercams| \
grep -10 -m 1 'Mora-ri' |grep aktiv|tr '\<' '\>'|awk -F\> '{print $3}')

case "$chkactive3" in
	aktiv)
		cam3col="${fg4}" ;;
	inaktiv)
		cam3col="${fg5}"
esac

# latest updated at:
chklast3=$(wget -q ${camservice} -O /tmp/weathercams; cat /tmp/weathercams| \
grep -4 -m 1 'Mora-ri' |tr '\(' '\)'|tr -d '\n\r'| awk -F\) '{print $2}'| \
sed -e 's/vor//' \
-e 's/ Jahr.*/년/' \
-e 's/ Monat.*/개월/' \
-e 's/ Tag.*/일/' \
-e 's/ Stunde.*/시간/' \
-e 's/ Minute.*/분/')	#; \
#printf \ 전)



# cam3 module
webcam3="^ib(1)^pa(0;2)${camdividerR}^pa(18;14)${cam3}^pa(22;120)${cam3col}${dfnt0}③ \
^pa(;114)${fg1}${dfnt2}${view3}^pa(43;130)${fg3}${chklast3} 전"



###	iv.  Putting All Cameras Together
#  
webcams=$"${webcam1}\n ${webcam2}\n ${webcam3}"
echo -e "${webcams}"


# refresh interval in seconds
sleep 300

done



* invoke the script like so:

$ sh /path/to/my/mws-ycam.sh | dzen2 -h 160 -w 600 -x 400 -y 16 -l 3 -sa l -bg '#002b36' -fg '#eee8d5' -m h -p &


### EOF ###
