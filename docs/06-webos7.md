# webOS 7 (webOS 22)

The second TV is a 43UQ7070ZUD on webOS 7.6.0 (software 04.60.90). The home app
is the same QML app in the same place, and the same overlay and boot hook work
unchanged. Patches `04` to `07` apply as they are. `01` to `03` needed porting
by hand because LG renamed or reworded a few lines. The ported set is in
[`../patches/webos7`](../patches/webos7), one file per step, same names as the
6.5 set.

## What the stock home looks like

Out of the box, webOS 7 shows a "Start a new experience with LG webOS" hero, a
Recent Input card, and a "TV functions" shelf (Edit App List, Guide, User Guide,
Home Dashboard) above the app ribbon. Patch `01` switches the shelf list to the
default set, which drops the Recent Input card and the TV functions shelf and
moves the ribbon up above the connection shelf. Patch `04` removes the hero.

## Differences from 6.5, by patch

- `01`: the ad request is now `requestRecommendedSponsoredAdData()` (was
  `requestRecommendedAdData()`), both where it's defined in
  `PromotionInterfaces.qml` and where `MainView.qml` calls it. The Recent Input
  card in `AdShelf.qml` is the `lastInputCard` item, further down the file.
  `ShelfList.js` and the other two `MainView.qml` calls are the same.
- `02`: same one-line change in `SystemProperties.qml`, at a different line.
- `03`: the cover rectangle behind the filler banner uses
  `styleSheet.screen.bgColor` instead of `"#000000"`, and the banner's opacity
  check also looks at `networkConnected`. Same fix: make both covers
  transparent and set the banner opacity to `0`.
- `04` to `07`: unchanged.
- `05`: the tile types are still `"title"` (Home Dashboard) and
  `"mobile_guide"` (Connection Guide). webOS 7 also shows Remote PC and "See
  User Guide" tiles at the end of the shelf. The patch leaves them alone.
- `06`: the launcher ids match, except `com.webos.app.livepick-full`
  (Who.Where.What?), which isn't on this TV. Leaving it in the list is harmless.
- `07`: `MobileComponent.qml` already imports `QtGraphicalEffects`, so
  `ColorOverlay` works as is.

## Screen and image sizes

The panel is 4K, but the UI is drawn at 1920x1080. The framebuffer reports
1920x2160, which is two 1080-line buffers. So `is4K` is false and the home app
loads images from `images/2k/`. The background is rendered at 1920x1080 (about
770 KB) and copied to both `2k/` and `4k/`.

This TV has about 1.3 GB of RAM, a bit more than the 6.5 TV, but the same size
limits apply. Keep backgrounds under 1 MB.

## Overlay and hook notes

- `hooks/70-homeqml-k` works as is. The checkpoint paths are the same, and
  `/var/log/dbg-log` shows `failed_to_restore` after the first relaunch, as on
  6.5.
- The stock tree has two files whose names differ only in case
  (`AccuWeather_Logo.png` and `accuweather_logo.png` in
  `images/hd/AIBoard/`). A Mac's default filesystem merges them, so a copy
  made on a Mac and pushed back is missing one. Build the overlay on the TV
  instead (`cp -a` the stock `qml` tree to `homeqml-k/qml`), then push only
  the files you changed.
- Screenshots: the capture service works with `"method":"SCREEN"`. With
  `"DISPLAY"` the image comes back black.

  ```sh
  luna-send -n 1 luna://com.webos.service.capture/executeOneShot \
    '{"path":"/tmp/cap.png","method":"SCREEN","width":1920,"height":1080,"format":"PNG"}'
  ```

- `luna-send` over SSH sometimes prints nothing. If it does, run it with
  `ssh -tt`.

## Apps

- Glasshouse isn't in the Homebrew Channel list. Install it through the
  Homebrew Channel install service with the `.ipk` from the project's GitHub
  release and its sha256:

  ```sh
  luna-send -i luna://org.webosbrew.hbchannel.service/install \
    '{"id":"io.github.rorygallagher2024.lg-webos-dashboard","ipkUrl":"<release .ipk url>","ipkHash":"<sha256>","subscribe":true}'
  ```

  Check the hash yourself (`shasum -a 256`) against the file you downloaded.
- Glasshouse adds its own boot hook (`50-tvweb`). When its ad blocking is on,
  it builds its own hosts file and mounts it over `/etc/hosts`, on top of the
  one from Life's Good Without Spying.
- App Update Blocker's boot hook calls its service once, while the service is
  still starting, and that call gets lost. After a reboot only a handful of
  `lgtvsdp.com` entries were in `/etc/hosts`, not the ~170 in its list. A
  second hook that runs after it and retries until the entries are there fixes
  it:

  ```sh
  #!/bin/sh
  # /var/lib/webosbrew/init.d/zz-updateblock-retry
  (
    i=0
    while [ $i -lt 18 ]; do
      [ "$(grep -c 'lgtvsdp\.com' /etc/hosts)" -ge 150 ] && break
      luna-send -n 1 -w 20000 luna://org.webosbrew.appupdateblocker.service/addUpdateDomains '{}' >/dev/null 2>&1
      i=$((i + 1)); sleep 10
    done
  ) >/dev/null 2>&1 &
  ```

  To check it's working, count the entries (`grep -c lgtvsdp.com /etc/hosts`)
  and ping one of them. It should resolve to `127.0.0.1`.
