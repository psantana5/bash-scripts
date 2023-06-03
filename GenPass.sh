#!/bin/bash

# Define the length of the password
length=12

# Define the characters to use in the password
characters="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+"

# Generate the password
password=$(head /dev/urandom | tr -dc "$characters" | head -c "$length")

# Save the password to a file
echo "$password" > password.txt
