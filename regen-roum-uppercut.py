#!/usr/bin/env python3
"""regen-roum-uppercut.py — reconstruye el UPPERCUT de ROUM desde sheets/uppercut/ (7 frames verdes).

Problema que arregla: el clip IA dibuja a ROUM a TAMAÑOS distintos frame a frame (jitter de
escala ~±12%). El pipeline normal (escala fija + clavar pies) convierte ese pulso en un
"saltito/bobbing" feo: un frame se encoge, el siguiente crece. Como ROUM hace el uppercut
DESDE EL SUELO (pies plantados) con anticipación (de pie -> cuclilla -> puño arriba), el fix es:

  1) Normalizar la escala POR FRAME por AREA de silueta (la masa del personaje es constante) ->
     mata el pulso de tamaño y deja el movimiento de pose (cuclilla/subida) intacto.
  2) Clavar los PIES (borde inferior + centro-x del pie) a FEET_Y  -> queda pegado al suelo.
  3) Calibrar la base para que los frames DE PIE igualen la altura de pie real de ROUM (~710px,
     medida de pose/walk), para no meter un "pop" de tamaño al entrar/salir del golpe.
  4) Escribir 13 frames en palíndromo (ida-y-vuelta): 1..7, 6..1  (hit_frame=5 sigue válido).
"""
import numpy as np
from PIL import Image
import glob, os

SRC = "imagen-action/roum/sheets/uppercut"
OUT = "imagen-action/roum/uppercut"
T_KEEP, T_CUT = 45, 130
CANVAS_W, CANVAS_H = 1300, 1280
FEET_Y = 1140
ANCHOR_X = 650
TARGET_STAND = 710.0           # altura de cuerpo de ROUM de pie (de pose~680 / walk~722)
ORDER = [0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0]   # palíndromo 13f desde 7 fuentes

def key_green(path):
    a = np.asarray(Image.open(path).convert("RGBA")).astype(np.int32)
    R, G, B = a[..., 0], a[..., 1], a[..., 2]
    greenness = G - np.maximum(R, B)
    alpha = np.clip((T_CUT - greenness) / float(T_CUT - T_KEEP), 0.0, 1.0) * 255
    spill = greenness > 0
    G2 = np.where(spill, np.maximum(R, B), G)
    return np.dstack([R, G2, B, alpha]).astype(np.uint8)

def foot_cx(mask):
    ys, xs = np.where(mask)
    bot = ys.max()
    band = mask[bot - 90:bot + 1, :]
    fxs = np.where(band.any(axis=0))[0]
    return int((fxs.min() + fxs.max()) / 2) if len(fxs) else mask.shape[1] // 2

def main():
    paths = sorted(glob.glob(os.path.join(SRC, "*.png")),
                   key=lambda p: int(os.path.basename(p).split('.')[0]))
    crops, areas, bodyHs = [], [], []
    for p in paths:
        rgba = key_green(p)
        m = rgba[..., 3] > 40
        ys, xs = np.where(m)
        t, b, l, r = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
        crops.append(rgba[t:b, l:r]); areas.append(int(m.sum())); bodyHs.append(b - t)

    ref = float(np.median(areas))
    corr = [(ref / a) ** 0.5 for a in areas]                       # escala por-frame (área)
    upright_units = np.mean([bodyHs[0] * corr[0], bodyHs[1] * corr[1]])  # frames 1-2 = de pie
    base = TARGET_STAND / upright_units
    print(f"  area-ref={ref:.0f}  base={base:.4f}  corr={[round(c,3) for c in corr]}")

    canv = []
    for crop, c in zip(crops, corr):
        img = Image.fromarray(crop)
        s = base * c
        nw, nh = max(1, round(img.width * s)), max(1, round(img.height * s))
        img = img.resize((nw, nh), Image.LANCZOS)
        mm = np.asarray(img)[..., 3] > 40
        fx = foot_cx(mm)
        cv = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        cv.alpha_composite(img, (ANCHOR_X - fx, FEET_Y - nh))
        canv.append(cv)

    for old in glob.glob(os.path.join(OUT, "*.png")):
        os.remove(old)
    for i, oi in enumerate(ORDER, 1):
        canv[oi].save(os.path.join(OUT, f"roum-uppercut-{i}.png"))
    print(f"  OK {len(ORDER)} frames -> {OUT}/")

if __name__ == "__main__":
    main()
