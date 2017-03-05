#!/bin/bash

# use this script for debugging locally

set -u # exit when referencing uninitialized variables

DIMENSIONS=1280x720x24

HOMEDIR=`mktemp -p /tmp -d home.XXXXXX.d`
export HOME=$HOMEDIR
mkdir $HOME/.fluxbox

export DISPLAY=:99
Xvfb $DISPLAY -screen 0 $DIMENSIONS +extension RANDR >/dev/null 2>&1 &

echo "waiting for display \"$DISPLAY\" to be available"
for i in 1 2 3 4 5; do xdpyinfo -display $DISPLAY >/dev/null 2>&1 && break || sleep "1s"; done
echo "display \"$DISPLAY\" is now available"

xdpyinfo -display $DISPLAY
echo "exit code of xdpdyinfo: $?"

echo "x11vnc starting on port 5900 and display $DISPLAY"

x11vnc -forever -shared -rfbport 5900 -display $DISPLAY >/dev/null 2>&1 &

echo "starting fluxbox"
# fluxbox -display $DISPLAY >/dev/null 2>&1 &
fluxbox -display $DISPLAY

ffmpeg -video_size 1280x720 -framerate 30 -f x11grab -i $DISPLAY.0 -pix_fmt yuv420p -vcodec libx264 $FILENAME >/dev/null 2>&1 &
