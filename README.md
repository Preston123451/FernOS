# FernOS

**A calmer way to use the internet.**

FernOS is an Arch Linux–based desktop operating system in the Fern software
ecosystem: KDE Plasma with a natural, quiet look (cream, beige and muted
green), built for **coding, working and gaming**. It uses Arch plus the
CachyOS repositories (fast `linux-cachyos` kernel, generic x86-64 builds that
run on any 64-bit PC) and is built reproducibly with
[archiso](https://wiki.archlinux.org/title/Archiso).

* **Game Mode / Work Mode**: one click in the panel (performance CPU + GameMode +
  effects off + night theme, or calm theme + focus timer + quiet CPU).
* **Zen Browser**, Code-OSS, Claude Code, Steam, Lutris, Heroic, Discord,
  MangoHud, Shelly, Fern and Fernblox preinstalled; fish shell.
* **Graphical installer** (Calamares): installs the live system as-is, no internet needed.

> **Status: 0.2, in development.** See [docs/ROADMAP.md](docs/ROADMAP.md) and the honest test status
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
