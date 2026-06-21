#!/bin/bash
set -euo pipefail

C='\033[0;36m'   # cyan
G='\033[0;32m'   # green
D='\033[2m'      # dim
R='\033[0m'      # reset

step() { echo -e "${C}▸${R}  $1"; }
ok()   { echo -e "${G}✓${R}  $1"; }
dim()  { echo -e "${D}$1${R}"; }

# ── optional commit message as first arg ────────────────────────────────────
MSG="${1:-"Deploy: $(date '+%Y-%m-%d %H:%M')"}"

# ── local build check ───────────────────────────────────────────────────────
step "Building Jekyll locally..."
if bundle exec jekyll build --quiet 2>/dev/null; then
  ok "Build OK"
else
  dim "Local build skipped (Jekyll not installed or incompatible Ruby). GitHub Actions will validate the build."
fi

# ── stage & commit ──────────────────────────────────────────────────────────
step "Staging changes..."
git add .

if git diff --staged --quiet; then
  dim "Nothing to commit – already up to date."
  exit 0
fi

git commit -m "$MSG"
ok "Committed: $MSG"

# ── push ─────────────────────────────────────────────────────────────────────
step "Pushing to GitHub..."
git push
ok "Done. GitHub Actions is building → live in ~1 min at fhartmann.com"
