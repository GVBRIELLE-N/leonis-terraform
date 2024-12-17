shader_type spatial;

uniform float heightOffset = 2;
uniform vec2 uvOffset;
uniform sampler2D heightMapTexture;

varying vec2 main_uv;

void vertex() {
	main_uv = UV + uvOffset;
	VERTEX.y += texture(heightMapTexture, main_uv).r * heightOffset * 4.0;
}

void fragment() {
	ALBEDO = vec3(0.35, 0.5, 0) * texture(heightMapTexture, main_uv).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
