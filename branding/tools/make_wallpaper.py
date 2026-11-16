#!/usr/bin/env python3
"""Generate the FernOS "Fern" wallpaper as SVG (light + dark), deterministically.

Usage: make_wallpaper.py OUTPUT_DIR
Render to PNG/JPEG with rsvg-convert (see render_assets.sh).
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from make_logo import frond  # noqa: E402

W, H = 3840, 2160

PALETTES = {
    "light": dict(sky_top="#F3F0E5", sky_bottom="#E9EDDF",
                  hills=("#DCE3D0", "#C9D4B9", "#AEBF98"), fern_opacity=0.55),
    "dark": dict(sky_top="#18271F", sky_bottom="#203128",
                 hills=("#26382D", "#2D4033", "#385640"), fern_opacity=0.35),
}


def hill(y_base, amp, phase, color):
    """A soft rolling hill built from cubic curves across the full width."""
    pts = [f"M0,{H}", f"L0,{y_base}"]
    segs = 4
    for i in range(segs):
        x0 = W * i / segs
        x1 = W * (i + 1) / segs
        up = amp if (i + phase) % 2 == 0 else -amp
        pts.append(f"C{x0 + W / segs / 3:.0f},{y_base - up:.0f} "
                   f"{x1 - W / segs / 3:.0f},{y_base - up:.0f} {x1:.0f},{y_base:.0f}")
    pts.append(f"L{W},{H}Z")
    return f'<path d="{" ".join(pts)}" fill="{color}"/>'


def wallpaper(p):
    h1, h2, h3 = p["hills"]
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{p["sky_top"]}"/>
      <stop offset="1" stop-color="{p["sky_bottom"]}"/>
    </linearGradient>
  </defs>
  <rect width="{W}" height="{H}" fill="url(#sky)"/>
  {hill(1380, 90, 0, h1)}
  {hill(1600, 70, 1, h2)}
  {hill(1840, 50, 0, h3)}
  <g opacity="{p["fern_opacity"]}" transform="translate(2620,1180) scale(4.4)">
  {frond()}
  </g>
  <g opacity="{p["fern_opacity"] * 0.7}" transform="translate(3420,1370) scale(2.6) rotate(18 128 128)">
  {frond()}
  </g>
</svg>
'''


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    out.mkdir(parents=True, exist_ok=True)
    for name, pal in PALETTES.items():
        (out / f"fern-{name}.svg").write_text(wallpaper(pal))


if __name__ == "__main__":
    main()
