#!/bin/bash
# ============================================================================
# FÓRMULA DE VOZ DE DAM  (natural + furiosa, aprobada en INFERNO)
# ----------------------------------------------------------------------------
# Convierte una voz cruda del TTS en la voz de batalla de DAM:
#   - pitch -1 semitono (apenas más grave, sigue siendo la voz real)
#   - saturación PARALELA tipo rasgado (furia de grito) mezclada por debajo
#   - presencia en medios (2.7k = "bite") + cuerpo en graves (180)
#   - compresión agresiva + reverb CORTO/sutil (natural, sin caverna)
#   - normalizado fuerte (-11.5 LUFS)
#
# Uso:
#   ./procesar-voz-dam.sh <archivo-entrada.mp3>  <nombre>
#   ej:  ./procesar-voz-dam.sh INFERNO_Vibes_xxx.mp3  inferno
#   -> escribe imagen-action/sound-effect/voz-<nombre>.wav
#
# Después: en Godot enfocá el editor para importar el .wav.
# ============================================================================
set -e
SRC="$1"
NAME="$2"
if [ -z "$SRC" ] || [ -z "$NAME" ]; then
  echo "uso: ./procesar-voz-dam.sh <entrada.mp3> <nombre>"; exit 1
fi
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/imagen-action/sound-effect/voz-${NAME}.wav"

ffmpeg -y -i "$SRC" -filter_complex "\
[0:a]rubberband=pitch=0.9439[v];\
[v]asplit=2[clean][d];\
[d]volume=12dB,alimiter=limit=0.9,volume=-9dB[dirt];\
[clean][dirt]amix=inputs=2:weights=1 0.4:normalize=0[mx];\
[mx]highpass=f=80,\
equalizer=f=2700:width_type=o:width=1.3:g=4,\
equalizer=f=180:width_type=o:width=1.2:g=2,\
acompressor=threshold=-19dB:ratio=4:attack=2:release=90,\
aecho=0.9:0.3:36:0.14,\
alimiter=limit=0.96,\
loudnorm=I=-11.5:TP=-1.0" \
  -ar 44100 -ac 1 "$OUT"

echo "listo: $OUT"
