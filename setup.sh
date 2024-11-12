#!/bin/bash

# Project Configuration
PROJECT_NAME="uniscript"
AUTHOR="Ally Elvis Nzeyimana"
GITHUB_USER="allyelvis"
REPO_NAME="uniscript_by_aenzbi"
VERSION_FILE="version.txt"
DIST_DIR="dist"
BUILD_DIR="build"

# Fetch or increment version number
if [ -f $VERSION_FILE ]; then
    VERSION=$(cat $VERSION_FILE)
    IFS='.' read -r major minor patch <<< "$VERSION"
    patch=$((patch+1))
    VERSION="$major.$minor.$patch"
else
    VERSION="1.0.0"
fi
echo "$VERSION" > $VERSION_FILE

REPO_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"

echo "Starting the final UniScript development and deployment process..."

# Clone or pull the latest from the repository
if [ -d "$PROJECT_NAME" ]; then
    cd $PROJECT_NAME
    git pull origin main
else
    git clone $REPO_URL
    cd $PROJECT_NAME
fi

# Generate source code files
echo "Generating source files for version $VERSION..."
SRC_DIR="src"
mkdir -p $SRC_DIR

cat > $SRC_DIR/main.us <<EOL
// Core file for UniScript v$VERSION by $AUTHOR
print("Welcome to UniScript $VERSION!")
function enhance() {
    print("Enhancing UniScript features automatically...")
}
EOL

# Update README with version and author information
cat > README.md <<EOL
# UniScript by Aenzbi

**Version:** $VERSION  
**Author:** $AUTHOR  

UniScript is designed for cross-platform app development in a unified, efficient way.

## Example Usage
\`\`\`uniscript
print("Hello, UniScript $VERSION World!")
\`\`\`
EOL

# Build Process
rm -rf $BUILD_DIR $DIST_DIR
mkdir -p $BUILD_DIR $DIST_DIR

# Package CLI tool if UniScript is Node-based
cat > $BUILD_DIR/package.json <<EOL
{
  "name": "$PROJECT_NAME",
  "version": "$VERSION",
  "description": "Cross-platform language for multi-platform deployment by Aenzbi.",
  "main": "main.js",
  "author": "$AUTHOR",
  "license": "MIT",
  "bin": {
    "uniscript": "./main.js"
  }
}
EOL

# Package binaries for Linux, Mac, and Windows
pkg $BUILD_DIR/main.js --output $DIST_DIR/${PROJECT_NAME}_linux --targets node18-linux-x64
pkg $BUILD_DIR/main.js --output $DIST_DIR/${PROJECT_NAME}_mac --targets node18-mac-x64
pkg $BUILD_DIR/main.js --output $DIST_DIR/${PROJECT_NAME}_win.exe --targets node18-win-x64

# Commit changes
git add .
git commit -m "Release UniScript $VERSION"
git push origin main

# Tag the release
git tag -a "v$VERSION" -m "UniScript version $VERSION"
git push origin "v$VERSION"

# Optional: Publish to npm
if [ -f "$BUILD_DIR/package.json" ]; then
    npm publish $BUILD_DIR
fi

echo "UniScript $VERSION built, packaged, and published successfully."
