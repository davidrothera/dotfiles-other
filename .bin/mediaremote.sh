#!/bin/bash
# Script courtesy of https://gist.github.com/tonyg/1aaf3b62bcb63dc6d626df9d12356125

if [ -z "$1" ]
then
    echo "Usage: MediaPlayer2-cmd { PlayPause | Next | Previous | Stop | ... }"
    exit 1
fi

tried_starting_something=false

while true
do
    first_matching_destination=$(dbus-send \
                                     --session \
                                     --dest=org.freedesktop.DBus \
                                     --print-reply \
                                     /org/freedesktop/DBus \
                                     org.freedesktop.DBus.ListNames | \
                                        fgrep org.mpris.MediaPlayer2. | \
                                        head -1 | \
                                        awk '{print $2}' | \
                                        sed -e 's:"::g' )
    echo first_matching_destination $first_matching_destination

    if [ -n "$first_matching_destination" ]
    then
        break
    fi

    if [ $tried_starting_something = true ]
    then
        echo "Couldn't start a media player."
        exit 1
    fi

    if [ -n "$(which spotify)" ]; then spotify &
    elif [ -n "$(which rhythmbox)" ]; then rhythmbox &
    else
        echo "No available media player, teach MediaPlayer2-cmd some new tricks"
        exit 1
    fi

    tried_starting_something=true
    sleep 3
done

dbus-send \
    --print-reply \
    --dest=$first_matching_destination \
    /org/mpris/MediaPlayer2 \
    org.mpris.MediaPlayer2.Player.$1

