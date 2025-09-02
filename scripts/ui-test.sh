#!/usr/bin/env bash
set -euo pipefail

# UI Test script for TimeTracker UI tests
# Usage:
#   ./scripts/ui-test.sh                          # Run all UI tests (default)
#   ./scripts/ui-test.sh --device "iPhone 15"    # Run on specific device
#   ./scripts/ui-test.sh --configuration Release # Run with specific configuration

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Default values
DESTINATION="platform=iOS Simulator,name=iPhone 15"
CONFIGURATION="Debug"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --device)
      DESTINATION="platform=iOS Simulator,name=$2"
      shift 2
      ;;
    --configuration)
      CONFIGURATION="$2"
      shift 2
      ;;
    --help|-h)
      echo "UI Test script for TimeTracker UI tests"
      echo ""
      echo "OPTIONS:"
      echo "  --device <name>       Test on specific simulator device (default: iPhone 15)"
      echo "  --configuration       Test configuration: Debug|Release (default: Debug)"
      echo "  --help, -h            Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
done

echo "==> Running TimeTracker UI tests..."
echo "    Configuration: $CONFIGURATION"
echo "    Destination: $DESTINATION"

# Run UI tests specifically
xcodebuild test \
  -scheme TimeTracker \
  -destination "$DESTINATION" \
  -configuration "$CONFIGURATION" \
  -only-testing TimeTrackerUITests

echo " UI tests completed successfully"