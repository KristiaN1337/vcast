#!/bin/bash
#
# This script generates the scrcpy binary "manually" (without gradle).
#
# Adapt Android platform and build tools versions (via ANDROID_PLATFORM and
# ANDROID_BUILD_TOOLS environment variables).
#
# Then execute:
#
#     BUILD_DIR=my_build_dir ./build_without_gradle.sh

set -e

SCRCPY_DEBUG=false
SCRCPY_VERSION_NAME=1.14

PLATFORM=${ANDROID_PLATFORM:-29}
BUILD_TOOLS=${ANDROID_BUILD_TOOLS:-29.0.2}

BUILD_DIR="$(realpath ${BUILD_DIR:-build_manual})"
CLASSES_DIR="$BUILD_DIR/classes"
SERVER_DIR=$(dirname "$0")
SERVER_BINARY=scrcpy-server

echo "Platform: android-$PLATFORM"
echo "Build-tools: $BUILD_TOOLS"
echo "Build dir: $BUILD_DIR"

rm -rf "$CLASSES_DIR" "$BUILD_DIR/$SERVER_BINARY" classes.dex
mkdir -p "$CLASSES_DIR/com/KristiaN1337/scrcpy"

<< EOF cat > "$CLASSES_DIR/com/KristiaN1337/scrcpy/BuildConfig.java"
package com.KristiaN1337.scrcpy;

public final class BuildConfig {
  public static final boolean DEBUG = $SCRCPY_DEBUG;
  public static final String VERSION_NAME = "$SCRCPY_VERSION_NAME";
}
EOF

echo "Generating java from aidl..."
cd "$SERVER_DIR/src/main/aidl"
"$ANDROID_HOME/build-tools/$BUILD_TOOLS/aidl" -o"$CLASSES_DIR" \
    android/view/IRotationWatcher.aidl
"$ANDROID_HOME/build-tools/$BUILD_TOOLS/aidl" -o"$CLASSES_DIR" \
    android/content/IOnPrimaryClipChangedListener.aidl

echo "Compiling java sources..."
cd ../java
javac -bootclasspath "$ANDROID_HOME/platforms/android-$PLATFORM/android.jar" \
    -cp "$CLASSES_DIR" -d "$CLASSES_DIR" -source 1.8 -target 1.8 \
    com/KristiaN1337/scrcpy/*.java \
    com/KristiaN1337/scrcpy/wrappers/*.java

echo "Dexing..."
cd "$CLASSES_DIR"
"$ANDROID_HOME/build-tools/$BUILD_TOOLS/dx" --dex \
    --output "$BUILD_DIR/classes.dex" \
    android/view/*.class \
    android/content/*.class \
    com/KristiaN1337/scrcpy/*.class \
    com/KristiaN1337/scrcpy/wrappers/*.class

echo "Archiving..."
cd "$BUILD_DIR"
jar cvf "$SERVER_BINARY" classes.dex
rm -rf classes.dex classes

echo "Server generated in $BUILD_DIR/$SERVER_BINARY"
