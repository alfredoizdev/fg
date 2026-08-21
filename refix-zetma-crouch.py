#!/usr/bin/env python3
"""
refix-zetma-crouch.py — RE-PROCESA crouch_jab / crouch_kick / crouch_punch / sweep de Zetma SKIN-2.
Estos moves se CORTABAN a la derecha (brazo/pie fuera del lienzo 1300) y el cuerpo se corria
"bruscamente hacia atras" porque el anclaje por la BANDA DE PIES SALTA (feet_cx cambia 200px cuando
el pie extendido pasa a ser el mas bajo). FIX: anclar por la CADERA (estable) en X + pies en Y, y
lienzo ANCHO auto-dimensionado para que la extension NO se corte. La cadera se pone al MISMO
offset-del-centro que skin-1 (alineacion en juego, el motor centra por textura, offset.x=0).
Usar ESTE script (no retrim) para regenerar estos 4 moves de skin-2. Ver memoria zetma-skin2.
"""
import glob, os, subprocess, tempfile
import numpy as np
from PIL import Image
T_KEEP,T_CUT=45,130
CANVAS_H=1280
SCALE=float(open("imagen-action/zetma/skin-2/scale.txt").read().strip())
BASE="imagen-action/zetma/sheets/skin-2"
# move: (mp4, N, H, fondo_y)  -- N,H de skin-1 (misma estructura), fondo_y=piso
SPEC={
 "crouch_jab":  ("crouch_jab_2.mp4",  59,10,1140),
 "crouch_kick": ("crouch_kick_2.mp4", 28,13,1140),
 "crouch_punch":("crouch_punch_2.mp4",39,15,1140),
 "sweep":       ("sweep_2.mp4",       38,15,1139),
}
def key_green(img):
    a=np.asarray(img.convert("RGBA")).astype(np.int32)
    R,G,B=a[...,0],a[...,1],a[...,2]; gr=G-np.maximum(R,B)
    al=np.clip((T_CUT-gr)/float(T_CUT-T_KEEP),0,1); al=(al*255).astype(np.uint8)
    G2=np.where(gr>0,np.maximum(R,B),G)
    return np.dstack([R,G2,B,al]).astype(np.uint8)
def tight(rgba):
    m=rgba[...,3]>40; ys=m.any(axis=1).nonzero()[0]; xs=m.any(axis=0).nonzero()[0]
    return rgba[ys.min():ys.max()+1, xs.min():xs.max()+1] if len(ys) else rgba
def feet_cx(m):
    ys=m.any(axis=1).nonzero()[0]; bot=ys.max(); band=m[max(0,bot-10):bot+1]
    xs=band.any(axis=0).nonzero()[0]; return int((xs.min()+xs.max())/2) if len(xs) else m.shape[1]//2
def hip_cx(m):
    ys=m.any(axis=1).nonzero()[0]; top,bot=ys.min(),ys.max(); h=bot-top
    hb=m[top+int(0.45*h):top+int(0.60*h)+1]; hx=hb.any(axis=0).nonzero()[0]  # cadera (crouch: 45-60%)
    return int((hx.min()+hx.max())/2) if len(hx) else feet_cx(m)
def scaled(rgba):
    img=Image.fromarray(rgba); nw,nh=max(1,round(img.width*SCALE)),max(1,round(img.height*SCALE))
    return img.resize((nw,nh),Image.LANCZOS)

# offset de cadera-del-centro en skin-1 (target de alineación)
def s1_hip_off(act):
    fs=sorted(glob.glob(f"imagen-action/zetma/{act}/zetma-{act}-*.png"),key=lambda p:int(p.split('-')[-1].split('.')[0]))
    if not fs: return 0
    offs=[]
    for f in fs[:5]:
        a=np.asarray(Image.open(f).convert("RGBA")); H,W=a.shape[:2]; m=a[...,3]>40
        offs.append(hip_cx(m)-W//2)
    return int(np.median(offs))

def onset_window(raw, N, H, cw_guess, hipx):
    # detecta golpe = onset de máx alcance a la der (medido con anclaje cadera provisorio)
    rights=[]
    for r in raw:
        im=scaled(r); m=np.asarray(im)[...,3]>40; hx=hip_cx(m)
        xs=m.any(axis=0).nonzero()[0]
        rights.append(int(xs.max()-hx) if len(xs) else 0)
    rights=np.array(rights); base=int(rights[:10].min()); thr=base+0.90*(rights.max()-base)
    on=np.nonzero(rights>=thr)[0]; strike=int(on[0]) if len(on) else int(np.argmax(rights))
    start=max(0,min(strike-H,len(raw)-N)); return raw[start:start+N], start, strike

for act,(mp4,N,H,by) in SPEC.items():
    hip_off=s1_hip_off(act)
    with tempfile.TemporaryDirectory() as t:
        subprocess.run(["ffmpeg","-y","-i",f"{BASE}/{mp4}",os.path.join(t,"f_%03d.png")],check=True,
                       stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        fs=sorted(glob.glob(os.path.join(t,"f_*.png")))
        raw=[tight(key_green(Image.open(f))) for f in fs]
        window,start,strike=onset_window(raw,N,H,1800,None)
        # medir extensión desde la CADERA en la ventana -> lienzo que no corta
        maxR=maxL=0; scs=[]
        for r in window:
            im=scaled(r); m=np.asarray(im)[...,3]>40; hx=hip_cx(m); scs.append((im,m,hx))
            xs=m.any(axis=0).nonzero()[0]
            if len(xs): maxR=max(maxR,xs.max()-hx); maxL=max(maxL,hx-xs.min())
        half=int(max(maxR-hip_off, maxL+hip_off))+70
        cw=2*half
        ANCHOR=cw//2+hip_off       # cadera al offset de skin-1
        out=f"imagen-action/zetma/skin-2/{act}"
        for old in glob.glob(f"{out}/zetma-{act}-*.png*"): os.remove(old)
        for i,(im,m,hx) in enumerate(scs,1):
            nh=im.height
            canvas=Image.new("RGBA",(cw,CANVAS_H),(0,0,0,0))
            canvas.alpha_composite(im,(ANCHOR-hx, by-nh))    # cadera fija X, pies en Y
            canvas.save(f"{out}/zetma-{act}-{i}.png")
        print(f"{act}: cw={cw} cadera@{ANCHOR}(off {hip_off}) golpe@f{strike-start+1}=H{H} extR={maxR} -> {len(scs)}f")
