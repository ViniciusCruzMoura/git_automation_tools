#!/bin/bash

# SOURCE_BRANCH="main"
# NEW_BRANCH="update-$USER-$(date +'%Y%m%d%H%M%S')"
SOURCE_BRANCH=$(git branch --show-current)
# NEW_BRANCH="update-$USER-$(date +'%y%m%d')"

git fetch --all
git pull origin $SOURCE_BRANCH
git add .

# git restore --staged push.sh
git status

while [[ -z "$COMMIT_MSG" ]]; do
    echo 'Enter the commit message:'
    read COMMIT_MSG
done

git commit -m "$COMMIT_MSG"
# git push origin $SOURCE_BRANCH:$NEW_BRANCH

# if [ $SOURCE_BRANCH != $NEW_BRANCH ]; then
#     git checkout -b $NEW_BRANCH
#     git reset --hard origin/$NEW_BRANCH
# fi
git push origin $SOURCE_BRANCH

git fetch --prune --prune-tags

echo "Push complete"
