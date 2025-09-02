#!/usr/bin/env bash
set -euo pipefail

# Build script for TimeTracker
# Usage:
#   ./scripts/build.sh                    # Build for simulator (default)
#   ./scripts/build.sh --device           # Build for device
#   ./scripts/build.sh --configuration Debug|Release
#   ./scripts/build.sh --clean            # Clean before build

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Default values
DESTINATION="platform=iOS Simulator,name=iPhone 15"
CONFIGURATION="Debug"
CLEAN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --device)
      DESTINATION="generic/platform=iOS"
      shift
      ;;
    --configuration)
      CONFIGURATION="$2"
      shift 2
      ;;
    --clean)
      CLEAN=true
      shift
      ;;
    --help|-h)
      echo "Build script for TimeTracker"
      echo ""
      echo "OPTIONS:"
      echo "  --device          Build for device (default: simulator)"
      echo "  --configuration   Build configuration: Debug|Release (default: Debug)"
      echo "  --clean           Clean before build"
      echo "  --help, -h        Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
done

if $CLEAN; then
  echo "==> Cleaning build..."
  xcodebuild -scheme TimeTracker clean
fi

echo "==> Building TimeTracker..."
echo "    Configuration: $CONFIGURATION"
echo "    Destination: $DESTINATION"

xcodebuild \
  -scheme TimeTracker \
  -destination "$DESTINATION" \
  -configuration "$CONFIGURATION" \
  build

echo " Build completed successfully"