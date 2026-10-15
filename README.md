# AeroJudge Device Volume Service

Volume/audio packages for AeroJudge judge devices. During migration, the app
repository still supplies production setup and packages; this repository holds
the separate v2 package with the same runtime files.

## Versions and hardware

| Version | Supported hardware | Status and instructions |
|---|---|---|
| [v1.0](https://github.com/AeroJudge/device-volume-svc/releases/tag/v1.0) | Legacy rotary volume knob; full PCB range unconfirmed | Preserved source; [historical README](https://github.com/AeroJudge/device-volume-svc/blob/v1.0/README.md) |
| [v2.0](https://github.com/AeroJudge/device-volume-svc/releases/tag/v2.0) | PCB 3.60 and 3.61, with the matching board configuration | Current release; [version instructions](https://github.com/AeroJudge/device-volume-svc/blob/v2.0/README.md) |

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

The ZIP contains `volume_service/` with six runtime files, this README and metadata.
Keep packaging to standard ZIP/checksum commands and preserve released tags/assets.
No separate builder or changelog is needed; the app retains its own changelog.
During migration, compare runtime changes with the app's `volume_service/`.

## Installation essentials

Setup/update scripts will consume the published files. Publishing does not update
devices or setup pins. Use the board's matching boot configuration and dependencies:

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
back the app JAR does not restore the audio stack. No new physical-device testing
is claimed by this repository migration.

## Diagnostics

```sh
systemctl status audio-hardware.service volume.service
journalctl -u audio-hardware.service -u volume.service -n 80 --no-pager
amixer -c sndrpihifiberry get Digital
sudo evtest
```
