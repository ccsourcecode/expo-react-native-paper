#!/bin/bash

# This script sets up the Android keystore for signing builds
# It can process the keystore from either an environment variable or a file

# Exit on error
set -e

echo "Setting up Android keystore for signing..."

# Create app directory if it doesn't exist
mkdir -p android/app

# Check for keystore sources
if [ -n "$ANDROID_KEYSTORE_BASE64" ]; then
  echo "Using keystore from ANDROID_KEYSTORE_BASE64 environment variable"
  echo "$ANDROID_KEYSTORE_BASE64" | base64 --decode > android/app/release.keystore
elif [ -f "android-key.keystore.base64" ]; then
  echo "Using keystore from android-key.keystore.base64 file"
  base64 --decode android-key.keystore.base64 > android/app/release.keystore
else
  echo "No keystore source found. Creating a temporary debug keystore."
  # Create a temporary keystore for testing builds
  if command -v keytool >/dev/null 2>&1; then
    echo "Creating temporary keystore using keytool"
    keytool -genkeypair -v -keystore android/app/release.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
  else
    echo "Error: keytool not found. Cannot create temporary keystore."
    echo "Please install JDK or set ANDROID_KEYSTORE_BASE64."
    exit 1
  fi
  
  # Set default keystore credentials for the temporary keystore
  export ANDROID_KEYSTORE_PASSWORD="android"
  export ANDROID_KEY_ALIAS="androiddebugkey"
  export ANDROID_KEY_PASSWORD="android"
fi

# Verify keystore file was created
if [ -f "android/app/release.keystore" ]; then
  echo "✅ Keystore file created successfully at android/app/release.keystore"
  ls -la android/app/release.keystore
else
  echo "❌ Failed to create keystore file"
  exit 1
fi

echo "Keystore setup complete!" 