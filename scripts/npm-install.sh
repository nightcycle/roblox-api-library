#!/bin/sh

set -e

npm cache clean --force
# remove the lock file
if [ -f package-lock.json ]; then
	echo "removing package-lock.json"
	rm -f package-lock.json
fi

# remove node_modules
if [ -d node_modules ]; then
	echo "removing node_modules"
	rm -rf node_modules
fi

# if [ ! -d node_modules ]; then
npm install
# fi

# if [ ! -d node_modules/.luau-aliases ]; then
npm run prepare
# fi

# for each directory under node_modules, check for a directory named ".vscode", if it exists remove it
for dir in $(find "node_modules" -type d -name ".vscode")
do
	echo "removing $dir"
	rm -rf "$dir"
done

for dir in $(find "node_modules" -type d -name "types")
do
	echo "removing $dir"
	rm -rf "$dir"
done