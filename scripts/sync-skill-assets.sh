#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/references"
PACKAGE_DIR="$ROOT_DIR/debug-tx"
PACKAGE_REFERENCES_DIR="$PACKAGE_DIR/references"
LOCAL_SKILL_DIR="$ROOT_DIR/.claude/skills/debug-tx"
LOCAL_REFERENCES_DIR="$LOCAL_SKILL_DIR/references"

mkdir -p "$PACKAGE_REFERENCES_DIR" "$LOCAL_REFERENCES_DIR"

for target_dir in "$PACKAGE_REFERENCES_DIR" "$LOCAL_REFERENCES_DIR"; do
	cp "$SOURCE_DIR/common-errors.md" "$target_dir/common-errors.md"
	cp "$SOURCE_DIR/rpc-playbook.md" "$target_dir/rpc-playbook.md"
	cp "$SOURCE_DIR/report-formatting.md" "$target_dir/report-formatting.md"
	cp "$SOURCE_DIR/setup-and-install.md" "$target_dir/setup-and-install.md"
	cp "$SOURCE_DIR/tools-guide.md" "$target_dir/tools-guide.md"
done

cp "$ROOT_DIR/VERSION" "$PACKAGE_DIR/VERSION"
cp "$ROOT_DIR/VERSION" "$LOCAL_SKILL_DIR/VERSION"
cp "$PACKAGE_DIR/SKILL.md" "$LOCAL_SKILL_DIR/SKILL.md"

printf 'Synced installable skill package to %s\n' "$PACKAGE_DIR"
printf 'Synced local Claude mirror to %s\n' "$LOCAL_SKILL_DIR"