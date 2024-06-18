# Generate Swift Bindings


We first build the binary for generating our bindings, and then use that to generate our bindings:

```bash
cargo build
cargo run --bin uniffi-bindgen generate --library ./target/debug/libshared.dylib --language swift --out-dir ./bindings
# Rename the FFI to module.modulemap so that XCFramework will work.
mv ./bindings/sharedFFI.modulemap ./bindings/module.modulemap
```

Now, let's add support for iOS:

```bash
rustup target add aarch64-apple-ios # for iOS
rustup target add x86_64-apple-ios # for Intel Mac simulators
rustup target add aarch64-apple-ios-sim # for M1 Mac simulators
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
