extends Node
# Singleton (autoload "Sel"): guarda la selección de MODO y PERSONAJES para pasarla
# entre las escenas separadas: title.tscn (menú) -> char_select.tscn -> main.tscn (pelea).

var mode := "vs_cpu"        # "vs_cpu" | "vs_2p" | "practice" | "break"
var p1 := "dam"             # personaje del jugador (P1)
var p2 := "dam"             # personaje del rival / CPU (P2)
var stage := 4              # escenario elegido (código STAGE de main.gd): 1=ciudad, 2=noche, 3=templo, 4=santuario
var configured := false     # true cuando el char-select terminó (la pelea arranca directo)
# PRECARGA: el char-select calienta aquí los frames de los 2 peleadores DURANTE el spinner;
# como este autoload persiste entre escenas, mantiene las texturas en caché para que main.gd
# NO se congele al construir sus SpriteFrames al entrar al round. main.gd lo vacía tras usar.
var warm_cache: Array = []

# ESCENARIOS elegibles en el char-select. "code" = el número que main.gd usa para montar
# el stage; "thumb" = miniatura para la tarjeta de selección.
# Por ahora SOLO un stage disponible (Santuario Dorado). Los demás quedan comentados
# para reactivarlos cuando estén listos.
const STAGES := [
	{"code": 4, "name": "GOLDEN SHRINE", "thumb": "res://imagen-action/stage/santuario-2/far.png"},
	{"code": 1, "name": "RUINED CITY", "thumb": "res://imagen-action/stage/city-2/far.png"},
	{"code": 5, "name": "INFERNO", "thumb": "res://imagen-action/stage/Inferno/far.png"},
	# {"code": 3, "name": "TEMPLE",       "thumb": "res://imagen-action/ui/stage-thumbs/templo.png"},
	# {"code": 2, "name": "MOONLIT NIGHT", "thumb": "res://imagen-action/ui/stage-thumbs/night.png"},
]

# lista de personajes jugables (id, nombre, arquetipo, avatar busto, pose full-body de pie)
# "portrait" = retrato-póster CON FONDO artístico, para enmarcar en el cuadro lateral del
# char-select (aparece con animación al hacer hover). "stand" = retrato de pie recortado.
# Cada uno cae al anterior si no existe.
const ROSTER := [
	{"id": "dam",  "name": "DAM",  "arch": "ASSASSIN", "avatar": "res://imagen-action/dam/avatar/dam-avatar.png",   "portrait": "res://imagen-action/dam/sheets/select-character-post-Dam-2.png",  "stand": "res://imagen-action/dam/select/dam-select.png",   "stand_fallback": "res://imagen-action/dam/pose/dam-pose-1.png",   "weapon": "KATANA",       "power": "INFERNO"},
	{"id": "favi", "name": "FE",   "arch": "ASSASSIN", "avatar": "res://imagen-action/favi/avatar/favi-avatar.png", "portrait": "res://imagen-action/favi/sheets/select-character-post-Fe-2.png", "stand": "res://imagen-action/favi/select/favi-select.png", "stand_fallback": "res://imagen-action/favi/pose/favi-pose-1.png", "weapon": "TWIN NEEDLES", "power": "WHIRLPOOL"},
	{"id": "aye",  "name": "AYE",  "arch": "WIZARD", "avatar": "res://imagen-action/aye/sheets/aye-face.png",   "portrait": "res://imagen-action/aye/sheets/slect-character-aye.png",        "stand": "res://imagen-action/aye/select/aye-select.png",   "stand_fallback": "res://imagen-action/aye/pose/aye-pose-1.png",   "weapon": "CRYSTAL STAFF",  "power": "PRISM"},
	{"id": "zetma", "name": "ZETMA", "arch": "ASSASSIN", "avatar": "res://imagen-action/zetma/sheets/zetma-face.png", "portrait": "res://imagen-action/zetma/sheets/zetma-face.png", "stand": "res://imagen-action/zetma/select/anim/zetma-select-1.png", "stand_fallback": "res://imagen-action/zetma/pose/zetma-pose-1.png", "weapon": "DAGGER", "power": "SHADOW CLONES"},
]

func _ready() -> void:
	_map_pad_p2()

# MANDO (Xbox u otro) = SIEMPRE el JUGADOR 2. Se registra por código (no en project.godot)
# al arrancar, una sola vez; el InputMap runtime persiste entre cambios de escena.
# D-pad/stick izq = mover · X=débil(R) · Y=medio(Q) · A=fuerte(W) · B=especial(E) · RB=breaker
func _map_pad_p2() -> void:
	var btns := {
		"weak_punch_p2": JOY_BUTTON_X, "attack_p2": JOY_BUTTON_Y,
		"kick_p2": JOY_BUTTON_A, "spin_kick_p2": JOY_BUTTON_B,
		"combo_break_p2": JOY_BUTTON_RIGHT_SHOULDER,
		"ui_up_p2": JOY_BUTTON_DPAD_UP, "ui_down_p2": JOY_BUTTON_DPAD_DOWN,
		"ui_left_p2": JOY_BUTTON_DPAD_LEFT, "ui_right_p2": JOY_BUTTON_DPAD_RIGHT,
	}
	for a in btns:
		var ev := InputEventJoypadButton.new()
		ev.button_index = btns[a]
		ev.device = -1
		InputMap.action_add_event(a, ev)
	# botón MENU/START del mando -> ui_cancel (= ESC): abre/cierra la PAUSA en pelea
	# y funciona de "atrás" en los menús. ui_cancel es solo teclado+este botón, así que
	# no interfiere con el combate (los fighters no leen ui_cancel).
	var ev_start := InputEventJoypadButton.new()
	ev_start.button_index = JOY_BUTTON_START
	ev_start.device = -1
	InputMap.action_add_event("ui_cancel", ev_start)
	# acción propia "pause_p2" con el MISMO botón START: distingue QUIÉN pausó
	# (ESC = P1 · START = P2) — la pausa solo la maneja el que la abrió
	if not InputMap.has_action("pause_p2"):
		InputMap.add_action("pause_p2")
	var ev_start2 := InputEventJoypadButton.new()
	ev_start2.button_index = JOY_BUTTON_START
	ev_start2.device = -1
	InputMap.action_add_event("pause_p2", ev_start2)
	var mots := {
		"ui_left_p2": [JOY_AXIS_LEFT_X, -1.0], "ui_right_p2": [JOY_AXIS_LEFT_X, 1.0],
		"ui_up_p2": [JOY_AXIS_LEFT_Y, -1.0], "ui_down_p2": [JOY_AXIS_LEFT_Y, 1.0],
	}
	for a in mots:
		var ev := InputEventJoypadMotion.new()
		ev.axis = mots[a][0]
		ev.axis_value = mots[a][1]
		ev.device = -1
		InputMap.action_add_event(a, ev)
	# Godot por DEFECTO también manda el D-pad/A del mando a ui_left/right/up/down/accept:
	# eso movería a P1 (y confirmaría por P1) con el mando de P2. Se le quita el mando a
	# TODAS las ui_*: los menús aceptan las acciones _p2 explícitamente donde toca.
	for ua in ["ui_left", "ui_right", "ui_up", "ui_down", "ui_accept"]:
		for ev in InputMap.action_get_events(ua):
			if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
				InputMap.action_erase_event(ua, ev)

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
	# en HEADLESS (tests/CI) el driver dummy nunca mezcla audio: el playback quedaría
	# retenido hasta el exit y Godot avisa "ObjectDB instances leaked". Sin música ahí.
	if DisplayServer.get_name() == "headless":
		return
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
