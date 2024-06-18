#!/bin/sh

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
if [[ "$CURRENT_HASH" == "$NEW_HASH" ]]; then
  echo "No changes detected, skipping build."
  exit 0
else
  echo "Changes detected, building... ($CURRENT_HASH != $NEW_HASH)"
fi

# Build the dylib.
cargo build

# Generate the Swift bindings, headers, and modulemap.
rm -rf "bindings"
cargo run --bin uniffi-bindgen generate --library ./target/debug/libshared.dylib --language swift --out-dir ./bindings

# Build the library for each target.
# Optional targets:
#   x86_64-apple-darwin
#   x86_64-apple-ios
#   aarch64-apple-ios-macabi (Mac Catalyst)
for TARGET in \
  aarch64-apple-darwin \
  aarch64-apple-ios \
  aarch64-apple-ios-sim; do
  # Uncomment this if you need to add the targets first.
  # rustup target add $TARGET
  cargo build --release --target=$TARGET
done

# Rename *.modulemap to module.modulemap
mv "./bindings/sharedFFI.modulemap" "./bindings/module.modulemap"

# Recreate the XCFramework.
rm -rf "ios/Shared.xcframework"
xcodebuild -create-xcframework \
  -library ./target/aarch64-apple-ios-sim/release/libshared.a -headers ./bindings \
  -library ./target/aarch64-apple-ios/release/libshared.a -headers ./bindings \
  -library ./target/aarch64-apple-darwin/release/libshared.a -headers ./bindings \
  -output "ios/Shared.xcframework"

# Finally, copy the Swift bindings into the XCode project which also updates the
# checksums in XCode.
rm -rf "$IOS_PROJECT/Generated/Shared.xcframework"
cp -r "ios/Shared.xcframework" "$IOS_PROJECT/Generated/Shared.xcframework"
rm -rf "$IOS_PROJECT/Generated/shared.swift"
cp "bindings/shared.swift" "$IOS_PROJECT/Generated/shared.swift"

# Done! No more steps since ./ios/Shared.xcframework and ./bindings/shared.swift are
# linked into the XCode project using relative paths to this directory.

# Update our build hash to skip unnecessary builds.
echo "$NEW_HASH" >target/build-hash.txt
