#!/bin/sh

echo ${IOS_PRIVATE_KEY_BASE64} | base64 -d > PrivateKey.p12
echo ${APP_STORE_CONNECT_API_KEY_BASE64} | base64 -d > AppStoreConnectApiKey.p8

bundle exec fastlane beta