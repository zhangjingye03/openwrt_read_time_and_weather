#!/bin/sh
# mp3 path
mp3_path="/mnt/weathers/"
# madplay volumn
VOLUMN="-20"
# city name (used to find mp3)
city_name="guangzhou"
# city gbk in chinese (used to query the sina weather)
city_gbk="%B9%E3%D6%DD"

# change working directory into tmp in order not to make rubbish files
rm -rf /tmp/weather
mkdir /tmp/weather
cd /tmp/weather

# using sina weather
wget "http://php.weather.sina.com.cn/xml.php?city=$city_gbk&password=DJOYnieT8234jlsK&day=0" -O got

# temperature
t_low=$(cat got | grep "<temperature2>" | sed  's/<temperature2>//' | sed 's/<\/temperature2>//')
t_high=$(cat got | grep "<temperature1>" | sed  's/<temperature1>//' | sed 's/<\/temperature1>//')
# weather state
t_state1=$(cat got | grep "<figure1>" | sed  's/<figure1>//' | sed 's/<\/figure1>//')
t_state2=$(cat got | grep "<figure2>" | sed  's/<figure2>//' | sed 's/<\/figure2>//')

# make playlist, p.mp3 to pause for 1s
playlist="today.mp3 p.mp3 $city_name.mp3 p.mp3";
# temperature < 11, broadcast directly
if [ $t_low -lt 11 ]; then
  playlist="$playlist $t_low.mp3"
else
  # pull the first num out
  t_low_first=$( echo $t_low | cut -b 1 )
  # cut out the second num
  t_low_last=$( echo $t_low | cut -d $t_low_first -f 2)
  # if the last num is 0, ignore it
  if [ $t_low_last -eq 0 ]; then
    playlist="$playlist $t_low_first.mp3 10.mp3"
  else
    playlist="$playlist $t_low_first.mp3 10.mp3 $t_low_last.mp3"
  fi
fi
# if the high temperature and the low one are equal, broadcast degree directly.
if [ $t_low -eq $t_high ]; then
  playlist="$playlist du.mp3 p.mp3"
else
  playlist="$playlist zhi.mp3"
  # temperature < 11, broadcast directly
  if [ $t_high -lt 11 ]; then
    playlist="$playlist $t_high.mp3"
  else
    # pull the first num out
    t_high_first=$( echo $t_high | cut -b 1 )
    # cut out the second num
    t_high_last=$( echo $t_high | cut -d $t_high_first -f 2)
    # if the last num is 0, ignore it
    if [ $t_high_last -eq 0 ]; then
      playlist="$playlist $t_high_first.mp3 10.mp3"
    else
      playlist="$playlist $t_high_first.mp3 10.mp3 $t_high_last.mp3"
    fi
  fi
  playlist="$playlist du.mp3 p.mp3"
fi
# check if the weather state is the same
if [ $t_state1 = $t_state2 ]; then
  playlist="$playlist $t_state1.mp3"
else
  playlist="$playlist $t_state1.mp3 zhuan.mp3 $t_state2.mp3"
fi

# broadcast weather!
cd $mp3_path
madplay -A $VOLUMN $playlist
