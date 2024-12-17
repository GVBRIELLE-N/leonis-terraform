shader_type spatial;

uniform float heightOffset = 2;
uniform sampler2D heightMapTexture;

void vertex() {
	VERTEX.y += texture(heightMapTexture, UV).r * heightOffset * 2.0;
}

void fragment() {
	ALBEDO = vec3(0, 1, 0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
