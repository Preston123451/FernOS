#!/usr/bin/env bash
# Build FernOS's own packages (packages/*) into a local pacman repository.
# Runs as a normal user; makepkg refuses to run as root.
#
# Output: build/repo/fernos.db.tar.zst + packages, consumed by scripts/build-iso.sh.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_dir="${repo_root}/build/repo"
pkg_build="${repo_root}/build/pkgbuild"

if [[ ${EUID} -eq 0 ]]; then
    echo "error: run this as a normal user (makepkg refuses root)." >&2
    exit 1
fi

# Reproducibility: timestamps inside packages come from the last commit.
SOURCE_DATE_EPOCH="$(git -C "${repo_root}" log -1 --pretty=%ct 2>/dev/null || date +%s)"
export SOURCE_DATE_EPOCH

rm -rf -- "${repo_dir}" "${pkg_build}"
mkdir -p -- "${repo_dir}" "${pkg_build}"

for pkgdir in "${repo_root}"/packages/*/; do
    [[ -f "${pkgdir}/PKGBUILD" ]] || continue
    echo ":: Building $(basename "${pkgdir}")"
    (
        cd "${pkgdir}"
        BUILDDIR="${pkg_build}" PKGDEST="${repo_dir}" SRCDEST="${pkg_build}/src" \
            makepkg --clean --cleanbuild --force --nodeps --noconfirm
    )
done

shopt -s nullglob
pkgs=("${repo_dir}"/*.pkg.tar.*)
(( ${#pkgs[@]} )) || { echo "error: no packages were built" >&2; exit 1; }
repo-add --new --remove "${repo_dir}/fernos.db.tar.zst" "${pkgs[@]}"
echo ":: Local repository ready: ${repo_dir}"
