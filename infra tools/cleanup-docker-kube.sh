#!/bin/bash

######################################################
# Part 1 - Uninstall Docker
######################################################
echo "Removing Docker..."

# Stop Docker service
sudo systemctl stop docker

# Remove Docker packages
sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli

# Remove Docker dependencies
sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce

# Remove Docker directories
sudo rm -rf /var/lib/docker /etc/docker
sudo rm /etc/apparmor.d/docker
sudo groupdel docker
sudo rm -rf /var/run/docker.sock

# Check if Docker removal was successful
if [ $? -ne 0 ]; then
  echo "Failed to completely remove Docker. Exiting."
  exit 1
fi

echo "Docker removed successfully."

######################################################
# Part 2 - Uninstall Kubernetes
######################################################
echo "Removing Kubernetes..."

# Stop kubelet service
sudo systemctl stop kubelet

# Remove Kubernetes packages
sudo apt-get purge -y kubeadm kubectl kubelet kubernetes-cni kube*

# Remove Kubernetes dependencies
sudo apt-get autoremove -y

# Remove Kubernetes directories
sudo rm -rf ~/.kube
sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/kubelet

# Remove Kubernetes repository list file
sudo rm -f /etc/apt/sources.list.d/kubernetes.list

# Check if Kubernetes removal was successful
if [ $? -ne 0 ]; then
  echo "Failed to completely remove Kubernetes. Exiting."
  exit 1
fi

echo "Kubernetes removed successfully."

######################################################
# Part 3 - Clean Up
######################################################
echo "Cleaning up..."

# Update package list
sudo apt-get update

# Check if update was successful
if [ $? -ne 0 ]; then
  echo "Failed to update package list. Exiting."
  exit 1
fi

echo "Clean up completed successfully."
