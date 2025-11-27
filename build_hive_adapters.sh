#!/bin/bash

# Script to generate Hive type adapters
# Run this after adding or modifying any @HiveType models

echo "🏗️  Building Hive adapters..."

# Clean previous builds
echo "Cleaning previous builds..."
flutter pub run build_runner clean

# Generate adapters
echo "Generating adapters..."
flutter pub run build_runner build --delete-conflicting-outputs

# Check if successful
if [ $? -eq 0 ]; then
    echo "✅ Hive adapters generated successfully!"
    echo ""
    echo "Generated files:"
    find lib -name "*.g.dart" -type f
else
    echo "❌ Failed to generate Hive adapters"
    exit 1
fi
