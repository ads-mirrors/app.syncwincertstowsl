#!/usr/bin/bash
set -euo pipefail
 
SRC="/mnt/c/ca-export/windows-root-certs"
DST="/usr/local/share/ca-certificates/windows-roots"
TMPDIR=$(mktemp -d)
sudo mkdir -p "$DST"
 
echo "📁 Splitting and importing Windows-exported root certs..."
 
for pem in "$SRC"/*.pem; do
  [ -f "$pem" ] || continue
  echo "Processing bundle: $pem"
 
  # Split each BEGIN/END certificate into discrete files in temp dir
  csplit -sz "$pem" '/-----BEGIN CERTIFICATE-----/' '{*}' -f "$TMPDIR/cert-" -b "%03d.pem" >/dev/null
 
  for cert in "$TMPDIR"/cert-*.pem; do
    # Ensure it's a valid certificate
    if grep -q "BEGIN CERTIFICATE" "$cert"; then
      filename=$(basename "$pem" .pem)-$(basename "$cert" .pem)
      dest="$DST/${filename}.crt"
      sudo cp "$cert" "$dest"
      echo "  -> Installed $dest"
    fi
  done
 
  rm -f "$TMPDIR"/cert-*.pem
done
 
rm -rf "$TMPDIR"
 
echo "⚙️ Running update-ca-certificates --fresh --verbose..."
sudo update-ca-certificates --fresh --verbose
 
echo "✅ Done. Certificates prefixed with '+' above are newly added ones."