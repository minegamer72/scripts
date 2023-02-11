#! /bin/bash
# This is my first bash script. #
# I use this for updating all of my packages on my arch *snort* install. #
# Requirements: flatpak, yay, pacman #
#
# For people who use a distro with apt: You will need to remove the entire if statement on line 34 > 43 and replace
# the if statement on line 23 > 32 to be apt update && apt upgrade or whatever update command it is now. #

# Check if running as root
if [ "$EUID" == 0 ]; then
  echo "DO NOT RUN THIS WITH ROOT UNLESS YOU ABSOLUTELY NEED TO!"
  echo

  # Prompt for continuing anyway
  read -p "CONTINUE ANYWAY? (Y/N): " -n 1 -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo
    exit
  fi
fi
echo

# Prompt for updating pacman packages
read -p "Update pacman packages? (Y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Skipping pacman -Syu"
  echo
else
  sudo pacman -Syu -y
  echo
fi

# Prompt for updating yay packages
read -p "Update yay packages? (Y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Skipping yay -Syu"
  echo
else
  yay -Syu -y
  echo
fi

# Prompt for updating flatpak packages
if [ "$EUID" == 0 ]; then
  echo "Skipping flatpak update due to script being ran as root"
  echo
else
  read -p "Update flatpak packages? (Y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Skipping command flatpak update"
    echo
  else
    flatpak update
    echo
  fi
fi

# Prompt for rebooting
read -p "Reboot? (Y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Not rebooting"
  echo
  exit
else
  reboot
fi
