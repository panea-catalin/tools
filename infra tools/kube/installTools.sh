#!/bin/bash

# Define log file
LOG_FILE="installation_report.log"
echo "Installation Report - $(date)" > $LOG_FILE

# Define colors for summary
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
        SUMMARY+=("${RED}$2 installation failed${NC}")
    else
        echo "Success: $1" | tee -a $LOG_FILE
        SUMMARY+=("${GREEN}$2 installed successfully${NC}")
    fi
}

# Function to check if a package is installed and its version
check_package() {
    PKG=$1
    PKG_NAME=$2
    VERSION_COMMAND=$3

    if dpkg -l | grep -q $PKG; then
        VERSION=$(eval $VERSION_COMMAND)
        echo "$PKG_NAME is already installed, version: $VERSION" | tee -a $LOG_FILE
        SUMMARY+=("${YELLOW}$PKG_NAME already installed, version: $VERSION${NC}")
        return 0
    else
        return 1
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update and upgrade the system
log_command "sudo apt update && sudo apt upgrade -y" "System update and upgrade"

# Install dependencies
log_command "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release" "Dependencies"

# Install Visual Studio Code
if ! command_exists code; then
    log_command "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg" "VS Code Key Download"
    log_command "sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/packages.microsoft.gpg" "VS Code Key Install"
    log_command "sudo sh -c 'echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main\" > /etc/apt/sources.list.d/vscode.list'" "VS Code Repository Add"
    log_command "sudo apt update" "VS Code Repository Update"
    log_command "sudo apt install -y code" "Visual Studio Code"
else
    VERSION=$(code --version | head -n 1)
    SUMMARY+=("${YELLOW}Visual Studio Code already installed, version: $VERSION${NC}")
fi

# Install Python
if ! command_exists python3; then
    log_command "sudo apt install -y python3 python3-pip" "Python3"
else
    VERSION=$(python3 --version)
    SUMMARY+=("${YELLOW}Python3 already installed, version: $VERSION${NC}")
fi

# Install Docker
if ! command_exists docker; then
    log_command "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg" "Docker Key Download"
    log_command "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null" "Docker Repository Add"
    log_command "sudo apt update" "Docker Repository Update"
    log_command "sudo apt install -y docker-ce docker-ce-cli containerd.io" "Docker"
    log_command "sudo usermod -aG docker $USER" "Docker Usermod"
else
    VERSION=$(docker --version)
    SUMMARY+=("${YELLOW}Docker already installed, version: $VERSION${NC}")
fi

# Install kubectl
if ! command_exists kubectl; then
    log_command "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"" "kubectl binary download"
    log_command "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256\"" "kubectl checksum download"
    log_command "echo \"$(cat kubectl.sha256)  kubectl\" | sha256sum --check" "kubectl binary validation"
    log_command "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl" "kubectl install"
    rm kubectl.sha256
else
    VERSION=$(kubectl version --client --output=yaml | grep gitVersion | awk '{print $2}')
    SUMMARY+=("${YELLOW}kubectl already installed, version: $VERSION${NC}")
fi

# Install Git
if ! command_exists git; then
    log_command "sudo apt install -y git" "Git"
else
    VERSION=$(git --version | head -n 1)
    SUMMARY+=("${YELLOW}Git already installed, version: $VERSION${NC}")
fi

# Display summary
echo -e "\nInstallation Summary:"
for entry in "${SUMMARY[@]}"; do
    echo -e $entry
done

# Final message
echo -e "\nInstallation completed. Check $LOG_FILE for details."

