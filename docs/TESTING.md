# Testing FernOS

**Rule: nothing is marked as working until it has been tested.** Record the
date, ISO file name, and environment for every result.

## Tools

```sh
./scripts/check.sh                 # static checks
./scripts/test-vm.sh               # UEFI boot of newest ISO
./scripts/test-vm.sh --bios        # BIOS boot
./scripts/test-vm.sh --disk        # ISO + empty 20G virtual disk (install target)
./scripts/test-vm.sh --boot-disk   # boot what was installed on that virtual disk
```
The VM scripts only use image files under `build/vm/`; they never touch real disks.

## Live ISO checklist (0.1)

| # | Test | How | Expected |
|---|---|---|---|
| 1 | ISO builds | `scripts/build-iso.sh` | exit 0, ISO in `build/out` |
| 2 | UEFI boot | `test-vm.sh` | systemd-boot menu shows "FernOS live", desktop appears |
| 3 | BIOS boot | `test-vm.sh --bios` | syslinux menu with Fern splash, desktop appears |
| 4 | Safe graphics | pick "safe graphics" entry | desktop appears (software rendering) |
| 5 | Autologin | — | logs in as `fern` with no prompt |
| 6 | Branding | look | Fern wallpaper, bottom panel, fern launcher icon, Fern Light colors |
| 7 | os-release | `cat /etc/os-release` | `NAME="FernOS"` |
| 8 | Konsole | open Konsole | Fern colors, Hack font, fern prompt in fish |
| 9 | Networking | `nmcli`, browse in Firefox | connected via NetworkManager |
| 10 | Audio | System Settings > Sound, play a test sound | PipeWire output works |
| 11 | Firewall | `sudo ufw status verbose` | active, deny incoming |
| 12 | Bluetooth | tray icon / `bluetoothctl show` | adapter listed (on hardware with BT) |
| 13 | Display | System Settings > Display | resolution changes apply |
| 14 | Apps launch | Dolphin, Kate, Firefox, Spectacle, Gwenview, Okular, Ark | open without errors |
| 15 | Package management | `sudo pacman -Sy && pacman -Si firefox` | works (needs network) |
| 16 | Failed units | `systemctl --failed` | none (or documented) |

## Results

| Date | ISO | Environment | Result |
|---|---|---|---|
| 2026-11-16 | — | static (`check.sh`) | **pass**: 189 listed packages resolve (972 with deps), all enabled units provided, no file conflicts |
| 2026-11-16 | — | ISO build | **not yet run**: needs sudo on the build host |
| — | — | QEMU UEFI/BIOS | **not yet run**: QEMU/OVMF not installed on build host |
| 2026-11-17 | fernos-2026.11.17-x86_64.iso (build 2) | ISO build on CachyOS host | **pass**: 3.2 GB ISO |
| 2026-11-17 | build 2 | QEMU/KVM UEFI, headless (`test-vm.sh --headless`, `vm-ctl.py`) | **pass**: systemd-boot menu, Plasma live desktop, autologin, Fern branding, Install icon, panel pins (Dolphin, Zen, Konsole, Code, Steam, Fernblox) |
| 2026-11-17 | build 2 | Game / Work / Normal modes (live) | **pass**: chooser dialog, night/mist wallpapers, FernDark/FernLight, notification; Normal restored the original wallpaper. Performance profile not offered by the VM CPU, fallback to balanced worked |
| 2026-11-17 | build 2 | Calamares install, erase 40 GB virtio disk, UEFI | **pass**: FernOS branding/slideshow, "All done", no errors in session log |
| 2026-11-17 | build 2 | Installed system boot (UEFI GRUB) | **pass**: GRUB → SDDM → Plasma as new user; fish shell, sudo needs password, live files removed, Calamares removed, zram active, os-release FernOS, NetworkManager connected, no failed units, `pacman -Sy` works, Fernblox and Zen launch |
| 2026-11-17 | build 2 | Issues found → fixed in build 3 | GRUB menu said "Arch Linux" (grubcfg skipped: fixed with `fernosbootloader` job); KWallet wizard on first password save (kwallet-pam); System Settings pin blank (desktop file renamed in Plasma 6); chooser text cut off |
| 2026-11-17 | build 3 | UEFI install + boot | **pass**: GRUB entry "FernOS", fixes from build 2 confirmed: System Settings pin, no KWallet wizard (Fernblox opened with no prompt), Fernblox shows Install Sober on a fresh system |
| 2026-11-17 | build 3 | BIOS (SeaBIOS) live boot, install, installed boot | **pass**: syslinux Fern menu, Calamares created BIOS boot partition + GRUB in MBR, installed system boots to SDDM |
| — | — | Sober install from Fernblox, Steam/game launch, Claude Code login | **not yet run** (needs downloads/accounts) |
| — | — | Real hardware | **not tested**. No hardware compatibility is claimed yet |

Installation and installed-system boot tests start with 0.2 (installer).
