shader_type spatial;

uniform float heightOffset = 2;
uniform sampler2D heightMapTexture;

//Top Layer
uniform vec4 topColour : source_color = vec4(1,0,0,1);
uniform sampler2D topTexture;
uniform sampler2D topNormalMap;
uniform vec2 topTiling;

//Middle Layer
uniform vec4 middleColour : source_color = vec4(0, 1, 0, 1);
uniform sampler2D middleTexture;
uniform sampler2D middleNormalMap;
uniform vec2 middleTiling;

//Bottom Layer
uniform vec4 bottomColour : source_color = vec4(0, 0, 1, 1);
uniform sampler2D bottomTexture;
uniform sampler2D bottomNormalMap;
uniform vec2 bottomTiling;

varying vec2 main_uv;

void vertex() {
	VERTEX.y += texture(heightMapTexture, UV).r * heightOffset * 4.0;
}

void fragment() {
	float b_blend = clamp(texture(heightMapTexture, UV).r, 0.0, 1);
	float t_blend = clamp(texture(heightMapTexture, UV).r, 0.0, 1);
	vec3 bc_mix = mix(bottomColour, middleColour, b_blend).rgb;
	vec3 tc_mix = mix(bc_mix, topColour.rgb, t_blend).rgb;
	
	vec3 bt_mix = mix(texture(bottomTexture, UV * bottomTiling), texture(middleTexture, UV * middleTiling), b_blend).rgb;
	vec3 tt_mix = mix(bt_mix, texture(topTexture, UV * topTiling).rgb, t_blend).rgb;
	ALBEDO = tc_mix * tt_mix;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
