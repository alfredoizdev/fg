extends Node2D
# Santuario Dorado con SCROLL + PARALLAX (stage 4) — arte v2 (piso GRANDE, nítido).
# La cámara la maneja main.gd (game_cam): sigue a los peleadores por un mundo ANCHO.
# Dos capas dentro de un ParallaxBackground:
#   - LEJOS (cielo + skyline): se mueve LENTO (profundidad). Espejado en vivo -> tilea sin costura.
#   - CERCA (piso + faroles): 1:1 con el mundo -> el suelo donde caminan. Verde de croma recortado.
# El arte v2 trae el piso GRANDE, así que se escala POCO (nítido, no pixelado).

const FAR_PNG  := "res://imagen-action/stage/santuario-2/far.png"
const NEAR_PNG := "res://imagen-action/stage/santuario-2/near-cut.png"

# --- AJUSTES (tunear si el piso o el cielo no calzan) ---
const FAR_SCALE := 1.14        # cielo cubre el alto de pantalla (948 -> 1080)
const FAR_Y := 0.0
const FAR_PARALLAX := 0.5      # el cielo se mueve al 50% de la cámara (profundidad)
const NEAR_SCALE := 1.02       # piso (arte v2 nuevo 1792×1024): escala CHICA -> nítido
const NEAR_Y := 42.0           # tope del piso (pies ~y820, fondo llega a ~1086)

func _ready() -> void:
	var far_tex: Texture2D = load(FAR_PNG) if ResourceLoader.exists(FAR_PNG) else null
	var near_tex: Texture2D = load(NEAR_PNG) if ResourceLoader.exists(NEAR_PNG) else null
	# FONDO base cálido oscuro fijo a la pantalla: tapa cualquier hueco que si no se vería GRIS.
	var base_layer := CanvasLayer.new()
	base_layer.layer = -2
	add_child(base_layer)
	var base := ColorRect.new()
	base.color = Color(0.09, 0.045, 0.06)   # atardecer oscuro (no gris)
	base.size = Vector2(1920, 1080)
	base_layer.add_child(base)
	var pbg := ParallaxBackground.new()
	pbg.layer = -1
	add_child(pbg)
	# ---- capa LEJOS (cielo) — espejado en vivo (sin PNG nuevo) para tilear sin costura ----
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
