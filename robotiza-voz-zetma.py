#!/usr/bin/env python3
"""
robotiza-voz-zetma.py — Da voz ROBÓTICA a los gritos de Zetma (máscara mecánica).
Efecto = ring-modulation (portadora ~58Hz, timbre metálico/vocoder) mezclada con algo de seco
+ comb metálico (resonancia de lata) + soft-clip (dureza digital). Respalda los originales en
sound-effect/backup-voz/ (para revertir/ajustar). Deja intactos walk/crouch/jump (SFX movimiento).
"""
import os, shutil, glob
import numpy as np
from scipy.io import wavfile
from scipy.signal import lfilter

SND = "imagen-action/zetma/sound-effect"
BK = os.path.join(SND, "backup-voz")
VOZ = ["punch", "kick", "weak_punch", "spin_kick", "pose",
       "air_grab", "ground_grab", "come_to_me", "zetma-select"]

CARRIER = 58.0     # Hz portadora ring-mod (metálico pero aún se entiende el grito)
RING_MIX = 0.72    # 0..1 cuánto ring vs seco
COMB_MS = 1.6      # resonancia metálica (delay corto)
COMB_G = 0.42      # feedback del comb
DRIVE = 1.7        # soft-clip

def to_float(x):
    if x.dtype == np.int16:  return x.astype(np.float64) / 32768.0, np.int16
    if x.dtype == np.int32:  return x.astype(np.float64) / 2147483648.0, np.int32
    if x.dtype == np.uint8:  return (x.astype(np.float64) - 128) / 128.0, np.uint8
    return x.astype(np.float64), np.float32

def from_float(y, dt):
    y = np.clip(y, -1.0, 1.0)
    if dt == np.int16:  return (y * 32767).astype(np.int16)
    if dt == np.int32:  return (y * 2147483647).astype(np.int32)
    if dt == np.uint8:  return (y * 128 + 128).clip(0, 255).astype(np.uint8)
    return y.astype(np.float32)

def robot(ch, sr):
    n = len(ch)
    t = np.arange(n) / float(sr)
    carrier = np.sin(2 * np.pi * CARRIER * t)
    y = RING_MIX * (ch * carrier) + (1.0 - RING_MIX) * ch     # ring-mod mezclado con seco
    D = max(1, int(sr * COMB_MS / 1000.0))                    # comb metálico (IIR: y[n]+g*y[n-D])
    a = np.zeros(D + 1); a[0] = 1.0; a[D] = -COMB_G
    y = lfilter([1.0], a, y)
    y = np.tanh(DRIVE * y) / np.tanh(DRIVE)                   # soft-clip = dureza digital
    return y

def process(name):
    path = os.path.join(SND, name + ".wav")
    if not os.path.exists(path):
        print(f"SKIP {name} (no existe)"); return
    os.makedirs(BK, exist_ok=True)
    bkp = os.path.join(BK, name + ".wav")
    if not os.path.exists(bkp):
        shutil.copy2(path, bkp)                              # respaldo del ORIGINAL (una vez)
    sr, data = wavfile.read(bkp)                             # procesa SIEMPRE desde el original
    x, dt = to_float(data)
    if x.ndim == 1:
        y = robot(x, sr)
    else:
        y = np.stack([robot(x[:, c], sr) for c in range(x.shape[1])], axis=1)
    peak = np.max(np.abs(y)) or 1.0
    y = y / peak * 0.97                                      # normaliza
    wavfile.write(path, sr, from_float(y, dt))
    print(f"  {name}: robotizado ({sr}Hz, {'stereo' if x.ndim>1 else 'mono'})")

if __name__ == "__main__":
    import sys
    only = sys.argv[1:] if len(sys.argv) > 1 else VOZ
    for n in only:
        process(n)
