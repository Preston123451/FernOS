#!/usr/bin/env python3
import libcalamares


def pretty_name():
    return "Selecting the GRUB boot loader"


def run():
    libcalamares.globalstorage.insert("packagechooser_bootloader", "grub")
    return None
