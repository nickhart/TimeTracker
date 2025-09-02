#!/usr/bin/env bash
set -euo pipefail

# Test script for TimeTracker unit tests
# Usage:
#   ./scripts/test.sh                              # Run all tests (default)
#   ./scripts/test.sh --arch arm64                 # Specify architecture (arm64/x86_64)
#   ./scripts/test.sh --device-name "iPhone 16"   # Specify simulator device
#   ./scripts/test.sh --os 18.5                   # Specify iOS version
#   ./scripts/test.sh --configuration Release     # Run with specific configuration
#   ./scripts/test.sh --coverage                  # Generate code coverage

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
COVERAGE=false

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
    --coverage)
      COVERAGE=true
      shift
      ;;
    --help|-h)
      echo "Test script for TimeTracker unit tests"
      echo ""
      echo "OPTIONS:"
      echo "  --arch <arm64|x86_64>        Specify architecture (default: native)"
      echo "  --device-name <name>         Simulator device name (default: iPhone 16)"
      echo "  --os <version>               iOS version (default: 18.5)"
      echo "  --configuration <config>     Test configuration: Debug|Release (default: Debug)"
      echo "  --coverage                   Enable code coverage collection"
      echo "  --help, -h                   Show this help"
      echo ""
      echo "EXAMPLES:"
      echo "  $0                           # Run tests with native arch"
      echo "  $0 --arch x86_64             # Run tests on x86_64 simulator"
      echo "  $0 --coverage                # Run tests with coverage"
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

echo "==> Running TimeTracker unit tests..."
echo "    Configuration: $CONFIGURATION"
echo "    Architecture: $ARCHITECTURE"
echo "    Device: $DEVICE_NAME (iOS $OS_VERSION)"
echo "    Destination: $DESTINATION"
if $COVERAGE; then
  echo "    Code Coverage: Enabled"
fi

# Build the test command
XCODEBUILD_CMD=(
  xcodebuild test
  -scheme TimeTracker
  -destination "$DESTINATION"
  -configuration "$CONFIGURATION"
  ARCHS="$ARCHITECTURE"
)

if $COVERAGE; then
  XCODEBUILD_CMD+=(
    -enableCodeCoverage YES
  )
fi

# Run the tests
"${XCODEBUILD_CMD[@]}"

if $COVERAGE; then
  echo ""
  echo "==> Exporting code coverage report..."

  # Get the latest test results
  DERIVED_DATA_PATH=$(xcodebuild -showBuildSettings -scheme TimeTracker | grep -m 1 "DERIVED_DATA_DIR" | grep -oE "\/.*")
  TEST_RESULTS=$(find "$DERIVED_DATA_PATH" -name "*.xcresult" | head -n 1)

  if [[ -n "$TEST_RESULTS" ]]; then
    # Export coverage report
    xcrun xccov view "$TEST_RESULTS" --report --only-targets
    echo ""
    echo "Full coverage report available at: $TEST_RESULTS"
  else
    echo "Warning: Could not find test results for coverage report"
  fi
fi

echo " Unit tests completed successfully"