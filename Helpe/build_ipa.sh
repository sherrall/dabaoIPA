#!/usr/bin/env bash
set -euo pipefail

command -v xcodegen >/dev/null || { echo "Install XcodeGen first: brew install xcodegen"; exit 1; }

xcodegen generate
xcodebuild \
  -project Helpe.xcodeproj \
  -scheme Helpe \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  build

APP="build/Build/Products/Release-iphoneos/Helpe.app"
rm -rf Payload Helpe.ipa
mkdir Payload
cp -R "$APP" "Payload/Helpe.app"

if command -v ldid >/dev/null; then
  ldid -S "Payload/Helpe.app/Helpe"
fi

zip -qry Helpe.ipa Payload
echo "Created Helpe.ipa"
