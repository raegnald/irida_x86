#!/bin/sh

./build.sh &&
sudo mkdir -p /usr/local/irida &&
sudo cp -r ./libraries/ /usr/local/irida &&
sudo cp -r ./irida.exe /usr/local/irida/irida &&
sudo ln -s /usr/local/irida/irida /bin/irida