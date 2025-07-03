shader_type canvas_item;

uniform float bar_height = 8.0;
uniform float scroll_speed = 1.0;
uniform float horizontal_offset = 0.001;
uniform float flicker_rate = 0.2;
uniform float flicker_interval = 0.1; // seconds between flicker checks
uniform float noise_rate = 0.5;
uniform int x_pixel_size = 5;
uniform int y_pixel_size = 5;

// random functions adapted from https://godotshaders.com/snippet/random-value/
float random_uv(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}
float random_time(float time) {
	vec2 uv = vec2(time, time);
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

 //pixelate function adapted from https://godotshaders.com/shader/pixelate-3/
vec2 pixelate(vec2 uv, vec2 texture_pixel_size) {
	vec2 correction = texture_pixel_size * vec2(float(x_pixel_size), float(y_pixel_size)) / vec2(2.0);
	vec2 texture_uv = floor(uv / texture_pixel_size);
	vec2 offset = vec2(float(int(texture_uv.x) % x_pixel_size), float(int(texture_uv.y) % y_pixel_size));
	vec2 target = (texture_uv - offset) * texture_pixel_size;
	return target + correction;
}

void fragment() {
    vec2 uv = UV;
	float quantized_time = floor(TIME / flicker_interval);
 
	// normal resolution
	if (random_time(quantized_time) > flicker_rate) {
		
		// scrolling noise
		if (random_uv(uv) > noise_rate) {
		    float y_shift = step(0.5, fract(uv.y * bar_height + TIME * scroll_speed)) * horizontal_offset;
		    uv.x += y_shift;
			
		    COLOR = texture(TEXTURE, uv);
		}
	}
	
	// really big pixels
	else if (random_time(quantized_time) > flicker_rate / 2.0) {
		uv = pixelate(uv, TEXTURE_PIXEL_SIZE * 2.0);
		COLOR = texture(TEXTURE, uv);
	}
	
	// big pixels
	else {
		uv = pixelate(uv, TEXTURE_PIXEL_SIZE);
		COLOR = texture(TEXTURE, uv);
	}
}