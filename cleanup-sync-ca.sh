#!/usr/bin/env bash
set -euo pipefail

WIN_EXPORT="/mnt/c/ca-export/windows-root-certs"
DST_DIR="/usr/local/share/ca-certificates/windows-roots"

echo "🗑️ Removing all installed Windows-exported CA certs from Ubuntu..."
if [ -d "$DST_DIR" ]; then
  sudo rm -rf "${DST_DIR:?}"/*
  echo "Deleted certs from $DST_DIR"
else
  echo "Directory $DST_DIR does not exist — nothing to remove."
fi

echo "🔄 Rebuilding CA trust store fresh..."
sudo update-ca-certificates --fresh --verbose

echo "✅ Trust store updated."

echo "🧹 Deleting Windows export folder..."
if [ -d "$WIN_EXPORT" ]; then
  rm -rf "${WIN_EXPORT:?}"
  echo "Removed $WIN_EXPORT"
else
  echo "Windows export folder $WIN_EXPORT does not exist."
fi

echo "✔️ Cleanup complete."
