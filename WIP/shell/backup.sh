#!/bin/bash
# This script automatically puts directories into a tarball and has the option of sending them to a remote server using scp
# scp should have password support, but an RSA key is highly reccomended (not only because it's seamless, it's more secure than a password!)



# Check if not running as root
if [ "$UID" -ne 0 ]; then
# Config file, points to where it should be.
config=~/.config/filebackup/configuration

# Get the current date
current_date=$(date +%-d )
mmddyydate=$(date +%m-%d-%y)

# Check Configuration
if [ ! -f "$config" ]; then
read -p "A configuration file was not found in ~/.config! Generate one now? (Y/N) : " ynp
if [ "$ynp" == Y ] || [ "$ynp" == y ]; then
# Start survey thingy
echo ""
echo "Enter directories to back up. (separated by space)"
echo ""
read -p "Directories to back up: " dirs
echo ""
read -p "Directory to store tarballs (if sending to remote server, this is temporary): " tarballdir
echo ""
read -p "Are these tarballs going to a remote server? (true/false): " remotelocation
# If the user answered true to $remotelocation
if [ "$remotelocation" == true ]; then
echo ""
read -p "Enter server address: " server
echo ""
read -p "Enter server port (default 22): " port
echo ""
read -p "Enter remote username: " username
echo ""
#read -s -p "Enter remote password (not echoed): " password
#echo ""
read -p "Enter remote directory: " remote_dir
echo ""
#read -p "Enter protocol to use (scp or rsync)" protocol
echo ""
# Create configuration file
echo "Attempting to create directory ~/.config/filebackup/"
mkdir ~/.config/filebackup/
touch configuration

# Write to configuration file

echo "tarballdir=$tarballdir" > "$config"
echo "dirs=('${dirs[0]}')" >> "$config"
echo "server=$server" >> "$config"
echo "port=$port" >> "$config"
echo "username=$username" >> "$config"
#echo "password=$password" >> "$config"
echo "dirs=(${dirs[@]})" >> "$config"
echo "remote_dir=$remote_dir" >> "$config"
#echo "protocol=$protocol" >> "$config"
echo "remotelocation=$remotelocation" >> "$config"
echo "Created configuration file: $config"
echo "Run the script again to back up files."
exit
else

# Create configuration file
mkdir ~/.config/filebackup/
touch configuration

# Write to configuration file
port=${port:-22}
server=${server:-0.0.0.0}
username=${username:-foo}
#password=${password:-abc123}
remote_dir=${remote_dir:-/home/foo/poo}
#protocol=${protocol:-scp}

echo "tarballdir=$tarballdir" > "$config"
echo "dirs=('${dirs[0]}')" >> "$config"
echo "server=$server" >> "$config"
echo "port=$port" >> "$config"
echo "username=$username" >> "$config"
#echo "password=$password" >> "$config"
echo "dirs=(${dirs[@]})" >> "$config"
echo "remote_dir=$remote_dir" >> "$config"
#echo "protocol=$protocol" >> "$config"
echo "remotelocation=$remotelocation" >> "$config"
echo "Created configuration file: $config"
echo "Run the script again to back up files."
exit
fi
echo "This script will not run without a configuration file. Exiting!"
echo ""
exit
fi
else
source "$config"

# Check if the current date is even or if the -F flag was used
if [ $((current_date % 2)) -ne 0 ] || [ "$1" == "-F" ]; then
    # Variables for later use
    dira=${#dirs[@]}
    sent=0
    user=$(whoami)
  read -p "Proceed with File Backup (may take a few minutes) [Y/N] : " answer

  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    # If user typed Y, then continue
    echo "Proceeding..."

    # If the $tarballdir is empty or incorrect, create a new directory for it.
    if [ ! -d "$tarballdir" ]; then
      mkdir "$tarballdir"
    fi

    # Create a tarball of all mentioned directories in dirs

    # If the user has $remotelocation set to true in their configuration file, proceed to send tars to the server inputted in their configuration file
    if [ "$remotelocation" == true ]; then
      echo "Attempting to send to remote server"
      echo "Sending $dira directory(ies)"
      sudo tar -czf "$mmddyydate-$user.tar.gz" "${dirs[@]}"
      scp -P "$port" "$mmddyydate-$user.tar.gz" "$username@$server:$remote_dir"
      sudo rm "$mmddyydate-$user.tar.gz"
      exit
       # done
      else
    for dir in "${dirs[@]}"; do
      sudo tar -czf "$tarballdir/$mmddyydate-$user.tar.gz"
      echo "Compressing directory ${dir}."
    done
      exit
    fi
  else
    # Don't do it if it's anything other than Y or y
    echo "Exiting via user action."
    exit
  fi
fi
fi
else
# If the user runs the script as root, it will skip everything and echo this.
echo "Don't run this as root!"
exit
fi
