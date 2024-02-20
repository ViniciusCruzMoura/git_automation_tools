branch() {
    PROD_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    NEW_BRANCH="update-$USER-$(date +'%y%m%d')"

    git fetch --all --prune --prune-tags

    git checkout $PROD_BRANCH
    git reset --hard origin/$PROD_BRANCH

    git checkout -B $NEW_BRANCH

    git push origin $NEW_BRANCH

    echo "Created and checked out new branch '$NEW_BRANCH' based on main"
}

merge() {
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
}

push() {
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
}

tag() {
    # git tag -l | xargs git tag -d
    # git fetch --tags
    git fetch --prune --prune-tags

    while [[ -z "$TAG" ]]; do
        echo "Enter the tag version:"
        read TAG;
    done

    git tag $TAG
    git push origin $TAG
}

case $1 in
	-help|--help|help)
		echo "These are common commands used in various situations:"
		exit 0
		;;
	-branch|--branch|branch)
		branch
		exit 0
		;;
	-merge|--merge|merge)
		merge
		exit 0
		;;
    -push|--push|push)
		push
		exit 0
		;;
    -tag|--tag|tag)
		tag
		exit 0
		;;
	*)
		echo "Unknown option, Try -help for more information."
		exit 0
		;;
esac
