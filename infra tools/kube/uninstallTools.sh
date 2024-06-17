#!/bin/bash

# Define log file
LOG_FILE="uninstallation_report.log"
echo "Uninstallation Report - $(date)" > $LOG_FILE

# Define colors for summary
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Summary array
SUMMARY=()

# Function to log output of each command and record summary
log_command() {
    echo "Running: $1" | tee -a $LOG_FILE
    eval $1 >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed" | tee -a $LOG_FILE
        SUMMARY+=("${RED}$2 uninstallation failed${NC}")
    else
        echo "Success: $1" | tee -a $LOG_FILE
        SUMMARY+=("${GREEN}$2 uninstalled successfully${NC}")
    fi
}

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q $1
    return $?
}

# Uninstall Visual Studio Code
if is_installed "code"; then
    log_command "sudo apt remove -y code" "Visual Studio Code"
    log_command "sudo rm -f /etc/apt/sources.list.d/vscode.list" "Visual Studio Code repository list removal"
else
    SUMMARY+=("${GREEN}Visual Studio Code is not installed${NC}")
fi

# Uninstall Python (if installed by this script)
if is_installed "python3"; then
    log_command "sudo apt remove -y python3 python3-pip" "Python3"
else
    SUMMARY+=("${GREEN}Python3 is not installed${NC}")
fi

# Uninstall Docker
if is_installed "docker-ce"; then
    log_command "sudo apt remove -y docker-ce docker-ce-cli containerd.io" "Docker"
    log_command "sudo rm -f /etc/apt/sources.list.d/docker.list" "Docker repository list removal"
    log_command "sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg" "Docker GPG key removal"
    if getent group docker >/dev/null; then
        log_command "sudo groupdel docker" "Docker group removal"
    else
        SUMMARY+=("${GREEN}Docker group does not exist${NC}")
    fi
else
    SUMMARY+=("${GREEN}Docker is not installed${NC}")
fi

# Uninstall kubectl
if [ -f /usr/local/bin/kubectl ]; then
    log_command "sudo rm -f /usr/local/bin/kubectl" "kubectl binary removal"
else
    SUMMARY+=("${GREEN}kubectl is not installed${NC}")
fi

# Uninstall Git
if is_installed "git"; then
    log_command "sudo apt remove -y git" "Git"
else
    SUMMARY+=("${GREEN}Git is not installed${NC}")
fi

# Clean up any unused packages and dependencies
log_command "sudo apt autoremove -y" "Package autoremove"

# Display summary
echo -e "\nUninstallation Summary:"
for entry in "${SUMMARY[@]}"; do
    echo -e $entry
done

# Final message
echo -e "\nUninstallation completed. Check $LOG_FILE for details."

