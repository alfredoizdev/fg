#!/usr/bin/env python3
"""
proc-aye2-clip.py — Procesa un CLIP (mp4) de Aye-2 (fondo verde) al lienzo del juego.

Aye-2 es la MÁS chica del juego (más que Fe). El arte se procesa a ~632px de cuerpo
(buena resolución) y el `base_scale` en el motor la achica (body_k ~0.60). Igual que
los demás: pies clavados a FEET_Y=1140, centro-x a ANCHOR_X=650, canvas 1300x1280.

- Croma verde -> alfa (+ despill).
- Normaliza ESCALA por frame por ÁREA de silueta (mata el jitter de escala del clip IA;
  válido en poses ~constantes como idle/caminar). Con --uniform lo desactiva.
- Calibra a --target-h de alto de cuerpo. Clava pies (o centra en vertical si --airborne).

Uso:
  python3 proc-aye2-clip.py imagen-action/aye-2/sheets/skin-1/pose-skin-1.mp4 --action pose
  python3 proc-aye2-clip.py <clip.mp4> --action walk
  python3 proc-aye2-clip.py <clip.mp4> --action jump --airborne
"""
import argparse, os, glob, subprocess, tempfile, shutil
import numpy as np
from PIL import Image
from scipy import ndimage

CW, CH, FEET_Y, ANCHOR_X = 1300, 1280, 1140, 650

def chroma(path):
    a = np.array(Image.open(path).convert("RGB")).astype(np.int16)
    R, G, B = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    green = (G > 110) & (G - R > 45) & (G - B > 45)
    m = ~green
    rgba = np.dstack([a.astype(np.uint8), np.where(m, 255, 0).astype(np.uint8)])
    # DESPILL solo en el FLECO pegado al fondo (borde de la silueta), no en TODO el interior.
    # Si despillamos todo, cualquier material legítimamente verde (p.ej. la bota holográfica
    # verde de Aye) se agrisa a max(R,B) y se ve "deshecho/desvanecido". El verde de pantalla
    # solo toca el borde, así que ahí basta con limpiar el fleco.
    fringe = m & ndimage.binary_dilation(green, iterations=3)
    sp = fringe & (G > R) & (G > B) & (G - np.maximum(R, B) > 18)
    rgba[sp, 1] = np.maximum(R, B)[sp].astype(np.uint8)
    return rgba, m

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("clip")
    ap.add_argument("--action", required=True)
    ap.add_argument("--skin", default="", help="skin-1 | skin-2 (namespacea la carpeta)")
    ap.add_argument("--target-h", type=float, default=632.0, help="alto de cuerpo del arte")
    ap.add_argument("--target-area", type=float, default=0.0,
                    help="ÁREA de silueta objetivo. OFF por defecto (0): usamos ALTO, porque el ÁREA "
                         "depende de la ROPA (tutú vs overol) y descalibra entre skins. Si >0, prioriza área.")
    ap.add_argument("--airborne", action="store_true", help="centra en vertical (sin clavar pies)")
    ap.add_argument("--uniform", action="store_true", help="escala uniforme (sin normalizar área)")
    ap.add_argument("--stand", action="store_true",
                    help="calibra la escala uniforme al PERCENTIL de alto de --stand-pct (los frames PARADOS), "
                         "no a la mediana. Para clips que empiezan parada y se agachan (crouch/get_up).")
    ap.add_argument("--stand-pct", type=float, default=90.0,
                    help="percentil de alto para --stand. 90=default; ~99 para clips MUY agachados (crouch) "
                         "donde el frame PARADO es el más alto y debe igualar al idle (632).")
    ap.add_argument("--baked", action="store_true",
                    help="clip con ARCO horneado (jump 145f, los pies suben en el frame): escala UNIFORME "
                         "+ offset vertical GLOBAL (pies del frame más bajo -> 1140) para preservar el arco.")
    args = ap.parse_args()

    tmp = tempfile.mkdtemp(prefix="aye2clip_")
    try:
        subprocess.run(["ffmpeg", "-v", "error", "-i", args.clip, f"{tmp}/f-%04d.png"], check=True)
        fs = sorted(glob.glob(f"{tmp}/*.png"))
        data = []
        for p in fs:
            rgba, m = chroma(p)
            ys, xs = np.where(m)
            if len(xs) == 0:
                continue
            data.append((rgba, int(m.sum()), int(ys.max() - ys.min())))
        if not data:
            print("sin frames con silueta"); return
        if args.baked:
            args.uniform = True   # arco: escala UNIFORME sí o sí (no deformar el movimiento)
        if args.target_area and args.target_area > 0 and not args.baked:
            # MISMO TAMAÑO en todas las skins/anims: cada frame a la misma ÁREA (invariante a
            # postura/mano levantada). Mata jitter Y unifica tamaño entre clips.
            scale_of = lambda a: (args.target_area / a) ** 0.5
        else:
            a_med = float(np.median([d[1] for d in data]))
            if args.uniform:
                bhs = [d[2] for d in data]
                H = float(np.percentile(bhs, args.stand_pct) if args.stand else np.median(bhs)); norm = lambda a: 1.0
            else:
                H = float(np.median([d[2] * (a_med / d[1]) ** 0.5 for d in data]))
                norm = lambda a: (a_med / a) ** 0.5
            g = args.target_h / H
            scale_of = lambda a: norm(a) * g

        dest = f"imagen-action/aye-2/{args.skin}/{args.action}" if args.skin else f"imagen-action/aye-2/{args.action}"
        os.makedirs(dest, exist_ok=True)
        for old in glob.glob(f"{dest}/aye2-{args.action}-*.png"):
            os.remove(old)
        # pasada 1: escalar y medir (para --baked necesito el offset vertical GLOBAL)
        scaled = []
        for (rgba, a, h) in data:
            s = scale_of(a)
            img = Image.fromarray(rgba, "RGBA")
            img = img.resize((max(1, round(img.width * s)), max(1, round(img.height * s))), Image.LANCZOS)
            mm = np.array(img)[:, :, 3] > 40
            ys, xs = np.where(mm)
            scaled.append((img, int(round(xs.mean())), int(ys.max()), int(round(ys.mean()))))
        dy_global = FEET_Y - max(t[2] for t in scaled) if args.baked else 0
        # pasada 2: componer
        for i, (img, cen, feet, cy) in enumerate(scaled, 1):
            canvas = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
            if args.baked:
                canvas.alpha_composite(img, (ANCHOR_X - cen, dy_global))     # offset GLOBAL: preserva el arco
            elif args.airborne:
                canvas.alpha_composite(img, (ANCHOR_X - cen, CH // 2 - cy))
            else:
                canvas.alpha_composite(img, (ANCHOR_X - cen, FEET_Y - feet))
            canvas.save(f"{dest}/aye2-{args.action}-{i}.png")
        mode = f"area={args.target_area:.0f}" if (args.target_area and args.target_area > 0) else f"h={args.target_h:.0f}"
        print(f"{args.action}: {len(data)} frames -> {dest}  ({mode})")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

if __name__ == "__main__":
    main()
