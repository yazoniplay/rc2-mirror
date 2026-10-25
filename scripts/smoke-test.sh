#!/usr/bin/env sh
set -eu

BASE_URL="${HLS_BASE_URL:-http://127.0.0.1:8888}"
MASTER_URL="$BASE_URL/demo/index.m3u8"
attempt=0

echo "Waiting for synthetic RTMP feed to appear as HLS..."
while [ "$attempt" -lt 40 ]; do
  attempt=$((attempt + 1))
  if curl --fail --silent "$MASTER_URL" -o /tmp/rc2-master.m3u8 2>/dev/null &&
     grep -q '#EXTM3U' /tmp/rc2-master.m3u8 &&
     grep -q '#EXT-X-STREAM-INF' /tmp/rc2-master.m3u8; then
    break
  fi
  sleep 2
done

if ! grep -q '#EXT-X-STREAM-INF' /tmp/rc2-master.m3u8 2>/dev/null; then
  echo "FAIL: HLS master playlist was not ready at $MASTER_URL"
  cat /tmp/rc2-master.m3u8 2>/dev/null || true
  exit 1
fi

# MediaMTX serves a master playlist first; follow its first video variant.
VARIANT="$(awk '/#EXT-X-STREAM-INF/ { getline; gsub(/\r/, ""); print; exit }' /tmp/rc2-master.m3u8)"
case "$VARIANT" in
  http://*|https://*) MEDIA_URL="$VARIANT" ;;
  /*) MEDIA_URL="$BASE_URL$VARIANT" ;;
  *) MEDIA_URL="$BASE_URL/demo/$VARIANT" ;;
esac

attempt=0
while [ "$attempt" -lt 20 ]; do
  attempt=$((attempt + 1))
  if curl --fail --silent "$MEDIA_URL" -o /tmp/rc2-media.m3u8 2>/dev/null &&
     grep -q '#EXTM3U' /tmp/rc2-media.m3u8 &&
     grep -Eq '^[^#].*\.(m4s|ts|mp4)(\?.*)?$' /tmp/rc2-media.m3u8; then
    break
  fi
  sleep 1
done

SEGMENT="$(grep -E '^[^#].*\.(m4s|ts|mp4)(\?.*)?$' /tmp/rc2-media.m3u8 2>/dev/null | head -n 1 | tr -d '\r' || true)"
if [ -z "$SEGMENT" ]; then
  echo "FAIL: media playlist contains no downloadable segments: $MEDIA_URL"
  cat /tmp/rc2-media.m3u8 2>/dev/null || true
  exit 1
fi

case "$SEGMENT" in
  http://*|https://*) SEGMENT_URL="$SEGMENT" ;;
  /*) SEGMENT_URL="$BASE_URL$SEGMENT" ;;
  *) SEGMENT_URL="$(dirname "$MEDIA_URL")/$SEGMENT" ;;
esac

curl --fail --silent --show-error "$SEGMENT_URL" -o /tmp/rc2-segment.bin
BYTES="$(wc -c < /tmp/rc2-segment.bin | tr -d ' ')"
if [ "$BYTES" -lt 1000 ]; then
  echo "FAIL: media segment is unexpectedly small ($BYTES bytes)"
  exit 1
fi

echo "PASS: HLS master playlist, video variant, and media segment verified ($BYTES bytes)."
echo "Master playlist: $MASTER_URL"
echo "Video playlist: $MEDIA_URL"
echo "Segment: $SEGMENT_URL"
