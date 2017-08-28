#!/usr/bin/env bash
set -e

INSTALL_TOOLS="build-essential libtool autoconf automake texinfo autotools-dev autoconf git"

HIDAPI_DEPENDENCIES="libudev-dev libusb-1.0-0-dev libfox-1.6-dev"
OPENOCD_DEPENDENCIES="libftdi-dev"

echo "Installing build tools and dependencies"
sudo apt-get update
sudo apt-get install  $INSTALL_TOOLS $HIDAPI_DEPENDENCIES $OPENOCD_DEPENDENCIES

echo "Creating temp folder"
rm -rf ~/temp_build_files
mkdir -p ~/temp_build_files
cd ~/temp_build_files

echo "Installing hidapi"
git clone git://github.com/signal11/hidapi.git hidapi
cd hidapi
# Fist time running booststrap fails because stuff
./bootstrap
./configure
make -j 4
sudo make install
cd ..

echo "Installing openocd"
git clone https://git.code.sf.net/p/openocd/code openocd-code
cd openocd-code
./bootstrap
./configure
make -j 4
sudo make install

# Copy udev rules and update
sudo cp ./contrib/60-openocd.rules /etc/udev/rules.d
sudo udevadm control --reload-rules && sudo udevadm trigger

# Remove source code
rm -rf ~/temp_build_files

# Test if install ok
openocd --version && echo "Install success" || echo "Install failed"
