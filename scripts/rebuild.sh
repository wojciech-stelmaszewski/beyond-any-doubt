#!/usr/bin/env bash
#
# Clean rebuild. Vite caches the modules that astro.config.mjs imports, so edits
# to the figure code are not picked up unless that cache is cleared first.
#
set -euo pipefail

cd "$(dirname "$0")/.."
rm -rf dist .astro node_modules/.vite node_modules/.astro
ASTRO_TELEMETRY_DISABLED=1 npx astro build
