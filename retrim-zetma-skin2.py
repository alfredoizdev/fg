#!/usr/bin/env python3
"""
retrim-zetma-skin2.py — RECORTA los clips de ataque de skin-2 a la MISMA estructura que
skin-1: N frames con el GOLPE (máximo alcance, la daga/pie/puño más extendido) alineado al
hit_frame H que el motor espera. Sin esto, skin-2 mete los 145 frames crudos y el golpe cae
en otro frame -> conecta antes de que el movimiento llegue.

Por ataque: (N = nº de frames de skin-1, H = hit_frame efectivo de skin-1).
Se detecta el frame del golpe en el clip crudo de skin-2 (máx x de la silueta = extensión a la
derecha) y se recorta la ventana [golpe-H, golpe-H+N) -> el golpe queda EXACTO en el frame H.
Mismo lienzo/anclaje que skin-1 (1300x1280, pies 650/1140) para que alinee en pantalla.
"""
import os, sys, glob, subprocess, tempfile
import numpy as np
from PIL import Image

CANVAS_H = 1280
FEET_Y, ANCHOR_X = 1140, 650
T_KEEP, T_CUT = 45, 130
SCALE = float(open("imagen-action/zetma/skin-2/scale.txt").read().strip())
BASE = "imagen-action/zetma/sheets/skin-2"

# ataque -> (mp4, N frames skin-1, H hit_frame efectivo skin-1, ancho_lienzo, fondo_y)
# el brazo extensible (spin_kick) y la patada voladora (jump_kick) usan lienzo 1800 como skin-1.
# fondo_y = dónde se ancla el borde inferior del cuerpo: 1140 en el suelo, 871 en el aire (flota).
SPEC = {
    "punch":        ("punch_2.mp4",        38, 15, 1300, 1140),
    "kick":         ("kick_2.mp4",         59, 23, 1300, 1140),
    "crouch_punch": ("crouch_punch_2.mp4", 39, 15, 1300, 1140),
    "crouch_kick":  ("crouch_kick_2.mp4",  28, 13, 1300, 1140),
    "crouch_jab":   ("crouch_jab_2.mp4",   59, 10, 1300, 1140),
    "weak_punch":   ("weak_punch.mp4",     54,  6, 1300, 1140),
    "spin_kick":    ("spin_kick_2.mp4",    31, 11, 1800, 1140),
    "jump_kick":    ("jump_kick_2.mp4",    90, 15, 1800,  871),
    "jump_punch":   ("jump_punch_2.mp4",  130, 30, 1800,  871),
    "air_spin_kick": ("air_spin_kick.mp4",  77, 11, 1800,  871),
    "air_jab":       ("air_jab_2.mp4",       74, 18, 1800,  871),
    # agarre: NO usa hit_frame (conecta por proximidad+tiempo 0.28-0.95s). "Mismo agarre/velocidad"
    # = mismo Nº de frames (130) con el brazo extendido en el mismo momento (onset skin-1 ~f39).
    "air_grab":      ("air_grab_2.mp4",      130, 39, 1800, 1064),
}

def key_green_arr(img):
    a = np.asarray(img.convert("RGBA")).astype(np.int32)
    R, G, B = a[..., 0], a[..., 1], a[..., 2]
    greenness = G - np.maximum(R, B)
    alpha = np.clip((T_CUT - greenness) / float(T_CUT - T_KEEP), 0.0, 1.0)
    alpha = (alpha * 255).astype(np.uint8)
    G2 = np.where(greenness > 0, np.maximum(R, B), G)
    return np.dstack([R, G2, B, alpha]).astype(np.uint8)

def tight_crop(rgba):
    m = rgba[..., 3] > 40
    ys = m.any(axis=1).nonzero()[0]; xs = m.any(axis=0).nonzero()[0]
    if len(ys) == 0 or len(xs) == 0:
        return rgba
    return rgba[ys.min():ys.max() + 1, xs.min():xs.max() + 1]

def feet_cx(mask):
    ys = mask.any(axis=1).nonzero()[0]
    if len(ys) == 0:
        return CANVAS_W // 2
    y1 = ys.max(); band = mask[max(0, y1 - 10):y1 + 1]
    xs = band.any(axis=0).nonzero()[0]
    if len(xs) == 0:
        xs = mask.any(axis=0).nonzero()[0]
    return int((xs.min() + xs.max()) / 2) if len(xs) else CANVAS_W // 2

def extract(mp4, tmp):
    subprocess.run(["ffmpeg", "-y", "-i", mp4, os.path.join(tmp, "f_%03d.png")],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return sorted(glob.glob(os.path.join(tmp, "f_*.png")))

def compose(rgba, canvas_w=1300, bottom_y=FEET_Y):
    """escala + ancla pies -> lienzo de juego (igual que procesa-zetma-skin2)."""
    img = Image.fromarray(rgba)
    nw, nh = max(1, round(img.width * SCALE)), max(1, round(img.height * SCALE))
    img = img.resize((nw, nh), Image.LANCZOS)
    m = np.asarray(img)[..., 3] > 40
    fx = feet_cx(m)
    canvas = Image.new("RGBA", (canvas_w, CANVAS_H), (0, 0, 0, 0))
    canvas.alpha_composite(img, (ANCHOR_X - fx, bottom_y - nh))
    return canvas

def process(action):
    mp4, N, H, cw, by = SPEC[action]
    src = os.path.join(BASE, mp4)
    if not os.path.exists(src):
        print(f"SKIP {action} ({mp4} no existe)"); return
    with tempfile.TemporaryDirectory() as tmp:
        frames = extract(src, tmp)
        raw = [tight_crop(key_green_arr(Image.open(f))) for f in frames]
        # GOLPE = frame de MÁXIMO alcance a la derecha MEDIDO SOBRE EL FRAME ANCLADO (pies en 650):
        # así "reach" = cuánto se extiende la daga/pie/puño desde el cuerpo (no el ancho del recorte,
        # que para la patada alta engaña porque la pose inicial es la más ancha).
        rights = []
        for r in raw:
            comp = np.asarray(compose(r, cw, by))
            xs = (comp[..., 3] > 40).any(axis=0).nonzero()[0]
            rights.append(int(xs.max()) if len(xs) else 0)
        rights = np.array(rights)
        # GOLPE = ONSET de la extensión (1er frame que alcanza ~95% del máx), NO el argmax:
        # las patadas/pokes SOSTIENEN la extensión (plateau) y el argmax caía al final del plateau.
        base = int(rights[:10].min())                       # alcance en reposo (primeros frames)
        thr = base + 0.90 * (int(rights.max()) - base)      # 90% del recorrido reposo->máx
        onset = np.nonzero(rights >= thr)[0]
        strike = int(onset[0]) if len(onset) else int(np.argmax(rights))
        start = strike - H
        # clamp para no salir del clip; conserva N frames
        start = max(0, min(start, len(raw) - N))
        window = raw[start:start + N]
        outdir = f"imagen-action/zetma/skin-2/{action}"
        os.makedirs(outdir, exist_ok=True)
        for old in glob.glob(f"{outdir}/zetma-{action}-*.png*"):
            os.remove(old)
        for i, r in enumerate(window, 1):
            compose(r, cw, by).save(f"{outdir}/zetma-{action}-{i}.png")
        print(f"[{action}] golpe_crudo=f{strike+1}  recorte=[{start+1}..{start+N}]  -> {len(window)}f (golpe@f{strike-start+1}=H{H}, lienzo {cw}, fondo {by})")

if __name__ == "__main__":
    only = sys.argv[1:] if len(sys.argv) > 1 else list(SPEC.keys())
    for a in only:
        if a in SPEC:
            process(a)
