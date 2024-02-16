#!/bin/bash

SOURCE_BRANCH=$(git branch --show-current)
PROD_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
MERGE_BRANCH="merge-$USER-$(date +'%y%m%d')"

git fetch --all --prune --prune-tags

# Ensure we're on the main branch
# git checkout $PROD_BRANCH

# Create a new branch based on the main branch
git checkout -B $MERGE_BRANCH

# Pull the latest changes from the main branch
git pull origin $PROD_BRANCH
# git reset --hard origin/$PROD_BRANCH

# Merge the specified branch into main
git merge $SOURCE_BRANCH

# Push the merged changes to the remote repository
git push origin $MERGE_BRANCH

# Optionally, you can delete the merged branch
# git branch -D $SOURCE_BRANCH

git checkout $SOURCE_BRANCH

git fetch --all --prune --prune-tags

echo "Merge complete"
