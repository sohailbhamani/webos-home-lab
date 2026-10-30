# webOS Home Screen Lab

Reclaim the home screen on an LG webOS 6.x TV you own: drop the ads, promos,
"Start a new experience" filler and unused tiles, put a real full-screen
photo behind everything, and make the input tiles dark so they sit on it.

> ⚖️ Not affiliated with LG. For a TV **you own**. No exploit here; no warranty. See [NOTICE.md](NOTICE.md).

This is a **customization** guide for a TV **you own**. It does not include any
exploit code. Rooting is done with the public community tools linked in
[`docs/01-rooting.md`](docs/01-rooting.md); everything in this repo runs
*after* the TV is already rooted.

Proven on a **43UP8000PUR, webOS 6.5 (software 03.51.16)**. Other 6.x models
use the same home app structure but file names and image sizes vary — read,
don't paste.


## What's here

| Path | What it is |
|------|-----------|
| `docs/01-rooting.md` | How people root LG TVs — links to the public tools, no exploit here |
| `docs/02-how-the-home-app-works.md` | webOS home is QML; the overlay + checkpoint trick that makes edits stick |
| `docs/03-the-edits.md` | Every change, what it does, and why, keyed to the patches |
| `docs/04-going-further.md` | Build your own app, the screensaver, doing it across several TVs |
| `docs/05-apps-and-settings.md` | The curated homebrew app set we install, and why; the privacy pass |
| `patches/` | One `git`-style patch per change, against LG's stock home QML |
| `hooks/70-homeqml-k` | Boot hook: bind-mount the patched copy and relaunch home |
| `scripts/render_home_bg.py` | Turn the ESO Milky Way panorama into a TV-safe background (geometry is tuned to that image) |
| `scripts/deploy.sh` | Copy the overlay to the TV and apply it |

## The shape of it

LG's home screen is a **QML app** on a signed, read-only partition. You can't
edit it in place, but you can **bind-mount a writable copy over it** and force
the app to relaunch from your copy. A boot hook re-applies the mount every
power-on. That's the whole mechanism — the rest is reading LG's QML and
changing the right lines.

See [`docs/02-how-the-home-app-works.md`](docs/02-how-the-home-app-works.md)
for the one real gotcha (webOS restores the home app from a frozen memory
checkpoint, so you have to delete the checkpoint or your edits stay invisible).

## Quick start (TV already rooted, SSH reachable)

```sh
# 1. Copy LG's stock home QML off the TV to ./stock-qml, then:
cd stock-qml
git init -q && git add -A && git commit -qm stock      # baseline to diff against
git apply ../patches/*.patch                            # apply the lessons you want

# 2. Render the background. The rotation/crop are tuned for the 3840x1920 ESO
#    Milky Way panorama; for another photo, adjust the constants at the top.
python3 ../scripts/render_home_bg.py my_photo.jpg bg_space_SIZE.jpg
cp bg_space_1920.jpg UserInterfaceLayer/Components/images/2k/bg_space.jpg
cp bg_space_1920.jpg UserInterfaceLayer/Components/images/4k/bg_space.jpg

# 3. Push the copy to the TV and apply (see scripts/deploy.sh for the real thing)
```

Apply the patches **one at a time** and look at the screen after each. Match
LG's exact image dimensions, keep assets small (a 1 GB-RAM TV thrashes on
oversized images), and always keep LG's original QML so you can roll back.

## Safety / scope

- This modifies **your own** TV's UI. Nothing here targets anyone else's device.
- Keep a backup of the stock QML and your boot hooks. A bad QML edit black-screens
  the home app; restoring the backup and relaunching fixes it.
- Don't let the TV auto-update — the public rooting tools include an update
  blocker for exactly this reason.
