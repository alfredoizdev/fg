#!/usr/bin/env python3
"""regen-roum-clip.py — procesa un clip de ROUM (fondo verde) a frames estabilizados.
Chroma + normalizar escala POR FRAME por ÁREA de silueta (mata el jitter de tamaño del clip IA).
Dos modos de anclaje:
  feet (default) — clava el pixel más bajo a FEET_Y (poses DE PIE: take_hit, take_hit_low).
  body           — clava el fondo del COMPONENTE CONEXO MAYOR (torso) a FEET_Y, ignorando vendas/
                   brazos colgantes que engañan al pixel más bajo (poses TENDIDAS: hit_fly, ko).
                   Ver [[ko-frame-anchoring]].
Calibra la base para que el frame de referencia iguale una altura objetivo.

Uso:  python3 regen-roum-clip.py <frames> <accion> [target=700] [ref_idx=0] [feet|body]
"""
import sys, glob, os
import numpy as np
from PIL import Image
from scipy import ndimage

T_KEEP, T_CUT = 45, 130
CANVAS_W, CANVAS_H = 1300, 1280
FEET_Y = 1140
ANCHOR_X = 650
CHAR = "roum"   # override con arg 6

def key_green(path):
    a = np.asarray(Image.open(path).convert("RGBA")).astype(np.int32)
    R, G, B = a[..., 0], a[..., 1], a[..., 2]
    greenness = G - np.maximum(R, B)
    alpha = np.clip((T_CUT - greenness) / float(T_CUT - T_KEEP), 0.0, 1.0) * 255
    spill = greenness > 0
    G2 = np.where(spill, np.maximum(R, B), G)
    return np.dstack([R, G2, B, alpha]).astype(np.uint8)

def feet_anchor(mask):
    """pixel más bajo + centro-x de la banda inferior (poses de pie)."""
    ys, xs = np.where(mask)
    bot = ys.max()
    band = mask[bot - 90:bot + 1, :]
    fxs = np.where(band.any(axis=0))[0]
    cx = int((fxs.min() + fxs.max()) / 2) if len(fxs) else mask.shape[1] // 2
    return cx, bot

def body_anchor(mask):
    """fondo + centro del COMPONENTE CONEXO MAYOR (torso); ignora apéndices finos colgantes."""
    lab, n = ndimage.label(mask)
    if n == 0:
        return feet_anchor(mask)
    sizes = ndimage.sum(np.ones_like(lab), lab, range(1, n + 1))
    big = int(np.argmax(sizes)) + 1
    ys, xs = np.where(lab == big)
    return int(xs.mean()), int(ys.max())

def main():
    src_dir, action = sys.argv[1], sys.argv[2]
    target = float(sys.argv[3]) if len(sys.argv) > 3 else 700.0
    ref = int(sys.argv[4]) if len(sys.argv) > 4 else 0
    mode = sys.argv[5] if len(sys.argv) > 5 else "feet"
    global CHAR
    if len(sys.argv) > 6: CHAR = sys.argv[6]
    anchor = body_anchor if mode == "body" else feet_anchor
    paths = sorted(glob.glob(os.path.join(src_dir, "*.png")))
    crops, areas, bodyHs = [], [], []
    for p in paths:
        rgba = key_green(p)
        m = rgba[..., 3] > 40
        ys, xs = np.where(m)
        if len(ys) == 0:
            crops.append(None); areas.append(1); bodyHs.append(1); continue
        t, b, l, r = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
        crops.append(rgba[t:b, l:r]); areas.append(int(m.sum())); bodyHs.append(b - t)

    good = [a for a in areas if a > 1]
    ref_area = float(np.median(good))
    corr = [(ref_area / a) ** 0.5 for a in areas]
    base = target / (bodyHs[ref] * corr[ref])
    print(f"  {action} [{mode}]: {len(paths)}f  area-ref={ref_area:.0f}  base={base:.4f}")

    outdir = os.path.join("imagen-action", CHAR, action)
    os.makedirs(outdir, exist_ok=True)
    for old in glob.glob(os.path.join(outdir, "*.png")):
        os.remove(old)
    for i, (crop, c) in enumerate(zip(crops, corr), 1):
        cv = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        if crop is not None:
            img = Image.fromarray(crop)
            s = base * c
            nw, nh = max(1, round(img.width * s)), max(1, round(img.height * s))
            img = img.resize((nw, nh), Image.LANCZOS)
            mm = np.asarray(img)[..., 3] > 40
            ax, ay = anchor(mm)                       # punto de anclaje EN la imagen escalada
            cv.alpha_composite(img, (ANCHOR_X - ax, FEET_Y - ay))
        cv.save(os.path.join(outdir, f"{CHAR}-{action}-{i}.png"))
    print(f"  OK -> {outdir}/")

if __name__ == "__main__":
    main()
