#!/bin/bash

PROD_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
NEW_BRANCH="update-$USER-$(date +'%y%m%d')"

git fetch --all --prune --prune-tags

git checkout $PROD_BRANCH
git reset --hard origin/$PROD_BRANCH

git checkout -B $NEW_BRANCH

git push origin $NEW_BRANCH
