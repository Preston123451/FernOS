# FernOS

**A calmer way to use the internet.**

FernOS is an Arch Linux–based desktop operating system in the Fern software
ecosystem: KDE Plasma with a natural, quiet look (cream, beige and muted
green) and sensible defaults. It is built reproducibly with
[archiso](https://wiki.archlinux.org/title/Archiso) from the official Arch
repositories, so it does not depend on the machine it is built on.

> **Status: 0.1 (Foundation), in development.** The live ISO is not yet
> installable. See [docs/ROADMAP.md](docs/ROADMAP.md) and the honest test status
> in [docs/TESTING.md](docs/TESTING.md).

## Quick start

```sh
./scripts/check.sh        # static checks, no root needed
./scripts/build-iso.sh    # builds packages + ISO (asks for sudo for mkarchiso)
./scripts/test-vm.sh      # boot the ISO in QEMU/KVM (UEFI); --bios for legacy
```

Full instructions: [docs/BUILDING.md](docs/BUILDING.md).

## Repository layout

| Path | What it is |
|---|---|
| `iso/profile/` | archiso profile: package list, boot menus, live-session-only files (`airootfs/`) |
| `packages/` | FernOS's own pacman packages (PKGBUILDs), built into a local repo |
| `desktop/` | Desktop defaults installed by `fernos-desktop-settings` (Plasma, Konsole, SDDM, fish, presets) |
| `branding/` | Logo and wallpaper sources, generators, and rendered assets (`dist/`) |
| `scripts/` | Build, check and VM test tools |
| `docs/` | Architecture decisions, building, testing, troubleshooting, roadmap |
| `build/` | Build output (ignored by git) |
