#!/bin/sh
set -eu
cd "$(dirname "$0")/OPUSHelper"
version="${OPUS_HELPER_VERSION:-0.1.0}"
build="${OPUS_HELPER_BUILD:-1}"
swift build -c release --arch arm64 --arch x86_64
bin="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/OPUSHelper"
app="../dist/OPUS Helper.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
cp "$bin" "$app/Contents/MacOS/OPUSHelper"
sed -e "s/__VERSION__/$version/" -e "s/__BUILD__/$build/" Resources/Info.plist > "$app/Contents/Info.plist"
codesign --force --sign - --timestamp=none "$app"
cd ../dist
rm -f OPUS-Helper.zip
ditto -c -k --keepParent "OPUS Helper.app" OPUS-Helper.zip
echo "built $(pwd)/OPUS-Helper.zip"
