#!/usr/bin/env python3
"""E20-T01: eski Android (< 8.0) uchun ilova belgisi PNG'lari — vektor
(`ic_launcher_foreground.xml`) bilan bir xil geometriya, flavor rangida.

    python3 tool/render_launcher_icons.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent / "android/app/src"
DENSITIES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
FLAVORS = {"main": "#4F46E5", "dev": "#B45309", "staging": "#0F766E"}
# Adaptiv belgining 108 birlik maydonidan eski belgida ko'rinadigan qismi.
VIEW = (18, 18, 90, 90)
SUPERSAMPLE = 4


def render(size: int, color: str) -> Image.Image:
    big = size * SUPERSAMPLE
    image = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.ellipse((0, 0, big - 1, big - 1), fill=color)

    scale = big / (VIEW[2] - VIEW[0])

    def box(x0, y0, x1, y1):
        return tuple(round((v - VIEW[i % 2]) * scale) for i, v in enumerate((x0, y0, x1, y1)))

    white = (255, 255, 255, 255)
    card = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    ImageDraw.Draw(card).rounded_rectangle(box(35, 30, 69, 40), radius=round(3 * scale), fill=white)
    card.putalpha(card.getchannel("A").point(lambda a: int(a * 0.7)))
    image.alpha_composite(card)
    draw.rounded_rectangle(box(30, 38, 78, 76), radius=round(6 * scale), fill=white)
    draw.ellipse(box(64, 53, 72, 61), fill=color)
    return image.resize((size, size), Image.LANCZOS)


def main() -> None:
    for flavor, color in FLAVORS.items():
        for density, size in DENSITIES.items():
            target = ROOT / flavor / "res" / f"mipmap-{density}" / "ic_launcher.png"
            target.parent.mkdir(parents=True, exist_ok=True)
            render(size, color).save(target, optimize=True)
            print(target.relative_to(ROOT.parent.parent.parent))


if __name__ == "__main__":
    main()
