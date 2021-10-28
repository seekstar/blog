#!/bin/bash

if [ ! $1 ]; then
	echo Usage: $0 file_base_name
	exit
fi

cd source/_posts
cd $(dirname $(find . -name "$1.md"))
mkdir -p $1
cd $1
grep "^\!\[.*\](.*)" ../$1.md | sed 's/\!\[.*\](//g' | sed 's/)$//g' | sed 's/?.*$//g' | xargs wget
cd ..
awk -v dirname=$1 '
{
	if (/^\!\[.*\](.*)/) {
		sub(/?.*$/,")");
		sub(/\(.*\//,"("dirname"/")
	}
	print $0
}
' $1.md > $1.md.tmp
mv $1.md.tmp $1.md
