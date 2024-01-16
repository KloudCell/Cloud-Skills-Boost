#! /bin/bash

while true; do
    # Print the message
    echo -e "Please accept the terms by going to the following link otherwise lab will not complete: \033[0;34mhttps://console.developers.google.com/terms/cloud\033[0m"
    
    # Ask for user input
    read -p "Have you accepted the terms? (y/n) " yn
    
    # Check the user input
    case $yn in
        [Yy]* ) break;;
        * ) echo "Please accept the terms to proceed.";;
    esac
done