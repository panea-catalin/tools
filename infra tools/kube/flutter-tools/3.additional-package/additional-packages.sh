#!/bin/bash

LOGFILE="install_android_sdk.log"
ANDROID_SDK_ROOT="$HOME/Android/Sdk"

# Check if Java is installed
if ! java -version &>/dev/null; then
    echo "Java is not installed. Installing Java..."
    sudo apt-get update -y >>"$LOGFILE" 2>&1
    sudo apt-get install -y openjdk-11-jdk >>"$LOGFILE" 2>&1
fi

# Set JAVA_HOME
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export JAVA_HOME

# Add JAVA_HOME and java to PATH
export PATH="$JAVA_HOME/bin:$PATH"

# Create Android SDK directory
mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"

# Download and install Android SDK command-line tools
cd "$ANDROID_SDK_ROOT"
wget https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip -O commandlinetools.zip >>"$LOGFILE" 2>&1
unzip -o commandlinetools.zip -d cmdline-tools >>"$LOGFILE" 2>&1
if [ -d "cmdline-tools/latest" ]; then
    rm -rf cmdline-tools/latest/*
else
    mkdir cmdline-tools/latest
fi
mv cmdline-tools/cmdline-tools/* cmdline-tools/latest/
rm -rf cmdline-tools/cmdline-tools
rm commandlinetools.zip

# Add cmdline-tools to PATH
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

# Clean up any duplicate platform-tools directories
if [ -d "$ANDROID_SDK_ROOT/platform-tools-2" ]; then
    rm -rf "$ANDROID_SDK_ROOT/platform-tools-2"
fi

# Accept licenses
yes | sdkmanager --licenses >>"$LOGFILE" 2>&1

# Install required packages
sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3" "extras;google;m2repository" "extras;android;m2repository" >>"$LOGFILE" 2>&1

# Install additional packages
sdkmanager "emulator" "patcher;v4" "tools" >>"$LOGFILE" 2>&1

# Install Android system images (optional, modify as needed)
sdkmanager "system-images;android-30;google_apis;x86_64" >>"$LOGFILE" 2>&1

# Create an Android Virtual Device (AVD) (optional, modify as needed)
echo no | avdmanager create avd -n test_avd -k "system-images;android-30;google_apis;x86_64" >>"$LOGFILE" 2>&1

# Output success message
echo -e "\e[32mAndroid SDK installation complete.\e[0m"

# Verify installation
echo -e "\n\e[32mInstalled SDK packages:\e[0m"
sdkmanager --list

# Check if Google Chrome is installed
if ! which google-chrome &>/dev/null; then
    echo "Google Chrome is not installed. Installing Google Chrome..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O google-chrome.deb >>"$LOGFILE" 2>&1
    sudo dpkg -i google-chrome.deb >>"$LOGFILE" 2>&1
    sudo apt-get install -f -y >>"$LOGFILE" 2>&1
    rm google-chrome.deb
fi

# Set CHROME_EXECUTABLE environment variable
export CHROME_EXECUTABLE=$(which google-chrome)
echo "export CHROME_EXECUTABLE=$(which google-chrome)" >> ~/.bashrc

# Note: Add the following lines to your .bashrc or .zshrc to persist the PATH changes
echo 'export ANDROID_SDK_ROOT="$HOME/Android/Sdk"' >> ~/.bashrc
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo 'export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"' >> ~/.bashrc

# Apply the changes
source ~/.bashrc

