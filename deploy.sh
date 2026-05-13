#!/bin/bash
set -eo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

SCHEME="EwigesWissen"
PROJECT="EwigesWissen.xcodeproj"
ARCHIVE_PATH="$PROJECT_DIR/build/EwigesWissen.xcarchive"
EXPORT_PATH="$PROJECT_DIR/build/export"
IPA_PATH="$EXPORT_PATH/EwigesWissen.ipa"

API_KEY_ID="1A4EOTQ8Y2MN"
API_ISSUER_ID="d47ec6ac-49e9-4f30-8695-016b515d3d2f"

# Bump build number from git commits
BUILD_NUMBER=$(git rev-list --count HEAD 2>/dev/null || echo "0")
echo "📦 Build-Nummer: $BUILD_NUMBER"
echo "BUILD_NUMBER = $BUILD_NUMBER" > BuildNumber.xcconfig
sed -i '' "s/CURRENT_PROJECT_VERSION: .*/CURRENT_PROJECT_VERSION: \"$BUILD_NUMBER\"/" project.yml

# Regenerate Xcode project
echo "⚙️  XcodeGen..."
if [ -x "$HOME/.local/bin/xcodegen-2.39" ]; then
    "$HOME/.local/bin/xcodegen-2.39" generate
elif command -v xcodegen &>/dev/null; then
    xcodegen generate
else
    echo "❌ xcodegen nicht gefunden."; exit 1
fi

# Clean previous build
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"
mkdir -p build

# Archive (Release config, generic iOS device)
echo ""
echo "📦 Archive..."
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    archive 2>&1 | tail -5

# Export IPA
echo ""
echo "📤 Export IPA..."
xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist ExportOptions.plist \
    -exportPath "$EXPORT_PATH" \
    -allowProvisioningUpdates 2>&1 | tail -5

# Upload to App Store Connect (TestFlight)
echo ""
echo "🚀 Upload to App Store Connect..."
xcrun altool --upload-app \
    --type ios \
    --file "$IPA_PATH" \
    --apiKey "$API_KEY_ID" \
    --apiIssuer "$API_ISSUER_ID"

echo ""
echo "✅ Build $BUILD_NUMBER hochgeladen!"
echo "   Prüfe TestFlight in 10-30 Min: https://appstoreconnect.apple.com"
