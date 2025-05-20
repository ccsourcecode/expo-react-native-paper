# Setting Up iOS Builds on CircleCI with fastlane

This guide provides step-by-step instructions to fix iOS build issues on CircleCI using fastlane.

## Step 1: Install fastlane locally

First, make sure you have Ruby and Bundler installed:

```bash
# Install Ruby (if not already installed)
# On macOS:
brew install ruby

# Install Bundler
gem install bundler
```

## Step 2: Configure your Gemfile

Create or update your Gemfile at the root of your project:

```ruby
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
```

## Step 3: Install gems locally

To avoid permission issues, install gems locally in the project:

```bash
# Configure bundler to install gems locally
bundle config set --local path 'vendor/bundle'

# Install gems
bundle install
```

## Step 4: Create required fastlane files

Create the following files:

### fastlane/Appfile
```ruby
app_identifier(ENV["APP_IDENTIFIER"] || "com.yourcompany.appname") # The bundle identifier of your app
apple_id(ENV["FASTLANE_USER"]) # Your Apple ID
team_id(ENV["APPLE_TEAM_ID"]) # Developer Portal Team ID
```

### fastlane/Matchfile (if using match for code signing)
```ruby
git_url(ENV["MATCH_GIT_URL"])
storage_mode("git")
type("appstore")
app_identifier([ENV["APP_IDENTIFIER"] || "com.yourcompany.appname"])
username(ENV["FASTLANE_USER"])
```

## Step 5: Create a deployment script

Create a file named `fastlane/deploy-ios.sh`:

```bash
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
```

Make the script executable:

```bash
chmod +x fastlane/deploy-ios.sh
```

## Step 6: Configure CircleCI

Update your `.circleci/config.yml` file:

```yaml
version: 2.1

orbs:
  node: circleci/node@5
  macos: circleci/macos@2.0.0

jobs:
  build-ios:
    macos:
      xcode: "15.4.0"  # Use the appropriate Xcode version
    environment:
      FL_OUTPUT_DIR: output
      FASTLANE_SKIP_UPDATE_CHECK: "true"
      FASTLANE_HIDE_CHANGELOG: "true"
      FASTLANE_DISABLE_COLORS: "true"
    steps:
      - checkout
      - node/install:
          node-version: '22.15.0'
      - run:
          name: Install node modules
          command: npm i
      - macos/switch-ruby:
          version: "3.1.3"
      - run:
          name: Install Bundler
          command: gem install bundler
      - restore_cache:
          keys:
            - gem-cache-v1-{{ checksum "Gemfile.lock" }}
      - run:
          name: Bundle install
          command: |
            bundle config set --local path 'vendor/bundle'
            bundle install
      - save_cache:
          key: gem-cache-v1-{{ checksum "Gemfile.lock" }}
          paths:
            - vendor/bundle
      - run:
          name: Install CocoaPods
          command: |
            cd ios
            pod install || pod install --repo-update
      - run:
          name: Run deploy script
          command: |
            chmod +x fastlane/deploy-ios.sh
            ./fastlane/deploy-ios.sh
          no_output_timeout: 30m

workflows:
  build-and-test:
    jobs:
      - build-ios
```

## Step 7: Set up environment variables in CircleCI

Add these environment variables in your CircleCI project settings:

### Required variables:
- `APPLE_TEAM_ID`: Your Apple Developer Team ID
- `APP_IDENTIFIER`: Your app's bundle identifier

### App Store Connect API Authentication (recommended):
- `ASC_KEY_ID`: Your App Store Connect API Key ID
- `ASC_ISSUER_ID`: Your App Store Connect API Issuer ID
- `ASC_KEY_CONTENT`: Your App Store Connect API Key content (with newlines as `\n`)

### Alternative: Apple ID Authentication:
- `FASTLANE_USER`: Your Apple ID email
- `FASTLANE_PASSWORD`: Your Apple ID password
- `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`: App-specific password

### Match code signing (if using):
- `MATCH_GIT_URL`: URL to your match repository
- `MATCH_PASSWORD`: Password to decrypt your match repository

## Step 8: Troubleshooting

If you encounter issues:

1. **Permission errors during gem installation**: Use `bundle config set --local path 'vendor/bundle'` to install gems locally.

2. **App Store Connect API authentication errors**: Check that your API key is properly formatted with newlines as `\n`.

3. **Code signing errors**: Consider using match for code signing, which is more reliable in CI environments.

4. **Build timeout**: Increase the `no_output_timeout` value in your CircleCI config if builds are timing out.

5. **Xcode version issues**: Make sure the Xcode version in CircleCI matches what your project requires. 