#!/bin/bash
# This shell script isn't formatted correctly and a part of it hasn't been tested.
# This script automatically puts directories into a tarball and has the option of sending them to a remote server using scp or rsync.
# Untested: Sending files over scp or rsync, I should have it tested by the end of this weekend.

# Config file, points to where it should be.

config=~/.config/filebackup/configuration

# Get the current date
current_date=$(date +%-d )

# Check if not running as root
if [ "$UID" -ne 0 ]; then

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
read -s -p "Enter remote password (not echoed): " password
echo ""
read -p "Enter remote directory: " remote_dir
echo ""
read -p "Enter protocol to use (scp or rsync)" protocol
echo ""
# Create configuration file
echo "Attempting to create directory ~/.config/filebackup/"
mkdir ~/.config/filebackup/
cd filebackup/
echo "Attempting to create file ~/.config/filebackup/configuration"
touch configuration


echo "Attempting to write to file ~/.config/filebackup/configuration"
# Write to configuration file

echo "tarballdir=$tarballdir" > "$config"
echo "dirs=('${dirs[0]}')" >> "$config"
echo "server=$server" >> "$config"
echo "port=$port" >> "$config"
echo "username=$username" >> "$config"
echo "password=$password" >> "$config"
echo "dirs=(${dirs[@]})" >> "$config"
echo "remote_dir=$remote_dir" >> "$config"
echo "protocol=$protocol" >> "$config"
echo "remotelocation=$remotelocation" >> "$config"
echo "Created configuration file: $config"
echo "Run the script again to back up files."
exit
else

# Create configuration file
echo "Attempting to create directory ~/.config/filebackup"
mkdir ~/.config/filebackup/
echo "Attempting to create file ~/.config/filebackup/configuration"
touch configuration

echo "Attempting to write to file ~/.config/filebackup/configuration"

# Write to configuration file
port=${port:-22}
server=${server:-0.0.0.0}
username=${username:-foo}
password=${password:-abc123}
remote_dir=${remote_dir:-/home/foo/poo}
protocol=${protocol:-scp}

echo "$tarballdir"
echo "tarballdir=$tarballdir" > "$config"
echo "dirs=('${dirs[0]}')" >> "$config"
echo "server=$server" >> "$config"
echo "port=$port" >> "$config"
echo "username=$username" >> "$config"
echo "password=$password" >> "$config"
echo "dirs=(${dirs[@]})" >> "$config"
echo "remote_dir=$remote_dir" >> "$config"
echo "protocol=$protocol" >> "$config"
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

# Check if the current date is even
if [ $((current_date % 2)) -ne 0 ] || [ "$1" == "-F" ]; then

  read -p "Proceed with File Backup (may take a few minutes) [Y/N] : " answer

  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    # Start to back up files
    echo "Proceeding..."

    if [ ! -d "$tarballdir" ]; then
      mkdir "$tarballdir"
    fi

    # Create a tarball of all mentioned directories in dirs
    
    for dir in "${dirs[@]}"; do
      sudo tar -czf "$tarballdir/${dir//\//_}.tar.gz" "$dir"
      echo "Compressing directory ${dir}."
    done

    if [ "$remotelocation" == true ]; then
      echo "Attempting to send to remote server"
      echo ""

      # Check if the protocol is valid
      if [ "$protocol" != "scp" ] && [ "$protocol" != "rsync" ]; then
        echo "Error: Invalid protocol in configuration, use either scp or rsync!"
        exit
      else
        # If the protocol is valid, then continue
        for file in "${dirs[@]}"; do
          # Send the tar archive to the remote directory
          if [ "$protocol" == "scp" ]; then
            scp "$tarballdir/${dir//\//_}.tar.gz" "$remote_dir"
            rm -r $tarballdir/*.tar.gz
          elif [ "$protocol" == "rsync" ]; then
            rsync -avz "$tarballdir/${dir//\//_}.tar.gz" "$remote_dir"
            rm -r $tarballdir/*.tar.gz
            # probably going to remove this else statement later because it's unneeded
            else
            echo "Error: Invalid protocol in configuration, use either scp or rsync! 1"
            exit
          fi
        done
      fi
      else
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
echo "Don't run this as root!"
fi
