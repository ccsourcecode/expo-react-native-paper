#!/bin/bash
set -e

echo "Setting up iOS signing configuration..."

# Create ios directory if it doesn't exist
mkdir -p ios

# Create or update exportOptions.plist with the actual Apple Team ID
if [ -n "$APPLE_TEAM_ID" ]; then
  echo "Using Apple Team ID: $APPLE_TEAM_ID"
  
  # Create the exportOptions.plist file with the real team ID
  cat > ios/exportOptions.plist << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$APPLE_TEAM_ID</string>
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
else
  echo "Warning: APPLE_TEAM_ID environment variable not set."
  echo "Using placeholder value in exportOptions.plist"
fi

echo "iOS signing configuration complete!" 