#!/bin/bash

# USDZtoPNG Release Build Script
# This script builds the app for distribution

set -e  # Exit on any error

echo "🚀 Building USDZtoPNG for Release..."

# Configuration
PROJECT_NAME="USDZtoPNG"
SCHEME_NAME="USDZtoPNG"
CONFIGURATION="Release"
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
APP_PATH="$ARCHIVE_PATH/Products/Applications/$PROJECT_NAME.app"
RELEASE_DIR="release"
VERSION=$(xcodebuild -project "$PROJECT_NAME.xcodeproj" -showBuildSettings | grep -m 1 'MARKETING_VERSION' | awk '{print $3}')

echo "📦 Version: $VERSION"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf "$RELEASE_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$RELEASE_DIR"

# Build archive
echo "🔨 Building archive..."
xcodebuild archive \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "platform=macOS" \
    SKIP_INSTALL=NO \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO

# Check if app was built successfully
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build failed - app not found at $APP_PATH"
    exit 1
fi

echo "✅ Build successful!"

# Create DMG (optional - requires create-dmg tool)
if command -v create-dmg &> /dev/null; then
    echo "📀 Creating DMG..."
    create-dmg \
        --volname "$PROJECT_NAME" \
        --volicon "$APP_PATH/Contents/Resources/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 600 300 \
        --icon-size 100 \
        --icon "$PROJECT_NAME.app" 175 120 \
        --hide-extension "$PROJECT_NAME.app" \
        --app-drop-link 425 120 \
        "$RELEASE_DIR/$PROJECT_NAME-$VERSION.dmg" \
        "$APP_PATH"
    echo "✅ DMG created: $RELEASE_DIR/$PROJECT_NAME-$VERSION.dmg"
else
    echo "⚠️  create-dmg not found. Skipping DMG creation."
    echo "   Install with: brew install create-dmg"
fi

# Create ZIP archive
echo "📦 Creating ZIP archive..."
cd "$BUILD_DIR"
zip -r "../$RELEASE_DIR/$PROJECT_NAME-$VERSION.zip" "$PROJECT_NAME.xcarchive/Products/Applications/$PROJECT_NAME.app"
cd ..

echo "✅ ZIP created: $RELEASE_DIR/$PROJECT_NAME-$VERSION.zip"

# Show app info
echo ""
echo "📱 App Information:"
echo "   Path: $APP_PATH"
echo "   Version: $VERSION"
echo "   Size: $(du -h "$APP_PATH" | cut -f1)"

# Show release files
echo ""
echo "📦 Release Files:"
ls -la "$RELEASE_DIR/"

echo ""
echo "🎉 Release build complete!"
echo "📁 Files are in the '$RELEASE_DIR' directory"
echo ""
echo "Next steps:"
echo "1. Test the app thoroughly"
echo "2. Upload to GitHub Releases"
echo "3. Update README with download links" 