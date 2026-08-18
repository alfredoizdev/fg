shader_type canvas_item;

// ============================================================
//  CÚPULA VOID de Zetma — domo de energía que ENJAULA al rival
//  (campo de fuerza morado: borde fresnel + bandas + anillo base)
// ============================================================
uniform float grow : hint_range(0.0, 1.0) = 1.0;   // 0 = cerrado · 1 = domo lleno
uniform float seed = 0.0;
uniform vec4 col_fill : source_color = vec4(0.48, 0.12, 1.24, 1.0);  // relleno morado (un poco MÁS OSCURO)
uniform vec4 col_rim  : source_color = vec4(1.65, 1.05, 2.55, 1.0);  // borde/anillo (HDR -> bloom, algo más oscuro)

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

void fragment() {
	float g = max(grow, 0.001);
	vec2 c = vec2(0.5, 0.5);               // centro del CÍRCULO
	float R = 0.44 * g;                    // radio IGUAL en x/y = CÍRCULO verdadero (cabe dentro del sprite, no se recorta)
	vec2 d = (UV - c) / R;
	float rr = length(d);                  // 1.0 = borde del círculo
	float t = TIME + seed * 10.0;

	// CORTE plano abajo: el sobrante que iría bajo el piso se recorta (ahí va el anillo del suelo)
	float cut = c.y + R * 0.55;            // línea del piso (deja la mayor parte del círculo)
	float above = smoothstep(cut + 0.012, cut - 0.012, UV.y);
	float z = sqrt(max(0.0, 1.0 - rr * rr));
	float fres = pow(1.0 - clamp(z, 0.0, 1.0), 1.7);

	// GIRO SOBRE EL EJE: meridianos de longitud que rotan (la esfera da vueltas sobre su eje)
	float lon = atan(d.x, max(z, 0.001));                     // longitud sobre la esfera falsa
	float spin = 0.5 + 0.5 * sin(lon * 5.0 - t * 2.4);        // franjas girando
	// bandas de energía que fluyen hacia arriba, mezcladas con el giro (domina el giro)
	float bands = 0.5 + 0.5 * sin(d.x * 7.0 + t * 0.7 + vnoise(d * 2.5 + vec2(0.0, -t * 1.2)) * 4.0);
	bands = mix(bands, spin, 0.6);

	// máscara del círculo (recortado abajo)
	float dome = smoothstep(1.0, 0.90, rr) * above;

	// anillo FINO en la línea de corte (elipse que casa con el ancho del círculo ahí)
	vec2 db = (UV - vec2(0.5, cut)) / vec2(R * 0.835, 0.05 * g);
	float bl = length(db);
	float ring = clamp(smoothstep(1.06, 1.0, bl) - smoothstep(1.0, 0.965, bl), 0.0, 1.0);

	// color (tinte morado MÁS presente)
	vec3 col = col_fill.rgb * (0.50 + 0.60 * bands);
	col = mix(col, col_rim.rgb, fres * dome);
	col += col_rim.rgb * ring * 1.35;

	float alpha = dome * (0.34 + 0.50 * bands + fres * 1.0);
	alpha = max(alpha, ring);
	COLOR = vec4(col, clamp(alpha, 0.0, 1.0));
}
