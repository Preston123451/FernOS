# Roadmap

Status key: ✅ done and tested · 🟡 implemented, not yet tested · ⬜ not started

## 0.1 Foundation
* 🟡 Bootable ISO (UEFI systemd-boot + BIOS syslinux), FernOS boot menus, safe-graphics entry
* 🟡 Live environment: autologin to KDE Plasma (Wayland) as `fern`
* 🟡 Fern branding: logo, light/dark wallpaper, Fern Light/Dark colors, Look-and-Feel, boot splash, os-release
* 🟡 NetworkManager, PipeWire, Bluetooth, ufw firewall
* 🟡 Fern Konsole profile and fish prompt *(pulled forward from 0.2)*
* ⬜ Boot test in QEMU (UEFI + BIOS). **Next step**

## 0.2 Coding, working and gaming (current)
* 🟡 Arch + CachyOS (generic x86-64) repos, `linux-cachyos` kernel, multilib
* 🟡 **Graphical installer**: Calamares (CachyOS build) with FernOS config, offline
  install of the live system, GRUB on UEFI + BIOS, fish shell, zram swap
* 🟡 **Game Mode / Work Mode** (`fernos-modes`): panel button, launcher entries,
  Fern Night / Fern Mist wallpapers, focus timer
* 🟡 Zen Browser (default), Code-OSS, Claude Code, dev toolchains
* 🟡 Steam, Lutris, Heroic, Discord, MangoHud, GameMode, Flatpak; Shelly
* 🟡 Fern and Fernblox packaged in `[fernos]` *(pulled forward from 0.5)*
* ⬜ SDDM login screen theme (currently Breeze with the Fern wallpaper)
* ⬜ Custom splash and Plymouth boot screen

## 0.3 Stability
* ⬜ Hardware test matrix (Intel/AMD CPUs; Intel/AMD/NVIDIA GPUs; Wi-Fi/BT chipsets)
* ⬜ NVIDIA proprietary driver option in the installer (`nvidia-open` + `nvidia-utils`)
* ⬜ Secure Boot (shim or sbctl-signed systemd-boot), installation tests, recovery docs

## 0.5 Fern ecosystem
* 🟡 Package the Fern desktop app and Fernblox *(done in 0.2)*
* ⬜ Fern application directory
* ⬜ Hosted FernOS repository and signing key for updates; official website


## 1.0 Stable
Reliable install, polished desktop, tested hardware list, complete docs, signed release ISO.
