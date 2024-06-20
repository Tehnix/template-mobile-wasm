#!/bin/bash

set -e

IOS_PROJECT="../appy/ios/App"

LIBRARY_NAME="shared"
LIBRARY_FILE="libmobile"

ADD_TARGETS=true
BUILD_WATCHOS_TARGETS=true
FORCE_RUN=false

for i in "$@"; do
  case $i in
    --force)
      FORCE_RUN="true"
      shift # Move to next argument.
      ;;
    --skip-watchos)
      BUILD_WATCHOS_TARGETS="false"
      shift # Move to next argument.
      ;;
    --skip-targets)
      ADD_TARGETS="false"
      shift # Move to next argument.
      ;;
    --*)
      echo "Unknown option $i"
      echo "Supported options:"
      echo "  --force: Force a build even if no changes are detected."
      echo "  --skip-watchos: Skip building watchOS targets."
      echo "  --skip-targets: Skip adding targets."
      exit 1
      ;;
    *) ;;
  esac
done

# Add homebrew items to path.
export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# Change to this directory (by default we'll be in the Xcode project directory)
SCRIPT_PATH=$(dirname "$(realpath $0)")
echo "$SCRIPT_PATH"
cd "$SCRIPT_PATH"

CURRENT_HASH=$(cat target/build-hash-ios.txt || echo "none")
NEW_HASH=$(find ./src ../shared/src -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum)

# If nothing changed, we skip the build. This not only has a performance benefit,
# but also stops Xcode from getting stuck in a recompile loop, since it will see
# the file timestamps being updated by the build script, and will recompile things.
if [[ "$FORCE_RUN" == "false" && "$CURRENT_HASH" == "$NEW_HASH" ]]; then
  echo "No changes detected, skipping build."
  exit 0
else
  echo "Changes detected, building... ($CURRENT_HASH != $NEW_HASH)"
fi

# Build the library.
cargo build

# Generate the Swift bindings, headers, and modulemap.
rm -rf "bindings" || echo "No bindings directory to remove."
cargo run --bin uniffi-bindgen generate --library ./target/debug/$LIBRARY_FILE.a --language swift --out-dir ./bindings

# Build the library for each target.
# NOTE: x86_64-apple-ios is actually also a simulator target.
# Optional targets:
# - x86_64-apple-darwin
# - aarch64-apple-ios-macabi (Mac Catalyst)
for TARGET in \
  aarch64-apple-darwin \
  aarch64-apple-ios \
  aarch64-apple-ios-sim \
  x86_64-apple-ios; do
  echo "Building $TARGET..."
  if [[ "$ADD_TARGETS" == "true" ]]; then
    rustup target add $TARGET
  fi
  cargo build --release --target=$TARGET
  echo "Finished building $TARGET."
done

# watchOS is a Tier 3 target, so we have to build the standard library ourselves.
# NOTE: We need all the watchOS targets to be built at the same time, to be able
# to run them in the simulator and on the device.
if [[ "$BUILD_WATCHOS_TARGETS" == "true" ]]; then
  rustup +nightly component add rust-src
  for TARGET in \
    aarch64-apple-watchos-sim \
    x86_64-apple-watchos-sim \
    aarch64-apple-watchos \
    armv7k-apple-watchos \
    arm64_32-apple-watchos; do
    echo "Building $TARGET..."
    cargo +nightly build -Zbuild-std=std,panic_abort --release --target=$TARGET
    echo "Finished building $TARGET."
  done
  # Combine the watchOS libraries into a single file using lipo.
  echo "Combining watchOS Simulator libraries..."
  mkdir -p target/watchOS-sim/release
  lipo -create target/aarch64-apple-watchos-sim/release/$LIBRARY_FILE.a \
    target/x86_64-apple-watchos-sim/release/$LIBRARY_FILE.a \
    -o target/watchOS-sim/release/$LIBRARY_FILE.a
  # Confirm the architectures.
  lipo -info target/watchOS-sim/release/$LIBRARY_FILE.a

  echo "Combining watchOS libraries..."
  mkdir -p target/watchOS/release
  lipo -create target/aarch64-apple-watchos/release/$LIBRARY_FILE.a \
    target/arm64_32-apple-watchos/release/$LIBRARY_FILE.a \
    target/armv7k-apple-watchos/release/$LIBRARY_FILE.a \
    -o target/watchOS/release/$LIBRARY_FILE.a
  # Confirm the architectures.
  lipo -info target/watchOS/release/$LIBRARY_FILE.a
fi

# Rename *.modulemap to module.modulemap
mv "./bindings/${LIBRARY_NAME}FFI.modulemap" "./bindings/module.modulemap"

# Recreate the XCFramework.
echo "Constructing the XCFramework..."
rm -rf "ios/Shared.xcframework" || echo "No XCFramework to remove."
if [[ "$BUILD_WATCHOS_TARGETS" == "true" ]]; then
  xcodebuild -create-xcframework \
    -library ./target/aarch64-apple-ios-sim/release/$LIBRARY_FILE.a -headers ./bindings \
    -library ./target/aarch64-apple-ios/release/$LIBRARY_FILE.a -headers ./bindings \
    -library ./target/aarch64-apple-darwin/release/$LIBRARY_FILE.a -headers ./bindings \
    -library ./target/watchOS-sim/release/$LIBRARY_FILE.a -headers ./bindings \
    -library ./target/watchOS/release/$LIBRARY_FILE.a -headers ./bindings \
    -output "ios/Shared.xcframework"
else
  xcodebuild -create-xcframework \
    -library ./target/aarch64-apple-ios-sim/release/$LIBRARY_FILE.a -headers ./bindings \
    -library ./target/aarch64-apple-ios/release/$LIBRARY_FILE.a -headers ./bindings \
    -library ./target/aarch64-apple-darwin/release/$LIBRARY_FILE.a -headers ./bindings \
    -output "ios/Shared.xcframework"
fi

# We need to combine the architectures for the iOS Simulator libraries after we've
# constructed the XCFramework, otherwise it will complain about them being the same,
# while also failing because of missing x86_64 if we omit it.
echo "Combining iOS Simulator libraries..."
mkdir -p target/iOS-sim/release
lipo -create target/aarch64-apple-ios-sim/release/$LIBRARY_FILE.a \
  target/x86_64-apple-ios/release/$LIBRARY_FILE.a \
  -o target/iOS-sim/release/$LIBRARY_FILE.a
# Confirm the architectures.
lipo -info target/iOS-sim/release/$LIBRARY_FILE.a
# Move it into place.
rm ios/Shared.xcframework/ios-arm64-simulator/$LIBRARY_FILE.a
cp target/iOS-sim/release/$LIBRARY_FILE.a ios/Shared.xcframework/ios-arm64-simulator/$LIBRARY_FILE.a

# Finally, copy the Swift bindings into the Xcode project which also updates the
# checksums in Xcode.
rm -rf "$IOS_PROJECT/Generated/Shared.xcframework" || echo "No XCFramework to remove."
cp -r "ios/Shared.xcframework" "$IOS_PROJECT/Generated/Shared.xcframework"
rm -rf "$IOS_PROJECT/Generated/shared.swift" || echo "No shared.swift to remove."
cp "bindings/${LIBRARY_NAME}.swift" "$IOS_PROJECT/Generated/shared.swift"

# Done! No more steps since ./ios/Shared.xcframework and ./bindings/shared.swift are
# linked into the Xcode project using relative paths to this directory.

# Update our build hash to skip unnecessary builds.
echo "$NEW_HASH" >target/build-hash-ios.txt

echo "Done!"
