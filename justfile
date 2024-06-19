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
  curl -fsSL https://bun.sh/install | bash
  # Install Rust and Cargo.
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  # Install cargo-binstall for installing binaries from crates.io.
  command -v cargo-binstall >/dev/null 2>&1 || curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
  # Install trunk for building Rust WebAssembly.
  command -v trunk >/dev/null 2>&1 || cargo binstall --no-confirm trunk
  # Install leptosfmt for formatting Leptos View macros.
  command -v leptosfmt >/dev/null 2>&1 || cargo binstall --no-confirm leptosfmt
  # Install cargo-edit for managing dependencies.
  command -v cargo-add >/dev/null 2>&1 || cargo binstall --no-confirm cargo-edit
  # Install dependencies.
  cd appy && bun install
  # Install test dependencies.
  cd appy/end2end && bun install

# Open the VS Code project workspace.
code:
  open project.code-workspace

# Open our Mobile project in XCode.
open:
  cd appy && bunx cap open ios

# Run the local Web Development server.
dev:
  cd appy && trunk serve

# Run our Mobile App in a Simulator.
run:
  cd appy && bunx cap run ios

# Build our Web App and sync the code to our Mobile Apps.
build-web:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd appy
  # Build the WASM files.
  trunk build --release
  # Sync the files to our Mobile projects.
  bunx cap sync

# Generate the Swift bindings for our Shared code.
build-shared args="":
  #!/usr/bin/env bash
  set -euxo pipefail
  cd mobile
  # Generate library for all our compile targets.
  ./build-ios.sh {{ args }}

# Sync the code to our Mobile Apps and update it.
sync:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd appy
  # Sync the files to our Mobile projects.
  bunx cap sync
