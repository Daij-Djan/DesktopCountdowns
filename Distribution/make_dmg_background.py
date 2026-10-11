#!/usr/bin/env python3
"""Renders the DMG window background (1x + 2x) in the website's sunset palette.

usage: make_dmg_background.py <out_dir>
writes background.png (640x400) and background@2x.png (1280x800)
"""
import math
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

WIDTH, HEIGHT = 640, 400
# keep in sync with make-dmg.sh icon positions
# content stays above y~340: Finder's optional tab bar can hide the bottom of the window
APP_POS = (170, 180)
APPS_POS = (470, 180)

# colors from dominik.pich.info/DesktopCountdowns
SKY_STOPS = [
  (0.00, (0x2B, 0x1D, 0x3A)),
  (0.30, (0x5A, 0x2C, 0x4C)),
  (0.60, (0xA3, 0x48, 0x5A)),
  (1.00, (0xF0, 0x95, 0x5A)),
]
INK = (0xFF, 0xF8, 0xF0)
INK_DIM = (0xF3, 0xDC, 0xCB)
FONT = "/System/Library/Fonts/SFNS.ttf"


def lerp(a, b, t):
  return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def sky_color(t):
  for (t0, c0), (t1, c1) in zip(SKY_STOPS, SKY_STOPS[1:]):
    if t <= t1:
      return lerp(c0, c1, (t - t0) / (t1 - t0))
  return SKY_STOPS[-1][1]


def font(size, weight):
  f = ImageFont.truetype(FONT, size)
  try:
    f.set_variation_by_name(weight)
  except (OSError, ValueError):
    pass
  return f


def render(scale):
  w, h = WIDTH * scale, HEIGHT * scale
  s = lambda v: round(v * scale)

  img = Image.new("RGB", (w, h))
  draw = ImageDraw.Draw(img)
  for y in range(h):
    draw.line([(0, y), (w, y)], fill=sky_color(y / (h - 1)))

  # warm glow top right, like the site's radial-gradient
  glow = Image.new("L", (w, h), 0)
  ImageDraw.Draw(glow).ellipse([s(330), s(-170), s(690), s(110)], fill=95)
  glow = glow.filter(ImageFilter.GaussianBlur(s(70)))
  img = Image.composite(Image.new("RGB", (w, h), (255, 190, 120)), img, glow)

  overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
  od = ImageDraw.Draw(overlay)

  # soft glass wells behind the two icons
  for cx, cy in (APP_POS, APPS_POS):
    od.rounded_rectangle(
      [s(cx - 82), s(cy - 82), s(cx + 82), s(cy + 100)],
      radius=s(22), fill=(255, 255, 255, 26), outline=(255, 255, 255, 46), width=max(1, s(1)),
    )

  # title
  title = font(s(26), "Bold")
  od.text((w / 2, s(36)), "DesktopCountdowns", font=title, fill=INK, anchor="mm")
  sub = font(s(13), "Regular")
  od.text((w / 2, s(62)), "your reminders, counting down on your desktop", font=sub, fill=INK_DIM + (230,), anchor="mm")

  # curved dashed arrow from app to Applications
  x0, x1, y = APP_POS[0] + 96, APPS_POS[0] - 96, APP_POS[1] - 4
  pts = []
  steps = 60
  for i in range(steps + 1):
    t = i / steps
    pts.append((x0 + (x1 - x0) * t, y - 26 * math.sin(math.pi * t)))
  arrow_color = INK + (235,)
  for i in range(0, steps - 4, 6):
    seg = [(s(px), s(py)) for px, py in pts[i:i + 4]]
    od.line(seg, fill=arrow_color, width=s(4), joint="curve")
  # arrow head along the final tangent
  (ax, ay), (bx, by) = pts[-3], pts[-1]
  ang = math.atan2(by - ay, bx - ax)
  head = 14
  tip = (bx + 4 * math.cos(ang), by + 4 * math.sin(ang))
  left = (tip[0] - head * math.cos(ang - 0.5), tip[1] - head * math.sin(ang - 0.5))
  right = (tip[0] - head * math.cos(ang + 0.5), tip[1] - head * math.sin(ang + 0.5))
  od.polygon([(s(p[0]), s(p[1])) for p in (tip, left, right)], fill=arrow_color)

  # drag & drop hint
  hint = font(s(15), "Semibold")
  od.text((w / 2, s(312)), "Drag DesktopCountdowns onto Applications to install", font=hint, fill=INK, anchor="mm")
  small = font(s(11), "Regular")
  od.text((w / 2, s(333)), "then open it from your Applications folder", font=small, fill=INK + (215,), anchor="mm")

  img = Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")
  return img


def main():
  out_dir = sys.argv[1] if len(sys.argv) > 1 else "."
  render(1).save(f"{out_dir}/background.png", dpi=(72, 72))
  render(2).save(f"{out_dir}/background@2x.png", dpi=(144, 144))


if __name__ == "__main__":
  main()
