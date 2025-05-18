#!/bin/bash
set -e

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

# Run fastlane beta lane
bundle exec fastlane ios beta 