

# Brewfile for TimeTracker
# Usage:
#   brew bundle install --file=./Brewfile
#   brew bundle lock     --file=./Brewfile   # create/update Brewfile.lock.json
#   brew bundle cleanup  --file=./Brewfile   # show what would be removed

# --- Taps --------------------------------------------------------------
# Homebrew Bundle is built-in, but this ensures availability of `brew bundle`.
tap "homebrew/bundle"
# XcodeGen is also in homebrew-core, but keeping the official tap ensures latest.
tap "yonaskolb/XcodeGen"

# --- Core Dev Utilities -----------------------------------------------
brew "git"
brew "make"
brew "jq"
# GitHub CLI for CI management
brew "gh"

# --- iOS / Swift Tooling ----------------------------------------------
# Project generator from project.yml
brew "xcodegen"
# Linting
brew "swiftlint"
# Formatting
brew "swiftformat"
# Optional: pretty Xcode build logs in CI / local
brew "xcbeautify"

# --- Notes -------------------------------------------------------------
# Homebrew doesn’t pin exact versions in Brewfiles; use `brew bundle lock` to
# generate Brewfile.lock.json for reproducible installs in CI.
# If you prefer to avoid the extra tap for XcodeGen, remove the tap above—
# the `xcodegen` formula exists in homebrew-core as well.
