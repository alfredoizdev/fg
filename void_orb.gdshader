shader_type canvas_item;

// ============================================================
//  ORBE VOID de Zetma — BOLA de energía ESFÉRICA (fake 3D) con
//  corona girando alrededor. Técnica: normal de esfera z=sqrt(1-r^2),
//  fresnel de borde, sombreado esférico, swirl mapeado en la bola,
//  y una corona de energía que rota afuera. Todo procedural + HDR.
// ============================================================
uniform float spin_speed = 1.0;
uniform float grow : hint_range(0.0, 1.0) = 1.0;
uniform float seed = 0.0;
uniform vec4 col_core : source_color = vec4(1.55, 0.85, 2.25, 1.0); // núcleo (menos blanco, más morado)
uniform vec4 col_mid  : source_color = vec4(0.52, 0.14, 1.25, 1.0); // cuerpo morado más OSCURO
uniform vec4 col_rim  : source_color = vec4(1.35, 0.55, 2.25, 1.0); // borde/corona más oscura (HDR -> bloom)
uniform vec4 col_deep : source_color = vec4(0.07, 0.01, 0.20, 1.0); // sombra/void

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

	float SR = 0.74;                         // radio de la ESFERA dentro del rect (deja borde para la corona)
	float rn = r / SR;                       // 0 centro, 1 = borde de la bola

	// ---------- ESFERA (fake 3D) ----------
	float z = sqrt(max(0.0, 1.0 - rn * rn)); // profundidad de la superficie esférica
	// swirl que se ENVUELVE en la bola y gira con el tiempo
	float sw = ang + t * 1.2 + (1.0 - z) * 3.5;
	float energy = fbm(vec2(sw * 0.9, rn * 2.2 - t * 0.6));
	energy += 0.5 * fbm(vec2(sw * 1.8 + 3.0, rn * 4.0 + t * 0.4));
	energy = smoothstep(0.34, 1.0, energy * 0.7);

	float fres = pow(1.0 - z, 2.6);          // BORDE brillante -> se ve esférico
	float core = pow(smoothstep(0.55, 0.0, rn), 2.2);
	// sombreado esférico (luz desde arriba-izquierda)
	float light = clamp(dot(normalize(vec3(uv / SR, z)), normalize(vec3(-0.35, -0.45, 0.82))), 0.0, 1.0);
	light = 0.45 + 0.55 * light;

	vec3 sph_col = mix(col_deep.rgb, col_mid.rgb, energy) * light;
	sph_col = mix(sph_col, col_core.rgb, core);
	sph_col = mix(sph_col, col_rim.rgb, fres * 0.9);
	float sph_mask = smoothstep(1.0, 0.95, rn);
	float sph_a = sph_mask * clamp(energy * 0.7 + core + fres * 0.9 + 0.22, 0.0, 1.0);

	// ---------- CORONA girando (afuera de la bola) ----------
	float ca = (r - SR) / (1.0 - SR);        // 0 en el borde de la bola, 1 en el borde del rect
	float corona = 0.0;
	if (ca > 0.0 && ca < 1.0) {
		float wisp = fbm(vec2(ang * 3.0 + t * 2.3, ca * 3.0 - t));
		wisp += 0.5 * fbm(vec2(ang * 6.0 - t * 1.6, ca * 5.0));
		corona = smoothstep(0.55, 1.05, wisp * 0.72) * (1.0 - ca);
	}

	// ---------- combinar (mezcla ponderada por alfa) ----------
	float a = clamp(sph_a + corona * 0.85, 0.0, 1.0);
	vec3 col = (sph_col * sph_a + col_rim.rgb * corona * 0.85) / max(a, 0.001);

	// grow: cierra/abre todo el conjunto desde el borde
	a *= smoothstep(grow, grow - 0.15, r);
	a *= smoothstep(0.02, 0.06, a);          // sin caja cuadrada

	COLOR = vec4(col, a);
}
