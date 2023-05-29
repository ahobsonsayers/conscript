#!/bin/bash

# Specify the word to count in the edid output that
# will determine the number of screens detected
WORD_TO_COUNT=Identifier

# Set inital first connected screen count to 0
FIRST_SCREEN_COUNT=0

# This should ensure that get-edid works
sudo modprobe i2c-dev

while :
do
    sleep 15
    
    # count the number of connected screens for a second time
    SECOND_SCREEN_COUNT=$( (sudo timeout 5s get-edid -q -m 0 | parse-edid) 2>/dev/null | grep -c $WORD_TO_COUNT )
    
    # check if there is a change in the number of connected screens
    if [ $FIRST_SCREEN_COUNT -ne $SECOND_SCREEN_COUNT ]
    then
        
        if [ $SECOND_SCREEN_COUNT -eq 0 ]
        then
            # screen disconnected
            echo "Screen has been Disconnected"
            pkill kodi-x11
            
        else
            # screen connected
            echo "Screen has been Connected"
            /home/arranhs/startkodi.sh &
            
        fi
        
        # set the second count as initial state for the next loop
        FIRST_SCREEN_COUNT=$SECOND_SCREEN_COUNT
    fi
done
