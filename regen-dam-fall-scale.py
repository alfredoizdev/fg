#!/usr/bin/env python3
"""
regen-dam-fall-scale.py — Arregla la ESCALA de la caída de DAM (hit_fly / hit_down).

Problema: los frames del clip nuevo se normalizaron por AREA de silueta constante
(~150k) — truco copiado del uppercut de ROUM. Sirve cuando la POSTURA no cambia
(silueta de masa constante), pero la caída va de PIE -> TENDIDO: al acostarse la
silueta se ACHICA natural (escorzo). Forzar area constante DUPLICA el tamaño del
cuerpo tendido -> "se ve mas grande al caer al piso".

Fix: reescalar cada frame para que su AREA siga la progresion natural de la caida,
en funcion de la POSTURA (aspecto = ancho/alto de la silueta, invariante a escala):
  - de pie (aspecto ~1): NO se toca (el tumbo aereo ya estaba bien).
  - tendido plano (aspecto alto): se achica al tamaño escorzado real.
Regla segura: NUNCA agranda (solo corrige lo inflado). Pies clavados a FEET_Y.

La tabla aspecto->area sale de la version committed BUENA de dam/hit_down (la que
se veia bien antes del cambio), capturada aqui como constante para ser reproducible.

Uso:
  python3 regen-dam-fall-scale.py            # aplica in-place a hit_fly y hit_down
  python3 regen-dam-fall-scale.py --out DIR  # escribe a DIR/<anim>/ para revisar
"""
import argparse, os, glob, re
import numpy as np
from PIL import Image

FEET_Y  = 1140
ANCHOR_X = 650
CANVAS_W, CANVAS_H = 1300, 1280

# aspecto (ancho/alto) -> area objetivo, de dam/hit_down committed (curva buena)
ASP = [1.504, 1.707, 1.875, 2.397, 3.285, 3.953, 4.287, 4.644, 5.162, 5.682, 6.478, 7.0]
ARE = [161362, 143574, 112503, 106813, 95758, 91492, 85762, 81741, 77804, 75966, 73714, 73714]
FLOOR_AREA = 88000     # tendido no baja de aquí: el escorzo puro se veía "un poquito chico" (pedido)

def target_area(aspect):
    a = float(np.clip(aspect, ASP[0], ASP[-1]))
    return max(float(np.interp(a, ASP, ARE)), FLOOR_AREA)

def measure(rgba):
    m = rgba[:, :, 3] > 40
    ys, xs = np.where(m)
    if len(xs) == 0:
        return 0, 0, 0
    area = int(m.sum())
    bw = int(xs.max() - xs.min())
    bh = int(ys.max() - ys.min())
    return area, bw, bh

def smooth(vals, k=5):
    if len(vals) < 2:
        return list(vals)
    v = np.asarray(vals, float)
    pad = np.pad(v, (k // 2, k // 2), mode='edge')
    return list(np.convolve(pad, np.ones(k) / k, 'valid'))

def process_anim(anim, out_dir):
    files = sorted(glob.glob(f"imagen-action/dam/{anim}/dam-{anim}-*.png"),
                   key=lambda p: int(re.search(r'-(\d+)\.png$', p).group(1)))
    dest = os.path.join(out_dir, anim) if out_dir else f"imagen-action/dam/{anim}"
    os.makedirs(dest, exist_ok=True)
    # pasada 1: medir area/aspecto y target crudo (por postura) de cada frame
    areas, raw_targets = [], []
    for p in files:
        area, bw, bh = measure(np.array(Image.open(p).convert("RGBA")))
        areas.append(area)
        raw_targets.append(target_area(bw / max(1, bh)) if area else 0.0)
    # suavizado temporal del target -> sin "pops" en poses diagonales de transicion
    targets = smooth(raw_targets, k=5)
    # pasada 2: aplicar (nunca agranda; escala alrededor de (ANCHOR_X, FEET_Y))
    changed = 0
    for p, area, target in zip(files, areas, targets):
        n = int(re.search(r'-(\d+)\.png$', p).group(1))
        dst_path = os.path.join(dest, f"dam-{anim}-{n}.png")
        rgba = np.array(Image.open(p).convert("RGBA"))
        s = (min(target, area) / area) ** 0.5 if area else 1.0
        if s > 0.998:                               # de pie / aereo: NO se toca
            if out_dir:
                Image.fromarray(rgba).save(dst_path)
            continue
        img = Image.fromarray(rgba).resize(
            (max(1, round(CANVAS_W * s)), max(1, round(CANVAS_H * s))), Image.LANCZOS)
        canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        canvas.alpha_composite(img, (round(ANCHOR_X * (1 - s)), round(FEET_Y * (1 - s))))
        canvas.save(dst_path)
        changed += 1
    print(f"  {anim}: {len(files)} frames, {changed} reescalados -> {dest}")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="", help="directorio de salida (revisar sin pisar)")
    args = ap.parse_args()
    for anim in ("hit_fly", "hit_down"):
        process_anim(anim, args.out)

if __name__ == "__main__":
    main()
