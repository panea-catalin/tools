# Package Installation Script

This bash script installs specified packages on your system and outputs the result in a formatted table. The output includes a green dot (●) for successfully installed packages and a red cross (✖) for failed installations, along with the package name, path, or an error message if the installation fails. Detailed output is logged to a file.

## Script Description

The script performs the following steps:
1. Updates and upgrades the system.
2. Installs a list of specified packages required for setting up the Flutter environment and for developing Linux apps.
3. Logs detailed output to a logfile.
4. Checks if each package was installed successfully and prints the results in a table with three columns:
   - Status (● for installed, ✖ for failed)
   - Package Name
   - Path or Error Message

## Usage

1. Save the script to a file (e.g., `install_packages.sh`).
2. Make the script executable:
    ```bash
    chmod +x install_packages.sh
    ```
3. Run the script:
    ```bash
    ./install_packages.sh
    ```
4. Check the `install_packages.log` file for detailed output and error messages.

## Script Code

```bash
#!/bin/bash

LOGFILE="install_packages.log"

# Update and upgrade the system
sudo apt-get update -y >>"$LOGFILE" 2>&1 && sudo apt-get upgrade -y >>"$LOGFILE" 2>&1

# Define the list of packages to install
packages=(
    "curl" "git" "unzip" "xz-utils" "zip" "libglu1-mesa"
    "clang" "cmake" "ninja-build" "pkg-config" "libgtk-3-dev" "libstdc++-12-dev"
)

# Function to check the installation of non-binary packages
check_non_binary_package() {
    local package=$1
    dpkg -s "$package" &>/dev/null && echo "Installed" || echo "Not installed"
}

# Function to install a package and check the result
install_package() {
    local package=$1
    local path
    if sudo apt-get install -y "$package" >>"$LOGFILE" 2>&1; then
        path=$(which "$package" 2>/dev/null)
        if [ -n "$path" ]; then
            printf "\e[32m●\e[0m\t%-15s\t%s\n" "$package" "$path"
        else
            # Check for non-binary packages
            if [[ "$package" =~ ^(xz-utils|libglu1-mesa|libgtk-3-dev|libstdc++-12-dev)$ ]]; then
                status=$(check_non_binary_package "$package")
                if [ "$status" == "Installed" ]; then
                    printf "\e[32m●\e[0m\t%-15s\t%s\n" "$package" "Installed, but no binary path"
                else
                    printf "\e[31m✖\e[0m\t%-15s\t%s\n" "$package" "Installation failed"
                fi
            else
                printf "\e[32m●\e[0m\t%-15s\t%s\n" "$package" "Installed, but no binary path"
            fi
        fi
    else
        printf "\e[31m✖\e[0m\t%-15s\t%s\n" "$package" "Installation failed"
    fi
}

# Iterate over the list of packages and install each one
for package in "${packages[@]}"; do
    install_package "$package"
done

