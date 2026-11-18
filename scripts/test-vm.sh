#!/usr/bin/env bash
# Boot a FernOS ISO in QEMU/KVM for testing. Never touches real disks.
#
#   ./scripts/test-vm.sh                    # newest ISO in build/out, UEFI
#   ./scripts/test-vm.sh --bios             # legacy BIOS boot
#   ./scripts/test-vm.sh --disk             # also attach build/vm/disk.qcow2 (20G, created if
#                                           # missing) as an install target
#   ./scripts/test-vm.sh --boot-disk        # boot the installed system from that disk image
#   ./scripts/test-vm.sh --iso path/to.iso
#   ./scripts/test-vm.sh --headless         # no window; control it with scripts/vm-ctl.py
#                                           # (screenshots, typing, clicks) over QMP
#
# Requires: qemu-desktop (or qemu-full), edk2-ovmf for UEFI.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
vm_dir="${repo_root}/build/vm"
iso="" mode=uefi disk=0 boot_disk=0 headless=0 mem="${FERNOS_VM_MEM:-4096}" cpus="${FERNOS_VM_CPUS:-4}"

while (( $# )); do
    case "$1" in
        --bios) mode=bios ;;
        --uefi) mode=uefi ;;
        --disk) disk=1 ;;
        --boot-disk) disk=1 boot_disk=1 ;;
        --iso) iso="$2"; shift ;;
        --headless) headless=1 ;;
        -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

command -v qemu-system-x86_64 >/dev/null || { echo "error: install qemu-desktop (sudo pacman -S qemu-desktop edk2-ovmf)" >&2; exit 1; }
if (( ! boot_disk )); then
    [[ -n "${iso}" ]] || iso="$(ls -t "${repo_root}"/build/out/*.iso 2>/dev/null | head -n1 || true)"
    [[ -f "${iso}" ]] || { echo "error: no ISO found; run scripts/build-iso.sh first" >&2; exit 1; }
fi
mkdir -p -- "${vm_dir}"

args=(-enable-kvm -machine q35 -cpu host -smp "${cpus}" -m "${mem}"
      -device virtio-vga-gl -display gtk,gl=on
      -device qemu-xhci -device usb-tablet
      -audiodev pipewire,id=snd0 -device intel-hda -device hda-duplex,audiodev=snd0
      -nic user,model=virtio-net-pci)
if [[ ! -e /dev/kvm ]]; then
    echo "warning: /dev/kvm missing, running without acceleration (slow)" >&2
    args=(-machine q35 -cpu max "${args[@]:5}")
fi

if [[ "${mode}" == uefi ]]; then
    code=/usr/share/edk2/x64/OVMF_CODE.4m.fd vars_tpl=/usr/share/edk2/x64/OVMF_VARS.4m.fd
    [[ -f "${code}" ]] || { echo "error: ${code} missing (sudo pacman -S edk2-ovmf)" >&2; exit 1; }
    [[ -f "${vm_dir}/OVMF_VARS.4m.fd" ]] || cp -- "${vars_tpl}" "${vm_dir}/OVMF_VARS.4m.fd"
    args+=(-drive "if=pflash,format=raw,unit=0,file=${code},read-only=on"
           -drive "if=pflash,format=raw,unit=1,file=${vm_dir}/OVMF_VARS.4m.fd")
fi

if (( disk )); then
    [[ -f "${vm_dir}/disk.qcow2" ]] || qemu-img create -f qcow2 "${vm_dir}/disk.qcow2" 40G
    args+=(-drive "file=${vm_dir}/disk.qcow2,if=virtio,format=qcow2")
fi
if (( ! boot_disk )); then
    args+=(-drive "file=${iso},media=cdrom,readonly=on" -boot order=d)
fi

if (( headless )); then
    # Swap the GTK window for a QMP socket + serial log (see scripts/vm-ctl.py).
    for i in "${!args[@]}"; do
        case "${args[i]}" in
            virtio-vga-gl) args[i]=virtio-vga ;;
            gtk,gl=on) args[i]=none ;;
        esac
    done
    rm -f -- "${vm_dir}/qmp.sock"
    args+=(-qmp "unix:${vm_dir}/qmp.sock,server,nowait" -serial "file:${vm_dir}/serial.log")
    args=("${args[@]/pipewire,id=snd0/none,id=snd0}")
fi

echo ":: ${mode^^} boot${iso:+ of ${iso}}"
exec qemu-system-x86_64 "${args[@]}"
