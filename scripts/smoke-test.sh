#!/usr/bin/env sh
set -eu

BASE_URL="${HLS_BASE_URL:-http://127.0.0.1:8888}"
PLAYLIST_URL="$BASE_URL/demo/index.m3u8"
attempt=0

echo "Waiting for synthetic RTMP feed to appear as HLS..."
while [ "$attempt" -lt 40 ]; do
  attempt=$((attempt + 1))
  if curl --fail --silent --show-error "$PLAYLIST_URL" -o /tmp/rc2-playlist.m3u8 2>/dev/null &&
     grep -q '#EXTM3U' /tmp/rc2-playlist.m3u8 &&
     grep -Eq '\.(m4s|ts|mp4)(\?|$)' /tmp/rc2-playlist.m3u8; then
    break
  fi
  sleep 2
done

if ! grep -q '#EXTM3U' /tmp/rc2-playlist.m3u8 2>/dev/null; then
  echo "FAIL: HLS playlist was not produced at $PLAYLIST_URL"
  exit 1
fi

SEGMENT="$(grep -E '\.(m4s|ts|mp4)(\?|$)' /tmp/rc2-playlist.m3u8 | head -n 1 | tr -d '\r')"
if [ -z "$SEGMENT" ]; then
  echo "FAIL: playlist contains no media segments"
  cat /tmp/rc2-playlist.m3u8
  exit 1
fi

case "$SEGMENT" in
  http://*|https://*) SEGMENT_URL="$SEGMENT" ;;
  *) SEGMENT_URL="$BASE_URL/demo/$SEGMENT" ;;
esac

curl --fail --silent --show-error "$SEGMENT_URL" -o /tmp/rc2-segment.bin
BYTES="$(wc -c < /tmp/rc2-segment.bin | tr -d ' ')"
if [ "$BYTES" -lt 1000 ]; then
  echo "FAIL: media segment is unexpectedly small ($BYTES bytes)"
  exit 1
fi

echo "PASS: HLS playlist exists and a media segment downloaded ($BYTES bytes)."
echo "Playlist: $PLAYLIST_URL"
