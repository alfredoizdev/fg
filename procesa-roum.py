#!/usr/bin/env python3
"""procesa-roum.py — frames de VIDEO (fondo verde) -> frames al lienzo global de ROUM.
Calca la lógica de procesar-sprites.py (chroma + escala por cuerpo + lienzo 1300x1280,
pies@1140) pero por-frame desde una carpeta de PNGs (extraídos de un mp4 con ffmpeg).
La escala se calcula del clip 'pose' (frame más alto) y se REUSA en los demás.

Uso:  python3 procesa-roum.py <carpeta_frames> --action pose|walk [--target 700]
"""
import argparse, os, glob
import numpy as np
from PIL import Image

CANVAS_W, CANVAS_H = 1300, 1280
FEET_Y   = 1140
ANCHOR_X = 650
CHAR = "roum"
T_KEEP, T_CUT = 45, 130

def key_green(path):
    img = Image.open(path).convert("RGBA")
    a = np.asarray(img).astype(np.int32)
    R, G, B = a[..., 0], a[..., 1], a[..., 2]
    greenness = G - np.maximum(R, B)
    alpha = np.clip((T_CUT - greenness) / float(T_CUT - T_KEEP), 0.0, 1.0)
    alpha = (alpha * 255).astype(np.uint8)
    spill = greenness > 0
    G2 = np.where(spill, np.maximum(R, B), G)
    return np.dstack([R, G2, B, alpha]).astype(np.uint8)

def tight(mask):
    ys, xs = np.where(mask)
    if len(xs) == 0: return None
    return xs.min(), ys.min(), xs.max()+1, ys.max()+1

def feet_cx(mask):
    h, w = mask.shape
    band = mask[int(h*0.75):, :]
    xs = np.where(band.any(axis=0))[0]
    return int(xs.mean()) if len(xs) else w//2

def crop_frame(path):
    rgba = key_green(path)
    mask = rgba[..., 3] > 40
    bb = tight(mask)
    if bb is None: return None
    l, t, r, b = bb
    return rgba[t:b, l:r]

def scale_path(): return os.path.join("imagen-action", CHAR, "scale.txt")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("frames_dir")
    ap.add_argument("--action", required=True)
    ap.add_argument("--target", type=int, default=700)  # alto de cuerpo objetivo (ROUM = tanque, el más alto)
    a = ap.parse_args()

    paths = sorted(glob.glob(os.path.join(a.frames_dir, "*.png")))
    crops = [c for c in (crop_frame(p) for p in paths) if c is not None]
    if not crops:
        print("  sin frames válidos"); return

    sp = scale_path()
    if a.action == "pose" or not os.path.exists(sp):
        stand = max((c[..., 3] > 40).any(axis=1).sum() for c in crops)  # frame más alto (de pie)
        scale = a.target / float(stand)
        os.makedirs(os.path.dirname(sp), exist_ok=True)
        with open(sp, "w") as f: f.write(f"{scale:.6f}\n")
        print(f"  escala = {scale:.4f} (cuerpo {stand}px -> {a.target}px) [guardada]")
    else:
        scale = float(open(sp).read().strip())
        print(f"  escala = {scale:.4f} [de {sp}]")

    outdir = os.path.join("imagen-action", CHAR, a.action)
    os.makedirs(outdir, exist_ok=True)
    for old in glob.glob(os.path.join(outdir, "*.png")): os.remove(old)
    for i, c in enumerate(crops, 1):
        img = Image.fromarray(c)
        nw, nh = max(1, round(img.width*scale)), max(1, round(img.height*scale))
        img = img.resize((nw, nh), Image.LANCZOS)
        m = np.asarray(img)[..., 3] > 40
        fx = feet_cx(m)
        canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0,0,0,0))
        canvas.alpha_composite(img, (ANCHOR_X - fx, FEET_Y - nh))
        canvas.save(os.path.join(outdir, f"{CHAR}-{a.action}-{i}.png"))
    print(f"  OK {len(crops)} frames -> {outdir}/  ({CANVAS_W}x{CANVAS_H})")

if __name__ == "__main__":
    main()
