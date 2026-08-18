extends Control
# PANTALLA DE SELECCIÓN DE PERSONAJE — estilo GG STRIVE (pedido con referencia):
# personajes ANIMADOS a cuerpo completo a los lados (frames de video sin fondo verde),
# panel diagonal ROJO (P1) / MORADO (P2), logo del juego AL CENTRO, placas de nombre
# estilo VERSUS y la fila del roster ABAJO al centro. La lógica no cambió:
# VS 2P = selección simultánea; otros modos = P1 y luego el rival; después SELECT STAGE.

var roster: Array = []
var picking := 0            # 0 = eligiendo 1P, 1 = eligiendo 2P (en VS 2P: 0 = AMBOS a la vez)
# VS 2P: selección SIMULTÁNEA — cada jugador confirma el suyo; con los dos listos -> stage
var locked1 := false
var locked2 := false
var sel1 := 0
var sel2 := 1
var t := 0.0

var big_font: SystemFont    # fuente pesada del juego (la del combo)
var fx: Control             # capa de cursores/glow (encima de las cartas)
var cards := []             # [{x, y, w, h, av}]
var appear_l := 0.0         # animación de aparición del personaje P1 (0→1 al hacer hover)
var appear_r := 0.0
var _sel_flash := [0.0, 0.0]   # flash de SELECCIÓN por lado (1→0): una sola vez al elegir
var shown1 := -1            # último personaje mostrado en el lado P1 (para detectar hover)
var shown2 := -1
var name_l: Label
var name_r: Label
var data_l: Label
var data_r: Label
var prompt: Label
# --- pantalla de carga (transición) ---
var loading := false
var load_t := 0.0
const VS_MIN_SHOW := 0.6     # tiempo mínimo que se ve la pantalla de carga (aunque cargue antes)
# PRECARGA de frames de los peleadores en VARIOS HILOS DE FONDO en paralelo (mucho más
# rápida que un solo hilo; aprovecha SSD + núcleos, y el spinner sigue fluido)
var _warm: Array = []        # rutas .png a precalentar
var _warm_threads: Array = []
const WARM_THREADS := 4      # hilos de precarga en paralelo
const WARM_SKIP := ["select", "sheets", "avatar"]   # dirs que NO son frames de pelea
# --- paso SELECT STAGE (picking == 2) — CARRUSEL ---
var sel_stage := 0
var stage_scroll := 0.0     # posición animada del carrusel (ease hacia sel_stage)
var stage_overlay: Control
var stage_fx: Control
var stage_fx_top: Control    # marcos/esquinas cortadas ENCIMA de los thumbs
var stage_clip: Control      # contenedor con clip_contents = RECORTA el carrusel al modal
var panel_fx: Control        # dibuja el rectángulo del modal (fondo + borde), SIN recorte
var stage_cards := []       # TextureRects de cada stage (se reposicionan cada frame)
# geometría del carrusel (la tarjeta CENTRAL es la elegida)
const ST_CW := 236.0        # tarjeta VERTICAL (retrato): muestra una FRANJA vertical del stage
const ST_CH := 408.0        # ~0.58:1 (alta y angosta)
const ST_CX := 960.0
const ST_CY := 344.0        # borde superior de la tarjeta central
const ST_SPACING := 250.0   # separación entre centros de tarjetas (juntas, tipo carrusel)
# MODAL: rectángulo perfecto que ENMARCA y RECORTA el carrusel. Lo que se salga por los
# lados (la tarjeta de al lado) queda OCULTO tras el modal en vez de invadir a los peleadores.
const ST_PANEL := Rect2(490.0, 194.0, 940.0, 708.0)
# --- pantalla de CARGA (logo FG FIGHTER + spinner) tras elegir stage ---
var load_overlay: Control
var load_logo: TextureRect
var load_spin: Control

# PALETA del logo: MORADO principal + blanco + rojo (sin dorado ni azul)
const RED := Color(0.95, 0.24, 0.20)
const BLU := Color(0.62, 0.40, 1.0)      # "2P": morado (antes azul)
const GOLD := Color(0.74, 0.52, 1.0)     # acento principal: morado (antes dorado)
const WHITE := Color(0.95, 0.95, 1.0)
# COLOR de cada personaje (para el flash intermitente al SELECCIONARLO): rojo/morado/azul
const CHAR_ACCENT := {
	"dam":  Color(1.10, 0.22, 0.16),   # rojo
	"favi": Color(0.32, 0.62, 1.15),   # azul (Fe)
	"aye":  Color(0.85, 0.40, 1.15),   # morado/rosa
	"zetma": Color(0.62, 0.20, 1.10),  # morado tóxico
}
const CARD_CUT := 16.0   # tamaño del corte diagonal en 2 esquinas de las cartas de retrato

# SLOTS BLOQUEADOS: peleadores que YA se muestran en la fila del roster (su avatar) pero AÚN no
# son jugables. Se dibujan en GRIS con cinta "SOON" y NO están en el roster seleccionable, así el
# cursor 1P/2P nunca cae en ellos. El avatar (roum-face) es el mismo formato de la barra de vida.
const LOCKED_SLOTS := [
	{"name": "ROUM", "avatar": "res://imagen-action/Roum/roum-face.png"},
]

# polígono de una carta con las esquinas SUP-IZQ e INF-DER cortadas en diagonal (look angular
# que combina con las cuñas de la pantalla). `grow` lo agranda hacia afuera (para borde/glow).
func _card_poly(x: float, y: float, w: float, h: float, grow: float) -> PackedVector2Array:
	var k := CARD_CUT
	var xa := x - grow; var ya := y - grow
	var xb := x + w + grow; var yb := y + h + grow
	return PackedVector2Array([
		Vector2(xa + k, ya), Vector2(xb, ya), Vector2(xb, yb - k),
		Vector2(xb - k, yb), Vector2(xa, yb), Vector2(xa, ya + k),
	])

# --- personajes ANIMADOS a los lados (frames del video select-*.mp4 sin fondo) ---
# Los que aún no tienen video caen a su retrato "stand" recortado (estático).
const SEL_ANIM := {
	"dam":  {"dir": "res://imagen-action/dam/select/anim",  "prefix": "dam-select", "n": 145, "fps": 24.0},
	"favi": {"dir": "res://imagen-action/favi/select/anim", "prefix": "fe-select",  "n": 145, "fps": 24.0},
	"aye":  {"dir": "res://imagen-action/aye/select/anim",  "prefix": "aye-select", "n": 145, "fps": 24.0},
	"zetma": {"dir": "res://imagen-action/zetma/select/anim", "prefix": "zetma-select", "n": 145, "fps": 24.0},
}
const CHAR_H := 830.0        # altura del MÁS ALTO (DAM adulto); los demás por body_k
const FEET_Y := 895.0        # línea de piso visual (los pies quedan sobre la banda inferior)
const CX_L := 340.0          # centro X del personaje P1
const CX_R := 1580.0         # centro X del personaje P2
# ESTATURA REAL de cada quien (= body_k del juego): DAM adulto 1.0, Fe ~10 años 0.71,
# Aye ~5 años 0.65. Escala la altura en pantalla para respetar quién es más alto.
const SIDE_BODY_K := {"dam": 1.0, "favi": 0.71, "aye": 0.65, "zetma": 0.85}   # Zetma un poco más bajo/chico que DAM (su pose de select es agachada y se ve grande)
var side_spr: Array = [null, null]    # AnimatedSprite2D por lado
var sel_frames := {}                  # id -> SpriteFrames COMPLETO (todos los frames, para el gesto al SELECCIONAR)
var sel_frames_lite := {}             # id -> SpriteFrames de 1 SOLO frame (pose), para el HOVER (instantáneo)
# precarga en HILO de los frames de select de TODOS los personajes: sin esto, la 1ª vez que
# el cursor cae en un personaje se cargaban sus 145 frames de golpe y el cursor se "trababa".
var _sel_warm_thread: Thread = null
var _sel_warm_cache: Array = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	Sel.play_menu_music()   # sigue la canción del menú (NO se reinicia: ya venía del título)
	_sfx_sel = AudioStreamPlayer.new()
	add_child(_sfx_sel)
	_voz_name = AudioStreamPlayer.new()
	_voz_name.volume_db = 2.0
	add_child(_voz_name)
	roster = Sel.ROSTER
	sel2 = 1 % roster.size()
	big_font = SystemFont.new()
	big_font.font_names = PackedStringArray(["Arial Black", "Impact", "Helvetica Neue", "Arial"])
	big_font.font_weight = 900
	# ---- PERSONAJES GRANDES a los lados (animados, estilo GG Strive) ----
	for s in 2:
		var spr := AnimatedSprite2D.new()
		spr.centered = true
		spr.flip_h = (s == 1)   # P2 mira hacia P1
		# la animación se reproduce UNA vez al posarse (hover) y se queda en la pose final
		add_child(spr)
		side_spr[s] = spr
	# ---- CARTAS del roster (fila ABAJO al centro, estilo GG) — más chicas y con esquinas
	# cortadas en diagonal (combinan con las cuñas diagonales de la pantalla) ----
	# la fila incluye el roster jugable + los slots BLOQUEADOS (Roum) al final -> centrada con todos
	var n := roster.size() + LOCKED_SLOTS.size()
	var cw := 90.0
	var ch := 112.0
	var gap := 16.0
	var total := n * cw + (n - 1) * gap
	var x0 := 960.0 - total / 2.0
	var gy := 930.0
	for i in n:
		var cx := x0 + i * (cw + gap)
		var lk := i - roster.size()          # >= 0 -> es un slot BLOQUEADO (no jugable)
		var av := TextureRect.new()
		var apath := String(LOCKED_SLOTS[lk]["avatar"]) if lk >= 0 else String(roster[i]["avatar"])
		if ResourceLoader.exists(apath):
			av.texture = load(apath)
		av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		av.position = Vector2(cx + 5, gy + 5); av.size = Vector2(cw - 10, ch - 10)
		av.clip_contents = true
		av.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if lk >= 0:
			av.modulate = Color(0.42, 0.42, 0.48, 1.0)   # gris apagado: aún no jugable
		add_child(av)
		cards.append({"x": cx, "y": gy, "w": cw, "h": ch, "av": av, "locked": lk >= 0})
	# ---- CAPA FX (cursores + glow, encima de las cartas) ----
	fx = Control.new()
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fx)
	fx.draw.connect(_draw_fx)
	# ---- TEXTOS (encima de todo) ----
	# LOGO del juego AL CENTRO (el "título en el medio" del pedido)
	var logo := TextureRect.new()
	if ResourceLoader.exists("res://imagen-action/ui/title-logo.png"):
		logo.texture = load("res://imagen-action/ui/title-logo.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	logo.size = Vector2(470, 262); logo.position = Vector2(960 - 235, 14)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo)
	_hdr("1P", Vector2(34, 18), RED, HORIZONTAL_ALIGNMENT_LEFT, 34)
	_hdr("2P", Vector2(-34, 18), BLU, HORIZONTAL_ALIGNMENT_RIGHT, 34)
	# nombres grandes sobre las PLACAS de color (estilo GG: texto blanco sobre placa)
	name_l = _big_name(true)
	name_r = _big_name(false)
	# character data — bajo la placa de cada lado
	data_l = _data_label(Vector2(64, 884))
	data_r = _data_label(Vector2(1456, 884))
	data_r.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# prompt (ayuda de controles) — centrado bajo el logo
	prompt = Label.new()
	prompt.add_theme_font_override("font", big_font)
	prompt.add_theme_font_size_override("font_size", 24)
	prompt.add_theme_constant_override("outline_size", 6)
	prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	prompt.add_theme_color_override("font_color", GOLD)
	prompt.position = Vector2(0, 286); prompt.size = Vector2(1920, 40)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(prompt)
	_build_loading_overlay()
	_build_stage_overlay()
	_refresh()
	# precalienta en segundo plano los frames de select de todos los personajes (cursor fluido)
	_sel_warm_thread = Thread.new()
	_sel_warm_thread.start(_sel_warm_worker)

# HILO: carga (disco+import) todas las texturas de select de todos los personajes y las
# devuelve; así _frames_for las encuentra en caché y no traba el cursor al pasar por uno nuevo.
func _exit_tree() -> void:
	# une el hilo de precalentado antes de destruir el nodo (evita "Thread destroyed" al salir)
	if _sel_warm_thread != null:
		_sel_warm_thread.wait_to_finish()
		_sel_warm_thread = null

func _sel_warm_worker() -> Array:
	var res := []
	for id in SEL_ANIM:
		var cfg: Dictionary = SEL_ANIM[id]
		for i in range(1, int(cfg["n"]) + 1):
			var p := "%s/%s-%d.png" % [String(cfg["dir"]), String(cfg["prefix"]), i]
			if ResourceLoader.exists(p):
				var tex = ResourceLoader.load(p)
				if tex != null:
					res.append(tex)
	return res

# ---------- personajes animados ----------
# SpriteFrames del personaje: TODOS los frames del video a su FPS (regla: no submuestrear);
# si no tiene video aún, un solo frame con su retrato de pie recortado.
func _frames_for(id: String) -> SpriteFrames:
	if sel_frames.has(id):
		return sel_frames[id]
	var sf := SpriteFrames.new()
	sf.add_animation("idle")
	sf.set_animation_loop("idle", false)   # se reproduce UNA vez y queda en la pose final
	if SEL_ANIM.has(id):
		var cfg: Dictionary = SEL_ANIM[id]
		sf.set_animation_speed("idle", float(cfg["fps"]))
		for i in range(1, int(cfg["n"]) + 1):
			var p := "%s/%s-%d.png" % [String(cfg["dir"]), String(cfg["prefix"]), i]
			if ResourceLoader.exists(p):
				sf.add_frame("idle", load(p))
	else:
		sf.set_animation_speed("idle", 1.0)
		var c := Sel.data(id)
		for k in ["stand", "stand_fallback"]:
			var p2 := String(c.get(k, ""))
			if ResourceLoader.exists(p2):
				sf.add_frame("idle", load(p2))
				break
	sel_frames[id] = sf
	return sf

# HOVER: SpriteFrames de UN SOLO frame (la pose neutra). En hover el personaje se muestra
# CONGELADO en el frame 0 (speed_scale=0), así que NO hay que cargar los ~145 frames del gesto
# —eso trababa el cursor al pasar a un personaje aún no precalentado (p.ej. Zetma)—. El set
# completo se construye recién al SELECCIONAR, en _play_anim. El frame 0 es el MISMO png que en
# el set completo, así que la escala calculada aquí sirve igual cuando se cambie al completo.
func _frames_for_lite(id: String) -> SpriteFrames:
	if sel_frames.has(id):
		return sel_frames[id]        # si ya está el completo, úsalo (frame 0 idéntico)
	if sel_frames_lite.has(id):
		return sel_frames_lite[id]
	var sf := SpriteFrames.new()
	sf.add_animation("idle")
	sf.set_animation_loop("idle", false)
	if SEL_ANIM.has(id):
		var cfg: Dictionary = SEL_ANIM[id]
		sf.set_animation_speed("idle", float(cfg["fps"]))
		var p := "%s/%s-1.png" % [String(cfg["dir"]), String(cfg["prefix"])]
		if ResourceLoader.exists(p):
			sf.add_frame("idle", load(p))
	else:
		sf.set_animation_speed("idle", 1.0)
		var c := Sel.data(id)
		for k in ["stand", "stand_fallback"]:
			var p2 := String(c.get(k, ""))
			if ResourceLoader.exists(p2):
				sf.add_frame("idle", load(p2))
				break
	sel_frames_lite[id] = sf
	return sf

func _set_side(s: int, id: String) -> void:
	var spr: AnimatedSprite2D = side_spr[s]
	spr.sprite_frames = _frames_for_lite(id)
	# CONGELADO en el primer frame: reproduce a velocidad 0 (así SÍ se dibuja el personaje;
	# un sprite detenido con stop() no renderiza en este Godot). Hover = quieto pero VISIBLE.
	spr.speed_scale = 0.0
	spr.play("idle")
	spr.frame = 0   # pose neutral (frame 1) hasta que lo SELECCIONEN
	# altura EN PANTALLA según la estatura real (body_k): DAM alto, Fe y Aye más bajitas.
	# Pies anclados en FEET_Y, así las niñas quedan con la cabeza más abajo (centered).
	var disp_h := CHAR_H * float(SIDE_BODY_K.get(id, 1.0))
	var sc := 1.0
	if spr.sprite_frames.get_frame_count("idle") > 0:
		var tex: Texture2D = spr.sprite_frames.get_frame_texture("idle", 0)
		if tex != null and tex.get_height() > 0:
			sc = disp_h / float(tex.get_height())
	spr.scale = Vector2(sc, sc)
	spr.position = Vector2(CX_L if s == 0 else CX_R, FEET_Y - disp_h * 0.5)

# al SELECCIONAR el personaje: reproduce su animación (gesto) UNA vez desde el principio.
# La voz va con demora (SEL_DELAY) para caer con el movimiento de boca del gesto.
func _play_anim(s: int) -> void:
	var spr: AnimatedSprite2D = side_spr[s]
	if spr == null:
		return
	# recién AQUÍ (al SELECCIONAR) se construye el set COMPLETO de frames del gesto; en hover
	# solo estaba el frame 0 (lite). El frame 0 es el mismo png, así que la escala no cambia.
	var id := String(roster[sel1 if s == 0 else sel2]["id"])
	spr.sprite_frames = _frames_for(id)
	spr.speed_scale = 1.0   # velocidad normal: ejecuta el gesto UNA vez y queda en la pose
	spr.frame = 0
	spr.play("idle")
	_sel_flash[s] = 1.0     # dispara el FLASH de selección (una sola vez, se va)

func _anim_side(s: int, ap: float, dir: float, active: bool) -> void:
	var spr: AnimatedSprite2D = side_spr[s]
	if spr == null or spr.sprite_frames == null:
		return
	var e := _ease_out(ap)
	var off := (1.0 - e) * 60.0 * dir
	spr.position.x = (CX_L if s == 0 else CX_R) + off
	var dim := 1.0 if active else 0.62
	spr.modulate = Color(dim, dim, dim, e)

# ---------- PANTALLA DE CARGA (logo FG FIGHTER + spinner) ----------
func _build_loading_overlay() -> void:
	load_overlay = Control.new()
	load_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	load_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_overlay.visible = false
	load_overlay.z_index = 6                       # por ENCIMA del overlay de stage (z=4)
	add_child(load_overlay)
	# fondo oscuro opaco
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.025, 0.06, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_overlay.add_child(bg)
	# LOGO FG FIGHTER (croma ya recortado), centrado
	load_logo = TextureRect.new()
	if ResourceLoader.exists("res://imagen-action/ui/title-logo.png"):
		load_logo.texture = load("res://imagen-action/ui/title-logo.png")
	load_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	load_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	load_logo.size = Vector2(820, 458); load_logo.position = Vector2(550, 250)
	load_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_overlay.add_child(load_logo)
	# SPINNER (se dibuja girando en _update_loading)
	load_spin = Control.new()
	load_spin.set_anchors_preset(Control.PRESET_FULL_RECT)
	load_spin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_overlay.add_child(load_spin)
	load_spin.draw.connect(_draw_spinner)

func _draw_spinner() -> void:
	# spinner de puntos girando (estela que se desvanece), centrado bajo el logo
	var purple := Color(0.62, 0.35, 1.0)           # morado (a juego con el logo)
	var c := Vector2(960, 860)
	var n := 12
	var head := fmod(load_t * 2.4, 1.0)            # posición de la cabeza (0..1) girando
	for i in n:
		var f := float(i) / float(n)
		var ang := f * TAU - PI * 0.5
		# distancia angular DETRÁS de la cabeza -> más tenue cuanto más atrás (estela)
		var d := fmod(head - f + 1.0, 1.0)
		var a := 0.15 + 0.85 * d
		var pos := c + Vector2(cos(ang), sin(ang)) * 42.0
		load_spin.draw_circle(pos, 7.0, Color(purple.r, purple.g, purple.b, a))

# ---------- paso SELECT STAGE (overlay a pantalla completa) ----------
func _build_stage_overlay() -> void:
	stage_overlay = Control.new()
	stage_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.visible = false
	stage_overlay.z_index = 4
	add_child(stage_overlay)
	# EMBEBIDO: NO hay fondo a pantalla completa. Los peleadores elegidos siguen visibles a los
	# lados; el carrusel de stages aparece en el CENTRO con un panel oscuro solo detrás de él
	# El póster full-screen quedó retirado a propósito.
	# PANEL del modal: rectángulo perfecto (fondo + borde). Va PRIMERO (al fondo) y SIN recorte
	# para que el borde salga nítido; el carrusel se dibuja DENTRO del recorte (stage_clip).
	panel_fx = Control.new()
	panel_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.add_child(panel_fx)
	panel_fx.draw.connect(_draw_stage_panel)
	# título (debajo del logo FG, encima del carrusel)
	var title := Label.new()
	title.add_theme_font_override("font", big_font)
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_color_override("font_outline_color", Color(0.15, 0.0, 0.0))
	title.add_theme_color_override("font_color", GOLD)
	title.text = "SELECT STAGE"
	title.position = Vector2(0, 236); title.size = Vector2(1920, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.add_child(title)
	# RECORTE: todo el carrusel (marcos + thumbs + esquinas) vive dentro de un contenedor con
	# clip_contents anclado a ST_PANEL. Un "mundo" hijo desplazado -ST_PANEL.pos deja que el resto
	# del código siga usando coordenadas ABSOLUTAS de pantalla; el clip oculta lo que se salga
	# del modal (la tarjeta de al lado ya no invade a los peleadores).
	stage_clip = Control.new()
	stage_clip.position = ST_PANEL.position
	stage_clip.size = ST_PANEL.size
	stage_clip.clip_contents = true
	stage_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.add_child(stage_clip)
	var stage_world := Control.new()
	stage_world.position = -ST_PANEL.position
	stage_world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_clip.add_child(stage_world)
	# capa de marcos (debajo de los thumbs para que el borde asome; el arrow va encima)
	stage_fx = Control.new()
	stage_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_world.add_child(stage_fx)
	stage_fx.draw.connect(_draw_stage_fx)
	# tarjetas (thumbnails) — se reposicionan cada frame en _layout_stage_carousel().
	# El nombre de cada stage se dibuja en _draw_stage_fx (así sigue al carrusel).
	stage_cards.clear()
	for i in Sel.STAGES.size():
		var th := TextureRect.new()
		var tp := String(Sel.STAGES[i]["thumb"])
		if ResourceLoader.exists(tp):
			th.texture = load(tp)
		th.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		th.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		th.clip_contents = true
		th.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stage_world.add_child(th)
		stage_cards.append(th)
	# capa de marcos ENCIMA de los thumbs (corta las esquinas + marco angular)
	stage_fx_top = Control.new()
	stage_fx_top.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage_fx_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_world.add_child(stage_fx_top)
	stage_fx_top.draw.connect(_draw_stage_fx_top)
	# hint
	var hint := Label.new()
	hint.add_theme_font_override("font", big_font)
	hint.add_theme_font_size_override("font_size", 28)
	hint.add_theme_constant_override("outline_size", 6)
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	hint.add_theme_color_override("font_color", Color(0.85, 0.85, 0.92))
	hint.text = "← →  ELEGIR        ENTER  CONFIRM        ESC  BACK"
	hint.position = Vector2(0, 862); hint.size = Vector2(1920, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.add_child(hint)

# geometría de la tarjeta i según la posición animada del carrusel
func _stage_geom(i: int) -> Dictionary:
	var rel := float(i) - stage_scroll
	var scale := lerpf(1.0, 0.78, minf(absf(rel), 1.0))
	var w := ST_CW * scale
	var h := ST_CH * scale
	var cx := ST_CX + rel * ST_SPACING
	var center_y := ST_CY + ST_CH * 0.5
	var rect := Rect2(cx - w * 0.5, center_y - h * 0.5, w, h)
	var alpha := clampf(1.32 - absf(rel) * 0.42, 0.0, 1.0)
	return {"rect": rect, "rel": rel, "alpha": alpha}

# reposiciona/escala/atenúa las tarjetas según el scroll (llamado cada frame)
func _layout_stage_carousel() -> void:
	for i in stage_cards.size():
		var g := _stage_geom(i)
		var r: Rect2 = g["rect"]
		var al: float = g["alpha"]
		var seld := (i == sel_stage)
		var card: TextureRect = stage_cards[i]
		card.position = r.position
		card.size = r.size
		var b := 1.0 if seld else 0.85     # los no elegidos, un poco más apagados
		card.modulate = Color(b, b, b, al)
		card.visible = al > 0.02

# fondo + borde del modal (rectángulo perfecto). SIN recorte: el carrusel se dibuja dentro
# de stage_clip; este panel lo enmarca por detrás con un borde nítido.
func _draw_stage_panel() -> void:
	var p := ST_PANEL
	panel_fx.draw_rect(p, Color(0.03, 0.02, 0.06, 0.90))                              # fondo casi opaco
	panel_fx.draw_rect(p.grow(3.0), Color(GOLD.r, GOLD.g, GOLD.b, 0.85), false, 3.0)   # borde
	panel_fx.draw_rect(p.grow(9.0), Color(GOLD.r, GOLD.g, GOLD.b, 0.22), false, 2.0)   # halo fino

func _draw_stage_fx() -> void:
	for i in stage_cards.size():
		var g := _stage_geom(i)
		var al: float = g["alpha"]
		if al < 0.05:
			continue
		var r: Rect2 = g["rect"]
		var seld := (i == sel_stage)
		# nombre bajo la tarjeta
		var nm := String(Sel.STAGES[i]["name"])
		var fs := 30
		var nmw := big_font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var ncol := Color(1, 1, 1, al) if seld else Color(0.6, 0.6, 0.68, al)
		stage_fx.draw_string(big_font, Vector2(r.position.x + r.size.x * 0.5 - nmw * 0.5, r.end.y + 46.0),
				nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ncol)

# marcos + ESQUINAS CORTADAS de las tarjetas de stage (mismo estilo que las cartas del avatar),
# dibujados ENCIMA de los thumbs para tapar las esquinas rectangulares.
func _draw_stage_fx_top() -> void:
	var pulse := 0.55 + 0.45 * sin(t * 6.0)
	var cutcol := Color(0.03, 0.02, 0.06)   # color del panel, para "cortar" las esquinas del thumb
	for i in stage_cards.size():
		var g := _stage_geom(i)
		var al: float = g["alpha"]
		if al < 0.05:
			continue
		var r: Rect2 = g["rect"]
		var seld := (i == sel_stage)
		var k := 20.0   # tamaño del corte de esquina
		# tapa las 2 esquinas (sup-izq e inf-der) con triángulos del color del panel
		stage_fx_top.draw_colored_polygon(PackedVector2Array([
				r.position, Vector2(r.position.x + k, r.position.y), Vector2(r.position.x, r.position.y + k)]), cutcol)
		stage_fx_top.draw_colored_polygon(PackedVector2Array([
				r.end, Vector2(r.end.x - k, r.end.y), Vector2(r.end.x, r.end.y - k)]), cutcol)
		# marco angular (cut-corner): dorado grueso si elegido, gris fino si no
		var poly := _stage_card_poly(r, k)
		if seld:
			for j in range(4, 0, -1):
				stage_fx_top.draw_polyline(poly, Color(GOLD.r, GOLD.g, GOLD.b, 0.10 * pulse), j * 4.0)
			stage_fx_top.draw_polyline(poly, Color(GOLD.r, GOLD.g, GOLD.b, 0.95), 6.0)
			var cxm := r.position.x + r.size.x * 0.5     # flecha arriba
			stage_fx_top.draw_colored_polygon(PackedVector2Array([
					Vector2(cxm - 18, r.position.y - 34), Vector2(cxm + 18, r.position.y - 34), Vector2(cxm, r.position.y - 8)]),
					Color(GOLD.r, GOLD.g, GOLD.b, pulse))
		else:
			stage_fx_top.draw_polyline(poly, Color(0.5, 0.5, 0.58, 0.7 * al), 3.0)

# polígono CERRADO de una tarjeta de stage con esquinas SUP-IZQ e INF-DER cortadas
func _stage_card_poly(r: Rect2, k: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(r.position.x + k, r.position.y), Vector2(r.end.x, r.position.y),
		Vector2(r.end.x, r.end.y - k), Vector2(r.end.x - k, r.end.y),
		Vector2(r.position.x, r.end.y), Vector2(r.position.x, r.position.y + k),
		Vector2(r.position.x + k, r.position.y)])

func _start_loading() -> void:
	loading = true
	load_t = 0.0
	set_process_unhandled_input(false)
	# cierra el hilo de precalentado de select si aún corre (evita hilo colgando al cambiar escena)
	if _sel_warm_thread != null:
		_sel_warm_cache = _sel_warm_thread.wait_to_finish()
		_sel_warm_thread = null
	# carga la escena de pelea EN SEGUNDO PLANO (no congela la pantalla de carga)
	ResourceLoader.load_threaded_request("res://main.tscn")
	# lista de frames de los 2 peleadores a PRECALENTAR mientras gira el spinner (así main.gd
	# construye sus SpriteFrames desde caché y NO se congela al entrar al round)
	Sel.warm_cache.clear()
	_warm.clear()
	_scan_fight_pngs("res://imagen-action/%s" % Sel.p1, _warm)
	if Sel.p2 != Sel.p1:
		_scan_fight_pngs("res://imagen-action/%s" % Sel.p2, _warm)
	# reparte las rutas en VARIOS hilos que precalientan en paralelo (no bloquean el spinner)
	_warm_threads.clear()
	var total := _warm.size()
	var per := int(ceil(float(total) / float(WARM_THREADS)))
	for i in WARM_THREADS:
		var lo := i * per
		var hi: int = min(lo + per, total)
		if lo >= hi:
			break
		var th := Thread.new()
		th.start(_warm_worker.bind(_warm.slice(lo, hi)))
		_warm_threads.append(th)
	# ocultar el overlay de stage (evita que tape la carga -> ya no parece bug)
	if stage_overlay != null:
		stage_overlay.visible = false
	load_overlay.visible = true

# HILO DE FONDO: carga (disco+import) todas las texturas y las devuelve. ResourceLoader.load
# es thread-safe; el subir a GPU pasa luego en el hilo principal al usarlas (rápido por textura).
func _warm_worker(paths: Array) -> Array:
	var res := []
	for p in paths:
		var tex = ResourceLoader.load(p)
		if tex != null:
			res.append(tex)
	return res

# junta recursivamente los .png de PELEA de un personaje (omite select/sheets/avatar)
func _scan_fight_pngs(path: String, out: Array) -> void:
	var d := DirAccess.open(path)
	if d == null:
		return
	d.list_dir_begin()
	var nm := d.get_next()
	while nm != "":
		if d.current_is_dir():
			if nm != "." and nm != ".." and not (nm in WARM_SKIP):
				_scan_fight_pngs(path + "/" + nm, out)
		elif nm.ends_with(".png"):
			out.append(path + "/" + nm)
		nm = d.get_next()
	d.list_dir_end()

# ---------- construcción de nodos ----------
func _hdr(txt: String, pos: Vector2, col: Color, align: int, size: int) -> void:
	var l := Label.new()
	l.add_theme_font_override("font", big_font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_constant_override("outline_size", 6)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_color_override("font_color", col)
	l.text = txt
	if align == HORIZONTAL_ALIGNMENT_LEFT:
		l.position = Vector2(pos.x, pos.y); l.size = Vector2(700, 44)
	else:
		l.position = Vector2(1920 - 700 - 34, pos.y); l.size = Vector2(700, 44)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)

# nombres estilo GG: texto BLANCO grande sobre la placa de color (la placa la pinta _draw)
func _big_name(left: bool) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", big_font)
	l.add_theme_font_size_override("font_size", 58)
	l.add_theme_constant_override("outline_size", 8)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_color_override("font_color", WHITE)
	if left:
		l.position = Vector2(70, 794); l.size = Vector2(560, 80)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		l.position = Vector2(1290, 794); l.size = Vector2(560, 80)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _data_label(pos: Vector2) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", big_font)
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_constant_override("outline_size", 4)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_color_override("font_color", Color(0.9, 0.9, 0.94))
	l.position = pos; l.size = Vector2(400, 160)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

# FLASH intermitente detrás del personaje elegido: columna de glow del COLOR del personaje que
# parpadea (on/off), para que quede clarísimo que ESE personaje fue seleccionado.
func _sel_flash_draw(cx: float, id: String, amt: float) -> void:
	var col: Color = CHAR_ACCENT.get(id, GOLD)
	var k := clampf(amt, 0.0, 1.0)                    # 1 (recién elegido) -> 0 (se fue)
	for i in range(6, 0, -1):                        # capas anchas -> halo suave que se va
		var hw := 120.0 + i * 44.0
		draw_colored_polygon(PackedVector2Array([
				Vector2(cx - hw, 100.0), Vector2(cx + hw, 100.0),
				Vector2(cx + hw * 0.7, FEET_Y), Vector2(cx - hw * 0.7, FEET_Y)]),
				Color(col.r, col.g, col.b, 0.07 * k))
	draw_colored_polygon(PackedVector2Array([        # núcleo brillante
			Vector2(cx - 160, 120.0), Vector2(cx + 160, 120.0),
			Vector2(cx + 110, FEET_Y), Vector2(cx - 110, FEET_Y)]),
			Color(col.r, col.g, col.b, 0.22 * k))

# ---------- FONDO estilo GG STRIVE: diagonales ROJO/MORADO + placas de nombre ----------
func _draw() -> void:
	var w := 1920.0
	var h := 1080.0
	# base (morado muy oscuro)
	draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.03, 0.08))
	# actividad de cada lado (el confirmado/inactivo baja de intensidad)
	var pl_active: float = 1.0 if picking == 0 else 0.55
	var pr_active: float = 1.0 if picking == 1 else 0.55
	if _vs2p() and picking < 2:   # simultáneo: los dos vivos; el que confirmó baja un poco
		pl_active = 0.7 if locked1 else 1.0
		pr_active = 0.7 if locked2 else 1.0
	# GRAN PANEL DIAGONAL ROJO (P1, izquierda) — dos capas para profundidad
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(880, 0), Vector2(600, h), Vector2(0, h)]),
			Color(0.28, 0.045, 0.09, 0.42 + 0.30 * pl_active))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(690, 0), Vector2(470, h), Vector2(0, h)]),
			Color(0.40, 0.06, 0.11, 0.30 + 0.25 * pl_active))
	# GRAN PANEL DIAGONAL MORADO (P2, derecha)
	draw_colored_polygon(PackedVector2Array([Vector2(w, 0), Vector2(1040, 0), Vector2(1320, h), Vector2(w, h)]),
			Color(0.14, 0.06, 0.28, 0.42 + 0.30 * pr_active))
	draw_colored_polygon(PackedVector2Array([Vector2(w, 0), Vector2(1230, 0), Vector2(1450, h), Vector2(w, h)]),
			Color(0.20, 0.08, 0.38, 0.30 + 0.25 * pr_active))
	# costuras de color en la diagonal de cada panel
	draw_line(Vector2(880, 0), Vector2(600, h), Color(RED.r, RED.g, RED.b, 0.5 + 0.5 * pl_active), 5.0)
	draw_line(Vector2(1040, 0), Vector2(1320, h), Color(BLU.r, BLU.g, BLU.b, 0.5 + 0.5 * pr_active), 5.0)
	# glow radial central (morado) para que el logo respire
	for i in range(7, 0, -1):
		var r := 95.0 * i
		draw_circle(Vector2(960, 170), r, Color(0.24, 0.10, 0.34, 0.045))
	# speedlines diagonales sutiles
	for i in range(-2, 22):
		var x := i * 96.0
		draw_line(Vector2(x, 0), Vector2(x - 210, h), Color(0.62, 0.4, 0.95, 0.04), 2.0)
	# FLASH de selección detrás del personaje (color del personaje) — UNA sola vez al elegir
	if _sel_flash[0] > 0.0:
		_sel_flash_draw(CX_L, String(roster[sel1]["id"]), _sel_flash[0])
	if _sel_flash[1] > 0.0:
		_sel_flash_draw(CX_R, String(roster[sel2]["id"]), _sel_flash[1])
	# banda superior fina
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, 70), Vector2(0, 58)]), Color(0.04, 0.02, 0.06, 0.9))
	draw_line(Vector2(0, 58), Vector2(w, 70), GOLD, 3.0)
	# banda inferior (sostiene el roster, estilo GG)
	draw_colored_polygon(PackedVector2Array([Vector2(0, 902), Vector2(w, 886), Vector2(w, h), Vector2(0, h)]), Color(0.035, 0.02, 0.055, 0.94))
	draw_line(Vector2(0, 902), Vector2(w, 886), Color(0.5, 0.2, 0.7), 3.0)
	# PLACAS DE NOMBRE estilo GG (inclinadas): roja P1 / morada P2, texto blanco encima
	var apl := 0.75 + 0.25 * pl_active
	var apr := 0.75 + 0.25 * pr_active
	draw_colored_polygon(PackedVector2Array([Vector2(40, 790), Vector2(660, 782), Vector2(644, 876), Vector2(40, 884)]),
			Color(RED.r * 0.82, RED.g * 0.5, RED.b * 0.5, apl))
	draw_line(Vector2(40, 790), Vector2(660, 782), Color(1, 1, 1, 0.85 * apl), 3.0)
	draw_colored_polygon(PackedVector2Array([Vector2(1260, 782), Vector2(1880, 790), Vector2(1880, 884), Vector2(1276, 876)]),
			Color(BLU.r * 0.62, BLU.g * 0.5, BLU.b * 0.82, apr))
	draw_line(Vector2(1260, 782), Vector2(1880, 790), Color(1, 1, 1, 0.85 * apr), 3.0)
	# marco de cada carta (bisel oscuro con esquinas cortadas) — el glow/cursor va en la capa fx
	for c in cards:
		var x: float = c["x"]; var y: float = c["y"]; var cw: float = c["w"]; var chh: float = c["h"]
		draw_colored_polygon(_card_poly(x, y, cw, chh, 4.0), Color(0, 0, 0, 0.85))
		draw_colored_polygon(_card_poly(x, y, cw, chh, 0.0), Color(0.10, 0.10, 0.14))

# ---------- CURSORES + GLOW (capa fx, encima de las cartas) ----------
func _draw_fx() -> void:
	var pulse := 0.6 + 0.4 * sin(t * 7.0)
	# FLASH ENCIMA del personaje al ELEGIRLO: un fogonazo del color del personaje sobre él que
	# blinkea un instante y se va (va en la capa fx = por ENCIMA del sprite).
	for s in 2:
		if _sel_flash[s] > 0.0:
			var fid := String(roster[sel1 if s == 0 else sel2]["id"])
			var fcol: Color = CHAR_ACCENT.get(fid, GOLD)
			var fcx := CX_L if s == 0 else CX_R
			var fa := pow(_sel_flash[s], 2.2) * 0.42   # blink breve (brillante al inicio, se va)
			fx.draw_colored_polygon(PackedVector2Array([
					Vector2(fcx - 205, 95.0), Vector2(fcx + 205, 95.0),
					Vector2(fcx + 150, FEET_Y + 18.0), Vector2(fcx - 150, FEET_Y + 18.0)]),
					Color(fcol.r, fcol.g, fcol.b, fa))
	# ESQUINAS CORTADAS: los avatares son rectangulares; aquí (encima de ellos) tapo las 2
	# esquinas con triángulos oscuros para que la carta se vea con corte diagonal, y le doy a
	# TODA carta un borde angular tenue.
	var cutcol := Color(0.06, 0.04, 0.09)
	for c in cards:
		var x: float = c["x"]; var y: float = c["y"]; var cw: float = c["w"]; var chh: float = c["h"]
		var k := CARD_CUT
		fx.draw_colored_polygon(PackedVector2Array([Vector2(x, y), Vector2(x + k, y), Vector2(x, y + k)]), cutcol)
		fx.draw_colored_polygon(PackedVector2Array([Vector2(x + cw, y + chh), Vector2(x + cw - k, y + chh), Vector2(x + cw, y + chh - k)]), cutcol)
		var op := _card_poly(x, y, cw, chh, 2.0); op.append(op[0])
		fx.draw_polyline(op, Color(0.55, 0.55, 0.66, 0.5), 2.0)
		# SLOT BLOQUEADO (aún no jugable): velo oscuro + cinta "SOON" abajo
		if c.get("locked", false):
			fx.draw_colored_polygon(_card_poly(x, y, cw, chh, 0.0), Color(0.02, 0.02, 0.04, 0.5))
			fx.draw_rect(Rect2(x, y + chh - 30, cw, 22), Color(GOLD.r * 0.5, GOLD.g * 0.5, GOLD.b * 0.5, 0.92))
			var sw := big_font.get_string_size("SOON", HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
			fx.draw_string(big_font, Vector2(x + cw * 0.5 - sw * 0.5, y + chh - 13), "SOON",
					HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1, 0.95))
	var a1: bool = (not locked1) if (_vs2p() and picking < 2) else (picking == 0)
	var a2: bool = (not locked2) if (_vs2p() and picking < 2) else (picking == 1)
	_cursor(sel1, RED, "1P", a1, pulse, -1)
	_cursor(sel2, BLU, "2P", a2, pulse, 1)
	# "READY" sobre el personaje confirmado (estilo GG) — en TODOS los modos.
	# VS 2P: por locked1/locked2. VS CPU / TRAINING (flujo secuencial): P1 listo al pasar a
	# elegir el rival (picking>=1); el rival listo al confirmarlo (picking>=2 o durante la
	# pausa post-selección _advancing).
	var r1: bool = locked1 if (_vs2p() and picking < 2) else (picking >= 1)
	var r2: bool = locked2 if (_vs2p() and picking < 2) else (picking >= 2 or _advancing)
	if r1:
		_ready_plate(CX_L, RED)
	if r2:
		_ready_plate(CX_R, BLU)

func _ready_plate(cx: float, col: Color) -> void:
	var r := Rect2(cx - 130, 470, 260, 64)   # sobre el CUERPO (antes 118 = sobre la cabeza)
	fx.draw_colored_polygon(PackedVector2Array([r.position, Vector2(r.end.x + 10, r.position.y),
			Vector2(r.end.x, r.end.y), Vector2(r.position.x - 10, r.end.y)]),
			Color(col.r * 0.75, col.g * 0.55, col.b * 0.55, 0.92))
	fx.draw_string(big_font, Vector2(r.position.x + 52, r.position.y + 47), "READY",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color(1, 1, 1, 0.95))

func _cursor(idx: int, col: Color, tag: String, active: bool, pulse: float, side: int) -> void:
	if idx < 0 or idx >= cards.size():
		return
	var c: Dictionary = cards[idx]
	var x: float = c["x"]; var y: float = c["y"]; var cw: float = c["w"]; var chh: float = c["h"]
	var a := 1.0 if active else 0.7
	var gl := (pulse if active else 0.5)
	# glow exterior (esquinas cortadas)
	for k in range(4, 0, -1):
		var e := k * 4.0
		var gp := _card_poly(x, y, cw, chh, e); gp.append(gp[0])
		fx.draw_polyline(gp, Color(col.r, col.g, col.b, 0.08 * gl * a), 3.0)
	# borde grueso (esquinas cortadas)
	var bp := _card_poly(x, y, cw, chh, 4.0); bp.append(bp[0])
	fx.draw_polyline(bp, Color(col.r, col.g, col.b, a), 5.0)
	# etiqueta 1P/2P sobre una plaquita
	var tx := x - 6 if side < 0 else x + cw - 44
	fx.draw_rect(Rect2(tx, y - 40, 50, 34), Color(col.r * 0.7, col.g * 0.7, col.b * 0.7, a))
	fx.draw_rect(Rect2(tx, y - 40, 50, 34), Color(0, 0, 0, a), false, 2.0)
	fx.draw_string(big_font, Vector2(tx + 8, y - 14), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(1, 1, 1, a))

# ---------- estado ----------
func _refresh() -> void:
	var c1: Dictionary = roster[sel1]
	var c2: Dictionary = roster[sel2]
	# al cambiar de personaje (hover), reinicia la animación de aparición del lado
	if sel1 != shown1:
		shown1 = sel1
		_set_side(0, String(c1["id"]))
		appear_l = 0.0
	if sel2 != shown2:
		shown2 = sel2
		_set_side(1, String(c2["id"]))
		appear_r = 0.0
	name_l.text = String(c1["name"])
	name_r.text = String(c2["name"])
	data_l.text = "CLASS:  %s\nWEAPON: %s\nPOWER:  %s" % [c1["arch"], c1["weapon"], c1["power"]]
	data_r.text = "CLASS:  %s\nWEAPON: %s\nPOWER:  %s" % [c2["arch"], c2["weapon"], c2["power"]]
	if _vs2p() and picking < 2:
		var t1 := "1P  ✔ LISTO" if locked1 else "1P:  ← →  ENTER"
		var con_mando := Input.get_connected_joypads().size() > 0
		var t2 := "2P  ✔ LISTO" if locked2 else ("2P:  MANDO  ✚  y  A" if con_mando else "2P:  J L  y  7")
		prompt.text = t1 + "        " + t2
	elif picking == 0:
		prompt.text = "1P:  ELIGE TU PERSONAJE   ( ← →   ENTER  ·  ESC )"
	elif picking == 1:
		prompt.text = "2P:  ELIGE EL RIVAL (CPU)   ( ← →   ENTER  ·  ESC )"
	else:
		prompt.text = ""
	# overlay de SELECT STAGE visible solo en el 3er paso
	if stage_overlay != null:
		stage_overlay.visible = (picking == 2)
	queue_redraw()

func _ease_out(x: float) -> float:
	return 1.0 - pow(1.0 - clampf(x, 0.0, 1.0), 3.0)

func _process(delta: float) -> void:
	t += delta
	# recoge el hilo de precalentado de frames de select cuando termina (mantiene refs en caché)
	if _sel_warm_thread != null and not _sel_warm_thread.is_alive():
		_sel_warm_cache = _sel_warm_thread.wait_to_finish()
		_sel_warm_thread = null
	if loading:
		_update_loading(delta)
		return
	# avanza la animación de aparición de los personajes (hover)
	appear_l = minf(1.0, appear_l + delta * 5.0)   # ~0.2s
	appear_r = minf(1.0, appear_r + delta * 5.0)
	var act_l: bool = (not locked1) if (_vs2p() and picking < 2) else (picking == 0)
	var act_r: bool = (not locked2) if (_vs2p() and picking < 2) else (picking == 1)
	_anim_side(0, appear_l, -1.0, act_l)
	_anim_side(1, appear_r, 1.0, act_r)
	if fx:
		fx.queue_redraw()
	# FLASH de selección (una sola vez): decae de 1→0; mientras dura, redibuja fondo y fx
	if _sel_flash[0] > 0.0 or _sel_flash[1] > 0.0:
		_sel_flash[0] = maxf(0.0, _sel_flash[0] - delta * 1.8)   # ~0.55s
		_sel_flash[1] = maxf(0.0, _sel_flash[1] - delta * 1.8)
		queue_redraw()
	if picking == 2 and stage_fx != null:
		stage_scroll = lerpf(stage_scroll, float(sel_stage), minf(delta * 12.0, 1.0))
		_layout_stage_carousel()
		stage_fx.queue_redraw()
		if stage_fx_top != null:
			stage_fx_top.queue_redraw()

func _update_loading(delta: float) -> void:
	load_t += delta
	if load_spin != null:
		load_spin.queue_redraw()
	# los HILOS precalientan en paralelo: el spinner sigue girando sin bloquearse.
	var warm_done := true
	for th in _warm_threads:
		if th.is_alive():
			warm_done = false
			break
	if warm_done and not _warm_threads.is_empty():
		for th in _warm_threads:
			Sel.warm_cache.append_array(th.wait_to_finish())   # recoge las texturas calientes
		_warm_threads.clear()
	# cuando la escena cargó, los frames están calientes Y ya se vio el mínimo -> entrar
	var st := ResourceLoader.load_threaded_get_status("res://main.tscn")
	if st == ResourceLoader.THREAD_LOAD_LOADED and warm_done and load_t >= VS_MIN_SHOW:
		var packed = ResourceLoader.load_threaded_get("res://main.tscn")
		get_tree().change_scene_to_packed(packed)
	elif st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		get_tree().change_scene_to_file("res://main.tscn")   # fallback

# --- sonidos del char-select: al confirmar suena "on-select" + la VOZ (épica) del nombre ---
const SEL_SFX := "res://imagen-action/sound-effect/on-select.mp3"
const HOVER_SFX := "res://imagen-action/sound-effect/hover-selection.mp3"   # campana al pasar por un personaje
const NAME_VOZ := {
	"dam": "res://imagen-action/sound-effect/dam-name.mp3",
	"favi": "res://imagen-action/sound-effect/fe-name.mp3",
	"aye": "res://imagen-action/sound-effect/aye.mp3",
}
# FRASE de selección por personaje (catchphrase, casa con la boca del clip). Si existe,
# suena EN LUGAR del nombre al confirmar. DAM: "excellent choice". Fe/Aye: pendientes.
const SEL_LINE := {
	"dam": "res://imagen-action/dam/sound-effect/excellent_choice_Vibes_Eleven_v3_01a0076e-f439-7e56-9545-5aaa4f1eb0d1.mp3",
	"favi": "res://imagen-action/favi/Fe-sound-effect/let_have_fun_Tattle_Eleven_v3_01a00770-428c-7f68-b7e5-1d5b6763fdd9.mp3",
	"aye": "res://imagen-action/aye/sound-effect/we_got_this_Cupcake_Eleven_v3_01a00772-a7ce-7ba0-8488-29fb6cd8bc37.mp3",
	"zetma": "res://imagen-action/zetma/sound-effect/zetma-select.wav",   # "the shades are with me" (robótica/terror)
}
# DEMORA (seg) antes de que suene la voz, para que arranque con el movimiento de boca del
# clip. Faviola algo más que DAM; Aye con la suya. (tuneable a gusto)
const SEL_DELAY := {"dam": 0.70, "favi": 1.60, "aye": 1.55, "zetma": 0.80}
const SELECT_HOLD := 2.2    # pausa tras la ÚLTIMA selección: se ve la animación antes de avanzar
var _advancing := false     # true durante esa pausa: congela el input
var _sfx_sel: AudioStreamPlayer
var _voz_name: AudioStreamPlayer
var _line_gen := 0    # generación de voz: un hover nuevo invalida la voz demorada anterior

# VOZ del personaje: su FRASE (excellent choice / let's have fun / we got this) o, si no
# tiene, la voz del nombre. Suena al POSARSE en él (hover) y también al confirmar, con una
# pequeña DEMORA por personaje para sincronizar con la boca del clip.
func _play_line(char_id: String) -> void:
	var ruta: String = SEL_LINE.get(char_id, "")
	if ruta == "" or not ResourceLoader.exists(ruta):
		ruta = NAME_VOZ.get(char_id, "")
	if _voz_name == null or ruta == "" or not ResourceLoader.exists(ruta):
		return
	_line_gen += 1
	var gen := _line_gen
	var delay: float = float(SEL_DELAY.get(char_id, 0.0))
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
		# si el jugador se movió a otro personaje mientras esperaba, NO suena la voz vieja
		if gen != _line_gen or not is_instance_valid(_voz_name):
			return
	_voz_name.stream = load(ruta)
	_voz_name.play()

func _play_select(char_id: String) -> void:
	if _sfx_sel != null and ResourceLoader.exists(SEL_SFX):
		_sfx_sel.stream = load(SEL_SFX)
		_sfx_sel.play()
	_play_line(char_id)

func _vs2p() -> bool:
	return Sel.mode == "vs_2p"

# tras la ÚLTIMA selección de personaje: PAUSA breve (input congelado) para ver la
# animación/gesto del último elegido, y luego pasa al SELECT STAGE.
func _goto_stage_after_hold() -> void:
	if _advancing:
		return
	_advancing = true
	Sel.p1 = String(roster[sel1]["id"])
	Sel.p2 = String(roster[sel2]["id"])
	await get_tree().create_timer(SELECT_HOLD).timeout
	picking = 2                                 # -> SELECT STAGE
	_advancing = false
	_refresh()

# VS 2P: SELECCIÓN SIMULTÁNEA. P1 (← → + ENTER/Q) y P2 (J/L + 7, o mando ✚ + A/Y)
# mueven su cursor A LA VEZ; cada uno confirma el suyo. ESC des-confirma (o sale al título).
func _input_vs2p() -> void:
	var moved := false
	if not locked1:
		var d1 := 0
		if Input.is_action_just_pressed("ui_left"):
			d1 = -1
		elif Input.is_action_just_pressed("ui_right"):
			d1 = 1
		if d1 != 0:
			sel1 = posmod(sel1 + d1, roster.size())
			moved = true
		elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
			locked1 = true
			_play_anim(0)                               # gesto del personaje P1
			_play_select(String(roster[sel1]["id"]))    # ping + voz demorada
			_refresh()
	if not locked2:
		var d2 := 0
		if Input.is_action_just_pressed("ui_left_p2"):
			d2 = -1
		elif Input.is_action_just_pressed("ui_right_p2"):
			d2 = 1
		if d2 != 0:
			sel2 = posmod(sel2 + d2, roster.size())
			moved = true
		elif Input.is_action_just_pressed("attack_p2") or Input.is_action_just_pressed("kick_p2"):
			locked2 = true
			_play_anim(1)                               # gesto del personaje P2
			_play_select(String(roster[sel2]["id"]))    # ping + voz demorada
			_refresh()
	if moved:
		if _sfx_sel != null and ResourceLoader.exists(HOVER_SFX):   # solo campana al pasar (sin voz)
			_sfx_sel.stream = load(HOVER_SFX)
			_sfx_sel.play()
		_refresh()
	if Input.is_action_just_pressed("ui_cancel"):
		if locked1 or locked2:
			locked1 = false
			locked2 = false
			_refresh()
		else:
			get_tree().change_scene_to_file("res://title.tscn")
		return
	if locked1 and locked2:
		_goto_stage_after_hold()                    # pausa breve viendo la animación -> stage

func _unhandled_input(_e: InputEvent) -> void:
	if _advancing:
		return                                       # pausa post-selección: input congelado
	if _vs2p() and picking < 2:
		_input_vs2p()
		return
	# en VS 2P el stage (picking == 2) también responde a las teclas/mando de P2
	var p2_also: bool = _vs2p() and picking == 2
	var dc := 0
	if Input.is_action_just_pressed("ui_left") or (p2_also and Input.is_action_just_pressed("ui_left_p2")):
		dc = -1
	elif Input.is_action_just_pressed("ui_right") or (p2_also and Input.is_action_just_pressed("ui_right_p2")):
		dc = 1
	if dc != 0:
		if picking == 0:
			sel1 = posmod(sel1 + dc, roster.size())
		elif picking == 1:
			sel2 = posmod(sel2 + dc, roster.size())
		else:                                            # picking == 2: elegir stage (carrusel, sin wrap)
			sel_stage = clampi(sel_stage + dc, 0, Sel.STAGES.size() - 1)
		if _sfx_sel != null and ResourceLoader.exists(HOVER_SFX):   # solo campana al pasar (sin voz)
			_sfx_sel.stream = load(HOVER_SFX)
			_sfx_sel.play()
		_refresh()
		return
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack") \
			or (p2_also and (Input.is_action_just_pressed("attack_p2") or Input.is_action_just_pressed("kick_p2"))):
		if picking == 0:
			_play_anim(0)                               # gesto del personaje (1P)
			_play_select(String(roster[sel1]["id"]))    # ping + voz demorada
			picking = 1
			_refresh()
		elif picking == 1:
			_play_anim(1)                               # gesto del rival (2P/CPU)
			_play_select(String(roster[sel2]["id"]))    # ping + voz demorada
			_goto_stage_after_hold()                    # pausa breve viendo la animación -> stage
		else:                                           # confirmar STAGE -> a la pelea
			Sel.stage = int(Sel.STAGES[sel_stage]["code"])
			Sel.configured = true
			if _sfx_sel != null and ResourceLoader.exists(SEL_SFX):
				_sfx_sel.stream = load(SEL_SFX)
				_sfx_sel.play()
			_start_loading()   # pantalla de carga (logo) mientras carga la pelea
	elif Input.is_action_just_pressed("ui_cancel"):
		if picking == 2:
			if _vs2p():
				# volver a la selección simultánea con los dos SIN confirmar
				picking = 0
				locked1 = false
				locked2 = false
			else:
				picking = 1
			_refresh()
		elif picking == 1:
			picking = 0
			_refresh()
		else:
			get_tree().change_scene_to_file("res://title.tscn")
