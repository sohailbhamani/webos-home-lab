# Rooting (use the public community tools)

This repo does **not** ship an exploit. Rooting an LG TV is a solved, documented
community process, and you should use the maintained tools rather than anything
hand-rolled. Everything else in this repo runs *after* your TV is rooted.

## Check your model first

Rootability depends on the exact model and firmware. Look yours up at:

- **<https://cani.rootmy.tv/>** — enter your model/firmware, it tells you which
  exploit (if any) applies and at what firmware it was patched.

If your firmware is newer than the patch version for every exploit, you can't
root it, and **you must not let a rootable TV auto-update past that line.** Turn
off *Settings → General → Software Update → Auto Update* before you start.

## The tools (all public, all maintained)

- **Homebrew Channel** — <https://github.com/webosbrew/webos-homebrew-channel>
  The app store + root manager you install once the exploit lands. Everything
  else is installed through it.
- **webOS Homebrew project** — <https://www.webosbrew.org/> — hub for the above,
  the app catalogue, and current instructions.
- **root.my.tv** — <https://rootmy.tv/> — the guided, step-by-step rooting flow
  for supported models.

Follow their instructions for your model. When you're done you'll have root SSH
and the Homebrew Channel, which is all this repo assumes.

## After rooting — the baseline this repo expects

Install these through the Homebrew Channel (all optional, but referenced here):

- **App Update Blocker** — stops LG re-updating apps (including your patched
  home app's neighbours) out from under you.
- **Life's Good Without Spying** / **Glasshouse** — privacy/telemetry and
  debloat dashboards. Nice to have; not required for the home-screen work.

You also want, from the TV, root SSH working. Keep the connection details and
keys **out of this repo** — they're specific to your TV.

## Don't

- Don't point any of this at a TV you don't own.
- Don't paste firmware images or keys into a public repo.
- Don't skip the backup step in the home-screen docs. Rolling back a bad UI edit
  is a 5-second restore *if* you kept the stock files.
