shader_type canvas_item;

// ============================================================
//  PORTAL VOID de ROUM — AGUJERO NEGRO tipo VÓRTICE (no esfera).
//  Centro oscuro (el "hoyo") + disco de acrecion CARMESÍ girando en
//  espiral log (se traga todo hacia el centro) + borde brillante HDR.
//  El sprite se ESCALA en Y (ellipse) para que se vea "de medio lado"
//  (disco inclinado, no un circulo de frente).  Todo procedural.
// ============================================================
uniform float spin_speed = 1.0;
uniform float grow : hint_range(0.0, 1.0) = 1.0;   // 0 = cerrado, 1 = abierto (anima la apertura)
uniform float seed = 0.0;
uniform vec4 col_void : source_color = vec4(0.0, 0.0, 0.0, 1.0);     // el hoyo: NEGRO puro
uniform vec4 col_disc : source_color = vec4(0.10, 0.004, 0.02, 1.0); // cuerpo casi NEGRO (rojo muy tenue)
uniform vec4 col_rim  : source_color = vec4(1.45, 0.07, 0.12, 1.0);  // filo CARMESÍ fino (HDR -> brilla)
uniform vec4 col_deep : source_color = vec4(0.02, 0.0, 0.01, 1.0);   // negro rojizo de fondo

float hash21(vec2 p) {
	p = fract(p * vec2(233.34, 851.73));
	p += dot(p, p + 23.45);
	return fract(p.x * p.y);
}
float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.55;
	for (int i = 0; i < 5; i++) {
		v += a * vnoise(p);
		p = p * 2.03 + 7.3;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = (UV - 0.5) * 2.0;              // -1..1
	float r = length(uv);
	float ang = atan(uv.y, uv.x);
	float t = TIME * spin_speed + seed * 6.2831;

	// --- ESPIRAL LOG: el disco se enrosca hacia el centro (efecto "se lo traga") ---
	float spiral = ang * 1.0 + t * 1.6 - log(max(r, 0.04)) * 2.6;
	float disc = fbm(vec2(spiral * 0.75, r * 3.0 - t * 0.7));
	disc += 0.5 * fbm(vec2(spiral * 1.6 + 4.0, r * 5.0 + t * 0.5));
	disc = smoothstep(0.30, 1.05, disc);

	// --- PERFIL: NEGRO grande PEGADO al filo + aro carmesí ULTRA FINO ---
	float black = smoothstep(0.85, 0.80, r);                              // negro sólido casi hasta el borde (~0.80)
	float rim   = smoothstep(0.81, 0.855, r) * smoothstep(0.905, 0.855, r); // ARO ultra fino ~0.855, pegado al negro

	// --- APERTURA (grow): el portal se abre desde el centro hacia afuera ---
	float open = smoothstep(grow * 1.0 + 0.02, grow * 1.0 - 0.09, r);

	// --- COLOR: negro puro + swirl carmesí sólo en el filo fino ---
	vec3 col = mix(col_void.rgb, col_rim.rgb, clamp(rim * (0.55 + 0.55 * disc), 0.0, 1.0));

	float a = open * clamp(black + rim * (0.7 + 0.5 * disc), 0.0, 1.0);
	COLOR = vec4(col, a);
}
