#!/usr/bin/env python3
"""FernOS: keep the NVIDIA 580xx driver only where an NVIDIA GPU is present.

The ISO ships the proprietary NVIDIA 580xx driver (the last series that
supports GeForce 900/10-series cards, and also covers 16/20/30/40-series),
prebuilt for linux-cachyos. On a PC without an NVIDIA graphics card it is
removed from the installed system, so nouveau is not blacklisted and no
unused driver is updated forever.
"""
from pathlib import Path

import libcalamares

NVIDIA_VENDOR = "0x10de"
DISPLAY_CLASS = "0x03"  # PCI base class 03 = display controller

NVIDIA_PACKAGES = [
    "linux-cachyos-nvidia-580xx",
    "nvidia-580xx-settings",
    "libxnvctrl-580xx",
    "lib32-nvidia-580xx-utils",
    "lib32-opencl-nvidia-580xx",
    "opencl-nvidia-580xx",
    "nvidia-580xx-utils",
]


def pretty_name():
    return "Setting up the graphics driver"


def has_nvidia_gpu():
    for dev in Path("/sys/bus/pci/devices").glob("*"):
        try:
            vendor = (dev / "vendor").read_text().strip().lower()
            klass = (dev / "class").read_text().strip().lower()
        except OSError:
            continue
        if vendor == NVIDIA_VENDOR and klass.startswith(DISPLAY_CLASS):
            return True
    return False


def run():
    if has_nvidia_gpu():
        libcalamares.utils.debug("fernosgpu: NVIDIA GPU found, keeping the NVIDIA 580xx driver")
        return None

    libcalamares.utils.debug("fernosgpu: no NVIDIA GPU, removing the NVIDIA driver")
    installed = [p for p in NVIDIA_PACKAGES
                 if libcalamares.utils.target_env_call(["pacman", "-Qq", p]) == 0]
    if installed:
        rc = libcalamares.utils.target_env_call(
            ["pacman", "-Rns", "--noconfirm", *installed])
        if rc != 0:
            # Not fatal: the driver only loads on NVIDIA hardware anyway.
            libcalamares.utils.warning(f"fernosgpu: pacman -R exited with {rc}")
    return None
