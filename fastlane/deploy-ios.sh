#!/bin/bash
set -e

# Define the project root directory
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DIR="$PROJECT_ROOT/ios"

echo "Setting up iOS deployment environment..."

# Set OpenSSL environment variables
export PATH="$(brew --prefix openssl@3)/bin:$PATH"
export LDFLAGS="-L$(brew --prefix openssl@3)/lib"
export CPPFLAGS="-I$(brew --prefix openssl@3)/include"
export PKG_CONFIG_PATH="$(brew --prefix openssl@3)/lib/pkgconfig"

# Ensure correct Ruby version
echo "Ruby version: $(ruby -v)"
echo "Bundler version: $(bundler -v)"

# Update certificate store for OpenSSL
echo "Updating OpenSSL certificate links..."
echo "Doing $(brew --prefix openssl@3)/etc/openssl@3/certs"
"$(brew --prefix openssl@3)/bin/c_rehash"

# Run our iOS signing setup script
echo "Setting up iOS signing..."
chmod +x "$PROJECT_ROOT/fastlane/setup-ios-signing.sh"
"$PROJECT_ROOT/fastlane/setup-ios-signing.sh"

# Create exportOptions.plist file
echo "Creating exportOptions.plist..."
TEAM_ID=${TEAM_ID:-${FASTLANE_TEAM_ID:-""}}
cat > "$IOS_DIR/exportOptions.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOL

echo "Building iOS app..."
cd "$IOS_DIR"
# Find the workspace and scheme names
WORKSPACE=$(find . -name '*.xcworkspace' | head -n 1)
SCHEME=$(find . -name '*.xcodeproj' -exec basename {} .xcodeproj \; | head -n 1)
echo "Using workspace: $WORKSPACE"
echo "Using scheme: $SCHEME"

xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Release -archivePath build/App.xcarchive archive

echo "Creating IPA file..."
xcodebuild -exportArchive -archivePath build/App.xcarchive -exportOptionsPlist exportOptions.plist -exportPath build

echo "Uploading to TestFlight..."
# Check if we have an IPA file
if [ -z "$(find build -name '*.ipa')" ]; then
  echo "Error: No IPA file found. Build may have failed."
  exit 1
fi

# Upload to TestFlight
if [ -n "$APP_STORE_CONNECT_API_KEY" ]; then
  echo "Using App Store Connect API for upload..."
  xcrun altool --upload-app --type ios --file "$(find build -name '*.ipa')" --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
else
  echo "Using Transporter for upload..."
  xcrun iTMSTransporter -m upload -assetFile "$(find build -name '*.ipa')" -v eXtreme
fi

echo "iOS deployment completed successfully!"

# Extract App Store Connect API key from environment variable
if [ ! -z "$APP_STORE_CONNECT_API_KEY" ]; then
  echo "Extracting App Store Connect API key from environment variable"
  mkdir -p ~/.appstoreconnect/private_keys/
  echo "$APP_STORE_CONNECT_API_KEY" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey.p8
fi

# Extract iOS private key from environment variable
if [ ! -z "$IOS_PRIVATE_KEY" ]; then
  echo "Extracting iOS private key from environment variable"
  mkdir -p ~/ios-certs
  echo "$IOS_PRIVATE_KEY" | base64 --decode > ~/ios-certs/distribution.p12
fi 