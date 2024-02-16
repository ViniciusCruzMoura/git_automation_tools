#!/bin/bash

# git tag -l | xargs git tag -d
# git fetch --tags
git fetch --prune --prune-tags

while [[ -z "$TAG" ]]; do
    echo "Enter the tag version:"
    read TAG;
done

git tag $TAG
git push origin $TAG