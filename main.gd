extends Node2D

# Arbitro del combate: rondas, vida, hitboxes y anuncios.

const LEFT_LIMIT := 115.0
const RIGHT_LIMIT := 1805.0
const MAX_HP := 100
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

var player_hp := MAX_HP
var dummy_hp := MAX_HP
var round_num := 1
var wins_p1 := 0
var wins_p2 := 0
# --- HUD nuevo: geometría de barras, METER de 3 segmentos, timer, puntos ---
const BAR_W := 700.0
const P1_BAR_X := 126.0    # la barra PEGADA al avatar (borde recto) y va al centro
const P2_BAR_X := 1094.0   # (1094 + 700 = 1794 = borde interno del avatar derecho)
const METER_MAX := 3.0
const MATCH_TIME := 99.0
var meter := [0.0, 0.0]        # carga del meter por lado (0..3)
var hp_bar_bg := []            # [P1,P2] fondo poligonal inclinado de la barra de vida
var hp_bar_fill := []          # [P1,P2] relleno poligonal (se recalcula por HP)
var hp_grad := []              # [P1,P2] texturas de degradado del relleno
var meter_bg := [[], []]       # fondo de cada segmento (3 por lado)
var meter_fl := [[], []]       # relleno de cada segmento (glow azul al cargar)
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
var _kick_voz_t := 0                        # cooldown (ms) para no solapar la voz de patada
var _voz_cache := {}                        # streams de voz cacheados por nombre
var ding_stream = null
var combo_ui := []      # contenedor por lado
var combo_num := []     # numero gigante
var combo_nom := []     # nombre del rango
var combo_band := []    # banda de color del número (verde -> rojo según el combo)
var combo_rest_x := [270.0, 1650.0]   # x de reposo del cartel (izq / der)
var combo_show_ms := [-100000, -100000]  # reloj REAL del inicio de la entrada deslizada
var combo_was_vis := [false, false]   # para detectar cuando aparece (y disparar el slide)

# menu de modo de rival
var dummy_ai_mode := true
var break_practice := false     # modo BREAK PRACTICE: la IA encadena combos y tú rompes
var menu_panel: ColorRect
var moves_panel: ColorRect
var menu_opts := []
var menu_sel := 0
var moves_sel := 0
var moves_items := []
var pinned_combo := -1
# BREAK epico: baner gigante + fogonazo de pantalla
var break_node: Node2D
var flash_rect: ColorRect
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
	if ResourceLoader.exists("res://imagen-action/sound-effect/combo-ding.wav"):
		ding_stream = load("res://imagen-action/sound-effect/combo-ding.wav")
	# musica de fondo en loop, bajita
	var music := AudioStreamPlayer.new()
	music.volume_db = -20.0
	add_child(music)
	var ruta_bg := "res://imagen-action/sound-effect/tunetank-emotional-classical-484234.mp3"
	if ResourceLoader.exists(ruta_bg):
		var bg_stream = load(ruta_bg)
		if bg_stream is AudioStreamMP3:
			bg_stream.loop = true          # repite sin cortes
		music.stream = bg_stream
		music.play()
	for i in 2:
		var c := Node2D.new()
		c.position = Vector2(270, 300) if i == 0 else Vector2(1650, 300)
		c.visible = false
		$UI.add_child(c)
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
		# número gigante BLANCO con contorno oscuro (resalta sobre el verde), centrado
		var n := Label.new()
		n.add_theme_font_size_override("font_size", 112)
		n.add_theme_color_override("font_color", Color(1, 1, 1))
		n.add_theme_color_override("font_outline_color", Color(0.05, 0.07, 0.02))
		n.add_theme_constant_override("outline_size", 12)
		n.position = Vector2(-HW, -110)
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
	var col1 := Label.new()
	col1.add_theme_font_size_override("font_size", 24)
	col1.position = Vector2(80, 118)
	col1.size = Vector2(560, 520)
	col1.text = "MOVES:\n\nR  —  Quick jab (4)\n↓ + R  —  Low jab (4)\nQ  —  Horizontal slash (8)\n→ + Q  —  Double slash (8+6)\n↓ ↘ →  + Q  —  EMBER DASH (15), wall slam\nW  —  Heavy slash (12)\n↓ + Q  —  Crouch slash (6)\n↓ + W  —  Rising launcher (9) ▲\nE  —  Traveling spin kick (13) ▲\n↓ + E  —  Ground sweep (12) ▼\nJump + Q  —  Air slash (9)\nJump + W  —  Dive kick (10)\nJump + E  —  Somersault kick (13) ▲\n\n▲ = launches into the air     ▼ = knocks down"
	vp.add_child(col1)
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

func on_breaker(quien: Node2D) -> void:
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

func _open_moves() -> void:
	state = "moves"
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
	player_hp = MAX_HP
	dummy_hp = MAX_HP
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

func _start_round() -> void:
	state = "intro"
	player.input_enabled = false
	dummy.ai_enabled = false
	player.revive()
	dummy.revive()
	player.position = Vector2(630, 625)
	dummy.position = Vector2(1290, 625)
	player.set_facing(1)
	dummy.set_facing(-1)
	player_hp = MAX_HP
	dummy_hp = MAX_HP
	for i in 2:
		combo_n[i] = 0
		combo_t[i] = 99.0
		combo_last[i] = ""
		combo_ui[i].visible = false
	meter = [0.0, 0.0]        # el meter arranca vacío cada ronda
	rounds_label.text = "%d  -  %d" % [wins_p1, wins_p2]
	announce.visible = true
	announce.text = "ROUND %d" % round_num
	await get_tree().create_timer(1.4).timeout
	announce.text = "FIGHT!"
	await get_tree().create_timer(0.7).timeout
	announce.visible = false
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
	var vhp: int = dummy_hp if atacante == player else player_hp
	if vhp > int(MAX_HP * ULTRA_HP):
		return false          # el rival aun tiene demasiada vida
	# el combo debe estar VIVO (3+ hits y dentro de la ventana): si ya dropeaste
	# aunque el numero siga apagandose en pantalla, ya NO cuenta
	if combo_n[idx] < 3 or combo_t[idx] > COMBO_WINDOW:
		return false
	_run_ultra(atacante, idx, largo)
	return true

func _ultra_count(idx: int, n: int, nombre := "") -> void:
	combo_n[idx] = n
	combo_t[idx] = 0.0
	combo_num[idx].text = str(n)
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
		# el rival se tambalea de pie recibiendo golpes (usa "pummeled" si existe)
		victima.crouching = false
		victima.airborne = false
		victima.ultra_hover = false
		# SIEMPRE mira hacia el atacante para que el recular sea acorde al golpe
		victima.set_facing(1 if atacante.position.x > victima.position.x else -1)
		var pose := "pummeled" if victima.sprite.sprite_frames.has_animation("pummeled") \
				else ("take_hit_low" if i % 2 == 0 else "take_hit")
		victima.sprite.play(pose)
		victima._play_sfx_key("take_hit")   # sonido de impacto por golpe
		victima._burst(0.95)                # chispas de golpe
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
	# FINISHER: mortal aereo (E arriba) que manda al rival MUY alto + caida brusca
	if state == "ultra":
		victima.ultra_hover = false   # libera el juggle: ahora el remate lo lanza
		atacante.sprite.speed_scale = 1.0
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
			dummy_hp = MAX_HP
		else:
			player_hp = MAX_HP
		state = "fight"
		player.input_enabled = true
		dummy.ai_enabled = dummy_ai_mode

# ---- INFIERNO: crítico de FUEGO (↓↘→+E tras un combo de 7+) ----
const CRIT_DMG := 50   # el golpe mas fuerte del juego

func try_critical(atacante: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if atacante == player else 1
	# requiere un combo VIVO de 7+ (rango MASTER)
	# TEMPORAL PARA PROBAR: bajado a 3; devolver a 7 despues
	if combo_n[idx] < 3 or combo_t[idx] > COMBO_WINDOW:
		return false
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
	# ENTRADA CINEMÁTICA (como el ULTRA): CONGELA el tiempo + la pantalla se
	# OSCURECE (velo rojo) + DAM alza la katana rodeado de SOMBRAS DE PODER
	atacante.sprite.play("flame_cast")
	_play_voz("inferno")                   # GRITA el poder al alzar la katana (ANTES de la bola)
	atacante.breaker_fx_t = 1.3            # sombras fantasma durante la carga
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.10, 0.01, 0.0, 0.55)   # velo OSCURO rojizo (no fogonazo)
	Engine.time_scale = 0.0                # pausa dramática
	await get_tree().create_timer(0.32, true, false, true).timeout
	Engine.time_scale = 1.0                # vuelve a velocidad NORMAL...
	# ...y AHÍ suelta la descarga: fogonazo naranja de ignición
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(1.3, 0.5, 0.12, 0.5)
	await get_tree().create_timer(0.12).timeout   # remata la pose antes de soltar
	# LANZA el vórtice de fuego que RUEDA por el suelo hacia el rival (veloz)
	var w: Node2D = atacante.spawn_fire_wave()
	var meta_x := victima.position.x - float(dir) * 60.0
	if w != null:
		var viaje := 0.0
		# vuela como bala de cañón: veloz, pero con un mínimo visible
		while viaje < 0.22 or float(dir) * (meta_x - w.global_position.x) > 0.0:
			var dt := get_process_delta_time()
			if float(dir) * (meta_x - w.global_position.x) > 0.0:   # aun no llega
				w.global_position.x += float(dir) * 1700.0 * dt
			viaje += dt
			if viaje > 0.6:   # tope de seguridad
				break
			await get_tree().process_frame
	# IMPACTO: el vórtice ALCANZA al rival -> EXPLOSIÓN dibujada + primer golpe
	if w != null:
		w.global_position.x = victima.global_position.x   # el vórtice llega al rival
	victima.set_facing(-dir)                              # encara al atacante
	victima.airborne = false
	victima.crouching = false
	victima.position.y = victima.floor_y
	victima._burst(1.3)
	victima.spawn_fire_impact()                           # estallido de fuego sobre el rival
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(1.6, 0.6, 0.15, 0.85)
	_shake(28.0, 0.45)                                    # sacudón del estallido
	Engine.time_scale = 0.30
	await get_tree().create_timer(0.14, true, false, true).timeout   # cámara lenta del impacto
	Engine.time_scale = 1.0
	# EMPUJE + MULTI-HIT: mientras la bola ENVUELVE y arrastra al rival por el
	# suelo, lo golpea una y otra vez (un hit cada PASO seg), subiendo el contador
	# como una ráfaga. El daño total del INFIERNO (CRIT_DMG) se reparte entre golpes.
	var n0: int = combo_n[idx]
	var HITS := 8
	var PASO := 0.07
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
		victima.position.y = victima.floor_y             # pegado al piso
		if w != null:
			w.global_position.x += avance                # el vórtice corre junto al rival
			w.modulate.a = clampf(1.0 - empuje / fin, 0.12, 1.0)   # se disipa al correrse
		polvo_cd -= dt
		if polvo_cd <= 0.0:
			victima._spawn_dash_smoke(0.55, 40.0)        # polvo brotando del rival empujado
			polvo_cd = 0.10
		# GOLPE periódico mientras la bola dure e impacte al rival
		hit_cd -= dt
		if hit_cd <= 0.0 and hit_i < HITS:
			hit_cd = PASO
			hit_i += 1
			var d := (CRIT_DMG - dealt) if hit_i == HITS else int(CRIT_DMG / HITS)
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
	if w != null:
		w.queue_free()                                   # el vórtice desaparece al correrse
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
	# METER: 3 segmentos inclinados con degradado NEÓN verde (oscuro -> claro, tubo)
	var meter_grad = load("res://imagen-action/hud/meter-grad-green.png")
	var mtw := 256.0
	var mth := 48.0
	for side in 2:
		meter_bg[side].clear(); meter_fl[side].clear()
		var msl := M_SL if side == 0 else -M_SL   # espejo a la derecha
		for s in 3:
			var bx := _meter_x(side, s)
			var poly := _para(bx, bx + M_W, M_Y, M_Y + M_H, msl)
			var bgp := Polygon2D.new()   # segmento con textura de degradado verde
			bgp.polygon = poly
			bgp.texture = meter_grad
			# UV: oscuro del lado del avatar -> claro hacia el centro (espejado a la derecha)
			if side == 0:
				bgp.uv = PackedVector2Array([Vector2(0, 0), Vector2(mtw, 0), Vector2(mtw, mth), Vector2(0, mth)])
			else:
				bgp.uv = PackedVector2Array([Vector2(mtw, 0), Vector2(0, 0), Vector2(0, mth), Vector2(mtw, mth)])
			bgp.color = Color(0.14, 0.14, 0.14, 1.0)   # modulación (se ajusta por carga)
			$UI.add_child(bgp)
			meter_bg[side].append(bgp)
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
			av.scale = Vector2(0.204, 0.204)   # 560*0.204 ~ 114
			av.position = Vector2(fx + 60, 68)
			av.flip_h = side == 1
			av.z_index = 6
			$UI.add_child(av)

# actualiza el relleno inclinado de una barra de vida (se vacía hacia el centro)
func _update_hp_bar(side: int, hp: int) -> void:
	var fill: Polygon2D = hp_bar_fill[side]
	var frac := clampf(float(hp) / float(MAX_HP), 0.0, 1.0)
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
	if hp > 0 and hp <= int(MAX_HP * ULTRA_HP):
		var p := 0.6 + 0.4 * absf(sin(glow_time * 7.0))
		fill.texture = null
		fill.color = Color(2.3 * p, 0.26 * p, 0.16 * p)
	else:
		fill.texture = null
		fill.color = Color(0.16, 0.46, 0.95)

# frase de victoria de DAM ("my work is done...")
var _victory_stream = null
func _play_victory_line() -> void:
	if _victory_stream == null:
		var ruta := "res://imagen-action/sound-effect/my-work-is-done-dam.mp3"
		_victory_stream = load(ruta) if ResourceLoader.exists(ruta) else null
	if _victory_stream != null and voz_player != null:
		# pequeño delay para que la voz caiga cuando la boca empieza a moverse (frame ~4)
		await get_tree().create_timer(0.35).timeout
		voz_player.stream = _victory_stream
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
		focus_atk.sprite.material = null
	focus_atk = null
	focus_cur = 0.0
	focus_target = 0.0
	modulate = Color(1, 1, 1)

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
		atacante.sprite.material = null   # solo lo quita si es el del dash (no pisa el del ultra)

# suaviza focus_cur hacia focus_target con reloj REAL (llamado desde _process)
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
				and dummy_hp > 0 and dummy_hp <= int(MAX_HP * ULTRA_HP)
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
				menu_panel.visible = false
				moves_panel.visible = true
				state = "moves"
			else:
				# 0=AI FIGHT (IA rankeada), 1=PRACTICE DUMMY (sin IA),
				# 2=BREAK PRACTICE (IA encadena combos, tú rompes; sin KO)
				break_practice = menu_sel == 2
				dummy_ai_mode = menu_sel == 0 or menu_sel == 2
				menu_panel.visible = false
				_start_round()
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

	# BARRAS DE VIDA inclinadas (se vacían hacia el CENTRO) con degradado
	_update_hp_bar(0, player_hp)
	_update_hp_bar(1, dummy_hp)
	# METER: borde negro fino (estático); el degradado verde se ILUMINA según la carga
	# (modulación del brillo de la textura). El segmento lleno late y hace bloom (HDR>1).
	var pulso := 0.7 + 0.3 * sin(glow_time * 8.0)
	for side in 2:
		var mv: float = meter[side]
		for s in 3:
			var f := clampf(mv - float(s), 0.0, 1.0)
			var b := 0.14 + 1.15 * f                 # oscuro vacío -> brillante lleno
			var lleno := f >= 0.999
			if lleno:
				b *= (1.0 + 0.5 * pulso)             # el lleno late (bloom)
			meter_bg[side][s].color = Color(b, b, b, 1.0)
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
	if result == "hit" or result == "launched":
		var hidx := 0 if att_is_player else 1
		var dmg_real: int = _combo_hit(hidx, int(atk["damage"]),
				String(atk["name"]), att.airborne or def.airborne)
		# temblorcito por cada golpe conectado (crece un poco con el combo)
		_shake(clampf(4.0 + float(combo_n[hidx]) * 0.7, 4.0, 13.0), 0.08)
		# el METER carga: el que pega gana más, el que recibe un poco
		meter[hidx] = minf(METER_MAX, meter[hidx] + float(dmg_real) * 0.014)
		meter[1 - hidx] = minf(METER_MAX, meter[1 - hidx] + float(dmg_real) * 0.006)
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
					dummy_hp = MAX_HP  # munieco de practica / drill: se reinicia, no muere
		else:
			player_hp = maxi(0, player_hp - dmg_real)
			if player_hp <= 0:
				if dummy_ai_mode and not break_practice:
					_end_round(false)
				else:
					player_hp = MAX_HP
	return done

func _end_round(player_won: bool) -> void:
	if state != "fight":
		return
	state = "round_end"
	player.input_enabled = false
	dummy.ai_enabled = false
	announce.visible = true
	announce.text = "K.O."
	if player_won:
		wins_p1 += 1
		dummy.do_ko()
	else:
		wins_p2 += 1
		player.do_ko()
	rounds_label.text = "%d  -  %d" % [wins_p1, wins_p2]
	await get_tree().create_timer(1.6).timeout
	if player_won:
		player.celebrate()
	else:
		dummy.celebrate()
	announce.text = "DAM WINS"
	await get_tree().create_timer(3.0).timeout
	if wins_p1 >= WINS_NEEDED or wins_p2 >= WINS_NEEDED:
		announce.text = "MATCH WINNER:\nDAM"
		await get_tree().create_timer(3.0).timeout
		wins_p1 = 0
		wins_p2 = 0
		round_num = 1
	else:
		round_num += 1
	_start_round()
