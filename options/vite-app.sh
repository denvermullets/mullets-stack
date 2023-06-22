#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please provide a project name as the first argument"
    exit 1
fi

project_name=$1

# create the frontend
yarn create vite "$project_name" --template react-ts

cd "$project_name"

git init

yarn add -D husky
yarn husky install
npm pkg set scripts.prepare="husky install"
npm pkg set scripts.test="tsc -p ./tsconfig.json"
yarn husky add .husky/pre-commit "yarn test"

source "$MAIN_SCRIPT_DIR/options/gitignore.sh"