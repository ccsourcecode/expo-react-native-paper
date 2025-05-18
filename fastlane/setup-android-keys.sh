#!/bin/bash
set -e

KEYSTORE_PATH="./android-key.keystore"
KEYSTORE_PROPERTIES="./android/keystore.properties"

echo "Setting up Android signing keys..."

# Decode keystore if provided as base64
if [ ! -z "$ANDROID_SIGNING_KEY" ]; then
  echo "Decoding keystore from environment variable..."
  echo "$ANDROID_SIGNING_KEY" | base64 --decode > "$KEYSTORE_PATH"
  echo "Keystore decoded to $KEYSTORE_PATH"
fi

# Create keystore.properties file
if [ ! -z "$ANDROID_KEYSTORE_PASSWORD" ] && [ ! -z "$ANDROID_KEY_ALIAS" ] && [ ! -z "$ANDROID_KEY_PASSWORD" ]; then
  echo "Creating keystore.properties file..."
  
  cat > "$KEYSTORE_PROPERTIES" << EOF
releaseKeyAlias=${ANDROID_KEY_ALIAS}
releaseKeyPassword=${ANDROID_KEY_PASSWORD}
releaseKeyStore=${KEYSTORE_PATH}
releaseStorePassword=${ANDROID_KEYSTORE_PASSWORD}
EOF

  echo "keystore.properties created at $KEYSTORE_PROPERTIES"
else
  echo "Warning: Missing Android signing credentials in environment variables"
fi

# Create Google Play credentials file if provided
if [ ! -z "$ANDROID_PLAY_STORE_CREDENTIALS" ]; then
  echo "Creating Google Play credentials file..."
  echo "$ANDROID_PLAY_STORE_CREDENTIALS" | base64 --decode > "play-store-credentials.json"
  echo "Google Play credentials file created"
fi

echo "Android signing setup complete!" 