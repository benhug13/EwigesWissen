#!/bin/sh
set -e

# Xcode Cloud post-clone script
# Installs xcodegen and generates EwigesWissen.xcodeproj from project.yml
# Runs from within the ci_scripts/ directory; project root is one level up.

echo "📦 Installing xcodegen..."
brew install xcodegen

echo "📦 Build-Nummer aus Git..."
cd "$CI_PRIMARY_REPOSITORY_PATH"
BUILD_NUMBER=$(git rev-list --count HEAD)
echo "BUILD_NUMBER = $BUILD_NUMBER" > BuildNumber.xcconfig
sed -i '' "s/CURRENT_PROJECT_VERSION: .*/CURRENT_PROJECT_VERSION: \"$BUILD_NUMBER\"/" project.yml
echo "Build-Nummer: $BUILD_NUMBER"

echo "⚙️  Generating Xcode project..."
xcodegen generate

echo "✅ Setup done."
