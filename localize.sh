#!/bin/bash

set -e

if [ ! "$1" ]; then
	echo Usage: $0 file_base_name
	exit
fi

cd source/_posts
file=$(find . -name "$1.md")
dirpath=$(dirname "$file")
cd "$dirpath"
if [ "$(grep "\!\[.*\](.*)." "$1".md)" != "" -o "$(grep ".\!\[.*\](.*)" "$1".md)" != "" ]; then
	echo There is a figure that does not occupy the whole line!
	exit
fi
mkdir -p "$1"
cd "$1"
grep "^\!\[.*\](.*)" ../"$1.md" | sed 's/\!\[.*\](//g' | sed 's/)$//g' | sed 's/?.*$//g' | xargs wget
cd ..
# %20 is url-encoded white space
awk -v dirname="$(echo $1 | sed 's/ /%20/g')" '
{
	if (/^\!\[.*\](.*)/) {
		sub(/?.*$/,")");
		sub(/#.*$/,")");
		sub(/\(.*\//,"("dirname"/")
	}
	print $0
}
' "$1.md" > "$1.md.tmp"
mv "$1.md.tmp" "$1.md"
