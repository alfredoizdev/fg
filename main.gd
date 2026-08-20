extends Node2D

# Arbitro del combate: rondas, vida, hitboxes y anuncios.

# límites del mundo donde caminan los peleadores. VAR (no const): el stage con SCROLL
# (santuario) los ensancha para que se pueda caminar por el mundo ancho.
var LEFT_LIMIT := 115.0
var RIGHT_LIMIT := 1805.0
# --- STAGE con SCROLL + PARALLAX (santuario) ---
var game_cam: Camera2D = null       # cámara que sigue a los peleadores (solo stage con scroll)
var scroll_stage := false           # ¿el stage actual tiene scroll?
var _screen_off := Vector2.ZERO     # esquina sup-izq de la vista (para pegar overlays a la pantalla)
const SCROLL_WORLD_W := 2720.0      # ancho del mundo del stage con scroll (la pantalla ve 1920)
const MAX_HP := 100   # (legado; la vida real es por personaje según arquetipo)
# vida por ARQUETIPO (puede variar por personaje)
# TRIÁNGULO de arquetipos: warrior=TANK (aguanta y pega fuerte, pero lento + super armor),
# assassin=RUSHDOWN (glass cannon: rápida y combea, poca vida), wizard=ZONER (medio).
const ARCH_HP := {"assassin": 1050, "wizard": 1150, "warrior": 1500}
var hp_max := [1200, 1200]   # vida máxima por lado [P1, P2], se setea de cada peleador
const HIT_MARGIN := 59.0     # tolerancia extra de alcance
const AIR_REACH_H := 302.0   # altura maxima a la que un golpe aereo alcanza a un rival en el piso
const WINS_NEEDED := 2       # rondas para ganar el combate
const BODY_SEP := 225.0      # distancia de COREOGRAFIA (blink, colocado del inferno: con 190 la victima quedaba solapada)
# (el empuje al CAMINAR ya no usa una constante: suma los body_halfw de la pareja — ver _char_data)
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

# ============ ORBES DE AYE-2 (mecánica firma: boomerang / plantar / recall) ============
# fx_floral == aye2. El árbitro posee 3 sprites de orbe por Aye y los actualiza cada frame.
# Ver docs/superpowers/specs/2026-08-20-aye-orb-system-design.md
enum { ORB_YELLOW, ORB_PINK, ORB_BLUE }                                          # índice de color
const ORB_TINT := [Color(1.0, 0.85, 0.25), Color(1.0, 0.45, 0.72), Color(0.4, 0.62, 1.0)]  # 🟡🩷🔵
enum { OST_ORBIT, OST_FLIGHT, OST_PLANT_OUT, OST_PLANTED, OST_RECALL }           # estado del orbe
enum { OMODE_BOOMERANG, OMODE_PLANT }                                            # modo de un lanzamiento
const ORB_ORBIT_R := 90.0            # radio de la órbita alrededor de Aye
const ORB_SPEED := 1400.0            # velocidad de viaje (ida/recall)
const ORB_RANGE := 1050.0            # boomerang: alcance máx si no toca
const PLANT_DIST := 860.0            # plantar: distancia fija de aterrizaje
const PLANT_TIMEOUT := 8.0           # vida de un plantado antes de auto-volver
const RECALL_HOLD := 0.25            # mantener R para llamar los 3 (vs tap = 1)
const ORB_DMG_YELLOW := 100          # daño del 🟡
const PLANT_CHIP := 18               # golpe de IDA al plantar (sin efecto)
const ORB_DMG_BLUE := 45             # daño del 🔵
const ORB_FREEZE_T := 0.8            # congelado del 🩷
const MANA_PER_BLUE := 0.12          # maná que suma el 🔵 al golpear
const ORB_SCALE := 0.15              # arte 512px -> ~77px
var orb_sets := []                   # un set por fighter fx_floral (ver _orb_setup_for)
var mana_hud := [null, null]         # contenedor Node2D del anillo por lado (toggle visibilidad)
var mana_ring_fill := [null, null]   # arco morado que se vacia (Line2D)
var mana_ring_glow := [null, null]   # HALO neón detrás del arco (Line2D ancho translúcido -> bloom)
var zetma_orb_frames: SpriteFrames = null   # ESPECIAL de Zetma: frames de la orb morada
var void_orb_shader: Shader = null   # SHADER procedural del orbe VOID (reemplaza los PNG)
var void_orb_tex: Texture2D = null   # textura blanca base sobre la que corre el shader
var void_dome_shader: Shader = null  # SHADER de la CÚPULA void que enjaula al rival
var void_portal_shader: Shader = null  # SHADER del AGUJERO NEGRO elíptico de ROUM (warp_grab)
var orb_mote_tex: Texture2D = null   # textura REDONDA suave para los motes de energía (no cuadrados)
var orb_charge := [0.0, 0.0]   # carga del especial por lado (solo Zetma); 1.0 = listo
var orb_used := [false, false] # ya usado este round (1 vez por round)
var orb_side := [false, false] # este lado es ZETMA (muestra el anillo de carga del orb)
const ORB_CHARGE_TIME := 18.0    # 1ª carga
const ORB_RECHARGE_TIME := 42.0  # tras usarlo: recarga MUY lenta
# VOID de ROUM: 4ª fuente del anillo de recurso (mismo slot que maná/rabia/orbe). Se llena
# PELEANDO (daño HECHO al rival, no recibido) y se GASTA en portales/cintas (warp/ground grab).
var void_charge := [0.0, 0.0]    # carga VOID por lado (0..1); 1.0 = anillo lleno
var void_side := [false, false]  # este lado es ROUM (muestra el anillo con estética de agujero negro)
var void_prev_foe_hp := [-1, -1] # hp del RIVAL el frame anterior (para sumar void por daño hecho; -1 = sin iniciar)
const VOID_FULL_DEALT := 0.40    # se llena tras HACER este % de la vida máx del rival (un buen combo)
const VOID_REGEN := 0.020        # chorrito pasivo mínimo por segundo (nunca queda del todo trabado)
var mana_avatar := [null, null]      # retrato del mago dentro del anillo (Sprite2D)
var mana_ring_bg := [null, null]     # anillo de fondo (Line2D) — se recompone con compensacion de aspecto
var mana_ring_frame := [null, null]  # marco negro (Line2D)
var mana_disc := [null, null]        # disco de fondo (Polygon2D)
const MANA_REGEN := 0.030            # recarga pasiva por segundo (~33s de vacio a lleno; MUY lento a proposito)
const MANA_REGEN_IDLE := 0.018       # bonus si esta quieta en el suelo (recupera un poco mas rapido)
const MANA_CHANNEL_REGEN := 0.25     # canaleo activo (doble-tap abajo): ~4s a full (rapido, vulnerable)
const MANA_R := 58.0                 # radio del anillo
const MANA_RING_W := 6.0             # grosor del anillo (más delgado y limpio)
const MANA_CY := 968.0               # centro Y (esquina de abajo)
const MANA_CX_L := 92.0              # centro X lado izquierdo (P1)
const MANA_CX_R := 1828.0            # centro X lado derecho (P2)
const MANA_AV_BOX := 104.0           # caja del retrato (circulo que llena el anillo)
# ---- RABIA de DAM (berserk): el anillo (mismo slot que el maná) se llena al PERDER vida.
# Lleno + E+R simultáneas -> castea el berserk (anim + onda expansiva) y la barra se DRENA
# mientras dura el modo: más rápido, pega más duro, oscuro con sombras rojas.
var rage := [0.0, 0.0]               # carga de rabia por lado (0..1)
var rage_on := [false, false]        # ¿berserk activo? (drenando)
var rage_side := [false, false]      # ¿ese lado es DAM? (se setea en _refresh_hud_chars)
var rage_prev_hp := [-1, -1]         # hp del frame anterior (detecta vida perdida; -1 = sin iniciar)
const RAGE_FULL_LOST := 0.60         # se llena tras perder este % de la vida máxima
const RAGE_DRAIN := 0.167            # drenaje por segundo en berserk (~6s de modo, pedido: más rápido)
var rage_dim: ColorRect = null       # velo oscuro de pantalla mientras hay un berserk activo
const RAGE_DMG := 1.35               # multiplicador de daño en berserk
const RAGE_NOVA_DMG := 70            # daño de la onda expansiva del casteo
var match_time := MATCH_TIME
var timer_label: Label
# marcadores "P1"/"P2" flotando sobre las cabezas al empezar el round (VS 2P)
var tag_p1: Label
var tag_p2: Label
var tag_t := 0.0
const TAG_TIME := 6.0
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
	# SEGUNDAS VENTANAS de golpes multi-hit: sin nivel propio caian a 0 y el 2o impacto
	# RESETEABA el combo a 1 ("quita doble pero cuenta uno" — torbellino de DAM, doble
	# patada de Fe). Mismo nivel que su golpe madre = el hit 2 SUMA.
	"spin_kick_2": 4, "kick_h2": 3, "jump_kick_h2": 3, "air_jab": 1, "air_jab_2": 1,
	"air_spin_kick_2": 4,   # ZETMA: 2º golpe de su doble patada aérea
	"weak_punch_2": 1, "weak_punch_3": 1,   # patadas POGO de DAM (R): 3 hits que cuentan
	"crouch_jab_2": 1,   # giro de hoja del ↓R de DAM (2o golpe de la estocada)
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
var combo_plate := []   # (OBSOLETO) placa vieja; el estilo nuevo usa banda + labels
var combo_digits := []  # (OBSOLETO) dígitos-imagen viejos
var combo_num_lbl := [] # NÚMERO grande del combo (estilo READY/FIGHT) por lado
var combo_hit_lbl := [] # palabra "HIT / HITS" por lado
var combo_band := []    # mini banda roja inclinada detrás del número, por lado
var combo_nom := []     # nombre FORZADO del ultra (APOCALYPSE...); el rango va en la placa
var combo_font: SystemFont   # fuente heavy del contador
var combo_plate_tex := {}    # rango -> Texture2D de la placa
var combo_digit_tex := []    # 0-9 -> Texture2D del dígito
const COMBO_PLATE_BY_RANK := {"DOUBLE!": "double", "TRIPLE!": "triple", "GREAT!": "great",
	"MASTER!": "master", "AWESOME!": "awesome", "LEGENDARY!!": "legendary"}
var combo_rest_x := [270.0, 1650.0]   # x de reposo del cartel (izq / der)
var combo_show_ms := [-100000, -100000]  # reloj REAL del inicio de la entrada deslizada
var combo_was_vis := [false, false]   # para detectar cuando aparece (y disparar el slide)

# menu de modo de rival
var dummy_ai_mode := true
var versus_2p := false          # VS 2P LOCAL: el dummy es un humano con teclas propias (_p2)
var break_practice := false     # modo BREAK PRACTICE: la IA encadena combos y tú rompes
var menu_panel: ColorRect
var moves_panel: ColorRect
var moves_frame: Control  # marco morado con glow (estilo SF6)
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
	{"id": "zetma", "name": "ZETMA", "arch": "assassin", "avatar": "res://imagen-action/zetma/sheets/zetma-face.png", "frames": "res://fighter_frames.tres", "scale": 1.0},
	{"id": "roum", "name": "ROUM", "arch": "warrior", "avatar": "res://imagen-action/roum/sheets/roum-face.png", "frames": "res://fighter_frames.tres", "scale": 1.3},
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
var orb_screen: ColorRect              # tinte MORADO OSCURO de pantalla mientras dura la esfera de Zetma
var ultra_panel: TextureRect          # paneles manga a pantalla completa durante el ultra
var ultra_panels: Array = []          # texturas ultra-1..6 (líneas de acción)
var break_t := 0.0
var flash_t := 0.0
var code_stage: Node2D = null  # escenario activo (para el tinte de combo)
var ultra_active := false       # ULTRA COMBO en curso (auto-ejecutado)
var ultra_largo := false        # version larga (APOCALIPSIS): dos tandas + cambio de lado
var _void_ko := false           # true = el perdedor ya se fue por el VOID LAUNCH de Zetma (no revivir su K.O.)
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
# BANNERS de inicio de ronda (imágenes GET READY / FIGHT, croma recortado). Entran con
# GOLPE: zoom enorme -> se cierran de golpe con rebote + sacudida de pantalla.
const RB_READY := "res://imagen-action/ui/get-ready-cut.png"
const RB_FIGHT := "res://imagen-action/ui/Fight-cut.png"
const RB_COUNTER := "res://imagen-action/ui/counter-cut.png"
var round_banner: TextureRect = null
var rb_ready_tex: Texture2D
var rb_fight_tex: Texture2D
var rb_counter_tex: Texture2D
var rb_ms := -100000
var rb_dur := 0.0
var rb_impact_done := false
const RB_CENTER := Vector2(960.0, 402.0)   # centro en pantalla
const RB_BOX := Vector2(1200.0, 720.0)     # caja donde encaja la imagen (mantiene proporción)
# --- BANDA ROJA animada READY / FIGHT (reemplaza las imágenes): una franja roja apagada que
# se abre de extremo a extremo desde el centro, aparece la palabra, se cierra, luego la siguiente.
var rb_band: ColorRect = null
var rb_text: Label = null
var rb_border_top: ColorRect = null      # franja VERDE (borde superior) con la palabra repetida en negro
var rb_border_bot: ColorRect = null      # franja VERDE (borde inferior)
var rb_border_top_lbl: Label = null
var rb_border_bot_lbl: Label = null
var rb_band_ms := -100000
var rb_band_dur := 0.0
const RB_BAND_H := 460.0                  # banda MÁS GRANDE (antes 372)
const RB_BAND_CY := 430.0
const RB_BAND_ROT := -0.055   # inclinación de la banda (radianes) — no recta, un poco enclinada
const RB_BORDER_H := 50.0                             # alto de las franjas verdes (bordes con texto repetido)
const RB_BAND_COL := Color(0.34, 0.14, 0.60, 0.96)   # MORADO del juego (violeta SF6, base oscura)
const RB_BORDER_COL := Color(0.55, 0.85, 0.16, 1.0)  # VERDE del juego (bordes)
var danger_round_shown := false          # DANGER: 1 sola vez por round (el primer player que caiga a ≤25%)
var _ultra_banner_name := ""             # nombre del ultra en curso (se muestra en la banda al terminar)
var _ultra_active_prev := false          # flanco true→false de ultra_active para disparar la banda del nombre
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
var pause_desc_lbl: Label          # línea de descripción de la opción (estilo SF6)
var pause_caret: Label             # ▼ bajo la pestaña activa (chrome SF6)
var pause_items: Array = []        # labels de las opciones
var pause_plates: Array = []       # barras de resalte (Panel) de cada opción
var pause_accent := Color(1.7, 0.35, 0.22)   # color del personaje (rojo DAM / azul Fe)
var pause_sel := 0
var pause_owner := 0               # quién ABRIÓ la pausa: 0 = P1 (ESC) · 1 = P2 (START del mando)
var pause_in_combos := false       # true = viendo la sublista de COMBOS
# --- PRACTICE (dentro de la pausa): toggles de comportamiento del DUMMY ---
var pause_in_practice := false     # true = viendo el sub-panel PRACTICE
var practice_panel: Control        # panel del sub-menú practice
var practice_items: Array = []     # labels de NOMBRE de las opciones
var practice_state_lbls: Array = []  # labels de ESTADO (ON/OFF) por opción
var practice_plates: Array = []    # barras de resalte por opción
var practice_sel := 0
var dummy_jump_practice := false   # el dummy salta cada ~1s
var dummy_lowhp_practice := false  # la vida del dummy queda CLAVADA en 25% (para practicar el ultra)
var dummy_jump_t := 0.0            # reloj del salto automático
# --- MODAL de CHOOSE STAGE (dentro de la pausa) ---
var pause_in_stage := false        # true = viendo el selector de stage
var pause_glass: Panel = null      # panel del menú de pausa (se oculta al abrir el modal de stage)
var stage_modal: Control = null
var stage_modal_sel := 0
var stage_modal_tex := []          # thumbnails por stage
var stage_modal_flash := 0.0       # blink morado al confirmar (1->0)
var stage_modal_flash_ms := 0      # reloj REAL del blink (time_scale=0 en pausa)
var stage_modal_swap_code := -1    # stage a cargar tras el blink
var pause_prev_state := "fight"    # estado al que se vuelve al reanudar
var pause_combos: Control          # subpanel con la lista de movimientos
var pause_combos_char := ""        # personaje MOSTRADO en el panel (← → alterna P1/P2)
var pause_combos_title: Label
var pause_combos_moves: Label
var pause_combos_fin: Label
var pause_combos_border: Array = []
var pause_combos_avatar: TextureRect   # retrato del personaje que juegas (top-left del panel)
var pause_combos_avframe: ColorRect    # marco de acento del retrato
# --- CAMBIAR PERSONAJE en medio del training (overlay desde la pausa) ---
var charswap_root: Control
var charswap_fx: Control
var charswap_cards := []       # [{av, rect}] por personaje
var charswap_sel := 0
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
	# SELLO DE BUILD en el titulo de la ventana: si el titulo NO coincide con el que
	# Claude anuncio, la ventana corre codigo VIEJO (relanzar con jugar.command)
	get_window().title = "FG Fighter — build 2026-08-20 IR"
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
	# SONIDO DE COMBO: hit-sound-combo (elegido por el usuario) — sube de tono por la escala
	# pentatónica con cada golpe encadenado (via pitch_scale en cada hit del combo).
	if ResourceLoader.exists("res://imagen-action/impact-effect/hit-sound-combo.mp3"):
		ding_stream = load("res://imagen-action/impact-effect/hit-sound-combo.mp3")
	elif ResourceLoader.exists("res://imagen-action/sound-effect/guitar-hit.wav"):
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
	# arte del contador de combo (placas por rango + dígitos rojos, ui/combo)
	for d in 10:
		combo_digit_tex.append(load("res://imagen-action/ui/combo/digit-%d.png" % d))
	for k in ["double", "triple", "great", "master", "awesome", "legendary"]:
		combo_plate_tex[k] = load("res://imagen-action/ui/combo/plate-%s.png" % k)
	for i in 2:
		var c := Node2D.new()
		c.position = Vector2(320, 320) if i == 0 else Vector2(1600, 320)
		c.rotation = RB_BAND_ROT       # inclinado igual que la banda READY/FIGHT
		c.visible = false
		$UI.add_child(c)
		# (SIN panel rojo detrás del número — pedido del usuario)
		var bnd := Polygon2D.new()
		bnd.visible = false
		c.add_child(bnd)
		combo_band.append(bnd)
		# NÚMERO grande del combo (blanco, contorno rojo oscuro) — como el texto de READY/FIGHT
		var num := Label.new()
		num.add_theme_font_override("font", combo_font)
		num.add_theme_font_size_override("font_size", 132)
		num.add_theme_constant_override("outline_size", 16)
		num.add_theme_color_override("font_outline_color", Color(0.14, 0.0, 0.02))
		num.add_theme_color_override("font_color", Color(1, 1, 1))
		num.size = Vector2(360, 150); num.position = Vector2(-180, -108)
		num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		num.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(num)
		combo_num_lbl.append(num)
		# palabra "HIT" (más chica, debajo)
		var hl := Label.new()
		hl.add_theme_font_override("font", combo_font)
		hl.add_theme_font_size_override("font_size", 46)
		hl.add_theme_constant_override("outline_size", 8)
		hl.add_theme_color_override("font_outline_color", Color(0.14, 0.0, 0.02))
		hl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.55))
		hl.size = Vector2(360, 48); hl.position = Vector2(-180, 44)
		hl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(hl)
		combo_hit_lbl.append(hl)
		# nombre FORZADO del ultra (APOCALYPSE...): solo se ve en el remate; el rango
		# normal ya viene pintado en la placa
		var nm := Label.new()
		nm.add_theme_font_override("font", combo_font)
		nm.add_theme_font_size_override("font_size", 42)
		nm.add_theme_color_override("font_color",
				Color(1.0, 0.9, 0.35) if i == 0 else Color(1.0, 0.55, 0.4))
		nm.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.5))
		nm.add_theme_constant_override("outline_size", 6)
		nm.position = Vector2(-186, 148)
		nm.size = Vector2(372, 58)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		nm.visible = false
		c.add_child(nm)
		# daño total del combo: PEGADO bajo la placa y en letras GORDAS (Arial Black)
		var dl := Label.new()
		dl.add_theme_font_override("font", combo_font)
		dl.add_theme_font_size_override("font_size", 32)
		dl.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
		dl.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
		dl.add_theme_constant_override("outline_size", 12)
		dl.position = Vector2(-186, 100)
		dl.size = Vector2(372, 40)
		dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		c.add_child(dl)
		combo_ui.append(c)
		combo_nom.append(nm)
		combo_dmg_lbl.append(dl)
	# fogonazo de pantalla del BREAK (encima de todo, invisible en reposo)
	flash_rect = ColorRect.new()
	flash_rect.size = Vector2(1920, 1080)
	flash_rect.color = Color(1, 1, 1, 0.0)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.z_index = -1   # el fogonazo tinta el MUNDO pero NUNCA tapa el HUD (vida/barras visibles, pedido)
	$UI.add_child(flash_rect)
	# TINTE MORADO OSCURO de pantalla mientras el rival está atrapado en la esfera de Zetma
	# (como flash_rect: en $UI a z=-1 → tiñe el MUNDO/peleadores pero NO tapa el HUD)
	orb_screen = ColorRect.new()
	orb_screen.size = Vector2(1920, 1080)
	orb_screen.color = Color(0.12, 0.02, 0.24, 0.0)
	orb_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	orb_screen.z_index = -1
	$UI.add_child(orb_screen)
	# paneles manga (líneas de acción) a pantalla completa durante el ULTRA:
	# van SOBRE los peleadores pero DEBAJO del contador de combo (se agregan antes)
	ultra_panel = TextureRect.new()
	ultra_panel.size = Vector2(1920, 1080)
	ultra_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ultra_panel.stretch_mode = TextureRect.STRETCH_SCALE
	ultra_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ultra_panel.z_index = -1   # las lineas manga tampoco tapan el HUD
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
	_setup_stage()
	_build_cutin()      # cut-in del INFIERNO: detrás de la acción, delante del escenario
	_build_announce()   # anuncios + KO + retrato del ganador: DETRÁS de los peleadores
	_build_round_banner()   # banners GET READY / FIGHT (imágenes): DETRÁS de los peleadores, con golpe
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
	# panel de MOVE LIST del TRAINER: centrado, grande y con clip para que el texto NO
	# pueda salirse (las columnas usan autowrap para partir las líneas largas).
	var mv_w := 1520.0
	var mv_h := 968.0
	var mv_mid := mv_w * 0.5 + 20.0    # separador vertical
	var vp := ColorRect.new()
	vp.color = Color(0.10, 0.055, 0.19, 0.96)   # morado oscuro (paleta del logo)
	vp.position = Vector2((1920.0 - mv_w) * 0.5, (1080.0 - mv_h) * 0.5)
	vp.size = Vector2(mv_w, mv_h)
	vp.clip_contents = true
	vp.visible = false
	$UI.add_child(vp)
	moves_panel = vp
	# MARCO morado con borde FINO (dibujado en _draw_moves_frame, lee el tamaño del nodo)
	moves_frame = Control.new()
	moves_frame.position = Vector2.ZERO; moves_frame.size = Vector2(mv_w, mv_h)
	moves_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vp.add_child(moves_frame)
	moves_frame.draw.connect(_draw_moves_frame)
	var vt := Label.new()
	vt.text = "DAM — MOVE LIST"
	vt.add_theme_font_size_override("font_size", 46)
	vt.position = Vector2(0, 28)
	vt.size = Vector2(mv_w, 60)
	vt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vp.add_child(vt)
	moves_title = vt
	# AVATAR del personaje (top-left) con marco de acento
	var mvfr := ColorRect.new()
	mvfr.position = Vector2(39, 19); mvfr.size = Vector2(102, 102)
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
	# lista de MOVES (columna izquierda). El texto por-personaje ya trae el encabezado "MOVES:".
	var col1 := Label.new()
	col1.add_theme_font_size_override("font_size", 21)   # más chico para que entren todas las líneas
	col1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col1.position = Vector2(70, 160)
	col1.size = Vector2(mv_mid - 70.0 - 30.0, mv_h - 160.0 - 80.0)
	col1.text = "MOVES:\n\nR  —  Quick jab (4)\n↓ + R  —  Low jab (4)"
	vp.add_child(col1)
	moves_col1 = col1
	# divisiones: linea bajo el titulo, columna central y pie
	for dv in [[70.0, 118.0, mv_w - 140.0, 3.0], [mv_mid, 150.0, 3.0, mv_h - 258.0], [70.0, mv_h - 96.0, mv_w - 140.0, 3.0]]:
		var linea := ColorRect.new()
		linea.position = Vector2(dv[0], dv[1])
		linea.size = Vector2(dv[2], dv[3])
		linea.color = Color(0.62, 0.42, 1.0, 0.5)
		vp.add_child(linea)
	# bloque SPECIALS & FINISHERS (columna derecha completa)
	var fin := Label.new()
	fin.add_theme_font_size_override("font_size", 21)   # más chico para que entren todas las líneas
	fin.add_theme_color_override("font_color", Color(0.82, 0.66, 1.0))
	fin.add_theme_color_override("font_outline_color", Color(0.10, 0.02, 0.20))
	fin.add_theme_constant_override("outline_size", 4)
	fin.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fin.position = Vector2(mv_mid + 34.0, 160)
	fin.size = Vector2(mv_w - (mv_mid + 34.0) - 40.0, mv_h - 160.0 - 80.0)
	fin.text = "★  SPECIALS  &  FINISHERS\n↑ + E  —  Combo Breaker (while hit, 1/round)\n↓ ↓ + E  —  INFERNO · his power\n        (after a 7-hit combo · 50 dmg)\n→ R  —  ANNIHILATION · short ultra (16 hits)\n→ E  —  APOCALYPSE · long ultra (31 hits)\n        ultras: 3-hit combo + rival ≤ 25% HP"
	vp.add_child(fin)
	moves_fin = fin
	var vb := Label.new()
	vb.text = "ESC  back"
	vb.add_theme_font_size_override("font_size", 26)
	vb.add_theme_color_override("font_color", Color(0.78, 0.6, 1.0))
	vb.position = Vector2(0, mv_h - 52.0)
	vb.size = Vector2(mv_w, 40)
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
	_build_charswap()       # overlay para cambiar de personaje en medio del training
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
			"vs_2p":
				# 2 JUGADORES LOCALES: sin IA; el dummy lee las acciones "_p2" (IJKL + 7890)
				dummy_ai_mode = false; break_practice = false
				versus_2p = true
				dummy.human_2p = true
				dummy.input_suffix = "_p2"
				player.debug_keys = false   # teclas de prueba fuera: chocan con las de P2
				dummy.debug_keys = false
			_:
				dummy_ai_mode = true; break_practice = false   # vs_cpu
		_start_round()
	else:
		# main.tscn ejecutado directo (sin pasar por el menú): fallback interno
		_open_menu()

# prende/apaga el control del jugador; en VS 2P el dummy (humano) va en espejo.
# (los ultras siguen tocando caster.input_enabled directo: eso es por-peleador y no pasa por aquí)
func _set_inputs(on: bool) -> void:
	player.input_enabled = on
	if versus_2p:
		dummy.input_enabled = on

func _open_menu() -> void:
	# PANTALLA PRINCIPAL (title): banner + VS CPU / TRAINER / VS ONLINE
	state = "title"
	break_practice = false
	dummy.ai_break_drill = false
	_set_inputs(false)
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
		fe_marks[i] = 0            # ronda nueva: sin marcas de Fe
		fe_mark_decay[i] = 0.0
	player.set_fe_marks(0)
	dummy.set_fe_marks(0)
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
	_set_inputs(true)

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
	_set_inputs(false)
	dummy.ai_enabled = false
	# --- CINE del COUNTER (como el ULTRA): todo va DETRÁS de los peleadores (z=-1) para que
	# los personajes Y el texto SOBRESALGAN por encima del OSCURO. Nada de velo amarillo encima. ---
	break_side = 1 if quien.position.x >= 960.0 else -1
	_show_round_banner("counter", 1.4)                   # imagen COUNTER con golpe (detrás de los peleadores)
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
		_dmg_number(atacante, d)
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
		_set_inputs(true)
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
			"moves": "MOVES:\n\nR  —  Quick needle jab\n↓ + R  —  WHITE TIGER · 1.5 bars (drags · 4 hits)\nQ  —  High spin kick\nW  —  Double kick · high launches ▲\n↓ + Q  —  Crouch scissor\n↓ + W  —  Rising needles ▲\nE  —  Needle top-spin · 2 hits\n↓ + E  —  Ground sweep ▼\n←→ + Q  —  NEEDLE DASH · 3 hits\n↓→ + Q  —  THUNDER strike (close)\n↓→ + W  —  THUNDER strike (far)\nJump + Q  —  Air scissor\nJump + W  —  Needle dive\nJump + E  —  Flying kick ▲\nJump + R  —  Double air kick\n\n▲ = launches into the air     ▼ = knocks down",
			"fin": "★  SPECIALS  &  FINISHERS  (meter: ↑E=2 · ↓←E=1)\n↑ + E  —  Combo Breaker (while hit) · or ANNIHILATION ultra\n        (2 bars + 3-hit combo + rival ≤25% HP)\n↓ → + R  —  APOCALYPSE · long ultra (3 bars + combo + rival ≤25% HP)\n↓ ↘ → + Q/W/E  —  THUNDER · 1/2/3 bodies · ½ bar\n← → + Q  —  NEEDLE DASH · rush, 3-hit combo\n↓ ← + E  —  WHIRLPOOL · 1 bar + combo (deadly spin ~40% HP)\nJump →  —  forward flip   ·   Jump + R  —  air double kick\n\nPARRY (Q + W together):  counter · 1 bar · breaks their combo",
		}
	if cid == "zetma":
		return {
			"title": "ZETMA — MOVE LIST",
			"moves": "MOVES:\n\nR  —  Twin dagger · thrust + kick (2)\n↓ + R  —  Low mechanical jab (2)\nQ  —  Straight punch\nW  —  Kick\n↓ + Q  —  Crouch punch\n↓ + W  —  Crouch kick\nE  —  EXTENDING ARM · long reach\n↓ + E  —  Ground sweep ▼\nJump + Q  —  Air punch\nJump + W  —  Air kick\nJump + E  —  Air double kick\nJump + R  —  Air dagger jab (2)\n\n▼ = knocks down",
			"fin": "★  SPECIALS  &  FINISHERS\n↓ → + Q  —  SCORPION HOOK · grab + pull\nJump ↓ → + Q  —  air hook (pull down)\n↓ ← + E  —  VOID ORB · slow-mo trap (1/round · charge ring)\n← → + E  —  COMBO BREAK · kicks out (while hit · ½ bar)\n↓ → + R  —  ANNIHILATION · short ultra\n↓ ← + W  —  APOCALYPSE · long ultra\n        (ultras: 3-hit combo + rival ≤ 25% HP)\n\nPARRY (Q + W together):  counter · 1 bar",
		}
	if cid == "roum":
		return {
			"title": "ROUM — MOVE LIST",
			"moves": "MOVES  (TANK · dark bandages):\n\nR  —  Two-hand SHOVE · slides them back (40)\n↓ + R  —  Low double poke (40+40)\nQ  —  Heavy punch (90)\nW  —  Big kick (100)\n↓ + Q  —  Crouch punch (85)\nE  —  HEADBUTT · lunge, launches (110) ▲\n→ → + Q  —  UPPERCUT · rising fist, launches (100) ▲\n↓ + E  —  Ground sweep · trips (80) ▼\nJump + Q  —  Air punch (85)\nJump + W  —  Air double kick (55+60)\nJump + E  —  Air spin kick · 2 hits (60+65)\nJump + R  —  Air double jab (40+45)\n\n▲ = launches into the air     ▼ = knocks down",
			"fin": "★  SPECIALS  &  SUPERS  (grappler)\n\n← → + Q  —  BLACK-BIND GRAB · hook & pull in (70) · free\n        (only ≤ 1.5 bodies · else falls to a punch)\n\n◕ VOID ring (crimson · fills by DEALING damage · PORTALS only):\n← → + R  —  WARP GRAB · portal swallows them, spits\n        them out in front (80) · ½ void · any range\n↓ ↓ + R  —  PIT GRAB · ANTI-AIR · slams bandages into a\n        pit, a portal above yanks an AIRBORNE foe down (85) · ½ void\n\n★ Green bar (supers):\n↓ + W  —  HEADBUTT NOVA · shockwave, launches ▲ (½ bar · 80)\n← ← → + W  —  VOID LASH · full-screen bandages, 6 hits,\n        shoves the rival to the screen edge (½ bar · 120)\n\n★  FINISHER:\n→ + Q  —  ANNIHILATION · short ultra · ground pummel\n        (2 bars + 2-hit combo + rival ≤ 25% HP)\n\n★  PORTAL ULTRA:\nHOLD R ~½s then RELEASE  —  VOID GRASP · a long portal\n        beatdown that ends in a void slam (2 bars + 2-hit combo · any HP)\n\nPARRY (Q + W together):  counter · 1 bar · breaks their combo",
		}
	return {
		"title": "DAM — MOVE LIST",
		"moves": "MOVES:\n\nR  —  Quick jab (4)\n↓ + R  —  Low jab (4)\nQ  —  Horizontal slash (8)\n→ + Q  —  Double slash (8+6)\n↓ ↘ →  + Q  —  EMBER DASH (15) · ½ bar · wall slam\nW  —  Heavy slash (12)\n↓ + Q  —  Crouch slash (6)\n↓ + W  —  Rising launcher (9) ▲\nE  —  Traveling spin kick (13) ▲\n↓ + E  —  Ground sweep (12) ▼\nJump + Q  —  Air slash (9)\nJump + W  —  Dive kick (10)\nJump + E  —  Somersault kick (13) ▲\n\n▲ = launches into the air     ▼ = knocks down",
		"fin": "★  SPECIALS  &  FINISHERS\n↑ + E  —  Combo Breaker (while hit, 1/round)\n↓ ↓ + E  —  INFERNO · his power\n        (after a 7-hit combo · 50 dmg)\n→ R  —  ANNIHILATION · short ultra (16 hits)\n→ E  —  APOCALYPSE · long ultra (31 hits)\n        ultras: 3-hit combo + rival ≤ 25% HP\n\nPARRY (Q + W together):  counter · 1 bar · breaks their combo",
	}

# marco morado con glow del panel de movimientos (estilo SF6)
func _draw_moves_frame() -> void:
	var PUR := Color(0.62, 0.40, 1.0)
	var sz := moves_frame.size
	var r := Rect2(0, 0, sz.x, sz.y)
	# glow exterior MUY sutil (1 capa) + borde FINO de 1.5px
	moves_frame.draw_rect(r.grow(3.0), Color(PUR.r, PUR.g, PUR.b, 0.10), false, 1.5)
	moves_frame.draw_rect(r, PUR, false, 1.5)
	# esquinas: brackets finos que dan el toque SF6 sin engordar el marco
	var cs := 40.0
	var br := Color(0.85, 0.7, 1.0)
	for c in [[Vector2(0, 0), 1, 1], [Vector2(sz.x, 0), -1, 1], [Vector2(0, sz.y), 1, -1], [Vector2(sz.x, sz.y), -1, -1]]:
		var p: Vector2 = c[0]
		var sx: float = c[1]
		var sy: float = c[2]
		moves_frame.draw_line(p, p + Vector2(cs * sx, 0), br, 2.0)
		moves_frame.draw_line(p, p + Vector2(0, cs * sy), br, 2.0)

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
const PAUSE_LABELS := ["CONTINUE", "REMATCH", "CHOOSE STAGE", "COMBOS", "CHANGE CHARACTER", "PRACTICE", "QUIT TO MENU"]

# === MENÚ DE PAUSA estilo SF6: panel de cristal violeta centrado con borde en glow,
#     pestaña activa con caret ▼, filas centradas (la seleccionada resaltada en barra)
#     y una línea de descripción abajo. Mismo overlay para VS y para TRAINING. ===
const PAUSE_PANEL := Rect2(280, 160, 1360, 760)   # panel de cristal centrado
# descripción de cada opción (una frase, en la voz del menú)
const PAUSE_DESCS := [
	"Resume the fight right where you left off.",
	"Restart the match from round 1 on the same stage.",
	"Switch to the next stage and restart the match.",
	"Open the move list for your character.",
	"Swap your fighter without leaving the match.",
	"Dummy options: auto-jump and low-HP (25%) ultra practice.",
	"Return to the main menu. The current match ends.",
]

func _pause_glass_style(bg: Color, border: Color, radius: int, glow: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(2)
	sb.border_color = border
	if glow > 0.0:
		sb.shadow_color = Color(border.r, border.g, border.b, 0.40)
		sb.shadow_size = int(glow)
	sb.anti_aliasing = true
	return sb

func _build_pause() -> void:
	var root := Control.new()
	root.position = Vector2.ZERO
	root.size = Vector2(1920, 1080)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.z_index = 120                       # SOBRE todo (peleadores + HUD + combo)
	root.visible = false
	$UI.add_child(root)
	pause_root = root
	# velo oscuro sobre la pelea congelada (deja ver el escenario tenue detrás del cristal)
	var veil := ColorRect.new()
	veil.color = Color(0.02, 0.02, 0.06, 0.72)
	veil.position = Vector2.ZERO; veil.size = Vector2(1920, 1080)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(veil)
	# líneas de acción manga MUY tenues detrás del panel (se recolorean por personaje)
	var lines := TextureRect.new()
	lines.size = Vector2(1920, 1080)
	lines.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lines.stretch_mode = TextureRect.STRETCH_SCALE
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.modulate = Color(1.7, 0.35, 0.22, 0.06)
	if ultra_panels.size() > 0:
		lines.texture = ultra_panels[0]
	root.add_child(lines)
	pause_lines = lines
	# ---- PANEL de cristal violeta con borde en glow (firma visual SF6) ----
	var glass := Panel.new()
	glass.position = PAUSE_PANEL.position
	glass.size = PAUSE_PANEL.size
	glass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glass.add_theme_stylebox_override("panel",
		_pause_glass_style(Color(0.28, 0.13, 0.52, 0.82), Color(0.80, 0.52, 1.0, 0.95), 22, 18.0))
	root.add_child(glass)
	pause_glass = glass
	# brillo superior sutil (da sensación de cristal iluminado arriba)
	var sheen := Panel.new()
	sheen.position = Vector2(16, 14); sheen.size = Vector2(PAUSE_PANEL.size.x - 32, 150)
	sheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sheen.add_theme_stylebox_override("panel",
		_pause_glass_style(Color(0.55, 0.32, 0.85, 0.28), Color(0, 0, 0, 0), 18, 0.0))
	glass.add_child(sheen)
	# fila de puntos de página (chrome decorativo SF6, arriba del todo)
	var dots := Label.new()
	dots.add_theme_font_size_override("font_size", 20)
	dots.add_theme_color_override("font_color", Color(0.85, 0.7, 1.0, 0.7))
	dots.text = "•  •  ●  •  •"
	dots.position = Vector2(0, 20); dots.size = Vector2(PAUSE_PANEL.size.x, 26)
	dots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glass.add_child(dots)
	# ---- PESTAÑA ACTIVA (hace de título): "PAUSED" ----
	var ttl := Label.new()
	ttl.text = "PAUSED"
	ttl.add_theme_font_override("font", combo_font)
	ttl.add_theme_font_size_override("font_size", 56)
	ttl.add_theme_color_override("font_color", Color(0.98, 0.97, 1.0))
	ttl.add_theme_color_override("font_outline_color", Color(0.5, 0.2, 0.85))
	ttl.add_theme_constant_override("outline_size", 8)
	ttl.position = Vector2(0, 44); ttl.size = Vector2(PAUSE_PANEL.size.x, 70)
	ttl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ttl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glass.add_child(ttl)
	pause_title_lbl = ttl
	# caret ▼ bajo la pestaña activa
	var caret := Label.new()
	caret.text = "▼"
	caret.add_theme_font_size_override("font_size", 30)
	caret.add_theme_color_override("font_color", Color(0.82, 0.55, 1.0))
	caret.position = Vector2(0, 108); caret.size = Vector2(PAUSE_PANEL.size.x, 34)
	caret.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caret.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glass.add_child(caret)
	pause_caret = caret
	# separador bajo la barra de pestaña
	var topsep := ColorRect.new()
	topsep.position = Vector2(60, 150); topsep.size = Vector2(PAUSE_PANEL.size.x - 120, 2)
	topsep.color = Color(0.75, 0.55, 1.0, 0.35)
	topsep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glass.add_child(topsep)
	# subtítulo: personaje elegido — "AYE — ROUND PAUSED"
	var sub := Label.new()
	sub.add_theme_font_override("font", combo_font)
	sub.add_theme_font_size_override("font_size", 30)
	sub.add_theme_color_override("font_color", Color(1.7, 0.4, 0.24))
	sub.position = Vector2(0, 166); sub.size = Vector2(PAUSE_PANEL.size.x, 40)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glass.add_child(sub)
	pause_sub_lbl = sub
	# ---- FILAS de opciones (centradas; la seleccionada se resalta con barra) ----
	pause_items.clear()
	pause_plates.clear()
	var row_x := 80.0
	var row_w := PAUSE_PANEL.size.x - 160.0
	var row_h := 58.0
	var row_y0 := 210.0        # DEBAJO del subtítulo (166) para no solaparse
	var row_gap := 64.0        # 7 opciones: gap más chico para no chocar con la descripción (694)
	for i in PAUSE_LABELS.size():
		var ry := row_y0 + float(i) * row_gap
		# barra de resalte (visible solo en la fila seleccionada)
		var bar := Panel.new()
		bar.position = Vector2(row_x, ry)
		bar.size = Vector2(row_w, row_h)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_theme_stylebox_override("panel",
			_pause_glass_style(Color(1.0, 0.95, 1.0, 0.16), Color(0.9, 0.68, 1.0, 0.85), 12, 0.0))
		bar.visible = false
		glass.add_child(bar)
		pause_plates.append(bar)
		# texto de la opción
		var lab := Label.new()
		lab.add_theme_font_override("font", combo_font)
		lab.add_theme_font_size_override("font_size", 36)
		lab.add_theme_color_override("font_color", Color(0.72, 0.68, 0.82))
		lab.add_theme_color_override("font_outline_color", Color(0.05, 0.0, 0.12, 0.8))
		lab.add_theme_constant_override("outline_size", 4)
		lab.position = Vector2(row_x, ry)
		lab.size = Vector2(row_w, row_h)
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lab.text = PAUSE_LABELS[i]
		glass.add_child(lab)
		pause_items.append(lab)
	# ---- línea de descripción (abajo, dentro del panel) ----
	var desc := Label.new()
	desc.add_theme_font_size_override("font_size", 28)
	desc.add_theme_color_override("font_color", Color(0.86, 0.82, 0.94))
	desc.position = Vector2(60, PAUSE_PANEL.size.y - 66)
	desc.size = Vector2(PAUSE_PANEL.size.x - 120, 40)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glass.add_child(desc)
	pause_desc_lbl = desc
	# ---- ayuda de controles (fuera del panel, abajo) ----
	var hint := Label.new()
	hint.add_theme_font_size_override("font_size", 28)
	hint.add_theme_color_override("font_color", Color(0.85, 0.72, 1.0))
	hint.add_theme_constant_override("outline_size", 4)
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	hint.text = "↑ ↓  SELECT        Q / ENTER  CONFIRM        ESC  RESUME"
	hint.position = Vector2(0, PAUSE_PANEL.end.y + 14)
	hint.size = Vector2(1920, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	backdrop.color = Color(0.03, 0.02, 0.07, 0.96)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cp.add_child(backdrop)
	# PANEL de cristal violeta con borde en glow (mismo look SF6 que el menú de pausa).
	# clip_contents = true → NADA de texto puede escapar del cristal (ni por la derecha ni
	# por abajo); combinado con autowrap en las columnas evita los desbordes.
	const CB_W := 1520.0
	const CB_H := 968.0
	var panel := Panel.new()
	panel.position = Vector2((1920.0 - CB_W) * 0.5, (1080.0 - CB_H) * 0.5)
	panel.size = Vector2(CB_W, CB_H)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.clip_contents = true
	panel.add_theme_stylebox_override("panel",
		_pause_glass_style(Color(0.24, 0.11, 0.46, 0.94), Color(0.80, 0.52, 1.0, 0.95), 22, 18.0))
	cp.add_child(panel)
	pause_combos_border.clear()
	# brillo superior sutil (cristal iluminado arriba)
	var csheen := Panel.new()
	csheen.position = Vector2(16, 14); csheen.size = Vector2(CB_W - 32.0, 130)
	csheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	csheen.add_theme_stylebox_override("panel",
		_pause_glass_style(Color(0.55, 0.32, 0.85, 0.26), Color(0, 0, 0, 0), 18, 0.0))
	panel.add_child(csheen)
	var ct := Label.new()
	ct.add_theme_font_override("font", combo_font)
	ct.add_theme_font_size_override("font_size", 52)
	ct.add_theme_color_override("font_color", Color(1.7, 0.4, 0.24))
	ct.position = Vector2(0, 28); ct.size = Vector2(CB_W, 66)
	ct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(ct)
	pause_combos_title = ct
	# AVATAR del personaje (top-left) con marco de acento FINO + halo mínimo detrás
	var avglow := ColorRect.new()
	avglow.position = Vector2(38, 14); avglow.size = Vector2(116, 116)
	avglow.color = Color(1.7, 0.4, 0.24, 0.20)
	panel.add_child(avglow)
	pause_combos_border.append(avglow)
	var avfr := ColorRect.new()
	avfr.position = Vector2(42, 18); avfr.size = Vector2(112, 112)
	avfr.color = Color(1.7, 0.4, 0.24, 1.0)
	panel.add_child(avfr)
	pause_combos_avframe = avfr
	var av := TextureRect.new()
	av.position = Vector2(44, 20); av.size = Vector2(108, 108)
	av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	av.clip_contents = true
	av.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(av)
	pause_combos_avatar = av
	# separador bajo el título — ARRANCA DESPUÉS del avatar (ya no lo cruza) + morado
	var sep := ColorRect.new()
	sep.position = Vector2(190, 118); sep.size = Vector2(CB_W - 230.0, 3)
	sep.color = Color(0.62, 0.42, 1.0, 0.55)
	panel.add_child(sep)
	# columnas: izquierda MOVES / derecha SPECIALS. AUTOWRAP para que las líneas largas
	# (sobre todo las de la derecha) se partan en vez de salirse del panel.
	var col_top := 160.0
	var col_h := 740.0
	var mid_x := CB_W * 0.5 + 20.0    # separador vertical algo a la derecha del centro
	var cm := Label.new()
	cm.add_theme_font_size_override("font_size", 21)   # más chico para que entren todas las líneas
	cm.add_theme_color_override("font_color", Color(0.92, 0.92, 0.96))
	cm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cm.position = Vector2(70, col_top); cm.size = Vector2(mid_x - 70.0 - 30.0, col_h)
	panel.add_child(cm)
	pause_combos_moves = cm
	# separador vertical (morado fijo)
	var vsep := ColorRect.new()
	vsep.position = Vector2(mid_x, col_top - 10.0); vsep.size = Vector2(3, col_h + 20.0)
	vsep.color = Color(0.62, 0.42, 1.0, 0.45)
	panel.add_child(vsep)
	var cf := Label.new()
	cf.add_theme_font_size_override("font_size", 21)   # más chico para que entren todas las líneas
	cf.add_theme_color_override("font_color", Color(0.82, 0.66, 1.0))
	cf.add_theme_color_override("font_outline_color", Color(0.10, 0.02, 0.20))
	cf.add_theme_constant_override("outline_size", 4)
	cf.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cf.position = Vector2(mid_x + 34.0, col_top); cf.size = Vector2(CB_W - (mid_x + 34.0) - 40.0, col_h)
	panel.add_child(cf)
	pause_combos_fin = cf
	var cb := Label.new()
	cb.add_theme_font_size_override("font_size", 28)
	cb.add_theme_color_override("font_color", Color(0.78, 0.6, 1.0))
	cb.text = "ESC / W  —  back"
	cb.position = Vector2(0, CB_H - 52.0); cb.size = Vector2(CB_W, 40)
	cb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(cb)

func _open_pause(owner := 0) -> void:
	if state != "fight":
		return
	pause_owner = owner
	pause_prev_state = state
	state = "pause"
	pause_sel = 0
	pause_in_combos = false
	_set_inputs(false)
	dummy.ai_enabled = false
	# color y nombre del personaje DEL QUE PAUSÓ (P1 o P2); el panel COMBOS abre con el suyo
	var pchar := selected_char if owner == 0 else cpu_char
	pause_combos_char = pchar
	pause_accent = _char_accent(pchar)
	var cname := "DAM"                       # nombre REAL del personaje (antes zetma caía en DAM)
	for c in CHARS:
		if String(c["id"]) == pchar:
			cname = String(c["name"]); break
	pause_sub_lbl.text = cname + "   —   ROUND PAUSED"
	pause_sub_lbl.add_theme_color_override("font_color", pause_accent)
	pause_title_lbl.add_theme_color_override("font_outline_color", pause_accent)
	pause_hint_lbl.add_theme_color_override("font_color", pause_accent.lerp(Color(1, 1, 1), 0.45))
	# la ayuda de controles habla el idioma del DUEÑO de la pausa (mando o teclado)
	if pause_owner == 1:
		pause_hint_lbl.text = "✚  SELECT        A / Y  CONFIRM        START  RESUME"
	else:
		pause_hint_lbl.text = "↑ ↓  SELECT        Q / ENTER  CONFIRM        ESC  RESUME"
	if pause_caret != null:
		pause_caret.add_theme_color_override("font_color", pause_accent.lerp(Color(1, 1, 1), 0.35))
	pause_lines.modulate = Color(pause_accent.r, pause_accent.g, pause_accent.b, 0.06)
	pause_combos_title.add_theme_color_override("font_color", pause_accent)
	for b in pause_combos_border:
		(b as ColorRect).color = Color(pause_accent.r, pause_accent.g, pause_accent.b, 0.6)
	pause_combos.visible = false
	pause_root.visible = true
	_pause_refresh()
	Engine.time_scale = 0.0                  # CONGELA la pelea (el menú anima en tiempo real)

func _pause_refresh() -> void:
	for i in pause_items.size():
		var selq := i == pause_sel
		var lab := pause_items[i] as Label
		var plate := pause_plates[i] as Panel
		lab.text = String(PAUSE_LABELS[i])
		lab.add_theme_color_override("font_color", Color(1, 1, 1) if selq else Color(0.72, 0.68, 0.82))
		plate.visible = selq
		plate.self_modulate = Color(1, 1, 1, 1)
	if pause_desc_lbl != null and pause_sel < PAUSE_DESCS.size():
		pause_desc_lbl.text = String(PAUSE_DESCS[pause_sel])

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
		# arranca con el personaje visto la última vez (o el de P1); ← → alterna P1/P2
		_pause_fill_combos(pause_combos_char if pause_combos_char != "" else selected_char)
	pause_combos.visible = show

# ===== PRACTICE (sub-panel de pausa): toggles del comportamiento del DUMMY =====
const PRAC_NAMES := ["DUMMY JUMP", "ULTRA PRACTICE"]
const PRAC_DESCS := ["The dummy jumps every ~1 second.", "Dummy HP locked at 25% (red) to practice your ultra."]
func _build_practice_panel() -> void:
	# MISMO patrón que el subpanel de combos: Control full-screen + backdrop OPACO (tapa la lista
	# de pausa por completo) + cristal violeta centrado estilo SF6.
	var cp := Control.new()
	cp.position = Vector2.ZERO; cp.size = Vector2(1920, 1080)
	cp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cp.visible = false
	pause_root.add_child(cp)
	practice_panel = cp
	var backdrop := ColorRect.new()
	backdrop.position = Vector2.ZERO; backdrop.size = Vector2(1920, 1080)
	backdrop.color = Color(0.03, 0.02, 0.07, 0.96)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cp.add_child(backdrop)
	const PW := 1040.0
	const PH := 620.0
	var panel := Panel.new()
	panel.position = Vector2((1920.0 - PW) * 0.5, (1080.0 - PH) * 0.5)
	panel.size = Vector2(PW, PH)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel",
		_pause_glass_style(Color(0.24, 0.11, 0.46, 0.96), Color(0.80, 0.52, 1.0, 0.95), 22, 18.0))
	cp.add_child(panel)
	var sheen := Panel.new()
	sheen.position = Vector2(16, 14); sheen.size = Vector2(PW - 32.0, 120)
	sheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sheen.add_theme_stylebox_override("panel",
		_pause_glass_style(Color(0.55, 0.32, 0.85, 0.26), Color(0, 0, 0, 0), 18, 0.0))
	panel.add_child(sheen)
	var ttl := Label.new()
	ttl.add_theme_font_override("font", combo_font)
	ttl.text = "PRACTICE"
	ttl.add_theme_font_size_override("font_size", 54)
	ttl.add_theme_color_override("font_color", Color(1.9, 1.55, 0.4))
	ttl.add_theme_color_override("font_outline_color", Color(0.05, 0.0, 0.12, 0.9))
	ttl.add_theme_constant_override("outline_size", 5)
	ttl.position = Vector2(0, 34); ttl.size = Vector2(PW, 66)
	ttl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(ttl)
	var subttl := Label.new()
	subttl.add_theme_font_override("font", combo_font)
	subttl.text = "DUMMY OPTIONS"
	subttl.add_theme_font_size_override("font_size", 24)
	subttl.add_theme_color_override("font_color", Color(0.72, 0.6, 0.95))
	subttl.position = Vector2(0, 104); subttl.size = Vector2(PW, 34)
	subttl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(subttl)
	practice_items.clear(); practice_state_lbls.clear(); practice_plates.clear()
	var row_x := 90.0
	var row_w := PW - 180.0
	var row_h := 90.0
	var row_y0 := 178.0
	var row_gap := 116.0
	for j in PRAC_NAMES.size():
		var ry := row_y0 + float(j) * row_gap
		# barra de resalte (solo en la fila seleccionada)
		var bar := Panel.new()
		bar.position = Vector2(row_x, ry); bar.size = Vector2(row_w, row_h)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_theme_stylebox_override("panel",
			_pause_glass_style(Color(1.0, 0.95, 1.0, 0.14), Color(0.9, 0.68, 1.0, 0.9), 14, 0.0))
		bar.visible = false
		panel.add_child(bar)
		practice_plates.append(bar)
		# NOMBRE (izquierda)
		var nm := Label.new()
		nm.add_theme_font_override("font", combo_font)
		nm.add_theme_font_size_override("font_size", 38)
		nm.text = PRAC_NAMES[j]
		nm.position = Vector2(row_x + 34.0, ry); nm.size = Vector2(row_w * 0.62, row_h)
		nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		panel.add_child(nm)
		practice_items.append(nm)
		# ESTADO ON/OFF (derecha)
		var stt := Label.new()
		stt.add_theme_font_override("font", combo_font)
		stt.add_theme_font_size_override("font_size", 40)
		stt.position = Vector2(row_x + row_w * 0.5, ry); stt.size = Vector2(row_w * 0.5 - 34.0, row_h)
		stt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		panel.add_child(stt)
		practice_state_lbls.append(stt)
	# descripción de la opción activa (estilo SF6) + ayuda de controles
	var desc := Label.new()
	desc.add_theme_font_override("font", combo_font)
	desc.name = "prac_desc"
	desc.add_theme_font_size_override("font_size", 24)
	desc.add_theme_color_override("font_color", Color(0.78, 0.72, 0.9))
	desc.position = Vector2(60, PH - 108); desc.size = Vector2(PW - 120, 34)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(desc)
	var hint := Label.new()
	hint.add_theme_font_override("font", combo_font)
	hint.text = "↑ ↓  select        Q  toggle        ESC  back"
	hint.add_theme_font_size_override("font_size", 22)
	hint.add_theme_color_override("font_color", Color(0.6, 0.55, 0.72))
	hint.position = Vector2(0, PH - 62); hint.size = Vector2(PW, 34)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(hint)

func _pause_show_practice(show: bool) -> void:
	if practice_panel == null:
		_build_practice_panel()
	pause_in_practice = show
	practice_panel.visible = show
	if show:
		practice_sel = 0
		_practice_refresh()

func _practice_refresh() -> void:
	var states := [dummy_jump_practice, dummy_lowhp_practice]
	for i in practice_items.size():
		var on: bool = states[i]
		var sel: bool = i == practice_sel
		(practice_plates[i] as Panel).visible = sel
		var nm := practice_items[i] as Label
		nm.add_theme_color_override("font_color", Color(1.0, 0.95, 0.55) if sel else Color(0.82, 0.78, 0.92))
		var stt := practice_state_lbls[i] as Label
		stt.text = "ON" if on else "OFF"
		stt.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45) if on else Color(0.9, 0.42, 0.42))
	# descripción de la opción seleccionada
	var d := practice_panel.find_child("prac_desc", true, false) as Label
	if d != null and practice_sel < PRAC_DESCS.size():
		d.text = PRAC_DESCS[practice_sel]

func _practice_toggle() -> void:
	if practice_sel == 0:
		dummy_jump_practice = not dummy_jump_practice
		dummy_jump_t = 0.0
	else:
		dummy_lowhp_practice = not dummy_lowhp_practice
	_practice_refresh()

# corre cada frame en pelea: salto automático del dummy + clavar su HP en 25%
func _update_dummy_practice(dt: float) -> void:
	if state != "fight":
		return
	# ULTRA PRACTICE: clava la vida del dummy en 25% (barra roja) para practicar el remate
	if dummy_lowhp_practice:
		var q: int = maxi(1, int(hp_max[1] * 0.25))
		if dummy_hp != q:
			dummy_hp = q
			_update_hp_bar(1, dummy_hp)
	# DUMMY JUMP: salta cada ~1s (solo en práctica: su IA apagada)
	if dummy_jump_practice and not dummy_ai_mode and is_instance_valid(dummy) \
			and not dummy.koed and not dummy.airborne and not dummy.is_downed() and dummy.input_enabled:
		dummy_jump_t += dt
		if dummy_jump_t >= 1.0:
			dummy_jump_t = 0.0
			dummy.airborne = true
			dummy.crouching = false
			dummy.vel_y = -dummy.JUMP_SPEED * dummy.jump_mult
			dummy._spawn_jump_dust(0.6)
			dummy.sprite.play("jump")
			# ZETMA: su clip de salto trae ~50 frames de AGACHARSE antes del despegue; igual que el
			# salto normal (fighter.gd), arranca en el DESPEGUE (frame 50) para NO mostrar la cuclilla
			# en el aire (antes el practice-jump lo omitía → se veía agachado volando).
			if dummy.fx_dark and dummy.sprite.sprite_frames.get_frame_count("jump") > 100:
				dummy.sprite.frame = 50

# ¿el jugador 2 usa mando? (si hay un pad conectado, se asume que es SUYO)
func _p2_en_mando() -> bool:
	return Input.get_connected_joypads().size() > 0

# traduce las teclas Q/W/E/R de los textos al dispositivo del JUGADOR 2:
# mando Xbox (Q→Y, W→A, E→B, R→X) o su lado del teclado (7/8/9/0).
# Solo toca letras SUELTAS (\b[QWER]\b): no rompe palabras como AWESOME.
func _keys_for_p2(t: String) -> String:
	var m := {"Q": "Y", "W": "A", "E": "B", "R": "X"} if _p2_en_mando() \
			else {"Q": "7", "W": "8", "E": "9", "R": "0"}
	var rx := RegEx.new()
	rx.compile("\\b[QWER]\\b")
	var out := ""
	var last := 0
	for res in rx.search_all(t):
		out += t.substr(last, res.get_start() - last) + String(m[res.get_string()])
		last = res.get_end()
	out += t.substr(last)
	return out

# llena el panel COMBOS de la pausa con la lista del personaje pedido (P1 o P2/rival);
# si la pausa es del JUGADOR 2, las teclas se muestran en SU dispositivo (mando/7890)
func _pause_fill_combos(cid: String) -> void:
	pause_combos_char = cid
	var t := _char_move_text(cid)
	var mv := String(t["moves"])
	var fn := String(t["fin"])
	if versus_2p and pause_owner == 1:
		mv = _keys_for_p2(mv)
		fn = _keys_for_p2(fn)
	pause_combos_title.text = String(t["title"])
	pause_combos_moves.text = mv
	pause_combos_fin.text = fn
	# COLOR temático + AVATAR del personaje mostrado (épico + por-personaje)
	var acc := _char_accent(cid)
	pause_combos_title.add_theme_color_override("font_color", acc)
	for br in pause_combos_border:
		var cr := br as ColorRect
		cr.color = Color(acc.r, acc.g, acc.b, cr.color.a)
	if pause_combos_avframe != null:
		pause_combos_avframe.color = acc
	if pause_combos_avatar != null:
		var avp := _char_avatar(cid)
		if ResourceLoader.exists(avp):
			pause_combos_avatar.texture = load(avp)

# ============================================================================
#  CAMBIAR PERSONAJE en medio del training (overlay estilo select morado)
# ============================================================================
func _build_charswap() -> void:
	charswap_root = Control.new()
	charswap_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	charswap_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	charswap_root.visible = false
	charswap_root.z_index = 60
	$UI.add_child(charswap_root)
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.09, 0.97)
	bg.position = Vector2.ZERO; bg.size = Vector2(1920, 1080)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	charswap_root.add_child(bg)
	var title := Label.new()
	title.add_theme_font_override("font", combo_font)
	title.add_theme_font_size_override("font_size", 66)
	title.add_theme_color_override("font_color", Color(0.82, 0.66, 1.0))
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_color_override("font_outline_color", Color(0.10, 0.0, 0.20))
	title.text = "CHANGE CHARACTER"
	title.position = Vector2(0, 120); title.size = Vector2(1920, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	charswap_root.add_child(title)
	# capa de marcos (encima de los avatares)
	charswap_fx = Control.new()
	charswap_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	charswap_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	charswap_root.add_child(charswap_fx)
	charswap_fx.draw.connect(_draw_charswap_fx)
	# tarjetas (avatar + nombre) por personaje
	var n := CHARS.size()
	var cw := 300.0
	var ch := 380.0
	var gap := 70.0
	var total := n * cw + (n - 1) * gap
	var x0 := 960.0 - total / 2.0
	var cy := 340.0
	charswap_cards.clear()
	for i in n:
		var x := x0 + i * (cw + gap)
		var av := TextureRect.new()
		var ap := String(CHARS[i]["avatar"])
		if ResourceLoader.exists(ap):
			av.texture = load(ap)
		av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		av.clip_contents = true
		av.position = Vector2(x, cy); av.size = Vector2(cw, ch)
		av.mouse_filter = Control.MOUSE_FILTER_IGNORE
		charswap_root.add_child(av)
		var nm := Label.new()
		nm.add_theme_font_override("font", combo_font)
		nm.add_theme_font_size_override("font_size", 40)
		nm.add_theme_constant_override("outline_size", 6)
		nm.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		nm.text = String(CHARS[i]["name"])
		nm.position = Vector2(x, cy + ch + 16); nm.size = Vector2(cw, 50)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		charswap_root.add_child(nm)
		charswap_cards.append({"av": av, "name": nm, "rect": Rect2(x, cy, cw, ch)})
	var hint := Label.new()
	hint.add_theme_font_override("font", combo_font)
	hint.add_theme_font_size_override("font_size", 28)
	hint.add_theme_color_override("font_color", Color(0.78, 0.6, 1.0))
	hint.text = "← →   ELEGIR      ENTER / Q   CONFIRMAR      ESC   CANCELAR"
	hint.position = Vector2(0, 900); hint.size = Vector2(1920, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	charswap_root.add_child(hint)

func _draw_charswap_fx() -> void:
	var pulse := 0.6 + 0.4 * sin(float(Time.get_ticks_msec()) / 1000.0 * 5.0)
	var PUR := Color(0.7, 0.5, 1.0)
	for i in charswap_cards.size():
		var r: Rect2 = charswap_cards[i]["rect"]
		if i == charswap_sel:
			for k in range(4, 0, -1):
				charswap_fx.draw_rect(r.grow(k * 4.0), Color(PUR.r, PUR.g, PUR.b, 0.10 * pulse), false, 3.0)
			charswap_fx.draw_rect(r.grow(5.0), Color(PUR.r, PUR.g, PUR.b, 0.95), false, 7.0)
			var cxm := r.position.x + r.size.x * 0.5
			charswap_fx.draw_colored_polygon(PackedVector2Array([
					Vector2(cxm - 18, r.position.y - 32), Vector2(cxm + 18, r.position.y - 32), Vector2(cxm, r.position.y - 8)]),
					Color(PUR.r, PUR.g, PUR.b, pulse))
		else:
			charswap_fx.draw_rect(r.grow(3.0), Color(0.5, 0.5, 0.6, 0.6), false, 3.0)

func _open_charswap() -> void:
	# índice del personaje actual
	charswap_sel = 0
	for i in CHARS.size():
		if String(CHARS[i]["id"]) == selected_char:
			charswap_sel = i
			break
	# atenúa/apaga las tarjetas no elegidas
	for i in charswap_cards.size():
		(charswap_cards[i]["av"] as TextureRect).modulate = Color(1, 1, 1, 1.0 if i == charswap_sel else 0.55)
	pause_root.visible = false
	charswap_root.visible = true
	charswap_fx.queue_redraw()
	state = "charswap"

func _charswap_confirm() -> void:
	var new_id := String(CHARS[charswap_sel]["id"])
	selected_char = new_id
	_apply_char(player, new_id)
	hp_max[0] = int(ARCH_HP.get(player.archetype, 1200))
	player.revive()
	player.position = Vector2(630, 625)
	player.set_facing(1)
	_refresh_hud_chars()
	charswap_root.visible = false
	# reanuda la pelea directamente
	pause_root.visible = false
	pause_in_combos = false
	pause_combos.visible = false
	state = "fight"
	Engine.time_scale = 1.0
	_set_inputs(true)
	dummy.ai_enabled = dummy_ai_mode

func _pause_confirm() -> void:
	match pause_sel:
		0:
			_close_pause()                   # CONTINUAR
		1:
			_rematch()                       # REMATCH: reinicia el combate (mismo stage)
		2:
			_open_choose_stage()             # CHOOSE STAGE: abre el modal selector
		3:
			_pause_show_combos(true)         # COMBOS
		4:
			_open_charswap()                 # CAMBIAR PERSONAJE (en medio del training)
		5:
			_pause_show_practice(true)       # PRACTICE: sub-panel de toggles del dummy
		6:
			# SALIR AL MENÚ PRINCIPAL (restaurar time_scale ANTES de cambiar de escena)
			Engine.time_scale = 1.0
			Sel.configured = false
			get_tree().change_scene_to_file("res://title.tscn")

# REMATCH: reinicia el combate desde el round 1 en el MISMO stage, sin salir al menú.
func _rematch() -> void:
	Engine.time_scale = 1.0
	pause_in_combos = false
	if pause_combos != null:
		pause_combos.visible = false
	if pause_root != null:
		pause_root.visible = false
	wins_p1 = 0
	wins_p2 = 0
	round_num = 1
	_start_round()

# ---- MODAL de CHOOSE STAGE (dentro de la pausa) ----
func _build_stage_modal() -> void:
	stage_modal = Control.new()
	stage_modal.position = Vector2.ZERO
	stage_modal.size = Vector2(1920, 1080)
	stage_modal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_modal.visible = false
	stage_modal.z_index = 40                     # por ENCIMA del panel de pausa
	pause_root.add_child(stage_modal)
	stage_modal.draw.connect(_draw_stage_modal)
	stage_modal_tex.clear()
	for s in Sel.STAGES:
		var tp := String(s.get("thumb", ""))
		stage_modal_tex.append(load(tp) if ResourceLoader.exists(tp) else null)

func _open_choose_stage() -> void:
	if stage_modal == null:
		_build_stage_modal()
	# arranca en el stage que se está jugando (para verlo en gris) o en el primero
	stage_modal_sel = 0
	for i in Sel.STAGES.size():
		if int(Sel.STAGES[i]["code"]) == Sel.stage:
			stage_modal_sel = i
			break
	stage_modal_flash = 0.0
	pause_in_stage = true
	if pause_glass != null:
		pause_glass.visible = false           # oculta el menú de pausa detrás
	stage_modal.visible = true
	stage_modal.queue_redraw()

func _close_choose_stage() -> void:
	pause_in_stage = false
	if pause_glass != null:
		pause_glass.visible = true            # vuelve a mostrar el menú de pausa
	if stage_modal != null:
		stage_modal.visible = false

func _confirm_choose_stage() -> void:
	var code := int(Sel.STAGES[stage_modal_sel]["code"])
	if code == Sel.stage:
		_close_choose_stage()                    # es el que ya se juega: solo cierra
		return
	# dispara el FOGONAZO morado; al terminar (_process de la pausa) hace el swap en vivo
	stage_modal_swap_code = code
	stage_modal_flash = 1.0
	stage_modal_flash_ms = Time.get_ticks_msec()

# dibuja el selector: velo + título + fila de tarjetas (la que se juega en GRIS, la elegida
# resaltada con blink morado). Reloj REAL para animar en pausa (time_scale=0).
func _draw_stage_modal() -> void:
	var t := float(Time.get_ticks_msec()) / 1000.0
	var pulse := 0.5 + 0.5 * absf(sin(t * 4.0))
	# fondo GENERAL más TRANSPARENTE (se ve el juego detrás) + PANEL propio contenido
	stage_modal.draw_rect(Rect2(0, 0, 1920, 1080), Color(0.02, 0.01, 0.05, 0.40))
	var panel := Rect2(150, 150, 1620, 800)
	stage_modal.draw_rect(panel, Color(0.12, 0.06, 0.22, 0.86))          # panel (opaco: tapa la pausa)
	stage_modal.draw_rect(panel.grow(3.0), Color(0.78, 0.5, 1.0, 0.9), false, 3.0)   # borde morado
	stage_modal.draw_string(combo_font, Vector2(0, 218), "SELECT STAGE",
			HORIZONTAL_ALIGNMENT_CENTER, 1920, 52, Color(0.85, 0.6, 1.0))
	var n := Sel.STAGES.size()
	var cw := 300.0
	var ch := 420.0
	var gap := 60.0
	var total := n * cw + (n - 1) * gap
	var x0 := 960.0 - total * 0.5
	var cy := 300.0
	for i in n:
		var cx := x0 + i * (cw + gap)
		var r := Rect2(cx, cy, cw, ch)
		var playing := int(Sel.STAGES[i]["code"]) == Sel.stage
		var seld := i == stage_modal_sel
		# thumbnail (en GRIS si es el que se está jugando)
		if i < stage_modal_tex.size() and stage_modal_tex[i] != null:
			var tint := Color(0.4, 0.4, 0.45, 1.0) if playing else Color(1, 1, 1, 1)
			stage_modal.draw_texture_rect(stage_modal_tex[i], r, false, tint)
		else:
			stage_modal.draw_rect(r, Color(0.12, 0.10, 0.16))
		# BLINK morado semi-transparente sobre la tarjeta ELEGIDA (efecto de selección)
		if seld and not playing:
			var fa := 0.22 + 0.30 * pulse
			if stage_modal_flash > 0.0:
				fa = 0.65 * stage_modal_flash          # fogonazo al confirmar
			stage_modal.draw_rect(r, Color(0.62, 0.30, 1.0, fa))
		# marco
		var bcol := Color(0.5, 0.5, 0.55, 0.7)
		var bw := 3.0
		if playing:
			bcol = Color(0.45, 0.45, 0.5, 0.8)
		elif seld:
			bcol = Color(0.85, 0.55, 1.0, 0.95); bw = 6.0
		stage_modal.draw_rect(r.grow(bw * 0.5), bcol, false, bw)
		# nombre + etiqueta PLAYING
		var nm := String(Sel.STAGES[i]["name"])
		var ncol := Color(0.55, 0.55, 0.6) if playing else (Color(1, 1, 1) if seld else Color(0.8, 0.8, 0.86))
		stage_modal.draw_string(combo_font, Vector2(cx, cy + ch + 44), nm,
				HORIZONTAL_ALIGNMENT_CENTER, cw, 30, ncol)
		if playing:
			stage_modal.draw_string(combo_font, Vector2(cx, cy + 40), "PLAYING",
					HORIZONTAL_ALIGNMENT_CENTER, cw, 26, Color(0.9, 0.5, 0.5, 0.9))
	stage_modal.draw_string(combo_font, Vector2(0, 880), "← →  SELECT      ENTER  CONFIRM      ESC  BACK",
			HORIZONTAL_ALIGNMENT_CENTER, 1920, 26, Color(0.8, 0.7, 0.95))

func _close_pause() -> void:
	pause_in_combos = false
	pause_combos.visible = false
	pause_in_practice = false                 # cierra el sub-panel practice (los toggles SIGUEN activos)
	if practice_panel != null:
		practice_panel.visible = false
	pause_root.visible = false
	state = pause_prev_state
	Engine.time_scale = 1.0
	_set_inputs(true)
	dummy.ai_enabled = dummy_ai_mode

func _open_moves() -> void:
	state = "moves"
	_set_moves_text()          # muestra los movimientos del personaje ELEGIDO (Fe o DAM)
	_set_inputs(false)
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
	_set_inputs(false)
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
const FAVI_SCALE := 1.0             # Fe (~10 años) claramente MÁS ALTA que Aye (~5): 1.0 -> ~496px vs 458 de Aye (+8%) AUN en guardia agachada. Con 0.95 quedaban casi iguales en pantalla.
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
# AYE-2 (idol rediseñada): la MÁS chica del juego. Arte 632px * 0.666 = 421 -> body_k 0.60.
const AYE2_SCALE := 0.666
const AYE2_FEET_FROM_CENTER := 500.0
const AYE2_MOVE_SPD := 0.7        # desplazamiento del walk (tuneable)

# DAM un poco más grande (antes 1.0). base_scale también escala sus FX/estelas/sombras,
# así que sube proporcional. El offset compensa para que los pies sigan en el piso.
const DAM_SCALE := 1.10
const DAM_FEET_FROM_CENTER := 500.0
const ZETMA_SCALE := 0.90            # un poco más bajo que DAM (idle ~635px vs 714 de DAM ≈89% en pantalla)
const ZETMA_FEET_FROM_CENTER := 500.0
const ROUM_SCALE := 1.14             # TANQUE: el MÁS GRANDE del roster, pero NO un gigante (era 1.30 = gigante)
const ROUM_FEET_FROM_CENTER := 500.0

# registra una ANIM ESTÁNDAR compartida (GUIA-COMUN: frozen, electrocuted, step, ...),
# solo si ya existen sus frames — el patrón común para TODOS los personajes
# anims que un personaje puede NO tener frames propios: se sustituyen por SU anim más
# parecido (nunca el arte de DAM, que el build copia como placeholder). flame_cast es
# exclusivo de DAM (los demás no lo lanzan) -> no se mapea.
# cada anim que un personaje puede NO tener -> LISTA de sustitutos propios (se usa el primero
# con frames). "pose" al final garantiza que NUNCA quede el arte de DAM. flame_cast usa el
# casteo propio de cada quien (crystal_cast Aye / water_cast Favi).
const ANIM_FALLBACK := {
	"fly_straight": ["hit_fly"], "wall_splat": ["hit_down"], "ko_air": ["ko"],
	"spin_kick": ["sweep"], "air_spin_kick": ["jump_kick"], "neutral_spin": ["jump"],
	"punch2": ["punch"], "flame_cast": ["crystal_cast", "water_cast", "pose"],
}

# BUGFIX cross-personaje: el build de Favi/Aye/Zetma copia frames de DAM como placeholder en
# los anims que ese personaje no tiene (fly_straight, wall_splat, ...). Al recibir/lanzar se
# veía el arte de DAM. Aquí cada placeholder se reemplaza por el anim PROPIO equivalente.
func _fix_placeholders(sf: SpriteFrames, frames_fn: Callable) -> void:
	if sf == null:
		return
	for miss in ANIM_FALLBACK:
		if not sf.has_animation(miss) or not frames_fn.call(miss).is_empty():
			continue                       # no lo tiene como placeholder, o SÍ tiene el suyo
		for fb in ANIM_FALLBACK[miss]:
			var fb_frames: Array = frames_fn.call(fb)
			if fb_frames.is_empty() or not sf.has_animation(fb):
				continue                   # este sustituto tampoco lo tiene: probar el siguiente
			sf.clear(miss)
			sf.set_animation_loop(miss, sf.get_animation_loop(fb))
			sf.set_animation_speed(miss, sf.get_animation_speed(fb))
			for t in fb_frames:
				sf.add_frame(miss, t)
			break                          # sustituido con arte propio: listo

func _register_shared_anim(sf: SpriteFrames, nombre: String, frames: Array, fps: float, en_loop := true) -> void:
	if frames.is_empty() or sf.has_animation(nombre):
		return
	sf.add_animation(nombre)
	sf.set_animation_loop(nombre, en_loop)
	sf.set_animation_speed(nombre, fps)
	for t in frames:
		sf.add_frame(nombre, t)

func _favi_register_frozen(sf: SpriteFrames) -> void:
	# ELECTROCUTADO estándar (GUIA-COMUN): convulsión SF mientras dura la descarga
	_register_shared_anim(sf, "electrocuted", _favi_action_frames("electrocuted"), 24.0)
	# PASO CORTO / BACKDASH (doble-tap, GUIA-COMUN): un disparo, sin loop
	# STEP v2 (clip dash-f, 20 frames): brinco rasante — 70fps ~0.29s: el deslizamiento
	# del motor (0.16s) cubre empuje+vuelo y el aterrizaje remata en el sitio
	_register_shared_anim(sf, "step", _favi_action_frames("step"), 70.0, false)
	_register_shared_anim(sf, "backdash", _favi_action_frames("backdash"), 30.0, false)
	# CONGELADO estándar (GUIA-COMUN): solo si ya hay frames en favi/frozen/
	var ffz := _favi_action_frames("frozen")
	if not ffz.is_empty() and not sf.has_animation("frozen"):
		sf.add_animation("frozen")
		sf.set_animation_loop("frozen", true)
		sf.set_animation_speed("frozen", 12.0)
		for t in ffz:
			sf.add_frame("frozen", t)

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
	# animación EXCLUSIVA de Fe: water_cast = THUNDER-CAST (invoca el rayo, especiales
	# ↓↘→). v2 de video: 50 frames (subida al cielo f1-17 + latigazo adelante f78-110;
	# el hold estático del clip se saltó). 90fps ≈ 0.55s, rápido para encadenar.
	if not sf.has_animation("water_cast"):
		sf.add_animation("water_cast")
	sf.set_animation_loop("water_cast", false)
	sf.set_animation_speed("water_cast", 90.0 if _favi_action_frames("water_cast").size() > 5 else 15.0)
	# AÉREAS RÁPIDAS (pedido global del usuario)
	if sf.has_animation("jump_punch"):
		sf.set_animation_speed("jump_punch", 28.0)
	if sf.has_animation("jump_kick"):
		# v2 del clavado: 22 frames completos del clip (f66-87) -> 70fps para el mismo
		# ~0.31s veloz; los 8 frames viejos (submuestreados) iban a 28
		sf.set_animation_speed("jump_kick", 70.0 if sf.get_frame_count("jump_kick") > 12 else 28.0)
	# walk NUEVO: UN PASO limpio (f13..36 del clip, 24 frames) con el pase elegante erguido.
	# Las dos piernas de Fe se ven iguales => un paso en loop = caminata completa. Paso de
	# 267px de pantalla a 484px/s -> 0.55s = 24f a 44fps: sin patinar
	if sf.has_animation("walk"):
		sf.set_animation_speed("walk", 44.0)
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
	# v2 (42 frames): DOBLE ARMADA A MANO del clip air_jab.mp4 (chamber → patada →
	# recoge → patada otra vez → recogida) porque la herramienta solo generaba UNA.
	var aj := _favi_action_frames("air_jab")
	if not aj.is_empty():
		if not sf.has_animation("air_jab"):
			sf.add_animation("air_jab")
		sf.clear("air_jab")
		sf.set_animation_loop("air_jab", false)
		sf.set_animation_speed("air_jab", 85.0 if aj.size() > 8 else 16.0)   # v2 VELOZ ~0.49s / sheet viejo 0.25s
		for t in aj:
			sf.add_frame("air_jab", t)
	# HIT_FLY v2 (49 frames del clip, vuelo estabilizado por centroide): mucho más
	# fluido que los 4 del sheet — la velocidad acompaña el arco del lanzamiento
	if sf.has_animation("hit_fly") and sf.get_frame_count("hit_fly") > 8:
		sf.set_animation_speed("hit_fly", 45.0)
	# KO v2 (41 frames: impacto -> asienta -> tendida, de la cola del mismo clip):
	# con peso — el juego sostiene el último frame (tendida boca arriba)
	if sf.has_animation("ko") and sf.get_frame_count("ko") > 8:
		sf.set_animation_speed("ko", 30.0)
	# VICTORY v2 (84 frames con zoom compensado): giro -> puño al cielo -> sostiene
	if sf.has_animation("victory") and sf.get_frame_count("victory") > 8:
		sf.set_animation_speed("victory", 30.0)
	# BLOCK v2 (clip, 31 frames): guardia extendida -> la segunda aguja CRUZA en X ->
	# jolt de absorcion. 68fps ~= 0.46s: mismo blockstun que el frame estatico viejo.
	if sf.has_animation("block") and sf.get_frame_count("block") > 8:
		sf.set_animation_speed("block", 68.0)
	# BLOCK_LOW v2 (clip, 25 frames): agachada cierra los brazos al cruce. 55fps ~= 0.45s
	if sf.has_animation("block_low") and sf.get_frame_count("block_low") > 8:
		sf.set_animation_speed("block_low", 55.0)
	# TAKE_HIT v2 (clip, 25 frames n2-26): LATIGAZO atras (pelo volando) + regreso
	# aturdido. 100fps ~= 0.25s: mismo hitstun que los 4 frames viejos — combos intactos.
	if sf.has_animation("take_hit") and sf.get_frame_count("take_hit") > 8:
		sf.set_animation_speed("take_hit", 100.0)
	# TAKE_HIT_LOW v2 (clip, 21 frames n114-134): jolt agachado (pelo volando) que se
	# asienta a la guardia baja. 100fps ~= 0.21s (viejo: 2 frames ~0.14s, reaccion baja corta)
	if sf.has_animation("take_hit_low") and sf.get_frame_count("take_hit_low") > 8:
		sf.set_animation_speed("take_hit_low", 100.0)
	# MORTAL AÉREO HACIA ADELANTE (salto + alante): flip que rota, EXCLUSIVA de Fe.
	var nsp := _favi_action_frames("neutral_spin")
	if not nsp.is_empty():
		if not sf.has_animation("neutral_spin"):
			sf.add_animation("neutral_spin")
		sf.set_animation_loop("neutral_spin", false)   # UN solo giro; luego cae (frame de salto)
		# v2 del clip (78 frames): veloz para que el flip quepa en el arco del salto
		sf.set_animation_speed("neutral_spin", 88.0 if nsp.size() > 20 else 18.0)
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
	# SALTO+E NUEVO (clip air_spin_kick): PATADA VOLADORA de agujas — carga + extensión +
	# recogida del video (40 frames). Reemplaza el mortal del sheet viejo.
	var fask := _favi_action_frames("air_spin_kick")
	if fask.size() > 8:
		if not sf.has_animation("air_spin_kick"):
			sf.add_animation("air_spin_kick")
		sf.clear("air_spin_kick")
		for t in fask:
			sf.add_frame("air_spin_kick", t)
		sf.set_animation_loop("air_spin_kick", false)
		sf.set_animation_speed("air_spin_kick", 78.0)   # aérea RÁPIDA (~0.51s)
		# CAÍDA AÉREA de Fe ("air_fall"): la RECOGIDA de la voladora (pierna plegándose,
		# frames 28-39) como anim de caída tras un ataque aéreo — sin ventanas de golpe.
		# El jump W congelado en su remate se veía "cayendo de pie con los pies abiertos".
		if not sf.has_animation("air_fall"):
			sf.add_animation("air_fall")
			sf.set_animation_loop("air_fall", false)
			sf.set_animation_speed("air_fall", 26.0)
			for i in range(28, fask.size()):
				sf.add_frame("air_fall", fask[i])
	elif sf.has_animation("air_spin_kick"):
		# fallback sheet viejo: va MÁS RÁPIDO que el resto de las anims de Fe
		sf.set_animation_speed("air_spin_kick", sf.get_animation_speed("air_spin_kick") * 1.5)
	# Q NUEVO (clip punch.mp4): PATADA ALTA GIRADA de suelo — planta el pie, la pierna
	# sube vertical y barre adelante (26 frames). Reemplaza la tijera del sheet viejo.
	var fpn := _favi_action_frames("punch")
	if fpn.size() > 12:
		if not sf.has_animation("punch"):
			sf.add_animation("punch")
		sf.clear("punch")
		for t in fpn:
			sf.add_frame("punch", t)
		sf.set_animation_loop("punch", false)
		sf.set_animation_speed("punch", 50.0)   # Q ligero y SNAPPY (26 frames ~0.52s)
	# W NUEVO (clip kick.mp4): DOBLE PATADA con la MISMA pierna — cintura y luego ALTA a
	# la cara (73 frames; la pausa muerta del clip entre patadas se excluyó). La ALTA lanza.
	var fkn := _favi_action_frames("kick")
	if fkn.size() > 12:
		if not sf.has_animation("kick"):
			sf.add_animation("kick")
		sf.clear("kick")
		for t in fkn:
			sf.add_frame("kick", t)
		sf.set_animation_loop("kick", false)
		sf.set_animation_speed("kick", 105.0)   # doble patada VELOZ ~0.70s (Fe es assassin)
	# AGACHARSE NUEVO (clip crouch.mp4): transición parada→agache con TODOS los frames
	# (22). Rápida — y al soltar ↓ el juego la reproduce en REVERSA para levantarse.
	if sf.has_animation("crouch") and sf.get_frame_count("crouch") > 8:
		sf.set_animation_speed("crouch", 75.0)
	# ↓R NUEVO (clip crouch_jab_1.mp4): CAST DEL TIGRE — agachada señala al frente
	# comandando el ataque (54 frames). NO golpea: el daño lo hará el TIGRE de energía.
	var fcj := _favi_action_frames("crouch_jab")
	if fcj.size() > 8:
		if not sf.has_animation("crouch_jab"):
			sf.add_animation("crouch_jab")
		sf.clear("crouch_jab")
		for t in fcj:
			sf.add_frame("crouch_jab", t)
		sf.set_animation_loop("crouch_jab", false)
		sf.set_animation_speed("crouch_jab", 95.0)   # cast ~0.57s
	# ↓E NUEVO (clip sweep.mp4): BARRIDA rasante — carga, pierna barre el piso, se
	# incorpora con el impulso y asienta al agache (87 frames, TODOS: movimiento continuo).
	var fsw := _favi_action_frames("sweep")
	if fsw.size() > 8:
		if not sf.has_animation("sweep"):
			sf.add_animation("sweep")
		sf.clear("sweep")
		for t in fsw:
			sf.add_frame("sweep", t)
		sf.set_animation_loop("sweep", false)
		sf.set_animation_speed("sweep", 105.0)   # barrida ~0.83s
	# ↓W NUEVO (clip crouch_kick.mp4): LANZADOR — del agache sube clavando la aguja en
	# lunge hacia adelante (48 frames; el lunge sostenido del clip se comprimió).
	var fck := _favi_action_frames("crouch_kick")
	if fck.size() > 8:
		if not sf.has_animation("crouch_kick"):
			sf.add_animation("crouch_kick")
		sf.clear("crouch_kick")
		for t in fck:
			sf.add_frame("crouch_kick", t)
		sf.set_animation_loop("crouch_kick", false)
		sf.set_animation_speed("crouch_kick", 95.0)   # lanzador ~0.51s
	# ↓Q NUEVO (clip crouch_punch.mp4): DOBLE ESTOCADA AGACHADA — ambos brazos juntos
	# (40 frames; la extensión sostenida del clip se comprimió). Arranca YA agachada.
	var fcp := _favi_action_frames("crouch_punch")
	if fcp.size() > 8:
		if not sf.has_animation("crouch_punch"):
			sf.add_animation("crouch_punch")
		sf.clear("crouch_punch")
		for t in fcp:
			sf.add_frame("crouch_punch", t)
		sf.set_animation_loop("crouch_punch", false)
		sf.set_animation_speed("crouch_punch", 100.0)   # poke agachado rápido (~0.40s)
	# R NUEVO (clip weak_punch.mp4): JAB DE AGUJA — subida + estocada de esgrima +
	# recogida (35 frames; la extensión sostenida del clip se comprimió). SNAPPY.
	var fwp := _favi_action_frames("weak_punch")
	if fwp.size() > 8:
		if not sf.has_animation("weak_punch"):
			sf.add_animation("weak_punch")
		sf.clear("weak_punch")
		for t in fwp:
			sf.add_frame("weak_punch", t)
		sf.set_animation_loop("weak_punch", false)
		sf.set_animation_speed("weak_punch", 95.0)   # jab rápido (~0.37s)
	# E NUEVO (clip spin_kick.mp4): PEONZA de video — molinillo completo con frenado y
	# vuelta a guardia (85 frames; la cola estática del clip se excluyó). RÁPIDA: es su spin.
	var fsp := _favi_action_frames("spin_kick")
	if fsp.size() > 12:
		if not sf.has_animation("spin_kick"):
			sf.add_animation("spin_kick")
		sf.clear("spin_kick")
		for t in fsp:
			sf.add_frame("spin_kick", t)
		sf.set_animation_loop("spin_kick", false)
		sf.set_animation_speed("spin_kick", 130.0)   # trompo VELOZ (~0.65s)
	if sf.has_animation("default"):
		sf.remove_animation("default")
	_favi_register_frozen(sf)   # CONGELADO estándar si ya hay frames
	# land NUEVO (5 frames del clip de jump: toque->flexión->recuperación)
	var fln := _favi_action_frames("land")
	if not fln.is_empty() and not sf.has_animation("land"):
		sf.add_animation("land")
		sf.set_animation_loop("land", false)
		sf.set_animation_speed("land", 17.0)
		for t in fln:
			sf.add_frame("land", t)
	# GET-PULL de Fe (víctima del gancho de Zetma): 1-5 horizontal (pies) / 6-10 aéreo (cuerpo)
	var fgp := _favi_action_frames("get_pull")
	if fgp.size() > 1:
		if not sf.has_animation("get_pull"):
			sf.add_animation("get_pull")
		sf.clear("get_pull")
		sf.set_animation_loop("get_pull", true)
		sf.set_animation_speed("get_pull", 12.0)
		for t in fgp:
			sf.add_frame("get_pull", t)
	var fgpa := _favi_action_frames("get_pull_air")
	if fgpa.size() > 1:
		if not sf.has_animation("get_pull_air"):
			sf.add_animation("get_pull_air")
		sf.clear("get_pull_air")
		sf.set_animation_loop("get_pull_air", true)
		sf.set_animation_speed("get_pull_air", 12.0)
		for t in fgpa:
			sf.add_frame("get_pull_air", t)
	# ASSASSIN (pedido): sus GOLPES van aún más veloces que lo tuneado — multiplicador
	# global 1.2x sobre las anims de ataque. Los hit_frame son índices de FRAME, así que
	# el impacto cae en el mismo cuadro (solo llega antes): hitboxes intactas.
	for a_atk in ["punch", "punch2", "kick", "spin_kick", "weak_punch", "crouch_punch",
			"crouch_kick", "sweep", "crouch_jab", "jump_punch", "jump_kick", "air_jab",
			"air_spin_kick"]:
		if sf.has_animation(a_atk):
			sf.set_animation_speed(a_atk, sf.get_animation_speed(a_atk) * 1.2)
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
	# CONGELADO estándar (GUIA-COMUN): solo si ya hay frames en aye/frozen/
	var azf := _aye_action_frames("frozen")
	if not azf.is_empty() and not sf.has_animation("frozen"):
		sf.add_animation("frozen")
		sf.set_animation_loop("frozen", true)
		sf.set_animation_speed("frozen", 12.0)
		for t in azf:
			sf.add_frame("frozen", t)
	# ELECTROCUTADO estándar (GUIA-COMUN): convulsión SF mientras dura la descarga
	_register_shared_anim(sf, "electrocuted", _aye_action_frames("electrocuted"), 24.0)
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
		sf.set_animation_speed("get_up", 78.0)   # levantada RÁPIDA (pedido): ~0.35s (+ destello de poder)
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
		# SOLO frames 1-6 (rayitas glitch PEGADAS al cuerpo). Del 7 en adelante el clip
		# se vuelve una BANDA/CUADRO rectangular a pantalla (el "cuadrado" que se veía
		# en teleport aéreo y backstab). Los orquestadores retienen el último frame
		# (fighter._on_animation_finished) hasta reaparecer.
		for i in mini(6, aye_tp.size()):
			sf.add_frame("teleport", aye_tp[i])
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
			"jump_kick_cast", "crystal_cast", "counter", "air_jab",
			"take_hit", "take_hit_low"]:
		if sf.has_animation(aa) and not _aye_action_frames(aa).is_empty():
			sf.set_animation_speed(aa, sf.get_animation_speed(aa) * 1.25)
	# GET-PULL de Aye (víctima del gancho): 1-5 horizontal (pies) / 6-9 aéreo (cuerpo)
	var agp := _aye_action_frames("get_pull")
	if agp.size() > 1:
		if not sf.has_animation("get_pull"):
			sf.add_animation("get_pull")
		sf.clear("get_pull")
		sf.set_animation_loop("get_pull", true)
		sf.set_animation_speed("get_pull", 12.0)
		for t in agp:
			sf.add_frame("get_pull", t)
	var agpa := _aye_action_frames("get_pull_air")
	if agpa.size() > 1:
		if not sf.has_animation("get_pull_air"):
			sf.add_animation("get_pull_air")
		sf.clear("get_pull_air")
		sf.set_animation_loop("get_pull_air", true)
		sf.set_animation_speed("get_pull_air", 12.0)
		for t in agpa:
			sf.add_frame("get_pull_air", t)
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

# ZETMA (4º peleador, WIP): carga los frames que YA existen en imagen-action/zetma/<accion>/
func _aye2_action_frames(accion: String, skin: String) -> Array:
	var out := []
	var i := 1
	while true:
		var p := "res://imagen-action/aye-2/%s/%s/aye2-%s-%d.png" % [skin, accion, accion, i]
		if ResourceLoader.exists(p):
			out.append(load(p))
			i += 1
		else:
			break
	return out

func _build_aye2_frames(skin: String) -> SpriteFrames:
	# clona la estructura de anims de DAM; usa el arte de AYE-2 donde exista (por SKIN),
	# y frames de DAM como placeholder donde aún no hay (walk_back/golpes/etc).
	var dam := load("res://fighter_frames.tres") as SpriteFrames
	var sf := SpriteFrames.new()
	for anim in dam.get_animation_names():
		var real := _aye2_action_frames(anim, skin)
		# Anims EXCLUSIVAS del arte de DAM: si Aye-2 no tiene el suyo, se OMITEN (no placeholder de DAM).
		#   pummeled -> recibe el ultra con "take_hit" (no sale DAM); ko_air -> cae con "ko";
		#   fly_straight/wall_splat -> vuela/estampa con "hit_fly".
		if real.is_empty() and anim in ["ko_air", "pummeled", "fly_straight", "wall_splat"]:
			continue
		if not sf.has_animation(anim):
			sf.add_animation(anim)
		sf.set_animation_loop(anim, dam.get_animation_loop(anim))
		if real.is_empty():
			sf.set_animation_speed(anim, dam.get_animation_speed(anim))
			for i in dam.get_frame_count(anim):
				sf.add_frame(anim, dam.get_frame_texture(anim, i))
		else:
			sf.set_animation_speed(anim, 24.0)   # clips de aye2 = 24fps nativo
			for t in real:
				sf.add_frame(anim, t)
	# cadencias afinadas (tuneable) de sus anims propias
	if not _aye2_action_frames("pose", skin).is_empty():
		sf.set_animation_speed("pose", 24.0)     # idle 145f @24 = respiración de ~6s
	if not _aye2_action_frames("walk", skin).is_empty():
		sf.set_animation_speed("walk", 30.0)
	if not _aye2_action_frames("crouch", skin).is_empty():
		sf.set_animation_speed("crouch", 130.0)   # 145f: agacharse RÁPIDO (24fps daba 6s)
	if not _aye2_action_frames("take_hit", skin).is_empty():
		sf.set_animation_speed("take_hit", 290.0)      # 145f -> ~0.5s de hitstun (flinch veloz, no 6s)
	if not _aye2_action_frames("take_hit_low", skin).is_empty():
		sf.set_animation_speed("take_hit_low", 290.0)  # 145f -> ~0.5s (golpe bajo)
	if not _aye2_action_frames("block", skin).is_empty():
		sf.set_animation_speed("block", 290.0)         # 145f -> ~0.5s de blockstun (no 6s)
	if not _aye2_action_frames("block_low", skin).is_empty():
		sf.set_animation_speed("block_low", 290.0)     # 145f -> ~0.5s de blockstun bajo
	if not _aye2_action_frames("hit_fly", skin).is_empty():
		sf.set_animation_speed("hit_fly", 200.0)       # 145f -> ~0.7s de volteo (luego sostiene el frame final en el aire)
	if not _aye2_action_frames("ko", skin).is_empty():
		sf.set_animation_speed("ko", 110.0)            # 145f -> ~1.3s de colapso; sostiene el frame final tendida
	if not _aye2_action_frames("victory", skin).is_empty():
		sf.set_animation_speed("victory", 50.0)        # 145f -> ~2.9s de floreo; sostiene la pose final (V)
	# GOLPES -> slots de botón. DE PIE: R=weak_punch Q=punch W=kick E=spin_kick (4 orbes).
	# AGACHADA: ↓Q=crouch_punch(orbe bajo) ↓W=crouch_kick(patada baja).
	# AIRE (v2): ↑Q=jump_punch(orbe recto) ↑W=jump_kick(orbe ↓) ↑E=air_spin_kick(orbe ↑) ↑R=air_jab(patada).
	# Cada slot se cablea SOLO si su clip existe (si no, queda el placeholder de DAM).
	# OJO combate: el motor tiene lógica de la AYE VIEJA en ↑E (jump_kick_cast, cristal + maná) y ↑R
	# (air_jab barrage + maná) — hay que decoplarla para aye2 (que ahí van orbe/patada sin maná).
	var atk_map := {"weak_punch": "orb_push", "punch": "orb_throw", "kick": "orb_jab", "spin_kick": "orb_e",
		"crouch_punch": "crouch_low", "crouch_kick": "crouch_kick", "crouch_jab": "crouch_jab", "sweep": "crouch_kick",
		"jump_punch": "jump_throw", "jump_kick": "jump_down", "air_spin_kick": "jump_up", "air_jab": "air_kick"}
	for slot in atk_map:
		var af := _aye2_action_frames(atk_map[slot], skin)
		if af.is_empty():
			continue
		if not sf.has_animation(slot):
			sf.add_animation(slot)
		sf.clear(slot)
		sf.set_animation_loop(slot, false)
		sf.set_animation_speed(slot, 150.0)   # 145f -> ~1s (primer pase; a recortar para combate)
		for t in af:
			sf.add_frame(slot, t)
	# DERRIBO (hit_down): aye2 NO lo hereda de DAM. Usa su clip PROPIO (el TRAMO FINAL del hit_fly:
	# la caída al piso + tendida boca arriba) si existe; si no, REUSA el ko como respaldo. Siempre
	# se ve SU cuerpo (nunca el placeholder de DAM). Encadena hit_down -> get_up.
	var hd_frames := _aye2_action_frames("hit_down", skin)
	if hd_frames.is_empty():
		hd_frames = _aye2_action_frames("ko", skin)   # respaldo si aún no hay hit_down propio
	if not hd_frames.is_empty():
		if not sf.has_animation("hit_down"):
			sf.add_animation("hit_down")
		sf.clear("hit_down")
		sf.set_animation_loop("hit_down", false)
		sf.set_animation_speed("hit_down", 120.0)   # 60f: caída al suelo + tendida (~0.5s)
		for t in hd_frames:
			sf.add_frame("hit_down", t)
	# GET_UP (levantón): aye2 NO lo hereda de DAM (no está en las anims clonadas), así que si tiene
	# frames propios hay que CREAR la anim explícitamente. Si no tiene, se asegura que no quede
	# ningún placeholder para que el motor encadene hit_down -> pose directo (sin levantar a DAM).
	var gu_frames := _aye2_action_frames("get_up", skin)
	if not gu_frames.is_empty():
		if not sf.has_animation("get_up"):
			sf.add_animation("get_up")
		sf.clear("get_up")
		sf.set_animation_loop("get_up", false)
		sf.set_animation_speed("get_up", 12.0)   # 7f (tendida->parada) -> ~0.6s de levantón
		for t in gu_frames:
			sf.add_frame("get_up", t)
	elif sf.has_animation("get_up"):
		sf.remove_animation("get_up")   # sin get_up propio: evita que el motor reproduzca el get_up de DAM
	return sf

func _zetma_action_frames(accion: String) -> Array:
	var out := []
	var i := 1
	while true:
		var p := "res://imagen-action/zetma/%s/zetma-%s-%d.png" % [accion, accion, i]
		if ResourceLoader.exists(p):
			out.append(load(p))
			i += 1
		else:
			break
	return out

# --- FRAMES DE ROUM (TANQUE): usa sus clips (roum/<accion>/roum-<accion>-N.png) donde existan;
# lo que aún NO tiene se rellena con su POSE (placeholder — siempre se ve a ROUM, nunca DAM).
func _roum_action_frames(accion: String) -> Array:
	var out := []
	var i := 1
	while true:
		var p := "res://imagen-action/roum/%s/roum-%s-%d.png" % [accion, accion, i]
		if ResourceLoader.exists(p):
			out.append(load(p))
			i += 1
		else:
			break
	return out

func _build_roum_frames() -> SpriteFrames:
	var sf := load("res://fighter_frames.tres").duplicate(true) as SpriteFrames
	var pose := _roum_action_frames("pose")
	if not pose.is_empty():
		# la POSE de ROUM reemplaza el idle Y sirve de placeholder para TODA anim aún sin arte
		for anim in sf.get_animation_names():
			sf.clear(anim)
			for t in pose:
				sf.add_frame(anim, t)
			sf.set_animation_speed(anim, 12.0)
			sf.set_animation_loop(anim, anim in ["pose", "walk", "crouch"])
	# clips REALES de ROUM que ya existan (pose + walk + crouch; los demás cuando lleguen).
	# crouch loop=FALSE: se agacha UNA vez y retiene (el motor lo levanta con play_backwards al soltar).
	var reg := {"pose": [28.0, true], "walk": [52.0, true], "crouch": [160.0, false],
		"punch": [170.0, false], "kick": [160.0, false], "jump": [120.0, false],
		"weak_punch": [175.0, false], "spin_kick": [165.0, false],
		"crouch_jab": [165.0, false], "crouch_punch": [158.0, false], "crouch_kick": [160.0, false],
		"sweep": [155.0, false], "jump_punch": [170.0, false], "jump_kick": [165.0, false],
		"air_jab": [170.0, false], "air_spin_kick": [165.0, false],
		"ground_grab": [100.0, false], "get_pull": [12.0, true], "victory": [24.0, false],
		"void_cast": [75.0, false], "warp_grab": [90.0, false], "pit_grab": [90.0, false],
		"uppercut": [30.0, false],
		"block": [110.0, false], "block_low": [90.0, false], "parry": [90.0, false],   # DEFENSA: guardia X (de pie/agachado) + desvío Q+W
		"take_hit": [160.0, false], "take_hit_low": [160.0, false],
		"hit_fly": [60.0, false], "ko": [100.0, false], "hit_down": [14.0, false]}   # take_hit/low=REACCIÓN a golpes (de pie, alto/bajo); hit_fly=sale VOLANDO (tendido, anclaje por cuerpo); ko=KO boca arriba (tendido); weak_punch=EMPUJÓN; spin_kick=CABEZAZO; crouch_jab/kick=DOBLE golpe bajo; crouch_punch=puño agachado; sweep=BARRIDA (↓E); get_pull=HALADO (víctima, loop); void_cast=SÚPER vendas; warp_grab=AGARRE por portal; pit_grab=ANTI-AÉREO; uppercut=LANZADOR
	for accion in reg:
		var fr := _roum_action_frames(accion)
		if fr.size() > 1:
			if not sf.has_animation(accion):
				sf.add_animation(accion)
			sf.clear(accion)
			for t in fr:
				sf.add_frame(accion, t)
			sf.set_animation_speed(accion, reg[accion][0])
			sf.set_animation_loop(accion, reg[accion][1])
	# ATAQUES que ROUM aún NO tiene clip: dejarlos CORTOS (~6 frames de pose) para que NO CONGELEN
	# el modelo ~12s (145 frames de pose @12fps) al dispararse. Se dispara la anim, hace un flash
	# breve y vuelve a neutral (sin golpe) hasta que llegue su clip. NO toca take_hit/block/ko.
	if not pose.is_empty():
		var stub: Array = pose.slice(0, mini(6, pose.size()))
		for a in ["fly_straight", "wall_splat"]:
			if sf.has_animation(a) and _roum_action_frames(a).is_empty():
				sf.clear(a)
				for t in stub:
					sf.add_frame(a, t)
				sf.set_animation_speed(a, 26.0)
				sf.set_animation_loop(a, false)
		# KO AÉREO: ROUM no tiene ko_air propio; QUITARLO hace que al aterrizar del vuelo (hit_fly)
		# caiga en su "ko" REAL (tendido boca arriba) en vez del pose-placeholder (se quedaba PARADO
		# y no-sólido, caminabas a través). El aterrizaje KO cae al else que juega "ko" (fighter.gd).
		if sf.has_animation("ko_air") and _roum_action_frames("ko_air").is_empty():
			sf.remove_animation("ko_air")
		# PUMMELED: ROUM no tiene ese clip (lo heredaba del .tres como POSE placeholder). QUITARLO hace
		# que al RECIBIR un ultra caiga al take_hit/take_hit_low REAL en vez de quedarse PARADO en su pose.
		if sf.has_animation("pummeled") and _roum_action_frames("pummeled").is_empty():
			sf.remove_animation("pummeled")
	return sf

# Zetma usa el .tres base (estructura de anims). Sobreescribe con SUS clips a medida que
# llegan; las que aún NO tiene se rellenan con su POSE (placeholder — siempre se ve a Zetma,
# nunca a DAM). Registra cada anim de zetma/<accion>/ que exista.
func _build_zetma_frames() -> SpriteFrames:
	var sf := load("res://fighter_frames.tres").duplicate(true) as SpriteFrames
	var pose := _zetma_action_frames("pose")
	if not pose.is_empty():
		# la POSE de Zetma reemplaza el idle Y sirve de placeholder para TODA anim aún sin arte
		for anim in sf.get_animation_names():
			sf.clear(anim)
			for t in pose:
				sf.add_frame(anim, t)
			sf.set_animation_speed(anim, 12.0)
			sf.set_animation_loop(anim, anim in ["pose", "walk", "crouch"])
	# clips REALES de Zetma que ya existan (se van sumando): pose ya está; las demás cuando lleguen
	# velocidades: media (assassin ágil PERO <=~60fps para que se VEAN todos los frames en
	# pantalla de 60fps; más rápido "corta" frames). El walk sincroniza con spd en _apply_char.
	# crouch loop=FALSE: se agacha UNA vez y retiene (el motor lo levanta con play_backwards
	# al soltar abajo). Con loop=true repetía el agacharse y no dejaba levantarse.
	# golpes RÁPIDOS (NINJA veloz, pedido reiterado): los clips se recortan a su ventana ACTIVA y
	# además van a 90fps (antes 60). La regla "no cortar frames" = NO submuestrear al EXTRAER +
	# AJUSTAR fps para la velocidad; los frames TODOS existen, la pantalla de 60Hz solo muestra un
	# subset (~2/3) — aceptado a cambio de que los golpes se sientan de ninja. hit_frame es índice
	# de frame, así que el impacto cae en el mismo cuadro, solo llega antes (hitboxes intactas).
	# ~90fps -> weak_punch(54f)≈0.6s, kick(59f)≈0.65s, crouch_kick(28f)≈0.31s, spin_kick(31f)≈0.34s.
	# NO subir pose/walk/crouch (idle/desplazamiento sincronizan con otra cosa). walk 43fps.
	var reg := {
		"pose": [26.0, true], "walk": [43.0, true], "jump": [60.0, false],
		"crouch": [56.0, false], "crouch_up": [56.0, false], "punch": [120.0, false],
		"kick": [120.0, false], "weak_punch": [120.0, false], "spin_kick": [120.0, false],
		"crouch_punch": [120.0, false], "sweep": [120.0, false],
		"crouch_kick": [120.0, false], "crouch_jab": [120.0, false],
		"jump_punch": [120.0, false],
		"jump_kick": [85.0, false],
		"air_spin_kick": [85.0, false],
		"air_jab": [120.0, false],
		"block_low": [90.0, false],
		"block": [110.0, false],
		"take_hit": [48.0, false], "take_hit_low": [48.0, false],
		"hit_fly": [95.0, false], "hit_down": [48.0, false],
		"pummeled": [40.0, true],
		"get_up": [20.0, false], "ko": [60.0, false],   # levantada RÁPIDA (~0.30s, pedido)
		"ground_grab": [105.0, false],   # gancho tipo Scorpion (↓→Q suelo): garfio out ~f49 = 0.47s
		"orb_cast": [24.0, false],   # ESPECIAL: brazo->cañón carga la orb morada (12f)
		"air_grab": [105.0, false],      # gancho AÉREO (↓→Q en el aire): garra abajo-adelante
		"victory": [48.0, false],        # VICTORIA: parado, se vira, se quita la máscara, cae el pelo morado (91f ~1.9s, retiene)
	}
	if not sf.has_animation("crouch_up"):
		sf.add_animation("crouch_up")
	for accion in reg:
		var fr := _zetma_action_frames(accion)
		if fr.size() > 1:
			if not sf.has_animation(accion):
				sf.add_animation(accion)   # anims NUEVAS (ground_grab, air_grab) no están en el .tres base
			sf.clear(accion)
			for t in fr:
				sf.add_frame(accion, t)
			sf.set_animation_speed(accion, reg[accion][0])
			sf.set_animation_loop(accion, reg[accion][1])
	return sf

func _build_dam_frames() -> SpriteFrames:
	var sf := load("res://fighter_frames.tres") as SpriteFrames
	# jump NUEVO (8 frames del clip: agacharse->despegue->vuelo->pose de caída al final;
	# el .tres solo traía 4) + land (5 frames: toque->flexión profunda->recuperación)
	var djn := _dam_action_frames("jump")
	if djn.size() > 4:
		sf.clear("jump")
		for t in djn:
			sf.add_frame("jump", t)
		sf.set_animation_speed("jump", 14.0)
	# estados ESTÁNDAR compartidos (GUIA-COMUN), solo si ya hay frames en dam/<estado>/
	_register_shared_anim(sf, "frozen", _dam_action_frames("frozen"), 12.0)
	_register_shared_anim(sf, "electrocuted", _dam_action_frames("electrocuted"), 24.0)
	_register_shared_anim(sf, "step", _dam_action_frames("step"), 30.0, false)
	_register_shared_anim(sf, "backdash", _dam_action_frames("backdash"), 30.0, false)
	var dln := _dam_action_frames("land")
	if not dln.is_empty() and not sf.has_animation("land"):
		sf.add_animation("land")
		sf.set_animation_loop("land", false)
		sf.set_animation_speed("land", 15.0)
		for t in dln:
			sf.add_frame("land", t)
	# E: TORBELLINO (clip hit-e RECUPERADO, 71 frames): giro con arcos propios + remate
	# en dam-pose-1. 95fps ~0.75s, 2 golpes (uno por vuelta) que ahora SI cuentan 2.
	var dsk := _dam_action_frames("spin_kick")
	if dsk.size() > 8:
		sf.clear("spin_kick")
		for t in dsk:
			sf.add_frame("spin_kick", t)
		sf.set_animation_speed("spin_kick", 95.0)
	# CROUCH v2 (clip crouch.mp4, 33 frames): parado -> rodilla en tierra con la espada al
	# frente. Sostiene el ultimo frame abajo; se levanta en REVERSA (logica generica).
	var dcr := _dam_action_frames("crouch")
	if dcr.size() > 8:
		sf.clear("crouch")
		for t in dcr:
			sf.add_frame("crouch", t)
		sf.set_animation_speed("crouch", 100.0)   # ~0.33s: responsivo (bloqueo bajo)
	# INFERNO CAST (clip, 130 frames, zoom anulado): espada al hombro -> palma -> canaleo
	# con viento. No-loop 70fps ~1.9s: la ventana del rito (~1.05s) muestra intro + hold.
	var difc := _dam_action_frames("inferno_cast")
	if not difc.is_empty():
		if not sf.has_animation("inferno_cast"):
			sf.add_animation("inferno_cast")
		sf.clear("inferno_cast")
		sf.set_animation_loop("inferno_cast", false)
		sf.set_animation_speed("inferno_cast", 95.0)   # SYNC (pedido): la palma se extiende a ~0.48s, a MITAD de la bola (build 0.85s)
		for t in difc:
			sf.add_frame("inferno_cast", t)
	# BLOCK v2 (clip block, frames 1-21 pre-zoom): alza el espadón VERTICAL como escudo
	# y se asienta. TRIPLE de rápido (pedido): 135fps ≈ 0.16s — la guardia sube al instante.
	var dblk := _dam_action_frames("block")
	if dblk.size() > 8:
		sf.clear("block")
		sf.set_animation_loop("block", false)
		sf.set_animation_speed("block", 135.0)
		for t in dblk:
			sf.add_frame("block", t)
	# HIT_FLY v2 (clip hit-fly f21-95): VUELO ragdoll noqueado — arqueado, brazos sueltos,
	# espada abrazada al cuerpo. Cuerpo centrado en (650,670) como el de Fe. 60fps.
	var dhf := _dam_action_frames("hit_fly")
	if dhf.size() > 8:
		sf.clear("hit_fly")
		sf.set_animation_loop("hit_fly", false)
		sf.set_animation_speed("hit_fly", 60.0)
		for t in dhf:
			sf.add_frame("hit_fly", t)
	# HIT_DOWN v2 (clip hit-fly f96-145): el ESTRELLÓN — choca de espaldas, rebota,
	# desliza y queda tendido (retiene el último cuadro). 45fps.
	var dhd := _dam_action_frames("hit_down")
	if dhd.size() > 8:
		if not sf.has_animation("hit_down"):
			sf.add_animation("hit_down")
		sf.clear("hit_down")
		sf.set_animation_loop("hit_down", false)
		sf.set_animation_speed("hit_down", 45.0)
		for t in dhd:
			sf.add_frame("hit_down", t)
	# GET_UP v3 (12 frames sueltos de get-up-frames, normalizados por masa): tendido ->
	# se incorpora -> rodilla con la espada -> se para a su guardia (empalma exacto:
	# tendido = canon 1019, guardia final = idle 650). 13fps ≈ 0.9s.
	var dgu := _dam_action_frames("get_up")
	if dgu.size() > 8:
		if not sf.has_animation("get_up"):
			sf.add_animation("get_up")
		sf.clear("get_up")
		sf.set_animation_loop("get_up", false)
		sf.set_animation_speed("get_up", 38.0)   # levantada RÁPIDA (pedido): ~0.32s (todos se levantan rápido)
		for t in dgu:
			sf.add_frame("get_up", t)
	# GET-PULL (víctima halada por el gancho de Zetma): frames 1-5 = jalón HORIZONTAL desde el
	# suelo (get_pull, anclado por pies); 6-10 = yankeado al AIRE (get_pull_air, cuerpo centrado).
	var dgp := _dam_action_frames("get_pull")
	if dgp.size() > 1:
		if not sf.has_animation("get_pull"):
			sf.add_animation("get_pull")
		sf.clear("get_pull")
		sf.set_animation_loop("get_pull", true)
		sf.set_animation_speed("get_pull", 12.0)
		for t in dgp:
			sf.add_frame("get_pull", t)
	var dgpa := _dam_action_frames("get_pull_air")
	if dgpa.size() > 1:
		if not sf.has_animation("get_pull_air"):
			sf.add_animation("get_pull_air")
		sf.clear("get_pull_air")
		sf.set_animation_loop("get_pull_air", true)
		sf.set_animation_speed("get_pull_air", 12.0)
		for t in dgpa:
			sf.add_frame("get_pull_air", t)
	# KO v2 (clip ko-face-up, 121 frames, canvas 1920): KO de pie — se tambalea, se
	# DERRUMBA de espaldas y queda tendido BOCA ARRIBA con la katana caída al lado
	# (canon de DAM). Mapeo fijo, pies plantados. 60fps ≈ 1.2s de desplome + tendido.
	var dko := _dam_action_frames("ko")
	if dko.size() > 8:
		sf.clear("ko")
		sf.set_animation_loop("ko", false)
		sf.set_animation_speed("ko", 72.0)   # desplome ágil (~1.7s con el tendido)
		for t in dko:
			sf.add_frame("ko", t)
	# PARRY v2 (clip parry, 145 frames): SNAP a la pose de desvío (espada diagonal) y la
	# SOSTIENE. Anclada por las botas (clavada en el sitio). 90fps: snap ~0.17s (dentro de
	# la ventana de 0.5s), retiene el último cuadro si la ventana dura más.
	var dpry := _dam_action_frames("parry")
	if dpry.size() > 8:
		if not sf.has_animation("parry"):
			sf.add_animation("parry")
		sf.clear("parry")
		sf.set_animation_loop("parry", false)
		sf.set_animation_speed("parry", 90.0)
		for t in dpry:
			sf.add_frame("parry", t)
	# VICTORIA v2 (clip victory, 145 frames): floreo -> clava la espada -> se yergue ->
	# RUGIDO -> sostiene la pose. Anclada por los pies. 78fps ≈ 1.85s, retiene el último.
	var dvic := _dam_action_frames("victory")
	if dvic.size() > 8:
		if not sf.has_animation("victory"):
			sf.add_animation("victory")
		sf.clear("victory")
		sf.set_animation_loop("victory", false)
		sf.set_animation_speed("victory", 24.0)   # velocidad ORIGINAL del clip: el audio
		for t in dvic:                            # (slam ~1.3s, rugido ~3s) casa exacto
			sf.add_frame("victory", t)
	# KO_AIR v2 (clip ko-fly f19-121, canvas 1920): el KO del último golpe — sale
	# volando en volteretas y cae TENDIDO (el aterrizaje congela el último cuadro,
	# anclado al suelo; el vuelo va anclado por el cuerpo). 70fps.
	var dka := _dam_action_frames("ko_air")
	if dka.size() > 8:
		if not sf.has_animation("ko_air"):
			sf.add_animation("ko_air")
		sf.clear("ko_air")
		sf.set_animation_loop("ko_air", false)
		sf.set_animation_speed("ko_air", 110.0)   # rápido: que el vuelo no se quede atrás de la caída real
		for t in dka:
			sf.add_frame("ko_air", t)
	# BLOCK_LOW v2 (clip block_low, 145 frames SIN zoom): cuclillas profundas con el
	# espadón HORIZONTAL sobre la cabeza como techo; ciclos de compresión al aguantar.
	# 60fps: entrada ~0.22s y el resto es el aguante (cada golpe bloqueado la reinicia).
	var dblo := _dam_action_frames("block_low")
	if dblo.size() > 8:
		sf.clear("block_low")
		sf.set_animation_loop("block_low", false)
		sf.set_animation_speed("block_low", 60.0)
		for t in dblo:
			sf.add_frame("block_low", t)
	# CASTEO del BERSERK (clip cast-berseke, 145 frames): alza el poder, EXPLOTA en
	# energía (~f52) y queda en la postura de rabia. 130fps ≈ 1.1s (pedido: más rápida).
	var dbrk := _dam_action_frames("berserk_cast")
	if not dbrk.is_empty():
		if not sf.has_animation("berserk_cast"):
			sf.add_animation("berserk_cast")
		sf.clear("berserk_cast")
		sf.set_animation_loop("berserk_cast", false)
		sf.set_animation_speed("berserk_cast", 130.0)
		for t in dbrk:
			sf.add_frame("berserk_cast", t)
	# TAKE_HIT v2 (clip take-hit, frames 1-33): latigazo de cabeza/torso hacia ATRÁS al
	# recibir golpe de pie y recupera la guardia. 120fps ≈ 0.27s, seco como el de Fe.
	var dth := _dam_action_frames("take_hit")
	if dth.size() > 8:
		sf.clear("take_hit")
		sf.set_animation_loop("take_hit", false)
		sf.set_animation_speed("take_hit", 120.0)
		for t in dth:
			sf.add_frame("take_hit", t)
	# TAKE_HIT_LOW v2 (clip take_hit_lower, frames 1-71): golpe BAJO — se DOBLA con la
	# cabeza a la cintura, aguanta encogido y se yergue. 130fps ≈ 0.55s.
	var dthl := _dam_action_frames("take_hit_low")
	if dthl.size() > 8:
		sf.clear("take_hit_low")
		sf.set_animation_loop("take_hit_low", false)
		sf.set_animation_speed("take_hit_low", 130.0)
		for t in dthl:
			sf.add_frame("take_hit_low", t)
	# ↓E v2 (clip sweep, 62 frames): BARRIDO derribador a ras del piso. 120fps ~0.52s.
	var dswv := _dam_action_frames("sweep")
	if dswv.size() > 12:
		sf.clear("sweep")
		for t in dswv:
			sf.add_frame("sweep", t)
		sf.set_animation_speed("sweep", 120.0)
	# ↓R v3 (clip crouch-jab, 60 frames): estocada + GIRO DE HOJA = DOS golpes. 120fps ~0.5s.
	var dcjv := _dam_action_frames("crouch_jab")
	if dcjv.size() > 8:
		sf.clear("crouch_jab")
		for i in dcjv.size():
			# el GIRO DE HOJA (frames 33+) va a camara mas lenta (x1.7) — a velocidad
			# plana casi no se leia (pedido); la estocada mantiene su snap
			sf.add_frame("crouch_jab", dcjv[i], 1.0 if i < 33 else 1.7)
		sf.set_animation_speed("crouch_jab", 120.0)
	# ↓W v2 (clip crouch-kick, 74 frames): GANCHO ASCENDENTE con arco propio del clip;
	# recuperacion que TERMINA AGACHADA. 120fps ~0.62s (lanzador pesado).
	var dckv := _dam_action_frames("crouch_kick")
	if dckv.size() > 12:
		sf.clear("crouch_kick")
		for t in dckv:
			sf.add_frame("crouch_kick", t)
		sf.set_animation_speed("crouch_kick", 120.0)
	# ↓Q v3 (clip crouch-punch NUEVO, 62 frames): carga sobre la cabeza + TAJO + estocada
	# extendida + recuperacion que TERMINA AGACHADA. 120fps ~0.52s (pesado con autoridad).
	var dcp := _dam_action_frames("crouch_punch")
	if dcp.size() > 8:
		sf.clear("crouch_punch")
		for t in dcp:
			sf.add_frame("crouch_punch", t)
		sf.set_animation_speed("crouch_punch", 120.0)
	# R POGO (clip hit-r, 43 frames): las TRES patadas apoyado en la espada — cada una
	# levanta RECTO y la siguiente lo recoge (pedido).
	var dwp := _dam_action_frames("weak_punch")
	if dwp.size() > 8:
		sf.clear("weak_punch")
		for t in dwp:
			sf.add_frame("weak_punch", t)
		sf.set_animation_speed("weak_punch", 45.0)   # POGO: ~0.27s entre patadas (el rival sube y cae justo)
	# W v3 (clip kick-2 NUEVO, 43 frames): MACHETAZO — alza a coil + descarga baja con
	# follow; remata dam-pose-1. Reemplaza el tajo de kick.mp4 (no gusto). 90fps ~= 0.48s.
	var dkw := _dam_action_frames("kick")
	if dkw.size() > 12:
		sf.clear("kick")
		for t in dkw:
			sf.add_frame("kick", t)
		sf.set_animation_speed("kick", 90.0)
	# PUNCH v2 (clip punsh.mp4, 48 frames): carga enroscada -> TAJO smear (f12-16) ->
	# LUNGE extendido -> recuperacion. 105fps ~= 0.46s (el viejo de 6 frames iba en 0.43s).
	var dpn := _dam_action_frames("punch")
	if dpn.size() > 8:
		sf.clear("punch")
		for t in dpn:
			sf.add_frame("punch", t)
		sf.set_animation_speed("punch", 105.0)
	# jump_punch NUEVO (8 frames: espada arriba -> TAJO down-forward -> follow; el .tres traía 3)
	var djp := _dam_action_frames("jump_punch")
	if djp.size() > 4:
		sf.clear("jump_punch")
		for t in djp:
			sf.add_frame("jump_punch", t)
		sf.set_animation_speed("jump_punch", 42.0)   # aéreas MUY rápidas
	# SALTO+R NUEVO (clip jum-mortal): MORTAL completo, reemplaza el doble corte air_jab
	var daj := _dam_action_frames("air_jab")
	if daj.size() > 4:
		sf.clear("air_jab")
		for t in daj:
			sf.add_frame("air_jab", t)
		sf.set_animation_speed("air_jab", 92.0)   # mortal en ~0.47s (aéreas MUY rápidas)
	# SALTO+E NUEVO (clip jump_kick_2): PATADA VOLADORA, reemplaza el air_spin_kick viejo
	var dask := _dam_action_frames("air_spin_kick")
	if dask.size() > 6:
		sf.clear("air_spin_kick")
		for t in dask:
			sf.add_frame("air_spin_kick", t)
		sf.set_animation_speed("air_spin_kick", 95.0)   # voladora en ~0.56s
	# jump_kick NUEVO (6 frames: espada arriba en el salto -> TAJO que baja; el .tres traía 3)
	var djk := _dam_action_frames("jump_kick")
	if djk.size() > 4:
		sf.clear("jump_kick")
		for t in djk:
			sf.add_frame("jump_kick", t)
		sf.set_animation_speed("jump_kick", 70.0)   # MOLINETE: 65 frames (~0.93s) — hélice veloz, 3 pasadas
	# walk NUEVO: el ciclo del arte cubre 840px de lienzo (924 en pantalla) y su velocidad
	# (620*0.65*1.1 = 443px/s) recorre eso en 2.08s -> 24 frames a 11.5fps = CERO patinaje
	# (el .tres solo traía 8 frames w1-w8: se limpia y se recarga desde la carpeta)
	var dwn := _dam_action_frames("walk")
	if dwn.size() > 8:
		sf.clear("walk")
		for t in dwn:
			sf.add_frame("walk", t)
	sf.set_animation_speed("walk", 11.5)
	# CONGELADO estándar (GUIA-COMUN): se registra solo si ya hay frames en dam/frozen/
	var dfz := _dam_action_frames("frozen")
	if not dfz.is_empty() and not sf.has_animation("frozen"):
		sf.add_animation("frozen")
		sf.set_animation_loop("frozen", true)
		sf.set_animation_speed("frozen", 12.0)
		for t in dfz:
			sf.add_frame("frozen", t)
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

func _stage_dust_tint() -> Color:
	# el POLVO (jump/dash/slam) toma un color acorde al escenario: en stages OSCUROS (ciudad
	# ruinosa / noche) un azul frío oscuro para que no resalte como nube blanca brillante;
	# en los CLAROS (templo / santuario) blanco natural. STAGE: 1=ciudad 2=noche 3=templo 4=santuario.
	match STAGE:
		1, 2:
			return Color(0.42, 0.50, 0.72)   # azul frío OSCURO (ciudad/noche)
		_:
			return Color(1, 1, 1)            # claro: polvo natural
	return Color(1, 1, 1)

func _apply_char(f: Node2D, id: String) -> void:
	var c := _char_data(id)
	f.archetype = String(c["arch"])
	f.fx_blue = id == "favi"   # estela del arma AZUL para Favi (naranja fuego para DAM)
	if id == "favi":
		f.swing_y_off = 144.0   # sus frames llevan el cuerpo MÁS ABAJO en el lienzo (coronilla 644 vs 500 de DAM): baja las estelas a su cuerpo
	f.fx_floral = id == "aye"  # estela MORADA+ROSA para Aye (se resetea para los demas)
	f.fx_dark = id == "zetma"  # ZETMA (ninja oscuridad): usa el audio propio de cada clip
	f.fx_warrior = id == "roum"  # ROUM (tanque): estela SMOKY carmesí-negra + tabla propia (retimada al golpe)
	f.dust_tint = _stage_dust_tint()   # el POLVO toma el color del escenario (azul oscuro en stages oscuros)
	# ALTURA corporal real vs DAM (arte 638×1.10=702): Fe 496×1.0=496 -> 0.71;
	# Aye 632×0.72=455 -> 0.65. Escala alcances verticales y chispas de impacto.
	f.body_k = 1.15 if id == "roum" else (0.78 if id == "zetma" else (0.71 if id == "favi" else (0.60 if id == "aye" else 1.0)))   # AYE-2 idol = la MÁS chica (0.60); ROUM el más GRANDE; Zetma más bajo que DAM
	# medio ANCHO para el empuje al caminar: DAM abre una postura ANCHA, Aye es diminuta.
	# Separacion minima de una pareja = suma (DAM+Aye 210, Fe+Aye 165, DAM+Fe 225 como antes)
	f.body_halfw = 130.0 if id == "zetma" else (90.0 if id == "favi" else (75.0 if id == "aye" else 150.0))   # Zetma: stance ninja medio
	if id == "favi":
		f.sprite.sprite_frames = _build_favi_frames()
		_fix_placeholders(f.sprite.sprite_frames, _favi_action_frames)   # nada de arte de DAM
		# base_scale (no sprite.scale directo): el efecto squash del fighter reescribe
		# sprite.scale cada frame, así que la escala de personaje va en base_scale.
		f.base_scale = Vector2(FAVI_SCALE, FAVI_SCALE)
		f.sprite.scale = f.base_scale
		# anclar los PIES al MISMO piso que DAM (escala 1.0): que no floten ni se hundan.
		f.sprite.offset = Vector2(0, FAVI_FEET_FROM_CENTER / FAVI_SCALE - FAVI_FEET_FROM_CENTER)
		f.spd = FAVI_SPD   # desplazamiento más rápido para acompañar la animación ágil
	elif id == "aye":
		# SLOT AYE = la nueva AYE-2 (idol de esferas). Skin por lado (Sel.p1/p2_skin).
		var skin: String = Sel.p1_skin if f == player else Sel.p2_skin
		f.sprite.sprite_frames = _build_aye2_frames(skin)
		_fix_placeholders(f.sprite.sprite_frames, func(a): return _aye2_action_frames(a, skin))
		f.base_scale = Vector2(AYE2_SCALE, AYE2_SCALE)
		f.sprite.scale = f.base_scale
		f.sprite.offset = Vector2(0, AYE2_FEET_FROM_CENTER / AYE2_SCALE - AYE2_FEET_FROM_CENTER)
		f.spd = AYE2_MOVE_SPD
		f.jump_mult = 1.12
	elif id == "zetma":
		f.sprite.sprite_frames = _build_zetma_frames()
		_fix_placeholders(f.sprite.sprite_frames, _zetma_action_frames)   # nada de arte de DAM
		f.base_scale = Vector2(ZETMA_SCALE, ZETMA_SCALE)
		f.sprite.scale = f.base_scale
		f.sprite.offset = Vector2(0, ZETMA_FEET_FROM_CENTER / ZETMA_SCALE - ZETMA_FEET_FROM_CENTER)
		f.spd = 1.7   # desplazamiento (ninja ágil): sincroniza con el walk a 35fps y su zancada nueva (larga) para que NO patine
		f.jump_mult = 1.28   # ninja ÁGIL: salta ALTO (antes 1.0 = el más bajo de todos)
	elif id == "roum":
		f.sprite.sprite_frames = _build_roum_frames()
		_fix_placeholders(f.sprite.sprite_frames, _roum_action_frames)   # nada de arte de DAM
		f.base_scale = Vector2(ROUM_SCALE, ROUM_SCALE)
		f.sprite.scale = f.base_scale
		f.sprite.offset = Vector2(0, ROUM_FEET_FROM_CENTER / ROUM_SCALE - ROUM_FEET_FROM_CENTER)
		f.spd = 1.03          # camina más rápido (pedido); walk 30->44 fps + spd 0.60->0.88 escalan JUNTOS para no patinar
		f.jump_mult = 1.35    # salta MÁS ALTO (pedido: que se levante más en el aire)
		f.body_halfw = 185.0  # CUERPO ANCHO: el más grande de todos (empuje al caminar)
	else:
		f.sprite.sprite_frames = _build_dam_frames()
		f.base_scale = Vector2(DAM_SCALE, DAM_SCALE)
		f.sprite.scale = f.base_scale
		f.sprite.offset = Vector2(0, DAM_FEET_FROM_CENTER / DAM_SCALE - DAM_FEET_FROM_CENTER)
		f.spd = 1.1   # con el walk nuevo (zancada larga, espada al frente) 0.9 lo hacía PATINAR: anim rápida y cuerpo lento. 1.1 + anim a 11fps sincronizan el paso
		f.jump_mult = 1.26   # el jump nuevo (impulso + vuelo recogido) pide MÁS altura (1.18 se quedaba corto)
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
func _fe_cast_fx(caster: Node2D, on: bool, body_dx := 0.0) -> void:
	# body_dx: offset local X del CUERPO vs el centro del nodo (el arte agachado de Fe
	# vive ~84px detrás del centro tras plantar los pies; se voltea con el facing)
	if on:
		if _fe_cast_mat == null:
			var sh := Shader.new()
			sh.code = _OUTLINE_CODE
			_fe_cast_mat = ShaderMaterial.new()
			_fe_cast_mat.shader = sh
			_fe_cast_mat.set_shader_parameter("line_color", Color(1.5, 1.7, 2.3, 1.0))  # BLANCO-azulado (energía pura, pivote del poder de Fe)
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
			p.color = Color(1.4, 1.6, 2.1, 0.9)   # blanco-azulado (energía pura)
			p.z_index = 4
			add_child(p)
			_fe_cast_particles = p
		_fe_cast_particles.global_position = caster.to_global(Vector2(body_dx * caster.facing, 320.0))  # torso de Fe
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
	get_tree().create_timer(0.55).timeout.connect(func() -> void:   # se apaga al terminar el cast (~50f @90)
		if is_instance_valid(caster): _fe_cast_fx(caster, false))
	# windup: el RAYO cae justo cuando el latigazo del thunder-cast baja (frame ~25 @90fps)
	await get_tree().create_timer(0.28).timeout
	if not is_instance_valid(caster) or not is_instance_valid(victima):
		return
	# NO auto-apunta: brota a 1/2/3 CUERPOS adelante de Fe (el jugador adivina la posición)
	var gx: float = caster.position.x + float(caster.facing) * GEYSER_BODY * float(bodies)
	gx = clampf(gx, 120.0, 1800.0)                        # dentro del escenario
	caster.spawn_water_geyser(gx)
	# FOGONAZO BLANCO de pantalla un instante: el flash del relámpago (el decay de
	# flash_ms lo desvanece solo en 0.3s)
	flash_rect.color = Color(1, 1, 1, 0.55)
	flash_ms = Time.get_ticks_msec()
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
		# el RAYO NO lanza (pedido): golpe seco en el sitio + ELECTROCUTADO — la víctima
		# parpadea blanco-azul semitransparente intermitente (electro_t en su cadena de tintes)
		var res: String = victima.receive_hit(false, false, dir, "kick_impact")
		if res == "hit" or res == "launched":
			victima.electro_t = 0.55
			var dmg: int = WATER_DMG[bodies - 1]
			_dmg_number(victima, dmg)
			if victima == dummy:
				dummy_hp = maxi(0, dummy_hp - dmg)
				if dummy_hp <= 0:
					if _round_real(): _end_round(true)
					else: dummy_hp = hp_max[1]
			else:
				player_hp = maxi(0, player_hp - dmg)
				if player_hp <= 0:
					if _round_real(): _end_round(false)
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
			_dmg_number(victima, dmg)
			if victima == dummy:
				dummy_hp = maxi(0, dummy_hp - dmg)
				if dummy_hp <= 0:
					if _round_real(): _end_round(true)
					else: dummy_hp = hp_max[1]
			else:
				player_hp = maxi(0, player_hp - dmg)
				if player_hp <= 0:
					if _round_real(): _end_round(false)
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
		# ANILLO de recurso: magos (wizard = maná), FE (assassin = INSTINTO de las
		# marcas: se llena con tiempo, el crítico lo vacía) y DAM (RABIA: se llena al
		# perder vida, E+R lleno = berserk)
		var is_mage: bool = String(c.get("arch", "")) == "wizard" or String(c["id"]) == "favi"
		mana_is_mage[side] = is_mage
		rage_side[side] = String(c["id"]) == "dam"
		orb_side[side] = String(c["id"]) == "zetma"   # anillo de carga del ORB abajo (estilo maná)
		void_side[side] = String(c["id"]) == "roum"   # anillo VOID de ROUM (mismo slot)
		rage[side] = 0.0
		rage_on[side] = false
		rage_prev_hp[side] = -1
		void_charge[side] = 0.0                         # arranca vacío cada round
		void_prev_foe_hp[side] = -1
		var ring_on: bool = is_mage or rage_side[side] or orb_side[side] or void_side[side]
		if mana_hud[side] != null:
			mana_hud[side].visible = ring_on
		if ring_on and mana_avatar[side] != null and ResourceLoader.exists(String(c["avatar"])):
			mana_avatar[side].texture = load(String(c["avatar"]))
			_cover_avatar(mana_avatar[side], MANA_AV_BOX, MANA_AV_BOX)
			mana_avatar[side].flip_h = side == 1

func _start_round() -> void:
	state = "intro"
	# por si el round anterior terminó con el VOID LAUNCH de Zetma (rival oculto/rotado): restaurar
	for _f in [player, dummy]:
		if _f != null:
			_f.visible = true
			_f.koed = false
			_f.ultra_hover = false
			_f.hit_flying = false
			if _f.sprite != null:
				_f.sprite.rotation = 0.0
	Sel.stop_menu_music()   # empieza la pelea: corta la canción del menú
	_apply_char(player, selected_char)          # personaje del jugador (frames + arquetipo + escala)
	_apply_char(dummy, cpu_char)                # el rival (P2/CPU): el que eligió el jugador en el 2do paso
	_apply_alt_colors()                         # P2 con otro tono (mirror match, distinguir P1/P2)
	# los SpriteFrames ya referencian sus texturas: soltar la precarga del char-select
	# (las usadas quedan vivas; las de más se liberan). Ver Sel.warm_cache.
	if not Sel.warm_cache.is_empty():
		Sel.warm_cache.clear()
	hp_max[0] = int(ARCH_HP.get(player.archetype, 1200))
	hp_max[1] = int(ARCH_HP.get(dummy.archetype, 1200))
	# ORBES DE AYE-2: si algún lado es Aye (fx_floral), crea sus 3 orbes orbitando.
	if player.fx_floral:
		_orb_setup_for(player, 0)
	if dummy.fx_floral:
		_orb_setup_for(dummy, 1)
	_refresh_hud_chars()
	_set_inputs(false)
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
	meter = [METER_MAX, METER_MAX]   # arranca con las barras CARGADAS (pedido del usuario)
	mana = [1.0, 1.0]        # mana lleno al empezar la ronda (los magos arrancan con hechizos)
	mana_flash_t = [0.0, 0.0]
	mana_full_flash_t = [0.0, 0.0]
	mana_was_full = [true, true]   # arranca full: no destella en el intro
	orb_charge = [1.0, 1.0]   # ESPECIAL de Zetma: arranca CARGADO (para probar sin esperar)
	orb_used = [false, false]
	danger_round_shown = false   # DANGER: se rearma cada round (el primer player que caiga a ≤25%)
	rounds_label.text = "%d  -  %d" % [wins_p1, wins_p2]
	announce.visible = false
	# CONTADOR del round a 99 y marcadores P1/P2 sobre las cabezas (VS 2P)
	match_time = MATCH_TIME
	if timer_label != null:
		timer_label.text = str(int(MATCH_TIME))
		timer_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_show_player_tags()
	# BANDA "ROUND 2 / ROUND 3" al empezar un round NUEVO (round_num ya viene incrementado); el round 1
	# va directo al READY. Se muestra, se espera, y recién ahí arranca READY → FIGHT.
	if round_num >= 2:
		_show_round_band("ROUND %d" % round_num, 1.30)
		await get_tree().create_timer(1.25).timeout
	# BANDA morada animada: READY entra por la izq y sale por la der, luego FIGHT.
	# Voz sintetizada (misma fórmula que inferno/apocalypse) al aparecer cada palabra.
	_show_round_band("READY", 1.45, "GET READY")   # centro "READY", bordes verdes "GET READY"
	_play_voz("ready")
	await get_tree().create_timer(1.40).timeout
	_show_round_band("FIGHT", 1.30)
	_play_voz("fight")
	await get_tree().create_timer(0.80).timeout
	state = "fight"
	_set_inputs(true)
	dummy.ai_enabled = dummy_ai_mode
	dummy.ai_break_drill = break_practice   # en BREAK PRACTICE la IA se lanza a encadenar combos

# ===== MARCAS de Fe (mecánica firma del assassin) =====
# Cada 3 golpes ENCADENADOS de Fe plantan una MARCA en el rival (diamantes azules sobre
# su cabeza). Con 3 marcas, el PRÓXIMO golpe FÍSICO revienta un CRÍTICO fijo de 300
# (número gigante) y consume las marcas. Sin marcar en un rato, se van cayendo de a una.
var fe_marks := [0, 0]          # marcas puestas POR el lado i (viven en su rival)
var fe_mark_decay := [0.0, 0.0]
const FE_MARK_MAX := 3
const FE_MARK_DECAY := 6.0      # segundos sin marcar para que se caiga una
const FE_CRIT_DMG := 300

func _fe_add_mark(idx: int) -> void:
	# INSTINTO (anillo tipo maná, azul): las marcas SOLO se acumulan con el anillo
	# LLENO — así no puede aplicar la mecánica todo el tiempo. Sin instinto: blink rojo.
	if mana[idx] < 0.999:
		mana_flash_t[idx] = 0.5
		return
	fe_mark_decay[idx] = FE_MARK_DECAY
	if fe_marks[idx] >= FE_MARK_MAX:
		return
	fe_marks[idx] += 1
	var victima: Node2D = dummy if idx == 0 else player
	if is_instance_valid(victima):
		victima.set_fe_marks(fe_marks[idx])

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
	# BERSERK de DAM: pega más duro mientras dura la rabia
	if is_instance_valid(atk_f) and atk_f.rage_mode:
		dmg = int(round(float(dmg) * RAGE_DMG))
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
	# MARCA de Fe: cada 3 golpes encadenados planta una marca en el rival
	if is_instance_valid(atk_f) and atk_f.fx_blue and combo_n[idx] % 3 == 0:
		_fe_add_mark(idx)
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
		_combo_display(idx, combo_n[idx])
		c.modulate = Color(1, 1, 1, 1)
		c.scale = Vector2(1.35, 1.35)
		c.visible = true
	return dmg_real

# cartel de combo estilo READY/FIGHT: NÚMERO grande + "HIT" sobre una mini banda roja inclinada.
# nombre != "" (ultras: APOCALYPSE...) agrega el label extra debajo.
func _combo_display(idx: int, n: int, nombre := "") -> void:
	combo_num_lbl[idx].text = str(n)
	combo_hit_lbl[idx].text = "HIT" if n == 1 else "HITS"
	combo_nom[idx].text = nombre
	combo_nom[idx].visible = nombre != ""

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
	# REGLA (pedido): los ULTRAS solo con los PIES EN EL SUELO — golpeando en el aire fallan
	if atacante.airborne or atacante.hit_flying or atacante.position.y < atacante.floor_y - 4.0:
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
	# sin nombre forzado, la placa trae el RANGO normal (DOUBLE, TRIPLE, ...); el nombre
	# del ultra (APOCALYPSE, etc.) solo se muestra en el remate como label extra
	_combo_display(idx, n, nombre)
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
	_ultra_banner_name = "APOCALYPSE" if largo else "ANNIHILATION"
	state = "ultra"
	_set_inputs(false)
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
	if largo and atacante.fx_dark:
		total_golpes = ULTRA_FLURRY.size() * 2 + 6   # ZETMA: 2 tandas de SUELO + 6 golpes AÉREOS
	var drain := maxi(1, int(round(hp0 * 0.95 / float(total_golpes))))
	n = await _ultra_flurry(atacante, victima, idx, dir, n, drain)
	# APOCALIPSIS: 2ª tanda de SUELO. DAM/otros CRUZAN al otro lado; ZETMA se queda del MISMO lado (no se vira).
	if largo and state == "ultra":
		if not atacante.fx_dark:
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
	# APOCALIPSIS (largo, NO Zetma): pre-remate = PATADA GIRATORIA (→E) EN EL SITIO, sin empujar.
	# El rival se queda en el lugar y recibe el impacto. Luego viene el mortal (arriba E).
	if largo and not atacante.fx_dark and state == "ultra":
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
	# ZETMA APOCALYPSE: en vez de cruzar, LEVANTA al rival y remata el combo EN EL AIRE (POCOS golpes aéreos).
	if largo and atacante.fx_dark and state == "ultra":
		var _zairn := 6
		var _zlift: float = victima.floor_y - 300.0        # altura del juggle
		victima.airborne = true
		victima.hit_flying = false
		victima.ultra_hover = true                          # flota (no cae) durante la ráfaga aérea
		victima.vel_x = 0.0
		victima.vel_y = 0.0
		atacante.airborne = true
		atacante.vel_y = 0.0
		flash_ms = Time.get_ticks_msec()
		flash_rect.color = Color(0.55, 0.2, 1.0, 0.5)       # fogonazo MORADO (Zetma) al subir
		for _zi in _zairn:
			if state != "ultra":
				break
			var _zramp := float(_zi) / float(maxi(1, _zairn - 1))
			victima.position.y = _zlift
			atacante.position.y = _zlift + 20.0
			atacante.position.x = clampf(victima.position.x - float(dir) * 150.0, LEFT_LIMIT, RIGHT_LIMIT)
			atacante.set_facing(dir)
			victima.set_facing(-dir)
			atacante.sprite.speed_scale = lerpf(1.5, 2.6, _zramp)
			atacante.sprite.play("air_jab" if _zi % 2 == 0 else "air_spin_kick")
			# JUGGLE: en el aire NO usa la pose de suelo — usa hit_fly (pose AÉREA), reculando por golpe
			if victima.sprite.sprite_frames.has_animation("hit_fly"):
				if String(victima.sprite.animation) != "hit_fly":
					victima.sprite.play("hit_fly")
				var _hf: int = victima.sprite.sprite_frames.get_frame_count("hit_fly")
				victima.sprite.frame = clampi(int(float(_hf) * 0.12), 0, _hf - 1)   # frame aéreo (reculón por golpe)
			else:
				victima.sprite.play("take_hit")
			victima._play_sfx_key("take_hit")
			victima._burst(0.95, false, 1, false, 500.0 * (1.0 - victima.base_scale.y))
			_shake(lerpf(11.0, 16.0, _zramp), 0.10)
			if ultra_panels.size() > 0:
				ultra_panel.texture = ultra_panels[_zi % ultra_panels.size()]
				ultra_panel.visible = true
			n += 1
			_ultra_count(idx, n)
			_focus_set(clampf((float(n) - 2.0) / 14.0, 0.15, 1.0))
			if idx == 0:
				dummy_hp = maxi(1, dummy_hp - drain)
			else:
				player_hp = maxi(1, player_hp - drain)
			combo_dmg[idx] += drain
			combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
			await get_tree().create_timer(lerpf(0.26, 0.07, _zramp)).timeout
		atacante.sprite.speed_scale = 1.0
	# ZETMA: VENTANA (~0.7s) para apretar E y disparar el LANZAMIENTO AL VACÍO (remate especial).
	var _void_launch := false
	if largo and atacante.fx_dark and state == "ultra":
		_show_announce("PRESS  E", Color(0.85, 0.45, 1.9), 0.7)
		Engine.time_scale = 0.35                                   # SLOW-MO: le da tiempo al player a reaccionar
		var _ws := Time.get_ticks_msec()
		while Time.get_ticks_msec() - _ws < 500 and state == "ultra":   # 0.5s de tiempo REAL (inmune al slow-mo)
			# el rival se queda FLOTANDO en pose AÉREA (cayendo), NO tendido, durante la ventana
			victima.ultra_hover = true
			victima.airborne = true
			victima.position.y = victima.floor_y - 300.0
			if victima.sprite.sprite_frames.has_animation("hit_fly"):
				if String(victima.sprite.animation) != "hit_fly":
					victima.sprite.play("hit_fly")
				var _wf: int = victima.sprite.sprite_frames.get_frame_count("hit_fly")
				victima.sprite.frame = clampi(int(float(_wf) * 0.14), 0, maxi(0, _wf - 1))
			if Input.is_action_just_pressed(atacante.act("spin_kick")):
				_void_launch = true
				break
			await get_tree().process_frame
		Engine.time_scale = 1.0                                    # restaura ANTES del finisher (si no apretó, sigue normal)
	# FINISHER: mortal aereo (E arriba) que manda al rival MUY alto + caida brusca (NO si hubo VOID LAUNCH)
	if state == "ultra" and not _void_launch:
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
	# ZETMA VOID LAUNCH: el rival SALE VOLANDO del stage y cae MUY a lo lejos hasta desaparecer
	# detrás del near layer; Zetma queda en pose de victoria.
	if _void_launch and state == "ultra":
		if idx == 0:
			combo_dmg[idx] += dummy_hp
			dummy_hp = 0
		else:
			combo_dmg[idx] += player_hp
			player_hp = 0
		combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
		_ultra_count(idx, n + 1, "VOID OUT")
		await _zetma_void_launch(atacante, victima, idx, dir)
		_void_ko = true   # _end_round NO revive al perdedor (ya se hundió tras el piso)
	atacante.breaker_fx_t = 0.0
	atacante.sprite.speed_scale = 1.0
	victima.ultra_hover = false   # por si el ultra se interrumpio en pleno juggle
	announce.visible = false
	_focus_end()                  # quita el borde rojo y restaura el brillo
	ultra_active = false
	# cierre: KO en pelea real (VS CPU / VS 2P), o revivir en modo practica
	if _round_real():
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
		_set_inputs(true)
		dummy.ai_enabled = dummy_ai_mode

# ParallaxBackground del stage activo (para meter overlays DETRÁS del near layer). null si no tiene.
func _stage_parallax() -> Node:
	if code_stage == null:
		return null
	for ch in code_stage.get_children():
		if ch is ParallaxBackground:
			return ch
	return null

# GRITO de derrota por personaje: Aye/Aye-2 = "NOOOO", Fe = "Nooo", Roum = "YHAAA"; resto (DAM/Zetma) = HAAAA de DAM.
func _scream_path_for(f: Node2D) -> String:
	var dam := "res://imagen-action/sound-effect/voz-ko-dam.wav"
	var p := ""
	if f.fx_floral:        # Aye / Aye-2
		p = "res://imagen-action/aye/sound-effect/NOOOOOO_Cupcake_Eleven_v3_019ff60e-c81b-7b9b-a55b-c0ce8fe29dcc.mp3"
	elif f.fx_blue:        # Fe
		p = "res://imagen-action/favi/Fe-sound-effect/nooo-fe-derrota.wav"
	elif f.fx_warrior:     # Roum
		p = "res://imagen-action/roum/sound-effect/YHAAAA_League_Eleven_v3_01a01682-6dc9-78dc-b70e-1b849305c26e.mp3"
	return p if (p != "" and ResourceLoader.exists(p)) else dam

# HUMO del inferno (humo-1..5) como AnimatedSprite2D suelto, para pegarle al que cae al vacío.
func _void_smoke_sprite() -> AnimatedSprite2D:
	var sf := SpriteFrames.new()
	sf.add_animation("s")
	sf.set_animation_loop("s", true)
	sf.set_animation_speed("s", 12.0)
	for i in range(1, 6):
		var pth := "res://imagen-action/impact-effect/humo/humo-%d.png" % i
		if ResourceLoader.exists(pth):
			sf.add_frame("s", load(pth))
	if sf.get_frame_count("s") == 0:
		return null
	var a := AnimatedSprite2D.new()
	a.sprite_frames = sf
	a.play("s")
	a.modulate = Color(0.8, 0.62, 1.0, 0.78)   # humo tenue morado-grisáceo (estela del inferno)
	a.z_index = -1                              # detrás del cuerpo del proxy
	a.position = Vector2(0.0, 60.0)             # un pelín abajo (estela de la caída)
	a.scale = Vector2(2.4, 2.4)                 # grande respecto al proxy chico
	return a

# ZETMA — LANZAMIENTO AL VACÍO: remate con OTRA patada + FREEZE, el rival sube y SALE de la pantalla,
# medio segundo después se lo ve CAYENDO a lo lejos con humo, y se hunde detrás del piso. Zetma posa.
func _zetma_void_launch(atacante: Node2D, victima: Node2D, idx: int, dir: int) -> void:
	Engine.time_scale = 1.0
	# --- REMATE: Zetma SALTA a la altura del rival y le mete una PATADA AÉREA que lo vuela ---
	atacante.airborne = true
	atacante.ultra_hover = true                          # sin gravedad: se queda AÉREO dando la patada (no cae al piso)
	atacante.vel_x = 0.0
	atacante.vel_y = 0.0
	atacante.set_facing(dir)
	atacante.position.x = clampf(victima.position.x - float(dir) * 175.0, LEFT_LIMIT, RIGHT_LIMIT)
	atacante.position.y = victima.position.y + 30.0      # a la ALTURA del rival (patada aérea de verdad)
	var _kickanim := "air_spin_kick" if atacante.sprite.sprite_frames.has_animation("air_spin_kick") else ("jump_kick" if atacante.sprite.sprite_frames.has_animation("jump_kick") else "spin_kick")
	atacante.sprite.speed_scale = 1.4
	atacante.sprite.play(_kickanim)
	# el rival espera en pose aérea
	if victima.sprite.sprite_frames.has_animation("hit_fly"):
		victima.sprite.play("hit_fly")
		var _hf0: int = victima.sprite.sprite_frames.get_frame_count("hit_fly")
		victima.sprite.frame = clampi(int(float(_hf0) * 0.14), 0, maxi(0, _hf0 - 1))
	await get_tree().create_timer(0.16).timeout          # deja correr la PATADA para que se VEA conectar
	# IMPACTO + FREEZE
	victima._play_sfx_key("take_hit")
	victima._burst(1.0, false, 1, false, 500.0 * (1.0 - victima.base_scale.y))
	_shake(28.0, 0.35)
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.6, 0.2, 1.0, 0.62)
	atacante.sprite.speed_scale = 1.0
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.5, true, false, true).timeout   # FREEZE real (inmune al time_scale)
	Engine.time_scale = 1.0
	# capturo un frame AÉREO del rival para el proxy lejano (pose de caída, sirve p/ TODOS)
	var _hfn: int = victima.sprite.sprite_frames.get_frame_count("hit_fly") if victima.sprite.sprite_frames.has_animation("hit_fly") else 0
	var _tex: Texture2D = victima.sprite.sprite_frames.get_frame_texture("hit_fly", clampi(int(float(_hfn) * 0.2), 0, maxi(0, _hfn - 1))) if _hfn > 0 else victima.sprite.sprite_frames.get_frame_texture(victima.sprite.animation, victima.sprite.frame)
	# GANADOR: recupera control tras la patada (la pose de victoria va DESPUÉS de que el rival se va)
	atacante.airborne = false
	atacante.ultra_hover = false                         # ya puede caer/posar normal
	atacante.position.y = atacante.floor_y               # vuelve al PISO (estaba aéreo por la patada)
	atacante.vel_x = 0.0
	atacante.vel_y = 0.0
	atacante.breaker_fx_t = 0.0
	# --- 1) SALE VOLANDO: SUBE y se va GRADUAL por arriba del stage. ultra_hover=TRUE para que el fighter
	#        NO aplique gravedad ni KO (si no, REBOTA en el piso y se ACUESTA); main controla su posición.
	victima.koed = true
	victima.ultra_hover = true
	victima.airborne = true
	victima.hit_flying = false
	victima.vel_x = 0.0
	victima.vel_y = 0.0
	if victima.sprite.sprite_frames.has_animation("hit_fly"):
		victima.sprite.play("hit_fly")
	# GRITO que se aleja: cada personaje grita con SU voz de derrota. ROUM = GRAVE (como todas sus voces).
	var _scream := _scream_path_for(victima)
	var _spitch: float = 0.72 if victima.fx_warrior else 1.05
	if ResourceLoader.exists(_scream) and victima.voz_player != null:
		victima.voz_player.stream = load(_scream)
		victima.voz_player.pitch_scale = _spitch
		victima.voz_player.volume_db = 3.0
		victima.voz_player.play()
	var _t := 0.0
	var _top := _screen_off.y - 350.0                    # borde superior de la vista (mundo) - margen = fuera de cuadro
	while victima.position.y > _top and _t < 1.3:
		var d := get_process_delta_time()
		victima.ultra_hover = true                       # se mantiene (que nada le vuelva a poner gravedad)
		victima.position.x += float(dir) * 600.0 * d     # un poco ADELANTE
		victima.position.y -= 2500.0 * d                 # SUBE GRADUAL -> sale POCO A POCO por arriba del stage
		if victima.sprite.sprite_frames.has_animation("hit_fly"):
			var _hf: int = victima.sprite.sprite_frames.get_frame_count("hit_fly")
			victima.sprite.frame = clampi(int(float(_hf) * 0.18), 0, maxi(0, _hf - 1))   # pose de VUELO (no tendida)
		victima.sprite.rotation += 5.0 * d
		if victima.voz_player != null:
			victima.voz_player.volume_db = lerpf(3.0, -3.0, clampf(_t / 0.8, 0.0, 1.0))
		await get_tree().process_frame
		_t += d
	victima.visible = false                              # recién ahora (ya está FUERA de cuadro, sin salto visible)
	victima.sprite.rotation = 0.0
	# ahora sí: GANADOR en pose de VICTORIA (ya voló al rival)
	if atacante.sprite.sprite_frames.has_animation("victory"):
		atacante.sprite.play("victory")
	# --- GAP ~0.4s: el ganador posa; el rival ya subió y está fuera, arriba ---
	await get_tree().create_timer(0.4).timeout
	# --- 2) CAE A LO LEJOS: proxy con HUMO del inferno, cayendo al espacio (arranca cerca y se aleja),
	#        DETRÁS del near layer (z=-2 en el ParallaxBackground) -> el piso lo tapa al descender ---
	var proxy := Sprite2D.new()
	proxy.texture = _tex
	proxy.centered = true
	proxy.z_as_relative = false
	var _pbg := _stage_parallax()
	var _occ := _pbg != null
	if _occ:
		_pbg.add_child(proxy)      # stages con piso en ParallaxBackground (city/santuario/inferno)
		proxy.z_index = -2         # DETRÁS del piso (near z=-1) -> se HUNDE tras él al caer
	else:
		add_child(proxy)           # stages procedurales (night/templo): no hay sprite de piso separado
		proxy.z_index = -1         # VISIBLE delante del fondo del stage, detrás de los peleadores -> se desvanece a lo lejos
	proxy.modulate = Color(0.5, 0.46, 0.62, 1.0)       # OSCURO (silueta nocturna)
	var _smoke := _void_smoke_sprite()                 # HUMO del inferno pegado al que cae
	if _smoke != null:
		proxy.add_child(_smoke)
	var _fx := 1260.0 if dir > 0 else 660.0
	proxy.position = Vector2(_fx, -90.0)               # arranca ARRIBA del borde -> ENTRA gradual desde el cielo
	proxy.scale = Vector2(0.17, 0.17)                  # LEJOS (más chico al caer)
	var _ft := 0.0
	var _fall := 2.0
	while _ft < _fall:
		var p := _ft / _fall
		proxy.position.y = lerpf(-90.0, 980.0, p)      # CAE desde arriba hasta hundirse tras el piso
		proxy.position.x = _fx + sin(_ft * 1.8) * 26.0
		var s := lerpf(0.17, 0.06, p)                  # se ALEJA cayendo (más lejos)
		proxy.scale = Vector2(s, s)
		proxy.rotation += 2.6 * get_process_delta_time()
		# con piso (occ): se desvanece justo al final (lo tapa el piso). Sin piso (procedural): se desvanece
		# ANTES, cayendo a lo lejos (no hay piso que lo esconda).
		if _occ:
			if p > 0.85:
				proxy.modulate.a = 1.0 - (p - 0.85) / 0.15
		elif p > 0.5:
			proxy.modulate.a = 1.0 - (p - 0.5) / 0.5
		if victima.voz_player != null:
			victima.voz_player.volume_db = lerpf(-5.0, -46.0, p)
			victima.voz_player.pitch_scale = lerpf(_spitch, _spitch * 0.78, p)   # doppler desde su tono base (Roum grave)
		await get_tree().process_frame
		_ft += get_process_delta_time()
	proxy.queue_free()
	# el grito ya se apagó: cortar y RESTAURAR el canal de voz (si no, futuras voces salen mudas/graves)
	if victima.voz_player != null:
		victima.voz_player.stop()
		victima.voz_player.volume_db = 0.0
		victima.voz_player.pitch_scale = 1.0

# ---- INFIERNO: crítico de FUEGO (↓↘→+E tras un combo de 7+) ----
const CRIT_DMG := 50   # el golpe mas fuerte del juego

func try_critical(atacante: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	# REGLA (pedido): el INFERNO solo se ejecuta CON LOS PIES EN EL SUELO — ni en el
	# aire ni golpeando en el aire (el casteo planta la pose; volando se rompia el rito)
	if atacante.airborne or atacante.hit_flying or atacante.position.y < atacante.floor_y - 4.0:
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

# BOOM del INFIERNO v2: los 2 IMPACT FRAMES de anime toman TODA la pantalla (flat art)
# con DAM dibujado POR ARRIBA (sube su z sobre el pantallazo un instante)
func _inferno_boom_overlay(atacante: Node2D, arriba: Node2D = null, foco_x := 960.0) -> void:
	# arriba: el nodo de ARTE de DAM que debe quedar sobre el pantallazo (p.ej. el super
	# congelado en su pose de mano); si no se pasa, se sube el fighter mismo.
	# foco_x: el CENTRO del arte se corre hacia donde ESTÁ la explosión (el domo) — con
	# margen extra de escala (1.45x) para que aun corrido siga cubriendo toda la pantalla.
	var texs := []
	for n in ["boom-1", "boom-2"]:
		var pth := "res://imagen-action/impact-effect/faller-fx/%s.png" % n
		if ResourceLoader.exists(pth):
			texs.append(load(pth))
	if texs.is_empty():
		return
	const BOOM_M := 1.45   # margen: ancho en pantalla 1920*1.45 => el centro puede correrse ±432
	var ov := Sprite2D.new()
	ov.texture = texs[0]
	ov.z_index = 20                        # sobre stage, rivales y efectos (< 10)
	ov.position = Vector2(clampf(foco_x, 960.0 - 432.0, 960.0 + 432.0), 540.0)
	ov.scale = Vector2(1920.0 * BOOM_M / float(texs[0].get_width()), 1080.0 * BOOM_M / float(texs[0].get_height()))
	add_child(ov)
	var subir: Node2D = arriba if arriba != null else atacante
	var zprev: int = subir.z_index
	subir.z_index = 21                     # el ARTE de DAM queda POR ARRIBA del pantallazo
	# ESTALLIDO (explotion-boom, del usuario): revienta justo con el pantallazo
	if ResourceLoader.exists("res://imagen-action/impact-effect/explotion-boom.wav"):
		var bp := AudioStreamPlayer.new()
		bp.stream = load("res://imagen-action/impact-effect/explotion-boom.wav")
		bp.volume_db = 3.0
		add_child(bp)
		bp.finished.connect(bp.queue_free)
		bp.play()
	if texs.size() > 1:
		get_tree().create_timer(0.09, true, false, true).timeout.connect(func() -> void:
			if is_instance_valid(ov):
				ov.texture = texs[1]
				ov.scale = Vector2(1920.0 * BOOM_M / float(texs[1].get_width()), 1080.0 * BOOM_M / float(texs[1].get_height())))
	get_tree().create_timer(0.18, true, false, true).timeout.connect(func() -> void:
		if is_instance_valid(ov):
			ov.queue_free()
		if is_instance_valid(subir):
			subir.z_index = zprev)

func _run_critical(atacante: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	ultra_active = true
	_ultra_banner_name = ""   # el CRÍTICO ya muestra su propia banda "CRITICAL" al golpear
	state = "ultra"
	_set_inputs(false)
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	atacante.airborne = false
	atacante.set_facing(dir)
	_focus_start(atacante)         # borde rojo eléctrico (aparece gradual)
	_focus_set(0.35)               # arranca tenue mientras carga la katana
	# INFIERNO v2 (arte "faller"): DAM se queda VIVO casteando (girando la katana) y el
	# FUEGO se junta y crece en DOMO adelante; en el BOOM los 2 impact-frames toman la
	# PANTALLA con DAM por arriba. Fallback: el super pre-animado viejo (oculta a DAM).
	var dome: AnimatedSprite2D = atacante.spawn_inferno_dome(dir)
	# OJO: dome se AUTO-LIBERA al terminar sus escombros (un objeto liberado == null en
	# GDScript) — el MODO se captura acá para que el remate no caiga en la rama vieja
	var modo_domo: bool = dome != null
	var sup: AnimatedSprite2D = null
	# CAST v3 (clip inferno_cast): DAM canaliza EN VIVO — espada al hombro, palma
	# extendida, abrigo azotado por el viento. Reemplaza el frame congelado del super.
	if atacante.sprite.sprite_frames.has_animation("inferno_cast"):
		atacante.sprite.play("inferno_cast")
	elif dome != null:
		# pose de CASTEO "por ahora" (pedido): el PRIMER cuadro del super viejo — DAM
		# canalizando con la MANO extendida — CONGELADO (nunca reproduce la ola vieja)
		sup = atacante.spawn_inferno_super()
		if sup != null:
			sup.pause()
			sup.frame = 0
			atacante.sprite.visible = false
			atacante.fx_sprite.visible = false
		else:
			atacante.sprite.play("pose")
	else:
		sup = atacante.spawn_inferno_super()
		if sup != null:
			atacante.sprite.visible = false        # esconde el DAM vivo (no más doble)
			atacante.fx_sprite.visible = false     # sin fantasma de arte viejo
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
	if dome != null:
		# SYNC (pedido): tras el cut-in la anim quedo congelada en la intro — saltar al
		# frame previo al empuje (clip v2: el brazo arranca en f58, 0-based 56): la PALMA
		# se extiende JUSTO cuando la bola empieza a salir
		if String(atacante.sprite.animation) == "inferno_cast":
			atacante.sprite.frame = 56
		dome.play("build")                 # el fuego se junta y el DOMO crece (0.85s)
		await get_tree().create_timer(0.85).timeout
		# BOOM: los 2 IMPACT FRAMES a PANTALLA COMPLETA con DAM por arriba, con el
		# arte CENTRADO donde está el domo (la explosión sale del punto real)
		_inferno_boom_overlay(atacante, sup, dome.global_position.x)
		# el flujo NO espera: la victima reacciona y recibe el castigo DURANTE la
		# explosion (pedido) — los escombros salen solos 0.18s despues por timer
		get_tree().create_timer(0.18).timeout.connect(func() -> void:
			if is_instance_valid(dome):
				# los ESCOMBROS/HUMO vienen ALTOS en el arte: se baja el nodo al SUELO
				dome.position.y += 150.0
				dome.play("out"),
			CONNECT_ONE_SHOT)
	else:
		if sup != null:
			sup.play("cast")               # viejo: DAM suelta la GRAN OLA de fuego
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
		if String(atacante.sprite.animation) == "inferno_cast":
			atacante.sprite.play("pose")             # suelta la palma (la anim quedó retenida)
		_focus_end()
		ultra_active = false
		state = "fight"
		_set_inputs(true)
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
		# con el DOMO nuevo la víctima NO se arrastra: el fuego revienta DEBAJO de ella
		var avance := float(dir) * (0.0 if modo_domo else 1050.0) * dt
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
			_dmg_number(victima, d)
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
	if String(atacante.sprite.animation) == "inferno_cast":
		atacante.sprite.play("pose")                     # suelta la palma (la anim quedó retenida al final)
	# REMATE
	victima.hard_fall = false
	if modo_domo:
		# el DOMO revienta DEBAJO de ella: sale volando RECTO HACIA ARRIBA (pedido —
		# nada de atrás-y-arriba: se anula el empuje horizontal del lanzador)
		victima.receive_hit(false, true, dir, "", false, 1.7)
		victima.vel_x = 0.0
	else:
		victima.receive_hit(false, false, dir, "", true, 1.0)   # trip -> derribo corto
	# NO se espera el aterrizaje: si murió, _end_round maneja la caída→boca abajo→freeze
	_focus_end()                  # quita el borde rojo y restaura el brillo
	ultra_active = false
	# cierre: KO si murió, si no vuelve a la pelea
	var murio: bool = (dummy_hp <= 0) if idx == 0 else (player_hp <= 0)
	state = "fight"
	if _round_real() and murio:
		_end_round(idx == 0)
	else:
		_set_inputs(true)
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
	_ultra_banner_name = "CRYSTAL FLURRY"
	state = "ultra"
	_set_inputs(false)
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
		atacante.voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
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
	_set_inputs(true)
	dummy.ai_enabled = dummy_ai_mode

# TELEPORT de Aye (↓→Q, reemplaza el dash): glitch out + TIEMBLA + sonido -> reaparece AL FRENTE del
# rival con un golpe. Sombras + borde MORADO que se desvanecen si no encadena un combo. Invulnerable.
# ---- RABIA de DAM: activación del BERSERK (E+R simultáneas con el anillo LLENO) ----
var rage_casting := [false, false]   # casteando la activación (sin drenaje aún)
func try_rage(f: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if f == player else 1
	if not rage_side[idx] or rage_on[idx] or rage[idx] < 0.999:
		return false
	if f.koed or f.airborne or f.hit_flying or f.frozen_t > 0.0 or f.special_t > 0.0 or f.is_downed():
		return false
	_run_rage_cast(f, idx)
	return true

func _run_rage_cast(f: Node2D, idx: int) -> void:
	# CASTEO: DAM alza el poder (clip cast-berseke) gritando su HAAAA; a mitad del clip
	# la energía REVIENTA -> onda expansiva; al terminar el clip arranca el MODO berserk.
	rage_on[idx] = true
	rage_casting[idx] = true
	var dur := 1.1
	if f.sprite.sprite_frames.has_animation("berserk_cast"):
		dur = float(f.sprite.sprite_frames.get_frame_count("berserk_cast")) / 130.0
		f.sprite.play("berserk_cast")
	f.special_t = dur + 0.05      # bloquea input/movimiento mientras castea (vulnerable, como Aye)
	f.vel_x = 0.0
	f.crouching = false
	var ruta := "res://imagen-action/sound-effect/voz-ko-dam.wav"   # su HAAAA de batalla
	if ResourceLoader.exists(ruta):
		f.voz_player.stream = load(ruta)
		f.voz_player.pitch_scale = 1.0
		f.voz_player.play()
	# la ONDA EXPANSIVA sale AL EMPEZAR la anim (pedido): despeja al rival con un
	# empujón rápido para que no pueda golpearlo durante el casteo
	_rage_nova(f, idx)
	_rage_cast_show(f, dur)   # PANTALLA ROJA parpadeante + temblor mientras castea (pedido)
	await get_tree().create_timer(minf(0.40, dur)).timeout          # la explosión del clip (~f52 @130fps)
	if not is_instance_valid(f) or f.koed:
		_rage_end(idx)
		return
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(1.2, 0.9, 0.55, 0.40)                  # fogonazo blanco-dorado
	_shake(16.0, 0.30)
	f._burst(1.5)
	await get_tree().create_timer(maxf(dur - 0.40, 0.0)).timeout
	rage_casting[idx] = false
	if not is_instance_valid(f) or f.koed:
		_rage_end(idx)
		return
	f.rage_mode = true            # BERSERK: oscuro + sombras rojas + más rápido + pega más

func _rage_end(idx: int) -> void:
	rage_on[idx] = false
	rage_casting[idx] = false
	var f: Node2D = player if idx == 0 else dummy
	if is_instance_valid(f):
		f.rage_mode = false

# SHOW del casteo del berserk: el fondo LATE en rojo y la cámara tiembla suave
# mientras dura la animación; al terminar deja el velo listo para el modo (oscuro).
# Además la onda REPELE: si el rival intenta acercarse durante el casteo, lo vuelve
# a empujar hacia atrás — DAM no puede ser golpeado mientras castea.
func _rage_cast_show(f: Node2D, dur: float) -> void:
	var v: Node2D = dummy if f == player else player
	var t := 0.0
	while t < dur and is_instance_valid(f) and not f.koed and state == "fight":
		var dt := get_process_delta_time()
		t += dt
		if rage_dim != null:
			var k := 0.5 + 0.5 * sin(t * 22.0)   # latido rápido
			rage_dim.color = Color(0.55, 0.02, 0.02, 0.14 + 0.18 * k)
		_shake(6.0, 0.08)                        # temblor continuo suave
		if is_instance_valid(v) and not v.koed and not v.airborne and not v.hit_flying \
				and absf(v.position.x - f.position.x) < 460.0:
			var rdir: int = signi(v.position.x - f.position.x)
			if rdir == 0:
				rdir = f.facing
			v.position.x = clampf(v.position.x + float(rdir) * 1500.0 * dt, 120.0, 1800.0)
		await get_tree().process_frame
	if rage_dim != null:
		rage_dim.color = Color(0.02, 0.0, 0.01, rage_dim.color.a)   # vuelve al velo oscuro del modo

# ONDA EXPANSIVA del casteo: círculo de energía BLANCO translúcido "de medio lado"
# (elipse en perspectiva) que crece desde DAM; si el frente alcanza al rival, le quita
# vida y lo EMPUJA hacia atrás. Respeta el bloqueo (receive_hit decide).
func _rage_nova(f: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var cont := Node2D.new()
	cont.position = Vector2(f.position.x, f.position.y - 60.0)
	cont.z_index = 30
	add_child(cont)
	var ring := Line2D.new()
	var pts := PackedVector2Array()
	for i in 49:
		var a := TAU * float(i) / 48.0
		pts.append(Vector2(cos(a), sin(a) * 0.34))   # elipse tumbada (perspectiva)
	ring.points = pts
	ring.closed = true
	ring.joint_mode = Line2D.LINE_JOINT_ROUND
	ring.default_color = Color(1.0, 1.0, 1.0, 0.55)
	cont.add_child(ring)
	var t := 0.0
	var golpeo := false
	var NOVA_DUR := 0.5
	var NOVA_R := 1500.0
	while t < NOVA_DUR:
		var dt := get_process_delta_time()
		t += dt
		var k := clampf(t / NOVA_DUR, 0.0, 1.0)
		var r := maxf(NOVA_R * k, 1.0)               # radio actual del frente (px)
		cont.scale = Vector2(r, r)
		ring.width = 34.0 / r                        # grosor visual ~34px constante
		ring.default_color.a = 0.55 * (1.0 - 0.85 * k)
		if not golpeo and is_instance_valid(victima) and not victima.koed \
				and absf(victima.position.x - cont.position.x) <= r \
				and victima.floor_y - victima.position.y < 320.0:
			golpeo = true
			var dir: int = signi(victima.position.x - cont.position.x)
			if dir == 0:
				dir = f.facing
			var res: String = victima.receive_hit(false, false, dir, "kick_impact")
			if res == "hit" or res == "launched":
				_dmg_number(victima, RAGE_NOVA_DMG)
				_shake(13.0, 0.18)
				if victima == dummy:
					dummy_hp = maxi(0, dummy_hp - RAGE_NOVA_DMG)
					if dummy_hp <= 0:
						if _round_real(): _end_round(true)
						else: dummy_hp = hp_max[1]
				else:
					player_hp = maxi(0, player_hp - RAGE_NOVA_DMG)
					if player_hp <= 0:
						if _round_real(): _end_round(false)
						else: player_hp = hp_max[0]
			# la onda EMPUJA SIEMPRE (aunque bloquee: es física, lo arrastra igual;
			# el daño sí lo salva el bloqueo)
			if res != "ignored":
				_rage_push(victima, dir)             # el empujón de la onda
		await get_tree().process_frame
	if is_instance_valid(cont):
		cont.queue_free()

func _rage_push(v: Node2D, dir: int) -> void:
	# empujón VELOZ de la onda: saca al rival del alcance (~550px en 0.25s) para que
	# no pueda golpear a DAM mientras castea
	var t := 0.0
	while t < 0.25 and is_instance_valid(v) and not v.airborne and not v.hit_flying:
		var dt := get_process_delta_time()
		t += dt
		v.position.x = clampf(v.position.x + float(dir) * 2200.0 * dt, 120.0, 1800.0)
		await get_tree().process_frame

# ====================== SÚPER de ROUM (↓W): CABEZAZO + ONDA EXPANSIVA ======================
# ↓W (½ barra): ROUM ruge y suelta una ONDA que se EXPANDE a toda la pantalla LANZANDO al rival
# hacia ARRIBA (aunque el cuerpo no lo toque) + temblor + borde carmesí + shade + grito YHAAAA.
const ROUM_NOVA_DMG := 80

func _roum_super(f: Node2D) -> void:
	if not try_meter_cost(f, 0.5):
		return   # sin ½ barra: try_meter_cost ya hace el deny_flash del atacante y del meter
	var idx := 0 if f == player else 1
	f.roum_super_t = 1.3
	f.crouching = false
	f.vel_x = 0.0
	f.sprite.play("crouch_kick")   # la anim PROPIA del ↓W (crouch_kick, con su pequeño salto) — NO el cabezazo del E
	# grito YHAAAA del súper (la anim de crouch_kick NO dispara la rama de sonido del spin_kick)
	var _hyap := "res://imagen-action/roum/sound-effect/voz-hya-roum.wav"
	if ResourceLoader.exists(_hyap):
		f.voz_player.stream = load(_hyap)
		f.voz_player.pitch_scale = 1.0
		f.voz_player.play()
	_roum_border(f, true)        # borde CARMESÍ en el personaje (color de su estela de swing)
	_shake(20.0, 0.35)           # temblor FUERTE de pantalla
	_roum_nova(f, idx)           # ONDA expansiva (corre en paralelo; lanza al rival hacia arriba)
	_roum_shade(0.5)             # velo oscuro breve detrás (shade del súper)
	await get_tree().create_timer(1.15).timeout
	_roum_border(f, false)

func _roum_nova(f: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var cont := Node2D.new()
	cont.position = Vector2(f.position.x, f.position.y - 40.0)
	cont.z_index = 30
	add_child(cont)
	var ring := Line2D.new()
	var pts := PackedVector2Array()
	for i in 49:
		var a := TAU * float(i) / 48.0
		pts.append(Vector2(cos(a), sin(a) * 0.34))   # elipse tumbada (perspectiva de suelo)
	ring.points = pts
	ring.closed = true
	ring.joint_mode = Line2D.LINE_JOINT_ROUND
	ring.default_color = Color(1.5, 0.16, 0.24, 0.62)   # CARMESÍ (color de ROUM)
	cont.add_child(ring)
	var t := 0.0
	var golpeo := false
	var NOVA_DUR := 0.55
	var NOVA_R := 1650.0
	while t < NOVA_DUR:
		var dt := get_process_delta_time()
		t += dt
		var k := clampf(t / NOVA_DUR, 0.0, 1.0)
		var r := maxf(NOVA_R * k, 1.0)               # radio del frente (px)
		cont.scale = Vector2(r, r)
		ring.width = 42.0 / r                        # grosor visual ~42px constante
		ring.default_color.a = 0.62 * (1.0 - 0.8 * k)
		if not golpeo and is_instance_valid(victima) and not victima.koed \
				and absf(victima.position.x - cont.position.x) <= r:
			golpeo = true
			var dir: int = signi(victima.position.x - cont.position.x)
			if dir == 0:
				dir = f.facing
			# LANZA hacia ARRIBA (strong -> _launch alto). "si el cuerpo no te da, te da la onda"
			var res: String = victima.receive_hit(false, true, dir, "kick_impact", false, 1.75)
			if res == "launched" or res == "hit":
				_dmg_number(victima, ROUM_NOVA_DMG)
				_shake(16.0, 0.22)
				if victima == dummy:
					dummy_hp = maxi(0, dummy_hp - ROUM_NOVA_DMG)
					if dummy_hp <= 0:
						if _round_real(): _end_round(true)
						else: dummy_hp = hp_max[1]
				else:
					player_hp = maxi(0, player_hp - ROUM_NOVA_DMG)
					if player_hp <= 0:
						if _round_real(): _end_round(false)
						else: player_hp = hp_max[0]
		await get_tree().process_frame
	if is_instance_valid(cont):
		cont.queue_free()

var _roum_border_mat: ShaderMaterial = null
func _roum_border(f: Node2D, on: bool) -> void:
	if on:
		if _roum_border_mat == null:
			var sh := Shader.new()
			sh.code = _OUTLINE_CODE
			_roum_border_mat = ShaderMaterial.new()
			_roum_border_mat.shader = sh
			_roum_border_mat.set_shader_parameter("line_color", Color(1.7, 0.2, 0.26, 1.0))  # CARMESÍ (color de swing de ROUM)
			_roum_border_mat.set_shader_parameter("width", 4.2)
			_roum_border_mat.set_shader_parameter("intensity", 1.0)
		f.sprite.material = _roum_border_mat
	elif f.sprite.material == _roum_border_mat:
		f.sprite.material = f.base_material   # restaura el material base (color alterno del P2, etc.)

# velo oscuro breve DETRÁS de los peleadores (reusa ko_red). Guarda state=="fight" para no pisar el velo del KO.
func _roum_shade(dur: float) -> void:
	if ko_red == null or state != "fight":
		return
	ko_red.color = Color(0.06, 0.02, 0.03, 0.5)   # carmesí muy oscuro
	ko_red.visible = true
	var t := 0.0
	while t < dur and state == "fight":
		var dt := get_process_delta_time()
		t += dt
		ko_red.color.a = 0.5 * (1.0 - t / dur)
		await get_tree().process_frame
	if state == "fight":
		ko_red.color.a = 0.0

# ---- ROUM: VOID LASH (←←→ + W) — SÚPER de vendas (½ barra) ----
# void_cast es una animación NORMAL de ROUM (roum/void_cast, lienzo 2000 ancho con ROUM CENTRADO,
# mismo anclaje/escala que todos sus frames) -> se reproduce en su sprite y queda del tamaño de
# siempre y con los pies al suelo. El rival queda ATRAPADO entre las vendas recibiendo una pila de
# golpes tipo ultra y SALE VOLANDO al terminar.
func _roum_void_cast(caster: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	if caster.airborne or caster.koed:
		return false
	if not caster.sprite.sprite_frames.has_animation("void_cast"):
		return false   # sin frames (Godot no los importó aún): NO consumas el input
	if not try_meter_cost(caster, 0.5):
		return true    # sin ½ barra: try_meter_cost ya hizo el deny_flash; input consumido
	_run_void_lash(caster)
	return true

func _run_void_lash(caster: Node2D) -> void:
	var opp: Node2D = dummy if caster == player else player
	var was_in: bool = caster.input_enabled
	var was_ai: bool = caster.ai_enabled
	caster.input_enabled = false
	caster.ai_enabled = false
	caster.crouching = false
	caster.vel_x = 0.0
	if is_instance_valid(opp):
		caster.set_facing(1 if opp.position.x >= caster.position.x else -1)
	var facing: int = caster.facing
	var arena: Node = caster.get_parent()
	# voz VOID_LASH GRAVE (hombre maduro ~40): versión con pitch -20% (misma duración); si falta, el mp3 crudo
	var sp := "res://imagen-action/roum/sound-effect/voz-void-lash-roum.wav"
	if not ResourceLoader.exists(sp):
		sp = "res://imagen-action/roum/sound-effect/VOID_LASH_League_Eleven_v3_01a017f5-8d12-791f-9654-40a3f2029776.mp3"
	if ResourceLoader.exists(sp):
		var strm = load(sp)
		if strm is AudioStreamMP3:
			strm.loop = false
		var vp := AudioStreamPlayer.new()
		vp.stream = strm
		vp.volume_db = 6.0   # el wav ya viene GRAVE (-20% pitch, duración intacta)
		arena.add_child(vp)
		vp.finished.connect(vp.queue_free)
		vp.play()
	# HUD cinemático de SÚPER (mismo focus/oscurecido + paneles manga que usan DAM y Aye)
	_focus_start(caster)
	_focus_set(0.45)
	_play_cutin(-1 if caster.position.x >= 960.0 else 1, caster)   # cut-in de HUD: retrato de ROUM
	if ultra_panels.size() > 0:
		ultra_panel.texture = ultra_panels[0]
		ultra_panel.visible = true
	_shake(18.0, 0.30)
	# ROUM hace el súper en su SPRITE NORMAL: MISMO anclaje/escala que TODOS sus frames -> NO se mueve
	# del suelo y queda del tamaño de siempre. Las vendas ya vienen en el frame (lienzo 2000 ancho).
	caster.vel_x = 0.0
	caster.airborne = false
	caster.sprite.play("void_cast")
	# el rival: ATRAPADO entre las vendas (al frente, sin control) recibiendo una PILA de golpes tipo ultra
	var opp_in := false
	var opp_ai := false
	var opp_grounded := false   # ¿le pegó EN EL SUELO? entonces se queda en el suelo (no flota) hasta el final
	if is_instance_valid(opp):
		opp_in = opp.input_enabled
		opp_ai = opp.ai_enabled
		opp_grounded = not opp.airborne
	var trap_x: float = clampf(caster.position.x + float(facing) * 560.0, LEFT_LIMIT, RIGHT_LIMIT)   # ~1.6 cuerpos al frente, en la zona de las vendas
	var hits := 10
	var per := 12
	var done := 0
	var t := 0.0
	var DUR := 1.60    # 120 frames @75fps (~1.6s, calza con la voz; sin submuestrear)
	var A0 := 0.30    # arranque del apaleo (tras el windup del latigazo)
	var A1 := 1.40    # fin del apaleo (luego SALE VOLANDO)
	while t < DUR and state == "fight" and is_instance_valid(caster) and not caster.koed:
		t += get_process_delta_time()
		if t >= A0 and t <= A1 and is_instance_valid(opp) and not opp.koed:
			# a merced: sin control, aguantando la pila de golpes
			opp.input_enabled = false
			opp.ai_enabled = false
			opp.hit_flying = false
			opp.crouching = false
			opp.vel_x = 0.0
			opp.vel_y = 0.0
			opp.set_facing(-facing)
			if opp_grounded:
				# le pegó EN EL SUELO -> se QUEDA en el suelo aguantando (NO se levanta hasta el final)
				opp.airborne = false
				opp.ultra_hover = false
				opp.position.x = lerpf(opp.position.x, trap_x, 0.16)
				opp.position.y = opp.floor_y
				if opp.sprite.sprite_frames.has_animation("take_hit") and String(opp.sprite.animation) != "take_hit":
					opp.sprite.play("take_hit")   # stagger de PIE (no el pummeled aéreo)
			else:
				# le pegó EN EL AIRE -> juggle suspendido en las vendas (temblando)
				opp.airborne = true
				opp.ultra_hover = true       # sin gravedad
				var jitter: float = sin(t * 55.0) * 9.0
				opp.position.x = lerpf(opp.position.x, trap_x, 0.25)
				opp.position.y = opp.floor_y - 210.0 + jitter
				if opp.sprite.sprite_frames.has_animation("pummeled"):
					if String(opp.sprite.animation) != "pummeled":
						opp.sprite.play("pummeled")
				elif opp.sprite.sprite_frames.has_animation("take_hit") and String(opp.sprite.animation) != "take_hit":
					opp.sprite.play("take_hit")
			# PILA de golpes (8 × 15 = 120) + manga panels ciclando + foco que sube
			if done < hits and t >= A0 + float(done) * ((A1 - A0) / float(hits)):
				done += 1
				_dmg_number(opp, per)
				opp._burst(0.9, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
				opp._play_sfx_key("take_hit")
				_shake(7.0, 0.05)
				_focus_set(0.45 + 0.45 * float(done) / float(hits))
				if ultra_panels.size() > 0:
					ultra_panel.texture = ultra_panels[done % ultra_panels.size()]
					ultra_panel.visible = true
				if opp == dummy:
					dummy_hp = maxi(0, dummy_hp - per)
					if dummy_hp <= 0:
						if _round_real(): _end_round(true)
						else: dummy_hp = hp_max[1]
				else:
					player_hp = maxi(0, player_hp - per)
					if player_hp <= 0:
						if _round_real(): _end_round(false)
						else: player_hp = hp_max[0]
		await get_tree().process_frame
	# FIN del súper: limpia HUD, restaura ROUM y el rival SALE VOLANDO (lanzado, tipo ultra)
	_focus_end()
	if is_instance_valid(caster):
		if not caster.koed and state == "fight":
			caster.sprite.play("pose")
		caster.input_enabled = was_in
		caster.ai_enabled = was_ai
	if is_instance_valid(opp):
		if not opp.koed and state == "fight":
			opp.ultra_hover = false      # libera el hover
			opp.airborne = true
			opp.hit_flying = true
			opp.vel_x = float(facing) * 900.0   # SALE VOLANDO hacia adelante (empujado por el latigazo)
			opp.vel_y = -700.0                  # bien arriba y lejos
			if opp.sprite.sprite_frames.has_animation("hit_fly"):
				opp.sprite.play("hit_fly")
		else:
			opp.ultra_hover = false
		opp.input_enabled = opp_in
		opp.ai_enabled = opp_ai

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

# ===== VOID de ROUM (mismo patrón que el maná, pero es el recurso del warrior Roum) =====
func _void_ok(caster: Node2D, cost: float) -> bool:
	var i := _mana_side(caster)
	if not void_side[i]:
		return true            # los no-Roum no usan void
	return void_charge[i] >= cost - 0.0001

func _void_spend(caster: Node2D, cost: float) -> void:
	var i := _mana_side(caster)
	if not void_side[i]:
		return
	void_charge[i] = maxf(0.0, void_charge[i] - cost)

func _void_denied(caster: Node2D) -> void:
	mana_flash_t[_mana_side(caster)] = 0.35   # anillo parpadea rojo (y el portal no sale)

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
	caster._spawn_jump_dust(0.65)   # poof de SALIDA (el blink es solo de suelo)
	var vr := "res://imagen-action/aye/sound-effect/teleport-aye.mp3"
	if ResourceLoader.exists(vr):
		caster.voz_player.stream = load(vr)
		caster.voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
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
		caster._spawn_jump_dust(0.65)   # poof de LLEGADA
		if caster.sprite.sprite_frames.has_animation("teleport"):
			# glitch de ENTRADA: la anim AL REVÉS (el glitch se disuelve sobre el cuerpo);
			# arranca sola en el último frame registrado (la anim solo tiene los frames
			# buenos 1-6, el cuadro del clip quedó fuera en _build_aye_frames)
			caster.sprite.play_backwards("teleport")
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
	if not from_air:
		caster._spawn_jump_dust(0.7)   # poof de SALIDA — SOLO en el suelo (aéreo no)
	var vr := "res://imagen-action/aye/sound-effect/teleport-aye.mp3"
	if ResourceLoader.exists(vr):
		caster.voz_player.stream = load(vr)
		caster.voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
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
	if not from_air:
		caster._spawn_jump_dust(0.7)   # poof de LLEGADA — SOLO en el suelo
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
	if combo_n[idx] < 2 or combo_t[idx] > COMBO_WINDOW + 0.45:
		return false          # necesita 2-3 golpes encadenados; ventana EXTENDIDA (~1.2s):
		# el motion ↓←E toma su tiempo tras el último hit (con 0.75 justos casi nunca salía)
	meter[idx] -= 1.0
	_run_whirlpool(atacante, idx)
	return true

func _run_whirlpool(atacante: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	# agarra al rival si está CERCA y: en el SUELO, o en el AIRE BAJO (cayendo) — el combo
	# natural Q→W LANZA y el whirlpool debe TRAGARSE al rival cuando cae (el vórtice de
	# agua sube alto). Lejos o demasiado alto: whiff (gira en vacío).
	var v_alt: float = victima.floor_y - victima.position.y
	var alcanza: bool = absf(victima.position.x - atacante.position.x) < 450.0 \
			and ((not victima.airborne) or v_alt < 380.0)
	ultra_active = true
	_ultra_banner_name = "WHIRLPOOL"
	state = "ultra"
	_set_inputs(false)
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	atacante.fe_dash_active = false
	atacante.airborne = false
	atacante.position.y = atacante.floor_y
	atacante.set_facing(dir)
	_fe_cast_fx(atacante, true)                    # borde BLANCO-azul eléctrico + partículas (solo Fe)
	# ARTE NUEVO (pedido): SU PROPIO GIRO (spin_kick v2) acelerado con efectos BLANCOS
	# por código (borde + sombras + destellos) — ya no el tornado de agua. Fallback: viejo.
	var usa_spin: bool = atacante.sprite.sprite_frames.has_animation("spin_kick") \
			and atacante.sprite.sprite_frames.get_frame_count("spin_kick") > 40
	var ganim := "spin_kick" if usa_spin else "whirlpool"
	var cyc0 := 12 if usa_spin else 1        # donde ARRANCA el ciclo de rotación pura
	var cyclen := 28 if usa_spin else 3      # largo del ciclo (f12..39 del trompo)
	var paso_g := 0.007 if usa_spin else 0.045   # ROTACIÓN FURIOSA: vuelta completa ~0.2s
	atacante.sprite.animation = ganim
	atacante.sprite.stop()
	atacante.sprite.frame = 0                      # pose de arranque (se ve durante el freeze)
	if atacante.has_method("_spawn_jump_dust"):
		atacante._spawn_jump_dust(0.55)   # un toque de polvo al arrancar (sutil, no tapa)
	# GRITA en su player de VOZ propio (no lo corta el sonido de impacto)
	var voz = load("res://imagen-action/favi/Fe-sound-effect/whirlpool-fe.wav")
	if voz != null and atacante.voz_player != null:
		atacante.voz_player.stream = voz
		atacante.voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
		atacante.voz_player.play()
	# CUT-IN del PERSONAJE (como el inferno de DAM): retrato de Fe en el lado opuesto al combo
	var combo_x: float = float(combo_rest_x[idx])
	_play_cutin(-1 if combo_x >= 960.0 else 1, atacante)
	# entrada cinemática: congela un instante + velo BLANCO-azul (energía pura)
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.5, 0.65, 1.0, 0.4)
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.28, true, false, true).timeout
	Engine.time_scale = 1.0
	# el rival queda atrapado AL LADO de Fe (en el suelo, o cayendo BAJO tras un lanzador)
	if alcanza:
		victima.airborne = false
		victima.hit_flying = false   # si venía LANZADO (Q→W→whirlpool), el vórtice lo baja
		victima.vel_x = 0.0
		victima.vel_y = 0.0
		victima.crouching = false
		victima.position.y = victima.floor_y
		victima.set_facing(-dir)
	_shake(20.0, 0.3)
	# ARRANQUE del giro: acelera del reposo hasta la rotación plena
	for fr in range(1, cyc0 + 1):
		atacante.sprite.frame = fr
		await get_tree().create_timer(0.03).timeout
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
		atacante.sprite.frame = cyc0 + (int(spin_clock / paso_g) % cyclen)
		if alcanza:
			# a BODY_SEP justo (con 190 quedaba SOLAPADA con Fe y el empuje anti-traspaso
			# arrastraba al par por el piso durante todo el huracán)
			victima.position.x = clampf(atacante.position.x + float(dir) * BODY_SEP, 120.0, 1800.0)
			victima.position.y = victima.floor_y
		# HURACÁN: suelta SOMBRAS azules y levanta POLVO bajo sus pies mientras gira
		ghost_cd -= dt
		if ghost_cd <= 0.0:
			ghost_cd = 0.04
			if atacante.has_method("_spawn_ghost"):
				atacante._spawn_ghost(false, true)   # estela BLANCA (energía pura)
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
			_dmg_number(victima, d)
			_ultra_count(idx, n0 + hit_i)
			combo_dmg[idx] += d
			combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
			victima._burst(0.9, false, 1, true)          # chispas AZULES
			_shake(11.0, 0.09)
			victima._play_sfx_key("take_hit")            # impacto en SU player (no corta la voz de Fe)
			victima.sprite.play("pummeled" if victima.sprite.sprite_frames.has_animation("pummeled") else "take_hit")
			victima.water_flash_t = 0.25                 # tinte azul-blanco del golpe
			flash_ms = Time.get_ticks_msec()
			flash_rect.color = Color(0.8, 0.9, 1.4, 0.3)   # destello BLANCO-azul (energía)
		t += dt
		await get_tree().process_frame
	# RECUPERACIÓN: desacelera saliendo del giro reproduciendo la ENTRADA al revés
	# (rotación -> guardia): el trompo se FRENA y Fe vuelve a la pose.
	for fr in range(cyc0, -1, -1):
		atacante.sprite.frame = fr
		await get_tree().create_timer(0.05).timeout
	_fe_cast_fx(atacante, false)                         # apaga el borde azul
	atacante.sprite.play("pose")
	# REMATE: lo derriba al piso (solo si el remolino lo atrapó)
	if alcanza:
		victima.receive_hit(false, false, dir, "", true, 1.0)
		# NO se espera el aterrizaje: _end_round maneja el vuelo→caída→boca abajo→freeze
	ultra_active = false
	var murio: bool = (dummy_hp <= 0) if idx == 0 else (player_hp <= 0)
	state = "fight"
	if _round_real() and murio:
		_end_round(idx == 0)
	else:
		_set_inputs(true)
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
	_ultra_banner_name = "ANNIHILATION"
	state = "ultra"
	_set_inputs(false)
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
	state = "fight"
	# ULTRA = FINISHER: solo se lanza con el rival en ROJO y el que lo recibe MUERE
	# (igual que ANNIHILATION/APOCALYPSE de DAM; en práctica se revive como siempre)
	if _round_real():
		if idx == 0:
			dummy_hp = 0
		else:
			player_hp = 0
		_end_round(idx == 0)
	else:
		_set_inputs(true)
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

# ============================================================================
# ROUM — ANNIHILATION (ultra CORTO, →→ R): GRAPPLER DE SUELO. Agarra al rival y lo
# MACHACA a ras de piso (cabezazos + rectos + agachados) SIN volar, y remata con el
# uppercut. Mismo framework que el ultra de Fe pero versión TERRESTRE (ambos plantados
# con ultra_hover para suprimir su física). Voz/nombre compartidos (annihilation).
# 12 golpes de ráfaga + combo(3) + remate(1) ≈ 16, como el ANNIHILATION de DAM.
const ROUM_ULTRA_SEQ := [
	["spin_kick", 0.62], ["punch", 0.56], ["crouch_punch", 0.24],
	["punch", 0.56], ["spin_kick", 0.62], ["crouch_punch", 0.24],
	["punch", 0.56], ["spin_kick", 0.62], ["punch", 0.56],
	["spin_kick", 0.62], ["crouch_punch", 0.24], ["spin_kick", 0.62],
]
func try_roum_ultra(atacante: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if atacante == player else 1
	if meter[idx] < 2.0:
		return false          # cuesta 2 BARRAS (ultra corto)
	if combo_n[idx] < 2 or combo_t[idx] > COMBO_WINDOW:
		return false          # necesita un combo VIVO de 2+ (pedido: basta con 2 golpes)
	# el rival debe estar EN ROJO: vida ≤25% (es un REMATE, como el de DAM/Fe)
	var vhp: int = dummy_hp if idx == 0 else player_hp
	if float(vhp) > float(hp_max[1 - idx]) * 0.25:
		return false
	meter[idx] -= 2.0
	_run_roum_ultra(atacante, idx)
	return true

func _run_roum_ultra(atacante: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	# PRIMER golpe bloqueable: si lo bloquea, el ultra NO entra (ni cobra el resto)
	var arranque: String = victima.receive_hit(false, false, dir, "kick_impact")
	if arranque != "hit" and arranque != "launched":
		return
	ultra_active = true
	_ultra_banner_name = "ANNIHILATION"
	state = "ultra"
	_set_inputs(false)
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	atacante.roum_super_t = 0.0
	_roum_border(atacante, true)                  # borde CARMESÍ (su color de poder)
	# entrada cinemática: congela + velo carmesí-oscuro + grito grave + shake
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.55, 0.05, 0.09, 0.6)
	Engine.time_scale = 0.0
	_shake(24.0, 0.5)
	var _hyap := "res://imagen-action/roum/sound-effect/voz-hya-roum.wav"
	if ResourceLoader.exists(_hyap):
		atacante.voz_player.stream = load(_hyap)
		atacante.voz_player.pitch_scale = 1.0
		atacante.voz_player.play()
	await get_tree().create_timer(0.5, true, false, true).timeout
	Engine.time_scale = 1.0
	# AGARRE: ambos quedan PLANTADOS a ras de piso; ultra_hover suprime su física
	var gy: float = victima.floor_y
	var n: int = combo_n[idx]
	var hp0: float = float(dummy_hp if idx == 0 else player_hp)
	var total_golpes := ROUM_ULTRA_SEQ.size() + 1
	var drain := maxi(1, int(round(hp0 * 0.92 / float(total_golpes))))
	atacante.ultra_hover = true
	atacante.airborne = false
	victima.ultra_hover = true
	victima.airborne = false
	victima.hit_flying = false
	atacante.set_facing(dir)
	atacante.position = Vector2(clampf(victima.position.x - float(dir) * 250.0, LEFT_LIMIT, RIGHT_LIMIT), gy)
	if atacante.sprite.sprite_frames.has_animation("ground_grab"):
		atacante.sprite.speed_scale = 1.0
		atacante.sprite.play("ground_grab")
	victima.set_facing(-dir)
	victima.position = Vector2(clampf(atacante.position.x + float(dir) * 250.0, LEFT_LIMIT, RIGHT_LIMIT), gy)
	victima.sprite.play("pummeled" if victima.sprite.sprite_frames.has_animation("pummeled") else "take_hit")
	await get_tree().create_timer(0.22).timeout
	# RÁFAGA de suelo: fija la POSE DE IMPACTO de cada clip (145f) y acelera el ritmo
	for i in ROUM_ULTRA_SEQ.size():
		if state != "ultra":
			break
		var frac: float = float(i) / float(maxi(1, ROUM_ULTRA_SEQ.size() - 1))
		var ramp := pow(frac, 1.5)
		var anim: String = ROUM_ULTRA_SEQ[i][0]
		var hitfrac: float = ROUM_ULTRA_SEQ[i][1]
		atacante.set_facing(dir)
		atacante.position = Vector2(clampf(victima.position.x - float(dir) * 250.0, LEFT_LIMIT, RIGHT_LIMIT), gy)
		if atacante.sprite.sprite_frames.has_animation(anim):
			atacante.sprite.play(anim)
			atacante.sprite.speed_scale = 0.0
			var fc: int = atacante.sprite.sprite_frames.get_frame_count(anim)
			atacante.sprite.frame = clampi(int(hitfrac * float(fc)), 0, fc - 1)
		# rival aturdido a ras de piso: se CONGELA igual que ROUM (speed_scale=0) y solo salta a una
		# pose de retroceso NUEVA por golpe → reacciona AL MISMO RITMO (antes su anim corría sola = rápida).
		victima.set_facing(-dir)
		victima.position.y = gy
		var vanim: String = "pummeled" if victima.sprite.sprite_frames.has_animation("pummeled") else "take_hit"
		victima.sprite.play(vanim)
		victima.sprite.speed_scale = 0.0
		var vfc: int = victima.sprite.sprite_frames.get_frame_count(vanim)
		var vbase: int = 9 if vanim == "pummeled" else int(vfc / 2)
		victima.sprite.frame = clampi(vbase - 1 + (i % 3), 0, vfc - 1)   # sacudida distinta por golpe
		victima._play_sfx_key("take_hit")
		victima._burst(1.05, false, 1, false)     # chispas CARMESÍ (no azules)
		atacante._spawn_slam_dust(dir, 0.7)       # polvo del impacto
		_shake(lerpf(12.0, 18.0, ramp), 0.1)
		n += 1
		_ultra_count(idx, n)
		if idx == 0:
			dummy_hp = maxi(1, dummy_hp - drain)
		else:
			player_hp = maxi(1, player_hp - drain)
		combo_dmg[idx] += drain
		combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
		await get_tree().create_timer(lerpf(0.30, 0.09, ramp)).timeout
	atacante.sprite.speed_scale = 1.0
	victima.sprite.speed_scale = 1.0   # descongela al rival para que el LANZAMIENTO del gancho lo anime
	# FINISHER: UPPERCUT que lo REVIENTA + vacía la vida restante
	# FINISHER = el GANCHO (uppercut): ROUM levanta el puño y REVIENTA al rival hacia ARRIBA.
	# El puño SUBE primero (ambos siguen congelados) y el LANZAMIENTO cae justo en el pico (~f7).
	if state == "ultra":
		n += 1
		_ultra_count(idx, n, "ANNIHILATION")      # ultra CORTO = ANNIHILATION (igual que DAM)
		atacante.set_facing(dir)
		atacante.sprite.speed_scale = 1.0
		if atacante.sprite.sprite_frames.has_animation("uppercut"):
			atacante.sprite.play("uppercut")
		await get_tree().create_timer(0.23).timeout   # deja SUBIR el puño hasta la extensión
	if state == "ultra":
		_play_voz("annihilation")                 # grita el nombre EN EL IMPACTO del gancho
		flash_ms = Time.get_ticks_msec()
		flash_rect.color = Color(1.1, 0.18, 0.24, 0.85)   # fogonazo CARMESÍ
		_shake(30.0, 0.4)
		Engine.time_scale = 0.3
		if idx == 0:
			combo_dmg[idx] += dummy_hp
			dummy_hp = 0
		else:
			combo_dmg[idx] += player_hp
			player_hp = 0
		combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]
		# el GANCHO lo LANZA al AIRE (launch alto); _end_round maneja el vuelo→caída→KO
		victima.ultra_hover = false
		atacante.ultra_hover = false
		victima.receive_hit(false, true, dir, "kick_impact", false, 1.9)
		await get_tree().create_timer(0.45, true, false, true).timeout
		Engine.time_scale = 1.0
	# cierre
	_roum_border(atacante, false)
	atacante.ultra_hover = false
	atacante.airborne = false
	atacante.position.y = atacante.floor_y
	atacante.sprite.speed_scale = 1.0
	atacante.sprite.play("pose")
	ultra_active = false
	state = "fight"
	# ULTRA = FINISHER: solo entra con el rival en ROJO y el que lo recibe MUERE
	if _round_real():
		if idx == 0:
			dummy_hp = 0
		else:
			player_hp = 0
		_end_round(idx == 0)
	else:
		_set_inputs(true)
		dummy.ai_enabled = dummy_ai_mode

# ============================================================================
#  ULTRA DE PORTALES de ROUM (←← → + R): encadena sus 3 agarres por PORTAL a
#  máxima potencia — GROUND GRAB (halan) -> WARP GRAB (traga+escupe) -> PIT GRAB
#  (pozo+cielo) -> SLAM final. NO usa el súper. Cuesta 2 barras + combo vivo (2+).
# ============================================================================
func _pu_damage(idx: int, dmg: int) -> void:
	if idx == 0:
		dummy_hp = maxi(0, dummy_hp - dmg)
	else:
		player_hp = maxi(0, player_hp - dmg)
	combo_dmg[idx] += dmg
	combo_dmg_lbl[idx].text = "DMG  %d" % combo_dmg[idx]

const PU_GAP := 360.0   # distancia Roum↔rival en el pummel (evita que se encimen; Roum es ancho)
var _pu_vscale := Vector2.ONE   # escala REAL del nodo del rival al empezar el ultra (para restaurar bien)
var _pu_i := 0                  # nº de golpe del ultra (para el ritmo: empieza LENTO y ACELERA)
const PU_TOTAL := 22.0          # golpes aprox del ultra (para el ramp de velocidad)

# un GOLPE del pummel del ultra: congela la pose de impacto de Roum + pose de retroceso del
# rival SIN encimarse (PU_GAP), chispas+polvo+shake, daña y cuenta. Devuelve el nuevo n.
func _pu_hit(atacante: Node2D, victima: Node2D, idx: int, dir: int, gy: float, anim: String, hitfrac: float, dmg: int, nm: String, n: int, wait: float) -> int:
	atacante.set_facing(dir)
	atacante.position = Vector2(clampf(victima.position.x - float(dir) * PU_GAP, LEFT_LIMIT, RIGHT_LIMIT), gy)
	if atacante.sprite.sprite_frames.has_animation(anim):
		atacante.sprite.play(anim)
		atacante.sprite.speed_scale = 0.0
		var afc: int = atacante.sprite.sprite_frames.get_frame_count(anim)
		atacante.sprite.frame = clampi(int(hitfrac * float(afc)), 0, afc - 1)
	victima.set_facing(-dir)
	victima.position.y = gy
	var vanim: String = "pummeled" if victima.sprite.sprite_frames.has_animation("pummeled") else "take_hit"
	victima.sprite.play(vanim)
	victima.sprite.speed_scale = 0.0
	var vfc: int = victima.sprite.sprite_frames.get_frame_count(vanim)
	var vbase: int = 9 if vanim == "pummeled" else int(vfc / 2)
	victima.sprite.frame = clampi(vbase - 1 + (n % 3), 0, vfc - 1)
	atacante._play_sfx_key("kick_impact")   # golpe de IMPACTO (canal del atacante)
	victima._play_sfx_key("take_hit")       # quejido del rival (otro canal)
	# DING de COMBO que sube de tono con cada golpe encadenado (el sonido que faltaba)
	if ding_stream:
		var st: int = DING_SCALE[mini(maxi(n - 1, 0), DING_SCALE.size() - 1)]
		ding_player.stream = ding_stream
		ding_player.pitch_scale = pow(2.0, float(st) / 12.0)
		ding_player.play()
	victima._burst(1.05, false, 1, false)
	atacante._spawn_slam_dust(dir, 0.7)
	_shake(15.0, 0.1)
	n += 1
	_ultra_count(idx, n, nm)
	_pu_damage(idx, dmg)
	# RITMO: arranca LENTO y ACELERA de a poco (start slow -> fast). Ignora el 'wait' fijo.
	var frac: float = clampf(float(_pu_i) / PU_TOTAL, 0.0, 1.0)
	_pu_i += 1
	await get_tree().create_timer(lerpf(0.26, 0.075, pow(frac, 0.9)), true, false, true).timeout
	return n

# LEVANTA al rival por el aire (juggle) mientras Roum se queda en el piso
func _pu_juggle_up(victima: Node2D, target_y: float, dur: float) -> void:
	if victima.sprite.sprite_frames.has_animation("hit_fly"):
		victima.sprite.speed_scale = 1.0
		victima.sprite.play("hit_fly")
	var y0: float = victima.position.y
	var t := 0.0
	while t < dur and state == "ultra":
		t += get_process_delta_time()
		victima.position.y = lerpf(y0, target_y, _ease_out_cubic(clampf(t / dur, 0.0, 1.0)))
		await get_tree().process_frame
	victima.position.y = target_y

func try_roum_portal_ultra(atacante: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if atacante == player else 1
	if meter[idx] < 2.0:
		return false          # cuesta 2 BARRAS
	if combo_n[idx] < 2 or combo_t[idx] > COMBO_WINDOW:
		return false          # necesita un combo VIVO de 2+
	meter[idx] -= 2.0
	_run_roum_portal_ultra(atacante, idx)
	return true

func _run_roum_portal_ultra(atacante: Node2D, idx: int) -> void:
	var victima: Node2D = dummy if idx == 0 else player
	var dir := 1 if victima.position.x >= atacante.position.x else -1
	# PRIMER golpe bloqueable: si lo bloquea, el ultra NO entra (ni cobra)
	var arranque: String = victima.receive_hit(false, false, dir, "kick_impact")
	if arranque != "hit" and arranque != "launched":
		return
	ultra_active = true
	_ultra_banner_name = "VOID GRASP"
	state = "ultra"
	_set_inputs(false)
	dummy.ai_enabled = false
	atacante.buffer_t = 0.0
	atacante.special_t = 0.0
	atacante.roum_super_t = 0.0
	_roum_border(atacante, true)
	# ENTRADA cinemática: congela + velo carmesí + grito grave + shake
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(0.55, 0.05, 0.09, 0.6)
	Engine.time_scale = 0.0
	_shake(24.0, 0.5)
	var _hyap := "res://imagen-action/roum/sound-effect/voz-hya-roum.wav"
	if ResourceLoader.exists(_hyap):
		atacante.voz_player.stream = load(_hyap)
		atacante.voz_player.pitch_scale = 1.0
		atacante.voz_player.play()
	await get_tree().create_timer(0.5, true, false, true).timeout
	Engine.time_scale = 1.0
	var gy: float = victima.floor_y
	var fc := dir
	var hp0: float = float(dummy_hp if idx == 0 else player_hp)
	var n: int = combo_n[idx]
	atacante.ultra_hover = true
	atacante.airborne = false
	victima.ultra_hover = true
	victima.airborne = false
	victima.hit_flying = false

	# escala REAL del nodo del rival (para encoger/restaurar bien; NO usar base_scale, que va en el sprite)
	_pu_vscale = victima.scale
	_pu_i = 0                       # reinicia el ritmo (empieza lento y acelera)
	# fuerza escala normal por si un squash/stretch quedó congelado (evita el "grande")
	atacante.sprite.scale = atacante.base_scale

	# ============ JUGGLE: Roum GOLPEA (solo sus poses de golpe, SIN anim de portal) ============
	n = await _pu_hit(atacante, victima, idx, dir, gy, "uppercut", 0.52, int(hp0 * 0.06), "HOOK", n, 0.09)
	if state != "ultra": _portal_ultra_end(atacante, victima, idx) ; return
	n = await _pu_hit(atacante, victima, idx, dir, gy, "punch", 0.5, int(hp0 * 0.05), "", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "crouch_punch", 0.5, int(hp0 * 0.05), "", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "weak_punch", 0.5, int(hp0 * 0.05), "", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "spin_kick", 0.5, int(hp0 * 0.06), "HEADBUTT", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "punch", 0.5, int(hp0 * 0.05), "", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "crouch_punch", 0.5, int(hp0 * 0.05), "", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "kick", 0.5, int(hp0 * 0.06), "", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "punch", 0.5, int(hp0 * 0.05), "", n, 0.09)
	if state != "ultra": _portal_ultra_end(atacante, victima, idx) ; return

	# ============ EL PORTAL (UNO SOLO): el rival se METE ADENTRO ============
	var bhp: AudioStreamPlayer = null
	if ResourceLoader.exists("res://imagen-action/roum/sound-effect/black-hole.mp3"):
		bhp = AudioStreamPlayer.new()
		bhp.stream = load("res://imagen-action/roum/sound-effect/black-hole.mp3")
		bhp.volume_db = 2.0
		add_child(bhp)
		bhp.finished.connect(bhp.queue_free)
		bhp.play()
	var portal := _make_void_portal(self)
	portal.position = Vector2(clampf(atacante.position.x + float(fc) * 470.0, LEFT_LIMIT, RIGHT_LIMIT), gy - 130.0)
	portal.scale = Vector2(float(fc) * 0.38, 1.20)   # elipse vertical GRANDE (por acá entra)
	await _portal_grow(portal, 0.0, 1.0, 0.18)
	var suck := _portal_suck_fx(portal.position)
	_shake(14.0, 0.14)
	if victima.sprite.sprite_frames.has_animation("get_pull"):
		victima.sprite.speed_scale = 1.0
		victima.sprite.play("get_pull")
	# SUCCIÓN: el rival es arrastrado y se METE COMPLETO dentro (posición=CENTRO, escala→0, se desvanece)
	var vp0: Vector2 = victima.position
	var ts := 0.0
	while ts < 0.30 and state == "ultra":
		ts += get_process_delta_time()
		var k := clampf(ts / 0.30, 0.0, 1.0)
		var kk := pow(k, 2.2)                       # acelera hacia el portal (succión)
		victima.position = vp0.lerp(portal.position, kk)
		victima.scale = _pu_vscale * lerpf(1.0, 0.02, kk)
		victima.modulate = Color(1, 1, 1, 1).lerp(Color(0.2, 0.08, 0.10, 0.0), kk)
		await get_tree().process_frame
	# YA ESTÁ ADENTRO: invisible dentro del portal
	victima.position = portal.position
	victima.scale = _pu_vscale * 0.02
	victima.modulate = Color(1, 1, 1, 0)
	if is_instance_valid(suck): suck.emitting = false
	_shake(10.0, 0.1)
	await get_tree().create_timer(0.18, true, false, true).timeout   # un instante: solo el portal
	# SALE del portal TELETRANSPORTADO justo frente a Roum (aparece de golpe)
	var tcl := create_tween() ; tcl.tween_property(portal, "scale", Vector2(0, portal.scale.y), 0.16) ; tcl.tween_callback(portal.queue_free)
	victima.position = Vector2(clampf(atacante.position.x + float(fc) * PU_GAP, LEFT_LIMIT, RIGHT_LIMIT), gy)
	victima.scale = _pu_vscale
	victima.modulate = Color(1, 1, 1, 1)
	victima.set_facing(-fc)
	if atacante.has_method("_spawn_jump_dust"): atacante._spawn_jump_dust(1.3)
	victima._burst(1.3, false, 1, false)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "ground_grab", 0.45, int(hp0 * 0.06), "VOID GRAB", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "punch", 0.5, int(hp0 * 0.05), "", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "spin_kick", 0.5, int(hp0 * 0.06), "HEADBUTT", n, 0.09)
	if state != "ultra": _portal_ultra_end(atacante, victima, idx) ; return

	# ============ AGARRE de vendas + FLURRY final ============
	if atacante.sprite.sprite_frames.has_animation("ground_grab"):
		atacante.sprite.speed_scale = 0.0
		atacante.sprite.play("ground_grab")
	var ribG := _make_portal_ribbons(5)
	var phG := 0.0
	var tG := 0.0
	while tG < 0.20 and state == "ultra":
		tG += get_process_delta_time()
		phG += get_process_delta_time() * 12.0
		_update_portal_ribbons(ribG, Vector2(atacante.position.x + float(dir) * 120.0, atacante.position.y + 150.0 * atacante.base_scale.y), Vector2(victima.position.x, victima.position.y + 210.0 * victima.base_scale.y), clampf(tG / 0.20, 0.0, 1.0), phG)
		await get_tree().process_frame
	ribG.queue_free()
	n = await _pu_hit(atacante, victima, idx, dir, gy, "ground_grab", 0.5, int(hp0 * 0.05), "GRAB", n, 0.09)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "punch", 0.5, int(hp0 * 0.04), "", n, 0.08)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "crouch_punch", 0.5, int(hp0 * 0.04), "", n, 0.08)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "weak_punch", 0.5, int(hp0 * 0.04), "", n, 0.08)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "kick", 0.5, int(hp0 * 0.05), "", n, 0.08)
	n = await _pu_hit(atacante, victima, idx, dir, gy, "punch", 0.5, int(hp0 * 0.04), "", n, 0.08)
	if state != "ultra": _portal_ultra_end(atacante, victima, idx) ; return

	# ============ REMATE: PATADA lo LEVANTA -> PORTAL de ARRIBA lo agarra -> lo saca -> GANCHO final ============
	# 1) PATADA (W) que lo LEVANTA al aire
	n = await _pu_hit(atacante, victima, idx, dir, gy, "kick", 0.5, int(hp0 * 0.05), "LAUNCH", n, 0.06)
	if state != "ultra": _portal_ultra_end(atacante, victima, idx) ; return
	await _pu_juggle_up(victima, gy - 340.0, 0.16)
	# 2) PORTAL DE ARRIBA lo AGARRA en el aire y lo traga
	var sky := _make_void_portal(self)
	sky.position = Vector2(victima.position.x, victima.position.y - 130.0)
	sky.scale = Vector2(float(fc) * 0.32, 0.60)
	await _portal_grow(sky, 0.0, 1.0, 0.12)
	var ribS := _make_portal_ribbons(5)
	var phS := 0.0
	var tS := 0.0
	while tS < 0.16 and state == "ultra":
		tS += get_process_delta_time()
		phS += get_process_delta_time() * 12.0
		_update_portal_ribbons(ribS, sky.position, Vector2(victima.position.x, victima.position.y + 210.0 * victima.base_scale.y), clampf(tS / 0.16, 0.0, 1.0), phS)
		await get_tree().process_frame
	ribS.queue_free()
	var svp: Vector2 = victima.position
	var ts2 := 0.0
	while ts2 < 0.14 and state == "ultra":
		ts2 += get_process_delta_time()
		var k := clampf(ts2 / 0.14, 0.0, 1.0)
		victima.position = svp.lerp(sky.position, _ease_out_cubic(k))
		victima.modulate = Color(1, 1, 1, 1).lerp(Color(0.2, 0.08, 0.10, 0.0), k)
		await get_tree().process_frame
	var tscl := create_tween() ; tscl.tween_property(sky, "scale", Vector2(0, sky.scale.y), 0.14) ; tscl.tween_callback(sky.queue_free)
	# 3) LO SACA otra vez, justo frente a Roum
	victima.position = Vector2(clampf(atacante.position.x + float(fc) * PU_GAP, LEFT_LIMIT, RIGHT_LIMIT), gy)
	victima.modulate = Color(1, 1, 1, 1)
	victima.set_facing(-fc)
	victima._burst(1.3, false, 1, false)
	if atacante.has_method("_spawn_jump_dust"): atacante._spawn_jump_dust(1.2)
	# 4) GANCHO FINAL: vacía la vida y lo LANZA volando -> cae -> se acaba
	n += 1
	_ultra_count(idx, n, "VOID GRASP")
	if atacante.sprite.sprite_frames.has_animation("uppercut"):
		atacante.sprite.speed_scale = 1.0
		atacante.sprite.play("uppercut")
	await get_tree().create_timer(0.18, true, false, true).timeout   # deja SUBIR el puño
	if ResourceLoader.exists(_hyap):
		atacante.voz_player.stream = load(_hyap)
		atacante.voz_player.pitch_scale = 0.9
		atacante.voz_player.play()
	flash_ms = Time.get_ticks_msec()
	flash_rect.color = Color(1.1, 0.18, 0.24, 0.85)
	_shake(34.0, 0.45)
	Engine.time_scale = 0.3
	if bhp != null and is_instance_valid(bhp):
		var twb := create_tween() ; twb.tween_property(bhp, "volume_db", -40.0, 0.18) ; twb.tween_callback(bhp.queue_free)
	var restante: int = dummy_hp if idx == 0 else player_hp
	_pu_damage(idx, maxi(0, restante - maxi(0, int(hp0 * 0.06))))   # deja ~6% (o mata si ya estaba bajo)
	victima._burst(1.8, false, 1, false)
	# VUELA y CAE: suelta el hover y lo LANZA fuerte hacia arriba -> _end_round maneja vuelo/caída/KO
	victima.ultra_hover = false
	victima.receive_hit(false, true, dir, "kick_impact", false, 2.2)
	await get_tree().create_timer(0.45, true, false, true).timeout
	Engine.time_scale = 1.0
	_portal_ultra_end(atacante, victima, idx)

func _portal_ultra_end(atacante: Node2D, victima: Node2D, idx: int) -> void:
	Engine.time_scale = 1.0
	_roum_border(atacante, false)
	atacante.ultra_hover = false
	atacante.airborne = false
	atacante.position.y = atacante.floor_y
	atacante.sprite.speed_scale = 1.0
	atacante.sprite.play("pose")
	if is_instance_valid(victima):
		victima.ultra_hover = false
		victima.scale = _pu_vscale                # restaura la escala REAL del nodo (por si abortó encogido)
		victima.modulate = Color(1, 1, 1, 1)
		if not victima.hit_flying:                # si fue LANZADO en el remate, que siga volando (no clavarlo)
			victima.position.y = victima.floor_y
	ultra_active = false
	state = "fight"
	if _round_real():
		if idx == 0:
			dummy_hp = 0
		else:
			player_hp = 0
		_end_round(idx == 0)
	else:
		_set_inputs(true)
		dummy.ai_enabled = dummy_ai_mode

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
	_ultra_banner_name = "APOCALYPSE"
	state = "ultra"
	_set_inputs(false)
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
	var drain := maxi(1, int(round(hp0 * 0.94 / 17.0)))   # ~17 golpes reparten 94%; el 3er rayo remata
	# el rival queda CLAVADO EN EL SUELO frente a ella TODO el ultra (pedido: los rayos
	# NO lo levantan, nada de flotar ni teleports — física suprimida, main lo posiciona)
	victima.ultra_hover = true
	victima.airborne = false
	victima.hit_flying = false
	victima.position.y = victima.floor_y
	atacante.set_facing(dir)
	victima.set_facing(-dir)
	# ---- FASE 1: RAYO de apertura — cae SOBRE el rival y lo ELECTROCUTA en el sitio ----
	if state == "ultra":
		atacante.ultra_hover = false
		atacante.airborne = false
		atacante.position.y = atacante.floor_y
		atacante.sprite.speed_scale = 1.4
		atacante.sprite.play("water_cast")
		if atacante.voz_player != null:
			atacante.voz_player.stream = load("res://imagen-action/favi/Fe-sound-effect/water-cast-fe-energetica.wav")
			atacante.voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
			atacante.voz_player.play()
		if atacante.has_method("spawn_water_geyser"):
			atacante.spawn_water_geyser(victima.position.x)
		_shake(13.0, 0.16)
		await get_tree().create_timer(0.30).timeout
		victima.position = Vector2(clampf(victima.position.x, LEFT_LIMIT, RIGHT_LIMIT), victima.floor_y)
		victima.electro_t = 0.55    # parpadeo eléctrico, quieto en el piso
		n += 1
		_ultra_count(idx, n)
		_fe_ultra_hit(idx, victima, drain)
	# rampa GLOBAL de los golpes (dash+peonza+air): arranca LENTO y ACELERA, como DAM.
	var k := 0.0
	var kmax := 13.0   # rampa sobre dash(3) + combo variado(10)
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
			victima.position = Vector2(cx, victima.floor_y)
			await get_tree().process_frame
			dt2 += get_process_delta_time()
		for h in 3:
			if state != "ultra":
				break
			var rp: float = pow(k / kmax, 1.7)
			victima.position = Vector2(cx, victima.floor_y)
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
	# ---- FASE 3: COMBO VARIADO en el lugar (pedido: nada de repetir la peonza 14 veces)
	# — jab, aguja, doble patada, tijera baja, peonza, barrida... su kit entero, acelerando
	if state == "ultra":
		var COMBO_VAR := ["weak_punch", "punch", "kick", "crouch_punch", "spin_kick",
				"weak_punch", "sweep", "kick", "punch", "spin_kick"]
		for h in COMBO_VAR.size():
			if state != "ultra":
				break
			var rp: float = pow(k / kmax, 1.7)
			victima.position = Vector2(cx, victima.floor_y)
			victima.set_facing(-dir)
			atacante.ultra_hover = false
			atacante.airborne = false
			atacante.position = Vector2(clampf(cx - float(dir) * 150.0, LEFT_LIMIT, RIGHT_LIMIT), atacante.floor_y)
			atacante.set_facing(dir)
			atacante.sprite.speed_scale = lerpf(1.6, 3.4, rp)
			atacante.sprite.play(COMBO_VAR[h])
			n += 1
			_ultra_count(idx, n)
			_fe_ultra_hit(idx, victima, drain)
			_shake(10.0, 0.08)
			await get_tree().create_timer(lerpf(0.42, 0.045, rp)).timeout
			k += 1.0
	# ---- FASE 4 (FINAL, pedido): Fe SE APARTA y caen LOS TRES RAYOS, uno tras otro,
	# sobre el rival CLAVADO en el piso — el tercero es el APOCALYPSE que lo funde ----
	if state == "ultra":
		atacante.ultra_hover = false
		atacante.airborne = false
		atacante.position = Vector2(clampf(cx - float(dir) * 520.0, LEFT_LIMIT, RIGHT_LIMIT), atacante.floor_y)
		atacante.set_facing(dir)
		for r in 3:
			if state != "ultra":
				break
			atacante.sprite.speed_scale = 2.0
			atacante.sprite.play("water_cast")
			if atacante.has_method("spawn_water_geyser"):
				atacante.spawn_water_geyser(cx)
			victima.position = Vector2(cx, victima.floor_y)
			victima.set_facing(-dir)
			victima.electro_t = 0.5              # convulsiona electrocutado, SIN elevarse
			flash_ms = Time.get_ticks_msec()
			flash_rect.color = Color(0.8, 0.9, 1.4, 0.35)
			_shake(14.0, 0.14)
			if r < 2:
				n += 1
				_ultra_count(idx, n)
				_fe_ultra_hit(idx, victima, drain)
				await get_tree().create_timer(0.34).timeout
			else:
				# TERCER RAYO = APOCALYPSE: vacía la vida; muere ELECTROCUTADO de pie
				# y se DESPLOMA con su caída (nada de salir volando)
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
				victima.ultra_hover = false
				victima.electro_t = 0.9
				victima.receive_hit(false, false, dir, "kick_impact")
				await get_tree().create_timer(0.45, true, false, true).timeout
				Engine.time_scale = 1.0
	# cierre
	_fe_cast_fx(atacante, false)
	atacante.ultra_hover = false
	atacante.airborne = false
	atacante.position.y = atacante.floor_y
	atacante.sprite.speed_scale = 1.0
	atacante.sprite.play("pose")
	atacante.breaker_fx_t = 0.0
	ultra_active = false
	state = "fight"
	# ULTRA = FINISHER: el que recibe el APOCALYPSE de Fe MUERE (regla de los ultras)
	if _round_real():
		if idx == 0:
			dummy_hp = 0
		else:
			player_hp = 0
		_end_round(idx == 0)
	else:
		_set_inputs(true)
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
		var rgw := Line2D.new()             # HALO neón (más ancho, translúcido) DETRÁS del arco -> bloom
		rgw.width = MANA_RING_W + 6.0
		rgw.default_color = Color(0.62, 0.30, 1.5, 0.5)
		rgw.joint_mode = Line2D.LINE_JOINT_ROUND
		rgw.begin_cap_mode = Line2D.LINE_CAP_ROUND
		rgw.end_cap_mode = Line2D.LINE_CAP_ROUND
		cont.add_child(rgw)
		mana_ring_glow[side] = rgw
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
var _victory_stream_roum = null  # voz de victoria de ROUM (audio del PROPIO clip victorymp4)
func _play_victory_line(who = null) -> void:
	# Aye se detecta por fx_floral; Fe por su animación exclusiva water_cast; ROUM por fx_warrior; si no, DAM
	var es_aye: bool = who != null and bool(who.get("fx_floral"))
	var es_fe: bool = who != null and not es_aye and who.sprite.sprite_frames.has_animation("water_cast")
	var es_roum: bool = who != null and bool(who.get("fx_warrior"))
	var es_zetma: bool = who != null and bool(who.get("fx_dark"))
	var stream = null
	if es_zetma:
		return                          # ZETMA: su victoria NO grita (no es KO) — sin voz
	if es_aye:
		if _victory_stream_aye == null:
			var raye := "res://imagen-action/aye/sound-effect/victory-aye.mp3"
			_victory_stream_aye = load(raye) if ResourceLoader.exists(raye) else null
		stream = _victory_stream_aye
	elif es_roum:
		# ROUM: su grito de victoria "IS MY VICTORY" (fallback al audio del clip viejo)
		if _victory_stream_roum == null:
			var rr := "res://imagen-action/roum/sound-effect/is-my-victory-roum.mp3"
			if not ResourceLoader.exists(rr):
				rr = "res://imagen-action/roum/sound-effect/victory-roum.wav"
			_victory_stream_roum = load(rr) if ResourceLoader.exists(rr) else null
		stream = _victory_stream_roum
	elif es_fe:
		if _victory_stream_fe == null:
			# "No... that was easy" — la línea presumida que ACTÚA el clip de victory
			# (la anim nueva la muestra hablando); fallback a la vieja enérgica
			var rfe := "res://imagen-action/favi/Fe-sound-effect/was-easy-fe.wav"
			if not ResourceLoader.exists(rfe):
				rfe = "res://imagen-action/favi/Fe-sound-effect/victory-fe-energetica.wav"
			_victory_stream_fe = load(rfe) if ResourceLoader.exists(rfe) else null
		stream = _victory_stream_fe
	else:
		if _victory_stream == null:
			# DAM: el audio del PROPIO clip de victoria (el rugido que puso la AI, pedido)
			var ruta := "res://imagen-action/sound-effect/victory-dam.wav"
			if not ResourceLoader.exists(ruta):
				ruta = "res://imagen-action/sound-effect/my-work-is-done-dam.mp3"
			_victory_stream = load(ruta) if ResourceLoader.exists(ruta) else null
		stream = _victory_stream
	if stream != null and voz_player != null:
		# delay para que la voz caiga CUANDO la boca se mueve: Fe primero da su GIRO y
		# habla al plantarse (frame ~40 @30fps ≈ 1.3s); DAM usa el audio del PROPIO clip
		# (ya trae su timing interno: arranca a la vez que la anim); Aye casi de inmediato
		await get_tree().create_timer(1.55 if es_fe else (0.0 if not es_aye else 0.35)).timeout
		voz_player.stream = stream
		voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
		voz_player.play()

# grito de finisher: reproduce voz-<nombre>.wav si existe (voz infernal)
func _play_voz(nombre: String) -> void:
	if not _voz_cache.has(nombre):
		var ruta := "res://imagen-action/sound-effect/voz-%s.wav" % nombre
		_voz_cache[nombre] = load(ruta) if ResourceLoader.exists(ruta) else null
	var st = _voz_cache[nombre]
	if st != null and voz_player != null:
		voz_player.stream = st
		voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
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
		kick_voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
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
	# BORDE del focus: MORADO para Aye (fx_floral), MORADO NEÓN OSCURO para Zetma (fx_dark),
	# ROJO para DAM/Fe (default del shader)
	_outline_mat.set_shader_parameter("line_color",
		Color(1.45, 0.35, 2.0, 1.0) if atacante.fx_floral \
		else (Color(1.25, 0.18, 2.1, 1.0) if atacante.fx_dark \
		else Color(1.9, 0.12, 0.12, 1.0)))
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
func _apply_alt_colors() -> void:
	# COLOR 2 DESACTIVADO (el usuario lo pidió quitar): ambos peleadores con su color normal.
	player.base_material = null; player.sprite.material = null
	dummy.base_material = null;  dummy.sprite.material = null

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
	# velo OSCURO del BERSERK (detrás de los peleadores): la escena se apaga mientras
	# alguien está en rabia; se funde suave en _update_hud
	rage_dim = ColorRect.new()
	rage_dim.color = Color(0.02, 0.0, 0.01, 0.0)
	rage_dim.position = Vector2.ZERO
	rage_dim.size = Vector2(1920, 1080)
	rage_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rage_dim.z_index = -1
	add_child(rage_dim)
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

# --- banners de inicio de ronda (imágenes GET READY / FIGHT) ---
func _build_round_banner() -> void:
	round_banner = TextureRect.new()
	round_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	round_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	round_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_banner.size = RB_BOX
	round_banner.pivot_offset = RB_BOX * 0.5           # escala desde el centro (para el golpe)
	round_banner.position = RB_CENTER - RB_BOX * 0.5
	round_banner.z_index = -1                           # DETRÁS de los peleadores (sobre el escenario)
	round_banner.z_as_relative = false
	round_banner.visible = false
	add_child(round_banner)
	if ResourceLoader.exists(RB_READY):
		rb_ready_tex = load(RB_READY)
	if ResourceLoader.exists(RB_FIGHT):
		rb_fight_tex = load(RB_FIGHT)
	if ResourceLoader.exists(RB_COUNTER):
		rb_counter_tex = load(RB_COUNTER)
	# ---- BANDA ROJA animada para READY / FIGHT ----
	# la banda es MÁS ANCHA que la pantalla (2400) para que, al estar INCLINADA, siga cubriendo
	# de extremo a extremo sin dejar huecos en las esquinas.
	rb_band = ColorRect.new()
	rb_band.color = RB_BAND_COL                           # MORADO del juego (antes rojo apagado)
	rb_band.size = Vector2(2400.0, RB_BAND_H)
	rb_band.position = Vector2(-240.0, RB_BAND_CY - RB_BAND_H * 0.5)
	rb_band.pivot_offset = Vector2(1200.0, RB_BAND_H * 0.5) # wipe + rotación desde el CENTRO
	rb_band.rotation = RB_BAND_ROT                         # inclinada (no recta)
	rb_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rb_band.z_index = -1                                   # DETRÁS de los peleadores (como el resto de anuncios)
	rb_band.z_as_relative = false
	rb_band.visible = false
	add_child(rb_band)
	# BORDES VERDES arriba y abajo, METIDOS dentro de la banda (deja un MARGEN morado en el borde exterior),
	# con la PALABRA repetida en negro (más chica). Hacia el CENTRO, un set de LÍNEAS lavanda separadas
	# que van de GORDA a DELGADA. Todo es hijo de rb_band → abre/cierra con ella.
	var RB_MARGIN := 16.0                                  # margen morado en el borde exterior (la franja va metida)
	var line_ws := [10.0, 7.0, 5.0, 3.0]                   # deco: gorda → delgada
	for edge in ["top", "bot"]:
		var top: bool = edge == "top"
		var bd := ColorRect.new()
		bd.color = RB_BORDER_COL
		bd.size = Vector2(2400.0, RB_BORDER_H)
		bd.position = Vector2(0.0, RB_MARGIN if top else RB_BAND_H - RB_BORDER_H - RB_MARGIN)
		bd.clip_contents = true                            # el texto no se sale de la franja
		bd.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rb_band.add_child(bd)
		var bl := Label.new()
		bl.add_theme_font_override("font", combo_font)
		bl.add_theme_font_size_override("font_size", 34)   # GET READY más CHICO (antes 46)
		bl.add_theme_color_override("font_color", Color(0, 0, 0))   # LETRAS NEGRAS
		bl.size = Vector2(2400.0, RB_BORDER_H)
		bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		bl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bd.add_child(bl)
		if top:
			rb_border_top = bd
			rb_border_top_lbl = bl
		else:
			rb_border_bot = bd
			rb_border_bot_lbl = bl
		# LÍNEAS deco (gorda→delgada), separadas, hacia el CENTRO desde la franja verde
		var ly: float = (RB_MARGIN + RB_BORDER_H + 10.0) if top else (RB_BAND_H - RB_MARGIN - RB_BORDER_H - 10.0)
		for lw in line_ws:
			var ln := ColorRect.new()
			ln.color = Color(0.78, 0.62, 1.0, 0.95)        # lavanda (acento sobre el morado)
			ln.size = Vector2(2400.0, lw)
			ln.position = Vector2(0.0, ly if top else ly - lw)
			ln.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rb_band.add_child(ln)
			ly += (lw + 9.0) if top else -(lw + 9.0)
	# texto READY / FIGHT (encima de la banda, aparece DESPUÉS de que se abre) — GRANDE
	rb_text = Label.new()
	rb_text.add_theme_font_override("font", combo_font)
	rb_text.add_theme_font_size_override("font_size", 300)   # texto MÁS GRANDE (antes 250)
	rb_text.add_theme_constant_override("outline_size", 22)
	rb_text.add_theme_color_override("font_outline_color", Color(0.06, 0.0, 0.12))   # contorno morado oscuro
	rb_text.add_theme_color_override("font_color", Color(1, 1, 1))
	rb_text.size = Vector2(2400.0, RB_BAND_H)
	rb_text.position = Vector2(-240.0, RB_BAND_CY - RB_BAND_H * 0.5)
	rb_text.pivot_offset = Vector2(1200.0, RB_BAND_H * 0.5)
	rb_text.rotation = RB_BAND_ROT                         # inclinado igual que la banda
	rb_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rb_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rb_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rb_text.z_index = -1
	rb_text.z_as_relative = false
	rb_text.visible = false
	add_child(rb_text)

func _show_round_banner(which: String, dur: float) -> void:
	if round_banner == null:
		return
	var tex: Texture2D = rb_ready_tex
	if which == "fight":
		tex = rb_fight_tex
	elif which == "counter":
		tex = rb_counter_tex
	if tex == null:
		return
	round_banner.texture = tex
	rb_dur = dur
	rb_ms = Time.get_ticks_msec()
	rb_impact_done = false
	round_banner.position = RB_CENTER - RB_BOX * 0.5
	round_banner.visible = true
	round_banner.scale = Vector2(2.6, 2.6)
	round_banner.modulate.a = 0.0

# GOLPE: entra ENORME y se cierra de golpe con rebote (ease_out_back) + sacudida al aterrizar;
# sale creciendo un pelín y desvaneciéndose. Reloj REAL (inmune al time_scale del intro).
func _round_banner_tick() -> void:
	if round_banner == null or not round_banner.visible:
		return
	var t := float(Time.get_ticks_msec() - rb_ms) / 1000.0
	if t < 0.0 or t > rb_dur:
		round_banner.visible = false
		return
	var IN := 0.20
	var OUT := 0.22
	var pin := clampf(t / IN, 0.0, 1.0)
	var pout := clampf((t - (rb_dur - OUT)) / OUT, 0.0, 1.0)
	var sc := lerpf(2.6, 1.0, _ease_out_back(pin))     # zoom de golpe con rebote
	var a := clampf(pin * 4.0, 0.0, 1.0)
	if pout > 0.0:
		sc = lerpf(1.0, 1.16, _ease_in_cubic(pout))    # al irse crece un poco
		a = 1.0 - pout
	round_banner.scale = Vector2(sc, sc)
	round_banner.modulate.a = a
	if not rb_impact_done and pin >= 0.6:              # dispara la sacudida al aterrizar
		rb_impact_done = true
		_shake(22.0, 0.28)

# BANDA ROJA: muestra una palabra (READY / FIGHT). La banda se abre de extremo a extremo desde el
# centro, aparece la palabra, y al final la banda se cierra. Reloj REAL (inmune al time_scale).
func _show_round_band(word: String, dur: float, border_word := "", band_col := Color(0, 0, 0, 0), border_col := Color(0, 0, 0, 0)) -> void:
	if rb_band == null:
		return
	rb_text.text = word
	# COLORES por-llamada: si no se pasan (alfa 0), usa el MORADO/VERDE por defecto. DANGER pasa ROJO + AMARILLO.
	rb_band.color = band_col if band_col.a > 0.0 else RB_BAND_COL
	var bcol: Color = border_col if border_col.a > 0.0 else RB_BORDER_COL
	if rb_border_top != null:
		rb_border_top.color = bcol
	if rb_border_bot != null:
		rb_border_bot.color = bcol
	# BORDES: palabra (o border_word) repetida a lo ancho en letras NEGRAS
	var bw: String = border_word if border_word != "" else word
	var rep: String = (bw + "     ").repeat(16)
	if rb_border_top_lbl != null:
		rb_border_top_lbl.text = rep
	if rb_border_bot_lbl != null:
		rb_border_bot_lbl.text = rep
	rb_band_dur = dur
	rb_band_ms = Time.get_ticks_msec()
	rb_band.visible = true
	rb_band.scale.x = 0.001
	rb_band.modulate.a = 0.0
	rb_text.visible = true
	rb_text.scale = Vector2(1.0, 1.0)
	rb_text.position.x = -240.0 - 2000.0   # arranca fuera de pantalla por la IZQUIERDA
	rb_text.modulate.a = 0.0

# DANGER (1×/round, el PRIMER player que caiga a ≤25%) + nombre del ULTRA al terminar (flanco true→false).
func _danger_ultra_banner_tick() -> void:
	# DANGER: solo en pelea, una vez por round, el primero que entre en rojo
	if state == "fight" and not danger_round_shown \
			and (player_hp <= int(hp_max[0] * ULTRA_HP) or dummy_hp <= int(hp_max[1] * ULTRA_HP)):
		danger_round_shown = true
		# DANGER: banda ROJA + bordes AMARILLOS (letras negras) + dura MÁS en pantalla
		_show_round_band("DANGER", 2.2, "DANGER", Color(0.74, 0.09, 0.11, 0.96), Color(0.98, 0.85, 0.10, 1.0))
		# VOZ "DANGER" al salir la banda (archivo general DANGER.mp3)
		if voz_player != null and ResourceLoader.exists("res://imagen-action/sound-effect/DANGER.mp3"):
			voz_player.stream = load("res://imagen-action/sound-effect/DANGER.mp3")
			voz_player.pitch_scale = 1.0
			voz_player.play()
	# nombre del ULTRA: al pasar ultra_active de true→false, muestra su nombre en banda + bordes
	if _ultra_active_prev and not ultra_active and _ultra_banner_name != "":
		_show_round_band(_ultra_banner_name, 1.4)
		_ultra_banner_name = ""
	_ultra_active_prev = ultra_active

func _round_band_tick() -> void:
	if rb_band == null or not rb_band.visible:
		return
	var t := float(Time.get_ticks_msec() - rb_band_ms) / 1000.0
	if t < 0.0 or t > rb_band_dur:
		rb_band.visible = false
		rb_text.visible = false
		return
	var OPEN := 0.16
	var CLOSE := 0.18
	var op := clampf(t / OPEN, 0.0, 1.0)
	var cp := clampf((t - (rb_band_dur - CLOSE)) / CLOSE, 0.0, 1.0)
	# la banda hace WIPE horizontal: se abre desde el centro y al final se cierra
	var wx := _ease_out_cubic(op)
	if cp > 0.0:
		wx = 1.0 - _ease_in_cubic(cp)
	rb_band.scale.x = maxf(wx, 0.001)
	rb_band.modulate.a = clampf(op * 3.0, 0.0, 1.0) * (1.0 - cp)
	rb_band.position = _screen_off + Vector2(-240.0, RB_BAND_CY - RB_BAND_H * 0.5)   # sigue la pantalla (stage con scroll)
	# el TEXTO entra deslizando desde la IZQUIERDA, se centra un momento, y SALE por la DERECHA,
	# viajando A LO LARGO de la inclinación de la banda (no horizontal).
	var IN_T := 0.42
	var OUT_START := rb_band_dur - 0.46
	var dx := 0.0
	var dy := 0.0
	if t < IN_T:
		dx = lerpf(-2200.0, 0.0, _ease_out_cubic(t / IN_T))       # entra desde la izquierda
	elif t > OUT_START:
		# SALE por el COSTADO (a la DERECHA) SIGUIENDO la inclinación de la banda — NO hacia arriba
		# (el movimiento vertical hacía que la palabra se saliera de la banda y quedara overlap feo).
		var pe := _ease_in_cubic((t - OUT_START) / maxf(rb_band_dur - OUT_START, 0.01))
		dx = lerpf(0.0, 2600.0, pe)     # a la DERECHA, a lo largo de la banda (dx*sin da la leve subida de la inclinación)
	var base_y := RB_BAND_CY - RB_BAND_H * 0.5
	rb_text.position.x = _screen_off.x - 240.0 + dx * cos(RB_BAND_ROT)   # se mueve a lo largo de la banda (+ sigue la pantalla)
	rb_text.position.y = _screen_off.y + base_y + dx * sin(RB_BAND_ROT) + dy
	rb_text.modulate.a = clampf(t / 0.08, 0.0, 1.0)               # aparece apenas arranca a entrar

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
	cutin_root.add_child(cutin_portrait)   # capa del cut-in: DETRÁS de los peleadores/acción, sobre las líneas
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
		elif caster.fx_dark:       # ZETMA: su cut-in (frame-avatar-screen keyeado)
			ctex = "res://imagen-action/zetma/cutin/zetma-cutin.png"
		elif caster.fx_warrior:    # ROUM: su avatar (frame-avatar-screen keyeado)
			ctex = "res://imagen-action/roum/cutin/roum-cutin.png"
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

func _orb_screen_tick() -> void:
	if orb_screen == null:
		return
	# el tinte de PANTALLA se DESHABILITÓ: apagaba también a los personajes/efectos. Ahora, mientras
	# dura la esfera, solo se oscurece el STAGE (code_stage) — ver el tinte del escenario en _physics.
	orb_screen.color.a = lerpf(orb_screen.color.a, 0.0, 0.18)

func _focus_tick() -> void:
	if focus_atk == null:
		return
	var ahora := Time.get_ticks_msec()
	var dt := float(ahora - _focus_last_ms) / 1000.0
	_focus_last_ms = ahora
	focus_cur = move_toward(focus_cur, focus_target, 2.2 * dt)   # ~0.45s de 0 a full
	_focus_apply()

# color de la banda del combo: VERDE (pocos hits) -> rojo CLARO -> rojo INTENSO
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

# ---------- ORBES DE AYE-2: manager (el árbitro posee y actualiza los 3 orbes) ----------
func _orb_name(c: int) -> String:
	return ["yellow", "pink", "blue"][c]

func _orb_set_for(owner: Node2D) -> Dictionary:
	for st in orb_sets:
		if st["owner"] == owner:
			return st
	return {}

func _orb_setup_for(owner: Node2D, idx: int) -> void:
	if not _orb_set_for(owner).is_empty():
		return
	var sprites := []
	var orbs := []
	for c in 3:
		var s := Sprite2D.new()
		var p := "res://imagen-action/aye-2/orb_%s/aye2-orb_%s-1.png" % [_orb_name(c), _orb_name(c)]
		if ResourceLoader.exists(p):
			s.texture = load(p)
		s.modulate = ORB_TINT[c]
		s.z_index = 5
		s.scale = Vector2(ORB_SCALE, ORB_SCALE)
		add_child(s)
		sprites.append(s)
		orbs.append({ "state": OST_ORBIT, "pos": Vector2.ZERO, "vel": Vector2.ZERO,
			"world_pos": Vector2.ZERO, "age": 0.0, "hit_done": false,
			"orbit_ang": TAU * float(c) / 3.0, "mode": OMODE_BOOMERANG })
	orb_sets.append({ "owner": owner, "idx": idx, "sprites": sprites, "orbs": orbs,
		"plant_order": [], "recall_held_t": 0.0 })

func _orb_update(delta: float) -> void:
	for st in orb_sets:
		var owner: Node2D = st["owner"]
		if not is_instance_valid(owner):
			continue
		var center: Vector2 = owner.global_position + Vector2(0, -120)   # a la altura del torso
		for c in 3:
			var o: Dictionary = st["orbs"][c]
			var spr: Sprite2D = st["sprites"][c]
			match o["state"]:
				OST_ORBIT:
					o["orbit_ang"] += delta * 1.4
					o["pos"] = center + Vector2(cos(o["orbit_ang"]), sin(o["orbit_ang"]) * 0.5) * ORB_ORBIT_R
				OST_FLIGHT:
					# BOOMERANG: viaja hasta ORB_RANGE y VUELVE; golpea UNA vez a la ida (efecto full).
					o["pos"] += o["vel"] * delta
					o["age"] += delta
					if not o["hit_done"] and _orb_hits_target(st, o) != null:
						_orb_apply_effect(st, c, true)
						o["hit_done"] = true
					if o["vel"].x != 0.0 and signf(o["vel"].x) == signf(o["pos"].x - center.x) and absf(o["pos"].x - center.x) >= ORB_RANGE:
						o["vel"] = -o["vel"]                 # llegó al alcance -> vuelve
					elif signf(o["vel"].x) != signf(o["pos"].x - center.x) and absf(o["pos"].x - center.x) < 40.0:
						o["state"] = OST_ORBIT               # volvió -> re-orbita
				_:
					pass   # PLANT_OUT/PLANTED/RECALL: Tareas 3-4
			spr.global_position = o["pos"]
			spr.visible = true

# lanza un orbe: boomerang (tap) o plantar (←→). Solo si ese color está en órbita.
func _orb_launch(owner: Node2D, color: int, mode: int) -> void:
	var st := _orb_set_for(owner)
	if st.is_empty():
		return
	var o: Dictionary = st["orbs"][color]
	if o["state"] != OST_ORBIT:
		return   # ese color no está disponible (en vuelo o plantado)
	var dir := 1.0 if owner.facing > 0 else -1.0
	o["pos"] = owner.global_position + Vector2(0, -120)   # sale del torso de Aye
	o["mode"] = mode
	o["hit_done"] = false
	o["age"] = 0.0
	o["vel"] = Vector2(dir * ORB_SPEED, 0.0)
	o["state"] = OST_PLANT_OUT if mode == OMODE_PLANT else OST_FLIGHT

# ¿el orbe está tocando al rival del owner? (AABB contra su cuerpo)
func _orb_hits_target(st: Dictionary, o: Dictionary) -> Node2D:
	var owner: Node2D = st["owner"]
	var tgt: Node2D = dummy if owner == player else player
	if not is_instance_valid(tgt) or tgt.koed:
		return null
	var hw: float = float(tgt.body_halfw)
	var fx: float = tgt.global_position.x
	var fy: float = tgt.global_position.y   # pies del rival
	if absf(o["pos"].x - fx) <= hw + 50.0 and o["pos"].y >= fy - 420.0 and o["pos"].y <= fy + 20.0:
		return tgt
	return null

# aplica el golpe del orbe (mismo patrón que _process_attacker): reacción + resta HP del lado correcto.
# full=false -> golpe de IDA al plantar (chip, SIN efecto de color).
func _orb_apply_effect(st: Dictionary, color: int, full: bool) -> void:
	var owner: Node2D = st["owner"]
	var tgt: Node2D = dummy if owner == player else player
	if not is_instance_valid(tgt):
		return
	var dir: int = signi(int(tgt.global_position.x - owner.global_position.x))
	if dir == 0:
		dir = owner.facing
	var dmg: int
	var res: String
	if not full:
		res = tgt.receive_hit(false, false, dir, "kick_impact")   # chip de ida al plantar
		dmg = PLANT_CHIP
	elif color == ORB_PINK:
		# 🩷 congela (freeze = 9º parámetro de receive_hit)
		res = tgt.receive_hit(false, false, dir, "kick_impact", false, 1.0, false, false, true)
		dmg = ORB_DMG_BLUE
	else:
		res = tgt.receive_hit(false, false, dir, "kick_impact")
		dmg = ORB_DMG_YELLOW if color == ORB_YELLOW else ORB_DMG_BLUE
	if res != "hit" and res != "launched":
		return   # bloqueado/ignorado: sin daño
	_dmg_number(tgt, dmg)
	if full and color == ORB_BLUE:
		mana[st["idx"]] = minf(1.0, mana[st["idx"]] + MANA_PER_BLUE)   # 🔵 carga maná
	if tgt == dummy:
		dummy_hp = maxi(0, dummy_hp - dmg)
		if dummy_hp <= 0:
			if _round_real(): _end_round(true)
			else: dummy_hp = hp_max[1]
	else:
		player_hp = maxi(0, player_hp - dmg)
		if player_hp <= 0:
			if _round_real(): _end_round(false)
			else: player_hp = hp_max[0]

func _physics_process(_delta: float) -> void:
	# PRACTICE (training): salto automático del dummy + su HP clavado en 25%
	_update_dummy_practice(_delta)
	_orb_update(_delta)   # ORBES DE AYE-2: orbitan/viajan cada frame
	# ESPECIAL de Zetma: la ORB se CARGA con el tiempo durante el combate (1 vez por round)
	if state == "fight":
		for _os in 2:
			var _of: Node2D = player if _os == 0 else dummy
			if is_instance_valid(_of) and _of.fx_dark and orb_charge[_os] < 1.0:
				var _rt: float = ORB_RECHARGE_TIME if orb_used[_os] else ORB_CHARGE_TIME
				orb_charge[_os] = minf(1.0, orb_charge[_os] + _delta / _rt)
	# BREAK PRACTICE: el combo breaker se recarga solo (rompes cuantas veces quieras)
	if break_practice and state == "fight" and player.breaker_inv_t <= 0.0:
		player.breaker_ready = true
	# aviso en pantalla: el jugador puede lanzar ANIQUILACIÓN (rival en rojo +
	# combo VIVO de 3+, dentro de la ventana, no mientras el numero se apaga)
	if ultra_hint:
		# NO se muestra en training/práctica (free ni break): solo en VS CPU real
		var listo: bool = state == "fight" and not ultra_active \
				and _round_real() \
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
		# MARCAS de Fe: sin marcar en un rato, se van cayendo de a una
		if fe_marks[i] > 0 and state == "fight":
			fe_mark_decay[i] -= _delta
			if fe_mark_decay[i] <= 0.0:
				fe_marks[i] -= 1
				fe_mark_decay[i] = FE_MARK_DECAY
				victima.set_fe_marks(fe_marks[i])
		var c: Node2D = combo_ui[i]
		# al APARECER (combo nuevo): fija el lado CONTRARIO a donde mira el atacante
		# (i=0 ataca el jugador, i=1 ataca el rival) y dispara la entrada deslizada
		if c.visible and not combo_was_vis[i]:
			combo_show_ms[i] = Time.get_ticks_msec()
			var atk: Node2D = player if i == 0 else dummy
			combo_rest_x[i] = 270.0 if atk.facing > 0 else 1650.0
		combo_was_vis[i] = c.visible
		if c.visible:
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
		if Input.is_action_just_pressed("ui_cancel"):
			moves_panel.visible = false
			state = "trainer"
			trainer_panel.visible = true
			return
		# navegación/demo de combos (solo si hay lista de combos; el panel simple no la tiene)
		if moves_items.size() > 0:
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
		return
	if state == "demo":
		if Input.is_action_just_pressed("ui_cancel"):
			_open_moves()
			return
	# ===== MENÚ DE PAUSA (mientras está congelado el combate) =====
	if state == "charswap":
		charswap_fx.queue_redraw()
		var dcs := 0
		if Input.is_action_just_pressed("ui_left"):
			dcs = -1
		if Input.is_action_just_pressed("ui_right"):
			dcs = 1
		if dcs != 0:
			charswap_sel = posmod(charswap_sel + dcs, charswap_cards.size())
			for i in charswap_cards.size():
				(charswap_cards[i]["av"] as TextureRect).modulate = Color(1, 1, 1, 1.0 if i == charswap_sel else 0.55)
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
			_charswap_confirm()
		elif Input.is_action_just_pressed("ui_cancel"):
			charswap_root.visible = false
			pause_root.visible = true
			state = "pause"
		return
	if state == "pause":
		# animación en tiempo REAL (el juego está en time_scale 0): líneas manga ciclan
		# y la placa activa PULSA. Time.get_ticks_msec NO se ve afectado por time_scale.
		var pt := float(Time.get_ticks_msec()) / 1000.0
		# MODAL de stage: animar el blink del card y, si se confirmó, el fogonazo -> swap
		if pause_in_stage:
			if stage_modal != null:
				stage_modal.queue_redraw()
			if stage_modal_flash > 0.0:
				var fel := float(Time.get_ticks_msec() - stage_modal_flash_ms) / 1000.0
				stage_modal_flash = maxf(0.001, 1.0 - fel / 0.45)
				if fel >= 0.45:
					stage_modal_flash = 0.0
					_swap_stage(stage_modal_swap_code)
					return
		if pause_lines and ultra_panels.size() > 0:
			pause_lines.texture = ultra_panels[int(pt * 6.0) % ultra_panels.size()]
		if not pause_in_combos and not pause_in_practice and pause_sel < pause_plates.size():
			var pulse := 0.72 + 0.28 * absf(sin(pt * 4.0))
			(pause_plates[pause_sel] as Panel).self_modulate = Color(1, 1, 1, pulse)
		# la pausa es DEL QUE LA ABRIÓ (pause_owner): SOLO sus controles la manejan.
		# ESC "puro" = ui_cancel sin pause_p2 (el START dispara los dos a la vez).
		var own_kb: bool = pause_owner == 0
		var esc_solo: bool = Input.is_action_just_pressed("ui_cancel") \
				and not Input.is_action_just_pressed("pause_p2")
		# MODAL de CHOOSE STAGE: ← → elige, ENTER confirma, ESC vuelve a la pausa
		if pause_in_stage:
			if stage_modal_flash > 0.0:
				return                         # ya confirmando (blink en curso): ignora input
			var sback: bool = (own_kb and (esc_solo or Input.is_action_just_pressed("kick"))) \
					or (not own_kb and (Input.is_action_just_pressed("pause_p2") or Input.is_action_just_pressed("kick_p2")))
			if sback:
				_close_choose_stage()
				return
			var sd := 0
			if (own_kb and Input.is_action_just_pressed("ui_left")) or (not own_kb and Input.is_action_just_pressed("ui_left_p2")):
				sd = -1
			if (own_kb and Input.is_action_just_pressed("ui_right")) or (not own_kb and Input.is_action_just_pressed("ui_right_p2")):
				sd = 1
			if sd != 0 and Sel.STAGES.size() > 0:
				stage_modal_sel = posmod(stage_modal_sel + sd, Sel.STAGES.size())
				stage_modal.queue_redraw()
			if (own_kb and (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"))) \
					or (not own_kb and (Input.is_action_just_pressed("attack_p2") or Input.is_action_just_pressed("kick_p2"))):
				_confirm_choose_stage()
			return
		if pause_in_practice:
			var pback: bool = (own_kb and (esc_solo or Input.is_action_just_pressed("kick"))) \
					or (not own_kb and (Input.is_action_just_pressed("pause_p2") or Input.is_action_just_pressed("kick_p2")))
			if pback:
				_pause_show_practice(false)
				return
			var ppd := 0
			if (own_kb and Input.is_action_just_pressed("ui_up")) or (not own_kb and Input.is_action_just_pressed("ui_up_p2")):
				ppd = -1
			if (own_kb and Input.is_action_just_pressed("ui_down")) or (not own_kb and Input.is_action_just_pressed("ui_down_p2")):
				ppd = 1
			if ppd != 0:
				practice_sel = posmod(practice_sel + ppd, practice_items.size())
				_practice_refresh()
			if (own_kb and (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"))) \
					or (not own_kb and (Input.is_action_just_pressed("attack_p2") or Input.is_action_just_pressed("kick_p2"))):
				_practice_toggle()
			return
		if pause_in_combos:
			var back: bool = (own_kb and (esc_solo or Input.is_action_just_pressed("kick"))) \
					or (not own_kb and (Input.is_action_just_pressed("pause_p2") or Input.is_action_just_pressed("kick_p2")))
			if back:
				_pause_show_combos(false)
				return
			# ← →: alterna entre la lista de P1 y la de P2 (solo el dueño)
			var tog: bool = (own_kb and (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"))) \
					or (not own_kb and (Input.is_action_just_pressed("ui_left_p2") or Input.is_action_just_pressed("ui_right_p2")))
			if tog:
				_pause_fill_combos(cpu_char if pause_combos_char == selected_char else selected_char)
			return
		var pd := 0
		if (own_kb and Input.is_action_just_pressed("ui_up")) or (not own_kb and Input.is_action_just_pressed("ui_up_p2")):
			pd = -1
		if (own_kb and Input.is_action_just_pressed("ui_down")) or (not own_kb and Input.is_action_just_pressed("ui_down_p2")):
			pd = 1
		if pd != 0:
			pause_sel = posmod(pause_sel + pd, pause_items.size())
			_pause_refresh()
		if (own_kb and (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"))) \
				or (not own_kb and (Input.is_action_just_pressed("attack_p2") or Input.is_action_just_pressed("kick_p2"))):
			_pause_confirm()
		elif (own_kb and esc_solo) or (not own_kb and Input.is_action_just_pressed("pause_p2")):
			_close_pause()          # solo el DUEÑO cierra: ESC (P1) o START (P2)
		return
	if state == "fight" and Input.is_action_just_pressed("pause_p2"):
		_open_pause(1)              # START del mando: pausa DEL JUGADOR 2
		return
	if state == "fight" and Input.is_action_just_pressed("ui_cancel") \
			and not Input.is_action_just_pressed("pause_p2"):
		_open_pause(0)              # ESC en pelea: pausa de P1 (ya NO salta al título)
		return

	# en entrenamiento solo existe el jugador: sin empuje, sin golpes, sin barras
	if TRAINING:
		player.position.x = clampf(player.position.x, LEFT_LIMIT, RIGHT_LIMIT)
		return

	# CONTADOR del round (solo rondas reales: VS CPU / VS 2P; se congela durante ultras).
	# En 0 -> TIME OVER: gana el de más vida.
	if state == "fight" and _round_real() and not ultra_active:
		match_time = maxf(0.0, match_time - get_physics_process_delta_time())
		if timer_label != null:
			var _ts := int(ceilf(match_time))
			timer_label.text = str(_ts)
			if _ts <= 10:
				timer_label.add_theme_color_override("font_color", Color(1.0, 0.28, 0.22))
		if match_time <= 0.0:
			_time_over()
			return
	# marcadores P1/P2 sobre las cabezas (se desvanecen solos)
	_update_player_tags(get_physics_process_delta_time())

	# cajas de empuje: los cuerpos no se traspasan (salvo saltando por encima
	# o cuando uno esta derribado). NO durante un ULTRA: esos coreografían las
	# posiciones a mano y el empuje DESLIZABA al par (whirlpool contra la pared
	# se corría al centro arrastrando a la víctima).
	if not ultra_active \
			and not player.airborne and not dummy.airborne \
			and not player.koed and not dummy.koed \
			and not player.is_downed() and not dummy.is_downed():
		var sep_dx: float = dummy.position.x - player.position.x
		var overlap: float = (player.body_halfw + dummy.body_halfw) - absf(sep_dx)
		if overlap > 0.0:
			var dir := 1.0 if sep_dx >= 0.0 else -1.0
			player.position.x -= dir * overlap * 0.5
			dummy.position.x += dir * overlap * 0.5

	# combos de 5+ hits: el ESCENARIO se tine dramatico (los peleadores y la UI
	# quedan normales y resaltan como con reflector)
	if code_stage != null:
		var combo_epico: bool = combo_n[0] > 4 or combo_n[1] > 4
		var _orb_trap: bool = (is_instance_valid(player) and player.orb_trap_t > 0.0) \
				or (is_instance_valid(dummy) and dummy.orb_trap_t > 0.0)
		var tinte := Color(1, 1, 1)
		if _orb_trap:
			tinte = Color(0.28, 0.22, 0.42)   # SOLO el STAGE se oscurece mientras la esfera está activa
		elif combo_epico:
			tinte = Color(0.42, 0.38, 0.82)
		code_stage.modulate = code_stage.modulate.lerp(tinte, 0.14)

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
	# RABIA de DAM: se llena con la VIDA PERDIDA; en berserk se DRENA con el tiempo
	if rage_dim != null and not (rage_casting[0] or rage_casting[1]):
		# PANTALLA OSCURA mientras alguien esté en berserk (fundido suave, no de golpe);
		# durante el CASTEO no se toca: el parpadeo rojo lo lleva _rage_cast_show
		var _quiere: float = 0.38 if (player.rage_mode or dummy.rage_mode) else 0.0
		rage_dim.color.a = lerpf(rage_dim.color.a, _quiere, clampf(_delta * 6.0, 0.0, 1.0))
	for rs in 2:
		if not rage_side[rs]:
			continue
		var cur_hp: int = player_hp if rs == 0 else dummy_hp
		if rage_prev_hp[rs] >= 0 and cur_hp < rage_prev_hp[rs] and not rage_on[rs]:
			rage[rs] = clampf(rage[rs] + float(rage_prev_hp[rs] - cur_hp) / (float(hp_max[rs]) * RAGE_FULL_LOST), 0.0, 1.0)
		rage_prev_hp[rs] = cur_hp
		if rage_on[rs] and not rage_casting[rs]:
			rage[rs] = maxf(0.0, rage[rs] - RAGE_DRAIN * _delta)
			if rage[rs] <= 0.0:
				_rage_end(rs)
		elif rs == 1 and dummy_ai_mode and rage[rs] >= 0.999 and state == "fight":
			try_rage(dummy)   # la CPU DAM revienta su rabia apenas se llena
	# VOID de ROUM: se llena PELEANDO (daño HECHO al rival) + chorrito pasivo mínimo
	for vs in 2:
		if not void_side[vs]:
			continue
		var foe_hp: int = dummy_hp if vs == 0 else player_hp
		var foe_max: int = hp_max[1] if vs == 0 else hp_max[0]
		if void_prev_foe_hp[vs] >= 0 and foe_hp < void_prev_foe_hp[vs] and foe_max > 0:
			void_charge[vs] = clampf(void_charge[vs] + float(void_prev_foe_hp[vs] - foe_hp) / (float(foe_max) * VOID_FULL_DEALT), 0.0, 1.0)
		void_prev_foe_hp[vs] = foe_hp
		if void_charge[vs] < 1.0 and state == "fight":
			void_charge[vs] = clampf(void_charge[vs] + VOID_REGEN * _delta, 0.0, 1.0)
	# MANA: arco morado de cada mago (parpadea rojo si falto mana) — y el anillo ROJO de
	# RABIA de DAM (mismo slot, alimentado por rage[] en vez de mana[])
	for mside in 2:
		if not (mana_is_mage[mside] or rage_side[mside] or orb_side[mside] or void_side[mside]) or mana_ring_fill[mside] == null:
			continue
		if mana_flash_t[mside] > 0.0:
			mana_flash_t[mside] = maxf(0.0, mana_flash_t[mside] - _delta)
		var mfr: float = clampf(void_charge[mside] if void_side[mside] else (orb_charge[mside] if orb_side[mside] else (rage[mside] if rage_side[mside] else mana[mside])), 0.0, 1.0)
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
		# color del anillo por personaje: MORADO (maná de maga) / AZUL (instinto de Fe) /
		# ROJO FUEGO (rabia de DAM)
		var _mfb: Node2D = player if mside == 0 else dummy
		var _azul: bool = is_instance_valid(_mfb) and _mfb.fx_blue
		var _dark: bool = is_instance_valid(_mfb) and _mfb.fx_dark
		var _void: bool = void_side[mside]   # ROUM: aro CARMESÍ (estética agujero negro)
		if rage_side[mside] and rage_on[mside]:
			# BERSERK drenando: rojo-naranja LATIENDO
			var rp := 0.6 + 0.4 * absf(sin(float(Time.get_ticks_msec()) / 1000.0 * 9.0))
			rfl.default_color = Color(1.4 + 0.8 * rp, 0.35 + 0.25 * rp, 0.10)
			rfl.width = MANA_RING_W + 3.0 * rp
		elif mana_flash_t[mside] > 0.0:
			rfl.default_color = Color(1.9, 0.22, 0.32)          # falta recurso: rojo
			rfl.width = MANA_RING_W
		elif fk > 0.0:
			rfl.default_color = (Color(2.05, 0.28, 0.30) if _void else (Color(2.1, 0.55, 0.20) if rage_side[mside] else (Color(0.30, 1.70, 3.05) if _azul else (Color(0.78, 0.12, 2.05) if _dark else Color(1.60, 0.60, 2.40))))).lerp(Color(2.6, 2.5, 3.0), fk)   # DESTELLO al llenarse
			rfl.width = MANA_RING_W + 7.0 * fk
		elif full_now:
			rfl.default_color = Color(2.05, 0.28, 0.30) if _void else (Color(2.1, 0.55, 0.20) if rage_side[mside] else (Color(0.30, 1.70, 3.05) if _azul else (Color(0.78, 0.12, 2.05) if _dark else Color(1.60, 0.60, 2.40))))   # lleno: NEÓN carmesí
			rfl.width = MANA_RING_W
		else:
			rfl.default_color = Color(1.15, 0.10, 0.12) if _void else (Color(1.20, 0.28, 0.18) if rage_side[mside] else (Color(0.20, 1.10, 2.40) if _azul else (Color(0.50, 0.08, 1.55) if _dark else Color(1.05, 0.38, 1.90))))   # cargando: NEÓN carmesí
			rfl.width = MANA_RING_W
		# HALO neon detras del arco (mismo recorrido, mas ancho y translucido -> bloom)
		if mana_ring_glow[mside] != null:
			var grw: Line2D = mana_ring_glow[mside]
			grw.points = rfl.points
			grw.width = rfl.width + 6.0
			grw.default_color = Color(rfl.default_color.r, rfl.default_color.g, rfl.default_color.b, 0.5)
	# DOTS de rounds: encendidos = rondas ganadas
	for side in 2:
		var w: int = wins_p1 if side == 0 else wins_p2
		for i in WINS_NEEDED:
			win_dots[side][i].color = Color(1.9, 1.55, 0.4) if i < w else Color(0.28, 0.3, 0.36)

# show del BREAK en tiempo REAL: corre aunque el juego este congelado o lento
# construye el ESCENARIO según STAGE (código). Reutilizable: en _ready y al CAMBIAR de stage.
const SCROLL_STAGES := [1, 4, 5]   # stages con SCROLL + parallax (cámara que sigue)
func _setup_stage() -> void:
	if STAGE < 1:
		return
	for n in CITY_NODES:
		var nd := get_node_or_null(n)
		if nd != null:
			nd.visible = false
	var esc: Node2D
	if STAGE == 1:
		esc = preload("res://city_stage.gd").new()      # ciudad en ruinas
	elif STAGE == 2:
		esc = preload("res://night_stage.gd").new()
	elif STAGE == 4:
		esc = preload("res://santuario_stage.gd").new()
	elif STAGE == 5:
		esc = preload("res://inferno_stage.gd").new()   # INFIERNO
	else:
		esc = preload("res://templo_stage.gd").new()
	esc.name = "CodeStage"
	add_child(esc)
	code_stage = esc
	if STAGE in SCROLL_STAGES:
		_setup_scroll_camera()

# CAMBIA de stage EN VIVO (sin recargar la escena -> instantáneo, sin pantalla en blanco):
# destruye el escenario/cámara actuales, arma el nuevo y reinicia el combate.
func _swap_stage(new_code: int) -> void:
	Engine.time_scale = 1.0
	# cierra la pausa/modal antes de recomponer el stage
	pause_in_stage = false
	pause_in_combos = false
	if stage_modal != null:
		stage_modal.visible = false
	if pause_root != null:
		pause_root.visible = false
	if code_stage != null:
		code_stage.queue_free()
		code_stage = null
	if game_cam != null:
		game_cam.queue_free()
		game_cam = null
	scroll_stage = false
	LEFT_LIMIT = 115.0
	RIGHT_LIMIT = 1805.0
	STAGE = new_code
	Sel.stage = new_code
	_setup_stage()
	wins_p1 = 0
	wins_p2 = 0
	round_num = 1
	_start_round()

# crea la cámara que sigue a los peleadores y ENSANCHA el mundo (stage con scroll).
func _setup_scroll_camera() -> void:
	RIGHT_LIMIT = SCROLL_WORLD_W - 115.0    # los peleadores pueden caminar por el mundo ancho
	game_cam = Camera2D.new()
	game_cam.position = Vector2(960, 540)
	game_cam.limit_left = 0
	game_cam.limit_right = int(SCROLL_WORLD_W)
	game_cam.limit_top = 0
	game_cam.limit_bottom = 1080
	game_cam.position_smoothing_enabled = true   # seguimiento suave (no brusco)
	game_cam.position_smoothing_speed = 6.0
	add_child(game_cam)
	game_cam.make_current()
	scroll_stage = true

func _process(_dt: float) -> void:
	var ahora := Time.get_ticks_msec()
	# CÁMARA con SCROLL (santuario): sigue el punto medio de los peleadores, acotada al mundo.
	if scroll_stage and game_cam != null and is_instance_valid(player) and is_instance_valid(dummy):
		var mid := (player.position.x + dummy.position.x) * 0.5
		game_cam.position.x = clampf(mid, 960.0, SCROLL_WORLD_W - 960.0)
		game_cam.position.y = 540.0
		# los overlays de PANTALLA COMPLETA (velo rojo, líneas del orb, K.O., cut-in...) están en
		# el MUNDO fijos en (0,0); al correrse la cámara se descentraban. Los pego a la esquina
		# sup-izq de la vista para que SIEMPRE cubran la pantalla.
		_screen_off = game_cam.get_screen_center_position() - Vector2(960.0, 540.0)
		# SOLO los overlays del MUNDO (add_child) siguen a la cámara. Los del $UI (CanvasLayer:
		# flash_rect, orb_screen, ultra_panel) YA son pantalla-fija -> NO se tocan (moverlos los
		# descentraba: el flash del rayo de Fe cubría solo media pantalla).
		for ov in [ko_red, rage_dim, ko_lines, anno_root, cutin_root]:
			if ov != null:
				ov.position = _screen_off
	# TEMBLOR de pantalla (reloj REAL). Con cámara, sacude el OFFSET de la cámara (si sacudo
	# el root, la cámara —hija— se mueve igual y el temblor se cancela); sin cámara, el root.
	var srem := shake_end_ms - ahora
	if srem > 0:
		var k := float(srem) / float(shake_dur_ms)
		var jolt := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_amp * k
		if game_cam != null:
			game_cam.offset = jolt
		else:
			position = jolt
	else:
		if game_cam != null and game_cam.offset != Vector2.ZERO:
			game_cam.offset = Vector2.ZERO
		if position != Vector2.ZERO:
			position = Vector2.ZERO
	_focus_tick()   # suaviza el borde rojo hacia su intensidad objetivo
	_orb_screen_tick()   # tinte morado oscuro mientras dura la esfera de Zetma
	_cutin_tick()   # anima el cut-in del INFIERNO (entrada/salida, reloj REAL)
	_announce_tick()  # anima el anuncio grande (COUNTER/K.O.)
	_round_banner_tick()  # anima el banner COUNTER (imagen, golpe, reloj REAL)
	_round_band_tick()    # anima la BANDA morada READY / FIGHT / CRITICAL / DANGER / ultra
	_danger_ultra_banner_tick()   # DANGER (1×/round) + nombre del ULTRA al terminar
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
		caster.voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
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
		# DOWN: pega si la diagonal PASA por el CUERPO del rival PARADO (aire-contra-suelo).
		# Caja de cuerpo COMPLETO (pecho±330 en Y, ±250 en X): la ventanita vieja (165/200,
		# solo el pecho) fallaba con la postura ANCHA de DAM — las medialunas le reventaban
		# en la pierna delantera (a ~250 del centro) sin registrar el golpe.
		if down and not target.koed and (target.floor_y - target.position.y) < 90.0:
			var tch: float = target.position.y + 500.0 - 485.0 * target.base_scale.y
			if absf(proj.position.x - target.position.x) < 250.0 and absf(proj.position.y - tch) < 330.0:
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
			_dmg_number(target, dmg_real)
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
		caster.voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
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
		caster.voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
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
	_dmg_number(opp, d)
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

# voz robótica "come to me" de Zetma al enganchar/halar
func _zetma_grab_voice(caster: Node2D) -> void:
	var v := "res://imagen-action/zetma/sound-effect/come_to_me.wav"
	if ResourceLoader.exists(v) and caster.get("voz_player") != null:
		caster.voz_player.stream = load(v)
		caster.voz_player.pitch_scale = 1.0
		caster.voz_player.volume_db = 6.0   # "come to me" bien audible (venía muy bajo)
		caster.voz_player.play()

# ---- ZETMA: GROUND GRAB (↓→E) — gancho mecánico tipo Scorpion ("get over here") ----
# Lanza el garfio; si el rival está AL ALCANCE y al frente, lo ENGANCHA y lo HALA hacia Zetma,
# quedando aturdido a su lado (ventana de combo). Si falla, es solo el whiff del brazo.
# VALIDADOR SÍNCRONO (devuelve bool fiable); lanza el coroutine _run_ground_grab aparte.
func _zetma_ground_grab(caster: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	if not caster.sprite.sprite_frames.has_animation("ground_grab"):
		return false
	if caster.airborne or caster.koed:
		return false
	_run_ground_grab(caster)   # fire-and-forget (corre el efecto async)
	return true

func _run_ground_grab(caster: Node2D) -> void:
	var opp: Node2D = dummy if caster == player else player
	var was_input: bool = caster.input_enabled
	var was_ai: bool = caster.ai_enabled
	caster.input_enabled = false
	caster.ai_enabled = false
	caster.crouching = false
	caster.vel_x = 0.0
	if is_instance_valid(opp):
		caster.set_facing(1 if opp.position.x >= caster.position.x else -1)
	caster.sprite.play("ground_grab")
	_zetma_grab_voice(caster)   # "come to me" robótico al estirar el brazo (no tarde)
	# 1) el garfio se EXTIENDE del todo (~0.47s = frame 49 a 105fps)
	await get_tree().create_timer(0.47).timeout
	if state != "fight" or String(caster.sprite.animation) != "ground_grab" or caster.koed:
		caster.input_enabled = was_input
		caster.ai_enabled = was_ai
		return
	# 2) ¿rival AL ALCANCE y al frente? (gancho largo, inbloqueable como el arpón de Scorpion)
	var GRAB_RANGE := 680.0
	var _ggdx: float = (opp.position.x - caster.position.x) if is_instance_valid(opp) else 99999.0
	# cuerpos ENCIMADOS cuentan como "al frente"; AGARRA en el aire (rival saltando o juggled) a
	# cualquier altura si está en rango X — NO al tirado en el piso. Sin chequeo de Y = anti-aéreo.
	var _ggfront: bool = int(signf(_ggdx)) == caster.facing or absf(_ggdx) < 175.0
	var connected: bool = is_instance_valid(opp) and not opp.koed \
		and (opp.airborne or opp.hit_flying or not opp.is_downed()) \
		and opp.breaker_inv_t <= 0.0 and _ggfront \
		and absf(_ggdx) <= GRAB_RANGE
	if not connected:
		await get_tree().create_timer(0.55).timeout   # whiff: recoge el brazo
		caster.input_enabled = was_input
		caster.ai_enabled = was_ai
		return
	# 3) ¡ENGANCHÓ! chispa + lo agarra (se tambalea en el sitio mientras el garfio sostiene)
	_shake(12.0, 0.12)
	var opp_was_input: bool = opp.input_enabled
	var opp_was_ai: bool = opp.ai_enabled
	opp.input_enabled = false   # bloqueado mientras el garfio lo hala
	opp.ai_enabled = false
	opp._burst(1.1, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
	opp._play_sfx_key("take_hit")
	opp.crouching = false
	opp.airborne = false
	opp.hit_flying = false
	opp.vel_y = 0.0
	opp.set_facing(-caster.facing)
	if opp.sprite.sprite_frames.has_animation("get_pull"):
		opp.sprite.play("get_pull")     # víctima: reacción de ser HALADO (horizontal, desde el suelo)
	elif opp.sprite.sprite_frames.has_animation("pummeled"):
		opp.sprite.play("pummeled")
	elif opp.sprite.sprite_frames.has_animation("take_hit"):
		opp.sprite.play("take_hit")
	caster.sprite.stop()   # ENGANCHÓ: manejo el frame del brazo con el jalón (recoge sin desfase)
	var fr0: int = int(0.60 * float(caster.sprite.sprite_frames.get_frame_count("ground_grab")))   # inicio del retract
	var frN: int = caster.sprite.sprite_frames.get_frame_count("ground_grab") - 1
	await get_tree().create_timer(0.08).timeout
	var sx0: float = opp.position.x if is_instance_valid(opp) else 0.0
	var target_x: float = clampf(caster.position.x + float(caster.facing) * 205.0, LEFT_LIMIT, RIGHT_LIMIT)
	var st := 0.0
	var pdur := 0.40
	while st < pdur and state == "fight" and is_instance_valid(opp) and not opp.koed \
			and String(caster.sprite.animation) == "ground_grab":
		var k := st / pdur
		opp.position.x = lerpf(sx0, target_x, _ease_out_cubic(k))
		opp.position.y = opp.floor_y
		caster.sprite.frame = int(lerpf(float(fr0), float(frN), k))
		_shake(4.0, 0.04)
		await get_tree().process_frame
		st += get_process_delta_time()
	if is_instance_valid(caster): caster.sprite.frame = frN
	# 5) DAÑO + queda aturdido a su lado (ventana de combo)
	if is_instance_valid(opp) and not opp.koed:
		var d := 45
		_dmg_number(opp, d)
		opp._burst(1.0, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
		if opp.sprite.sprite_frames.has_animation("take_hit"):
			opp.sprite.play("take_hit")
		if caster == player:
			dummy_hp = maxi(0, dummy_hp - d)
			if dummy_hp <= 0 and _round_real(): _end_round(true)
		else:
			player_hp = maxi(0, player_hp - d)
			if player_hp <= 0 and _round_real(): _end_round(false)
	if is_instance_valid(caster) and not caster.koed and String(caster.sprite.animation) == "ground_grab":
		caster.sprite.play("pose")   # el clip no retrae del todo el brazo -> vuelve a la guardia limpia
	caster.input_enabled = was_input
	caster.ai_enabled = was_ai
	if is_instance_valid(opp):
		opp.input_enabled = opp_was_input
		opp.ai_enabled = opp_was_ai

# ---- ROUM: GROUND GRAB (↓→Q) — estira las VENDAS y HALA al rival. Validador SÍNCRONO: SOLO sale si el
# rival está a ≤1.5 CUERPOS y al frente (si está lejos, NO sale -> las vendas no se ven CORTADAS). ----
func _roum_ground_grab(caster: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	if not caster.sprite.sprite_frames.has_animation("ground_grab"):
		return false
	if caster.airborne or caster.koed:
		return false
	var opp: Node2D = dummy if caster == player else player
	if not is_instance_valid(opp) or opp.koed:
		return false
	var dx: float = opp.position.x - caster.position.x
	if int(signf(dx)) != caster.facing and absf(dx) >= 175.0:
		return false   # a la espalda: no sale
	if absf(dx) > GEYSER_BODY * 2.75:
		return false   # más lejos de ~2.75 cuerpos (~962px): NO sale el agarre (pedido: alcance 2.5-3 cuerpos)
	# GRATIS (sin VOID): el VOID es SOLO para los PORTALES (warp_grab). Este es el agarre de vendas al ras.
	_run_roum_grab(caster, opp)
	return true

func _run_roum_grab(caster: Node2D, opp: Node2D) -> void:
	var was_input: bool = caster.input_enabled
	var was_ai: bool = caster.ai_enabled
	caster.input_enabled = false
	caster.ai_enabled = false
	caster.crouching = false
	caster.vel_x = 0.0
	caster.set_facing(1 if opp.position.x >= caster.position.x else -1)
	caster.sprite.play("ground_grab")
	_shake(8.0, 0.1)
	# 1) las VENDAS se estiran (~f31 = 0.33s a 100fps). El rango ya se validó -> engancha sí o sí.
	await get_tree().create_timer(0.33).timeout
	if state != "fight" or caster.koed or String(caster.sprite.animation) != "ground_grab" or not is_instance_valid(opp) or opp.koed:
		if is_instance_valid(caster):
			caster.input_enabled = was_input
			caster.ai_enabled = was_ai
			if String(caster.sprite.animation) == "ground_grab":
				caster.sprite.play("pose")
		return
	# 2) ENGANCHÓ: agarra + HALA hacia ROUM mientras las vendas se RETRAEN (frame f115->f145)
	_shake(12.0, 0.12)
	var opp_was_input: bool = opp.input_enabled
	var opp_was_ai: bool = opp.ai_enabled
	opp.input_enabled = false
	opp.ai_enabled = false
	opp.crouching = false
	opp.airborne = false
	opp.hit_flying = false
	opp.vel_y = 0.0
	opp.vel_x = 0.0
	opp.set_facing(-caster.facing)
	opp._burst(1.1, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
	opp._play_sfx_key("take_hit")
	if opp.sprite.sprite_frames.has_animation("get_pull"):
		opp.sprite.play("get_pull")
	elif opp.sprite.sprite_frames.has_animation("take_hit"):
		opp.sprite.play("take_hit")
	caster.sprite.stop()   # controlo el frame: las vendas se METEN adentro (retract f115->f145) al halar
	var frames_gg: int = caster.sprite.sprite_frames.get_frame_count("ground_grab")
	var fr0: int = int(0.79 * float(frames_gg))   # ~f115: inicio del retract
	var frN: int = frames_gg - 1
	var sx0: float = opp.position.x
	var target_x: float = clampf(caster.position.x + float(caster.facing) * 260.0, LEFT_LIMIT, RIGHT_LIMIT)
	var st := 0.0
	var pdur := 0.34
	while st < pdur and state == "fight" and is_instance_valid(opp) and not opp.koed \
			and is_instance_valid(caster) and String(caster.sprite.animation) == "ground_grab":
		var k := st / pdur
		opp.position.x = lerpf(sx0, target_x, _ease_out_cubic(k))
		opp.position.y = opp.floor_y
		caster.sprite.frame = int(lerpf(float(fr0), float(frN), k))
		_shake(4.0, 0.04)
		await get_tree().process_frame
		st += get_process_delta_time()
	if is_instance_valid(caster):
		caster.sprite.frame = frN
	# 3) DAÑO + queda a su lado (ventana de combo)
	if is_instance_valid(opp) and not opp.koed:
		var d := 70
		_dmg_number(opp, d)
		opp._burst(1.0, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
		if opp.sprite.sprite_frames.has_animation("take_hit"):
			opp.sprite.play("take_hit")
		if caster == player:
			dummy_hp = maxi(0, dummy_hp - d)
			if dummy_hp <= 0 and _round_real(): _end_round(true)
		else:
			player_hp = maxi(0, player_hp - d)
			if player_hp <= 0 and _round_real(): _end_round(false)
	if is_instance_valid(caster) and not caster.koed and String(caster.sprite.animation) == "ground_grab":
		caster.sprite.play("pose")   # vuelve a guardia limpia (vendas adentro)
	if is_instance_valid(caster):
		caster.input_enabled = was_input
		caster.ai_enabled = was_ai
	if is_instance_valid(opp):
		opp.input_enabled = opp_was_input
		opp.ai_enabled = opp_was_ai

# ---- ZETMA: AIR GRAB (↓→Q en el aire) — gancho AÉREO ("get over here" aéreo) ----
# Solo EN EL AIRE: lanza la garra abajo-adelante; si engancha, HALA al rival hacia Zetma
# (sube hasta su altura) y lo suelta lanzado. VALIDADOR síncrono + coroutine aparte.
func _zetma_air_grab(caster: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	if not caster.sprite.sprite_frames.has_animation("air_grab"):
		return false
	if not caster.airborne or caster.koed:
		return false
	_run_air_grab(caster)
	return true

func _run_air_grab(caster: Node2D) -> void:
	var opp: Node2D = dummy if caster == player else player
	var was_input: bool = caster.input_enabled
	var was_ai: bool = caster.ai_enabled
	caster.input_enabled = false
	caster.ai_enabled = false
	if is_instance_valid(opp):
		caster.set_facing(1 if opp.position.x >= caster.position.x else -1)
	caster.sprite.play("air_grab")
	_zetma_grab_voice(caster)   # "come to me" robótico al lanzar la garra
	# 1+2) la garra se EXTIENDE y BUSCA enganchar durante una VENTANA (no un instante). Así ATRAPA
	# al rival que CAE tras un golpe: antes el chequeo era un único frame y ya lo había pasado / ya
	# había tocado el piso, y además rechazaba a los JUGGLED (is_downed incluye hit_flying).
	var GRAB_RANGE := 560.0
	var _connected := false
	var _seek := 0.0
	while _seek < 0.95 and state == "fight" and not caster.koed \
			and String(caster.sprite.animation) == "air_grab":
		_seek += get_process_delta_time()
		if _seek >= 0.28 and is_instance_valid(opp) and not opp.koed:
			var _gdx: float = opp.position.x - caster.position.x
			# cuerpos ENCIMADOS cuentan como "al frente" aunque el signo no calce
			var _gfront: bool = int(signf(_gdx)) == caster.facing or absf(_gdx) < 175.0
			# AGARRABLE: de pie, en el AIRE o JUGGLED (hit_flying) — NO tirado en el PISO
			var _grabbable: bool = opp.airborne or opp.hit_flying or not opp.is_downed()
			var _gdy: float = opp.position.y - caster.position.y   # + = rival ABAJO
			# el brazo TELESCOPEA lejos abajo-adelante: mucho alcance hacia ABAJO (engancha la caída)
			if _grabbable and _gfront and absf(_gdx) <= GRAB_RANGE and _gdy >= -280.0 and _gdy <= 900.0:
				_connected = true
				break
		await get_tree().process_frame
	if not _connected:
		if is_instance_valid(caster) and String(caster.sprite.animation) == "air_grab":
			caster.sprite.play("jump")   # WHIFF: apaga el hover -> cae
			caster.sprite.frame = caster.sprite.sprite_frames.get_frame_count("jump") - 2   # pose de CAÍDA (no el agachado del despegue)
		caster.input_enabled = was_input
		caster.ai_enabled = was_ai
		return
	# 3) ¡ENGANCHÓ! chispa + lo agarra y lo bloquea
	_shake(12.0, 0.12)
	opp._burst(1.1, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
	opp._play_sfx_key("take_hit")
	var opp_was_input: bool = opp.input_enabled
	var opp_was_ai: bool = opp.ai_enabled
	opp.input_enabled = false
	opp.ai_enabled = false
	opp.crouching = false
	opp.hit_flying = false
	opp.set_facing(-caster.facing)
	if opp.sprite.sprite_frames.has_animation("get_pull_air"):
		opp.sprite.play("get_pull_air")   # víctima: yankeada hacia ARRIBA (jalón aéreo)
	elif opp.sprite.sprite_frames.has_animation("take_hit"):
		opp.sprite.play("take_hit")
	caster.sprite.stop()   # ENGANCHÓ: brazo recogiéndose al ritmo que el rival sube (sin desfase)
	var afr0: int = int(0.72 * float(caster.sprite.sprite_frames.get_frame_count("air_grab")))   # inicio del retract
	var afrN: int = caster.sprite.sprite_frames.get_frame_count("air_grab") - 1
	# 4) HALA: arrastra al rival hasta la ALTURA de Zetma + brazo recogiéndose SINCRONIZADO
	var st := 0.0
	var pdur := 0.40
	while st < pdur and state == "fight" and is_instance_valid(opp) and not opp.koed \
			and String(caster.sprite.animation) == "air_grab":
		var k := st / pdur
		var tx: float = clampf(caster.position.x + float(caster.facing) * 175.0, LEFT_LIMIT, RIGHT_LIMIT)
		var ty: float = caster.position.y
		opp.airborne = true
		opp.vel_y = 0.0
		opp.position.x = lerpf(opp.position.x, tx, 0.30)
		opp.position.y = lerpf(opp.position.y, ty, 0.30)
		caster.sprite.frame = int(lerpf(float(afr0), float(afrN), k))
		_shake(4.0, 0.04)
		await get_tree().process_frame
		st += get_process_delta_time()
	if is_instance_valid(caster): caster.sprite.frame = afrN
	# 5) DAÑO (cuenta como golpe de COMBO -> encadena) + lo SUELTA lanzado y CERCA (juggle-able)
	if is_instance_valid(opp) and not opp.koed:
		var _hidx := 0 if caster == player else 1
		var d: int = _combo_hit(_hidx, 45, "air_grab", true)   # pasa por el combo: suma hit y permite seguir
		_dmg_number(opp, d)
		opp._burst(1.0, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
		opp.airborne = true
		opp.hit_flying = true
		opp.vel_x = float(caster.facing) * 160.0   # menos empuje -> queda cerca para encadenar
		opp.vel_y = -120.0
		if opp.sprite.sprite_frames.has_animation("hit_fly"):
			opp.sprite.play("hit_fly")
		if caster == player:
			dummy_hp = maxi(0, dummy_hp - d)
			if dummy_hp <= 0 and _round_real(): _end_round(true)
		else:
			player_hp = maxi(0, player_hp - d)
			if player_hp <= 0 and _round_real(): _end_round(false)
	if is_instance_valid(caster) and not caster.koed and String(caster.sprite.animation) == "air_grab":
		caster.sprite.play("jump")   # CONNECT: cae con la pose de salto (no queda flotando)
		caster.sprite.frame = caster.sprite.sprite_frames.get_frame_count("jump") - 2   # pose de CAÍDA, no el despegue
	caster.input_enabled = was_input
	caster.ai_enabled = was_ai
	if is_instance_valid(opp):
		opp.input_enabled = opp_was_input
		opp.ai_enabled = opp_was_ai

# ============ ESPECIAL de ZETMA: ORB de cámara lenta (1 vez por round) ============
func _zetma_orb_ready(caster: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if caster == player else 1
	return orb_charge[idx] >= 1.0

func _zetma_orb_special(caster: Node2D) -> bool:
	if not _zetma_orb_ready(caster):
		return false
	if caster.airborne or caster.koed:
		return false   # el VOID ORB solo se lanza EN EL SUELO (nunca en el aire)
	if not caster.sprite.sprite_frames.has_animation("orb_cast"):
		return false
	var idx := 0 if caster == player else 1
	orb_used[idx] = true
	orb_charge[idx] = 0.0
	_run_orb_cast(caster)
	return true

func _run_orb_cast(caster: Node2D) -> void:
	var was_input: bool = caster.input_enabled
	var was_ai: bool = caster.ai_enabled
	caster.input_enabled = false
	caster.ai_enabled = false
	caster.crouching = false
	caster.vel_x = 0.0
	var opp: Node2D = dummy if caster == player else player
	if is_instance_valid(opp):
		caster.set_facing(1 if opp.position.x >= caster.position.x else -1)
	caster.sprite.play("orb_cast")
	# VOZ robótica del súper ("VOID ORB"), estilo char-select, al LANZARLO
	if voz_player != null and ResourceLoader.exists("res://imagen-action/zetma/sound-effect/VOID_ORB.mp3"):
		voz_player.stream = load("res://imagen-action/zetma/sound-effect/VOID_ORB.mp3")
		voz_player.pitch_scale = 1.0
		voz_player.play()
	var _px: float = caster.position.x   # x de origen (VUELVE aquí tras el retroceso — no es deriva)
	_play_cutin(-1 if caster.position.x >= 960.0 else 1, caster)   # cut-in de HUD (como el especial de DAM)
	await get_tree().create_timer(0.34).timeout   # la orb se carga en la punta
	if is_instance_valid(caster): caster.position.x = _px
	if state == "fight" and not caster.koed:
		_spawn_zetma_orb(caster)
	# RETROCESO VISIBLE con POLVO: el culatazo lo EMPUJA hacia atrás y levanta polvo en los pies
	if is_instance_valid(caster) and caster.has_method("_spawn_dash_smoke"):
		caster._spawn_dash_smoke(1.05, 45.0, true, 0.20)   # puff fuerte del empuje: ESPEJADO y pegado a los pies
	var _kb := 170.0            # pico del culatazo
	var _rest := 130.0         # SE QUEDA retrocedido acá (NO vuelve al frente)
	var _rt := 0.0
	var _dcd := 0.0
	while _rt < 0.5 and is_instance_valid(caster) and not caster.koed:
		_rt += get_process_delta_time()
		var _off: float
		if _rt < 0.10:
			_off = _kb * (_rt / 0.10)                                            # golpe: sale disparado atrás
		else:
			_off = lerpf(_kb, _rest, clampf((_rt - 0.10) / 0.30, 0.0, 1.0))      # asienta y SE QUEDA retrocedido
		caster.position.x = _px - float(caster.facing) * _off
		_dcd -= get_process_delta_time()
		if _dcd <= 0.0 and _rt < 0.26 and caster.has_method("_spawn_dash_smoke"):
			_dcd = 0.07
			caster._spawn_dash_smoke(0.7, 32.0, true, 0.20)   # polvo mientras se desliza atrás (espejado, a los pies)
		await get_tree().process_frame
	if is_instance_valid(caster): caster.position.x = _px - float(caster.facing) * _rest   # queda retrocedido, no rebota al frente
	caster.input_enabled = was_input
	caster.ai_enabled = was_ai
	if is_instance_valid(caster) and not caster.koed and String(caster.sprite.animation) == "orb_cast":
		caster.sprite.play("pose")

func _make_void_orb(arena: Node) -> Sprite2D:
	if void_orb_shader == null:
		void_orb_shader = load("res://void_orb.gdshader")
	if void_orb_tex == null:
		var img := Image.create(768, 768, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 1, 1, 1))
		void_orb_tex = ImageTexture.create_from_image(img)
	var sp := Sprite2D.new()
	sp.texture = void_orb_tex
	sp.centered = true
	var mat := ShaderMaterial.new()
	mat.shader = void_orb_shader
	mat.set_shader_parameter("grow", 1.0)
	mat.set_shader_parameter("seed", 0.37)
	sp.material = mat
	# motes de energía ORBITANDO la bola (efecto girando alrededor)
	var motes := CPUParticles2D.new()
	motes.texture = _orb_mote_tex()            # REDONDOS (antes: cuadraditos)
	motes.amount = 16
	motes.lifetime = 1.1
	motes.local_coords = true
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	motes.emission_sphere_radius = 275.0
	motes.gravity = Vector2.ZERO
	motes.orbit_velocity_min = 0.5
	motes.orbit_velocity_max = 0.95
	motes.initial_velocity_min = 0.0
	motes.initial_velocity_max = 0.0
	motes.scale_amount_min = 0.30              # chicos
	motes.scale_amount_max = 0.62
	motes.color = Color(1.5, 0.75, 2.4)        # un poco más OSCUROS
	sp.add_child(motes)
	motes.emitting = true
	arena.add_child(sp)
	return sp

# ---- ROUM warp_grab: PORTAL/agujero negro elíptico (void_portal.gdshader) ----
func _make_void_portal(arena: Node) -> Sprite2D:
	if void_portal_shader == null:
		void_portal_shader = load("res://void_portal.gdshader")
	if void_orb_tex == null:
		var img := Image.create(768, 768, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 1, 1, 1))
		void_orb_tex = ImageTexture.create_from_image(img)
	var sp := Sprite2D.new()
	sp.texture = void_orb_tex
	sp.centered = true
	sp.z_index = 22
	var mat := ShaderMaterial.new()
	mat.shader = void_portal_shader
	mat.set_shader_parameter("grow", 0.0)      # arranca CERRADO
	mat.set_shader_parameter("spin_speed", 1.5)
	mat.set_shader_parameter("seed", 0.61)
	sp.material = mat
	arena.add_child(sp)
	return sp

# partículas CARMESÍ/NEGRAS succionadas HACIA el portal (efecto de que traga al rival)
func _portal_suck_fx(pos: Vector2) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = _orb_mote_tex()
	p.z_index = 23
	p.position = pos
	p.amount = 120                      # MUCHAS más
	p.lifetime = 0.5
	p.local_coords = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	p.emission_sphere_radius = 280.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 0.0
	p.initial_velocity_max = 0.0
	p.radial_accel_min = -1900.0        # HACIA el centro = succión (más fuerte)
	p.radial_accel_max = -1100.0
	p.tangential_accel_min = 350.0      # con giro (espiral al tragarse)
	p.tangential_accel_max = 750.0
	p.scale_amount_min = 0.08           # BIEN chicas
	p.scale_amount_max = 0.22
	var ramp := Gradient.new()
	ramp.set_color(0, Color(3.0, 0.15, 0.15, 1.0))    # ROJO brillante (HDR -> brilla/bloom)
	ramp.add_point(0.5, Color(0.5, 0.02, 0.02, 0.95)) # rojo oscuro
	ramp.set_color(1, Color(0.0, 0.0, 0.0, 0.0))      # NEGRO (se apaga)
	p.color_ramp = ramp
	p.emitting = true
	add_child(p)
	return p

# POLVO de arrastre: RÁFAGA one-shot (se ve TODO de golpe, no depende de cuánto dure el grab).
# dir = sentido de la barrida del polvo (rival: contrario al hala; Roum: hacia donde hala).
func _pull_dust(dir: int) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = _orb_mote_tex()
	p.z_index = 6
	p.amount = 46
	p.lifetime = 0.55
	p.one_shot = true              # RÁFAGA: suelta las 46 de una y no repite
	p.explosiveness = 0.9          # casi todas en el instante 0 -> puff bien visible
	p.local_coords = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(28.0, 82.0)
	p.direction = Vector2(float(dir), -0.35)          # barrida lateral (líneas blancas del boceto)
	p.spread = 26.0
	p.gravity = Vector2(0, 240)
	p.initial_velocity_min = 300.0
	p.initial_velocity_max = 640.0
	p.scale_amount_min = 0.40
	p.scale_amount_max = 1.05                          # más grandes = se ven
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.82, 0.74, 0.64, 0.95))  # polvo claro, opaco al salir
	ramp.add_point(0.5, Color(0.6, 0.52, 0.44, 0.6))
	ramp.set_color(1, Color(0.4, 0.34, 0.3, 0.0))
	p.color_ramp = ramp
	p.emitting = true
	add_child(p)
	return p

# libera un nodo (ej. partículas one-shot) tras `delay` seg, para que la ráfaga se vea completa
func _free_node_later(node: Node, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(node):
		node.queue_free()

# VENDAS oscuras que SALEN del 2º portal y enganchan al rival (Line2D onduladas, punta carmesí)
func _make_portal_ribbons(n_ribbons: int) -> Node2D:
	var cont := Node2D.new()
	cont.z_index = 24   # POR ENCIMA del portal (z=22) -> se ven sobre el borde rojo
	for i in n_ribbons:
		var ln := Line2D.new()
		ln.width = 30.0                           # GRUESAS como las vendas del personaje
		ln.begin_cap_mode = Line2D.LINE_CAP_ROUND
		ln.end_cap_mode = Line2D.LINE_CAP_ROUND
		ln.joint_mode = Line2D.LINE_JOINT_ROUND
		var g := Gradient.new()
		g.set_color(0, Color(0.01, 0.0, 0.01))    # NEGRO (mismo color que el interior del agujero)
		g.set_color(1, Color(0.03, 0.0, 0.03))    # negro (NADA de rojo)
		ln.gradient = g
		var wc := Curve.new()
		wc.add_point(Vector2(0.0, 1.0))           # gruesa en el portal
		wc.add_point(Vector2(1.0, 0.7))           # sigue gorda hacia la punta
		ln.width_curve = wc
		cont.add_child(ln)
	add_child(cont)
	return cont

# actualiza las cintas: van de from_pos (portal) a to_pos (rival), onduladas; reach 0..1 = extensión
func _update_portal_ribbons(cont: Node2D, from_pos: Vector2, to_pos: Vector2, reach: float, phase: float) -> void:
	if not is_instance_valid(cont):
		return
	var n := cont.get_child_count()
	var dirv := to_pos - from_pos
	var perp := dirv.orthogonal().normalized() if dirv.length() > 1.0 else Vector2.UP
	# ONDULADAS (como cintas de tela): cada venda serpentea del portal al rival, con la onda
	# ATENUÁNDOSE hacia la punta para que LLEGUE limpio al cuerpo (converge en to_pos).
	for i in n:
		var ln: Line2D = cont.get_child(i)
		var pts := PackedVector2Array()
		var segs := 22
		var ampb := 17.0                           # amplitud del TRENZADO (se cruzan entre sí)
		var ph_i := phase + float(i) * 2.1         # FASE distinta por cinta -> se ENTRELAZAN/cruzan
		var off := float(i - (n - 1) / 2) * 5.0    # arrancan cerca del CENTRO del hueco (abanico chico)
		for s in segs + 1:
			var u := float(s) / float(segs)
			var uu := u * clampf(reach, 0.0, 1.0)  # reach 0..1 = qué tanto se extendió
			var base := from_pos.lerp(to_pos, uu)
			var env := sin(uu * PI)                # 0 en el portal y en el cuerpo, MÁX al medio -> convergen
			var wob := sin(uu * 7.5 + ph_i) * ampb * env
			var start_off := off * (1.0 - uu)      # el abanico del inicio se cierra hacia el cuerpo
			pts.append(base + perp * (wob + start_off))
		ln.points = pts

# ROUM ←→R: AGARRE por PORTAL. v1 = casteo (warp_grab) + abre el agujero negro elíptico frente
# a él, sincronizado con el lanzamiento de las vendas (~f80). El 2º portal + el agarre/teleport
# del rival vienen en la v2.
func _roum_warp_grab(f: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	if not f.sprite.sprite_frames.has_animation("warp_grab"):
		return false
	if f.airborne or f.koed or f.is_downed():
		return false
	# cuesta ½ ANILLO VOID (largo alcance + teleport). Sin void: anillo parpadea rojo + NO sale.
	# (ya NO usa la barra verde: el súper de Roum queda libre para esa barra)
	if not _void_ok(f, 0.5):
		_void_denied(f)
		f._deny_flash()
		return true
	_void_spend(f, 0.5)
	var opp: Node2D = dummy if f == player else player
	_run_roum_warp(f, opp)
	return true

# ROUM ↓↓R: PIT GRAB (ANTI-AÉREO). Azota las vendas al frente-abajo -> portal en el frente-abajo;
# un 2º portal sale ARRIBA inclinado y, si el rival está EN EL AIRE, lo agarra y lo hala al piso.
func _roum_pit_grab(f: Node2D) -> bool:
	if state != "fight" or ultra_active:
		return false
	if not f.sprite.sprite_frames.has_animation("pit_grab"):
		return false
	if f.airborne or f.koed or f.is_downed():
		return false
	# cuesta ½ ANILLO VOID (es un portal). Sin void: anillo parpadea rojo + NO sale.
	if not _void_ok(f, 0.5):
		_void_denied(f)
		f._deny_flash()
		return true
	_void_spend(f, 0.5)
	var opp: Node2D = dummy if f == player else player
	_run_roum_pit(f, opp)
	return true

func _run_roum_pit(f: Node2D, opp: Node2D) -> void:
	var was_input: bool = f.input_enabled
	var was_ai: bool = f.ai_enabled
	f.input_enabled = false
	f.ai_enabled = false
	f.crouching = false
	f.vel_x = 0.0
	f.sprite.speed_scale = 2.2                 # animación RÁPIDA (el hoyo dura poco; que la anim le siga el ritmo)
	f.sprite.play("pit_grab")
	# 1er PORTAL al FRENTE-ABAJO — abre DESDE EL INICIO del movimiento (casi sin espera)
	await get_tree().create_timer(0.03).timeout
	if state != "fight" or not is_instance_valid(f) or f.koed or String(f.sprite.animation) != "pit_grab":
		_warp_restore(f, was_input, was_ai)
		return
	var fc: int = f.facing
	var pit := _make_void_portal(self)
	# ELIPSE PLANA sobre el SUELO (hoyo en el piso), MÁS SEPARADO de él y bien plano (como en el piso de verdad).
	# ground_y = línea de PISO real del juego (to_global de SHADOW_FEET_OFFSET=500), no floor_y (que es el origen alto)
	var ground_y := f.to_global(Vector2(0.0, 500.0)).y
	pit.position = Vector2(f.position.x + float(fc) * 390.0, ground_y - 22.0)   # MÁS lejos de Roum
	pit.rotation = -float(fc) * 0.05                      # CASI HORIZONTAL = hoyo visto en el piso
	pit.scale = Vector2(float(fc) * 0.96, 0.20)           # AÚN más ANCHO y PLANO (bien pegado al suelo)
	# SONIDO del agujero negro (se corta al cerrar los portales)
	var bhp: AudioStreamPlayer = null
	if ResourceLoader.exists("res://imagen-action/roum/sound-effect/black-hole.mp3"):
		bhp = AudioStreamPlayer.new()
		bhp.stream = load("res://imagen-action/roum/sound-effect/black-hole.mp3")
		bhp.volume_db = 2.0
		add_child(bhp)
		bhp.finished.connect(bhp.queue_free)
		bhp.play()
	await _portal_grow(pit, 0.0, 1.0, 0.16)
	_shake(10.0, 0.10)
	# DUST: las vendas azotan el piso al abrirse el hoyo (polvo del juego, en el spot del portal)
	if f.has_method("_spawn_jump_dust"):
		f._spawn_jump_dust(1.5, pit.position.x)
		f._spawn_jump_dust(1.1, pit.position.x - float(fc) * 90.0)
	await get_tree().create_timer(0.09).timeout           # rápido: atrapar al rival mientras sigue en el aire
	# 2º HOLE + AGARRE — SÓLO si el rival está EN EL AIRE y CERCA (anti-aéreo de alcance corto).
	# Flujo: el rival es METIDO al 2º hoyo (sobre él) y SALE del 1er hoyo (el del piso), de ABAJO
	# hacia ARRIBA, frente a Roum.
	var sky: Sprite2D = null
	# el 2º HOLE + las cintas SALEN SIEMPRE (aunque el rival no salte) — INTENTAN agarrar.
	var grab_ok: bool = is_instance_valid(opp) and not opp.koed and not opp.is_downed()
	# pero el AGARRE real (meter→sacar→daño) SÓLO conecta si está EN EL AIRE y CERCA (anti-aéreo corto).
	# HOYO AÉREO a una DISTANCIA FIJA de Roum (arriba-adelante) — NO donde está el rival. Sale SIEMPRE
	# en el mismo punto; agarra sólo si el rival está EN EL AIRE y DENTRO de ese hoyo (cerca del punto).
	var sky_pos := Vector2(f.position.x + float(fc) * 760.0, f.position.y - 350.0)   # MÁS a la DERECHA (adelante) y arriba
	var will_grab: bool = grab_ok \
		and (opp.airborne or opp.hit_flying or opp.position.y < opp.floor_y - 40.0) \
		and opp.position.distance_to(sky_pos) <= 560.0
	if state == "fight" and grab_ok:
		sky = _make_void_portal(self)
		# 2º HOLE ESTÁTICO a distancia fija de Roum, BIEN de medio lado (diagonal y angosto)
		sky.position = sky_pos
		sky.rotation = -float(fc) * 0.95                      # MÁS ladeado (de medio lado)
		sky.scale = Vector2(float(fc) * 0.28, 0.62)           # MÁS ANGOSTO y elongado (óvalo de medio lado)
		await _portal_grow(sky, 0.0, 1.0, 0.11)               # se abre en su lugar (NO sigue al rival)
		var suck := _portal_suck_fx(sky.position)
		var ribbons := _make_portal_ribbons(5)
		var rib_phase := 0.0
		# las cintas SALEN del hoyo fijo e intentan alcanzar al rival
		var rt := 0.0
		while rt < 0.09 and is_instance_valid(opp) and not opp.koed:
			rt += get_process_delta_time()
			rib_phase += get_process_delta_time() * 11.0
			_update_portal_ribbons(ribbons, sky.position, Vector2(opp.position.x, opp.position.y), clampf(rt / 0.09, 0.0, 1.0), rib_phase)
			await get_tree().process_frame
		if will_grab:
			var opp_was_input: bool = opp.input_enabled
			var opp_was_ai: bool = opp.ai_enabled
			opp.input_enabled = false
			opp.ai_enabled = false
			opp.crouching = false
			opp.airborne = false
			opp.hit_flying = false
			opp.vel_x = 0.0
			opp.vel_y = 0.0
			opp.set_facing(-fc)
			if opp.sprite.sprite_frames.has_animation("get_pull"):
				opp.sprite.play("get_pull")
			opp._play_sfx_key("take_hit")
			# SUCK: el rival es ARRASTRADO DENTRO del 2º hoyo (se mete y DESAPARECE)
			var opos0: Vector2 = opp.position
			var scenter: Vector2 = sky.position
			var st := 0.0
			while st < 0.13 and state == "fight" and is_instance_valid(opp) and not opp.koed:
				var k := st / 0.13
				opp.position = opos0.lerp(scenter, _ease_out_cubic(k))
				var dk := lerpf(1.0, 0.10, k)
				opp.modulate = Color(dk, dk, dk, lerpf(1.0, 0.0, k))   # se oscurece y se desvanece dentro
				rib_phase += get_process_delta_time() * 11.0
				_update_portal_ribbons(ribbons, sky.position, Vector2(opp.position.x, opp.position.y), 1.0, rib_phase)
				await get_tree().process_frame
				st += get_process_delta_time()
			# EMERGE: SALE del 1er hoyo (pit, frente a Roum) de ABAJO hacia ARRIBA
			if is_instance_valid(opp) and not opp.koed:
				var land := Vector2(clampf(f.position.x + float(fc) * 230.0, LEFT_LIMIT, RIGHT_LIMIT), opp.floor_y)
				var below := Vector2(pit.position.x, opp.floor_y + 190.0)   # justo bajo el pit (oculto)
				opp.position = below
				opp.set_facing(-fc)
				if opp.sprite.sprite_frames.has_animation("get_pull"):
					opp.sprite.play("get_pull")
				if f.has_method("_spawn_jump_dust"):
					f._spawn_jump_dust(1.2, pit.position.x)          # polvo al SALIR del piso
				_shake(12.0, 0.12)
				var es := 0.0
				while es < 0.18 and is_instance_valid(opp) and not opp.koed:
					var k := es / 0.18
					opp.position.x = lerpf(below.x, land.x, _ease_out_cubic(k))
					opp.position.y = lerpf(below.y, land.y, _ease_out_cubic(k))   # de ABAJO hacia ARRIBA
					var lit := lerpf(0.10, 1.0, k)
					opp.modulate = Color(lit, lit, lit, clampf(k * 2.0, 0.0, 1.0))   # reaparece
					await get_tree().process_frame
					es += get_process_delta_time()
				opp.position = land
				opp.modulate = Color(1, 1, 1, 1)
				if opp.has_method("_spawn_jump_dust"):
					opp._spawn_jump_dust(1.1)
				_shake(14.0, 0.14)
				opp._burst(1.1, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
				var d := 85
				_dmg_number(opp, d)
				if f == player:
					dummy_hp = maxi(0, dummy_hp - d)
					if dummy_hp <= 0 and _round_real(): _end_round(true)
				else:
					player_hp = maxi(0, player_hp - d)
					if player_hp <= 0 and _round_real(): _end_round(false)
				await get_tree().create_timer(0.12).timeout
				if is_instance_valid(opp):
					opp.modulate = Color(1, 1, 1, 1)
					opp.input_enabled = opp_was_input
					opp.ai_enabled = opp_was_ai
					if String(opp.sprite.animation) == "get_pull":
						opp.sprite.play("pose")
		else:
			# NO conectó (rival en el piso o lejos): las cintas se RETRAEN (el hoyo intentó y falló)
			var mt := 0.0
			while mt < 0.10 and is_instance_valid(opp):
				mt += get_process_delta_time()
				rib_phase += get_process_delta_time() * 11.0
				_update_portal_ribbons(ribbons, sky.position, Vector2(opp.position.x, opp.position.y), clampf(1.0 - mt / 0.10, 0.0, 1.0), rib_phase)
				await get_tree().process_frame
		# limpieza común de las cintas/succión
		if is_instance_valid(suck):
			suck.emitting = false
			_free_node_later(suck, 0.6)
		if is_instance_valid(ribbons):
			ribbons.queue_free()
	else:
		await get_tree().create_timer(0.12).timeout
	# CORTA el sonido y CIERRA los portales
	if is_instance_valid(bhp):
		var tw := create_tween()
		tw.tween_property(bhp, "volume_db", -40.0, 0.18)
		tw.tween_callback(bhp.queue_free)
	if sky != null and is_instance_valid(sky):
		await _portal_grow(sky, 1.0, 0.0, 0.10)
		sky.queue_free()
	if is_instance_valid(pit):
		await _portal_grow(pit, 1.0, 0.0, 0.12)
		pit.queue_free()
	_warp_restore(f, was_input, was_ai)

# anima el 'grow' del portal de a->b en dur segundos (apertura/cierre)
func _portal_grow(portal: Sprite2D, a: float, b: float, dur: float) -> void:
	if not is_instance_valid(portal):
		return
	var mat: ShaderMaterial = portal.material
	var t := 0.0
	while t < dur and is_instance_valid(portal):
		t += get_process_delta_time()
		mat.set_shader_parameter("grow", lerpf(a, b, clampf(t / dur, 0.0, 1.0)))
		await get_tree().process_frame
	if is_instance_valid(portal):
		mat.set_shader_parameter("grow", b)

func _warp_restore(f: Node2D, was_input: bool, was_ai: bool) -> void:
	if is_instance_valid(f):
		f.sprite.speed_scale = 1.0                # restaura la velocidad normal de anim
		f.input_enabled = was_input
		f.ai_enabled = was_ai
		if String(f.sprite.animation) in ["warp_grab", "pit_grab"]:
			f.sprite.play("pose")

func _run_roum_warp(f: Node2D, opp: Node2D) -> void:
	# LOCK del casteo: sin esto el idle/locomoción del fighter PISA la anim (no se ejecutaba)
	var was_input: bool = f.input_enabled
	var was_ai: bool = f.ai_enabled
	f.input_enabled = false
	f.ai_enabled = false
	f.crouching = false
	f.vel_x = 0.0
	f.sprite.speed_scale = 1.5                 # TODA la anim más rápida (se restaura en _warp_restore)
	f.sprite.play("warp_grab")
	# 1er PORTAL frente a Roum: aparece cuando ROTA la mano (más rápido) y CRECE ahí
	await get_tree().create_timer(0.15).timeout
	if state != "fight" or not is_instance_valid(f) or f.koed or String(f.sprite.animation) != "warp_grab":
		_warp_restore(f, was_input, was_ai)
		return
	var fc: int = f.facing
	var portal := _make_void_portal(self)
	portal.position = Vector2(f.position.x + float(fc) * 480.0, f.position.y - 60.0)
	portal.scale = Vector2(float(fc) * 0.34, 1.10)   # ELIPSE VERTICAL ALTA (por acá SALE el rival)
	# SONIDO del agujero negro (lo puso el usuario): suena al abrirse el portal.
	# Se GUARDA la referencia para CORTARLO cuando se cierran los huecos (el clip es más largo
	# que la acción; si no, seguiría sonando después de que desaparecen los portales).
	var bhp: AudioStreamPlayer = null
	if ResourceLoader.exists("res://imagen-action/roum/sound-effect/black-hole.mp3"):
		bhp = AudioStreamPlayer.new()
		bhp.stream = load("res://imagen-action/roum/sound-effect/black-hole.mp3")
		bhp.volume_db = 2.0
		add_child(bhp)
		bhp.finished.connect(bhp.queue_free)
		bhp.play()
	await _portal_grow(portal, 0.0, 1.0, 0.18)       # abre mientras rota la mano (más rápido)
	await get_tree().create_timer(0.18).timeout      # las vendas se lanzan y ENTRAN al portal
	# 2º PORTAL cerca del RIVAL: de ahí salen las vendas, lo AGARRAN y lo TRAGAN
	var portal2: Sprite2D = null
	if state == "fight" and is_instance_valid(opp) and not opp.koed and not opp.is_downed():
		portal2 = _make_void_portal(self)
		# DETRÁS del rival (lo atrapa por la ESPALDA y lo hala hacia atrás, al portal)
		portal2.position = Vector2(opp.position.x + float(fc) * 250.0, opp.position.y - 60.0)
		portal2.scale = Vector2(float(-fc) * 0.34, 1.10)
		await _portal_grow(portal2, 0.0, 1.0, 0.11)
		var suck := _portal_suck_fx(portal2.position)   # partículas carmesí/negras succionadas al 2º portal
		_shake(12.0, 0.12)
		# VENDAS: SALEN del 2º portal y ENGANCHAN al rival por la espalda (extienden reach 0->1)
		var ribbons := _make_portal_ribbons(5)
		var rib_phase := 0.0
		var rt := 0.0
		while rt < 0.10 and is_instance_valid(opp) and not opp.koed:
			rt += get_process_delta_time()
			rib_phase += get_process_delta_time() * 11.0
			# objetivo = PECHO REAL del rival (escala por base_scale): sirve para ALTOS y BAJITOS.
			# El portal está alto; la cinta baja en diagonal hasta el cuerpo -> SIEMPRE le da.
			_update_portal_ribbons(ribbons, portal2.position, Vector2(opp.position.x, opp.position.y + 210.0 * opp.base_scale.y), clampf(rt / 0.10, 0.0, 1.0), rib_phase)
			await get_tree().process_frame
		var opp_was_input: bool = opp.input_enabled
		var opp_was_ai: bool = opp.ai_enabled
		opp.input_enabled = false
		opp.ai_enabled = false
		opp.crouching = false
		opp.airborne = false
		opp.hit_flying = false
		opp.vel_x = 0.0
		opp.vel_y = 0.0
		opp.set_facing(-fc)
		if opp.sprite.sprite_frames.has_animation("get_pull"):
			opp.sprite.play("get_pull")
		opp._play_sfx_key("take_hit")
		# TRAGADO: el rival es absorbido HACIA el 2º portal (detrás), desvaneciéndose.
		# POLVO de arrastre con el DUST DEL JUEGO (arte real, bien visible) en AMBOS peleadores.
		var opos0: Vector2 = opp.position
		var pcenter: Vector2 = portal2.position
		if opp.has_method("_spawn_jump_dust"):
			opp._spawn_jump_dust(1.25)                   # RIVAL halado: puff fuerte a sus pies
		if f.has_method("_spawn_jump_dust"):
			f._spawn_jump_dust(1.0)                      # ROUM (el que hala): puff a sus pies
		var st := 0.0
		var dtrail := 0.0
		while st < 0.11 and state == "fight" and is_instance_valid(opp) and not opp.koed:   # AÚN MÁS RÁPIDO
			var k := st / 0.11
			opp.position = opos0.lerp(pcenter, _ease_out_cubic(k))
			# al METERSE al agujero: se oscurece a SILUETA NEGRA + se desvanece
			var dk := lerpf(1.0, 0.05, k)
			opp.modulate = Color(dk, dk, dk, lerpf(1.0, 0.30, k))
			dtrail += get_process_delta_time()
			if dtrail >= 0.045 and opp.has_method("_spawn_jump_dust"):   # ESTELA de polvo mientras lo arrastra
				dtrail = 0.0
				opp._spawn_jump_dust(0.85)
			rib_phase += get_process_delta_time() * 9.0
			_update_portal_ribbons(ribbons, pcenter, Vector2(opp.position.x, opp.position.y + 210.0 * opp.base_scale.y), 1.0, rib_phase)
			await get_tree().process_frame
			st += get_process_delta_time()
		if is_instance_valid(suck):
			suck.emitting = false
			suck.queue_free()
		if is_instance_valid(ribbons):
			ribbons.queue_free()
		# EMERGE por el 1er PORTAL (frente a Roum) y se desliza a su sitio, mirando a Roum + daño
		if is_instance_valid(opp) and not opp.koed:
			var emerge_x: float = clampf(f.position.x + float(fc) * 480.0, LEFT_LIMIT, RIGHT_LIMIT)  # sale POR el 1er portal
			var target_x: float = clampf(f.position.x + float(fc) * 260.0, LEFT_LIMIT, RIGHT_LIMIT)  # queda adelante de Roum
			opp.position = Vector2(emerge_x, opp.floor_y)
			opp.set_facing(-fc)
			if opp.sprite.sprite_frames.has_animation("get_pull"):
				opp.sprite.play("get_pull")
			elif opp.sprite.sprite_frames.has_animation("take_hit"):
				opp.sprite.play("take_hit")
			_shake(14.0, 0.14)
			var es := 0.0
			while es < 0.15 and is_instance_valid(opp) and not opp.koed:
				var k := es / 0.15
				opp.position.x = lerpf(emerge_x, target_x, _ease_out_cubic(k))
				opp.position.y = opp.floor_y
				# al SALIR del portal: recupera color (de silueta negra a color) + aparece
				var lit := lerpf(0.05, 1.0, k)
				opp.modulate = Color(lit, lit, lit, clampf(k * 2.0, 0.0, 1.0))
				await get_tree().process_frame
				es += get_process_delta_time()
			if is_instance_valid(opp):
				opp.position = Vector2(target_x, opp.floor_y)
				opp.modulate = Color(1, 1, 1, 1)   # color pleno recuperado
				opp._burst(1.1, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
				var d := 80
				_dmg_number(opp, d)
				if f == player:
					dummy_hp = maxi(0, dummy_hp - d)
					if dummy_hp <= 0 and _round_real(): _end_round(true)
				else:
					player_hp = maxi(0, player_hp - d)
					if player_hp <= 0 and _round_real(): _end_round(false)
		await get_tree().create_timer(0.15).timeout   # breve ventana de combo (más corta)
		if is_instance_valid(opp):
			opp.modulate = Color(1, 1, 1, 1)   # asegura color pleno al soltarlo
			opp.input_enabled = opp_was_input
			opp.ai_enabled = opp_was_ai
			if String(opp.sprite.animation) == "get_pull":
				opp.sprite.play("pose")
	# CORTA el sonido del agujero negro AL IRSE los huecos (fade corto, en paralelo al cierre):
	# el clip dura más que la acción, así no sigue sonando después de que desaparecen los portales.
	if is_instance_valid(bhp):
		var tw := create_tween()
		tw.tween_property(bhp, "volume_db", -40.0, 0.18)
		tw.tween_callback(bhp.queue_free)
	# CIERRA los dos portales
	if portal2 != null and is_instance_valid(portal2):
		await _portal_grow(portal2, 1.0, 0.0, 0.10)
		portal2.queue_free()
	if is_instance_valid(portal):
		await _portal_grow(portal, 1.0, 0.0, 0.12)
		portal.queue_free()
	_warp_restore(f, was_input, was_ai)

func _orb_mote_tex() -> Texture2D:
	# mote REDONDO con núcleo brillante y borde suave (para que las partículas no salgan cuadradas)
	if orb_mote_tex != null:
		return orb_mote_tex
	var s := 24
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	for y in s:
		for x in s:
			var dd := Vector2(x - s / 2.0, y - s / 2.0).length() / (s / 2.0)
			var a := clampf(1.0 - dd, 0.0, 1.0)
			a = a * a                          # núcleo intenso + halo suave = punto luminoso redondo
			img.set_pixel(x, y, Color(1, 1, 1, a))
	orb_mote_tex = ImageTexture.create_from_image(img)
	return orb_mote_tex

func _spawn_void_suction(arena: Node, cx: float, cy: float, r0: float) -> void:
	# ONDA de SUCCIÓN: como el nova de DAM pero AL REVÉS — un anillo neón que entra
	# desde AFUERA y se CONTRAE hasta el centro de la esfera (se ve como que chupa todo adentro)
	if not is_instance_valid(arena):
		return
	var cont := Node2D.new()
	cont.position = Vector2(cx, cy)
	cont.z_index = 11                          # sobre el domo (z=10)
	arena.add_child(cont)
	var ring := Line2D.new()
	var pts := PackedVector2Array()
	for i in 49:
		var a := TAU * float(i) / 48.0
		pts.append(Vector2(cos(a), sin(a)))    # círculo (esfera redonda)
	ring.points = pts
	ring.closed = true
	ring.joint_mode = Line2D.LINE_JOINT_ROUND
	ring.default_color = Color(1.7, 0.85, 2.6, 0.0)   # neón morado HDR -> bloom
	cont.add_child(ring)
	var t := 0.0
	var DUR := 0.72
	while t < DUR and is_instance_valid(cont):
		t += get_process_delta_time()
		var k := clampf(t / DUR, 0.0, 1.0)
		var r := maxf(r0 * (1.0 - k), 1.0)      # CONTRAE: afuera -> adentro (muere en el centro)
		cont.scale = Vector2(r, r)
		ring.width = 8.0 / r                     # grosor visual ~8px constante
		ring.default_color.a = 0.9 * smoothstep(0.0, 0.12, k) * (1.0 - smoothstep(0.72, 1.0, k))
		await get_tree().process_frame
	if is_instance_valid(cont):
		cont.queue_free()

func _make_void_dome(arena: Node) -> Sprite2D:
	if void_dome_shader == null:
		void_dome_shader = load("res://void_dome.gdshader")
	if void_orb_tex == null:
		var img := Image.create(768, 768, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 1, 1, 1))
		void_orb_tex = ImageTexture.create_from_image(img)
	var sp := Sprite2D.new()
	sp.texture = void_orb_tex
	sp.centered = true
	var mat := ShaderMaterial.new()
	mat.shader = void_dome_shader
	mat.set_shader_parameter("grow", 0.0)
	mat.set_shader_parameter("seed", 0.51)
	sp.material = mat
	# energía subiendo y orbitando DENTRO de la cúpula (épico) — motes REDONDOS, chicos y brillantes
	var sw := CPUParticles2D.new()
	sw.texture = _orb_mote_tex()               # redondo (antes: cuadrados grandes)
	sw.amount = 32
	sw.lifetime = 1.3
	sw.local_coords = true
	sw.position = Vector2(0, 40)               # emite alrededor del centro del círculo (que ahora está subido)
	sw.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	sw.emission_sphere_radius = 235.0
	sw.gravity = Vector2.ZERO
	sw.orbit_velocity_min = 0.8                # ORBITAN claro alrededor (esfera girando)
	sw.orbit_velocity_max = 1.4
	sw.radial_accel_min = -45.0               # + succión: los hala hacia adentro
	sw.radial_accel_max = -12.0
	sw.initial_velocity_min = 0.0
	sw.initial_velocity_max = 15.0
	sw.scale_amount_min = 0.30                 # chicos
	sw.scale_amount_max = 0.72
	sw.color = Color(1.9, 0.95, 2.9)           # luminosos pero un poco más OSCUROS
	sp.add_child(sw)
	sw.emitting = true
	arena.add_child(sp)
	return sp

func _spawn_zetma_orb(caster: Node2D) -> void:
	var dir: int = caster.facing
	var opp: Node2D = dummy if caster == player else player
	var arena: Node = caster.get_parent()
	var proj := _make_void_orb(arena)          # ORBE VOID por SHADER (no PNG)
	proj.z_index = 7
	var _sh := "res://imagen-action/zetma/sound-effect/orb-energy.mp3"   # sonido de ENERGÍA del orb
	if ResourceLoader.exists(_sh):
		# player PROPIO en la arena: no lo corta el sfx_player ni hereda un volume_db bajo (p.ej. -8 del pose)
		var _strm = load(_sh)
		if _strm is AudioStreamMP3:
			_strm.loop = false
		var _osp := AudioStreamPlayer.new()
		_osp.stream = _strm
		_osp.volume_db = 6.0                    # bien audible
		arena.add_child(_osp)
		_osp.finished.connect(_osp.queue_free)
		_osp.play()
	var py: float = caster.position.y - 32.0    # más al CENTRO del cañón (antes salía arriba)
	var startx: float = caster.position.x + float(dir) * 230.0
	proj.position = Vector2(startx, py)
	proj.scale = Vector2(0.38, 0.38)            # sale un poco MÁS PEQUEÑA y crece
	proj.modulate = Color(0.74, 0.62, 0.92, 1.0) # más oscuro (morado más profundo)
	var hit := false
	var start_ms := Time.get_ticks_msec()
	var last_ms := start_ms
	var travelled := 0.0
	while state == "fight" and is_instance_valid(proj) and (Time.get_ticks_msec() - start_ms) < 2200:
		var now := Time.get_ticks_msec()
		var dt := clampf(float(now - last_ms) / 1000.0, 0.0, 0.05)
		last_ms = now
		var step: float = 1050.0 * dt
		proj.position.x += float(dir) * step
		travelled += step
		proj.scale = Vector2.ONE * lerpf(0.38, 0.82, clampf(travelled / 320.0, 0.0, 1.0))   # crece (un poco más chica)
		if is_instance_valid(opp) and not opp.koed and not opp.is_downed() \
				and opp.breaker_inv_t <= 0.0 and absf(proj.position.x - opp.position.x) < 150.0:
			hit = true; break
		if proj.position.x < LEFT_LIMIT or proj.position.x > RIGHT_LIMIT:
			break
		await get_tree().process_frame
	if hit and is_instance_valid(opp):
		_zetma_orb_hit(caster, opp, proj)
	elif is_instance_valid(proj):
		var tw := proj.create_tween(); tw.tween_property(proj, "modulate:a", 0.0, 0.2); tw.tween_callback(proj.queue_free)

func _spawn_dmg_number(arena: Node, wx: float, wy: float, amount: int) -> void:
	if not is_instance_valid(arena):
		return
	var lb := Label.new()
	lb.text = "-%d" % amount
	lb.add_theme_font_size_override("font_size", 66)
	lb.add_theme_color_override("font_color", Color(1.7, 0.7, 2.3))
	lb.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	lb.add_theme_constant_override("outline_size", 10)
	lb.z_index = 20
	lb.position = Vector2(wx, wy)
	arena.add_child(lb)
	var tw := lb.create_tween()
	tw.tween_property(lb, "position:y", wy - 130.0, 0.75).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(lb, "scale", Vector2(1.25, 1.25), 0.12)
	tw.parallel().tween_property(lb, "modulate:a", 0.0, 0.55).set_delay(0.28)
	tw.tween_callback(lb.queue_free)

func _zetma_orb_hit(caster: Node2D, opp: Node2D, proj: Node2D) -> void:
	# TRAMPA: rival en CÁMARA LENTA 2s (no actúa, sí recibe golpes) + Zetma gana velocidad
	opp.orb_trap_was_input = opp.input_enabled
	opp.orb_trap_was_ai = opp.ai_enabled
	opp.orb_trap_sprite_home = opp.sprite.position
	opp.input_enabled = false
	opp.ai_enabled = false
	opp.hit_flying = false; opp.airborne = false; opp.vel_x = 0.0; opp.vel_y = 0.0
	opp.position.y = opp.floor_y
	if opp.sprite.sprite_frames.has_animation("get_pull"):
		opp.sprite.play("get_pull")   # anim de "halado" mientras la esfera lo absorbe (NO se escala)
	opp.orb_trap_t = 2.0
	opp.orb_trap_max = 2.0
	caster.orb_haste_t = 2.0
	_shake(24.0, 0.34)
	opp._play_sfx_key("take_hit")
	# HUMO DE CAÍDA en el suelo bajo la esfera (llegó a su tamaño MÁXIMO): polvo morado/void
	if opp.has_method("_spawn_jump_dust"):
		opp._spawn_jump_dust(1.25, NAN, Color(0.80, 0.42, 1.45, 1.0))
	# el orb IMPACTA y se transforma en una CÚPULA VOID que ENJAULA al rival
	if is_instance_valid(proj):
		proj.queue_free()                      # el proyectil desaparece
	var _arena: Node = opp.get_parent()
	var dome := _make_void_dome(_arena)
	var _dmat: ShaderMaterial = dome.material as ShaderMaterial
	dome.z_index = 10                          # domo SEMI-TRANSPARENTE por delante (ves al rival adentro)
	var _oppz0: int = opp.z_index
	var _bs: float = opp.base_scale.y          # el CÍRCULO escala con el tamaño del rival
	var _dsc := 1.15 * _bs                     # tamaño (tuneable) — más CHICA que antes
	# los PIES caen SIEMPRE en position.y+500 (el offset compensa la escala); la cabeza SÍ escala.
	# Por eso el centro del cuerpo NO es proporcional a bs: se ancla a pies - MITAD de la altura
	# visible (≈340*bs). Así la esfera queda centrada en el rival sea grande (DAM) o chico (Aye).
	var _cy: float = opp.position.y + 500.0 - 340.0 * _bs - 45.0   # centro del CUERPO, SUBIDO 45px (tuneable)
	dome.scale = Vector2(_dsc, _dsc)
	dome.position = Vector2(opp.position.x, _cy)
	var st := 0.0
	var drain_t := 0.0
	var dead := false
	var _rev := 0.4
	var _suck_t := 0.0
	var _suck_r0 := 1250.0                             # las ondas entran desde TODA la pantalla
	var _suck_root := Node2D.new()                     # contenedor: se libera al final -> NINGUNA onda queda flotando
	_arena.add_child(_suck_root)
	var _grnd: float = _cy + 185.86 * _dsc             # línea del SUELO (corte del círculo) a tamaño full
	var _cutoff := 185.86                              # (0.742-0.5)*768: offset del corte por unidad de escala
	# SONIDO mientras la esfera está en pantalla (orb-duration.mp3)
	var _dur_snd: AudioStreamPlayer = null
	var _dsnd := "res://imagen-action/zetma/sound-effect/orb-duration.mp3"
	if ResourceLoader.exists(_dsnd):
		var _ds = load(_dsnd)
		if _ds is AudioStreamMP3: _ds.loop = false
		_dur_snd = AudioStreamPlayer.new()
		_dur_snd.stream = _ds
		_dur_snd.volume_db = 7.0
		_arena.add_child(_dur_snd)
		_dur_snd.play()
	while st < 2.0 and is_instance_valid(dome) and is_instance_valid(opp):
		var _d: float = get_process_delta_time()
		var _rem: float = 2.0 - st
		var g: float = 1.0
		var _sc: float = _dsc
		var _posy: float = _cy
		if st < 0.16:
			g = st / 0.16                      # SLAM: el domo se ABRE de golpe
		elif _rem <= _rev:
			# CIERRE: se hace CHICA hundiéndose en el SUELO (NO colapsa al centro)
			var s := clampf(_rem / _rev, 0.0, 1.0)   # 1 -> 0
			_sc = _dsc * s
			_posy = _grnd - _cutoff * _sc            # el suelo queda FIJO; la esfera se encoge hacia él
			dome.modulate.a = clampf(s * 1.3, 0.0, 1.0)
		if _dmat != null: _dmat.set_shader_parameter("grow", clampf(g, 0.0, 1.0))
		dome.scale = Vector2(_sc, _sc)
		dome.position = Vector2(opp.position.x, _posy)
		opp.orb_trap_top_y = (_cy - opp.position.y) - 337.9 * _dsc - 20.0   # derivada de la CIMA real de la esfera
		# ONDAS de SUCCIÓN: anillos que entran desde TODA la pantalla y mueren en el CENTRO
		# (paran ANTES del cierre para que ninguna quede flotando separada al morir la esfera)
		_suck_t += _d
		if g >= 0.9 and _rem > _rev + 0.8 and _suck_t >= 0.32:
			_suck_t -= 0.32
			_spawn_void_suction(_suck_root, opp.position.x, _cy, _suck_r0)
		# DRENA vida: -20 cada 0.5s mientras el rival esté atrapado en la esfera
		drain_t += _d
		if drain_t >= 0.5:
			drain_t -= 0.5
			if caster == player:
				dummy_hp = maxi(0, dummy_hp - 20)
			else:
				player_hp = maxi(0, player_hp - 20)
			opp._play_sfx_key("take_hit")
			_shake(6.0, 0.10)
			if opp.has_method("_burst"):
				opp._burst(0.8, false, 1, false, 500.0 * (1.0 - opp.base_scale.y))
			_spawn_dmg_number(opp.get_parent(), opp.position.x - 44.0, opp.position.y - 260.0, 20)
			dead = (dummy_hp <= 0) if caster == player else (player_hp <= 0)
			if dead:
				break
		await get_tree().process_frame
		st += _d
	# suelta la trampa y limpia el estado del atrapado (para KO limpio o fin normal)
	if is_instance_valid(opp):
		opp.orb_trap_t = 0.0
		opp.sprite.speed_scale = 1.0
		opp.sprite.modulate = Color(1, 1, 1, 1)
		opp.input_enabled = opp.orb_trap_was_input
		opp.ai_enabled = opp.orb_trap_was_ai
		opp.sprite.scale = opp.base_scale
		opp.sprite.position = opp.orb_trap_sprite_home
		opp.z_index = _oppz0
		if not opp.koed and opp.sprite.sprite_frames.has_animation("pose"):
			opp.sprite.play("pose")
	if is_instance_valid(dome):
		var tw := dome.create_tween(); tw.tween_property(dome, "modulate:a", 0.0, 0.3); tw.tween_callback(dome.queue_free)
	if is_instance_valid(_suck_root):
		_suck_root.queue_free()                # mata TODAS las ondas restantes (ninguna queda flotando)
	if is_instance_valid(_dur_snd):
		_dur_snd.stop(); _dur_snd.queue_free() # corta el sonido de duración de la orb
	# si murió por el DRENAJE de la esfera, cerrar la ronda
	if dead:
		if caster == player and dummy_hp <= 0 and _round_real():
			_end_round(true)
		elif caster == dummy and player_hp <= 0 and _round_real():
			_end_round(false)

# feedback "SIN BARRA": el medidor PARPADEA (apaga/prende 3 veces) — sin esto el comando
# parecía ROTO. OJO: nada de tintes sobre el relleno verde (rojo×verde se veía GRIS sucio);
# el tono gris es EXCLUSIVO del personaje (_deny_flash del fighter).
func _meter_deny_flash(idx: int) -> void:
	for k in 3:
		for seg in meter_fill[idx]:
			if is_instance_valid(seg):
				seg.visible = false
		await get_tree().create_timer(0.07).timeout
		for seg in meter_fill[idx]:
			if is_instance_valid(seg):
				seg.visible = true
		await get_tree().create_timer(0.07).timeout

# el TIGRE cuesta BARRA Y MEDIA: se cobra al INICIAR el cast (como el whirlpool su barra)
# gasto GENÉRICO de barra con deny (personaje gris + blink de la barra si no alcanza)
func try_meter_cost(caster: Node2D, costo: float) -> bool:
	if state != "fight" or ultra_active:
		return false
	var idx := 0 if caster == player else 1
	if meter[idx] < costo:
		_meter_deny_flash(idx)
		caster._deny_flash()
		return false
	meter[idx] -= costo
	return true

# THUNDER de Fe (↓↘→ Q/W/E): cuesta MEDIA barra
func try_thunder_cost(caster: Node2D) -> bool:
	return try_meter_cost(caster, 0.5)

func try_tiger_cost(caster: Node2D) -> bool:
	if state != "fight" or ultra_active or _fe_tiger_active:
		return false
	var idx := 0 if caster == player else 1
	if meter[idx] < 1.5:
		_meter_deny_flash(idx)
		caster._deny_flash()   # GRIS: no pudo castear por falta de barra
		return false
	meter[idx] -= 1.5
	return true

# ---- FE: TIGRE DE ENERGÍA BLANCA (↓R = cast agachada + tigre que corre y ARRASTRA) ----
# El tigre corre hacia adelante; al tocar al rival lo AGARRA y lo arrastra pegándole 4
# veces, remata DERRIBANDO y sigue de largo hasta disolverse. La guardia lo deshace.
var _fe_tiger_frames: SpriteFrames = null
var _fe_tiger_active := false
func _fe_tiger_attack(caster: Node2D) -> void:
	if state != "fight" or ultra_active or _fe_tiger_active:
		return
	if String(caster.sprite.animation) != "crouch_jab":
		return   # el cast fue interrumpido (recibió un golpe, etc.): el tigre no sale
	if _fe_tiger_frames == null:
		if not ResourceLoader.exists("res://imagen-action/impact-effect/tiger-fe/run-1.png"):
			return
		_fe_tiger_frames = SpriteFrames.new()
		for anim in [["run", true, 40.0], ["out", false, 34.0]]:
			_fe_tiger_frames.add_animation(anim[0])
			_fe_tiger_frames.set_animation_loop(anim[0], anim[1])
			_fe_tiger_frames.set_animation_speed(anim[0], anim[2])
			var fi := 1
			while ResourceLoader.exists("res://imagen-action/impact-effect/tiger-fe/%s-%d.png" % [anim[0], fi]):
				_fe_tiger_frames.add_frame(anim[0], load("res://imagen-action/impact-effect/tiger-fe/%s-%d.png" % [anim[0], fi]))
				fi += 1
	_fe_tiger_active = true
	var victima: Node2D = dummy if caster == player else player
	var idx := 0 if caster == player else 1
	var dir := 1 if caster.facing >= 0 else -1
	var tg := AnimatedSprite2D.new()
	tg.sprite_frames = _fe_tiger_frames
	tg.flip_h = dir < 0
	tg.scale = Vector2(0.72, 0.72)   # un poco más chico (pedido del usuario)
	tg.z_index = 5
	# PATAS en la línea de piso REAL: los nodos de los peleadores llevan scale 0.65 en la
	# escena -> sus pies visuales están a +324 del nodo (499×0.65), NO a +499 (ese error
	# hundía al tigre 175px). Patas del tigre a +190 del centro del recorte ×0.72 = 137.
	# 324 - 137 = +187.
	tg.position = Vector2(caster.position.x + float(dir) * 210.0, caster.floor_y + 187.0)
	add_child(tg)
	tg.play("run")
	# RUGIDO al aparecer — en un player PROPIO del tigre (la voz de Fe "Let go, Tiger!"
	# va por su canal y NO deben cortarse entre sí)
	var roar := "res://imagen-action/favi/Fe-sound-effect/tiger-roar.mp3"
	if ResourceLoader.exists(roar):
		var rp := AudioStreamPlayer.new()
		rp.stream = load(roar)
		rp.volume_db = 7.0   # el mp3 crudo viene BAJO: el rugido debe imponerse
		tg.add_child(rp)
		rp.play()
	var speed := 1500.0
	var hits_left := 4
	var hit_cd := 0.0
	var grabbed := false
	var traveled := 0.0
	# el tigre corre CORTO (~2 cuerpos) y se desvanece; si AGARRA al rival dentro de ese
	# rango, el presupuesto se extiende para completar el arrastre de 4 golpes
	var run_max := 500.0
	while is_instance_valid(tg) and state == "fight":
		var dt := get_process_delta_time()
		tg.position.x += float(dir) * speed * dt
		traveled += speed * dt
		if grabbed and is_instance_valid(victima) and not victima.koed:
			# ARRASTRE: el rival va pegado al frente del tigre recibiendo golpes
			victima.position.x = clampf(tg.position.x + float(dir) * 60.0, LEFT_LIMIT, RIGHT_LIMIT)
			victima.position.y = victima.floor_y
			hit_cd -= dt
			if hit_cd <= 0.0 and hits_left > 0:
				hit_cd = 0.13
				hits_left -= 1
				if idx == 0:
					dummy_hp = maxi(0, dummy_hp - 25)
				else:
					player_hp = maxi(0, player_hp - 25)
				_dmg_number(victima, 25)
				victima._burst(1.0, false, 1, true)
				victima.sprite.play("take_hit")
				victima._play_sfx_key("take_hit")
				_shake(9.0, 0.08)
			if hits_left <= 0:
				victima.receive_hit(false, false, dir, "", true, 1.0)   # remate: DERRIBA
				grabbed = false
				speed = 1800.0   # suelta a la presa y sigue un TOQUE más antes de esfumarse
				run_max = traveled + 240.0
		elif not grabbed and hits_left == 4 and is_instance_valid(victima) and not victima.koed \
				and absf(victima.position.x - tg.position.x) < 140.0 \
				and (not victima.airborne or (victima.floor_y - victima.position.y) < 260.0):
			var res: String = victima.receive_hit(false, false, dir, "kick_impact")
			if res == "blocked" or res == "armored" or res == "ignored":
				break   # la guardia deshace al tigre
			victima.airborne = false
			victima.hit_flying = false
			victima.vel_x = 0.0
			victima.vel_y = 0.0
			grabbed = true
			hit_cd = 0.05
			speed = 1050.0   # frena un poco mientras lo maulea (se leen los golpes)
			run_max = traveled + 900.0   # presupuesto extra para el arrastre completo
		if tg.position.x < LEFT_LIMIT - 240.0 or tg.position.x > RIGHT_LIMIT + 240.0 \
				or (not grabbed and traveled > run_max):
			break
		await get_tree().process_frame
	if is_instance_valid(tg):
		tg.play("out")   # se DISUELVE en energía blanca (frames reales del clip)
		await get_tree().create_timer(0.5).timeout
		tg.queue_free()
	_fe_tiger_active = false
	var murio: bool = (dummy_hp <= 0) if idx == 0 else (player_hp <= 0)
	if murio and _round_real():
		_end_round(idx == 0)

# ============================================================================
#  IMPACTO estilo 2XKO (PRUEBA — fácil de revertir: poné IMPACT_2XKO=false o borrá
#  esta función + su única llamada en _process_attacker). Estrella cómic + líneas
#  de impacto radiales + anillo de choque DE MEDIO LADO (elipse ladeada), colores HDR.
# ============================================================================
const IMPACT_2XKO := false
func _burst_star_pts(n: int) -> PackedVector2Array:
	# estrella de n puntas, radio exterior variando (jagged/filoso tipo tinta), unitaria
	var pts := PackedVector2Array()
	for i in n * 2:
		var ang := TAU * float(i) / float(n * 2) - PI * 0.5
		var outer: bool = (i % 2) == 0
		var r: float = (0.82 + 0.18 * absf(sin(float(i) * 2.3))) if outer else 0.40
		pts.append(Vector2(cos(ang), sin(ang)) * r)
	return pts
func _scale_pts(pts: PackedVector2Array, s: float) -> PackedVector2Array:
	var o := PackedVector2Array()
	for p in pts:
		o.append(p * s)
	return o
func _impact_2xko(pos: Vector2, sz: float, tint: Color) -> void:
	var cont := Node2D.new()
	cont.position = pos
	cont.z_index = 26
	add_child(cont)
	var star_unit := _burst_star_pts(11)
	var outline := Polygon2D.new()
	outline.color = tint                                  # borde de COLOR (HDR → bloom)
	cont.add_child(outline)
	var core := Polygon2D.new()
	core.color = Color(3.0, 3.0, 3.2)                     # relleno BLANCO HDR
	cont.add_child(core)
	# líneas de impacto radiales (spokes)
	var lines: Array = []
	for i in 8:
		var ln := Line2D.new()
		ln.width = sz * 0.07
		ln.default_color = tint
		ln.begin_cap_mode = Line2D.LINE_CAP_ROUND
		ln.end_cap_mode = Line2D.LINE_CAP_ROUND
		cont.add_child(ln)
		lines.append(ln)
	# anillo de choque DE MEDIO LADO (elipse achatada en Y + ladeada), no círculo de frente
	var ring := Line2D.new()
	ring.width = sz * 0.055
	ring.default_color = tint
	ring.closed = true
	cont.add_child(ring)
	var ring_tilt := -0.45                                 # ladeo del anillo
	var t := 0.0
	var life := 0.17
	while t < life and is_instance_valid(cont):
		t += get_process_delta_time()
		var k: float = clampf(t / life, 0.0, 1.0)
		var pop: float = 0.55 + _ease_out_cubic(clampf(k * 2.2, 0.0, 1.0)) * 0.75   # POP rápido
		var a: float = clampf(1.0 - k, 0.0, 1.0)
		outline.polygon = _scale_pts(star_unit, sz * 1.16 * pop)
		outline.self_modulate.a = a
		core.polygon = _scale_pts(star_unit, sz * 0.90 * pop)
		core.self_modulate.a = clampf(1.0 - k * 1.7, 0.0, 1.0)   # el blanco se va antes
		for i in lines.size():
			var ln: Line2D = lines[i]
			var ang := TAU * float(i) / float(lines.size()) + 0.19
			var d := Vector2(cos(ang), sin(ang))
			ln.points = PackedVector2Array([d * sz * (0.85 + k * 0.7), d * sz * (1.25 + _ease_out_cubic(k) * 1.6)])
			ln.self_modulate.a = a
		# anillo: elipse ACHATADA (Y*0.5) y LADEADA (rotada) = se ve de medio lado
		var rr: float = sz * (0.7 + _ease_out_cubic(k) * 2.1)
		var rp := PackedVector2Array()
		for j in 33:
			var aa := TAU * float(j) / 32.0
			var e := Vector2(cos(aa) * rr, sin(aa) * rr * 0.5)      # achatada en Y (de medio lado)
			rp.append(e.rotated(ring_tilt))                        # ladeada
		ring.points = rp
		ring.self_modulate.a = clampf(1.0 - k * 1.15, 0.0, 1.0)
		await get_tree().process_frame
	if is_instance_valid(cont):
		cont.queue_free()

# color del impacto según el ATACANTE (para que el burst combine con su energía)
func _impact_tint(att: Node2D) -> Color:
	if att.fx_blue:
		return Color(0.5, 1.5, 3.2)          # Fe: azul
	if att.fx_floral:
		return Color(1.7, 0.5, 2.8)          # Aye: morado
	if att.fx_dark:
		return Color(1.3, 0.4, 2.7)          # Zetma: morado-oscuro
	if att.archetype == "warrior":
		return Color(2.6, 0.35, 0.3)         # Roum: carmesí
	return Color(2.6, 1.4, 0.25)             # DAM/def: naranja-dorado

# ---- NÚMEROS DE DAÑO: "-20" ROJO flotando sobre el golpeado en CADA impacto ----
func _dmg_number(victima: Node2D, dmg: int, grande := false) -> void:
	# grande = CRÍTICO de Fe (-300): número mucho más gordo, brillante y sube más
	if dmg <= 0 or not is_instance_valid(victima):
		return
	var l := Label.new()
	l.text = "-%d" % dmg
	if combo_font != null:
		l.add_theme_font_override("font", combo_font)
	l.add_theme_font_size_override("font_size", 92 if grande else 46)
	l.add_theme_color_override("font_color", Color(1.9, 0.32, 0.2) if grande else Color(1.0, 0.24, 0.18))
	l.add_theme_color_override("font_outline_color", Color(0.10, 0.0, 0.0, 0.92))
	l.add_theme_constant_override("outline_size", 18 if grande else 12)
	l.z_index = 30
	l.position = Vector2(victima.position.x + randf_range(-55.0, 25.0), victima.position.y + 40.0)
	add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", l.position.y - (215.0 if grande else 140.0), 0.7 if grande else 0.6).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.5 if grande else 0.45).set_delay(0.3 if grande else 0.2)
	tw.tween_callback(l.queue_free)

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
	if String(atk["name"]) in ["air_jab", "air_jab_2"] and not att.fx_blue and not att.fx_dark \
			and not (def.airborne and (def.floor_y - def.position.y) > 40.0):
		return done
	# el JUMP Q de DAM (estocada horizontal): la espada va a SU altura en el aire ->
	# AIRE-A-AIRE, no le pega a un rival PARADO en el suelo desde el cielo
	if String(atk["name"]) == "jump_punch" and att.airborne \
			and not att.fx_blue and not att.fx_floral \
			and not (def.airborne and (def.floor_y - def.position.y) > 40.0):
		return done
	# el MOLINETE de DAM (salto+W): ANTES era aire-a-aire PURO; ahora "depende la
	# situación" (pedido): si pasa BAJITO sobre un rival parado, la espada girando SÍ
	# lo toca — lo decide la banda vertical de contacto real de más abajo (|Δy| ≤ 360):
	# desde lo alto del salto sigue sin pegar al suelo, pegado al cuerpo sí.
	# los golpes BAJOS raspan el piso: fallan contra un rival en el aire
	if bool(atk.get("low", false)) and def.airborne \
			and (def.floor_y - def.position.y) > 40.0:
		return done
	var dx: float = def.position.x - att.position.x
	# DIRECCIONAL: un golpe pega hacia donde MIRA el atacante, NO de espaldas (al saltar
	# POR ENCIMA del rival el golpe registraba ya pasado, con el arma apuntando al lado
	# contrario = hit fantasma). Cuerpos ENCIMADOS (<60px) cuentan como contacto. Los
	# giros CIRCULARES (peonza de Fe, molinete de DAM) sí barren ambos lados.
	var circular: bool = String(atk["name"]) in ["spin_kick", "spin_kick_2", "jump_kick_h2", "jump_kick_h3"] \
			or (String(atk["name"]) == "jump_kick" and not att.fx_blue and not att.fx_floral)
	if not circular and absf(dx) > 60.0 and int(signf(dx)) != att.facing:
		if String(atk["name"]) in ["air_spin_kick", "ember_dash"]:
			return ""   # los que VIAJAN siguen probando (el rival puede quedar delante)
		return done
	# el ALCANCE (y el margen) escalan con la ALTURA REAL del cuerpo del atacante (body_k:
	# DAM 1.0, Fe 0.71, Aye 0.65). ANTES escalaba por base_scale — y Fe renderiza a escala
	# 1.0 con un CUERPO chico: TODOS sus golpes registraban ~30% más allá de la punta del
	# arte ("hits fantasma"). AUDITADO contra los frames horneados: con body_k el alcance
	# máximo (reach+margen) cae exactamente en la punta del pie/aguja de cada golpe.
	# DAM queda idéntico; Aye ya calzaba (su base_scale 0.655 ≈ su cuerpo real 0.65).
	var reach: float = float(atk["reach"]) * att.body_k
	if absf(dx) > reach + HIT_MARGIN * att.body_k + def.body_halfw:   # + ancho del RIVAL: el golpe llega a su BORDE, no a su centro (antes había que estar "extra pegado")
		# la giratoria y el dash viajan: si aun no alcanza, sigue intentando cada frame
		if String(atk["name"]) in ["spin_kick", "air_spin_kick", "ember_dash"]:
			return ""
		# ROUM: sus golpes pesados SOSTIENEN la extensión varios frames → reintenta el alcance durante
		# su VENTANA ACTIVA (no solo en hit_frame), así deja de "a veces da a veces no".
		if int(atk["frame"]) < int(atk["hit_frame"]) + 6:   # TODOS: reintenta el alcance su VENTANA ACTIVA (unos frames tras hit_frame), no solo en 1 frame → no "a veces sí a veces no"
			return ""
		return done
	# alcance vertical: si alguien esta en el aire, lo que importa es la
	# distancia REAL entre los cuerpos (la giratoria se eleva y eso cuenta)
	var alcanza := true
	if att.airborne or def.airborne:
		# las giratorias barren mas banda vertical (el mortal cubre todo el giro)
		var v_max := 420.0 if String(atk["name"]) in ["spin_kick", "air_spin_kick"] else 360.0
		# salto+E de Fe: pega donde LLEGA EL PIE (contacto real, no desde media pantalla)
		if String(atk["name"]) == "air_spin_kick" and att.fx_blue:
			v_max = 420.0   # (x body_k abajo -> ~300 real)
		# EN EL SUELO no se alcanza a un rival ALTO en el aire (no pegar desde abajo al aire
		# vacío): sólo llega a un rival BAJO, recién lanzado. Los LANZADORES (giratoria /
		# crouch_kick / patada alta de Fe) llegan un poco más para poder encadenar el juggle.
		if not att.airborne and def.airborne \
				and (def.floor_y - def.position.y) > 60.0:
			# PATADAS POGO de DAM (R): la bota patea ALTO — recoge al rival en TODO el
			# rebote (con 150 las patadas 2 y 3 pasaban por DEBAJO del que iba subiendo)
			if String(atk["name"]).begins_with("weak_punch") and not att.fx_blue and not att.fx_floral:
				v_max = 480.0
			else:
				v_max = 400.0 if ((att.fx_warrior and String(atk["name"]) in ["punch", "kick", "spin_kick"]) or (att.fx_dark and String(atk["name"]) == "kick")) else (250.0 if String(atk["name"]) in ["spin_kick", "crouch_kick", "kick_h2"] else 150.0)   # ROUM Q/W/E y ZETMA W (patada alta) = anti-aéreos → alcanzan al rival que CAE
		# la banda vertical escala por el cuerpo MÁS GRANDE de los dos (body_k: DAM 1.0,
		# Fe 0.71, Aye 0.65): a un modelo GRANDE le pegás donde su cuerpo llega (Fe en el
		# aire SÍ alcanza la cabeza de DAM parado — su centro queda lejos porque él es
		# alto, pero el contacto es real); a un modelo BAJITO solo si estás cerca.
		alcanza = absf(att.position.y - def.position.y) <= v_max * maxf(att.body_k, def.body_k)
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
	var result: String = def.receive_hit(bool(atk["low"]), bool(atk.get("strong", false)), push, String(atk.get("impact_sfx", "")), bool(atk.get("trip", false)), float(atk.get("launch_mult", 1.0)), bool(atk.get("wall_launch", false)), false, bool(atk.get("freeze", false)), float(atk.get("shove", 0.0)), bool(atk.get("bounce", false)))
	# lanzador VERTICAL (patadas POGO de DAM): sube RECTO, sin empuje lateral — la
	# siguiente patada lo recoge exactamente donde cayo
	if result == "launched" and bool(atk.get("vertical", false)):
		def.vel_x = 0.0
		# tope de ALTURA del pogo: rebote a la altura del PECHO, atrapable por la
		# siguiente patada (sin tope salia disparado hasta el techo de la pantalla)
		def.vel_y = maxf(def.vel_y, -950.0)
	# PUSHBACK del GIRO (E): cada golpe EMPUJA al rival — tras 2-3 E seguidos queda FUERA
	# de alcance y el "combo infinito con una tecla" se corta solo (blockstring estilo SF).
	# En la ESQUINA no se puede empujar a la victima: se empuja al ATACANTE (regla clasica).
	if result in ["hit", "blocked"] and not def.airborne \
			and (String(atk["name"]) == "spin_kick_2" or (att.fx_dark and String(atk["name"]) == "spin_kick")):
		var _pp: float = float(1 if dx >= 0.0 else -1) * 130.0
		if def.position.x <= 121.0 or def.position.x >= 1799.0:
			att.position.x = clampf(att.position.x - _pp, 120.0, 1800.0)
		else:
			def.position.x = clampf(def.position.x + _pp, 120.0, 1800.0)
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
		_dmg_number(def, chip)
		if att_is_player:
			dummy_hp = maxi(1, dummy_hp - chip)
		else:
			player_hp = maxi(1, player_hp - chip)
		_shake(6.0, 0.08)
	if result == "hit" or result == "launched" or result == "frozen":
		# golpe AÉREO con separación vertical: reubica la CHISPA a la altura del ARMA del
		# atacante (no en el pecho del defensor) — el impacto se ve pegado a la espada/aguja
		if att.airborne and absf(att.position.y - def.position.y) > 80.0:
			def._burst(1.0, false, 1, att.fx_blue, clampf(att.position.y - def.position.y, -300.0 * att.body_k, 60.0))
		# HITSTOP: ambos se CONGELAN unos frames en el impacto (peso + pausa entre golpes,
		# como los juegos pro). La duración escala con el PESO del golpe: jab ligero =
		# congelamiento corto y ágil; golpe fuerte / lanzador = largo y con más impacto. El
		# atacante congela un pelín MENOS que la víctima (el que pega recupera antes y se
		# siente el control), técnica clásica de fighting games.
		var strong := bool(atk.get("strong", false))
		var dmg := float(atk.get("damage", 50))
		# IMPACTO estilo 2XKO (PRUEBA — quitar esta llamada o poner IMPACT_2XKO=false para revertir):
		# sólo en golpes FUERTES / lanzadores / súpers (los jabs livianos quedan con la chispa normal)
		if IMPACT_2XKO and (strong or dmg >= 55.0 or result == "launched"):
			var _big: float = 1.35 if (result == "launched" or dmg >= 90.0) else 1.0
			var _hp := Vector2((att.position.x + def.position.x) * 0.5, def.position.y + 150.0 * def.base_scale.y)
			_impact_2xko(_hp, 120.0 * _big * def.base_scale.y, _impact_tint(att))
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
			att.air_float_t = 0.36
			att.air_move_used = false
			# REBOTE DEL IMPACTO: al conectar, el golpe lo IMPULSA un poco hacia ARRIBA
			# (no sigue cayendo): esa altura extra es la que deja ENCADENAR el próximo aéreo
			att.vel_y = minf(att.vel_y, -700.0 * att.CHAR_SCALE)
		var hidx := 0 if att_is_player else 1
		# CRÍTICO de Fe: con 3 MARCAS en el rival, este golpe físico revienta 300 FIJO
		var fe_crit: bool = att.fx_blue and fe_marks[hidx] >= FE_MARK_MAX
		var dmg_real: int = _combo_hit(hidx, int(atk["damage"]),
				String(atk["name"]), att.airborne or def.airborne)
		if fe_crit:
			combo_dmg[hidx] += FE_CRIT_DMG - dmg_real   # el DMG del combo cuenta el crítico real
			combo_dmg_lbl[hidx].text = "DMG  %d" % combo_dmg[hidx]
			dmg_real = FE_CRIT_DMG                      # fijo: sin escalado anti-infinito
			fe_marks[hidx] = 0
			fe_mark_decay[hidx] = FE_MARK_DECAY
			def.set_fe_marks(0)
			# el crítico VACÍA el INSTINTO: a recargar con tiempo antes de volver a marcar
			mana[hidx] = 0.0
			mana_was_full[hidx] = false
			# CINE del CRÍTICO: banner "CRITICAL" (banda roja estilo READY/FIGHT) + los frames se
			# CONGELAN mientras la banda está en pantalla; al IRSE la banda se REANUDAN las animaciones.
			# La banda usa reloj REAL, así que anima aunque Engine.time_scale sea 0.
			# SIN flash rojo de pantalla: la banda "CRITICAL" se lee LIMPIA, igual que READY/FIGHT
			# del inicio de round (el flash rojo lavaba la banda roja y se veía distinta).
			_show_round_band("CRITICAL", 0.95)
			Engine.time_scale = 0.0
			get_tree().create_timer(0.72, true, false, true).timeout.connect(
				func() -> void: Engine.time_scale = 0.35)   # cola breve de cámara lenta
			get_tree().create_timer(0.95, true, false, true).timeout.connect(
				func() -> void: Engine.time_scale = 1.0)     # se reanuda justo al irse la banda
		_dmg_number(def, dmg_real, fe_crit)
		# temblorcito por cada golpe conectado (el crítico sacude FUERTE)
		_shake(14.0 if fe_crit else clampf(4.0 + float(combo_n[hidx]) * 0.7, 4.0, 13.0), 0.16 if fe_crit else 0.08)
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
				if _round_real():
					_end_round(true)
				else:
					dummy_hp = hp_max[1]  # munieco de practica / drill: se reinicia, no muere
		else:
			player_hp = maxi(0, player_hp - dmg_real)
			if player_hp <= 0:
				if _round_real():
					_end_round(false)
				else:
					player_hp = hp_max[0]
	return done

# ¿la ronda se juega DE VERDAD (alguien puede morir y hay contador)? VS CPU o VS 2P;
# en práctica libre / break practice la vida se resetea y el timer no corre.
func _round_real() -> bool:
	return (dummy_ai_mode or versus_2p) and not break_practice

# TIME OVER: se acabó el contador — gana el que tenga MÁS VIDA (proporcional a su barra;
# empate exacto: ronda para P1, caso rarísimo)
# marcadores P1 (rojo) / P2 (azul) sobre cada peleador al arrancar el round (solo VS 2P):
# siguen al personaje unos segundos y se desvanecen para no estorbar la pelea
func _show_player_tags() -> void:
	if not versus_2p:
		return
	if tag_p1 == null:
		tag_p1 = _mk_player_tag("P1", Color(0.95, 0.24, 0.20))
		tag_p2 = _mk_player_tag("P2", Color(0.30, 0.58, 1.0))
	tag_t = TAG_TIME
	tag_p1.visible = true
	tag_p2.visible = true

func _mk_player_tag(txt: String, col: Color) -> Label:
	var l := Label.new()
	l.text = txt + "\n▼"
	l.add_theme_font_size_override("font_size", 42)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 12)
	l.size = Vector2(120, 100)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.z_index = 60
	l.visible = false
	$UI.add_child(l)
	return l

func _update_player_tags(delta: float) -> void:
	if tag_t <= 0.0 or tag_p1 == null:
		return
	tag_t = maxf(0.0, tag_t - delta)
	var a := clampf(tag_t / 0.8, 0.0, 1.0)   # el último 0.8 s se desvanece
	var pares := [[tag_p1, player], [tag_p2, dummy]]
	for par in pares:
		var l: Label = par[0]
		var f: Node2D = par[1]
		# justo sobre la cabeza (los pies están en position.y): debajo del HUD de arriba
		l.position = Vector2(f.position.x - 60.0, clampf(f.position.y - 500.0, 130.0, 1000.0))
		l.modulate.a = a
	if tag_t <= 0.0:
		tag_p1.visible = false
		tag_p2.visible = false

func _time_over() -> void:
	if state != "fight":
		return
	var f1 := float(player_hp) / maxf(1.0, float(hp_max[0]))
	var f2 := float(dummy_hp) / maxf(1.0, float(hp_max[1]))
	_end_round(f1 >= f2)

func _end_round(player_won: bool) -> void:
	if state != "fight":
		return
	state = "round_end"
	_set_inputs(false)
	dummy.ai_enabled = false
	announce.visible = false
	_rage_end(0)   # el BERSERK muere con la ronda (la rabia restante se conserva)
	_rage_end(1)
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
	if _void_ko:
		# VOID LAUNCH de Zetma: el perdedor YA se fue de la pantalla (hundido tras el piso).
		# NO lo revivimos ni animamos su K.O. de suelo — directo al remate/tally.
		_void_ko = false
		ko_lines.modulate = Color(1.7, 0.28, 0.28, 0.0)
	else:
		loser.die_ko()
		ko_lines.modulate = Color(1.7, 0.28, 0.28, 0.0)         # líneas rojas (DETRÁS de players)
		if aerial:
			# SUBE hasta cerca del ápice (rojo tenue, aún SIN K.O.)
			var ps := Time.get_ticks_msec()
			while (loser.airborne or loser.hit_flying) and loser.vel_y < -100.0 and Time.get_ticks_msec() - ps < 600:
				ko_red.color.a = 0.35
				await get_tree().process_frame
		else:
			# muerte parada: deja correr la caída de espaldas COMPLETA hasta quedar TENDIDO
			# (el desplome v2 dura ~1.7s; antes se cortaba a los 750ms — espera dinámica)
			var gs := Time.get_ticks_msec()
			while String(loser.sprite.animation) == "ko" and loser.sprite.is_playing() \
					and Time.get_ticks_msec() - gs < 2400:
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
	elif winner.fx_dark:       # ZETMA
		win_tex = "res://imagen-action/zetma/cutin/zetma-cutin.png"
	elif winner.fx_warrior:    # ROUM: aún sin cut-in propio -> usa su pose de select (pulgar arriba, cuerpo entero)
		win_tex = "res://imagen-action/roum/select/anim/roum-select-78.png"
	if ResourceLoader.exists(win_tex):
		win_portrait.texture = load(win_tex)
	var win_name := "AYE" if winner.fx_floral else ("FE" if winner.fx_blue else ("ZETMA" if winner.fx_dark else ("ROUM" if winner.fx_warrior else "DAM")))
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
	win_portrait.move_to_front()   # por ENCIMA del cartel "X WINS" (mismo z: manda el orden)
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
		# GANÓ EL COMBATE: banda VICTORY estilo READY/FIGHT (entra por la izq, sale por la der)
		# + voz sintetizada (voz-victory.wav si existe, misma fórmula que inferno/apocalypse).
		_show_round_band("VICTORY", 2.6)
		_play_voz("victory")
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
