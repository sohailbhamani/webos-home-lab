# How the webOS home app works (and how to edit it)

## It's a QML app on a read-only partition

The home screen is a Qt/QML application living at:

```
/usr/palm/applications/com.webos.app.home/qml
```

`main.qml` loads `UserInterfaceLayer/Containers/MainView.qml`, which composes the
background, the top band, the app ribbon and the connection/input shelf. The
partition is signed and read-only, so you can't write to it. But you don't need
to.

## The overlay: bind-mount a writable copy over it

1. Copy the whole `qml` tree to a writable spot (we use
   `/var/lib/webosbrew/homeqml-k/qml`).
2. Edit the copy.
3. `mount --bind` your copy over the real path. The app now reads your files.

A reboot drops the mount (the copy lives on persistent storage), so a boot hook
re-applies it on every power-on. See
[`../hooks/70-homeqml-k`](../hooks/70-homeqml-k).

## The one real gotcha: the CRIU checkpoint

If you only bind-mount and relaunch, your edits don't show up. webOS preloads
the home app from a frozen memory image (CRIU checkpoint) with the original QML
baked in:

```
/mnt/lg/cmn_data/checkpoint/com.webos.app.home
/var/palm/jail/*/tmp/checkpoint/com.webos.app.home
```

So the hook has to do these, in order:

1. `mount --bind` the patched copy
2. delete the checkpoint dirs
3. `kill -9` the running home PID
4. `luna-send … /launch` the home app

Now `sam` can't restore from the frozen image and launches fresh from your
files. Confirm in `/var/log/dbg-log`:

```
sam ... HANDLE_CRIU {"app_id":"com.webos.app.home","status":"failed_to_restore"}
```

`failed_to_restore` is a success here. It means webOS ignored the frozen copy.
It then dumps a new checkpoint from your patched state, which is fine.

## Verifying an overlay is live

Don't trust `mount | grep`. It can show nothing even when the overlay is active.
Compare checksums instead:

```sh
md5sum /usr/palm/applications/com.webos.app.home/qml/.../MainView.qml \
       /var/lib/webosbrew/homeqml-k/qml/.../MainView.qml
```

If they match, the overlay is live.

## Rules that save you a black screen

- Edit one thing, relaunch, look. QML errors don't warn. They just blank the
  home app.
- Keep braces balanced. After every edit, the count of `{` must equal `}` in the
  file. A stray brace kills the whole app.
- Match LG's exact image dimensions and keep files small. This TV has 1 GB of
  RAM, and an oversized or wrongly-sized background thrashes it and blacks the
  screen. Keep backgrounds under ~1 MB and banners under ~2 MB.
- Never put JPEG bytes in a `.png`-named file (or the other way round). The
  decoder trips on the mismatch.
- Always keep LG's stock QML. To roll back, point the hook at the stock tree (or
  disable it), delete the checkpoints, and relaunch.
