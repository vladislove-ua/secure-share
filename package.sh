#!/bin/sh

set -e

GOOS=linux GOARCH=amd64 go build

(cd public && bower install)
for i in `find public/bower_components/ -name "*.min.js"`
do
	gzip -c $i > $i.gz
done

rm -f public/css/*.min.css
for i in `ls public/css/*.css`
do
        minVer=`echo $i | sed 's/\.css/.min.css/'`
        node_modules/.bin/minify $i --output $minVer
        gzip -c $i  > $i.gz
        gzip -c $minVer  > $minVer.gz
done

for i in `ls public/js/*.js | grep -v '.min.'`
do
	minVer=`echo $i | sed 's/\.js/.min.js/'`
	rm -f $minVer
	node_modules/.bin/uglifyjs $i -c -o $minVer
	gzip -c $i  > $i.gz
	gzip -c $minVer  > $minVer.gz
done


release=1
githash=`git rev-parse --short HEAD`
gitnum=`git rev-list v$release..HEAD --count`
ver=${release}.${gitnum}-${githash}
mkdir -p pkgs
rm -f pkgs/*
archive=pkgs/secure-share.$branch$ver.tar
tar -cf $archive secure-share public
gzip $archive
