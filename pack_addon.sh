#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 <version>"
	exit 1
fi

VERSION=$1

cp LICENSE ./addons/clog/
cp README.md ./addons/clog/
sed -i '' "s/version=\".*\"/version=\"$VERSION\"/" ./addons/clog/plugin.cfg
zip -r clog.zip ./addons/clog -x "*.uid"