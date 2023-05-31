#!/bin/bash

toilet -f bigmono9 -F gay --gay "File Finder"

echo "What's the name of the directory you wish to find?" 
read directory

echo "What's the name of the file you want to search for?" 
read filename

if [ -e "$directory/$filename" ]; then
    echo "File found: $directory/$filename"
else
    echo "File could not be found"
fi
