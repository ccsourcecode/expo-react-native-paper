#!/bin/bash
set -e

# Make script executable
chmod +x fastlane/setup-android-keys.sh

# Set up Android signing keys and credentials
./fastlane/setup-android-keys.sh

# Configure Gradle properties for improved CI performance
echo "Configuring Gradle for optimal CI performance"

# Increase Java memory allocation for Gradle
export GRADLE_OPTS="$GRADLE_OPTS -Dorg.gradle.jvmargs=-Xmx4g"

# Add progress output to prevent timeouts
export CI_PROGRESS=true

# Set environment variables for Fastlane
export ANDROID_KEYSTORE_FILE="./android-key.keystore"

# Print environment info
echo "Java version:"
java -version
echo "Gradle version:"
./gradlew --version

# Run fastlane beta lane
echo "Starting Android build with fastlane..."
bundle exec fastlane android beta --verbose 