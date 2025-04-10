shader_type canvas_item;

uniform float outline_width = 1.0; // Base width of the outline
uniform float pulse_speed = 10.0;   // Speed of the pulsation
uniform float pulse_amplitude = 2.0; // How much the outline expands/contracts
uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red color

void fragment() {
    // Get the original texture color
    vec4 sprite_color = texture(TEXTURE, UV);

    // Calculate the pulsating width
    float time_factor = sin(TIME * pulse_speed) * pulse_amplitude;
    float current_width = outline_width + time_factor;

    // Sample neighboring pixels to detect edges
    float alpha = sprite_color.a;
    vec2 pixel_size = TEXTURE_PIXEL_SIZE; // Size of one pixel in UV space

    // Check surrounding pixels for outline
    float outline = 0.0;
    for (float x = -1.0; x <= 1.0; x += 1.0) {
        for (float y = -1.0; y <= 1.0; y += 1.0) {
            vec2 offset = vec2(x, y) * pixel_size * current_width;
            float neighbor_alpha = texture(TEXTURE, UV + offset).a;
            outline = max(outline, neighbor_alpha);
        }
    }

    // Create the glow effect
    float glow = outline - alpha; // Only show where there’s no sprite
    vec4 final_color = sprite_color;

    // Add the pulsating red outline
    if (glow > 0.0) {
        final_color.rgb = mix(final_color.rgb, outline_color.rgb, glow);
        final_color.a = max(final_color.a, glow * outline_color.a);
    }

    COLOR = final_color;
}