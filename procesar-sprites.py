#!/usr/bin/env python3
"""
procesar-sprites.py — Procesa una HOJA de sprites (fondo verde #00FF00) y saca
los frames individuales con transparencia, TODOS al mismo LIENZO GLOBAL del
personaje (mismos pies en la misma línea, mismo tamaño), igual que DAM.

Modelo (calcado de DAM):
  - Lienzo global: 1300x1280
  - Línea de pies: y = 1140  (el borde inferior del personaje cae ahí)
  - Cuerpo de pie objetivo: ~700 px  (se escala cada personaje para igualarlo)
  - Ancla horizontal: centroide de los pies -> x = 650 (queda centrada)

Flujo:
  1) La PRIMERA hoja debe ser 'pose' (de pie): calcula el factor de escala del
     personaje (700 / alto_de_pie) y lo guarda en imagen-action/<char>/scale.txt
  2) Las demás hojas reusan ese factor. Así TODAS las acciones quedan a la misma
     escala y con los pies alineados -> sin saltos al cambiar de animación.

Uso:
  python3 procesar-sprites.py <hoja.png> --char favi --action pose  --rows 2 --cols 2
  python3 procesar-sprites.py <hoja.png> --char favi --action walk  --rows 2 --cols 4
  # acciones aéreas (sin pies en el piso): centra en vertical
  python3 procesar-sprites.py <hoja.png> --char favi --action wall-bounce --airborne
"""
import argparse, os, sys
import numpy as np
from PIL import Image

# ---- Lienzo global (igual que DAM) ----
CANVAS_W, CANVAS_H = 1300, 1280
FEET_Y   = 1140          # línea de piso
ANCHOR_X = 650           # centro horizontal (centroide de pies -> aquí)
TARGET_BODY = 645        # alto del personaje de pie (Favi ~92% de DAM=700)

# ---- Chroma key ----
T_KEEP = 45     # greenness <= esto  -> se conserva
T_CUT  = 130    # greenness >= esto  -> fondo; en medio se difumina el borde

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

def runs(on):
    res, i, n = [], 0, len(on)
    while i < n:
        if on[i]:
            j = i
            while j < n and on[j]:
                j += 1
            res.append((i, j)); i = j
        else:
            i += 1
    return res

def merge_short_gaps(spans, gap):
    if not spans: return spans
    out = [list(spans[0])]
    for a, b in spans[1:]:
        if a - out[-1][1] < gap:
            out[-1][1] = b
        else:
            out.append([a, b])
    return [tuple(s) for s in out]

def detect_cells(mask, rows, cols):
    H, W = mask.shape
    if rows and cols:
        ys = [(int(r*H/rows), int((r+1)*H/rows)) for r in range(rows)]
        cells = []
        for (y0, y1) in ys:
            for c in range(cols):
                cells.append((y0, y1, int(c*W/cols), int((c+1)*W/cols)))
        return cells
    row_on = mask.sum(axis=1) > max(3, 0.004*W)
    row_bands = merge_short_gaps(runs(row_on), int(0.03*H))
    row_bands = [b for b in row_bands if b[1]-b[0] >= 0.06*H]
    cells = []
    for (y0, y1) in row_bands:
        col_on = mask[y0:y1].sum(axis=0) > max(3, 0.01*(y1-y0))
        col_bands = merge_short_gaps(runs(col_on), int(0.03*W))
        col_bands = [b for b in col_bands if b[1]-b[0] >= 0.04*W]
        for (x0, x1) in col_bands:
            cells.append((y0, y1, x0, x1))
    return cells

def tight(mask):
    ys, xs = np.where(mask)
    if len(xs) == 0: return None
    return xs.min(), ys.min(), xs.max()+1, ys.max()+1

def feet_cx(mask):
    h, w = mask.shape
    band = mask[int(h*0.75):, :]
    xs = np.where(band.any(axis=0))[0]
    return int(xs.mean()) if len(xs) else w//2

def get_crops(rgba, rows, cols):
    mask = rgba[..., 3] > 40
    crops = []
    for (y0, y1, x0, x1) in detect_cells(mask, rows, cols):
        bb = tight(mask[y0:y1, x0:x1])
        if bb is None: continue
        l, t, r, b = bb
        crops.append(rgba[y0+t:y0+b, x0+l:x0+r])
    return crops

def scale_path(char): return os.path.join("imagen-action", char, "scale.txt")

def process(sheet, char, action, rows, cols, airborne):
    rgba = key_green(sheet)
    crops = get_crops(rgba, rows, cols)
    n = len(crops)

    # factor de escala del personaje
    sp = scale_path(char)
    if action == "pose" or not os.path.exists(sp):
        stand = max((c[...,3] > 40).any(axis=1).sum() for c in crops)  # frame más alto
        scale = TARGET_BODY / float(stand)
        os.makedirs(os.path.dirname(sp), exist_ok=True)
        with open(sp, "w") as f: f.write(f"{scale:.6f}\n")
        print(f"  escala del personaje = {scale:.4f} (cuerpo {stand}px -> {TARGET_BODY}px) [guardada]")
    else:
        scale = float(open(sp).read().strip())
        print(f"  escala del personaje = {scale:.4f} [de {sp}]")

    outdir = os.path.join("imagen-action", char, action)
    os.makedirs(outdir, exist_ok=True)
    saved = []
    for i, c in enumerate(crops, 1):
        img = Image.fromarray(c)
        nw, nh = max(1, round(img.width*scale)), max(1, round(img.height*scale))
        img = img.resize((nw, nh), Image.LANCZOS)
        m = np.asarray(img)[..., 3] > 40
        fx = feet_cx(m)
        canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0,0,0,0))
        px = ANCHOR_X - fx
        py = (CANVAS_H - nh)//2 if airborne else (FEET_Y - nh)
        canvas.alpha_composite(img, (px, py))
        p = os.path.join(outdir, f"{char}-{action}-{i}.png")
        canvas.save(p); saved.append(p)

    # preview
    scratch = os.environ.get("SCRATCH", "/tmp")
    scale_prev = 0.32
    pw, ph = int(CANVAS_W*scale_prev), int(CANVAS_H*scale_prev)
    prev = Image.new("RGB", (pw*len(saved), ph), (110,110,120))
    for i, p in enumerate(saved):
        fr = Image.open(p).resize((pw, ph), Image.LANCZOS)
        prev.paste(fr, (i*pw, 0), fr)
    # línea de piso en el preview
    from PIL import ImageDraw
    d = ImageDraw.Draw(prev); yline = int(FEET_Y*scale_prev)
    d.line([(0,yline),(prev.width,yline)], fill=(255,80,80), width=1)
    pv = os.path.join(scratch, f"preview-{char}-{action}.png")
    prev.save(pv)
    print(f"  ✓ {n} frames -> {outdir}/  ({CANVAS_W}x{CANVAS_H})  preview: {pv}")
    return saved

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("sheet")
    ap.add_argument("--char", required=True)
    ap.add_argument("--action", required=True)
    ap.add_argument("--rows", type=int, default=None)
    ap.add_argument("--cols", type=int, default=None)
    ap.add_argument("--airborne", action="store_true",
                    help="acción aérea: centra en vertical en vez de anclar por pies")
    args = ap.parse_args()
    print(f"Procesando {args.sheet}  ({args.char}/{args.action})")
    process(args.sheet, args.char, args.action, args.rows, args.cols, args.airborne)
