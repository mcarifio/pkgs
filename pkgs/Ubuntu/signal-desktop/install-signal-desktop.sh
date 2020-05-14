#!/usr/bin/env bash

curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo "deb [arch=amd64] https://updates.signal.org/desktop/apt $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/signal-$(lsb_release -sc).list
sudo apt update && sudo apt install signal-desktop
