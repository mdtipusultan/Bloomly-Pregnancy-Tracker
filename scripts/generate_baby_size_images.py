#!/usr/bin/env python3
"""Download realistic baby-size food photos and prepare Xcode assets."""

from __future__ import annotations

import json
import time
import urllib.parse
import urllib.request
from io import BytesIO
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "BloomlyPregnancyTracker/BloomlyShared/Assets.xcassets"
ATTRIBUTION = ROOT / "BloomlyPregnancyTracker/BloomlyShared/baby_size_photo_attribution.json"
SIZE = 512
UA = "BloomlyPregnancyTracker/1.0 (baby-size-assets; educational-app)"

# Wikimedia Commons filenames (CC / public domain). Fallbacks tried in order.
PHOTO_FILES: dict[str, list[str]] = {
    "poppy_seed": ["Poppy_seeds.jpg"],
    "sesame_seed": ["Sesame-Seeds.jpg", "Sesame_seeds.jpg"],
    "lentil": ["Lentil.jpg", "Lentils.jpg"],
    "blueberry": ["Blueberries.jpg", "Blueberry.jpg"],
    "raspberry": ["Raspberries.jpg", "Rubus_idaeus_fruit.jpg"],
    "grape": ["Grapes.jpg", "Table_grapes.jpg"],
    "cherry": ["Cherries.jpg", "Cherry_fruit.jpg"],
    "strawberry": ["Strawberries.jpg", "Strawberry.jpg"],
    "fig": ["Figs.jpg", "Fig_fruit.jpg", "Ficus_carica_fruit.jpg"],
    "lime": ["Limes.jpg", "Lime_fruit.jpg", "Lime.jpg"],
    "peach": ["Peach_fruit.jpg", "Peach.jpg", "Peaches.jpg"],
    "plum": ["Plums.jpg", "Plum.jpg"],
    "lemon": ["Lemon.jpg", "Lemons.jpg"],
    "nectarine": ["Nectarine.jpg", "Nectarines.jpg"],
    "apple": ["Apple_(1).jpg", "Apple_fruit.jpg"],
    "avocado": ["Avocado_fruit.jpg", "Avocado.jpg"],
    "pear": ["Pear.jpg", "Pears.jpg"],
    "bell_pepper": ["Red_bell_pepper.jpg", "Bell_pepper.jpg"],
    "mango": ["Mango.jpg", "Mangoes.jpg"],
    "banana": ["Banana-Single.jpg", "Banana.jpg"],
    "carrot": ["Carrot.jpg", "Carrots.jpg"],
    "papaya": ["Papaya.jpg", "Papaya_fruit.jpg"],
    "grapefruit": ["Grapefruit.jpg", "Grapefruits.jpg"],
    "cantaloupe": ["Cantaloupe.jpg", "Cantaloupe_melon.jpg"],
    "cauliflower": ["Cauliflower.jpg", "Cauliflower_head.jpg"],
    "head_of_lettuce": ["Iceberg_lettuce.jpg", "Lettuce_head.jpg", "Lettuce.jpg"],
    "rutabaga": ["Rutabaga.jpg", "Swede.jpg"],
    "eggplant": ["Eggplant.jpg", "Aubergine.jpg"],
    "butternut_squash": ["Butternut_squash.jpg", "Butternut_Squash.jpg"],
    "cabbage": ["Cabbage.jpg", "Green_cabbage.jpg"],
    "coconut": ["Coconut.jpg", "Coconuts.jpg"],
    "jicama": ["Jicama.jpg", "Pachyrhizus_erosus_root.jpg"],
    "pineapple": ["Pineapple.jpg", "Pineapples.jpg"],
    "honeydew_melon": ["Honeydew.jpg", "Honeydew_melon.jpg"],
    "romaine_lettuce": ["Romaine_lettuce.jpg", "Romaine.jpg"],
    "bunch_of_swiss_chard": ["Swiss_chard.jpg", "Chard.jpg"],
    "mini_watermelon": ["AGROSEX_DuendeRayada.jpg", "Melon_Sugar_Baby_Matisse-9946.jpg"],
    "pumpkin": ["Pumpkin.jpg", "Pumpkins.jpg"],
    "small_pumpkin": ["Pumpkin.jpg", "Small_pumpkin.jpg"],
    "watermelon": ["Watermelon.jpg", "Watermelon_fruit.jpg"],
    "full_term_baby": ["Sleeping_newborn.jpg", "Newborn_infant.jpg"],
}


def download(filename: str, width: int = 900) -> Image.Image:
    url = (
        "https://commons.wikimedia.org/wiki/Special:FilePath/"
        f"{urllib.parse.quote(filename)}?width={width}"
    )
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as response:
        data = response.read()
    return Image.open(BytesIO(data)).convert("RGBA")


def background_color(img: Image.Image) -> tuple[int, int, int]:
    w, h = img.size
    samples = [
        img.getpixel((2, 2))[:3],
        img.getpixel((w - 3, 2))[:3],
        img.getpixel((2, h - 3))[:3],
        img.getpixel((w - 3, h - 3))[:3],
    ]
    return (
        sum(s[0] for s in samples) // 4,
        sum(s[1] for s in samples) // 4,
        sum(s[2] for s in samples) // 4,
    )


def remove_background(img: Image.Image, tolerance: int = 38) -> Image.Image:
    bg = background_color(img)
    px = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if abs(r - bg[0]) <= tolerance and abs(g - bg[1]) <= tolerance and abs(b - bg[2]) <= tolerance:
                px[x, y] = (r, g, b, 0)
    return img


def trim_transparent(img: Image.Image) -> Image.Image:
    bbox = img.getbbox()
    return img.crop(bbox) if bbox else img


def fit_canvas(img: Image.Image, size: int = SIZE, padding: float = 0.08) -> Image.Image:
    img = trim_transparent(img)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    max_side = int(size * (1 - padding * 2))
    img.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
    x = (size - img.width) // 2
    y = (size - img.height) // 2
    canvas.paste(img, (x, y), img)
    return canvas


def save_asset(name: str, img: Image.Image) -> None:
    folder = ASSETS / f"BabySize_{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    img.save(folder / f"{name}.png", "PNG")
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal", "scale": "1x"}],
        "info": {"author": "xcode", "version": 1},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def main() -> None:
    attribution: dict[str, dict[str, str]] = {}
    failures: list[str] = []

    for name, candidates in PHOTO_FILES.items():
        saved = False
        for filename in candidates:
            try:
                img = download(filename)
                processed = fit_canvas(remove_background(img))
                save_asset(name, processed)
                attribution[name] = {
                    "source": "Wikimedia Commons",
                    "file": filename,
                    "url": f"https://commons.wikimedia.org/wiki/File:{urllib.parse.quote(filename.replace(' ', '_'))}",
                    "license": "See file page on Wikimedia Commons",
                }
                print(f"OK  BabySize_{name} <- {filename}")
                saved = True
                break
            except Exception as exc:  # noqa: BLE001
                print(f"TRY BabySize_{name} {filename}: {exc}")
            time.sleep(2.0)
        if not saved:
            failures.append(name)

    ATTRIBUTION.write_text(json.dumps(attribution, indent=2) + "\n")
    print(f"\nSaved {len(attribution)} assets.")
    if failures:
        raise SystemExit(f"Failed items: {', '.join(failures)}")


if __name__ == "__main__":
    main()
