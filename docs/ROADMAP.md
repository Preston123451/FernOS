# Roadmap

Status key: ✅ done and tested · 🟡 implemented, not yet tested · ⬜ not started

## 0.1 Foundation (current)
* 🟡 Bootable ISO (UEFI systemd-boot + BIOS syslinux), FernOS boot menus, safe-graphics entry
* 🟡 Live environment: autologin to KDE Plasma (Wayland) as `fern`
* 🟡 Fern branding: logo, light/dark wallpaper, Fern Light/Dark colors, Look-and-Feel, boot splash, os-release
* 🟡 NetworkManager, PipeWire, Bluetooth, ufw firewall
* 🟡 Fern Konsole profile and fish prompt *(pulled forward from 0.2)*
* ⬜ Boot test in QEMU (UEFI + BIOS). **Next step**

## 0.2 Desktop
* ⬜ **Graphical installer.** Plan: **Calamares**, which isn't in the official
  repos. Build it from its AUR PKGBUILD into the local `[fernos]` repo
  (`packages/calamares`), plus a `fernos-calamares-config` package with Fern
  branding. Use the `unpackfs` module to copy the live squashfs, then remove the
  live-only files (`sudoers.d/10-fernos-live`, polkit rule, autologin),
  `systemctl preset-all`, and install the bootloader (systemd-boot on UEFI, GRUB on BIOS).
  Every partitioning step must stay behind Calamares' explicit confirmation page.
* ⬜ SDDM login screen theme (currently Breeze with the Fern wallpaper)
* ⬜ Custom splash and Plymouth boot screen
* ⬜ Notification and Dolphin tuning (needs testing against Plasma 6 config keys)

## 0.3 Stability
* ⬜ Hardware test matrix (Intel/AMD CPUs; Intel/AMD/NVIDIA GPUs; Wi-Fi/BT chipsets)
* ⬜ NVIDIA proprietary driver option in the installer (`nvidia-open` + `nvidia-utils`)
* ⬜ Secure Boot (shim or sbctl-signed systemd-boot), installation tests, recovery docs

## 0.5 Fern ecosystem
* ⬜ Package the Fern desktop app (`~/Projects/Fern`, PySide6) and FernBlox as pacman packages in `[fernos]`
* ⬜ Fern application directory
* ⬜ Hosted FernOS repository and signing key for updates; official website

Nothing for Fern or FernBlox ships in 0.1. They will be packaged when they reach 0.5.

## 1.0 Stable
Reliable install, polished desktop, tested hardware list, complete docs, signed release ISO.
