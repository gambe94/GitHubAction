#!/bin/bash

test_branching() {
    # Create a new branch
    git checkout main

    git pull origin main

    # Create release branch release/{TODAY_DATE}
    RELEASE_BRANCH_NAME=release/$(date +%Y_%m_%d)
    git checkout -b $RELEASE_BRANCH_NAME
    git push origin $RELEASE_BRANCH_NAME --set-upstream

    # Create a feature branch
    git checkout -b feature/CRMC-5
    # Create a dummy file with some content
    echo 'Hello, World!' > dummy.txt
    # Add the dummy file to the new branch
    git add dummy.txt
    # Commit the changes
    git commit -m "Add dummy file to test branch"

    # Push the changes to the remote repository
    git push origin feature/CRMC-5 --set-upstream

    gh pr create --base  $RELEASE_BRANCH_NAME --title "Feature implemented" --body "Everything works again"

    # Merge the changes from the feature branch
    gh pr merge --squash

    git checkout $RELEASE_BRANCH_NAME
    git pull origin $RELEASE_BRANCH_NAME

}
