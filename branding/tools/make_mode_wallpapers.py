#!/usr/bin/env python3
"""Generate the FernOS mode wallpapers as SVG, deterministically.

  fern-night.svg  Game Mode: dark forest night with a glowing fern
  fern-mist.svg   Work Mode: calm, low-contrast mist with one faint fern

Usage: make_mode_wallpapers.py OUTPUT_DIR
Rendered to PNG by render-assets.sh.
"""
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from make_logo import MOSS, MOSS_DARK, MOSS_LIGHT, frond  # noqa: E402
from make_wallpaper import H, W, hill  # noqa: E402


def recolor(body, light, mid, dark):
    return body.replace(MOSS_LIGHT, light).replace(MOSS, mid).replace(MOSS_DARK, dark)


def night():
    rng = random.Random(7)  # fixed seed: same stars every build
    stars = "\n  ".join(
        f'<circle cx="{rng.randrange(W)}" cy="{rng.randrange(int(H * 0.55))}" '
        f'r="{rng.choice((1.5, 2, 2.5, 3))}" fill="#DDF5D0" opacity="{rng.uniform(0.25, 0.8):.2f}"/>'
        for _ in range(140)
    )
    glow_fern = recolor(frond(), "#B8F27C", "#6FDC8C", "#3FA86A")
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#05090A"/>
      <stop offset="0.6" stop-color="#0B1712"/>
      <stop offset="1" stop-color="#11241A"/>
    </linearGradient>
    <radialGradient id="aura" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0" stop-color="#6FDC8C" stop-opacity="0.35"/>
      <stop offset="1" stop-color="#6FDC8C" stop-opacity="0"/>
    </radialGradient>
    <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="6" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <rect width="{W}" height="{H}" fill="url(#sky)"/>
  {stars}
  <ellipse cx="2700" cy="1060" rx="1100" ry="900" fill="url(#aura)"/>
  {hill(1500, 80, 0, "#0E1C15")}
  {hill(1700, 60, 1, "#132619")}
  {hill(1900, 45, 0, "#183020")}
  <g filter="url(#glow)" transform="translate(2160,420) scale(4.6)">
  {glow_fern}
  </g>
</svg>
'''


def mist():
    soft_fern = recolor(frond(), "#C9D4B9", "#B7C5A4", "#9FB28B")
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#F6F4EC"/>
      <stop offset="1" stop-color="#E4EADB"/>
    </linearGradient>
  </defs>
  <rect width="{W}" height="{H}" fill="url(#sky)"/>
  {hill(1720, 40, 1, "#E6EBDD")}
  {hill(1900, 30, 0, "#DCE3D0")}
  <g opacity="0.55" transform="translate(2980,1420) scale(2.4)">
  {soft_fern}
  </g>
</svg>
'''


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    out.mkdir(parents=True, exist_ok=True)
    (out / "fern-night.svg").write_text(night())
    (out / "fern-mist.svg").write_text(mist())


if __name__ == "__main__":
    main()
