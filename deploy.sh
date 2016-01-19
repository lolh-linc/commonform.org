#!/bin/bash

BUILD=build
ROOT=/var/www/commonform.org
FLAGS="--verbose --checksum --recursive --sparse --compress --human-readable --progress"
REF=${1:-HEAD}

(
	set -e
	COMMIT=`git rev-parse "$REF"`
	GITDIR=`pwd`
	TMPDIR=`mktemp -d`
	trap "{ cd "$GITDIR" ; rm -rf "$TMPDIR"; exit 255; }" SIGINT EXIT
	git clone -s "$GITDIR" "$TMPDIR"
	cd $TMPDIR
	npm install
  npm shrinkwrap --dev
	npm run build
  mv npm-shrinkwrap.json build/npm-shrinkwrap.json
	rsync $FLAGS $BUILD/* commonform.org:$ROOT/releases/$COMMIT
	cat $BUILD/index.html | sed -e "s/RELEASE\//https:\/\/commonform.org\/releases\/$COMMIT\//" > index.html
	rsync $FLAGS index.html commonform.org:$ROOT/
)
