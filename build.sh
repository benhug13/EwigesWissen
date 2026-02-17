#!/bin/bash
set -eo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

SCHEME="EwigesWissen"
PROJECT="EwigesWissen.xcodeproj"
APP_PATH="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -showBuildSettings 2>/dev/null | grep -m1 "BUILT_PRODUCTS_DIR" | awk '{print $3}')/EwigesWissen.app"

# Devices
DEVICES=(
    "00008110-000E058022E0401E|iPhone 13 pro von Ben"
    "00008130-0004446200698D3A|iPhone von Tom"
)

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

# Build once (for first device destination, works for all since same arch)
FIRST_ID="${DEVICES[0]%%|*}"
echo ""
echo "🔨 Build..."
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "id=$FIRST_ID" \
    -allowProvisioningUpdates \
    build 2>&1 | tail -3

# Recalculate app path after build
APP_PATH="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "id=$FIRST_ID" -showBuildSettings 2>/dev/null | grep -m1 "BUILT_PRODUCTS_DIR" | awk '{print $3}')/EwigesWissen.app"

# Install on each device
for entry in "${DEVICES[@]}"; do
    DEVICE_ID="${entry%%|*}"
    DEVICE_NAME="${entry##*|}"

    echo ""
    echo "📲 Installiere auf $DEVICE_NAME..."
    xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH" 2>&1 | tail -3
done

echo ""
echo "✅ Version 1.0.0 ($BUILD_NUMBER) auf allen Geräten installiert!"
