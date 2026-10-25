# RC2 Mirror

Mobile-first website concept for privately viewing a DJI RC 2 video feed on an iPhone.

## Current status
This is a UI prototype only. The preview button demonstrates interface states; it does not connect to a controller or display live drone video.

## Files
- `index.html` — page structure
- `styles.css` — responsive styling
- `app.js` — preview and copy-room interactions

## Important technical note
A static GitHub Pages site cannot receive an RTMP stream directly in the browser, and the RC 2's supported feed path has not yet been validated for this use case. Do not describe this prototype as working screen mirroring. Real private viewing would require a verified video source and, if streams are relayed, a server-side service with proper access controls.

## Publish
In the repository, open **Settings → Pages**, select **Deploy from a branch**, choose **main** and **/(root)**, then save. GitHub Pages looks for `index.html` in the selected publishing source.