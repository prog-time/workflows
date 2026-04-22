#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f "Cargo.toml" ]]; then
  echo "::error::No Cargo.toml found"
  exit 1
fi

echo "ℹ️ Running Clippy..."
cargo clippy --all-targets --all-features -- -D warnings \
  && echo "✅ Clippy passed" \
  || { echo "❌ Clippy found issues"; exit 1; }
