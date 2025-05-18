#!/bin/bash
set -e

GRADLE_PROPERTIES="android/gradle.properties"

echo "Checking for deprecated Gradle properties..."

if [ -f "$GRADLE_PROPERTIES" ]; then
  echo "Found gradle.properties file"
  
  # Remove the deprecated property if it exists
  if grep -q "android.enableR8" "$GRADLE_PROPERTIES"; then
    echo "Removing deprecated android.enableR8 property"
    sed -i '/android.enableR8/d' "$GRADLE_PROPERTIES"
  else
    echo "No deprecated android.enableR8 property found"
  fi
  
  echo "Gradle properties file updated"
else
  echo "No gradle.properties file found yet"
fi

echo "Gradle properties check complete" 