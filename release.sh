#!/bin/bash
# release.sh — Claude Code Pet version release helper
# Usage: ./release.sh <version>   e.g. ./release.sh 1.1.0
set -euo pipefail

REPO="wassupss/homebrew-claude-code-pet"
FORMULA="Formula/claude-code-pet.rb"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>  (e.g. $0 1.1.0)"
  exit 1
fi

VERSION="$1"
TAG="v${VERSION}"
TARBALL_URL="https://github.com/${REPO}/archive/refs/tags/${TAG}.tar.gz"

echo "==> Releasing ${TAG}..."

# 1. Sync pet.py from dev location (if running from the repo root)
if [[ -f "pet.py" ]]; then
  echo "==> Syncing pet.py → libexec/pet.py"
  cp pet.py libexec/pet.py
fi

# 2. Placeholder formula update (version + URL, SHA256 filled after tag)
sed -i '' \
  -e "s|url \".*\"|url \"${TARBALL_URL}\"|" \
  -e "s|version \".*\"|version \"${VERSION}\"|" \
  -e "s|sha256 \".*\"|sha256 \"PLACEHOLDER\"|" \
  "${FORMULA}"

# 3. Commit all changes
git add -A
git commit -m "chore: prepare release ${TAG}"

# 4. Tag
git tag "${TAG}"

# 5. Push branch + tag
git push origin HEAD
git push origin "${TAG}"

echo "==> Waiting 5s for GitHub to process the tarball..."
sleep 5

# 6. Compute SHA256 from the uploaded tarball
echo "==> Computing SHA256..."
SHA256=$(curl -sL "${TARBALL_URL}" | shasum -a 256 | awk '{print $1}')
echo "    SHA256: ${SHA256}"

# 7. Update formula with real SHA256
sed -i '' -e "s|sha256 \"PLACEHOLDER\"|sha256 \"${SHA256}\"|" "${FORMULA}"

# 8. Commit formula fix
git add "${FORMULA}"
git commit -m "chore: update sha256 for ${TAG}"
git push origin HEAD

echo ""
echo "✓ Release ${TAG} complete!"
echo ""
echo "Install with:"
echo "  brew tap ${REPO%/*}/claude-code-pet"
echo "  brew install claude-code-pet"
echo ""
echo "Upgrade existing installs with:"
echo "  brew upgrade claude-code-pet"
