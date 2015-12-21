uniform Image canvas_velocity;
uniform vec2 canvas_size;

const int NUM_SAMPLES = 64;

vec4 effect(vec4 color, Image canvas_scene, vec2 texture_coords, vec2 screen_coords) {
	vec2 velocity = Texel(canvas_velocity, texture_coords).xy;
	vec4 col = Texel(canvas_scene, texture_coords);
	for (int i = 1; i < NUM_SAMPLES; ++i) {
		vec2 offset = velocity * (float(i) / float(NUM_SAMPLES - 1) - 0.5);
		offset /= canvas_size;
		vec4 s = Texel(canvas_scene, texture_coords + offset);
		col += vec4(s.xyz * s.a, 0.0);
	}
	vec4 result = col / float(NUM_SAMPLES);
	result.a = 1.0;

	return result;
}