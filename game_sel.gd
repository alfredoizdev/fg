extends Node
# Singleton (autoload "Sel"): guarda la selección de MODO y PERSONAJES para pasarla
# entre las escenas separadas: title.tscn (menú) -> char_select.tscn -> main.tscn (pelea).

var mode := "vs_cpu"        # "vs_cpu" | "practice" | "break"
var p1 := "dam"             # personaje del jugador (P1)
var p2 := "dam"             # personaje del rival / CPU (P2)
var configured := false     # true cuando el char-select terminó (la pelea arranca directo)

# lista de personajes jugables (id, nombre, arquetipo, avatar busto, pose full-body de pie)
# "portrait" = retrato-póster CON FONDO artístico, para enmarcar en el cuadro lateral del
# char-select (aparece con animación al hacer hover). "stand" = retrato de pie recortado.
# Cada uno cae al anterior si no existe.
const ROSTER := [
	{"id": "dam",  "name": "DAM",  "arch": "ASSASSIN", "avatar": "res://imagen-action/dam/avatar/dam-avatar.png",   "portrait": "res://imagen-action/dam/sheets/select-character-post-Dam-2.png",  "stand": "res://imagen-action/dam/select/dam-select.png",   "stand_fallback": "res://imagen-action/dam/pose/dam-pose-1.png",   "weapon": "KATANA",       "power": "INFERNO"},
	{"id": "favi", "name": "FE",   "arch": "ASSASSIN", "avatar": "res://imagen-action/favi/avatar/favi-avatar.png", "portrait": "res://imagen-action/favi/sheets/select-character-post-Fe-2.png", "stand": "res://imagen-action/favi/select/favi-select.png", "stand_fallback": "res://imagen-action/favi/pose/favi-pose-1.png", "weapon": "TWIN NEEDLES", "power": "WHIRLPOOL"},
	{"id": "aye",  "name": "AYE",  "arch": "ASSASSIN", "avatar": "res://imagen-action/aye/avatar/aye-avatar.png",   "portrait": "res://imagen-action/aye/sheets/select-character-post-Aye-2.png", "stand": "res://imagen-action/aye/select/aye-select.png",   "stand_fallback": "res://imagen-action/aye/pose/aye-pose-1.png",   "weapon": "BLOOM STAFF",  "power": "BLOSSOM"},
]

func portrait_of(id: String) -> String:
	var c := data(id)
	for k in ["portrait", "stand", "stand_fallback"]:
		var p := String(c.get(k, ""))
		if ResourceLoader.exists(p):
			return p
	return ""

func data(id: String) -> Dictionary:
	for c in ROSTER:
		if c["id"] == id:
			return c
	return ROSTER[0]
