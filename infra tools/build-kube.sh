#!/bin/bash

######################################################
# Part 1 - Update
######################################################
echo "Running update."
sudo apt-get update

# Check if the update was successful
if [ $? -ne 0 ]; then
  echo "Update failed. Exiting."
  exit 1
fi

echo "Update successful."

######################################################
# Part 2 - Install, Start, and Enable Docker
######################################################
sudo apt-get install -y docker.io

# Check if the installation was successful
if [ $? -ne 0 ]; then
  echo "Docker installation failed. Exiting."
  exit 1
fi

echo "Docker installation successful."

sudo systemctl enable docker

# Check if enabling Docker was successful
if [ $? -ne 0 ]; then
  echo "Failed to enable Docker. Exiting."
  exit 1
fi

echo "Docker enabled successfully."

sudo systemctl start docker

# Check if starting Docker was successful
if [ $? -ne 0 ]; then
  echo "Failed to start Docker. Exiting."
  exit 1
fi

echo "Docker started successfully."

######################################################
# Part 3 - Install Kubernetes
######################################################
echo "Installing Kubernetes..."

# Update package list and install dependencies
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

# Check if the update and installation of dependencies were successful
if [ $? -ne 0 ]; then
  echo "Failed to update package list or install dependencies. Exiting."
  exit 1
fi

echo "Package list updated and dependencies installed."

# Add Kubernetes signing key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Check if the key was added successfully
if [ $? -ne 0 ]; then
  echo "Failed to add Kubernetes signing key. Exiting."
  exit 1
fi

echo "Kubernetes signing key added."

# Add Kubernetes repository for Ubuntu Jammy (22.04)
echo "deb https://apt.kubernetes.io/ kubernetes-jammy main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package list again
sudo apt-get update

# Check if the update was successful
if [ $? -ne 0 ]; then
  echo "Failed to update package list after adding Kubernetes repository. Exiting."
  exit 1
fi

echo "Package list updated with Kubernetes repository."

# Install Kubernetes components
sudo apt-get install -y kubelet kubeadm kubectl

# Check if the installation was successful
if [ $? -ne 0 ]; then
  echo "Failed to install Kubernetes components. Exiting."
  exit 1
fi

echo "Kubernetes components installed."

# Prevent automatic updates of Kubernetes components
sudo apt-mark hold kubelet kubeadm kubectl

# Check if holding the packages was successful
if [ $? -ne 0 ]; then
  echo "Failed to hold Kubernetes packages. Exiting."
  exit 1
fi

echo "Kubernetes packages held successfully."

echo "Kubernetes installation completed successfully."
