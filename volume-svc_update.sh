#!/bin/bash

if [ ! -f ".judge_volume_svc_ver" ]; then
  touch ".judge_volume_svc_ver"
fi

last_release=$(cat .judge_volume_svc_ver)

latest_release=$(curl --silent --fail -G https://api.github.com/repos/AeroJudge/judge-volume-svc/releases/latest)
if [ $? -ne 0 ]; then
   echo "Error fetching latest volume service release (no internet?)!" >&2
   exit 1
fi

latest_tag=$(echo $latest_release | grep -oP '"tag_name": "(.*?)"' | cut -d' ' -f2 | tr -d [\"])
if [ $? -ne 0 ]; then
   echo "Error parsing feed!" >&2
   exit 1
fi

if [ "$latest_tag" != "$last_release" ]; then
    echo "New volume service release found: $latest_tag"
    echo "Previous release: $last_release"

    echo $latest_tag > .judge_volume_svc_ver

    # Clean up volume_service folder
    sudo mkdir -p /var/opt/volume_service
    sudo rm -f /var/opt/volume_service/*

    echo "Getting assets list..."
    assets_url=$(echo $latest_release | grep -oP '"assets_url": "(.*?)"' | cut -d' ' -f2 | tr -d [\"])
    if [ $? -ne 0 ]; then
       echo "Error parsing for assets url!" >&2
       exit 1
    fi

    assets=$(curl --silent --fail -G $assets_url | grep download_url | tr -d [\"] | cut -d' ' -f6)
    if [ $? -ne 0 ]; then
       echo "Error fetching assets feed!" >&2
       exit 1
    fi

    for asset_url in $assets
    do
        filename=$(basename "$asset_url")
        echo "Downloading: $filename"
        
        if [[ "$filename" == "volume.py" ]]; then
            # Download volume.py to /var/opt/volume_service/
            curl --silent --fail -L "$asset_url" -o /tmp/volume.py
            if [ $? -ne 0 ]; then
                echo "Error downloading $filename!" >&2
                exit 1
            fi
            sudo mv /tmp/volume.py /var/opt/volume_service/
            sudo chown -R judge:judge /var/opt/volume_service
            sudo chmod +x /var/opt/volume_service/volume.py
            
        elif [[ "$filename" == "volume.service" ]]; then
            # Only deploy volume.service if it doesn't exist
            if [ ! -f /etc/systemd/system/volume.service ]; then
                curl --silent --fail -L "$asset_url" -o /tmp/volume.service
                if [ $? -ne 0 ]; then
                    echo "Error downloading $filename!" >&2
                    exit 1
                fi
                sudo mv /tmp/volume.service /etc/systemd/system/
            else
                echo "volume.service already exists in /etc/systemd/system/, skipping..."
            fi
        fi
    done

    sudo systemctl daemon-reload
    
    # Enable and start (or restart) the service
    if sudo systemctl list-unit-files | grep -q "^volume.service"; then
        echo "Restarting volume service..."
        sudo systemctl restart volume.service
    else
        echo "Enabling and starting volume service..."
        sudo systemctl enable volume.service
        sudo systemctl start volume.service
    fi

else
    echo "Latest version already installed"
fi

exit 0