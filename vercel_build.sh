#!/bin/bash
set -e # Hentikan script jika ada perintah yang error

echo "--- 1. Checking Environment ---"
echo "Current directory: $(pwd)"

# Download Flutter SDK (Hanya jika belum ada)
if [ ! -d "flutter" ]; then
    echo "--- 2. Cloning Flutter SDK ---"
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
    echo "--- 2. Flutter SDK found, skipping clone ---"
fi

# Add flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

# Run flutter doctor
echo "--- 3. Running Flutter Doctor ---"
flutter doctor -v

# Enable web support
flutter config --enable-web

# Get Dependencies
echo "--- 4. Getting Packages ---"
flutter pub get

# Build the web app
echo "--- 5. Building Web App ---"
# Tambahkan --verbose jika ingin log sangat detail, tapi --release sudah cukup biasanya
flutter build web --release --web-renderer html --no-tree-shake-icons

# Check build result
if [ ! -d "build/web" ]; then
    echo "ERROR: Folder build/web tidak ditemukan! Build gagal."
    exit 1
fi

echo "--- 6. Copying Output ---"
# Copy output to public folder (Vercel looks here)
cp -r build/web/* .

echo "--- SUCCESS! ---"