#!/usr/bin/env bash
set -e # exit with nonzero exit code if anything fails

# create temporary directory to work in
GITDIR=$(mktemp -d); trap "{ rm -rf $GITDIR; }" EXIT

cp -r $OUTDIR/* $GITDIR

cd $GITDIR
git init
git config user.name $GIT_USER
git config user.email $GIT_EMAIL

git add .
git commit -m "$COMMIT_MESSAGE"
git push --force --quiet "https://${GH_TOKEN}@github.com/${GH_REPO}.git" $BRANCH:$TGT_BRANCH  > /dev/null 2>&1
