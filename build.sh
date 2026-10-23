#!/usr/bin/env bash
# Packs dist/<id>-<version>.vplugin: a zip with viewerly-plugin.toml at its root. Nothing to
# compile; the plugin is an agent definition.
set -euo pipefail
root="$(cd "$(dirname "$0")" && pwd)"
cd "$root"

field() { sed -n "s/^$1 = \"\(.*\)\"$/\1/p" viewerly-plugin.toml | head -n 1; }
id="$(field id)"
version="$(field version)"
mkdir -p dist
file="dist/$id-$version.vplugin"
rm -f "$file"
zip -qXD "$file" viewerly-plugin.toml agents/aider.toml README.md LICENSE
echo "$root/$file ($(wc -c < "$file" | tr -d ' ') bytes)"
