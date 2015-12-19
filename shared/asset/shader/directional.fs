uniform vec3 light_dir;
uniform vec4 light_color;
uniform float specularity = 1.0;

vec4 effect(vec4 color, Image canvas_info, vec2 texture_coords, vec2 screen_coords) {
	vec4 info = Texel(canvas_info, texture_coords);

	vec3 normal = info.rgb;
	float occlusion = info.a;

	normal *= 2.0;
	normal -= 1.0;
	normal *= vec3(1.0, -1.0, 1.0);


	vec3 L = -light_dir;
	vec3 view = vec3(0.0, -1.0, 0.0);
	vec3 half = (view + L) * 0.5;

	vec3 lighting = light_color.rgb * max(0.0, dot(normal, L));
	float specular = pow(max(0.0, dot(half, normal)), specularity);

	return vec4(lighting.rgb, specular);
}