# Troubleshooting

## Live ISO

**Black screen or garbled display after boot.** Choose the *safe graphics*
boot entry (adds `nomodeset`). This is common on NVIDIA cards and very new GPUs.

**Stuck at a console instead of the desktop.** Switch with Ctrl+Alt+F1. On
another console (Ctrl+Alt+F2, login `root`, no password), check
`systemctl status sddm` and `journalctl -b -u sddm`.

**No network.** Run `nmcli device status`. For Wi-Fi: `nmcli device wifi connect "<SSID>" --ask`.
If Wi-Fi is missing entirely, check `rfkill list` and that firmware loaded: `journalctl -b -k | grep -i firmware`.

**No sound.** Run `wpctl status` and check that the right output is the default. In VMs, make
sure an audio device is attached.

**Screen reader.** Choose the *with speech* boot entry.

## Build

**`mkarchiso` fails while installing packages.** The mirror may be out of
sync. Retry, or use another mirrorlist: `FERNOS_MIRRORLIST=/path/to/mirrorlist ./scripts/build-iso.sh`.
Run `./scripts/check.sh` first; it catches missing/renamed packages without root.

**"error: run as your normal user".** The scripts call sudo themselves; makepkg refuses to run as root.

**Disk fills up.** `sudo rm -rf build/work` (mkarchiso's scratch directory) is always safe to delete.

## Installed system (from 0.2)
Recovery: boot the live ISO, `mount` the root partition, `arch-chroot` into it,
then fix it with pacman. To be documented with the installer.
