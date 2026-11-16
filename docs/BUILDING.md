# Building FernOS

## Requirements (Arch-based host)

```sh
sudo pacman -S --needed archiso base-devel rsync git
# for VM testing:
sudo pacman -S --needed qemu-desktop edk2-ovmf
```

Disk: ~15 GB free under `build/` while building. RAM: 4 GB+.

## Steps

```sh
./scripts/check.sh       # validates package list, units, file conflicts (no root)
./scripts/build-iso.sh   # ~20-40 min; sudo prompt for mkarchiso
```

`build-iso.sh` does this:
1. `scripts/build-packages.sh` builds `packages/*` with makepkg into `build/repo`.
2. It copies `iso/profile` to `build/profile` and adds the `[fernos]` repo and a
   dedicated package cache to its `pacman.conf`.
3. It runs `sudo mkarchiso` and writes the ISO to `build/out/` and the log to `build/build-iso.log`.

## Changing branding or colors

```sh
./branding/tools/render-assets.sh                         # logo, wallpapers, boot splash
python3 desktop/tools/make_colorschemes.py desktop/rootfs # Plasma colors + kdeglobals
cp branding/dist/boot/splash.png iso/profile/syslinux/splash.png
```
Commit the regenerated files: ISO builds use the committed outputs and need no Python or librsvg.
Bump `pkgver` in `packages/fernos-desktop-settings/PKGBUILD` when its contents change.
