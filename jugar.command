#!/bin/bash
# Doble clic en Finder para abrir FG Fighter en ventana (sin el Play del editor).
# También corre desde el chat con:  !./jugar.command
DIR="$(cd "$(dirname "$0")" && pwd)"
# ruta ABSOLUTA a godot (Finder no incluye /opt/homebrew/bin en el PATH)
GODOT="/opt/homebrew/bin/godot"
[ -x "$GODOT" ] || GODOT="$(command -v godot)"
# IMPORTA primero los assets nuevos (PNG/WAV recién agregados) — así no salen mudos ni
# invisibles por falta del .import. Headless, importa y sale; después lanza el juego.
echo "== importando assets nuevos =="
"$GODOT" --headless --import --path "$DIR"
echo "== lanzando FG Fighter =="
exec "$GODOT" --path "$DIR"
