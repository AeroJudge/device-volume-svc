# AeroJudge Device Volume Service

Volume/audio packages for AeroJudge judge devices. Device setup and updates
consume this package from its latest release. Existing volume installations
are preserved during app updates.

## Versions and hardware

| Version | Supported hardware | Status and instructions |
|---|---|---|
| [v1.0](https://github.com/AeroJudge/device-volume-svc/releases/tag/v1.0) | Legacy rotary volume knob; full PCB range unconfirmed | Preserved source; [historical README](https://github.com/AeroJudge/device-volume-svc/blob/v1.0/README.md) |
| [v2.0](https://github.com/AeroJudge/device-volume-svc/releases/tag/v2.0) | PCB 3.60 and 3.61, with the matching board configuration | Previous release; [version instructions](https://github.com/AeroJudge/device-volume-svc/blob/v2.0/README.md) |
| [v2.1](https://github.com/AeroJudge/device-volume-svc/releases/tag/v2.1) | PCB 3.60 and 3.61, with the matching board configuration | Current release, same runtime files as v2.0; the archive no longer includes this README. [Version instructions](https://github.com/AeroJudge/device-volume-svc/blob/v2.1/README.md) |

Use `vGENERATION.RELEASE`: v1 is the legacy rotary stack; v2 is the current
stack. Increment the release number for each change: v2.0, v2.1, v2.2.
`package.json` declares the version and exact supported PCB revisions. Keep the
table in sync; new board support requires matching wiring, boot configuration
and dependencies. Legacy code and its updater remain in `v1.0` history.

## Releasing

1. Work in a branch, update metadata and this table, and merge when ready.
2. Push a new `v2.*` tag matching the version in `package.json`.
3. The [workflow](.github/workflows/release.yml) checks source syntax and tag
   agreement, then publishes `volume_service.zip`, `package.json` and `SHA256SUMS`.

The ZIP contains `volume_service/` with runtime files and metadata.
Keep packaging to standard ZIP/checksum commands and preserve released tags/assets.
No separate builder or changelog is needed; the app retains its own changelog.

## Installation essentials

Setup/update scripts consume the published files. Publishing alone does not
update installed devices. Use the board's matching boot configuration and
dependencies:

```sh
sudo apt install alsa-utils python3-evdev evtest
```

Installed paths:

- `/usr/local/sbin/aerojudge-audio-hardware` ? root-owned hardware helper.
- `/etc/systemd/system/audio-hardware.service` and `/etc/systemd/system/volume.service`.
- `/var/opt/volume_service/volume.py` and `tone-*.wav`.
- `/boot/config.txt` ? board-specific GPIO/DAC configuration.

Fresh setup enables the services for the required reboot. App updates do not
replace an existing volume installation. The controls start at 80%, adjust within
65-100%, and provide directional tone feedback with hold/repeat support.

Verify checksums when downloading; they do not establish hardware compatibility.
Keep previous packages and matching boot configurations for recovery. Rolling
back the app JAR does not restore the audio stack. Fresh installation of v2.1
and audio/volume operation passed on PCB 3.61 device DPG-131 on 2026-10-22.
This does not establish new PCB 3.60 or legacy coverage.

## Diagnostics

```sh
systemctl status audio-hardware.service volume.service
journalctl -u audio-hardware.service -u volume.service -n 80 --no-pager
amixer -c sndrpihifiberry get Digital
sudo evtest
```
