extends Node2D

# Arbitro del combate: rondas, vida, hitboxes y anuncios.

const LEFT_LIMIT := 115.0
const RIGHT_LIMIT := 1805.0
const MAX_HP := 100   # (legado; la vida real es por personaje según arquetipo)
# vida por ARQUETIPO (puede variar por personaje)
const ARCH_HP := {"assassin": 1200, "wizard": 1000, "warrior": 1500}
var hp_max := [1200, 1200]   # vida máxima por lado [P1, P2], se setea de cada peleador
const HIT_MARGIN := 59.0     # tolerancia extra de alcance
const AIR_REACH_H := 302.0   # altura maxima a la que un golpe aereo alcanza a un rival en el piso
const WINS_NEEDED := 2       # rondas para ganar el combate
const BODY_SEP := 143.0      # distancia minima entre cuerpos en el piso
const TRAINING := false      # modo entrenamiento: sin rival, sin escenario, sin UI
const STAGE := 3             # 1 = ciudad en llamas, 2 = noche de luna, 3 = templo al atardecer
const CITY_NODES := ["BG", "StageBase", "Flame1", "Patch1", "Patch2", "Patch3",
	"Patch4", "Patch5", "Window1", "Window2", "Window3", "Window4",
	"Smoke1", "Smoke2", "Embers"]

@onready var player: Node2D = $Player
@onready var dummy: Node2D = $Dummy
@onready var p1_fill: ColorRect = $UI/P1Fill
@onready var p2_fill: ColorRect = $UI/P2Fill
@onready var announce: Label = $UI/Announce
@onready var rounds_label: Label = $UI/Rounds
@onready var world_env: WorldEnvironment = $WorldEnvironment

var glow_time := 0.0

var player_hp := 1200
var dummy_hp := 1200
var round_num := 1
var wins_p1 := 0
var wins_p2 := 0
# --- HUD nuevo: geometría de barras, METER de 3 segmentos, timer, puntos ---
const BAR_W := 700.0
const P1_BAR_X := 126.0    # la barra PEGADA al avatar (borde recto) y va al centro
const P2_BAR_X := 1094.0   # (1094 + 700 = 1794 = borde interno del avatar derecho)
const METER_MAX := 3.0
const MATCH_TIME := 99.0
const METER_REGEN := 0.02      # recarga pasiva por segundo (neutro MUY lento)
const METER_WALK := 0.025      # bonus mínimo al caminar (neutro sigue muy lento)
const BLOCK_DRAIN := 0.0030    # energía drenada al BLOQUEAR, por punto de daño (más costoso)
const HIT_DRAIN := 0.0018      # energía perdida al RECIBIR un impacto real, por punto de daño
var meter := [0.0, 0.0]        # carga del meter por lado (0..3)
var hp_bar_bg := []            # [P1,P2] fondo poligonal inclinado de la barra de vida
var hp_bar_fill := []          # [P1,P2] relleno poligonal (se recalcula por HP)
var hp_grad := []              # [P1,P2] texturas de degradado del relleno
var meter_bg := [[], []]       # fondo OSCURO de cada segmento (3 por lado)
var meter_fill := [[], []]     # relleno VERDE por ancho (media barra = medio lleno)
var meter_fl := [[], []]       # borde negro (Line2D) de cada segmento
var meter_spark := [[], []]    # chispas (CPUParticles2D) del segmento lleno
var match_time := MATCH_TIME
var timer_label: Label
var win_dots := [[], []]       # puntos de victoria por lado
var timed_out := false         # ya se resolvió el fin por tiempo
var state := "intro"        # intro / fight / round_end
var attack_done_p1 := ""    # ataque ya resuelto en esta instancia de animacion
var attack_done_p2 := "" 

# contador de combos [p1, p2]
const COMBO_WINDOW := 0.75   # segundos entre golpes para que siga el combo
var combo_n := [0, 0]
var combo_t := [99.0, 99.0]
var combo_dmg := [0, 0]
var combo_last := ["", ""]   # ultimo golpe del combo: repetirlo = drop
var combo_lvl := [0, 0]      # nivel del ultimo golpe (escalera debil→fuerte)
const ATK_LEVEL := {
	"weak_punch": 1, "crouch_jab": 1,
	"punch": 2, "punch2": 2, "crouch_punch": 2, "jump_punch": 2,
	"kick": 3, "crouch_kick": 3, "jump_kick": 3,
	"spin_kick": 4, "air_spin_kick": 4, "sweep": 4,
	"ember_dash": 5,
}
var combo_dmg_lbl := []
# campana de combo: sube por la escala pentatonica con cada golpe
const DING_SCALE := [0, 2, 4, 7, 9, 12, 14, 16, 19, 21, 24]
var ding_player: AudioStreamPlayer
var voz_player: AudioStreamPlayer          # grito de finisher (voz infernal)
var kick_voz_player: AudioStreamPlayer     # voz furiosa de la patada giratoria (E)
var music_player: AudioStreamPlayer        # música de fondo (se libera en _exit_tree)
var _kick_voz_t := 0                        # cooldown (ms) para no solapar la voz de patada
var _voz_cache := {}                        # streams de voz cacheados por nombre
var ding_stream = null
var combo_ui := []      # contenedor por lado
var combo_num := []     # numero gigante
var combo_ghost := []   # numero FANTASMA gigante detras (estilo GG Strive)
var combo_nom := []     # nombre del rango
var combo_font: SystemFont   # fuente heavy del contador
var combo_band := []    # banda de color del número (verde -> rojo según el combo)
var combo_face := []    # cara/ojos del ATACANTE como fondo del panel del número
var combo_rest_x := [270.0, 1650.0]   # x de reposo del cartel (izq / der)
var combo_show_ms := [-100000, -100000]  # reloj REAL del inicio de la entrada deslizada
var combo_was_vis := [false, false]   # para detectar cuando aparece (y disparar el slide)

# menu de modo de rival
var dummy_ai_mode := true
var break_practice := false     # modo BREAK PRACTICE: la IA encadena combos y tú rompes
var menu_panel: ColorRect
var moves_panel: ColorRect
var moves_title: Label   # título de la lista (cambia según personaje)
var moves_col1: Label    # columna de MOVES (cambia según personaje)
var moves_fin: Label     # bloque SPECIALS & FINISHERS (cambia según personaje)
var menu_opts := []
var menu_sel := 0
# --- SELECCIÓN DE PERSONAJE ---
# cada personaje: id, nombre, arquetipo (vida), avatar, frames de pelea, escala de sprite.
# Un personaje está "listo" (jugable) sólo si su recurso de frames existe.
const CHARS := [
	{"id": "dam",  "name": "DAM",  "arch": "assassin", "avatar": "res://imagen-action/dam/avatar/dam-avatar.png",  "frames": "res://fighter_frames.tres", "scale": 1.0},
	{"id": "favi", "name": "FE",   "arch": "assassin", "avatar": "res://imagen-action/favi/avatar/favi-avatar.png", "frames": "res://favi_frames.tres",   "scale": 0.82},
	{"id": "aye",  "name": "AYE",  "arch": "assassin", "avatar": "res://imagen-action/aye/avatar/aye-avatar.png",   "frames": "res://fighter_frames.tres", "scale": 0.78},
]
var char_panel: ColorRect
var char_cards := []            # [{border, av, name_lbl, wip_lbl, ready}] por personaje
var char_sel := 0              # índice de CHARS resaltado
var selected_char := "dam"    # personaje elegido por el jugador
var pending_mode := 0         # modo de pelea elegido antes de elegir personaje
var hud_name := [null, null]  # labels del nombre en el HUD [P1,P2]
var hud_avatar := [null, null] # sprites del avatar en el HUD [P1,P2]
var moves_sel := 0
var moves_items := []
var pinned_combo := -1
# BREAK epico: baner gigante + fogonazo de pantalla
var break_node: Node2D
var flash_rect: ColorRect
var ultra_panel: TextureRect          # paneles manga a pantalla completa durante el ultra
var ultra_panels: Array = []          # texturas ultra-1..6 (líneas de acción)
var break_t := 0.0
var flash_t := 0.0
var code_stage: Node2D = null  # escenario activo (para el tinte de combo)
var ultra_active := false       # ULTRA COMBO en curso (auto-ejecutado)
var ultra_largo := false        # version larga (APOCALIPSIS): dos tandas + cambio de lado
var ultra_hint: Label           # aviso "→ R ANIQUILACIÓN" en pantalla
var break_banners := []        # carteles inclinados que entran deslizando desde el borde
var break_side := -1           # -1 = breaker a la izquierda (carteles izq), 1 = derecha
var break_ms := -100000        # reloj REAL del inicio del break (ticks msec)
var flash_ms := -100000
# TEMBLOR de pantalla (sacude el nodo raíz Main; la UI en CanvasLayer no tiembla)
var shake_end_ms := -100000
var shake_amp := 0.0
var shake_dur_ms := 1
# CUT-IN cinemático del INFIERNO: retrato de DAM que ENTRA desde un lado (según el
# facing) sobre una banda roja diagonal con líneas de velocidad. Estilo P4A.
var cutin_root: Control = null
var cutin_dark: ColorRect
var cutin_band: ColorRect
var cutin_lines := []
var cutin_manga: TextureRect          # líneas de acción manga (ultra-1..6) que ciclan
var cutin_portrait: TextureRect
var cutin_flash: ColorRect
var cutin_ms := -100000
var cutin_side := -1
const CUTIN_BG := 0.22     # el panel/líneas SUBEN de abajo hacia arriba
const CUTIN_IN := 0.26     # ...y DESPUÉS entra el personaje
const CUTIN_HOLD := 0.52   # aguanta durante el FRAME CONGELADO (freeze largo)
const CUTIN_OUT := 0.40    # ...y se va mientras corren los frames del rayo
const CUTIN_PW := 776.0
const CUTIN_PH := 1150.0
# ANUNCIOS épicos (READY / FIGHT / K.O.) con fuente gruesa + SOMBRA PLANA + animación
var anno_root: Control = null
var anno_main: Label
var anno_sh: Label
var anno_ms := -100000
var anno_dur := 0.0
var anno_side := -1            # lado por el que ENTRA (-1 izq, +1 der); sale por el opuesto
var ko_red: ColorRect = null       # velo ROJO del KO (detrás de los peleadores)
var ko_lines: TextureRect = null   # líneas del ultra en el KO (detrás, tintadas rojo)
var win_portrait: TextureRect = null   # retrato del GANADOR (estilo cut-in del inferno)
# ENFOQUE épico del ULTRA: borde rojo eléctrico en el atacante + escena oscurecida
var _outline_mat: ShaderMaterial = null
var pin_panel: ColorRect
var pin_label: Label
var pin_success_t := 0.0
var combo_seq := []   # secuencia de golpes del combo actual del jugador
# secuencia exacta que debe ejecutar el jugador para el SUCCESS de cada combo
const COMBO_SEQS := {
	"triple": ["weak_punch", "punch", "kick"],
	"rdqw": ["weak_punch", "punch", "punch2", "kick"],
	"dqw": ["punch", "punch2", "kick"],
	"rql": ["weak_punch", "punch", "crouch_kick"],
	"rqe": ["weak_punch", "punch", "spin_kick"],
	"g5": ["weak_punch", "crouch_punch", "punch", "punch2", "kick"],
	"juggle": ["crouch_kick", "jump_punch", "air_spin_kick"],
	"corner": ["crouch_kick", "punch", "crouch_kick"],
	"m7": ["weak_punch", "crouch_punch", "punch", "punch2", "crouch_kick", "jump_punch", "air_spin_kick"],
	"a9": ["weak_punch", "crouch_punch", "punch", "punch2", "crouch_kick", "punch", "crouch_kick", "jump_punch", "air_spin_kick"],
}
const DEMO_COMBOS := [
	["R,  Q,  W   —   TRIPLE (3)", "triple"],
	["R,  →+Q,  W   —   4 hits", "rdqw"],
	["→+Q,  W   —   TRIPLE (3)", "dqw"],
	["R,  Q,  ↓+W   —   launcher", "rql"],
	["R,  Q,  E   —   spin kick", "rqe"],
	["R, ↓+Q, →+Q, W   —   GREAT (5)", "g5"],
	["↓+W, jump, air Q, air E  (4)", "juggle"],
	["Corner: ↓+W, wall, Q, ↓+W  (4)", "corner"],
	["R, ↓+Q, →+Q, ↓+W, air Q, E — MASTER (7)", "m7"],
	["Corner AWESOME — 9 hits", "a9"],
]

func _ready() -> void:
	dummy.ai_target = player
	# vida máxima según el arquetipo de cada peleador (assassin/wizard/warrior)
	hp_max[0] = int(ARCH_HP.get(player.archetype, 1200))
	hp_max[1] = int(ARCH_HP.get(dummy.archetype, 1200))
	player_hp = hp_max[0]
	dummy_hp = hp_max[1]
	ding_player = AudioStreamPlayer.new()
	ding_player.volume_db = -3.0
	add_child(ding_player)
	voz_player = AudioStreamPlayer.new()      # gritos de finisher (voz infernal)
	voz_player.volume_db = 1.0
	add_child(voz_player)
	kick_voz_player = AudioStreamPlayer.new() # grito furioso de la patada giratoria (E)
	kick_voz_player.volume_db = 0.0
	add_child(kick_voz_player)
	_build_hud()                              # meter de 3 segmentos + avatares
	# nota de GUITARRA aguda (guitar-hit) en vez de la campana; sube por la escala
	# pentatónica con cada golpe (via pitch_scale en cada hit del combo).
	if ResourceLoader.exists("res://imagen-action/sound-effect/guitar-hit.wav"):
		ding_stream = load("res://imagen-action/sound-effect/guitar-hit.wav")
	elif ResourceLoader.exists("res://imagen-action/sound-effect/combo-ding.wav"):
		ding_stream = load("res://imagen-action/sound-effect/combo-ding.wav")
	# el cierre de ventana lo maneja _notification (para apagar el audio antes de quit)
	get_tree().set_auto_accept_quit(false)
	# musica de fondo en loop, bajita
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -14.0   # ambiente (sound-guitar) un poco más alto
	add_child(music_player)
	var ruta_bg := "res://imagen-action/sound-effect/sound-guitar.mp3"
	if ResourceLoader.exists(ruta_bg):
		var bg_stream = load(ruta_bg)
		if bg_stream is AudioStreamOggVorbis:
			bg_stream.loop = true          # repite sin cortes
		elif bg_stream is AudioStreamMP3:
			bg_stream.loop = true          # loop del MP3 (sound-guitar)
		music_player.stream = bg_stream
		music_player.play()
	# fuente heavy para el contador de combo (Arial Black: la mejor display del Mac)
	combo_font = SystemFont.new()
	combo_font.font_names = PackedStringArray(["Arial Black", "Impact", "Helvetica Neue", "Arial"])
	combo_font.font_weight = 900
	for i in 2:
		var c := Node2D.new()
		c.position = Vector2(270, 335) if i == 0 else Vector2(1650, 335)
		c.visible = false
		$UI.add_child(c)
		# NÚMERO FANTASMA gigante detrás (estilo GG Strive): semitransparente, enorme,
		# se agrega PRIMERO para quedar por detrás de las bandas/número nítido
		var gh := Label.new()
		gh.add_theme_font_override("font", combo_font)
		gh.add_theme_font_size_override("font_size", 340)
		gh.add_theme_color_override("font_color", Color(1, 1, 1, 0.13))
		gh.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.18))
		gh.add_theme_constant_override("outline_size", 10)
		gh.position = Vector2(-260, -330)
		gh.size = Vector2(520, 440)
		gh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gh.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		gh.rotation_degrees = -8.0
		gh.pivot_offset = Vector2(260, 220)
		gh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(gh)
		combo_ghost.append(gh)
		var slant := 18.0
		var HW := 186.0   # medio ancho: las dos bandas comparten el MISMO centro y bordes
		# --- BANDA del número: cartel VERDE inclinado (mismo estilo del BREAK) ---
		var nb_poly := PackedVector2Array([Vector2(-HW + slant, -100), Vector2(HW + slant, -100),
				Vector2(HW - slant, 8), Vector2(-HW - slant, 8)])
		var nb_sh := Polygon2D.new()
		nb_sh.polygon = nb_poly
		nb_sh.color = Color(0, 0, 0, 0.32)
		nb_sh.position = Vector2(6, 8)
		c.add_child(nb_sh)
		var nb := Polygon2D.new()
		nb.polygon = nb_poly
		nb.color = Color(0.62, 0.86, 0.16)
		c.add_child(nb)
		combo_band.append(nb)   # se recolorea (verde->rojo) según crece el combo
		# CARA/OJOS del atacante como fondo del panel (encima del color, bajo el número)
		var fc := Polygon2D.new()
		fc.polygon = nb_poly
		fc.color = Color(1, 1, 1, 0.62)   # se blend con la banda de color de abajo
		c.add_child(fc)
		combo_face.append(fc)
		# número gigante BLANCO con contorno oscuro (resalta sobre el verde), centrado
		var n := Label.new()
		n.add_theme_font_override("font", combo_font)
		n.add_theme_font_size_override("font_size", 128)
		n.add_theme_color_override("font_color", Color(1, 1, 1))
		n.add_theme_color_override("font_outline_color", Color(0.05, 0.07, 0.02))
		n.add_theme_constant_override("outline_size", 12)
		n.position = Vector2(-HW, -134)
		n.size = Vector2(2.0 * HW, 128)
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		n.rotation_degrees = -5.0
		n.pivot_offset = Vector2(HW, 64)
		c.add_child(n)
		# etiqueta "HITS" pequeña, PEGADA a la derecha del número
		# (mismo estilo: blanco con contorno oscuro)
		var g := Label.new()
		g.text = "HITS"
		g.add_theme_font_override("font", combo_font)
		g.add_theme_font_size_override("font_size", 26)
		g.add_theme_color_override("font_color", Color(1, 1, 1))
		g.add_theme_color_override("font_outline_color", Color(0.05, 0.07, 0.02))
		g.add_theme_constant_override("outline_size", 6)
		g.position = Vector2(72, -8)
		g.size = Vector2(120, 36)
		g.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		g.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		g.rotation_degrees = -5.0
		c.add_child(g)
		# --- BANDA del rango: cartel OSCURO inclinado, ALINEADO bajo la verde ---
		var rb_poly := PackedVector2Array([Vector2(-HW + slant, 20), Vector2(HW + slant, 20),
				Vector2(HW - slant, 78), Vector2(-HW - slant, 78)])
		var rb_sh := Polygon2D.new()
		rb_sh.polygon = rb_poly
		rb_sh.color = Color(0, 0, 0, 0.3)
		rb_sh.position = Vector2(6, 7)
		c.add_child(rb_sh)
		var rb := Polygon2D.new()
		rb.polygon = rb_poly
		rb.color = Color(0.13, 0.14, 0.17, 0.97)
		c.add_child(rb)
		var nm := Label.new()
		nm.add_theme_font_override("font", combo_font)
		nm.add_theme_font_size_override("font_size", 42)
		nm.add_theme_color_override("font_color",
				Color(1.0, 0.9, 0.35) if i == 0 else Color(1.0, 0.55, 0.4))
		nm.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.5))
		nm.add_theme_constant_override("outline_size", 6)
		nm.position = Vector2(-HW, 22)
		nm.size = Vector2(2.0 * HW, 58)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		nm.rotation_degrees = -5.0
		nm.pivot_offset = Vector2(HW, 29)
		c.add_child(nm)
		# daño total del combo, centrado debajo
		var dl := Label.new()
		dl.add_theme_font_size_override("font_size", 28)
		dl.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
		dl.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
		dl.add_theme_constant_override("outline_size", 9)
		dl.position = Vector2(-HW, 88)
		dl.size = Vector2(2.0 * HW, 40)
		dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		c.add_child(dl)
		combo_ui.append(c)
		combo_num.append(n)
		combo_nom.append(nm)
		combo_dmg_lbl.append(dl)
	# fogonazo de pantalla del BREAK (encima de todo, invisible en reposo)
	flash_rect = ColorRect.new()
	flash_rect.size = Vector2(1920, 1080)
	flash_rect.color = Color(1, 1, 1, 0.0)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.add_child(flash_rect)
	# paneles manga (líneas de acción) a pantalla completa durante el ULTRA:
	# van SOBRE los peleadores pero DEBAJO del contador de combo (se agregan antes)
	ultra_panel = TextureRect.new()
	ultra_panel.size = Vector2(1920, 1080)
	ultra_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ultra_panel.stretch_mode = TextureRect.STRETCH_SCALE
	ultra_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ultra_panel.visible = false
	ultra_panel.z_index = 3   # POR ENCIMA del flash (z=0) para que el fogonazo no lo lave
	$UI.add_child(ultra_panel)
	for i in range(1, 7):
		var t := load("res://imagen-action/impact-effect/ultra/ultra-%d.png" % i)
		if t != null:
			ultra_panels.append(t)
	# aviso "→ R  ULTRA!" cuando el comando esta habilitado (rival en rojo + combo)
	ultra_hint = Label.new()
	ultra_hint.text = "→ R   ANNIHILATION"
	ultra_hint.add_theme_font_size_override("font_size", 44)
	ultra_hint.add_theme_color_override("font_color", Color(1.6, 0.85, 0.2))
	ultra_hint.add_theme_color_override("font_outline_color", Color(0.15, 0.02, 0.02))
	ultra_hint.add_theme_constant_override("outline_size", 12)
	ultra_hint.position = Vector2(660, 150)
	ultra_hint.size = Vector2(600, 60)
	ultra_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ultra_hint.visible = false
	$UI.add_child(ultra_hint)
	# BREAK estilo carteles: dos BANDAS INCLINADAS que ENTRAN deslizándose desde
	# el borde izquierdo, con palabras distintas (animadas con reloj REAL en _process)
	break_node = Node2D.new()
	break_node.visible = false
	$UI.add_child(break_node)
	break_banners.clear()
	# los dos carteles se ENCABALGAN (verde arriba al frente, gris abajo corrido a la
	# derecha), como en la referencia. z: mayor = al frente. xo: corrimiento lateral.
	var defs := [
		{"txt": "BREAK!", "bar": Color(0.62, 0.86, 0.16), "fg": Color(0.08, 0.11, 0.02),
			"y": 600.0, "xo": 0.0, "z": 2, "delay": 0.0, "w": 640.0, "h": 122.0, "fs": 98},
		{"txt": "COUNTER!", "bar": Color(0.13, 0.14, 0.17, 0.97), "fg": Color(1, 1, 1),
			"y": 686.0, "xo": 110.0, "z": 1, "delay": 0.10, "w": 740.0, "h": 108.0, "fs": 84},
	]
	for d in defs:
		var b := Node2D.new()
		b.rotation_degrees = -6.0
		b.z_index = int(d["z"])       # el verde (z mayor) queda al frente
		b.visible = false
		break_node.add_child(b)
		var ww: float = d["w"]
		var hh: float = d["h"]
		var slant := 36.0
		# sombra desplazada de la banda
		var sh := Polygon2D.new()
		sh.polygon = PackedVector2Array([Vector2(slant, -hh * 0.5), Vector2(ww, -hh * 0.5),
				Vector2(ww - slant, hh * 0.5), Vector2(0.0, hh * 0.5)])
		sh.color = Color(0, 0, 0, 0.35)
		sh.position = Vector2(10, 12)
		b.add_child(sh)
		# banda (parallelogramo inclinado)
		var bar := Polygon2D.new()
		bar.polygon = PackedVector2Array([Vector2(slant, -hh * 0.5), Vector2(ww, -hh * 0.5),
				Vector2(ww - slant, hh * 0.5), Vector2(0.0, hh * 0.5)])
		bar.color = d["bar"]
		b.add_child(bar)
		# palabra en negrita (sombra + relleno)
		var lsh := Label.new()
		lsh.text = d["txt"]
		lsh.add_theme_font_size_override("font_size", int(d["fs"]))
		lsh.add_theme_color_override("font_color", Color(0, 0, 0, 0.4))
		lsh.position = Vector2(slant + 34.0 + 6.0, -hh * 0.5 + 6.0)
		lsh.size = Vector2(ww, hh)
		lsh.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		b.add_child(lsh)
		var lab := Label.new()
		lab.text = d["txt"]
		lab.add_theme_font_size_override("font_size", int(d["fs"]))
		lab.add_theme_color_override("font_color", d["fg"])
		lab.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.5))
		lab.add_theme_constant_override("outline_size", 5)
		lab.position = Vector2(slant + 34.0, -hh * 0.5)
		lab.size = Vector2(ww, hh)
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		b.add_child(lab)
		var yy: float = d["y"]
		# la posición de reposo/entrada se calcula en _process según el lado del breaker
		break_banners.append({"node": b, "w": ww, "y": yy, "xo": float(d["xo"]),
				"delay": float(d["delay"])})
	if STAGE >= 2:
		for n in CITY_NODES:
			get_node(n).visible = false
		var esc: Node2D
		if STAGE == 2:
			esc = preload("res://night_stage.gd").new()
		else:
			esc = preload("res://templo_stage.gd").new()
		esc.name = "CodeStage"
		add_child(esc)
		code_stage = esc
	_build_cutin()      # cut-in del INFIERNO: detrás de la acción, delante del escenario
	_build_announce()   # anuncios + KO + retrato del ganador: DETRÁS de los peleadores
	var mp := ColorRect.new()
	mp.color = Color(0.03, 0.03, 0.07, 0.88)
	mp.position = Vector2(610, 300)
	mp.size = Vector2(700, 540)
	mp.visible = false
	$UI.add_child(mp)
	menu_panel = mp
	var ti := Label.new()
	ti.text = "OPPONENT MODE"
	ti.add_theme_font_size_override("font_size", 46)
	ti.position = Vector2(0, 30)
	ti.size = Vector2(700, 60)
	ti.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mp.add_child(ti)
	for j in 4:
		var o := Label.new()
		o.add_theme_font_size_override("font_size", 38)
		o.position = Vector2(0, 120 + j * 80)
		o.size = Vector2(700, 60)
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mp.add_child(o)
		menu_opts.append(o)
	var hint := Label.new()
	hint.text = "↑ ↓  select      Q  confirm      (ESC in fight: back to menu)"
	hint.add_theme_font_size_override("font_size", 20)
	hint.add_theme_color_override("font_color", Color(0.65, 0.65, 0.7))
	hint.position = Vector2(0, 480)
	hint.size = Vector2(700, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mp.add_child(hint)
	# --- PANEL DE SELECCIÓN DE PERSONAJE ---
	var cp := ColorRect.new()
	cp.color = Color(0.03, 0.03, 0.07, 0.92)
	cp.position = Vector2(360, 150)
	cp.size = Vector2(1200, 760)
	cp.visible = false
	$UI.add_child(cp)
	char_panel = cp
	var ct := Label.new()
	ct.text = "SELECT YOUR FIGHTER"
	ct.add_theme_font_size_override("font_size", 48)
	ct.position = Vector2(0, 40); ct.size = Vector2(1200, 60)
	ct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cp.add_child(ct)
	char_cards = []
	for i in CHARS.size():
		var c: Dictionary = CHARS[i]
		var cardx := 195.0 + i * 285.0
		var border := ColorRect.new()
		border.color = Color(0, 0, 0)
		border.position = Vector2(cardx, 165); border.size = Vector2(240, 336)
		cp.add_child(border)
		var inner := ColorRect.new()
		inner.color = Color(0.09, 0.09, 0.13)
		inner.position = Vector2(cardx + 6, 171); inner.size = Vector2(228, 324)
		cp.add_child(inner)
		var av := Sprite2D.new()
		if ResourceLoader.exists(String(c["avatar"])):
			av.texture = load(String(c["avatar"]))
		av.centered = true
		_cover_avatar(av, 186, 202)   # las 3 cartas al MISMO tamaño, con margen dentro del marco
		av.position = Vector2(cardx + 120, 288)
		cp.add_child(av)
		var nm := Label.new()
		nm.text = String(c["name"])
		nm.add_theme_font_size_override("font_size", 34)
		nm.position = Vector2(cardx, 400); nm.size = Vector2(240, 46)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cp.add_child(nm)
		char_cards.append({"border": border, "av": av, "name": nm})
	var chint := Label.new()
	chint.text = "←  →   choose        Q  confirm        ESC  back"
	chint.add_theme_font_size_override("font_size", 22)
	chint.add_theme_color_override("font_color", Color(0.65, 0.65, 0.7))
	chint.position = Vector2(0, 690); chint.size = Vector2(1200, 40)
	chint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cp.add_child(chint)
	var vp := ColorRect.new()
	vp.color = Color(0.03, 0.03, 0.07, 0.93)
	vp.position = Vector2(310, 110)
	vp.size = Vector2(1300, 850)
	vp.visible = false
	$UI.add_child(vp)
	moves_panel = vp
	var vt := Label.new()
	vt.text = "DAM — MOVE LIST"
	vt.add_theme_font_size_override("font_size", 46)
	vt.position = Vector2(0, 26)
	vt.size = Vector2(1300, 60)
	vt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vp.add_child(vt)
	moves_title = vt
	var col1 := Label.new()
	col1.add_theme_font_size_override("font_size", 24)
	col1.position = Vector2(80, 118)
	col1.size = Vector2(560, 520)
	col1.text = "MOVES:\n\nR  —  Quick jab (4)\n↓ + R  —  Low jab (4)\nQ  —  Horizontal slash (8)\n→ + Q  —  Double slash (8+6)\n↓ ↘ →  + Q  —  EMBER DASH (15), wall slam\nW  —  Heavy slash (12)\n↓ + Q  —  Crouch slash (6)\n↓ + W  —  Rising launcher (9) ▲\nE  —  Traveling spin kick (13) ▲\n↓ + E  —  Ground sweep (12) ▼\nJump + Q  —  Air slash (9)\nJump + W  —  Dive kick (10)\nJump + E  —  Somersault kick (13) ▲\nJump + R  —  Air double slash\nJump →  —  forward flip\n\n▲ = launches into the air     ▼ = knocks down"
	vp.add_child(col1)
	moves_col1 = col1
	# divisiones: linea bajo el titulo, columna central y pie
	for dv in [[80.0, 98.0, 1140.0, 3.0], [648.0, 115.0, 3.0, 660.0], [80.0, 780.0, 1140.0, 3.0]]:
		var linea := ColorRect.new()
		linea.position = Vector2(dv[0], dv[1])
		linea.size = Vector2(dv[2], dv[3])
		linea.color = Color(0.95, 0.75, 0.3, 0.45)
		vp.add_child(linea)
	var ch := Label.new()
	ch.text = "COMBOS   (Q = watch demo)"
	ch.add_theme_font_size_override("font_size", 28)
	ch.add_theme_color_override("font_color", Color(0.95, 0.8, 0.4))
	ch.position = Vector2(690, 120)
	ch.size = Vector2(560, 40)
	vp.add_child(ch)
	for k in DEMO_COMBOS.size():
		var it := Label.new()
		it.add_theme_font_size_override("font_size", 22)
		it.position = Vector2(690, 158 + k * 44)
		it.size = Vector2(590, 42)
		vp.add_child(it)
		moves_items.append(it)
	# reglas de combo (movidas a la columna izquierda, bajo los golpes)
	var regla := Label.new()
	regla.text = "Combo rules: never repeat a move,\ngo WEAK → STRONG (R → Q → W → E).\nIn the air the ladder is free."
	regla.add_theme_font_size_override("font_size", 21)
	regla.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	regla.position = Vector2(80, 648)
	regla.size = Vector2(560, 90)
	vp.add_child(regla)
	# separador dorado y bloque FINISHERS & POWER (derecha, bajo los combos)
	var fsep := ColorRect.new()
	fsep.position = Vector2(690, 604)
	fsep.size = Vector2(600, 3)
	fsep.color = Color(1.0, 0.6, 0.2, 0.6)
	vp.add_child(fsep)
	var fin := Label.new()
	fin.add_theme_font_size_override("font_size", 22)
	fin.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28))
	fin.add_theme_color_override("font_outline_color", Color(0.22, 0.03, 0.0))
	fin.add_theme_constant_override("outline_size", 4)
	fin.position = Vector2(690, 616)
	fin.size = Vector2(600, 190)
	fin.text = "★  SPECIALS  &  FINISHERS\n↑ + E  —  Combo Breaker (while hit, 1/round)\n↓ ↓ + E  —  INFERNO · his power\n        (after a 7-hit combo · 50 dmg)\n→ R  —  ANNIHILATION · short ultra (16 hits)\n→ E  —  APOCALYPSE · long ultra (31 hits)\n        ultras: 3-hit combo + rival ≤ 25% HP"
	vp.add_child(fin)
	moves_fin = fin
	var vb := Label.new()
	vb.text = "↑↓ select    Q watch demo    W pin/unpin on screen    ESC back"
	vb.add_theme_font_size_override("font_size", 26)
	vb.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	vb.position = Vector2(0, 790)
	vb.size = Vector2(1300, 40)
	vb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vp.add_child(vb)
	var pp := ColorRect.new()
	pp.color = Color(0.03, 0.03, 0.07, 0.82)
	pp.position = Vector2(560, 86)
	pp.size = Vector2(800, 48)
	pp.visible = false
	$UI.add_child(pp)
	pin_panel = pp
	var pl := Label.new()
	pl.add_theme_font_size_override("font_size", 26)
	pl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	pl.position = Vector2(0, 6)
	pl.size = Vector2(800, 36)
	pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pp.add_child(pl)
	pin_label = pl
	if TRAINING:
		_enter_training()
	else:
		_open_menu()

func _open_menu() -> void:
	state = "menu"
	break_practice = false
	dummy.ai_break_drill = false
	player.input_enabled = false
	dummy.ai_enabled = false
	player.revive()
	dummy.revive()
	player.position = Vector2(630, 625)
	dummy.position = Vector2(1290, 625)
	player.set_facing(1)
	dummy.set_facing(-1)
	announce.visible = false
	for i in 2:
		combo_n[i] = 0
		combo_ui[i].visible = false
	if moves_panel:
		moves_panel.visible = false
	menu_panel.visible = true

func _enter_training() -> void:
	state = "training"
	dummy.visible = false
	dummy.ai_enabled = false
	for n in CITY_NODES:
		get_node(n).visible = false
	if has_node("CodeStage"):
		get_node("CodeStage").visible = false
	$UI.visible = false
	player.set_facing(1)
	player.input_enabled = true

func meter_can_break(quien: Node2D) -> bool:
	# se puede romper si el breaker tiene al menos ½ barra (salvo en BREAK PRACTICE)
	if break_practice:
		return true
	var i := 0 if quien == player else 1
	return meter[i] >= 0.5

func on_breaker(quien: Node2D) -> void:
	var b_idx := 0 if quien == player else 1
	meter[b_idx] = maxf(0.0, meter[b_idx] - 0.5)   # romper gasta ½ barra
	var otro: Node2D = dummy if quien == player else player
	var dir := 1.0 if otro.position.x >= quien.position.x else -1.0
	otro.position.x = clampf(otro.position.x + dir * 240.0, LEFT_LIMIT, RIGHT_LIMIT)
	# el atacante RECIBE el golpe del mortal del breaker
	if not otro.koed:
		otro.receive_hit(false, false, int(dir), "kick_impact")
	var idx := 1 if quien == player else 0
	combo_n[idx] = 0
	combo_t[idx] = 99.0
	combo_ui[idx].visible = false
	# los carteles se anclan al lado donde está QUIEN rompe (no se salen del borde)
	break_side = 1 if quien.position.x >= 960.0 else -1
	# BREAK de cine: CONGELADO total -> camara lenta -> normal, con fogonazo
	# y carteles entrando (las anima _process con reloj real, inmune al congelado)
	break_ms = Time.get_ticks_msec()
	flash_ms = break_ms
	flash_rect.color = Color(1.0, 0.55, 0.2, 0.55)
	Engine.time_scale = 0.0
	get_tree().create_timer(0.14, true, false, true).timeout.connect(
		func() -> void: Engine.time_scale = 0.25)
	get_tree().create_timer(0.55, true, false, true).timeout.connect(
		func() -> void: Engine.time_scale = 1.0)

func _hide_announce_soon() -> void:
	await get_tree().create_timer(0.6).timeout
	if state == "fight" or state == "demo":
		announce.visible = false

# pone el título / MOVES / FINISHERS de la lista según el personaje ELEGIDO
func _set_moves_text() -> void:
	if moves_title == null:
		return
	if selected_char == "favi":
		moves_title.text = "FE — MOVE LIST"
		moves_col1.text = "MOVES:\n\nR  —  Quick needle jab (4)\n↓ + R  —  Low needle jab (4)\nQ  —  Scissor slash (10)\n→ + Q  —  Double scissor\nW  —  Heavy scissor (10)\n↓ + Q  —  Crouch scissor (3)\n↓ + W  —  Rising needles (5) ▲\nE  —  Needle spin · 2 hits\n↓ + E  —  Ground sweep (6) ▼\nJump + Q  —  Air scissor (4)\nJump + W  —  Dive needle (4)\nJump + E  —  Air somersault (8) ▲\n\n▲ = launches into the air     ▼ = knocks down"
		moves_fin.text = "★  SPECIALS  &  FINISHERS  (meter: ↑E=2 · ↓←E=1)\n↑ + E  —  Combo Breaker (while hit) · or ANNIHILATION ultra\n        (2 bars + 3-hit combo + rival ≤25% HP)\n↓ → + R  —  APOCALYPSE · long ultra (3 bars + combo + rival ≤25% HP)\n↓ ↘ → + Q/W/E  —  WATER GEYSER · 1/2/3 bodies\n← → + Q  —  NEEDLE DASH · rush, 3-hit combo\n↓ ← + E  —  WHIRLPOOL · 1 bar + combo (deadly spin ~40% HP)\nJump →  —  forward flip   ·   Jump + R  —  air double kick"
	else:
		moves_title.text = "DAM — MOVE LIST"
		moves_col1.text = "MOVES:\n\nR  —  Quick jab (4)\n↓ + R  —  Low jab (4)\nQ  —  Horizontal slash (8)\n→ + Q  —  Double slash (8+6)\n↓ ↘ →  + Q  —  EMBER DASH (15), wall slam\nW  —  Heavy slash (12)\n↓ + Q  —  Crouch slash (6)\n↓ + W  —  Rising launcher (9) ▲\nE  —  Traveling spin kick (13) ▲\n↓ + E  —  Ground sweep (12) ▼\nJump + Q  —  Air slash (9)\nJump + W  —  Dive kick (10)\nJump + E  —  Somersault kick (13) ▲\n\n▲ = launches into the air     ▼ = knocks down"
		moves_fin.text = "★  SPECIALS  &  FINISHERS\n↑ + E  —  Combo Breaker (while hit, 1/round)\n↓ ↓ + E  —  INFERNO · his power\n        (after a 7-hit combo · 50 dmg)\n→ R  —  ANNIHILATION · short ultra (16 hits)\n→ E  —  APOCALYPSE · long ultra (31 hits)\n        ultras: 3-hit combo + rival ≤ 25% HP"

func _open_moves() -> void:
	state = "moves"
	_set_moves_text()          # muestra los movimientos del personaje ELEGIDO (Fe o DAM)
	player.input_enabled = false
	dummy.ai_enabled = false
	player.revive()
	dummy.revive()
	player.position = Vector2(630, 625)
	dummy.position = Vector2(1290, 625)
	player.set_facing(1)
	dummy.set_facing(-1)
	announce.visible = false
	menu_panel.visible = false
	moves_panel.visible = true

func _dt(sec: float) -> Signal:
	return get_tree().create_timer(sec).timeout

func _demo_anim(a: String) -> void:
	if state == "demo":
		player.sprite.play(a)

func _demo_jump() -> void:
	if state == "demo":
		player.airborne = true
		player.vel_y = -player.JUMP_SPEED
		player.sprite.play("jump")

var demo_glide_t := 0.0

func _demo_snap() -> void:
	# asistencia de demo: activa un deslizamiento rapido hacia el rival
	# (el movimiento real pasa en _physics_process — nada de teleport)
	if state == "demo":
		demo_glide_t = 0.16

func _run_demo(id: String) -> void:
	pinned_combo = moves_sel  # ver un demo lo deja fijado en pantalla
	state = "demo"
	moves_panel.visible = false
	menu_panel.visible = false
	player.input_enabled = false
	dummy.ai_enabled = false
	var prev_mode := dummy_ai_mode
	dummy_ai_mode = false
	player.revive()
	dummy.revive()
	player_hp = hp_max[0]
	dummy_hp = hp_max[1]
	for i in 2:
		combo_n[i] = 0
		combo_t[i] = 99.0
		combo_last[i] = ""
		combo_ui[i].visible = false
	if id in ["corner", "a9", "l11"]:
		player.position = Vector2(1280, 625)
		dummy.position = Vector2(1560, 625)
	else:
		player.position = Vector2(820, 625)
		dummy.position = Vector2(1120, 625)
	player.set_facing(1)
	dummy.set_facing(-1)
	announce.visible = true
	announce.text = "DEMO"
	await _dt(0.8)
	announce.visible = false
	if state != "demo":
		dummy_ai_mode = prev_mode
		return
	match id:
		"triple":
			_demo_anim("weak_punch")
			await _dt(0.22)
			_demo_anim("punch")
			await _dt(0.32)
			_demo_anim("kick")
			await _dt(0.6)
		"rdqw":
			_demo_anim("weak_punch")
			await _dt(0.22)
			player.punch_followup = true
			_demo_anim("punch")
			await _dt(0.74)
			_demo_anim("kick")
			await _dt(0.6)
		"dqw":
			player.punch_followup = true
			_demo_anim("punch")
			await _dt(0.72)
			_demo_anim("kick")
			await _dt(0.6)
		"rqe":
			_demo_anim("weak_punch")
			await _dt(0.22)
			_demo_anim("punch")
			await _dt(0.32)
			_demo_anim("spin_kick")
			await _dt(1.2)
		"rql":
			_demo_anim("weak_punch")
			await _dt(0.22)
			_demo_anim("punch")
			await _dt(0.32)
			_demo_anim("crouch_kick")
			await _dt(0.8)
		"juggle":
			_demo_anim("crouch_kick")
			await _dt(0.5)
			if state == "demo":
				player.airborne = true
				player.vel_y = -player.JUMP_SPEED
				player.sprite.play("jump")
			await _dt(0.26)
			if state == "demo":
				player.position.x = clampf(dummy.position.x - 180.0, 115.0, 1805.0)
			_demo_anim("jump_punch")
			await _dt(0.42)
			if state == "demo":
				player.position.x = clampf(dummy.position.x - 180.0, 115.0, 1805.0)
			_demo_anim("air_spin_kick")
			await _dt(1.1)
		"corner":
			_demo_anim("crouch_kick")
			await _dt(1.0)
			if state == "demo":
				player.position.x = clampf(dummy.position.x - 300.0, 115.0, 1805.0)
			_demo_anim("punch")
			await _dt(0.5)
			_demo_anim("crouch_kick")
			await _dt(0.9)
		"g5":
			_demo_anim("weak_punch")
			await _dt(0.22)
			_demo_anim("crouch_punch")
			await _dt(0.26)
			player.punch_followup = true
			_demo_anim("punch")
			await _dt(0.74)
			_demo_anim("kick")
			await _dt(0.6)
		"m7":
			_demo_anim("weak_punch")
			await _dt(0.22)
			_demo_anim("crouch_punch")
			await _dt(0.26)
			player.punch_followup = true
			_demo_anim("punch")
			await _dt(0.74)
			_demo_anim("crouch_kick")
			await _dt(0.5)
			_demo_jump()
			await _dt(0.26)
			_demo_snap()
			_demo_anim("jump_punch")
			await _dt(0.42)
			_demo_snap()
			_demo_anim("air_spin_kick")
			await _dt(0.3)
			_demo_snap()
			await _dt(0.9)
		"a9":
			_demo_anim("weak_punch")
			await _dt(0.22)
			_demo_anim("crouch_punch")
			await _dt(0.26)
			player.punch_followup = true
			_demo_anim("punch")
			await _dt(0.74)
			_demo_anim("crouch_kick")
			await _dt(1.0)
			if state == "demo":
				player.position.x = clampf(dummy.position.x - 300.0, 115.0, 1805.0)
			_demo_anim("punch")
			await _dt(0.5)
			_demo_anim("crouch_kick")
			await _dt(0.5)
			_demo_jump()
			await _dt(0.26)
			_demo_snap()
			_demo_anim("jump_punch")
			await _dt(0.42)
			_demo_snap()
			_demo_anim("air_spin_kick")
			await _dt(0.3)
			_demo_snap()
			await _dt(0.9)
		"l11":
			_demo_anim("weak_punch")
			await _dt(0.22)
			_demo_anim("crouch_punch")
			await _dt(0.26)
			player.punch_followup = true
			_demo_anim("punch")
			await _dt(0.74)
			_demo_anim("crouch_kick")
			await _dt(0.5)
			_demo_jump()
			await _dt(0.26)
			_demo_snap()
			_demo_anim("jump_punch")
			await _dt(0.42)
			_demo_snap()
			_demo_anim("air_spin_kick")
			await _dt(0.3)
			_demo_snap()
			await _dt(0.8)
			if state == "demo":
				player.position.x = clampf(dummy.position.x - 300.0, 115.0, 1805.0)
			_demo_anim("punch")
			await _dt(0.5)
			_demo_anim("crouch_kick")
			await _dt(0.5)
			_demo_jump()
			await _dt(0.26)
			_demo_snap()
			_demo_anim("jump_punch")
			await _dt(0.42)
			_demo_snap()
			_demo_anim("air_spin_kick")
			await _dt(0.3)
			_demo_snap()
			await _dt(0.9)
	await _dt(1.5)
	dummy_ai_mode = prev_mode
	if state == "demo":
		_open_moves()

# --- FRAMES DE FAVI (en código): espeja la estructura de DAM (mismos nombres, loop,
# speed y conteo). Usa los frames REALES de Favi donde existan (favi/<accion>/), y la
# POSE como placeholder para el resto — así es jugable ya y cada animación real se
# activa sola cuando la otra terminal procese su sheet.
# al CERRAR la ventana: parar la música y soltar el stream ANTES de quit(), si no el
# AudioServer de Godot deja el playback vivo y avisa "audio leaked / resource still in
# use at exit". Requiere set_auto_accept_quit(false) en _ready (lo maneja este handler).
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_cerrar_limpio()

func _cerrar_limpio() -> void:
	_apagar_audio()
	# darle 2 frames al AudioServer para vaciar el playback parado antes de salir
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit()

func _exit_tree() -> void:
	_apagar_audio()

func _apagar_audio() -> void:
	if is_instance_valid(music_player):
		music_player.stop()
		music_player.stream = null

func _favi_action_frames(accion: String) -> Array:
	for variante in [accion, accion.replace("_", "-")]:
		var out := []
		var i := 1
		while true:
			var p := "res://imagen-action/favi/%s/favi-%s-%d.png" % [variante, variante, i]
			if ResourceLoader.exists(p):
				out.append(load(p))
				i += 1
			else:
				break
		if not out.is_empty():
			return out
	return []

const FAVI_SPD := 1.2   # Favi es assassin ágil: anima y se desplaza ~20% más rápido que DAM
# Favi es una NENA de ~10 años al lado de DAM (joven adulto): se ve más baja.
const FAVI_SCALE := 0.85            # ~68% de la altura de DAM (su cabeza a la altura del pecho)
# En la textura (1300x1280, centrada) los pies están ~500px bajo el centro (feetY 1140 - 640).
# A escala 1.0 (como DAM) los pies caen en el PISO; para otra escala se compensa el offset
# para que los pies sigan cayendo en ese MISMO piso (y no floten ni se hundan).
const FAVI_FEET_FROM_CENTER := 500.0

# AYE (The Blooming Dynamo): NENA de ~5 años -> más baja aún que Fe. Ágil ("dynamo").
# Pre-cableada con PLACEHOLDER (los frames de DAM) hasta procesar sus hojas verdes.
const AYE_SPD := 1.25
const AYE_SCALE := 0.72            # ~5 años: más chica que Fe (0.85)
const AYE_FEET_FROM_CENTER := 500.0

# DAM un poco más grande (antes 1.0). base_scale también escala sus FX/estelas/sombras,
# así que sube proporcional. El offset compensa para que los pies sigan en el piso.
const DAM_SCALE := 1.10
const DAM_FEET_FROM_CENTER := 500.0

func _build_favi_frames() -> SpriteFrames:
	var dam := load("res://fighter_frames.tres") as SpriteFrames
	var sf := SpriteFrames.new()
	var pose := _favi_action_frames("pose")
	if pose.is_empty():
		pose = [load("res://imagen-action/favi/avatar/favi-avatar.png")]
	for anim in dam.get_animation_names():
		if not sf.has_animation(anim):
			sf.add_animation(anim)
		sf.set_animation_loop(anim, dam.get_animation_loop(anim))
		sf.set_animation_speed(anim, dam.get_animation_speed(anim) * FAVI_SPD)
		var real := _favi_action_frames(anim)
		if real.is_empty():
			var n: int = maxi(1, dam.get_frame_count(anim))   # placeholder pose, mismo conteo
			for i in n:
				sf.add_frame(anim, pose[i % pose.size()])
		else:
			for t in real:
				sf.add_frame(anim, t)
	# animación EXCLUSIVA de Fe: water_cast (especial de agua ↓↘→+W). Placeholder = pose
	# hasta tener water-cast-fe-sheet.png (5 frames) procesado en favi/water_cast/.
	if not sf.has_animation("water_cast"):
		sf.add_animation("water_cast")
	sf.set_animation_loop("water_cast", false)
	sf.set_animation_speed("water_cast", 15.0)   # cast RÁPIDO para poder encadenar el combo
	var wc := _favi_action_frames("water_cast")
	if wc.is_empty():
		for i in 5:
			sf.add_frame("water_cast", pose[i % pose.size()])
	else:
		for t in wc:
			sf.add_frame("water_cast", t)
	# DASH DE AGUJAS (←→+Q): animación EXCLUSIVA de Fe. Se agrega solo cuando existan los
	# frames reales (dash-strike-sheet); mientras tanto _start_fe_dash usa "punch" de placeholder.
	var dsh := _favi_action_frames("dash")
	if not dsh.is_empty():
		if not sf.has_animation("dash"):
			sf.add_animation("dash")
		sf.set_animation_loop("dash", false)
		sf.set_animation_speed("dash", 18.0)
		for t in dsh:
			sf.add_frame("dash", t)
	# WHIRLPOOL (finisher ↓←E): animación EXCLUSIVA de Fe (giro mortal con vórtice de agua).
	var whl := _favi_action_frames("whirlpool")
	if not whl.is_empty():
		if not sf.has_animation("whirlpool"):
			sf.add_animation("whirlpool")
		# HURACÁN: gira MUY RÁPIDO y en LOOP -> muchas vueltas durante el remate (golpea seguido)
		sf.set_animation_loop("whirlpool", true)
		sf.set_animation_speed("whirlpool", 34.0)   # 6 frames ~0.18s por vuelta = giro muy veloz
		for t in whl:
			sf.add_frame("whirlpool", t)
	# PATADA AÉREA DOBLE (salto+R): animación EXCLUSIVA de Fe (no existe en DAM).
	var aj := _favi_action_frames("air_jab")
	if not aj.is_empty():
		if not sf.has_animation("air_jab"):
			sf.add_animation("air_jab")
		sf.set_animation_loop("air_jab", false)
		sf.set_animation_speed("air_jab", 16.0)   # 4 frames ~0.25s = doble patadita rápida
		for t in aj:
			sf.add_frame("air_jab", t)
	# MORTAL AÉREO HACIA ADELANTE (salto + alante): flip que rota, EXCLUSIVA de Fe.
	var nsp := _favi_action_frames("neutral_spin")
	if not nsp.is_empty():
		if not sf.has_animation("neutral_spin"):
			sf.add_animation("neutral_spin")
		sf.set_animation_loop("neutral_spin", false)   # UN solo giro; luego cae (frame de salto)
		sf.set_animation_speed("neutral_spin", 18.0)
		for t in nsp:
			sf.add_frame("neutral_spin", t)
	# el mortal aéreo (salto+E) va MÁS RÁPIDO que el resto de las animaciones de Fe
	if sf.has_animation("air_spin_kick"):
		sf.set_animation_speed("air_spin_kick", sf.get_animation_speed("air_spin_kick") * 1.5)
	if sf.has_animation("default"):
		sf.remove_animation("default")
	return sf

func _char_data(id: String) -> Dictionary:
	for c in CHARS:
		if String(c["id"]) == id:
			return c
	return CHARS[0]

# aplica un personaje a un peleador: frames, arquetipo (vida) y escala de sprite
# --- FRAMES DE AYE (en código): espeja la estructura de DAM. Usa los frames REALES de Aye
# donde existan (aye/<accion>/aye-<accion>-N.png); si no, PLACEHOLDER = los frames de DAM.
func _aye_action_frames(accion: String) -> Array:
	for variante in [accion, accion.replace("_", "-")]:
		var out := []
		var i := 1
		while true:
			var p := "res://imagen-action/aye/%s/aye-%s-%d.png" % [variante, variante, i]
			if ResourceLoader.exists(p):
				out.append(load(p))
				i += 1
			else:
				break
		if not out.is_empty():
			return out
	return []

func _build_aye_frames() -> SpriteFrames:
	var dam := load("res://fighter_frames.tres") as SpriteFrames
	var sf := SpriteFrames.new()
	for anim in dam.get_animation_names():
		if not sf.has_animation(anim):
			sf.add_animation(anim)
		sf.set_animation_loop(anim, dam.get_animation_loop(anim))
		sf.set_animation_speed(anim, dam.get_animation_speed(anim) * AYE_SPD)
		var real := _aye_action_frames(anim)
		if real.is_empty():
			for i in dam.get_frame_count(anim):   # placeholder: frame de DAM
				sf.add_frame(anim, dam.get_frame_texture(anim, i))
		else:
			for t in real:
				sf.add_frame(anim, t)
	if sf.has_animation("default"):
		sf.remove_animation("default")
	return sf

# frames de DAM (fighter_frames.tres) + las animaciones NUEVAS por paridad con Fe (air_jab,
# neutral_spin) agregadas si ya existen sus frames. Se agrega UNA vez (el .tres es compartido).
func _dam_action_frames(accion: String) -> Array:
	var out := []
	var i := 1
	while true:
		var p := "res://imagen-action/dam/%s/dam-%s-%d.png" % [accion, accion, i]
		if ResourceLoader.exists(p):
			out.append(load(p))
			i += 1
		else:
			break
	return out

func _build_dam_frames() -> SpriteFrames:
	var sf := load("res://fighter_frames.tres") as SpriteFrames
	# Salto + R = DOBLE CORTE AÉREO (air_jab)
	if not sf.has_animation("air_jab"):
		var aj := _dam_action_frames("air_jab")
		if not aj.is_empty():
			sf.add_animation("air_jab")
			sf.set_animation_loop("air_jab", false)
			sf.set_animation_speed("air_jab", 16.0)
			for t in aj:
				sf.add_frame("air_jab", t)
	# Salto hacia adelante = MORTAL (neutral_spin)
	if not sf.has_animation("neutral_spin"):
		var ns := _dam_action_frames("neutral_spin")
		if not ns.is_empty():
			sf.add_animation("neutral_spin")
			sf.set_animation_loop("neutral_spin", false)   # UN solo giro; luego cae
			sf.set_animation_speed("neutral_spin", 13.0)   # DAM: un poco más lento que Fe
			for t in ns:
				sf.add_frame("neutral_spin", t)
	return sf

func _apply_char(f: Node2D, id: String) -> void:
	var c := _char_data(id)
	f.archetype = String(c["arch"])
	f.fx_blue = id == "favi"   # estela del arma AZUL para Favi (naranja fuego para DAM)
	f.fx_floral = id == "aye"  # estela MORADA+ROSA para Aye (se resetea para los demas)
	if id == "favi":
		f.sprite.sprite_frames = _build_favi_frames()
		# base_scale (no sprite.scale directo): el efecto squash del fighter reescribe
		# sprite.scale cada frame, así que la escala de personaje va en base_scale.
		f.base_scale = Vector2(FAVI_SCALE, FAVI_SCALE)
		f.sprite.scale = f.base_scale
		# anclar los PIES al MISMO piso que DAM (escala 1.0): que no floten ni se hundan.
		f.sprite.offset = Vector2(0, FAVI_FEET_FROM_CENTER / FAVI_SCALE - FAVI_FEET_FROM_CENTER)
		f.spd = FAVI_SPD   # desplazamiento más rápido para acompañar la animación ágil
	elif id == "aye":
		f.sprite.sprite_frames = _build_aye_frames()
		f.base_scale = Vector2(AYE_SCALE, AYE_SCALE)
		f.sprite.scale = f.base_scale
		f.sprite.offset = Vector2(0, AYE_FEET_FROM_CENTER / AYE_SCALE - AYE_FEET_FROM_CENTER)
		f.spd = AYE_SPD
	else:
		f.sprite.sprite_frames = _build_dam_frames()
		f.base_scale = Vector2(DAM_SCALE, DAM_SCALE)
		f.sprite.scale = f.base_scale
		f.sprite.offset = Vector2(0, DAM_FEET_FROM_CENTER / DAM_SCALE - DAM_FEET_FROM_CENTER)
		f.spd = 1.0
	f.sprite.play("pose")

# ESPECIAL DE AGUA de Fe (medialuna + Q/W/E): brota un géiser a 1/2/3 CUERPOS adelante.
# JUGGLE: Q lanza bajo, W más alto (rebote), E el más alto y fuerte. El lanzado sube
# pero casi NO se aleja (poco horizontal) para poder encadenar los tres castes en combo.
# Golpea en el suelo O en el aire si ya está en juggle (hit_flying), no si saltó a propósito.
const GEYSER_BODY := 350.0   # 1 "cuerpo" de distancia (clara, adelante de Fe) para el géiser
const WATER_DMG := [80, 110, 150]     # Q · W · E
const WATER_LIFT := [1.1, 1.5, 2.0]   # altura de lanzamiento por nivel (más alto = más hang-time)

# efecto visual del cast de Fe: borde AZUL eléctrico brillante + pocas partículas azules
var _fe_cast_mat: ShaderMaterial = null
var _fe_cast_particles: CPUParticles2D = null
func _fe_cast_fx(caster: Node2D, on: bool) -> void:
	if on:
		if _fe_cast_mat == null:
			var sh := Shader.new()
			sh.code = _OUTLINE_CODE
			_fe_cast_mat = ShaderMaterial.new()
			_fe_cast_mat.shader = sh
			_fe_cast_mat.set_shader_parameter("line_color", Color(0.35, 0.75, 2.0, 1.0))  # azul marino eléctrico
			_fe_cast_mat.set_shader_parameter("intensity", 0.95)
		caster.sprite.material = _fe_cast_mat
		if not is_instance_valid(_fe_cast_particles):
			var p := CPUParticles2D.new()
			p.amount = 14                      # pocas
			p.lifetime = 0.6
			p.one_shot = false
			p.local_coords = false
			p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			p.emission_rect_extents = Vector2(48.0, 135.0)  # alrededor del cuerpo
			p.direction = Vector2(0, -1)
			p.spread = 45.0
			p.gravity = Vector2(0, -150)
			p.initial_velocity_min = 40.0
			p.initial_velocity_max = 140.0
			p.scale_amount_min = 2.2
			p.scale_amount_max = 4.5
			p.color = Color(0.5, 0.85, 1.7, 0.9)   # azul eléctrico marino claro
			p.z_index = 4
			add_child(p)
			_fe_cast_particles = p
		_fe_cast_particles.global_position = caster.to_global(Vector2(0, 320.0))  # torso de Fe
		_fe_cast_particles.emitting = true
	else:
		if caster.sprite.material == _fe_cast_mat:
			caster.sprite.material = caster.base_material   # restaura el color alterno (P2)
		if is_instance_valid(_fe_cast_particles):
			_fe_cast_particles.emitting = false
			var pp := _fe_cast_particles
			_fe_cast_particles = null
			get_tree().create_timer(0.7).timeout.connect(func() -> void:
				if is_instance_valid(pp): pp.queue_free())

func _fe_water_special(caster: Node2D, bodies: int) -> void:
	var victima: Node2D = dummy if caster == player else player
	_fe_cast_fx(caster, true)                            # borde + partículas azules
	get_tree().create_timer(0.45).timeout.connect(func() -> void:   # se apaga al terminar el cast
		if is_instance_valid(caster): _fe_cast_fx(caster, false))
	await get_tree().create_timer(0.18).timeout          # windup corto del cast (grita)
	if not is_instance_valid(caster) or not is_instance_valid(victima):
		return
	# NO auto-apunta: brota a 1/2/3 CUERPOS adelante de Fe (el jugador adivina la posición)
	var gx: float = caster.position.x + float(caster.facing) * GEYSER_BODY * float(bodies)
	gx = clampf(gx, 120.0, 1800.0)                        # dentro del escenario
	caster.spawn_water_geyser(gx)
	_shake(9.0, 0.14)
	await get_tree().create_timer(0.10).timeout           # sube el chorro y conecta
	if not is_instance_valid(victima) or not is_instance_valid(caster):
		return
	# alcanzable si está donde brotó el géiser Y (en el suelo, o ya volando en juggle)
	var alcanzable: bool = (not victima.airborne) or victima.hit_flying
	if alcanzable and absf(victima.position.x - gx) < 150.0:
		var dir: int = signi(victima.position.x - caster.position.x)
		if dir == 0:
			dir = caster.facing
		var h: float = WATER_LIFT[bodies - 1]
		var res: String = victima.receive_hit(false, true, dir, "kick_impact", false, h)
		if res == "launched":
			victima.water_flash_t = 0.45                 # capa azul: golpeado por el agua
			victima.water_bg = true                      # estela de sombras AZULES + cuerpo azul hasta caer
			# deriva ~1 CUERPO hacia atrás por golpe: pasa de 1→2→3 cuerpos para encadenar Q→W→E
			victima.vel_x = float(dir) * 450.0
			var dmg: int = WATER_DMG[bodies - 1]
			if victima == dummy:
				dummy_hp = maxi(0, dummy_hp - dmg)
				if dummy_hp <= 0:
					if dummy_ai_mode and not break_practice: _end_round(true)
					else: dummy_hp = hp_max[1]
			else:
				player_hp = maxi(0, player_hp - dmg)
				if player_hp <= 0:
					if dummy_ai_mode and not break_practice: _end_round(false)
					else: player_hp = hp_max[0]

# DASH DE AGUJAS de Fe (←→+Q): embiste mostrando la CORRIDA con agua; si alcanza al rival EN EL
# SUELO, frena en seco (sin atravesarlo) y, AL TERMINAR la animación del dash, suelta el golpe:
# 3 pinchazos rápidos SIN levantarlo (queda en el sitio para seguir el combo).
const DASH_DMG := [40, 40, 55]   # 3 golpes (semi-combo)
const DASH_REACH := 300.0        # distancia a la que alcanza al rival y frena
const DASH_DISPLAY := 0.24       # deja correr la anim del dash COMPLETA (4 frames @18fps) -> se ve el agua
func _fe_dash_attack(caster: Node2D) -> void:
	var victima: Node2D = dummy if caster == player else player
	var t := 0.0
	var alcanzo := false
	# deja correr la EMBESTIDA completa (para que se VEA el agua). Marca si alcanzó al rival y,
	# en ese momento, FRENA el avance (fe_dash_t=0) sin cortar la animación del dash.
	while t < DASH_DISPLAY:
		await get_tree().physics_frame
		if not is_instance_valid(caster) or not is_instance_valid(victima) or not caster.fe_dash_active:
			if is_instance_valid(caster): caster.fe_dash_active = false
			return
		t += get_physics_process_delta_time()
		if not alcanzo and not victima.koed and not victima.airborne \
				and absf(victima.position.x - caster.position.x) < DASH_REACH \
				and absf(victima.position.y - caster.position.y) < 200.0:
			alcanzo = true
			caster.fe_dash_t = 0.0   # frena en seco (no lo atraviesa); la anim del dash sigue
	caster.fe_dash_t = 0.0
	if not alcanzo or victima.koed:
		if is_instance_valid(caster):
			caster.fe_dash_active = false   # la embestida no conectó: termina el dash
			if String(caster.sprite.animation) == "dash":
				caster.sprite.play("pose")  # vuelve a la guardia
		return
	# GOLPE que ARRANCA el combo, DESPUÉS del último frame del dash (los 3 pinchazos).
	# fe_dash_active sigue true -> esta animación no auto-pega; el daño lo meten los 3 hits.
	caster.sprite.play("punch")
	var dir: int = signi(victima.position.x - caster.position.x)
	if dir == 0:
		dir = caster.facing
	# 3 pinchazos seguidos, strong=false -> "hit" normal (NO levanta), se queda en el sitio
	for i in 3:
		if not is_instance_valid(victima) or victima.koed:
			break
		var res: String = victima.receive_hit(false, false, dir, "kick_impact")
		if res == "hit":
			victima.water_flash_t = 0.22          # leve toque azul del agua
			_shake(5.0, 0.08)
			var dmg: int = DASH_DMG[i]
			if victima == dummy:
				dummy_hp = maxi(0, dummy_hp - dmg)
				if dummy_hp <= 0:
					if dummy_ai_mode and not break_practice: _end_round(true)
					else: dummy_hp = hp_max[1]
			else:
				player_hp = maxi(0, player_hp - dmg)
				if player_hp <= 0:
					if dummy_ai_mode and not break_practice: _end_round(false)
					else: player_hp = hp_max[0]
		await get_tree().create_timer(0.09).timeout
	if is_instance_valid(caster):
		caster.fe_dash_active = false      # combo del dash terminado
		caster.sprite.play("pose")         # queda en guardia, lista para seguir combeando

# actualiza nombre + avatar del HUD según los personajes (P1 = jugador, P2 = rival)
func _refresh_hud_chars() -> void:
	var ids := [selected_char, "dam"]
	for side in 2:
		var c := _char_data(ids[side])
		if hud_name[side] != null:
			hud_name[side].text = String(c["name"])
		if hud_avatar[side] != null and ResourceLoader.exists(String(c["avatar"])):
			hud_avatar[side].texture = load(String(c["avatar"]))
			_cover_avatar(hud_avatar[side], 114, 114)   # reajusta al tamaño real del retrato nuevo
		# cara/ojos del atacante como fondo del panel del combo (mapea la franja de los ojos)
		if side < combo_face.size() and combo_face[side] != null and ResourceLoader.exists(String(c["avatar"])):
			var ftex: Texture2D = load(String(c["avatar"]))
			combo_face[side].texture = ftex
			var ts: Vector2 = ftex.get_size()
			# franja a la ALTURA DE LOS OJOS (no el pelo): ~0.46..0.66 del alto
			combo_face[side].uv = PackedVector2Array([
				Vector2(ts.x * 0.14, ts.y * 0.46), Vector2(ts.x * 0.86, ts.y * 0.46),
				Vector2(ts.x * 0.86, ts.y * 0.66), Vector2(ts.x * 0.14, ts.y * 0.66)])

func _start_round() -> void:
	state = "intro"
	_apply_char(player, selected_char)          # personaje del jugador (frames + arquetipo + escala)
	_apply_char(dummy, "dam")                   # el rival (siempre DAM): misma escala/offset/frames que P1
	_apply_alt_colors()                         # P2 con otro tono (mirror match, distinguir P1/P2)
	hp_max[0] = int(ARCH_HP.get(player.archetype, 1200))
	hp_max[1] = int(ARCH_HP.get(dummy.archetype, 1200))
	_refresh_hud_chars()
	player.input_enabled = false
	dummy.ai_enabled = false
	player.revive()
	dummy.revive()
	player.position = Vector2(630, 625)
	dummy.position = Vector2(1290, 625)
	player.set_facing(1)
	dummy.set_facing(-1)
	player_hp = hp_max[0]
	dummy_hp = hp_max[1]
	for i in 2:
		combo_n[i] = 0
		combo_t[i] = 99.0
		combo_last[i] = ""
		combo_ui[i].visible = false
	meter = [1.0, 1.0]        # arranca con 1 barra (solo INFERNO); las otras 2 se ganan
	rounds_label.text = "%d  -  %d" % [wins_p1, wins_p2]
	announce.visible = false
	# READY cruza desde la IZQUIERDA -> FIGHT! entra desde la DERECHA casi cuando READY se va
	_show_announce("READY", Color(0.88, 0.74, 0.20), 1.0, -1)   # sólido, bajo el umbral de glow
	await get_tree().create_timer(0.82).timeout
	_show_announce("FIGHT!", Color(0.88, 0.31, 0.18), 0.9, 1)
	await get_tree().create_timer(0.55).timeout
	state = "fight"
	player.input_enabled = true
	dummy.ai_enabled = dummy_ai_mode
	dummy.ai_break_drill = break_practice   # en BREAK PRACTICE la IA se lanza a encadenar combos

func _combo_name(n: int) -> String:
	if n >= 11: return "LEGENDARY!!"
	if n >= 9: return "AWESOME!"
	if n >= 7: return "MASTER!"
	if n >= 5: return "GREAT!"
	if n >= 3: return "TRIPLE!"
	if n >= 2: return "DOUBLE!"
	return ""

func _combo_hit(idx: int, dmg: int, atk_name: String, aereo: bool) -> int:
	# drop: ventana cerrada, golpe repetido, o bajar en la escalera de fuerza
	# (en el aire la escalera es libre: los juggles encadenan lo que sea)
	var nivel: int = ATK_LEVEL.get(atk_name, 0)
	var baja: bool = not aereo and combo_n[idx] > 0 and nivel < int(combo_lvl[idx])
	if combo_t[idx] > COMBO_WINDOW or atk_name == combo_last[idx] or baja:
		combo_n[idx] = 1
	else:
		combo_n[idx] += 1
	# escalado anti-infinito: del golpe 4 en adelante el dano baja (minimo 50%)
	var factor := 1.0
	if combo_n[idx] > 3:
		factor = maxf(1.0 - 0.1 * float(combo_n[idx] - 3), 0.5)
	var dmg_real := maxi(1, int(round(dmg * factor)))
	if combo_n[idx] == 1:
		combo_dmg[idx] = dmg_real
	else:
		combo_dmg[idx] += dmg_real
	combo_last[idx] = atk_name
	combo_lvl[idx] = nivel
	combo_t[idx] = 0.0
	# rastreo de secuencia para el SUCCESS del combo fijado (solo jugador)
	if idx == 0:
		if combo_n[0] == 1:
			combo_seq = [atk_name]
		else:
			combo_seq.append(atk_name)
		if pinned_combo >= 0 and state == "fight":
			var esperado: Array = COMBO_SEQS.get(String(DEMO_COMBOS[pinned_combo][1]), [])
			if esperado.size() > 0 and combo_seq.size() >= esperado.size():
				if combo_seq.slice(combo_seq.size() - esperado.size()) == esperado:
					pin_success_t = 1.2
	combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
	if combo_n[idx] >= 2 and ding_stream:
		var st: int = DING_SCALE[mini(combo_n[idx] - 2, DING_SCALE.size() - 1)]
		ding_player.stream = ding_stream
		ding_player.pitch_scale = pow(2.0, float(st) / 12.0)
		ding_player.play()
	if combo_n[idx] >= 2:
		var c: Node2D = combo_ui[idx]
		combo_num[idx].text = str(combo_n[idx])
		combo_ghost[idx].text = str(combo_n[idx])
		var nombre := _combo_name(combo_n[idx])
		combo_nom[idx].text = nombre
		combo_nom[idx].visible = nombre != ""
		c.modulate = Color(1, 1, 1, 1)
		c.scale = Vector2(1.35, 1.35)
		c.visible = true
	return dmg_real

# ---- ULTRA COMBO (estilo Killer Instinct) ----
# se dispara con → R R cuando el rival esta a <=15% de vida y traes un combo de
# 3+. El personaje ejecuta SOLO una tanda larga que acelera, con sombras.
const ULTRA_HP := 0.25   # umbral de vida del rival para habilitar el ULTRA (25%)
const ULTRA_FLURRY := [
	"weak_punch", "punch", "crouch_jab", "punch2", "kick",
	"crouch_punch", "weak_punch", "punch", "crouch_kick", "kick",
	"weak_punch", "punch2", "crouch_jab", "kick", "punch",
]

func try_ultra(atacante: Node2D, largo := false) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if atacante == player else 1
	var costo := 3.0 if largo else 2.0   # APOCALYPSE (largo) = 3 barras, ANNIHILATION = 2
	if meter[idx] < costo:
		return false          # sin barras suficientes para el ultra
	# el combo debe estar VIVO (3+ hits y dentro de la ventana): si ya dropeaste
	# aunque el numero siga apagandose en pantalla, ya NO cuenta
	if combo_n[idx] < 3 or combo_t[idx] > COMBO_WINDOW:
		return false
	# el rival debe estar EN ROJO (vida ≤25%) — como dice la lista y como los ultras de Fe
	var vhp: int = dummy_hp if idx == 0 else player_hp
	if float(vhp) > float(hp_max[1 - idx]) * 0.25:
		return false
	meter[idx] -= costo
	_run_ultra(atacante, idx, largo)
	return true

func _ultra_count(idx: int, n: int, nombre := "") -> void:
	combo_n[idx] = n
	combo_t[idx] = 0.0
	combo_num[idx].text = str(n)
	combo_ghost[idx].text = str(n)
	# sin nombre forzado, usa el RANGO normal (DOUBLE, TRIPLE, ...); el nombre del
	# ultra (APOCALYPSE, etc.) solo se muestra en el remate
	var rango := nombre if nombre != "" else _combo_name(n)
	combo_nom[idx].text = rango
	combo_nom[idx].visible = rango != ""
	var c: Node2D = combo_ui[idx]
	c.modulate = Color(1, 1, 1, 1)
	c.scale = Vector2(1.5, 1.5)
	c.visible = true
	if ding_stream:
		var st: int = DING_SCALE[mini(n - 2, DING_SCALE.size() - 1)]
		ding_player.stream = ding_stream
		ding_player.pitch_scale = pow(2.0, float(st) / 12.0)
		ding_player.play()

# una tanda de golpes con arranque lento -> rapidisimo, sombras y drenado de vida
func _ultra_flurry(atacante: Node2D, victima: Node2D, idx: int, dir: int, n0: int, drain: int) -> int:
	var n := n0
	var np := float(ULTRA_FLURRY.size() - 1)
	for i in ULTRA_FLURRY.size():
		if state != "ultra":
			break
		var ramp := pow(float(i) / np, 1.7)          # arranca MUY lento y acelera
		atacante.airborne = false
		var dist := 150.0 + 40.0 * sin(float(i) * 1.9)
		atacante.position.x = clampf(victima.position.x - float(dir) * dist, LEFT_LIMIT, RIGHT_LIMIT)
		atacante.set_facing(dir)
		atacante.sprite.speed_scale = lerpf(0.4, 3.0, ramp)
		atacante.sprite.play(ULTRA_FLURRY[i])
		# el rival se tambalea de pie recibiendo golpes (usa "pummeled": bucle de
		# tambaleo, ideal para la rafaga continua del ultra; ya con arte nuevo)
		victima.crouching = false
		victima.airborne = false
		victima.ultra_hover = false
		# SIEMPRE mira hacia el atacante para que el recular sea acorde al golpe
		victima.set_facing(1 if atacante.position.x > victima.position.x else -1)
		if victima.sprite.sprite_frames.has_animation("pummeled"):
			# NO reiniciar cada golpe (se veía glitch/rapidísimo): se inicia UNA vez
			# y hace loop suave durante toda la ráfaga.
			if String(victima.sprite.animation) != "pummeled":
				victima.sprite.play("pummeled")
		else:
			victima.sprite.play("take_hit_low" if i % 2 == 0 else "take_hit")
		# panel manga a pantalla completa: CAMBIA en cada golpe (cicla 1->6 rápido)
		if ultra_panels.size() > 0:
			ultra_panel.texture = ultra_panels[i % ultra_panels.size()]
			ultra_panel.visible = true
		victima._play_sfx_key("take_hit")   # sonido de impacto por golpe
		# chispa al PECHO (base_corr sigue el pecho según la escala del personaje)
		victima._burst(0.95, false, 1, false, 500.0 * (1.0 - victima.base_scale.y))
		_shake(lerpf(9.0, 16.0, ramp), 0.12)   # temblor por golpe (crece con la ráfaga)
		victima.position.x = clampf(victima.position.x + float(dir) * 5.0, LEFT_LIMIT, RIGHT_LIMIT)
		n += 1
		_ultra_count(idx, n)   # rango normal (DOUBLE, TRIPLE, GREAT, ...), no el nombre del ultra
		_focus_set(clampf((float(n) - 2.0) / 14.0, 0.15, 1.0))   # el borde se intensifica con el combo
		if idx == 0:
			dummy_hp = maxi(1, dummy_hp - drain)
		else:
			player_hp = maxi(1, player_hp - drain)
		combo_dmg[idx] += drain                                  # el daño total se va sumando
		combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
		await get_tree().create_timer(lerpf(0.42, 0.05, ramp)).timeout
	return n

func _run_ultra(atacante: Node2D, idx: int, largo := false) -> void:
	ultra_largo = largo
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	# PRIMER golpe bloqueable: si el rival lo bloquea, la ANIQUILACIÓN NO entra
	var arranque: String = victima.receive_hit(false, false, dir, "kick_impact")
	if arranque != "hit" and arranque != "launched":
		return   # bloqueado (o ignorado): no arranca
	ultra_active = true
	state = "ultra"
	player.input_enabled = false
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	_focus_start(atacante)         # borde rojo eléctrico (aparece gradual con el combo)
	# NOTA: los paneles manga NO se muestran aquí (en la activación). Salen RETRASADOS,
	# con la ráfaga (cuando la pantalla ya se oscureció) — ver _ultra_flurry.
	# arranque dramatico: congelado + fogonazo (el rotulo va en el contador de combo)
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(1.0, 0.4, 0.15, 0.6)
	Engine.time_scale = 0.0
	_shake(26.0, 0.5)              # sacudón fuerte al entrar
	await get_tree().create_timer(0.55, true, false, true).timeout
	Engine.time_scale = 1.0
	atacante.set_facing(dir)
	victima.set_facing(-dir)
	var hp0: float = float(dummy_hp if idx == 0 else player_hp)
	var n: int = combo_n[idx]
	atacante.breaker_fx_t = 40.0   # sombras continuas durante toda la tanda
	# el drenado reparte la vida entre TODOS los golpes (una tanda, o dos si es largo)
	var total_golpes := ULTRA_FLURRY.size() * (2 if largo else 1)
	var drain := maxi(1, int(round(hp0 * 0.95 / float(total_golpes))))
	n = await _ultra_flurry(atacante, victima, idx, dir, n, drain)
	# APOCALIPSIS: cruza al OTRO lado del rival y hace otra tanda
	if largo and state == "ultra":
		dir = -dir
		flash_ms = Time.get_ticks_msec()
		flash_rect.color = Color(0.4, 0.55, 1.0, 0.5)
		# dash cruzado con estela de sombras hasta el otro flanco
		var destino := clampf(victima.position.x - float(dir) * 150.0, LEFT_LIMIT, RIGHT_LIMIT)
		var cruz := 0.0
		while cruz < 0.16:
			atacante.position.x = lerpf(atacante.position.x, destino, 0.35)
			atacante.set_facing(dir)
			await get_tree().process_frame
			cruz += get_process_delta_time()
		victima.set_facing(-dir)
		n = await _ultra_flurry(atacante, victima, idx, dir, n, drain)
	# APOCALIPSIS (largo): pre-remate = PATADA GIRATORIA (→E) EN EL SITIO, sin empujar.
	# El rival se queda en el lugar y recibe el impacto. Luego viene el mortal (arriba E).
	if largo and state == "ultra":
		atacante.set_facing(dir)
		atacante.position.x = clampf(victima.position.x - float(dir) * 200.0, LEFT_LIMIT, RIGHT_LIMIT)
		var spx := atacante.position.x
		var svx := victima.position.x
		atacante.airborne = false
		atacante.sprite.speed_scale = 1.5
		atacante.sprite.play("spin_kick")
		victima.set_facing(-dir)
		victima.receive_hit(false, false, dir, "kick_impact")   # impacto EN EL SITIO (no lanza)
		if victima.sprite.sprite_frames.has_animation("pummeled"):
			victima.sprite.play("pummeled")
		n += 1
		_ultra_count(idx, n)
		_shake(14.0, 0.18)
		flash_ms = Time.get_ticks_msec()
		flash_rect.color = Color(1.0, 0.5, 0.2, 0.5)
		var st := 0.0
		while st < 0.40 and state == "ultra":
			atacante.position.x = spx          # el spin_kick NO empuja: fijo en el sitio
			victima.position.x = svx           # el rival se queda en el lugar
			await get_tree().process_frame
			st += get_process_delta_time()
		atacante.sprite.speed_scale = 1.0
	# FINISHER: mortal aereo (E arriba) que manda al rival MUY alto + caida brusca
	if state == "ultra":
		victima.ultra_hover = false   # libera el juggle: ahora el remate lo lanza
		atacante.sprite.speed_scale = 1.0
		# arrima el atacante a distancia de patada para que la DOBLE PATADA conecte
		atacante.position.x = clampf(victima.position.x - float(dir) * 165.0, LEFT_LIMIT, RIGHT_LIMIT)
		atacante.set_facing(dir)
		atacante.airborne = true
		atacante.vel_y = -atacante.JUMP_SPEED
		atacante.sprite.play("air_spin_kick")
		atacante.breaker_fx_t = 1.0   # sombras en el salto del remate
		n += 1
		_ultra_count(idx, n, "APOCALYPSE" if largo else "ANNIHILATION")
		_play_voz("apocalypse" if largo else "annihilation")   # grito infernal en el REMATE
		flash_ms = Time.get_ticks_msec()
		flash_rect.color = Color(1.0, 0.55, 0.2, 0.75)
		Engine.time_scale = 0.3
		# el golpe FINAL vacia la barra por completo (sin rojito sobrante)
		# y suma el daño restante al total mostrado
		if idx == 0:
			combo_dmg[idx] += dummy_hp
			dummy_hp = 0
		else:
			combo_dmg[idx] += player_hp
			player_hp = 0
		combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
		# lanzamiento muy alto + caida acelerada (hard_fall)
		victima.receive_hit(false, true, dir, "kick_impact", false, 1.9)
		victima.hard_fall = true
		await get_tree().create_timer(0.4, true, false, true).timeout
		Engine.time_scale = 1.0
		# esperar a que el rival suba, caiga brusco y se estrelle en el piso
		var vuelo := 0.0
		while victima.airborne and vuelo < 3.0:
			await get_tree().process_frame
			vuelo += get_process_delta_time()
		await get_tree().create_timer(0.35).timeout
	atacante.breaker_fx_t = 0.0
	atacante.sprite.speed_scale = 1.0
	victima.ultra_hover = false   # por si el ultra se interrumpio en pleno juggle
	announce.visible = false
	_focus_end()                  # quita el borde rojo y restaura el brillo
	ultra_active = false
	# cierre: KO en pelea real, o revivir en modo practica
	if dummy_ai_mode:
		state = "fight"
		if idx == 0:
			dummy_hp = 0
			_end_round(true)
		else:
			player_hp = 0
			_end_round(false)
	else:
		if idx == 0:
			dummy_hp = hp_max[1]
		else:
			player_hp = hp_max[0]
		state = "fight"
		player.input_enabled = true
		dummy.ai_enabled = dummy_ai_mode

# ---- INFIERNO: crítico de FUEGO (↓↘→+E tras un combo de 7+) ----
const CRIT_DMG := 50   # el golpe mas fuerte del juego

func try_critical(atacante: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if atacante == player else 1
	if meter[idx] < 1.0:
		return false          # INFERNO cuesta 1 barra
	# requiere un combo VIVO de 7+ (rango MASTER)
	# TEMPORAL PARA PROBAR: bajado a 3; devolver a 7 despues
	if combo_n[idx] < 3 or combo_t[idx] > COMBO_WINDOW:
		return false
	meter[idx] -= 1.0
	_run_critical(atacante, idx)
	return true

func _run_critical(atacante: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	ultra_active = true
	state = "ultra"
	player.input_enabled = false
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	atacante.airborne = false
	atacante.set_facing(dir)
	_focus_start(atacante)         # borde rojo eléctrico (aparece gradual)
	_focus_set(0.35)               # arranca tenue mientras carga la katana
	# SUPER pre-animado DESDE EL ARRANQUE: OCULTA por completo a DAM (nada de arte
	# viejo, nada de doble DAM) y muestra la animación combinada (DAM casteando +
	# GRAN OLA de fuego roja) como UNA sola pieza. El frame 1 (DAM cargando) queda
	# CONGELADO durante la pausa dramática; el rayo se suelta al reanudar el tiempo.
	var sup: AnimatedSprite2D = atacante.spawn_inferno_super()
	if sup != null:
		atacante.sprite.visible = false        # esconde el DAM vivo (no más doble)
		atacante.fx_sprite.visible = false     # sin fantasma de arte viejo
		# el super queda en su frame 0 (DAM cargando) durante el freeze: entre el
		# spawn y el time_scale=0 no se dibuja ningún frame, así que no avanza.
	else:
		atacante.sprite.play("pose")           # respaldo: pose NUEVA (nunca flame_cast viejo)
	_play_voz("inferno")                   # GRITA el poder al alzar la katana (ANTES de la bola)
	# CUT-IN: el retrato sale en el lado OPUESTO al contador de combo (para no chocar).
	var combo_x: float = float(combo_rest_x[idx])
	_play_cutin(-1 if combo_x >= 960.0 else 1)   # combo a la derecha -> retrato a la izquierda
	flash_ms = Time.get_ticks_msec()
	# velo TENUE: el cut-in va DETRÁS de la acción y del velo, así que lo dejamos
	# suave para que el retrato/banda se vean brillantes (el drama lo da el cut-in).
	flash_rect.color = Color(0.10, 0.01, 0.0, 0.22)
	Engine.time_scale = 0.0                # pausa dramática (FRAME CONGELADO largo)
	await get_tree().create_timer(1.0, true, false, true).timeout   # el cut-in juega aquí
	Engine.time_scale = 1.0                # vuelve a velocidad NORMAL...
	# ...y AHÍ suelta la descarga: fogonazo naranja de ignición + DISPARA el rayo
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(1.3, 0.5, 0.12, 0.5)
	if sup != null:
		sup.play("cast")                   # AHORA sí: DAM suelta la GRAN OLA de fuego
	# espera a que la ola crezca y alcance al rival antes del impacto
	await get_tree().create_timer(0.42).timeout
	# ¿el FUEGO toca de verdad al rival? Debe estar DELANTE de DAM, dentro del alcance
	# del rayo y NO demasiado alto. Si saltó por encima o está lejos, el poder PASA DE
	# LARGO: se ve la gran ola pero NO golpea (nada de golpes "fantasma").
	var REACH_X := 1400.0            # alcance horizontal del rayo
	var REACH_UP := 430.0            # alto máx (sobre el piso) que toca el fuego
	var to_v: float = (victima.position.x - atacante.position.x) * float(dir)
	var alto: float = victima.floor_y - victima.position.y     # >0 si el rival está en el aire
	var connects: bool = to_v >= -140.0 and to_v <= REACH_X and alto <= REACH_UP and alto >= -60.0
	if not connects:
		await get_tree().create_timer(0.5).timeout       # deja terminar la ola (whiff)
		if sup != null:
			sup.queue_free()
		atacante.sprite.visible = true
		_focus_end()
		ultra_active = false
		state = "fight"
		player.input_enabled = true
		dummy.ai_enabled = dummy_ai_mode
		return
	# CONECTA: golpea al rival DONDE el fuego lo tocó (en el aire o en el suelo), SIN
	# arrastrarlo al piso. Guarda esa altura para mantenerlo dentro de la ola.
	var hit_y: float = victima.position.y
	victima.set_facing(-dir)                              # encara al atacante
	victima.crouching = false
	victima._burst(1.3)
	if victima.has_method("start_burn"):
		victima.start_burn()                             # queda QUEMADO (oscuro) y se recupera de a poco
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(1.6, 0.6, 0.15, 0.85)
	_shake(28.0, 0.45)                                    # sacudón del estallido
	Engine.time_scale = 0.30
	await get_tree().create_timer(0.14, true, false, true).timeout   # cámara lenta del impacto
	Engine.time_scale = 1.0
	# EMPUJE + MULTI-HIT: el fuego ENVUELVE y arrastra al rival (a la ALTURA donde lo
	# tocó, aire o suelo), golpeándolo una y otra vez. El daño se reparte entre golpes.
	var n0: int = combo_n[idx]
	var HITS := 8
	var PASO := 0.07
	var crit_total := int(hp_max[1 - idx] * 0.40)   # INFERNO: ~40% de la vida del rival
	var dealt := 0
	var hit_i := 0
	var hit_cd := 0.0
	var polvo_cd := 0.0
	var empuje := 0.0
	var fin := float(HITS) * PASO + 0.06
	while empuje < fin:
		var dt := get_process_delta_time()
		var avance := float(dir) * 1050.0 * dt           # empujón veloz
		victima.position.x = clampf(victima.position.x + avance, 120.0, 1800.0)
		victima.position.y = hit_y                        # a la ALTURA donde lo tocó el fuego
		polvo_cd -= dt
		if polvo_cd <= 0.0 and hit_y >= victima.floor_y - 20.0:
			victima._spawn_dash_smoke(0.55, 40.0)        # polvo solo si va por el suelo
			polvo_cd = 0.10
		# GOLPE periódico mientras la ola dure e impacte al rival
		hit_cd -= dt
		if hit_cd <= 0.0 and hit_i < HITS:
			hit_cd = PASO
			hit_i += 1
			var d := (crit_total - dealt) if hit_i == HITS else int(crit_total / HITS)
			dealt += d
			if idx == 0:
				dummy_hp = maxi(0, dummy_hp - d)
			else:
				player_hp = maxi(0, player_hp - d)
			_ultra_count(idx, n0 + hit_i)                # rango normal (sube hit por hit)
			combo_dmg[idx] += d                          # el daño total se va sumando
			combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
			_focus_set(0.4 + 0.6 * float(hit_i) / float(HITS))   # el borde se intensifica con el multi-hit
			victima._burst(0.85)                         # chispas por golpe
			_shake(12.0, 0.1)                            # temblor por golpe del multi-hit
			victima._play_sfx_key("take_hit")            # sonido de impacto por golpe
			victima.sprite.play("pummeled" if victima.sprite.sprite_frames.has_animation("pummeled") else "take_hit")
			flash_ms = Time.get_ticks_msec()             # fogonazo corto por golpe
			flash_rect.color = Color(1.4, 0.55, 0.15, 0.5)
		empuje += dt
		await get_tree().process_frame
	if sup != null:
		sup.queue_free()                                 # quita el super pre-animado
	atacante.sprite.visible = true                       # DAM vuelve a su sprite normal
	# REMATE: el estallido lo derriba al piso
	victima.hard_fall = false
	victima.receive_hit(false, false, dir, "", true, 1.0)   # trip -> derribo corto
	# esperar a que el rival caiga
	var vuelo := 0.0
	while victima.airborne and vuelo < 2.0:
		await get_tree().process_frame
		vuelo += get_process_delta_time()
	_focus_end()                  # quita el borde rojo y restaura el brillo
	ultra_active = false
	# cierre: KO si murió, si no vuelve a la pelea
	var murio: bool = (dummy_hp <= 0) if idx == 0 else (player_hp <= 0)
	state = "fight"
	if dummy_ai_mode and murio:
		_end_round(idx == 0)
	else:
		player.input_enabled = true
		dummy.ai_enabled = dummy_ai_mode

# WHIRLPOOL (finisher de Fe, ↓←+E): GIRO MORTAL en el lugar que atrapa al rival en un
# vórtice de agua y le quita BASTANTE vida. Se habilita tras un combo VIVO de 2+ golpes.
func try_whirlpool(atacante: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if atacante == player else 1
	if meter[idx] < 1.0:
		return false          # cuesta 1 BARRA (el "primer poder", como el INFERNO de DAM)
	if combo_n[idx] < 2 or combo_t[idx] > COMBO_WINDOW:
		return false          # necesita 2-3 golpes encadenados vivos
	meter[idx] -= 1.0
	_run_whirlpool(atacante, idx)
	return true

func _run_whirlpool(atacante: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	# SOLO agarra al rival si está EN EL SUELO y CERCA. Si está en el aire o lejos, Fe gira en
	# VACÍO (whiff): hace el remolino pero NO lo teletransporta ni le pega.
	var alcanza: bool = (not victima.airborne) and absf(victima.position.x - atacante.position.x) < 450.0
	ultra_active = true
	state = "ultra"
	player.input_enabled = false
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	atacante.fe_dash_active = false
	atacante.airborne = false
	atacante.position.y = atacante.floor_y
	atacante.set_facing(dir)
	_fe_cast_fx(atacante, true)                    # borde AZUL eléctrico + partículas (solo Fe)
	atacante.sprite.play("whirlpool")
	if atacante.has_method("_spawn_jump_dust"):
		atacante._spawn_jump_dust(0.55)   # un toque de polvo al arrancar (sutil, no tapa)
	# GRITA en su player de VOZ propio (no lo corta el sonido de impacto)
	var voz = load("res://imagen-action/favi/Fe-sound-effect/whirlpool-fe.wav")
	if voz != null and atacante.voz_player != null:
		atacante.voz_player.stream = voz
		atacante.voz_player.play()
	# entrada cinemática: congela un instante + velo AZUL marino
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.05, 0.12, 0.35, 0.5)
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.28, true, false, true).timeout
	Engine.time_scale = 1.0
	# el rival queda atrapado AL LADO de Fe (SOLO si estaba en el suelo y cerca)
	if alcanza:
		victima.airborne = false
		victima.crouching = false
		victima.position.y = victima.floor_y
		victima.set_facing(-dir)
	_shake(20.0, 0.3)
	# MULTI-HIT del remolino (HURACÁN): golpea repetido y MUY RÁPIDO SIN lanzarlo; ~40% de su vida
	var n0: int = combo_n[idx]
	var HITS := 12
	var PASO := 0.052
	var total := int(hp_max[1 - idx] * 0.40)
	var dealt := 0
	var hit_i := 0
	var hit_cd := 0.0
	var t := 0.0
	var polvo_cd := 0.0   # polvo (dust de salto/caída) que levanta el huracán bajo sus pies
	var ghost_cd := 0.0   # estela de SOMBRAS azules mientras gira
	var fin := float(HITS) * PASO + 0.05
	while t < fin:
		var dt := get_process_delta_time()
		if alcanza:
			victima.position.x = clampf(atacante.position.x + float(dir) * 190.0, 120.0, 1800.0)
			victima.position.y = victima.floor_y
		# HURACÁN: suelta SOMBRAS azules y levanta POLVO bajo sus pies mientras gira
		ghost_cd -= dt
		if ghost_cd <= 0.0:
			ghost_cd = 0.04
			if atacante.has_method("_spawn_ghost"):
				atacante._spawn_ghost(true)
		polvo_cd -= dt
		if polvo_cd <= 0.0:
			polvo_cd = 0.30   # MUY espaciado: solo un par de puffs chicos (antes se enredaba)
			if atacante.has_method("_spawn_jump_dust"):
				atacante._spawn_jump_dust(0.45)
		hit_cd -= dt
		if alcanza and hit_cd <= 0.0 and hit_i < HITS:
			hit_cd = PASO
			hit_i += 1
			var d := (total - dealt) if hit_i == HITS else int(total / HITS)
			dealt += d
			if idx == 0:
				dummy_hp = maxi(0, dummy_hp - d)
			else:
				player_hp = maxi(0, player_hp - d)
			_ultra_count(idx, n0 + hit_i)
			combo_dmg[idx] += d
			combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
			victima._burst(0.9, false, 1, true)          # chispas AZULES
			_shake(11.0, 0.09)
			victima._play_sfx_key("take_hit")            # impacto en SU player (no corta la voz de Fe)
			victima.sprite.play("pummeled" if victima.sprite.sprite_frames.has_animation("pummeled") else "take_hit")
			victima.water_flash_t = 0.25                 # tinte azul del agua
			flash_ms = Time.get_ticks_msec()
			flash_rect.color = Color(0.3, 0.55, 1.2, 0.35)
		t += dt
		await get_tree().process_frame
	_fe_cast_fx(atacante, false)                         # apaga el borde azul
	atacante.sprite.play("pose")                         # frena el giro (la anim hacía loop)
	# REMATE: lo derriba al piso (solo si el remolino lo atrapó)
	if alcanza:
		victima.receive_hit(false, false, dir, "", true, 1.0)
		var vuelo := 0.0
		while victima.airborne and vuelo < 2.0:
			await get_tree().process_frame
			vuelo += get_process_delta_time()
	ultra_active = false
	var murio: bool = (dummy_hp <= 0) if idx == 0 else (player_hp <= 0)
	state = "fight"
	if dummy_ai_mode and murio:
		_end_round(idx == 0)
	else:
		player.input_enabled = true
		dummy.ai_enabled = dummy_ai_mode

# ULTRA CORTO de Fe (↑+E): tras un combo VIVO de 3 y con 2 BARRAS (barra roja). Combo aéreo:
# LANZA al rival arriba y lo mantiene flotando (juggle) golpeándolo con air_spin_kick (salto+E)
# varias veces + golpes aéreos, y REMATA con una picada que lo estrella. Dropea casi toda la vida.
# Los ultras se llaman IGUAL en TODOS los personajes: corto = ANNIHILATION, largo = APOCALYPSE.
# Comparten la MISMA voz que DAM (voz-annihilation / voz-apocalypse), que suena AL FINAL (remate).
func try_fe_ultra(atacante: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if atacante == player else 1
	if meter[idx] < 2.0:
		return false          # cuesta 2 BARRAS (ultra corto)
	if combo_n[idx] < 3 or combo_t[idx] > COMBO_WINDOW:
		return false          # necesita un combo VIVO de 3+
	# el rival debe estar EN ROJO: vida ≤25% (como el ultra de DAM). Es un remate, no de arranque.
	var vhp: int = dummy_hp if idx == 0 else player_hp
	if float(vhp) > float(hp_max[1 - idx]) * 0.25:
		return false
	meter[idx] -= 2.0
	_run_fe_ultra(atacante, idx)
	return true

# secuencia del juggle: usa el mortal aéreo (↑E) varias veces + cortes aéreos.
# 12 golpes -> con el combo inicial (3) y el remate (1) da ~16, como el ANNIHILATION de DAM.
const FE_ULTRA_JUGGLE := ["air_spin_kick", "jump_punch", "air_spin_kick", "jump_kick", "air_spin_kick", "jump_punch", "air_spin_kick", "jump_kick", "air_spin_kick", "jump_punch", "air_spin_kick", "jump_kick"]
func _run_fe_ultra(atacante: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	# PRIMER golpe bloqueable: si lo bloquea, el ultra NO entra
	var arranque: String = victima.receive_hit(false, false, dir, "kick_impact")
	if arranque != "hit" and arranque != "launched":
		return
	ultra_active = true
	state = "ultra"
	player.input_enabled = false
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	atacante.fe_dash_active = false
	_fe_cast_fx(atacante, true)                   # borde AZUL eléctrico (solo Fe)
	# entrada cinemática: congela + velo azul + grito
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.10, 0.28, 0.75, 0.6)
	Engine.time_scale = 0.0
	_shake(24.0, 0.5)
	await get_tree().create_timer(0.5, true, false, true).timeout
	Engine.time_scale = 1.0
	# JUGGLE: ambos FLOTAN (ultra_hover suprime su física; main controla pose y posición)
	var hp0: float = float(dummy_hp if idx == 0 else player_hp)
	var n: int = combo_n[idx]
	var alto: float = victima.floor_y - 540.0
	atacante.breaker_fx_t = 40.0   # sombras azules continuas
	victima.ultra_hover = true
	victima.airborne = true
	victima.hit_flying = true
	var total_golpes := FE_ULTRA_JUGGLE.size() + 1
	var drain := maxi(1, int(round(hp0 * 0.92 / float(total_golpes))))
	for i in FE_ULTRA_JUGGLE.size():
		if state != "ultra":
			break
		var frac: float = float(i) / float(maxi(1, FE_ULTRA_JUGGLE.size() - 1))
		var ramp := pow(frac, 1.7)
		# SUBE POCO A POCO: empieza cerca del piso (donde lo agarra) y trepa hasta arriba
		var subida: float = lerpf(victima.floor_y - 130.0, alto, frac)
		# Fe flota al lado del rival, a su altura, y ejecuta el golpe aéreo
		atacante.ultra_hover = true
		atacante.airborne = true
		atacante.set_facing(dir)
		atacante.position = Vector2(clampf(victima.position.x - float(dir) * 155.0, LEFT_LIMIT, RIGHT_LIMIT), subida)
		atacante.sprite.speed_scale = lerpf(0.5, 2.8, ramp)
		atacante.sprite.play(FE_ULTRA_JUGGLE[i])
		# el rival flota recibiendo el castigo
		victima.position.y = subida + 20.0
		victima.set_facing(-dir)
		victima.sprite.play("pummeled" if victima.sprite.sprite_frames.has_animation("pummeled") else "take_hit")
		victima._play_sfx_key("take_hit")
		victima._burst(0.95, false, 1, true)   # chispas AZULES
		victima.water_flash_t = 0.2
		_shake(lerpf(10.0, 16.0, ramp), 0.1)
		n += 1
		_ultra_count(idx, n)
		if idx == 0:
			dummy_hp = maxi(1, dummy_hp - drain)
		else:
			player_hp = maxi(1, player_hp - drain)
		combo_dmg[idx] += drain
		combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
		await get_tree().create_timer(lerpf(0.42, 0.06, ramp)).timeout
	# FINISHER: PICADA que lo estrella al piso + vacía la vida restante
	if state == "ultra":
		n += 1
		_ultra_count(idx, n, "ANNIHILATION")   # ultra CORTO = ANNIHILATION (igual que DAM)
		_play_voz("annihilation")              # grita el nombre AL FINAL (misma voz que DAM)
		flash_ms = Time.get_ticks_msec()
		flash_rect.color = Color(0.35, 0.62, 1.35, 0.85)
		Engine.time_scale = 0.3
		if idx == 0:
			combo_dmg[idx] += dummy_hp
			dummy_hp = 0
		else:
			combo_dmg[idx] += player_hp
			player_hp = 0
		combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
		atacante.sprite.speed_scale = 1.0
		atacante.sprite.play("air_spin_kick")
		victima.ultra_hover = false
		victima.receive_hit(false, true, dir, "kick_impact", false, 1.7)
		victima.hard_fall = true
		atacante.ultra_hover = false
		atacante.airborne = true
		atacante.vel_y = 200.0
		await get_tree().create_timer(0.4, true, false, true).timeout
		Engine.time_scale = 1.0
		var vuelo := 0.0
		while victima.airborne and vuelo < 2.0:
			await get_tree().process_frame
			vuelo += get_process_delta_time()
	# cierre
	_fe_cast_fx(atacante, false)
	atacante.ultra_hover = false
	atacante.airborne = false
	atacante.position.y = atacante.floor_y
	atacante.sprite.speed_scale = 1.0
	atacante.sprite.play("pose")
	atacante.breaker_fx_t = 0.0
	ultra_active = false
	var murio: bool = (dummy_hp <= 0) if idx == 0 else (player_hp <= 0)
	state = "fight"
	if dummy_ai_mode and murio:
		_end_round(idx == 0)
	else:
		player.input_enabled = true
		dummy.ai_enabled = dummy_ai_mode

# helper: aplica UN golpe del ultra al rival (daño + chispas AZULES + sonido + pose de castigo)
func _fe_ultra_hit(idx: int, victima: Node2D, drain: int) -> void:
	if idx == 0:
		dummy_hp = maxi(1, dummy_hp - drain)
	else:
		player_hp = maxi(1, player_hp - drain)
	combo_dmg[idx] += drain
	combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
	victima._burst(0.95, false, 1, true)          # chispas AZULES
	victima._play_sfx_key("take_hit")
	victima.water_flash_t = 0.2
	victima.sprite.play("pummeled" if victima.sprite.sprite_frames.has_animation("pummeled") else "take_hit")

# ULTRA LARGO de Fe (↓→ + R): APOCALYPSE. Épico: GÉISER de agua ×2 que lo ELEVA -> DASH ->
# PEONZA (spin_kick) varios golpes -> air_spin_kick ×3 que lo eleva -> remate. 3 barras + combo + rojo.
func try_fe_ultra_long(atacante: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if atacante == player else 1
	if meter[idx] < 3.0:
		return false          # cuesta 3 BARRAS (ultra largo)
	if combo_n[idx] < 3 or combo_t[idx] > COMBO_WINDOW:
		return false
	var vhp: int = dummy_hp if idx == 0 else player_hp
	if float(vhp) > float(hp_max[1 - idx]) * 0.25:
		return false          # el rival debe estar EN ROJO (≤25%)
	meter[idx] -= 3.0
	_run_fe_ultra_long(atacante, idx)
	return true

func _run_fe_ultra_long(atacante: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	var arranque: String = victima.receive_hit(false, false, dir, "kick_impact")
	if arranque != "hit" and arranque != "launched":
		return
	ultra_active = true
	state = "ultra"
	player.input_enabled = false
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	atacante.fe_dash_active = false
	_fe_cast_fx(atacante, true)
	atacante.breaker_fx_t = 60.0                  # sombras azules toda la duración
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.10, 0.28, 0.75, 0.6)
	Engine.time_scale = 0.0
	_shake(26.0, 0.55)
	await get_tree().create_timer(0.5, true, false, true).timeout
	Engine.time_scale = 1.0
	var hp0: float = float(dummy_hp if idx == 0 else player_hp)
	var n: int = combo_n[idx]
	var drain := maxi(1, int(round(hp0 * 0.94 / 25.0)))   # ~25 golpes reparten 94%; el remate el resto
	victima.ultra_hover = true
	victima.airborne = true
	victima.hit_flying = true
	atacante.set_facing(dir)
	victima.set_facing(-dir)
	# ---- FASE 1: GÉISER de agua ×2 que lo ELEVA (una vez, después dos veces más alto) ----
	for g in 2:
		if state != "ultra":
			break
		atacante.ultra_hover = false
		atacante.airborne = false
		atacante.position.y = atacante.floor_y
		atacante.sprite.speed_scale = 1.4
		atacante.sprite.play("water_cast")
		if atacante.voz_player != null:
			atacante.voz_player.stream = load("res://imagen-action/favi/Fe-sound-effect/water-cast-fe-energetica.wav")
			atacante.voz_player.play()
		if atacante.has_method("spawn_water_geyser"):
			atacante.spawn_water_geyser(victima.position.x)
		_shake(13.0, 0.16)
		var top1: float = victima.floor_y - (300.0 + 170.0 * float(g))
		var t0 := 0.0
		while t0 < 0.30:
			victima.position.y = lerpf(victima.position.y, top1, 0.32)
			victima.position.x = clampf(atacante.position.x + float(dir) * 250.0, LEFT_LIMIT, RIGHT_LIMIT)
			await get_tree().process_frame
			t0 += get_process_delta_time()
		n += 1
		_ultra_count(idx, n)
		_fe_ultra_hit(idx, victima, drain)
	# rampa GLOBAL de los golpes (dash+peonza+air): arranca LENTO y ACELERA, como DAM.
	var k := 0.0
	var kmax := 20.0
	# posición FIJA del castigo: ambos anclados aquí para que NO se separen ni deriven
	var cx: float = clampf(victima.position.x, LEFT_LIMIT + 260.0, RIGHT_LIMIT - 260.0)
	# ---- FASE 2: DASH que embiste, luego estocadas EN EL LUGAR ----
	if state == "ultra":
		atacante.ultra_hover = false
		atacante.airborne = false
		atacante.position = Vector2(clampf(cx - float(dir) * 440.0, LEFT_LIMIT, RIGHT_LIMIT), atacante.floor_y)
		atacante.set_facing(dir)
		atacante.sprite.speed_scale = 1.7
		atacante.sprite.play("dash" if atacante.sprite.sprite_frames.has_animation("dash") else "punch")
		var destino: float = clampf(cx - float(dir) * 150.0, LEFT_LIMIT, RIGHT_LIMIT)
		var dt2 := 0.0
		while dt2 < 0.20:
			atacante.position.x = lerpf(atacante.position.x, destino, 0.4)
			victima.position = Vector2(cx, victima.floor_y - 60.0)
			await get_tree().process_frame
			dt2 += get_process_delta_time()
		for h in 3:
			if state != "ultra":
				break
			var rp: float = pow(k / kmax, 1.7)
			victima.position = Vector2(cx, victima.floor_y - 60.0)
			atacante.position = Vector2(destino, atacante.floor_y)
			atacante.set_facing(dir)
			atacante.sprite.speed_scale = lerpf(1.4, 3.2, rp)
			atacante.sprite.play("punch")
			n += 1
			_ultra_count(idx, n)
			_fe_ultra_hit(idx, victima, drain)
			_shake(11.0, 0.09)
			await get_tree().create_timer(lerpf(0.42, 0.045, rp)).timeout
			k += 1.0
	# ---- FASE 3: PEONZA (spin_kick) EN EL LUGAR (re-reproduce cada golpe) ----
	if state == "ultra":
		for h in 14:
			if state != "ultra":
				break
			var rp: float = pow(k / kmax, 1.7)
			victima.position = Vector2(cx, victima.floor_y - 40.0)
			victima.set_facing(-dir)
			atacante.ultra_hover = false
			atacante.airborne = false
			atacante.position = Vector2(clampf(cx - float(dir) * 150.0, LEFT_LIMIT, RIGHT_LIMIT), atacante.floor_y)
			atacante.set_facing(dir)
			atacante.sprite.speed_scale = lerpf(1.6, 3.4, rp)
			atacante.sprite.play("spin_kick")
			n += 1
			_ultra_count(idx, n)
			_fe_ultra_hit(idx, victima, drain)
			_shake(10.0, 0.08)
			await get_tree().create_timer(lerpf(0.42, 0.045, rp)).timeout
			k += 1.0
	# ---- FASE 4: air_spin_kick ×3 EN EL MISMO LUGAR (los 3 golpes ahí, no se mueve) ----
	if state == "ultra":
		var ay: float = victima.floor_y - 300.0
		for h in 3:
			if state != "ultra":
				break
			var rp: float = pow(k / kmax, 1.7)
			atacante.ultra_hover = true
			atacante.airborne = true
			atacante.position = Vector2(clampf(cx - float(dir) * 140.0, LEFT_LIMIT, RIGHT_LIMIT), ay)
			atacante.set_facing(dir)
			atacante.sprite.speed_scale = lerpf(1.8, 3.2, rp)
			atacante.sprite.play("air_spin_kick")
			victima.position = Vector2(cx, ay + 20.0)
			victima.set_facing(-dir)
			n += 1
			_ultra_count(idx, n)
			_fe_ultra_hit(idx, victima, drain)
			_shake(13.0, 0.1)
			await get_tree().create_timer(lerpf(0.24, 0.09, rp)).timeout
			k += 1.0

	# ---- FINISHER ÉPICO: remate + KO ----
	if state == "ultra":
		n += 1
		_ultra_count(idx, n, "APOCALYPSE")
		_play_voz("apocalypse")
		flash_ms = Time.get_ticks_msec()
		flash_rect.color = Color(0.35, 0.62, 1.35, 0.9)
		Engine.time_scale = 0.3
		if idx == 0:
			combo_dmg[idx] += dummy_hp
			dummy_hp = 0
		else:
			combo_dmg[idx] += player_hp
			player_hp = 0
		combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
		atacante.sprite.speed_scale = 1.0
		atacante.sprite.play("air_spin_kick")
		victima.ultra_hover = false
		victima.receive_hit(false, true, dir, "kick_impact", false, 1.9)
		victima.hard_fall = true
		atacante.ultra_hover = false
		atacante.airborne = true
		atacante.vel_y = 220.0
		await get_tree().create_timer(0.45, true, false, true).timeout
		Engine.time_scale = 1.0
		var vuelo := 0.0
		while victima.airborne and vuelo < 2.0:
			await get_tree().process_frame
			vuelo += get_process_delta_time()
	# cierre
	_fe_cast_fx(atacante, false)
	atacante.ultra_hover = false
	atacante.airborne = false
	atacante.position.y = atacante.floor_y
	atacante.sprite.speed_scale = 1.0
	atacante.sprite.play("pose")
	atacante.breaker_fx_t = 0.0
	ultra_active = false
	var murio2: bool = (dummy_hp <= 0) if idx == 0 else (player_hp <= 0)
	state = "fight"
	if dummy_ai_mode and murio2:
		_end_round(idx == 0)
	else:
		player.input_enabled = true
		dummy.ai_enabled = dummy_ai_mode

# barra de vida: verde normal; ROJA parpadeante en zona de peligro (<=15%)
# ---- HUD: reubica barras, meter de 3 segmentos y avatares en las esquinas ----
# parallelogramo inclinado a la derecha (borde superior corrido por 'sl')
func _para(x0: float, x1: float, yt: float, yb: float, sl: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x0 + sl, yt), Vector2(x1 + sl, yt), Vector2(x1, yb), Vector2(x0, yb)])

# barra de vida: el borde del lado del AVATAR es RECTO (vertical); el del centro, inclinado
func _bar_poly(side: int, xL: float, xR: float, yt: float, yb: float, s: float) -> PackedVector2Array:
	if side == 0:   # avatar a la izquierda -> izquierda recta, derecha (centro) inclinada
		return PackedVector2Array([Vector2(xL, yt), Vector2(xR + s, yt), Vector2(xR, yb), Vector2(xL, yb)])
	else:           # avatar a la derecha -> derecha recta, izquierda (centro) inclinada
		return PackedVector2Array([Vector2(xL - s, yt), Vector2(xR, yt), Vector2(xR, yb), Vector2(xL, yb)])

const HP_YT := 40.0
const HP_YB := 74.0
const HP_SL := 22.0
const M_W := 118.0
const M_H := 22.0
const M_SL := 12.0
const M_GAP := 14.0
const M_Y := 80.0
const M_MARGIN := 16.0   # separación entre el avatar y la primera barra de carga

func _meter_x(side: int, s: int) -> float:
	return (P1_BAR_X + M_MARGIN + s * (M_W + M_GAP)) if side == 0 else ((P2_BAR_X + BAR_W) - M_MARGIN - M_W - s * (M_W + M_GAP))

# Ajusta un Sprite2D con retrato para que LLENE una caja de box_w x box_h (modo "cover"):
# recorta la textura a la proporción de la caja y la escala, sin importar su tamaño real.
# El recorte vertical va sesgado hacia ARRIBA (0.30) para conservar la cara.
func _cover_avatar(av: Sprite2D, box_w: float, box_h: float) -> void:
	if av == null or av.texture == null:
		return
	var tw := float(av.texture.get_width())
	var th := float(av.texture.get_height())
	if tw <= 0.0 or th <= 0.0:
		return
	var box_ar := box_w / box_h
	var rw := tw
	var rh := th
	if tw / th > box_ar:
		rw = th * box_ar          # textura más ancha que la caja -> recorta los lados
	else:
		rh = tw / box_ar          # textura más alta -> recorta arriba/abajo
	av.region_enabled = true
	av.region_rect = Rect2((tw - rw) * 0.5, (th - rh) * 0.30, rw, rh)
	av.scale = Vector2(box_w / rw, box_h / rh)

func _build_hud() -> void:
	# oculta las barras rectangulares viejas (ahora son polígonos inclinados)
	for n in ["P1Back", "P1Fill", "P2Back", "P2Fill"]:
		var nd = $UI.get_node_or_null(n)
		if nd: (nd as CanvasItem).visible = false
	# NOMBRE BOLD ITÁLICO (skew) sobre placa sutil + DOTS de rounds hacia el centro
	($UI/P1Label as Label).visible = false
	($UI/P2Label as Label).visible = false
	win_dots = [[], []]
	for side in 2:
		var nx0: float = (P1_BAR_X + 2) if side == 0 else (P2_BAR_X + BAR_W - 186)
		var nw := Node2D.new()         # wrapper con SKEW = itálica
		nw.skew = -0.22
		nw.position = Vector2(0, -8)   # sube el nombre: padding con la barra de vida
		nw.z_index = 5
		var lbl := Label.new()
		lbl.text = "DAM"
		lbl.add_theme_font_size_override("font_size", 36)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		lbl.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.04))
		lbl.add_theme_constant_override("outline_size", 11)
		lbl.size = Vector2(172, 40)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if side == 0:
			lbl.position = Vector2(nx0 + 20, 0)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		else:
			lbl.position = Vector2(nx0 - 4, 0)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		nw.add_child(lbl)
		$UI.add_child(nw)
		hud_name[side] = lbl
		for i in WINS_NEEDED:
			var dc: float = (770.0 + i * 34) if side == 0 else (1150.0 - i * 34)
			var d := Polygon2D.new()
			d.polygon = PackedVector2Array([Vector2(dc, 12), Vector2(dc + 9, 22), Vector2(dc, 32), Vector2(dc - 9, 22)])
			d.z_index = 4
			$UI.add_child(d)
			win_dots[side].append(d)
	# TIMER "99" bold itálico al centro (reemplaza el "0 - 0")
	rounds_label.visible = false
	var tw := Node2D.new()
	tw.skew = -0.16
	tw.z_index = 5
	tw.position = Vector2(960, 0)
	timer_label = Label.new()
	timer_label.text = "99"
	timer_label.add_theme_font_size_override("font_size", 66)
	timer_label.add_theme_color_override("font_color", Color(1, 1, 1))
	timer_label.add_theme_color_override("font_outline_color", Color(0.09, 0.14, 0.24))
	timer_label.add_theme_constant_override("outline_size", 12)
	timer_label.position = Vector2(-80, 2)
	timer_label.size = Vector2(160, 74)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tw.add_child(timer_label)
	$UI.add_child(tw)
	# BARRAS DE VIDA inclinadas: borde de color + fondo oscuro + relleno con TEXTURA de degradado
	hp_bar_bg = []; hp_bar_fill = []
	for side in 2:
		var x0: float = P1_BAR_X if side == 0 else P2_BAR_X
		var edge := Polygon2D.new()   # borde NEGRO fino
		edge.polygon = _bar_poly(side, x0 - 2, x0 + BAR_W + 2, HP_YT - 2, HP_YB + 2, HP_SL)
		edge.color = Color(0, 0, 0)
		$UI.add_child(edge)
		var bg := Polygon2D.new()   # parte vacía = oscuro neutro
		bg.polygon = _bar_poly(side, x0, x0 + BAR_W, HP_YT, HP_YB, HP_SL)
		bg.color = Color(0.05, 0.06, 0.09, 0.97)
		$UI.add_child(bg)
		hp_bar_bg.append(bg)
		var fill := Polygon2D.new()   # relleno AZUL PLANO
		fill.z_index = 1
		$UI.add_child(fill)
		hp_bar_fill.append(fill)
	# METER: 3 segmentos inclinados, VERDE PLANO (relleno por ancho: media barra = medio lleno)
	for side in 2:
		meter_bg[side].clear(); meter_fill[side].clear(); meter_fl[side].clear()
		var msl := M_SL if side == 0 else -M_SL   # espejo a la derecha
		for s in 3:
			var bx := _meter_x(side, s)
			var poly := _para(bx, bx + M_W, M_Y, M_Y + M_H, msl)
			var bgp := Polygon2D.new()   # fondo OSCURO (parte vacía del segmento)
			bgp.polygon = poly
			bgp.color = Color(0.06, 0.10, 0.07, 0.97)
			$UI.add_child(bgp)
			meter_bg[side].append(bgp)
			var fp := Polygon2D.new()    # relleno VERDE (se recalcula por carga, por ancho)
			fp.color = Color(0.22, 0.82, 0.34, 0.98)
			fp.z_index = 1
			$UI.add_child(fp)
			meter_fill[side].append(fp)
			var ln := Line2D.new()       # borde NEGRO fino
			var pts := PackedVector2Array(poly)
			pts.append(poly[0])
			ln.points = pts
			ln.width = 2.5
			ln.default_color = Color(0, 0, 0)
			ln.joint_mode = Line2D.LINE_JOINT_ROUND
			ln.z_index = 2
			$UI.add_child(ln)
			meter_fl[side].append(ln)
			# CHISPAS: pocas partículas verdes en loop, solo cuando el segmento está lleno
			var sp := CPUParticles2D.new()
			sp.position = Vector2(bx + M_W * 0.5 + msl * 0.5, M_Y + M_H * 0.5)
			sp.z_index = 3
			sp.emitting = false
			sp.amount = 7
			sp.lifetime = 0.75
			sp.explosiveness = 0.0
			sp.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			sp.emission_rect_extents = Vector2(M_W * 0.42, M_H * 0.45)
			sp.direction = Vector2(0, -1)
			sp.spread = 38.0
			sp.gravity = Vector2(0, 55)
			sp.initial_velocity_min = 22.0
			sp.initial_velocity_max = 58.0
			sp.scale_amount_min = 1.4
			sp.scale_amount_max = 3.0
			sp.color = Color(0.7, 2.6, 0.9)   # verde HDR -> bloom (chispa brillante)
			$UI.add_child(sp)
			meter_spark[side].append(sp)
	# AVATARES CUADRADOS en la esquina (la barra ARRANCA junto a ellos)
	var av_tex = load("res://imagen-action/dam/avatar/dam-avatar.png") if ResourceLoader.exists("res://imagen-action/dam/avatar/dam-avatar.png") else null
	for side in 2:
		var fx: float = 6.0 if side == 0 else 1794.0
		var sh_dx: float = 6.0 if side == 0 else -6.0   # la sombra cae hacia adentro, pegada
		var shadow := ColorRect.new()   # sombra plana (silueta sólida detrás)
		shadow.color = Color(0, 0, 0, 0.9)
		shadow.position = Vector2(fx + sh_dx, 8 + 6); shadow.size = Vector2(120, 120)
		shadow.z_index = 4
		$UI.add_child(shadow)
		var fr := ColorRect.new()   # marco negro
		fr.color = Color(0, 0, 0)
		fr.position = Vector2(fx, 8); fr.size = Vector2(120, 120)
		fr.z_index = 5
		$UI.add_child(fr)
		var inner := ColorRect.new()   # fondo oscuro
		inner.color = Color(0.06, 0.06, 0.09)
		inner.position = Vector2(fx + 3, 11); inner.size = Vector2(114, 114)
		inner.z_index = 5
		$UI.add_child(inner)
		if av_tex != null:
			var av := Sprite2D.new()   # retrato (recorte cuadrado, llena el marco)
			av.texture = av_tex
			av.centered = true
			_cover_avatar(av, 114, 114)   # llena el marco sea cual sea el tamaño de la textura
			av.position = Vector2(fx + 60, 68)
			av.flip_h = side == 1
			av.z_index = 6
			$UI.add_child(av)
			hud_avatar[side] = av

# actualiza el relleno inclinado de una barra de vida (se vacía hacia el centro)
func _update_hp_bar(side: int, hp: int) -> void:
	var fill: Polygon2D = hp_bar_fill[side]
	var frac := clampf(float(hp) / float(hp_max[side]), 0.0, 1.0)
	if frac <= 0.001:
		fill.visible = false
		return
	fill.visible = true
	var x0: float = P1_BAR_X if side == 0 else P2_BAR_X
	var lx: float
	var rx: float
	if side == 0:                       # outer = izquierda; se vacía hacia el centro (der)
		lx = x0; rx = x0 + BAR_W * frac
	else:                               # outer = derecha; se vacía hacia el centro (izq)
		rx = x0 + BAR_W; lx = rx - BAR_W * frac
	fill.polygon = _bar_poly(side, lx, rx, HP_YT, HP_YB, HP_SL)
	# relleno AZUL PLANO para ambos. En peligro (≤25%) parpadea ROJO.
	if hp > 0 and hp <= int(hp_max[side] * ULTRA_HP):
		var p := 0.6 + 0.4 * absf(sin(glow_time * 7.0))
		fill.texture = null
		fill.color = Color(2.3 * p, 0.26 * p, 0.16 * p)
	else:
		fill.texture = null
		fill.color = Color(0.16, 0.46, 0.95)

# frase de victoria de DAM ("my work is done...")
var _victory_stream = null       # voz de victoria de DAM
var _victory_stream_fe = null    # voz de victoria de Fe (energética, "no was easy")
func _play_victory_line(who = null) -> void:
	# Fe se detecta por su animación exclusiva water_cast; si no, es DAM
	var es_fe: bool = who != null and who.sprite.sprite_frames.has_animation("water_cast")
	var stream = null
	if es_fe:
		if _victory_stream_fe == null:
			var rfe := "res://imagen-action/favi/Fe-sound-effect/victory-fe-energetica.wav"
			_victory_stream_fe = load(rfe) if ResourceLoader.exists(rfe) else null
		stream = _victory_stream_fe
	else:
		if _victory_stream == null:
			var ruta := "res://imagen-action/sound-effect/my-work-is-done-dam.mp3"
			_victory_stream = load(ruta) if ResourceLoader.exists(ruta) else null
		stream = _victory_stream
	if stream != null and voz_player != null:
		# pequeño delay para que la voz caiga cuando la boca empieza a moverse (frame ~4)
		await get_tree().create_timer(0.35).timeout
		voz_player.stream = stream
		voz_player.play()

# grito de finisher: reproduce voz-<nombre>.wav si existe (voz infernal)
func _play_voz(nombre: String) -> void:
	if not _voz_cache.has(nombre):
		var ruta := "res://imagen-action/sound-effect/voz-%s.wav" % nombre
		_voz_cache[nombre] = load(ruta) if ResourceLoader.exists(ruta) else null
	var st = _voz_cache[nombre]
	if st != null and voz_player != null:
		voz_player.stream = st
		voz_player.play()

# voz de la patada giratoria (E): reproductor propio + cooldown para que no
# corte las voces de finisher ni se solape al encadenar patadas.
func _play_kick_voz() -> void:
	var ahora := Time.get_ticks_msec()
	if ahora - _kick_voz_t < 900:
		return
	if not _voz_cache.has("kicking"):
		var ruta := "res://imagen-action/sound-effect/voz-kicking.wav"
		_voz_cache["kicking"] = load(ruta) if ResourceLoader.exists(ruta) else null
	var st = _voz_cache["kicking"]
	if st != null and kick_voz_player != null:
		_kick_voz_t = ahora
		kick_voz_player.stream = st
		kick_voz_player.play()

# dispara un temblor de pantalla (amp en px, dur en seg); se acumula al mayor
func _shake(amp: float, dur: float) -> void:
	var ahora := Time.get_ticks_msec()
	var rem := shake_end_ms - ahora
	if amp >= shake_amp or rem <= 0:
		shake_amp = amp
	shake_dur_ms = maxi(1, int(dur * 1000.0))
	shake_end_ms = ahora + shake_dur_ms

# ENFOQUE del ULTRA: borde ROJO ELÉCTRICO en el atacante + escena oscurecida.
# La INTENSIDAD (uniform intensity 0..1) sube gradualmente con el combo.
const _OUTLINE_CODE := """
shader_type canvas_item;
render_mode unshaded;
uniform vec4 line_color : source_color = vec4(1.9, 0.12, 0.12, 1.0);
uniform float width = 3.2;
uniform float intensity = 0.0;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec2 s = TEXTURE_PIXEL_SIZE * width * (0.45 + 0.55 * intensity);   // el borde ENGROSA con la intensidad
	float a = 0.0;
	a = max(a, texture(TEXTURE, UV + vec2(s.x, 0.0)).a);
	a = max(a, texture(TEXTURE, UV + vec2(-s.x, 0.0)).a);
	a = max(a, texture(TEXTURE, UV + vec2(0.0, s.y)).a);
	a = max(a, texture(TEXTURE, UV + vec2(0.0, -s.y)).a);
	a = max(a, texture(TEXTURE, UV + vec2(s.x, s.y)).a);
	a = max(a, texture(TEXTURE, UV + vec2(-s.x, s.y)).a);
	a = max(a, texture(TEXTURE, UV + vec2(s.x, -s.y)).a);
	a = max(a, texture(TEXTURE, UV + vec2(-s.x, -s.y)).a);
	float outline = a * (1.0 - c.a) * intensity;          // aparece gradual con la intensidad
	float pulse = 0.75 + 0.35 * sin(TIME * 26.0);
	vec4 oc = vec4(line_color.rgb * (0.8 + 0.9 * pulse) * (0.6 + 0.4 * intensity), 1.0);
	COLOR = mix(c, oc, outline);
}
"""

# --- enfoque dinámico: nivel 0..1 que se suaviza hacia un objetivo ---
var focus_atk: Node2D = null
var focus_cur := 0.0
var focus_target := 0.0
var _focus_last_ms := 0

func _focus_start(atacante: Node2D) -> void:
	if _outline_mat == null:
		var sh := Shader.new()
		sh.code = _OUTLINE_CODE
		_outline_mat = ShaderMaterial.new()
		_outline_mat.shader = sh
	atacante.sprite.material = _outline_mat
	focus_atk = atacante
	focus_cur = 0.0
	focus_target = 0.0
	_focus_last_ms = Time.get_ticks_msec()
	_focus_apply()

func _focus_set(level: float) -> void:   # objetivo de intensidad (0..1)
	focus_target = clampf(level, 0.0, 1.0)

func _focus_end() -> void:
	if focus_atk != null:
		focus_atk.sprite.material = focus_atk.base_material   # restaura el color alterno (P2)
	focus_atk = null
	focus_cur = 0.0
	focus_target = 0.0
	modulate = Color(1, 1, 1)
	if ultra_panel != null:
		ultra_panel.visible = false   # quita los paneles manga al terminar el ultra

func _focus_apply() -> void:
	if _outline_mat != null:
		_outline_mat.set_shader_parameter("intensity", focus_cur)
	modulate = Color(1, 1, 1).lerp(Color(0.55, 0.55, 0.64), focus_cur)   # oscurece con la intensidad

# borde rojo eléctrico para el EMBER DASH (sin oscurecer la escena; el dash es rápido)
var _dash_mat: ShaderMaterial = null
func _dash_border(atacante: Node2D, on: bool) -> void:
	if on:
		if _dash_mat == null:
			var sh := Shader.new()
			sh.code = _OUTLINE_CODE
			_dash_mat = ShaderMaterial.new()
			_dash_mat.shader = sh
			_dash_mat.set_shader_parameter("intensity", 0.9)
		atacante.sprite.material = _dash_mat
	elif atacante.sprite.material == _dash_mat:
		atacante.sprite.material = atacante.base_material   # restaura el color alterno (P2)

# COLOR ALTERNO del P2 (mirror match): cambia el TONO de los colores SATURADOS
# (abrigo/pelo) sin tocar piel/negros, para distinguir P1 de P2. Respeta el modulate
# (quemadura/agua) y se restaura tras el ultra/dash vía base_material.
# Método simple y a prueba de negro: INTERCAMBIA rojo<->azul SOLO en el rojo profundo
# (abrigo/pelo de DAM). Piel (naranja, g/b más altos) y negros quedan intactos. NO
# toca el brillo, así que nunca sale silueta negra.
const _HUE_CODE := """
shader_type canvas_item;
render_mode unshaded;
uniform float amount = 1.0;
void fragment(){
	vec4 c = texture(TEXTURE, UV);
	float mask = smoothstep(0.25, 0.35, c.r) * (1.0 - smoothstep(0.32, 0.47, max(c.g, c.b)));
	vec3 swapped = vec3(c.b, c.g, c.r);   // rojo -> AZUL (intercambio de canal)
	c.rgb = mix(c.rgb, swapped, mask * amount);
	COLOR = c * COLOR;   // respeta el modulate (quemadura/agua)
}
"""
var _p2_mat: ShaderMaterial = null

func _apply_alt_colors() -> void:
	if _p2_mat == null:
		var sh := Shader.new()
		sh.code = _HUE_CODE
		_p2_mat = ShaderMaterial.new()
		_p2_mat.shader = sh
		_p2_mat.set_shader_parameter("amount", 1.0)
	player.base_material = null
	player.sprite.material = null                # P1: color normal
	dummy.base_material = _p2_mat
	dummy.sprite.material = _p2_mat              # P2: tono cambiado (mismo char, otro color)

# suaviza focus_cur hacia focus_target con reloj REAL (llamado desde _process)
# ---- ANUNCIOS épicos (READY / FIGHT / K.O.): fuente gruesa + SOMBRA PLANA atrás ----
func _mk_anno_label(col: Color, outline: int) -> Label:
	var l := Label.new()
	l.size = Vector2(1920, 300)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", combo_font)
	l.add_theme_font_size_override("font_size", 210)
	l.add_theme_color_override("font_color", col)
	if outline > 0:
		l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.55))
		l.add_theme_constant_override("outline_size", outline)
	l.pivot_offset = Vector2(960, 150)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _build_announce() -> void:
	# TODO va en el MUNDO, DETRÁS de los peleadores (z=-1, sobre el escenario): así los
	# PLAYERS SOBRESALEN por encima de las letras / rojo / retrato del ganador.
	# velo ROJO del KO
	ko_red = ColorRect.new()
	ko_red.color = Color(1.3, 0.06, 0.05, 0.0)
	ko_red.position = Vector2.ZERO
	ko_red.size = Vector2(1920, 1080)
	ko_red.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ko_red.z_index = -1
	add_child(ko_red)
	# líneas del ultra para el KO (ciclan ultra-1..6, tintadas de rojo)
	ko_lines = TextureRect.new()
	ko_lines.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ko_lines.stretch_mode = TextureRect.STRETCH_SCALE
	ko_lines.position = Vector2.ZERO
	ko_lines.size = Vector2(1920, 1080)
	ko_lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ko_lines.modulate = Color(1.7, 0.28, 0.28, 0.0)
	ko_lines.z_index = -1
	if ultra_panels.size() > 0:
		ko_lines.texture = ultra_panels[0]
	add_child(ko_lines)
	# retrato del GANADOR (por ahora DAM; Fe/otros luego) estilo cut-in del inferno
	win_portrait = TextureRect.new()
	if ResourceLoader.exists("res://imagen-action/dam/cutin/dam-cutin.png"):
		win_portrait.texture = load("res://imagen-action/dam/cutin/dam-cutin.png")
	win_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	win_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	win_portrait.size = Vector2(CUTIN_PW, CUTIN_PH)
	win_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	win_portrait.modulate = Color(1, 1, 1, 0.0)
	win_portrait.z_index = -1
	add_child(win_portrait)
	# grupo del texto grande (sombra plana) — encima del rojo/líneas pero DETRÁS de players
	anno_root = Control.new()
	anno_root.position = Vector2.ZERO
	anno_root.size = Vector2(1920, 1080)
	anno_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anno_root.z_index = -1
	anno_root.visible = false
	add_child(anno_root)
	anno_sh = _mk_anno_label(Color(0.05, 0.04, 0.07, 1.0), 0)   # SOMBRA plana (offset, sin borde)
	anno_sh.position = Vector2(18, 374)
	anno_root.add_child(anno_sh)
	anno_main = _mk_anno_label(Color(1, 1, 1, 1), 12)           # texto principal
	anno_main.position = Vector2(0, 356)
	anno_root.add_child(anno_main)

func _show_announce(txt: String, col: Color, dur: float, side := -1) -> void:
	if anno_root == null:
		return
	anno_main.text = txt
	anno_sh.text = txt
	anno_main.add_theme_color_override("font_color", col)
	anno_dur = dur
	anno_side = side
	anno_ms = Time.get_ticks_msec()
	anno_root.visible = true

func _announce_tick() -> void:
	if anno_root == null or not anno_root.visible:
		return
	var t := float(Time.get_ticks_msec() - anno_ms) / 1000.0
	if t < 0.0 or t > anno_dur:
		anno_root.visible = false
		return
	var pin := clampf(t / 0.17, 0.0, 1.0)                        # ENTRA desde un lado (rápido)
	var pout := clampf((t - (anno_dur - 0.20)) / 0.20, 0.0, 1.0)  # SALE por el lado opuesto
	# CRUZA la pantalla: entra desde 'anno_side', reposa al centro, sale al opuesto
	var enter_off := 2100.0 * float(anno_side)     # fuera de pantalla del lado de entrada
	var x := lerpf(enter_off, 0.0, _ease_out_cubic(pin))
	if pout > 0.0:
		x = lerpf(0.0, -enter_off, _ease_in_cubic(pout))
	# ligero rebote de escala al asentar + estela de la sombra en el sentido del movimiento
	var sc := lerpf(1.22, 1.0, _ease_out_back(pin))
	var vx := 0.0                                    # velocidad horizontal aprox (para la estela)
	if pin < 1.0: vx = -enter_off * (1.0 - pin) * 0.05
	elif pout > 0.0: vx = enter_off * pout * 0.05
	var a := clampf(pin * 3.0, 0.0, 1.0) * (1.0 - pout * 0.6)
	anno_main.position = Vector2(x, 356.0)
	anno_sh.position = Vector2(x + 18.0 + vx, 374.0)   # sombra plana + estela de velocidad
	anno_main.scale = Vector2(sc, sc)
	anno_sh.scale = Vector2(sc, sc)
	anno_main.modulate.a = a
	anno_sh.modulate.a = a * 0.85

func _ease_in_cubic(p: float) -> float:
	return p * p * p

# ---- CUT-IN del INFIERNO: retrato de DAM que entra desde un lado (estilo P4A) ----
func _build_cutin() -> void:
	# El cut-in va en el MUNDO, DETRÁS de los peleadores (z=-1, sobre el escenario):
	# así la acción (DAM + fuego + rival) y el HUD/combo se ven ENCIMA. Se agrega
	# después del escenario para quedar por delante de él.
	cutin_root = Control.new()
	cutin_root.position = Vector2.ZERO
	cutin_root.size = Vector2(1920, 1080)
	cutin_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cutin_root.z_index = -1
	cutin_root.visible = false
	add_child(cutin_root)
	# velo oscuro para que el cut-in resalte (detrás de la acción)
	cutin_dark = ColorRect.new()
	cutin_dark.color = Color(0.06, 0.0, 0.02, 0.0)
	cutin_dark.position = Vector2.ZERO
	cutin_dark.size = Vector2(1920, 1080)
	cutin_dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cutin_root.add_child(cutin_dark)
	# PANEL rojo que cubre TODO el ancho de la pantalla por abajo (sube desde abajo).
	# Ancho de sobra (2400) para que aún rotado cubra los 1920 sin cortarse.
	cutin_band = ColorRect.new()
	cutin_band.color = Color(0.85, 0.11, 0.05, 0.0)
	cutin_band.size = Vector2(2400.0, 860.0)
	cutin_band.pivot_offset = cutin_band.size * 0.5
	cutin_band.rotation = deg_to_rad(-9.0)
	cutin_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cutin_root.add_child(cutin_band)
	# LÍNEAS naranjas de velocidad (full-width, mismo ángulo que el panel)
	for i in 7:
		var ln := ColorRect.new()
		ln.color = Color(1.5, 0.55, 0.18, 0.0)
		ln.size = Vector2(2400.0, 7.0 + float(i % 3) * 5.0)
		ln.pivot_offset = ln.size * 0.5
		ln.rotation = deg_to_rad(-9.0)
		ln.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cutin_root.add_child(ln)
		cutin_lines.append(ln)
	# LÍNEAS DE ACCIÓN MANGA (como el ultra): ciclan ultra-1..6 para dar la vibración
	cutin_manga = TextureRect.new()
	cutin_manga.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cutin_manga.stretch_mode = TextureRect.STRETCH_SCALE
	cutin_manga.position = Vector2.ZERO
	cutin_manga.size = Vector2(1920, 1080)
	cutin_manga.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cutin_manga.modulate = Color(1, 1, 1, 0)
	if ultra_panels.size() > 0:
		cutin_manga.texture = ultra_panels[0]
	cutin_root.add_child(cutin_manga)
	# retrato de DAM (encima de la banda y las líneas)
	cutin_portrait = TextureRect.new()
	if ResourceLoader.exists("res://imagen-action/dam/cutin/dam-cutin.png"):
		cutin_portrait.texture = load("res://imagen-action/dam/cutin/dam-cutin.png")
	cutin_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cutin_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cutin_portrait.size = Vector2(CUTIN_PW, CUTIN_PH)
	cutin_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cutin_root.add_child(cutin_portrait)
	# flash blanco de entrada
	cutin_flash = ColorRect.new()
	cutin_flash.color = Color(1, 1, 1, 0)
	cutin_flash.position = Vector2.ZERO
	cutin_flash.size = Vector2(1920, 1080)
	cutin_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cutin_root.add_child(cutin_flash)

func _play_cutin(side: int) -> void:
	if cutin_root == null:
		return
	# side = -1 (retrato a la IZQUIERDA) o +1 (DERECHA). Se pasa el OPUESTO al combo.
	cutin_side = side
	cutin_ms = Time.get_ticks_msec()
	cutin_root.visible = true

func _cutin_tick() -> void:
	if cutin_root == null or not cutin_root.visible:
		return
	var t := float(Time.get_ticks_msec() - cutin_ms) / 1000.0
	var total := CUTIN_BG + CUTIN_IN + CUTIN_HOLD + CUTIN_OUT
	if t < 0.0 or t > total:
		cutin_root.visible = false
		return
	# fases: (1) el PANEL sube de abajo hacia arriba (full-width), (2) entra el
	# personaje, (3) hold largo, (4) salida.
	var pbg := clampf(t / CUTIN_BG, 0.0, 1.0)                       # subida del panel
	var pin := clampf((t - CUTIN_BG) / CUTIN_IN, 0.0, 1.0)          # entrada del personaje
	var pout := clampf((t - CUTIN_BG - CUTIN_IN - CUTIN_HOLD) / CUTIN_OUT, 0.0, 1.0)
	# --- PANEL: cubre TODO el ancho por abajo y sube desde abajo (y_off +1080 -> 0) ---
	var rise := lerpf(1080.0, 0.0, _ease_out_cubic(pbg))
	cutin_band.position = Vector2(960.0 - cutin_band.size.x * 0.5, 760.0 - cutin_band.size.y * 0.5 + rise)
	# líneas naranjas full-width, repartidas sobre el panel, suben con él
	for i in cutin_lines.size():
		var ln: ColorRect = cutin_lines[i]
		ln.position = Vector2(960.0 - ln.size.x * 0.5, 470.0 + float(i) * 95.0 - ln.size.y * 0.5 + rise)
	# --- PERSONAJE: entra desde su lado (OPUESTO al combo), con rebote ---
	var rest_x: float
	var off_x: float
	if cutin_side < 0:                      # retrato a la IZQUIERDA
		rest_x = -CUTIN_PW * 0.18
		off_x = -CUTIN_PW - 120.0
	else:                                   # a la DERECHA
		rest_x = 1920.0 - CUTIN_PW * 0.82
		off_x = 1920.0 + 120.0
	var x := lerpf(off_x, rest_x, _ease_out_back(pin))
	if pout > 0.0:
		x = lerpf(rest_x, off_x, pout * pout)
	cutin_portrait.position = Vector2(x, 1080.0 - CUTIN_PH + 30.0)
	# --- alfas ---
	var vis := 1.0 - pout
	cutin_dark.color.a = 0.4 * minf(pbg, vis)
	cutin_band.color.a = 0.85 * minf(pbg, vis)
	for lc in cutin_lines:
		lc.color.a = 0.5 * minf(pbg, vis)
	# líneas de acción MANGA: ciclan rápido (vibración) y suben con el panel
	if cutin_manga != null and ultra_panels.size() > 0:
		cutin_manga.texture = ultra_panels[int(t * 16.0) % ultra_panels.size()]
		cutin_manga.position = Vector2(0.0, rise * 0.6)
		cutin_manga.modulate.a = 0.8 * minf(pbg, vis)
	cutin_portrait.modulate.a = clampf(pin * 1.4, 0.0, 1.0) * vis
	# flash blanco cuando el personaje ENTRA (no al principio)
	var ft := t - CUTIN_BG
	cutin_flash.color.a = maxf(0.0, 0.7 * (1.0 - ft / 0.12)) if ft >= 0.0 else 0.0

func _ease_out_cubic(p: float) -> float:
	var q := 1.0 - p
	return 1.0 - q * q * q

func _focus_tick() -> void:
	if focus_atk == null:
		return
	var ahora := Time.get_ticks_msec()
	var dt := float(ahora - _focus_last_ms) / 1000.0
	_focus_last_ms = ahora
	focus_cur = move_toward(focus_cur, focus_target, 2.2 * dt)   # ~0.45s de 0 a full
	_focus_apply()

# color de la banda del combo: VERDE (pocos hits) -> rojo CLARO -> rojo INTENSO
func _combo_band_color(n: int) -> Color:
	var t := clampf((float(n) - 2.0) / 8.0, 0.0, 1.0)   # 0 en 2 hits, 1 en 10+
	var verde := Color(0.62, 0.86, 0.16)
	var rojo_claro := Color(1.55, 0.5, 0.38)            # rojo claro (HDR, con bloom)
	var rojo_int := Color(1.95, 0.11, 0.11)             # rojo intenso
	if t < 0.5:
		return verde.lerp(rojo_claro, t / 0.5)
	return rojo_claro.lerp(rojo_int, (t - 0.5) / 0.5)

func _ease_out_back(p: float) -> float:
	# entrada con rebote: pasa el destino y regresa (overshoot)
	var c1 := 1.70158
	var c3 := c1 + 1.0
	var q := p - 1.0
	return 1.0 + c3 * q * q * q + c1 * q * q

func _tint_hp_bar(bar: ColorRect, hp: int) -> void:
	if hp > 0 and hp <= int(MAX_HP * ULTRA_HP):
		var p := 0.6 + 0.4 * absf(sin(glow_time * 7.0))
		bar.color = Color(1.15 * p, 0.16 * p, 0.12 * p, 1.0)   # rojo que palpita
	else:
		bar.color = Color(0.32, 0.82, 0.4, 1.0)                # verde normal

func _physics_process(_delta: float) -> void:
	# BREAK PRACTICE: el combo breaker se recarga solo (rompes cuantas veces quieras)
	if break_practice and state == "fight" and player.breaker_inv_t <= 0.0:
		player.breaker_ready = true
	# aviso en pantalla: el jugador puede lanzar ANIQUILACIÓN (rival en rojo +
	# combo VIVO de 3+, dentro de la ventana, no mientras el numero se apaga)
	if ultra_hint:
		var listo: bool = state == "fight" and not ultra_active \
				and combo_n[0] >= 3 and combo_t[0] <= COMBO_WINDOW \
				and meter[0] >= 2.0
		ultra_hint.visible = listo
		if listo:
			ultra_hint.modulate.a = 0.6 + 0.4 * absf(sin(glow_time * 8.0))
	# contador de combos: pop, cierre y desvanecido
	for i in 2:
		var victima: Node2D = dummy if i == 0 else player
		if victima.hit_flying:
			combo_t[i] = 0.0  # mientras la victima vuela, el combo sigue vivo
		combo_t[i] += _delta
		var c: Node2D = combo_ui[i]
		# al APARECER (combo nuevo): fija el lado CONTRARIO a donde mira el atacante
		# (i=0 ataca el jugador, i=1 ataca el rival) y dispara la entrada deslizada
		if c.visible and not combo_was_vis[i]:
			combo_show_ms[i] = Time.get_ticks_msec()
			var atk: Node2D = player if i == 0 else dummy
			combo_rest_x[i] = 270.0 if atk.facing > 0 else 1650.0
		combo_was_vis[i] = c.visible
		if c.visible:
			# la banda vira de VERDE a ROJO (claro->intenso) según crece el combo
			combo_band[i].color = _combo_band_color(combo_n[i])
			# ENTRA deslizando desde SU borde (el opuesto a donde mira el atacante)
			var rest_x: float = combo_rest_x[i]
			var off_x: float = rest_x - 780.0 if rest_x < 960.0 else rest_x + 780.0
			var ts := float(Time.get_ticks_msec() - int(combo_show_ms[i])) / 1000.0
			if ts < 0.34:
				c.position.x = lerpf(off_x, rest_x, _ease_out_back(ts / 0.34))
			else:
				c.position.x = rest_x
			c.scale = c.scale.lerp(Vector2.ONE, minf(12.0 * _delta, 1.0))
			if combo_n[i] > 0 and combo_t[i] > COMBO_WINDOW:
				c.modulate.a -= 1.6 * _delta
				if c.modulate.a <= 0.0:
					c.visible = false
					combo_n[i] = 0
	# combo fijado: visible arriba durante la pelea
	if pin_panel:
		if pinned_combo >= 0 and state in ["fight", "demo"] \
				and Input.is_action_just_pressed("pin_clear"):
			pinned_combo = -1  # C: quitar la guia de pantalla
		pin_panel.visible = pinned_combo >= 0 and state in ["fight", "demo"]
		if pin_panel.visible:
			pin_success_t = maxf(0.0, pin_success_t - _delta)
			if pin_success_t > 0.0:
				pin_label.text = "✔  SUCCESS!"
				pin_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))
			else:
				pin_label.text = "★  " + String(DEMO_COMBOS[pinned_combo][0]) + "    [C]"
				pin_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))

	# el fuego de la ciudad respira: el bloom pulsa con dos ondas superpuestas
	glow_time += _delta
	world_env.environment.glow_intensity = 1.1 + 0.18 * sin(glow_time * 1.4) + 0.08 * sin(glow_time * 3.7)

	# menu de modo de rival
	if state == "menu":
		var dirm := 0
		if Input.is_action_just_pressed("ui_up"):
			dirm = -1
		if Input.is_action_just_pressed("ui_down"):
			dirm = 1
		menu_sel = posmod(menu_sel + dirm, 4)
		for j in 4:
			menu_opts[j].modulate = Color(1.0, 0.85, 0.25) if j == menu_sel else Color(0.62, 0.62, 0.68)
			menu_opts[j].text = ("▶  " if j == menu_sel else "") + ["AI FIGHT", "PRACTICE DUMMY", "BREAK PRACTICE", "MOVES & COMBOS"][j]
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
			if menu_sel == 3:
				_open_moves()          # abre la lista (actualiza el texto según el personaje elegido)
			else:
				# guarda el modo y pasa a elegir personaje
				pending_mode = menu_sel
				menu_panel.visible = false
				char_panel.visible = true
				state = "char_select"
		return
	if state == "char_select":
		var dc := 0
		if Input.is_action_just_pressed("ui_left"):
			dc = -1
		if Input.is_action_just_pressed("ui_right"):
			dc = 1
		char_sel = posmod(char_sel + dc, CHARS.size())
		for i in char_cards.size():
			char_cards[i]["border"].color = Color(1.0, 0.85, 0.25) if i == char_sel else Color(0, 0, 0)
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
			selected_char = String(CHARS[char_sel]["id"])
			# 0=AI FIGHT, 1=PRACTICE DUMMY, 2=BREAK PRACTICE
			break_practice = pending_mode == 2
			dummy_ai_mode = pending_mode == 0 or pending_mode == 2
			char_panel.visible = false
			_start_round()
		elif Input.is_action_just_pressed("ui_cancel"):
			char_panel.visible = false
			menu_panel.visible = true
			state = "menu"
		return
	if state == "moves":
		var dirm2 := 0
		if Input.is_action_just_pressed("ui_up"):
			dirm2 = -1
		if Input.is_action_just_pressed("ui_down"):
			dirm2 = 1
		moves_sel = posmod(moves_sel + dirm2, moves_items.size())
		if Input.is_action_just_pressed("kick"):
			pinned_combo = -1 if pinned_combo == moves_sel else moves_sel
		for j in moves_items.size():
			moves_items[j].modulate = Color(1.0, 0.85, 0.25) if j == moves_sel else Color(0.85, 0.85, 0.9)
			moves_items[j].text = ("▶ " if j == moves_sel else "   ") \
					+ ("★ " if j == pinned_combo else "") + DEMO_COMBOS[j][0]
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
			_run_demo(String(DEMO_COMBOS[moves_sel][1]))
		elif Input.is_action_just_pressed("ui_cancel"):
			moves_panel.visible = false
			menu_panel.visible = true
			state = "menu"
		return
	if state == "demo":
		if Input.is_action_just_pressed("ui_cancel"):
			_open_moves()
			return
	if state == "fight" and Input.is_action_just_pressed("ui_cancel"):
		_open_menu()
		return

	# en entrenamiento solo existe el jugador: sin empuje, sin golpes, sin barras
	if TRAINING:
		player.position.x = clampf(player.position.x, LEFT_LIMIT, RIGHT_LIMIT)
		return

	# cajas de empuje: los cuerpos no se traspasan (salvo saltando por encima
	# o cuando uno esta derribado)
	if not player.airborne and not dummy.airborne \
			and not player.koed and not dummy.koed \
			and not player.is_downed() and not dummy.is_downed():
		var sep_dx: float = dummy.position.x - player.position.x
		var overlap := BODY_SEP - absf(sep_dx)
		if overlap > 0.0:
			var dir := 1.0 if sep_dx >= 0.0 else -1.0
			player.position.x -= dir * overlap * 0.5
			dummy.position.x += dir * overlap * 0.5

	# combos de 5+ hits: el ESCENARIO se tine dramatico (los peleadores y la UI
	# quedan normales y resaltan como con reflector)
	if code_stage != null:
		var combo_epico: bool = combo_n[0] > 4 or combo_n[1] > 4
		var tinte := Color(0.42, 0.38, 0.82) if combo_epico else Color(1, 1, 1)
		code_stage.modulate = code_stage.modulate.lerp(tinte, 0.1)

	# deslizamiento de asistencia del demo: DAM persigue al rival suavemente
	if state == "demo" and demo_glide_t > 0.0:
		demo_glide_t -= get_physics_process_delta_time()
		var tx := clampf(dummy.position.x - 180.0, 115.0, 1805.0)
		player.position.x = lerpf(player.position.x, tx, 0.4)
		if player.airborne and dummy.airborne:
			player.position.y = lerpf(player.position.y, clampf(dummy.position.y, 145.0, 625.0), 0.4)

	# limites de pantalla
	player.position.x = clampf(player.position.x, LEFT_LIMIT, RIGHT_LIMIT)
	dummy.position.x = clampf(dummy.position.x, LEFT_LIMIT, RIGHT_LIMIT)

	if state == "fight" or state == "demo":
		# siempre de frente al rival
		player.set_facing(1 if dummy.position.x >= player.position.x else -1)
		dummy.set_facing(1 if player.position.x >= dummy.position.x else -1)

		# golpes en ambos sentidos
		attack_done_p1 = _process_attacker(player, dummy, attack_done_p1, true)
		attack_done_p2 = _process_attacker(dummy, player, attack_done_p2, false)

		# RECARGA del meter: pasiva con el tiempo + extra al caminar hacia el rival.
		# (los golpes también recargan, en _process_attacker.)
		if not ultra_active:
			for i in 2:
				var fgt: Node2D = player if i == 0 else dummy
				var gain := METER_REGEN
				if String(fgt.sprite.animation) == "walk" and fgt.walk_dir == 1:
					gain += METER_WALK          # caminando hacia adelante
				meter[i] = clampf(meter[i] + gain * _delta, 0.0, METER_MAX)

	# BARRAS DE VIDA inclinadas (se vacían hacia el CENTRO) con degradado
	_update_hp_bar(0, player_hp)
	_update_hp_bar(1, dummy_hp)
	# METER: relleno VERDE por ANCHO (media barra = medio llena), desde el lado del avatar.
	# Las chispas (partículas) sólo emiten en el segmento lleno.
	for side in 2:
		var mv: float = meter[side]
		var msl := M_SL if side == 0 else -M_SL
		for s in 3:
			var f := clampf(mv - float(s), 0.0, 1.0)
			var lleno := f >= 0.999
			var fp: Polygon2D = meter_fill[side][s]
			if f <= 0.001:
				fp.visible = false
			else:
				fp.visible = true
				var bx := _meter_x(side, s)
				if side == 0:   # llena desde la izquierda (lado del avatar) hacia el centro
					fp.polygon = _para(bx, bx + M_W * f, M_Y, M_Y + M_H, msl)
				else:           # llena desde la derecha (lado del avatar) hacia el centro
					fp.polygon = _para(bx + M_W * (1.0 - f), bx + M_W, M_Y, M_Y + M_H, msl)
			if s < meter_spark[side].size():
				meter_spark[side][s].emitting = lleno   # chispas solo en el segmento lleno
	# DOTS de rounds: encendidos = rondas ganadas
	for side in 2:
		var w: int = wins_p1 if side == 0 else wins_p2
		for i in WINS_NEEDED:
			win_dots[side][i].color = Color(1.9, 1.55, 0.4) if i < w else Color(0.28, 0.3, 0.36)

# show del BREAK en tiempo REAL: corre aunque el juego este congelado o lento
func _process(_dt: float) -> void:
	var ahora := Time.get_ticks_msec()
	# TEMBLOR de pantalla: sacude el nodo raíz (reloj REAL, inmune al time_scale)
	var srem := shake_end_ms - ahora
	if srem > 0:
		var k := float(srem) / float(shake_dur_ms)
		position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_amp * k
	elif position != Vector2.ZERO:
		position = Vector2.ZERO
	_focus_tick()   # suaviza el borde rojo hacia su intensidad objetivo
	_cutin_tick()   # anima el cut-in del INFIERNO (entrada/salida, reloj REAL)
	_announce_tick()  # anima el anuncio grande (READY/FIGHT/K.O.)
	var t := float(ahora - break_ms) / 1000.0
	if t >= 0.0 and t < 1.7:
		break_node.visible = true
		for bd in break_banners:
			var b: Node2D = bd["node"]
			var ww: float = bd["w"]
			var yy: float = bd["y"]
			var xo: float = bd["xo"]
			# se ANCLAN al lado del breaker y NO se salen del borde
			var rest_x: float
			var off_x: float
			if break_side < 0:                                # breaker a la izquierda
				rest_x = 150.0 + xo                           # xo = corrimiento a la derecha
				off_x = -ww - 220.0                           # entra desde el borde izq
			else:                                             # breaker a la derecha (espejado)
				rest_x = 1920.0 - ww - 150.0 - xo             # pegado al borde der
				off_x = 1920.0 + 220.0                        # entra desde el borde der
			var ti := t - float(bd["delay"])
			if ti < 0.0:
				b.visible = false
				continue
			b.visible = true
			var px: float
			if ti < 0.42:
				# ENTRA deslizando con rebote (overshoot) desde el borde del breaker
				px = lerpf(off_x, rest_x, _ease_out_back(ti / 0.42))
			elif t < 1.35:
				px = rest_x                                   # se sostiene
			else:
				# SALE rápido hacia su borde de nuevo
				var p2 := clampf((t - 1.35) / 0.28, 0.0, 1.0)
				px = lerpf(rest_x, off_x, p2 * p2)
			b.position = Vector2(px, yy)
	elif break_node != null and break_node.visible:
		break_node.visible = false
	var tf := float(ahora - flash_ms) / 1000.0
	if tf >= 0.0 and tf < 0.3:
		flash_rect.color.a = 0.55 * (1.0 - tf / 0.3)
	elif flash_rect != null and flash_rect.color.a > 0.0:
		flash_rect.color.a = 0.0

func _process_attacker(att: Node2D, def: Node2D, done: String, att_is_player: bool) -> String:
	var atk: Dictionary = att.current_attack()
	if atk.is_empty():
		return ""
	if done == String(atk["name"]) or int(atk["frame"]) < int(atk["hit_frame"]):
		return done
	done = String(atk["name"])
	if def.koed or (def.is_downed() and not def.hit_flying):
		return done
	# el AIR JAB (arriba R) es AIRE-A-AIRE: SOLO conecta si el rival está EN EL AIRE
	# (si el rival está en el suelo, pasa de largo aunque el atacante haya saltado)
	if String(atk["name"]) in ["air_jab", "air_jab_2"] \
			and not (def.airborne and (def.floor_y - def.position.y) > 40.0):
		return done
	# los golpes BAJOS raspan el piso: fallan contra un rival en el aire
	if bool(atk.get("low", false)) and def.airborne \
			and (def.floor_y - def.position.y) > 40.0:
		return done
	var dx: float = def.position.x - att.position.x
	if absf(dx) > float(atk["reach"]) + HIT_MARGIN:
		# la giratoria y el dash viajan: si aun no alcanza, sigue intentando cada frame
		if String(atk["name"]) in ["spin_kick", "air_spin_kick", "ember_dash"]:
			return ""
		return done
	# alcance vertical: si alguien esta en el aire, lo que importa es la
	# distancia REAL entre los cuerpos (la giratoria se eleva y eso cuenta)
	var alcanza := true
	if att.airborne or def.airborne:
		# las giratorias barren mas banda vertical (el mortal cubre todo el giro)
		var v_max := 420.0 if String(atk["name"]) in ["spin_kick", "air_spin_kick"] else 360.0
		alcanza = absf(att.position.y - def.position.y) <= v_max
	if not alcanza:
		if String(atk["name"]) in ["spin_kick", "air_spin_kick", "ember_dash"]:
			return ""
		return done
	var push := 1 if dx >= 0.0 else -1
	var result: String = def.receive_hit(bool(atk["low"]), bool(atk.get("strong", false)), push, String(atk.get("impact_sfx", "")), bool(atk.get("trip", false)), float(atk.get("launch_mult", 1.0)), bool(atk.get("wall_launch", false)))
	if result != "ignored":
		att.duck_swing()
	# BLOQUEAR gasta energía: mantener la guardia mientras recibís golpes drena el meter
	# (proporcional a la fuerza del golpe). Es un costo por cada golpe aguantado.
	if result == "blocked":
		var didx := 1 if att_is_player else 0
		meter[didx] = maxf(0.0, meter[didx] - float(atk.get("damage", 50)) * BLOCK_DRAIN)
	if result == "hit" or result == "launched":
		# HITSTOP: ambos se CONGELAN unos frames en el impacto (peso + pausa entre golpes,
		# como los juegos pro). Golpe fuerte = congela más.
		var hs := 0.11 if bool(atk.get("strong", false)) else 0.07
		att.apply_hitstop(hs)
		def.apply_hitstop(hs)
		# si el atacante golpea EN EL AIRE, flota un poco para seguir el juggle (si
		# falla en el aire NO flota: cae normal)
		if att.airborne:
			att.air_float_t = 0.45
		var hidx := 0 if att_is_player else 1
		var dmg_real: int = _combo_hit(hidx, int(atk["damage"]),
				String(atk["name"]), att.airborne or def.airborne)
		# temblorcito por cada golpe conectado (crece un poco con el combo)
		_shake(clampf(4.0 + float(combo_n[hidx]) * 0.7, 4.0, 13.0), 0.08)
		# el METER carga: el que pega gana más, el que recibe un poco
		meter[hidx] = minf(METER_MAX, meter[hidx] + float(dmg_real) * 0.0020)   # pegar CARGA
		meter[1 - hidx] = maxf(0.0, meter[1 - hidx] - float(dmg_real) * HIT_DRAIN)   # recibir DRENA
		# la IA puede romper tu combo largo (si aun tiene su breaker)
		if att_is_player and dummy_ai_mode and combo_n[0] >= 3 and randf() < 0.55:
			if dummy.do_breaker():
				on_breaker(dummy)
		if att_is_player:
			dummy_hp = maxi(0, dummy_hp - dmg_real)
			if dummy_hp <= 0:
				if dummy_ai_mode and not break_practice:
					_end_round(true)
				else:
					dummy_hp = hp_max[1]  # munieco de practica / drill: se reinicia, no muere
		else:
			player_hp = maxi(0, player_hp - dmg_real)
			if player_hp <= 0:
				if dummy_ai_mode and not break_practice:
					_end_round(false)
				else:
					player_hp = hp_max[0]
	return done

func _end_round(player_won: bool) -> void:
	if state != "fight":
		return
	state = "round_end"
	player.input_enabled = false
	dummy.ai_enabled = false
	announce.visible = false
	# CINEMÁTICO del KO: CONGELA la pantalla, sale K.O. GRANDE, la pantalla se pone
	# ROJA con las líneas del ultra... y luego se va todo y siguen los frames normales.
	_show_announce("K.O.", Color(0.88, 0.15, 0.12), 2.4, -1)   # sólido, bajo el umbral de glow
	ko_lines.modulate = Color(1.7, 0.28, 0.28, 0.0)         # líneas rojas (DETRÁS de players)
	ko_lines.visible = true
	_shake(26.0, 0.5)
	Engine.time_scale = 0.0                                  # FREEZE (largo)
	var ks := Time.get_ticks_msec()
	while Time.get_ticks_msec() - ks < 1050:
		var kt := float(Time.get_ticks_msec() - ks) / 1000.0
		if ultra_panels.size() > 0:
			ko_lines.texture = ultra_panels[int(kt * 16.0) % ultra_panels.size()]
		ko_lines.modulate.a = 1.0
		ko_red.color.a = 0.62                                # pantalla ROJA (detrás, players sobresalen)
		await get_tree().process_frame
	Engine.time_scale = 1.0                                  # ...y SIGUEN los frames normales
	if player_won:
		wins_p1 += 1
		dummy.do_ko()
	else:
		wins_p2 += 1
		player.do_ko()
	rounds_label.text = "%d  -  %d" % [wins_p1, wins_p2]
	# se VA todo: el rojo y las líneas se desvanecen mientras el KO cae
	var fsm := Time.get_ticks_msec()
	while Time.get_ticks_msec() - fsm < 800:
		var k := 1.0 - float(Time.get_ticks_msec() - fsm) / 800.0
		ko_red.color.a = 0.62 * k
		ko_lines.modulate.a = k
		if ultra_panels.size() > 0:
			ko_lines.texture = ultra_panels[int(float(Time.get_ticks_msec() - fsm) / 60.0) % ultra_panels.size()]
		await get_tree().process_frame
	ko_red.color.a = 0.0
	ko_lines.visible = false
	await get_tree().create_timer(0.7).timeout
	if player_won:
		player.celebrate()
	else:
		dummy.celebrate()
	# GANADOR: su retrato (estilo cut-in del inferno) entra DETRÁS de los peleadores;
	# el player celebra ENCIMA y SOBRESALE. Por ahora siempre DAM (Fe/otros luego).
	var wside := -1 if player_won else 1
	var wrest_x := (-CUTIN_PW * 0.14) if wside < 0 else (1920.0 - CUTIN_PW * 0.86)
	var woff_x := wrest_x - 240.0 * float(wside)
	win_portrait.position = Vector2(woff_x, 1080.0 - CUTIN_PH + 30.0)
	win_portrait.visible = true
	_show_announce("DAM WINS", Color(0.88, 0.75, 0.28), 3.3, wside)
	var ws := Time.get_ticks_msec()
	while Time.get_ticks_msec() - ws < 340:
		var wp := float(Time.get_ticks_msec() - ws) / 340.0
		win_portrait.position.x = lerpf(woff_x, wrest_x, _ease_out_cubic(wp))
		win_portrait.modulate.a = wp
		await get_tree().process_frame
	win_portrait.position.x = wrest_x
	win_portrait.modulate.a = 1.0
	await get_tree().create_timer(2.55).timeout
	var wf := Time.get_ticks_msec()
	while Time.get_ticks_msec() - wf < 430:
		win_portrait.modulate.a = 1.0 - float(Time.get_ticks_msec() - wf) / 430.0
		await get_tree().process_frame
	win_portrait.modulate.a = 0.0
	win_portrait.visible = false
	if wins_p1 >= WINS_NEEDED or wins_p2 >= WINS_NEEDED:
		announce.visible = true
		announce.text = "MATCH WINNER:\nDAM"
		await get_tree().create_timer(3.0).timeout
		wins_p1 = 0
		wins_p2 = 0
		round_num = 1
	else:
		round_num += 1
	_start_round()
