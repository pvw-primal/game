// NOTE: Shader automatically converted from Godot Engine 4.1.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_lambert,specular_schlick_ggx;

uniform sampler2D texture_albedo : source_color,filter_nearest_mipmap,repeat_disable;

uniform sampler2D texture_metallic : hint_default_white,filter_nearest_mipmap,repeat_disable;
//uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_nearest_mipmap,repeat_disable;

uniform sampler2D texture_emission : source_color, hint_default_black,filter_nearest_mipmap,repeat_disable;
const vec4 emission = vec4(0, 0, 0, 1);
const float emission_energy = .8;

const float alpha_scissor_threshold = 0.5;
const float roughness = 1.0;
const float specular = 0.5;
const float metallic = 0.0;

const float TOLERANCE = .01;

instance uniform vec3 replaceR = vec3(.45, .4, .4);
instance uniform vec3 replaceG = vec3(.5, .5, 1);
instance uniform vec3 replaceB = vec3(.5, .5, 1);

void vertex() {
	//UV = UV * vec2(.5, .5);
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	if (albedo_tex.r > TOLERANCE && albedo_tex.b < TOLERANCE && albedo_tex.g < TOLERANCE){
		ALBEDO = replaceR;
	}
	else if (albedo_tex.g > TOLERANCE && albedo_tex.b < TOLERANCE && albedo_tex.r < TOLERANCE){
		ALBEDO = replaceG;
	}
	else if (albedo_tex.b > TOLERANCE && albedo_tex.r < TOLERANCE && albedo_tex.g < TOLERANCE){
		ALBEDO = replaceB;
	}
	else {
		ALBEDO = albedo_tex.rgb;
	}
	//ALBEDO *= COLOR.rgb;
	//ALBEDO = albedo.rgb * albedo_tex.rgb;
//	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
//	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	vec3 emission_tex = ALBEDO;
	EMISSION = (emission.rgb+emission_tex)*emission_energy;
	ALPHA *= albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}


