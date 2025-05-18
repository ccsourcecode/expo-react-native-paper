#!/bin/bash
set -e

# Define the project root directory
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DIR="$PROJECT_ROOT/ios"

echo "Setting up iOS signing..."

# Check if the iOS directory exists
if [ ! -d "$IOS_DIR" ]; then
  echo "Error: iOS directory not found. This script must be run on a macOS machine after generating the iOS project files."
  exit 1
fi

# Find the xcodeproj file
XCODEPROJ_PATH=$(find "$IOS_DIR" -name "*.xcodeproj" -depth 1 | head -n 1)
if [ -z "$XCODEPROJ_PATH" ]; then
  echo "Error: No Xcode project found in the iOS directory."
  exit 1
fi

PROJECT_NAME=$(basename "$XCODEPROJ_PATH" .xcodeproj)
echo "Found Xcode project: $PROJECT_NAME"

# Create a simple Ruby script to modify the Xcode project
TEMP_RUBY_SCRIPT="$IOS_DIR/update_signing.rb"
cat > "$TEMP_RUBY_SCRIPT" << 'EOF'
#!/usr/bin/env ruby
require 'xcodeproj'

# Get the project path from command line
project_path = ARGV[0]
team_id = ARGV[1] || "DEVELOPMENT_TEAM_PLACEHOLDER"

puts "Opening project at #{project_path}"
project = Xcodeproj::Project.open(project_path)

# For each target in the project
project.targets.each do |target|
  puts "Configuring target: #{target.name}"
  
  # For each build configuration (Debug, Release, etc.)
  target.build_configurations.each do |config|
    puts "Updating #{config.name} configuration"
    
    # Enable automatic signing
    config.build_settings["CODE_SIGN_STYLE"] = "Automatic"
    config.build_settings["DEVELOPMENT_TEAM"] = team_id
    
    # Set provisioning profile specifier to empty for automatic provisioning
    config.build_settings["PROVISIONING_PROFILE_SPECIFIER"] = ""
    
    # Additional settings for modern build system
    config.build_settings["CODE_SIGN_IDENTITY"] = "Apple Development"
    config.build_settings["CODE_SIGN_IDENTITY[sdk=iphoneos*]"] = "Apple Development"
  end
end

# Save the changes
project.save
puts "Project updated successfully!"
EOF

# Make the script executable
chmod +x "$TEMP_RUBY_SCRIPT"

# Install xcodeproj gem if not already installed
if ! gem list xcodeproj -i > /dev/null 2>&1; then
  echo "Installing xcodeproj gem..."
  gem install xcodeproj
fi

# Run the Ruby script
echo "Updating Xcode project signing settings..."
TEAM_ID=${TEAM_ID:-""}  # Use TEAM_ID env var if set, otherwise empty string
ruby "$TEMP_RUBY_SCRIPT" "$XCODEPROJ_PATH" "$TEAM_ID"

# Clean up
rm "$TEMP_RUBY_SCRIPT"

# Update the project.pbxproj file directly for CI environment
echo "Ensuring project.pbxproj has correct signing settings for CI..."
PROJECT_PBXPROJ="$XCODEPROJ_PATH/project.pbxproj"

# Replace any leftover manual signing with automatic
sed -i '' 's/CODE_SIGN_STYLE = Manual;/CODE_SIGN_STYLE = Automatic;/g' "$PROJECT_PBXPROJ"

# If no TEAM_ID was provided, check for FASTLANE_TEAM_ID and use that
if [ -z "$TEAM_ID" ] && [ ! -z "$FASTLANE_TEAM_ID" ]; then
  echo "Using FASTLANE_TEAM_ID: $FASTLANE_TEAM_ID"
  sed -i '' "s/DEVELOPMENT_TEAM = \"\";/DEVELOPMENT_TEAM = \"$FASTLANE_TEAM_ID\";/g" "$PROJECT_PBXPROJ"
  sed -i '' "s/DEVELOPMENT_TEAM_PLACEHOLDER/$FASTLANE_TEAM_ID/g" "$PROJECT_PBXPROJ"
fi

echo "iOS signing setup complete!" 