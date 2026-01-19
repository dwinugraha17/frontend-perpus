#!/bin/bash
set -e

echo "=== STARTING BUILD SCRIPT ==="
echo "Current directory: $(pwd)"

# 1. Clean up potential corrupted cache
if [ -d "flutter" ] && [ ! -f "flutter/bin/flutter" ]; then
    echo "WARNING: Flutter directory exists but binary is missing. Removing..."
    rm -rf flutter
fi

# 2. Download Flutter SDK if missing
if [ ! -d "flutter" ]; then
    echo "--- Cloning Flutter SDK (Stable) ---"
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
    echo "--- Flutter SDK found, skipping clone ---"
fi

# 3. Setup Path
export PATH="$(pwd)/flutter/bin:$PATH"

# 4. Verify Flutter Installation
echo "--- Verifying Flutter ---"
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter command not found in PATH!"
    exit 1
fi
flutter doctor -v

# 5. Config
echo "--- Configuring Flutter ---"
flutter config --enable-web
flutter config --no-analytics

# 6. Install Dependencies
echo "--- Installing Dependencies ---"
flutter pub get

# 7. Build
echo "--- Building Web App ---"
# Force HTML renderer for better compatibility and avoid black screen
flutter build web --release --web-renderer html --base-href /

# 8. Check Output
if [ ! -d "build/web" ]; then
    echo "ERROR: Build directory 'build/web' not found!"
    exit 1
fi

echo "=== BUILD SUCCESSFUL ==="
