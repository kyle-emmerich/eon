uniform Image canvas_light;
uniform Image canvas_info;

vec4 effect(vec4 color, Image canvas_diffuse, vec2 texture_coords, vec2 screen_coords) {
	vec4 diffuse = Texel(canvas_diffuse, texture_coords);
	vec4 info = Texel(canvas_info, texture_coords);
	vec4 light = Texel(canvas_light, texture_coords);

	float occlusion = info.a;
	light.rgba *= occlusion;

	vec3 combined = (diffuse.rgb * light.rgb) + light.a;
	return vec4(combined.rgb * diffuse.a, 1.0);
}