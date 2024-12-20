shader_type spatial;

uniform float heightOffset = 2;
uniform sampler2D heightMapTexture;

//Top Layer
uniform vec4 rockColour : source_color = vec4(1,0,0,1);
uniform sampler2D rockTexture;
uniform sampler2D rockNormalMap;
uniform vec2 rockTiling;

//Middle Layer
uniform vec4 groundColour : source_color = vec4(0, 1, 0, 1);
uniform sampler2D groundTexture;
uniform sampler2D groundNormalMap;
uniform vec2 groundTiling;

//Bottom Layer
uniform vec4 detailColour : source_color = vec4(0, 0, 1, 1);
uniform sampler2D detailTexture;
uniform sampler2D detailNormalMap;
uniform vec2 detailTiling;



varying vec2 main_uv;
varying float normal_y;
varying float vert_y;

void vertex(){
	normal_y = NORMAL.y;
	vert_y = VERTEX.y;
}


void fragment() {
	float tex_blend = 0.5;

//0.955, 0.99
	float min_angle = 0.955;
	float max_angle = 1.01;

	float min_height = -8.0;
	float max_height = 10.0;

	float r_g_blend = normal_y;

	r_g_blend = max(min_angle, r_g_blend);
	r_g_blend = min(max_angle, r_g_blend);
	r_g_blend -= min_angle;
	r_g_blend /= max_angle - min_angle;

	float s_g_blend = vert_y;
	s_g_blend = max(min_height, s_g_blend);
	s_g_blend = min(max_height, s_g_blend);
	s_g_blend -= min_height;
	s_g_blend /= max_height - min_height;

	float b_blend = clamp(texture(heightMapTexture, UV).r / tex_blend, 0.0, 1.0);
	float t_blend = clamp(texture(heightMapTexture, UV).r / (heightOffset * tex_blend), 0.0, 1.0);

	vec3 c0 = mix(detailColour, groundColour, b_blend).rgb;
	vec3 c1 = mix(c0, rockColour.rgb, t_blend).rgb;

	vec3 t0 = mix(texture(rockTexture, UV * rockTiling).rgb, texture(groundTexture, UV * groundTiling * 100.0).rgb, r_g_blend);
	vec3 t1 = mix(texture(detailTexture, UV * detailTiling * 100.0).rgb, t0, s_g_blend);

	vec3 n0 = mix(texture(rockNormalMap, UV * rockTiling).rgb, texture(groundNormalMap, UV * groundTiling * 100.0).rgb, r_g_blend);
	vec3 n1 = mix(texture(detailNormalMap, UV * detailTiling * 100.0).rgb, n0, s_g_blend);

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
