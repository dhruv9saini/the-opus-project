#!/bin/sh
set -eu
cd "$(dirname "$0")/OPUSAtHome"
version="${OPUS_AT_HOME_VERSION:-0.1.0}"
build="${OPUS_AT_HOME_BUILD:-1}"
swift build -c release --arch arm64 --arch x86_64
bin="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/OPUSAtHome"
app="../dist/OPUS@Home.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
cp "$bin" "$app/Contents/MacOS/OPUSAtHome"
sed -e "s/__VERSION__/$version/" -e "s/__BUILD__/$build/" Resources/Info.plist > "$app/Contents/Info.plist"
cd ../dist
rm -f OPUS-at-Home.zip
if [ -n "${OPUS_SIGN_IDENTITY:-}" ]; then
  codesign --force --options runtime --timestamp --sign "$OPUS_SIGN_IDENTITY" "OPUS@Home.app"
  ditto -c -k --keepParent "OPUS@Home.app" OPUS-at-Home.zip
  if [ -n "${OPUS_NOTARY_KEY:-}" ]; then
    xcrun notarytool submit OPUS-at-Home.zip --key "$OPUS_NOTARY_KEY" --key-id "$OPUS_NOTARY_KEY_ID" --issuer "$OPUS_NOTARY_ISSUER" --wait
    xcrun stapler staple "OPUS@Home.app"
    rm -f OPUS-at-Home.zip
    ditto -c -k --keepParent "OPUS@Home.app" OPUS-at-Home.zip
    spctl --assess --type execute --verbose "OPUS@Home.app"
  fi
else
  codesign --force --sign - --timestamp=none "OPUS@Home.app"
  ditto -c -k --keepParent "OPUS@Home.app" OPUS-at-Home.zip
fi
echo "built $(pwd)/OPUS-at-Home.zip"
