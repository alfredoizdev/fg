#!/usr/bin/env python3
"""
procesa-zetma-skin2.py — Procesa los clips mp4 de Zetma SKIN-2 (fondo verde) a
frames PNG con transparencia, al MISMO lienzo/tamaño/anclaje que su skin-1.
  - Lienzo 1300x1280, pies a y=1140, centro x=650 (como skin-1).
  - Cuerpo de pie objetivo = 716px (medido en skin-1 -> mismo tamaño en pantalla).
  - Ojos NARANJAS (no verdes): chroma verde directo, sin tratamiento especial.
  - Salida: imagen-action/zetma/skin-2/<accion>/zetma-<accion>-N.png (NO pisa skin-1).
Uso:  python3 procesa-zetma-skin2.py            (todo, pose primero)
      python3 procesa-zetma-skin2.py weak_punch (una accion; pose debe existir)
"""
import os, sys, glob, subprocess, tempfile
import numpy as np
from PIL import Image

CANVAS_W, CANVAS_H = 1300, 1280
FEET_Y   = 1140
ANCHOR_X = 650
TARGET_BODY = 716          # alto del cuerpo de pie de skin-1 (para igualar tamaño)
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

def tight_crop(rgba):
    m = rgba[..., 3] > 40
    ys = m.any(axis=1).nonzero()[0]
    xs = m.any(axis=0).nonzero()[0]
    if len(ys) == 0 or len(xs) == 0:
        return rgba
    return rgba[ys.min():ys.max() + 1, xs.min():xs.max() + 1]

def body_h(rgba):
    return rgba.shape[0]

def extract(mp4, tmp):
    subprocess.run(["ffmpeg", "-y", "-i", mp4, os.path.join(tmp, "f_%03d.png")],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return sorted(glob.glob(os.path.join(tmp, "f_*.png")))

def process(clip, action, airborne=False):
    mp4 = os.path.join(BASE, clip)
    if not os.path.exists(mp4):
        print(f"SKIP {clip} (no existe)"); return
    print(f"[{action}] {clip}")
    with tempfile.TemporaryDirectory() as tmp:
        frames = extract(mp4, tmp)
        rgbas = [tight_crop(key_green_arr(Image.open(f))) for f in frames]
        if action == "pose" or not os.path.exists(SCALE_FILE):
            stand = max(body_h(r) for r in rgbas)
            scale = TARGET_BODY / float(stand)
            os.makedirs(os.path.dirname(SCALE_FILE), exist_ok=True)
            open(SCALE_FILE, "w").write(f"{scale:.6f}\n")
            print(f"  escala skin-2 = {scale:.4f} (cuerpo {stand}px -> {TARGET_BODY}) [guardada]")
        else:
            scale = float(open(SCALE_FILE).read().strip())
            print(f"  escala skin-2 = {scale:.4f} [de {SCALE_FILE}]")
        outdir = f"imagen-action/zetma/skin-2/{action}"
        os.makedirs(outdir, exist_ok=True)
        for old in glob.glob(f"{outdir}/zetma-{action}-*.png*"):
            os.remove(old)
        for i, r in enumerate(rgbas, 1):
            img = Image.fromarray(r)
            nw, nh = max(1, round(img.width * scale)), max(1, round(img.height * scale))
            img = img.resize((nw, nh), Image.LANCZOS)
            m = np.asarray(img)[..., 3] > 40
            fx = feet_cx(m)
            canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
            px = ANCHOR_X - fx
            py = (CANVAS_H - nh) // 2 if airborne else (FEET_Y - nh)
            canvas.alpha_composite(img, (px, py))
            canvas.save(f"{outdir}/zetma-{action}-{i}.png")
        print(f"  -> {len(rgbas)} frames en {outdir}")

CLIPS = [
    ("pose_2.mp4", "pose", False),
    ("walk_2.mp4", "walk", False),
    ("crouch.mp4", "crouch", False),
    ("jump_2.mp4", "jump", False),
    ("punch_2.mp4", "punch", False),
    ("weak_punch.mp4", "weak_punch", False),
    ("crouch_punch_2.mp4", "crouch_punch", False),
    ("kick_2.mp4", "kick", False),
    ("spin_kick_2.mp4", "spin_kick", False),
    ("crouch_kick_2.mp4", "crouch_kick", False),
    ("crouch_jab_2.mp4", "crouch_jab", False),
]

if __name__ == "__main__":
    only = sys.argv[1:] if len(sys.argv) > 1 else None
    for clip, action, air in CLIPS:
        if only and action not in only:
            continue
        process(clip, action, air)
