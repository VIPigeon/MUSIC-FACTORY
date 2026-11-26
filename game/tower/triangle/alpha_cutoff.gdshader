shader_type canvas_item;

uniform float alpha_cutoff : hint_range(0.0, 1.0) = 0.3;
varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	float coverage = texture(TEXTURE, UV).a;
	COLOR = vec4(tint.rgb, step(alpha_cutoff, coverage) * tint.a);
}
