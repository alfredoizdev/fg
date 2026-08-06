#!/bin/bash
# Doble clic en Finder para abrir FG Fighter en ventana (sin el Play del editor).
# También corre desde el chat con:  !./jugar.command
DIR="$(cd "$(dirname "$0")" && pwd)"
exec godot --path "$DIR"
