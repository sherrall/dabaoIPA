# Helpe

Helpe is an original, independent iOS app for adding a short intentional pause before opening a chosen app. It is not a clone of any existing app and contains no copied code, assets, branding, entitlements, or product IDs.

## Features

- Local app shortcut list
- Breathing pause flow
- Intention input
- Attempt history stored on device

## Build Locally

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen).
2. Run `./build_ipa.sh` on macOS with Xcode installed.
3. Open the generated `Helpe.ipa`.

## Package With GitHub Actions

Run the **Build Unsigned IPA** workflow. The workflow creates `Helpe.ipa` and uploads it as an artifact. The app is unsigned, so it is intended for tools that accept unsigned or pseudo-signed IPAs. Installing on a standard iPhone still requires Apple development signing.
