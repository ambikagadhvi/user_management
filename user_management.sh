#!/bin/bash

# Function to create a new user
create_user() {
  local username=$1
  local groupname=$2
  echo "Creating user '$username' with group '$groupname'..."
  
  # Add group if it doesn't exist
  if ! getent group "$groupname" > /dev/null; then
    echo "Group '$groupname' does not exist. Creating it..."
    groupadd "$groupname"
  fi

  # Add user and assign to group
  if ! id "$username" > /dev/null 2>&1; then
    useradd -m -g "$groupname" -s /bin/bash "$username"
    echo "User '$username' created and added to group '$groupname'."
  else
    echo "User '$username' already exists."
  fi
}

# Function to set permissions on a directory
set_permissions() {
  local dir=$1
  local groupname=$2
  echo "Setting permissions for directory '$dir' for group '$groupname'..."
  
  # Create directory if it doesn't exist
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    echo "Directory '$dir' created."
  fi
  
  # Change group ownership and set permissions
  chown :$groupname "$dir"
  chmod 770 "$dir"
  echo "Permissions set: '$dir' owned by group '$groupname' with rwx access."
}

# Function to generate a report of users and groups
generate_report() {
  echo "Generating user and group report..."
  echo "=== User and Group Report ===" > user_report.txt
  echo "Date: $(date)" >> user_report.txt
  echo >> user_report.txt
  echo "Users:" >> user_report.txt
  awk -F':' '{ print $1 }' /etc/passwd >> user_report.txt
  echo >> user_report.txt
  echo "Groups:" >> user_report.txt
  awk -F':' '{ print $1 }' /etc/group >> user_report.txt
  echo "Report saved as 'user_report.txt'."
}

# Main script execution
echo "User Management System"
echo "1. Create User"
echo "2. Set Directory Permissions"
echo "3. Generate Report"
echo "4. Exit"
read -p "Choose an option: " choice

case $choice in
  1)
    read -p "Enter username: " username
    read -p "Enter group name: " groupname
    create_user "$username" "$groupname"
    ;;
  2)
    read -p "Enter directory path: " dir
    read -p "Enter group name: " groupname
    set_permissions "$dir" "$groupname"
    ;;
  3)
    generate_report
    ;;
  4)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid option. Exiting..."
    exit 1
    ;;
esac
