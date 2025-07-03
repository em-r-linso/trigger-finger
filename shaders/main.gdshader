shader_type spatial;
render_mode world_vertex_coords, unshaded;

uniform sampler2D texture_albedo;

void fragment() {
	vec4 texture_color = texture(texture_albedo, UV);
	ALBEDO = texture_color.rgb;
}

void vertex() {
	float snap_amount = 0.02;

	vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
	vec4 view_pos = VIEW_MATRIX * world_pos;
	view_pos.xyz = floor(view_pos.xyz / snap_amount) * snap_amount;
	vec4 snapped_world_pos = inverse(VIEW_MATRIX) * view_pos;
	VERTEX = (inverse(MODEL_MATRIX) * snapped_world_pos).xyz;
}