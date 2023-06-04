#!/bin/bash

toilet -f bigmono9 -F gay --gay "Resource Monitor" -w 120

echo "What do you wish to do: "
echo "Monitor CPU usage (1)"
echo "Monitor RAM usage (2)"
echo "Monitor disk space usage (3)"

read -p "Enter the selected option: " option

if [ $option -eq 1 ]
then
    top
elif [ $option -eq 2 ]
then
    free
elif [ $option -eq 3 ]
then
    df -h
fi