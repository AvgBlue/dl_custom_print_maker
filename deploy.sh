#!/bin/bash

# Ensure the script exits if any command fails
set -e

OUTPUT=$1
BASE_HREF=/$OUTPUT/
GITHUB_USER=AvgBlue
GITHUB_REPO=https://github.com/$GITHUB_USER/$OUTPUT
BUILD_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')

if [ -z "$OUTPUT" ]; then
    echo "OUTPUT is not set. Usage: ./deploy.sh <output_repo_name>"
    exit 1
fi

echo "Clean existing repository"
flutter clean

echo "Getting packages..."
flutter pub get

echo "Generating the web folder..."
flutter create . --platform web

echo "Building for web..."
flutter build web --release

echo "Deploying to git repository"
cd build/web
git init
git add .
git commit -m "Deploy Version $BUILD_VERSION"
git branch -M main
git remote add origin $GITHUB_REPO
git push -u -f origin main

echo "✅ Finished deploy: $GITHUB_REPO"
echo "🚀 Flutter web URL: https://$GITHUB_USER.github.io/$OUTPUT/"
