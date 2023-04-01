#!/bin/bash

# Update the package index and install Node.js
sudo apt update
sudo apt install nodejs -y

# Install npm, the package manager for Node.js
sudo apt install npm -y

# Install Git to clone the OWASP Juice Shop repository
sudo apt install git -y

# Clone the OWASP Juice Shop repository
git clone https://github.com/bkimminich/juice-shop.git

# Navigate to the OWASP Juice Shop directory
cd juice-shop/

# Install the required Node.js packages
npm install

# Start the OWASP Juice Shop server
npm start
