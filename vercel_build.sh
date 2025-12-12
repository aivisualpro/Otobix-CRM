#!/bin/bash
set -e

# Download Flutter 3.35.5 (includes Dart >=3.9)
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.5-stable.tar.xz

# Extract Flutter
tar xf flutter_linux_3.35.5-stable.tar.xz

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Fix git safe directory warning
git config --global --add safe.directory /vercel/path0/flutter

# Enable web & install dependencies
flutter config --enable-web
flutter pub get

# Build for web
flutter build web
Collapse










