shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); // Cyan glow
uniform float glow_intensity : hint_range(0.1, 5.0) = 2.0;
uniform float pulse_speed : hint_range(0.1, 10.0) = 2.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV); // Get texture color
    float alpha = tex_color.a; // Keep original transparency

    // Pulsing glow using sine function
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

    // Apply glow color based on texture alpha
    vec4 glow = glow_color * glow_intensity * pulse * alpha;

    // Additive blending: keeps texture visible while adding glow
    COLOR = tex_color + glow;
    COLOR.a = tex_color.a; // Keep original transparency
}
