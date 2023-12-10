#!/bin/bash

# Define the web root directory
WEB_ROOT="/var/www/"

# Get a list of directories in the web root
echo "Available websites:"
sites=($WEB_ROOT*/)
for i in "${!sites[@]}"; do 
  echo "$i: ${sites[$i]}"
done

# Prompt the user to choose a website to remove
echo "Enter the number of the website you want to remove:"
read -r choice

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Invalid selection: Input is not a number."
    exit 1
fi

# Check if the choice is within the array index
if (( choice < 0 || choice >= ${#sites[@]} )); then
    echo "Invalid selection: Number is out of range."
    exit 1
fi

# Confirm removal
echo "You have selected to remove: ${sites[$choice]}"
echo "WARNING: This will delete all files for this website and cannot be undone!"
echo "Type 'confirm' to proceed:"
read -r confirmation

if [ "$confirmation" == "confirm" ]; then
  # Extract domain name from the directory path
  domain=$(basename "${sites[$choice]}")

  # Disable the site, delete files, and drop the database
  sudo a2dissite "$domain.conf" && \
  sudo systemctl reload apache2 && \
  sudo rm -rf "${sites[$choice]}" && \
  sudo rm "/etc/apache2/sites-available/$domain.conf" && \
  echo "Site files and configuration for $domain have been removed."

  # Drop database and user (replace with your own logic for database/user naming)
  echo "Dropping the database and user, please enter the MySQL root password:"
  DB_NAME="${domain//./_}_db"
  DB_USER="${domain//./_}_user"
  mysql -u root -p -e "DROP DATABASE IF EXISTS $DB_NAME; DROP USER IF EXISTS '$DB_USER'@'localhost';"
  echo "Database and user for $domain have been removed."
else
  echo "Removal canceled."
fi
