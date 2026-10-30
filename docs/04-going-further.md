# Going further

Once the TV is rooted and the home screen is yours, the same access opens up a
lot more. Notes and starting points below.

## Make your own homebrew app

A webOS app is just a web app in a signed `.ipk` package. For something like a
**weather / radar dashboard**, tier 2 (an HTML5 app) is the right level — no
native SDK needed.

1. **App skeleton.** An `.ipk` is a folder with `appinfo.json` (id, title, icon,
   `main: index.html`, `type: web`) plus your `index.html` / JS / CSS.
2. **Build it** with the LG CLI, `ares-package`, from the public webOS SDK
   (<https://webostv.developer.lge.com/>), or the community `ares-cli`.
3. **Install it** through the Homebrew Channel (or `ares-install` in dev mode).
   No store, no signing fees — it's your TV.
4. **Data.** A weather app just fetches an API. Good free ones:
   - **NWS / weather.gov** (US, no key) for conditions + alerts.
   - **Open-Meteo** (no key) for forecast + current temp.
   - **RainViewer** for an animated radar tile overlay (free tier).
   Render it full-screen, big type, auto-refresh on a timer — it reads great
   across a room.
5. **Autostart / screensaver.** You can point the idle screensaver at your own
   app, or launch it on boot via an `init.d` hook like the home overlay here.

The home-app overlay in this repo is the harder version of the same skill
(editing a signed app in place); a standalone `.ipk` is the easy, clean way to
add something brand new.

## The screensaver

webOS ships a built-in screensaver app (`com.webos.app.screensaver`) and an art
gallery (`com.webos.app.igallery`). Both are themeable the same way the home app
is — bind-mount a patched copy, or replace the screensaver target with your own
`.ipk` (e.g. the weather dashboard, or a photo/space slideshow). Set the idle
timeout in *Settings → General → Screen Saver*.

## Other things people do with a rooted LG TV

- **YouTube ad-free** (`youtube-webos`) — the usual first install.
- **Debloat + privacy** — Glasshouse (uninstall LG apps, kill ad domains),
  Life's Good Without Spying (telemetry off).
- **Remap the remote** — LG Input Hook: make the Home button open *your* launcher
  or app instead of LG's.
- **Ambilight** — hyperion-webos / PicCap drives LED strips or Hue bulbs from the
  screen contents.
- **Local media** — Jellyfin / Kodi as `.ipk`s.
- **VNC / screenshots** — the VNC server app lets you see and capture the screen
  from a laptop (handy when iterating on UI like this).

## Doing this across several TVs

The overlay is model- and firmware-specific in its *details* (file names, image
sizes), but the method is identical. For each TV: root it with the public tools,
extract its stock QML, re-apply the patches (adjusting any paths that differ),
render a background at that panel's dimensions, and deploy. Keep each TV's
stock-QML backup and its overlay in its own folder — don't assume one TV's
patched files drop onto another untouched.
