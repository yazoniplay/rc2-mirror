# RC2 Mirror — technical feasibility test

## What is confirmed

DJI's official DJI Fly livestream guide says:
- DJI RC 2 supports RTMP livestreaming for compatible aircraft/controller firmware.
- DJI RC 2 livestream output is limited to 720p.
- DJI Fly v1.16.0+ may require a microphone plugged into the controller to start livestreaming.
- DJI's RTMP workflow requires a reachable RTMP ingest server and a valid stream URL/key.

Official source: https://repair.dji.com/help/content?customId=en-us03400006727&documentType=artical&lang=en&paperDocType=paper&re=US&spaceId=34

This is a potential path to stream the **live camera view**. It does not prove full-screen mirroring of every RC 2 UI element.

## Test A — confirm the controller can start RTMP

Do this on the ground, with the aircraft and controller safely stationary. Do not attempt this during flight.

1. Power on the controller and compatible aircraft, then open DJI Fly and enter the camera view.
2. Open the transmission/live-streaming settings and look for RTMP.
3. If RTMP is available, do not enter random URLs or share a stream key publicly. We need a server endpoint first.
4. Record whether RTMP is present, whether DJI requests a microphone, and the aircraft model + DJI Fly/firmware versions.

**Pass:** RTMP is offered and DJI allows a custom RTMP destination.
**Fail/blocked:** RTMP is absent, unavailable for the aircraft/firmware, or DJI requires an unavailable prerequisite.

## Test B — browser playback

RTMP itself is not directly playable by a normal web page. The server must accept RTMP and expose a browser-friendly output such as HLS or WebRTC.

1. Start with a known test stream and verify it plays in the target browser.
2. Configure the ingest/relay service and test its HLS/WebRTC output.
3. Only after the browser test passes, point the RC 2 at the ingest endpoint.
4. Test the result on iPhone Safari and Android/desktop browsers.

Do not put an RTMP stream key in client-side JavaScript, a public repository, screenshots, or a public URL. Treat it like a password.

## Current status

- [x] Official documentation confirms an RTMP route exists for supported combinations.
- [ ] Confirm RTMP menu on the actual controller/aircraft.
- [ ] Select and deploy an ingest server that supports RTMP plus HLS/WebRTC output.
- [ ] Prove a test stream plays on iPhone Safari.
- [ ] Prove the RC 2 feed reaches that player.
- [ ] Add authentication and verify unauthorized viewers cannot watch.

## Important distinction

A public GitHub Pages site is suitable for static UI only. It cannot itself receive RTMP or keep stream keys secret. The video ingest and access-control service must be hosted separately.
