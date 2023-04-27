#!/usr/bin/env bash

# clean build directory
cd public
ls | grep -v .gitkeep | xargs rm -rf {}
cd ..

# build hugo
hugo -t hugo-book

# clean deploy directory
rm -rf docs/*

# copy to deploy directory
cp -r public/* docs/

# prepare to deploy
cd docs/
git add .
cd ..

# deploy
# git commit -m ""
# git push


