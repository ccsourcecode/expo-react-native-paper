# iOS Build Guide

This document provides instructions for setting up and running iOS builds for this Expo React Native project.

## Prerequisites

- **macOS**: iOS apps can only be built on macOS.
- **Xcode**: Make sure you have Xcode installed and updated to the latest version.
- **Apple Developer Account**: You need an Apple Developer account to sign and distribute iOS apps.
- **Ruby and Bundler**: Make sure Ruby and Bundler are installed.

## Environment Variables

The build process requires specific environment variables:

- `TEAM_ID` or `FASTLANE_TEAM_ID`: Your Apple Developer Team ID
- `APP_STORE_CONNECT_API_KEY` (optional): Base64-encoded App Store Connect API key
- `ASC_KEY_ID` (optional): App Store Connect API Key ID
- `ASC_ISSUER_ID` (optional): App Store Connect API Issuer ID
- `IOS_PRIVATE_KEY` (optional): Base64-encoded iOS distribution certificate private key

## Build Process

### 1. Generate Native Project Files

If you're starting from a managed Expo project, you need to first generate the native iOS files:

```bash
npx expo prebuild -p ios
```

### 2. Set Up Signing

The signing setup is handled automatically by our build scripts, but you need to make sure your Apple Developer Team ID is correctly set. For local development, you can:

1. Open the Xcode project in the `ios` directory
2. Go to the project settings
3. Select your team in the "Signing & Capabilities" tab

### 3. Running the Build

To run a build:

```bash
# From the project root
bash fastlane/deploy-ios.sh
```

### Troubleshooting

#### Common Issues:

1. **Missing Development Team**:

   ```
   error: Signing for "exporeactnativepaper" requires a development team
   ```

   - Solution: Set the `TEAM_ID` or `FASTLANE_TEAM_ID` environment variable to your Apple Developer Team ID.
2. **Certificate Issues**:

   - Ensure you have the correct distribution certificates and provisioning profiles.
   - For CI environments, provide them via the environment variables.
3. **Build Failures**:

   - Check Xcode logs for detailed error messages.
   - Ensure your project has a valid Bundle Identifier that matches your provisioning profile.

#### Finding Your Team ID

Your Team ID can be found in the Apple Developer portal:

1. Log in to [developer.apple.com](https://developer.apple.com)
2. Go to "Membership" in the sidebar
3. Your Team ID is listed under "Team ID"

## CI/CD Integration

For CI/CD environments, ensure all required environment variables are set in your CI system. The build scripts are designed to work automatically in CI environments when properly configured.

### CircleCI Example

```yaml
jobs:
  build_ios:
    macos:
      xcode: 15.0.0
    environment:
      FASTLANE_TEAM_ID: "YOUR_TEAM_ID"
    steps:
      - checkout
      - run: npm install
      - run: npx expo prebuild -p ios
      - run: bash fastlane/deploy-ios.sh
```
