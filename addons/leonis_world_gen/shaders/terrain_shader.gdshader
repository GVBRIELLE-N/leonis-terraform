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
	
	VERTEX.y += texture(heightMapTexture, UV).r * heightOffset;
}

void fragment() {
	float tex_blend = 0.5;
	float b_blend = clamp(texture(heightMapTexture, UV).r / tex_blend, 0.0, 1.0);
	float t_blend = clamp(texture(heightMapTexture, UV).r / (heightOffset * tex_blend), 0.0, 1.0);
	
	vec3 c0 = mix(bottomColour, middleColour, b_blend).rgb;
	vec3 c1 = mix(c0, topColour.rgb, t_blend).rgb;
	
	vec3 t0 = mix(texture(bottomTexture, UV * bottomTiling).rgb, texture(middleTexture, UV * middleTiling).rgb, b_blend);
	vec3 t1 = mix(t0, texture(topTexture, UV * topTiling).rgb, t_blend);
	
	vec3 n0 = mix(texture(bottomNormalMap, UV * bottomTiling).rgb, texture(middleNormalMap, UV * middleTiling).rgb, b_blend);
	vec3 n1 = mix(n0, texture(topNormalMap, UV * topTiling).rgb, t_blend);
		
	vec3 tc_mix = c1;
	
	vec3 tt_mix = t1;
	ALBEDO = tt_mix * tc_mix;
	NORMAL_MAP = n1;
	ROUGHNESS = 1.0;
	METALLIC = 1.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
