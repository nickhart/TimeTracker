

#!/usr/bin/env bash
set -euo pipefail

# Format helper script for TimeTracker
# Usage:
#   ./scripts/format.sh         # check only
#   ./scripts/format.sh --fix   # auto-fix

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIX_MODE=false

if [[ "${1:-}" == "--fix" ]]; then
  FIX_MODE=true
fi

cd "$ROOT_DIR"

if $FIX_MODE; then
  echo "==> Running SwiftFormat (auto-fix)..."
  swiftformat .
else
  echo "==> Checking SwiftFormat (lint)..."
  swiftformat --lint .
fi

echo "✅ Format checks passed."