#!/usr/bin/env python3
"""Generate the FernOS vector logo (deterministic).

Usage: make_logo.py OUTPUT_DIR
Writes fernos.svg (frond only, transparent) and fernos-badge.svg
(frond on a cream rounded square, for launchers/boot menus).
"""
import math
import sys
from pathlib import Path

MOSS_DARK = "#597B55"   # stem / shadow side (Fernblox light accent)
MOSS = "#82966B"        # Fern "moss"
MOSS_LIGHT = "#9BAE7D"  # Fern "moss_light"
CREAM = "#EDE8D8"       # Fern "text" / cream
FOREST = "#18271F"      # Fern "background"


def frond():
    """Return SVG elements for a single fern frond curving up and to the right."""
    # Stem: quadratic curve from bottom-left to top-right.
    p0, p1, p2 = (60, 206), (120, 146), (200, 50)

    def bez(t):
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1]
        dx = 2 * (1 - t) * (p1[0] - p0[0]) + 2 * t * (p2[0] - p1[0])
        dy = 2 * (1 - t) * (p1[1] - p0[1]) + 2 * t * (p2[1] - p1[1])
        return x, y, math.atan2(dy, dx)

    def leaflet(x, y, a, length, width, color):
        tx, ty = x + length * math.cos(a), y + length * math.sin(a)
        nx, ny = -math.sin(a) * width, math.cos(a) * width
        mx, my = x + (tx - x) * 0.45, y + (ty - y) * 0.45
        return (f'<path d="M{x:.1f},{y:.1f} Q{mx + nx:.1f},{my + ny:.1f} {tx:.1f},{ty:.1f} '
                f'Q{mx - nx:.1f},{my - ny:.1f} {x:.1f},{y:.1f}Z" fill="{color}"/>')

    parts = []
    n = 8
    for i in range(n):
        t = 0.14 + i * (0.78 / n)
        x, y, ang = bez(t)
        length = 54 * (1 - t) ** 0.8 + 12   # leaflets shrink toward the tip
        for side, color in ((-1, MOSS_LIGHT), (1, MOSS)):
            parts.append(leaflet(x, y, ang + side * math.radians(62), length, length * 0.26, color))
    # Tip leaflet, pointing along the stem; the stem stops underneath it.
    x, y, ang = bez(0.92)
    parts.append(leaflet(x, y, ang, 30, 8, MOSS_LIGHT))
    parts.append(f'<path d="M{p0[0]},{p0[1]} Q{p1[0]},{p1[1]} {x:.1f},{y:.1f}" stroke="{MOSS_DARK}" '
                 'stroke-width="7" stroke-linecap="round" fill="none"/>')
    return "\n  ".join(parts)


def svg(body, bg=None):
    rect = (f'<rect x="8" y="8" width="240" height="240" rx="56" fill="{bg}"/>\n  ' if bg else "")
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">\n'
            f'  {rect}{body}\n</svg>\n')


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    out.mkdir(parents=True, exist_ok=True)
    (out / "fernos.svg").write_text(svg(frond()))
    (out / "fernos-badge.svg").write_text(svg(frond(), bg=CREAM))


if __name__ == "__main__":
    main()
