shader_type spatial;

render_mode vertex_lighting;

uniform float heightOffset = 2;
uniform sampler2D heightMapTexture;

//Splat_0
uniform sampler2D splat_0;

uniform sampler2D splat_0_0;
uniform vec2 splat_0_0_uv;

uniform sampler2D splat_0_r;
uniform vec2 splat_0_r_uv;

uniform sampler2D splat_0_g;
uniform vec2 splat_0_g_uv;

uniform sampler2D splat_0_b;
uniform vec2 splat_0_b_uv;

//Splat_1
uniform sampler2D splat_1;

uniform sampler2D splat_1_0;
uniform vec2 splat_1_0_uv;

uniform sampler2D splat_1_r;
uniform vec2 splat_1_r_uv;

uniform sampler2D splat_1_g;
uniform vec2 splat_1_g_uv;

uniform sampler2D splat_1_b;
uniform vec2 splat_1_b_uv;

//Splat_2
uniform sampler2D splat_2;

uniform sampler2D splat_2_0;
uniform vec2 splat_2_0_uv;

uniform sampler2D splat_2_r;
uniform vec2 splat_2_r_uv;

uniform sampler2D splat_2_g;
uniform vec2 splat_2_g_uv;

uniform sampler2D splat_2_b;
uniform vec2 splat_2_b_uv;

// Mix variables
varying vec3 mix_0_1;
varying vec3 mix_1_1;
varying vec3 mix_2_1;

varying vec3 mix_0_2;
varying vec3 mix_1_2;
varying vec3 mix_2_2;

varying vec3 mix_0_3;
varying vec3 mix_1_3;
varying vec3 mix_2_3;

varying float weight_0;
varying float weight_1;

varying vec2 main_uv;
varying float normal_y;
varying float vert_y;

void vertex(){
	normal_y = NORMAL.y;
	vert_y = VERTEX.y;
}


void fragment() {
	vec3 splat_tex_0 = texture(splat_0, UV).rgb;
	vec3 splat_tex_1 = texture(splat_1, UV).rgb;
	vec3 splat_tex_2 = texture(splat_2, UV).rgb;
	
	weight_0 = (splat_tex_1.r + splat_tex_1.g + splat_tex_1.b)/3.0;
	weight_1 = (splat_tex_2.r + splat_tex_2.g + splat_tex_2.b)/3.0;
	
//	Splat 0
	vec3 tex_0 = texture(splat_0_0, UV * splat_0_0_uv * 100.0).rgb;
	vec3 tex_1 = texture(splat_0_r, UV * splat_0_r_uv * 100.0).rgb;
	vec3 tex_2 = texture(splat_0_g, UV * splat_0_g_uv * 100.0).rgb;
	vec3 tex_3 = texture(splat_0_b, UV * splat_0_b_uv * 100.0).rgb;
	
// Splat 1
	vec3 tex_4 = texture(splat_1_0, UV * splat_1_0_uv * 100.0).rgb;
	vec3 tex_5 = texture(splat_1_r, UV * splat_1_r_uv * 100.0).rgb;
	vec3 tex_6 = texture(splat_1_g, UV * splat_1_g_uv * 100.0).rgb;
	vec3 tex_7 = texture(splat_1_b, UV * splat_1_b_uv * 100.0).rgb;
	
//	Splat 2
	vec3 tex_8 = texture(splat_2_0, UV * splat_2_0_uv * 100.0).rgb;
	vec3 tex_9 = texture(splat_2_r, UV * splat_2_r_uv * 100.0).rgb;
	vec3 tex_10 = texture(splat_2_g, UV * splat_2_g_uv * 100.0).rgb;
	vec3 tex_11 = texture(splat_2_b, UV * splat_2_b_uv * 100.0).rgb;
	
	mix_0_1 = mix(tex_0, tex_1, splat_tex_0.r);
	mix_0_2 = mix(mix_0_1, tex_2, splat_tex_0.g);
	mix_0_3 = mix(mix_0_2, tex_3, splat_tex_0.b);
	
	mix_1_1 = mix(tex_4, tex_5, splat_tex_1.r);
	mix_1_2 = mix(mix_1_1, tex_6, splat_tex_1.g);
	mix_1_3 = mix(mix_1_2, tex_7, splat_tex_1.b);
	
	mix_2_1 = mix(tex_8, tex_9, splat_tex_2.r);
	mix_2_2 = mix(mix_2_1, tex_10, splat_tex_2.g);
	mix_2_3 = mix(mix_2_2, tex_11, splat_tex_2.b);
	
	vec3 final_mix_0 = mix(mix_0_3, mix_1_3, weight_0);
	vec3 final_mix = mix(final_mix_0, mix_2_3, weight_1);
	
	ALBEDO = mix_0_3;
	SPECULAR = 0.0;
	METALLIC = 1.0;
	ROUGHNESS = 1.0;
}
