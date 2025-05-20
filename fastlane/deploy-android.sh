#!/bin/bash
set -e

# Print environment info
echo "Running on: $(uname -a)"
echo "Ruby version: $(ruby -v)"
echo "Bundler version: $(bundle -v)"

# Set up environment variables for non-interactive use
export FASTLANE_SKIP_UPDATE_CHECK=1
export FASTLANE_HIDE_CHANGELOG=1
export FASTLANE_DISABLE_COLORS=1

# Check required environment variables
if [ -z "$ANDROID_KEYSTORE_PATH" ] && [ -z "$ANDROID_KEYSTORE_BASE64" ]; then
  echo "Error: Neither ANDROID_KEYSTORE_PATH nor ANDROID_KEYSTORE_BASE64 is set"
  exit 1
fi

# Set up keystore from base64 if provided
if [ ! -z "$ANDROID_KEYSTORE_BASE64" ]; then
  echo "Setting up Android keystore from base64"
  mkdir -p android/app
  echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > android/app/release.keystore
  export ANDROID_KEYSTORE_PATH="$(pwd)/android/app/release.keystore"
  echo "Keystore saved to $ANDROID_KEYSTORE_PATH"
fi

# Set up Google Play JSON key if provided
if [ ! -z "$GOOGLE_PLAY_JSON_KEY" ]; then
  echo "Setting up Google Play JSON key"
  echo "$GOOGLE_PLAY_JSON_KEY" | base64 -d > google-play-key.json
  export GOOGLE_PLAY_JSON_KEY_PATH="$(pwd)/google-play-key.json"
  echo "Google Play key saved to $GOOGLE_PLAY_JSON_KEY_PATH"
fi

# Run fastlane
echo "Starting Android build and deployment..."
bundle exec fastlane android deploy_to_production

# Clean up
if [ -f "google-play-key.json" ]; then
  rm google-play-key.json
fi

echo "Android deployment completed!" 