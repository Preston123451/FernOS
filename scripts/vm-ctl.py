#!/usr/bin/env python3
"""Drive a headless FernOS test VM (scripts/test-vm.sh --headless) over QMP.

  vm-ctl.py shot OUT.png            screenshot of the VM screen
  vm-ctl.py type 'some text'        type text (US layout)
  vm-ctl.py key ctrl-alt-t          press a key combo (QEMU key names: ret, tab, esc, spc, ...)
  vm-ctl.py click X Y [right|double]   click at screen pixel X,Y (of the last screenshot size)
  vm-ctl.py move X Y                move the pointer
  vm-ctl.py scroll X Y N            scroll N notches at X,Y (negative = up)
  vm-ctl.py powerdown | quit        ACPI shutdown / kill the VM

Only talks to build/vm/qmp.sock; never touches real disks or the host desktop.
"""
import json
import os
import socket
import struct
import sys
import time
from pathlib import Path

VM_DIR = Path(__file__).resolve().parent.parent / "build" / "vm"
SOCK = VM_DIR / "qmp.sock"
SIZE_FILE = VM_DIR / "screen-size"


class QMP:
    def __init__(self, path=SOCK):
        self.s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.s.connect(str(path))
        self.f = self.s.makefile("rwb")
        self._read()  # greeting
        self.cmd("qmp_capabilities")

    def _read(self):
        while True:
            line = self.f.readline()
            if not line:
                raise ConnectionError("QMP closed")
            msg = json.loads(line)
            if "event" not in msg:
                return msg

    def cmd(self, name, **args):
        self.f.write(json.dumps({"execute": name, "arguments": args}).encode() + b"\n")
        self.f.flush()
        reply = self._read()
        if "error" in reply:
            raise RuntimeError(f"{name}: {reply['error']}")
        return reply.get("return")


def png_size(path):
    with open(path, "rb") as f:
        head = f.read(24)
    return struct.unpack(">II", head[16:24])


def screen_size():
    try:
        w, h = SIZE_FILE.read_text().split()
        return int(w), int(h)
    except (OSError, ValueError):
        return 1280, 800


CHARS = {
    " ": "spc", "\n": "ret", "\t": "tab", "-": "minus", "=": "equal", "[": "bracket_left",
    "]": "bracket_right", ";": "semicolon", "'": "apostrophe", "`": "grave_accent",
    "\\": "backslash", ",": "comma", ".": "dot", "/": "slash",
}
SHIFTED = {
    "!": "1", "@": "2", "#": "3", "$": "4", "%": "5", "^": "6", "&": "7", "*": "8",
    "(": "9", ")": "0", "_": "minus", "+": "equal", "{": "bracket_left", "}": "bracket_right",
    ":": "semicolon", '"': "apostrophe", "~": "grave_accent", "|": "backslash", "<": "comma",
    ">": "dot", "?": "slash",
}


def keys_for(ch):
    if ch.isalpha() and ch.isascii():
        return (["shift", ch.lower()] if ch.isupper() else [ch])
    if ch.isdigit():
        return [ch]
    if ch in CHARS:
        return [CHARS[ch]]
    if ch in SHIFTED:
        return ["shift", SHIFTED[ch]]
    raise ValueError(f"cannot type {ch!r}")


def send_keys(q, names, hold=80):
    q.cmd("send-key", keys=[{"type": "qcode", "data": n} for n in names], **{"hold-time": hold})


def key_event(q, name, down):
    q.cmd("input-send-event", events=[
        {"type": "key", "data": {"down": down, "key": {"type": "qcode", "data": name}}}])


def move(q, x, y):
    w, h = screen_size()
    q.cmd("input-send-event", events=[
        {"type": "abs", "data": {"axis": "x", "value": int(x * 32767 / max(1, w - 1))}},
        {"type": "abs", "data": {"axis": "y", "value": int(y * 32767 / max(1, h - 1))}},
    ])


def button(q, btn, down):
    q.cmd("input-send-event", events=[{"type": "btn", "data": {"down": down, "button": btn}}])


def main(argv):
    if len(argv) < 2:
        print(__doc__.strip())
        return 2
    q = QMP()
    op, args = argv[1], argv[2:]
    if op == "shot":
        out = Path(args[0]).resolve()
        tmp = out.with_suffix(".ppm")
        q.cmd("screendump", filename=str(tmp))
        os.system(f"magick '{tmp}' '{out}' && rm -f '{tmp}'")
        w, h = png_size(out)
        SIZE_FILE.write_text(f"{w} {h}")
        print(f"{out} {w}x{h}")
    elif op == "type":
        # Explicit key down/up events, one character at a time: send-key with a
        # hold time drops keys when calls overlap on a busy guest.
        for ch in " ".join(args):
            names = keys_for(ch)
            for n in names:
                key_event(q, n, True)
            time.sleep(0.02)
            for n in reversed(names):
                key_event(q, n, False)
            time.sleep(0.03)
    elif op == "key":
        for combo in args:
            send_keys(q, combo.split("-"))
            time.sleep(0.15)
    elif op in ("click", "move"):
        x, y = int(args[0]), int(args[1])
        move(q, x, y)
        if op == "click":
            kind = args[2] if len(args) > 2 else "left"
            btn = "right" if kind == "right" else "left"
            for _ in range(2 if kind == "double" else 1):
                time.sleep(0.05)
                button(q, btn, True)
                time.sleep(0.08)
                button(q, btn, False)
    elif op == "scroll":
        x, y, n = int(args[0]), int(args[1]), int(args[2])
        move(q, x, y)
        btn = "wheel-down" if n > 0 else "wheel-up"
        for _ in range(abs(n)):
            button(q, btn, True)
            button(q, btn, False)
            time.sleep(0.05)
    elif op == "powerdown":
        q.cmd("system_powerdown")
    elif op == "quit":
        q.cmd("quit")
    else:
        print(f"unknown command {op}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
