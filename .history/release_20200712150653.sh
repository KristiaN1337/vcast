#!/bin/bash
set -e

# test locally
TESTDIR=build_test
rm -rf "$TESTDIR"
# run client tests with ASAN enabled
meson "$TESTDIR" -Db_sanitize=address
ninja -C"$TESTDIR" test

# test server
GRADLE=${GRADLE:-./gradlew}
$GRADLE -p server check

BUILDDIR=build_release
rm -rf "$BUILDDIR"
meson "$BUILDDIR" --buildtype release --strip -Db_lto=true
cd "$BUILDDIR"
ninja
cd -

# build Windows releases
make -f Makefile.CrossWindows

# the generated server must be the same everywhere
cmp "$BUILDDIR/server/vcast-server" dist/vcast-win32/vcast-server
cmp "$BUILDDIR/server/vcast-server" dist/vcast-win64/vcast-server

# get version name
TAG=$(git describe --tags --always)

# create release directory
mkdir -p "release-$TAG"
cp "$BUILDDIR/server/vcast-server" "release-$TAG/vcast-server-$TAG"
cp "dist/vcast-win32-$TAG.zip" "release-$TAG/"
cp "dist/vcast-win64-$TAG.zip" "release-$TAG/"

# generate checksums
cd "release-$TAG"
sha256sum "vcast-server-$TAG" \
          "vcast-win32-$TAG.zip" \
          "vcast-win64-$TAG.zip" > SHA256SUMS.txt

echo "Release generated in release-$TAG/"
