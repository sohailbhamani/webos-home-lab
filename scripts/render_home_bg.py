import sys
from PIL import Image, ImageEnhance, ImageDraw, ImageFilter
src, out = sys.argv[1], sys.argv[2]
im = Image.open(src).convert("RGB")                      # 3840x1920 ESO panorama
im = im.rotate(-14, resample=Image.BICUBIC, expand=False, center=(1920, 960))
cw, ch = 2304, 1296                                     # 16:9 window around the core
left, top = 1920 - cw // 2, 960 - int(ch * 0.38)        # core band in the upper half
im = im.crop((left, top, left + cw, top + ch))
im = ImageEnhance.Brightness(im).enhance(1.55)
im = ImageEnhance.Contrast(im).enhance(1.15)
im = ImageEnhance.Color(im).enhance(1.25)
# Darken the lower half so app tiles and text stay readable.
mask = Image.new("L", (cw, ch))
d = ImageDraw.Draw(mask)
for y in range(ch):
    t = max(0.0, (y / ch - 0.45) / 0.55)
    d.line([(0, y), (cw, y)], fill=int(255 * min(1.0, t) * 0.62))
im = Image.composite(Image.new("RGB", (cw, ch), (0, 0, 0)), im, mask)
for (w, h, q) in [(1920, 1080, 86)]:
    r = im.resize((w, h), Image.LANCZOS)
    p = out.replace("SIZE", f"{w}")
    r.save(p, "JPEG", quality=q, optimize=True, progressive=False)
    import os; print(p, os.path.getsize(p))
r = im.resize((1280, 720), Image.LANCZOS); r.save(out.replace("SIZE", "preview"), "JPEG", quality=80)
