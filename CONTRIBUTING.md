# Contributing / house rules

This repo documents modifying your own TV. Keep it clean and free of leaks.

## Never commit

- Private keys of any kind (`webos_rsa`, SSH keys, `.pem`). `.gitignore` and
  gitleaks block them. Don't override that.
- Device specifics: your TV's IP, MAC, SSH password or passphrase. The docs use
  the placeholder `root@<tv-ip>`, so keep it that way.
- LG's stock QML (`stock-qml/`, `*-qml/`). It's LG's copyrighted code, and you
  extract it from your own TV. Only our patches (diffs) belong here.
- Firmware or packages (`.ipk`, `.img`, `.bin`, `.epk`).

## Before you push

```sh
pre-commit install        # one time; runs gitleaks + checks on every commit
pre-commit run --all-files
```

CI (`.github/workflows/ci.yml`) re-runs the same guards on every push and PR:
gitleaks, a tracked-file guard (no keys, firmware or stock QML), and a shell
parse check. A red check means something leaked or broke, so fix it before
merging.

## Changes

- One logical change per patch, against the stock baseline, tagged in-line.
- Test on a real TV one step at a time. Never push an untested QML edit.
- Update `docs/03-the-edits.md` when you add or change a patch.
