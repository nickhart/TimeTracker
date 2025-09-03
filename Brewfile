

# Brewfile for TimeTracker
# Usage:
#   brew bundle install --file=./Brewfile
#   brew bundle lock     --file=./Brewfile   # create/update Brewfile.lock.json
#   brew bundle cleanup  --file=./Brewfile   # show what would be removed

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
# All formulas are available in homebrew-core (no custom taps needed).
