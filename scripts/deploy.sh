#!/bin/sh
# Deploy the patched home-screen overlay to a rooted LG webOS 6.x or 7.x TV.
# On webOS 7, seed the overlay on the TV first (cp -a the stock qml tree into
# homeqml-k/qml), because a copy made on a Mac loses a file. See docs/06-webos7.md.
#
# Run this on your workstation. It expects:
#   - ./stock-qml   : LG's stock home QML with the patches you want already applied
#   - root SSH to the TV
#
# Set TV_HOST (and TV_PASS or an SSH key). This script never stores them.
#
# It copies the overlay under /var/lib/webosbrew/homeqml-k, installs the boot
# hook, and runs the hook once to apply it live. Nothing here is TV-specific
# except TV_HOST — keep secrets out of the repo.
set -eu

: "${TV_HOST:?set TV_HOST=root@<tv-ip>}"
SRC=${1:-stock-qml}
REMOTE_QML=/var/lib/webosbrew/homeqml-k/qml
HOOK=/var/lib/webosbrew/init.d/70-homeqml-k

[ -f "$SRC/main.qml" ] || { echo "no $SRC/main.qml — point at your patched qml tree"; exit 1; }

echo "==> backing up stock QML on the TV (only while the live QML is stock)"
# Gate on the patch marker, not on homeqml-k existing: once the overlay is
# mounted, the live path shows the patched copy and must not be saved as stock.
ssh "$TV_HOST" '
  Q=/usr/palm/applications/com.webos.app.home/qml
  if grep -rqs "custom:" "$Q"; then
    echo "live QML is already patched (overlay mounted) — skipping backup"
  else
    B=/var/lib/webosbrew/backup-home-$(date +%Y%m%d-%H%M)
    mkdir -p "$B"
    cp -a /var/lib/webosbrew/init.d "$B/init.d" 2>/dev/null || true
    cp -a "$Q" "$B/stock-qml"
    echo "backup: $B"
  fi
'

echo "==> syncing overlay"
# tar over ssh (rsync may be absent on the TV)
tar -C "$SRC" -czf - . | ssh "$TV_HOST" '
  mkdir -p '"$REMOTE_QML"' && tar -C '"$REMOTE_QML"' -xzf -
'

echo "==> installing boot hook"
scp hooks/70-homeqml-k "$TV_HOST:$HOOK"
ssh "$TV_HOST" "chmod 755 $HOOK && sh $HOOK"

echo "==> verifying overlay is live"
ssh "$TV_HOST" '
  L=/usr/palm/applications/com.webos.app.home/qml/UserInterfaceLayer/Containers/MainView.qml
  C='"$REMOTE_QML"'/UserInterfaceLayer/Containers/MainView.qml
  [ "$(md5sum "$L" | cut -d" " -f1)" = "$(md5sum "$C" | cut -d" " -f1)" ] \
    && echo "overlay live" || echo "overlay NOT live — check the hook / dbg-log"
'
echo "Done. Look at the TV."
