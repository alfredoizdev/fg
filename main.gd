extends Node2D

# Arbitro del combate: rondas, vida, hitboxes y anuncios.

const LEFT_LIMIT := 115.0
const RIGHT_LIMIT := 1805.0
const MAX_HP := 100   # (legado; la vida real es por personaje según arquetipo)
# vida por ARQUETIPO (puede variar por personaje)
# TRIÁNGULO de arquetipos: warrior=TANK (aguanta y pega fuerte, pero lento + super armor),
# assassin=RUSHDOWN (glass cannon: rápida y combea, poca vida), wizard=ZONER (medio).
const ARCH_HP := {"assassin": 1050, "wizard": 1150, "warrior": 1500}
var hp_max := [1200, 1200]   # vida máxima por lado [P1, P2], se setea de cada peleador
const HIT_MARGIN := 59.0     # tolerancia extra de alcance
const AIR_REACH_H := 302.0   # altura maxima a la que un golpe aereo alcanza a un rival en el piso
const WINS_NEEDED := 2       # rondas para ganar el combate
const BODY_SEP := 225.0      # distancia minima entre cuerpos en el piso (antes 143 = se metían uno dentro del otro)
const TRAINING := false      # modo entrenamiento: sin rival, sin escenario, sin UI
var STAGE: int = Sel.stage   # escenario elegido en el char-select (1=ciudad, 2=noche, 3=templo, 4=santuario)
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

# ============ MANA OSCURO (dark energy) — recurso de HECHIZOS, solo magos (wizard) ============
# Se rellena SOLO con el tiempo (la barra VERDE se gana peleando). Anillo morado en la esquina de
# abajo del lado del mago, con su retrato adentro. Los golpes normales NO gastan mana.
var mana := [1.0, 1.0]               # carga de mana por lado (0..1)
var mana_is_mage := [false, false]   # ¿ese lado es mago? (se setea en _refresh_hud_chars)
var mana_flash_t := [0.0, 0.0]       # parpadeo ROJO del anillo cuando falto mana (feedback)
var mana_full_flash_t := [0.0, 0.0]  # destello cuando el mana llega a FULL (avisa al player)
var mana_was_full := [false, false]  # estado full del frame anterior (detecta el cruce a lleno)
var mana_hud := [null, null]         # contenedor Node2D del anillo por lado (toggle visibilidad)
var mana_ring_fill := [null, null]   # arco morado que se vacia (Line2D)
var mana_avatar := [null, null]      # retrato del mago dentro del anillo (Sprite2D)
var mana_ring_bg := [null, null]     # anillo de fondo (Line2D) — se recompone con compensacion de aspecto
var mana_ring_frame := [null, null]  # marco negro (Line2D)
var mana_disc := [null, null]        # disco de fondo (Polygon2D)
const MANA_REGEN := 0.030            # recarga pasiva por segundo (~33s de vacio a lleno; MUY lento a proposito)
const MANA_REGEN_IDLE := 0.018       # bonus si esta quieta en el suelo (recupera un poco mas rapido)
const MANA_CHANNEL_REGEN := 0.25     # canaleo activo (doble-tap abajo): ~4s a full (rapido, vulnerable)
const MANA_R := 58.0                 # radio del anillo
const MANA_RING_W := 11.0            # grosor del anillo
const MANA_CY := 968.0               # centro Y (esquina de abajo)
const MANA_CX_L := 92.0              # centro X lado izquierdo (P1)
const MANA_CX_R := 1828.0            # centro X lado derecho (P2)
const MANA_AV_BOX := 104.0           # caja del retrato (circulo que llena el anillo)
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
	"spin_kick": 4, "air_spin_kick": 4, "sweep": 4, "crystal_cast": 4,   # E de Aye = nivel 4 (no resetea el combo)
	# 3 proyectiles aéreos de jump_kick_cast: nombres DISTINTOS (mismo nivel 4) para contar como 3 hits
	"crystal_air_a": 4, "crystal_air_b": 4, "crystal_air_c": 4,
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
var moves_avatar: TextureRect   # retrato del personaje en la pantalla MOVES del trainer
var moves_avframe: ColorRect    # marco de acento del retrato
var menu_opts := []
var menu_sel := 0
# --- PANTALLA PRINCIPAL (title) y submenú TRAINER ---
var title_panel: Control          # pantalla principal: banner + VS CPU / TRAINER / VS ONLINE
var title_opts := []              # labels de las 3 opciones
var title_sel := 0
var trainer_panel: ColorRect      # submenú de TRAINER (práctica / break / moves)
var trainer_opts := []
var trainer_sel := 0
# char-select de DOS pasos: el jugador elige SU personaje (P1) y luego el del rival/CPU (P2)
var cpu_char := "dam"             # personaje del rival (P2 / CPU)
var picking := 0                  # en char_select: 0 = eligiendo P1, 1 = eligiendo P2
var char_sel_p1 := 0
var char_sel_p2 := 1
var vs_from_trainer := false      # el char-select vino de TRAINER (no de VS CPU)
var char_side_l: TextureRect      # retrato grande del lado IZQUIERDO (P1)
var char_side_r: TextureRect      # retrato grande del lado DERECHO (P2)
var char_vs_label: Label          # "VS" en el centro
var char_pick_label: Label        # "PLAYER 1 — CHOOSE YOUR FIGHTER" / "SELECT CPU"
# --- SELECCIÓN DE PERSONAJE ---
# cada personaje: id, nombre, arquetipo (vida), avatar, frames de pelea, escala de sprite.
# Un personaje está "listo" (jugable) sólo si su recurso de frames existe.
const CHARS := [
	{"id": "dam",  "name": "DAM",  "arch": "assassin", "avatar": "res://imagen-action/dam/avatar/dam-avatar.png",  "frames": "res://fighter_frames.tres", "scale": 1.0},
	{"id": "favi", "name": "FE",   "arch": "assassin", "avatar": "res://imagen-action/favi/avatar/favi-avatar.png", "frames": "res://favi_frames.tres",   "scale": 0.82},
	{"id": "aye",  "name": "AYE",  "arch": "wizard", "avatar": "res://imagen-action/aye/sheets/aye-face.png",   "frames": "res://fighter_frames.tres", "scale": 0.78},
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
const CUTIN_HOLD := 0.95   # aguanta durante el FRAME CONGELADO (más rato en pantalla)
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
# ===== MENÚ DE PAUSA (dentro de la pelea): CONTINUAR / COMBOS / SALIR =====
var pause_root: Control            # capa raíz del menú de pausa (sobre todo, z alto)
var pause_lines: TextureRect       # líneas de acción manga tintadas al color del personaje
var pause_title_lbl: Label         # "PAUSA"
var pause_sub_lbl: Label           # nombre del personaje elegido
var pause_hint_lbl: Label          # ayuda de controles
var pause_items: Array = []        # labels de las opciones
var pause_plates: Array = []       # polígonos de fondo de cada opción (para resaltar)
var pause_accent := Color(1.7, 0.35, 0.22)   # color del personaje (rojo DAM / azul Fe)
var pause_sel := 0
var pause_in_combos := false       # true = viendo la sublista de COMBOS
var pause_prev_state := "fight"    # estado al que se vuelve al reanudar
var pause_combos: Control          # subpanel con la lista de movimientos
var pause_combos_title: Label
var pause_combos_moves: Label
var pause_combos_fin: Label
var pause_combos_border: Array = []
var pause_combos_avatar: TextureRect   # retrato del personaje que juegas (top-left del panel)
var pause_combos_avframe: ColorRect    # marco de acento del retrato
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
		elif STAGE == 4:
			esc = preload("res://santuario_stage.gd").new()
		else:
			esc = preload("res://templo_stage.gd").new()
		esc.name = "CodeStage"
		add_child(esc)
		code_stage = esc
	_build_cutin()      # cut-in del INFIERNO: detrás de la acción, delante del escenario
	_build_announce()   # anuncios + KO + retrato del ganador: DETRÁS de los peleadores
	# ===== PANTALLA PRINCIPAL (title): banner + VS CPU / TRAINER / VS ONLINE =====
	var tp := Control.new()
	tp.position = Vector2.ZERO
	tp.size = Vector2(1920, 1080)
	tp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tp.visible = false
	$UI.add_child(tp)
	title_panel = tp
	menu_panel = null
	# velo oscuro para que resalte el menú sobre el escenario
	var veil := ColorRect.new()
	veil.color = Color(0.02, 0.02, 0.05, 0.72)
	veil.position = Vector2.ZERO; veil.size = Vector2(1920, 1080)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tp.add_child(veil)
	# BANNER (placeholder): si existe un PNG de banner lo usa; si no, título estilizado
	if ResourceLoader.exists("res://imagen-action/ui/banner.png"):
		var bn := TextureRect.new()
		bn.texture = load("res://imagen-action/ui/banner.png")
		bn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bn.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bn.position = Vector2(360, 90); bn.size = Vector2(1200, 300)
		bn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tp.add_child(bn)
	else:
		var bshadow := Label.new()
		bshadow.text = "FG FIGHTER"
		bshadow.add_theme_font_size_override("font_size", 190)
		bshadow.add_theme_color_override("font_color", Color(0.06, 0.0, 0.0, 0.9))
		bshadow.position = Vector2(14, 132); bshadow.size = Vector2(1920, 260)
		bshadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bshadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tp.add_child(bshadow)
		var banner := Label.new()
		banner.text = "FG FIGHTER"
		banner.add_theme_font_size_override("font_size", 190)
		banner.add_theme_color_override("font_color", Color(0.86, 0.16, 0.13))
		banner.position = Vector2(0, 120); banner.size = Vector2(1920, 260)
		banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tp.add_child(banner)
	# opciones (abajo del banner)
	for j in 3:
		var o := Label.new()
		o.add_theme_font_size_override("font_size", 62)
		o.position = Vector2(0, 470 + j * 118)
		o.size = Vector2(1920, 90)
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		o.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tp.add_child(o)
		title_opts.append(o)
	var thint := Label.new()
	thint.text = "↑ ↓  select        Q / Enter  confirm"
	thint.add_theme_font_size_override("font_size", 26)
	thint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.78))
	thint.position = Vector2(0, 960); thint.size = Vector2(1920, 40)
	thint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tp.add_child(thint)
	# ===== SUBMENÚ TRAINER: práctica / break practice / moves & combos =====
	var trp := ColorRect.new()
	trp.color = Color(0.03, 0.03, 0.07, 0.9)
	trp.position = Vector2(610, 300)
	trp.size = Vector2(700, 560)
	trp.visible = false
	$UI.add_child(trp)
	trainer_panel = trp
	var trt := Label.new()
	trt.text = "TRAINER"
	trt.add_theme_font_size_override("font_size", 52)
	trt.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	trt.position = Vector2(0, 34); trt.size = Vector2(700, 64)
	trt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trp.add_child(trt)
	for j in 3:
		var o := Label.new()
		o.add_theme_font_size_override("font_size", 40)
		o.position = Vector2(0, 160 + j * 92); o.size = Vector2(700, 60)
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		trp.add_child(o)
		trainer_opts.append(o)
	var trh := Label.new()
	trh.text = "↑ ↓  select      Q  confirm      ESC  back"
	trh.add_theme_font_size_override("font_size", 20)
	trh.add_theme_color_override("font_color", Color(0.65, 0.65, 0.7))
	trh.position = Vector2(0, 496); trh.size = Vector2(700, 40)
	trh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trp.add_child(trh)
	# --- PANEL DE SELECCIÓN DE PERSONAJE ---
	var cp := ColorRect.new()
	cp.color = Color(0.03, 0.03, 0.07, 0.92)
	cp.position = Vector2(360, 150)
	cp.size = Vector2(1200, 760)
	cp.visible = false
	$UI.add_child(cp)
	char_panel = cp
	var ct := Label.new()
	ct.text = "PLAYER 1 — CHOOSE YOUR FIGHTER"
	ct.add_theme_font_size_override("font_size", 44)
	ct.position = Vector2(0, 40); ct.size = Vector2(1200, 60)
	ct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cp.add_child(ct)
	char_pick_label = ct
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
	# retratos GRANDES a los lados (estilo VS): P1 a la izquierda, P2 (CPU) a la derecha.
	# Van en $UI (fuera del panel central) y se muestran solo en char_select.
	char_side_l = TextureRect.new()
	char_side_l.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	char_side_l.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	char_side_l.position = Vector2(-30, 250); char_side_l.size = Vector2(430, 760)
	char_side_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	char_side_l.visible = false
	$UI.add_child(char_side_l)
	char_side_r = TextureRect.new()
	char_side_r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	char_side_r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	char_side_r.flip_h = true                    # el lado derecho mira hacia adentro
	char_side_r.position = Vector2(1520, 250); char_side_r.size = Vector2(430, 760)
	char_side_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	char_side_r.visible = false
	$UI.add_child(char_side_r)
	# "VS" grande entre los dos retratos (aparece cuando ya elegiste P1)
	char_vs_label = Label.new()
	char_vs_label.text = "VS"
	char_vs_label.add_theme_font_size_override("font_size", 120)
	char_vs_label.add_theme_color_override("font_color", Color(0.92, 0.2, 0.15))
	char_vs_label.position = Vector2(0, 930); char_vs_label.size = Vector2(1920, 140)
	char_vs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_vs_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	char_vs_label.visible = false
	$UI.add_child(char_vs_label)
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
	# AVATAR del personaje (top-left) con marco de acento
	var mvfr := ColorRect.new()
	mvfr.position = Vector2(36, 16); mvfr.size = Vector2(108, 108)
	mvfr.color = Color(1.7, 0.4, 0.24, 1.0)
	vp.add_child(mvfr)
	moves_avframe = mvfr
	var mav := TextureRect.new()
	mav.position = Vector2(41, 21); mav.size = Vector2(98, 98)
	mav.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mav.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	mav.clip_contents = true
	mav.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vp.add_child(mav)
	moves_avatar = mav
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
	_build_pause()          # menú de pausa de la pelea (ESC): CONTINUAR / COMBOS / SALIR
	if TRAINING:
		_enter_training()
	elif Sel.configured:
		# vino del char-select (escena separada): aplica modo + personajes y a PELEAR directo
		selected_char = Sel.p1
		cpu_char = Sel.p2
		match Sel.mode:
			"practice":
				dummy_ai_mode = false; break_practice = false
			"break":
				dummy_ai_mode = true; break_practice = true
			_:
				dummy_ai_mode = true; break_practice = false   # vs_cpu
		_start_round()
	else:
		# main.tscn ejecutado directo (sin pasar por el menú): fallback interno
		_open_menu()

func _open_menu() -> void:
	# PANTALLA PRINCIPAL (title): banner + VS CPU / TRAINER / VS ONLINE
	state = "title"
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
	if trainer_panel:
		trainer_panel.visible = false
	if char_panel:
		char_panel.visible = false
	_hide_char_vs()
	title_panel.visible = true

func _open_trainer() -> void:
	state = "trainer"
	title_panel.visible = false
	trainer_panel.visible = true

func _hide_char_vs() -> void:
	if char_side_l: char_side_l.visible = false
	if char_side_r: char_side_r.visible = false
	if char_vs_label: char_vs_label.visible = false

# arranca el char-select de DOS pasos. from_trainer: vino de TRAINER (no de VS CPU).
# mode: 0 = VS CPU (IA), 1 = práctica libre, 2 = break practice.
func _begin_char_select(from_trainer: bool, mode: int) -> void:
	vs_from_trainer = from_trainer
	pending_mode = mode
	picking = 0
	char_sel_p1 = 0
	char_sel_p2 = 1
	title_panel.visible = false
	trainer_panel.visible = false
	char_panel.visible = true
	state = "char_select"
	_refresh_char_select()

func _refresh_char_select() -> void:
	# título dinámico: primero elige el JUGADOR, luego el rival (CPU)
	char_pick_label.text = "PLAYER 1 — CHOOSE YOUR FIGHTER" if picking == 0 else "SELECT CPU FIGHTER"
	var cur := char_sel_p1 if picking == 0 else char_sel_p2
	var cur_col := Color(1.0, 0.3, 0.25) if picking == 0 else Color(0.35, 0.55, 1.0)  # P1 rojo, P2 azul
	for i in char_cards.size():
		var col := Color(0, 0, 0)
		if picking == 1 and i == char_sel_p1:
			col = Color(0.85, 0.22, 0.18)   # marca fija del que eligió P1
		if i == cur:
			col = cur_col
		char_cards[i]["border"].color = col
	# retratos laterales estilo VS: P1 fijo a la izquierda (una vez elegido) + preview P2 a la derecha
	if picking == 0:
		char_side_l.visible = false
		char_side_r.visible = false
		char_vs_label.visible = false
	else:
		var p1av := String(CHARS[char_sel_p1]["avatar"])
		if ResourceLoader.exists(p1av):
			char_side_l.texture = load(p1av)
		char_side_l.visible = true
		char_vs_label.visible = true
		var p2av := String(CHARS[char_sel_p2]["avatar"])
		if ResourceLoader.exists(p2av):
			char_side_r.texture = load(p2av)
		char_side_r.visible = true

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

# ---- PARRY / COUNTER (↓+E, estándar): desvía el combo y contraataca. Gasta 1 barra. ----
func meter_can_parry(quien: Node2D) -> bool:
	if break_practice:
		return true
	var i := 0 if quien == player else 1
	return meter[i] >= 1.0

# cuántos golpes lleva el combo que le hacen a 'victima' (para el límite ≤4 del combo break)
func combo_hits_on(victima: Node2D) -> int:
	var atk_idx := 1 if victima == player else 0
	return combo_n[atk_idx]

# ACTIVACIÓN del PARRY (Q+W): gasta 1 barra AL ACTIVAR (riesgo: si no te pegan en la
# ventana, la perdiste). El borde/aura lo pone el fighter (breaker_fx_t). El counter en sí
# lo dispara on_parry cuando te pegan dentro de la ventana (ver _process_attacker).
func on_parry_start(quien: Node2D) -> void:
	var i := 0 if quien == player else 1
	if not break_practice:
		meter[i] = maxf(0.0, meter[i] - 1.0)
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = (Color(0.55, 0.85, 1.0, 0.30) if quien.fx_blue else Color(1.0, 0.6, 0.4, 0.30))

func on_parry(quien: Node2D, atacante: Node2D) -> void:
	quien.parry_t = 0.0                                   # consume la ventana
	quien.sprite.modulate = Color(1, 1, 1, 1)            # limpia el glow de la postura
	var p_idx := 0 if quien == player else 1
	var a_idx := 1 if quien == player else 0
	var dir := 1 if atacante.position.x >= quien.position.x else -1
	quien.set_facing(dir)
	# corta el combo del atacante
	combo_n[a_idx] = 0
	combo_t[a_idx] = 99.0
	if a_idx < combo_ui.size():
		combo_ui[a_idx].visible = false
	# bloquea el control durante el counter
	player.input_enabled = false
	dummy.ai_enabled = false
	# --- CINE del COUNTER (como el ULTRA): todo va DETRÁS de los peleadores (z=-1) para que
	# los personajes Y el texto SOBRESALGAN por encima del OSCURO. Nada de velo amarillo encima. ---
	break_side = 1 if quien.position.x >= 960.0 else -1
	_show_announce("COUNTER", Color(1.0, 0.9, 0.25), 1.6, break_side)
	_play_voz("counter")                                 # voz épica (efecto tipo apocalypse) al ejecutar el counter
	var line_col: Color = Color(0.55, 0.85, 1.7) if quien.fx_blue else Color(1.7, 0.42, 0.28)  # líneas AZUL (Fe) / ROJO (DAM)
	quien.breaker_fx_t = 1.8
	_shake(18.0, 0.3)
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(1.0, 1.0, 1.0, 0.55)         # SOLO un destello blanco BREVE del desvío (se desvanece)
	# velo OSCURO (ko_red, z=-1 DETRÁS) + LÍNEAS del ultra (ko_lines, z=-1 DETRÁS)
	ko_red.color = Color(0.03, 0.03, 0.07, 0.62)
	ko_lines.visible = true
	# freeze corto del desvío (congelado dramático)
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.18, true, false, true).timeout
	Engine.time_scale = 1.0
	# el parrier reproduce su COUNTER; 3 golpes automáticos al atacante
	if quien.sprite.sprite_frames.has_animation("counter"):
		quien.sprite.play("counter")
	var crit := int(hp_max[1 - p_idx] * 0.30)            # el counter pega ~30% de la vida
	var dealt := 0
	var t0 := Time.get_ticks_msec()
	for h in 3:
		# LÍNEAS del ultra ciclando + OSCURO (todo DETRÁS de los players)
		var kt := float(Time.get_ticks_msec() - t0) / 1000.0
		if ultra_panels.size() > 0:
			ko_lines.texture = ultra_panels[int(kt * 16.0) % ultra_panels.size()]
		ko_lines.modulate = Color(line_col.r, line_col.g, line_col.b, 1.0)
		ko_red.color.a = 0.62
		await get_tree().create_timer(0.10).timeout
		if atacante.koed:
			break
		var last: bool = h == 2
		atacante.set_facing(-dir)
		atacante.receive_hit(false, false, dir, "kick_impact")  # NO lanza: recoil corto, queda CERCA
		var d: int = (crit - dealt) if last else int(crit / 3)
		dealt += d
		if a_idx == 0:
			dummy_hp = maxi(0, dummy_hp - d)
		else:
			player_hp = maxi(0, player_hp - d)
		atacante._burst(0.95, false, 1, quien.fx_blue)
		_shake(12.0, 0.1)
	# NO lo ALEJA: queda cerca en take_hit para que el que hizo el counter SIGA COMBEANDO.
	# El counter cuenta como 3 golpes de SU combo y deja la ventana abierta para encadenar.
	combo_n[p_idx] = 3
	combo_t[p_idx] = 0.0
	combo_lvl[p_idx] = 0
	# se desvanece el OSCURO + las LÍNEAS
	var fs := Time.get_ticks_msec()
	while Time.get_ticks_msec() - fs < 400:
		var k := 1.0 - float(Time.get_ticks_msec() - fs) / 400.0
		ko_red.color.a = 0.62 * k
		ko_lines.modulate.a = k
		await get_tree().process_frame
	ko_red.color = Color(1.3, 0.06, 0.05, 0.0)
	ko_lines.visible = false
	if state == "fight":
		quien.sprite.play("pose")
		player.input_enabled = true
		dummy.ai_enabled = dummy_ai_mode

func _hide_announce_soon() -> void:
	await get_tree().create_timer(0.6).timeout
	if state == "fight" or state == "demo":
		announce.visible = false

# pone el título / MOVES / FINISHERS de la lista según el personaje ELEGIDO
# texto de MOVE LIST por personaje (compartido por la pantalla MOVES y el menú de pausa)
func _char_move_text(cid: String) -> Dictionary:
	if cid == "aye":
		return {
			"title": "AYE — MOVE LIST",
			"moves": "MOVES:\n\nR  —  Staff poke (50)\n↓ + R  —  Low crouch poke (50)\nQ  —  Staff thrust (90)\n→ + Q  —  Double thrust (90+90)\n↓ + Q  —  Crouch jab (90)\nW  —  ICE PILLAR cast (100)\n↓ + W  —  ICE MOON · rising launcher (100) ▲\nE  —  CRYSTAL SHOT · projectile (80)\n↓ + E  —  ICE SPIKES · sweep, FREEZES (100) ✦\nJump + Q  —  Air staff (90)\nJump + W  —  Air overhead (100)\nJump + E  —  SPIN CAST · 3 air crystals\nJump + R  —  AIR BOLTS · diagonal needles\n\n▲ = launches into the air     ✦ = freezes the rival ~1s",
			"fin": "★  SPECIALS   (purple MANA ring: spells drain it)\n↓ ↓  —  CHANNEL MANA · fast refill (vulnerable)\n← ←  /  → →  —  BLINK back / forward (teleport step)\n↓ → Q  —  TELEPORT STRIKE · front, invincible (air OK)\n↓ → W  —  BACKSTAB · teleport BEHIND + push\n→ ↓ ← R  —  PRISM ORB · freezing orb\n↑↑ R  —  COMBO BREAK (1/round, while hit)\n↓ ← Q  —  CRYSTAL FLURRY super (3-hit combo + 1.5 bars)\n\nBEST COMBO:  R → Q → W → ↓E   (go UP only)\nPARRY (Q + W together):  counter, 1 bar",
		}
	if cid == "favi":
		return {
			"title": "FE — MOVE LIST",
			"moves": "MOVES:\n\nR  —  Quick needle jab (4)\n↓ + R  —  Low needle jab (4)\nQ  —  Scissor slash (10)\n→ + Q  —  Double scissor\nW  —  Heavy scissor (10)\n↓ + Q  —  Crouch scissor (3)\n↓ + W  —  Rising needles (5) ▲\nE  —  Needle spin · 2 hits\n↓ + E  —  Ground sweep (6) ▼\nJump + Q  —  Air scissor (4)\nJump + W  —  Dive needle (4)\nJump + E  —  Air somersault (8) ▲\n\n▲ = launches into the air     ▼ = knocks down",
			"fin": "★  SPECIALS  &  FINISHERS  (meter: ↑E=2 · ↓←E=1)\n↑ + E  —  Combo Breaker (while hit) · or ANNIHILATION ultra\n        (2 bars + 3-hit combo + rival ≤25% HP)\n↓ → + R  —  APOCALYPSE · long ultra (3 bars + combo + rival ≤25% HP)\n↓ ↘ → + Q/W/E  —  WATER GEYSER · 1/2/3 bodies\n← → + Q  —  NEEDLE DASH · rush, 3-hit combo\n↓ ← + E  —  WHIRLPOOL · 1 bar + combo (deadly spin ~40% HP)\nJump →  —  forward flip   ·   Jump + R  —  air double kick\n\nPARRY (Q + W together):  counter · 1 bar · breaks their combo",
		}
	return {
		"title": "DAM — MOVE LIST",
		"moves": "MOVES:\n\nR  —  Quick jab (4)\n↓ + R  —  Low jab (4)\nQ  —  Horizontal slash (8)\n→ + Q  —  Double slash (8+6)\n↓ ↘ →  + Q  —  EMBER DASH (15), wall slam\nW  —  Heavy slash (12)\n↓ + Q  —  Crouch slash (6)\n↓ + W  —  Rising launcher (9) ▲\nE  —  Traveling spin kick (13) ▲\n↓ + E  —  Ground sweep (12) ▼\nJump + Q  —  Air slash (9)\nJump + W  —  Dive kick (10)\nJump + E  —  Somersault kick (13) ▲\n\n▲ = launches into the air     ▼ = knocks down",
		"fin": "★  SPECIALS  &  FINISHERS\n↑ + E  —  Combo Breaker (while hit, 1/round)\n↓ ↓ + E  —  INFERNO · his power\n        (after a 7-hit combo · 50 dmg)\n→ R  —  ANNIHILATION · short ultra (16 hits)\n→ E  —  APOCALYPSE · long ultra (31 hits)\n        ultras: 3-hit combo + rival ≤ 25% HP\n\nPARRY (Q + W together):  counter · 1 bar · breaks their combo",
	}

func _set_moves_text() -> void:
	if moves_title == null:
		return
	var t := _char_move_text(selected_char)
	moves_title.text = String(t["title"])
	moves_col1.text = String(t["moves"])
	moves_fin.text = String(t["fin"])
	# AVATAR + color de acento del personaje (por-personaje, épico)
	var acc := _char_accent(selected_char)
	moves_title.add_theme_color_override("font_color", acc)
	if moves_avframe != null:
		moves_avframe.color = acc
	if moves_avatar != null:
		var avp := _char_avatar(selected_char)
		if ResourceLoader.exists(avp):
			moves_avatar.texture = load(avp)

# ============================================================================
#  MENÚ DE PAUSA (ESC en pelea): CONTINUAR / COMBOS / SALIR AL MENÚ
#  Estilo tipo SF6/Guilty Gear: velo oscuro + líneas de acción manga tintadas
#  al color del personaje, placas inclinadas que se encienden al seleccionar.
# ============================================================================
const PAUSE_LABELS := ["CONTINUE", "COMBOS", "QUIT TO MENU"]

func _pause_plate_poly(w: float, h: float, slant: float) -> PackedVector2Array:
	# paralelogramo inclinado (misma estética que los carteles de BREAK/COUNTER)
	return PackedVector2Array([Vector2(slant, 0.0), Vector2(w, 0.0),
			Vector2(w - slant, h), Vector2(0.0, h)])

func _build_pause() -> void:
	var root := Control.new()
	root.position = Vector2.ZERO
	root.size = Vector2(1920, 1080)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.z_index = 120                       # SOBRE todo (peleadores + HUD + combo)
	root.visible = false
	$UI.add_child(root)
	pause_root = root
	# velo oscuro casi opaco
	var veil := ColorRect.new()
	veil.color = Color(0.02, 0.02, 0.06, 0.9)
	veil.position = Vector2.ZERO; veil.size = Vector2(1920, 1080)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(veil)
	# líneas de acción manga (ciclan y se tintan al color del personaje en _open/_process)
	var lines := TextureRect.new()
	lines.size = Vector2(1920, 1080)
	lines.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lines.stretch_mode = TextureRect.STRETCH_SCALE
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.modulate = Color(1.7, 0.35, 0.22, 0.14)
	if ultra_panels.size() > 0:
		lines.texture = ultra_panels[0]
	root.add_child(lines)
	pause_lines = lines
	# barras diagonales de acento (arriba y abajo) para enmarcar
	for yb in [Vector2(0.0, 96.0), Vector2(0.0, 968.0)]:
		var bar := Polygon2D.new()
		bar.polygon = PackedVector2Array([Vector2(0, yb.y), Vector2(1920, yb.y - 34.0),
				Vector2(1920, yb.y + 12.0), Vector2(0, yb.y + 46.0)])
		bar.color = Color(1.7, 0.35, 0.22, 0.55)
		bar.name = "AccentBar"
		root.add_child(bar)
	# título "PAUSA"
	var ttl := Label.new()
	ttl.text = "PAUSED"
	ttl.add_theme_font_override("font", combo_font)
	ttl.add_theme_font_size_override("font_size", 150)
	ttl.add_theme_color_override("font_color", Color(0.97, 0.97, 1.0))
	ttl.add_theme_color_override("font_outline_color", Color(1.7, 0.35, 0.22))
	ttl.add_theme_constant_override("outline_size", 14)
	ttl.position = Vector2(230, 150)
	ttl.size = Vector2(900, 170)
	root.add_child(ttl)
	pause_title_lbl = ttl
	# subtítulo: nombre del personaje elegido
	var sub := Label.new()
	sub.add_theme_font_override("font", combo_font)
	sub.add_theme_font_size_override("font_size", 46)
	sub.add_theme_color_override("font_color", Color(1.7, 0.4, 0.24))
	sub.position = Vector2(244, 322)
	sub.size = Vector2(900, 56)
	root.add_child(sub)
	pause_sub_lbl = sub
	# placas del menú (inclinadas), una por opción
	pause_items.clear()
	pause_plates.clear()
	var pw := 640.0
	var ph := 92.0
	var slant := 34.0
	for i in PAUSE_LABELS.size():
		var pos := Vector2(240.0, 468.0 + float(i) * 118.0)
		# sombra
		var sh := Polygon2D.new()
		sh.polygon = _pause_plate_poly(pw, ph, slant)
		sh.color = Color(0, 0, 0, 0.4)
		sh.position = pos + Vector2(9, 10)
		root.add_child(sh)
		# placa
		var plate := Polygon2D.new()
		plate.polygon = _pause_plate_poly(pw, ph, slant)
		plate.color = Color(0.08, 0.09, 0.14, 0.92)
		plate.position = pos
		root.add_child(plate)
		pause_plates.append(plate)
		# texto
		var lab := Label.new()
		lab.add_theme_font_override("font", combo_font)
		lab.add_theme_font_size_override("font_size", 48)
		lab.add_theme_color_override("font_color", Color(0.6, 0.62, 0.7))
		lab.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
		lab.add_theme_constant_override("outline_size", 5)
		lab.position = pos + Vector2(slant + 40.0, 16.0)
		lab.size = Vector2(pw, ph)
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.text = PAUSE_LABELS[i]
		root.add_child(lab)
		pause_items.append(lab)
	# ayuda de controles (abajo)
	var hint := Label.new()
	hint.add_theme_font_size_override("font_size", 30)
	hint.add_theme_color_override("font_color", Color(1.0, 0.7, 0.5))
	hint.add_theme_constant_override("outline_size", 4)
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	hint.text = "↑ ↓  MOVE       Q / ENTER  SELECT       ESC  RESUME FIGHT"
	hint.position = Vector2(240, 900)
	hint.size = Vector2(1440, 40)
	root.add_child(hint)
	pause_hint_lbl = hint
	# ---- SUBPANEL DE COMBOS (lista de movimientos del personaje) ----
	var cp := Control.new()
	cp.position = Vector2.ZERO; cp.size = Vector2(1920, 1080)
	cp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cp.visible = false
	root.add_child(cp)
	pause_combos = cp
	# fondo OPACO a pantalla completa: tapa el menú de pausa por completo (sin transparentar)
	var backdrop := ColorRect.new()
	backdrop.position = Vector2.ZERO; backdrop.size = Vector2(1920, 1080)
	backdrop.color = Color(0.02, 0.01, 0.04, 1.0)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cp.add_child(backdrop)
	var panel := ColorRect.new()
	panel.color = Color(0.05, 0.04, 0.10, 1.0)
	panel.position = Vector2(250, 96)
	panel.size = Vector2(1420, 890)
	cp.add_child(panel)
	pause_combos_border.clear()
	# marco de acento (4 líneas)
	for r in [Rect2(0, 0, 1420, 6), Rect2(0, 884, 1420, 6), Rect2(0, 0, 6, 890), Rect2(1414, 0, 6, 890)]:
		var br := ColorRect.new()
		br.position = r.position; br.size = r.size
		br.color = Color(1.7, 0.4, 0.24, 0.6)
		panel.add_child(br)
		pause_combos_border.append(br)
	var ct := Label.new()
	ct.add_theme_font_override("font", combo_font)
	ct.add_theme_font_size_override("font_size", 54)
	ct.add_theme_color_override("font_color", Color(1.7, 0.4, 0.24))
	ct.position = Vector2(0, 30); ct.size = Vector2(1420, 66)
	ct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(ct)
	pause_combos_title = ct
	# AVATAR del personaje (top-left) con marco de acento + brillo detrás
	var avglow := ColorRect.new()
	avglow.position = Vector2(30, 12); avglow.size = Vector2(140, 140)
	avglow.color = Color(1.7, 0.4, 0.24, 0.22)
	panel.add_child(avglow)
	pause_combos_border.append(avglow)
	var avfr := ColorRect.new()
	avfr.position = Vector2(40, 18); avfr.size = Vector2(120, 120)
	avfr.color = Color(1.7, 0.4, 0.24, 1.0)
	panel.add_child(avfr)
	pause_combos_avframe = avfr
	var av := TextureRect.new()
	av.position = Vector2(45, 23); av.size = Vector2(110, 110)
	av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	av.clip_contents = true
	av.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(av)
	pause_combos_avatar = av
	# separador bajo el título
	var sep := ColorRect.new()
	sep.position = Vector2(90, 116); sep.size = Vector2(1240, 3)
	sep.color = Color(1.0, 0.6, 0.3, 0.5)
	panel.add_child(sep)
	pause_combos_border.append(sep)
	var cm := Label.new()
	cm.add_theme_font_size_override("font_size", 27)
	cm.add_theme_color_override("font_color", Color(0.92, 0.92, 0.96))
	cm.position = Vector2(90, 150); cm.size = Vector2(640, 700)
	panel.add_child(cm)
	pause_combos_moves = cm
	# separador vertical
	var vsep := ColorRect.new()
	vsep.position = Vector2(720, 140); vsep.size = Vector2(3, 700)
	vsep.color = Color(1.0, 0.6, 0.3, 0.4)
	panel.add_child(vsep)
	pause_combos_border.append(vsep)
	var cf := Label.new()
	cf.add_theme_font_size_override("font_size", 27)
	cf.add_theme_color_override("font_color", Color(1.0, 0.82, 0.4))
	cf.add_theme_color_override("font_outline_color", Color(0.22, 0.03, 0.0))
	cf.add_theme_constant_override("outline_size", 4)
	cf.position = Vector2(760, 150); cf.size = Vector2(600, 700)
	panel.add_child(cf)
	pause_combos_fin = cf
	var cb := Label.new()
	cb.add_theme_font_size_override("font_size", 28)
	cb.add_theme_color_override("font_color", Color(1.0, 0.75, 0.45))
	cb.text = "ESC / W  —  back"
	cb.position = Vector2(0, 838); cb.size = Vector2(1420, 40)
	cb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(cb)

func _open_pause() -> void:
	if state != "fight":
		return
	pause_prev_state = state
	state = "pause"
	pause_sel = 0
	pause_in_combos = false
	player.input_enabled = false
	dummy.ai_enabled = false
	# color del personaje ELEGIDO (morado Aye / azul Fe / rojo DAM)
	pause_accent = _char_accent(selected_char)
	var cname := "AYE" if selected_char == "aye" else ("FE" if selected_char == "favi" else "DAM")
	pause_sub_lbl.text = cname + "   —   ROUND PAUSED"
	pause_sub_lbl.add_theme_color_override("font_color", pause_accent)
	pause_title_lbl.add_theme_color_override("font_outline_color", pause_accent)
	pause_hint_lbl.add_theme_color_override("font_color", pause_accent.lerp(Color(1, 1, 1), 0.45))
	pause_lines.modulate = Color(pause_accent.r, pause_accent.g, pause_accent.b, 0.14)
	pause_combos_title.add_theme_color_override("font_color", pause_accent)
	for b in pause_combos_border:
		(b as ColorRect).color = Color(pause_accent.r, pause_accent.g, pause_accent.b, 0.6)
	for a in pause_root.get_children():
		if a is Polygon2D and (a as Polygon2D).name == "AccentBar":
			(a as Polygon2D).color = Color(pause_accent.r, pause_accent.g, pause_accent.b, 0.55)
	pause_combos.visible = false
	pause_root.visible = true
	_pause_refresh()
	Engine.time_scale = 0.0                  # CONGELA la pelea (el menú anima en tiempo real)

func _pause_refresh() -> void:
	for i in pause_items.size():
		var selq := i == pause_sel
		var lab := pause_items[i] as Label
		var plate := pause_plates[i] as Polygon2D
		lab.text = ("▶   " if selq else "     ") + String(PAUSE_LABELS[i])
		lab.add_theme_color_override("font_color", Color(1, 1, 1) if selq else Color(0.58, 0.6, 0.7))
		plate.color = pause_accent if selq else Color(0.08, 0.09, 0.14, 0.92)

# color de acento por personaje (morado Aye / azul Fe / rojo DAM)
func _char_accent(cid: String) -> Color:
	if cid == "aye":
		return Color(1.35, 0.45, 2.0)
	if cid == "favi":
		return Color(0.4, 0.72, 1.7)
	return Color(1.7, 0.4, 0.24)

func _char_avatar(cid: String) -> String:
	for c in CHARS:
		if String(c["id"]) == cid:
			return String(c["avatar"])
	return String(CHARS[0]["avatar"])

func _pause_show_combos(show: bool) -> void:
	pause_in_combos = show
	if show:
		var t := _char_move_text(selected_char)
		pause_combos_title.text = String(t["title"])
		pause_combos_moves.text = String(t["moves"])
		pause_combos_fin.text = String(t["fin"])
		# COLOR temático + AVATAR del personaje que estás jugando (épico + por-personaje)
		var acc := _char_accent(selected_char)
		pause_combos_title.add_theme_color_override("font_color", acc)
		for br in pause_combos_border:
			var cr := br as ColorRect
			cr.color = Color(acc.r, acc.g, acc.b, cr.color.a)
		if pause_combos_avframe != null:
			pause_combos_avframe.color = acc
		if pause_combos_avatar != null:
			var avp := _char_avatar(selected_char)
			if ResourceLoader.exists(avp):
				pause_combos_avatar.texture = load(avp)
	pause_combos.visible = show

func _pause_confirm() -> void:
	match pause_sel:
		0:
			_close_pause()                   # CONTINUAR
		1:
			_pause_show_combos(true)         # COMBOS
		2:
			# SALIR AL MENÚ PRINCIPAL (restaurar time_scale ANTES de cambiar de escena)
			Engine.time_scale = 1.0
			Sel.configured = false
			get_tree().change_scene_to_file("res://title.tscn")

func _close_pause() -> void:
	pause_in_combos = false
	pause_combos.visible = false
	pause_root.visible = false
	state = pause_prev_state
	Engine.time_scale = 1.0
	player.input_enabled = true
	dummy.ai_enabled = dummy_ai_mode

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
	if title_panel: title_panel.visible = false
	if trainer_panel: trainer_panel.visible = false
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
	if title_panel: title_panel.visible = false
	if trainer_panel: trainer_panel.visible = false
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
const AYE_SPD := 1.0     # multiplicador de la velocidad de ANIMACIÓN de Aye (anims sin override)
const AYE_MOVE_SPD := 0.69   # DESPLAZAMIENTO: 0.55 base no-skate * 1.25 (mismo factor que sus anims apuradas -> el walk sigue sin patinar)
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
		var real := _favi_action_frames(anim)
		# Animaciones EXCLUSIVAS del arte de DAM. Si Fe no tiene el suyo, se OMITEN (no
		# placeholder de pose parada, que se ve TIESA/mal):
		#   ko_air      -> Fe cae con "ko" (boca arriba)
		#   pummeled    -> Fe recibe el ultra con "take_hit" (golpe real, no estática)
		#   fly_straight-> Fe vuela hacia la pared con "hit_fly" (vuelo real, no de pie)
		#   wall_splat  -> hasta tener wall-bounce-sheet.png, Fe se estrella en "hit_fly"
		#                  (volando) en vez de la pose parada. Cuando exista el arte del
		#                  estampado boca abajo se procesa a favi/wall_splat/ y deja de omitirse.
		if real.is_empty() and anim in ["ko_air", "pummeled", "fly_straight", "wall_splat"]:
			continue
		if not sf.has_animation(anim):
			sf.add_animation(anim)
		sf.set_animation_loop(anim, dam.get_animation_loop(anim))
		sf.set_animation_speed(anim, dam.get_animation_speed(anim) * FAVI_SPD)
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
		sf.set_animation_loop("whirlpool", false)   # control MANUAL de frames en _run_whirlpool
		sf.set_animation_speed("whirlpool", 12.0)   # (no se usa: los frames se setean a mano)
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
	# COUNTER (parry-contraataque, ↓+E): desvío (f1) + 3 estocadas (f2-f5) + recuperación (f6)
	var cnt := _favi_action_frames("counter")
	if not cnt.is_empty():
		if not sf.has_animation("counter"):
			sf.add_animation("counter")
		sf.set_animation_loop("counter", false)
		sf.set_animation_speed("counter", 16.0)
		for t in cnt:
			sf.add_frame("counter", t)
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
		var base_speed: float = dam.get_animation_speed(anim) * AYE_SPD
		var real := _aye_action_frames(anim)
		if real.is_empty():
			sf.set_animation_speed(anim, base_speed)
			for i in dam.get_frame_count(anim):   # placeholder: frame de DAM
				sf.add_frame(anim, dam.get_frame_texture(anim, i))
		else:
			# la animación de Aye puede tener MÁS frames que DAM (ej. walk 16 vs 8). Escalamos la
			# velocidad al conteo REAL para conservar la MISMA cadencia (el ciclo dura igual, no
			# patina): fps = fps_dam * AYE_SPD * (frames_aye / frames_dam).
			var dcount: int = maxi(1, dam.get_frame_count(anim))
			sf.set_animation_speed(anim, base_speed * float(real.size()) / float(dcount))
			for t in real:
				sf.add_frame(anim, t)
	# WALK de Aye: cadencia PROPIA y calmada. El video es una zancada más lenta/larga que la
	# marcha rápida de DAM (13fps); heredar esa velocidad con 16 frames la hacía ir glitch-rápido.
	# ~15fps con 16 frames = ciclo ~1.07s (se lee como caminata). Tuneable.
	if sf.has_animation("walk") and not _aye_action_frames("walk").is_empty():
		sf.set_animation_speed("walk", 30.0)
	# POSE (idle) de Aye: cadencia CALMA de respiración (12 frames @ 5fps = ciclo ~2.4s). Tuneable.
	if sf.has_animation("pose") and not _aye_action_frames("pose").is_empty():
		sf.set_animation_speed("pose", 24.0)
	# WALK_BACK de Aye: animación PROPIA de retroceso (NO es el walk al revés). Solo se crea si
	# ya existen sus frames (imagen-action/aye/walk_back/aye-walk_back-N.png); si no, el motor cae
	# al fallback (walk invertido). Velocidad a calibrar cuando lleguen los frames (como el walk).
	var wb := _aye_action_frames("walk_back")
	if not wb.is_empty():
		if not sf.has_animation("walk_back"):
			sf.add_animation("walk_back")
		sf.set_animation_loop("walk_back", true)
		sf.set_animation_speed("walk_back", 30.0)   # 29 frames de salto @ 30fps = ~1s por brinco. Tuneable.
		for t in wb:
			sf.add_frame("walk_back", t)
	# CROUCH de Aye: transición de pie->agachada (no-loop, se sostiene el último frame). 17 frames
	# @ 50fps = ~0.34s bajando (y al revés para pararse). Tuneable.
	if sf.has_animation("crouch") and not _aye_action_frames("crouch").is_empty():
		sf.set_animation_speed("crouch", 50.0)
	# JUMP de Aye: 17 frames (despegue->ápice->caída) sincronizados al airtime (~0.88s). La ALTURA
	# la da la física (vel_y); la animación va vertical in-place (pies anclados). ~20fps. Tuneable.
	if sf.has_animation("jump") and not _aye_action_frames("jump").is_empty():
		sf.set_animation_speed("jump", 20.0)
	# WEAK_PUNCH (R): ESTOCADA COMPLETA. guardia→jab→windup→THRUST extendido (#170, sostenido)→
	# recupera a la GUARDIA braceada (#174)→idle. 24 frames @ 34fps = ~0.7s (setup DENSO: abre los
	# pies fluido). Reach largo (override en fighter.gd para que alcance a media distancia). Tuneable.
	if sf.has_animation("weak_punch") and not _aye_action_frames("weak_punch").is_empty():
		sf.set_animation_speed("weak_punch", 46.0)   # más SNAPPY (24 frames @46 = ~0.52s). Tuneable.
	# TAKE_HIT / TAKE_HIT_LOW de Aye: flinch morado. Velocidad PROPIA (no la cadencia rapidísima de DAM,
	# que casi no se veía): ~24fps para que el latigazo + recuperación se LEAN. Tuneable.
	if sf.has_animation("take_hit") and not _aye_action_frames("take_hit").is_empty():
		sf.set_animation_speed("take_hit", 24.0)     # 13 frames @24 = ~0.54s (visible). Tuneable.
	if sf.has_animation("take_hit_low") and not _aye_action_frames("take_hit_low").is_empty():
		sf.set_animation_speed("take_hit_low", 24.0)
	# AIR_JAB (salto+R) de Aye = casteo DIAGONAL ABAJO: guardia -> apunta el báculo diagonal -> sostiene.
	# 9 frames @ 20fps = ~0.45s; llega al apuntado (frame ~3) y sostiene mientras salen los 3 bolts. Tuneable.
	if sf.has_animation("air_jab") and not _aye_action_frames("air_jab").is_empty():
		sf.set_animation_speed("air_jab", 20.0)
	# MANA_CHARGE (canaleo doble-tap abajo): LOOP del canaleo (circulo magico + particulas + pelo
	# volando). 27 frames @16fps = ~1.7s por vuelta. Tuneable.
	var mc_frames := _aye_action_frames("mana_charge")
	if not mc_frames.is_empty():
		if not sf.has_animation("mana_charge"):
			sf.add_animation("mana_charge")
		sf.set_animation_loop("mana_charge", true)
		sf.set_animation_speed("mana_charge", 16.0)
		for t in mc_frames:
			sf.add_frame("mana_charge", t)
	# PUMMELED (tambaleo en LOOP mientras la comban en el super/finishers): 23 frames @20fps (~1.15s).
	var pm_frames := _aye_action_frames("pummeled")
	if not pm_frames.is_empty():
		if not sf.has_animation("pummeled"):
			sf.add_animation("pummeled")
			for t in pm_frames:
				sf.add_frame("pummeled", t)
		sf.set_animation_loop("pummeled", true)
		sf.set_animation_speed("pummeled", 32.0)   # rápido: acompaña la ráfaga del ultra (los golpes son veloces)
	# GET_UP (recuperacion: tendida -> se para): 27 frames @22fps (~1.2s), NO loop, termina de pie (#248).
	var gu_frames := _aye_action_frames("get_up")
	if not gu_frames.is_empty():
		if not sf.has_animation("get_up"):
			sf.add_animation("get_up")
			for t in gu_frames:
				sf.add_frame("get_up", t)
		sf.set_animation_loop("get_up", false)
		sf.set_animation_speed("get_up", 46.0)   # MUY rápido: el snap a idle casi no se nota (+ destello de poder)
	# KO / KO_AIR / VICTORY (DAM ya las tiene; el loop generico usa los frames de Aye) -> velocidad propia
	if sf.has_animation("ko") and not _aye_action_frames("ko").is_empty():
		sf.set_animation_speed("ko", 22.0)         # 23 frames: colapso de espaldas (~1s), retiene tendida
	if sf.has_animation("ko_air") and not _aye_action_frames("ko_air").is_empty():
		sf.set_animation_speed("ko_air", 18.0)     # 16 frames: tendida boca abajo
	if sf.has_animation("victory") and not _aye_action_frames("victory").is_empty():
		sf.set_animation_speed("victory", 22.0)    # 45 frames: celebracion + giro (~2s), retiene pose
	# PUNCH (Q): estocada fuerte con el báculo. 12 frames @ 28fps = ~0.43s. Tuneable.
	if sf.has_animation("punch") and not _aye_action_frames("punch").is_empty():
		sf.set_animation_speed("punch", 28.0)
	# PUNCH2 (2do golpe de →Q, doble estocada): Aye NO tiene arte propio de punch2 -> REUSA sus frames
	# de punch. Sin esto, el 2do golpe caía al placeholder de DAM (se "transformaba" en la katana). Mismo ritmo.
	var aye_p1 := _aye_action_frames("punch")
	if not aye_p1.is_empty() and _aye_action_frames("punch2").is_empty():
		if sf.has_animation("punch2"):
			sf.remove_animation("punch2")
		sf.add_animation("punch2")
		sf.set_animation_loop("punch2", false)
		sf.set_animation_speed("punch2", 28.0)
		for t in aye_p1:
			sf.add_frame("punch2", t)
	# KICK (W) = ICE-GROW cast: alza el báculo alto y vuelve. 33 frames @ 30fps = ~1.1s. Tuneable.
	if sf.has_animation("kick") and not _aye_action_frames("kick").is_empty():
		sf.set_animation_speed("kick", 30.0)
	# CROUCH_PUNCH (↓Q): jab bajo agachada. 17 frames @ 42fps = ~0.40s (rápido, ágil). Tuneable.
	if sf.has_animation("crouch_punch") and not _aye_action_frames("crouch_punch").is_empty():
		sf.set_animation_speed("crouch_punch", 54.0)   # más SNAPPY (17 frames @54 = ~0.31s). Tuneable.
	# CROUCH_KICK (↓W): gancho ascendente anti-aéreo. 15 frames @ 26fps = ~0.58s (más fluido). Tuneable.
	if sf.has_animation("crouch_kick") and not _aye_action_frames("crouch_kick").is_empty():
		sf.set_animation_speed("crouch_kick", 26.0)
	# CROUCH_JAB (↓R): poke bajo agachada con el báculo. 12 frames @ 34fps = ~0.35s (snappy, jab rápido).
	# guardia→windup→poke PICO(#6, extendido)→hold breve→recupera a guardia baja. Tuneable.
	if sf.has_animation("crouch_jab") and not _aye_action_frames("crouch_jab").is_empty():
		sf.set_animation_speed("crouch_jab", 34.0)
	# SWEEP (↓E) = ICE-SPIKES cast: giro bajo→release al frente (erupta el hielo, #6)→recover. RÁPIDO.
	# 10 frames @ 28fps = ~0.36s. Al conectar CONGELA al rival (freeze morado). Tuneable.
	if sf.has_animation("sweep") and not _aye_action_frames("sweep").is_empty():
		sf.set_animation_speed("sweep", 28.0)
	# JUMP_PUNCH (salto+Q): golpe aéreo con el báculo. 14 frames @ 24fps = ~0.58s (cabe en el airtime). Tuneable.
	if sf.has_animation("jump_punch") and not _aye_action_frames("jump_punch").is_empty():
		sf.set_animation_speed("jump_punch", 24.0)
	# JUMP_KICK (salto+W): golpe aéreo OVERHEAD (báculo baja). 10 frames @ 26fps = ~0.38s. RÁPIDO
	# a propósito: el strike veloz + el swing disimulan frames donde la IA corta el báculo. Tuneable.
	if sf.has_animation("jump_kick") and not _aye_action_frames("jump_kick").is_empty():
		sf.set_animation_speed("jump_kick", 26.0)
	# CRYSTAL_CAST (E de Aye): cast a distancia. NO es anim de DAM -> se agrega aparte (como el
	# water_cast de Fe). Solo si tiene frames propios. 12 frames @ 20fps = ~0.6s. Tuneable.
	var aye_cc := _aye_action_frames("crystal_cast")
	if not aye_cc.is_empty():
		if not sf.has_animation("crystal_cast"):
			sf.add_animation("crystal_cast")
		sf.set_animation_loop("crystal_cast", false)
		sf.set_animation_speed("crystal_cast", 20.0)
		for t in aye_cc:
			sf.add_frame("crystal_cast", t)
	# CRYSTAL_FLURRY (SÚPER de Aye, ↓←+Q): ráfaga del báculo estilo lightning-legs. NO es anim de DAM
	# -> se agrega aparte. 18 frames @ 26fps = ~0.7s (rápido). La orquesta el súper (main._run_crystal_flurry).
	var aye_cf := _aye_action_frames("crystal_flurry")
	if not aye_cf.is_empty():
		if not sf.has_animation("crystal_flurry"):
			sf.add_animation("crystal_flurry")
		sf.set_animation_loop("crystal_flurry", true)   # LOOP: la ráfaga sigue mientras dure el súper
		sf.set_animation_speed("crystal_flurry", 58.0)  # 145 frames FLUIDOS @58fps = ~2.5s la tanda
		for t in aye_cf:
			sf.add_frame("crystal_flurry", t)
	# COUNTER (PARRY de Aye): frame 0 = pose de DESVÍO diagonal (do_parry la congela) -> extiende el
	# báculo al frente = contraataque. NO es anim de DAM (.tres) -> se agrega aparte. 7 frames @ 20fps.
	var aye_ct := _aye_action_frames("counter")
	if not aye_ct.is_empty():
		if not sf.has_animation("counter"):
			sf.add_animation("counter")
		sf.set_animation_loop("counter", false)
		sf.set_animation_speed("counter", 20.0)
		for t in aye_ct:
			sf.add_frame("counter", t)
	# TELEPORT (↓→Q de Aye): glitch morado (dissolve out -> reform in). NO es anim de DAM -> se agrega
	# aparte. Solo si tiene frames propios (imagen-action/aye/teleport/). ~30fps.
	var aye_tp := _aye_action_frames("teleport")
	if not aye_tp.is_empty():
		if not sf.has_animation("teleport"):
			sf.add_animation("teleport")
		sf.set_animation_loop("teleport", false)
		sf.set_animation_speed("teleport", 30.0)
		for t in aye_tp:
			sf.add_frame("teleport", t)
	# JUMP_KICK_CAST (salto+Q de Aye): gira el báculo (molinete) y al LANZARLO al frente invoca 3
	# proyectiles de cristal RECTOS (frames 6-9). NO es anim de DAM -> se agrega aparte. 9 frames @ 22fps
	# = ~0.41s (cabe en el airtime; los 3 disparos salen en la fase de lanzamiento). Tuneable.
	var aye_jkc := _aye_action_frames("jump_kick_cast")
	if not aye_jkc.is_empty():
		if not sf.has_animation("jump_kick_cast"):
			sf.add_animation("jump_kick_cast")
		sf.set_animation_loop("jump_kick_cast", false)
		sf.set_animation_speed("jump_kick_cast", 18.0)   # 20 frames @18 = ~1.1s (giro dura + cae suave)
		for t in aye_jkc:
			sf.add_frame("jump_kick_cast", t)
	# LAND (aterrizaje): flexiona las rodillas para amortiguar y se recupera a la pose. NO es anim de DAM
	# -> se agrega aparte. Solo si tiene frames propios. No-loop (se juega una vez -> vuelve a idle). ~24fps.
	var aye_land := _aye_action_frames("land")
	if not aye_land.is_empty():
		if not sf.has_animation("land"):
			sf.add_animation("land")
		sf.set_animation_loop("land", false)
		sf.set_animation_speed("land", 15.0)   # 6 frames @15 = ~0.40s: se VE la flexión (antes 24 = muy rápido)
		for t in aye_land:
			sf.add_frame("land", t)
	# NEUTRAL_SPIN (salto ADELANTE / mortal): Aye no tiene giro propio. Si no hay frames suyos,
	# quitamos el placeholder de DAM (katana) para que el salto adelante caiga al "jump" normal
	# (fighter.gd: si no existe neutral_spin, juega "jump"). Si algún día se generan sus frames,
	# se conserva la animación y vuelve a usarse.
	if sf.has_animation("neutral_spin") and _aye_action_frames("neutral_spin").is_empty():
		sf.remove_animation("neutral_spin")
	# AYE se sentía LENTA: apurar TODAS sus acciones de personaje un 25% (golpes, caminar,
	# saltos, reacciones). NO tocar: proyectiles (crystal_fly/impact van aparte), mana_charge,
	# pummeled/get_up (ya tuneadas), ko/ko_air/victory (escenas), pose (idle), crystal_flurry (ultra).
	for aa in ["walk", "walk_back", "jump", "land", "weak_punch", "punch", "kick",
			"crouch_punch", "crouch_kick", "crouch_jab", "sweep", "jump_punch", "jump_kick",
			"jump_kick_cast", "crystal_cast", "teleport", "counter", "air_jab",
			"take_hit", "take_hit_low"]:
		if sf.has_animation(aa) and not _aye_action_frames(aa).is_empty():
			sf.set_animation_speed(aa, sf.get_animation_speed(aa) * 1.25)
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
	# COUNTER (parry-contraataque, ↓+E): desvío + 3 cortes
	if not sf.has_animation("counter"):
		var cf := _dam_action_frames("counter")
		if not cf.is_empty():
			sf.add_animation("counter")
			sf.set_animation_loop("counter", false)
			sf.set_animation_speed("counter", 16.0)
			for t in cf:
				sf.add_frame("counter", t)
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
		f.spd = AYE_MOVE_SPD
		f.jump_mult = 1.12   # salta un poquito más alto que el resto
	else:
		f.sprite.sprite_frames = _build_dam_frames()
		f.base_scale = Vector2(DAM_SCALE, DAM_SCALE)
		f.sprite.scale = f.base_scale
		f.sprite.offset = Vector2(0, DAM_FEET_FROM_CENTER / DAM_SCALE - DAM_FEET_FROM_CENTER)
		f.spd = 0.9   # TANK: se desplaza más lento (le cuesta acercarse a un zoner) -> su debilidad
		f.has_super_armor = true   # TANK: super armor en el arranque de su pesado (kick)
		# KO tendido de DAM: el cuerpo flotaba (el pixel más bajo era la mano/katana).
		# Se baja el boca-arriba y se sube el boca-abajo (que estaba hundido ~100px).
		f.ko_lie_drop_up = 120.0   # (antes 70, quedaba flotando alto vs Fe -> se baja más)
		f.ko_lie_drop_down = -95.0
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
	var ids := [selected_char, cpu_char]
	for side in 2:
		var c := _char_data(ids[side])
		if hud_name[side] != null:
			hud_name[side].text = String(c["name"])
		if hud_avatar[side] != null and ResourceLoader.exists(String(c["avatar"])):
			hud_avatar[side].texture = load(String(c["avatar"]))
			_cover_avatar(hud_avatar[side], 114, 114, 1.4 if ids[side] == "aye" else 1.0)   # Aye: acerca su cara
		# MANA: ¿este lado es mago (wizard)? -> muestra el anillo y carga su retrato
		var is_mage: bool = String(c.get("arch", "")) == "wizard"
		mana_is_mage[side] = is_mage
		if mana_hud[side] != null:
			mana_hud[side].visible = is_mage
		if is_mage and mana_avatar[side] != null and ResourceLoader.exists(String(c["avatar"])):
			mana_avatar[side].texture = load(String(c["avatar"]))
			_cover_avatar(mana_avatar[side], MANA_AV_BOX, MANA_AV_BOX)
			mana_avatar[side].flip_h = side == 1

func _start_round() -> void:
	state = "intro"
	Sel.stop_menu_music()   # empieza la pelea: corta la canción del menú
	_apply_char(player, selected_char)          # personaje del jugador (frames + arquetipo + escala)
	_apply_char(dummy, cpu_char)                # el rival (P2/CPU): el que eligió el jugador en el 2do paso
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
	mana = [1.0, 1.0]        # mana lleno al empezar la ronda (los magos arrancan con hechizos)
	mana_flash_t = [0.0, 0.0]
	mana_full_flash_t = [0.0, 0.0]
	mana_was_full = [true, true]   # arranca full: no destella en el intro
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
	# Aye (zoner) tiene casts LENTOS con daño RETRASADO (proyectil que viaja, hielo que erupta): ventana
	# de combo más AMPLIA solo para ella, para que sus cadenas no se caigan por el tiempo de viaje/cast.
	var win: float = COMBO_WINDOW
	var atk_f: Node2D = player if idx == 0 else dummy
	if is_instance_valid(atk_f) and atk_f.fx_floral:
		win = 1.25
	var baja: bool = not aereo and combo_n[idx] > 0 and nivel < int(combo_lvl[idx])
	if combo_t[idx] > win or atk_name == combo_last[idx] or baja:
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
		victima.hit_flying = false
		victima.hard_fall = false
		victima.ultra_hover = false
		victima.vel_y = 0.0
		victima.position.y = victima.floor_y   # se queda EN EL PISO toda la ráfaga (no flota)
		# SIEMPRE mira hacia el atacante para que el recular sea acorde al golpe
		victima.set_facing(1 if atacante.position.x > victima.position.x else -1)
		if victima.sprite.sprite_frames.has_animation("pummeled"):
			# NO reiniciar cada golpe (se veía glitch/rapidísimo): se inicia UNA vez
			# y hace loop suave durante toda la ráfaga.
			if String(victima.sprite.animation) != "pummeled":
				victima.sprite.play("pummeled")
		else:
			victima.sprite.play("take_hit_low" if i % 2 == 0 else "take_hit")
		# el tambaleo SIGUE EL RITMO de los golpes: cada golpe REINICIA el latigazo (desde
		# el tramo de cabeza-atrás) y la velocidad se ajusta para que UN ciclo completo dure
		# exactamente el intervalo hasta el próximo golpe; si la ráfaga ya va más rápida que
		# el ciclo, corre libre a tope
		if String(victima.sprite.animation) == "pummeled":
			var paso_g := lerpf(0.42, 0.05, ramp)
			var ciclo: float = float(victima.sprite.sprite_frames.get_frame_count("pummeled")) \
					/ float(victima.sprite.sprite_frames.get_animation_speed("pummeled"))
			if paso_g >= 0.20:
				victima.sprite.frame = 9   # arranca en el inicio del latigazo hacia ATRÁS
			victima.sprite.speed_scale = clampf(ciclo / paso_g, 1.0, 3.2)
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
	victima.sprite.speed_scale = 1.0
	return n

func _run_ultra(atacante: Node2D, idx: int, largo := false) -> void:
	ultra_largo = largo
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	# EL ULTRA AGARRA AL RIVAL: si estaba EN EL AIRE / volando / lejos arriba, se lo trae al
	# PISO de pie y de FRENTE. Sin esto quedaba flotando arriba recibiendo golpes fantasma y
	# virado al revés (DAM en el suelo pegándole al aire).
	victima.airborne = false
	victima.hit_flying = false
	victima.hard_fall = false
	victima.ultra_hover = false
	victima.crouching = false
	victima.vel_x = 0.0
	victima.vel_y = 0.0
	victima.position.y = victima.floor_y
	victima.set_facing(-dir)
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
		else:
			victima.sprite.play("take_hit")   # Fe (sin pummeled): reacciona al golpe
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
		# lanzamiento alto + caida acelerada (hard_fall). Sube RECTO (vel_x=0) y SIN rebote de
		# pared (wall_bounced=true) -> nunca entra en wall_splat boca abajo; cae BOCA ARRIBA
		# igual en los dos ultras. Fuerza moderada (1.25) + tope de techo para no salirse arriba.
		victima.receive_hit(false, true, dir, "kick_impact", false, 1.25)
		victima.vel_x = 0.0
		victima.wall_bounced = true
		victima.hard_fall = true
		await get_tree().create_timer(0.4, true, false, true).timeout
		Engine.time_scale = 1.0
		# NO se espera el aterrizaje: _end_round maneja el vuelo→caída→boca abajo→freeze
		# (K.O. a tiempo y el rival completa su vuelo por los aires, sin flotar).
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
	_play_cutin(-1 if combo_x >= 960.0 else 1, atacante)   # combo a la derecha -> retrato a la izquierda
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
	# NO se espera el aterrizaje: si murió, _end_round maneja la caída→boca abajo→freeze
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

# ---- AYE: SÚPER CRYSTAL FLURRY (↓←+Q tras 3 golpes, cuesta 1.5 barras) ----
# Ráfaga del báculo (lightning legs) con estela NEÓN morada: varios golpes CRÍTICOS y deja al rival
# CONGELADO 1s. Escena épica (pantalla oscura + líneas manga + cut-in + grito), estilo inferno de DAM.
func try_crystal_flurry(atacante: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if atacante == player else 1
	if meter[idx] < 1.5:
		return false          # cuesta 1.5 BARRAS
	if combo_n[idx] < 3 or combo_t[idx] > COMBO_WINDOW:
		return false          # necesita 3 golpes encadenados VIVOS
	# NO conecta de LEJOS: el rival debe estar CERCA. Si un lanzador (↓W, salto+E, etc.) lo mandó
	# lejos, el súper NO se activa (antes Aye se teletransportaba y pegaba de un extremo al otro).
	var victima: Node2D = dummy if idx == 0 else player
	if absf(victima.position.x - atacante.position.x) > 520.0:
		return false
	meter[idx] -= 1.5
	_run_crystal_flurry(atacante, idx)   # resetea combo_n al final (no repetir el súper)
	return true

func _run_crystal_flurry(atacante: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	ultra_active = true
	state = "ultra"
	player.input_enabled = false
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	atacante.airborne = false
	atacante.crouching = false
	atacante.set_facing(dir)
	_focus_start(atacante)         # borde + PANTALLA OSCURA (se intensifica con el combo)
	_focus_set(0.35)
	# trae al rival al piso, de frente
	victima.airborne = false
	victima.hit_flying = false
	victima.hard_fall = false
	victima.ultra_hover = false
	victima.crouching = false
	victima.vel_x = 0.0
	victima.vel_y = 0.0
	victima.position.y = victima.floor_y
	victima.set_facing(-dir)
	# GRITO del súper + CUT-IN (retrato de Aye, lado opuesto al contador de combo)
	var vflur := "res://imagen-action/aye/sound-effect/crystal_flurry_Cupcake_Eleven_v3_019ff390-2631-7f3d-8d53-c74ae4ef5664.mp3"
	if ResourceLoader.exists(vflur):
		atacante.voz_player.stream = load(vflur)
		atacante.voz_player.play()
	var combo_x: float = float(combo_rest_x[idx])
	_play_cutin(-1 if combo_x >= 960.0 else 1, atacante)
	# arranque dramático: pose CONGELADA en el frame 0 + velo MORADO tenue durante el cut-in
	atacante.sprite.play("crystal_flurry")
	atacante.sprite.frame = 26              # arranca en la ESTOCADA (#192), no en la pose parada del wind-up
	atacante.sprite.speed_scale = 0.0
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.10, 0.0, 0.14, 0.22)
	Engine.time_scale = 0.0
	await get_tree().create_timer(1.4, true, false, true).timeout   # pausa dramática (el cut-in dura más)
	Engine.time_scale = 1.0
	atacante.sprite.speed_scale = 1.0        # SUELTA la ráfaga
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.9, 0.35, 1.4, 0.45)   # fogonazo MORADO al soltar
	_shake(22.0, 0.3)
	# MULTI-HIT: golpes CRÍTICOS mientras corre la anim (la estela NEÓN la dibuja el propio sprite,
	# AYE_SWING_FX["crystal_flurry"]). El rival se tambalea (pummeled). El súper NO mata (min 1 HP):
	# el CONGELADO final es el remate/sello del zoner.
	var n0: int = combo_n[idx]
	var HITS := 16
	var PASO := 0.09
	var crit_total := int(hp_max[1 - idx] * 0.35)   # ~35% de la vida del rival, repartido
	var dealt := 0
	var hit_i := 0
	var hit_cd := 0.06   # arranca ya en la estocada -> golpes casi de inmediato
	var t := 0.0
	var fin := 0.06 + float(HITS) * PASO + 0.06
	atacante.position.x = clampf(victima.position.x - float(dir) * 175.0, LEFT_LIMIT, RIGHT_LIMIT)
	while t < fin and state == "ultra":
		var dt := get_process_delta_time()
		atacante.set_facing(dir)
		victima.set_facing(-dir)
		victima.position.y = victima.floor_y
		if victima.sprite.sprite_frames.has_animation("pummeled"):
			if String(victima.sprite.animation) != "pummeled":
				victima.sprite.play("pummeled")
		hit_cd -= dt
		if hit_cd <= 0.0 and hit_i < HITS:
			hit_cd = PASO
			hit_i += 1
			var d := (crit_total - dealt) if hit_i == HITS else int(crit_total / HITS)
			dealt += d
			if idx == 0:
				dummy_hp = maxi(1, dummy_hp - d)
			else:
				player_hp = maxi(1, player_hp - d)
			_ultra_count(idx, n0 + hit_i)
			combo_dmg[idx] += d
			combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
			_focus_set(0.4 + 0.6 * float(hit_i) / float(HITS))
			if ultra_panels.size() > 0:
				ultra_panel.texture = ultra_panels[hit_i % ultra_panels.size()]
				ultra_panel.visible = true
			victima._burst(0.85, false, 1, false, 500.0 * (1.0 - victima.base_scale.y))
			_shake(12.0, 0.1)
			victima._play_sfx_key("take_hit")
			flash_ms = Time.get_ticks_msec()
			flash_rect.color = Color(0.85, 0.35, 1.3, 0.4)   # fogonazo morado por golpe
		t += dt
		await get_tree().process_frame
	# REMATE: GOLPE FINAL con el uppercut ↓W (crouch_kick = su lanzador de luna de hielo). Aye hace el
	# gancho ascendente, erupta su LUNA morada y LANZA al rival por los aires (así se LEE el golpe final,
	# no un corte seco). El lanzamiento lo saca del tambaleo (pummeled) -> hit_fly -> se recupera solo.
	atacante.sprite.speed_scale = 1.0
	atacante.airborne = false
	atacante.crouching = false
	atacante.set_facing(dir)
	atacante.position.x = clampf(victima.position.x - float(dir) * 150.0, LEFT_LIMIT, RIGHT_LIMIT)
	atacante.moon_cast_spawned = false     # garantiza que la LUNA erupte en el remate
	atacante.sprite.play("crouch_kick")    # el uppercut lanzador (báculo hacia arriba + luna morada)
	# breve windup del uppercut antes del impacto
	var wu := 0.0
	while wu < 0.16 and state == "ultra":
		atacante.set_facing(dir)
		await get_tree().process_frame
		wu += get_process_delta_time()
	# IMPACTO del golpe final: fogonazo morado + cámara lenta + LANZA ALTO
	victima.set_facing(-dir)
	victima._burst(1.4)
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.95, 0.4, 1.6, 0.8)
	_shake(30.0, 0.45)
	Engine.time_scale = 0.30
	await get_tree().create_timer(0.14, true, false, true).timeout
	Engine.time_scale = 1.0
	victima.receive_hit(false, true, dir, "kick_impact", false, 1.45)   # strong -> _launch ALTO
	# deja que el uppercut de Aye TERMINE antes de devolver el control (no corta el golpe final)
	var rec := 0.0
	while rec < 0.30 and state == "ultra":
		atacante.set_facing(dir)
		await get_tree().process_frame
		rec += get_process_delta_time()
	_focus_end()
	ultra_active = false
	state = "fight"
	# NO repetir el súper: resetea el combo del atacante para que exija un combo de 3 NUEVO antes de
	# poder soltarlo otra vez (aunque le sobren barras). Cierra también la ventana por si acaso.
	combo_n[idx] = 0
	combo_t[idx] = COMBO_WINDOW + 1.0
	atacante.sprite.play("pose")           # se para tras el uppercut
	player.input_enabled = true
	dummy.ai_enabled = dummy_ai_mode

# TELEPORT de Aye (↓→Q, reemplaza el dash): glitch out + TIEMBLA + sonido -> reaparece AL FRENTE del
# rival con un golpe. Sombras + borde MORADO que se desvanecen si no encadena un combo. Invulnerable.
# ¿Aye tiene barra para el teleport? (lo consulta fighter._start_teleport ANTES de comprometerse)
# ---- MANA: API de hechizos (fighter consulta antes de castear) ----
func _mana_side(caster: Node2D) -> int:
	return 0 if caster == player else 1

func _mana_ok(caster: Node2D, cost: float) -> bool:
	var i := _mana_side(caster)
	if not mana_is_mage[i]:
		return true            # los no-magos nunca se quedan sin "mana"
	return mana[i] >= cost - 0.0001

func _mana_spend(caster: Node2D, cost: float) -> void:
	var i := _mana_side(caster)
	if not mana_is_mage[i]:
		return
	mana[i] = maxf(0.0, mana[i] - cost)

# feedback cuando NO alcanza el mana: el anillo parpadea rojo (y el hechizo no sale)
func _mana_denied(caster: Node2D) -> void:
	mana_flash_t[_mana_side(caster)] = 0.35

# puntos de un circulo/arco (para el anillo de mana). frac=1 -> circulo completo.
# compensacion de ASPECTO: con window/stretch/aspect=ignore un circulo del lienzo (1920x1080) se OVALA
# si la ventana no es 16:9. Multiplicamos el radio X por k para que el anillo salga CIRCULAR.
func _mana_xk() -> float:
	var w := get_window().size
	if w.x <= 0 or w.y <= 0:
		return 1.0
	return (float(w.y) * 1920.0) / (float(w.x) * 1080.0)

func _mana_circle_pts(cx: float, cy: float, r: float, n: int, frac: float, side: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var k := _mana_xk()
	var total := int(round(float(n) * clampf(frac, 0.0, 1.0)))
	var dirp := 1.0 if side == 0 else -1.0   # P1 horario, P2 antihorario (espejo)
	for i in range(total + 1):
		var a := -PI * 0.5 + dirp * TAU * float(i) / float(n)
		pts.append(Vector2(cx + cos(a) * r * k, cy + sin(a) * r))
	return pts

func _mana_disc_pts(cx: float, cy: float, r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var k := _mana_xk()
	for i in n:
		var a := TAU * float(i) / float(n)
		pts.append(Vector2(cx + cos(a) * r * k, cy + sin(a) * r))
	return pts

func _aye_bar_ok(caster: Node2D) -> bool:
	var idx := 0 if caster == player else 1
	return meter[idx] >= 1.0

# BLINK de Aye (←← / →→): glitch EN EL SITIO (anim teleport + tiembla + sonido) y
# reaparece ~CUERPO Y MEDIO hacia ATRÁS (escape) o ADELANTE (avance; frena a UN cuerpo
# del rival para no montarse encima). Sin golpe. Esquiva breve. El maná ya se cobró
# en fighter._start_blink.
func _aye_blink(caster: Node2D, fwd := false) -> void:
	if state != "fight" or ultra_active:
		return
	caster.crouching = false
	caster.vel_x = 0.0
	caster.vel_y = 0.0
	caster.buffer_t = 0.0
	caster.breaker_inv_t = maxf(caster.breaker_inv_t, 0.35)   # esquiva breve durante el glitch
	caster.breaker_fx_t = maxf(caster.breaker_fx_t, 0.5)      # sombras moradas
	caster._cast_border_on(0.6)
	var was_input: bool = caster.input_enabled
	var was_ai: bool = caster.ai_enabled
	caster.input_enabled = false
	caster.ai_enabled = false
	if caster.sprite.sprite_frames.has_animation("teleport"):
		caster.sprite.play("teleport")
	var vr := "res://imagen-action/aye/sound-effect/teleport-aye.mp3"
	if ResourceLoader.exists(vr):
		caster.voz_player.stream = load(vr)
		caster.voz_player.play()
	var base_off: float = caster.sprite.offset.x
	var t := 0.0
	while t < 0.16 and state == "fight":
		caster.sprite.offset.x = base_off + randf_range(-11.0, 11.0)   # TIEMBLA
		_shake(7.0, 0.04)
		await get_tree().process_frame
		t += get_process_delta_time()
	caster.sprite.offset.x = base_off
	if state == "fight":
		var _bopp: Node2D = dummy if caster == player else player
		var _bdir := float(caster.facing) * (1.0 if fwd else -1.0)
		var _bdest: float = caster.position.x + _bdir * BODY_SEP * 1.5
		if fwd:
			# tope: no atravesar ni montarse en el rival — frena a UN cuerpo de él; si ya
			# está más cerca que eso, no avanza (el glitch queda en el sitio)
			if caster.facing > 0:
				_bdest = maxf(caster.position.x, minf(_bdest, _bopp.position.x - BODY_SEP))
			else:
				_bdest = minf(caster.position.x, maxf(_bdest, _bopp.position.x + BODY_SEP))
		caster.position.x = clampf(_bdest, LEFT_LIMIT, RIGHT_LIMIT)
		caster.position.y = caster.floor_y
		if caster.sprite.sprite_frames.has_animation("teleport"):
			# glitch de ENTRADA: la anim AL REVÉS desde el frame 6 (el glitch se disuelve).
			# NO reproducirla completa hacia adelante: los frames 10-11 son el CUADRO glitch
			# a pantalla completa (55%+ del lienzo) y se veía un rectángulo gigante.
			caster.sprite.play_backwards("teleport")
			caster.sprite.frame = 6
	caster.input_enabled = was_input
	caster.ai_enabled = was_ai

func _aye_teleport(caster: Node2D, from_air := false) -> void:
	if state != "fight" or ultra_active:
		return
	# el costo del teleport ahora es MANA (se cobra en fighter._start_teleport via _spell_afford)
	var opp: Node2D = dummy if caster == player else player
	caster.crouching = false
	caster.airborne = from_air   # si teleportó EN EL AIRE, se queda en el aire (combo aéreo)
	caster.vel_x = 0.0
	caster.vel_y = 0.0
	caster.buffer_t = 0.0
	caster.breaker_inv_t = maxf(caster.breaker_inv_t, 0.5)   # invulnerable (esquiva) durante el glitch
	caster.breaker_fx_t = maxf(caster.breaker_fx_t, 0.8)     # sombras MORADAS (se desvanecen)
	caster._cast_border_on(1.2)                              # borde MORADO (se desvanece si no combea)
	var was_input: bool = caster.input_enabled
	var was_ai: bool = caster.ai_enabled
	caster.input_enabled = false
	caster.ai_enabled = false
	# GLITCH OUT en el sitio + sonido + TIEMBLA (jitter del sprite + shake de cámara)
	if caster.sprite.sprite_frames.has_animation("teleport"):
		caster.sprite.play("teleport")
	var vr := "res://imagen-action/aye/sound-effect/teleport-aye.mp3"
	if ResourceLoader.exists(vr):
		caster.voz_player.stream = load(vr)
		caster.voz_player.play()
	var base_off: float = caster.sprite.offset.x
	var hold_y: float = caster.position.y   # en el aire: congela su altura durante el glitch (sin caer)
	var t := 0.0
	while t < 0.24 and state == "fight":
		caster.sprite.offset.x = base_off + randf_range(-13.0, 13.0)   # TIEMBLA
		if from_air:
			caster.vel_y = 0.0
			caster.position.y = hold_y     # no la deja caer por gravedad mientras glitchea
		_shake(9.0, 0.05)
		await get_tree().process_frame
		t += get_process_delta_time()
	caster.sprite.offset.x = base_off
	if state != "fight":
		caster.input_enabled = was_input
		caster.ai_enabled = was_ai
		return
	# REAPARECE justo AL FRENTE del rival, encarándolo, con un GOLPE
	var dir := 1 if opp.position.x >= caster.position.x else -1
	caster.position.x = clampf(opp.position.x - float(dir) * 150.0, LEFT_LIMIT, RIGHT_LIMIT)
	if from_air:
		# EN EL AIRE: reaparece a la altura del rival (si también está arriba) o mantiene su altura
		# aérea, y remata con un GOLPE AÉREO. Luego cae normal (gravedad).
		caster.position.y = opp.position.y if opp.airborne else minf(caster.position.y, caster.floor_y - 120.0)
		caster.airborne = true
		caster.vel_y = -120.0          # pequeño impulso; la gravedad la hace caer enseguida
	else:
		caster.position.y = caster.floor_y
	caster.set_facing(dir)
	caster._spawn_ghost(false)         # after-imagen morada al reaparecer
	_shake(15.0, 0.13)
	if from_air and caster.sprite.sprite_frames.has_animation("jump_punch"):
		caster.sprite.play("jump_punch")   # GOLPE AÉREO de llegada
	else:
		caster.sprite.play("weak_punch")   # el GOLPE de llegada (el árbitro aplica el hit a rango)
	caster.input_enabled = was_input
	caster.ai_enabled = was_ai

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
	atacante.sprite.animation = "whirlpool"
	atacante.sprite.stop()
	atacante.sprite.frame = 0                      # f1: pose de arranque (se ve durante el freeze)
	if atacante.has_method("_spawn_jump_dust"):
		atacante._spawn_jump_dust(0.55)   # un toque de polvo al arrancar (sutil, no tapa)
	# GRITA en su player de VOZ propio (no lo corta el sonido de impacto)
	var voz = load("res://imagen-action/favi/Fe-sound-effect/whirlpool-fe.wav")
	if voz != null and atacante.voz_player != null:
		atacante.voz_player.stream = voz
		atacante.voz_player.play()
	# CUT-IN del PERSONAJE (como el inferno de DAM): retrato de Fe en el lado opuesto al combo
	var combo_x: float = float(combo_rest_x[idx])
	_play_cutin(-1 if combo_x >= 960.0 else 1, atacante)
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
	# ARRANQUE del giro: acelera del reposo (f1) al tornado completo (f4)
	for fr in range(1, atacante.sprite.sprite_frames.get_frame_count("whirlpool")):
		atacante.sprite.frame = fr
		await get_tree().create_timer(0.045).timeout
	var spin_clock := 0.0   # reloj del giro (cicla los frames de tornado)
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
		# GIRA: cicla los frames de TORNADO (f2,f3,f4) rápido — nunca vuelve a la pose f1
		spin_clock += dt
		atacante.sprite.frame = 1 + (int(spin_clock / 0.045) % 3)
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
	# RECUPERACIÓN: desacelera saliendo del giro reproduciendo los frames AL REVÉS
	# (f4 -> f1): da la sensación de que el tornado se FRENA y Favi vuelve a la pose.
	var nfr: int = atacante.sprite.sprite_frames.get_frame_count("whirlpool")
	for fr in range(nfr - 1, -1, -1):
		atacante.sprite.frame = fr
		await get_tree().create_timer(0.06).timeout
	_fe_cast_fx(atacante, false)                         # apaga el borde azul
	atacante.sprite.play("pose")
	# REMATE: lo derriba al piso (solo si el remolino lo atrapó)
	if alcanza:
		victima.receive_hit(false, false, dir, "", true, 1.0)
		# NO se espera el aterrizaje: _end_round maneja el vuelo→caída→boca abajo→freeze
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
		if String(victima.sprite.animation) == "pummeled":
			var paso_g := lerpf(0.42, 0.06, ramp)
			var ciclo: float = float(victima.sprite.sprite_frames.get_frame_count("pummeled")) \
					/ float(victima.sprite.sprite_frames.get_animation_speed("pummeled"))
			if paso_g >= 0.20:
				victima.sprite.frame = 9   # un latigazo nuevo por golpe (cabeza atrás)
			victima.sprite.speed_scale = clampf(ciclo / paso_g, 1.0, 3.2)
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
	victima.sprite.speed_scale = 1.0
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
		# NO se espera el aterrizaje: _end_round maneja el vuelo→caída→boca abajo→freeze
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
		# NO se espera el aterrizaje: _end_round maneja el vuelo→caída→boca abajo→freeze
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
func _cover_avatar(av: Sprite2D, box_w: float, box_h: float, zoom := 1.0) -> void:
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
	rw /= zoom                    # zoom>1 = recorta una ventana mas chica = ACERCA la cara
	rh /= zoom
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

	# mascara circular para el retrato (recorta la foto a un CIRCULO como el anillo)
	var _mana_mask_sh := Shader.new()
	_mana_mask_sh.code = "shader_type canvas_item;\nvoid fragment() {\n\tfloat d = distance(UV, vec2(0.5));\n\tCOLOR.a *= smoothstep(0.5, 0.47, d);\n}\n"
	# ---- ANILLO DE MANA (mana oscuro) en la esquina de ABAJO, solo visible para magos ----
	for side in 2:
		var cont := Node2D.new()
		cont.z_index = 9
		cont.visible = false                # oculto hasta saber si el lado es mago
		$UI.add_child(cont)
		mana_hud[side] = cont
		var mcx: float = MANA_CX_L if side == 0 else MANA_CX_R
		var disc := Polygon2D.new()         # disco oscuro de fondo (el "orbe")
		disc.polygon = _mana_disc_pts(mcx, MANA_CY, MANA_R - 3.0, 40)
		disc.color = Color(0.05, 0.03, 0.09, 0.97)
		cont.add_child(disc)
		mana_disc[side] = disc
		var av2 := Sprite2D.new()           # retrato del mago (se carga en _refresh_hud_chars)
		av2.centered = true
		av2.position = Vector2(mcx, MANA_CY)
		var _mmat := ShaderMaterial.new()
		_mmat.shader = _mana_mask_sh
		av2.material = _mmat
		cont.add_child(av2)
		mana_avatar[side] = av2
		var rbg := Line2D.new()             # anillo de fondo (circulo completo, morado oscuro)
		rbg.points = _mana_circle_pts(mcx, MANA_CY, MANA_R, 48, 1.0, side)
		rbg.width = MANA_RING_W
		rbg.default_color = Color(0.14, 0.07, 0.22, 0.96)
		rbg.joint_mode = Line2D.LINE_JOINT_ROUND
		cont.add_child(rbg)
		mana_ring_bg[side] = rbg
		var rf := Line2D.new()              # arco de mana (morado brillante, se vacia)
		rf.width = MANA_RING_W
		rf.default_color = Color(0.62, 0.30, 1.5)
		rf.joint_mode = Line2D.LINE_JOINT_ROUND
		rf.begin_cap_mode = Line2D.LINE_CAP_ROUND
		rf.end_cap_mode = Line2D.LINE_CAP_ROUND
		cont.add_child(rf)
		mana_ring_fill[side] = rf
		var rfr := Line2D.new()             # marco negro fino por fuera
		rfr.points = _mana_circle_pts(mcx, MANA_CY, MANA_R + MANA_RING_W * 0.5 + 1.5, 48, 1.0, side)
		rfr.width = 1.0
		rfr.default_color = Color(0, 0, 0, 0.9)
		cont.add_child(rfr)
		mana_ring_frame[side] = rfr

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
var _victory_stream_aye = null   # voz de victoria de Aye (victory-aye.mp3)
func _play_victory_line(who = null) -> void:
	# Aye se detecta por fx_floral; Fe por su animación exclusiva water_cast; si no, es DAM
	var es_aye: bool = who != null and bool(who.get("fx_floral"))
	var es_fe: bool = who != null and not es_aye and who.sprite.sprite_frames.has_animation("water_cast")
	var stream = null
	if es_aye:
		if _victory_stream_aye == null:
			var raye := "res://imagen-action/aye/sound-effect/victory-aye.mp3"
			_victory_stream_aye = load(raye) if ResourceLoader.exists(raye) else null
		stream = _victory_stream_aye
	elif es_fe:
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
	# BORDE del focus: MORADO para Aye (fx_floral), ROJO para DAM/Fe (default del shader)
	_outline_mat.set_shader_parameter("line_color",
		Color(1.45, 0.35, 2.0, 1.0) if atacante.fx_floral else Color(1.9, 0.12, 0.12, 1.0))
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

# borde MORADO para los CAST de hielo de Aye (W pilar / ↓W luna): como los ultras, pero
# corto y sin oscurecer la escena. Reusa el shader de outline con line_color morado.
var _cast_mat: ShaderMaterial = null
func _cast_border(atacante: Node2D, on: bool) -> void:
	if on:
		if _cast_mat == null:
			var sh := Shader.new()
			sh.code = _OUTLINE_CODE
			_cast_mat = ShaderMaterial.new()
			_cast_mat.shader = sh
			_cast_mat.set_shader_parameter("line_color", Color(1.45, 0.35, 2.0, 1.0))  # MORADO brillante
			_cast_mat.set_shader_parameter("width", 3.6)
			_cast_mat.set_shader_parameter("intensity", 0.95)
		atacante.sprite.material = _cast_mat
	elif atacante.sprite.material == _cast_mat:
		atacante.sprite.material = atacante.base_material   # restaura el color alterno (P2)

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
	# color alterno de P2 DESACTIVADO (el usuario lo pidió quitar: no se veía bien).
	# ambos peleadores quedan con su color normal.
	player.base_material = null
	player.sprite.material = null
	dummy.base_material = null
	dummy.sprite.material = null

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

func _play_cutin(side: int, caster: Node2D = null) -> void:
	if cutin_root == null:
		return
	# retrato del PERSONAJE que castea: DAM usa su cut-in del inferno; Fe su victory-hud.
	if caster != null and cutin_portrait != null:
		var ctex := "res://imagen-action/dam/cutin/dam-cutin.png"
		if caster.fx_floral:       # Aye: su retrato de cut-in (victory-hud-aye keyeado)
			ctex = "res://imagen-action/aye/sheets/victory-hud-aye-key.png"
		elif caster.fx_blue:       # Fe: su victory-hud
			ctex = "res://imagen-action/favi/sheets/victory-hud-fe-key.png"
		if ResourceLoader.exists(ctex):
			cutin_portrait.texture = load(ctex)
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
	# ANCLA el BORDE INFERIOR del retrato al borde de abajo (~1110), calculado según el aspecto de la
	# textura (STRETCH_KEEP_ASPECT_CENTERED la centra en la caja; sin esto Aye "flotaba" por su ratio distinto).
	var cy := 1080.0 - CUTIN_PH + 30.0
	if cutin_portrait.texture != null:
		var tw := float(cutin_portrait.texture.get_width())
		var th := float(cutin_portrait.texture.get_height())
		if tw > 0.0 and th > 0.0:
			var disp_h: float = th * minf(CUTIN_PW / tw, CUTIN_PH / th)
			cy = 1110.0 - (CUTIN_PH + disp_h) * 0.5
	cutin_portrait.position = Vector2(x, cy)
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
		# NO se muestra en training/práctica (free ni break): solo en VS CPU real
		var listo: bool = state == "fight" and not ultra_active \
				and dummy_ai_mode and not break_practice \
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
	if state == "title":
		var dirm := 0
		if Input.is_action_just_pressed("ui_up"):
			dirm = -1
		if Input.is_action_just_pressed("ui_down"):
			dirm = 1
		title_sel = posmod(title_sel + dirm, 3)
		for j in 3:
			var disabled := j == 2   # VS ONLINE aún no disponible
			var base := Color(0.42, 0.42, 0.48) if disabled else Color(0.62, 0.62, 0.68)
			title_opts[j].modulate = Color(1.0, 0.85, 0.25) if j == title_sel else base
			var lbl: String = ["VS CPU", "TRAINER", "VS ONLINE"][j]
			if disabled:
				lbl += "   (coming soon)"
			title_opts[j].text = ("▶  " if j == title_sel else "") + lbl
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
			if title_sel == 0:
				_begin_char_select(false, 0)     # VS CPU: pelea con IA
			elif title_sel == 1:
				_open_trainer()
			# title_sel == 2 (VS ONLINE): deshabilitado, no hace nada
		return
	if state == "trainer":
		var dirt := 0
		if Input.is_action_just_pressed("ui_up"):
			dirt = -1
		if Input.is_action_just_pressed("ui_down"):
			dirt = 1
		trainer_sel = posmod(trainer_sel + dirt, 3)
		for j in 3:
			trainer_opts[j].modulate = Color(1.0, 0.85, 0.25) if j == trainer_sel else Color(0.62, 0.62, 0.68)
			trainer_opts[j].text = ("▶  " if j == trainer_sel else "") + ["FREE PRACTICE", "BREAK PRACTICE", "MOVES & COMBOS"][j]
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
			if trainer_sel == 0:
				_begin_char_select(true, 1)      # práctica libre (dummy sin IA)
			elif trainer_sel == 1:
				_begin_char_select(true, 2)      # break practice
			else:
				trainer_panel.visible = false
				_open_moves()
		elif Input.is_action_just_pressed("ui_cancel"):
			_open_menu()
		return
	if state == "char_select":
		var dc := 0
		if Input.is_action_just_pressed("ui_left"):
			dc = -1
		if Input.is_action_just_pressed("ui_right"):
			dc = 1
		if picking == 0:
			char_sel_p1 = posmod(char_sel_p1 + dc, CHARS.size())
		else:
			char_sel_p2 = posmod(char_sel_p2 + dc, CHARS.size())
		_refresh_char_select()
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
			if picking == 0:
				# el jugador ya eligió SU personaje -> ahora elige el del rival (CPU)
				selected_char = String(CHARS[char_sel_p1]["id"])
				picking = 1
				_refresh_char_select()
			else:
				cpu_char = String(CHARS[char_sel_p2]["id"])
				break_practice = pending_mode == 2
				dummy_ai_mode = pending_mode == 0 or pending_mode == 2
				char_panel.visible = false
				_hide_char_vs()
				_start_round()
		elif Input.is_action_just_pressed("ui_cancel"):
			if picking == 1:
				picking = 0                       # vuelve a elegir P1
				_refresh_char_select()
			else:
				char_panel.visible = false
				_hide_char_vs()
				if vs_from_trainer:
					state = "trainer"; trainer_panel.visible = true
				else:
					_open_menu()
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
			state = "trainer"
			trainer_panel.visible = true
		return
	if state == "demo":
		if Input.is_action_just_pressed("ui_cancel"):
			_open_moves()
			return
	# ===== MENÚ DE PAUSA (mientras está congelado el combate) =====
	if state == "pause":
		# animación en tiempo REAL (el juego está en time_scale 0): líneas manga ciclan
		# y la placa activa PULSA. Time.get_ticks_msec NO se ve afectado por time_scale.
		var pt := float(Time.get_ticks_msec()) / 1000.0
		if pause_lines and ultra_panels.size() > 0:
			pause_lines.texture = ultra_panels[int(pt * 6.0) % ultra_panels.size()]
		if not pause_in_combos and pause_sel < pause_plates.size():
			var pulse := 0.68 + 0.32 * absf(sin(pt * 5.0))
			var c := Color(pause_accent.r * pulse, pause_accent.g * pulse, pause_accent.b * pulse, 1.0)
			(pause_plates[pause_sel] as Polygon2D).color = c
		if pause_in_combos:
			if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("kick"):
				_pause_show_combos(false)
			return
		var pd := 0
		if Input.is_action_just_pressed("ui_up"):
			pd = -1
		if Input.is_action_just_pressed("ui_down"):
			pd = 1
		if pd != 0:
			pause_sel = posmod(pause_sel + pd, pause_items.size())
			_pause_refresh()
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
			_pause_confirm()
		elif Input.is_action_just_pressed("ui_cancel"):
			_close_pause()          # ESC = seguir peleando
		return
	if state == "fight" and Input.is_action_just_pressed("ui_cancel"):
		_open_pause()               # ESC en pelea: abre el menú de pausa (ya NO salta al título)
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
			# MANA: se rellena SOLO con el tiempo (mas rapido si esta quieta en el suelo)
			for mi in 2:
				if not mana_is_mage[mi]:
					continue
				var mf2: Node2D = player if mi == 0 else dummy
				if mf2.channeling and mana[mi] >= 1.0:
					mf2._stop_channel()                            # LLENO: termina el canaleo
				if mana[mi] < 1.0:
					var mg := MANA_REGEN
					if mf2.channeling:
						mg = MANA_CHANNEL_REGEN                     # canaleo activo: recarga RAPIDA
					elif not mf2.airborne and String(mf2.sprite.animation) in ["pose", "idle", "crouch"]:
						mg += MANA_REGEN_IDLE
					mana[mi] = clampf(mana[mi] + mg * _delta, 0.0, 1.0)

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
	# MANA: arco morado de cada mago (parpadea rojo si falto mana)
	for mside in 2:
		if not mana_is_mage[mside] or mana_ring_fill[mside] == null:
			continue
		if mana_flash_t[mside] > 0.0:
			mana_flash_t[mside] = maxf(0.0, mana_flash_t[mside] - _delta)
		var mfr: float = clampf(mana[mside], 0.0, 1.0)
		var mcx2: float = MANA_CX_L if mside == 0 else MANA_CX_R
		var rfl: Line2D = mana_ring_fill[mside]
		rfl.points = _mana_circle_pts(mcx2, MANA_CY, MANA_R, 48, mfr, mside)
		# compensacion de aspecto (circulo perfecto en cualquier ventana)
		if mana_ring_bg[mside] != null:
			mana_ring_bg[mside].points = _mana_circle_pts(mcx2, MANA_CY, MANA_R, 48, 1.0, mside)
		if mana_ring_frame[mside] != null:
			mana_ring_frame[mside].points = _mana_circle_pts(mcx2, MANA_CY, MANA_R + MANA_RING_W * 0.5 + 1.5, 48, 1.0, mside)
		if mana_disc[mside] != null:
			mana_disc[mside].polygon = _mana_disc_pts(mcx2, MANA_CY, MANA_R - 3.0, 40)
		if mana_avatar[mside] != null:
			mana_avatar[mside].scale.x = mana_avatar[mside].scale.y * _mana_xk()
		# DETECTA el instante en que se LLENA -> destello de "full mana"
		var full_now: bool = mfr >= 0.999
		if full_now and not mana_was_full[mside]:
			mana_full_flash_t[mside] = 0.6
		mana_was_full[mside] = full_now
		if mana_full_flash_t[mside] > 0.0:
			mana_full_flash_t[mside] = maxf(0.0, mana_full_flash_t[mside] - _delta)
		var fk: float = mana_full_flash_t[mside] / 0.6
		if mana_flash_t[mside] > 0.0:
			rfl.default_color = Color(1.9, 0.22, 0.32)          # falta mana: rojo
			rfl.width = MANA_RING_W
		elif fk > 0.0:
			rfl.default_color = Color(0.95, 0.60, 2.05).lerp(Color(2.4, 2.1, 3.0), fk)   # DESTELLO al llenarse
			rfl.width = MANA_RING_W + 7.0 * fk
		elif full_now:
			rfl.default_color = Color(0.95, 0.60, 2.05)         # lleno: brilla
			rfl.width = MANA_RING_W
		else:
			rfl.default_color = Color(0.58, 0.30, 1.45)         # cargando: morado
			rfl.width = MANA_RING_W
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

# ===== PROYECTIL DE CRISTAL de Aye (E = crystal_cast) =====
var crystal_fly_frames: SpriteFrames = null
var crystal_impact_frames: SpriteFrames = null
var frost_orb_frames: SpriteFrames = null   # orbe PRISM ORB (efecto: crece+gira -> hold -> rompe+desaparece)

func _build_crystal_frames() -> void:
	if crystal_fly_frames == null:
		crystal_fly_frames = SpriteFrames.new()
		crystal_fly_frames.add_animation("fly")
		crystal_fly_frames.set_animation_loop("fly", true)
		crystal_fly_frames.set_animation_speed("fly", 18.0)
		var i := 1
		while ResourceLoader.exists("res://imagen-action/aye/crystal_shard/aye-crystal_shard-%d.png" % i):
			crystal_fly_frames.add_frame("fly", load("res://imagen-action/aye/crystal_shard/aye-crystal_shard-%d.png" % i))
			i += 1
	if crystal_impact_frames == null:
		crystal_impact_frames = SpriteFrames.new()
		crystal_impact_frames.add_animation("impact")
		crystal_impact_frames.set_animation_loop("impact", false)
		crystal_impact_frames.set_animation_speed("impact", 22.0)
		var j := 1
		while ResourceLoader.exists("res://imagen-action/aye/crystal_impact/aye-crystal_impact-%d.png" % j):
			crystal_impact_frames.add_frame("impact", load("res://imagen-action/aye/crystal_impact/aye-crystal_impact-%d.png" % j))
			j += 1

# jump_kick_cast (salto+E): dispara los 3 proyectiles UNO DETRÁS DEL OTRO (secuencial, NO los 3 a la vez),
# rectos a la altura de Aye (aire-vs-aire). Cada uno con borde morado + shade. Voz de cast = la misma que
# su golpe E parado (crystal_cast: "PRISM BOLT"). Se llama UNA vez cuando la anim llega al lanzamiento.
func _aye_air_barrage(caster: Node2D, down := false) -> void:
	if not is_instance_valid(caster):
		return
	var vr := "res://imagen-action/aye/sound-effect/prims-bolt-aye.mp3"
	if ResourceLoader.exists(vr):
		caster.voz_player.stream = load(vr)
		caster.voz_player.play()
	for i in range(3):
		if not is_instance_valid(caster) or state != "fight":
			return
		caster.breaker_fx_t = maxf(caster.breaker_fx_t, 0.5)   # SHADE morado por disparo
		caster._cast_border_on(0.5)                            # borde MORADO por disparo
		_spawn_crystal_projectile(caster, true, i, down)       # down=true -> diagonal abajo (aire-vs-suelo)
		if i < 2:
			await get_tree().create_timer(0.13).timeout        # espaciado -> salen uno detrás del otro

# Aye lanza el proyectil (lo llama fighter al gritar en crystal_cast). Viaja hacia el rival y
# SIEMPRE estalla al llegar (esquivado o no); solo hace daño si el rival está en el punto de impacto.
func _spawn_crystal_projectile(caster: Node2D, air := false, shot := 0, down := false) -> void:
	_build_crystal_frames()
	if crystal_fly_frames.get_frame_count("fly") == 0:
		return
	var dir: int = caster.facing
	var s: float = 0.45 * caster.base_scale.x   # proyectil MÁS PEQUEÑO
	# altura MEDIA del cuerpo (a la ALTURA REAL del que lanza, esté en el suelo o EN EL AIRE): sale
	# de su báculo. salto+E: RECTO a su altura (aire-vs-aire). salto+R (down): DIAGONAL abajo hacia el
	# rival en el SUELO (aire-vs-suelo) — la trayectoria la calcula _crystal_travel.
	# ref #187: position.y+(500-485*bs). bs=0.72 -> ~+150.
	var py: float = caster.position.y + 500.0 - 485.0 * caster.base_scale.y
	var proj := AnimatedSprite2D.new()
	proj.sprite_frames = crystal_fly_frames
	proj.animation = "fly"
	proj.z_index = 7
	proj.scale = Vector2(s * float(dir), s)   # flip: la estela queda DETRÁS
	caster.get_parent().add_child(proj)
	proj.position = Vector2(caster.position.x + float(dir) * 150.0, py)
	proj.play("fly")
	_crystal_travel(proj, caster, dir, py, air, shot, down)

func _crystal_travel(proj: AnimatedSprite2D, caster: Node2D, dir: int, py: float, air := false, shot := 0, down := false) -> void:
	# capturamos lo del caster ANTES del vuelo (por si se libera al terminar el round)
	var caster_is_player: bool = caster == player
	var arena: Node = caster.get_parent()
	var cs: float = caster.base_scale.x
	# hit-check por altura (SUELO): golpea si el rival está a la misma altura del PROYECTIL. En el aire
	# (jump_kick_cast) el proyectil vuela RECTO a la altura de Aye -> es un combo AIRE-CONTRA-AIRE: solo
	# le da al rival si TAMBIÉN está por los aires a esa altura (si está parado abajo, pasa por encima).
	var caster_y: float = caster.position.y
	var target: Node2D = dummy if caster_is_player else player
	# SFX de VUELO (whoosh): más bajo y se CORTA al impactar (no debe seguir sonando después)
	var fly_sp: AudioStreamPlayer = null
	var fly_sfx := "res://imagen-action/aye/sound-effect/prim-bolt-fly.mp3"
	if ResourceLoader.exists(fly_sfx):
		fly_sp = AudioStreamPlayer.new()
		fly_sp.stream = load(fly_sfx)
		fly_sp.volume_db = -9.0
		arena.add_child(fly_sp)
		fly_sp.play()
	var speed := 1700.0
	# TRAYECTORIA: recto horizontal por defecto (salto+E / crystal_cast). En modo DOWN (salto+R) sale en
	# DIAGONAL FIJA abajo-adelante (~45°), siguiendo el ángulo del báculo (#219) — NO apunta al rival: es
	# una diagonal fija y pega por PROXIMIDAD si su línea pasa cerca del rival PARADO (aire-contra-suelo).
	var vel := Vector2(float(dir) * speed, 0.0)
	var ground_stop: float = caster.floor_y + 500.0 - 330.0 * caster.base_scale.y   # ~nivel de piernas del rival parado
	if down:
		var a := deg_to_rad(45.0)
		vel = Vector2(float(dir) * speed * cos(a), speed * sin(a))
		proj.rotation = float(dir) * a   # inclina el creciente hacia la diagonal (respeta el flip por dir)
	var dhit := false                    # (down) pegó por proximidad durante el vuelo
	var ghost_t := 0.0
	while is_instance_valid(proj) and is_instance_valid(target):
		proj.position += vel * get_process_delta_time()
		# SHADE effect: deja una estela de "fantasmas" morados que se quedan y se desvanecen
		ghost_t += get_process_delta_time()
		if ghost_t >= 0.028:
			ghost_t = 0.0
			_spawn_moon_ghost(arena, proj)
		# DOWN: pega si la diagonal PASA CERCA del cuerpo del rival PARADO (aire-contra-suelo)
		if down and not target.koed and (target.floor_y - target.position.y) < 90.0:
			var tch: float = target.position.y + 500.0 - 485.0 * target.base_scale.y
			if absf(proj.position.x - target.position.x) < 165.0 and absf(proj.position.y - tch) < 200.0:
				dhit = true
				break
		var reached: bool = (dir > 0 and proj.position.x >= target.position.x) or (dir < 0 and proj.position.x <= target.position.x)
		if (not down and reached) or proj.position.x < LEFT_LIMIT or proj.position.x > RIGHT_LIMIT or (down and proj.position.y > ground_stop):
			break
		await get_tree().process_frame
	# corta el whoosh de vuelo apenas termina el viaje (impacto o pared) para que NO siga sonando
	if is_instance_valid(fly_sp):
		fly_sp.queue_free()
	if not is_instance_valid(proj) or not is_instance_valid(arena):
		if is_instance_valid(proj):
			proj.queue_free()
		return
	var ix: float = proj.position.x
	var iy: float = proj.position.y   # en DOWN la diagonal desciende: el impacto es en el punto real
	proj.queue_free()
	# IMPACTO (splash) en el punto de contacto — SIEMPRE que llega (esquivado o no)
	var imp := AnimatedSprite2D.new()
	imp.sprite_frames = crystal_impact_frames
	imp.animation = "impact"
	imp.z_index = 7
	var si: float = 0.5 * cs
	imp.scale = Vector2(si, si)
	arena.add_child(imp)
	imp.position = Vector2(ix, iy)
	imp.play("impact")
	imp.animation_finished.connect(imp.queue_free)
	# SFX del SPLASH al reventar el proyectil
	var spl_sfx := "res://imagen-action/aye/sound-effect/prims-bolt-spl.mp3"
	if ResourceLoader.exists(spl_sfx):
		var sp2 := AudioStreamPlayer.new()
		sp2.stream = load(spl_sfx)
		arena.add_child(sp2)
		sp2.finished.connect(sp2.queue_free)
		sp2.play()
	# DAÑO solo si el rival está EN el punto de impacto: cerca en X y a la altura del PROYECTIL.
	# En el suelo: misma altura de suelo. En el aire (recto a la altura de Aye): golpea si el pecho del
	# rival está a la altura de vuelo del proyectil (py) -> combo aire-contra-aire.
	var tgt_ok := false
	if is_instance_valid(target) and not target.koed:
		if down:
			tgt_ok = dhit                                    # DOWN: ya se resolvió por proximidad en el vuelo
		elif air:
			var tgt_chest: float = target.position.y + 500.0 - 485.0 * target.base_scale.y
			tgt_ok = absf(target.position.x - ix) < 240.0 and absf(iy - tgt_chest) < 240.0
		else:
			tgt_ok = absf(target.position.x - ix) < 240.0 and absf(target.position.y - caster_y) < 230.0
	if tgt_ok:
		var res: String = target.receive_hit(false, false, dir, "", false)
		if res == "hit" or res == "launched":
			# SUMA al combo (pasa por _combo_hit) para que ↓E (freeze) + E (proyectil) encadenen.
			# AÉREO (jump_kick_cast): cada uno de los 3 proyectiles usa un NOMBRE DISTINTO (crystal_air_a/b/c)
			# para que NO se lean como "mismo golpe repetido" y cuenten como 3 HITS reales. Menos daño
			# c/u (son 3). El empuje pequeño lo da el propio take_hit (push_dir*20) → "empuja un poco".
			var hidx := 0 if caster_is_player else 1
			var atk_id: String = "crystal_cast"
			var proj_dmg := 80
			if air:
				atk_id = ["crystal_air_a", "crystal_air_b", "crystal_air_c"][clampi(shot, 0, 2)]
				proj_dmg = 50
			var dmg_real: int = _combo_hit(hidx, proj_dmg, atk_id, target.airborne)
			if caster_is_player:
				dummy_hp = maxi(0, dummy_hp - dmg_real)
			else:
				player_hp = maxi(0, player_hp - dmg_real)
			meter[hidx] = minf(METER_MAX, meter[hidx] + float(dmg_real) * 0.0020)   # el proyectil también CARGA barra
			_shake(9.0, 0.12)

# SHADE del proyectil: copia fantasma MORADA del frame actual de la luna, que se queda en el sitio
# y se desvanece (deja una estela detrás del proyectil que vuela).
func _spawn_moon_ghost(arena: Node, proj: AnimatedSprite2D) -> void:
	if not is_instance_valid(proj) or not is_instance_valid(arena):
		return
	var tex: Texture2D = proj.sprite_frames.get_frame_texture(proj.animation, proj.frame)
	if tex == null:
		return
	var g := Sprite2D.new()
	g.texture = tex
	g.position = proj.position
	g.scale = proj.scale          # hereda el flip (facing) y el tamaño
	g.z_index = 6                 # detrás del proyectil (z=7)
	g.modulate = Color(1.35, 0.45, 1.85, 0.30)   # morado translúcido
	arena.add_child(g)
	var tw := g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.26)
	tw.tween_callback(g.queue_free)

# ---- AYE: FROST ORB "PRISM ORB" (→↓←+R) ----
# Orbe de cristal que se DESPLAZA girando y creciendo ~4 cuerpos, deja estela morada de congelación en
# el suelo, flota ~1.5s y luego se ROMPE (esquirlas que desaparecen). Si el rival la TOCA (corre, salta
# o lo empujan hacia ella) -> CONGELADO ~1s + se rompe. Una sola anim; el motor controla fase/posición.
const ORB_GROW_END := 10   # frame donde termina crecer+girar (0..10) y empieza el HOLD
const ORB_CRACK := 11      # frame donde empieza a agrietarse/romperse (11..21)
func _build_frost_orb_frames() -> void:
	if frost_orb_frames != null:
		return
	frost_orb_frames = SpriteFrames.new()
	frost_orb_frames.add_animation("orb")
	frost_orb_frames.set_animation_loop("orb", false)
	var i := 1
	while ResourceLoader.exists("res://imagen-action/aye/frost_orb/aye-frost_orb-%d.png" % i):
		frost_orb_frames.add_frame("orb", load("res://imagen-action/aye/frost_orb/aye-frost_orb-%d.png" % i))
		i += 1

# ¿el rival está TOCANDO la orbe? (cerca en X y no saltó MUY por encima). ox = x de la orbe; gy su base.
func _orb_touch(opp: Node2D, ox: float, base: float) -> bool:
	if not is_instance_valid(opp) or opp.koed:
		return false
	if absf(opp.position.x - ox) > 190.0 * base:
		return false
	# la orbe va del suelo hacia arriba ~460*base; si el rival saltó por ENCIMA del orbe, no lo toca
	return (opp.floor_y - opp.position.y) < 430.0 * base

# estela MORADA de congelación en el suelo por donde pasa la orbe (se desvanece)
func _spawn_frost_trail(arena: Node, x: float, gy: float, base: float) -> void:
	if not is_instance_valid(arena):
		return
	var p := Polygon2D.new()
	var w := 95.0 * base
	var h := 26.0 * base
	var pts := PackedVector2Array()
	for k in range(12):
		var a := TAU * float(k) / 12.0
		pts.append(Vector2(cos(a) * w, sin(a) * h))
	p.polygon = pts
	p.color = Color(0.72, 0.32, 1.0, 0.45)   # morado translúcido (hielo)
	p.position = Vector2(x, gy)
	p.z_index = 3   # en el suelo, detrás de la orbe
	arena.add_child(p)
	var tw := p.create_tween()
	tw.tween_property(p, "modulate:a", 0.0, 0.9)   # se desvanece
	tw.tween_callback(p.queue_free)

func _spawn_frost_orb(caster: Node2D) -> void:
	_build_frost_orb_frames()
	if frost_orb_frames.get_frame_count("orb") == 0:
		return
	var dir: int = caster.facing
	var idx := 0 if caster == player else 1
	var opp: Node2D = dummy if caster == player else player
	var arena: Node = caster.get_parent()
	var base: float = caster.base_scale.x
	# GRITO "PRISM ORB" al castear (voz, como el prism-bolt)
	var vr := "res://imagen-action/aye/sound-effect/PRISM_ORB_Cupcake_Eleven_v3_019ff62a-9604-703e-9275-380f8bbbd818.mp3"
	if ResourceLoader.exists(vr):
		caster.voz_player.stream = load(vr)
		caster.voz_player.play()
	caster._cast_border_on(0.6)
	var s: float = 0.55 * base
	var proj := AnimatedSprite2D.new()
	proj.sprite_frames = frost_orb_frames
	proj.animation = "orb"
	proj.z_index = 6
	proj.scale = Vector2(s, s)
	arena.add_child(proj)
	# la orbe está anclada por su BASE (ring) en canvas y=800 (de 920, centro 460); el sprite se centra
	# en proj.position -> la base cae 340*s px por debajo. La ponemos al NIVEL EXACTO DEL SUELO (el mismo
	# que usan sus efectos de suelo: to_global(0, SHADOW_FEET_OFFSET=500)).
	var feet_world: float = caster.to_global(Vector2(0.0, 500.0)).y
	var gy: float = feet_world - 340.0 * s   # base (canvas 800) al NIVEL DEL SUELO -> encima de su estela
	var startx: float = caster.position.x + float(dir) * 180.0
	var endx: float = clampf(startx + float(dir) * 240.0, LEFT_LIMIT + 60.0, RIGHT_LIMIT - 60.0)   # ~2 cuerpos (corto)
	proj.position = Vector2(startx, gy)
	proj.stop()
	proj.frame = 0
	var frozen := false
	# SPIN: tras crecer, loopea los frames de tamaño completo (7..ORB_GROW_END) para que SIGA GIRANDO
	# mientras viaja Y mientras flota (antes se quedaba estática = "deja de rotar antes de pararse").
	var spin_lo := 7
	var spin_f := float(spin_lo)
	var spin_fps := 14.0
	# FASE 1: CRECE rápido (primer 40%) y luego VIAJA LENTO girando hasta ~2 cuerpos, luego SE DETIENE
	var t := 0.0
	var dur := 1.5   # recorrido LENTO. Tuneable.
	var grow_dur := dur * 0.40
	var trail_t := 0.0
	while t < dur and state == "fight" and is_instance_valid(proj):
		if t < grow_dur:
			proj.frame = int(round((t / grow_dur) * float(ORB_GROW_END)))   # crece de abajo-arriba
		else:
			spin_f += spin_fps * get_process_delta_time()                   # loop de spin (full-size)
			if spin_f > float(ORB_GROW_END):
				spin_f = float(spin_lo)
			proj.frame = int(spin_f)
		proj.position.x = lerpf(startx, endx, t / dur)
		trail_t += get_process_delta_time()
		if trail_t >= 0.05:
			trail_t = 0.0
			_spawn_frost_trail(arena, proj.position.x, feet_world, base)   # estela en el SUELO (pies)
		if _orb_touch(opp, proj.position.x, base):
			frozen = true
			break
		await get_tree().process_frame
		t += get_process_delta_time()
	# FASE 2: HOLD ~1.5s DETENIDA pero SIGUE GIRANDO (loop de spin), chequeando toque
	if not frozen and is_instance_valid(proj):
		var h := 0.0
		while h < 1.5 and state == "fight" and is_instance_valid(proj):
			spin_f += spin_fps * get_process_delta_time()
			if spin_f > float(ORB_GROW_END):
				spin_f = float(spin_lo)
			proj.frame = int(spin_f)
			if _orb_touch(opp, proj.position.x, base):
				frozen = true
				break
			await get_tree().process_frame
			h += get_process_delta_time()
	# CONGELA si lo tocó (DIRECTO: sirve estando parado O en el aire, y NO lo puede bloquear la IA)
	if frozen and is_instance_valid(opp) and not opp.koed:
		opp.frozen_t = 1.0        # ~1s congelado (el freeze block de _physics_process lo pausa + tinta morado)
		opp.vel_x = 0.0
		opp.vel_y = 0.0           # se queda congelado DONDE esté (si saltó, en el aire; cae al descongelar)
		var d := 45
		if caster == player:
			dummy_hp = maxi(0, dummy_hp - d)
		else:
			player_hp = maxi(0, player_hp - d)
		_shake(13.0, 0.16)
	# FASE 3: se ROMPE (frames ORB_CRACK..fin) y desaparece
	if is_instance_valid(proj):
		var last: int = frost_orb_frames.get_frame_count("orb") - 1
		var st := 0.0
		var sdur := 0.8
		while st < sdur and is_instance_valid(proj):
			var k: float = st / sdur
			proj.frame = ORB_CRACK + int(round(k * float(last - ORB_CRACK)))
			await get_tree().process_frame
			st += get_process_delta_time()
		if is_instance_valid(proj):
			proj.queue_free()

# ---- AYE: BACKSTAB (↓→W) ----
# Se teleporta DETRÁS del rival, lo golpea y lo EMPUJA ~3 cuerpos hacia adelante (hacia donde dejó la orbe).
# Si en el empujón el rival TOCA la orbe -> el coroutine del orb lo congela (opp.frozen_t) y frenamos el slide.
func _aye_backstab(caster: Node2D) -> void:
	if state != "fight" or ultra_active:
		return
	var opp: Node2D = dummy if caster == player else player
	if not is_instance_valid(opp) or opp.koed:
		# whiff: sin rival válido, solo el golpe en el sitio
		caster.sprite.play("weak_punch")
		return
	var to_opp := 1 if opp.position.x >= caster.position.x else -1   # dir de Aye -> rival (y del empujón inverso)
	# MISMO EFECTO DE TELEPORT que ↓→Q: glitch morado (anim "teleport") + tiembla + invuln + borde/sombras
	caster.breaker_inv_t = maxf(caster.breaker_inv_t, 0.5)
	caster.breaker_fx_t = maxf(caster.breaker_fx_t, 0.8)
	caster._cast_border_on(1.0)
	var was_input: bool = caster.input_enabled
	var was_ai: bool = caster.ai_enabled
	caster.input_enabled = false
	caster.ai_enabled = false
	if caster.sprite.sprite_frames.has_animation("teleport"):
		caster.sprite.play("teleport")
	var vr := "res://imagen-action/aye/sound-effect/teleport-aye.mp3"
	if ResourceLoader.exists(vr):
		caster.voz_player.stream = load(vr)
		caster.voz_player.play()
	# GLITCH OUT en el sitio + TIEMBLA (jitter del sprite + shake), igual que el teleport
	var base_off: float = caster.sprite.offset.x
	var gt := 0.0
	while gt < 0.24 and state == "fight" and is_instance_valid(opp):
		caster.sprite.offset.x = base_off + randf_range(-13.0, 13.0)
		_shake(9.0, 0.05)
		await get_tree().process_frame
		gt += get_process_delta_time()
	caster.sprite.offset.x = base_off
	if state != "fight" or not is_instance_valid(opp) or opp.koed:
		caster.input_enabled = was_input
		caster.ai_enabled = was_ai
		return
	# REAPARECE detrás del rival (lado opuesto), encarándolo, con un GOLPE
	to_opp = 1 if opp.position.x >= caster.position.x else -1
	caster._spawn_ghost(false)
	caster.position.x = clampf(opp.position.x + float(to_opp) * 175.0, LEFT_LIMIT, RIGHT_LIMIT)
	caster.set_facing(-to_opp)          # ahora Aye está DETRÁS, encara al rival
	# APARECE YA GOLPEANDO: salta a la ESTOCADA del weak_punch (báculo extendido), no a la guardia,
	# para que se LEA el golpe (si no, aparece en pose neutra y el rival "sale golpeado" sin ver el golpe).
	caster.sprite.play("weak_punch")
	var thrust: int = mini(14, caster.sprite.sprite_frames.get_frame_count("weak_punch") - 1)
	caster.sprite.frame = thrust
	caster.input_enabled = was_input
	caster.ai_enabled = was_ai
	_shake(14.0, 0.15)
	# EFECTO DE IMPACTO (chispa) al conectar, a la altura del pecho del rival (como un golpe normal)
	opp._burst(1.3, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
	opp._play_sfx_key("take_hit")   # sonido de impacto
	# DAÑO del golpe
	var d := 50
	if caster == player:
		dummy_hp = maxi(0, dummy_hp - d)
	else:
		player_hp = maxi(0, player_hp - d)
	# EMPUJA al rival ~3 cuerpos hacia ADELANTE (dir -to_opp, hacia donde estaba Aye / la orbe) con un SLIDE.
	# Si toca la orbe durante el slide, el coroutine del orb pone frozen_t>0 y aquí paramos.
	var push_dir := -to_opp
	opp.crouching = false
	opp.airborne = false
	opp.hit_flying = false
	opp.vel_y = 0.0
	opp.set_facing(-push_dir)            # el rival mira hacia Aye (que quedó atrás)
	opp.sprite.play("take_hit")
	var sx0: float = opp.position.x
	var target_x: float = clampf(sx0 + float(push_dir) * 470.0, LEFT_LIMIT, RIGHT_LIMIT)   # ~3 cuerpos
	var st := 0.0
	var sdur := 0.30
	while st < sdur and state == "fight" and is_instance_valid(opp) and not opp.koed and opp.frozen_t <= 0.0:
		opp.position.x = lerpf(sx0, target_x, st / sdur)
		await get_tree().process_frame
		st += get_process_delta_time()

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
	# el AIR JAB de DAM es AIRE-A-AIRE (solo pega si el rival está EN EL AIRE). El de Fe es
	# JUMP-IN: pega también al rival EN EL SUELO si está a rango (por eso el not att.fx_blue).
	if String(atk["name"]) in ["air_jab", "air_jab_2"] and not att.fx_blue \
			and not (def.airborne and (def.floor_y - def.position.y) > 40.0):
		return done
	# los golpes BAJOS raspan el piso: fallan contra un rival en el aire
	if bool(atk.get("low", false)) and def.airborne \
			and (def.floor_y - def.position.y) > 40.0:
		return done
	var dx: float = def.position.x - att.position.x
	# el ALCANCE escala con el CUERPO del atacante (Fe/Aye son más chicas que DAM): sin esto
	# Fe pegaba desde "cuerpo y medio" porque usaba el reach tuneado para DAM. DAM = idéntico.
	var reach: float = float(atk["reach"]) * (att.base_scale.x / DAM_SCALE)
	if absf(dx) > reach + HIT_MARGIN:
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
		# EN EL SUELO no se alcanza a un rival ALTO en el aire (no pegar desde abajo al aire
		# vacío): sólo llega a un rival BAJO, recién lanzado. Los LANZADORES (giratoria /
		# crouch_kick) llegan un poco más para poder encadenar el juggle. Aplica a ambos.
		if not att.airborne and def.airborne \
				and (def.floor_y - def.position.y) > 60.0:
			v_max = 250.0 if String(atk["name"]) in ["spin_kick", "crouch_kick"] else 150.0
		alcanza = absf(att.position.y - def.position.y) <= v_max
	if not alcanza:
		if String(atk["name"]) in ["spin_kick", "air_spin_kick", "ember_dash"]:
			return ""
		return done
	# PARRY: si el defensor está en la VENTANA de parry (Q+W) y el golpe iba a conectar,
	# lo DESVÍA y CONTRAATACA (on_parry) en vez de recibir daño.
	if def.parry_t > 0.0 and not def.koed:
		att.duck_swing()          # corta el whoosh del atacante
		on_parry(def, att)
		return done
	var push := 1 if dx >= 0.0 else -1
	var result: String = def.receive_hit(bool(atk["low"]), bool(atk.get("strong", false)), push, String(atk.get("impact_sfx", "")), bool(atk.get("trip", false)), float(atk.get("launch_mult", 1.0)), bool(atk.get("wall_launch", false)), false, bool(atk.get("freeze", false)))
	if result != "ignored":
		att.duck_swing()
	# BLOQUEAR gasta energía: mantener la guardia mientras recibís golpes drena el meter
	# (proporcional a la fuerza del golpe). Es un costo por cada golpe aguantado.
	if result == "blocked":
		var didx := 1 if att_is_player else 0
		meter[didx] = maxf(0.0, meter[didx] - float(atk.get("damage", 50)) * BLOCK_DRAIN)
	if result == "armored":
		# TANK aguantó con super armor: recibe CHIP (daño reducido), SIN combo/hitstop/empuje.
		# El chip NO lo mata (min 1) para que su pesado alcance a rematar al assassin.
		var chip := maxi(1, int(float(atk.get("damage", 50)) * 0.45))
		if att_is_player:
			dummy_hp = maxi(1, dummy_hp - chip)
		else:
			player_hp = maxi(1, player_hp - chip)
		_shake(6.0, 0.08)
	if result == "hit" or result == "launched" or result == "frozen":
		# HITSTOP: ambos se CONGELAN unos frames en el impacto (peso + pausa entre golpes,
		# como los juegos pro). La duración escala con el PESO del golpe: jab ligero =
		# congelamiento corto y ágil; golpe fuerte / lanzador = largo y con más impacto. El
		# atacante congela un pelín MENOS que la víctima (el que pega recupera antes y se
		# siente el control), técnica clásica de fighting games.
		var strong := bool(atk.get("strong", false))
		var dmg := float(atk.get("damage", 50))
		# valores tipo STREET FIGHTER (~11-16 frames): jab ~0.11s, golpe fuerte ~0.20s,
		# lanzador ~0.26s. El freeze sólido da ese "peso" pesado de SF sin sentirse lento.
		var hs := 0.11 + clampf(dmg / 100.0, 0.0, 1.0) * 0.09   # 0.11 (jab) .. 0.20 (100 dmg)
		if result == "launched":
			hs += 0.06                                          # el lanzador pega MÁS fuerte
		if result != "frozen":
			def.apply_hitstop(hs)                               # el CONGELADO (frozen_t) reemplaza el hitstop de la víctima
		att.apply_hitstop(hs * 0.85)                            # el atacante recupera un pelín antes
		# micro-shake proporcional al golpe: le da "punch" al impacto sin marear
		_shake(lerpf(4.0, 13.0, clampf(dmg / 110.0, 0.0, 1.0)) + (5.0 if strong else 0.0), hs)
		# si el atacante golpea EN EL AIRE, flota un poco para seguir el juggle y puede
		# encadenar OTRO golpe aéreo (distinto, por la regla de oro). Si falla NO flota
		# ni puede repetir: cae normal.
		if att.airborne:
			att.air_float_t = 0.32
			att.air_move_used = false
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
	var loser: Node = dummy if player_won else player
	if player_won:
		wins_p1 += 1
	else:
		wins_p2 += 1
	rounds_label.text = "%d  -  %d" % [wins_p1, wins_p2]
	# el rival muere: si el golpe lo LANZÓ, sube por los aires y al llegar al ÁPICE se
	# CONGELA todo con el K.O. (slam mid-air); si murió PARADO, cae de espaldas y se
	# congela YA TENDIDO en el piso. En ambos casos, tras el freeze sigue normal.
	var aerial: bool = loser.airborne or loser.hit_flying
	loser.die_ko()
	ko_lines.modulate = Color(1.7, 0.28, 0.28, 0.0)         # líneas rojas (DETRÁS de players)
	if aerial:
		# SUBE hasta cerca del ápice (rojo tenue, aún SIN K.O.)
		var ps := Time.get_ticks_msec()
		while (loser.airborne or loser.hit_flying) and loser.vel_y < -100.0 and Time.get_ticks_msec() - ps < 600:
			ko_red.color.a = 0.35
			await get_tree().process_frame
	else:
		# muerte parada: deja correr la caída de espaldas hasta quedar TENDIDO (sin K.O. aún)
		var gs := Time.get_ticks_msec()
		while Time.get_ticks_msec() - gs < 750:
			ko_red.color.a = 0.35
			await get_tree().process_frame
		loser.force_grounded_ko()                            # asegura el frame TENDIDO
	# SLAM: CONGELA + K.O. + shake (rival mid-air si fue aéreo, o ya tendido si de suelo)
	_show_announce("K.O.", Color(0.88, 0.15, 0.12), 2.4, -1)   # sólido, bajo el umbral de glow
	ko_lines.visible = true
	_shake(26.0, 0.5)
	Engine.time_scale = 0.0                                  # CONGELA
	var ks := Time.get_ticks_msec()
	while Time.get_ticks_msec() - ks < 850:
		var kt := float(Time.get_ticks_msec() - ks) / 1000.0
		if ultra_panels.size() > 0:
			ko_lines.texture = ultra_panels[int(kt * 16.0) % ultra_panels.size()]
		ko_lines.modulate.a = 1.0
		ko_red.color.a = 0.62                                # pantalla ROJA (detrás, players sobresalen)
		await get_tree().process_frame
	Engine.time_scale = 1.0                                  # ...y AHORA sigue normal
	if aerial:
		# tras el freeze CAE y queda tendido BOCA ABAJO en el piso
		var fs := Time.get_ticks_msec()
		while (loser.airborne or loser.hit_flying) and Time.get_ticks_msec() - fs < 2500:
			var ft := float(Time.get_ticks_msec() - fs) / 1000.0
			if ultra_panels.size() > 0:
				ko_lines.texture = ultra_panels[int(ft * 16.0) % ultra_panels.size()]
			ko_lines.modulate.a = 1.0
			ko_red.color.a = 0.55                            # rojo mientras cae
			await get_tree().process_frame
		loser.force_grounded_ko()                            # tendido BOCA ABAJO en el piso
	# se VA todo: el rojo y las líneas se desvanecen mientras el KO cae
	var fsm := Time.get_ticks_msec()
	while Time.get_ticks_msec() - fsm < 800:
		var k := 1.0 - float(Time.get_ticks_msec() - fsm) / 800.0
		ko_red.color.a = 0.55 * k
		ko_lines.modulate.a = k
		if ultra_panels.size() > 0:
			ko_lines.texture = ultra_panels[int(float(Time.get_ticks_msec() - fsm) / 60.0) % ultra_panels.size()]
		await get_tree().process_frame
	ko_red.color.a = 0.0
	ko_lines.visible = false
	await get_tree().create_timer(0.7).timeout
	var winner: Node2D = player if player_won else dummy
	if player_won:
		player.celebrate()
	else:
		dummy.celebrate()
	# GANADOR: su retrato (estilo cut-in del inferno) entra DETRÁS de los peleadores; el
	# ganador celebra ENCIMA y SOBRESALE. El retrato y el nombre son del PERSONAJE que ganó.
	var win_tex := "res://imagen-action/dam/cutin/dam-cutin.png"
	if winner.fx_floral:       # Aye
		win_tex = "res://imagen-action/aye/sheets/victory-hud-aye-key.png"
	elif winner.fx_blue:       # Fe
		win_tex = "res://imagen-action/favi/sheets/victory-hud-fe-key.png"
	if ResourceLoader.exists(win_tex):
		win_portrait.texture = load(win_tex)
	var win_name := "AYE" if winner.fx_floral else ("FE" if winner.fx_blue else "DAM")
	# el retrato sale DEL LADO DONDE ESTÁ el ganador (queda detrás de él y el personaje
	# sobresale encima); antes dependía de quién ganó y podía salir desconectado al otro lado
	var wside := -1 if winner.position.x < 960.0 else 1
	var wrest_x := (-CUTIN_PW * 0.14) if wside < 0 else (1920.0 - CUTIN_PW * 0.86)
	var woff_x := wrest_x - 240.0 * float(wside)
	var wcy := 1080.0 - CUTIN_PH + 30.0   # ancla el borde inferior del retrato al de abajo (según su aspecto)
	if win_portrait.texture != null:
		var wtw := float(win_portrait.texture.get_width())
		var wth := float(win_portrait.texture.get_height())
		if wtw > 0.0 and wth > 0.0:
			var wdh: float = wth * minf(CUTIN_PW / wtw, CUTIN_PH / wth)
			wcy = 1110.0 - (CUTIN_PH + wdh) * 0.5
	win_portrait.position = Vector2(woff_x, wcy)
	win_portrait.visible = true
	# PANELES ROJOS MANGA (como el inferno) DETRÁS del ganador: ciclan ultra-1..6 tintados
	# de rojo durante la celebración (el retrato y el peleador van por encima, z mayor).
	ko_lines.modulate = Color(1.7, 0.28, 0.28, 0.0)
	ko_lines.visible = true
	ko_red.color.a = 0.0
	_show_announce(win_name + " WINS", Color(0.88, 0.75, 0.28), 3.3, wside)
	var ws := Time.get_ticks_msec()
	while Time.get_ticks_msec() - ws < 340:
		var wp := float(Time.get_ticks_msec() - ws) / 340.0
		win_portrait.position.x = lerpf(woff_x, wrest_x, _ease_out_cubic(wp))
		win_portrait.modulate.a = wp
		if ultra_panels.size() > 0:
			ko_lines.texture = ultra_panels[int(wp * 16.0) % ultra_panels.size()]
		ko_lines.modulate.a = 0.9 * wp
		await get_tree().process_frame
	win_portrait.position.x = wrest_x
	win_portrait.modulate.a = 1.0
	# HOLD: retrato fijo + líneas manga vibrando (ciclando) 2.55s
	var wh := Time.get_ticks_msec()
	while Time.get_ticks_msec() - wh < 2550:
		if ultra_panels.size() > 0:
			ko_lines.texture = ultra_panels[int(float(Time.get_ticks_msec() - wh) / 62.0) % ultra_panels.size()]
		ko_lines.modulate.a = 0.9
		await get_tree().process_frame
	var wf := Time.get_ticks_msec()
	while Time.get_ticks_msec() - wf < 430:
		var wk := 1.0 - float(Time.get_ticks_msec() - wf) / 430.0
		win_portrait.modulate.a = wk
		ko_lines.modulate.a = 0.9 * wk
		if ultra_panels.size() > 0:
			ko_lines.texture = ultra_panels[int(float(Time.get_ticks_msec() - wf) / 62.0) % ultra_panels.size()]
		await get_tree().process_frame
	win_portrait.modulate.a = 0.0
	win_portrait.visible = false
	ko_lines.visible = false
	ko_lines.modulate.a = 0.0
	if wins_p1 >= WINS_NEEDED or wins_p2 >= WINS_NEEDED:
		var winner_name := String(Sel.data(selected_char if player_won else cpu_char)["name"])
		announce.visible = true
		announce.text = "MATCH WINNER:\n" + winner_name
		await get_tree().create_timer(3.0).timeout
		wins_p1 = 0
		wins_p2 = 0
		round_num = 1
		# fin del combate: vuelve a la PANTALLA PRINCIPAL (escena separada)
		if Sel.configured:
			Sel.configured = false
			get_tree().change_scene_to_file("res://title.tscn")
			return
	else:
		round_num += 1
	_start_round()
