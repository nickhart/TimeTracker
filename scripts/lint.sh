

#!/usr/bin/env bash
set -euo pipefail

# Lint helper script for TimeTracker
# Usage:
#   ./scripts/lint.sh         # check only
#   ./scripts/lint.sh --fix   # attempt auto-fix, then re-check

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIX_MODE=false

if [[ "${1:-}" == "--fix" ]]; then
  FIX_MODE=true
fi

cd "$ROOT_DIR"

if $FIX_MODE; then
  echo "==> Running SwiftFormat (auto-fix)..."
  swiftformat .

  echo "==> Running SwiftLint (auto-fix where possible)..."
  swiftlint --fix
fi

echo "==> Running SwiftLint (check)..."
swiftlint --strict

echo "==> Running SwiftFormat (check)..."
swiftformat --lint .

echo "✅ Lint checks passed."