#!/usr/bin/env bash
set -euo pipefail

# Test script for TimeTracker unit tests
# Usage:
#   ./scripts/test.sh                          # Run all tests (default)
#   ./scripts/test.sh --device "iPhone 15"    # Run on specific device
#   ./scripts/test.sh --configuration Release # Run with specific configuration
#   ./scripts/test.sh --coverage              # Generate code coverage

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Default values
DESTINATION="platform=iOS Simulator,name=iPhone 15"
CONFIGURATION="Debug"
COVERAGE=false

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
    --coverage)
      COVERAGE=true
      shift
      ;;
    --help|-h)
      echo "Test script for TimeTracker unit tests"
      echo ""
      echo "OPTIONS:"
      echo "  --device <name>       Test on specific simulator device (default: iPhone 15)"
      echo "  --configuration       Test configuration: Debug|Release (default: Debug)"
      echo "  --coverage            Enable code coverage collection"
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

echo "==> Running TimeTracker unit tests..."
echo "    Configuration: $CONFIGURATION"
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