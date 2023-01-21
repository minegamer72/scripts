#! /bin/bash
# This is my first bash script. #
# I use this for updating all of my packages on my arch *snort* install. #
# Requirements: flatpak, yay, pacman #
#
# For people who use a distro with apt: You will need to remove the entire if statement on line 38 > 48 and replace
# the if statement on line 27 > 36 to be apt update && apt upgrade or whatever update command it is now. #

# check if running as root #
if [ "$EUID" == 0 ]
  then echo "DO NOT RUN THIS WITH ROOT UNLESS YOU ABSOLUTELY NEED TO!! "
echo

# prompt for continuing anyway #

read -p "CONTINUE ANYWAY?" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
echo
exit
fi
fi
echo

# prompt pacman update #

read -p "update pacman packages? Y or N (case insensitive) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
echo "skipping pacman -Syu"
echo
else
sudo pacman -Syu -y
echo
fi

# prompt update yay packages #

read -p "update yay packages? Y or N (case insensitive) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then echo "skipping yay -Syu"
echo
else
yay -Syu -y
echo
fi

# prompt update flatpak packages #

if [ "$EUID" == 0 ] # check if root #
then
echo "skipping flatpak update due to script being ran as root" # stop the script from updating flatpak packages as root #
echo
else

read -p "update flatpak packages? Y or N (case insensitive) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then echo "skipping command flatpak update"
echo

else
flatpak update
echo
fi
fi

read -p "reboot? Y or N (case insensitive) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then echo "not rebooting"
echo
exit
else
reboot
fi

