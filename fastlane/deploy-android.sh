#!/bin/bash
set -e

# Extract Play Store credentials from environment variable
if [ ! -z "$ANDROID_PLAY_STORE_CREDENTIALS" ]; then
  echo "Extracting Play Store credentials from environment variable"
  echo "$ANDROID_PLAY_STORE_CREDENTIALS" | base64 --decode > play-store-credentials.json
fi

# Extract Android signing key from environment variable
if [ ! -z "$ANDROID_SIGNING_KEY" ]; then
  echo "Extracting Android signing key from environment variable"
  echo "$ANDROID_SIGNING_KEY" | base64 --decode > example-app.keystore
fi

# Run fastlane beta lane
bundle exec fastlane android beta 