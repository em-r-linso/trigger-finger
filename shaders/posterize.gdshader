shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

const vec3[16] COLOR_PALETTE = vec3[](
    vec3(0, 0, 0),
    vec3(1, 1, 1),
    vec3(0.533, 0, 0),
    vec3(0.667, 1, 0.933),
    vec3(0.8, 0.267, 0.8),
    vec3(0, 0.8, 0.333),
    vec3(0, 0, 0.667),
    vec3(0.933, 0.933, 0.467),
    vec3(0.867, 0.533, 0.333),
    vec3(0.4, 0.267, 0),
    vec3(1, 0.467, 0.467),
    vec3(0.2, 0.2, 0.2),
    vec3(0.467, 0.467, 0.467),
    vec3(0.667, 1, 0.4),
    vec3(0, 0.533, 1),
    vec3(0.733, 0.733, 0.733)
);

vec3 find_nearest_color(vec3 input_color) {
    vec3 nearest_color = COLOR_PALETTE[0];
    float min_distance = distance(input_color, COLOR_PALETTE[0]);

    for (int i = 1; i < 16; i++) {
        float d = distance(input_color, COLOR_PALETTE[i]);
        if (d < min_distance) {
            min_distance = d;
            nearest_color = COLOR_PALETTE[i];
        }
    }
    return nearest_color;
}

void fragment() {
    vec4 screen_color = texture(screen_texture, SCREEN_UV);
    COLOR = vec4(find_nearest_color(screen_color.rgb), 1.0);
}