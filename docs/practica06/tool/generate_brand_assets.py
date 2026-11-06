"""Edit the colors/geometry here, then run: python tool/generate_brand_assets.py"""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
BACKGROUND = '#173B65'
ACCENT = '#55DDD0'
INK = '#FFFFFF'
SIZE = 1024

def logo(transparent=False):
    image = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0) if transparent else BACKGROUND)
    draw = ImageDraw.Draw(image)
    draw.arc((245, 245, 779, 779), 48, 312, fill=INK, width=92)
    draw.polygon([(479, 376), (479, 648), (690, 512)], fill=ACCENT)
    return image

def save(image, path, size):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    image.resize((size, size), Image.Resampling.LANCZOS).save(path)

solid, foreground = logo(), logo(True)
save(solid, 'assets/branding/cinemapedia.png', 1024)
res = 'android/app/src/main/res'
(ROOT / res / 'values/brand_colors.xml').write_text(
    f'<resources>\n    <color name="cinemapedia_background">{BACKGROUND}</color>\n</resources>\n',
    encoding='utf-8',
)
for density, size, scale in [('mdpi',48,1), ('hdpi',72,1.5), ('xhdpi',96,2), ('xxhdpi',144,3), ('xxxhdpi',192,4)]:
    save(solid, f'{res}/mipmap-{density}/ic_launcher.png', size)
    save(foreground, f'{res}/drawable-{density}/cinemapedia_foreground.png', int(108*scale))
    save(foreground, f'{res}/drawable-{density}/cinemapedia_splash.png', int(144*scale))

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <rect width="1024" height="1024" rx="220" fill="{BACKGROUND}"/>
  <path d="M659.9 347.8 A221 221 0 1 0 659.9 676.2" fill="none" stroke="{INK}" stroke-width="92"/>
  <path d="M479 376 L479 648 L690 512 Z" fill="{ACCENT}"/>
</svg>'''
(ROOT/'assets/branding/cinemapedia.svg').write_text(svg, encoding='utf-8')
print('Cinemapedia brand assets generated.')
