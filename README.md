# Volume Service Update

This directory contains the update script for the IMAC Judge Volume Service.

## Assets

The GitHub release includes the following assets:

- `volume.py` - The main Python service file
- `volume.service` - The systemd service file
- `volume-svc_update.sh` - The update script (this file)

## Installation

The update script is typically run automatically by the Judge system. However, if you need to manually update the update script itself, follow these steps:

### Manual Update of the Update Script

1. Download the latest `volume-svc_update.sh` from the [releases page](https://github.com/AeroJudge/judge-volume-svc/releases/latest):

```bash
curl -L https://github.com/AeroJudge/judge-volume-svc/releases/latest/download/volume-svc_update.sh -o /tmp/volume-svc_update.sh
```

2. Move it to the judge home directory and set permissions:

```bash
sudo mv /tmp/volume-svc_update.sh /home/judge/
sudo chown judge:judge /home/judge/volume-svc_update.sh
sudo chmod +x /home/judge/volume-svc_update.sh
```

3. Run the update script to fetch and deploy the latest volume service:

```bash
/home/judge/volume-svc_update.sh
```

## How It Works

The `volume-svc_update.sh` script:

1. Checks the latest GitHub release for new versions
2. Downloads the release assets (`volume.py` and optionally `volume.service`)
3. Deploys `volume.py` to `/var/opt/volume_service/`
4. Deploys `volume.service` to `/etc/systemd/system/` (only if it doesn't exist)
5. Reloads systemd and restarts the volume service

## Version Tracking

The script maintains a `.judge_volume_svc_ver` file to track which release version is currently installed.
