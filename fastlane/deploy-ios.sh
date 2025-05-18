#!/bin/bash
set -e

echo "Setting up iOS deployment environment..."

# Fix OpenSSL issues
if [ -f "./fastlane/fix-openssl.sh" ]; then
  echo "Running OpenSSL fix script..."
  chmod +x ./fastlane/fix-openssl.sh
  ./fastlane/fix-openssl.sh
fi

# Ensure OpenSSL environment is properly set
if brew list -1 | grep -q "^openssl@3"; then
  echo "Using installed OpenSSL 3"
  export PATH="/usr/local/opt/openssl@3/bin:$PATH"
  export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
  export CPPFLAGS="-I/usr/local/opt/openssl@3/include"
  export PKG_CONFIG_PATH="/usr/local/opt/openssl@3/lib/pkgconfig"
else
  echo "OpenSSL 3 not found, installing..."
  brew install openssl@3
  export PATH="/usr/local/opt/openssl@3/bin:$PATH"
  export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
  export CPPFLAGS="-I/usr/local/opt/openssl@3/include"
  export PKG_CONFIG_PATH="/usr/local/opt/openssl@3/lib/pkgconfig"
fi

# Set environment variables for Fastlane
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

echo "Debugging OpenSSL version and paths:"
which openssl
openssl version
echo $PATH
echo $LDFLAGS
echo $CPPFLAGS

echo "Starting iOS build with fastlane..."
# Use timeout to handle potential hanging builds
timeout 60m bundle exec fastlane ios beta --verbose

echo "iOS build completed successfully!"

# Extract App Store Connect API key from environment variable
if [ ! -z "$APP_STORE_CONNECT_API_KEY" ]; then
  echo "Extracting App Store Connect API key from environment variable"
  mkdir -p ~/.appstoreconnect/private_keys/
  echo "$APP_STORE_CONNECT_API_KEY" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey.p8
fi

# Extract iOS private key from environment variable
if [ ! -z "$IOS_PRIVATE_KEY" ]; then
  echo "Extracting iOS private key from environment variable"
  mkdir -p ~/ios-certs
  echo "$IOS_PRIVATE_KEY" | base64 --decode > ~/ios-certs/distribution.p12
fi 