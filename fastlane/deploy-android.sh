#!/bin/bash
set -e

echo "Setting up Android signing keys..."
# This script assumes that the ANDROID_SIGNING_KEY and ANDROID_PLAY_STORE_CREDENTIALS are set in environment variables

# Run setup-android-keys.sh if it exists
if [ -f "./fastlane/setup-android-keys.sh" ]; then
  chmod +x ./fastlane/setup-android-keys.sh
  ./fastlane/setup-android-keys.sh
fi

echo "Configuring Gradle for optimal CI performance"
echo "Java version:"
java -version

echo "Ensuring gradlew exists and is executable..."
if [ ! -f "./android/gradlew" ]; then
  echo "gradlew not found! Creating gradle wrapper..."
  cd android
  # Create gradle wrapper if it doesn't exist
  gradle wrapper
  cd ..
fi

# Make sure gradlew is executable
chmod +x ./android/gradlew

echo "Gradle version:"
cd android
./gradlew --version

echo "Building Android app..."
# Add timeout to handle long builds
timeout 40m ./gradlew app:bundleRelease app:assembleRelease --no-daemon --max-workers 2 -Dorg.gradle.configureondemand=true -Dorg.gradle.jvmargs="-Xmx3g -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8"

echo "Android build completed successfully!" 