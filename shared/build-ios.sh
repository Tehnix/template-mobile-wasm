#!/bin/sh

ADD_TARGETS=true
BUILD_WATCHOS_TARGETS=true

# Add homebrew items to path.
export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

IOS_PROJECT="../appy/ios/App"

# Change to this directory (by default we'll be in the XCode project directory)
SCRIPT_PATH=$(dirname "$(realpath $0)")
echo "$SCRIPT_PATH"
cd "$SCRIPT_PATH"

CURRENT_HASH=$(cat target/build-hash.txt || echo "none")
NEW_HASH=$(find ./src -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum)

# If nothing changed, we skip the build. This not only has a performance benefit,
# but also stops XCode from getting stuck in a recompile loop, since it will see
# the file timestamps being updated by the build script, and will recompile things.
# if [[ "$CURRENT_HASH" == "$NEW_HASH" ]]; then
#   echo "No changes detected, skipping build."
#   exit 0
# else
#   echo "Changes detected, building... ($CURRENT_HASH != $NEW_HASH)"
# fi

# Build the library.
cargo build

# Generate the Swift bindings, headers, and modulemap.
rm -rf "bindings" || echo "No bindings directory to remove."
cargo run --bin uniffi-bindgen generate --library ./target/debug/libshared.a --language swift --out-dir ./bindings

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
  lipo -create target/aarch64-apple-watchos-sim/release/libshared.a \
    target/x86_64-apple-watchos-sim/release/libshared.a \
    -o target/watchOS-sim/release/libshared.a
  # Confirm the architectures.
  lipo -info target/watchOS-sim/release/libshared.a

  echo "Combining watchOS libraries..."
  mkdir -p target/watchOS/release
  lipo -create target/aarch64-apple-watchos/release/libshared.a \
    target/arm64_32-apple-watchos/release/libshared.a \
    target/armv7k-apple-watchos/release/libshared.a \
    -o target/watchOS/release/libshared.a
  # Confirm the architectures.
  lipo -info target/watchOS/release/libshared.a
fi

# Rename *.modulemap to module.modulemap
mv "./bindings/sharedFFI.modulemap" "./bindings/module.modulemap"

# Recreate the XCFramework.
echo "Constructing the XCFramework..."
rm -rf "ios/Shared.xcframework" || echo "No XCFramework to remove."
if [[ "$BUILD_WATCHOS_TARGETS" == "true" ]]; then
  xcodebuild -create-xcframework \
    -library ./target/aarch64-apple-ios-sim/release/libshared.a -headers ./bindings \
    -library ./target/aarch64-apple-ios/release/libshared.a -headers ./bindings \
    -library ./target/aarch64-apple-darwin/release/libshared.a -headers ./bindings \
    -library ./target/watchOS-sim/release/libshared.a -headers ./bindings \
    -library ./target/watchOS/release/libshared.a -headers ./bindings \
    -output "ios/Shared.xcframework"
else
  xcodebuild -create-xcframework \
    -library ./target/aarch64-apple-ios-sim/release/libshared.a -headers ./bindings \
    -library ./target/aarch64-apple-ios/release/libshared.a -headers ./bindings \
    -library ./target/aarch64-apple-darwin/release/libshared.a -headers ./bindings \
    -output "ios/Shared.xcframework"
fi

# We need to combine the architectures for the iOS Simulator libraries after we've
# constructed the XCFramework, otherwise it will complain about them being the same,
# while also failing because of missing x86_64 if we omit it.
echo "Combining iOS Simulator libraries..."
mkdir -p target/iOS-sim/release
lipo -create target/aarch64-apple-ios-sim/release/libshared.a \
  target/x86_64-apple-ios/release/libshared.a \
  -o target/iOS-sim/release/libshared.a
# Confirm the architectures.
lipo -info target/iOS-sim/release/libshared.a
# Move it into place.
rm ios/Shared.xcframework/ios-arm64-simulator/libshared.a
cp target/iOS-sim/release/libshared.a ios/Shared.xcframework/ios-arm64-simulator/libshared.a

# Finally, copy the Swift bindings into the XCode project which also updates the
# checksums in XCode.
rm -rf "$IOS_PROJECT/Generated/Shared.xcframework" || echo "No XCFramework to remove."
cp -r "ios/Shared.xcframework" "$IOS_PROJECT/Generated/Shared.xcframework"
rm -rf "$IOS_PROJECT/Generated/shared.swift" || echo "No shared.swift to remove."
cp "bindings/shared.swift" "$IOS_PROJECT/Generated/shared.swift"

# Done! No more steps since ./ios/Shared.xcframework and ./bindings/shared.swift are
# linked into the XCode project using relative paths to this directory.

# Update our build hash to skip unnecessary builds.
echo "$NEW_HASH" >target/build-hash.txt

echo "Done!"
