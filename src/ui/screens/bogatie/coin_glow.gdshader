shader_type canvas_item;

uniform float speed = 0.5; // Speed of the moving white line
uniform float width = 0.9; // Width of the white line
uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); // Cyan glow
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Base color for the coin
uniform float left_width : hint_range(0.0, 1.0) = 0.5;
uniform float right_width : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 pixelColor = texture(TEXTURE, UV);
    float brightness = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;
    vec4 grayScale = vec4(brightness, brightness, brightness, pixelColor.a);
    
    // Calculate the moving wave effect using a sine function
    float time_offset = fract(TIME * speed);
    //float wave = sin((UV.y + time_offset) * TAU) * 0.9 + 0.1; // Sin wave mapped to [0,1]
    float diagonal_wave = sin(((UV.x + UV.y) * 1.0 + time_offset) * TAU) * 0.9 + 0.01; // Increased frequency diagonally
    float line_effect = smoothstep(left_width - width, right_width + width, diagonal_wave);
    
    // Apply base color and glow effect
    vec4 finalColor = mix(pixelColor * base_color, glow_color, line_effect * pixelColor.a);
    COLOR = finalColor;
}
