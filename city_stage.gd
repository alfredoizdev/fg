extends Node2D
# Ciudad en ruinas de noche con SCROLL + PARALLAX (stage 1) — arte v2 (piso GRANDE, nítido).
# Mismo esquema y MISMA escala de piso que el santuario v2 (estándar) para que los personajes
# se vean del mismo tamaño en los dos stages.
#   - LEJOS (skyline + luna): se mueve LENTO (profundidad). Espejado en vivo -> sin costura.
#   - CERCA (puente/calle de escombros): 1:1 con el mundo. Verde de croma recortado.

const FAR_PNG  := "res://imagen-action/stage/city-2/far.png"
const NEAR_PNG := "res://imagen-action/stage/city-2/near-cut.png"

# --- AJUSTES (MISMOS que el santuario v2 = estándar del piso) ---
const FAR_SCALE := 1.14
const FAR_Y := 0.0
const FAR_PARALLAX := 0.5
const NEAR_SCALE := 1.10       # piso escala CHICA (arte grande) -> nítido y proporcional
const NEAR_Y := 42.0           # pies ~y820

func _ready() -> void:
	var far_tex: Texture2D = load(FAR_PNG) if ResourceLoader.exists(FAR_PNG) else null
	var near_tex: Texture2D = load(NEAR_PNG) if ResourceLoader.exists(NEAR_PNG) else null
	# FONDO base OSCURO (noche) fijo a la pantalla: tapa cualquier hueco (bajo el puente) -> sin gris.
	var base_layer := CanvasLayer.new()
	base_layer.layer = -2
	add_child(base_layer)
	var base := ColorRect.new()
	base.color = Color(0.03, 0.035, 0.075)   # azul-noche muy oscuro
	base.size = Vector2(1920, 1080)
	base_layer.add_child(base)
	var pbg := ParallaxBackground.new()
	pbg.layer = -1
	add_child(pbg)
	# ---- capa LEJOS (skyline) — espejado en vivo -> tilea sin costura ----
	if far_tex != null:
		var tw := far_tex.get_width() * FAR_SCALE
		var fl := ParallaxLayer.new()
		fl.motion_scale = Vector2(FAR_PARALLAX, 1.0)
		fl.motion_mirroring = Vector2(tw * 2.0, 0.0)
		var fs := Sprite2D.new()
		fs.texture = far_tex; fs.centered = false
		fs.scale = Vector2(FAR_SCALE, FAR_SCALE)
		fs.position = Vector2(0.0, FAR_Y); fs.z_index = -2
		fl.add_child(fs)
		var fs2 := Sprite2D.new()
		fs2.texture = far_tex; fs2.centered = false
		fs2.scale = Vector2(-FAR_SCALE, FAR_SCALE)
		fs2.position = Vector2(tw * 2.0, FAR_Y); fs2.z_index = -2
		fl.add_child(fs2)
		pbg.add_child(fl)
	# ---- capa CERCA (piso) — 1:1 con el mundo, ESPEJADO en vivo -> tilea SIN COSTURA ----
	if near_tex != null:
		var ntw := near_tex.get_width() * NEAR_SCALE
		var nl := ParallaxLayer.new()
		nl.motion_scale = Vector2(1.0, 1.0)
		nl.motion_mirroring = Vector2(ntw * 2.0, 0.0)
		var ns := Sprite2D.new()
		ns.texture = near_tex; ns.centered = false
		ns.scale = Vector2(NEAR_SCALE, NEAR_SCALE)
		ns.position = Vector2(0.0, NEAR_Y); ns.z_index = -1
		nl.add_child(ns)
		var ns2 := Sprite2D.new()               # copia ESPEJADA (flip horizontal)
		ns2.texture = near_tex; ns2.centered = false
		ns2.scale = Vector2(-NEAR_SCALE, NEAR_SCALE)
		ns2.position = Vector2(ntw * 2.0, NEAR_Y); ns2.z_index = -1
		nl.add_child(ns2)
		pbg.add_child(nl)
	# ---- LLUVIA suave (llovizna): fija a la pantalla, encima de todo pero tenue ----
	_add_rain()

# LLUVIA — llovizna sutil. CanvasLayer fijo a cámara con 2 capas de partículas
# (lejana fina/tenue + cercana un poco más marcada), gotas alargadas en diagonal leve.
const RAIN_DIAG := 0.16          # inclinación de la caída (x por cada 1 de y)

func _make_drop_tex() -> ImageTexture:
	# gota = línea vertical suave (más brillante en el medio, se desvanece en las puntas)
	var w := 3
	var h := 26
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		var t := float(y) / float(h - 1)
		var a := pow(sin(t * PI), 0.7)                 # 0 → 1 → 0 a lo largo
		for x in w:
			var cx := (float(w) - 1.0) * 0.5
			var ax: float = 1.0 - absf(float(x) - cx) / (cx + 0.001)   # falloff horizontal
			img.set_pixel(x, y, Color(0.72, 0.80, 0.95, float(a) * ax))
	return ImageTexture.create_from_image(img)

func _make_rain_emitter(drop: ImageTexture, amount: int, vel: float, sc: float, alpha: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = drop
	p.amount = amount
	p.lifetime = 1.4
	p.preprocess = 1.4                                 # la pantalla arranca ya lloviendo
	p.local_coords = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(1060.0, 8.0)
	p.position = Vector2(960.0, -30.0)                 # borde superior, ancho completo
	p.direction = Vector2(RAIN_DIAG, 1.0)
	p.spread = 2.0
	p.gravity = Vector2(0.0, 240.0)
	p.initial_velocity_min = vel * 0.9
	p.initial_velocity_max = vel * 1.12
	p.scale_amount_min = sc * 0.8
	p.scale_amount_max = sc * 1.2
	var ang := rad_to_deg(atan2(RAIN_DIAG, 1.0))       # inclina la raya para seguir la caída
	p.angle_min = ang
	p.angle_max = ang
	p.color = Color(0.72, 0.80, 0.95, alpha)
	return p

func _add_rain() -> void:
	var drop := _make_drop_tex()
	var cl := CanvasLayer.new()
	cl.layer = 3                                       # encima de la pelea, pero tenue
	add_child(cl)
	# capa LEJANA: fina, tenue, lenta
	cl.add_child(_make_rain_emitter(drop, 90, 780.0, 0.7, 0.16))
	# capa CERCANA: un poco más gruesa y rápida
	cl.add_child(_make_rain_emitter(drop, 70, 1060.0, 1.05, 0.28))
