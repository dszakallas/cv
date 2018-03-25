#!/usr/bin/env bash
set -e # exit with nonzero exit code if anything fails

# create temporary directory to work in
GITDIR=$(mktemp -d); trap "{ rm -rf $GITDIR; }" EXIT


cd $GITDIR
git init
git config user.name $GIT_USER
git config user.email $GIT_EMAIL
git remote add origin "https://github.com/${GH_REPO}.git"
git pull
git checkout gh-pages

cp -r $OUTDIR/**/* $GITDIR

git add .
git commit -m $MESSAGE
git push --quiet "https://${GH_TOKEN}@github.com/${GH_REPO}.git" $BRANCH:$TGT_BRANCH  > /dev/null 2>&1
