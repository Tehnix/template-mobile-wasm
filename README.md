# Rust on Mobile via Capacitor

After exploring multiple solutions to working with Rust on Mobile, this seems so far to be the best option:

- Compile to WASM via Rust and a framework such as Leptos
- Package WASM using [Capacitor](https://capacitorjs.com/docs)
- Support native Widgets using the generated XCode project and Swift
- Use Rust code from Swift via [UniFFI](https://github.com/mozilla/uniffi-rs)


In short, construct the shared code for all platforms (iOS, macOS, watchOS):

```bash
cd shared && ./build-ios.sh
```

Change the Leptos/WASM/Rust app and build the artifacts:

```bash
cd appy && trunk build
```

Sync the changes over with Capacitor and run it in a Simulator:

```bash
cd appy && bunx cap sync && bunx cap run ios
```

## Setting up Capacitor

Then dependencies are setup in package.json, but otherwise they are:

```bash
bun install @capacitor/core
bun install --dev @capacitor/cli
bun install @capacitor/ios
```

We first initialize Capacitor in our project:

```bash
bunx cap init
```

Then we can setup the iOS project:

```bash
bunx cap add ios
```

After we've built our WASM files into `dist/` we can sync them over to the XCode project:

```bash
bunx cap sync
```

And finally either open the XCode project `bunx cap ios open` or run it directly in the Simulator via `bunx cap ios run`.

## Setting up UniFFI

While everything is handled by the `./build-ios.sh` script it might be nice to get an overview of what's going on (if you're doing this yourself from scratch, I recommend [this post](https://forgen.tech/en/blog/post/building-an-ios-app-with-rust-using-uniffi)).

We first build the binary for generating our bindings, and then use that to generate our bindings:

```bash
cargo build
cargo run --bin uniffi-bindgen generate --library ./target/debug/libshared.dylib --language swift --out-dir ./bindings
```

We also need to rename the FFI to module.modulemap so that XCFramework will work:

```bash
mv ./bindings/sharedFFI.modulemap ./bindings/module.modulemap
```

Now, let's add support for iOS and the Simulator:

```bash
rustup target add aarch64-apple-ios # for iOS
rustup target add aarch64-apple-ios-sim # for M1 Mac simulators
```

If you're on Intel instead use:

```bash
rustup target add x86_64-apple-ios # for Intel Mac simulators
```

and then build for the iOS target:

```bash
cargo build --release --target=aarch64-apple-ios-sim
cargo build --release --target=aarch64-apple-ios
```

We can then create our XCFramework:

```bash
xcodebuild -create-xcframework \
        -library ./target/aarch64-apple-ios-sim/release/libshared.a -headers ./bindings \
        -library ./target/aarch64-apple-ios/release/libshared.a -headers ./bindings \
        -output "ios/Shared.xcframework"
```

Done! 

As the final step we drag-n-drop ./ios/Shared.xcframework and ./bindings/shared.swift into the XCode project.
