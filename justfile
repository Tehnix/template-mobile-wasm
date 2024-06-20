# Display help information.
help:
  @ just --list
  @ echo "\nHelpful resources:"
  @ echo " - Capacitor Docs: https://capacitorjs.com/docs/ios"
  @ echo " - Trunk Docs: https://trunkrs.dev"
  @ echo " - Leptos Book: https://book.leptos.dev"
  @ echo " - TailwindCSS Docs: https://tailwindcss.com/docs/installation"

# Setup the tooling needed for the project.
install-tooling:
  # Install bun for managing JS dependencies.
  command -v bun >/dev/null 2>&1 || curl -fsSL https://bun.sh/install | bash
  # Install Rust and Cargo.
  command -v rustup >/dev/null 2>&1 || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  # Install cargo-binstall for installing binaries from crates.io.
  command -v cargo-binstall >/dev/null 2>&1 || curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
  # Install trunk for building Rust WebAssembly.
  command -v trunk >/dev/null 2>&1 || cargo binstall --no-confirm trunk
  # Install leptosfmt for formatting Leptos View macros.
  command -v leptosfmt >/dev/null 2>&1 || cargo binstall --no-confirm leptosfmt
  # Install cargo-edit for managing dependencies.
  command -v cargo-add >/dev/null 2>&1 || cargo binstall --no-confirm cargo-edit
  # Install cargo-watch for rerunning scripts on changes.
  command -v cargo-watch >/dev/null 2>&1 || cargo binstall --no-confirm cargo-watch
  # Install dependencies.
  cd appy && bun install
  # Install test dependencies.
  cd appy/end2end && bun install
  @ echo "\n\nIf you don't have it already, you need to install Xcode and Android Studio for the Mobile Apps."
  @ echo "  - Xcode: https://developer.apple.com/xcode/"
  @ echo "  - Android Studio: https://developer.android.com/studio"

# Open the VS Code project workspace.
code:
  open project.code-workspace

# Open our Mobile project in Xcode. Platform can be "ios" or "android" (default "ios").
open platform="ios":
  cd appy && bunx cap open {{ platform }}

# Run the local Web Development server on the port.
dev port="8080":
  cd appy && trunk serve --port {{ port }}

# Run our Mobile App in a Simulator. Platform can be "ios" or "android" (default "ios").
run platform="ios":
  cd appy && bunx cap run {{ platform }}

# Run end-to-end tests. Tests can be omitted for all, or a specific test name (default "").
test +tests="":
  cd appy/end2end && bun run e2e {{ tests }}

# Build our Web App, Shared code, and sync the changes to our Mobile Apps.
build:
  @ just build-web
  @ just build-shared

# Only build our Web App and sync the code to our Mobile Apps.
build-web:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd appy
  # Build the WASM files.
  trunk build --release
  # Sync the files to our Mobile projects.
  bunx cap sync

# Only generate the Swift bindings for our Shared code. Args can be passed to the script e.g. "--force" (default "").
build-shared args="":
  #!/usr/bin/env bash
  set -euxo pipefail
  cd mobile
  # Generate library for all our compile targets.
  ./build-ios.sh {{ args }}

# Only sync the code to our Mobile Apps and update it.
sync:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd appy
  # Sync the files to our Mobile projects.
  bunx cap sync
