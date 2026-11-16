#!/usr/bin/env bash
# Build the FernOS ISO.
#
#   ./scripts/build-iso.sh            # build packages, then the ISO (asks for sudo once)
#
# Run as your normal user. Only mkarchiso itself runs as root, via sudo.
# Output: build/out/fernos-<date>-x86_64.iso
#
# Independence from the build host: packages come only from the Arch repositories
# listed in iso/profile/pacman.conf plus the local [fernos] repo, using a dedicated
# package cache (build/cache) so nothing from the host's own cache (e.g. CachyOS
# rebuilds) can end up in the image.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build="${repo_root}/build"
profile_src="${repo_root}/iso/profile"
profile_gen="${build}/profile"
mirrorlist="${FERNOS_MIRRORLIST:-/etc/pacman.d/mirrorlist}"

if [[ ${EUID} -eq 0 ]]; then
    echo "error: run as your normal user; the script calls sudo for mkarchiso only." >&2
    exit 1
fi
for cmd in mkarchiso makepkg repo-add rsync sudo; do
    command -v "${cmd}" >/dev/null || { echo "error: '${cmd}' not found (install archiso, base-devel, rsync)" >&2; exit 1; }
done
grep -q '^Server' "${mirrorlist}" || { echo "error: no Server lines in ${mirrorlist}" >&2; exit 1; }

SOURCE_DATE_EPOCH="$(git -C "${repo_root}" log -1 --pretty=%ct 2>/dev/null || date +%s)"
export SOURCE_DATE_EPOCH

# 1. FernOS packages -> build/repo
"${repo_root}/scripts/build-packages.sh"

# 2. Generated profile: the tracked profile plus build-time-only repo/cache settings.
rm -rf -- "${profile_gen}"
rsync -a -- "${profile_src}/" "${profile_gen}/"
mkdir -p -- "${build}/cache/pkg"
sed -i \
    -e "s|^Include = /etc/pacman.d/mirrorlist|Include = ${mirrorlist}|" \
    -e "/^\[options\]/a CacheDir = ${build}/cache/pkg/" \
    "${profile_gen}/pacman.conf"
cat >>"${profile_gen}/pacman.conf" <<CONF

# Local FernOS packages (build/repo), added by scripts/build-iso.sh at build time only.
[fernos]
SigLevel = Optional TrustAll
Server = file://${build}/repo
CONF

# 3. Build. A stale work dir makes mkarchiso skip steps, so always start clean.
echo ":: Building ISO (sudo is needed for mkarchiso)"
sudo rm -rf -- "${build}/work"
mkdir -p -- "${build}/out"
set +e
sudo --preserve-env=SOURCE_DATE_EPOCH \
    mkarchiso -v -r -w "${build}/work" -o "${build}/out" "${profile_gen}" \
    2>&1 | tee "${build}/build-iso.log"
status=${PIPESTATUS[0]}
set -e
sudo chown -R "$(id -u):$(id -g)" -- "${build}/out" "${build}/cache" 2>/dev/null || true
if (( status != 0 )); then
    echo "error: mkarchiso failed (exit ${status}); see build/build-iso.log" >&2
    exit "${status}"
fi
ls -lh -- "${build}"/out/*.iso
