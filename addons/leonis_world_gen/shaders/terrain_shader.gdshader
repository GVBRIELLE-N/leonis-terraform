shader_type spatial;

uniform float heightOffset = 2;
uniform sampler2D heightMapTexture;

void vertex() {
	VERTEX.y += texture(heightMapTexture, UV).r * heightOffset * 4.0;
}

void fragment() {
	ALBEDO = vec3(0.35, 0.5, 0) * texture(heightMapTexture, UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
