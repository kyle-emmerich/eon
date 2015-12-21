uniform Image normal_tex;
uniform Image custom_tex;
uniform Image occlusion_tex;
uniform vec4 custom_color;
uniform vec4 ambient_light;
uniform float rotation;
uniform vec2 velocity;

vec3 light_dir = normalize(vec3(1.0, 0.0, -0.5));

vec4 alpha_blend(vec4 src, vec4 dst) {
	return vec4(dst.a) * dst + vec4(1.0 - dst.a) * src;
}

void effects(vec4 color, Image diffuse_tex, vec2 texture_coords, vec2 screen_coords) {
	vec4 diffuse = Texel(diffuse_tex, texture_coords);
	diffuse.rgb *= diffuse.a;
	vec3 normal = pow(Texel(normal_tex, texture_coords).yxz, vec3(2.2));
	vec4 custom = Texel(custom_tex, texture_coords) * custom_color;
	float occlusion = pow(Texel(occlusion_tex, texture_coords).r, 2.2);

	normal *= 2.0;
	normal -= 1.0;
	normal.x *= -1.0;

	vec3 world = normal.xyz;
	world.x = normal.x * cos(rotation) + normal.y * sin(rotation);
	world.y = normal.x * sin(rotation) - normal.y * cos(rotation);
	world.z = normal.z;
	world = normalize(world);

	world *= 0.5;
	world += 0.5;

	diffuse = alpha_blend(diffuse, custom);
	love_Canvases[0] = diffuse;
	love_Canvases[1] = vec4(world.xyz, occlusion * diffuse.a);
	love_Canvases[2] = vec4(velocity.xy, 0.0, diffuse.a);
}