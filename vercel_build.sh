#!/bin/bash

# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

# Run flutter doctor
flutter doctor

# Enable web support
flutter config --enable-web

# Build the web app
flutter build web --release --web-renderer html

# Copy output to public folder (Vercel looks here)
cp -r build/web/* .
