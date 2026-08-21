#!/usr/bin/env python3
"""
procesa-zetma-skin2-extras.py — Procesa los 3 assets EXTRA de Zetma SKIN-2:
  1) select_vs_2.png  -> sheets/skin-2/zetma-vs2.png   (retrato VS, chroma + recorte)
  2) avatar-select.png-> cutin/zetma-cutin2.png         (avatar del cut-in del super)
  3) select-animation.mp4 -> skin-2/select_anim/zetma-select_anim-N.png
        (preview animado del char-select, mismo lienzo/anclaje que la pose de skin-2)

Los dos primeros se dejan RECORTADOS a la silueta con transparencia (como zetma-vs.png).
El tercero se ancla igual que la pose (pies a FEET_Y, escala de skin-2) para que el loop
del preview quede encuadrado idéntico a los demás.
"""
import os, glob, subprocess, tempfile
import numpy as np
from PIL import Image

CANVAS_W, CANVAS_H = 1300, 1280
FEET_Y   = 1140
ANCHOR_X = 650
T_KEEP, T_CUT = 45, 130
SCALE_FILE = "imagen-action/zetma/skin-2/scale.txt"
BASE = "imagen-action/zetma/sheets/skin-2"

def key_green_arr(img):
    a = np.asarray(img.convert("RGBA")).astype(np.int32)
    R, G, B = a[..., 0], a[..., 1], a[..., 2]
    greenness = G - np.maximum(R, B)
    alpha = np.clip((T_CUT - greenness) / float(T_CUT - T_KEEP), 0.0, 1.0)
    alpha = (alpha * 255).astype(np.uint8)
    spill = greenness > 0
    G2 = np.where(spill, np.maximum(R, B), G)
    return np.dstack([R, G2, B, alpha]).astype(np.uint8)

def tight_crop(rgba):
    m = rgba[..., 3] > 40
    ys = m.any(axis=1).nonzero()[0]
    xs = m.any(axis=0).nonzero()[0]
    if len(ys) == 0 or len(xs) == 0:
        return rgba
    return rgba[ys.min():ys.max() + 1, xs.min():xs.max() + 1]

def feet_cx(mask):
    ys = mask.any(axis=1).nonzero()[0]
    if len(ys) == 0:
        return CANVAS_W // 2
    y1 = ys.max()
    band = mask[max(0, y1 - 10):y1 + 1]
    xs = band.any(axis=0).nonzero()[0]
    if len(xs) == 0:
        xs = mask.any(axis=0).nonzero()[0]
    return int((xs.min() + xs.max()) / 2) if len(xs) else CANVAS_W // 2

def process_still(src, dst):
    if not os.path.exists(src):
        print(f"SKIP {src} (no existe)"); return
    r = tight_crop(key_green_arr(Image.open(src)))
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    Image.fromarray(r).save(dst)
    print(f"  {src} -> {dst}  ({r.shape[1]}x{r.shape[0]})")

def extract(mp4, tmp):
    subprocess.run(["ffmpeg", "-y", "-i", mp4, os.path.join(tmp, "f_%03d.png")],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return sorted(glob.glob(os.path.join(tmp, "f_*.png")))

# El PREVIEW del char-select escala por ALTO de textura -> el personaje debe LLENAR el alto,
# como los frames originales de select (zetma/select/anim = 480x1022). Si se deja en el lienzo
# de juego (1300x1280, cuerpo 716) sale CHIQUITO. Aquí: canvas de alto SEL_H con el cuerpo casi
# lleno (mismo tamaño en pantalla que skin-1) y pies anclados abajo-centro (sin jitter).
SEL_H = 1022               # = alto de los frames originales de select (skin-1) -> mismo tamaño

def process_select_anim(mp4, action="select_anim"):
    if not os.path.exists(mp4):
        print(f"SKIP {mp4} (no existe)"); return
    outdir = f"imagen-action/zetma/skin-2/{action}"
    os.makedirs(outdir, exist_ok=True)
    for old in glob.glob(f"{outdir}/zetma-{action}-*.png*"):
        os.remove(old)
    with tempfile.TemporaryDirectory() as tmp:
        frames = extract(mp4, tmp)
        rgbas = [tight_crop(key_green_arr(Image.open(f))) for f in frames]
        stand = max(r.shape[0] for r in rgbas)          # cuerpo más alto del clip
        scale = (SEL_H * 0.98) / float(stand)           # el cuerpo LLENA el alto (como el original)
        scaled = []
        for r in rgbas:
            img = Image.fromarray(r)
            scaled.append(img.resize((max(1, round(img.width * scale)),
                                      max(1, round(img.height * scale))), Image.LANCZOS))
        # ANCLA por los PIES (punto ESTABLE, no se corre cuando el brazo se mueve) y hace el lienzo
        # ANCHO para que el cuerpo/brazos que se extienden al lado de los pies NO se corten.
        # Mide, respecto al centro de los pies, cuánto se va el cuerpo a izq/der en TODO el clip.
        MARG = 40
        feets, lefts, rights = [], [], []
        for im in scaled:
            m = np.asarray(im)[..., 3] > 40
            xs = m.any(axis=0).nonzero()[0]
            fx = feet_cx(m)
            feets.append(fx); lefts.append(int(xs.min()) - fx); rights.append(int(xs.max()) - fx)
        max_left = min(lefts)        # negativo: lo más a la IZQ del cuerpo respecto a los pies
        max_right = max(rights)
        # PIES al CENTRO del lienzo (el juego centra por textura) y lienzo SIMÉTRICO lo bastante
        # ancho para que ni izq ni der se corten en ningún frame -> centrado + sin jitter + sin corte.
        half = max(-max_left, max_right) + MARG
        anchor = half                # pies fijos en el centro (=half) en TODOS los frames
        cw = 2 * half
        for i, im in enumerate(scaled, 1):
            m = np.asarray(im)[..., 3] > 40
            fx = feet_cx(m)
            canvas = Image.new("RGBA", (cw, SEL_H), (0, 0, 0, 0))
            canvas.alpha_composite(im, (anchor - fx, SEL_H - im.height))  # pies fijos en 'anchor'
            canvas.save(f"{outdir}/zetma-{action}-{i}.png")
    print(f"  {mp4} -> {outdir}  ({len(rgbas)} frames, canvas {cw}x{SEL_H}, escala {scale:.4f}, pies@{anchor})")

if __name__ == "__main__":
    print("[VS portrait skin-2]")
    process_still(f"{BASE}/select_vs_2.png", "imagen-action/zetma/sheets/skin-2/zetma-vs2.png")
    print("[cut-in super skin-2]")
    process_still(f"{BASE}/avatar-select.png", "imagen-action/zetma/cutin/zetma-cutin2.png")
    print("[select animation skin-2]")
    process_select_anim(f"{BASE}/select-animation.mp4", "select_anim")
