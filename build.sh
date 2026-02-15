#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

DEVICE_ID="00008110-000E058022E0401E"
DEVICE_NAME="iPhone 13 pro von Ben"
SCHEME="EwigesWissen"
PROJECT="EwigesWissen.xcodeproj"

# Count git commits for build number
BUILD_NUMBER=$(git rev-list --count HEAD 2>/dev/null || echo "0")
echo "📦 Build-Nummer (Commits): $BUILD_NUMBER"

# Update BuildNumber.xcconfig
echo "BUILD_NUMBER = $BUILD_NUMBER" > BuildNumber.xcconfig

# Update CURRENT_PROJECT_VERSION in project.yml
sed -i '' "s/CURRENT_PROJECT_VERSION: .*/CURRENT_PROJECT_VERSION: \"$BUILD_NUMBER\"/" project.yml

# Regenerate Xcode project
echo "⚙️  XcodeGen..."
if command -v xcodegen &>/dev/null; then
    xcodegen generate
elif [ -x /tmp/xcodegen_bin/xcodegen/bin/xcodegen ]; then
    /tmp/xcodegen_bin/xcodegen/bin/xcodegen generate
else
    echo "❌ xcodegen nicht gefunden. Bitte installieren: brew install xcodegen"
    exit 1
fi

# Build for device
echo ""
echo "🔨 Build für $DEVICE_NAME..."
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "id=$DEVICE_ID" \
    -allowProvisioningUpdates \
    build 2>&1 | tail -5

echo ""
echo "✅ Build erfolgreich! Version 1.0.0 ($BUILD_NUMBER)"
