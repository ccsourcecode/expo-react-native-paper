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

# Fix any deprecated Gradle properties
echo "Fixing any deprecated Gradle properties..."
chmod +x fastlane/fix-gradle-properties.sh
./fastlane/fix-gradle-properties.sh

echo "Gradle version:"
cd android
./gradlew --version

echo "Building Android app..."
# Add memory optimizations before building
echo "Configuring additional memory optimizations..."
cd android
cat >> gradle.properties << 'EOL'
# Memory optimizations
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g -XX:+HeapDumpOnOutOfMemoryError
org.gradle.daemon=false
org.gradle.workers.max=1
android.disableAutomaticComponentCreation=true
kapt.incremental.apt=false
# Skia optimizations
skiko.native.dependencies.strip=false
EOL

# Split the build into separate tasks to avoid memory issues
echo "Building app using separate tasks to avoid memory issues..."
./gradlew clean
./gradlew :app:bundleRelease --no-daemon --max-workers 1 -Dorg.gradle.configureondemand=true
./gradlew :app:assembleRelease --no-daemon --max-workers 1 -Dorg.gradle.configureondemand=true

echo "Android build completed successfully!" 