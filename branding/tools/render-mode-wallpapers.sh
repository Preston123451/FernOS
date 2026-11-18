#!/usr/bin/env bash
# Render the Game Mode ("Fern Night") and Work Mode ("Fern Mist") wallpapers.
# Requires: python3, rsvg-convert (librsvg), magick (imagemagick).
# Output (committed): dist/wallpaper-night, dist/wallpaper-mist (KDE wallpaper packages).
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist="${here}/dist"
python3 "${here}/tools/make_mode_wallpapers.py" "${here}/wallpaper"
for name in night mist; do
    out="${dist}/wallpaper-${name}/contents"
    rm -rf -- "${dist}/wallpaper-${name}"
    mkdir -p "${out}/images"
    for res in 1920x1080 2560x1440 3840x2160 1920x1200 1366x768; do
        w="${res%x*}"; h="${res#*x}"
        rsvg-convert -w "$((w * 2160 / h > w ? w * 2160 / h : w))" "${here}/wallpaper/fern-${name}.svg" \
            | magick - -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" -strip \
                -define png:exclude-chunks=date,time "${out}/images/${res}.png"
    done
    magick "${out}/images/1920x1080.png" -resize 400x225 -strip \
        -define png:exclude-chunks=date,time "${out}/screenshot.png"
done
echo "Rendered mode wallpapers into ${dist}"
