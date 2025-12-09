#!/bin/bash
# Full ExpressLRS-Configurator ARM64 Build Script
# Installs everything from scratch, logs everything, uses apt/npm/yarn only

set -e  # Exit immediately on any error

# 0️⃣ Install system dependencies via apt
sudo apt update
sudo apt install -y build-essential git python3 python3-pip pkg-config libx11-dev libxkbfile-dev libsecret-1-dev \
  libgconf-2-4 libnss3 libxss1 libasound2 libatk-bridge2.0-0 libgtk-3-0

echo "System dependencies installed."

# 1️⃣ Prepare project directory
mkdir -p ~/elrs
cd ~/elrs

# 2️⃣ Clone the repository recursively
git clone --recursive https://github.com/ExpressLRS/ExpressLRS-Configurator.git
cd ExpressLRS-Configurator

# 3️⃣ Clean old node modules and lock files just in case
rm -rf node_modules package-lock.json yarn.lock
echo "Cleaned previous node_modules and lock files"

# 4️⃣ Install Node dependencies
npm install --legacy-peer-deps
yarn install
echo "Node dependencies installed."

# 5️⃣ Fix Electron sandbox permissions (important for Electron to run correctly)
if [ ! -f "/usr/local/lib/node_modules/electron/dist/chrome-sandbox" ]; then
  echo "chrome-sandbox file not found, skipping sandbox fix"
else
  echo "Fixing Electron sandbox permissions..."
  sudo chown root:root /usr/local/lib/node_modules/electron/dist/chrome-sandbox
  sudo chmod 4755 /usr/local/lib/node_modules/electron/dist/chrome-sandbox
  echo "Electron sandbox permissions fixed"
fi

# 6️⃣ Rebuild native modules for ARM64
npx electron-builder install-app-deps
echo "Native dependencies rebuilt."

# 7️⃣ Build the Linux ARM64 application with live logging
echo "Starting build process for ARM64 architecture..."
npx electron-builder --linux --arm64 --publish never 2>&1 | tee build.log

# 8️⃣ Done building! Check ./dist for the Linux ARM64 binary.
echo "Build complete! Check ./dist for the Linux ARM64 binary."

# 9️⃣ Run the app (this is the step to launch the app after build)
# Make sure the app is built first before trying to run it.
DIST_DIR="./dist"
if [ -d "$DIST_DIR" ]; then
  echo "Launching ExpressLRS Configurator..."
  # If the app was packaged successfully, run it.
  ./dist/ExpressLRS-Configurator-linux-arm64/ExpressLRS-Configurator
else
  echo "Error: Build directory not found. Please check the build log."
fi

# 🔟 Optional: Clean up unnecessary files (comment this out if you want to keep the node_modules)
# rm -rf node_modules package-lock.json yarn.lock
# echo "Cleaned up build files."

