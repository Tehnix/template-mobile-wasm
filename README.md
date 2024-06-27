# Mobile: Rust on Mobile

> This is a template project for building a Rust application that can be run on Web, iOS and Android using Leptos, Capacitor and UniFFI.

After exploring multiple solutions to working with Rust on Mobile, this seems so far to be the best option:

- Compile to WASM via Rust and a framework such as Leptos
- Package WASM using [Capacitor](https://capacitorjs.com/docs)
- Interface with [Capacitor Plugins](https://capacitorjs.com/docs/plugins)
- Support native Widgets using the generated Xcode project and Swift
- Use Rust code from Swift via [UniFFI](https://github.com/mozilla/uniffi-rs)

So that's exactly what I've set up in this repository, ready to use:

- `appy`: A Rust/Leptos/WASM Frontend, with i18n, TailwindCSS, and CapacitorJS set up
  - We've added setup for Android, iOS, iOS Widgets, watchOS, and macOS (via the iOS App)
- `shared`: Code that is shared between `appy` and the `mobile` crate
- `capacitor-rs`: Exposing bindings to the Capacitor JavaScript library, so we can use it in Rust
- `mobile`: Pulls in and reexports `shared` to generate UniFFI bindings for Swift + Kotlin

We use [just](https://github.com/casey/just) to setup various commands in the `justfile` (`brew install just` to install it).

You can run `just` or `just help` to see all available commands and some helpful resources:

```bash
Available recipes:
    build               # Build our Web App, Shared code, and sync the changes to our Mobile Apps.
    build-plugins       # Only bundle the Capacitor JavaScript plugin files.
    build-shared platform="ios" args="" # Only generate the Swift bindings for our Shared code. Platform can be "ios" or "android" (default "ios"). Args can be passed to the script e.g. "--force" (default "").
    build-web           # Only build our Web App and sync the code to our Mobile Apps.
    code                # Open the VS Code project workspace.
    dev port="8080"     # Run the local Web Development server on the port.
    help                # Display help information.
    install-tooling     # Setup the tooling needed for the project.
    open platform="ios" # Open our Mobile project in Xcode. Platform can be "ios" or "android" (default "ios").
    run platform="ios"  # Run our Mobile App in a Simulator. Platform can be "ios" or "android" (default "ios").
    sync                # Only sync the code to our Mobile Apps and update it.
    test +tests=""      # Run end-to-end tests. Tests can be omitted for all, or a specific test name (default "").

Helpful resources:
 - Capacitor Docs: https://capacitorjs.com/docs/ios
 - Trunk Docs: https://trunkrs.dev
 - Leptos Book: https://book.leptos.dev
 - TailwindCSS Docs: https://tailwindcss.com/docs/installation
```

In short, install the necessary tooling (Capacitor, Trunk, Bun, Rust, dependencies, etc.):

```bash
just install-tooling
```

Build everything:

```bash
just build
```

Or, build things individually.

```bash
# Build the Leptos/WASM/Rust app, and sync the changes with Capacitor
just build-web
# Construct the shared code for all platforms (iOS, macOS, watchOS)
just build-shared
```

Run it in a Simulator:

```bash
just run # or: just run android
```

Or open Xcode

```bash
just open # or: just open android
```

## Setting up Capacitor from scratch

Then dependencies are setup in `appy/package.json`, but otherwise they are:

```bash
bun install @capacitor/core
bun install --dev @capacitor/cli
bun install @capacitor/ios
```

We then initialize Capacitor in our project:

```bash
bunx cap init
```

Then we can setup the iOS project:

```bash
bunx cap add ios
```

After we've built our WASM files into `dist/` we can sync them over to the Xcode project:

```bash
bunx cap sync
```

And finally either open the Xcode project `bunx cap ios open` or run it directly in the Simulator via `bunx cap ios run`.

## Setting up UniFFI from scratch

While everything is handled by the `./mobile/build-ios.sh` script it might be nice to get an overview of what's going on (if you're doing this yourself from scratch, I recommend [this post](https://forgen.tech/en/blog/post/building-an-ios-app-with-rust-using-uniffi)) (and [this for Android](https://forgen.tech/en/blog/post/building-an-android-app-with-rust-using-uniffi)).

> NOTE: We also support Android but you'll need to have downloaded the [NDK](https://developer.android.com/studio/projects/install-ndk), and then you can run `just build-shared android`.

We first build the binary for generating our bindings, and then use that to generate our bindings:

```bash
cargo build
cargo run --bin uniffi-bindgen generate --library ./target/debug/libmobile.a --language swift --out-dir ./bindings
```

We also need to rename the FFI to module.modulemap so that XCFramework will work:

```bash
mv ./bindings/sharedFFI.modulemap ./bindings/module.modulemap
```

Now, let's add support for iOS, the Simulator and macOS via rustup:

```bash
rustup target add aarch64-apple-darwin
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
rustup target add x86_64-apple-ios # iOS simulator, also needed on Arm Macs.
```

and then build the library for all of our targets:

```bash
carbo build --release --target=aarch64-apple-darwin
carbo build --release --target=aarch64-apple-ios
carbo build --release --target=aarch64-apple-ios-sim
carbo build --release --target=x86_64-apple-ios
```

We'll combine `x86_64-apple-ios` and `aarch64-apple-ios-sim` into a single binary later on, but for now we keep them separate.

If we want watchOS we need to handle things a bit differently, since these are Tier 3 targets (i.e. Rustup won't have their stdlib):

```bash
cargo +nightly build -Zbuild-std=std,panic_abort --release --target=aarch64-apple-watchos-sim
cargo +nightly build -Zbuild-std=std,panic_abort --release --target=x86_64-apple-watchos-sim
cargo +nightly build -Zbuild-std=std,panic_abort --release --target=aarch64-apple-watchos
cargo +nightly build -Zbuild-std=std,panic_abort --release --target=armv7k-apple-watchos
cargo +nightly build -Zbuild-std=std,panic_abort --release --target=arm64_32-apple-watchos
```

That's a lot of targets, which represent all the various Watch models, as well as the simulators (we always need both ARM and x86).

`xcodebuild` won't be happy if we just drop them in individually, so we need to create a fat binary:

```bash
# Combine the watchOS simulator libraries into a single file using lipo.
mkdir -p target/watchOS-sim/release
lipo -create target/aarch64-apple-watchos-sim/release/libmobile.a \
target/x86_64-apple-watchos-sim/release/libmobile.a \
        -o target/watchOS-sim/release/libmobile.a
# Confirm the architectures.
lipo -info target/watchOS-sim/release/libmobile.a

# Combine the watchOS libraries into a single file using lipo.
mkdir -p target/watchOS/release
lipo -create target/aarch64-apple-watchos/release/libmobile.a \
        target/arm64_32-apple-watchos/release/libmobile.a \
        target/armv7k-apple-watchos/release/libmobile.a \
        -o target/watchOS/release/libmobile.a
# Confirm the architectures.
lipo -info target/watchOS/release/libmobile.a
```

We can then create our XCFramework:

```bash
xcodebuild -create-xcframework \
    -library ./target/aarch64-apple-ios-sim/release/libmobile.a -headers ./bindings \
    -library ./target/aarch64-apple-ios/release/libmobile.a -headers ./bindings \
    -library ./target/aarch64-apple-darwin/release/libmobile.a -headers ./bindings \
    -library ./target/watchOS-sim/release/libmobile.a -headers ./bindings \
    -library ./target/watchOS/release/libmobile.a -headers ./bindings \
    -output "ios/Shared.xcframework"
```

And finally, we'll combine `x86_64-apple-ios` and `aarch64-apple-ios-sim` into a single binary. If we included both of these in the XCFramework, `xcodebuild` would complain that these are the same, and not generate our XCFramework file. Oddly enough, it will not be able to build the project without both, so we let `xcodebuild` generate the XCFramework first, and then replace the binary with the fat binary:

```bash
# We need to combine the architectures for the iOS Simulator libraries after we've
# constructed the XCFramework, otherwise it will complain about them being the same,
# while also failing because of missing x86_64 if we omit it.
mkdir -p target/iOS-sim/release
lipo -create target/aarch64-apple-ios-sim/release/libmobile.a \
  target/x86_64-apple-ios/release/libmobile.a \
  -o target/iOS-sim/release/libmobile.a
# Confirm the architectures.
lipo -info target/iOS-sim/release/libmobile.a
# Move it into place.
rm ios/Shared.xcframework/ios-arm64-simulator/libmobile.a
cp target/iOS-sim/release/libmobile.a ios/Shared.xcframework/ios-arm64-simulator/libmobile.a
```

Done!

As the final step we drag-n-drop ./ios/Shared.xcframework and ./bindings/shared.swift into the Xcode project whereever you want them. I personally like to create a new group (folder) called `Generated` for them (the `build-ios.sh` script assumes that's the case).
