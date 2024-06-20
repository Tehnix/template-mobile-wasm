#!/bin/bash

set -e

ANDROID_PROJECT="../appy/android/app"
ANDROID_GENERATED_DIR="$ANDROID_PROJECT/src/main/java/com/example/shared"

LIBRARY_FILE="libmobile"

ADD_TARGETS=true
FORCE_RUN=false

for i in "$@"; do
  case $i in
    --force)
      FORCE_RUN="true"
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

CURRENT_HASH=$(cat target/build-hash-android.txt || echo "none")
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

if [[ "$ADD_TARGETS" == "true" ]]; then
  rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi \
    i686-linux-android \
    x86_64-linux-android
fi

# Build the library.
cargo build

# Build the Android libraries in jniLibs
cargo ndk -o "$ANDROID_PROJECT/src/main/jniLibs" \
  --manifest-path ./Cargo.toml \
  -t armeabi-v7a \
  -t arm64-v8a \
  -t x86 \
  -t x86_64 \
  build --release

# Generate the Kotlin bindings.
rm -rf "$ANDROID_GENERATED_DIR" || echo "No Kotlin bindings directory to remove."
cargo run --bin uniffi-bindgen generate --library ./target/debug/$LIBRARY_FILE.dylib --language kotlin --out-dir "$ANDROID_GENERATED_DIR"

# Update our build hash to skip unnecessary builds.
echo "$NEW_HASH" >target/build-hash-android.txt

echo "Done!"
