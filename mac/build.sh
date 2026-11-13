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
cd ../dist
rm -f OPUS-Helper.zip
if [ -n "${OPUS_SIGN_IDENTITY:-}" ]; then
  codesign --force --options runtime --timestamp --sign "$OPUS_SIGN_IDENTITY" "OPUS Helper.app"
  ditto -c -k --keepParent "OPUS Helper.app" OPUS-Helper.zip
  if [ -n "${OPUS_NOTARY_KEY:-}" ]; then
    xcrun notarytool submit OPUS-Helper.zip --key "$OPUS_NOTARY_KEY" --key-id "$OPUS_NOTARY_KEY_ID" --issuer "$OPUS_NOTARY_ISSUER" --wait
    xcrun stapler staple "OPUS Helper.app"
    rm -f OPUS-Helper.zip
    ditto -c -k --keepParent "OPUS Helper.app" OPUS-Helper.zip
    spctl --assess --type execute --verbose "OPUS Helper.app"
  fi
else
  codesign --force --sign - --timestamp=none "OPUS Helper.app"
  ditto -c -k --keepParent "OPUS Helper.app" OPUS-Helper.zip
fi
echo "built $(pwd)/OPUS-Helper.zip"
