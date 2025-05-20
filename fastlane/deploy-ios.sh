#!/bin/bash
set -e

# Print environment info
echo "Running on: $(uname -a)"
echo "Ruby version: $(ruby -v)"
echo "Bundler version: $(bundle -v)"
echo "Xcode version: $(xcodebuild -version)"

# Set up environment variables for non-interactive use
export FASTLANE_SKIP_UPDATE_CHECK=1
export FASTLANE_HIDE_CHANGELOG=1
export FASTLANE_DISABLE_COLORS=1

# Check required environment variables
if [ -z "$APPLE_TEAM_ID" ]; then
  echo "Error: APPLE_TEAM_ID is not set"
  exit 1
fi

# Set up App Store Connect API key if provided
if [ ! -z "$ASC_KEY_CONTENT" ]; then
  echo "Using App Store Connect API key for authentication"
  # Make sure key content is properly formatted with newlines
  echo "$ASC_KEY_CONTENT" | sed 's/\\n/\n/g' > asc_key.p8
  export ASC_KEY_FILEPATH="$(pwd)/asc_key.p8"
  echo "API key saved to $ASC_KEY_FILEPATH"
fi

# Run fastlane
echo "Starting iOS build and deployment..."
bundle exec fastlane ios uploadtestflight

# Clean up
if [ -f "asc_key.p8" ]; then
  rm asc_key.p8
fi

echo "iOS deployment completed!" 