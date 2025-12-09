#!/bin/bash

# Set up user variables
user=$(whoami)
install_dir="$HOME/elrs/ExpressLRS-Configurator"
repo_url="https://github.com/ExpressLRS/ExpressLRS-Configurator.git"

# 1. Check if directory exists, clone if not
if [ ! -d "$install_dir" ]; then
    echo "Cloning ExpressLRS Configurator repo..."
    git clone "$repo_url" "$install_dir"
else
    echo "Repository already cloned. Pulling latest changes..."
    cd "$install_dir"
    git pull
fi

# 2. Install dependencies: make sure you have Node.js, npm, yarn, etc.
echo "Checking dependencies..."

# Ensure node & npm are installed
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing..."
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Ensure yarn is installed
if ! command -v yarn &> /dev/null; then
    echo "Yarn not found. Installing..."
    npm install -g yarn
fi

# Ensure necessary build tools are available
if ! dpkg -l | grep -q "build-essential"; then
    echo "Installing build-essential package..."
    sudo apt-get install -y build-essential
fi

# 3. Install app dependencies
echo "Installing app dependencies..."
cd "$install_dir"
yarn install

# 4. Handle environment variables in .bashrc
bashrc_file="$HOME/.bashrc"

# Check and add Node.js and Yarn paths if not already present
if ! grep -q 'export PATH=.*yarn' "$bashrc_file"; then
    echo "Adding Yarn to PATH in .bashrc..."
    echo 'export PATH="$PATH:$(yarn global bin)"' >> "$bashrc_file"
fi

# Check and add custom environment variables, if needed (e.g., for Electron)
if ! grep -q 'export NODE_ENV=production' "$bashrc_file"; then
    echo "Adding NODE_ENV to .bashrc..."
    echo 'export NODE_ENV=production' >> "$bashrc_file"
fi

# Reload .bashrc to apply changes
source "$bashrc_file"

# 5. Build the project
echo "Building the project..."
yarn build

# 6. Handle Electron app permissions (for Linux)
# Check if `chrome-sandbox` permissions need to be fixed (Electron sandbox)
chrome_sandbox="$install_dir/release/linux-arm64-unpacked/chrome-sandbox"
if [ -f "$chrome_sandbox" ] && [ ! -x "$chrome_sandbox" ]; then
    echo "Fixing chrome-sandbox permissions..."
    sudo chown root:root "$chrome_sandbox"
    sudo chmod 4755 "$chrome_sandbox"
fi

# 7. Install the app (electron-builder packaging)
echo "Packaging the app..."
yarn package

echo "Installation completed successfully!"
echo "You can run the app by navigating to $install_dir/release/linux-arm64-unpacked and running './expresslrs-configurator'."
