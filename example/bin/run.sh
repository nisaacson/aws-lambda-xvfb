#!/bin/bash

set -u
set -x

DIMENSIONS="1280x720"
BIT_DEPTH=24
FILENAME=${1:?"Please specify a FILENAME as the first argument to store recorded video"}


function shutdown {
  echo "begin shutdown script"
  # rm -rf $PROFILEDIR
  echo "SIGINT ffmpeg"
  kill -s SIGINT $FFMPEG_PID  2>/dev/null || true
  echo "SIGINT fluxbox"
  kill -s SIGINT $FLUXBOX_PID || true
  echo "SIGINT Xvfb"
  kill -s SIGINT $XVFB_PID || true

  echo "SIGTERM ffmpeg"
  kill -s SIGTERM $FFMPEG_PID 2>/dev/null || true
  echo "SIGTERM fluxbox"
  kill -s SIGTERM $FLUXBOX_PID || true
  echo "SIGTERM Xvfb"
  kill -s SIGTERM $XVFB_PID || true

  echo "wait for XVFB_PID"
  wait $XVFB_PID

  echo "wait for FLUXBOX_PID"
  wait $FLUXBOX_PID

  echo "wait for FFMPEG_PID"
  wait $FFMPEG_PID

  echo "shutdown complete"
}

HOMEDIR=`mktemp -p /tmp -d home.XXXXXX.d`
export HOME=$HOMEDIR
mkdir $HOME/.fluxbox

export DISPLAY=:99
Xvfb $DISPLAY -screen 0 ${DIMENSIONS}x${BIT_DEPTH} +extension RANDR >/dev/null 2>&1 &
# Xvfb $DISPLAY -screen 0 ${DIMENSIONS}x${BIT_DEPTH} +extension RANDR
XVFB_PID=$!

echo "waiting for display \"$DISPLAY\" to be available"
xdpyinfo -display $DISPLAY
for i in 1 2 3 4 5; do xdpyinfo -display $DISPLAY >/dev/null 2>&1 && break || sleep "1s"; done
echo "display \"$DISPLAY\" is now available"

# xdpyinfo -display $DISPLAY
# echo "exit code of xdpdyinfo: $?"

# echo "x11vnc starting on port 5900 and display $DISPLAY"
# x11vnc -forever -shared -rfbport 5900 -display $DISPLAY >/dev/null 2>&1 &
#
echo "starting fluxbox"
fluxbox -display $DISPLAY >/dev/null 2>&1 &
FLUXBOX_PID=$!
echo "fluxbox started"

echo "starting ffmpeg"
echo "FILENAME: \"$FILENAME\""
# ffmpeg -video_size ${DIMENSIONS} -framerate 30 -f x11grab -i ${DISPLAY}.0 -pix_fmt yuv420p -vcodec libx264 ${FILENAME} >/dev/null 2>&1 &
ffmpeg -video_size ${DIMENSIONS} -framerate 30 -f x11grab -i ${DISPLAY}.0 -pix_fmt yuv420p -vcodec libx264 ${FILENAME} &
FFMPEG_PID=$!

echo "ffmpeg running"

# record 5 seconds of video
sleep 5s
kill -s SIGINT "$FFMPEG_PID"
# timeout --signal=SIGINT "$FFMPEG_PID"
echo "wait for FFMPEG_PID"
wait $FFMPEG_PID
echo "ffmpeg shutdown cleanly"
