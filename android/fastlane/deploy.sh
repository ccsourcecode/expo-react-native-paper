#!/bin/sh

echo ${ANDROID_SIGNING_KEY_BASE64} | base64 -d > fastlane/example-app.keystore
echo ${ANDROID_PLAY_STORE_CREDENTIALS_BASE64} | base64 -d > fastlane/play-store-credentials.json

fastlane beta