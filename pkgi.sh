#!/bin/bash
 
toilet "PACKAGE FINDER" -w 140

read -p "What's the name of the package you wish to find? " package

read -p "Do you want to generate a file with the locations of $package ? y/n " option

if [ $option == "y" ]; then
    touch report.txt
    echo "Report of $package at this date: $(date)" > report.txt
    apt list --installed | grep $package >> report.txt

elif [ $option == "n" ]; then
    apt list --installed | grep $package
fi