# FernOS architecture and decisions

Each decision records **what** was chosen, **why**, and what it costs.

## ADR-1: Built from the archiso `releng` profile
The project started as a copy of archiso's `releng` profile with FernOS changes
(baseline commit `da02f8b`). We keep that structure so upstream archiso fixes
can be diffed and merged: `diff -r /usr/share/archiso/configs/releng iso/profile`.

## ADR-2: Only official Arch repositories, dedicated package cache
`iso/profile/pacman.conf` lists only `[core]` and `[extra]`. `scripts/build-iso.sh`
adds the local `[fernos]` repo and a **dedicated package cache** (`build/cache`)
at build time. The build host is CachyOS, whose cache holds CachyOS rebuilds
of Arch packages; the separate cache keeps them out of the ISO. The
mirrorlist defaults to the host's `/etc/pacman.d/mirrorlist` (override with
`FERNOS_MIRRORLIST=...`). `SOURCE_DATE_EPOCH` is the last commit time.

## ADR-3: Desktop defaults ship as a package, not as live-ISO files
Branding and desktop defaults (`desktop/rootfs`, `branding/dist`) are packaged
as **`fernos-desktop-settings`** (`packages/`). The live ISO installs it like any
other package, and the installer (0.2) will install the same package, so the
live and installed systems look the same and updates can be shipped later.
`iso/profile/airootfs` holds **only** live-session behaviour: autologin, the
passwordless `fern` user, NOPASSWD sudo, the polkit rule, no screen lock.

Defaults use **KDE's config cascading**. Files in `/etc/xdg/*rc` are system-wide
defaults that every user inherits until they change a setting in System Settings
(saved to `~/.config`). Nothing is written into user home directories, so user
changes are never overwritten.

## ADR-4: Plasma look via a Look-and-Feel package
`/etc/xdg/kdeglobals` sets `LookAndFeelPackage=org.fernos.desktop`. On a user's
first login, plasmashell builds the panel and desktop from that package's
`layouts/org.kde.plasma.desktop-layout.js`: a bottom floating panel, the Fern
launcher icon, Dolphin/Firefox/Konsole/Settings pinned, and the Fern wallpaper.
Splash, lock screen and logout screens fall back to Breeze. The Breeze splash
is disabled (`ksplashrc`) until FernOS has its own.

## ADR-5: Colors are generated from the Fern app palette
The palette comes from the existing Fern app (`Fern/fern/theme.py`) and
Fernblox light/dark themes, not invented. `desktop/tools/make_colorschemes.py`
generates `FernLight`/`FernDark` Plasma schemes and `/etc/xdg/kdeglobals`;
`branding/tools/` generates the logo and wallpapers. **Edit the generators,
not the outputs**, then rerun them.

## ADR-6: os-release via pacman hook
`/usr/lib/os-release` belongs to Arch's `filesystem` package. A hook in
`fernos-desktop-settings` re-applies FernOS's copy (`ID=fernos`, `ID_LIKE=arch`)
after `filesystem` installs or upgrades. Cost: `pacman -Qkk filesystem` reports
the file as modified. That is expected.

## ADR-7: Networking = NetworkManager only
releng enabled `systemd-networkd` + `iwd` for a console installer. A desktop
needs NetworkManager (Plasma's network applet uses it). Running both causes
interfaces to be fought over, so networkd, its wait-online and iwd were
disabled. `systemd-resolved` is kept; NetworkManager uses it automatically
through the stub `resolv.conf`.

## ADR-8: Security defaults
* **Firewall:** `ufw` is enabled (deny incoming, allow outgoing) by a hook that
  runs only on ufw's *first install*, so a user's later choice is never
  overridden. GUI: System Settings > Firewall (`plasma-firewall`).
* **No SSH server on the live ISO** (releng enabled `sshd` with root login).
* **No secrets in the ISO.** The live user `fern` has an empty password *by
  design*, like every Arch-based live medium. The NOPASSWD sudo and polkit
  rules live in `airootfs/` and never reach installed systems.
* Removed `cloud-init` (VM provisioning). It isn't useful on a desktop and slowed boot.

## ADR-9: Graphics: open drivers on the live ISO, "safe graphics" entry
The live ISO ships Mesa (Intel/AMD/nouveau + NVK Vulkan) and VA-API drivers.
Proprietary NVIDIA (`nvidia-open`) is *not* on the live ISO: it replaces
nouveau for all NVIDIA cards and does not support older GPUs. It will be
an installer option (0.3). Boot menus have a **safe graphics** (`nomodeset`)
entry for both BIOS and UEFI.
Plasma 6 on current Arch has no X11 session package, so there is no X11
desktop fallback. The SDDM greeter itself runs on X11 (sddm depends on xorg-server).

## ADR-10: Live user shell is fish
Kept from the existing work (`20-fernos-user.hook`). FernOS ships a system-wide
fish prompt and colors in `/etc/fish/`; users override them in `~/.config/fish`.
