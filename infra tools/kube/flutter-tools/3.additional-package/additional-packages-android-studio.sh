#!/bin/bash

LOGFILE="install_android_studio.log"
ANDROID_SDK_ROOT="$HOME/Android/Sdk"
ANDROID_STUDIO_DIR="$HOME/android-studio"

# Update and upgrade the system
sudo apt-get update -y >>"$LOGFILE" 2>&1 && sudo apt-get upgrade -y >>"$LOGFILE" 2>&1

# Install dependencies
sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 >>"$LOGFILE" 2>&1

# Download and install Android Studio
cd /tmp
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.2.1.18/android-studio-2022.2.1.18-linux.tar.gz -O android-studio.tar.gz >>"$LOGFILE" 2>&1
tar -xzf android-studio.tar.gz >>"$LOGFILE" 2>&1
rm android-studio.tar.gz

# Move to a standard location
mv android-studio "$ANDROID_STUDIO_DIR" >>"$LOGFILE" 2>&1

# Add Android Studio to PATH
echo "export PATH=\"$ANDROID_STUDIO_DIR/bin:\$PATH\"" >> ~/.bashrc

# Apply the changes
source ~/.bashrc

# Verify installation
"$ANDROID_STUDIO_DIR/bin/studio.sh" --version >>"$LOGFILE" 2>&1

# Output success message
echo -e "\e[32mAndroid Studio installation complete.\e[0m"

# Clean up
cd -
