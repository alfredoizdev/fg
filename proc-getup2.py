#!/usr/bin/env python3
"""
proc-getup2.py — Procesa el clip nuevo de LEVANTARSE de DAM (sheets/get-up-2/, 10
frames crudos 1448x1086 con fondo verde) al lienzo global de DAM.

- Croma verde -> alfa (con despill de borde).
- Escala UNIFORME calibrada para que el frame DE PIE (el ultimo) iguale la altura
  cuerpo del get_up actual (~603px) -> sin "pop" al volver al idle.
- Pies clavados a FEET_Y=1140; ancla horizontal por centroide-x a ANCHOR_X.
  (get_up cambia de postura tendido->de pie; NO se normaliza area, se conserva la
   masa natural, igual que la caida arreglada. Ver [[ai-clip-scale-jitter]].)

Salida: imagen-action/dam/get_up/dam-get_up-N.png  (o --out DIR para revisar).
"""
import argparse, os, glob, re
import numpy as np
from PIL import Image

SRC = "imagen-action/dam/sheets/get-up-2"
CANVAS_W, CANVAS_H = 1300, 1280
FEET_Y = 1140
ANCHOR_X = 650
TARGET_STAND_H = 603      # altura cuerpo de pie objetivo (= get_up actual f12)

def chroma(pil):
    """quita fondo verde; devuelve rgba (uint8) y mascara bool del personaje."""
    a = np.array(pil.convert("RGB")).astype(np.int16)
    R, G, B = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    green = (G > 110) & (G - R > 45) & (G - B > 45)
    mask = ~green
    rgba = np.dstack([a.astype(np.uint8), np.where(mask, 255, 0).astype(np.uint8)])
    # despill: en pixeles del personaje con verde dominante, baja G al max(R,B)
    spill = mask & (G > R) & (G > B) & (G - np.maximum(R, B) > 20)
    rgba[spill, 1] = np.maximum(R, B)[spill].astype(np.uint8)
    return rgba, mask

def body_metrics(mask):
    """feetY (borde inferior), foot_cx (centro-x banda inferior 40px del cuerpo),
       height (corona->pies), centroid_x."""
    ys, xs = np.where(mask)
    feet = ys.max(); top = ys.min()
    band = xs[ys >= feet - 40]
    return feet, int(round(band.mean())), int(feet - top), int(round(xs.mean()))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="", help="dir de revision (no pisa el real)")
    args = ap.parse_args()
    files = sorted(glob.glob(f"{SRC}/*.png"),
                   key=lambda p: int(re.search(r'/(\d+)\.png$', p).group(1)))
    # calibrar escala con el ULTIMO frame (de pie)
    _, m_last = chroma(Image.open(files[-1]))
    _, _, h_last, _ = body_metrics(m_last)
    scale = TARGET_STAND_H / float(h_last)
    print(f"frames={len(files)}  h_de_pie_crudo={h_last}px  escala={scale:.4f} -> {TARGET_STAND_H}px")

    dest = os.path.join(args.out, "get_up") if args.out else "imagen-action/dam/get_up"
    os.makedirs(dest, exist_ok=True)
    for p in files:
        n = int(re.search(r'/(\d+)\.png$', p).group(1))
        rgba, mask = chroma(Image.open(p))
        img = Image.fromarray(rgba, "RGBA")
        nw, nh = max(1, round(img.width * scale)), max(1, round(img.height * scale))
        img = img.resize((nw, nh), Image.LANCZOS)
        m2 = np.array(img)[:, :, 3] > 40
        feet, fcx, _, cen = body_metrics(m2)
        canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        canvas.alpha_composite(img, (ANCHOR_X - cen, FEET_Y - feet))
        canvas.save(os.path.join(dest, f"dam-get_up-{n}.png"))
    print(f"  -> {dest} ({len(files)} frames)")

if __name__ == "__main__":
    main()
