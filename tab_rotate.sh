#!/bin/bash
#Variables
syntax_error=0
orientation=0

#Detect the current orientation
current_orientation="$(xrandr -q --verbose | grep 'connected' | \
	egrep -o  '\) (normal|left|inverted|right) \(' | \
       	egrep -o '(normal|left|inverted|right)')"
# 1=left, 2=inverted, 3=right, 0=normal

#Next orintation, rotate 90 degrees
case $current_orientation in
        normal)   orientation=1 ;;
        left)     orientation=2 ;;
        inverted) orientation=3 ;;
        right)    orientation=0 ;;
esac

#Use the orientation if it is given
if [ "$1." != "." ]; then
        orientation=$1
fi

#Touchscreen input method
method=evdev

#Detect input device id
device=`xinput --list | grep Cando|awk '{ print $12 }' | awk -F '=' '{ print $2 }'`

#Default input settings (first 2 rows of a 3x3 rotation matrix)
mata=1; matb=0; matc=0; matd=0; mate=1; matf=0;

#Work out the input settng for each orientatiom
case $orientation in
        0) mata=1;  matb=0; matc=0; matd=0;  mate=1;  matf=0 ;;
        1) mata=0;  matb=1; matc=1; matd=1;  mate=0;  matf=0 ;;
        2) mata=-1; matb=0; matc=1; matd=0;  mate=-1; matf=1 ;;
        3) mata=0;  matb=1; matc=0; matd=-1; mate=0;  matf=1 ;;
esac

#Set the touchscreen rotation
if [ $method = "evdev" ]; then
        xinput set-prop "$device" "Coordinate Transformation Matrix" $mata $matb $matc $matd $mate $matf 0 0 1
fi

#Set the screen rotation
xrandr -o $orientation

