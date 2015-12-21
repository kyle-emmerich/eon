uniform Image canvas_diffuse;
uniform Image canvas_info;
uniform vec2 canvas_size;
uniform vec3 light_pos;
uniform vec4 light_color;
uniform float light_radius;
uniform float specularity = 1.0;

vec4 effect(vec4 color, Image unused, vec2 texture_coords, vec2 screen_coords) {
	vec2 coords = screen_coords / canvas_size;
	vec4 diffuse = Texel(canvas_diffuse, coords);
	vec4 info = Texel(canvas_info, coords);

	vec3 normal = info.rgb;
	normal *= 2.0;
	normal -= 1.0;

	vec3 pos = vec3(screen_coords.xy, 0.0);
	vec3 light_dir = light_pos - pos;
	float dist = length(light_dir);
	vec3 L = light_dir / dist;
	vec3 view = vec3(0.0, 0.0, -1.0);
	vec3 half_vec = (view + L) * 0.5;

	vec3 lighting = light_color.rgb * max(0.0, dot(normal, L));
	float specular = pow(max(0.0, dot(half_vec, normal)), specularity);

	float light_min = 0.1;
	float light_atten_a = 0.005;
	float light_atten_b = 1.0 / (light_radius * light_radius * light_min);
	float atten = 1.0 / (1.0 + light_atten_a * dist + light_atten_b * dist * dist);

	return vec4(lighting.rgb * atten * diffuse.a, min(1.0, specular));
}