#!/bin/bash

toilet -f bigmono9 -F gay --gay "CONVERT TO PDF" -w 120

echo "Change format from .txt to .html (press 1)"
echo "Change format from .txt to .pdf (press 2)"
echo "Change format from .docx to .pdf (press 3)"

read -p "What do you wish to do: " selection

if (( selection == 1 )); then
    read -p "Enter the file name with .txt extension: " filename
    mv -- "$filename" "${filename%.txt}.html"
    echo "File extension changed successfully. Find the file at $(pwd)/${filename%.txt}.html"
elif (( selection == 2 )); then
    read -p "Enter the file name with .txt extension: " filename
    mv -- "$filename" "${filename%.txt}.pdf"
    echo "File extension changed from .txt to .pdf for $filename"
elif (( selection == 3 )); then
    read -p "Enter the file name with .docx extension: " filename
    libreoffice --convert-to pdf "$filename" --outdir "$(pwd)"
    rm "$filename"
    echo "File extension changed from .docx to .pdf for $filename"
else
    echo "Invalid selection"
fi
