#!/bin/bash

# Load variables from the configuration file
# Ensure 'push_config.env' contains variables: TARGET_REGISTRY_URL, REGISTRY_USER, REGISTRY_PASSWORD
source push_config.env

echo "Logging in to $TARGET_REGISTRY_URL..."
podman login $TARGET_REGISTRY_URL -u $REGISTRY_USER -p $REGISTRY_PASSWORD

A=0

# List all images and filter those with the target registry URL
for IMAGE in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep "^$TARGET_REGISTRY_URL"); do
    echo "Pushing $IMAGE..."
    docker push $IMAGE
    A=$((A+1))
    echo "Image number $A pushed."
done

