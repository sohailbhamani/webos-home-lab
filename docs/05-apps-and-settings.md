# Apps we install, and why

The home-screen patches are half the job. The other half is a small set of
homebrew apps and a privacy pass. This is the set we install, all through the
Homebrew Channel once the TV is rooted. Everything here is free and open-source.
On webOS 7, Glasshouse isn't in the Homebrew Channel list and App Update Blocker
needs a boot retry. See [`06-webos7.md`](06-webos7.md).

## The set

| App | Package id | Why we install it |
|-----|-----------|-------------------|
| Homebrew Channel | `org.webosbrew.hbchannel` | The store and root manager. Everything else installs through it. First thing on. |
| App Update Blocker | `org.webosbrew.appupdateblocker` | Stops LG silently re-updating apps, including the ones next to our patched home app, which can undo customizations or re-enable telemetry. On early. |
| YouTube AdFree | `youtube.leanback.v4` | Ad-free YouTube ([`youtube-webos`](https://github.com/webosbrew/youtube-webos)). The biggest day-to-day win. |
| Glasshouse | `io.github.rorygallagher2024.lg-webos-dashboard` | Debloat and privacy dashboard: disable LG background services, block ~78 LG ad/telemetry domains, flip the consent toggles off in one place. On webOS 6.x LG's built-in apps live on the read-only system partition, so they can't be truly uninstalled, only disabled or hidden. |
| Life's Good Without Spying | `ooo.lew.lifesgoodwithoutspying` | Turns off LG's data collection and telemetry at the service level. It works alongside Glasshouse's domain blocking. |
| VNC Server | `org.webosbrew.vncserver` | See and capture the screen from a laptop. Very handy while iterating on the home-screen UI (and for screenshots). Its launcher icon is hidden by patch `06`, but it stays installed. |

Keep versions current through the Homebrew Channel. It keeps your settings across
an update.

## Privacy / debloat pass (do once)

1. Turn off auto-update on the TV first: *Settings → General → Software
   Update → Auto Update off.* On a rootable TV, a firmware bump can patch the
   exploit, so never let it update past your rooted firmware.
2. Glasshouse → Privacy tab: switch every consent/promo toggle off and enable
   ad-domain blocking.
3. Life's Good Without Spying: enable it, to kill telemetry at the service layer.
   Then turn two of its options **off**: *Ads & ACR* (`ads.stop`) and
   *LG service platform* (`domains.sdp`). HBO Max needs both (see below).
4. App Update Blocker: leave it on so none of the above gets reverted.

After this pass plus the home-screen patches, the TV shows your content and your
background. No ads, no promos, no "recommended for you", and the known LG ad,
ACR and telemetry domains are blocked. The TV still reaches LG's service
platform (SDP) domains, which HBO Max needs.

## Not installed by default, but worth it

- LG Input Hook: remap the remote's Home button to open your launcher or an app
  instead of LG's home. Pairs well with a custom home experience.
- hyperion-webos / PicCap: ambilight, driving LED strips or Hue bulbs from the
  screen contents.
- Jellyfin / Kodi: local media servers, installable as `.ipk`s.
- Your own app, e.g. a weather/radar dashboard. See
  [`04-going-further.md`](04-going-further.md).

## Store apps (Netflix, Prime, etc.)

These come from LG's store and can't be version-checked from the shell, and the
App Update Blocker stops them auto-updating. If one misbehaves, toggle the
blocker off for a single manual update, then back on.

### HBO Max stuck on its logo

Symptom: HBO Max shows its logo and a spinner forever, or "Can't connect to HBO
Max". Both come from Life's Good Without Spying defaults:

- *Ads & ACR* (`ads.stop`) stubs out LG's ad manager plus the ACR, nudge and
  upload services. HBO Max waits on one of them at launch, so it spins forever.
- *LG service platform* (`domains.sdp`) blocks LG's service platform (SDP)
  domains. With those blocked, HBO Max gets "Can't connect".

Fix: in the app, turn both options off and apply. Over SSH, the same thing is:

```sh
C=/var/lib/webosbrew/lifesgoodwithoutspying.conf
[ -f "$C" ] && cp "$C" "$C.bak"
printf 'ads.stop=off\ndomains.sdp=off\n' >> "$C"
/var/lib/webosbrew/init.d/50-lifesgoodwithoutspying
```

Re-running the hook removes the stubs and the SDP block (check with
`mount | grep admanager`, which should print nothing). Those services run again,
but the known ad, ACR and telemetry domains stay blocked and the consents stay
off. The setting survives reboots.

If another streaming app hangs the same way, test the same two options first.

### Finding which block broke an app

When an app hangs or can't connect, test the two kinds of block one at a time.
Both checks are temporary; re-running the hook (last step) restores everything.

1. **Domain block.** Lift it and relaunch the app:
   ```sh
   while mount | grep -q ' /etc/hosts '; do umount /etc/hosts || break; done
   ```
   If the app now works, a blocked domain category is the cause. Restore
   (step 3), then turn categories off in the app a few at a time until the app
   works. The domain lists are in the app's `init/blocklist.d/`.
2. **Stubbed services.** The services the app stubbed out are listed in
   `/var/lib/webosbrew/lifesgoodwithoutspying.stubbed`, and each one is a bind
   mount. `umount` one, relaunch the app, and see whether it gets further.
3. **Restore.** Run `/var/lib/webosbrew/init.d/50-lifesgoodwithoutspying`. It
   puts back the block and the stubs from your saved settings. Then make the
   real change in the app, so it sticks.
