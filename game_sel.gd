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
	{"id": "aye",  "name": "AYE",  "arch": "WIZARD", "avatar": "res://imagen-action/aye/sheets/aye-face.png",   "portrait": "res://imagen-action/aye/sheets/slect-character-aye.png",        "stand": "res://imagen-action/aye/select/aye-select.png",   "stand_fallback": "res://imagen-action/aye/pose/aye-pose-1.png",   "weapon": "CRYSTAL STAFF",  "power": "PRISM"},
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

# --- Música de los MENÚS (título + char-select). Va en el AUTOLOAD para que PERSISTA
# entre las dos escenas (no se reinicia al pasar de una a otra) y hace LOOP. La pelea
# la corta con stop_menu_music(). ---
var _music: AudioStreamPlayer = null
const MENU_MUSIC := "res://imagen-action/sound-effect/main-song-screen.mp3"

func play_menu_music() -> void:
	if _music != null and _music.playing:
		return   # ya está sonando: NO reiniciar al cambiar de título a char-select
	if _music == null:
		_music = AudioStreamPlayer.new()
		if ResourceLoader.exists(MENU_MUSIC):
			var s := load(MENU_MUSIC)
			if s is AudioStreamMP3 or s is AudioStreamOggVorbis:
				s.loop = true   # LOOP seamless (se repite sin corte)
			_music.stream = s
		_music.finished.connect(func(): _music.play())   # respaldo de loop
		add_child(_music)
	if _music.stream != null:
		_music.play()

func stop_menu_music() -> void:
	if _music != null:
		_music.stop()

# al CERRAR la ventana: parar la música y soltar el stream para que el AudioServer no
# avise "resource still in use at exit". (En cierre por Ctrl+C / kill duro el aviso puede
# seguir saliendo porque ese camino no dispara esta notificación — es inofensivo.)
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE \
			or what == NOTIFICATION_EXIT_TREE or what == NOTIFICATION_CRASH:
		if _music != null:
			_music.stop()
			_music.stream = null
