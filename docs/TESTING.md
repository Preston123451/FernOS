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
| — | — | Real hardware | **not tested**. No hardware compatibility is claimed yet |

Installation and installed-system boot tests start with 0.2 (installer).
