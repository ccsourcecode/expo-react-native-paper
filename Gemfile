source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
gem "aws-sdk-s3", "~> 1.123.0"
gem "aws-sdk-core", "~> 3.174.0"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path) 