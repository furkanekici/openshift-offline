#!/bin/bash

# This script requires the following environment variables defined in pull_config.env:
#   SOURCE_REGISTRY_URL - URL of the source Docker registry
#   TARGET_REGISTRY_URL - URL of the target Docker registry
#   TARGET_PROJECT_NAME - Name of the project in the target registry
#   TLS_VERIFY - TLS verification setting (use '--tls-verify=true' to enable, '--tls-verify=false' to disable) 
source pull_config.env

TAGS_FILE="tags_list.txt"

skopeo list-tags $TLS_VERIFY docker://$SOURCE_REGISTRY_URL | jq -r '.Tags[]' > $TAGS_FILE

echo "Tags have been saved to $TAGS_FILE"

# Get the repository name from the source registry URL
REPO_NAME=$(basename $SOURCE_REGISTRY_URL)

# Fetch tags using skopeo and process them directly in a loop
for TAG in $(skopeo list-tags $TLS_VERIFY docker://$SOURCE_REGISTRY_URL | jq -r '.Tags[]'); do
    SOURCE_IMAGE="$SOURCE_REGISTRY_URL:$TAG"
    TARGET_IMAGE="$TARGET_REGISTRY_URL/$TARGET_PROJECT_NAME/$REPO_NAME:$TAG"

    echo "Pulling $SOURCE_IMAGE..."
    docker pull $SOURCE_IMAGE

    echo "Tagging and pushing to $TARGET_IMAGE..."
    docker tag $SOURCE_IMAGE $TARGET_IMAGE

    # Remove the old image
    echo "Removing local copy of $SOURCE_IMAGE..."
    docker rmi $SOURCE_IMAGE
done

