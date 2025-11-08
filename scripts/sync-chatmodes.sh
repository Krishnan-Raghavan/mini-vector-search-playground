#!/usr/bin/env bash
set -euo pipefail
# Simple helper to copy chatmode templates from the central templates repo
# into this project's local `.github/chatmodes/` directory (which is git-ignored).
#
# Usage:
#   ./scripts/sync-chatmodes.sh [-r /path/to/templates] [-t template-file] [-a] [--force]
#
# Examples:
#   # copy one template by name
#   ./scripts/sync-chatmodes.sh -t simple-coding-agent.chatmode.md
#
#   # copy all templates
#   ./scripts/sync-chatmodes.sh -a

TEMPLATES_DIR_DEFAULT="$HOME/agent-modes-templates"
DEST_DIR=".github/chatmodes"
TEMPLATE=""
COPY_ALL=false
FORCE=false

usage() {
  cat <<EOF
Usage: $0 [-r templates_dir] [-t template-file] [-a] [--force]

Options:
  -r DIR     Path to local clone of agent-modes-templates (default: $TEMPLATES_DIR_DEFAULT)
  -t FILE    Template filename to copy from templates dir
  -a         Copy all templates from templates dir
  --force    Overwrite existing files in $DEST_DIR
  -h         Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r)
      TEMPLATES_DIR="$2"
      shift 2
      ;;
    -t)
      TEMPLATE="$2"
      shift 2
      ;;
    -a)
      COPY_ALL=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

TEMPLATES_DIR="${TEMPLATES_DIR:-$TEMPLATES_DIR_DEFAULT}"

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Templates directory not found: $TEMPLATES_DIR" >&2
  echo "Please clone the templates repo first: git clone git@github.com:Krishnan-Raghavan/agent-modes-templates.git $TEMPLATES_DIR" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

copy_file() {
  local src="$1"
  local base
  base=$(basename "$src")
  local dst="$DEST_DIR/$base"
  if [[ -e "$dst" && "$FORCE" != true ]]; then
    echo "Skipping $base — destination exists (use --force to overwrite)"
    return
  fi
  cp "$src" "$dst"
  echo "Copied $base -> $dst"
}

if [[ "$COPY_ALL" == true ]]; then
  shopt -s nullglob
  found=false
  for f in "$TEMPLATES_DIR"/*.chatmode.md; do
    found=true
    copy_file "$f"
  done
  if [[ "$found" == false ]]; then
    echo "No templates found in $TEMPLATES_DIR"
    exit 1
  fi
  exit 0
fi

if [[ -n "$TEMPLATE" ]]; then
  src="$TEMPLATES_DIR/$TEMPLATE"
  if [[ ! -f "$src" ]]; then
    echo "Template not found: $src" >&2
    exit 1
  fi
  copy_file "$src"
  exit 0
fi

echo "Nothing to do. Use -t <template-file> or -a to copy all."
usage
exit 2
