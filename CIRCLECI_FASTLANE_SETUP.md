# Setting Up iOS Builds with CircleCI and fastlane

This guide explains how to set up iOS builds for your React Native/Expo project using CircleCI and fastlane.

## Prerequisites

- Apple Developer Account
- CircleCI account connected to your GitHub/GitLab repository
- Basic understanding of iOS code signing

## Environment Variables

Set the following environment variables in your CircleCI project settings:

### Required Variables

- `APPLE_TEAM_ID`: Your Apple Developer Team ID
- `APP_IDENTIFIER`: Your app's bundle identifier (e.g., com.yourcompany.exporeactnativepaper)

### App Store Connect API Authentication (Recommended)

- `ASC_KEY_ID`: Your App Store Connect API Key ID
- `ASC_ISSUER_ID`: Your App Store Connect API Issuer ID
- `ASC_KEY_CONTENT`: Your App Store Connect API Key content (with newlines as `\n`)

### Alternative: Apple ID Authentication

- `FASTLANE_USER`: Your Apple ID email
- `FASTLANE_PASSWORD`: Your Apple ID password or app-specific password
- `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`: App-specific password for Apple ID

### Code Signing with Match (Recommended)

- `MATCH_GIT_URL`: URL to your private match repository
- `MATCH_PASSWORD`: Password to decrypt the match repository
- `MATCH_GIT_BASIC_AUTH`: Base64-encoded username:password for private repo access (optional)
- `MATCH_READONLY`: Set to true for CI builds (default: true)

### Manual Provisioning Profile (Alternative to Match)

- `PROVISIONING_PROFILE_NAME`: Name of your provisioning profile

## Setting Up App Store Connect API Key

1. Go to App Store Connect > Users and Access > Keys
2. Create a new API Key with App Manager permissions
3. Download the .p8 file
4. Set the following environment variables in CircleCI:
   - `ASC_KEY_ID`: The Key ID shown in App Store Connect
   - `ASC_ISSUER_ID`: The Issuer ID shown in App Store Connect
   - `ASC_KEY_CONTENT`: The contents of the .p8 file with newlines replaced by `\n`

## Setting Up Match for Code Signing

Match is the recommended way to handle code signing for CI builds. It stores your certificates and provisioning profiles in a private Git repository.

1. Create a private Git repository for match
2. Set up match locally:
   ```
   cd ios
   fastlane match init
   ```
3. Generate certificates and profiles:
   ```
   fastlane match development
   fastlane match appstore
   ```
4. Set the `MATCH_GIT_URL` and `MATCH_PASSWORD` environment variables in CircleCI

## Troubleshooting

### Common Issues

1. **Build Fails with Code Signing Errors**:
   - Ensure your Team ID is correct
   - Check that your certificates and provisioning profiles are valid
   - Try using match instead of manual code signing

2. **"Invalid curve name" Error**:
   - Make sure your ASC_KEY_CONTENT is properly formatted with `\n` for newlines
   - Try base64 encoding the key and using ASC_KEY_CONTENT_BASE64 instead

3. **App Store Connect API Authentication Fails**:
   - Verify your ASC_KEY_ID and ASC_ISSUER_ID are correct
   - Check that your API key has the necessary permissions

4. **Xcode Version Issues**:
   - Make sure the Xcode version in the CircleCI config matches what your project requires

## Resources

- [fastlane Documentation](http://docs.fastlane.tools/getting-started/ios/setup/)
- [CircleCI iOS Documentation](https://circleci.com/docs/ios-tutorial/)
- [App Store Connect API Documentation](https://developer.apple.com/documentation/appstoreconnectapi) 