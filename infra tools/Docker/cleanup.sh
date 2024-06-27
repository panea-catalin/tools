#!/bin/bash

# List of image IDs to keep (from localhost repo and Kubernetes images)
keep_images=(
  "869fd146593c"  # localhost:5000/flutter-image-toale
  "23ff21917545"  # localhost:5000/mongodb-toale and mongodb-toale
  "89bc3a1db8b7"  # localhost:5000/flask-router-toale and flask-router-toale
  "5dea1f4edf69"  # jenkins/jenkins
  "4aefe0ec9485"  # kiwigrid/k8s-sidecar
  "c42f13656d0b"  # registry.k8s.io/kube-apiserver
  "c7aad43836fa"  # registry.k8s.io/kube-controller-manager
  "259c8277fcbb"  # registry.k8s.io/kube-scheduler
  "a0bf559e280c"  # registry.k8s.io/kube-proxy
  "3861cfcd7c04"  # registry.k8s.io/etcd
  "cbb01a7bd410"  # registry.k8s.io/coredns/coredns
  "e6f181688397"  # registry.k8s.io/pause
  "6e38f40d628d"  # gcr.io/k8s-minikube/storage-provisioner
)

# Get all image IDs and their repositories
all_images=$(docker images --format "{{.ID}} {{.Repository}}")

# Loop through all images
while IFS= read -r line; do
  image_id=$(echo $line | awk '{print $1}')
  repo=$(echo $line | awk '{print $2}')

  # Check if the image is in the keep_images array
  if [[ ! " ${keep_images[@]} " =~ " ${image_id} " ]]; then
    # Check if the repository is not localhost or Kubernetes-related
    if [[ $repo != localhost* ]] && [[ $repo != registry.k8s.io* ]] && [[ $repo != gcr.io* ]]; then
      # Get the containers using the image
      containers=$(docker ps -a -q --filter ancestor=$image_id)
      if [ -n "$containers" ]; then
        # Stop and remove the containers
        docker stop $containers
        docker rm $containers
      fi
      # Delete the image
      docker rmi -f $image_id
    fi
  fi
done <<< "$all_images"

