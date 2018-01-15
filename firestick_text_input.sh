#!/bin/bash

set -e

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

KEY_DELAY="0.5"

#INPUT="Trolls on Netflix"
#INPUT="Trolls"
INPUT="$1"

#Make all spaces underscores
INPUT=${INPUT// /_}

#Remove single quote
INPUT=${INPUT//\'/}
INPUT=${INPUT//_&#39;_/}

#Replace dash with space
INPUT=${INPUT//-/_}

#Make input all uppercase
INPUT=${INPUT^^}

echo $INPUT > $HERE/temp.txt

#The Firestick search bar looks like:
#A B C D E F G H I J K L M
#N O P Q R S T U V W X Y Z
#1 2 3 4 5 6 7 8 9 0 - _
#
#where - is delete and _ is a space, create a dictionary below to match so we can navigate the search

declare -A SEARCH_CHARS=( ["A"]=101 ["B"]=102 ["C"]=103 ["D"]=104 ["E"]=105 ["F"]=106 ["G"]=107 ["H"]=108 ["I"]=109 ["J"]=110 ["K"]=111 ["L"]=112 ["M"]=113 ["N"]=201 ["O"]=202 ["P"]=203 ["Q"]=204 ["R"]=205 ["S"]=206 ["T"]=207 ["U"]=208 ["V"]=209 ["W"]=210 ["X"]=211 ["Y"]=212 ["Z"]=213 ["1"]=301 ["2"]=302 ["3"]=303 ["4"]=304 ["5"]=305 ["6"]=306 ["7"]=307 ["8"]=308 ["9"]=309 ["0"]=310 ["-"]=311 ["_"]=312 )

#get into search menu
IP="192.168.1.113"
adb devices -l | grep "$IP" | xargs -0 test -z && adb connect $IP
adb shell dumpsys power | grep "Display Power: state=ON" | xargs -0 test -z && adb shell input keyevent 26
adb shell input keyevent 3
sleep 3
echo -e "input keyevent 21\ninput keyevent 20\nexit" | adb shell
#adb shell input keyevent 21
#adb shell input keyevent 20
sleep 1

CURR_ROW=1
CURR_COL=1
for c in `grep -o . <<< $INPUT`; do
  #echo $c=${SEARCH_CHARS[$c]}
  NEW_ROW=1
  NEW_COL=1
  if [ ${SEARCH_CHARS[$c]} -gt 299 ]; then
    NEW_ROW=3
    NEW_COL=$((${SEARCH_CHARS[$c]} -  300))
  elif [ ${SEARCH_CHARS[$c]} -gt 199 ]; then
    NEW_ROW=2
    NEW_COL=$((${SEARCH_CHARS[$c]} -  200))
  else
    NEW_ROW=1
    NEW_COL=$((${SEARCH_CHARS[$c]} -  100))
  fi

  UP_DOWN=$(($NEW_ROW - $CURR_ROW))
  LEFT_RIGHT=$(($NEW_COL - $CURR_COL))

  if [ $CURR_ROW -eq 3 ] && [ $CURR_COL -eq 12 ] && [ $UP_DOWN -lt 0 ]; then
    LEFT_RIGHT=$((LEFT_RIGHT - 1))
  fi

  if [ $NEW_ROW -eq 3 ]; then
    if [ $LEFT_RIGHT -gt 6 ]; then
      LEFT_RIGHT=$((LEFT_RIGHT - 12))
    elif [ $LEFT_RIGHT -lt -6 ]; then
      LEFT_RIGHT=$((LEFT_RIGHT + 12))
    fi
  else
    if [ $LEFT_RIGHT -gt 6 ]; then
      LEFT_RIGHT=$((LEFT_RIGHT - 13))
    elif [ $LEFT_RIGHT -lt -6 ]; then
      LEFT_RIGHT=$((LEFT_RIGHT + 13))
    fi
  fi

  #home 3
  #up 19
  #down 20
  #left 21
  #right 22
  #enter 66

  while [ $UP_DOWN -gt 0 ]; do
    adb shell input keyevent 20 &
    sleep $KEY_DELAY
    UP_DOWN=$(($UP_DOWN - 1))
  done
  while [ $UP_DOWN -lt 0 ]; do
    adb shell input keyevent 19 &
    sleep $KEY_DELAY
    UP_DOWN=$(($UP_DOWN + 1))
  done
  while [ $LEFT_RIGHT -gt 0 ]; do
    adb shell input keyevent 22 &
    sleep $KEY_DELAY
    LEFT_RIGHT=$(($LEFT_RIGHT - 1))
  done
  while [ $LEFT_RIGHT -lt 0 ]; do
    adb shell input keyevent 21 &
    sleep $KEY_DELAY
    LEFT_RIGHT=$(($LEFT_RIGHT + 1))
  done
  adb shell input keyevent 66 &
  sleep $KEY_DELAY

  CURR_ROW=$NEW_ROW
  CURR_COL=$NEW_COL
done


UP_DOWN=$((4 - $CURR_ROW))
while [ $UP_DOWN -gt 0 ]; do
  adb shell input keyevent 20 &
  sleep $KEY_DELAY
  UP_DOWN=$(($UP_DOWN - 1))
done
adb shell input keyevent 66
sleep 1
adb shell input keyevent 66
sleep 3
adb shell input keyevent 66

