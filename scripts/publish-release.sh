#!/usr/bin/env bash
# Publish a FernOS release: upload the ISO as ONE file to the Internet Archive
# (archive.org item "fernos"; GitHub releases cap files at 2 GiB), point the
# download page and README at it, and push to GitHub (Pages redeploys itself).
#
#   ./scripts/publish-release.sh 0.3 [path/to.iso]
#
# Needs: ia (python-internetarchive) set up once with `ia configure`, and gh/git
# push access to the GitHub repo.
set -euo pipefail

version="${1:?usage: publish-release.sh VERSION [ISO]   e.g. 0.3}"
version="${version#v}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
iso="${2:-$(ls -t "${repo_root}"/build/out/*.iso | head -n1)}"
item="fernos"
name="fernos-${version}-x86_64.iso"
url="https://archive.org/download/${item}/${name}"

command -v ia >/dev/null || { echo "error: install python-internetarchive and run 'ia configure'" >&2; exit 1; }
ia configure --whoami >/dev/null 2>&1 || { echo "error: run 'ia configure' first" >&2; exit 1; }

echo ":: SHA-256 of $(basename "${iso}")"
sha="$(sha256sum "${iso}" | cut -d' ' -f1)"
echo "   ${sha}"

echo ":: Uploading ${name} to archive.org/details/${item}"
ia upload "${item}" "${iso}" --remote-name="${name}" --checksum --retries 10 \
    --metadata="mediatype:software" --metadata="collection:open_source_software" \
    --metadata="title:FernOS"

echo ":: Pointing the download page and README at ${name}"
cd "${repo_root}"
sed -i -E \
    -e "s|https://archive.org/download/${item}/fernos-[0-9.]+-x86_64\.iso|${url}|g" \
    -e "s|fernos-[0-9.]+-x86_64\.iso|${name}|g" \
    -e "s|[0-9a-f]{64}|${sha}|g" \
    -e "s|FernOS [0-9.]+ \(ISO|FernOS ${version} (ISO|g" \
    -e "s|Version [0-9.]+ ·|Version ${version} ·|g" \
    site/index.html README.md
git add site/index.html README.md
git commit -m "Release FernOS ${version}" >/dev/null || true
git push origin HEAD:main

echo ":: Done"
echo "   Download: ${url}"
echo "   Page:     https://preston123451.github.io/FernOS/ (updates in a minute)"
