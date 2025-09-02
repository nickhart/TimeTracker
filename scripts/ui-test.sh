#!/usr/bin/env bash
set -euo pipefail

# UI Test script for TimeTracker UI tests
# Usage:
#   ./scripts/ui-test.sh                              # Run all UI tests (default)
#   ./scripts/ui-test.sh --arch arm64                 # Specify architecture (arm64/x86_64)
#   ./scripts/ui-test.sh --device-name "iPhone 16"   # Specify simulator device
#   ./scripts/ui-test.sh --os 18.5                   # Specify iOS version
#   ./scripts/ui-test.sh --configuration Release     # Run with specific configuration

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Source helper functions
source "$(dirname "${BASH_SOURCE[0]}")/_helpers.sh"

# Check dependencies
check_dependencies

# Default values
DEVICE_NAME="iPhone 16"
OS_VERSION="18.5"
ARCHITECTURE=""
CONFIGURATION="Debug"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --arch)
      ARCHITECTURE="$2"
      if ! validate_arch "$ARCHITECTURE"; then
        exit 1
      fi
      shift 2
      ;;
    --device-name)
      DEVICE_NAME="$2"
      shift 2
      ;;
    --os)
      OS_VERSION="$2"
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
      echo "  --arch <arm64|x86_64>        Specify architecture (default: native)"
      echo "  --device-name <name>         Simulator device name (default: iPhone 16)"
      echo "  --os <version>               iOS version (default: 18.5)"
      echo "  --configuration <config>     Test configuration: Debug|Release (default: Debug)"
      echo "  --help, -h                   Show this help"
      echo ""
      echo "EXAMPLES:"
      echo "  $0                           # Run UI tests with native arch"
      echo "  $0 --arch x86_64             # Run UI tests on x86_64 simulator"
      echo "  $0 --device-name 'iPhone 16' --os 18.2"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
done

# Set default architecture if not specified
if [[ -z "$ARCHITECTURE" ]]; then
  ARCHITECTURE=$(get_native_arch)
fi

# Determine destination
DESTINATION=$(get_simulator_destination "$DEVICE_NAME" "$OS_VERSION" "$ARCHITECTURE")
dest_status=$?
case $dest_status in
  0)
    echo "✓ Found exact simulator match"
    ;;
  1)
    echo "⚠️  Warning: Using fallback destination - may show multiple destination warning"
    ;;
  2)
    echo "❌ Error: No suitable simulators found"
    echo "Use './scripts/simulator.sh list --family iPhone' to see available simulators"
    exit 1
    ;;
esac

echo "==> Running TimeTracker UI tests..."
echo "    Configuration: $CONFIGURATION"
echo "    Architecture: $ARCHITECTURE"
echo "    Device: $DEVICE_NAME (iOS $OS_VERSION)"
echo "    Destination: $DESTINATION"

# Run UI tests specifically
xcodebuild test \
  -scheme TimeTracker \
  -destination "$DESTINATION" \
  -configuration "$CONFIGURATION" \
  -only-testing TimeTrackerUITests \
  ARCHS="$ARCHITECTURE"

echo "✅ UI tests completed successfully"