#!/usr/bin/env bash
# Regenerate every FernOS branding raster from the vector sources.
# Requires: python3, rsvg-convert (librsvg), magick (imagemagick).
# Output is committed in branding/dist so ISO builds need none of these tools.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist="${here}/dist"
rm -rf -- "${dist}"
mkdir -p "${dist}"/{icons,wallpaper/contents/images,wallpaper/contents/images_dark,boot}

python3 "${here}/tools/make_logo.py" "${here}/logo"
python3 "${here}/tools/make_wallpaper.py" "${here}/wallpaper"

# Icons (hicolor theme sizes).
cp "${here}/logo/fernos.svg" "${dist}/icons/fernos.svg"
cp "${here}/logo/fernos-badge.svg" "${dist}/icons/fernos-badge.svg"
for s in 16 22 24 32 48 64 128 256; do
    rsvg-convert -w "$s" -h "$s" "${here}/logo/fernos-badge.svg" -o "${dist}/icons/fernos-${s}.png"
done

# Wallpaper package (KDE "Fern"), light + dark variants.
for res in 1920x1080 2560x1440 3840x2160 1920x1200 1366x768; do
    w="${res%x*}"; h="${res#*x}"
    for v in light dark; do
        case "$v" in light) d=images ;; dark) d=images_dark ;; esac
        # Scale to cover, then centre-crop to the exact resolution.
        rsvg-convert -w "$((w * 2160 / h > w ? w * 2160 / h : w))" "${here}/wallpaper/fern-${v}.svg" \
            | magick - -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" -strip \
                -define png:exclude-chunks=date,time "${dist}/wallpaper/contents/images/../${d}/${res}.png"
    done
done
magick "${dist}/wallpaper/contents/images/1920x1080.png" -resize 400x225 -strip \
    -define png:exclude-chunks=date,time "${dist}/wallpaper/contents/screenshot.png"

# BIOS boot splash (syslinux vesamenu: 640x480).
rsvg-convert -w 853 "${here}/wallpaper/fern-dark.svg" \
    | magick - -gravity center -extent 640x480 -strip -define png:exclude-chunks=date,time \
        "${dist}/boot/splash.png"
echo "Rendered assets into ${dist}"
