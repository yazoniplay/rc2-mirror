# RC2 Mirror

Mobile-first website concept for privately viewing a DJI RC 2 video feed on an iPhone.

## Current status

- The landing page is a UI prototype; its preview does not connect to a controller.
- A synthetic streaming pipeline is defined using MediaMTX + FFmpeg.
- GitHub Actions runs a smoke test that publishes generated test-pattern video over RTMP and checks that MediaMTX serves an HLS playlist and media segment.
- `player-test.html` can play a public sample HLS video, or a local HLS URL during the Docker test.

## Test the streaming pipeline

Requirements: Docker Engine and Docker Compose.

```sh
docker compose up -d
sh scripts/smoke-test.sh
```

Open `http://localhost:8888/demo/index.m3u8` to inspect the generated HLS playlist. You can use that URL in the player test page while it is being served locally.

Stop the pipeline:

```sh
docker compose down -v
```

The synthetic source is a generated test pattern and tone; it is not footage from a drone. GitHub Actions should run the same smoke test on pushes and pull requests.

## What this proves—and does not prove

A passing CI test proves the RTMP-to-HLS software path works with a synthetic publisher. It does not prove DJI RC 2 compatibility, full controller-screen mirroring, production reliability, or private access control.

## Security and hosting

- RTMP port 1935 and HLS port 8888 are bound to localhost in Docker Compose, not exposed to the public internet.
- HLS CORS is permissive for local testing only. Do not copy this configuration into a public deployment without restricting origins and implementing authentication.
- Never put stream keys in browser code, public repository files, or screenshots.
- GitHub Pages is only static hosting; it cannot receive RTMP itself. A real remotely accessible feed requires a separate streaming service and an authentication design.

## Publish the static website

In the repository, open **Settings → Pages**, select **Deploy from a branch**, choose **main** and **/(root)**, then save. GitHub Pages looks for `index.html` in the selected publishing source.
