#!/usr/bin/env bash
# Static checks that need no root and no VM. Run before every ISO build.
#   1. Shell/JSON syntax of project files
#   2. Every package in packages.x86_64 (and all dependencies) resolves against
#      CachyOS [cachyos] + Arch [core]/[extra]/[multilib] + the local [fernos] repo
#   3. Every systemd unit enabled in the live image is shipped by a listed package
#   4. FernOS packages don't overwrite files owned by Arch packages
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
profile="${repo_root}/iso/profile"
tmp="$(mktemp -d)"; trap 'rm -rf -- "${tmp}"' EXIT
fail=0
ok()  { printf '  \e[32mok\e[0m   %s\n' "$*"; }
bad() { printf '  \e[31mFAIL\e[0m %s\n' "$*"; fail=1; }

echo ":: Syntax"
for f in "${repo_root}"/scripts/*.sh "${repo_root}"/branding/tools/*.sh "${profile}/profiledef.sh" \
         "${profile}"/airootfs/usr/local/bin/*; do
    head -n1 "$f" | grep -q 'sh' || continue
    bash -n "$f" 2>"${tmp}/err" && ok "${f#"${repo_root}/"}" || bad "${f#"${repo_root}/"}: $(cat "${tmp}/err")"
done
while IFS= read -r -d '' f; do
    python3 -m json.tool "$f" >/dev/null 2>&1 && ok "${f#"${repo_root}/"}" || bad "invalid JSON: ${f#"${repo_root}/"}"
done < <(find "${repo_root}/desktop" -name '*.json' -print0)

echo ":: Package resolution (CachyOS + Arch repos + local [fernos])"
[[ -f "${repo_root}/build/repo/fernos.db.tar.zst" ]] || "${repo_root}/scripts/build-packages.sh" >/dev/null
sed "s|^Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|" "${profile}/pacman.conf" >"${tmp}/pacman.conf"
printf '\n[fernos]\nSigLevel = Optional TrustAll\nServer = file://%s\n' "${repo_root}/build/repo" >>"${tmp}/pacman.conf"
mkdir -p "${tmp}/db"
pac() { pacman --config "${tmp}/pacman.conf" --dbpath "${tmp}/db" --logfile /dev/null "$@"; }
fakeroot -- pacman --config "${tmp}/pacman.conf" --dbpath "${tmp}/db" --logfile /dev/null -Sy >/dev/null 2>&1 \
    && fakeroot -- pacman --config "${tmp}/pacman.conf" --dbpath "${tmp}/db" --logfile /dev/null -Fy >/dev/null 2>&1 \
    || { bad "could not sync package databases (offline?)"; exit 1; }
mapfile -t pkgs < <(sed 's/#.*//' "${profile}/packages.x86_64" | awk 'NF')
if pac -Sp --print-format '%n' "${pkgs[@]}" >"${tmp}/resolved" 2>"${tmp}/err"; then
    ok "${#pkgs[@]} listed packages -> $(wc -l <"${tmp}/resolved") packages after dependencies"
else
    bad "resolution failed:"; sed 's/^/       /' "${tmp}/err"
fi

echo ":: Enabled units are provided by the image"
while IFS= read -r link; do
    target="$(readlink "${link}")"
    case "${target}" in
        /usr/lib/systemd/system/*) unit="${target#/}" ;;
        *) continue ;;  # relative links point at units inside airootfs
    esac
    owner="$(pac -Fq "/${unit}" 2>/dev/null | sed 's|.*/||' | sort -u)"
    found=0
    for o in ${owner}; do grep -qx "${o}" "${tmp}/resolved" && found=1; done
    (( found )) && ok "${link#"${profile}/airootfs/"} -> ${unit##*/}" \
                || bad "${link#"${profile}/airootfs/"}: ${unit} not shipped by any package in the image"
done < <(find "${profile}/airootfs/etc/systemd/system" -type l)

echo ":: FernOS packages vs Arch file ownership"
for p in "${repo_root}"/build/repo/*.pkg.tar.zst; do
    n=0
    while IFS= read -r f; do
        owner="$(pac -Fq "/${f}" 2>/dev/null | grep -v '^fernos/' | grep -v 'deepin-kwin')"
        [[ -n "${owner}" ]] && { bad "/${f} also owned by ${owner}"; n=1; }
    done < <(bsdtar -tf "$p" | grep -v '^\.' | grep -v '/$')
    (( n )) || ok "$(basename "$p"): no conflicts"
done

echo
(( fail )) && { echo "Checks FAILED"; exit 1; } || echo "All checks passed"
