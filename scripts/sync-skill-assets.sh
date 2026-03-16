#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/references"
TARGET_DIR="$ROOT_DIR/.claude/skills/debug-tx/references"

mkdir -p "$TARGET_DIR"

cp "$SOURCE_DIR/common-errors.md" "$TARGET_DIR/common-errors.md"
cp "$SOURCE_DIR/rpc-playbook.md" "$TARGET_DIR/rpc-playbook.md"
cp "$SOURCE_DIR/report-formatting.md" "$TARGET_DIR/report-formatting.md"
cp "$SOURCE_DIR/setup-and-install.md" "$TARGET_DIR/setup-and-install.md"
cp "$SOURCE_DIR/tools-guide.md" "$TARGET_DIR/tools-guide.md"

printf 'Synced references to %s\n' "$TARGET_DIR"