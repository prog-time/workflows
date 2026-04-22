#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f "Cargo.toml" ]]; then
  echo "::error::No Cargo.toml found"
  exit 1
fi

echo "ℹ️ Running cargo test..."
cargo test --all-features --verbose \
  && echo "✅ cargo tests passed" \
  || { echo "❌ cargo tests failed"; exit 1; }
