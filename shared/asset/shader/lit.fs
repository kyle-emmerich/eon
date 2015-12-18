uniform Image normal_tex;
uniform Image custom_tex;
uniform Image occlusion_tex;
uniform vec4 custom_color;
uniform vec4 ambient_light;
uniform float rotation;

vec3 light_dir = vec3(-0.0001, -0.0001, -1.0);

float norm = 1.0 / 3.14159;

vec4 alpha_blend(vec4 src, vec4 dst) {
	return vec4(dst.a) * dst + vec4(1.0 - dst.a) * src;
}

vec4 effect(vec4 color, Image diffuse_tex, vec2 texture_coords, vec2 screen_coords) {
	vec4 diffuse = Texel(diffuse_tex, texture_coords);
	vec3 normal = Texel(normal_tex, texture_coords).yxz;
	vec4 custom = Texel(custom_tex, texture_coords) * custom_color;
	vec4 occlusion = Texel(occlusion_tex, texture_coords);

	normal *= 0.5;
	normal -= 0.5;
	normal *= vec3(-1.0, -1.0, 1.0);

	vec3 world = vec3(0.0);
	world.x = normal.x * cos(-rotation) - normal.y * sin(-rotation);
	world.y = normal.x * sin(-rotation) + normal.y * cos(-rotation);
	world.z = normal.z;
	world = normalize(world);

	vec3 view = vec3(0.0, 1.0, 0.0);
	vec3 half = (view + light_dir) * 0.5;

	vec4 lighting = max(0.0, dot(world, light_dir)) * occlusion + ambient_light * 2.0;
	lighting.a = 1.0;
	vec4 specular = vec4(pow(max(0.0, dot(half, world)), 16.0));
	specular.a = 0.0;
	//TODO: sum up light contributions

	

	vec4 blended = alpha_blend(diffuse, custom);
	return blended * color * lighting + specular;
}