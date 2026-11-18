#!/usr/bin/env bash
# Publish FernOS on GitHub: push the repo, upload the ISO as a release, turn on the
# download page (site/ via GitHub Pages).
#
#   ./scripts/publish-release.sh v0.2 [path/to.iso]
#
# Needs: gh (logged in with `gh auth login`). GitHub release files are limited to
# 2 GiB each, so the ISO is split into fernos-x86_64.iso.part1/.part2 with stable
# names; the page links to releases/latest/download/<name>.
set -euo pipefail

tag="${1:?usage: publish-release.sh TAG [ISO]}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
iso="${2:-$(ls -t "${repo_root}"/build/out/*.iso | head -n1)}"
stage="${repo_root}/build/release"

gh auth status >/dev/null 2>&1 || { echo "error: run 'gh auth login' first" >&2; exit 1; }
owner="$(gh api user -q .login)"
repo="${owner}/FernOS"

# 1. Repository (public) + push
if ! gh repo view "${repo}" >/dev/null 2>&1; then
    gh repo create "${repo}" --public \
        --description "FernOS: a calm KDE Plasma desktop on Arch + CachyOS for coding, working and gaming" \
        --homepage "https://${owner}.github.io/FernOS/"
fi
git -C "${repo_root}" remote get-url origin >/dev/null 2>&1 \
    || git -C "${repo_root}" remote add origin "https://github.com/${repo}.git"
git -C "${repo_root}" push -u origin HEAD:main

# 2. Release assets
rm -rf -- "${stage}"; mkdir -p -- "${stage}"
echo ":: Splitting $(basename "${iso}")"
split -b 1900M -d -a 1 --numeric-suffixes=1 "${iso}" "${stage}/fernos-x86_64.iso.part"
(cd "$(dirname "${iso}")" && sha256sum "$(basename "${iso}")") \
    | sed "s|  .*|  fernos-x86_64.iso|" >"${stage}/fernos-x86_64.iso.sha256"
[[ ! -e "${stage}/fernos-x86_64.iso.part3" ]] || { echo "error: ISO needs 3+ parts; update site/index.html links" >&2; exit 1; }
ls -la "${stage}"

notes="FernOS ${tag#v}. Download both parts, join them, then write the ISO to a USB stick.

Linux/macOS: \`cat fernos-x86_64.iso.part1 fernos-x86_64.iso.part2 > fernos-x86_64.iso\`
Windows: \`copy /b fernos-x86_64.iso.part1 + fernos-x86_64.iso.part2 fernos-x86_64.iso\`

Full instructions: https://${owner}.github.io/FernOS/"
gh release create "${tag}" --repo "${repo}" --title "FernOS ${tag#v}" --notes "${notes}" \
    "${stage}"/fernos-x86_64.iso.part* "${stage}/fernos-x86_64.iso.sha256"

# 3. Download page (GitHub Pages from the Actions workflow)
gh api -X POST "repos/${repo}/pages" -f build_type=workflow >/dev/null 2>&1 \
    || gh api -X PUT "repos/${repo}/pages" -f build_type=workflow >/dev/null
gh workflow run pages.yml --repo "${repo}" >/dev/null 2>&1 || true

rm -rf -- "${stage}"
echo ":: Done"
echo "   Page:    https://${owner}.github.io/FernOS/  (live in a minute or two)"
echo "   Release: https://github.com/${repo}/releases/tag/${tag}"
