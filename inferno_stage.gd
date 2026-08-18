extends Node2D
# INFIERNO con SCROLL + PARALLAX (stage 5). Mismo esquema/escala estándar que santuario/city.
#   - LEJOS (cielo de fuego): lento (profundidad), espejado en vivo -> sin costura.
#   - CERCA (piso): 1:1 con el mundo. Verde de croma recortado.

const FAR_PNG  := "res://imagen-action/stage/Inferno/far.png"
const NEAR_PNG := "res://imagen-action/stage/Inferno/near-cut.png"

const FAR_SCALE := 1.14
const FAR_Y := 0.0
const FAR_PARALLAX := 0.5
const NEAR_SCALE := 1.10        # arte 1659×948 -> escala del estándar original
const NEAR_Y := 42.0

func _ready() -> void:
	var far_tex: Texture2D = load(FAR_PNG) if ResourceLoader.exists(FAR_PNG) else null
	var near_tex: Texture2D = load(NEAR_PNG) if ResourceLoader.exists(NEAR_PNG) else null
	var base_layer := CanvasLayer.new()
	base_layer.layer = -2
	add_child(base_layer)
	var base := ColorRect.new()
	base.color = Color(0.10, 0.03, 0.02)   # rojo-fuego muy oscuro (no gris)
	base.size = Vector2(1920, 1080)
	base_layer.add_child(base)
	var pbg := ParallaxBackground.new()
	pbg.layer = -1
	add_child(pbg)
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
		var ns2 := Sprite2D.new()
		ns2.texture = near_tex; ns2.centered = false
		ns2.scale = Vector2(-NEAR_SCALE, NEAR_SCALE)
		ns2.position = Vector2(ntw * 2.0, NEAR_Y); ns2.z_index = -1
		nl.add_child(ns2)
		pbg.add_child(nl)
	# ---- AMBIENTE: brasas rojas chiquitas + niebla tenue (cubren todo el mundo ancho) ----
	# EMBERS: partículas chiquitas y BRILLOSAS que suben (naranja-rojo HDR -> bloom del glow)
	var embers := CPUParticles2D.new()
	embers.z_index = 1
	embers.position = Vector2(1360, 1120)              # centro del mundo, desde abajo
	embers.amount = 120
	embers.lifetime = 5.5
	embers.preprocess = 5.5
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(1500, 40)   # ancho: cubre el mundo con scroll
	embers.direction = Vector2(0, -1)
	embers.spread = 22.0
	embers.gravity = Vector2(6, -20)                   # suben con leve deriva
	embers.initial_velocity_min = 18.0
	embers.initial_velocity_max = 60.0
	embers.scale_amount_min = 1.0
	embers.scale_amount_max = 3.2
	embers.color = Color(2.6, 0.7, 0.2, 0.95)          # naranja-rojo brillante
	var ramp := Gradient.new()                         # se encienden y se apagan (parpadeo)
	ramp.set_color(0, Color(2.8, 0.9, 0.3, 0.0))
	ramp.add_point(0.2, Color(2.8, 0.7, 0.25, 1.0))
	ramp.set_color(1, Color(1.6, 0.25, 0.1, 0.0))
	embers.color_ramp = ramp
	add_child(embers)
	# textura REDONDA suave (gradiente radial blanco->transparente) para que las partículas de
	# niebla NO se vean como cuadrados, sino como manchas suaves.
	var soft_grad := Gradient.new()
	soft_grad.set_color(0, Color(1, 1, 1, 1))
	soft_grad.set_color(1, Color(1, 1, 1, 0))
	var soft_tex := GradientTexture2D.new()
	soft_tex.gradient = soft_grad
	soft_tex.fill = GradientTexture2D.FILL_RADIAL
	soft_tex.fill_from = Vector2(0.5, 0.5)
	soft_tex.fill_to = Vector2(0.5, 1.0)
	soft_tex.width = 128
	soft_tex.height = 128
	# NIEBLA: manchas SUAVES y translúcidas que derivan (nebulosa roja abajo)
	var fog := CPUParticles2D.new()
	fog.texture = soft_tex                             # <- redonda, no cuadrada
	fog.z_index = 0
	fog.position = Vector2(1360, 840)
	fog.amount = 20
	fog.lifetime = 14.0
	fog.preprocess = 14.0
	fog.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog.emission_rect_extents = Vector2(1500, 200)
	fog.direction = Vector2(1, -0.15)
	fog.spread = 40.0
	fog.gravity = Vector2(4, -2)
	fog.initial_velocity_min = 4.0
	fog.initial_velocity_max = 14.0
	fog.scale_amount_min = 1.8                          # con textura de 128px -> ~230-450px de niebla
	fog.scale_amount_max = 3.6
	fog.color = Color(0.9, 0.18, 0.12, 0.12)           # rojo humo muy translúcido
	var framp := Gradient.new()
	framp.set_color(0, Color(0.9, 0.2, 0.12, 0.0))
	framp.add_point(0.4, Color(0.85, 0.2, 0.12, 0.18))
	framp.set_color(1, Color(0.7, 0.12, 0.08, 0.0))
	fog.color_ramp = framp
	add_child(fog)
